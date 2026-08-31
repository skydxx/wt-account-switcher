@echo off
set "SCRIPT_PATH=%APPDATA%\WT_Switcher\wt_switch.ps1"

if not exist "%SCRIPT_PATH%" (
    echo WT Switcher is not installed. Please run install.bat first.
    exit /b 1
)

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT_PATH%' %*"
