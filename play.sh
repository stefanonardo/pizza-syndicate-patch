#!/usr/bin/env bash
set -euo pipefail

# Pizza Syndicate — Linux/Wine Launcher (with original CD mounted)

GAMEDIR="$(cd "$(dirname "$0")" && pwd)"
DRIVE="P"
EXE="$GAMEDIR/PIZZA.EXE"
WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"
CNC_VERSION="7.1.0.0"
CNC_URL="https://github.com/FunkyFr3sh/cnc-ddraw/releases/download/v${CNC_VERSION}/cnc-ddraw.zip"

echo "============================================"
echo " Pizza Syndicate — Linux/Wine Launcher"
echo "============================================"
echo
echo "Game folder : $GAMEDIR"
echo "Wine prefix : $WINEPREFIX"
echo

# -------------------------------------------------------------------
# 1. Check PIZZA.EXE exists
# -------------------------------------------------------------------
if [ ! -f "$EXE" ]; then
    echo "ERROR: PIZZA.EXE not found."
    echo "Place this script in your Pizza Syndicate game folder."
    exit 1
fi
echo "PIZZA.EXE: OK"

# -------------------------------------------------------------------
# 2. Install cnc-ddraw (one-time)
# -------------------------------------------------------------------
if [ -f "$GAMEDIR/ddraw.dll" ]; then
    echo "cnc-ddraw: OK"
else
    echo "Downloading cnc-ddraw v${CNC_VERSION}..."
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT

    if command -v curl &>/dev/null; then
        curl -fSL "$CNC_URL" -o "$TMP/cnc-ddraw.zip"
    elif command -v wget &>/dev/null; then
        wget -q "$CNC_URL" -O "$TMP/cnc-ddraw.zip"
    else
        echo "ERROR: curl or wget required. Install one and retry."
        exit 1
    fi

    unzip -qo "$TMP/cnc-ddraw.zip" ddraw.dll ddraw.ini -d "$GAMEDIR"

    echo "Configuring ddraw.ini..."
    sed -i \
        -e 's/^fullscreen=false/fullscreen=true/' \
        -e 's/^maintas=false/maintas=true/' \
        -e 's/^renderer=auto/renderer=opengl/' \
        "$GAMEDIR/ddraw.ini"

    rm -rf "$TMP"
    trap - EXIT
    echo "cnc-ddraw: installed"
fi

# -------------------------------------------------------------------
# 3. Wine registry
# -------------------------------------------------------------------
echo "Setting registry..."
wine reg add "HKLM\\SOFTWARE\\SOFTWARE2000\\Pizza Syndicate\\Data" \
    /v Path /t REG_SZ /d "${DRIVE}:\\\\" /f /reg:32 >/dev/null 2>&1
wine reg add "HKLM\\SOFTWARE\\SOFTWARE 2000\\Pizza Syndicate\\Data" \
    /v Path /t REG_SZ /d "${DRIVE}:\\\\" /f /reg:32 >/dev/null 2>&1
echo "Registry: OK"

# -------------------------------------------------------------------
# 4. Launch
# -------------------------------------------------------------------
echo
echo "Launching..."
echo

cd "$GAMEDIR"
WINEDLLOVERRIDES="ddraw=n,b" wine PIZZA.EXE
