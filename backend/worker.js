/**
 * ============================================================================
 * HZ HUB — Licensing / Telemetry / Admin backend  (Cloudflare Worker, ESM)
 * ============================================================================
 *
 * Single-file worker. Persistence = Cloudflare KV bound as env.STATS.
 * If STATS is not bound, falls back to in-memory storage (cold-start resets)
 * — bind KV for production.
 *
 * KV schema (single namespace `STATS`, JSON docs):
 *   "keys"   : { <key>: { st:"on"|"off", hw, bind, note, wm, at, exp, uses, last, u, uid } }
 *   "agg"    : { total, games:{g:n}, users:{uid:{u,dn,count,hwSet,last}}, events:[…≤100] }
 *   "status" : { global:bool, games:{g:bool}, msg, ver }
 *   "pk:<g>" : { pk:"<b64>", at }                 ← payload key ต่อเกม (deploy.py อัปโหลด)
 *   "rl:<ip>": { n, ts }                          ← rate-limit bucket /unlock
 *
 * Client-facing (public):
 *   GET  /status?g=<id>&hw=<hwid> → {on,msg,banned:[wm…]}      (client polls 60s)
 *   POST /ping   {ev,g,tag,u|username,dn,uid,hw|hwid,place}    (telemetry)
 *   POST /unlock {k|key,hw|hwid,u,dn,uid,g,tag}                (web-key → payload key)
 *       → {ok:true, pk:"<b64>", wm} | {ok:false, why:"no-key|banned|expired|bound|rate|no-pk"}
 *
 * Admin (x-admin-key header หรือ ?key= ; ผิด = 403):
 *   POST /admin/keygen        {count,note,custom?,bind?,days?}
 *   GET  /admin/keys          → JSON dump ทุกคีย์
 *   POST /admin/key/manage    {key,action:"ban"|"unban"|"reset_hwid"|"delete"}
 *   POST /admin/system        {maintenance:bool,msg?,game?,version?}
 *   GET  /admin/stats         → telemetry JSON
 *   GET  /admin               → HTML dashboard
 *   GET  /admin/setpk?g&pk    → อัปโหลด payload key (deploy.py ใช้)
 *   GET  /admin/set?g&on&msg  → alias ของ /admin/system สำหรับเปิดลิงก์ตรง
 *
 * Required env secret: ADMIN_KEY  (Settings → Variables and Secrets)
 * ============================================================================
 */

const enc = new TextEncoder();
const JSON_HEADERS = {
  "content-type": "application/json; charset=utf-8",
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "content-type,x-admin-key",
  "access-control-allow-methods": "GET,POST,OPTIONS",
};
const mem = {}; // fallback when KV unbound

/* ----------------------------- utils ------------------------------------- */

const adminKey = (env) => env.ADMIN_KEY || "";
function isAdmin(req, env) {
  const k = adminKey(env);
  if (!k) return false;
  const url = new URL(req.url);
  return req.headers.get("x-admin-key") === k || url.searchParams.get("key") === k;
}
const j = (obj, status = 200) => new Response(JSON.stringify(obj), { status, headers: JSON_HEADERS });
const bad = (why, status = 400) => j({ ok: false, why }, status);
const esc = (s) => String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));
const thai = (t) => (t ? new Date(t).toLocaleString("th-TH") : "-");
const b64d = (s) => Uint8Array.from(atob(s), (c) => c.charCodeAt(0));

async function kvGet(env, key, dflt) {
  try {
    const v = env.STATS ? await env.STATS.get(key, "json") : mem[key];
    return v && typeof v === "object" ? v : dflt;
  } catch { return dflt; }
}
async function kvPut(env, key, val) {
  if (env.STATS) await env.STATS.put(key, JSON.stringify(val));
  else mem[key] = val;
}
const getAgg = (env) => kvGet(env, "agg", { total: 0, games: {}, users: {}, events: [] });
const getKeys = (env) => kvGet(env, "keys", {});
const getStatusDoc = (env) => kvGet(env, "status", { global: true, games: {}, msg: "", ver: "" });

