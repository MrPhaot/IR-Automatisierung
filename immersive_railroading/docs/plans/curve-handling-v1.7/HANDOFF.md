# Handoff: Behebung Terminal‑Buffer Stall (Emergency Buffer Throttle)

## TL;DR
Reproduziere das im `path_test23` Log beobachtete Terminal‑Buffer‑Stall (wiederholte `stop_guidance_block_reason=outside_capture_window` während `buffer_approach`), wende die vorbereitete, minimal invasive Tuning‑Patch an (erzwungene minimale Emergency‑Throttle + Brems‑Hold‑Verlängerung), führe Syntax‑ und Unit/Harness‑Tests lokal aus und erstelle einen lokalen Commit (nicht pushen).

---

## Kontext & Schlüsselbefunde
- Controller: `immersive_railroading/programs/train_controller.lua`
- Preview/Harness: `immersive_railroading/tests/previews/controller_preview.lua` und `tests/harnesses/controller_sim.lua`
- Beobachtete Signatur (aus `path_test23.log`): `guidance_mode=route`, `reason=buffer_approach`, `stop_guidance_entry=false`, `stop_guidance_block_reason=outside_capture_window`, `throttle=0.00`, `brake=0.00`, `physical_distance≈10.24m`, `physical_distance_minus_buffer≈7.24m`.
- Parity: Workspace vs deployed differiert nur durch ein EOF‑Newline (keine funktionelle Abweichung).
- Problem: `PROFILES.fast.terminal_buffer_throttle_limit = 0.02` und `DEFAULTS.throttle_deadband = 0.03` → kleine Emergency‑Throttle wird wegen Deadband auf `0` gesetzt.

Geplante Änderungen (minimal):
- `DEFAULTS.brake_release_hold_s`: 0.8 → 1.5
- `PROFILES.fast.terminal_buffer_throttle_limit`: 0.02 → 0.05
- Emergency‑Throttle: wenn `physical_distance_minus_buffer` knapp oberhalb `capture_distance` (≤ 1.5×capture), setze `emergency_min_throttle = DEFAULTS.throttle_deadband + 0.01` und stelle sicher, dass `throttle` mindestens diese minimale Größe erreicht (aber nicht über das lokale `throttle_limit`).

---

## Voraussetzungen / Environment
- Arbeitsverzeichnis: Projekt‑Root (z. B. `/home/mrphaot/Dokumente/lua/minecraft`).
- Benötigte Werkzeuge: `lua`, `luac`, `git`, `grep`, `cp`.
- Nicht pushen: Änderungen lokal committen, aber nicht zum Remote pushen.

---

## Auszuführende Schritte (konkret)
1. Baseline & Backup
```bash
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
cp immersive_railroading/programs/train_controller.lua immersive_railroading/programs/train_controller.lua.bak
lua tests/harnesses/controller_sim.lua > harness_run_before.log 2>&1 || true
lua immersive_railroading/tests/previews/test_outside_capture_window.lua > unit_test_before.log 2>&1 || true
grep -c 'stop_guidance_block_reason=outside_capture_window' harness_run_before.log > harness_counts_before.txt || true
grep -c 'reason=buffer_approach' harness_run_before.log >> harness_counts_before.txt || true
```

2. Patch anwenden (minimal, nur die unten stehenden Stellen verändern). Beispiel‑Patch (unified diff):
```diff
*** a/immersive_railroading/programs/train_controller.lua
--- b/immersive_railroading/programs/train_controller.lua
@@
-  brake_release_hold_s = 0.8,
+  brake_release_hold_s = 1.5,
@@
-    terminal_buffer_throttle_limit = 0.02,
+    terminal_buffer_throttle_limit = 0.05,
@@
-      local buffer_target_speed_mps = 0
-      local buffer_speed_cap_active_mps = 0
-      local buffer_throttle_limit_active = 0
-      local terminal_buffer_brake_active = false
-      local terminal_buffer_brake_reason = "inactive"
+      local buffer_target_speed_mps = 0
+      local buffer_speed_cap_active_mps = 0
+      local buffer_throttle_limit_active = 0
+      local terminal_buffer_brake_active = false
+      local terminal_buffer_brake_reason = "inactive"
+      local emergency_min_throttle = nil
@@
-              emit_line(logger, ("emergency_buffer_throttle_active capture_base=%.2f physical_distance_minus_buffer=%.2f"):format(
-                capture_base,
-                physical_distance_minus_buffer_m
-              ))
+              emergency_min_throttle = DEFAULTS.throttle_deadband + 0.01
+              emit_line(logger, ("emergency_buffer_throttle_active capture_base=%.2f physical_distance_minus_buffer=%.2f emergency_min_throttle=%.2f"):format(
+                capture_base,
+                physical_distance_minus_buffer_m,
+                emergency_min_throttle
+              ))
@@
-          throttle = clamp(effort, 0, throttle_limit)
+          throttle = clamp(effort, 0, throttle_limit)
+          if emergency_min_throttle then
+            throttle = math.max(throttle, math.min(emergency_min_throttle, throttle_limit))
+          end
```
Hinweis: Die drei Änderungen (`brake_release_hold_s`, `terminal_buffer_throttle_limit`, und die `emergency_min_throttle`‑Änderungen) müssen *zweimal* vorgenommen werden — jeweils in den beiden Scopes `control_loop` und `run_route_leg` (Datei enthält beide Implementierungen). Achte darauf, nur die genannten Blöcke zu ändern.

