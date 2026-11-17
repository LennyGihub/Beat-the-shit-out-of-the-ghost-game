# One-time setup of the Microsoft dev tunnel for the Roblox MCP bridge. Started by setup-devtunnel.bat
# (double-click that one). Nothing to type: it installs the devtunnel program, signs in with GitHub (it shows a
# code to enter at github.com/login/device, on any device), makes a persistent tunnel to port 8765, saves its id where start-bridge.bat looks for it,
# restarts the bridge and checks that the tunnel answers.
#
# It can be run again: an existing tunnel is kept. The bridge key is never read or shown.
# What it did is written to  %USERPROFILE%\roblox-devtunnel-result.txt  (short) and
# %USERPROFILE%\roblox-devtunnel-setup.log  (everything the programs printed).
$ErrorActionPreference = "Continue"
$port = 8765
$log = Join-Path $env:USERPROFILE "roblox-devtunnel-setup.log"
$result = Join-Path $env:USERPROFILE "roblox-devtunnel-result.txt"
$tunnelFile = Join-Path $env:USERPROFILE "roblox-mcp-bridge-tunnel.txt"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Say($text) {
    Write-Host $text
    Add-Content -Path $log -Value ((Get-Date -Format "HH:mm:ss") + " " + $text)
}
function Finish($status, $lines) {
    $all = @("status: " + $status) + $lines
    Set-Content -Path $result -Value $all
    Say ""
    Say "===== RESULT ====="
    foreach ($l in $all) { Say $l }
    Say "(saved in $result)"
    exit
}
function Find-DevTunnel {
    $c = Get-Command devtunnel -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    $link = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\devtunnel.exe"
    if (Test-Path $link) { return $link }
    $packages = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
    if (Test-Path $packages) {
        $f = Get-ChildItem -Path $packages -Recurse -Filter "devtunnel.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($f) { return $f.FullName }
    }
    return $null
}
# run devtunnel, keep what it printed in the log, return it as one text
function Run-DevTunnel($dt, $arguments) {
    Say ("> devtunnel " + ($arguments -join " "))
    $out = (& $dt @arguments 2>&1 | Out-String)
    Add-Content -Path $log -Value $out
    return $out
}

Set-Content -Path $log -Value ("Dev tunnel setup, " + (Get-Date))
Say "Setting up the Microsoft dev tunnel for the Roblox MCP bridge."

# 1) the devtunnel program
$dt = Find-DevTunnel
if (-not $dt) {
    Say "Installing devtunnel (winget)..."
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Finish "FAILED" @("step: install", "winget is not on this PC: install 'App Installer' from the Microsoft Store, then run this again")
    }
    $out = (& winget install --id Microsoft.devtunnel -e --accept-source-agreements --accept-package-agreements 2>&1 | Out-String)
    Add-Content -Path $log -Value $out
    $dt = Find-DevTunnel
}
if (-not $dt) { Finish "FAILED" @("step: install", "devtunnel.exe was not found after the install (see the log)") }
Say "devtunnel: $dt"

# 2) signed in? (GitHub account; the sign-in is kept on this PC)
$who = Run-DevTunnel $dt @("user", "show")
if ($LASTEXITCODE -ne 0 -or $who -match "(?i)not logged in") {
    # device code: devtunnel prints a short code below; it is entered at https://github.com/login/device
    # on any device (a phone works), signed in to the GitHub account. Nothing to click on this PC.
    Say "Signing in with GitHub. A CODE appears below: enter it at https://github.com/login/device (a phone works)."
    & $dt user login -g -d
    $who = Run-DevTunnel $dt @("user", "show")
    if ($LASTEXITCODE -ne 0 -or $who -match "(?i)not logged in") {
        Finish "FAILED" @("step: sign in", "the GitHub sign-in was not completed (run this again and enter the new code at https://github.com/login/device)")
    }
}
Say ("Signed in: " + $who.Trim())

