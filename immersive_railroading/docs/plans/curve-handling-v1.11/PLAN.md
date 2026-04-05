# V1.10 Umsetzungsplan: `fast` auf konservatives Endspiel zurückführen, nur Reise schneller machen

## Zusammenfassung
- Aktueller Ist-Stand aus den letzten beiden Logs ist klar:
  - `path_test31` (`profile=conservative`) endet erfolgreich mit `arrived_at_target`.
  - `path_test32` (`profile=fast`) endet mit `terminal_limit_exit reason=stalled_outside_v1_limit`.
- Ziel: `fast` soll kurzfristig als sichere Zwischenstufe das gleiche Endspiel wie `conservative` fahren und sich nur in der Reisegeschwindigkeit unterscheiden.
- Leitprinzip: keine neue Terminallogik, sondern konservatives Verhalten übernehmen und `fast` nur im `pass_through`-Abschnitt schneller machen.

## Implementierungsänderungen
- **1) `fast`-Terminalprofil 1:1 auf `conservative` setzen**
  - In `PROFILES.fast` alle terminal-/bremsrelevanten Felder auf den aktuellen `conservative`-Wert angleichen:
    - `stop_cap_brake_scale`, `required_stop_margin_m`, `no_reverse_distance_m`, `force_brake_distance_m`
    - `terminal_recovery_*`
    - `approach_stop_target_speed_scale`, `approach_stop_throttle_scale`
    - `terminal_buffer_*`
    - `terminal_success_buffer_tolerance_m`
    - `buffer_settle_forward_*`
    - `buffer_settle_reverse_*`
    - `buffer_settle_max_lateral_m`
    - `launch_throttle_scale`, `brake_exit_margin_mps`, `end_phase_integral_decay`
  - Ergebnis: ab Terminal-Anflug und in Stop-Guidance identisches Verhalten zu `conservative`.

- **2) Reisegeschwindigkeit als separater Profilparameter**
  - Neues Profilfeld ergänzen:
    - `conservative.travel_speed_scale = 1.0`
    - `fast.travel_speed_scale = 1.15` (default aus bisheriger Richtung, bewusst moderat).
  - In `run_route_leg(...)` Zielgeschwindigkeit nur für Reiseabschnitte skalieren:
    - wenn `leg.mode == "pass_through"`: `target_speed_mps = math.min(target_speed_mps * profile.travel_speed_scale, characteristics.cruise_mps * profile.travel_speed_scale)`
    - wenn `leg.mode == "terminal"`: keine Skalierung, konservatives Endspiel bleibt unangetastet.
  - Keine zusätzliche Reise-Throttle-Sonderlogik einführen; nur Speed-Cap-Anhebung.

- **3) Stop-Guidance- und Failure-Mechanik unverändert lassen**
  - `can_enter_stop_guidance(...)`, stop-progress channel, `terminal_failure_arming_allowed(...)` bleiben funktional unverändert.
  - Wir ändern hier bewusst nichts, um nur die Profilentkopplung zu testen.

## Testplan
- **Pflichtchecks lokal**
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
  - `lua tests/previews/test_outside_capture_window.lua`

- **Neue/erweiterte Previews**
  - Profil-Paritätstest: `fast`-Terminalfelder entsprechen exakt `conservative`.
  - Reise-Skalierungstest: `travel_speed_scale` wirkt nur bei `pass_through`, nicht bei `terminal`.
  - Regression: bestehende Stop-Guidance-/Failure-Previews bleiben grün.

- **Real-Log-Abnahme**
  - Neuer `conservative`-Lauf muss weiter `arrived_at_target` liefern (Referenz: `path_test31`).
  - Neuer `fast`-Lauf darf nicht mehr in `terminal_limit_exit stalled_outside_v1_limit` enden (Referenzfehler: `path_test32`).
  - `fast` soll im Reiseabschnitt höhere `speed_toward_target`/frühere Leg-Abschlüsse zeigen, bei vergleichbarem Terminalverhalten zu `conservative`.

## Annahmen
- Wir priorisieren Stabilisierung vor Feintuning: `fast` bekommt vorerst keine eigene Endspielstrategie mehr.
- `+15%` Reisegeschwindigkeit ist ein konservativer Default, um Regressionsrisiko im Terminal zu minimieren.
- Falls `fast` danach stabil ist, kann ein späterer Schritt wieder vorsichtig differenzierte `fast`-Terminalparameter einführen.
