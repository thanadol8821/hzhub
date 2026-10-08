# HZ HUB — Chicken or Hero (Huss Valley)

บอทอัตโนมัติเต็มรูปแบบสำหรับเกม "Chicken or Hero" (placeId `107535308163741`)
โครงสร้างแบบ reusable — เปลี่ยนแมพใหม่ดึง `Ui/Ux` ไปปรับได้เลย

---

## โครงสร้างไฟล์

### โฟลเดอร์เกมนี้ (`ไก่หรือฮีโร่/`)

| ไฟล์ | บทบาท |
|---|---|
| `hz_valley.lua` | **สคริปต์ dev ต้นฉบับ** — ตัวที่รันตรงผ่าน executor / autoexec dev (ไม่ push ขึ้น repo) |
| `releases/hz_valley.lua` | **release build** (single-file เข้ารหัส + หน้าคีย์) — ผลจาก deploy.py |
| `releases/hz_valley.lua.keys.json` | คีย์ที่ฝังใน build นั้น |
| `deploy.json` / `deploy.py` / `ดีพอย.cmd` | ระบบดีพอยอัตโนมัติ multi-game → GitHub |
| `dump/` | ข้อมูล dump แมพ (remotes/interact/state/GUI/scripts index) — ใช้อ้างอิงทำระบบ |
| `watch/` | เครื่องมือเฝ้าเกมสด (`เทส.cmd` = daemon+Roblox+log จอเดียว, `watch.py` = tail log สี) |

### Framework (`../Ui/Ux/`)

```
Ux/
├── FishUI/          ← UI library ทั้งก้อน (13 โมดูล)
│   ├── init.lua         loader + Setup wizard + StandardPages + KeyStore
│   ├── core.lua         helper เบส: new/corner/tw/label + sfx + font
│   ├── tokens.lua       สี TH / ข้อความ STR / FT
│   ├── icons.lua        ไอคอน vector วาดจาก Frame (ไม่ใช้อิโมจิ) 17 แบบ
│   ├── fx.lua           blur/windowFX/capsule/keycap/pillBtn/kname
│   ├── window.lua       หน้าต่างหลัก + notify + satellite + config + logout
│   ├── nav.lua          แท็บ/ซับเมนู/ค้นหาในหน้า
│   ├── widgets.lua      Toggle/Button/Slider/Dropdown/Input/Keybind/Label/Warn
│   ├── keyscreen.lua    หน้าใส่คีย์เต็มระบบ
│   ├── sidebar.lua      แผงซ้ายหน้าคีย์ (avatar/เครื่อง/เกม/เวลา)
│   └── pages/{games,announce,support,settings}.lua
├── Core/              ← HZCore: ยูทิลเกม (hub/char/net/loop/store/safety/single/log/janitor/util)
├── Guard/             ← HZGuard: คีย์/crypto/env/integrity/protocol/session/backend
├── Games/             ← registry.json + ฮับต่อเกม + _template
├── tools/
│   ├── build.py         dist/FishUI.lua + HZCore.lua + HZGuard.lua (single-file)
│   ├── release.py       build release เข้ารหัสพร้อมหน้าคีย์
│   ├── release_boot.lua gate/bootstrap ที่ฝังใน release
│   ├── check.py         static check + unknown-globals
│   ├── luacheck.py      syntax เท่านั้น
│   ├── verify.py        เทสครบ 5 เฟส
│   └── test/run.py      เทสทั้งชุด (mock luau)
├── dist/              ← ผล build ล่าสุด (single-file)
└── README.md / AI_GUIDE.md / SPEC_BACKEND.md
```

### Workspace ที่ executor ใช้จริง (`%LOCALAPPDATA%/Xeno/workspace/`)

- `hz_valley.lua` — copy ของตัว dev (sync ด้วย `tools/sync_xeno.py` หรือ cp)
- `hz_valley_test.lua` — release artifact (autoexec โหลดตัวนี้)
- `FishUI/*.lua` — โมดูล dev ที่ `hz_valley.lua` โหลดผ่าน readfile
- `hz_valley_log.txt` — log บอท (buffer flush ทุก 1.5s)
- `hz_valley_status.txt` — heartbeat จาก autoexec
- `hz_valley_cfg.json` / `FishUI/hz_valley.json` — config สองชั้น (เกม/ธีม)
- `FishUI/key.txt` — คีย์จำ (dev) | `hz_valley_test.lua.keys.json` = catalog release
- `hz_gate_log.txt` — log หน้าคีย์ของ release

---

## ระบบใน `hz_valley.lua`

| ระบบ | ทำงานยังไง |
|---|---|
| **Runner AI** | เดินทางเข้า safe zone อัตโนมัติ, dash เร่งเมื่อเหยี่ยวใกล้, ปล่อยสกิลหนี |
| **Catcher AI** | ไล่เหยื่อใกล้สุด → tackle → melee → BearTrap → ยืนยันจับ |
| **GOD dodge** | อ่าน telegraph attr ของ catcher ทุกเฟรม (Heartbeat 0ms) → ghost/dash/หลบทัน windup |
| **RescueKit** | โดนจับ → ชุบตัวเองอัตโนมัติ → กลับมาเล่นต่อ |
| **ESP** | Highlight เฉพาะกรอบสีรอบตัว — แดง=วิ่งไล่ / น้ำเงิน=วิ่งหนี — per-player pcall, เกิดใหม่สร้างใหม่อัตโนมัติ |
| **Auto-claim** | ขอของฟรีทุก remote ตอนจบแมตช์ |
| **Auto-vote/HeroChoice/gear** | โหวตแมพ + เลือก hero + ซื้อ/equip เกียร์ (per-item cooldown 45s กัน spam) |
| **Anti-AFK / stuck / spin** | ครบ loop ทุกตัวห่อ `guard()` (21 จุด) — error ถูก log ไม่ฆ่า thread |
| **Log** | buffer + writefile flush ทุก 1.5s → `hz_valley_log.txt` |
| **Config** | `hz_valley_cfg.json` (state เกม) + `FishUI/hz_valley.json` (ธีม/opacity/keybind ของ FishUI) — ไม่ชนกัน |

