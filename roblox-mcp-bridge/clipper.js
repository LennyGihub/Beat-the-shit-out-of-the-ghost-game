#!/usr/bin/env node
"use strict";
// THE TIKTOK CLIP MAKER (2026-11-24, week 1 of the TikTok plan). Runs on the PC, next to the bridge.
// It films the game in a Studio playtest, edits every clip for TikTok and writes its caption:
//   node clipper.js make [count] [--kind fight|entrance|ultimate|giant] [--name <monster / ultimate / form>]
//   node clipper.js edit <video> --hook "<text>" [--layout full|framed]     (edit a video you recorded yourself)
//   node clipper.js list                                                    (what it can film)
// (make-clips.bat = "node clipper.js make 4")
// How: Studio (through mcp-gateway.js, like pull-from-github.js) -> the game's Studio-only film camera + bot
// (Client/ClipCam: player attributes ClipShot / ClipCalib) -> the PC records the game picture at 60 fps: by default
// through the gateway's PC tools (pc_window / pc_ffmpeg: ffmpeg ddagrab, no OBS; the edit runs on the PC too and only
// the finished clip comes back, so a cloud session can make clips by itself), or with OBS (--obs) ->
// ffmpeg edits: finds the game picture by the magenta calibration frame, makes it 1080x1920, writes the hook in
// the game's marker font, adds the end card ("SEARCH JUMP THE GHOST ON ROBLOX - CODE: TIKTOK").
// Output: %USERPROFILE%\Videos\JumpTheGhost\clips\<date>_<kind>_<name>.mp4 + .txt (the caption to paste).
// The game's MUSIC is muted while filming (it is licensed for Roblox only): add a TikTok sound when you post.
// Needs: Roblox Studio open on the place with MCP connected, start-bridge.bat running, OBS open (Tools > WebSocket
// Server Settings > Enable; its password in %USERPROFILE%\obs-websocket-password.txt) with a scene capturing the
// Studio window, ffmpeg (winget install Gyan.FFmpeg), Node 22+. The Studio window must stay visible (not
// minimised, screen on) while it films. It starts a playtest by itself and stops it at the end.
// Env: PORT, KEYFILE, ROBLOX_MCP_URL (like the other bridge scripts), OBS_URL (ws://127.0.0.1:4455), OBS_PASSWORD,
// CLIPS_DIR, FFMPEG, FFPROBE, STUDIO (part of the Studio window's name). Test without OBS: --frames (screenshots).
const fs = require("fs");
const path = require("path");
const os = require("os");
const crypto = require("crypto");
const { spawnSync } = require("child_process");

const PORT = process.env.PORT || "8765";
const KEYFILE = process.env.KEYFILE || path.join(os.homedir(), "roblox-mcp-bridge-key.txt");
const MCP = process.env.ROBLOX_MCP_URL || `http://127.0.0.1:${PORT}/mcp`;
const OBS_URL = process.env.OBS_URL || "ws://127.0.0.1:4455";
const OBS_PASSFILE = path.join(os.homedir(), "obs-websocket-password.txt");
const OUT = process.env.CLIPS_DIR || path.join(os.homedir(), "Videos", "JumpTheGhost");
const FONT_DIR = path.join(__dirname, "fonts");
const FONT = path.join(FONT_DIR, "PermanentMarker-Regular.ttf");
const FONT_URL = "https://raw.githubusercontent.com/google/fonts/main/apache/permanentmarker/PermanentMarker-Regular.ttf";
const FFMPEG = process.env.FFMPEG || "ffmpeg";
const FFPROBE = process.env.FFPROBE || "ffprobe";
const WANT = (process.env.STUDIO || "").toLowerCase();
const W = 1080, H = 1920, FPS = 30, END_CARD = 2.4;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const log = (...a) => console.log(...a);

// ---- arguments --------------------------------------------------------------------------------------------------
const argv = process.argv.slice(2);
function opt(name, def) {
  const i = argv.indexOf("--" + name);
  if (i < 0) return def;
  const v = argv[i + 1];
  argv.splice(i, v !== undefined && !v.startsWith("--") ? 2 : 1);
  return v !== undefined && !v.startsWith("--") ? v : true;
}

