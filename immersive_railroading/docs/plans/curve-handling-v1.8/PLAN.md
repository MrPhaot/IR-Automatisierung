# Curve Handling V1.8: Handoff for `test26` Terminal-Regler Stall and Premature Stop-Phase Failure

## Zusammenfassung
- Dieser Handoff ersetzt `curve-handling-v1.7` als aktuellen Arbeitskontext.
- Der neue Kernbefund ist nicht, dass der globale PID grundsätzlich falsch wäre. Das aktuelle Restproblem sitzt in der Terminal-Schicht und würgt den physikbasierten Regler im `fast`-Profil zu hart ab.
- `test26` zeigt zwei gekoppelte Fehler:
  1. in `guidance_mode=route` bleibt `buffer_approach` aktiv, aber `throttle` fällt trotz positivem `terminal_buffer_target_speed` auf `0.00`
  2. nach `stop_guidance_entry` kann `terminal_failure_pending` anlaufen, während die Deadlock-Recovery noch auf `waiting_for_deadlock_timer` steht
- Ziel ist ein ausgereifter Fix, der den vorhandenen PID-Kern beibehält, aber die Terminal-Regelung so umbaut, dass sie im Endspiel weder den Vortrieb verhungern lässt noch Failure vor Recovery starten kann.

## Aktueller Stand und Diagnose
- Produktionsdatei bleibt ausschließlich `programs/train_controller.lua`.
- Der PID-Kern ist weiterhin physikbasiert in `derive_pid(...)`.
- Relevante bestätigte Codepunkte:
  - `derive_pid(...)`
  - `can_enter_stop_guidance(...)`
  - der Terminalblock in `run_route_leg(...)`
  - der aktuelle `v1.7`-Emergency-Throttle-Patch im Terminal-Route-Guidance-Drive-Branch
- Relevante bestätigte Logbefunde aus `path_test26.log`:
  - vor `stop_guidance`:
    - `reason=buffer_approach`
    - `guidance_mode=route`
    - `stop_guidance_block_reason=outside_capture_window`
    - `terminal_buffer_target_speed` bleibt positiv (`~1.43..2.04m/s`)
    - `speed_toward_target` liegt darunter (`~0.90..1.01m/s`)
    - trotzdem `throttle=0.00`, `brake=0.00`
  - erst bei `physical_distance=7.89m` erfolgt `stop_guidance_entry`
  - danach:
    - `reason=approach_stop`, dann `final_brake_hold`
    - `buffer_settle_block_reason=waiting_for_deadlock_timer`
    - gleichzeitig `terminal_failure_pending=true`
    - kurz darauf `terminal_limit_exit reason=stalled_outside_v1_limit`
- Daraus folgt:
  - der `v1.7`-Fix adressiert nur den Sonderfall knapp außerhalb des Capture-Windows
  - `test26` scheitert aber im normalen Soft-Zone-`buffer_approach` innerhalb der aktiven Terminal-Pufferregelung
  - der zweite Fehler ist ein Reihenfolgefehler in Stop-Guidance: Failure darf anlaufen, obwohl Recovery noch bewusst auf den Stall-Timer wartet

## Implementierungsänderungen
- **Nicht ändern**
  - keine Neugestaltung von Route-Geometrie, Waypoints, CLI oder `route_book`
  - kein genereller PID-Neuentwurf
  - kein Logger-Redesign
- **Zielbild**
  - der Terminal-Approach bleibt physikbasiert, bekommt aber eine explizite adaptive `progress-floor`-Regel im `buffer_approach`
  - diese Regel greift nur im engen Terminal-Kontext
  - Deadlock-Recovery und Failure werden zeitlich sauber entkoppelt

### 1. Ersetze den `v1.7`-Emergency-Fix durch einen echten Terminal-Progress-Floor
- Das bisherige Muster
  - `terminal_buffer_throttle_limit` erhöhen
  - einmalige `emergency_min_throttle`
  - nur knapp oberhalb `capture_distance`
  reicht nicht aus.
- Stattdessen neue Hilfsfunktion einführen:
  - `terminal_buffer_progress_floor(profile, speed_toward_target_mps, buffer_target_speed_mps, throttle_limit)`
