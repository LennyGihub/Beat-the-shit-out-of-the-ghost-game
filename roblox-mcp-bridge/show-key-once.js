// Show the bridge key ONCE, on the owner's phone, without anybody else seeing it.
//
// For when the owner is away from the PC and needs the key (to give it to a cloud environment through its secure
// form). Started by show-key-once.bat. It:
//   1. makes a one-time code and prints it in this window (the code is NOT the key);
//   2. opens a temporary Microsoft dev tunnel to a tiny page on this PC and prints its https address;
//   3. the page asks for the code; with the right code it shows the key once, then everything shuts down and the
//      temporary address stops existing.
// Whoever helps on the PC only passes on the address and the code. The key itself is never printed here, never
// written anywhere, and the page is gone after one use, 5 wrong codes or 15 minutes.
//
// Plain Node (18+), no packages. Needs `devtunnel` signed in (setup-devtunnel.bat did that).
// Env: KEYFILE (bridge key file), KEYPAGE_PORT (8771), NO_TUNNEL=1 (tests: no tunnel, local page only).
const http = require("http");
const fs = require("fs");
const os = require("os");
const path = require("path");
const crypto = require("crypto");
const { spawn, execFile } = require("child_process");

const PORT = Number(process.env.KEYPAGE_PORT || 8771);
const KEYFILE = process.env.KEYFILE || path.join(os.homedir(), "roblox-mcp-bridge-key.txt");
const LIFETIME_MS = 15 * 60 * 1000;
const MAX_TRIES = 5;

let key;
try {
  key = fs.readFileSync(KEYFILE, "utf8").trim();
} catch {
  console.log("The key file was not found: " + KEYFILE);
  process.exit(1);
}
if (!key) {
  console.log("The key file is empty: " + KEYFILE);
  process.exit(1);
}

// 8 letters / digits that cannot be mistaken for each other, shown as XXXX-XXXX
const ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
let code = "";
while (code.length < 8) {
  const b = crypto.randomBytes(1)[0];
  if (b < ALPHABET.length * 8) code += ALPHABET[b % ALPHABET.length]; // (no bias: 248 = 31 * 8)
}
const shown = code.slice(0, 4) + "-" + code.slice(4);

let tries = 0;
let done = false;
let tunnel = null;

function page(body) {
  return `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Bridge key</title><style>
body{font-family:system-ui,sans-serif;background:#15110f;color:#e8dec8;margin:0;padding:24px;max-width:520px}
h1{font-size:20px}input,button{font-size:18px;padding:12px;border-radius:8px;border:1px solid #6a5a4a;width:100%;box-sizing:border-box;margin-top:10px}
input{background:#241d1a;color:#e8dec8}button{background:#96121a;color:#fff;border:0}p{line-height:1.4}.ok{color:#96dc6e}.bad{color:#e6463c}
</style></head><body>${body}</body></html>`;
}
const FORM = (note) => page(`<h1>Roblox bridge key</h1><p>Enter the one-time code shown on the PC.</p>${note}
<form method="post" action="/"><input name="code" autocomplete="off" autocapitalize="characters" placeholder="XXXX-XXXX" autofocus>
<button type="submit">Show the key</button></form>`);

function shutdown(why) {
  if (done) return;
  done = true;
  console.log("");
  console.log(why);
  console.log("The page is closed. You can close this window.");
  server.close();
  if (tunnel && tunnel.pid) {
    if (process.platform === "win32") execFile("taskkill", ["/PID", String(tunnel.pid), "/T", "/F"], () => process.exit(0));
    else { tunnel.kill(); process.exit(0); }
    setTimeout(() => process.exit(0), 4000);
  } else {
    setTimeout(() => process.exit(0), 500);
  }
}

