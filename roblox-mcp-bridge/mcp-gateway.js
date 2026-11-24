// Single-process MCP gateway: ONE Studio MCP (mcp.bat) shared by every Claude session.
//
// Why: supergateway --stateful starts a new mcp.bat for every MCP session / reconnect. Each copy
// fights for Studio's single connection, so Studio keeps jumping between them and every other
// call fails with "No Roblox Studio instances are connected". This gateway starts mcp.bat once,
// keeps it alive (restarts it if it dies) and multiplexes all sessions onto it by remapping
// JSON-RPC ids. Streamable HTTP, JSON responses (no SSE), API key, 127.0.0.1 only.
//
// Env: PORT (8765), KEYFILE (bridge key file), HELPER (cmd that starts Studio's mcp.bat)
const http = require("http");
const fs = require("fs");
const crypto = require("crypto");
const { spawn } = require("child_process");

const PORT = Number(process.env.PORT || 8765);
const KEY = fs.readFileSync(process.env.KEYFILE, "utf8").trim();
const HELPER = process.env.HELPER;
const CALL_TIMEOUT_MS = 10 * 60 * 1000; // generate_mesh etc. can take minutes

let child = null;
let buf = "";
let nextId = 1;
const pending = new Map(); // internal id -> { resolve }
let initResult = null; // cached result of our own initialize
let ready = null; // promise resolved when the child is initialized

function log(...a) {
  console.log(new Date().toISOString().slice(11, 19), ...a);
}

function send(msg) {
  child.stdin.write(JSON.stringify(msg) + "\n");
}

function request(method, params) {
  const id = nextId++;
  return new Promise((resolve) => {
    const timer = setTimeout(() => {
      pending.delete(id);
      resolve({ jsonrpc: "2.0", id, error: { code: -32001, message: "Studio MCP timed out" } });
    }, CALL_TIMEOUT_MS);
    pending.set(id, { resolve: (m) => { clearTimeout(timer); resolve(m); } });
    send({ jsonrpc: "2.0", id, method, params });
  });
}

function onChildMessage(msg) {
  if (msg.id !== undefined && (msg.result !== undefined || msg.error !== undefined)) {
    const p = pending.get(msg.id);
    if (p) {
      pending.delete(msg.id);
      p.resolve(msg);
    }
  } else if (msg.method && msg.id !== undefined) {
    // server -> client request (e.g. ping): answer it ourselves
    send({ jsonrpc: "2.0", id: msg.id, result: {} });
  } // server notifications are dropped (no SSE stream to deliver them on)
}

function startChild() {
  log("starting Studio MCP:", HELPER);
  buf = "";
  child = process.platform === "win32"
    ? spawn("cmd.exe", ["/c", HELPER], { stdio: ["pipe", "pipe", "pipe"], windowsHide: true })
    : spawn("sh", [HELPER], { stdio: ["pipe", "pipe", "pipe"] });
  child.stdout.setEncoding("utf8");
  child.stdout.on("data", (chunk) => {
    buf += chunk;
    let i;
    while ((i = buf.indexOf("\n")) >= 0) {
      const line = buf.slice(0, i).trim();
      buf = buf.slice(i + 1);
      if (!line) continue;
      try {
        onChildMessage(JSON.parse(line));
      } catch {
        log("child (non-JSON):", line.slice(0, 200));
      }
    }
  });
  child.stderr.setEncoding("utf8");
  child.stderr.on("data", (d) => process.stderr.write("[studio-mcp] " + d));
  child.on("exit", (code) => {
    log("Studio MCP exited with code", code, "- restarting in 2 s");
    for (const [id, p] of pending) p.resolve({ jsonrpc: "2.0", id, error: { code: -32002, message: "Studio MCP restarted" } });
    pending.clear();
    initResult = null;
    setTimeout(boot, 2000);
  });
}

function boot() {
  startChild();
  ready = request("initialize", {
    protocolVersion: "2025-03-26",
    capabilities: {},
    clientInfo: { name: "roblox-mcp-bridge", version: "2.0" },
  }).then((r) => {
    if (r.error) throw new Error(r.error.message);
    initResult = r.result;
    send({ jsonrpc: "2.0", method: "notifications/initialized" });
    log("Studio MCP ready:", JSON.stringify(initResult.serverInfo || {}));
  });
  ready.catch((e) => log("initialize failed:", e.message));
}

