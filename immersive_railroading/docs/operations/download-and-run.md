# Download And Run

## Hosting Assumption
- Files are expected to be hosted on GitHub Raw.
- `programs/install_manifest.lua` uses raw URLs in the shape:
  - `https://raw.githubusercontent.com/MrPhaot/IR-Automatisierung/<ref>/immersive_railroading/...`

## OpenOS Install Flow
From an OpenComputers machine inside OpenOS:

```sh
mkdir -p /home/immersive_railroading
cd /home/immersive_railroading
wget -f https://raw.githubusercontent.com/MrPhaot/IR-Automatisierung/main/immersive_railroading/programs/install.lua programs/install.lua
wget -f https://raw.githubusercontent.com/MrPhaot/IR-Automatisierung/main/immersive_railroading/programs/ir_install.lua programs/ir_install.lua
wget -f https://raw.githubusercontent.com/MrPhaot/IR-Automatisierung/main/immersive_railroading/programs/install_manifest.lua programs/install_manifest.lua
lua programs/ir_install.lua
```

Why this is the preferred entrypoint:
- `install` is already an OpenOS system command, so using that name is misleading.
- `ir_install.lua` avoids the name collision and still delegates to the same project installer logic.
- `lua programs/install.lua` also works, but `lua programs/ir_install.lua` is the documented default.

## Update Flow
- Replace `main` with a branch, tag, or commit ref when you want reproducible installs.
- Re-run `lua programs/ir_install.lua` after updating `programs/install_manifest.lua`.
- Current branch work is happening on `PID-Regler`.
- `programs/install_manifest.lua` still points to `main`, so branch-specific controller testing is safer with direct `wget` for the individual files you want to deploy.

## Train Controller Invocation
Preferred OpenOS entrypoint:

```sh
cd /home/immersive_railroading/programs
trainctl inspect --log
trainctl goto -120 64 -35 40 3 --log=test.log
```

Fallback when you explicitly want to invoke the Lua frontend:

```sh
cd /home/immersive_railroading/programs
lua train_controller.lua -- inspect --log
lua train_controller.lua -- goto -120 64 -35 40 3 --log=test.log
```

Why this matters:
- OpenOS `lua` parses command-line options before your script runs.
- Without the separating `--`, negative coordinates like `-35` and flags like `--log` never reach `train_controller.lua`.
- `trainctl` avoids that pre-processing and passes the arguments through unchanged.

## Test-World Log Location
The current OpenComputers test machine writes logs under:

`~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/`

Useful real examples from that directory:
- `train_controller.log`
- `reverse_test.log`
- `reverse_test1.log`

That path is inspect-only for this project, but it is the quickest place to verify what `--log` captured during an in-game run.

## Safety Notes
- The installer rejects:
  - absolute paths
  - `..` path traversal
  - duplicate manifest paths
- Keep manifest paths repo-relative under `immersive_railroading/`.
- Do not use bare `install`, because that calls the OpenOS system installer instead of this project.

## Offline Or Manual Fallback
- Copy the `immersive_railroading/` folder into the OpenOS filesystem manually.
- Run `lua programs/train_controller.lua inspect` to confirm the control card is visible.
