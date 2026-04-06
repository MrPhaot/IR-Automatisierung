# Fix-Plan: `cmd`-Oszillation trotz korrekter Zielgeschwindigkeit

## Zusammenfassung
- Der Planner ist nach aktuellem Stand nicht mehr der Hauptfehler: `speed_plan_command_mps` wirkt in der Terminalphase plausibel.
- Das verbleibende Problem sitzt in der **Regler-/Allocator-Schicht** und ist profilunabhängig.
- `test35` zeigt das Muster klar:
  - `speed_plan_command_mps` bleibt sinnvoll,
  - `d_term_active` ist vor Stop-Guidance in der Terminal-Routephase noch aktiv,
  - `effort_cmd` bzw. `allocated_throttle` springen bei sehr kleinen Istgeschwindigkeiten zu stark.
- `test36` ist für die Terminaldiagnose nicht brauchbar, weil der Lauf vor der relevanten Endphase abgebrochen wurde.
- Die wahrscheinliche Restursache ist eine Kombination aus:
  1. zu direkte Verwendung des gemessenen `speed_toward_target_mps` als Reglerinput,
  2. noch aktiver D-Anteil in der Terminal-Routephase,
  3. fehlender **Effort-/Aktuator-Slew-Limitierung**,
  4. zu hoher Reglerautorität im Terminal relativ zur gewünschten Feinbewegung.

## Implementierungsänderungen
- **1. Eigenen Regler-Messkanal einführen**
  - Neuer State-Kanal nur für die Längsregelung:
    - `controller_speed_mps`
    - `previous_controller_speed_mps`
  - Bildung:
    - `controller_speed_mps = ema(previous_controller_speed_mps, speed_toward_target_mps, DEFAULTS.speed_filter_memory_s, dt_s)`
  - Verwendung:
    - `speed_error = speed_plan.speed_command_mps - controller_speed_mps`
    - D-Messung nur auf `controller_speed_mps`, nicht direkt auf rohem `speed_toward_target_mps`
  - Ziel:
    - Messrauschen und kleine Projektionssprünge dürfen `cmd` nicht direkt umwerfen

- **2. D-Anteil auf gesamte Terminalphase deaktivieren**
  - Aktuell wird D nur abgeschaltet, wenn:
    - `speed_command_mps <= 1.0`
    - oder `guidance_mode == "stop"`
  - Das reicht nicht, weil die Oszillation bereits in der Terminal-Routephase vor Stop-Guidance sichtbar ist.
  - Neue feste Regel:
    - `derivative_gain_scale = 0` für `leg.mode == "terminal"`
    - außerhalb Terminalphase unverändert
  - Ziel:
    - kein D-Kick im gesamten Endspiel

- **3. Terminal-spezifische Effort-Limits einführen**
  - Neuer interner Helper, z. B. `limit_effort_for_phase(...)`
  - Feste Limits:
    - `pass_through`: `drive <= 1.0`, `brake <= 1.0`
    - `terminal route`: `drive <= 0.30`, `brake <= 1.0`
    - `terminal committed stop` (`stop_context.in_no_reverse_approach` oder `guidance_mode == "stop"`): `drive <= 0.18`, `brake <= 0.85`
    - `final low-speed stop` (`speed_command_mps <= 1.0` oder `distance_to_target_m <= 3.0`): `drive <= 0.10`, `brake <= 0.70`
  - Anwenden auf `effort_cmd` vor `allocate_effort_to_controls(...)`
  - Ziel:
    - selbst bei korrekter Sollgeschwindigkeit darf das Terminal nur mit kleiner Stellgröße nachführen

- **4. Effort-Slew-Limiter ergänzen**
  - Neuer State:
    - `previous_effort_cmd = 0`
  - Neuer Helper, z. B. `slew_limit_effort(previous_effort_cmd, target_effort_cmd, dt_s, max_step_per_s)`
  - Feste Slew-Raten:
    - `pass_through`: `0.80 / s`
    - `terminal route`: `0.25 / s`
    - `terminal committed stop`: `0.12 / s`
  - Nach `limit_effort_for_phase(...)` anwenden, vor `allocate_effort_to_controls(...)`
  - Ziel:
    - kein Springen von fast null auf große Terminal-`cmd`-Werte innerhalb weniger Ticks

