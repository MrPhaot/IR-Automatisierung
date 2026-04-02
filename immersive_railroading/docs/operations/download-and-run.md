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
wget -f https://raw.githubusercontent.com/MrPhaot/IR-Automatisierung/main/immersive_railroading/programs/install_manifest.lua programs/install_manifest.lua
lua programs/install.lua
```

## Update Flow
- Replace `main` with a branch, tag, or commit ref when you want reproducible installs.
- Re-run `lua programs/install.lua` after updating `programs/install_manifest.lua`.

## Safety Notes
- The installer rejects:
  - absolute paths
  - `..` path traversal
  - duplicate manifest paths
- Keep manifest paths repo-relative under `immersive_railroading/`.

## Offline Or Manual Fallback
- Copy the `immersive_railroading/` folder into the OpenOS filesystem manually.
- Run `lua programs/train_controller.lua inspect` to confirm the control card is visible.