// ---- Studio, through the local gateway -------------------------------------------------------------------------------
let session = null, nextId = 10, SID = null;
function key() { try { return fs.readFileSync(KEYFILE, "utf8").trim(); } catch { return null; } }
async function rpc(body) {
  const headers = { "Content-Type": "application/json", Accept: "application/json, text/event-stream", "X-Tunnel-Skip-AntiPhishing-Page": "true" };
  const k = key();
  if (k) headers["x-api-key"] = k;
  if (session) { headers["Mcp-Session-Id"] = session; headers["MCP-Protocol-Version"] = "2025-06-18"; }
  let last = "";
  for (let attempt = 0; attempt < 6; attempt++) {
    let r;
    try {
      r = await fetch(MCP, { method: "POST", headers, body: JSON.stringify(body) });
    } catch (e) {
      last = "the bridge is not running (start start-bridge.bat first)";
      await sleep(1500 * (attempt + 1));
      continue;
    }
    if ([502, 503, 504].includes(r.status)) { last = "the bridge answered " + r.status; await sleep(1500 * (attempt + 1)); continue; }
    if (r.status === 401) throw new Error("the bridge refused the key in " + KEYFILE);
    if (!r.ok && r.status !== 202) throw new Error("the bridge answered " + r.status);
    session = r.headers.get("mcp-session-id") || session;
    const text = await r.text();
    if (!text) return null;
    const data = text.split(/\r?\n/).filter((l) => l.startsWith("data: ")).map((l) => l.slice(6));
    return JSON.parse(data.length ? data[data.length - 1] : text);
  }
  throw new Error(last);
}
async function call(name, a) {
  if (!session) {
    await rpc({ jsonrpc: "2.0", id: 1, method: "initialize", params: { protocolVersion: "2025-06-18", capabilities: {}, clientInfo: { name: "clipper", version: "1" } } });
    await rpc({ jsonrpc: "2.0", method: "notifications/initialized" });
  }
  const d = await rpc({ jsonrpc: "2.0", id: ++nextId, method: "tools/call", params: { name, arguments: a } });
  if (!d || d.error) throw new Error(name + ": " + JSON.stringify(d && d.error));
  if (d.result.isError) throw new Error(name + ": " + (d.result.content || []).map((c) => c.text || "").join("").slice(0, 300));
  return d.result.content || [];
}
const textOf = (content) => content.map((c) => c.text || "").join("");
async function pickStudio() {
  const t = textOf(await call("list_roblox_studios", {}));
  const i = t.search(/[{[]/);
  const parsed = JSON.parse(i >= 0 ? t.slice(i) : t);
  const open = (parsed.studios || parsed || []).filter((s) => s && s.name && (!WANT || String(s.name).toLowerCase().includes(WANT)));
  if (!open.length) throw new Error("no Roblox Studio has the place open with MCP connected");
  SID = open[0].id;
  return open[0];
}
async function luau(dm, code) { return textOf(await call("execute_luau", { studio_id: SID, datamodel_type: dm, code })); }
async function studioMode() { return textOf(await call("get_studio_state", { studio_id: SID })); }
async function setPlay(on) { return textOf(await call("start_stop_play", { studio_id: SID, is_start: on })); }
const lua = (s) => JSON.stringify(String(s)); // a JS string literal is a valid Luau string literal here

// ---- the game, in the playtest ----------------------------------------------------------------------------------
async function admin(cmd) {
  return luau("Server", `local RS = game:GetService("ReplicatedStorage")
RS:SetAttribute("DebugAdminResult", nil)
RS:SetAttribute("DebugAdmin", ${lua(cmd)} .. " #" .. math.random(1, 1e9))
local t = os.clock()
while os.clock() - t < 10 and RS:GetAttribute("DebugAdminResult") == nil do task.wait(0.1) end
return tostring(RS:GetAttribute("DebugAdminResult"))`);
}
const setShot = (s) => luau("Client", `game:GetService("Players").LocalPlayer:SetAttribute("ClipShot", ${lua(s ? JSON.stringify(s) : "")}) return "ok"`);
const setCalib = (on) => luau("Client", `game:GetService("Players").LocalPlayer:SetAttribute("ClipCalib", ${on}) return "ok"`);
const client = (code) => luau("Client", `local lp = game:GetService("Players").LocalPlayer\nlocal RS = game:GetService("ReplicatedStorage")\n${code}`);
const server = (code) => luau("Server", `local RS = game:GetService("ReplicatedStorage")\nlocal lp = game:GetService("Players"):GetPlayers()[1]\n${code}`);
async function ghostState() { return (await server(`local g = workspace:FindFirstChild("Ghost") return tostring(g and g:GetAttribute("State"))`)).trim(); }
// wait until the monster is out of its entrance (or none came)
async function waitSettled(maxS) {
  const t0 = Date.now();
  while (Date.now() - t0 < maxS * 1000) {
    const s = await ghostState();
    if (s !== "nil" && s !== "Spawn" && !s.includes("nil")) return s;
    await sleep(1500);
  }
  return "timeout";
}
async function runRunning() { return (await server(`return tostring(require(game:GetService("ServerScriptService").Server.Run).running())`)).includes("true"); }
async function toPark() {
  await setShot(null);
  if (await runRunning()) { await admin("endrun"); await sleep(3500); }
  await client(`pcall(function() RS.Remotes.Sandbox:FireServer("leave") end) return "ok"`);
  await sleep(1500);
}
async function leaveSandbox() {
  await setShot(null);
  await client(`pcall(function() RS.Remotes.Sandbox:FireServer("leave") end) return "ok"`);
}
async function ensureRun(house) {
  await server(`lp:SetAttribute("AdminGod", true) RS:SetAttribute("DebugGhostGod", true) return "ok"`);
  if (!(await runRunning())) {
    await admin("start " + house + " Normal");
    await sleep(6000);
    await waitSettled(30); // (the run's first monster and its entrance)
  }
}

const CATALOG = `local HS = game:GetService("HttpService")
local S = game:GetService("ReplicatedStorage").Shared
local Maps, Monsters, Ent, Ults, Forms = require(S.Maps), require(S.Monsters), require(S.Entrances), require(S.Ultimates), require(S.Forms)
local out = { houses = {}, monsters = {}, ults = {}, giants = {} }
for _, m in Maps.list do if not (m :: any).campaign then table.insert(out.houses, { id = m.id, name = m.name }) end end
for _, m in Monsters.list do table.insert(out.monsters, { id = m.id, name = m.name, entrance = Ent.of(m.id) }) end
for _, u in Ults.list do table.insert(out.ults, { id = u.id, name = u.name, dur = u.dur }) end
for _, kind in { "stim", "potion" } do
  for _, f in Forms.ofKind(kind, "Moon") do table.insert(out.giants, { id = f.id, name = f.name, rarity = f.rarity, kind = kind }) end
end
return HS:JSONEncode(out)`;
async function catalog() {
  const t = await luau("Server", CATALOG);
  return JSON.parse(t.slice(t.indexOf("{")));
}

// ---- what it films --------------------------------------------------------------------------------------------------
const RARITY = ["COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "MYTHIC"];
const pickOf = (a) => a[Math.floor(Math.random() * a.length)];
const KINDS = {
  fight: {
    layout: "tall",
    list: (c) => c.monsters,
    hooks: ["POV: tonight YOU are the scary one", "{name} picked the wrong house", "When the ghost realises you fight back",
      "I punched {name} across the room", "Ghosts when I start swinging", "{name} vs my fists", "Nobody warned {name} about me"],
    async prep(p, c) { await leaveSandbox(); await ensureRun(pickOf(c.houses).id); await admin("monster " + p.id); await sleep(2500); await waitSettled(30);
      await server(`RS:SetAttribute("DebugGhostGod", true) return "ok"`); await setShot({ cam: "fps", bot: "fight", hideUI: true }); await sleep(1500); },
    async action() {
      await sleep(12000);
      // the knockout: the monster can die again, almost no health left: the bot's next hits finish it
      await server(`RS:SetAttribute("DebugGhostGod", false) RS:SetAttribute("DebugGhostHP", 0.05) return "ok"`);
      // the clip ends shortly after the knockout (the monster's State is "Dead", then it is removed)
      const t0 = Date.now();
      while (Date.now() - t0 < 9000) {
        const st = await ghostState();
        if (st.includes("Dead") || st.includes("nil")) break;
        await sleep(400);
      }
      await sleep(1800);
    },
    async after() { await setShot(null); await server(`RS:SetAttribute("DebugGhostGod", true) return "ok"`); },
  },
  entrance: {
    layout: "framed",
    list: (c) => c.monsters,
    hooks: ["Rating ghost entrances: {name}", "POV: {name} found your house", "This is how {name} walks in...", "{name} has the scariest entrance",
      "Rate this entrance 1-10", "When {name} hears you're home"],
    async prep(p, c) { await leaveSandbox(); await ensureRun(pickOf(c.houses).id); await setShot({ cam: "game", hideUI: true }); await sleep(800); },
    async action(p) { await admin("monster " + p.id); await sleep(Math.min(16, (p.entrance || 4) + 3) * 1000); },
    async after() { await setShot(null); },
  },
  ultimate: {
    layout: "tall",
    list: (c) => c.ults,
    hooks: ["Rating every ultimate: {name}", "This ultimate is unfair: {name}", "Ghosts hate this move", "POV: you unlocked {name}", "The {name} ultimate goes crazy"],
    async prep(p) { await toPark(); await client(`RS.Remotes.Sandbox:FireServer("enter", ${lua(p.id)}) return "ok"`); await sleep(7000);
      await setShot({ cam: "fps", bot: "ult", hideUI: true }); await sleep(1000); },
    async action(p) { await sleep(Math.min(16, 7 + (p.dur || 5)) * 1000); },
    async after() { await setShot(null); await client(`RS.Remotes.Sandbox:FireServer("leave") return "ok"`); await sleep(2000); },
  },
  giant: {
    layout: "tall",
    list: (c) => c.giants,
    hooks: ["When you open a {rarity} {kind}...", "My form is 10x bigger than me", "Getting the {name} form be like", "Flexing my {rarity} form in the lobby",
      "POV: you pulled a {rarity}"],
    async prep() { await toPark(); await admin("form off"); await setShot({ cam: "orbit", subject: "player", radius: 46, height: 9, lookY: 16, speed: 11, fov: 60, bot: "strut", hideUI: true });
      await sleep(1200); },
    async action(p) {
      await admin("form " + p.id); // (gives + wears it: the giant rises out of the ground)
      await sleep(2200);
      await client(`lp:SetAttribute("DebugFormBurst", "x") task.wait(0.1) lp:SetAttribute("DebugFormBurst", ${lua(p.kind)}) return "ok"`);
      await sleep(11000);
    },
    async after() { await setShot(null); await admin("form off"); },
  },
};
const ORDER = ["fight", "entrance", "giant", "ultimate"];
function hookFor(kind, p) {
  const h = pickOf(KINDS[kind].hooks);
  return h.replace(/\{name\}/g, String(p.name || "").toUpperCase()).replace(/\{rarity\}/g, RARITY[(p.rarity || 1) - 1] || "")
    .replace(/\{kind\}/g, p.kind === "stim" ? "JAR" : "POTION").toUpperCase();
}
function caption(hook) {
  return hook + "\n\nPlay JUMP THE GHOST on Roblox - use code TIKTOK for free cash!\n#roblox #robloxhorror #robloxgames #ghost #gaming #fyp\n";
}

// ---- history: no same clip twice in a row -----------------------------------------------------------------------
const HIST = path.join(OUT, "history.json");
function loadHist() { try { return JSON.parse(fs.readFileSync(HIST, "utf8")); } catch { return { n: 0, used: {} }; } }
function saveHist(h) { fs.mkdirSync(OUT, { recursive: true }); fs.writeFileSync(HIST, JSON.stringify(h, null, 1)); }
function choose(kind, cat, hist, name) {
  const list = KINDS[kind].list(cat);
  if (name) {
    const n = String(name).toLowerCase();
    const hit = list.find((x) => String(x.id).toLowerCase() === n || String(x.name).toLowerCase().includes(n));
    if (!hit) throw new Error(`no ${kind} called "${name}" (node clipper.js list)`);
    return hit;
  }
  const uses = (x) => hist.used[kind + ":" + x.id] || 0;
  const least = Math.min(...list.map(uses));
  return pickOf(list.filter((x) => uses(x) === least));
}

// ---- recording: OBS (obs-websocket 5) -----------------------------------------------------------------------------
class Obs {
  async connect() {
    if (typeof WebSocket === "undefined") throw new Error("this Node is too old for OBS control: install Node 22 or newer (winget install OpenJS.NodeJS.LTS)");
    this.pending = new Map();
    this.n = 0;
    this.ws = new WebSocket(OBS_URL);
    await new Promise((resolve, reject) => {
      const t = setTimeout(() => reject(new Error(`OBS is not answering on ${OBS_URL}: open OBS, Tools > WebSocket Server Settings > Enable WebSocket server`)), 6000);
      this.ws.onerror = () => {};
      this.ws.onclose = (ev) => { clearTimeout(t); reject(new Error("OBS closed the connection" + (ev.code === 4009 ? ": wrong password (" + OBS_PASSFILE + ")" : " (" + ev.code + ")"))); };
      this.ws.onmessage = (ev) => {
        const m = JSON.parse(typeof ev.data === "string" ? ev.data : Buffer.from(ev.data).toString());
        if (m.op === 0) {
          const d = { rpcVersion: 1 };
          if (m.d.authentication) {
            let pw = process.env.OBS_PASSWORD;
            try { pw = pw || fs.readFileSync(OBS_PASSFILE, "utf8").trim(); } catch {}
            if (!pw) { reject(new Error("OBS asks for a password: put it in " + OBS_PASSFILE)); return; }
            const b64 = (s) => crypto.createHash("sha256").update(s).digest("base64");
            d.authentication = b64(b64(pw + m.d.authentication.salt) + m.d.authentication.challenge);
          }
          this.ws.send(JSON.stringify({ op: 1, d }));
        } else if (m.op === 2) {
          clearTimeout(t);
          resolve();
        } else if (m.op === 7) {
          const p = this.pending.get(m.d.requestId);
          if (!p) return;
          this.pending.delete(m.d.requestId);
          if (m.d.requestStatus.result) p.resolve(m.d.responseData || {});
          else p.reject(new Error(m.d.requestType + ": " + (m.d.requestStatus.comment || m.d.requestStatus.code)));
        }
      };
    });
  }
  req(type, data) {
    const id = "r" + ++this.n;
    return new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject });
      this.ws.send(JSON.stringify({ op: 6, d: { requestType: type, requestId: id, requestData: data || {} } }));
      setTimeout(() => { if (this.pending.has(id)) { this.pending.delete(id); reject(new Error(type + ": OBS did not answer")); } }, 20000);
    });
  }
  async start() {
    const st = await this.req("GetRecordStatus");
    if (st.outputActive) await this.req("StopRecord");
    await this.req("StartRecord");
  }
  async stop() {
    const r = await this.req("StopRecord");
    await sleep(1500); // (the file is being finished)
    if (!r.outputPath || !fs.existsSync(r.outputPath)) throw new Error("OBS did not say where it saved the recording");
    return r.outputPath;
  }
  get calibMs() { return 700; }
  close() { try { this.ws.close(); } catch {} }
}
// TEST ONLY (no OBS): screenshots through the bridge, put together into a slow video
class Frames {
  async connect() {}
  async start() {
    this.dir = fs.mkdtempSync(path.join(os.tmpdir(), "clipframes-"));
    this.frames = [];
    this.on = true;
    this.loop = (async () => {
      while (this.on) {
        const t = Date.now();
        const content = await call("screen_capture", { studio_id: SID, capture_id: "Clip" }).catch(() => []);
        const img = content.find((c) => c.type === "image");
        if (img) {
          const f = path.join(this.dir, "f" + String(this.frames.length).padStart(4, "0") + ".png");
          fs.writeFileSync(f, Buffer.from(img.data, "base64"));
          this.frames.push({ f, t });
        }
        await sleep(200);
      }
    })();
  }
  async stop() {
    this.on = false;
    await this.loop;
    const list = this.frames.map((x, i) => `file '${x.f}'\nduration ${(((this.frames[i + 1] || { t: x.t + 1000 }).t - x.t) / 1000).toFixed(3)}`).join("\n");
    fs.writeFileSync(path.join(this.dir, "list.txt"), list + `\nfile '${this.frames[this.frames.length - 1].f}'\n`);
    const out = path.join(this.dir, "raw.mp4");
    run(FFMPEG, ["-y", "-v", "error", "-f", "concat", "-safe", "0", "-i", path.join(this.dir, "list.txt"), "-vf", "fps=30,scale=trunc(iw/2)*2:trunc(ih/2)*2,format=yuv420p", "-c:v", "libx264", "-crf", "16", out]);
    return out;
  }
  get calibMs() { return 3000; }
  close() {}
}