- **5. Integrator im Terminal enger begrenzen**
  - Aktuell:
    - `integral_limit = max(speed_plan.speed_command_mps * 2, characteristics.cruise_mps)`
  - Das ist im Terminal viel zu großzügig.
  - Neue Regel:
    - `pass_through`: unverändert
    - `terminal route`: `integral_limit = min(1.5, speed_plan.speed_command_mps)`
    - `terminal committed stop`: `integral_limit = min(0.75, speed_plan.speed_command_mps)`
  - Zusätzlich:
    - Integrator reset, wenn `effort_cmd` das Vorzeichen wechselt
    - Integrator reset bei Wechsel von `force_mode`
  - Ziel:
    - keine langsame Aufladung, die kleine Low-Speed-Korrekturen übermächtig macht

- **6. `allocate_effort_to_controls(...)` unverändert einfach lassen**
  - Keine Rückkehr zu throttle-limit-basiertem Design
  - Keine neue Profil-Logik im Allocator
  - Die Phasensensitivität soll vor dem Allocator stattfinden:
    - Messfilter
    - D-Gate
    - Effort-Limit
    - Slew-Limit
  - Ziel:
    - Architektur bleibt speed-zentrisch, aber mit sauberer Stellgrößenhygiene

## Interne Schnittstellen / neue State-Felder
- **Neue State-Felder**
  - `controller_speed_mps`
  - `previous_controller_speed_mps`
  - `previous_effort_cmd`
  - optional `previous_force_mode`
- **Neue Helper**
  - `limit_effort_for_phase(effort_cmd, leg, state, speed_plan, distance_to_target_m)`
  - `slew_limit_effort(previous_effort_cmd, target_effort_cmd, dt_s, max_step_per_s)`
- **Bestehende Helper anpassen**
  - `compute_longitudinal_effort(...)`
    - D-Messung auf `controller_speed_mps`
    - `previous_error` nur noch für I/P-Historie oder ganz entfernen, wenn ungenutzt

## Testplan
- **Pflichtchecks**
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
  - `lua tests/previews/test_outside_capture_window.lua`
- **Neue Preview-Fälle**
  - `controller_speed_mps` glättet kleine Low-Speed-Sprünge gegenüber `speed_toward_target_mps`
  - D-Term ist für jede `leg.mode == "terminal"`-Situation deaktiviert
  - Terminal route effort clamp:
    - großer positiver Fehler führt nicht über `0.30` Drive-Effort
  - Committed stop effort clamp:
    - Drive-Effort bleibt `<= 0.18`
  - Slew-Limit:
    - aufeinanderfolgende `effort_cmd`-Werte ändern sich nur innerhalb der erlaubten Schrittweite
  - Terminal integral limit:
    - Integrator bleibt im Low-Speed-Endspiel im kleinen Bereich
- **Real-Log-Abnahme**
  - `test35`-Nachfolger:
    - `speed_plan_command_mps` darf plausibel bleiben
    - `effort_cmd` darf in der Terminalphase nicht mehr stark springen
    - `allocated_throttle` muss sichtbar ruhiger werden
    - `d_term_active=false` im gesamten Terminal
  - Beide Profile prüfen, aber gleiche Reglererwartung:
    - Profilunterschiede dürfen nur aus Planner-/Profilparametern kommen, nicht aus separater Terminal-Actuatorlogik

## Annahmen
- `test35` bleibt die maßgebliche Evidenz für die Oszillation.
- `test36` wird wegen vorzeitigem Abbruch nicht zur Terminaldiagnose verwendet.
- Das verbleibende Problem ist **Reglerautorität + Stellgrößenruhe**, nicht mehr primär Sollgeschwindigkeitsplanung.
- Die gewünschte Richtung bleibt speed-zentrisch; der Fix darf keine Rückkehr zu alten throttle-limit-Heuristiken sein.
