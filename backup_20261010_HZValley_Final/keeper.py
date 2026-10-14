# -*- coding: utf-8 -*-
"""keeper.py — Host-side Sentinel (process/session watcher) for HZ HUB

Watches RobloxPlayerBeta.exe and the client-side heartbeat file written by
hz_keeper.lua (autoexec). On crash/exit/hang it relaunches the game via the
roblox:// deep link and keeps a persistent session state.

  py keeper.py              = watch loop (Ctrl+C to stop)
  py keeper.py --once       = single status check and exit
  py keeper.py --place N    = override target place id

Anti-spam: max 5 consecutive relaunches -> 30s cooldown.
Logs: logs/session.log  |  State: keeper_state.json
"""
import os, sys, json, time, glob, subprocess, argparse, ctypes, datetime

os.system("")
G, Y, C, D, W, R, X = "\033[92m", "\033[93m", "\033[96m", "\033[90m", "\033[97m", "\033[91m", "\033[0m"

HERE = os.path.dirname(os.path.abspath(__file__))
WS = os.path.expandvars(r"%LOCALAPPDATA%\Xeno\workspace")
HB_FILE = os.path.join(WS, "hz_keeper_heartbeat.txt")
ST_FILE = os.path.join(WS, "hz_keeper_state.json")
LOGDIR = os.path.join(HERE, "logs")
LOGFILE = os.path.join(LOGDIR, "session.log")
SENT_STATE = os.path.join(HERE, "keeper_state.json")
EXE = "RobloxPlayerBeta.exe"
MAX_REJOIN = 5
COOLDOWN_S = 30
HB_STALE_S = 90
POLL_S = 10

def slog(msg):
    line = "[%s] %s" % (datetime.datetime.now().strftime("%H:%M:%S"), msg)
    print(C + "  " + line + X, flush=True)
    os.makedirs(LOGDIR, exist_ok=True)
    with open(LOGFILE, "a", encoding="utf-8") as f:
        f.write(line + "\n")

def pids_of_roblox():
    out = subprocess.run(["tasklist", "/FI", "IMAGENAME eq %s" % EXE, "/FO", "CSV", "/NH"],
                         capture_output=True, text=True).stdout
    pids = []
    for ln in out.splitlines():
        parts = [p.strip('"') for p in ln.split('","')]
        if len(parts) >= 2 and parts[0].lower() == EXE.lower():
            try: pids.append(int(parts[1]))
            except ValueError: pass
    return pids

def relaunch(place):
    uri = "roblox://placeId=%d" % place
    slog("relaunch -> %s" % uri)
    subprocess.Popen(["cmd", "/c", "start", "", uri],
                     creationflags=subprocess.CREATE_NO_WINDOW)

def kill_pid(pid):
    subprocess.run(["taskkill", "/F", "/PID", str(pid)],
                   capture_output=True)
    slog("killed hung pid %d" % pid)

def heartbeat_age():
    try:
        return time.time() - os.path.getmtime(HB_FILE)
    except OSError:
        return None

def save_sent(**kw):
    st = {}
    if os.path.exists(SENT_STATE):
        try: st = json.load(open(SENT_STATE, encoding="utf-8"))
        except Exception: pass
    st.update(kw); st["ts"] = time.time()
    with open(SENT_STATE, "w", encoding="utf-8") as f:
        json.dump(st, f, indent=1)

def client_state():
    try:
        return json.load(open(ST_FILE, encoding="utf-8"))
    except Exception:
        return {}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--once", action="store_true")
    ap.add_argument("--place", type=int, default=107535308163741)
    args = ap.parse_args()
    place = args.place

    consecutive = 0
    ever_seen_process = False
    slog("sentinel up — watching %s place=%d hb-stale=%ds poll=%ds"
         % (EXE, place, HB_STALE_S, POLL_S))

    while True:
        pids = pids_of_roblox()
        age = heartbeat_age()
        cst = client_state()

        if not pids:
            if ever_seen_process:
                slog("process gone (crash/exit) — last client: %s"
                     % json.dumps({k: cst.get(k) for k in ("user", "job", "RunState", "InMatch")}))
            ever_seen_process = False
            consecutive += 1
            if consecutive > MAX_REJOIN:
                slog("rejoin cap %d hit — cooldown %ds" % (MAX_REJOIN, COOLDOWN_S))
                time.sleep(COOLDOWN_S); consecutive = 0
            relaunch(place)
            save_sent(pid=None, action="relaunch", consecutive=consecutive)
        else:
            ever_seen_process = True
            if consecutive: consecutive = 0
            # freeze guard: process alive but heartbeat stale
            if age is not None and age > HB_STALE_S:
                slog("heartbeat stale %.0fs — client likely hung" % age)
                for pid in pids:
                    kill_pid(pid)
                save_sent(pid=pids, action="kill-hung", hb_age=age)
            else:
                save_sent(pid=pids, action="alive", hb_age=age,
                          place=cst.get("place"), user=cst.get("user"))

        if args.once:
            print("pids=%s hb_age=%s state=%s"
                  % (pids, ("%.0fs" % age) if age else "n/a",
                     json.dumps({k: cst.get(k) for k in ("place","user","RunState","InMatch")})))
            return
        time.sleep(POLL_S)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        slog("sentinel stopped by user")