3. Syntax‑Check + After‑Runs
```bash
luac -p immersive_railroading/programs/train_controller.lua
lua tests/harnesses/controller_sim.lua > harness_run_after.log 2>&1 || true
lua immersive_railroading/tests/previews/test_outside_capture_window.lua > unit_test_after.log 2>&1 || true
grep -c 'stop_guidance_block_reason=outside_capture_window' harness_run_after.log > harness_counts_after.txt || true
grep -c 'reason=buffer_approach' harness_run_after.log >> harness_counts_after.txt || true
grep -E 'emergency_buffer_throttle_active' harness_run_after.log | head -n 20 || true
```

4. Commit (lokal, kein Push)
```bash
git checkout -b fix/terminal-buffer-emergency-throttle
git add immersive_railroading/programs/train_controller.lua
git commit -m "fix: ensure emergency buffer throttle exceeds deadband; increase brake_release_hold_s"
git show --name-only HEAD
git rev-parse HEAD > commit_hash.txt
```

5. Falls Fehler auftreten: Revert auf Backup
```bash
cp immersive_railroading/programs/train_controller.lua.bak immersive_railroading/programs/train_controller.lua
# optional: git checkout -- immersive_railroading/programs/train_controller.lua
```

---

## Akzeptanzkriterien
- `luac -p` meldet keine Syntaxfehler.
- `harness_counts_after.txt` zeigt deutlich weniger (idealerweise 0) wiederholte Einträge `stop_guidance_block_reason=outside_capture_window` an derselben Distanz (keine dauerhafte Schleife >3 Zyklen).
- `harness_run_after.log` enthält `emergency_buffer_throttle_active`‑Einträge.
- Unit‑Test `test_outside_capture_window.lua` verhält sich erwartungsgemäß (keine Regressionen).
- Commit existiert lokal und enthält nur die intendierten Änderungen.

---

## Erwartete Artefakte (zu liefern vom ausführenden Agenten)
- `harness_run_before.log`
- `unit_test_before.log`
- `harness_counts_before.txt`
- `harness_run_after.log`
- `unit_test_after.log`
- `harness_counts_after.txt`
- `commit_hash.txt` (oder Commit‑Hash in der Antwort)
- kurze Zusammenfassung (2‑5 Sätze) mit: geänderte Dateien, Commit‑Hash, greps/Zeilen aus `harness_run_after.log` die `emergency_buffer_throttle_active` zeigen, und ob Akzeptanzkriterien erfüllt sind.

---

## Fallbacks / Weitere Optionen
- Falls der Fix die Situation nicht zuverlässig löst, teste:
  1. Candidate 1: erhöhe `PROFILES.fast.terminal_buffer_capture_distance_m` leicht (z. B. 5.0 → 6.5) und wiederhole Tests.
  2. Candidate 3: evaluiere dynamische capture_distance (aufwändiger) — nur nach Testmatrix.

---

## Anmerkungen
- Die Datei `immersive_railroading/programs/train_controller.lua` enthält zwei getrennte Lauflogiken (`control_loop` und `run_route_leg`). Die Änderungen müssen in *beiden* Plätzen identisch vorgenommen werden.
- Die angegebene `emergency_min_throttle` wird auf `DEFAULTS.throttle_deadband + 0.01` gesetzt (z. B. 0.03 + 0.01 = 0.04) — dadurch wird das Deadband umgangen, aber das Throttle bleibt konservativ begrenzt durch `throttle_limit`.


