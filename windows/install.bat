@echo off
setlocal

set "APP_DIR=%APPDATA%\WT_Switcher"
set "BIN_DIR=%APP_DIR%\bin"

echo Installing WT Account Switcher...

if not exist "%APP_DIR%" mkdir "%APP_DIR%"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"

:: Copy scripts to AppData
copy /Y wt_switch.ps1 "%APP_DIR%\wt_switch.ps1" >nul
copy /Y wt.bat "%BIN_DIR%\wt.bat" >nul

:: Add to User PATH if not already there
echo Checking PATH...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); if ($userPath -notlike '*%BIN_DIR%*') { [Environment]::SetEnvironmentVariable('PATH', $userPath + ';%BIN_DIR%', 'User'); Write-Host 'Added to PATH. Please restart your terminal.' -ForegroundColor Green } else { Write-Host 'Already in PATH.' -ForegroundColor Yellow }"

echo.
echo Installation complete!
echo To configure paths, open a new Command Prompt or PowerShell and type:
echo   wt config setup
echo.
pause