// ---- PC TOOLS (2026-11-24: the TikTok clip maker, run by the cloud session) --------------------------------------
// Tools this gateway answers itself (they never reach Studio): pc_info, pc_window, pc_ffmpeg, pc_job, pc_stop,
// pc_put, pc_get, pc_files. They only touch one folder, WORK (%USERPROFILE%\Videos\JumpTheGhost\work): file names are
// plain names (no folders), ffmpeg runs inside it, and its arguments (and a -filter_complex_script file) may not hold
// paths, ".." or network / file protocols. Same key as everything else. The screen is recorded with ffmpeg's
// ddagrab (Windows desktop duplication: 60 fps, light on the PC); the edits run here too, only the finished clips go
// back through the tunnel.
const os = require("os");
const path = require("path");
const WORK = process.env.CLIP_WORK || path.join(os.homedir(), "Videos", "JumpTheGhost", "work");
// (winget puts ffmpeg in WinGet\Links: found there even before Windows refreshes the PATH of this window)
const WINGET_FFMPEG = path.join(process.env.LOCALAPPDATA || "", "Microsoft", "WinGet", "Links", "ffmpeg.exe");
const FFMPEG = process.env.FFMPEG || (process.platform === "win32" && fs.existsSync(WINGET_FFMPEG) ? WINGET_FFMPEG : "ffmpeg");
const jobs = new Map();
let jobN = 0;
const NAME = /^[A-Za-z0-9][A-Za-z0-9_.-]{0,100}$/;
const BAD_ARG = /(^[A-Za-z]:[\\/])|(^[\\/])|(\.\.)|(^(https?|ftp|file|tcp|udp|rtmp|rtsp|concat|subfile|pipe|data|crypto|async|cache|smb|sftp|srt|gopher|unix|fd|tee|tls|zmq):)/i;
const BAD_GRAPH = /([A-Za-z]:[\\/])|(\\\\)|(\.\.)|([=:,;'"]\/)|\bmovie=|\bamovie=|sendcmd|zmq/i;
function inWork(n) {
  if (typeof n !== "string" || !NAME.test(n) || n.includes("..")) throw new Error("bad file name: " + n);
  return path.join(WORK, n);
}
function checkArgs(args) {
  if (!Array.isArray(args) || args.length > 200) throw new Error("args must be a list");
  args.forEach((a, i) => {
    if (typeof a !== "string" || a.length > 4000) throw new Error("bad argument");
    if (BAD_ARG.test(a)) throw new Error("argument not allowed: " + a.slice(0, 80));
    if (args[i - 1] === "-filter_complex_script" && BAD_GRAPH.test(fs.readFileSync(inWork(a), "utf8"))) throw new Error("filter script not allowed");
  });
}
function runCapture(cmd, args, input) {
  return new Promise((resolve) => {
    let out = "", err = "";
    let p;
    try { p = spawn(cmd, args, { windowsHide: true }); } catch (e) { resolve({ code: -2, out: "", err: String(e.message) }); return; }
    p.stdout.on("data", (d) => (out += d));
    p.stderr.on("data", (d) => (err += d));
    p.on("error", (e) => resolve({ code: -2, out, err: err + e.message }));
    p.on("exit", (code) => resolve({ code, out, err }));
    if (input) p.stdin.end(input);
  });
}
const PS_WINDOW = `
Add-Type @"
using System; using System.Runtime.InteropServices;
public class W {
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern void keybd_event(byte k, byte s, uint f, UIntPtr e);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  public struct RECT { public int L, T, R, B; }
}
"@
$p = Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $p) { "none"; exit }
[W]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero); [W]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
[W]::ShowWindow($p.MainWindowHandle, 3) | Out-Null
[W]::SetForegroundWindow($p.MainWindowHandle) | Out-Null
Start-Sleep -Milliseconds 400
$r = New-Object W+RECT; [W]::GetWindowRect($p.MainWindowHandle, [ref]$r) | Out-Null
"$($r.L),$($r.T),$($r.R),$($r.B)"`;
const PS_AWAKE = (s) => `
Add-Type @"
using System; using System.Runtime.InteropServices;
public class A { [DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f); }
"@
[A]::SetThreadExecutionState(0x80000003) | Out-Null
Start-Sleep -Seconds ${Math.max(1, Math.min(3600, Math.floor(s)))}`;
let awake = null;
const PC_TOOLS = [
  { name: "pc_info", description: "PC side of the clip maker: ffmpeg version, H.264 encoders, the work folder.", inputSchema: { type: "object", properties: {} } },
  { name: "pc_window", description: "Brings Roblox Studio to the front, maximised; keeps the screen awake for awake_s seconds. Returns the window rectangle.", inputSchema: { type: "object", properties: { awake_s: { type: "number" } } } },
  { name: "pc_ffmpeg", description: "Runs ffmpeg in the work folder (plain file names only). wait=true waits for the end; else returns a job id.", inputSchema: { type: "object", properties: { args: { type: "array", items: { type: "string" } }, wait: { type: "boolean" }, timeout_s: { type: "number" } }, required: ["args"] } },
  { name: "pc_job", description: "A pc_ffmpeg job: running or its exit code, and the end of its log. wait_s waits up to that long for it to end.", inputSchema: { type: "object", properties: { job: { type: "string" }, wait_s: { type: "number" } }, required: ["job"] } },
  { name: "pc_stop", description: "Asks a running pc_ffmpeg job to finish (like pressing q).", inputSchema: { type: "object", properties: { job: { type: "string" } }, required: ["job"] } },
  { name: "pc_put", description: "Writes a file (base64) into the work folder.", inputSchema: { type: "object", properties: { name: { type: "string" }, data: { type: "string" }, append: { type: "boolean" } }, required: ["name", "data"] } },
  { name: "pc_get", description: "Reads part of a file of the work folder (base64, 6 MB at most per call).", inputSchema: { type: "object", properties: { name: { type: "string" }, offset: { type: "number" }, length: { type: "number" } }, required: ["name"] } },
  { name: "pc_files", description: "Lists the work folder; delete = names to remove first.", inputSchema: { type: "object", properties: { delete: { type: "array", items: { type: "string" } } } } },
];
async function pcTool(name, a) {
  fs.mkdirSync(WORK, { recursive: true });
  if (name === "pc_info") {
    const v = await runCapture(FFMPEG, ["-hide_banner", "-version"]);
    const e = v.code === 0 ? await runCapture(FFMPEG, ["-hide_banner", "-encoders"]) : { out: "" };
    const f = v.code === 0 ? await runCapture(FFMPEG, ["-hide_banner", "-filters"]) : { out: "" };
    const enc = ["h264_nvenc", "h264_qsv", "h264_amf", "libx264"].filter((x) => e.out.includes(" " + x + " "));
    return { platform: process.platform, ffmpeg: v.code === 0 ? v.out.split("\n")[0] : null, encoders: enc, ddagrab: / ddagrab /.test(f.out), drawtext: / drawtext /.test(f.out), work: WORK, cpus: os.cpus().length };
  }
  if (name === "pc_window") {
    if (process.platform !== "win32") return { rect: null };
    const r = await runCapture("powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", PS_WINDOW]);
    if (a.awake_s) {
      if (awake) try { awake.kill(); } catch {}
      awake = spawn("powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", PS_AWAKE(a.awake_s)], { windowsHide: true, stdio: "ignore" });
    }
    return { rect: r.out.trim() || null, err: r.err.slice(-300) };
  }
  if (name === "pc_ffmpeg") {
    checkArgs(a.args);
    const id = "j" + ++jobN;
    const p = spawn(FFMPEG, a.args, { cwd: WORK, windowsHide: true, stdio: ["pipe", "ignore", "pipe"] });
    const job = { p, err: "", code: null, t0: Date.now() };
    p.stderr.setEncoding("utf8");
    p.stderr.on("data", (d) => (job.err = (job.err + d).slice(-8000)));
    p.on("exit", (c) => (job.code = c === null ? -1 : c));
    p.on("error", (e) => { job.code = -2; job.err += "\n" + e.message; });
    setTimeout(() => { if (job.code === null) try { p.kill(); } catch {} }, Math.min(3600, a.timeout_s || 900) * 1000);
    jobs.set(id, job);
    if (!a.wait) return { job: id };
    while (job.code === null) await new Promise((r) => setTimeout(r, 200));
    return { job: id, code: job.code, log: job.err.slice(-1500), seconds: (Date.now() - job.t0) / 1000 };
  }
  if (name === "pc_job" || name === "pc_stop") {
    const job = jobs.get(a.job);
    if (!job) throw new Error("no job " + a.job);
    if (name === "pc_stop" && job.code === null) try { job.p.stdin.write("q"); } catch {}
    const until = Date.now() + Math.min(600, a.wait_s || (name === "pc_stop" ? 15 : 0)) * 1000;
    while (job.code === null && Date.now() < until) await new Promise((r) => setTimeout(r, 200));
    return { running: job.code === null, code: job.code, log: job.err.slice(-1500), seconds: (Date.now() - job.t0) / 1000 };
  }
  if (name === "pc_put") {
    const buf = Buffer.from(String(a.data || ""), "base64");
    if (buf.length > 25e6) throw new Error("too big");
    (a.append ? fs.appendFileSync : fs.writeFileSync)(inWork(a.name), buf);
    return { name: a.name, size: fs.statSync(inWork(a.name)).size };
  }
  if (name === "pc_get") {
    const f = inWork(a.name);
    const size = fs.statSync(f).size;
    const off = Math.max(0, Math.floor(a.offset || 0));
    const len = Math.max(0, Math.min(6e6, Math.floor(a.length || 6e6), size - off));
    const fd = fs.openSync(f, "r");
    const buf = Buffer.alloc(len);
    fs.readSync(fd, buf, 0, len, off);
    fs.closeSync(fd);
    return { name: a.name, size, offset: off, data: buf.toString("base64") };
  }
  if (name === "pc_files") {
    for (const n of a.delete || []) try { fs.unlinkSync(inWork(n)); } catch {}
    return { work: WORK, files: fs.readdirSync(WORK).map((n) => ({ name: n, size: fs.statSync(path.join(WORK, n)).size })) };
  }
  throw new Error("unknown tool " + name);
}

