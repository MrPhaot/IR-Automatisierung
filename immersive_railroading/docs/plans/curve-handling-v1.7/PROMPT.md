Handoff: Reproduce and fix 'outside_capture_window' terminal‑buffer stall

Goal:
- Follow the plan under "immersive_railroading/docs/plans/curve-handling-v1.7/HANDOFF.md"; below is the summary of the objectives:
    - Reproduce the stall observed in path_test23.log (repeated stop_guidance_block_reason=outside_capture_window during buffer_approach) using the workspace controller.
    - Implement the minimal fix: emergency buffer throttle injection + tuning (increase brake_release_hold_s, raise fast profile throttle cap).
    - Verify via unit test and harness, then create a local commit. DO NOT push to remote.

Environment:
- Project root: run commands from repository root.
- Required tools: lua, luac, git, grep, cp.

Tasks (ordered):
1) Record baseline and backup original file.
2) Apply the exact edits described in the attached patch (ensure you edit both `control_loop` and `run_route_leg` occurrences).
3) Run `luac -p` (fail if syntax errors).
4) Run the harness and unit test to collect before/after logs and counts.
5) Commit to branch `fix/terminal-buffer-emergency-throttle` with message: "fix: ensure emergency buffer throttle exceeds deadband; increase brake_release_hold_s".
6) Return: changed file list, unified diff, commit hash, `grep` excerpts showing `emergency_buffer_throttle_active`, and counts before/after. If failure, restore backup and attach logs.

Outputs expected:
- All artifacts listed in the Handoff file.
- A one‑paragraph summary confirming whether Akzeptanzkriterien erfüllt sind.

If you need additional runtime values (exact profile fields, or the original `path_test23.log`), ask before changing files.