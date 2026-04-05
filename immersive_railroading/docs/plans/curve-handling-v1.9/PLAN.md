# Curve Handling V1.9: Root-Cause Handoff for `test26`/`test27`

## Zusammenfassung
- Dieser Handoff ersetzt `curve-handling-v1.8` als aktuellen Arbeitskontext.
- Der neue Kernbefund ist nicht, dass der globale PID grundsätzlich falsch wäre.
- Der neue Kernbefund ist auch nicht, dass noch einmal Brake-/Throttle-Schwellen blind nachgetunt werden müssten.
- Das verbleibende Problem ist ein Zustands- und Signalschnittstellenfehler im Terminal-Stop-Pfad:
  - der Stop-Guidance-Deadlockpfad nutzt noch `state.progress_speed_mps`
  - dieses Signal wechselt beim `stop_guidance_entry` aber unbemerkt seinen Bezugsrahmen
  - dadurch wird Stillstand relativ zum Stop-Ziel nicht sauber erkannt
  - in `test27` bleibt `waiting_for_deadlock_timer` aktiv, ohne dass `terminal_deadlock_candidate_since` sinnvoll altern kann
- Ziel ist ein sauberer Root-Cause-Fix mit separatem stop-lokalem Fortschrittssignal, nicht ein weiterer Minimalpatch über neue magische Zahlen.

## Verifizierter lokaler Stand
- `luac -p programs/train_controller.lua` ist aktuell grün.
- `lua tests/previews/controller_preview.lua` ist aktuell grün.
- Aktuell verifizierte Preview-Ausgaben:
  - `pid ok: kp=0.0941 ki=0.0109 kd=0.4500`
  - `brake learning ok: 1.230 m/s^2`
  - `stop profile ok: 7.36 m/s at 25m, 21.24 m/s at 400m`
  - `lateral frame regression ok: 15.28 m/s cap stays above zero`
  - `axis capture regression ok: sideways startup jitter rejected`
  - `target line axis regression ok: target geometry stays primary over early motion samples`
  - `approach stop regression ok: late braking is forced near the target`
  - `overshoot recovery regression ok: small overshoot keeps braking before reverse recovery`
  - `terminal brake hold regression ok: approach stop does not release the brake too early`
  - `off-target line regression ok: large residual miss is not treated as a valid terminal arrival`
  - `curve guard regression ok: bends do not immediately trigger moving-away braking`
  - `startup guard regression ok: early shallow regressions do not trigger stop-and-go`
  - `interrupt regression ok: interrupted and terminated reasons are recognized`
  - `canonical import regression ok: preview uses production defaults, profiles, and lookup paths`
  - `characteristic extraction ok: mass=100493 traction=194161 power=1900789W`
- `tests/previews/test_outside_capture_window.lua` existiert bereits und soll grün bleiben.

## Technische Root-Cause-Diagnose
- Produktionsdatei bleibt ausschließlich `programs/train_controller.lua`.
- Relevante bestätigte Codepunkte:
  - `terminal_buffer_progress_floor(...)`
  - `terminal_failure_arming_allowed(...)`
  - `target_ahead_stalled` im Stop-Guidance-Block von `run_route_leg(...)`
  - `forward_deadlock_recovery_block_reason(...)`
  - der `stop_guidance_entry`-Pfad in `run_route_leg(...)`
- Hauptursache präzise:
  - `state.progress_speed_mps` wird in `run_route_leg(...)` zunächst relativ zum physischen Ziel fortgeschrieben
  - beim `stop_guidance_entry` wechselt die Führungsgeometrie aber von `distance_to_physical_target_m` auf `distance_to_stop_target_m`
  - das Fortschrittssignal bleibt dennoch derselbe Verlaufskanal
  - dadurch enthält `state.progress_speed_mps` nach dem Zielrahmenwechsel keinen sauberen Nachweis von "steht wirklich fast still relativ zum Stop-Ziel"
- Folgefehler:
  - Deadlock-Erkennung in Stop-Guidance bewertet Stagnation auf Basis eines kontaminierten Signals
  - `waiting_for_deadlock_timer` kann dadurch wiederholt aktiv bleiben
  - `terminal_deadlock_candidate_since` reift nicht verlässlich aus
  - `deadlock_forward_recovery` wird praktisch blockiert, obwohl Failure korrekt serialisiert bleibt

## Pflichtbefunde aus den Logs
- `test23`
  - alter Pre-Stop-Route-Stall
  - kein `stop_guidance_entry`
  - wiederholtes `reason=buffer_approach`
