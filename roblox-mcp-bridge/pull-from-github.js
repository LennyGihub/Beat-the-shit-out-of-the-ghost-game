// Pull the game's pending scripts from GitHub into the open Studio. No tunnel, no login.
//
// Cloud sessions that cannot reach Studio (tunnel off, or its monthly bandwidth used up) commit their scripts to
// `pending/src/` on the main branch of the public game repo (same layout as game/). This script, on the PC,
// reads that folder from GitHub and writes every new or changed script into Studio through the local gateway
// (mcp-gateway.js on 127.0.0.1, started by start-bridge.bat). One way only: GitHub -> Studio.
//
//   node pull-from-github.js            one pass: what changed since the last pull
//   node pull-from-github.js --watch    keep running: pull again whenever somebody pushes to main
//   node pull-from-github.js --all      push every pending script again
//   node pull-from-github.js --studio "part of the place name"     when several Studios are open
//
// Studio must be in Edit mode (stop the playtest). It remembers what it already pushed in
// %USERPROFILE%\roblox-github-sync.json. Plain Node (18+), no packages.
// Env: PORT (8765), KEYFILE (bridge key file), SYNC_STATE, ROBLOX_MCP_URL.
const fs = require("fs");
const os = require("os");
const path = require("path");

const OWNER = "LennyGihub";
const REPO = "Beat-the-shit-out-of-the-ghost-game";
const BRANCH = "main";
const DIR = "pending/src/";
const PORT = Number(process.env.PORT || 8765);
const KEYFILE = process.env.KEYFILE || path.join(os.homedir(), "roblox-mcp-bridge-key.txt");
const STATE = process.env.SYNC_STATE || path.join(os.homedir(), "roblox-github-sync.json");
const MCP = process.env.ROBLOX_MCP_URL || `http://127.0.0.1:${PORT}/mcp`;
const POLL_MS = 15000;
// only these services are ever written to (the first folder of a script's path)
const SERVICES = ["Workspace", "ReplicatedFirst", "ReplicatedStorage", "ServerScriptService", "ServerStorage", "StarterGui",
  "StarterPack", "StarterPlayer", "Lighting", "SoundService", "Teams", "TextChatService", "Chat"];

const args = process.argv.slice(2);
const WATCH = args.includes("--watch");
const ALL = args.includes("--all");
const WANT = args.includes("--studio") ? String(args[args.indexOf("--studio") + 1] || "").toLowerCase() : "";

function log(...a) {
  console.log(new Date().toTimeString().slice(0, 8), ...a);
}

// ---- GitHub (public repo: nothing to log in to) ----------------------------------------------------------
// the commit main points at, read the way `git` does (this address has no hourly limit, unlike the API)
async function headSha() {
  const r = await fetch(`https://github.com/${OWNER}/${REPO}.git/info/refs?service=git-upload-pack`, {
    headers: { "User-Agent": "git/2.40" },
  });
  if (!r.ok) throw new Error("GitHub answered " + r.status + " for the branch list");
  const m = (await r.text()).match(new RegExp("([0-9a-f]{40}) refs/heads/" + BRANCH + "\\n"));
  if (!m) throw new Error("branch " + BRANCH + " not found on GitHub");
  return m[1];
}

// every file of that commit: [{ path, sha }]  (asked only when main moved: the API allows 60 calls an hour)
async function tree(sha) {
  const r = await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/git/trees/${sha}?recursive=1`, {
    headers: { "User-Agent": "roblox-mcp-bridge", Accept: "application/vnd.github+json" },
  });
  if (!r.ok) throw new Error("GitHub answered " + r.status + " for the file list" + (r.status === 403 ? " (hourly limit: it will work again within the hour)" : ""));
  const j = await r.json();
  return j.tree.filter((e) => e.type === "blob" && e.path.startsWith(DIR) && e.path.endsWith(".luau"));
}

async function download(sha, file) {
  const r = await fetch(`https://raw.githubusercontent.com/${OWNER}/${REPO}/${sha}/${file.split("/").map(encodeURIComponent).join("/")}`);
  if (!r.ok) throw new Error("GitHub answered " + r.status + " for " + file);
  return (await r.text()).replace(/\r\n/g, "\n");
}

// ---- Studio (through the local gateway) ------------------------------------------------------------------
let session = null;
let nextId = 10;
async function rpc(body) {
  const key = fs.readFileSync(KEYFILE, "utf8").trim();
  const headers = { "Content-Type": "application/json", "x-api-key": key };
  if (session) headers["Mcp-Session-Id"] = session;
  let r;
  try {
    r = await fetch(MCP, { method: "POST", headers, body: JSON.stringify(body) });
  } catch (e) {
    throw new Error("the gateway is not running (start start-bridge.bat first)");
  }
  if (r.status === 401) throw new Error("the gateway refused the key in " + KEYFILE);
  if (!r.ok && r.status !== 202) throw new Error("the gateway answered " + r.status);
  session = r.headers.get("mcp-session-id") || session;
  const text = await r.text();
  return text ? JSON.parse(text) : null;
}

