# Fix-Plan: Terminal-Oszillation nach `test35`

## Zusammenfassung
- Die eigentliche Ursache ist eine Kombination aus drei Architekturfehlern im neuen speed-zentrischen Umbau:
  1. Der Planner liefert in der Terminalphase weiterhin einen **hohen Geschwindigkeits-Sollwert**, obwohl dieser semantisch nur eine **Obergrenze** ist.
  2. Der Regler verfolgt diese Obergrenze wie ein echtes Tracking-Ziel und versucht dadurch kurz vor dem Halt noch aktiv zu beschleunigen.
  3. Der D-Anteil arbeitet auf rohem `speed_error` und verstärkt bei niedrigen Geschwindigkeiten und springenden Zielwerten die Stellgrößeninstabilität.
- `test35` zeigt das direkt:
  - in der Terminalphase stehen `speed_plan_target_mps` Werte wie `6.14` oder `4.44`,
  - während `speed_toward_target` nur bei `0.05..0.35 m/s` liegt,
  - und der Regler trotzdem wechselnde positive bzw. beinahe neutrale `effort_cmd`-Werte erzeugt.

## Implementierungsänderungen
- **1. Planner-Ausgabe semantisch aufteilen**
  - `make_speed_plan(...)` darf nicht mehr `v_target_mps` als alleinige Tracking-Größe liefern.
  - Stattdessen zwei Größen führen:
    - `speed_limit_mps`: physikalisch/sicherheitsseitige Obergrenze aus Stop-Envelope
    - `speed_command_mps`: tatsächlich zu trackender Sollwert
  - Regel:
    - außerhalb der Terminal-Commit-Phase darf `speed_command_mps` dem Limit folgen
    - ab `stop_context.in_no_reverse_approach == true` oder `guidance_mode == "stop"` wird `speed_command_mps` **monoton fallend** geführt
    - in dieser Phase darf `speed_command_mps` nicht mehr wieder nach oben gezogen werden, nur weil die Hüllkurve rechnerisch noch mehr erlauben würde
- **2. Terminalphase auf „deceleration commitment“ umstellen**
  - Beim Eintritt in die committed stop phase einen Zustand ergänzen, z. B.:
    - `state.terminal_speed_command_mps`
    - `state.terminal_speed_commit_active`
  - Verhalten:
    - initialisiere `terminal_speed_command_mps = min(current_speed_toward_target_mps, speed_limit_mps)`
    - danach pro Tick:
      - `terminal_speed_command_mps = min(previous_terminal_speed_command_mps, speed_limit_mps)`
    - optional zusätzlich mit kleiner Absenkrate, aber **niemals nach oben**
  - Dadurch wird verhindert, dass der Zug in 8 m Restabstand noch auf 4 m/s „hochgeregelt“ wird
- **3. Regler auf derivative-on-measurement umstellen**
  - `compute_longitudinal_effort(...)` soll den D-Anteil nicht mehr aus `speed_error` bilden.
  - Stattdessen:
    - D auf gemessener Geschwindigkeitsänderung
    - also sinngemäß `d_meas = -(v_actual - v_actual_prev) / dt`
  - Optional, aber empfohlen:
    - D-Anteil über EMA filtern
    - D-Anteil in Stop-/Low-Speed-Phase unterhalb einer Schwelle stark reduzieren oder deaktivieren
  - Ziel:
    - keine derivative kick durch sich ändernde Sollwerte
    - weniger Stellgrößenflattern bei Low-Speed-Rauschen
- **4. Low-Speed-Terminalregler als PI oder PD-gedämpft betreiben**
  - Unterhalb eines klaren Gates, z. B.:
    - `speed_command_mps <= 1.0`
    - oder `guidance_mode == "stop"`
  - D-Anteil auf `0` oder auf stark reduzierten Faktor setzen
  - P + I reicht in dieser Phase aus; D schadet dort mehr als er hilft
