#!/usr/bin/env node
"use strict";
// THE TIKTOK CLIP MAKER (2026-11-24, week 1 of the TikTok plan). Runs on the PC, next to the bridge.
// It films the game in a Studio playtest, edits every clip for TikTok and writes its caption:
//   node clipper.js make [count] [--kind fight|entrance|ultimate|giant] [--name <monster / ultimate / form>]
//   node clipper.js edit <video> --hook "<text>" [--layout full|framed]     (edit a video you recorded yourself)
//   node clipper.js list                                                    (what it can film)
// (make-clips.bat = "node clipper.js make 4")
// How: Studio (through mcp-gateway.js, like pull-from-github.js) -> the game's Studio-only film camera + bot
// (Client/ClipCam: player attributes ClipShot / ClipCalib) -> OBS records the Studio window (obs-websocket) ->
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
    layout: "full",
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
    layout: "full",
    list: (c) => c.ults,
    hooks: ["Rating every ultimate: {name}", "This ultimate is unfair: {name}", "Ghosts hate this move", "POV: you unlocked {name}", "The {name} ultimate goes crazy"],
    async prep(p) { await toPark(); await client(`RS.Remotes.Sandbox:FireServer("enter", ${lua(p.id)}) return "ok"`); await sleep(7000);
      await setShot({ cam: "fps", bot: "ult", hideUI: true }); await sleep(1000); },
    async action(p) { await sleep(Math.min(16, 7 + (p.dur || 5)) * 1000); },
    async after() { await setShot(null); await client(`RS.Remotes.Sandbox:FireServer("leave") return "ok"`); await sleep(2000); },
  },
  giant: {
    layout: "full",
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
function edit(file, o) {
  const info = probe(file);
  const cal = findCalib(file, info);
  if (!cal) log("  (no calibration frame found: the whole recording is used)");
  const c = cal || { x: 0, y: 0, w: info.w - (info.w % 2), h: info.h - (info.h % 2), start: 0 };
  const start = c.start + (o.lead || 0.2);
  const len = Math.max(2, Math.min(o.dur || 999, info.dur - start - 0.2));
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "clipedit-"));
  fs.copyFileSync(FONT, path.join(tmp, "font.ttf"));
  // every text goes through a file (no escaping problems); ffmpeg runs inside tmp, so the paths are plain names
  let n = 0;
  const textFile = (s) => { const f = "t" + n++ + ".txt"; fs.writeFileSync(path.join(tmp, f), s); return f; };
  const draw = (s, size, y, color, extra) =>
    `drawtext=fontfile=font.ttf:textfile=${textFile(s)}:fontsize=${size}:fontcolor=${color}:borderw=${Math.round(size / 11)}:bordercolor=black:` +
    `shadowx=0:shadowy=${Math.round(size / 14)}:shadowcolor=black@0.6:x=(w-text_w)/2:y=${y}${extra || ""}`;
  let g = `[0:v]trim=start=${start.toFixed(3)}:duration=${len.toFixed(3)},setpts=PTS-STARTPTS,crop=${c.w}:${c.h}:${c.x}:${c.y}`;
  if (o.layout === "framed") {
    // the whole picture in the middle, a blurred zoom of it behind
    g += `,split[a][b];[a]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},boxblur=26:2,eq=brightness=-0.22[bg];` +
      `[b]scale=${W}:-2:flags=lanczos[fg];[bg][fg]overlay=0:(H-h)/2+40,setsar=1`;
  } else {
    // full screen: the middle of the picture (ClipCam keeps the action in the middle)
    const tw = Math.min(c.w, Math.floor((c.h * 9) / 16 / 2) * 2);
    g += `,crop=${tw}:${c.h}:(in_w-${tw})/2:0,scale=${W}:${H}:flags=lanczos,setsar=1`;
  }
  g += `,fps=${FPS},tpad=stop_mode=clone:stop_duration=${END_CARD}`;
  // the hook, big, in the top part (the whole clip)
  const lines = wrap(o.hook || "", 16);
  const size = lines.some((l) => l.length > 12) ? 82 : 96;
  lines.forEach((l, i) => { g += "," + draw(l, size, Math.round(H * 0.11) + i * Math.round(size * 1.18), "white", `:enable='lt(t,${len.toFixed(2)})'`); });
  // the end card: darker, the game's name, the code
  const on = `:enable='gte(t,${len.toFixed(2)})':alpha='min(1,(t-${len.toFixed(2)})/0.25)'`;
  g += `,drawbox=x=0:y=0:w=iw:h=ih:color=black@0.62:t=fill:enable='gte(t,${len.toFixed(2)})'`;
  g += "," + draw("SEARCH", 64, 640, "white", on);
  g += "," + draw("JUMP THE GHOST", 102, 735, "white", on);
  g += "," + draw("ON ROBLOX", 74, 880, "white", on);
  g += "," + draw("CODE: TIKTOK", 86, 1080, "0xFFC446", on);
  g += ",format=yuv420p[v]";
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
    "-c:v", "libx264", "-preset", "medium", "-crf", "19", "-r", String(FPS), "-c:a", "aac", "-b:a", "160k", "-movflags", "+faststart", path.resolve(o.out));
  run(FFMPEG, args, { cwd: tmp });
  fs.rmSync(tmp, { recursive: true, force: true });
  return { len: total, crop: c };
}