// THE PC TOOLS (mcp-gateway.js pc_*): ffmpeg ddagrab records the game picture at 60 fps on the PC, the edit runs on
// the PC, the finished clip comes back in pieces. Works from a cloud session through the tunnel.
const jparse = (content) => { const t = textOf(content); return JSON.parse(t.slice(t.search(/[{[]/))); };
class PcRec {
  async connect() {
    let info;
    try { info = jparse(await call("pc_info", {})); } catch (e) {
      throw new Error("the bridge has no PC tools yet: update mcp-gateway.js on the PC and restart start-bridge.bat (" + e.message + ")");
    }
    if (!info.ffmpeg) throw new Error("ffmpeg is missing on the PC: winget install Gyan.FFmpeg, then restart start-bridge.bat");
    if (!info.ddagrab) throw new Error("the PC's ffmpeg cannot grab the screen (no ddagrab): winget upgrade Gyan.FFmpeg");
    this.enc = ["h264_nvenc", "h264_qsv", "h264_amf", "libx264"].filter((e) => info.encoders.includes(e));
    this.cpus = info.cpus || 4;
    log(`PC: ${info.ffmpeg.split(" Copyright")[0]}, encoders ${this.enc.join(", ")}`);
    const files = jparse(await call("pc_files", {})).files;
    if (!files.some((f) => f.name === "font.ttf")) {
      await ensureFont();
      await call("pc_put", { name: "font.ttf", data: fs.readFileSync(FONT).toString("base64") });
    }
  }
  async ff(args, wait, timeout) { return jparse(await call("pc_ffmpeg", { args, wait: wait !== false, timeout_s: timeout || 900 })); }
  encArgs(e, quality) {
    if (e === "h264_nvenc") return ["-c:v", "h264_nvenc", "-preset", "p5", "-rc", "vbr", "-cq", quality ? "19" : "17", "-b:v", "0"];
    if (e === "h264_qsv") return ["-c:v", "h264_qsv", "-global_quality", quality ? "21" : "18"];
    if (e === "h264_amf") return ["-c:v", "h264_amf", "-rc", "cqp", "-qp_i", quality ? "20" : "17", "-qp_p", quality ? "22" : "19"];
    return ["-c:v", "libx264", "-preset", quality ? (this.cpus >= 8 ? "medium" : "faster") : "veryfast", "-crf", quality ? "19" : "16"];
  }
  // a file of the work folder -> here, in 6 MB pieces
  async fetch(name, dest) {
    let off = 0, size = 1;
    const out = fs.openSync(dest, "w");
    while (off < size) {
      const r = jparse(await call("pc_get", { name, offset: off, length: 6e6 }));
      size = r.size;
      const b = Buffer.from(r.data, "base64");
      if (!b.length) break;
      fs.writeSync(out, b);
      off += b.length;
    }
    fs.closeSync(out);
    return dest;
  }
  // where the game picture is on the screen (while the magenta frame is up): Studio to the front, one grabbed frame
  async locate() {
    const w = jparse(await call("pc_window", { awake_s: 1800 }));
    if (!w.rect || w.rect === "none") throw new Error("no Roblox Studio window on the PC");
    await sleep(1500);
    for (const idx of [0, 1, 2]) {
      const r = await this.ff(["-y", "-v", "error", "-f", "lavfi", "-i", `ddagrab=output_idx=${idx}:framerate=10:draw_mouse=0`, "-frames:v", "8",
        "-vf", "hwdownload,format=bgra,scale=iw/2:ih/2", "-update", "1", "calib.png"], true, 60);
      if (r.code !== 0) continue;
      const rect = magentaRect(await this.fetch("calib.png", path.join(os.tmpdir(), "clip-calib.png")));
      if (rect) {
        const ev = (v) => Math.max(2, Math.floor(v / 2) * 2);
        this.idx = idx;
        this.rect = { x: ev(rect.x * 2), y: ev(rect.y * 2), w: ev(rect.w * 2), h: ev(rect.h * 2) };
        return this.rect;
      }
    }
    throw new Error("the game picture is not on the screen: keep the Studio window visible (not minimised, screen on)");
  }
  async start(maxS) {
    const r = this.rect;
    this.raw = "raw_" + Date.now() + ".mp4";
    const res = await this.ff(["-y", "-v", "error", "-f", "lavfi", "-i",
      `ddagrab=output_idx=${this.idx}:framerate=60:draw_mouse=0:offset_x=${r.x}:offset_y=${r.y}:video_size=${r.w}x${r.h}`,
      "-vf", "hwdownload,format=bgra", "-t", String(maxS), ...this.encArgs(this.enc[0], false), "-pix_fmt", "yuv420p", "-r", "60", this.raw], false, maxS + 120);
    this.job = res.job;
    await sleep(1500);
    const st = jparse(await call("pc_job", { job: this.job }));
    if (!st.running && st.code !== 0) {
      // (a GPU encoder listed by ffmpeg but not usable on this PC: the next one)
      if (this.enc.length > 1) { log(`  (${this.enc[0]} failed, trying ${this.enc[1]})`); this.enc.shift(); return this.start(maxS); }
      throw new Error("the recording failed: " + st.log.slice(-400));
    }
  }
  async stop() {
    let st = jparse(await call("pc_stop", { job: this.job }));
    for (let i = 0; i < 20 && st.running; i++) st = jparse(await call("pc_job", { job: this.job, wait_s: 3 }));
    if (st.code !== 0 && st.code !== 255) throw new Error("the recording ended badly: " + st.log.slice(-400));
    return this.raw;
  }
  // the edit, on the PC: texts + filter script uploaded, ffmpeg makes the 1080x1920 60 fps clip
  // the real length of a recording on the PC (a quick copy pass to nowhere; its log's last time=)
  async duration(name) {
    const r = await this.ff(["-v", "info", "-i", name, "-map", "0:v:0", "-c", "copy", "-f", "null", "-"], true, 120);
    const m = [...String(r.log).matchAll(/time=(\d+):(\d+):(\d+(?:\.\d+)?)/g)].pop();
    return m ? Number(m[1]) * 3600 + Number(m[2]) * 60 + Number(m[3]) : null;
  }
  async edit(raw, o) {
    const id = "c" + Date.now();
    const d = await this.duration(raw);
    if (d) o = Object.assign({}, o, { len: Math.max(2, Math.min(o.len, d - o.start - 0.05)) });
    const { graph, texts } = buildGraph(Object.assign({}, o, { crop: { x: 0, y: 0, w: this.rect.w, h: this.rect.h }, fps: 60 }), (i) => `${id}_t${i}.txt`, "font.ttf");
    for (let i = 0; i < texts.length; i++) await call("pc_put", { name: `${id}_t${i}.txt`, data: Buffer.from(texts[i]).toString("base64") });
    await call("pc_put", { name: `${id}_g.txt`, data: Buffer.from(graph).toString("base64") });
    const total = (o.len + END_CARD).toFixed(2);
    const final = `${id}_final.mp4`;
    const args = (enc) => ["-y", "-v", "error", "-i", raw, "-f", "lavfi", "-t", total, "-i", "anullsrc=r=48000:cl=stereo", "-filter_complex_script", `${id}_g.txt`,
      "-map", "[v]", "-map", "1:a", "-t", total, ...this.encArgs(enc, true), "-pix_fmt", "yuv420p", "-r", "60", "-c:a", "aac", "-b:a", "128k", "-movflags", "+faststart", final];
    let r = await this.ff(args(this.enc[0]), true, 1200);
    if (r.code !== 0 && this.enc[0] !== "libx264") r = await this.ff(args("libx264"), true, 1800);
    await call("pc_files", { delete: texts.map((_, i) => `${id}_t${i}.txt`).concat([`${id}_g.txt`]) });
    if (r.code !== 0) throw new Error("the edit failed on the PC: " + r.log.slice(-500));
    return final;
  }
  get calibMs() { return 700; }
  close() {}
}

// ---- editing (ffmpeg) -------------------------------------------------------------------------------------------
function run(cmd, args, opts) {
  const r = spawnSync(cmd, args, Object.assign({ maxBuffer: 1 << 30 }, opts || {}));
  if (r.error) throw new Error(cmd === FFMPEG || cmd === FFPROBE ? "ffmpeg is missing: winget install Gyan.FFmpeg (then open a new window)" : String(r.error));
  if (r.status !== 0) throw new Error(path.basename(cmd) + " failed: " + String(r.stderr || "").slice(-800));
  return r.stdout;
}
function probe(file) {
  const j = JSON.parse(run(FFPROBE, ["-v", "error", "-show_entries", "stream=codec_type,width,height:format=duration", "-of", "json", file]).toString());
  const v = j.streams.find((s) => s.codec_type === "video");
  return { w: v.width, h: v.height, dur: parseFloat(j.format.duration), audio: j.streams.some((s) => s.codec_type === "audio") };
}
// the magenta calibration frame: where the game picture is inside the recorded window, and when the clip starts
function findCalib(file, info) {
  const sw = 480, sh = Math.round((info.h * sw) / info.w / 2) * 2;
  const buf = run(FFMPEG, ["-v", "error", "-t", "15", "-i", file, "-vf", `fps=10,scale=${sw}:${sh}`, "-f", "rawvideo", "-pix_fmt", "rgb24", "-"]);
  const size = sw * sh * 3, n = Math.floor(buf.length / size);
  let best = null, lastCal = -1, firstCal = -1;
  for (let i = 0; i < n; i++) {
    let x0 = sw, y0 = sh, x1 = -1, y1 = -1, count = 0;
    for (let y = 0; y < sh; y++) {
      for (let x = 0; x < sw; x++) {
        const o = i * size + (y * sw + x) * 3;
        if (buf[o] > 170 && buf[o + 1] < 100 && buf[o + 2] > 170) {
          count++;
          if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y;
        }
      }
    }
    if (count > sw * sh * 0.12) {
      if (firstCal < 0) firstCal = i;
      lastCal = i;
      if (!best || count > best.count) best = { x0, y0, x1, y1, count };
    } else if (lastCal >= 0) break;
  }
  if (!best) return null;
  const k = info.w / sw, m = 2; // (a small margin inside the edge)
  const even = (v) => Math.max(2, Math.floor(v / 2) * 2);
  const x = Math.floor((best.x0 + m) * k), y = Math.floor((best.y0 + m) * k);
  return { x, y, w: even((best.x1 - best.x0 + 1 - 2 * m) * k), h: even((best.y1 - best.y0 + 1 - 2 * m) * k), start: (lastCal + 1) / 10 + 0.1 };
}
async function ensureFont() {
  if (fs.existsSync(FONT)) return;
  fs.mkdirSync(FONT_DIR, { recursive: true });
  const r = await fetch(FONT_URL);
  if (!r.ok) throw new Error("could not download the marker font (" + r.status + ")");
  fs.writeFileSync(FONT, Buffer.from(await r.arrayBuffer()));
}
// a hook split in lines of at most ~16 characters (big text, 2-3 lines)
function wrap(text, max) {
  const words = text.split(/\s+/).filter(Boolean), lines = [];
  let cur = "";
  for (const w of words) {
    if (cur && (cur + " " + w).length > max) { lines.push(cur); cur = w; } else cur = cur ? cur + " " + w : w;
  }
  if (cur) lines.push(cur);
  return lines.slice(0, 4);
}
// the magenta frame in one picture: its rectangle (in that picture's pixels), or nil
function magentaRect(file) {
  const info = probe(file);
  const sw = Math.min(640, info.w), sh = Math.round((info.h * sw) / info.w);
  const buf = run(FFMPEG, ["-v", "error", "-i", file, "-frames:v", "1", "-vf", `scale=${sw}:${sh}`, "-f", "rawvideo", "-pix_fmt", "rgb24", "-"]);
  let x0 = sw, y0 = sh, x1 = -1, y1 = -1, count = 0;
  for (let y = 0; y < sh; y++) {
    for (let x = 0; x < sw; x++) {
      const o = (y * sw + x) * 3;
      if (buf[o] > 170 && buf[o + 1] < 100 && buf[o + 2] > 170) {
        count++;
        if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y;
      }
    }
  }
  if (count < sw * sh * 0.04) return null;
  const k = info.w / sw, m = 2;
  return { x: Math.floor((x0 + m) * k), y: Math.floor((y0 + m) * k), w: Math.floor((x1 - x0 + 1 - 2 * m) * k), h: Math.floor((y1 - y0 + 1 - 2 * m) * k) };
}
// the filter graph of a clip (shared by the PC edit and the local one). o: crop {x,y,w,h}, start, len, layout
// (tall | full | framed), hook, fps. textName(i) = the file name of text i; font = the font file's name.
function buildGraph(o, textName, font) {
  const texts = [];
  const tf = (str) => { texts.push(str); return textName(texts.length - 1); };
  const draw = (str, size, y, color, extra) =>
    `drawtext=fontfile=${font}:textfile=${tf(str)}:fontsize=${size}:fontcolor=${color}:borderw=${Math.round(size / 11)}:bordercolor=black:` +
    `shadowx=0:shadowy=${Math.round(size / 14)}:shadowcolor=black@0.6:x=(w-text_w)/2:y=${y}${extra || ""}`;
  const c = o.crop, L = o.len.toFixed(2);
  let g = `[0:v]trim=start=${o.start.toFixed(3)}:duration=${o.len.toFixed(3)},setpts=PTS-STARTPTS,crop=${c.w}:${c.h}:${c.x}:${c.y}`;
  let hookY = Math.round(H * 0.11);
  if (o.layout === "framed") {
    // the whole picture in the middle, a blurred zoom of it behind
    g += `,split[a][b];[a]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},boxblur=26:2,eq=brightness=-0.22[bg];` +
      `[b]scale=${W}:-2:flags=lanczos[fg];[bg][fg]overlay=0:(H-h)/2+40,setsar=1`;
  } else if (o.layout === "tall") {
    // a 3:4 slice of the middle (sharper than a 9:16 one: less enlarged), 1080x1440 under a band for the hook
    const tw = Math.min(c.w, Math.floor((c.h * 3) / 4 / 2) * 2);
    g += `,crop=${tw}:${c.h}:(in_w-${tw})/2:0,split[a][b];[a]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},boxblur=30:2,eq=brightness=-0.32[bg];` +
      `[b]scale=${W}:1440:flags=lanczos[fg];[bg][fg]overlay=0:400,setsar=1`;
    hookY = 80;
  } else {
    // full screen: the middle 9:16 of the picture
    const tw = Math.min(c.w, Math.floor((c.h * 9) / 16 / 2) * 2);
    g += `,crop=${tw}:${c.h}:(in_w-${tw})/2:0,scale=${W}:${H}:flags=lanczos,setsar=1`;
  }
  g += `,fps=${o.fps || FPS},tpad=stop_mode=clone:stop_duration=${END_CARD}`;
  const lines = wrap(o.hook || "", 16);
  const size = lines.some((l) => l.length > 12) ? 82 : 96;
  lines.forEach((l, i) => { g += "," + draw(l, size, hookY + i * Math.round(size * 1.18), "white", `:enable='lt(t,${L})'`); });
  const on = `:enable='gte(t,${L})':alpha='min(1,(t-${L})/0.25)'`;
  g += `,drawbox=x=0:y=0:w=iw:h=ih:color=black@0.62:t=fill:enable='gte(t,${L})'`;
  g += "," + draw("SEARCH", 64, 640, "white", on);
  g += "," + draw("JUMP THE GHOST", 102, 735, "white", on);
  g += "," + draw("ON ROBLOX", 74, 880, "white", on);
  g += "," + draw("CODE: TIKTOK", 86, 1080, "0xFFC446", on);
  g += ",format=yuv420p[v]";
  return { graph: g, texts };
}
// the edit here (the edit command, OBS and --frames recordings): finds the game picture by the magenta frame
function edit(file, o) {
  const info = probe(file);
  const cal = findCalib(file, info);
  if (!cal) log("  (no calibration frame found: the whole recording is used)");
  const c = cal || { x: 0, y: 0, w: info.w - (info.w % 2), h: info.h - (info.h % 2), start: 0 };
  const start = c.start + (o.lead || 0.2);
  const len = Math.max(2, Math.min(o.dur || 999, info.dur - start - 0.2));
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "clipedit-"));
  fs.copyFileSync(FONT, path.join(tmp, "font.ttf"));
  const built = buildGraph({ crop: c, start, len, layout: o.layout, hook: o.hook, fps: o.fps || FPS }, (i) => "t" + i + ".txt", "font.ttf");
  built.texts.forEach((t, i) => fs.writeFileSync(path.join(tmp, "t" + i + ".txt"), t));
  let g = built.graph;
  const total = len + END_CARD;
  const args = ["-y", "-v", "error", "-i", path.resolve(file)];
  if (info.audio) {
    g += `;[0:a]atrim=start=${start.toFixed(3)}:duration=${len.toFixed(3)},asetpts=PTS-STARTPTS,apad=pad_dur=${END_CARD},` +
      `afade=t=out:st=${(total - 0.9).toFixed(2)}:d=0.9,loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000[a]`;
  } else {
    args.push("-f", "lavfi", "-t", total.toFixed(2), "-i", "anullsrc=r=48000:cl=stereo");
  }
  fs.writeFileSync(path.join(tmp, "graph.txt"), g);
  args.push("-filter_complex_script", "graph.txt", "-map", "[v]", "-map", info.audio ? "[a]" : "1:a", "-t", total.toFixed(2),
    "-c:v", "libx264", "-preset", "medium", "-crf", "19", "-r", String(o.fps || FPS), "-c:a", "aac", "-b:a", "160k", "-movflags", "+faststart", path.resolve(o.out));
  run(FFMPEG, args, { cwd: tmp });
  fs.rmSync(tmp, { recursive: true, force: true });
  return { len: total, crop: c };
}