- Zweck:
  - wenn der Zug im Terminal-Route-Guidance-Approach sauber Richtung Ziel fährt
  - `buffer_approach` aktiv ist
  - `stop_guidance` nur wegen `outside_capture_window` blockiert ist
  - keine Bremse aktiv ist
  - und der PID-Effort unter das Deadband fällt,
  - dann soll ein kleiner adaptiver Vortriebs-Floor gesetzt werden
- Der Floor soll nicht als starre Einzelzahl modelliert werden, sondern aus vorhandenen Größen abgeleitet:
  - Basis: `DEFAULTS.throttle_deadband`
  - Skaliert mit:
    - Speed-Shortfall relativ zu `buffer_target_speed_mps`
    - Profil (`fast` stärker als `conservative`)
    - verfügbarem `throttle_limit`
- Konkrete Default-Form:
```lua
local function terminal_buffer_progress_floor(profile, speed_toward_target_mps, buffer_target_speed_mps, throttle_limit)
  if buffer_target_speed_mps <= 0 then
    return nil
  end

  local shortfall = math.max(buffer_target_speed_mps - math.max(speed_toward_target_mps, 0), 0)
  if shortfall <= DEFAULTS.arrival_speed_mps then
    return nil
  end

  local profile_scale = profile.name == "fast" and 1.0 or 0.6
  local base_floor = DEFAULTS.throttle_deadband + 0.01
  local adaptive_floor = base_floor + math.min(shortfall / math.max(buffer_target_speed_mps, 0.1), 1.0) * 0.02 * profile_scale
  return math.min(adaptive_floor, throttle_limit)
end
```
- Aktivierungsbedingungen vollständig festziehen:
  - `leg.mode == "terminal"`
  - `state.guidance_mode == "route"`
  - `buffer_target_speed_mps > 0`
  - `state.stop_guidance_block_reason == "outside_capture_window"`
  - `speed_toward_target_mps < buffer_target_speed_mps - DEFAULTS.arrival_speed_mps`
  - `overspeed < 0`
  - `terminal_buffer_brake_active == false`
  - `stop_context.in_no_reverse_approach == false`
- Deaktivierungsbedingungen:
  - `stop_guidance_ready == true`
  - `terminal_buffer_brake_active == true`
  - `speed_toward_target_mps >= buffer_target_speed_mps - DEFAULTS.arrival_speed_mps`
- Anwendung:
  - im bestehenden Drive-Branch nach `throttle = clamp(effort, 0, throttle_limit)`
  - im normalen `buffer_target_speed_mps > 0`-Pfad
  - nicht nur im bisherigen engen `emergency_threshold`-Zweig
- Der `v1.7`-Emergency-Zweig darf höchstens als sehr schmaler Zusatz-Fallback bleiben, aber nicht mehr der primäre Mechanismus sein.

### 2. Halte `fast` im Terminal-Approach wirklich auf `fast`-Niveau
- `test26` zeigt, dass `fast` im letzten Pufferapproach zu defensiv wird.
- Dafür die Soft-Zone leicht aggressiver machen, ohne Capture-Geometrie umzubauen.
- Entscheidung vollständig festziehen:
  - `PROFILES.fast.terminal_buffer_final_speed_cap_mps`: `0.7 -> 0.9`
  - `PROFILES.fast.terminal_buffer_throttle_limit`: unverändert bei `0.05`
  - `PROFILES.fast.terminal_buffer_capture_distance_m`: unverändert bei `5.0`
- Begründung:
  - `fast` läuft im kritischen Bereich bereits mit `~0.9..1.0m/s`, obwohl der Zielwert höher wäre
  - ein etwas höherer finaler Speed-Cap stützt den Progress-Floor, ohne eine neue Geometriephase zu erfinden

### 3. Failure darf nicht früher anlaufen als die Deadlock-Recovery
- In Stop-Guidance muss die Failure-Logik explizit auf den Deadlock-Wartezustand Rücksicht nehmen.
- Konkreter beobachteter Fehler:
  - `buffer_settle_block_reason=waiting_for_deadlock_timer`
  - gleichzeitig `terminal_failure_pending=true`
