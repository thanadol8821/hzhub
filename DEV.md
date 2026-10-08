# HZ HUB — เอกสาร dev หลัก (อ่านไฟล์นี้ก่อน ไฟล์เดียวจบ)

โปรเจกต์บอทอัตโนมัติ Roblox — โครง reusable รองรับหลายแมพ คีย์ชุดเดียวใช้ได้ทุกเกม
repo: `https://github.com/thanadol8821/hzhub` (**public** — เทสเตอร์ loadstring ผ่าน raw URL ได้)

---

## 1. ภาพรวมสถาปัตยกรรม

```
┌─ เทสเตอร์ ──────────────────────────────────────────┐
│  releases/hz_<id>.lua — ไฟล์เดียวต่อเกม เข้ารหัสเต็ม │
│  หน้าคีย์เด้ง → ใส่ 123 → ฮับเปิด (คีย์เดียวทุกเกม)  │
└──────────────────────────────────────────────────────┘
                ▲ deploy.py build+push
┌─ โฟลเดอร์นี้ (repo root) ────────────────────────────┐
│  deploy.json  — registry เกม + คีย์กลาง + policy     │
│  deploy.py    — pipeline: build→sync→commit→push     │
│  ดีพอย.cmd    — wrapper ดับเบิลคลิก                   │
│  releases/    — artifact ที่ push (push เท่านั้นที่ public)│
│  README.md    — คู่มือเทสเตอร์                        │
│  DEV.md       — ไฟล์นี้                               │
│  hz_valley.lua— source dev (gitignore, ไม่ push)     │
│  dump/ watch/ — เครื่องมือ dev (gitignore)           │
└──────────────────────────────────────────────────────┘
                ▲ ใช้ framework เดียวกัน
┌─ ../Ui/Ux/ (แชร์ทุกเกม — แยก repo ไม่ push) ─────────┐
│  FishUI/ — UI lib (window/widgets/nav/keyscreen/...) │
│  Core/   — game utils (char/net/loop/store/safety)   │
│  Guard/  — key/crypto/env/integrity/session/backend  │
│  Games/  — registry + _template สำหรับแมพใหม่        │
│  tools/  — build.py release.py check.py test/run.py  │
│  dist/   — single-file builds                        │
└──────────────────────────────────────────────────────┘
                ▲ runtime
┌─ %LOCALAPPDATA%/Xeno/workspace/ ─────────────────────┐
│  hz_valley.lua      dev script (autoexec dev)        │
│  hz_valley_test.lua artifact ล่าสุด (deploy ซิงก์มา) │
│  FishUI/*.lua       โมดูลที่ dev script โหลดผ่าน readfile│
│  hz_valley_log.txt / hz_valley_status.txt / hz_gate_log.txt │
└──────────────────────────────────────────────────────┘
```

---

## 2. ระบบคีย์ — คีย์เดียวทุกแมพ

- คีย์เทสอยู่ใน `deploy.json → keys` (ตอนนี้ `123` + HZV×3)
- release.py ฝังคีย์ wrapped เข้า artifact ทุกตัว → เทสเตอร์ใส่คีย์เดียวกันได้ทุกเกม
- `keyMode`: `always` ถามทุกครั้ง / `fill` เติมให้ / `auto` จำ+ผ่านเลย
- `blockOn`: `never`=ปิด env-check (เทสต้องตัวนี้ — executor ทำให้ env เด้งเตือนเอง) | `high`=บล็อกเครื่องมือดักจับจริง (ขาย)
- logout → เคลียร์คีย์จำ → เด้งกลับหน้าคีย์ (release) / reload สคริปต์ (dev)

---

## 3. ไปป์ไลน์ดีพอย (`deploy.py`)

```bash
py deploy.py               # tag อัตโนมัติ v<yymmdd-HHMM> → build ทุก enabled → commit+push
py deploy.py "v2.7"        # tag เอง
py deploy.py --only valley # เกมเดียว
py deploy.py --no-push     # build+commit ไม่ push
```

ทำอะไรบ้างต่อเกม:
1. `release.py` wrap `src` → `releases/hz_<id>.lua` (เข้ารหัส+key gate+FishUI ฝังครบ)
2. copy → `%XENO_WS%/hz_<id>_test.lua` (autoexec โหลดชื่อนี้)
3. อัปเดตตาราง `<!--FILES-->` ใน README อัตโนมัติ
4. `git add+commit` (ข้ามถ้าไม่มีอะไรเปลี่ยน) → `pull --rebase` → `push`

