@echo off
rem Shows the bridge key ONCE on your phone (you are away from the PC and need the key).
rem This window prints a one-time code and a temporary https address: open the address on the phone,
rem enter the code, copy the key. The key is never shown in this window.
title Bridge key page
node "%~dp0show-key-once.js"
echo.
pause
