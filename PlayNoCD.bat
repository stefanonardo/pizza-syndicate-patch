@echo off
setlocal

:: Pizza Syndicate - Windows 11 Launcher (no CD, game files on disk)

set "GAMEDIR=%~dp0"
set "GAMEDIR=%GAMEDIR:~0,-1%"
set "DRIVE=P"
set "EXE=%GAMEDIR%\PIZZA.EXE"
set "CNC_URL=https://github.com/FunkyFr3sh/cnc-ddraw/releases/download/v7.1.0.0/cnc-ddraw.zip"

echo ============================================
echo  Pizza Syndicate - Windows 11 Launcher
echo  (no CD mode)
echo ============================================
echo.
echo Game folder: %GAMEDIR%
echo.

:: ---------------------------------------------------------------
:: 1. Check PIZZA.EXE exists
:: ---------------------------------------------------------------
if not exist "%EXE%" (
    echo ERROR: PIZZA.EXE not found.
    echo Place this file in your Pizza Syndicate game folder.
    goto :fail
)
echo PIZZA.EXE: OK

:: ---------------------------------------------------------------
:: 2. Install cnc-ddraw (one-time)
:: ---------------------------------------------------------------
if exist "%GAMEDIR%\ddraw.dll" (
    echo cnc-ddraw: OK
) else (
    echo Downloading cnc-ddraw...
    powershell -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%CNC_URL%' -OutFile '%GAMEDIR%\cnc-ddraw.zip'"
    if not exist "%GAMEDIR%\cnc-ddraw.zip" (
        echo ERROR: Download failed. Get cnc-ddraw manually from:
        echo   https://github.com/FunkyFr3sh/cnc-ddraw/releases
        goto :fail
    )
    echo Extracting...
    powershell -ExecutionPolicy Bypass -Command "Expand-Archive '%GAMEDIR%\cnc-ddraw.zip' '%GAMEDIR%\cnc-ddraw-temp' -Force; Copy-Item '%GAMEDIR%\cnc-ddraw-temp\ddraw.dll' '%GAMEDIR%'; Copy-Item '%GAMEDIR%\cnc-ddraw-temp\ddraw.ini' '%GAMEDIR%'; Remove-Item '%GAMEDIR%\cnc-ddraw-temp' -Recurse; Remove-Item '%GAMEDIR%\cnc-ddraw.zip'"
    echo Configuring...
    powershell -ExecutionPolicy Bypass -Command "$c=Get-Content '%GAMEDIR%\ddraw.ini' -Raw; $c=$c-replace'fullscreen=false','fullscreen=true'; $c=$c-replace'maintas=false','maintas=true'; $c=$c-replace'renderer=auto','renderer=opengl'; Set-Content '%GAMEDIR%\ddraw.ini' $c -NoNewline"
    echo cnc-ddraw: installed
)

:: ---------------------------------------------------------------
:: 3. Registry
:: ---------------------------------------------------------------
echo Setting registry...
reg add "HKLM\SOFTWARE\SOFTWARE2000\Pizza Syndicate\Data" /v Path /t REG_SZ /d %DRIVE%:\ /f /reg:32 >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Cannot write registry. Please right-click PlayNoCD.bat
    echo and choose "Run as administrator", then try again.
    goto :fail
)
reg add "HKLM\SOFTWARE\SOFTWARE 2000\Pizza Syndicate\Data" /v Path /t REG_SZ /d %DRIVE%:\ /f /reg:32 >nul 2>&1
echo Registry: OK

:: ---------------------------------------------------------------
:: 4. Map drive letter and launch
:: ---------------------------------------------------------------
subst %DRIVE%: /d >nul 2>&1
subst %DRIVE%: "%GAMEDIR%"
echo Drive: %DRIVE%: = %GAMEDIR%
echo.
echo Launching...
echo.

cd /d "%GAMEDIR%"
PIZZA.EXE

:: ---------------------------------------------------------------
:: 5. Clean up
:: ---------------------------------------------------------------
subst %DRIVE%: /d >nul 2>&1
goto :eof

:fail
echo.
pause