`deploy.json` schema:
```json
{
  "keys": ["123","HZV-..."],   // คีย์เทส — ฝังทุกเกม
  "keyMode": "auto",           // always|fill|auto
  "blockOn": "never",          // low|medium|high|never
  "outDir": "releases",
  "games": [{
    "id": "valley",            // → releases/hz_valley.lua + hz_valley_test.lua ใน ws
    "name": "Chicken or Hero",
    "placeId": 107535308163741,
    "src": "hz_valley.lua",    // path สัมพัทธ์โฟลเดอร์นี้ หรือ "%XENO_WS%/x.lua"
    "enabled": true            // false = ข้าม (ยังไม่พร้อม)
  }]
}
```

เกมที่ลงทะเบียนแล้ว: `valley` (เปิด) · `dice` `ubg` `warz` `mart` (`enabled:false` — src ชี้ไป `%XENO_WS%/hz_*.lua` ที่มีอยู่จริง เปิดได้ทุกเมื่อ)

## เพิ่มแมพใหม่

1. เขียนสคริปต์ใหม่ (ใช้ FishUI เหมือนเดิม — ดู `Ui/Ux/Games/_template/` + `hz_valley.lua` เป็นตัวอย่าง)
2. เพิ่ม entry `{"id":"<id>","name":"...","placeId":<id>,"src":"<ไฟล์>.lua","enabled":true}` ใน `deploy.json`
3. กด `ดีพอย.cmd` — จบ (คีย์เดิมเปิดได้ทันที)

## วิธีส่งให้เทสเตอร์

repo **public** แล้ว — เทสเตอร์รันบรรทัดเดียวจบ (ไม่ต้องโหลดไฟล์):
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/thanadol8821/hzhub/main/releases/hz_valley.lua"))()
```
เปลี่ยนชื่อไฟล์ตามแมพ `releases/hz_<id>.lua` — คีย์ `123` ใช้ได้ทุกตัว
(สำรอง: ส่งไฟล์ตรง → `loadstring(readfile("hz_<id>.lua"))()`)

---

## 4. ระบบใน `hz_valley.lua` (สคริปต์หลัก ~1950 บรรทัด)

| ระบบ | หลักการ |
|---|---|
| Runner AI | autopilot loop — เดินทางเข้า safe zone, dash+ปล่อยสกิลตอนเหยี่ยวใกล้ |
| Catcher AI | เลือกเหยื่อใกล้สุด → chase → tackle → melee → BearTrap → ยืนยัน |
| GOD dodge | Heartbeat 0ms อ่าน attr telegraph ของ catcher → หลบทัน windup |
| RescueKit | โดนจับ → ชุบตัวเอง → กลับ Active ต่อ |
| ESP | Highlight + Billboard ชื่อ/ระยะ (AlwaysOnTop) parent เข้า char ตรง — แดง=ไล่/น้ำเงิน=หนี — per-player pcall + respawn-guard |
| Auto-claim/vote/hero/gear | remote fire ตอนจบแมตช์ + equip เกียร์ตาม tier (buy cooldown 45s/ไอเทมกัน spam) |
| Config | `hz_valley_cfg.json` (state เกม) + `FishUI/hz_valley.json` (ธีม/keybind — FishUI autosave) |
| Log | buffer → `writefile` flush ทุก 1.5s → `hz_valley_log.txt` |
| Guard | `guard("name",fn)` ห่อ loop/handler ทั้งหมด (21 จุด) — error → log ไม่ฆ่า thread |

ปุ่ม: `RightShift` เมนู · `RightAlt` keybinds · `M/K/Del` เมนู/ปิดด่วน/ปิดถาวร

## 5. FishUI สำหรับ dev/AI ใหม่

```lua
local FishUI = loadstring(readfile("FishUI.lua"))()   -- หรือ dist/FishUI.lua
local win = FishUI.Window{title="HZ HUB", w=740,h=560, toggleKey=Enum.KeyCode.RightShift,
    onLogout=function() ... end}
