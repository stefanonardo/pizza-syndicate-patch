# Pizza Syndicate -- Windows 11 Compatibility Fix

Run **Pizza Syndicate** (Software 2000, 1999) on Windows 10/11 with fullscreen scaling.

## Quick Start

1. Copy your game files to a folder (e.g. `C:\Games\PizzaSyndicate`)
2. Download `Play.bat` and `PlayNoCD.bat` from this repo into the game folder (next to `PIZZA.EXE`)
3. Right-click the appropriate launcher and choose "Run as administrator":
   - **`Play.bat`** — if you have the original CD in your drive
   - **`PlayNoCD.bat`** — if you copied the game files to disk (requires a no-CD patched `PIZZA.EXE` — the launcher does **not** apply the patch itself)

On first run, both launchers will automatically download and configure [cnc-ddraw](https://github.com/FunkyFr3sh/cnc-ddraw) for fullscreen scaling with 4:3 aspect ratio. On subsequent runs they skip straight to launch.

## What do the launchers change?

| What | Details |
|------|---------|
| **cnc-ddraw** | Downloads `ddraw.dll` + `ddraw.ini` into the game folder. Sets `fullscreen=true`, `maintas=true`, and `renderer=opengl`. |
| **Registry** | Creates `HKLM\SOFTWARE\SOFTWARE2000\Pizza Syndicate\Data` with the drive letter (one-time, requires admin). |
| **Drive letter** | `PlayNoCD.bat` only: maps `P:` to the game folder via `subst` while the game is running, removes it on exit. |

## Compatibility

Tested with:
- v1.00 (Italian retail, 1,424,384 bytes)
- v1.02a (German patch, 1,424,384 bytes)

## Troubleshooting

**"Name::Name: Unable to open file 'Name.txt'"**
Copy `Name.txt` from the CD root into the game folder. This file contains the name generator data and must sit next to `PIZZA.EXE`.

**"Cannot read registry entry's! Please reinstall."**
The registry key wasn't created. Right-click the `.bat` file and choose "Run as administrator".

**Game runs but the window is tiny / no scaling**
Check that `ddraw.dll` and `ddraw.ini` are in the game folder and `fullscreen=true` is set in `ddraw.ini`.

**Game shows a black screen or crashes on startup**
Try setting `renderer=opengl` in `ddraw.ini`.

**Mouse doesn't work properly**
Make sure `adjmouse=true` is set in `ddraw.ini` (it's the default).

## Running on Linux (Wine)

```bash
# Install Wine
sudo dnf install wine.i686    # Fedora
sudo apt install wine32        # Debian/Ubuntu

# Set up drive mapping and registry
export WINEPREFIX=~/.wine
mkdir -p "$WINEPREFIX/dosdevices"
ln -sfn /path/to/game "$WINEPREFIX/dosdevices/p:"
wine reg add "HKLM\SOFTWARE\SOFTWARE2000\Pizza Syndicate\Data" \
    /v Path /t REG_SZ /d "P:\\" /f /reg:32

# Launch (cnc-ddraw must be in the game folder)
cd /path/to/game
WINEDLLOVERRIDES="ddraw=n,b" wine PIZZA.EXE
```

## Credits

- **cnc-ddraw** by [FunkyFr3sh](https://github.com/FunkyFr3sh/cnc-ddraw) (MIT License)
