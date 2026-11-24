#!/usr/bin/env python3
"""Send the game's due PUSH NOTIFICATIONS (2026-11-24, week 1 of the retention plan).

The game plans them (Server/Notify): when a player leaves, it writes their next reminders into the MemoryStore
sorted map "Notify_v1" (key = UserId, value = {"list": [{"t": unix time, "k": kind, "a": {parameters}}]}, sort key =
the first one's time). This script, run every hour by GitHub Actions (.github/workflows/notify.yml), sends every
reminder whose time has come through Roblox's Open Cloud user notifications API, so they go out even when no game
server is running. A sent one is removed from the player's list; the item is deleted when its list is empty.
Roblox allows one notification per player per day from a game: a refused one (HTTP 429) moves to the next day; a
player who can't get them (400 / 403: not opted in, under 13...) is dropped.

Needs the environment variable ROBLOX_API_KEY: an Open Cloud API key (Creator Hub > Open Cloud > API Keys) with,
for this experience: "memory-store.sorted-map" read + write, and "user.user-notification" write.
The notification texts are "notification strings" made in Creator Hub (the experience > Engagement > Notifications);
put each one's id in tools/notify/config.json under its kind (an empty id = that kind is not sent).

Test without Roblox: python3 tools/notify/send.py --dry --items items.json  (a JSON list of items as the API returns
them: {"path": ".../items/<userId>", "value": {...}, "numericSortKey": t}); prints what it would do.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
CFG = json.load(open(os.path.join(HERE, "config.json"), encoding="utf-8"))
UNIVERSE = str(CFG["universe"])
MAP = CFG.get("map", "Notify_v1")
TEMPLATES = CFG.get("templates", {})
API = "https://apis.roblox.com/cloud/v2"
ITEMS = f"{API}/universes/{UNIVERSE}/memory-store/sorted-maps/{urllib.parse.quote(MAP)}/items"
DAY = 86400


def call(method, url, key, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("x-api-key", key)
    if data is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            raw = r.read()
            return r.status, (json.loads(raw) if raw else {})
    except urllib.error.HTTPError as e:
        raw = e.read()
        try:
            return e.code, json.loads(raw)
        except Exception:
            return e.code, {"raw": raw[:300].decode(errors="replace")}


def due_items(key, now):
    """Items whose sort key (their first reminder's time) has come, oldest first."""
    out, token = [], ""
    while True:
        url = f"{ITEMS}?maxPageSize=100&orderBy=asc" + (f"&pageToken={urllib.parse.quote(token)}" if token else "")
        code, res = call("GET", url, key)
        if code != 200:
            sys.exit(f"listing failed: HTTP {code} {res}")
        stop = False
        for it in res.get("items", []):
            if float(it.get("numericSortKey", 0)) > now:
                stop = True
                break
            out.append(it)
        token = res.get("nextPageToken", "")
        if stop or not token:
            return out


def send(key, user, kind, params):
    tid = TEMPLATES.get(kind, "")
    if not tid:
        return "skip"  # (no notification string for this kind yet)
    body = {
        "source": {"universe": f"universes/{UNIVERSE}"},
        "payload": {
            "message_id": tid,
            "type": "MOMENT",
            "parameters": {k: {"string_value": str(v)} for k, v in (params or {}).items()},
            "join_experience": {"launch_data": f"notif:{kind}"},
            "analytics_data": {"category": kind},
        },
    }
    code, res = call("POST", f"{API}/users/{user}/notifications", key, body)
    if code == 200:
        return "sent"
    if code == 429:
        return "later"
    if code in (400, 403, 404):
        return "drop"
    print(f"  user {user}: HTTP {code} {res}")
    return "later"


def handle(item, now, key, dry):
    """Send what is due in one player's list; returns (action, new list)."""
    user = item["path"].rsplit("/", 1)[-1]
    value = item.get("value") or {}
    if isinstance(value, str):
        value = json.loads(value)
    lst = sorted(value.get("list", []), key=lambda e: e.get("t", 0))
    keep, sent = [], False
    for e in lst:
        if e.get("t", 0) > now or sent:
            keep.append(e)
            continue
        res = "sent" if dry else send(key, user, e.get("k", ""), e.get("a"))
        print(f"  user {user}: {e.get('k')} -> {res}" + (" (dry run)" if dry else ""))
        if res == "sent":
            sent = True  # (one a day: the next due one waits for the next run after the day turned)
        elif res == "later":
            e["t"] = max(e.get("t", 0), now) + DAY
            keep.append(e)
        elif res == "drop":
            return "delete", []
        # "skip": that kind has no text yet, it is dropped
    # one a day: whatever is left goes at least a day after a sent one
    if sent:
        for e in keep:
            e["t"] = max(e["t"], now + DAY)
    keep.sort(key=lambda e: e["t"])
    return ("update" if keep else "delete"), keep


def main():
    dry = "--dry" in sys.argv
    now = time.time()
    key = os.environ.get("ROBLOX_API_KEY", "")
    if "--items" in sys.argv:
        items = json.load(open(sys.argv[sys.argv.index("--items") + 1], encoding="utf-8"))
        items = [it for it in items if float(it.get("numericSortKey", 0)) <= now]
    else:
        if not key:
            print("ROBLOX_API_KEY is not set: nothing sent")
            return
        if not any(TEMPLATES.values()):
            print("no notification string ids in tools/notify/config.json yet: nothing sent")
            return
        items = due_items(key, now)
    print(f"{len(items)} player(s) with something due")
    for it in items:
        action, keep = handle(it, now, key, dry)
        if dry:
            print(f"  -> {action} {keep}")
            continue
        url = f"{ITEMS}/{urllib.parse.quote(it['path'].rsplit('/', 1)[-1])}"
        if action == "delete":
            call("DELETE", url, key)
        else:
            ttl = int(max(keep[-1]["t"] - now + 2 * DAY, 60))
            ttl = min(ttl, 45 * DAY - 60)
            code, res = call("PATCH", url, key, {"value": {"list": keep}, "numericSortKey": keep[0]["t"], "ttl": f"{ttl}s"})
            if code != 200:
                print(f"  update failed: HTTP {code} {res}")


if __name__ == "__main__":
    main()