win:Config("name")                        -- autosave ธีม/opacity/toggleKey ลง FishUI/name.json
local pg = win:Page("ภาพรวม","monitor")   -- icon จาก icons.lua (ไม่ใช่อิโมจิ)
local sub = pg:Sub("สถานะ")
local gb = sub:Groupbox("กล่อง","Left")   -- Left|Right
gb:Toggle{label="..",tip="..",key=Enum.KeyCode.X,default=false,cb=function(v) end}
gb:Slider{label="..",min,max,step,suffix,default,cb}
gb:Dropdown{label,options,default,cb}
gb:Input{label,placeholder,cb}            -- cb(text,enterPressed)
gb:Button{label,danger,hold,cb}           -- danger=true = กดค้างจน fuse เต็ม
gb:Label("ข้อความ <b>rich</b>")  gb:Divider()
win:Notify{title,text,dur}
win:Destroy()  win:Logout()  win:SetTheme(i)  win:SetOpacity(0-40)
```

เสียง: `sfx("click"|"tick"|"open"|"ok"|"bad"|"noti")` — builtin rbxasset ครบทุก handler แล้ว
ปรับเสียง: `D.sndVol` (ผูกกับ setup.json → SoundVolume แล้ว)

## 6. Quirks ของ Xeno (สำคัญ — AI/dev ต้องรู้)

| อาการ | ความจริง |
|---|---|
| `appendfile` มีแต่เขียนไม่ลง | ใช้ `writefile` + buffer เท่านั้น |
| `ctl eval`/jobs ส่งได้แต่ writefile/print เงียบ | ดูผลผ่านไฟล์ log ของสคริปต์เอง |
| autoexec ยิงเฉพาะ Xeno.exe (GUI) | daemon ล้วนไม่ยิง — เปิด GUI ไว้ |
| client เด้งเป็นบางครั้ง | engine "cannot keep up" — ไม่ใช่บั๊กสคริปต์ รีจอยใหม่ |

## 7. เทส

```bash
cd Ui/Ux && py tools/test/run.py    # mock luau — ต้อง 11/11 ผ่าน
```

ครอบ: core loop/net/store/single/safety · FishUI behavior+smoke · guard crypto+session+loader · hub example · valley UI · release gate · **logout→keyscreen regression** · valley full (init→window→เพจ→controls→KILL)

## 8. ไฟล์ log/สถานะ (ใน workspace)

| ไฟล์ | เนื้อ |
|---|---|
| `hz_valley_log.txt` | event เกมทั้งหมด (buffered) |
| `hz_valley_status.txt` | autoexec heartbeat `OK|เวลา|place` หรือ ERROR |
| `hz_gate_log.txt` | หน้าคีย์ release (env findings/unlock/logout) |
| `hz_loader_log.txt` | loader multi-game (ถ้าใช้) |
| `FishUI/setup.json` | เสียง/ธีม/จำคีย์ ของหน้าคีย์ |
| `FishUI/key.txt` | คีย์จำ (dev) |

## 9. ของที่ยังไม่ทำ/ข้อจำกัด

- ~~แบ็กเอนด์จริงยังไม่มี~~ — **ทำแล้ว** ดู §11 (worker v2.2.1 + hz_system แยกโฟลเดอร์): คีย์เว็บ/kill-switch/telemetry/autoban/snapshot ครบ
- `blockOn:"never"` ตอนนี้ตั้งใจให้เทสเตอร์เข้าได้ทุก executor — ถ้าขายจริง/กันดั้มหนักเปลี่ยนเป็น `"high"` ใน `hz_system/deploy/deploy.json` แล้ว deploy ใหม่
- คนที่มีคีย์จริงยัง dump payload จากหน่วยความจำได้ (เพดานฝั่ง client ของทุกสคริปต์) — กันทางอ้อมด้วย wm ตามล่า + แบนคีย์รั่ว + anti-share autoban
- เกม dice/ubg/warz/mart ยังใช้ UI ตัวเอง (ไม่ใช่ FishUI) — ถ้าจะย้ายเข้าระบบเดียวกันต้องเขียนใหม่ผ่าน `Games/_template/`

## 10. เวิร์กโฟลว์มาตรฐานทุกครั้งที่แก้

```
แก้ FishUI/* หรือ hz_valley.lua
  → py tools/build.py                  (อัปเดต dist)
  → cp FishUI/* "$XENO_WS/FishUI/"     (sync ให้ dev script)
  → py tools/test/run.py               (ต้อง 11/11)
  → py deploy.py                       (build release+push repo+sync ws)
  → เทสในเกมจริง (watch/เทส.cmd)
```

## 11. Backend — Cloudflare Worker (ระบบคีย์ + telemetry + kill-switch)

> **ระบบนี้อยู่นอก repo แล้ว** — อ่าน `../hz_system/README.md` ก่อน (master handbook: deploy flow, registry, secrets, recovery)

**URL:** `https://dry-wave-054e.thanadol821.workers.dev` (account: thanadol821)
**หลังบ้าน:** `https://<worker>/<ADMIN_PATH>/admin` (ค่าจริงใน `hz_system/secrets/`) — admin path ลับอยู่ใน env `ADMIN_PATH` บน CF (ไม่มีใน repo ใดๆ) + หน้า SSR รับ `?key=` ตรงๆ (ฟอร์ม login = GET ธรรมดา ไม่พึ่ง JS/storage) — ทุก path อื่น = fake 404 ขาว
**Source:** `../hz_system/backend/worker.js` **v2.2.1** (นอก repo, สะอาด) → ตัว deploy จริง `../hz_system/secrets/worker_deploy.js` (local-only, ฝัง ADMIN_KEY/ADMIN_PATH/AUDIT_KEY/HMAC_SECRET fallback)
**กำกับ release ตั้งแต่:** v261008-keysys เป็นต้นไป — boot ฝัง `API` URL + status-watch + serverUnlock

### 11.1 สถาปัตยกรรม

```
client (release_boot.lua)                     worker.js                       KV namespace "hzhub"
─────────────────────────                     ──────────                      ─────────────────────
start → GET /status?g&id&hw ────────────────► buildStatus() ────────────────► "status" + "keys".st + "banned" + "autoban"
      ← {on,msg,banned:[wm…]}                                                  (banned = wm ของคีย์ off/autoban; until→เปิดเอง)
      off → หน้า "ปิดปรับปรุง" + re-check ทุก 60วิ
      on  → ping("gate") ──────POST /ping──► agg/users/events ─────────────► "agg" doc
keyscreen → unwrap(key):
      ├── คีย์ฝัง → unwrap local (wraps)  — offline ได้
      └── ไม่ผ่าน → POST /unlock {k,hw…} ─► ตรวจ keys/rl/pk ────────────────► "keys" + "pk:<g>" + "rl:<ip>"
                  ← {ok,pk} → ตรวจ hmac(pk,salt..ct)==tag → decrypt payload → run
watch loop 60วิ → status off → killRuntime() + หน้าบำรุงรักษา / on → หายเอง

client pings ที่ส่งขึ้น /ping (ev, tag=build|wm → หลังบ้านเห็นจากคีย์ไหน):
  gate · unlock · loaded (funnel) · win:<map> · lost:<map> · kill:<kind> · perfect ·
  warn / warn:staff (fair-play ของเกม) · err:<ระบบ> · alive (ทุก 4นาทีในแมตช์) · role:<role>
  throttle ฝั่ง client: ≥2s/ครั้ง · ≤45/10นาที (worker cap 60) — เกินโควตาตกเงียบ
unlock ตอบ why → หน้าคีย์แปลเป็นภาษาอ่านง่าย: banned→"ถูกระงับ" expired→"หมดอายุ"
  bound/no-hw→"ผูกเครื่องอื่น" rate→"เร็วเกิน" no-pk/kv-down→"เน็ต" (ไม่นับเดา)
```

### 11.2 KV schema (namespace `hzhub`, binding `STATS`)

| doc key | เนื้อ | เจ้าของ (ใครเขียนได้) |
|---|---|---|
| `keys` | `{<key>:{st:"on"\|"off",bind,maxHw,note,wm,at,exp}}` | **admin เท่านั้น** (keygen/manage/หน้าแอดมิน) |
| `usage` | `{<key>:{uses,last,u,uid,hws:[…],hw,seen:{hw:t},flag?}}` (hws = เครื่องที่ผูก ≤ maxHw; seen = เครื่องที่เคยใช้ใน window) | **unlock เท่านั้น** (นับครั้ง + ผูกเครื่อง + จับแชร์) |
| `banned` | `{<key>:{wm,hw}}` index สำรองของ st=off | admin เท่านั้น |
| `autoban` | `{<key>:{wm,hws,t,n,reason}}` คีย์ที่ออโต้แบน (แชร์เกิน limit) | unlock (เพิ่ม) / admin-auto (ปลด) |
| `auto` | `{shareLimit,shareHours,shareAction:"flag"\|"ban",purgeExpiredDays,dailySnapshot}` การตั้งค่าออโต้ | admin (auto cfg) |
| `autostate` | `{last,actions:[…]}` ผลรันออโต้ล่าสุด | auto job |
| `snap:<iso>` | `{at,version,keys,usage,banned,status,autoban}` snapshot รายวัน (เก็บ ≤7 ชุด) | auto job |
| `alog` | `{items:[{t,who,act,target,detail}≤200]}` บันทึกการกระทำแอดมิน | admin เท่านั้น |
| `agg` | `{total,games:{},users:{uid:{u,dn,count,hwSet,last}},events:[≤100]}` | ping |
| `status` | `{global:bool,games:{g:bool},until:{scope:ts},msg,ver}` (until = เปิดเองอัตโนมัติ) | admin (system) |
| `pk:<g>` | `{pk:"<b64 32B>",at}` | setpk (deploy.py) |
| `games` | `{<g>:{at}}` ทะเบียนเกมที่ deploy — audit เช็ก pk เฉพาะเกมนี้ (id เก่าค้างใน agg ไม่ฟ้อง) | setpk |
| `rl:<ip>` `rl:a:<ip>` | `{n,ts}` rate-limit unlock(15)/admin-fail(20) ต่อ 10นาที (TTL 1 ชม.) | unlock / admin-auth |

**หลักออกแบบ (กัน lost-update):** KV เป็น eventual consistency — read-modify-write ทั้ง doc จาก 2 request พร้อมกันทำให้ตัวหนึ่งหาย
(เคยทำให้คีย์ที่แบนไว้หายหลัง redeploy เพราะ `/unlock` เขียนทับ `keys` ทั้ง doc ด้วยข้อมูลเก่า) → ตอนนี้ `/unlock` **ไม่แตะ `keys`** เขียนแค่ `usage`;
ค่าที่ต้องไม่หาย (st/exp/bind/note) อยู่ใน doc ที่ admin เขียนคนเดียว · การอ่าน KV พลาดจะ **throw** (ไม่คืนค่าว่างเงียบๆ) → admin write ไม่ทับข้อมูลด้วย `{}`
· ข้อมูลเก่าที่ฝัง uses/hw ใน `keys` ยังอ่านได้ (legacy fallback)

ไม่ผูก `STATS` = fallback in-memory → **คีย์/pk/สถิติหายตอน cold start** (ใช้ชั่วคราวได้ ห้ามใช้จริง)

### 11.3 Endpoints

**Public (สคริปต์เรียก — ไม่มี auth)**

| endpoint | input | output |
|---|---|---|
| `GET /status?g=<id>&hw=<hwid>` | query | `{on,msg,banned:[wm…]}` — banned คือ wm ของคีย์ st=off + เครื่องที่ hw ตรงคีย์โดนแบนจะ on:false |
| `POST /ping` | `{ev,g,tag,u,dn,uid,hw,place}` | `{ok}` — เก็บสถิติ (รับ alias key/username/hwid/action ด้วย) |
| `POST /unlock` | `{k|key,hw|hwid,u,dn,uid,g,tag}` | ผ่าน → `{ok,pk(b64),wm,sig}` / ไม่ผ่าน → `{ok:false,why:no-key\|banned\|expired\|bound\|rate\|no-pk}` |

**Admin (ทั้งหมดอยู่ใต้ `ADMIN_PATH` ลับ — path อื่น = fake 404)**

| endpoint | auth | ทำอะไร |
|---|---|---|
| `GET <AP>/admin` | ไม่มี → ฟอร์มใส่รหัส (GET ธรรมดา ไม่ใช้ JS/storage) | ใส่รหัสแล้วไป `?key=` |
| `GET <AP>/admin?key=` | query | **แดชบอร์ด server-rendered** (ทำงานได้แม้ปิด JS — JS มีแค่ script เดียว nonce'd สำหรับปุ่มคัดลอก): ภาพรวม · kill-switch รายเกม+ข้อความ+**นาทีเปิดเอง** · สร้างคีย์ (สุ่ม/กำหนดเอง/จำนวน≤50/อายุวัน/ล็อกเครื่อง) → คีย์ใหม่แสดงพร้อมปุ่มคัดลอก · ตารางคีย์ (คลิกคีย์=เลือกทั้งดอก + ปุ่มคัดลอก) +ค้นหา · แบน/ปลดแบน · ปลดเครื่อง · ล็อก/เลิกล็อกเครื่อง · กำหนดจำนวนเครื่อง/คีย์ (1-10) · +7/+30วัน · ไม่จำกัดอายุ · แก้หมายเหตุ · ลบ(หน้ายืนยัน) · ผู้ใช้ · events · บันทึกการกระทำแอดมิน · **การ์ด "ระบบออโต้"** (ตั้งค่า/รัน/สำรอง/กู้คืน/ปลดออโต้แบน) · ปุ่ม "ตรวจสุขภาพระบบ" (`?health=1`) |
| `POST <AP>/admin?key=` | query + form | act = `newkey` `ban` `unban` `reset_hwid` `delete` `extend` `noexp` `bind` `maxhw` `note` `sys` `autocfg` `autorun` `snap` `restore` `unautoban` → 303 กลับพร้อมแถบผลลัพธ์ (newkey ส่ง `nk=` คีย์ใหม่) |
| `POST /admin/keygen` `{count,note,custom?,bind?,days?}` | header | custom ต้องเป็น `[A-Za-z0-9_-]{3,64}` (dup=409) |
| `GET /admin/keys` | header | คีย์ทั้งหมด (merge usage) |
| `POST /admin/key/manage` `{key,action,days?,note?,bind?}` | header | action: `ban` `unban` `reset_hwid` `delete` `extend` `noexp` `bind` `maxhw`(n) `note` (ban คีย์ฝังได้) |
| `POST /admin/system` `{game?,maintenance\|on,msg?,version?,minutes?}` | header | kill-switch (body ว่าง = 400 no-op) · `minutes>0` = เปิดเองอัตโนมัติเมื่อครบ |
| `GET /admin/auto` | header (admin หรือ `AUDIT_KEY`) | สถานะออโต้: cfg · last run · snapshots · autoban (คีย์ถูกปิดบัง) |
| `POST /admin/auto` `{action}` | header (admin) | `cfg`{shareLimit,shareHours,shareAction,purgeExpiredDays,dailySnapshot} · `run`(บังคับรัน) · `snapshot` · `restore`{id,mode,confirm?} · `unautoban`{key} |
| Cron `scheduled()` | CF Trigger | รันออโต้รายวัน (ตั้งใน CF → Triggers → Cron เช่น `0 * * * *`; ไม่ตั้งก็รัน lazy ตอนเปิดหน้าแอดมิน ห่าง ≥20ชม.) — ทำ: สำรอง · self-heal · ลบคีย์หมดอายุนาน |
| `GET /admin/stats` | header (admin หรือ `AUDIT_KEY`) | JSON สรุป |
| `GET /admin/audit` | header (admin หรือ **`AUDIT_KEY` อ่านอย่างเดียว**) | ตรวจสุขภาพ/ความสมบูรณ์ทั้งระบบ: env/KV roundtrip/wm integrity/pk/index แบน/ขนาด doc + admin log 30 รายการล่าสุด — คีย์ถูกปิดบัง ไม่มีรหัส/pk ในผล |
| `GET /admin/export` · `POST /admin/import` `{keys,usage,status?,mode,confirm?}` | header (admin) | สำรอง/กู้คืน: mode `merge`(เพิ่มที่ขาด) `overwrite`(ไฟล์ชนะ) `replace`(ล้างแล้วใส่ใหม่ ต้อง `confirm:"REPLACE"`); wm คำนวณใหม่เสมอ; ไม่รวม pk |
| `POST /admin/setpk` `{g,pk}` (GET `?g&pk` ยังรองรับ) | header | อัปโหลด payload key — deploy.py ใช้ POST |

JSON API รับ `x-admin-key` **เท่านั้น** (ไม่รับ `?key=`) · หน้าแอดมินรับ `?key=` (ต้องใช้เพราะไม่พึ่ง JS) → ส่ง `referrer-policy: no-referrer` + `no-store`
· admin พลาด 20 ครั้ง/10นาที/IP → 429 **แม้ใส่ถูก** (เช็ก lockout ก่อนเทียบรหัส) · เทียบรหัสแบบเวลาคงที่

### 11.4 โมเดลความปลอดภัย

- **ADMIN_KEY**: env secret บน Cloudflare (ค่าอยู่ใน `../hz_system/secrets/secrets.json` เท่านั้น — ห้ามเขียนใน repo) + fallback ฝังใน `worker_deploy.js` เท่านั้น — **repo/artifact ไม่มี** → หลังบ้านเป็นของเจ้าของคนเดียว คนนอกเจอ 403
- **PK** (payload key): เกิดตอน build ใน `release.py` → อยู่ใน `<artifact>.pk` (gitignore) + KV `pk:<g>` เท่านั้น — ไม่อยู่ใน repo; เปลี่ยนทุก build → pk รั่ว = เปิดได้แค่ build เก่า
- **unwrap flow**: คีย์ฝังผ่าน crypto ในเครื่อง (ทำงานแม้ worker ตาย) · คีย์เว็บต้อง server คืน pk → แบน/ลบ = ตายทันที · คีย์ฝังโดนแบน = wm ไปใน /status.banned → client ปฏิเสธ
- **banned ผ่าน wm** (hmac(key,"hzv-id")[:8]hex) — server คำนวณด้วย WebCrypto ตรงฝั่ง client เป๊ะ
- **rate-limit** `/unlock`: 15 fail/IP/10นาที (นับทุกเหตุผลที่ไม่ ok) · `/ping`: 60/IP/10นาที (in-memory ไม่เปลือง KV write) · admin: 20 fail/IP/10นาที
- **KV ล่ม**: `/status` fail-open · `/unlock` fail-closed (503 kv-down) · `/ping` พลาดเงียบ · admin write พลาด = error ไม่ทับข้อมูล
- **KV Free plan**: 1,000 writes/วัน — unlock/ping/admin แต่ละครั้งใช้ 1-2 writes; ถ้าผู้ใช้เยอะให้อัป Workers Paid
- **ออโต้ (v2.2)**: ทุก mutation ลง `alog` เหมือนแอดมิน · autoban ปลดได้ที่หน้าแอดมิน/`auto unautoban` · snapshot เก็บ 7 ชุดกู้ merge ได้ · `restore` mode `replace` ต้อง `confirm:"REPLACE"` เหมือน import · kill-switch `minutes` ไม่ลบสถานะ — เช็กเวลาตอนอ่าน (KV ล่มไม่ทำให้เปิดเอง)
- **hwid bind**: เฉพาะคีย์ที่ `bind:true` — unlock จำ hw ได้สูงสุด `maxHw` เครื่อง (ค่าเริ่ม 1) เต็มแล้วเครื่องใหม่ได้ `bound` / admin ปลดด้วย reset_hwid หรือเพิ่ม maxhw · bind แต่ไม่ส่ง hw = `no-hw`
- **fail-open โดยเจตนา**: status/เน็ตดับ → ไม่บล็อกเทสเตอร์ (ปรับเป็น fail-closed ได้ใน fetchStatus)
- **MITM**: pk ต้องผ่าน `hmac(pk,salt..ct)==tag` ฝั่ง client — server ปลอมส่ง pk เทียมไม่ได้ (ได้แค่ของจริงหรือ fail) + TLS

### 11.5 Setup checklist (ทำครั้งเดียว)

1. `../hz_system/backend/worker.js` → copy เป็น `../hz_system/secrets/worker_deploy.js` → แทน `env.ADMIN_KEY || ""` ด้วย `|| "<รหัสที่อยากได้>"` (หรือตั้ง env ADMIN_KEY ใน CF Variables)
2. วาง `../hz_system/secrets/worker_deploy.js` ลง Cloudflare editor → Deploy
3. KV: สร้าง namespace → worker Settings→Bindings→KV → Variable `STATS`
4. `../hz_system/secrets/secrets.json`: `{"adminKey","adminPath","ownerKey","auditKey","hmacSecret"}` — deploy.py ใช้ adminKey auth setpk + merge ownerKey เป็นคีย์ฝังลับ; auditKey = ช่องอ่านอย่างเดียว; hmacSecret = กุญแจเซ็น sig แยกจาก adminKey (regen deploy.js ฝังทั้งหมด — ดู `../hz_system/secrets/README.md`)
   - **`deploy.json → keys` ว่างแล้ว** — ไม่มีคีย์ฝัง public; คีย์ฝังเดิม (`123`, HZV×3) ถูก ban ใน worker → wm เข้า `/status.banned`
   - `releases/*.keys.json` ไม่ push (gitignore) — รายการคีย์+wm เก็บ local เท่านั้น
5. ครั้งแรก: `deploy.py` หรือ manual `…/admin/setpk?key=<k>&g=<id>&pk=<ไฟล์ .pk>`

### 11.6 Playbook ปฏิบัติการ

| อยาก | ทำ |
|---|---|
| สร้างคีย์เทสเตอร์ | `/admin` → ช่องสร้างคีย์ (กำหนดเอง/สุ่ม + note + อายุวัน + ล็อกเครื่อง) → +สร้างคีย์ |
| แบนคน | ปุ่ม "แบน" ข้างคีย์ → unlock= banned + wm เข้า status.banned (คีย์ฝังก็ตาย) |
| แบนทั้งเครื่อง | แบนคีย์ที่ผูก hw นั้น → status?hw= จะ on:false |
| ปิดระบบทั้งหมด | kill-switch "ปิด" + msg → ทุก client ขึ้นหน้าบำรุงรักษาใน ≤60วิ |
| ปิดเฉพาะเกม | เลือก game ในฟอร์ม → g=<id> |
| ดูใครใช้ | `/admin` ตารางผู้ใช้/เครื่อง/เหตุการณ์ หรือ `/admin/stats` |
| คีย์หมดอายุ | ตั้ง `days` ตอนสร้าง → exp เกิน unlock= expired |
| worker ตาย/หาย | สร้างใหม่ + วาง worker_deploy.js + ผูก KV ใหม่ + setpk ซ้ำ (ดู _backups/*/BACKUP.md) |
| เปลี่ยน URL worker | `deploy.json→api` → `py deploy.py` |

