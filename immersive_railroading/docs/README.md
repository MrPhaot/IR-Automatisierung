# Docs

- `runtime.md`: confirmed environment facts plus mismatches that affect implementation choices
- `control-model.md`: current speed-centric controller shape, brake learning, and stop-envelope design
- `signals-and-blocks.md`: V2-oriented reservation notes kept separate from V1 controller logic
- `station-schedules.md`: frozen V1 detector/station/route/schedule schema plus wait and redstone rules
- `operations/download-and-run.md`: OpenOS `wget` install and update workflow, plus the current test-world log path
- `research/air-brake-notes.md`: compact notes from the brake PDF
- `plans/foundation-v1/PLAN.md`: original frozen implementation plan for the first V1 controller pass
- `plans/speed-centric-controller-v1/`: current redesign history for the speed-centric controller branch

`runtime.md`, `station-schedules.md`, and `operations/download-and-run.md` are the living reference docs for the production controller/dispatcher surface.
Read `runtime.md` first when changing production code.