/** wm = first 8 bytes of HMAC-SHA256(key, "hzv-id") as hex — identical to client. */
async function wmOf(key) {
  const ck = await crypto.subtle.importKey("raw", enc.encode(key), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const sig = new Uint8Array(await crypto.subtle.sign("HMAC", ck, enc.encode("hzv-id")));
  return [...sig.slice(0, 8)].map((b) => b.toString(16).padStart(2, "0")).join("");
}
/** Sign critical payload for client (integrity marker; TLS + artifact tag do the real work). */
async function signPayload(env, data) {
  const secret = env.HMAC_SECRET || adminKey(env) || "hz-srv";
  const ck = await crypto.subtle.importKey("raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const sig = new Uint8Array(await crypto.subtle.sign("HMAC", ck, enc.encode(data)));
  return btoa(String.fromCharCode(...sig));
}

/** Cryptographically secure key: HZ-XXXX-XXXX-XXXX (Crockford-ish charset, no confusables). */
function genKey() {
  const CH = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
  const rnd = crypto.getRandomValues(new Uint8Array(12));
  const seg = (o) => [...rnd.slice(o, o + 4)].map((b) => CH[b % CH.length]).join("");
  return `HZ-${seg(0)}-${seg(4)}-${seg(8)}`;
}

/* ----------------------------- status ------------------------------------ */

async function buildStatus(env, g, hw) {
  const d = { on: true, msg: "", banned: [] };
  const doc = await getStatusDoc(env);
  if (doc) {
    if (doc.global === false) d.on = false;
    if (g && doc.games && doc.games[g] === false) d.on = false;
    if (typeof doc.msg === "string") d.msg = doc.msg;
  }
  const keys = await getKeys(env);
  for (const k in keys) {
    const r = keys[k];
    if (r.st === "off") {
      if (r.wm) d.banned.push(r.wm);
      if (hw && r.hw && r.hw === hw) d.on = false; // แบนทั้งเครื่อง
    }
  }
  return d;
}

/* --------------------------- client routes -------------------------------- */

async function routeStatus(url, env) {
  return j(await buildStatus(env, url.searchParams.get("g"), url.searchParams.get("hw")));
}

async function routePing(req, env) {
  let b = {}; try { b = await req.json(); } catch { return bad("bad-json"); }
  const g = String(b.g || "?"), u = String(b.u || b.username || "?"), hw = String(b.hw || b.hwid || "?");
  console.log(`PING ${b.ev || b.action || "ev"} | g=${g} tag=${b.tag || ""} | @${u} uid=${b.uid || ""} hw=${hw.slice(0, 12)} place=${b.place || 0}`);
  const agg = await getAgg(env);
  agg.total = (agg.total || 0) + 1;
  agg.games[g] = (agg.games[g] || 0) + 1;
  const ukey = String(b.uid || u);
  const cur = agg.users[ukey] || { u, dn: b.dn || "", first: Date.now(), count: 0, hwSet: {} };
  cur.u = u; cur.dn = b.dn || cur.dn; cur.last = Date.now(); cur.count = (cur.count || 0) + 1;
  cur.hwSet = cur.hwSet || {}; cur.hwSet[hw.slice(0, 16)] = true;
  agg.users[ukey] = cur;
  agg.events = agg.events || [];
  agg.events.push({ t: Date.now(), ev: b.ev || b.action || "", g, u, tag: b.tag || "" });
  if (agg.events.length > 100) agg.events = agg.events.slice(-100);
  await kvPut(env, "agg", agg);
  return j({ ok: true });
}

async function routeUnlock(req, env) {
  let b = {}; try { b = await req.json(); } catch { return bad("bad-json"); }
  const key = String(b.k || b.key || ""), hw = String(b.hw || b.hwid || ""), g = String(b.g || "");
  // rate-limit brute-force: 15 tries / 10 min / IP
  const ip = req.headers.get("cf-connecting-ip") || "?";
  const rl = await kvGet(env, "rl:" + ip, { n: 0, ts: 0 });
  if (rl.ts < Date.now() - 600e3) { rl.n = 0; rl.ts = Date.now(); }
  if (rl.n >= 15) return bad("rate", 429);
  const keys = await getKeys(env);
  const rec = keys[key];
  if (!rec) { rl.n++; await kvPut(env, "rl:" + ip, rl); return bad("no-key"); }
  if (rec.st === "off") return bad("banned", 403);
  if (rec.exp && Date.now() > rec.exp) return bad("expired", 403);
  if (rec.bind && rec.hw && rec.hw !== hw) return bad("bound", 403);
  const pkdoc = await kvGet(env, "pk:" + g, null);
  if (!pkdoc || !pkdoc.pk) return bad("no-pk", 503);
  if (rec.bind && !rec.hw) rec.hw = hw; // ผูกเครื่องเฉพาะคีย์ที่ติ๊ก bind
  rec.uses = (rec.uses || 0) + 1; rec.last = Date.now(); rec.u = b.u || ""; rec.uid = b.uid || 0;
  keys[key] = rec;
  await kvPut(env, "keys", keys);
  rl.n = 0; await kvPut(env, "rl:" + ip, rl);
  console.log(`UNLOCK ok g=${g} @${b.u} key=${key.slice(0, 6)}… wm=${rec.wm || ""}`);
  return j({ ok: true, pk: pkdoc.pk, wm: rec.wm || "", sig: await signPayload(env, pkdoc.pk + hw) });
}

/* ---------------------------- admin routes -------------------------------- */

async function routeKeygen(req, env) {
  let b = {}; try { b = await req.json(); } catch {}
  const url = new URL(req.url);
  const count = Math.min(Math.max(1, b.count || url.searchParams.get("count") || 1), 50);
  const note = b.note ?? url.searchParams.get("note") ?? "";
  const custom = b.custom || url.searchParams.get("k") || "";
  const bind = !!(b.bind ?? (url.searchParams.get("bind") === "1"));
  const days = parseFloat(b.days ?? url.searchParams.get("exp") ?? "0") || 0;
  const keys = await getKeys(env);
  const made = [];
  for (let i = 0; i < count; i++) {
    let k = (i === 0 && custom) ? custom : genKey();
    if (keys[k]) return bad("dup:" + k, 409);
    keys[k] = {
      st: "on", hw: null, bind, note, wm: await wmOf(k), at: Date.now(),
      exp: days > 0 ? Date.now() + days * 864e5 : 0, uses: 0,
    };
    made.push(k);
  }
  await kvPut(env, "keys", keys);
  console.log(`KEYGEN +${made.length} note=${note}`);
  return j({ ok: true, keys: made });
}

async function routeKeyList(env) {
  const keys = await getKeys(env);
  return j({ ok: true, count: Object.keys(keys).length, keys });
}

async function routeKeyManage(req, env) {
  let b = {}; try { b = await req.json(); } catch {}
  const url = new URL(req.url);
  const k = b.key || url.searchParams.get("k") || "";
  const action = b.action || url.searchParams.get("st") || "";
  if (!k) return bad("no-key");
  const keys = await getKeys(env);
  if (action === "delete") {
    delete keys[k];
    await kvPut(env, "keys", keys);
    return j({ ok: true, deleted: k });
  }
  if (!keys[k]) {
    if (action === "ban") keys[k] = { st: "off", note: "ban baked", wm: await wmOf(k), at: Date.now(), uses: 0 };
    else return bad("no-key");
  }
  const r = keys[k];
  if (action === "ban") r.st = "off";
  else if (action === "unban") r.st = "on";
  else if (action === "reset_hwid") r.hw = null;
  else return bad("bad-action");
  keys[k] = r;
  await kvPut(env, "keys", keys);
  console.log(`KEY ${action} ${k}`);
  return j({ ok: true, key: k, st: r.st, hw: r.hw });
}

async function routeSystem(req, env) {
  let b = {}; try { b = await req.json(); } catch {}
  const url = new URL(req.url);
  const doc = await getStatusDoc(env);
  doc.games = doc.games || {};
  const g = b.game || url.searchParams.get("g") || "all";
  let on;
  if (b.maintenance !== undefined) on = !b.maintenance;
  else if (url.searchParams.get("on") !== null) on = url.searchParams.get("on") !== "0";
  else return bad("no-op"); // POST ว่างไม่แตะสถานะ — กัน refresh พลิก kill-switch
  if (g === "all") doc.global = !!on; else doc.games[g] = !!on;
  const msg = b.msg ?? url.searchParams.get("msg");
  if (msg !== undefined) doc.msg = msg;
  if (b.version) doc.ver = b.version;
  await kvPut(env, "status", doc);
  console.log(`SYSTEM g=${g} on=${on} msg=${doc.msg || ""}`);
  return j({ ok: true, status: doc });
}

async function routeStats(env) {
  const agg = await getAgg(env);
  const users = Object.values(agg.users || {});
  const machines = new Set(); users.forEach((x) => Object.keys(x.hwSet || {}).forEach((h) => machines.add(h)));
  return j({
    total_pings: agg.total || 0, unique_users: users.length, unique_machines: machines.size,
    games: agg.games || {}, users: users.map((x) => ({ u: x.u, dn: x.dn, count: x.count, machines: Object.keys(x.hwSet || {}).length, last: x.last })),
    events_tail: (agg.events || []).slice(-20).reverse(), status: await buildStatus(env, null, null), kv: !!env.STATS,
  });
}

async function routeSetpk(url, env) {
  const g = url.searchParams.get("g") || "", pk = url.searchParams.get("pk") || "";
  try { if (b64d(pk).length !== 32) return bad("bad-pk"); }
  catch { return bad("bad-pk"); }
  await kvPut(env, "pk:" + g, { pk, at: Date.now() });
  console.log(`SETPK g=${g}`);
  return j({ ok: true, g });
}

/* --------------------------- admin dashboard ------------------------------ */

function adminHtml(AB) {
  return `<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Admin</title><style>
:root{--bg:#0f0c1a;--card:#1c1730;--card2:#241d3d;--line:#382f55;--tx:#ece8f7;--mut:#9a8fc0;--grn:#43d17c;--red:#ff5c6c;--amb:#ffc35c;--acc:#7c5cff}
*{box-sizing:border-box}
body{font-family:system-ui,-apple-system,sans-serif;background:var(--bg);color:var(--tx);margin:0;padding:0}
.top{position:sticky;top:0;background:rgba(15,12,26,.92);backdrop-filter:blur(8px);border-bottom:1px solid var(--line);padding:12px 20px;display:flex;align-items:center;gap:12px;z-index:9}
.top h1{font-size:17px;margin:0;font-weight:800;letter-spacing:.5px}
.pill{padding:4px 12px;border-radius:20px;font-size:12px;font-weight:700}
.pill.on{background:rgba(67,209,124,.15);color:var(--grn);border:1px solid rgba(67,209,124,.4)}
.pill.off{background:rgba(255,92,108,.15);color:var(--red);border:1px solid rgba(255,92,108,.4)}
.wrap{max-width:1100px;margin:auto;padding:16px}
.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px;margin:14px 0}
.stat{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:14px}
.stat .n{font-size:26px;font-weight:800}.stat .l{font-size:11px;color:var(--mut);text-transform:uppercase;letter-spacing:.6px}
.card{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:18px;margin:14px 0}
.card h2{font-size:14px;color:var(--mut);margin:0 0 12px;text-transform:uppercase;letter-spacing:.8px}
.b{padding:8px 14px;border-radius:8px;border:0;cursor:pointer;font-weight:700;font-size:12px;color:#fff;transition:.15s}
.b:hover{filter:brightness(1.2)}.b:active{transform:scale(.96)}
.bp{background:var(--acc)}.bg{background:#2e7d5b}.br{background:#c93a4e}.bm{background:#4a3f6b}
.b.sm{padding:5px 10px;font-size:11px}
table{width:100%;border-collapse:collapse;font-size:12px}
th{color:var(--mut);font-size:10px;text-transform:uppercase;letter-spacing:.6px}
td,th{padding:9px 8px;border-bottom:1px solid var(--line);text-align:left}
tr:hover td{background:rgba(124,92,255,.05)}
input,select{padding:9px 12px;border-radius:8px;border:1px solid var(--line);background:#151020;color:var(--tx);margin:3px;font-size:13px}
input:focus{outline:none;border-color:var(--acc)}
code{background:#151020;padding:3px 8px;border-radius:5px;font-size:12px}
.dot{display:inline-block;width:8px;height:8px;border-radius:50%;margin-right:6px}
.dot.g{background:var(--grn)}.dot.r{background:var(--red)}
.tag{font-size:10px;padding:2px 8px;border-radius:10px;background:var(--card2);color:var(--mut)}
#toast{position:fixed;bottom:18px;right:18px;background:var(--acc);padding:11px 20px;border-radius:10px;display:none;font-weight:700;box-shadow:0 6px 24px rgba(0,0,0,.5);z-index:99}
#gate{min-height:100vh;display:flex;align-items:center;justify-content:center}
#gate .card{width:320px;text-align:center;padding:32px}
#gate input{width:100%;text-align:center;font-size:15px;padding:12px;margin:10px 0}
.mono{font-family:ui-monospace,monospace}
.search{width:200px}
</style>

<div id="gate"><div class="card"><div style="font-size:34px;margin-bottom:6px">LOCKED</div>
<h2 style="color:var(--tx);font-size:16px">RESTRICTED AREA</h2>
<input id="pw" type="password" placeholder="admin key" autocomplete="off">
<button class="b bp" style="width:100%;padding:10px" onclick="doLogin()">Unlock</button>
<div id="gateMsg" style="color:var(--red);font-size:12px;margin-top:8px"></div></div></div>

<div id="app" style="display:none">
<div class="top"><h1>HZ HUB <span style="color:var(--mut);font-weight:400;font-size:12px">admin console</span></h1>
<span id="sysPill" class="pill on">LIVE</span>
<span style="flex:1"></span>
<button class="b bm sm" onclick="load()">Refresh</button>
<button class="b br sm" onclick="logout()">Logout</button></div>
<div class="wrap">
<div id="toast"></div>

<div class="cards" id="cards"></div>

<div class="card"><h2>KILL-SWITCH</h2>
<select id="sysG"><option value="all">ทุกเกม</option><option value="valley">valley</option></select>
<select id="sysOn"><option value="1">เปิดใช้งาน</option><option value="0">ปิดระบบ (kill)</option></select>
<input id="sysMsg" placeholder="ข้อความถึงผู้ใช้ เช่น กำลังอัปเดต v3" size="30">
<button class="b bp" onclick="sysSet()">ตั้งค่า</button>
<span style="font-size:11px;color:var(--mut);margin-left:8px">client เช็กทุก 60 วิ — ปิดแล้วทุกเครื่องขึ้นหน้าบำรุงรักษา</span></div>

<div class="card"><h2>สร้างคีย์</h2>
<input id="kgCustom" placeholder="คีย์กำหนดเอง (เว้น=สุ่ม HZ-XXXX)" size="22">
<input id="kgNote" placeholder="หมายเหตุ / ชื่อเทสเตอร์" size="18">
<input id="kgDays" placeholder="อายุ (วัน)" size="8" type="number" min="0">
<label style="font-size:12px;color:var(--mut)"><input type="checkbox" id="kgBind"> ล็อกเครื่องแรก</label>
<button class="b bg" onclick="keygen()">สร้างคีย์</button>
<div id="kgOut" style="margin-top:10px;font-size:14px"></div></div>

<div class="card"><h2>คีย์ทั้งหมด</h2>
<div id="kvNote"></div>
<input class="search" id="kq" placeholder="ค้นหาคีย์/ชื่อเทสเตอร์/ผู้ใช้..." oninput="renderKeys()">
<table><thead><tr><th>คีย์</th><th>สถานะ</th><th>หมายเหตุ</th><th>ผู้ใช้</th><th>ครั้ง</th><th>เครื่อง</th><th>หมดอายุ</th><th>ล่าสุด</th><th></th></tr></thead>
<tbody id="krows"></tbody></table></div>

<div class="card"><h2>ผู้ใช้ล่าสุด</h2>
<table><thead><tr><th>ผู้เล่น</th><th>ชื่อแสดง</th><th>ครั้ง</th><th>เครื่อง</th><th>ล่าสุด</th></tr></thead><tbody id="urows"></tbody></table></div>

<div class="card"><h2>เหตุการณ์ล่าสุด</h2>
<table><thead><tr><th>เวลา</th><th>event</th><th>เกม</th><th>ผู้เล่น</th><th>build</th></tr></thead><tbody id="erows"></tbody></table></div>
</div></div>

<script>
const PRE="${AB}";
let K=sessionStorage.getItem("hzk")||"";
{const u=new URL(location.href),qk=u.searchParams.get("key");
 if(qk){K=qk;sessionStorage.setItem("hzk",K);u.search="";history.replaceState(0,"",u.pathname);}}
const $=id=>document.getElementById(id);
let KEYS={};
async function api(p,o){
  const r=await fetch(PRE+p,{headers:{"x-admin-key":K,"content-type":"application/json"},...o});
  if(r.status===403||r.status===401){$("gate").style.display="flex";$("app").style.display="none";if(K)$("gateMsg").textContent="key ไม่ถูกต้อง";K="";sessionStorage.removeItem("hzk");throw 403;}
  return r.json();
}
function doLogin(){K=$("pw").value.trim();sessionStorage.setItem("hzk",K);$("gateMsg").textContent="";load();}
function logout(){sessionStorage.removeItem("hzk");K="";location.reload();}
const toast=(m,bad)=>{const t=$("toast");t.textContent=m;t.style.background=bad?"#c93a4e":"#7c5cff";t.style.display="block";setTimeout(()=>t.style.display="none",2600)};
const fdt=t=>t?new Date(t).toLocaleString("th-TH"):"-";
const cp=t=>{navigator.clipboard.writeText(t).then(()=>toast("copied: "+t))};

async function sysSet(){
  const r=await api("/admin/system",{method:"POST",body:JSON.stringify({game:sysG.value,maintenance:sysOn.value==="0",msg:sysMsg.value})});
  toast(r.ok?"ตั้งค่าแล้ว":"ล้มเหลว",!r.ok); load();
}
async function keygen(){
  const body={count:1,note:kgNote.value,custom:kgCustom.value||undefined,bind:kgBind.checked,days:parseFloat(kgDays.value)||0};
  const r=await api("/admin/keygen",{method:"POST",body:JSON.stringify(body)});
  if(r.ok){kgOut.innerHTML='คีย์ใหม่: <code class="mono" style="font-size:15px;color:var(--grn)">'+r.keys[0]+'</code> <button class="b bp sm" onclick="cp(\\''+r.keys[0]+'\\')">copy</button>';kgCustom.value="";}
  else kgOut.textContent="ล้มเหลว: "+(r.why||"?");
  load();
}
async function manage(k,a){
  const r=await api("/admin/key/manage",{method:"POST",body:JSON.stringify({key:k,action:a})});
  toast(r.ok?a+" "+k:"ล้มเหลว",!r.ok); load();
}
function renderKeys(){
  const q=($("kq").value||"").toLowerCase();
  const rows=Object.entries(KEYS).filter(([k,r])=>!q||k.toLowerCase().includes(q)||(r.note||"").toLowerCase().includes(q)||(r.u||"").toLowerCase().includes(q))
    .sort((a,b)=>(b[1].at||0)-(a[1].at||0));
  $("krows").innerHTML=rows.map(([k,r])=>{
    const off=r.st==="off",expd=r.exp&&r.exp<Date.now();
    return "<tr><td><code class='mono'>"+k+"</code> <button class='b bm sm' onclick=\\"cp('"+k+"')\\">copy</button></td>"+
    "<td><span class='dot "+(off?"r":"g")+"'></span>"+(off?"แบน":expd?"หมดอายุ":"ใช้งาน")+"</td>"+
    "<td>"+(r.note||"")+"</td><td>"+(r.u?"@"+r.u:"-")+"</td><td>"+(r.uses||0)+"</td>"+
    "<td>"+(r.bind?(r.hw?"locked":"รอผูก"):"-")+"</td><td>"+(r.exp?fdt(r.exp):"ไม่จำกัด")+"</td><td>"+fdt(r.last)+"</td>"+
    "<td style='white-space:nowrap'><button class='b "+(off?"bg":"br")+" sm' onclick=\\"manage('"+k+"','"+(off?"unban":"ban")+"')\\">"+(off?"ปลดแบน":"แบน")+"</button>"+
    "<button class='b bm sm' onclick=\\"manage('"+k+"','reset_hwid')\\">ปลดเครื่อง</button>"+
    "<button class='b br sm' onclick=\\"if(confirm('ลบ "+k+" ?'))manage('"+k+"','delete')\\">ลบ</button></td></tr>";
  }).join("")||"<tr><td colspan=9 style='color:var(--mut)'>ไม่มีคีย์ — สร้างจากฟอร์มด้านบน</td></tr>";
}
async function load(){
  try{
    const [kl,ss]=await Promise.all([api("/admin/keys"),api("/admin/stats")]);
    $("gate").style.display="none";$("app").style.display="block";
    KEYS=kl.keys||{};
    const sysOff=ss.status&&ss.status.on===false;
    $("sysPill").textContent=sysOff?"OFFLINE":"LIVE";$("sysPill").className="pill "+(sysOff?"off":"on");
    const vals=Object.values(KEYS);
    const act=vals.filter(r=>r.st!=="off").length, ban=vals.filter(r=>r.st==="off").length;
    $("cards").innerHTML=
      '<div class="stat"><div class="n">'+vals.length+'</div><div class="l">คีย์ทั้งหมด</div></div>'+
      '<div class="stat"><div class="n" style="color:var(--grn)">'+act+'</div><div class="l">ใช้งาน</div></div>'+
      '<div class="stat"><div class="n" style="color:var(--red)">'+ban+'</div><div class="l">แบน</div></div>'+
      '<div class="stat"><div class="n">'+(ss.unique_users||0)+'</div><div class="l">ผู้ใช้</div></div>'+
      '<div class="stat"><div class="n">'+(ss.unique_machines||0)+'</div><div class="l">เครื่อง</div></div>'+
      '<div class="stat"><div class="n">'+(ss.total_pings||0)+'</div><div class="l">ping</div></div>';
    $("kvNote").innerHTML=ss.kv?"":'<div style="color:var(--amb);font-size:12px;margin-bottom:8px">KV ไม่ได้ผูก — ข้อมูลรีเซ็ตตอน cold start</div>';
    renderKeys();
    $("urows").innerHTML=(ss.users||[]).map(x=>"<tr><td class='mono'>@"+x.u+"</td><td>"+(x.dn||"")+"</td><td>"+x.count+"</td><td>"+x.machines+"</td><td>"+fdt(x.last)+"</td></tr>").join("")||"<tr><td colspan=5 style='color:var(--mut)'>ยังไม่มีผู้ใช้</td></tr>";
    $("erows").innerHTML=(ss.events_tail||[]).map(e=>"<tr><td>"+new Date(e.t).toLocaleTimeString("th-TH")+"</td><td><span class='tag'>"+e.ev+"</span></td><td>"+e.g+"</td><td class='mono'>@"+e.u+"</td><td>"+e.tag+"</td></tr>").join("")||"<tr><td colspan=5 style='color:var(--mut)'>ยังไม่มี</td></tr>";
  }catch(e){}
}
$("pw").addEventListener("keydown",e=>{if(e.key==="Enter")doLogin()});
load(); setInterval(()=>{if(K)load().catch(()=>{})},15000);
</script>`;
}

/* ------------------------------- router ----------------------------------- */

// secret admin prefix — deploy copy ฝังค่าไว้; repo ตัวเปล่าใช้ "" = admin อยู่ที่ /admin ตรงๆ (ยังต้อง ADMIN_KEY)
const ADMIN_BASE = (env) => env.ADMIN_PATH || "";
// หน้าขาว 404 เหมือนไม่มีอะไรอยู่เลย — คนนอกสแกนเจอแค่นี้
const fake404 = () => new Response(
  `<!DOCTYPE html><html><head><title>404 Not Found</title></head><body><center><h1>404 Not Found</h1></center><hr><center>cloudflare</center></body></html>`,
  { status: 404, headers: { "content-type": "text/html" } });

export default {
  async fetch(req, env) {
    try {
      const url = new URL(req.url);
      let p = url.pathname;
      if (req.method === "OPTIONS") return new Response(null, { headers: JSON_HEADERS });

      // ── public (สคริปต์เรียก — path ต้องคงเดิมเพราะฝังใน release artifact) ──
      if (p === "/status" && req.method === "GET") return routeStatus(url, env);
      if (p === "/ping" && req.method === "POST") return routePing(req, env);
      if (p === "/unlock" && req.method === "POST") return routeUnlock(req, env);

      // ── admin — อยู่ใต้ secret prefix เท่านั้น (ตั้ง ADMIN_PATH → /admin ตรงๆ = 404 นิ่ง) ──
      const AB = ADMIN_BASE(env);
      const isAdminZone = AB ? p.startsWith(AB + "/") : (p.startsWith("/admin") || p === "/stats");
      if (isAdminZone) {
        const ap = AB ? p.slice(AB.length) : p; // strip prefix → route เหมือนเดิม

        if (ap === "/admin" || ap === "/admin/")
          return new Response(adminHtml(AB), { headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-store", "referrer-policy": "no-referrer", "x-content-type-options": "nosniff" } });

        // auth: header x-admin-key หรือ ?key= — ผิด = นับ fail, เกิน 20/10นาที = 429
        if (!isAdmin(req, env)) {
          const ip = req.headers.get("cf-connecting-ip") || "?";
          const rl = await kvGet(env, "rl:a:" + ip, { n: 0, ts: 0 });
          if (rl.ts < Date.now() - 600e3) { rl.n = 0; rl.ts = Date.now(); }
          rl.n++; await kvPut(env, "rl:a:" + ip, rl);
          if (rl.n > 20) return new Response("slow down", { status: 429 });
          return new Response("forbidden", { status: 403 });
        }

        if (ap === "/admin/keygen" && req.method === "POST") return routeKeygen(req, env);
        if (ap === "/admin/key/new") return routeKeygen(req, env); // alias GET
        if (ap === "/admin/keys") return routeKeyList(env);
        if (ap === "/admin/key/manage" && req.method === "POST") return routeKeyManage(req, env);
        if (ap === "/admin/system" && req.method === "POST") return routeSystem(req, env);
        if (ap === "/admin/set") return routeSystem(req, env); // alias GET
        if (ap === "/admin/stats" || ap === "/stats") return routeStats(env);
        if (ap === "/admin/setpk") return routeSetpk(url, env);
        return fake404();
      }

      return fake404(); // ทุกอย่างอื่น = ขาวโล่ง เหมือนไม่มีอะไรเลย
    } catch (e) {
      console.log("FATAL " + (e && e.stack || e));
      return j({ ok: false, why: "server-error" }, 500);
    }
  },
};