### ปุ่มควบคุม

- `RightShift` — ซ่อน/แสดงเมนู (เปลี่ยนได้ในหน้าตั้งค่า)
- `RightAlt` — แผง keybinds ลอย
- `M` / `K` / `Del` — บอท: เมนู / ปิดด่วน / ปิดถาวร (destroy GUI)

### ESP

- เปิดที่ หมวดฟาร์ม&เสริม → `ESP ผู้เล่น`
- Highlight `AlwaysOnTop` parent ตรงเข้า character (เสถียรกว่า ScreenGui)
- สีล้วน 2 ฝั่ง — ไม่มีป้ายชื่อ (คลีนตามสั่ง)

### เสียงปุ่ม (builtin `rbxasset://` — น่ารัก โหลดทันที)

| เหตุ | เสียง |
|---|---|
| click (ทุกปุ่ม 29 จุด) | button.wav / snap.wav / electronicpingshort.wav (สุ่ม+เร่งจังหวะ ±10%) |
| open | swoosh.wav |
| ok (คีย์ผ่าน/บันทึก) | rubber duck.wav |
| bad (ผิด/ล็อก) | uuhhh.mp3 |
| noti | victory.wav |

ปรับระดับได้ในหน้าตั้งค่าเซิร์ฟเวอร์ (ผูก `D.sndVol` เข้า sfx แล้ว)

---

## ระบบคีย์ (release)

- build ด้วย `tools/release.py` → ไฟล์เดียวเข้ารหัส + gate หน้าคีย์
- `keyMode`: `always`=ถามทุกครั้ง / `fill`=เติมให้รอกด / `auto`=จำคีย์ผ่านเลย (build เทสปัจจุบัน = auto)
- คีย์เทส: `123` + HZV-* สามตัว (ดู `.keys.json`)
- `blockOn`: เทสต้อง `never` (env-check เจอตัว executor เองจะบล็อกทางเข้า) — build ขายจริงใช้ `high`
- **logout** → เคลียร์คีย์จำ → เด้งกลับหน้าคีย์ (เทสผ่าน mock) — dev build = reload สคริปต์ตัวเอง

## คำสั่ง build/เทส

```bash
cd Ui/Ux
py tools/build.py                                        # dist ทั้ง 3 ไฟล์
py tools/test/run.py                                     # เทส mock ทั้งหมด (ต้องผ่าน 11/11)
py tools/check.py ../../ไก่หรือฮีโร่/hz_valley.lua       # static check
```

## ดีพอย (GitHub: thanadol8821/hzhub)

โครงแบบ multi-game — **คีย์ชุดเดียวใช้ได้ทุกแมพ** ทะเบียนที่ `deploy.json`:

```json
{
  "keys": [...คีย์เทสทั้งหมด...],
  "keyMode": "auto", "blockOn": "never",
  "games": [
    {"id":"valley","name":"...","placeId":107535308163741,"src":"hz_valley.lua","enabled":true},
    {"id":"dice","src":"%XENO_WS%/hz_dice.lua","enabled":false},  ← เปิดเมื่อพร้อม
    ...
  ]
}
```

- `src` รองรับ `%XENO_WS%` = workspace ของ Xeno
- ผล build ลง `releases/hz_<id>.lua` + sync เข้า workspace เป็น `hz_<id>_test.lua` อัตโนมัติ
- `--only <id>` build เกมเดียว · `--no-push` build อย่างเดียว
- README ตารางไฟล์ (`<!--FILES-->`) ถูกอัปเดตตามเกมที่ build สำเร็จ

```bash
py deploy.py           # tag อัตโนมัติ v<yymmdd-HHMM> + push
py deploy.py "v2.7"    # tag เอง
ดีพอย.cmd              # ดับเบิลคลิก
```

**เพิ่มแมพใหม่**: วางสคริปต์ไว้ที่ไหนก็ได้ → เพิ่ม entry ใน `deploy.json` (`enabled:true`) → กด `ดีพอย.cmd` — คีย์เดิมเปิดได้ทันทีไม่ต้องแจกใหม่

## Quirks ของ Xeno ที่ต้องรู้ (เรียนมาแล้ว)

- `appendfile` มีฟังก์ชันแต่ **เขียนไม่ลงจริง** → ใช้ `writefile` + buffer เท่านั้น
- `ctl eval`/jobs ส่ง script ได้แต่ **writefile/print ใน context นั้นเงียบ** → ดูผลผ่าน log ไฟล์ของสคริปต์
- autoexec ยิงเฉพาะตอน **Xeno.exe (GUI) เปิด** — daemon ล้วนไม่ยิง
- ตอน attach client อาจเด้งเป็นระยะ ("client cannot keep up") — ปัญหา engine ไม่ใช่สคริปต์

## เฝ้าดูสด

```
ไก่หรือฮีโร่\watch\เทส.cmd   ← เปิดทุกอย่าง+ดู log จอเดียว
py watch.py                   ← tail log ทุกช่องพร้อมสี
```

## เอาไปใช้กับแมพใหม่

1. คัดลอก `Games/_template/` → `Games/hub_<placeId>/` แก้ `hub.lua`
2. เพิ่ม `{placeId=..., file="hub_xxx.lua"}` ใน `Games/registry.json`
3. เกมเฉพาะใส่ใน hub.lua; UI/cfg/key ทั้งหมดได้มาฟรีจาก FishUI/Guard
