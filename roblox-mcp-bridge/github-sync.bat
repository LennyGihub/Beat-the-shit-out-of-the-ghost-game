@echo off
rem Starts only the GitHub sync (pending scripts from GitHub into the open Studio). The gateway must already
rem be running (start-bridge.bat opens this window by itself: use this file only to restart the sync alone).
title GitHub sync
set "PORT=8765"
set "KEYFILE=%USERPROFILE%\roblox-mcp-bridge-key.txt"
node "%~dp0pull-from-github.js" --watch
pause
