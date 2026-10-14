# -*- coding: utf-8 -*-
"""extractor.py v2 — Ultra-Deep Recursive Data Serialization & Object Mapping

Modes:
  py extractor.py                     = full pipeline (deploy→rejoin→wait→collect→summarize)
  py extractor.py --mode deep-props   = same, plus deep-props post analysis
  py extractor.py --mode collect      = collect existing dd_* from workspace (no rejoin)
  py extractor.py --snap <name>       = collect + store snapshot under deep_extract/snaps/<name>
  py extractor.py --diff <snapA> <snapB>
      = state diffing: objects/attrs/values added·removed·changed between snapshots
  py extractor.py --target <dir>      = override output dir (default ./deep_extract)

Pipeline notes: exec/jobs channel is unreliable — we trigger the Luau dumper via
autoexec on a fresh attach (kill+launch, daemon autoattach fires it on join).
"""
import os, sys, json, time, glob, shutil, subprocess, argparse

os.system("")
G, Y, C, D, W, R, X = "\033[92m", "\033[93m", "\033[96m", "\033[90m", "\033[97m", "\033[91m", "\033[0m"
def log(c, m): print(c + "[extractor] " + m + X, flush=True)

HERE = os.path.dirname(os.path.abspath(__file__))
RUNNER = os.path.join(os.path.dirname(HERE), "ตัวรันโรบอค")
XCTL = os.path.join(RUNNER, "xenoctl.py")
XDIR = os.path.join(RUNNER, "Xeno-App", "xenoctl")
WS = os.path.expandvars(r"%LOCALAPPDATA%\Xeno\workspace")
AE = os.path.expandvars(r"%LOCALAPPDATA%\Xeno\autoexec")
PLACE = 107535308163741
DUMPER = os.path.join(WS, "hz_deepdump.lua")
TRIGGER = os.path.join(AE, "hz_deepdump_auto.lua")
STATE = os.path.join(XDIR, "state.json")

def xctl(*args):
    return subprocess.run([sys.executable, XCTL, *args], cwd=RUNNER,
                          capture_output=True, text=True, timeout=120).stdout

def step_deploy():
    src = os.path.join(HERE, "hz_deepdump.lua")
    if not os.path.exists(src):
        log(R, "missing repo dumper " + src); sys.exit(1)
    shutil.copy2(src, DUMPER)
    with open(TRIGGER, "w") as f:
        # wait for the real place — autoexec also fires on menu attach (place=0)
        f.write(('local PLACE=%d\n'
                'local t0=tick()\n'
                'while game.PlaceId~=PLACE and tick()-t0<180 do task.wait(1) end\n'
                'if game.PlaceId==PLACE then loadstring(readfile("hz_deepdump.lua"))() end\n') % PLACE)
    for f in glob.glob(os.path.join(WS, "dd_*")):
        os.remove(f)
    log(G, "deployed dumper + autoexec trigger, cleared stale dd_* artifacts")

def step_rejoin():
    log(Y, "killing Roblox + relaunching (autoexec fires on fresh attach)")
    xctl("kill"); time.sleep(2); xctl("launch")

def wait_place(timeout=600):
    log(C, "waiting for client in place %d — join the game now ..." % PLACE)
    t0 = time.time()
    while time.time() - t0 < timeout:
        try:
            st = json.load(open(STATE))
            for c in st.get("clients", []):
                if c[4] == PLACE:
                    log(G, "client %s @%s attached in place" % (c[1], c[0]))
                    return True
        except Exception:
            pass
        time.sleep(3)
    return False

def wait_dump(timeout=2400):
    log(C, "waiting for dump artifacts (dd_index.json = done marker) ...")
    t0 = time.time(); last = -1
    while time.time() - t0 < timeout:
        files = glob.glob(os.path.join(WS, "dd_*"))
        if len(files) != last:
            last = len(files); log(D, "  artifacts: %d" % last)
        if os.path.exists(os.path.join(WS, "dd_index.json")):
            log(G, "dump complete — %d artifacts" % last)
            return True
        time.sleep(4)
    return False

def collect(out):
    os.makedirs(out, exist_ok=True)
    moved = []
    for f in sorted(glob.glob(os.path.join(WS, "dd_*"))):
        dst = os.path.join(out, os.path.basename(f))
        shutil.copy2(f, dst); moved.append(dst)
    log(G, "collected %d files -> %s" % (len(moved), out))
    return moved

def parse_tree(path):
    rows = []
    for ln in open(path, encoding="utf-8", errors="replace"):
        d = (len(ln) - len(ln.lstrip())) // 2
        body = ln.strip()
        cls = body[1:body.index("]")] if body.startswith("[") else "?"
        name = body[body.index("]") + 2:].split(" P{")[0].split(" TAG{")[0].split(" ATTR{")[0]
        rows.append((d, cls, name, body))
    return rows

