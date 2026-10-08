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

## 4. ระบบใน `hz_valley.lua` (สคริปต์หลัก ~1900 บรรทัด)

| ระบบ | หลักการ |
|---|---|
| Runner AI | autopilot loop — เดินทางเข้า safe zone, dash+ปล่อยสกิลตอนเหยี่ยวใกล้ |
| Catcher AI | เลือกเหยื่อใกล้สุด → chase → tackle → melee → BearTrap → ยืนยัน |
| GOD dodge | Heartbeat 0ms อ่าน attr telegraph ของ catcher → หลบทัน windup |
| RescueKit | โดนจับ → ชุบตัวเอง → กลับ Active ต่อ |
| ESP | Highlight (AlwaysOnTop) parent เข้า char ตรง — แดง=ไล่/น้ำเงิน=หนี — per-player pcall + respawn-guard |
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

- แบ็กเอนด์จริงยังไม่มี — release ใช้คีย์ฝัง (keyMode auto); ถ้าจะทำ server จริงดู `Ui/Ux/SPEC_BACKEND.md` + `hz_loader.lua` mode release
- ESP ไม่มีชื่อ/ระยะแล้ว (ตัดออกตามสั่ง — เหลือแค่กรอบสี)
- `blockOn:never` เฉพาะ build เทส — build ขายต้องเปลี่ยน
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

## 11. Backend (Cloudflare Worker) — ตั้งแต่ v261008-telemetry

worker URL: `https://dry-wave-054e.thanadol821.workers.dev` — source อยู่ที่ `backend/worker.js`

### การติดตั้งครั้งแรก (ทำครั้งเดียว)

1. dash.cloudflare.com → Workers → `dry-wave-054e` → **Edit code**
2. ลบโค้ดเดิม → วางเนื้อ `backend/worker.js` ทั้งไฟล์ → **Deploy**
3. (แนะนำ) ตั้งรหัสแอดมิน: worker → **Settings → Variables and Secrets** → Add `ADMIN_KEY` = รหัสลับของเรา (ถ้าไม่ตั้ง ใช้ค่า fallback `hz-admin-123` — เปลี่ยนเถอะ อย่าใช้ค่า default จริง)
4. (แนะนำ — เก็บสถิติถาวร) **Storage → KV** → สร้าง namespace `HZHUB` → worker → Settings → **Bindings** → Add → KV Namespace → Variable name `STATS`

ไม่ผูก KV ก็ทำงานได้ — สถิติอยู่ในหน่วยความจำ worker (รีเซ็ตตอน cold start ~ หลังไม่มีคนใช้สักพัก) + เห็น ping สดในแท็บ logs/observability ของ dashboard อยู่ดี

### ใช้งานประจำวัน

| อยากทำ | ทำไง |
|---|---|
| ดูสถิติหลังบ้าน | เปิด `<worker>/admin?key=<ADMIN_KEY>` — จำนวน ping/คน/เครื่อง/ผู้ใช้ล่าสุด + ฟอร์มเปิดปิด |
| ปิดระบบทั้งหมด (kill-switch) | `/admin/set?key=K&g=all&on=0&msg=กำลังอัปเดต` — ทุก client โดนตัดภายใน 60 วิ |
| ปิดเฉพาะเกม | `/admin/set?key=K&g=valley&on=0` |
| เปิดกลับ | `/admin/set?key=K&g=all&on=1` — client เด้งกลับเอง |
| ดูสถิติดิบ | `/stats?key=K` (JSON) |

### สิ่งที่สคริปต์ทำอัตโนมัติ (release_boot.lua)

- เปิดเกม → `GET /status?g=<id>` → off = หน้าต่าง "ปิดปรับปรุงชั่วคราว" ไม่ถามคีย์
- ผ่าน status → `POST /ping ev=gate` (นับคนเห็นหน้าคีย์) — ใส่คีย์ผ่าน → `ev=unlock`
- ทุก 60 วิ เช็ก status ซ้ำ — โดนปิดกลางทาง = ฆ่ารันไทม์ + ขึ้นหน้าบำรุงรักษา / เปิดกลับ = หน้าหายเอง
- **fail-open**: worker ล่ม/เน็ตดับ/ตอบมั่ว = ไม่บล็อก (เทสเตอร์ไม่หงุดหงิด) — อยาก fail-closed ค่อยปรับ
- ping ส่ง: event, เกม, tag, @username, displayName, userId, hwid (ย่อใน stats), placeId — ไม่มีรหัสผ่าน/cookie ใดๆ

### ข้อควรรู้

- สคริปต์ใช้ `request`/`http_request`/`syn.request` ของ executor POST — Xeno รองรับ `request`; executor อื่นบางตัวไม่มี → ping เงียบไปเฉยๆ ไม่พัง
- status เช็กผ่าน `game:HttpGet` — ใช้ได้ทุก executor
- วิธีเปลี่ยน worker → แก้ `api` ใน deploy.json แล้ว deploy ใหม่
