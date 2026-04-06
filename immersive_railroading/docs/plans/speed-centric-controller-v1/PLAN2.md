# Fix-Plan: `conservative` von ~0.65-1.0 m auf ~0.2 m Buffer-Fehler bringen

## Zusammenfassung
- Die Ursache liegt nicht mehr im Regler, sondern im **zu späten Eintritt in die Stop-Guidance**.
- Verifizierte Evidenz aus den letzten Logs:
  - `conservative` in `path_test37.log`:
    - `stop_guidance_entry reason=late_buffer_capture`
    - Eintritt erst bei `physical_distance=2.89m`, `physical_distance_minus_buffer=-0.11m`
    - Endwert: `physical_buffer_error=0.65m`
  - `fast` in `path_test38.log`:
    - `stop_guidance_entry reason=buffer_window`
    - Eintritt schon bei `physical_distance=10.87m`, `physical_distance_minus_buffer=7.87m`
    - Endwert: `physical_buffer_error=0.24m`
- Der Hauptfehler ist damit: `conservative` benutzt für den Guidance-Eintritt dieselbe große Sicherheitsmarge wie für den No-Reverse-/Recovery-Bereich. Dadurch wird die Guidance zu spät freigegeben und der gute Endregler bekommt die Strecke nicht mehr früh genug.

## Implementierungsänderungen
- **Stop-Guidance-Marge von der allgemeinen Stop-Marge entkoppeln**
  - Neues Profilfeld einführen: `stop_guidance_entry_margin_m`
  - In [`train_controller.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua) soll `can_enter_stop_guidance(...)` nicht mehr `profile.required_stop_margin_m` verwenden, sondern:
    - `profile.stop_guidance_entry_margin_m or profile.required_stop_margin_m`
  - Nur diese Guidance-Entry-Prüfung umstellen.
  - `required_stop_margin_m` bleibt weiterhin für `in_no_reverse_approach`, `must_stop_now` und die konservative Recovery-Hülle zuständig.

- **Profilwerte fest setzen**
  - `conservative.stop_guidance_entry_margin_m = 2.0`
  - `fast.stop_guidance_entry_margin_m = 2.5`
  - `conservative.approach_stop_target_speed_scale = 0.45`
  - `fast.approach_stop_target_speed_scale` unverändert bei `0.55`
  - Nicht ändern:
    - `conservative.required_stop_margin_m = 5.0`
    - `conservative.no_reverse_distance_m = 42.0`
    - `stop_cap_brake_scale`
    - PID-/Effort-/Slew-Parameter

- **Beabsichtigte Wirkung**
  - `conservative` soll die Stop-Guidance noch **vor** dem Buffer-Überschreiten aktivieren.
  - Mit den verifizierten `test37`-Werten gilt dann:
    - bei `physical_distance_minus_buffer=3.13m`, `speed_toward_target=1.47m/s`, `brake_snapshot=1.059`
    - wird `can_enter_stop_guidance(...)` mit `stop_guidance_entry_margin_m=2.0` zu `true`
    - also `buffer_window` statt spätem `late_buffer_capture`
  - Das senkt den Fehler, ohne die konservative Recovery-Philosophie nach der Guidance aufzuweichen.

- **Logging erweitern**
  - Periodisches Log um `stop_guidance_entry_margin_m` ergänzen.
  - Optional zusätzlich `stop_guidance_required_stop_m` loggen, damit spätere Diagnosen die Entry-Entscheidung direkt nachvollziehen können.

## Tests und Abnahme
- **Statische Checks**
  - `luac -p immersive_railroading/programs/train_controller.lua`

- **Gezielte Preview-/Unit-Fälle**
  - Neuer Guidance-Entry-Test für `conservative` mit repräsentativen `test37`-Werten:
    - `physical_distance_minus_buffer_m = 3.13`
    - `speed_toward_target_mps = 1.47`
    - `brake_snapshot_mps2 = 1.059`
    - `physical_lateral_error_m = 0.52`
    - `route_alignment >= terminal_stop_guidance_alignment_min`
    - Erwartung: `true, "buffer_window", capture_speed_limit`
  - Bestehender `fast`-Entry-Fall muss unverändert grün bleiben.
  - Regressionstest:
    - `required_stop_margin_m` beeinflusst weiter `no_reverse_approach`
    - `stop_guidance_entry_margin_m` beeinflusst nur `can_enter_stop_guidance(...)`

- **Real-Log-Abnahme**
  - Neuer konservativer Referenzlauf auf derselben Route:
    - `stop_guidance_entry_reason` muss `buffer_window` sein, nicht `late_buffer_capture`
    - `stop_guidance_entry_physical_distance` muss klar **vor** dem Buffer liegen
    - `physical_distance_minus_buffer` beim Entry muss `> 0` sein
    - finaler `physical_buffer_error` soll in den Korridor `0.10m .. 0.30m`
  - `fast` darf sich nicht verschlechtern:
    - Ziel weiter ungefähr im Bereich `~0.24m`

## Annahmen
- Die aktuelle Reglerarchitektur nach dem speed-zentrischen Umbau ist für das Restproblem ausreichend stabil; der Engpass ist die Entry-Semantik, nicht der PID.
- Der konservative Fehler soll verkleinert werden, ohne `fast` neu zu kalibrieren.
- Die richtige Lösung ist **nicht**:
  - aggressiverer PID
  - neue Throttle-Limits
  - engeres `terminal_success_buffer_tolerance_m`
- Die richtige Lösung ist:
  - frühere, kontrollierte Stop-Guidance für `conservative`
  - bei gleichzeitig unverändert konservativer No-Reverse-/Recovery-Hülle.
