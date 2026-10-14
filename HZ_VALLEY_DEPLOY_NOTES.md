# HZ VALLEY — DEPLOY & OPS NOTES
สำหรับ Huss Valley / Chicken or Hero · place `107535308163741` · อัปเดต 2026-10-10

---

## 1. โครงสร้าง

| ไฟล์ | หน้าที่ |
|---|---|
| `src/hz_valley.lua` | ซอร์สหลักฉบับเดียว (~1900 บรรทัด) — UI + autopilot + combat + rescue + telemetry |
| `hz_valley.lua` (root) | deploy copy → Xeno autoexec |
| `Xeno/workspace/hz_valley_test.lua` | copy สำหรับ loadstring ทดสอบสด |
| `deep_extract/` | spec + dump: `CATCHER_SPEC_FINAL.md` `RUNNER_SPEC_FINAL.md` `FINDINGS_SUMMARY.md` |
| `Xeno/workspace/hz_valley_log.txt` | log สดทุก event |
| `Xeno/workspace/hz_findings.txt` | collector: attr ใหม่/RunState/Threat/MatchSummary |
| `Xeno/workspace/hz_valley_cfg.json` | cfg ที่เซฟจากเมนู (โหลดอัตโนมัติ) |

ส่วนประกอบใน `hz_valley.lua`:
- **remotes** (บรรทัด ~40-63): ผูก GameAction/MeleeEvent/RescueEvent/GearEvent/Ghost/Clone/BoostRequest/Prefs/Armory/Admin/Quests/Crates
- **cfg** (~128): flag เปิด/ปิดทุกระบบ + พารามิเตอร์ปรับได้ — persist `hz_valley_cfg.json`
- **combatReady()**: gate catcher รวม — role/state/locks/`WalkSpeed>=1`/ControlGate/GlobalPaused/MapChanging
- **pickRunnerP0()**: เลือกเป้า — skip `GhostImmuneUntil`/`Ghosted`/`HitShielded` (ไม่ข้าม `Cloaked`)
- **autopilotTick()**: runner — วิ่งเข้าโซน, juke, dash, gem drift, rescue scan
- **catcherThreat()**: อ่าน ReachPhase/TackleActive/BigDaggerActive/dist รวมเป็น TRACK/REACH/DIVE
- **combatTick()**: catcher — preflight `HitReplayMath.sweep` → Melee ≤`MeleeRange` / Tackle ≤`TackleRange` @ `readyAt-0.03`
- **collectors**: char attrs + RunState first-seen + ThreatIntensity + BoostRequest + MatchSummary → `hz_findings.txt`
- **UI**: การ์ดควบคุม + stepper ปรับค่า + stats `S{ survived, caught, evaded, perfects, skillUsed, tackles, ghosted, rescued }`

## 2. การ deploy/run

```bash
# ผ่าน daemon (แนะนำ) — attach + autoexec อัตโนมัติ
cd "C:\เกมส์\โปรโรบอค\ตัวรันโรบอค"
python xenoctl.py rejoin          # kill → launch → attach → autoexec

# client ติดอยู่เมนู (PlaceId=0)? — join ผ่าน cookie สด:
python -c "import xenoctl as x,json,re,os
d=json.loads(open(x.COOKIES).read()); sec=re.search(r'(_\|WARNING[^\t\n]+)',x.dpapi_decrypt(d['CookiesData'])).group(1)
t=x.auth_ticket(sec); os.startfile(x.join_uri('107535308163741',t))"

# โหลดซ้ำระหว่างเกม (ไม่ต้อง rejoin) — ผ่านช่องสั่ง bf_cmd.lua:
#   KILL=true task.wait(0.4) แล้ว loadstring(readfile("hz_valley_test.lua"))()
```

Keybinds ในเกม: `M` = เมนู · `K` = ปิด/เปิดระบบด่วน · `Delete` = ปิดถาวร · `RightShift` = toggle UI
ปิดจากนอกเกม: `getgenv().HZ_VALLEY()` → ตั้ง KILL ทุก loop หยุด + disconnect connections ทั้งหมด

## 3. Gates ที่ต้องรู้ (ห้ามลบ)

