@echo off
rem Updates the bridge files from GitHub and installs ffmpeg if needed (update-bridge.ps1).
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-bridge.ps1"
pause
