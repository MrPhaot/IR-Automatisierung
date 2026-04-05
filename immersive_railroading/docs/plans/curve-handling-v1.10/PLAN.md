# Curve Handling V1.10: `fast` Reise-Boost + konservatives Bremsprofil + `test29` Hänger-Fix

## Zusammenfassung
- Zielbild ist jetzt eindeutig:
  - `fast` soll nur auf der Strecke (Reisephase) schneller sein.
  - Terminal-/Bremsverhalten von `fast` soll 1:1 dem aktuellen `conservative` entsprechen.
  - `test29`-Hänger (kein `stop_guidance_entry`, Endlosschleife in Route-Guidance) muss beseitigt werden.
- Verifizierter Log-Befund:
  - `path_test28.log`: erfolgreich mit `stop_guidance_entry` und `arrived_at_target`.
  - `path_test29.log`: kein `stop_guidance_entry`-Event, wiederholt `stop_guidance_block_reason=insufficient_braking_room`, danach Abbruch bei stillstehendem Zug (`speed_toward_target=0.00`).

## Implementierungsänderungen
- **1) Hängerursache direkt beheben (`can_enter_stop_guidance`)**
  - In `can_enter_stop_guidance(...)` einen Low-Speed-Override für späten Capture ergänzen:
    - greift nur, wenn aktuell `stop_guidance_ready` wegen `required_stop_margin_m` fehlschlägt,
    - Zug bereits praktisch steht (`forward_speed_mps <= DEFAULTS.arrival_speed_mps`),
    - und wir sehr nahe am Buffer sind (`physical_distance_minus_buffer_m <= DEFAULTS.arrival_distance_m + DEFAULTS.terminal_stop_margin_m`).
  - Verhalten:
    - dann `true` mit neuem Reason, z. B. `low_speed_capture_override`,
    - sonst unverändert `false, "insufficient_braking_room"`.
  - Zweck: verhindert den Route-Guidance-Deadlock bei stillstehendem Zug knapp vor dem Stop-Buffer.

- **2) `fast` Terminalprofil auf `conservative` angleichen (1:1)**
  - In `PROFILES.fast` alle terminal-/bremsrelevanten Parameter auf die aktuellen `conservative`-Werte setzen:
    - `stop_cap_brake_scale`
    - `required_stop_margin_m`
    - `no_reverse_distance_m`
    - `force_brake_distance_m`
    - `terminal_recovery_*`
    - `approach_stop_target_speed_scale`
    - `approach_stop_throttle_scale`
    - `terminal_buffer_*`
    - `terminal_success_buffer_tolerance_m`
    - `buffer_settle_forward_*`
    - `buffer_settle_reverse_*`
    - `buffer_settle_max_lateral_m`
    - `launch_throttle_scale`
    - `brake_exit_margin_mps`
    - `end_phase_integral_decay`
  - Ergebnis: Ab Terminal-Approach und in Stop-Guidance verhalten sich `fast` und `conservative` gleich.

- **3) Reisegeschwindigkeit von `fast` explizit über eigenen Drive-Scale lösen**
  - Neue Profil-Property einführen, z. B. `pass_through_throttle_scale`:
    - `conservative = 1.0`
    - `fast = 1.15` (entspricht deiner Entscheidung „Mittel +15%“)
  - Anwenden nur in Reisephase:
    - im Drive-Branch bei `leg.mode == "pass_through"` (nicht im Stop-Guidance-/Terminal-Bremsbereich),
    - auf den berechneten `throttle_limit` (mit Clamp auf max. `1.0`).
  - Dadurch bleibt der Bremsabschnitt identisch, aber der Streckenanteil spürbar schneller.

- **4) Logging für Diagnose ergänzen**
  - Bestehendes Runtime-Logging beibehalten.
  - Neues `stop_guidance_entry_reason` aus dem Override (`low_speed_capture_override`) muss in Logs klar sichtbar sein, um `test29` gezielt zu verifizieren.

## Testplan
- **Lokale Pflichtchecks**
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
  - `lua tests/previews/test_outside_capture_window.lua`

- **Neue Preview-Fälle**
  1. `can_enter_stop_guidance` mit konservativen Margins, sehr niedriger Geschwindigkeit und kleinem `physical_distance_minus_buffer_m`:
     - erwartet: `true`, Reason `low_speed_capture_override`.
  2. Profil-Parität:
     - assert, dass `fast` für alle terminal-/bremsrelevanten Felder exakt den `conservative`-Wert hat.
  3. Reise-Boost:
     - bei pass-through-spezifischer Throttle-Limit-Berechnung ist `fast` um 15% höher als `conservative`.

- **Real-Log-Verifikation**
  - `test29` (`conservative`):
    - muss `stop_guidance_entry`-Event enthalten,
    - darf nicht in `insufficient_braking_room` hängen,
    - darf nicht per `aborted_by_user` enden.
  - `test28` (`fast`):
    - weiterhin erfolgreich (`arrived_at_target`),
    - Terminalverhalten entspricht konservativem Muster,
    - Reiseabschnitt bleibt schneller (höherer pass-through-Drive).

## Annahmen und Defaults
- `Terminal 1:1` ist verbindlich: `fast` unterscheidet sich im Endspiel nicht mehr von `conservative`.
- Reise-Boost ist verbindlich auf `+15%` gesetzt.
- Der `test29`-Hänger ist primär ein Entry-Gating-Problem (`insufficient_braking_room` bei nahezu Nullgeschwindigkeit), nicht ein weiterer Deadlock-Timer-Fall.