- **5. PID-Skalierung im Terminal einfrieren**
  - `derive_pid(...)` im Terminal nicht mehr von jedem Tick-`brake_model` abhängig machen
  - Stattdessen bei Eintritt in den Terminal-Commit eine gefrorene Regelbasis verwenden:
    - z. B. aus `state.terminal_brake_snapshot_mps2`
  - Grund:
    - `test35` zeigt `terminal_brake_snapshot=0.830`, aber `brake_model=0.331`
    - diese Drift führt zu inkonsistenter Planner-/Regler-Basis
- **6. Brake-Learning in der Low-Speed-Terminalphase sperren**
  - Brake-Learning nicht weiter aktualisieren, wenn:
    - `guidance_mode == "stop"`
    - oder `stop_context.in_no_reverse_approach`
    - und `speed_toward_target_mps <= 1.0`
  - Diese Samples sind zu verrauscht und drücken das Modell unrealistisch nach unten
- **7. Nicht anfassen**
  - keine Route-Geometrie-Änderung
  - keine `route_book`-/CLI-Änderung
  - keine neue Profilphilosophie
  - keine Rückkehr zu Throttle-Limits als Primärmittel
  - keine Arbeit an `weight_approach_factor(...)` im aktiven Routenpfad

## Konkrete Zielarchitektur im Code
- **`make_speed_plan(...)`**
  - erweitern auf:
    - `speed_limit_mps`
    - `speed_command_mps`
    - `desired_reverser`
    - `reason`
    - `force_mode`
- **Neuer Helper**
  - z. B. `update_terminal_speed_command(previous_cmd, speed_limit_mps, speed_toward_target_mps, committed_stop)`
  - Verhalten:
    - außerhalb committed stop: `return speed_limit_mps`
    - innerhalb committed stop:
      - `return min(previous_cmd or speed_toward_target_mps, speed_limit_mps)`
- **`compute_longitudinal_effort(...)`**
  - Eingänge ergänzen:
    - `actual_speed_mps`
    - `previous_actual_speed_mps`
    - `derivative_gain_scale`
  - D-Term nicht mehr aus `(speed_error - previous_error) / dt`
- **Logging**
  - zusätzlich loggen:
    - `speed_plan_limit_mps`
    - `speed_plan_command_mps`
    - `terminal_speed_commit_active`
    - optional `d_term_active`

## Testplan
- **Pflichtchecks**
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
  - `lua tests/previews/test_outside_capture_window.lua`
- **Neue Preview-Fälle**
  - Terminal-Commit:
    - sobald `in_no_reverse_approach` aktiv ist, darf `speed_command_mps` nicht mehr steigen
  - Derivative-on-measurement:
    - Änderung von `speed_limit_mps` allein darf keinen D-Kick erzeugen
  - Low-Speed stop guidance:
    - bei `v_actual` nahe null und positivem Restabstand bleibt `effort_cmd` klein und stabil positiv oder neutral, nicht oszillierend
  - Brake-learning gate:
    - Low-Speed-Terminalsamples verändern `brake_model` nicht weiter
- **Real-Log-Abnahme**
  - `test35`-Nachfolger:
    - keine wechselnden großen `allocated_throttle`-Sprünge in der Terminalphase
    - `speed_plan_command_mps` fällt monoton im committed stop
    - keine aktive Beschleunigung mehr kurz vor dem Halt
  - Beide Profile prüfen:
    - Problembehebung muss profilübergreifend gelten

## Annahmen
- `test34` ist veraltet und wird nicht als Evidenz benutzt.
- Die Terminal-Oszillation ist ein Architekturproblem des neuen speed-zentrischen Reglers, nicht ein Profilproblem.
- Der wichtigste Fix ist semantisch:
  - **speed limit != tracking target**
- Gewichte sind im aktiven Route-Regler kein primärer Hebel und sollen in diesem Fix nicht verfolgt werden.
