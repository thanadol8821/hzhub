/**
 * HZ HUB backend — Cloudflare Worker (telemetry + kill-switch + key server)
 * วางโค้ดนี้ลง editor ของ worker (dash.cloudflare.com → Workers → Edit) แล้ว Deploy
 *
 * Endpoints:
 *   GET  /status?g=<id>            → {on,msg,banned:[wm...]}     (สคริปต์เช็กทุก 60 วิ)
 *   POST /ping   {ev,g,tag,u,dn,uid,hw,place,x}                   (สถิติ)
 *   POST /unlock {k,hw,u,dn,uid,g,tag} → {ok,pk}|{ok:false,why}   (ปลดล็อกด้วยคีย์ที่สร้างบนเว็บ)
 *   GET  /stats?key=<ADMIN_KEY>    → JSON สรุป
 *   GET  /admin?key=<ADMIN_KEY>    → หน้าแดชบอร์ด (สถิติ + จัดการคีย์ + เปิด/ปิดระบบ)
 *   GET  /admin/set?key=..&g=all|<id>&on=1|0&msg=..              (kill-switch)
 *   GET  /admin/key/new?key=..&k=<คีย์>&note=..&bind=1           (สร้างคีย์ — เว้น k ว่าง = สุ่ม)
 *   GET  /admin/key/set?key=..&k=<คีย์>&st=on|off                (แบน/ปลดแบน)
 *   GET  /admin/key/del?key=..&k=<คีย์>                          (ลบ)
 *   GET  /admin/setpk?key=..&g=<id>&pk=<b64>                     (deploy.py อัปโหลด payload key)
 *
 * ตั้งค่า (Settings → Variables and Secrets):
 *   ADMIN_KEY — บังคับ: รหัสเข้าหลังบ้าน (ไม่ตั้ง = admin ปิดสนิท 403)
 *   STATS     — KV namespace binding (แนะนำมาก — เก็บคีย์+สถิติถาวร)
 *               ไม่ผูก = คีย์/สถิติอยู่ใน memory รีเซ็ตตอน cold start
 */

const enc = new TextEncoder();
const J = { "content-type": "application/json; charset=utf-8", "access-control-allow-origin": "*" };
const mem = {}; // fallback เมื่อไม่มี KV

const adminKey = (env) => env.ADMIN_KEY || "";
const isAdmin = (url, env) => adminKey(env) !== "" && url.searchParams.get("key") === adminKey(env);
const b64d = (s) => Uint8Array.from(atob(s), (c) => c.charCodeAt(0));

