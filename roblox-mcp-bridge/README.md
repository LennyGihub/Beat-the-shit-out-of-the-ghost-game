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

## Each time you want to test

1. Open Roblox Studio on your place, check **MCP Ready** (bottom-right).
2. Double-click `start-bridge.bat` (four windows open: gateway, image relay, GitHub sync, ngrok).
3. Start a **new** cloud session on this game's environment (`Ghost ahh game`).
4. When done, close the windows: the bridge is off and nothing can reach Studio.

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