def loadj(out, name, default):
    p = os.path.join(out, name)
    if not os.path.exists(p): return default
    try:
        return json.load(open(p, encoding="utf-8"))
    except Exception:
        return default

def postprocess(out):
    idx = loadj(out, "dd_index.json", {})
    maps = []
    for tf in sorted(glob.glob(os.path.join(out, "dd_Workspace_tree_*.txt"))):
        rows = parse_tree(tf)
        for i, (d, cls, name, body) in enumerate(rows):
            if d == 0:
                j = i + 1
                while j < len(rows) and rows[j][0] > 0:
                    j += 1
                maps.append({"name": name, "class": cls, "descendants": j - i - 1})
    maps.sort(key=lambda m: -m["descendants"])
    json.dump(maps, open(os.path.join(out, "maps.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)

    attrs = loadj(out, "dd_attributes.json", {})
    values = loadj(out, "dd_values.json", [])
    remotes = open(os.path.join(out, "dd_remotes.txt"), encoding="utf-8").read().splitlines() \
        if os.path.exists(os.path.join(out, "dd_remotes.txt")) else []
    assets = loadj(out, "dd_assets.json", {})
    hidden = loadj(out, "dd_hidden.json", [])
    globs = loadj(out, "dd_globals.json", {})
    cframes = loadj(out, "dd_map_cframes.json", [])

    # prop stats from jsonl chunks
    propRows = 0; classProps = {}
    for pf in sorted(glob.glob(os.path.join(out, "dd_props_*.jsonl"))):
        for ln in open(pf, encoding="utf-8", errors="replace"):
            propRows += 1
            try:
                c = json.loads(ln)["c"]
                classProps[c] = classProps.get(c, 0) + 1
            except Exception:
                pass
    return dict(idx=idx, maps=maps, attrs=attrs, values=values, remotes=remotes,
                assets=assets, hidden=hidden, globs=globs, cframes=cframes,
                propRows=propRows, classProps=classProps)

def summary(out, P, files, title="ULTRA DUMP"):
    idx = P["idx"]
    L = []
    L.append("# %s — Chicken or Hero (place %d)" % (title, PLACE))
    L.append("")
    L.append("> %s | job %s" % (idx.get("ts", "?"), str(idx.get("job", "?"))[:13]))
    L.append("")
    L.append("## Artifacts"); L.append("")
    L.append("| file | bytes |"); L.append("|---|---|")
    for f in files:
        L.append("| `%s` | %d |" % (os.path.basename(f), os.path.getsize(f)))
    L.append("")
    L.append("## Scope (client-visible DataModel)"); L.append("")
    for k, v in idx.get("roots", {}).items():
        L.append("- **%s** — %s nodes%s" % (k, v.get("nodes"),
                 (" _(err: %s)_" % str(v["err"])[:60]) if "err" in v else ""))
    c = idx.get("counts", {})
    L.append("")
    L.append("remotes **%d** · values **%d** · attributed-instances **%d** · pivots **%d** · hidden **%d**"
             % (c.get("remotes", 0), c.get("values", 0), c.get("attrs", 0),
                c.get("cframes", 0), idx.get("hiddenCount", 0)))
    L.append("deep-prop rows **%d** across **%d** classes · sounds **%d** · images **%d** · meshes **%d**"
             % (P["propRows"], len(P["classProps"]), c.get("sounds", 0), c.get("images", 0), c.get("meshes", 0)))
    L.append("")
    L.append("## CollectionService tags"); L.append("")
    for t, n in sorted(idx.get("tags", {}).items(), key=lambda x: -x[1])[:30]:
        L.append("- `%s` × %d" % (t, n))
    L.append("")
    L.append("## Hidden (nil-parented) instances")
    L.append("")
    L.append("```")
    for h in P["hidden"][:60]:
        L.append("%-28s %-40s par=%s kids=%s" % (h.get("c", "?"), str(h.get("n", "?"))[:40],
                 str(h.get("par", "?"))[:50], h.get("kids", "?")))
    L.append("```")
    L.append("")
    L.append("## Globals snapshot")
    L.append("")
    for scope in ("env", "shared", "genv"):
        tbl = P["globs"].get(scope, {})
        keys = list(tbl.keys()) if isinstance(tbl, dict) else []
        L.append("- `%s` — %d keys: %s" % (scope, len(keys), ", ".join(keys[:25])))
    L.append("")
    L.append("## Top classes"); L.append("")
    for t, n in sorted(idx.get("classes", {}).items(), key=lambda x: -x[1])[:30]:
        L.append("- `%s` × %d" % (t, n))
    L.append("")
    L.append("## Workspace top-level (map candidates)"); L.append("")
    L.append("| object | class | descendants |"); L.append("|---|---|---|")
    for m in P["maps"][:40]:
        L.append("| %s | %s | %d |" % (m["name"], m["class"], m["descendants"]))
    L.append("")
    L.append("## Remotes"); L.append(""); L.append("```")
    L.extend(P["remotes"][:80]); L.append("```")
    open(os.path.join(out, "ULTRA_DUMP_SUMMARY.md"), "w", encoding="utf-8").write("\n".join(L))
    log(G, "ULTRA_DUMP_SUMMARY.md written")

def state_diff(out, a, b):
    """diff two snapshots: added/removed instances, attr+value changes"""
    da = loadj(os.path.join(out, "snaps", a), "dd_attributes.json", {})
    db = loadj(os.path.join(out, "snaps", b), "dd_attributes.json", {})
    va = {v["p"]: v["v"] for v in loadj(os.path.join(out, "snaps", a), "dd_values.json", [])}
    vb = {v["p"]: v["v"] for v in loadj(os.path.join(out, "snaps", b), "dd_values.json", [])}
    # path sets from props jsonl
    def paths(snap):
        s = set()
        for pf in glob.glob(os.path.join(out, "snaps", snap, "dd_props_*.jsonl")):
            for ln in open(pf, encoding="utf-8", errors="replace"):
                try: s.add(json.loads(ln)["p"])
                except Exception: pass
        for tf in glob.glob(os.path.join(out, "snaps", snap, "dd_*_tree_*.txt")):
            # tree lines don't carry full paths — skip
            pass
        return s
    pa, pb = paths(a), paths(b)
    diff = {
        "added": sorted(pb - pa),
        "removed": sorted(pa - pb),
        "attr_changed": {k: {"a": da[k], "b": db[k]} for k in da if k in db and da[k] != db[k]},
        "attr_added": sorted(set(db) - set(da)),
        "attr_removed": sorted(set(da) - set(db)),
        "value_changed": {k: {"a": va[k], "b": vb[k]} for k in va if k in vb and va[k] != vb[k]},
        "value_added": sorted(set(vb) - set(va)),
        "value_removed": sorted(set(va) - set(vb)),
    }
    dst = os.path.join(out, "diff_%s_vs_%s.json" % (a, b))
    json.dump(diff, open(dst, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    log(G, "diff -> %s  (added %d / removed %d / attrΔ %d / valΔ %d)"
        % (dst, len(diff["added"]), len(diff["removed"]),
           len(diff["attr_changed"]), len(diff["value_changed"])))

def run_pipeline(out, mode):
    log(W, "=== ultra deep extract — mode=%s out=%s ===" % (mode, out))
    step_deploy()
    step_rejoin()
    if not wait_place(): log(R, "timeout waiting for client in place"); sys.exit(2)
    if not wait_dump(): log(R, "timeout waiting for artifacts"); sys.exit(3)
    files = collect(out)
    P = postprocess(out)
    summary(out, P, files)
    try: os.remove(TRIGGER)
    except OSError: pass
    log(W, "=== done — see %s ===" % out)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", default="run",
                    choices=["run", "deep-props", "collect", "diff"])
    ap.add_argument("--target", default=None, help="output dir (default ./deep_extract)")
    ap.add_argument("--snap", default=None, help="collect into snaps/<name>")
    ap.add_argument("--diff", nargs=2, metavar=("A", "B"), help="diff two snapshots")
    ap.add_argument("--no-rejoin", action="store_true", help="skip kill+launch")
    args = ap.parse_args()

    out = os.path.abspath(args.target) if args.target else os.path.join(HERE, "deep_extract")

    if args.diff:
        state_diff(out, args.diff[0], args.diff[1]); return
    if args.snap:
        snapdir = os.path.join(out, "snaps", args.snap)
        files = collect(snapdir)
        log(G, "snapshot '%s' -> %s (%d files)" % (args.snap, snapdir, len(files))); return
    if args.mode == "collect":
        files = collect(out)
        P = postprocess(out); summary(out, P, files); return

    if args.no_rejoin:
        step_deploy()
        log(C, "no-rejoin: run loadstring(readfile(\"hz_deepdump.lua\"))() in executor, waiting for artifacts ...")
        if not wait_dump():
            log(R, "timeout"); sys.exit(3)
    else:
        run_pipeline(out, args.mode); return
    files = collect(out)
    P = postprocess(out); summary(out, P, files)
    log(W, "=== done — see %s ===" % out)

if __name__ == "__main__":
    main()
