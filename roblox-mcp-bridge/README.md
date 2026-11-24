# Roblox Studio MCP bridge (PC → cloud Claude)

Studio's MCP server is a local program (`%LOCALAPPDATA%\Roblox\mcp.bat`), so only a
Claude session running **on the PC** can start it. This bridge lets a **cloud** session
(this game's environment, e.g. `Ghost ahh game`) use the same tools, to compare it with a local session.

```
Roblox Studio ⇄ mcp.bat (stdio, ONE copy) ⇄ mcp-gateway.js :8765 (127.0.0.1, API key) ⇄ ngrok https ⇄ cloud Claude
```

## One-time setup on the PC

1. Install Node.js (for `npx`) if `npx -v` fails in a terminal.
2. Install ngrok: `winget install ngrok.ngrok`, create a free account at ngrok.com, then
   `ngrok config add-authtoken <your token>` (the token from the ngrok dashboard).
3. In the ngrok dashboard → **Domains**, claim your free static domain
   (looks like `something-something.ngrok-free.app`).
4. Open `start-bridge.bat` and set `NGROK_DOMAIN` to that domain.
5. Tell Claude the domain (not the key). Claude then adds it to the cloud environment and
   asks for the bridge key through a secure form: paste the content of
   `%USERPROFILE%\roblox-mcp-bridge-key.txt` there, never in the chat.

## Microsoft Dev Tunnels instead of ngrok

ngrok's free plan stops after 1 GB a month. `start-bridge.bat` uses a Microsoft dev tunnel instead when the file
`%USERPROFILE%\roblox-mcp-bridge-tunnel.txt` holds a tunnel id. One-time setup: double-click
`setup-devtunnel.bat` (it does the steps below by itself, restarts the bridge, tests the tunnel and writes the
address in `%USERPROFILE%\roblox-devtunnel-result.txt`). By hand:

```
winget install Microsoft.devtunnel
devtunnel user login -g                      (sign in with GitHub)
devtunnel create -a                          (a persistent tunnel, anonymous access: the bridge key is the lock)
devtunnel port create <tunnel id> -p 8765 --protocol http
```

Put the tunnel id (one line, nothing else) in `%USERPROFILE%\roblox-mcp-bridge-tunnel.txt`. The address is
`https://<tunnel id>-8765.<region>.devtunnels.ms` (shown by `devtunnel host <tunnel id>`): give it to Claude,
which stores the bridge key for it through the secure form. A tunnel that is not used for 30 days is deleted.
Delete the file to go back to ngrok.

## Without the tunnel: GitHub sync

ngrok's free plan has a monthly bandwidth limit; once it is used up (error `ERR_NGROK_725`) no cloud session can
reach Studio until the next month. Scripts still get into the game:

```
cloud Claude -> git push (main, folder pending/src) -> GitHub -> pull-from-github.js on the PC -> mcp-gateway.js -> Studio
```

`start-bridge.bat` opens a **GitHub sync** window (`pull-from-github.js --watch`). Every 15 seconds it looks at the
`main` branch of the game's public repo and writes each new or changed script of `pending/src/` into the open
Studio (Edit mode only: it waits while a playtest runs). Nothing to log in to, no tunnel. It is one way: Claude
cannot see Studio through it (no playtest, no screenshots), so save the place and tell Claude what you see.
`node pull-from-github.js --all` pushes every pending script again. `github-sync.bat` restarts the sync alone (the gateway must be running).

## TikTok clips (clipper.js) - made by the cloud session

The cloud Claude session makes the clips by itself, at 60 fps: it starts a playtest, sets up each shot (a
first-person fight that ends in a knockout, a monster's entrance, an ultimate in the sandbox, a Moon form's giant in
the park), and through the gateway's **PC tools** (`pc_window`, `pc_ffmpeg`, `pc_get`... in mcp-gateway.js) brings
Studio to the front, records the game picture with ffmpeg (Windows desktop duplication, `ddagrab`: no OBS), edits it
on this PC (1080x1920 60 fps, the hook in the game's marker font, an end card "SEARCH JUMP THE GHOST ON ROBLOX - CODE:
TIKTOK") and downloads only the finished clip. Work files: `%USERPROFILE%\Videos\JumpTheGhost\work` (the PC tools
can touch nothing else; their ffmpeg arguments may not hold paths or network addresses). No game sound: the clips get
a TikTok sound when they are posted (the game's music / sounds are licensed for Roblox only).

One-time setup: double-click **`update-bridge.bat`** (or, the first time, in a PowerShell window in this folder:
`iwr -UseBasicParsing https://raw.githubusercontent.com/LennyGihub/Beat-the-shit-out-of-the-ghost-game/main/roblox-mcp-bridge/update-bridge.ps1 -OutFile update-bridge.ps1; powershell -ExecutionPolicy Bypass -File .\update-bridge.ps1`).
It downloads the new bridge files and installs ffmpeg. Then close the bridge windows and start `start-bridge.bat`.

While it films: Roblox Studio open on the place, the bridge running, the screen on (no sleep), and nobody using the
PC (the recording takes what is on the screen: Studio is brought to the front and maximised by itself).

On the PC itself: `make-clips.bat` (`node clipper.js make 4`) does the same; `--obs` records with OBS instead
(Tools > WebSocket Server Settings > Enable, password in `%USERPROFILE%\obs-websocket-password.txt`, a Window Capture
of Studio); `node clipper.js list` shows what it can film; `node clipper.js edit <video> --hook "..."` edits a video
you recorded yourself. Clips + captions: `%USERPROFILE%\Videos\JumpTheGhost\clips`; `history.json` keeps them from
repeating.

## Each time you want to test

1. Open Roblox Studio on your place, check **MCP Ready** (bottom-right).
2. Double-click `start-bridge.bat` (four windows open: gateway, image relay, GitHub sync, ngrok).
3. Start a **new** cloud session on this game's environment (`Ghost ahh game`).
4. When done, close the windows: the bridge is off and nothing can reach Studio.

## Getting the key when you are away from the PC

`show-key-once.bat` prints a one-time code and a temporary https address (a second, throw-away dev tunnel). Open
the address on your phone, enter the code, and the page shows the bridge key once; then the page and its address
are gone (also after 5 wrong codes or 15 minutes). Whoever starts it on the PC only passes on the address and the
code: the key is never shown in the window.

## Safety

- Anyone with the URL **and** the key can run Luau in your open Studio. The key stays in
  the file on your PC and in the environment's secret store; Claude never sees it.
- The gateway only listens on 127.0.0.1; the only way in is the ngrok address + key.
- Leave the bridge off when you are not testing. To change the key, delete the key file,
  start the bridge again (a new one is made) and update the secret in the environment.

## Why mcp-gateway.js (not supergateway)

`supergateway --stateful` started a new `mcp.bat` for every Claude session and every reconnect.
The copies fought over Studio's single connection, so Studio jumped between them and most calls
failed with "No Roblox Studio instances are connected" (log: `No studio available for proxy ...`,
`WebSocket error ... 10054`). `mcp-gateway.js` (plain Node, no packages) starts `mcp.bat` once,
restarts it if it dies, and shares it between all sessions. Its window logs each tool call.