- Konkrete Änderung:
  - im Aufrufer von `should_fail_terminal_limit(...)` einen Guard ergänzen:
    - wenn `buffer_settle_block_reason == "waiting_for_deadlock_timer"`, dann `terminal_limit_failure = false`
- Diese Lösung ist bevorzugt gegenüber einer tiefen Änderung in `should_fail_terminal_limit(...)`, damit die Failure-Funktion selbst allgemein bleibt.
- Ziel:
  - solange Recovery noch absichtlich auf Stall-Timer wartet, darf kein `terminal_failure_pending` gesetzt werden
  - erst nach Ablauf des Timers und weiterhin fehlender Recovery darf Failure anfangen

### 4. Deadlock-Timer sauber an realen Stillstand binden
- Der existierende `target_ahead_stalled`-Pfad bleibt erhalten.
- Die Timer-Initialisierung soll aber enger mit echter Stagnation gekoppelt werden:
  - nicht nur „speed sehr klein“
  - zusätzlich „Fortschritt pro Tick nahezu null“
- Konkrete Vorgabe:
  - `target_ahead_stalled` zusätzlich an `progress_speed <= DEFAULTS.terminal_deadlock_stall_speed_mps` binden
  - falls `progress_speed` im Block nicht direkt verfügbar ist, äquivalent über sehr kleine `distance_delta` oder eine vorhandene Fortschrittsgröße lösen
- Ziel:
  - kein Deadlock-Timer während normaler Bremsphase
  - Deadlock-Timer erst, wenn der Zug wirklich steht oder fast steht

### 5. Preview- und Harness-Abdeckung ausbauen
- Bestehende Preview-Abdeckung beibehalten.
- Neu ergänzen:
  - `buffer_approach`-Fall mit aktivem `buffer_target_speed_mps`, `outside_capture_window`, positivem Shortfall und zu kleinem PID-Effort:
    - erwartetes Ergebnis: `terminal_buffer_progress_floor(...)` liefert Wert > Deadband
  - Profilvergleich:
    - `fast`-Floor > `conservative`-Floor bei gleichem Shortfall
  - Stop-Guidance-Failure-Race:
    - wenn `buffer_settle_block_reason == "waiting_for_deadlock_timer"`, dann darf kein Failure-Pending ausgelöst werden
  - Regression:
    - alter `test23`-Sonderfall knapp außerhalb Capture-Window bleibt abgedeckt
- Falls der Harness stabil ist:
  - vor/nach Counts für:
    - `reason=buffer_approach`
    - `stop_guidance_block_reason=outside_capture_window`
    - `terminal_limit_exit`
    - `final_brake_hold`

## Testplan
- **Primärfall `test26`**
  - im Terminal-Route-Guidance-Approach darf der Zug nicht mehr mit:
    - `buffer_target_speed_mps > speed_toward_target_mps`
    - `throttle=0.00`
    - `brake=0.00`
    - `reason=buffer_approach`
    hängenbleiben
  - `stop_guidance_entry` soll früher oder robuster erreichbar sein
  - nach `stop_guidance_entry` darf `terminal_failure_pending` nicht bereits während `waiting_for_deadlock_timer` anlaufen
- **Regression `test23`**
  - der alte pre-stop route stall darf nicht zurückkommen
- **Regression `test20`**
  - kein endloses `final_brake_hold`
- **Regression `test19`**
  - weiterhin keine falsche Erfolgsfreigabe
- **Profilverhalten**
  - `fast` bleibt im Terminal-Approach klar assertiver als `conservative`
  - ohne neues Overshoot-Pendeln
- **Lokale Prüfungen**
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
  - zusätzliche Preview- oder Harness-Checks für die neuen Guards

## Annahmen
- Der globale PID-Kern bleibt erhalten; der Fix sitzt in der Terminal-Regelschicht.
- Die `v1.7`-Änderungen sind als Zwischenversuch zu betrachten, nicht als finale Richtung.
- Der nächste Agent soll einen ausgereiften Funktionsfix bauen, keinen weiteren Minimal-Hack nur über einzelne magische Schwellwerte.