async function call(name, a) {
  if (!session) {
    await rpc({ jsonrpc: "2.0", id: 1, method: "initialize", params: { protocolVersion: "2025-06-18", capabilities: {}, clientInfo: { name: "pull-from-github", version: "1" } } });
    await rpc({ jsonrpc: "2.0", method: "notifications/initialized" });
  }
  const d = await rpc({ jsonrpc: "2.0", id: ++nextId, method: "tools/call", params: { name, arguments: a } });
  if (!d || d.error) throw new Error(name + ": " + JSON.stringify(d && d.error));
  const text = (d.result.content || []).map((c) => c.text || "").join("");
  if (d.result.isError) throw new Error(name + ": " + text.slice(0, 300));
  return text;
}

// the Studio to write to (Edit mode only: a playtest is never interrupted)
async function pickStudio() {
  const text = await call("list_roblox_studios", {});
  const i = text.search(/[{[]/);
  const parsed = JSON.parse(i >= 0 ? text.slice(i) : text);
  const studios = (parsed.studios || parsed || []).filter((s) => !WANT || String(s.name).toLowerCase().includes(WANT));
  if (!studios.length) throw new Error("no Roblox Studio is open with MCP Ready" + (WANT ? ' (matching "' + WANT + '")' : ""));
  const s = studios[0];
  if (s.mode && String(s.mode).toLowerCase() !== "edit") throw new Error('Studio "' + s.name + '" is in a playtest: press Stop, the scripts go in right after');
  return s;
}

// pending/src/<Service>/<Folder...>/<Name>[.server|.client].luau  ->  where it lives in the place
function target(file) {
  const rel = file.slice(DIR.length).split("/");
  let name = rel.pop();
  let cls = "ModuleScript";
  if (name.includes("~")) return null; // an exported duplicate name: never pushed
  if (name.endsWith(".server.luau")) { cls = "Script"; name = name.slice(0, -12); }
  else if (name.endsWith(".client.luau")) { cls = "LocalScript"; name = name.slice(0, -12); }
  else name = name.slice(0, -5);
  if (!rel.length || !SERVICES.includes(rel[0])) return null;
  return { folders: rel, name, cls };
}

// same Luau as tools/deploy_luau.py: make the folders, make or replace the script, set its source
async function push(studio, t, src) {
  const eq = "=".repeat(12);
  if (src.includes("]" + eq + "]")) throw new Error("the source contains a long-bracket terminator");
  const code = `
local path = {${t.folders.map((x) => JSON.stringify(x)).join(", ")}}
local cur = game:GetService(path[1])
for i = 2, #path do
  local c = cur:FindFirstChild(path[i])
  if not c then c = Instance.new("Folder"); c.Name = path[i]; c.Parent = cur end
  cur = c
end
local s = cur:FindFirstChild(${JSON.stringify(t.name)})
if s and s.ClassName ~= "${t.cls}" then s:Destroy(); s = nil end
if not s then s = Instance.new("${t.cls}"); s.Name = ${JSON.stringify(t.name)}; s.Parent = cur end
s.Source = [${eq}[${src}]${eq}]
return s:GetFullName() .. " " .. #s.Source
`;
  return (await call("execute_luau", { studio_id: studio.id, datamodel_type: "Edit", code })).trim().slice(-120);
}

// ---- one pass --------------------------------------------------------------------------------------------
function loadState() {
  try { return JSON.parse(fs.readFileSync(STATE, "utf8")); } catch { return { files: {} }; }
}
let doneSha = null; // the commit that is fully in Studio
let lastProblem = "";

async function pass(all) {
  const sha = await headSha();
  if (sha === doneSha && !all) return 0;
  const state = loadState();
  const files = await tree(sha);
  const todo = files.filter((f) => all || state.files[f.path] !== f.sha);
  if (!todo.length) {
    if (doneSha === null) log("Studio already has every pending script (" + files.length + " on GitHub, commit " + sha.slice(0, 7) + ").");
    doneSha = sha;
    return 0;
  }
  const studio = await pickStudio();
  log(todo.length + " script(s) to push into " + studio.name + " (commit " + sha.slice(0, 7) + ")");
  let n = 0;
  for (const f of todo) {
    const t = target(f.path);
    if (!t) { log("  skipped (not a script path): " + f.path); state.files[f.path] = f.sha; continue; }
    const out = await push(studio, t, await download(sha, f.path));
    state.files[f.path] = f.sha;
    fs.writeFileSync(STATE, JSON.stringify(state, null, 1)); // after each one: a stop in the middle loses nothing
    log("  " + out);
    n++;
  }
  fs.writeFileSync(STATE, JSON.stringify(state, null, 1));
  doneSha = sha;
  log("Done: " + n + " script(s) in Studio. Save the place (File > Save / Publish) to keep them.");
  return n;
}

async function main() {
  if (!WATCH) {
    try { await pass(ALL); } catch (e) { console.error("Not pushed: " + e.message); process.exitCode = 1; }
    return;
  }
  log("Watching " + OWNER + "/" + REPO + " (" + BRANCH + ", " + DIR + ") - leave this window open.");
  let first = ALL;
  for (;;) {
    try {
      await pass(first);
      first = false;
      lastProblem = "";
    } catch (e) {
      session = null; // a restarted gateway hands out a new session
      if (e.message !== lastProblem) log("Waiting: " + e.message);
      lastProblem = e.message;
    }
    await new Promise((r) => setTimeout(r, POLL_MS));
  }
}

main();