- `test26`
  - `stop_guidance_entry` wieder vorhanden
  - Übergang in `final_brake_hold`
  - früher noch Failure-vor-Recovery-Race
- `test27`
  - Failure-Guard greift jetzt
  - `terminal_failure_pending=false` bleibt korrekt
  - aber `waiting_for_deadlock_timer` wiederholt sich
  - der Lauf endet nicht in Recovery, sondern hängt bis zum Nutzerabbruch
- Pflichtschluss:
  - `aaae838` war ein sinnvoller Zwischenfix
  - die neue Hauptursache ist jetzt die fehlerhafte Wiederverwendung des globalen Fortschrittssignals nach dem Stop-Zielwechsel

## Implementierungsänderungen
- **Nicht ändern**
  - keine Route-Geometrie-Neudefinition
  - keine Waypoint-Semantik-Änderung
  - keine CLI- oder `route_book`-Änderung
  - kein globaler PID-Umbau
  - kein Logger-Redesign
  - kein weiteres blindes Tuning nur über `terminal_deadlock_stall_time_s`, `terminal_buffer_throttle_limit`, `brake_window` oder `deadband`

### 1. Separaten Stop-Guidance-Fortschrittskanal einführen
- In `begin_leg(...)` neue State-Felder ergänzen:
  - `stop_previous_distance_to_target_m = nil`
  - `stop_distance_delta_m = 0`
  - `stop_progress_speed_mps = 0`
  - `stop_progress_initialized = false`
- Diese Felder sind ausschließlich für `guidance_mode == "stop"` zuständig.
- Der bestehende globale Fortschrittskanal bleibt für Route-Guidance und allgemeines Verlaufstracking erhalten.

### 2. Stop-Kanal explizit bei `stop_guidance_entry` initialisieren
- Beim Umschalten auf Stop-Guidance:
  - `state.stop_previous_distance_to_target_m = distance_to_stop_target_m`
  - `state.stop_distance_delta_m = 0`
  - `state.stop_progress_speed_mps = 0`
  - `state.stop_progress_initialized = true`
- Zusätzlich:
  - der physische Zielkanal darf nach dem Rahmenwechsel nicht als Deadlock-Stagnationsquelle weiterverwendet werden
  - insbesondere darf der Wechsel von physischem Ziel zu Stop-Ziel kein künstliches Progress-Sample erzeugen

### 3. Stop-Fortschritt nur relativ zum Stop-Ziel berechnen
- Nur im Stop-Guidance-Zweig:
```lua
local raw_stop_progress_speed_mps = 0
if state.stop_progress_initialized and state.stop_previous_distance_to_target_m then
  raw_stop_progress_speed_mps =
    (state.stop_previous_distance_to_target_m - distance_to_stop_target_m) / dt_s
end

state.stop_distance_delta_m = state.stop_previous_distance_to_target_m
  and (distance_to_stop_target_m - state.stop_previous_distance_to_target_m)
  or 0

state.stop_progress_speed_mps = ema(
  state.stop_progress_speed_mps,
  raw_stop_progress_speed_mps,
  DEFAULTS.distance_progress_memory_s,
  dt_s
) or raw_stop_progress_speed_mps

state.stop_previous_distance_to_target_m = distance_to_stop_target_m
```
- Beim ersten Sample nach dem Einstieg darf kein synthetischer Sprung vom physischen Ziel auf das Stop-Ziel entstehen.
- Außerhalb von Stop-Guidance:
  - Stop-Kanal entweder unangetastet lassen oder kontrolliert auf neutrale Werte halten
  - aber nicht zur Deadlock-Bewertung heranziehen

### 4. Deadlock-Stagnation auf den Stop-Kanal umstellen
- In `target_ahead_stalled` ersetzen:
  - `math.abs(state.progress_speed_mps) <= DEFAULTS.terminal_deadlock_stall_speed_mps`
- durch:
  - `math.abs(state.stop_progress_speed_mps) <= DEFAULTS.terminal_deadlock_stall_speed_mps`
- Unverändert beibehalten:
  - Gate über `speed_toward_target_mps`
  - Gate über `axis_speed_mps`
- Ziel:
  - Deadlock-Kandidat basiert auf echter Stop-relativer Stagnation
  - nicht mehr auf einem Verlaufssignal, das vor und nach `stop_guidance_entry` verschiedene Bezugsrahmen mischt

