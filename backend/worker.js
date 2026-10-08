/**
 * HZ HUB backend — Cloudflare Worker
 * แพสต์โค้ดนี้ลงใน editor ของ worker (dash.cloudflare.com → Workers → dry-wave-054e → Edit)
 *
 * Endpoints:
 *   GET  /status?g=<id>            → {"on":true|false,"msg":"..."}   (สคริปต์เช็กทุก 60 วิ)
 *   POST /ping   {ev,g,tag,u,dn,uid,hw,place,x}                      (สคริปต์ยิงตอนเข้า/ปลดคีย์)
 *   GET  /stats?key=<ADMIN_KEY>    → JSON สรุป (คน/เครื่อง/เกม/ล่าสุด)
 *   GET  /admin?key=<ADMIN_KEY>    → หน้าแดชบอร์ด: สถิติ + ปุ่มเปิด/ปิดระบบ
 *   GET  /admin/set?key=...&g=all|<id>&on=1|0&msg=...  → สลับสถานะ (kill-switch)
 *
 * ตั้งค่า:
 *   ADMIN_KEY — Worker → Settings → Variables → ตั้งเอง (ค่าเริ่มต้น "hz-admin-123" เปลี่ยนเถอะ)
 *   STATS     — KV namespace binding (ไม่ผูกก็ทำงานได้: สถิติอยู่ในหน่วยความจำ+logs)
 */

const ADMIN_FALLBACK = "hz-admin-123"; // ← ตั้ง ADMIN_KEY ใน Worker Variables แล้วเปลี่ยนอันนี้ด้วยก็ได้

// สถิติใน-memory (fallback เมื่อไม่มี KV) — รีเซ็ตตอน cold start
const mem = { agg: null };

async function getAgg(env) {
  if (env.STATS) {
    const v = await env.STATS.get("agg", "json");
    return v && typeof v === "object" ? v : { total: 0, users: {}, games: {}, events: [] };
  }
  return mem.agg || { total: 0, users: {}, games: {}, events: [] };
}
async function putAgg(env, agg) {
  if (env.STATS) await env.STATS.put("agg", JSON.stringify(agg));
  else mem.agg = agg;
}

async function getStatus(env, g) {
  const d = { on: true, msg: "" };
  let doc = null;
  if (env.STATS) doc = await env.STATS.get("status", "json");
  else doc = mem.status;
  if (doc && typeof doc === "object") {
    if (doc.global === false) d.on = false;
    if (g && doc.games && doc.games[g] === false) d.on = false;
    if (typeof doc.msg === "string") d.msg = doc.msg;
  }
  return d;
}
async function setStatus(env, g, on, msg) {
  let doc = (env.STATS ? await env.STATS.get("status", "json") : mem.status) || {};
  if (typeof doc !== "object") doc = {};
  doc.games = doc.games || {};
  if (g === "all") doc.global = !!on;
  else doc.games[g] = !!on;
  if (msg !== undefined) doc.msg = msg;
  if (env.STATS) await env.STATS.put("status", JSON.stringify(doc));
  else mem.status = doc;
  return doc;
}

function adminKey(env) { return env.ADMIN_KEY || ADMIN_FALLBACK; }
function isAdmin(url, env) { return url.searchParams.get("key") === adminKey(env); }

const J = { "content-type": "application/json; charset=utf-8", "access-control-allow-origin": "*" };