| Gate | เช็ค | ถ้า fail |
|---|---|---|
| `combatReady()` | role/state/HP/`WalkSpeed>=1`/MovementLocked/Ragdolled/TackleActive/Sit/PlatformStand/Anchored/DaggerState/ControlGate | idle ไม่ยิง |
| `moveBlocked()` | GlobalPaused/MapChanging/**FairPlayNoticeOpen**/ScreenPresentationActive | ไม่ขยับไม่ยิง |
| `ControlGate.reason` | UI เปิด 25+ เหตุ (Spectating/Choice/MapVote/...) | input หยุดเอง |
| immune skip | GhostImmuneUntil/Ghosted/HitShielded บนเป้า | หาเป้าใหม่ |
| dash-aware | `BoostEffectAt` เป้า <0.55s | รอ dive อย่าเสีย |
| cooldown | `TackleResult.readyAt`/`AbilityReadyAt`/`GearReadyAt` (server) | รอ |

## 4. ปัญหาที่เจอ + วิธีแก้

| อาการ | สาเหตุ | แก้ |
|---|---|---|
| vel=0 ทั้งแมตช์ เป็น Catcher | **server ไม่ restore WalkSpeed** หลัง lobby→Active (WS=0 ตอน Lobby = ปกติ!) | `rejoin` — รอบใหม่ client ใหม่จะ WS ปกติ ถ้าค้าง >2 รอบ = rejoin เลย |
| `join_place: no ticket` 401 | `accounts/main.dat` เก่ากว่า `RobloxCookies.dat` | ดึง cookie สดจาก COOKIES แล้วสร้าง ticket เอง (โค้ดด้านบน) |
| `require` module พัง | ContactCatchConfig require fail บาง context | fallback `TACKLE_FALLBACK`/constants ในโค้ดแล้ว |
| luac 5.1 เช็ค syntax ไม่ได้ | Luau `+=`/`//` syntax | loadstring บน client = validator จริง |
| stuck spam ตอน freeze | detector ไม่รู้ WS=0 | แก้แล้ว — WS<1 → stuckT=0 |

## 5. ตัวแปรปรับได้ (cfg / เมนู stepper)

```
Enabled(หลัก) · AutoPlay · AutoTackle · AutoMelee · AutoDash · AutoAbility
Dodge · DodgeDash · GodMode · AutoGear · AutoEquip · AutoRescue(ผ่าน loop)
AutoSpin · AutoVote · AutoQuest · FreeClaim · GemFarm · AutoTitle · SpeedTrick
PlayHero (false=ไก่ true=เหยี่ยว)
TackleRange=18 · MeleeRange=6.4 · RescueRange=7 · ThreatRange=25
JukeNear=9 · JukeFar=16 · GemDrift=12
```

ค่าคงที่ในโค้ด (ต้องแก้ไฟล์): `CAT_MAXSPD`, `LONG_DIVE_SPD`(=catMax×0.8 สด), `guardSlowUntil`, melee cadence ~0.86s, rescue hold 0.36s

## 6. คำสั่งวิเคราะห์สด (bf_cmd.lua)

```lua
-- สถานะตัวละคร
return LP:GetAttribute("RunState").." "..LP:GetAttribute("GameRole")
-- WS/freeze check
local h=LP.Character:FindFirstChildOfClass("Humanoid")
return "WS="..h.WalkSpeed.." MR="..LP.Character:GetAttribute("MovementReset")
-- ถอดโมดูล (ใช้ request decompile ของ Xeno)
return decompile(require(RS.ChickenOrHero.Movement.MovementConfig))
-- stats บอท
return getgenv().HZ and getgenv().HZ.stats and game:GetService("HttpService"):JSONEncode(getgenv().HZ.stats())
```

## 7. ข้อห้ามถาวร (ทำแล้วโดน detect)

- ❌ `HitReplayEvent` — CombatPrediction ของเกมยิงเอง ยิงเอง = replay ผิดตำแหน่ง
- ❌ `chrono.*` / `GoatAnalytics` / `MovementGuardEvent` / `ChronoView` — listen-only
- ❌ เขียน attrs ฝั่ง server: RunState/GameRole/Cloaked/Concealed/CombatLife
- ❌ `at` ต้อง `workspace:GetServerTimeNow()` เสมอ · position/velocity จริงเสมอ
- ❌ ยิงเร็วกว่า melee 0.5s / tackle 1.1s / gear throttle 0.6s
- ❌ dash: ผ่าน `BoostInput.request` เท่านั้น (physics server-side)
- ❌ gear: ผ่าน contract `GearEvent` จริง + report จริง (airhorn เช็ค LOS จริง)