function authorized(req) {
  const a = req.headers["authorization"] || "";
  const x = req.headers["x-api-key"] || "";
  const token = a.startsWith("Bearer ") ? a.slice(7) : a;
  const ok = (t) => t && t.length === KEY.length && crypto.timingSafeEqual(Buffer.from(t), Buffer.from(KEY));
  return ok(token.trim()) || ok(String(x).trim());
}

async function handle(msg) {
  if (msg.method === "initialize") {
    await ready;
    return { jsonrpc: "2.0", id: msg.id, result: initResult };
  }
  if (msg.id === undefined) {
    // client notification: "initialized" was already sent by us; forward anything else
    if (msg.method && msg.method !== "notifications/initialized") send(msg);
    return null;
  }
  if (!msg.method) return null; // a client response to a server request: nothing waits for it
  // the PC tools are answered here (see PC TOOLS above)
  if (msg.method === "tools/call" && msg.params && String(msg.params.name).startsWith("pc_")) {
    try {
      const out = await pcTool(msg.params.name, msg.params.arguments || {});
      return { jsonrpc: "2.0", id: msg.id, result: { content: [{ type: "text", text: JSON.stringify(out) }] } };
    } catch (e) {
      return { jsonrpc: "2.0", id: msg.id, result: { isError: true, content: [{ type: "text", text: String(e.message || e) }] } };
    }
  }
  await ready;
  const r = await request(msg.method, msg.params);
  if (msg.method === "tools/list" && r.result && Array.isArray(r.result.tools)) r.result.tools = r.result.tools.concat(PC_TOOLS);
  return { jsonrpc: "2.0", id: msg.id, ...(r.error ? { error: r.error } : { result: r.result }) };
}

