# IR Save Extractor

This is a read-only Python 3 extractor for Minecraft 1.7.10 Anvil saves with
Immersive Railroading. It reads Universal Mod Core tile NBT directly and emits a
versioned `ir-geometry-topology.json` artifact plus an extraction report.

## Start the GUI

From the repository root, run the executable launcher:

```bash
./immersive_railroading/tools/run_ir_save_extractor.py
```

It opens the GUI and asks for the save folder and a separate output folder.

Run from the repository root:

```bash
PYTHONPATH=immersive_railroading/tools \
python3 -m ir_save_extractor SAVE_FOLDER OUTPUT_FOLDER \
  --resource immersive_railroading/.cache/jar \
  --resource /path/to/addon.zip
```

The GUI uses the same core:

```bash
PYTHONPATH=immersive_railroading/tools python3 -m ir_save_extractor.gui
```

The save directory and any directory below it are rejected as output paths. A
missing track resource writes an incomplete artifact/report and then fails the
command. The output is not proof evidence or implementation-ready until the
geometry is differentially checked against the live IR builders and all active
route topology is resolved.