const server = http.createServer((req, res) => {
  const headers = { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store", "X-Robots-Tag": "noindex" };
  if (done) { res.writeHead(410, headers).end(page("<h1>Closed</h1><p>This page was already used.</p>")); return; }
  const url = (req.url || "/").split("?")[0];
  if (url !== "/") { res.writeHead(404, headers).end(page("<h1>Not found</h1>")); return; }
  if (req.method === "GET") { res.writeHead(200, headers).end(FORM("")); return; }
  if (req.method !== "POST") { res.writeHead(405, headers).end(); return; }
  let body = "";
  req.on("data", (c) => {
    body += c;
    if (body.length > 2000) req.destroy();
  });
  req.on("end", () => {
    if (done) { res.writeHead(410, headers).end(page("<h1>Closed</h1>")); return; }
    const given = String(new URLSearchParams(body).get("code") || "").toUpperCase().replace(/[^A-Z0-9]/g, "");
    const a = crypto.createHash("sha256").update(given).digest();
    const b = crypto.createHash("sha256").update(code).digest();
    if (!crypto.timingSafeEqual(a, b)) {
      tries++;
      const left = MAX_TRIES - tries;
      console.log("A wrong code was entered (" + left + " tries left).");
      // a pause before the answer slows down guessing
      setTimeout(() => {
        if (left <= 0) {
          res.writeHead(403, headers).end(page('<h1>Closed</h1><p class="bad">Too many wrong codes. Start again on the PC.</p>'));
          shutdown("Too many wrong codes: nothing was shown.");
        } else {
          res.writeHead(200, headers).end(FORM('<p class="bad">Wrong code. ' + left + " tries left.</p>"));
        }
      }, 1500);
      return;
    }
    const safe = key.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/"/g, "&quot;");
    res.writeHead(200, headers).end(page(`<h1 class="ok">Here is the bridge key</h1>
<p>Copy it now: this page works only once. Paste it in Claude's secure form (never in a chat).</p>
<input id="k" readonly value="${safe}" onclick="this.select()">
<button onclick="var k=document.getElementById('k');k.select();if(navigator.clipboard){navigator.clipboard.writeText(k.value).then(function(){document.getElementById('m').textContent='Copied.'})}else{document.execCommand('copy');document.getElementById('m').textContent='Copied.'}">Copy</button>
<p id="m" class="ok"></p>`));
    shutdown("The right code was entered: the key was shown once on that device.");
  });
});

server.listen(PORT, "127.0.0.1", () => {
  console.log("==================================================");
  console.log("  ONE-TIME CODE:   " + shown);
  console.log("==================================================");
  console.log("(this code is not the key; it works once, for 15 minutes)");
  console.log("");
  if (process.env.NO_TUNNEL === "1") {
    console.log("ADDRESS: http://127.0.0.1:" + PORT + "/  (test: no tunnel)");
    return;
  }
  console.log("Opening a temporary tunnel, the ADDRESS appears below in a few seconds...");
  tunnel = process.platform === "win32"
    ? spawn("cmd.exe", ["/c", "devtunnel", "host", "-p", String(PORT), "-a"], { stdio: ["ignore", "pipe", "pipe"], windowsHide: true })
    : spawn("devtunnel", ["host", "-p", String(PORT), "-a"], { stdio: ["ignore", "pipe", "pipe"] });
  let seen = false;
  const onText = (d) => {
    const text = String(d);
    const m = text.match(new RegExp("https://[a-z0-9-]+-" + PORT + "\\.[a-z0-9]+\\.devtunnels\\.ms"));
    if (m && !seen) {
      seen = true;
      console.log("");
      console.log("==================================================");
      console.log("  ADDRESS:   " + m[0]);
      console.log("==================================================");
      console.log("Open that address on the phone, press Continue on Microsoft's warning page, enter the code.");
    } else if (!seen) {
      process.stdout.write("[devtunnel] " + text);
    }
  };
  tunnel.stdout.on("data", onText);
  tunnel.stderr.on("data", onText);
  tunnel.on("exit", (c) => { if (!done) shutdown("The temporary tunnel stopped (code " + c + "): nothing was shown. Is devtunnel signed in?"); });
});

setTimeout(() => shutdown("15 minutes passed: nothing was shown."), LIFETIME_MS).unref();
