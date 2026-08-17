# Plan: Schedule Scope/Redstone Implementation — Finish Remaining Items

## Context

The main feature work from `docs/plans/factorio-schedule-v1/1786581005158-ir111-schedule-scope-redstone.md` is **already implemented** in the working tree. The uncommitted diff touches:

- `programs/lib/station_schedule.lua` — `arrived_at_station`, pulse rules, `allowed_outputs`, `entry_station_ids`
- `programs/station_dispatch.lua` — arrival-pulse dispatch
- `programs/route_book_editor.lua` — station-chooser, `arrived_at_station` UI, `signal`/`pulse_ticks`, scope union
- `tests/previews/station_schedule_preview.lua` — new preview blocks
- `docs/station-schedules.md` — updated semantics

One whitespace defect and two doc updates from §1.5 of the plan are still outstanding.

## Remaining Work

### 1. Fix whitespace defect in `station_schedule.lua`

`programs/lib/station_schedule.lua` line 321 has an extra leading space on the `for` loop inside the redstone-rule condition validation path. This is cosmetic but inconsistent with the surrounding indentation.

**Fix:** remove the single leading space on that `for` line so it aligns with the `plain_condition.redstone = nil` line above it.

### 2. Update `docs/runtime.md` baseline note

Per plan §1.5: add a one-line "Baseline" note at the top of `runtime.md` stating the project targets **Minecraft 1.7.10 / Immersive Railroading 1.11.0** (jar: `ImmersiveRailroading-1.7.10-forge-1.11.0.jar`) and that the GitHub `TeamOpenIndustry/ImmersiveRailroading` repo covers other MC versions and does not apply here.

Also update the "Confirmed Components" section to annotate that `component.ir_remote_control` is the Radio Control Card, distinct from `ir_augment_detector` / `ir_augment_control`, and add the one-line note about augment configuration now being done via the in-game `AugmentFilterGUI`.

### 3. Update `README.md` baseline note

Per plan §1.5: add the same one-line baseline note at the top of `README.md`.

### 4. Validate

- Run `luac -p` on all four edited Lua files.
- Run `lua tests/previews/station_schedule_preview.lua` from the project root to confirm all preview assertions pass.
- Run `lua tests/previews/route_book_editor_emulator.lua` and `lua tests/previews/term_ui_preview.lua` to confirm no regressions.

## Validation Criteria

- `luac -p` exits 0 for all four edited `.lua` files.
- `station_schedule_preview.lua` prints `station_schedule_preview ok`.
- No diff noise introduced by the whitespace fix (only the single leading space removed).
- `docs/runtime.md` and `README.md` each gain exactly one baseline paragraph, no other structural changes.

## Out of Scope

- `AGENTS.md` update requires explicit user permission (plan §1.5 notes this).
- `docs/operations/download-and-run.md` `cargoFill` / `/immersiverailroading reload` verification (§1.4) is deferred — those commands need in-game confirmation.
- Redstone input waits, junction graph, block reservations (explicitly V1-out-of-scope per `docs/station-schedules.md`).
- PID formal proof (`docs/plans/pid-formal-proof.tex`) is a separate research artifact; no code action required.
