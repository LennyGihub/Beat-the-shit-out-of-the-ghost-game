@echo off
rem Makes TikTok clips of the game (clipper.js). Studio open on the place with MCP, start-bridge.bat running, OBS open.
rem   make-clips.bat            4 clips (fight, entrance, giant, ultimate in turn)
rem   make-clips.bat 8          8 clips
rem   make-clips.bat 2 --kind fight --name scarecrow
cd /d "%~dp0"
set "N=%~1"
if "%N%"=="" set "N=4"
node clipper.js make %N% %2 %3 %4 %5 %6 %7
pause
