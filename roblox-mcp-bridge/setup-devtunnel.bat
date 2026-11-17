@echo off
rem One-time setup of the Microsoft dev tunnel for the bridge: double-click, nothing to type.
rem It installs devtunnel, signs in with GitHub (approve it in the browser), makes the tunnel,
rem restarts the bridge and tests it. The result is in %USERPROFILE%\roblox-devtunnel-result.txt
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-devtunnel.ps1"
echo.
pause
