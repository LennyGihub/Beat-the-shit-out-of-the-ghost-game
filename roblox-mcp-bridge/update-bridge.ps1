# UPDATE THE BRIDGE (2026-11-24): downloads the latest bridge files from the game's GitHub repo into this folder
# (the one with start-bridge.bat) and installs ffmpeg if it is missing (the cloud session records and edits the
# TikTok clips with it: mcp-gateway.js PC tools). Then close the bridge windows and start start-bridge.bat again.
# Double-click update-bridge.bat, or in a PowerShell window in this folder: powershell -ExecutionPolicy Bypass -File .\update-bridge.ps1
$ErrorActionPreference = "Stop"
$base = "https://raw.githubusercontent.com/LennyGihub/Beat-the-shit-out-of-the-ghost-game/main/roblox-mcp-bridge"
$here = $PSScriptRoot
if (-not $here -or -not (Test-Path (Join-Path $here "start-bridge.bat"))) { $here = (Get-Location).Path }
if (-not (Test-Path (Join-Path $here "start-bridge.bat"))) { Write-Host "Run this in the bridge folder (the one with start-bridge.bat)."; exit 1 }
$files = "mcp-gateway.js", "start-bridge.bat", "pull-from-github.js", "image-relay.js", "github-sync.bat", "clipper.js", "make-clips.bat", "update-bridge.ps1", "update-bridge.bat", "README.md"
foreach ($f in $files) {
  try {
    Invoke-WebRequest "$base/$f" -OutFile (Join-Path $here $f) -UseBasicParsing
    Write-Host "updated $f"
  } catch { Write-Host "could not download $f : $($_.Exception.Message)" }
}
$links = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\ffmpeg.exe"
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue) -and -not (Test-Path $links)) {
  Write-Host "installing ffmpeg (the clips are recorded and edited with it)..."
  winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements
} else { Write-Host "ffmpeg is already installed" }
Write-Host ""
Write-Host "Done. Close the bridge windows (Roblox MCP gateway, Image relay, GitHub sync, Dev tunnel) and double-click start-bridge.bat again."