### 5. Failure-Serialisierung unverändert lassen
- `terminal_failure_arming_allowed(buffer_settle_block_reason)` bleibt bestehen.
- `waiting_for_deadlock_timer` darf Failure weiterhin blockieren.
- Diese Logik wird nicht ersetzt.
- Der Root-Cause-Fix besteht darin, den Deadlock-Timer endlich mit einem korrekten Stop-Signal arbeiten zu lassen.

### 6. Logging minimal, aber gezielt erweitern
- Im periodischen Terminal-Log ergänzen:
  - `stop_distance_delta`
  - `stop_progress_speed`
  - optional `stop_progress_initialized`
- Ziel:
  - künftige Real-Logs müssen zeigen, ob Deadlock auf sauberer Stop-Stagnation basiert
  - `test27`-artige Hänger sollen direkt über das Logbild diagnostizierbar sein

### 7. Route-Approach nur sekundär anfassen
- `terminal_buffer_progress_floor(...)` bleibt bestehen.
- Nur falls der Stop-Progress-Fix allein `test26`/`test27` nicht stabilisiert:
  - Aktivierungsbedingung leicht erweitern
  - insbesondere nicht mehr strikt an `not stop_context.in_no_reverse_approach` koppeln
- Das ist ausdrücklich nicht der Primärfix.

## Preview- und Verifikationsanforderungen
- Bereits geprüfte lokale Checks, die weiterhin grün bleiben müssen:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
  - `lua tests/previews/test_outside_capture_window.lua`

### Verbindliche Preview-Erweiterungen
1. **Stop-Progress-Reset-Preview**
   - prüft, dass beim `stop_guidance_entry` der stop-lokale Fortschrittskanal auf definierte Nullwerte gesetzt wird
   - kein künstlicher Sprung vom physischen Ziel auf das Stop-Ziel
2. **Deadlock-Signal-Source-Preview**
   - simuliert Stop-Guidance mit:
     - `speed_toward_target_mps ~= 0`
     - `axis_speed_mps ~= 0`
     - globales `progress_speed_mps` verfälscht
     - stop-lokales `stop_progress_speed_mps` korrekt nahe null
   - erwartetes Ergebnis:
     - Deadlock-Kandidat hängt nur am stop-lokalen Signal
3. **Waiting-Timer-Serialization-Preview**
   - bestätigt:
     - `terminal_failure_arming_allowed("waiting_for_deadlock_timer") == false`
   - bestehende Semantik bleibt stabil
4. **Outside-Capture-Regression-Preview**
   - der vorhandene Fall aus `tests/previews/test_outside_capture_window.lua` bleibt grün
5. **Optionaler Preview-Fall für das `test27`-Muster**
   - stop-guidance aktiv
   - `target_ahead`
   - `speed_toward_target_mps` und `axis_speed_mps` nahe null
   - stop-lokaler Fortschritt nahe null über mehrere Samples
   - erwartetes Ergebnis:
     - `terminal_deadlock_candidate_since` kann sichtbar altern

## Verbindliche lokale Abschlusschecks
- `luac -p programs/train_controller.lua`
- `lua tests/previews/controller_preview.lua`
- `lua tests/previews/test_outside_capture_window.lua`

## Falls möglich: Real-Log-Verifikation
- Neues Laufprotokoll gezielt prüfen auf:
  - `stop_guidance_entry`
  - `stop_progress_speed`
  - `waiting_for_deadlock_timer`
  - `terminal_deadlock_candidate_elapsed_s`
  - `deadlock_forward_recovery`
  - `terminal_failure_pending`
  - `terminal_limit_exit`

## Akzeptanzkriterien
- `test27`-Muster darf nicht mehr endlos in `waiting_for_deadlock_timer` hängen.
- `terminal_deadlock_candidate_elapsed_s` muss bei echtem Zielstillstand sichtbar wachsen.
- `deadlock_forward_recovery` muss prinzipiell wieder erreichbar sein.
- `terminal_failure_pending` darf während `waiting_for_deadlock_timer` weiterhin nicht gesetzt werden.
- `test23`-Stall vor `stop_guidance_entry` darf nicht zurückkommen.
- `test19` darf weiterhin keinen falschen Erfolg akzeptieren.
- `test20` darf nicht zurück in endloses `final_brake_hold` ohne Recovery-Pfad fallen.

## Annahmen
- Hauptproblem sitzt in der Wiederverwendung eines globalen Fortschrittssignals über einen Zielrahmenwechsel hinweg.
- `aaae838` bleibt konzeptionell richtig und wird nicht zurückgenommen.
- Der nächste Agent soll einen signaltechnisch sauberen Fix bauen, keinen weiteren Minimalpatch nur über neue Schwellenwerte.