// ---- commands -----------------------------------------------------------------------------------------------------
const slug = (s) => String(s).replace(/[^A-Za-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 32);
const stamp = () => new Date().toISOString().replace(/[:T]/g, "-").slice(0, 19);

async function make(count, kindArg, nameArg, frames) {
  ensureFfmpeg();
  await ensureFont();
  const s = await pickStudio();
  log(`Studio: ${s.name}`);
  const startedPlay = !/Current Studio Mode:\s*Play/i.test(await studioMode());
  if (startedPlay) { log("starting a playtest..."); await setPlay(true); await sleep(14000); }
  // the client is ready and its window is big enough
  let size = "";
  for (let i = 0; i < 30 && !size; i++) {
    const r = await client(`local v = workspace.CurrentCamera.ViewportSize
return (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp:GetAttribute("Level")) and (math.floor(v.X) .. "x" .. math.floor(v.Y)) or "wait"`);
    if (!r.includes("wait")) size = r.trim(); else await sleep(2000);
  }
  if (!size) throw new Error("the playtest's player never appeared");
  const [vw, vh] = size.split("x").map(Number);
  if (vw < 400 || vh < 300) throw new Error(`the Studio window is minimised or too small (${size}): keep it big and visible while filming`);
  log(`game picture: ${size}`);
  const cat = await catalog();
  const rec = frames ? new Frames() : new Obs();
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
        await rec.start();
        await sleep(600);
        await setCalib(true);
        await sleep(rec.calibMs);
        await setCalib(false);
        await K.action(p, cat);
        const raw = await rec.stop();
        await K.after(p, cat);
        const hook = hookFor(kind, p);
        const out = path.join(OUT, "clips", `${stamp()}_${kind}_${slug(p.name)}.mp4`);
        log(`  editing (${path.basename(raw)}) -> ${path.basename(out)}`);
        edit(raw, { hook, layout: K.layout, out });
        fs.writeFileSync(out.replace(/\.mp4$/, ".txt"), caption(hook));
        hist.n++;
        hist.used[kind + ":" + p.id] = (hist.used[kind + ":" + p.id] || 0) + 1;
        saveHist(hist);
        made.push(out);
      } catch (e) {
        log("  failed: " + e.message);
        await setCalib(false).catch(() => {});
        await setShot(null).catch(() => {});
        if (rec instanceof Obs) await rec.req("StopRecord").catch(() => {});
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
  const kind = opt("kind", null), name = opt("name", null), frames = opt("frames", false);
  const hook = opt("hook", ""), layout = opt("layout", "full"), out = opt("out", null);
  if (cmd === "make") {
    await make(parseInt(argv[0] || "1", 10) || 1, kind, name, frames);
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
main().catch((e) => { console.error("ERROR: " + e.message); process.exit(1); });