http
  .createServer((req, res) => {
    if (!req.url.startsWith("/mcp")) {
      res.writeHead(404).end();
      return;
    }
    if (!authorized(req)) {
      res.writeHead(401).end("unauthorized");
      return;
    }
    if (req.method === "DELETE") {
      res.writeHead(200).end();
      return;
    }
    if (req.method !== "POST") {
      res.writeHead(405, { Allow: "POST, DELETE" }).end();
      return;
    }
    let body = "";
    req.setEncoding("utf8");
    req.on("data", (c) => (body += c));
    req.on("end", async () => {
      let parsed;
      try {
        parsed = JSON.parse(body);
      } catch {
        res.writeHead(400).end("bad json");
        return;
      }
      const batch = Array.isArray(parsed);
      const msgs = batch ? parsed : [parsed];
      const headers = { "Content-Type": "application/json" };
      if (msgs.some((m) => m.method === "initialize")) headers["Mcp-Session-Id"] = crypto.randomUUID();
      else if (req.headers["mcp-session-id"]) headers["Mcp-Session-Id"] = req.headers["mcp-session-id"];
      try {
        const out = (await Promise.all(msgs.map(handle))).filter(Boolean);
        if (out.length === 0) {
          res.writeHead(202, headers).end();
          return;
        }
        const tool = msgs.find((m) => m.method === "tools/call");
        if (tool) log("call", tool.params && tool.params.name);
        res.writeHead(200, headers).end(JSON.stringify(batch ? out : out[0]));
      } catch (e) {
        res.writeHead(500, headers).end(JSON.stringify({ jsonrpc: "2.0", id: null, error: { code: -32603, message: String(e.message || e) } }));
      }
    });
  })
  .listen(PORT, "127.0.0.1", () => log("MCP gateway on http://127.0.0.1:" + PORT + "/mcp (one shared Studio MCP)"));

boot();