# 3) the tunnel: the saved one if it still exists, else a new persistent one with anonymous access
#    (anyone can reach the address, but the gateway refuses every request without the bridge key)
$id = ""
if (Test-Path $tunnelFile) {
    $saved = (Get-Content -Path $tunnelFile -Raw)
    if ($saved) { $saved = $saved.Trim() }
    if ($saved) {
        $null = Run-DevTunnel $dt @("show", $saved)
        if ($LASTEXITCODE -eq 0) { $id = $saved; Say "Keeping the tunnel already saved: $id" }
    }
}
if (-not $id) {
    $out = Run-DevTunnel $dt @("create", "-a")
    if ($out -match "(?im)tunnel\s*id\s*:\s*(\S+)") { $id = $Matches[1] }
    if (-not $id) {
        $out = Run-DevTunnel $dt @("list")
        if ($out -match "(?m)^\s*([a-z0-9][a-z0-9-]*\.[a-z0-9]+)\s") { $id = $Matches[1] }
    }
    if (-not $id) { Finish "FAILED" @("step: create tunnel", "could not read the tunnel id from devtunnel's answer (it is in the log)") }
    Say "New tunnel: $id"
}

# 4) its port (an 'already exists' answer on a second run is fine)
$null = Run-DevTunnel $dt @("port", "create", $id, "-p", "$port", "--protocol", "http")

# 5) where start-bridge.bat looks for it (one line, nothing after the id)
[System.IO.File]::WriteAllText($tunnelFile, $id)

# 6) the public address: read it from devtunnel, else build it from the id (<name>.<region>)
$address = ""
$show = Run-DevTunnel $dt @("show", $id)
if ($show -match "(https://[a-z0-9-]+-$port\.[a-z0-9]+\.devtunnels\.ms)") { $address = $Matches[1] }
if (-not $address) {
    $parts = $id.Split(".")
    if ($parts.Length -ge 2) { $address = "https://" + $parts[0] + "-" + $port + "." + $parts[1] + ".devtunnels.ms" }
}

# 7) restart the bridge so it uses the tunnel (the old gateway, relay, sync and tunnel are stopped first)
Say "Restarting the bridge..."
# (found by what the programs are: in Windows Terminal the windows' titles cannot be used to find them)
$me = $PID
$old = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessId -ne $me -and $_.CommandLine -and (
        $_.CommandLine -match "mcp-gateway\.js|image-relay\.js|pull-from-github\.js" -or
        $_.Name -eq "ngrok.exe" -or
        ($_.Name -eq "devtunnel.exe" -and $_.CommandLine -match " host "))
}
foreach ($p in $old) { $null = (& taskkill /PID $p.ProcessId /T /F 2>&1 | Out-String) }
Start-Sleep -Seconds 2
$bat = Join-Path $here "start-bridge.bat"
if (-not (Test-Path $bat)) { Finish "FAILED" @("step: restart", "start-bridge.bat is not next to this script ($here)", "tunnel id: $id", "address: $address") }
Start-Process -FilePath $bat -WorkingDirectory $here

# 8) does the tunnel answer? A request without the key must be refused by the gateway: 401 = it works end to end
$code = ""
if ($address) {
    for ($try = 1; $try -le 5; $try++) {
        Start-Sleep -Seconds 8
        $code = (& curl.exe -s -o NUL -w "%{http_code}" -m 30 -X POST ($address + "/mcp") -H "Content-Type: application/json" -H "Accept: application/json" -d "{}" 2>&1 | Out-String).Trim()
        Say "test $try : the tunnel answered $code"
        if ($code -eq "401") { break }
    }
}
if ($code -eq "401") {
    Finish "OK" @("address: $address", "tunnel id: $id", "test: 401 (the tunnel reaches the gateway)", "next: give this address to Claude")
} else {
    Finish "TUNNEL MADE, TEST NOT PASSED" @("address: $address", "tunnel id: $id", "test: '$code' (expected 401)", "look at the 'Dev tunnel' and 'Roblox MCP gateway' windows; details in $log")
}