export default {
  async fetch(req, env) {
    const url = new URL(req.url);

    if (url.pathname === "/status") {
      const d = await getStatus(env, url.searchParams.get("g"));
      return new Response(JSON.stringify(d), { headers: J });
    }

    if (url.pathname === "/ping" && req.method === "POST") {
      let b = {};
      try { b = await req.json(); } catch {}
      const g = b.g || "?", u = b.u || "?", hw = b.hw || "?";
      console.log(`PING ${b.ev || "ev"} | g=${g} tag=${b.tag || ""} | @${u} (${b.dn || ""}) uid=${b.uid || ""} hw=${String(hw).slice(0, 12)} place=${b.place || 0}`);
      const agg = await getAgg(env);
      agg.total = (agg.total || 0) + 1;
      agg.games[g] = (agg.games[g] || 0) + 1;
      const ukey = String(b.uid || u);
      const cur = agg.users[ukey] || { u, dn: b.dn || "", first: Date.now(), count: 0, hwSet: {} };
      cur.u = u; cur.dn = b.dn || cur.dn; cur.last = Date.now(); cur.count = (cur.count || 0) + 1;
      cur.hwSet = cur.hwSet || {}; cur.hwSet[String(hw).slice(0, 16)] = true;
      agg.users[ukey] = cur;
      agg.events = agg.events || [];
      agg.events.push({ t: Date.now(), ev: b.ev || "", g, u, tag: b.tag || "" });
      if (agg.events.length > 100) agg.events = agg.events.slice(-100);
      await putAgg(env, agg);
      return new Response(JSON.stringify({ ok: true }), { headers: J });
    }

    if (url.pathname === "/stats") {
      if (!isAdmin(url, env)) return new Response("forbidden", { status: 403 });
      const agg = await getAgg(env);
      const users = Object.values(agg.users || {});
      const machines = new Set(); users.forEach(x => Object.keys(x.hwSet || {}).forEach(h => machines.add(h)));
      const summary = {
        total_pings: agg.total || 0,
        unique_users: users.length,
        unique_machines: machines.size,
        games: agg.games || {},
        users: users.map(x => ({ u: x.u, dn: x.dn, count: x.count, machines: Object.keys(x.hwSet || {}).length, last: x.last })),
        events_tail: (agg.events || []).slice(-20).reverse(),
        status: await getStatus(env, null),
        kv: !!env.STATS,
      };
      return new Response(JSON.stringify(summary, null, 2), { headers: J });
    }

    if (url.pathname === "/admin/set") {
      if (!isAdmin(url, env)) return new Response("forbidden", { status: 403 });
      const g = url.searchParams.get("g") || "all";
      const on = url.searchParams.get("on") !== "0";
      const msg = url.searchParams.get("msg");
      const doc = await setStatus(env, g, on, msg);
      console.log(`ADMIN set g=${g} on=${on} msg=${msg || ""}`);
      return new Response(JSON.stringify({ ok: true, status: doc }), { headers: J });
    }

    if (url.pathname === "/admin") {
      if (!isAdmin(url, env)) return new Response("forbidden", { status: 403 });
      const agg = await getAgg(env);
      const st = await getStatus(env, null);
      const users = Object.values(agg.users || {});
      const machines = new Set(); users.forEach(x => Object.keys(x.hwSet || {}).forEach(h => machines.add(h)));
      const k = adminKey(env);
      const rows = users.sort((a, b) => (b.last || 0) - (a.last || 0)).map(x =>
        `<tr><td>@${x.u}</td><td>${x.dn || ""}</td><td>${x.count || 0}</td><td>${Object.keys(x.hwSet || {}).length}</td><td>${x.last ? new Date(x.last).toLocaleString("th-TH") : "-"}</td></tr>`).join("");
      const evs = (agg.events || []).slice(-15).reverse().map(e =>
        `<tr><td>${new Date(e.t).toLocaleTimeString("th-TH")}</td><td>${e.ev}</td><td>${e.g}</td><td>@${e.u}</td><td>${e.tag}</td></tr>`).join("");
      const html = `<!doctype html><meta charset="utf-8"><title>HZ HUB admin</title><style>
        body{font-family:system-ui;background:#14101c;color:#e8e4f2;padding:24px;max-width:900px;margin:auto}
        .c{background:#241d33;border:1px solid #443a5e;border-radius:12px;padding:16px;margin:12px 0}
        .b{display:inline-block;padding:10px 18px;border-radius:8px;text-decoration:none;font-weight:700;margin:4px}
        .on{background:#2e7d5b;color:#fff}.off{background:#b33;color:#fff}
        table{width:100%;border-collapse:collapse;font-size:13px}td,th{padding:6px;border-bottom:1px solid #332a44;text-align:left}
        h1{font-size:22px}h2{font-size:15px;color:#b9aee0}.stat{font-size:28px;font-weight:800}
        input{padding:8px;border-radius:6px;border:1px solid #443a5e;background:#1a1526;color:#fff;width:260px}
      </style>
      <h1>HZ HUB — หลังบ้าน</h1>
      <div class="c"><h2>สถานะระบบ</h2>
        <p>ตอนนี้: <b style="color:${st.on ? "#6f6" : "#f66"}">${st.on ? "เปิดอยู่" : "ปิดอยู่"}</b> ${st.msg ? "· " + st.msg : ""}</p>
        <form onsubmit="location.href='/admin/set?key=${k}&g=all&on='+this.on.value+'&msg='+encodeURIComponent(this.msg.value);return false">
          <select name="on"><option value="1">เปิด</option><option value="0">ปิด (kill)</option></select>
          <input name="msg" placeholder="ข้อความบอกผู้ใช้ เช่น กำลังอัปเดต v3">
          <button class="b on" type="submit">ตั้งค่า</button>
        </form>
        <p style="font-size:12px;color:#8a80a0">ปิดต่อเกม: /admin/set?key=${k}&g=<ไอดีเกม>&on=0 (id ดูใน deploy.json)</p>
      </div>
      <div class="c"><h2>สถิติ${env.STATS ? "" : " (KV ไม่ได้ผูก — ค่ารีเซ็ตตอน cold start)"}</h2>
        <span class="stat">${agg.total || 0}</span> ping · <span class="stat">${users.length}</span> คน · <span class="stat">${machines.size}</span> เครื่อง
        <p style="font-size:12px">${Object.entries(agg.games || {}).map(([g, n]) => g + ": " + n).join(" · ")}</p>
      </div>
      <div class="c"><h2>ผู้ใช้ล่าสุด</h2><table><tr><th>ผู้เล่น</th><th>ชื่อแสดง</th><th>ครั้ง</th><th>เครื่อง</th><th>ล่าสุด</th></tr>${rows || "<tr><td colspan=5>ยังไม่มี</td></tr>"}</table></div>
      <div class="c"><h2>เหตุการณ์ล่าสุด</h2><table><tr><th>เวลา</th><th>ev</th><th>เกม</th><th>ผู้เล่น</th><th>เวอร์ชัน</th></tr>${evs || "<tr><td colspan=5>ยังไม่มี</td></tr>"}</table></div>`;
      return new Response(html, { headers: { "content-type": "text/html; charset=utf-8" } });
    }

    return new Response("HZ HUB backend ok — /status /ping /stats /admin", { headers: J });
  },
};