### 11.7 จุดที่ client ผูกกับ backend (release_boot.lua)

- `API = @@API@@` ← release.py `--api` ← `deploy.json→api`
- `fetchStatus()` — GET /status ทุก 60วิ · `STATUS.banned` set → unwrap เช็ก wm ก่อน
- `serverUnlock(key)` — fallback หลัง wraps ไม่ผ่าน → POST /unlock → ตรวจ tag เหมือน wrap
- `ping(ev)` — POST /ping throttle ≥2s/ครั้ง ≤45/10นาที (executor request/http_request — ไม่มีก็เงียบ) — ev = gate · unlock · loaded · win/lost:<map> · kill:<kind> · perfect · warn(:staff) · err:<ระบบ> · alive · role:<role> (tag = `build|wm` → หลังบ้านเห็นจากคีย์ไหน)
- `showMaint()/killRuntime()` — หน้าบำรุงรักษา + เคาะ runtime (`getgenv().HZ_VALLEY()` = KILL flag)

### 11.8 ข้อจำกัด/จุดที่ยังไม่ทำ

- คีย์ฝังทำงาน offline (เจตนา — owner keys ไม่ควรตายตาม server) → แบนคีย์ฝังมีผลเฉพาะตอน client เช็ก status ได้ (เน็ตดับ+คีย์ฝัง = เข้าได้ — ยอมรับไว้สำหรับเทส)
- stats ปลอมได้ (ping ไม่มี auth — ข้อมูลสาธารณะไม่สำคัญ)
- session heartbeat = `alive` ping ทุก 4นาทีในแมตช์ (รู้แอคทีฟอยู่ แต่ไม่รู้ "เลิก" เป๊ะๆ — executor ไม่มี on-close hook)
- คนที่มีคีย์จริง dump payload จากหน่วยความจำได้ (เพดาน client-side ของทุกสคริปต์) → กันทางอ้อม: wm ใน telemetry ทุก event + แบนคีย์รั่ว + anti-share autoban