// ---- commands -----------------------------------------------------------------------------------------------------
const slug = (s) => String(s).replace(/[^A-Za-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 32);
const stamp = () => new Date().toISOString().replace(/[:T]/g, "-").slice(0, 19);

async function make(count, kindArg, nameArg, mode) {
  ensureFfmpeg();
  await ensureFont();
  const s = await pickStudio();
  log(`Studio: ${s.name}`);
  const startedPlay = !/Current Studio Mode:\s*Play/i.test(await studioMode());
  if (startedPlay) { log("starting a playtest..."); await setPlay(true); await sleep(14000); }
  let size = "";
  for (let i = 0; i < 30 && !size; i++) {
    const r = await client(`local v = workspace.CurrentCamera.ViewportSize
return (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp:GetAttribute("Level")) and (math.floor(v.X) .. "x" .. math.floor(v.Y)) or "wait"`);
    if (!r.includes("wait")) size = r.trim(); else await sleep(2000);
  }
  if (!size) throw new Error("the playtest's player never appeared");
  const cat = await catalog();
  const rec = mode === "frames" ? new Frames() : mode === "obs" ? new Obs() : new PcRec();
  await rec.connect();
  const hist = loadHist();
  fs.mkdirSync(path.join(OUT, "clips"), { recursive: true });
  const made = [];
  try {
    for (let i = 0; i < count; i++) {
      const kind = kindArg || ORDER[hist.n % ORDER.length];
      if (!KINDS[kind]) throw new Error("unknown kind " + kind + " (fight, entrance, ultimate, giant)");
      const K = KINDS[kind];
      const p = choose(kind, cat, hist, nameArg);
      log(`[${i + 1}/${count}] ${kind}: ${p.name}`);
      try {
        await K.prep(p, cat);
        const hook = hookFor(kind, p);
        const out = path.join(OUT, "clips", `${stamp()}_${kind}_${slug(p.name)}.mp4`);
        if (rec instanceof PcRec) {
          // where the game picture is (once a run: Studio is brought to the front, maximised), then 60 fps
          if (!rec.rect) {
            await setCalib(true);
            await sleep(900);
            try { await rec.locate(); } finally { await setCalib(false); }
            log(`  game picture on the PC screen: ${rec.rect.w}x${rec.rect.h} at ${rec.rect.x},${rec.rect.y}`);
          }
          const fps = (await client(`local n = 0 local c = game:GetService("RunService").RenderStepped:Connect(function() n += 1 end) task.wait(1) c:Disconnect() return tostring(n)`)).trim();
          if (Number(fps) < 45) log(`  (warning: Studio draws only ${fps} frames a second${Number(fps) === 0 ? ": is its window visible and the screen on?" : ""})`);
          await rec.start(70);
          const tA = Date.now();
          await K.action(p, cat);
          const len = (Date.now() - tA) / 1000 + 0.3;
          const raw = await rec.stop();
          await K.after(p, cat);
          log(`  editing on the PC (${len.toFixed(1)} s, Studio at ${fps} fps)...`);
          const final = await rec.edit(raw, { hook, layout: K.layout, start: 1.2, len });
          log("  downloading the clip...");
          await rec.fetch(final, out);
          await call("pc_files", { delete: [raw] });
        } else {
          await rec.start();
          await sleep(600);
          await setCalib(true);
          await sleep(rec.calibMs);
          await setCalib(false);
          await K.action(p, cat);
          const raw = await rec.stop();
          await K.after(p, cat);
          log(`  editing (${path.basename(raw)}) -> ${path.basename(out)}`);
          edit(raw, { hook, layout: K.layout, out, fps: mode === "frames" ? 30 : 60 });
        }
        fs.writeFileSync(out.replace(/\.mp4$/, ".txt"), caption(hook));
        hist.n++;
        hist.used[kind + ":" + p.id] = (hist.used[kind + ":" + p.id] || 0) + 1;
        saveHist(hist);
        made.push(out);
        log("  -> " + path.basename(out));
      } catch (e) {
        log("  failed: " + e.message);
        await setCalib(false).catch(() => {});
        await setShot(null).catch(() => {});
        if (rec instanceof Obs) await rec.req("StopRecord").catch(() => {});
        if (rec instanceof PcRec && rec.job) await call("pc_stop", { job: rec.job }).catch(() => {});
      }
    }
  } finally {
    rec.close();
    await setShot(null).catch(() => {});
    if (startedPlay && !opt("keep-playing", false)) { await setPlay(false).catch(() => {}); }
  }
  log(`\n${made.length} clip(s) in ${path.join(OUT, "clips")}`);
  made.forEach((m) => log("  " + path.basename(m)));
  return made;
}
function ensureFfmpeg() { run(FFMPEG, ["-version"]); }

async function main() {
  const cmd = argv.shift();
  const kind = opt("kind", null), name = opt("name", null), mode = opt("frames", false) ? "frames" : opt("obs", false) ? "obs" : "pc";
  const hook = opt("hook", ""), layout = opt("layout", "full"), out = opt("out", null);
  if (cmd === "make") {
    await make(parseInt(argv[0] || "1", 10) || 1, kind, name, mode);
  } else if (cmd === "edit") {
    ensureFfmpeg();
    await ensureFont();
    const file = argv[0];
    if (!file) throw new Error("usage: node clipper.js edit <video> --hook \"<text>\" [--layout full|framed]");
    const dest = out || file.replace(/\.[^.]+$/, "") + "_tiktok.mp4";
    const r = edit(file, { hook: String(hook).toUpperCase(), layout, out: dest });
    if (hook) fs.writeFileSync(dest.replace(/\.mp4$/, ".txt"), caption(String(hook).toUpperCase()));
    log(`${dest} (${r.len.toFixed(1)} s, game picture ${r.crop.w}x${r.crop.h} at ${r.crop.x},${r.crop.y})`);
  } else if (cmd === "list") {
    await pickStudio();
    if (!/Current Studio Mode:\s*Play/i.test(await studioMode())) { log("(start a playtest first: the list comes from the running game)"); return; }
    const c = await catalog();
    log("fight / entrance: " + c.monsters.map((m) => m.name).join(", "));
    log("ultimate: " + c.ults.map((u) => u.name).join(", "));
    log("giant: " + c.giants.map((g) => g.name).join(", "));
  } else {
    log(fs.readFileSync(__filename, "utf8").split("\n").slice(2, 8).join("\n"));
  }
}
if (require.main === module) main().catch((e) => { console.error("ERROR: " + e.message); process.exit(1); });
module.exports = { PcRec, buildGraph, magentaRect, edit, call, textOf };