// ── wm = hmac(key,"hzv-id")[:8] hex — ตรงกับฝั่ง client เป๊ะ ──
async function wmOf(key) {
  const ck = await crypto.subtle.importKey("raw", enc.encode(key), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const sig = new Uint8Array(await crypto.subtle.sign("HMAC", ck, enc.encode("hzv-id")));
  return [...sig.slice(0, 8)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

// ── KV helpers (doc-based — เทสเตอร์ระดับนี้พอ) ──
async function kvGet(env, key, dflt) {
  const v = env.STATS ? await env.STATS.get(key, "json") : mem[key];
  return v && typeof v === "object" ? v : dflt;
}
async function kvPut(env, key, val) {
  if (env.STATS) await env.STATS.put(key, JSON.stringify(val));
  else mem[key] = val;
}
const getAgg = (env) => kvGet(env, "agg", { total: 0, users: {}, games: {}, events: [] });
const getKeys = (env) => kvGet(env, "keys", {});
const getPk = (env, g) => kvGet(env, "pk:" + g, null);

async function getStatus(env, g) {
  const d = { on: true, msg: "", banned: [] };
  const doc = await kvGet(env, "status", null);
  if (doc) {
    if (doc.global === false) d.on = false;
    if (g && doc.games && doc.games[g] === false) d.on = false;
    if (typeof doc.msg === "string") d.msg = doc.msg;
  }
  // คีย์ที่โดนแบน (ทั้งคีย์เว็บและแบนคีย์ฝังด้วย wm)
  const keys = await getKeys(env);
  for (const k in keys) if (keys[k].st === "off" && keys[k].wm) d.banned.push(keys[k].wm);
  return d;
}
async function setStatus(env, g, on, msg) {
  const doc = await kvGet(env, "status", {});
  doc.games = doc.games || {};
  if (g === "all") doc.global = !!on;
  else doc.games[g] = !!on;
  if (msg !== undefined) doc.msg = msg;
  await kvPut(env, "status", doc);
  return doc;
}

function thai(t) { return t ? new Date(t).toLocaleString("th-TH") : "-"; }
const esc = (s) => String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

async function adminPage(env, url) {
  const k = adminKey(env);
  const [agg, st, keys] = await Promise.all([getAgg(env), getStatus(env, null), getKeys(env)]);
  const users = Object.values(agg.users || {});
  const machines = new Set(); users.forEach((x) => Object.keys(x.hwSet || {}).forEach((h) => machines.add(h)));
  const kvNote = env.STATS ? "" : ' <b style="color:#f96">(KV ไม่ได้ผูก — คีย์/สถิติรีเซ็ตตอน cold start)</b>';

  const krows = Object.entries(keys).sort((a, b) => (b[1].at || 0) - (a[1].at || 0)).map(([key, r]) =>
    `<tr><td><code>${esc(key)}</code></td>
     <td style="color:${r.st === "off" ? "#f66" : "#6f6"}">${r.st === "off" ? "แบน" : "ใช้ได้"}</td>
     <td>${esc(r.note || "")}</td><td>${esc(r.u || "-")}</td><td>${r.uses || 0}</td>
     <td>${r.hw ? "ล็อก" : "-"}</td><td>${thai(r.last)}</td>
     <td><a class="b ${r.st === "off" ? "on" : "off"}" href="/admin/key/set?key=${k}&k=${encodeURIComponent(key)}&st=${r.st === "off" ? "on" : "off"}">${r.st === "off" ? "ปลดแบน" : "แบน"}</a>
     <a class="b off" href="/admin/key/del?key=${k}&k=${encodeURIComponent(key)}" onclick="return confirm('ลบ ${esc(key)}?')">ลบ</a></td></tr>`).join("");

  const urows = users.sort((a, b) => (b.last || 0) - (a.last || 0)).map((x) =>
    `<tr><td>@${esc(x.u)}</td><td>${esc(x.dn || "")}</td><td>${x.count || 0}</td><td>${Object.keys(x.hwSet || {}).length}</td><td>${thai(x.last)}</td></tr>`).join("");
  const evs = (agg.events || []).slice(-15).reverse().map((e) =>
    `<tr><td>${new Date(e.t).toLocaleTimeString("th-TH")}</td><td>${esc(e.ev)}</td><td>${esc(e.g)}</td><td>@${esc(e.u)}</td><td>${esc(e.tag)}</td></tr>`).join("");

  const html = `<!doctype html><meta charset="utf-8"><title>HZ HUB admin</title><style>
    body{font-family:system-ui;background:#14101c;color:#e8e4f2;padding:24px;max-width:960px;margin:auto}
    .c{background:#241d33;border:1px solid #443a5e;border-radius:12px;padding:16px;margin:12px 0}
    .b{display:inline-block;padding:8px 14px;border-radius:8px;text-decoration:none;font-weight:700;margin:2px;color:#fff;font-size:12px}
    .on{background:#2e7d5b}.off{background:#b33}
    button.b{border:0;cursor:pointer}
    table{width:100%;border-collapse:collapse;font-size:12px}td,th{padding:6px;border-bottom:1px solid #332a44;text-align:left}
    h1{font-size:22px}h2{font-size:15px;color:#b9aee0}.stat{font-size:28px;font-weight:800}
    input,select{padding:8px;border-radius:6px;border:1px solid #443a5e;background:#1a1526;color:#fff}
    code{background:#1a1526;padding:2px 6px;border-radius:4px}
  </style>
  <h1>HZ HUB — หลังบ้าน</h1>

  <div class="c"><h2>ระบบ (kill-switch)</h2>
    <p>สถานะ: <b style="color:${st.on ? "#6f6" : "#f66"}">${st.on ? "เปิด" : "ปิด"}</b> ${st.msg ? "· " + esc(st.msg) : ""}</p>
    <form onsubmit="location.href='/admin/set?key=${k}&g='+this.g.value+'&on='+this.on.value+'&msg='+encodeURIComponent(this.msg.value);return false">
      <select name="g"><option value="all">ทุกเกม</option><option value="valley">valley</option></select>
      <select name="on"><option value="1">เปิด</option><option value="0">ปิด (kill)</option></select>
      <input name="msg" placeholder="ข้อความถึงผู้ใช้" size="30">
      <button class="b on" type="submit">ตั้งค่า</button>
    </form></div>

  <div class="c"><h2>จัดการคีย์${kvNote}</h2>
    <form onsubmit="location.href='/admin/key/new?key=${k}&k='+encodeURIComponent(this.k.value)+'&note='+encodeURIComponent(this.note.value)+'&bind='+(this.bind.checked?1:0);return false">
      <input name="k" placeholder="คีย์ใหม่ (เว้นว่าง=สุ่ม HZV-xxxx)" size="22">
      <input name="note" placeholder="หมายเหตุ เช่น ชื่อเทสเตอร์" size="22">
      <label><input type="checkbox" name="bind"> ล็อกเครื่องแรกที่ใช้</label>
      <button class="b on" type="submit">+ สร้างคีย์</button>
    </form>
    <p style="font-size:12px;color:#8a80a0">คีย์ที่สร้างที่นี่ใช้ปลดล็อกผ่านเซิร์ฟเวอร์ (deploy ต้องอัปโหลด pk แล้ว) · คีย์ฝังในไฟล์ (123, HZV-...) ใส่ในนี้แล้ว "แบน" = ตัดการใช้งานคีย์นั้นทุกเครื่อง</p>
    <table><tr><th>คีย์</th><th>สถานะ</th><th>หมายเหตุ</th><th>ผู้ใช้ล่าสุด</th><th>ครั้ง</th><th>เครื่อง</th><th>ใช้ล่าสุด</th><th></th></tr>
    ${krows || "<tr><td colspan=8>ยังไม่มีคีย์บนเว็บ — คีย์ฝังใน build ยังใช้ได้ปกติ</td></tr>"}</table></div>

  <div class="c"><h2>สถิติ</h2>
    <span class="stat">${agg.total || 0}</span> ping · <span class="stat">${users.length}</span> คน · <span class="stat">${machines.size}</span> เครื่อง
    <p style="font-size:12px">${Object.entries(agg.games || {}).map(([g, n]) => g + ": " + n).join(" · ")}</p></div>

  <div class="c"><h2>ผู้ใช้ล่าสุด</h2><table><tr><th>ผู้เล่น</th><th>ชื่อแสดง</th><th>ครั้ง</th><th>เครื่อง</th><th>ล่าสุด</th></tr>${urows || "<tr><td colspan=5>ยังไม่มี</td></tr>"}</table></div>
  <div class="c"><h2>เหตุการณ์ล่าสุด</h2><table><tr><th>เวลา</th><th>ev</th><th>เกม</th><th>ผู้เล่น</th><th>เวอร์ชัน</th></tr>${evs || "<tr><td colspan=5>ยังไม่มี</td></tr>"}</table></div>`;
  return new Response(html, { headers: { "content-type": "text/html; charset=utf-8" } });
}

export default {
  async fetch(req, env) {
    const url = new URL(req.url);

    if (url.pathname === "/status")
      return new Response(JSON.stringify(await getStatus(env, url.searchParams.get("g"))), { headers: J });

    if (url.pathname === "/ping" && req.method === "POST") {
      let b = {}; try { b = await req.json(); } catch {}
      const g = b.g || "?", u = b.u || "?", hw = String(b.hw || "?");
      console.log(`PING ${b.ev || "ev"} | g=${g} tag=${b.tag || ""} | @${u} uid=${b.uid || ""} hw=${hw.slice(0, 12)} place=${b.place || 0}`);
      const agg = await getAgg(env);
      agg.total = (agg.total || 0) + 1;
      agg.games[g] = (agg.games[g] || 0) + 1;
      const ukey = String(b.uid || u);
      const cur = agg.users[ukey] || { u, dn: b.dn || "", first: Date.now(), count: 0, hwSet: {} };
      cur.u = u; cur.dn = b.dn || cur.dn; cur.last = Date.now(); cur.count = (cur.count || 0) + 1;
      cur.hwSet = cur.hwSet || {}; cur.hwSet[hw.slice(0, 16)] = true;
      agg.users[ukey] = cur;
      agg.events = agg.events || [];
      agg.events.push({ t: Date.now(), ev: b.ev || "", g, u, tag: b.tag || "" });
      if (agg.events.length > 100) agg.events = agg.events.slice(-100);
      await kvPut(env, "agg", agg);
      return new Response(JSON.stringify({ ok: true }), { headers: J });
    }

    if (url.pathname === "/unlock" && req.method === "POST") {
      let b = {}; try { b = await req.json(); } catch {}
      const key = String(b.k || ""), hw = String(b.hw || ""), g = String(b.g || "");
      const keys = await getKeys(env);
      const rec = keys[key];
      if (!rec) return new Response(JSON.stringify({ ok: false, why: "no-key" }), { headers: J });
      if (rec.st === "off") return new Response(JSON.stringify({ ok: false, why: "banned" }), { headers: J });
      if (rec.exp && Date.now() > rec.exp) return new Response(JSON.stringify({ ok: false, why: "expired" }), { headers: J });
      if (rec.hw && rec.hw !== hw) return new Response(JSON.stringify({ ok: false, why: "bound" }), { headers: J });
      const pk = await getPk(env, g);
      if (!pk || !pk.pk) return new Response(JSON.stringify({ ok: false, why: "no-pk" }), { headers: J });
      if (!rec.hw) rec.hw = hw;
      rec.uses = (rec.uses || 0) + 1; rec.last = Date.now(); rec.u = b.u || ""; rec.uid = b.uid || 0;
      keys[key] = rec; await kvPut(env, "keys", keys);
      console.log(`UNLOCK ok g=${g} @${b.u} key=${key.slice(0, 8)}… wm=${rec.wm || ""}`);
      return new Response(JSON.stringify({ ok: true, pk: pk.pk }), { headers: J });
    }

    if (url.pathname === "/stats") {
      if (!isAdmin(url, env)) return new Response("forbidden", { status: 403 });
      const agg = await getAgg(env);
      const users = Object.values(agg.users || {});
      const machines = new Set(); users.forEach((x) => Object.keys(x.hwSet || {}).forEach((h) => machines.add(h)));
      return new Response(JSON.stringify({
        total_pings: agg.total || 0, unique_users: users.length, unique_machines: machines.size,
        games: agg.games || {}, users: users.map((x) => ({ u: x.u, dn: x.dn, count: x.count, machines: Object.keys(x.hwSet || {}).length, last: x.last })),
        events_tail: (agg.events || []).slice(-20).reverse(), status: await getStatus(env, null), kv: !!env.STATS,
      }, null, 2), { headers: J });
    }

    if (url.pathname === "/admin/set") {
      if (!isAdmin(url, env)) return new Response("forbidden", { status: 403 });
      const doc = await setStatus(env, url.searchParams.get("g") || "all",
        url.searchParams.get("on") !== "0", url.searchParams.get("msg") || undefined);
      return new Response(JSON.stringify({ ok: true, status: doc }), { headers: J });
    }

    if (url.pathname === "/admin/key/new") {
      if (!isAdmin(url, env)) return new Response("forbidden", { status: 403 });
      let k = url.searchParams.get("k") || "";
      if (!k) k = "HZV-" + crypto.randomUUID().replace(/-/g, "").slice(0, 6).toUpperCase() + "-" + crypto.randomUUID().replace(/-/g, "").slice(0, 6).toUpperCase();
      const keys = await getKeys(env);
      keys[k] = { st: "on", note: url.searchParams.get("note") || "", bind: url.searchParams.get("bind") === "1", wm: await wmOf(k), at: Date.now(), uses: 0 };
      await kvPut(env, "keys", keys);
      console.log(`KEY new ${k} note=${keys[k].note}`);
      return new Response(JSON.stringify({ ok: true, key: k, wm: keys[k].wm }), { headers: J });
    }

    if (url.pathname === "/admin/key/set") {
      if (!isAdmin(url, env)) return new Response("forbidden", { status: 403 });
      const k = url.searchParams.get("k") || "";
      const keys = await getKeys(env);
      if (!keys[k]) { // แบนคีย์ฝัง: สร้าง record ที่มีแค่ wm+st=off
        if (url.searchParams.get("st") === "off") keys[k] = { st: "off", note: "ban baked", wm: await wmOf(k), at: Date.now(), uses: 0 };
        else return new Response(JSON.stringify({ ok: false, why: "no-key" }), { headers: J });
      } else keys[k].st = url.searchParams.get("st") === "off" ? "off" : "on";
      await kvPut(env, "keys", keys);
      return new Response(JSON.stringify({ ok: true, key: k, st: keys[k].st }), { headers: J });
    }

    if (url.pathname === "/admin/key/del") {
      if (!isAdmin(url, env)) return new Response("forbidden", { status: 403 });
      const keys = await getKeys(env);
      delete keys[url.searchParams.get("k") || ""];
      await kvPut(env, "keys", keys);
      return new Response(JSON.stringify({ ok: true }), { headers: J });
    }

    if (url.pathname === "/admin/setpk") {
      if (!isAdmin(url, env)) return new Response("forbidden", { status: 403 });
      const g = url.searchParams.get("g") || "", pk = url.searchParams.get("pk") || "";
      try { if (b64d(pk).length !== 32) return new Response(JSON.stringify({ ok: false, why: "bad-pk" }), { headers: J }); }
      catch { return new Response(JSON.stringify({ ok: false, why: "bad-pk" }), { headers: J }); }
      await kvPut(env, "pk:" + g, { pk, at: Date.now() });
      console.log(`SETPK g=${g}`);
      return new Response(JSON.stringify({ ok: true, g }), { headers: J });
    }

    if (url.pathname === "/admin") {
      if (!isAdmin(url, env)) return new Response("forbidden", { status: 403 });
      return adminPage(env, url);
    }

    return new Response("HZ HUB backend ok — /status /ping /unlock | admin ต้องมี ADMIN_KEY (Settings→Variables)", { headers: J });
  },
};
