# RUNNER SPEC FINAL — Huss Valley (Chicken or Hero)
ถอดจาก client modules + LocalScripts จริง (decompile สด @esihz750) + dump attributes — เขียนโค้ด auto-evade ได้ทันที
อัปเดต: 2026-10-10 · ความสมบูรณ์ ~95%

---

## 1. โครงสร้างสถานะนักวิ่ง (Attributes)

### 1.1 Player attributes (อ่านจาก `Player:GetAttribute`)
| Attr | ค่า | ผู้ตั้ง | หมายเหตุ |
|---|---|---|---|
| `GameRole` | `Runner`/`Catcher`/`Lobby` | server | เปลี่ยนทันทีเมื่อจบ crossing (โดนจับ→Catcher รอบถัดไป) |
| `InMatch` | bool | server | |
| `RunState` | `Lobby`/`Active`/`Caught` | server | Caught + Ragdolled = รอชุบ หรือกลายเป็น catcher รอบหน้า |
| `RunNumber` | int | server (Session) | รอบปัจจุบัน |
| `CombatLife` | int | server | เห็น 15/16 บน catcher, 2-83 บน runner |
| `ClientReady` | bool | client | ตัวเราเองตั้ง |
| `EquippedKnife` | skin id | server | `GhostScythe`→ghost, `CloneDagger`→clone, `BalloonDagger`,`BaseDagger`,`CluckBasher` |
| `TouchAutoMelee` | bool | prefs | ผู้เล่นหลายคน true จริง |
| `AbilityReadyAt` | serverTime | server | cd ability (gear) ปัจจุบัน |
| `GearReadyAt` | serverTime | server | cd item ปัจจุบัน |
| `GhostAbilityReadyAt` | serverTime | server | cd ghost 45s |
| `GhostImmuneUntil` | serverTime | server | **immunity 2 วินาที** ("IMMUNE · 2 SECONDS") |
| `CloneAbilityReadyAt` | serverTime | server | cd clone 45s |
| `CloneAbilityActiveUntil` | serverTime | server | clones ออก 12s |
| `CatcherThreatIntensity` | 0..1 | server | บน LocalPlayer — เจอ =0 (เราเป็น catcher ตอนนั้น) |
| `CatcherThreatUpdatedAt` | serverTime | server | |
| `HighPingWarning` | bool | server | |
| `ConnectionCheckMatches` | int | server | |
| `Spectating` | bool | server | gate |
| `EscapeStreakState` | JSON `{count,eligible,matchId}` | server | |
| `CrossingBalanceNotice` | JSON `{baseline,id,role,turning,...}` | server | balance info |
| `FFALives` | int (3) | server | เฉพาะ `AdminMatchMode=="FFACatchers"` |
| `FFADownUntil` | serverTime | server | "GET UP IN n" |
| `FFAImmuneUntil` | serverTime | server | "INVINCIBLE · n" respawn shield |
| `FFAInvincible` | bool | server | ยิง airhorn ไม่โดนคนนี้ |
| `LastMatchAdmission` / `LastMatchAdmissionAt` | str/time | server | |

### 1.2 Character attributes (match-only — ไม่อยู่ใน lobby dump)
| Attr | ความหมาย |
|---|---|
| `Ragdolled` | ล้ม/โดนจับ — humanoid ถูก force Physics state (RescueClient เขียน local) |
| `RescueAvailable` | ชุบได้ (runner ที่โดนจับใน crossing) |
| `RescueHelperId` | userId ของคนที่กำลังชุบอยู่ (lock) |
| `Cloaked` | **Cloak gear active** — ตัวเองเห็น 0.8 alpha, คนอื่นเห็นตามระยะ (0@≤0.5st → 1@20st) |
| `Ghosted` | GhostScythe active — ซ่อน 0.8 flat |
| `HitShielded` | OneHitShield เปิดอยู่ (0.75s) |
| `BigDaggerActive` | catcher เปิด BigDagger (reach ×2 หวดถัดไป) — **เตือน:อย่าเข้าใกล้** |
| `MovementLocked` | ขยับไม่ได้ |
| `TackleActive` | กำลัง dive (catcher) |
| `BoostEffectAt` | server stamp เมื่อ dash ออก — trigger anim |
| `BoostDashName` | `DashLeft`/`DashRight` — **dash แบบเลี้ยว** เจอจริงใน dump 20 chars |
| `DashAnimationSequence`,`DashFromDirection`,`DashToDirection`,`DashVisualFacing` | anim data |
| `DashCooldownUntil` | **os.clock (client clock!)** ไม่ใช่ server time |
| `Concealed` | ยังไม่เคยเห็น true — น่าจะ server targeting flag (คู่กับ Cloaked) |

### 1.3 Session attributes
`Phase` (Intermission/GroupRun/Prepare/SelectHero/HeroChoice/ChoiceReveal/RunResolution/Results/FinalRun), `MatchStep`, `MatchStepDeadline`, `RunNumber`, `ActiveMapId`, `GlobalPaused`, `MapChanging`, `Notice`/`NoticeUntil`, `HeroUserId`, `SelectedUserId`, `LeadUserId`, `AdminMatchMode` (`CrossyRoad`/`DonkeyKong`/`FFACatchers`), `SpectateAvailable`, `MatchHealth`, `Announcement`, `StartSide`, `EndsAt`, `MatchSummary` (StringValue — JSON เต็มจบแมตช์)

---

## 2. กลไกการเคลื่อนไหว (MovementConfig จริง)

```
MaxSpeed=33.6  Accel=36  Decel=66  SpeedScale=1.2  Tick=0.05
Runner: ×1.06 → 35.62 s/s | accel ×1.42 | TurnRetention90=0.72
Catcher: ×1.10 → 36.96 s/s | TurnRate 300°/s (slow 720) | retention 0.65
→ Runner ช้ากว่า 1.34 s/s แต่เร่ง+เลี้ยวเก่งกว่า — หนีด้วยมุม ไม่ใช่เส้นตรง
```

### CrossingBalance (rubber-band — คนน้อยได้บัฟ)
```
pressure = clamp((catchers-1)/(total-2),0,1)^1.25   (เปิดเมื่อ total>2)
runnerScale  = 1 + 0.12·pressure   (สูงสุด +12% speed)
catcherScale = 1 - 0.08·pressure
runner accel +55%·pressure, turnRetention→0.88, brake +20%
```
→ ทีม runner เหลือน้อย = เร็วขึ้นเอง อ่าน `CrossingRunnerSpeedScale`/`CrossingCatcherSpeedScale` ได้สด

### DASH (runner เท่านั้น — catcher ใช้ไม่ได้)
```
Mode=RunBoost  Distance=10.8 studs  Duration=0.28s  Cooldown=1.1s
Recovery=0.2s @0.8 speed | exit speed ×0.85 | ScaleDistanceWithSpeed=true
Input: Space / R2 / tap — buffer 0.18s (touch 0.32)
Directional: MinTurnAngle=90°, TurnInputGrace=0.38s, MinIntentAngle=35°
  → dash ตอน input เลี้ยว ≥90° = DashLeft/DashRight (เจอจริงใน dump!)
Gate: !Catcher, Health>0, !Anchored !Sit !PlatformStand !MovementLocked !TackleActive !movementReason
Server stamps: BoostEffectAt (serverTime) + DashCooldownUntil (os.clock!)
```
**ผ่านทาง `Movement.BoostInput` module** — `request(dir)`→`consume()` หน้าต่าง 0.15s — physics ฝั่ง server

### PERFECT DODGE
server ตัดสินเอง (dash ทันช่วง catcher's windup/active โดยนัย) → `BoostRequest.OnClientEvent("PerfectDodge")` → UI เท่านั้น — **ไม่ต้องยิงอะไรเพิ่ม แค่ dash จังหวะถูก**

### หน้าต่างปลอดภัยหลัง catcher พลาด
```
tackle พลาด: recovery 0.6s + cd 1.1s  = 1.7s ยิงไม่ได้
melee พลาด:  recovery 0.55s + input gap 0.5s ≈ 1.05s
→ โดนไล่ใกล้ๆ แล้วเขาพลาด = วิ่งสวน/ตรงต่อได้เลย 1.0-1.7s
```

---

## 3. ความสามารถฝั่งหนี (GearCatalog + contracts จริง)

### 3.1 Role Abilities (Kind="Ability", กด Q/R1 — `AbilityReadyAt` gate)
```
GearEvent:FireServer("UseAbility", nil, dashDirection, requestId, nil, airhornReport?)
```
| Ability | CD | Effect | ใช้ตอน |
|---|---|---|---|
| **Cloak** | 35s | หายตัว 3s — `Cloaked` char attr; **ยังโดนจับได้**, ใช้ item = หลุด, ระยะใกล้เห็นจาง | โดน ReachTarget ล็อก / จะถึงเส้น |
| **OneHitShield** | 45s (ฟรี) | `HitShielded` 0.75s บล็อก 1 หวด | เห็น Windup/Active แน่ๆ |
| **InflatableDecoy** | 30s | ตุ๊กตาวิ่งตรง 7s โดนจับ=แตก | โยนทิศเดิมแล้วเบี่ยง |
| **EmergencyAirhorn** | 18s | ระเบิด catcher รอบตัว cone 14 studs/ΔY≤6 — **client ส่ง target list เอง** | catcher ประชิด ≤10 |
| **PocketDoor** | 25s | ประตูหน้าตัว 6s — catcher ทะลุ/อ้อม | คอแคบ/ข้ามสะพาน |

### 3.2 Items (Kind="Item", กด C/B — `GearReadyAt` gate, มีจำนวนชาร์จ)
```
GearEvent:FireServer("Use", nil, direction, requestId)
```
| Item | CD | Effect |
|---|---|---|
| **RescueKit** | 22s | **ชุบตัวเอง** ตอน `RunState==Caught` + char `RescueAvailable` — ปุ่มแสดง "REVIVE YOURSELF" |
| **Adrenaline** | 12s | +60% accel + turn retention ดีขึ้น 5s |
| **BananaPeel** | 12s | เปลือกกล้วย 15s — ฝั่งตรงข้ามเหยียบ=ลื่นล้ม |

### 3.3 Knife abilities (กด R/L1 — knife-locked)
| Knife | CD | Effect |
|---|---|---|
| **GhostScythe** | 45s | `GhostAbilityEvent:FireServer("Activate")` → `Ghosted` + `GhostImmuneUntil` = **จับไม่ได้ 2 วินาที** — ทุกคนเห็น pulse! |
| **CloneDagger** | 45s | `CloneAbilityEvent:FireServer("Activate")` → **2 clones 12s** (JukeChance 0.65, swap 4 studs, think 0.35) — catcher เห็น 3 ตัว |

### 3.4 Rescue (ชุบเพื่อน — F/X hold)
```
target: char RescueAvailable + Ragdolled, ≤6.75 studs, LOS (CollisionGroup CoHRunner)
RescueEvent:FireServer("Begin", userId) → hold 0.3s → ("Finish", userId) · ออกระยะ/เปลี่ยนเป้า → ("Cancel", id)
RescueHelperId = lock 1 คน · MaxRescuesPerCrossing=1 · FinishGrace 1.5s
```
**Caught ของตัวเอง:** `RunState=="Caught"`+`Ragdolled` → "DOWNED" ถ้า RescueAvailable มิฉะนั้น "CAUGHT · เป็น catcher รอบหน้า"

### 3.5 Catcher abilities (เพื่อเตรียมรับมือ)
BigDagger(25s,reach×2→`BigDaggerActive`) · BearTrap(35s,throw 10st,trigger 2,stun 0.5s,อายุ 12.9s) · RufusLeash(20s,throw 15st 65s/s,pull 6st,radius 2.8) · BowlingBall(20s,42s/s ล้ม) · RocketShoes(18s,carry 0.6s LinearVelocity)

---

## 4. ตรวจจับภัยจากข้อมูลสด (read-only)

| สัญญาณ | ที่ | ความหมาย | การตอบสนอง |
|---|---|---|---|
| `CatcherThreatIntensity` | LocalPlayer | 0→1 อันตรายขึ้น | >0.7 = หนีจริงจัง |
| `ReachPhase` | char ของ catcher | `Tracking`/`Windup`/`Active` | Windup=0.12s เตือนก่อนฟัน → **dash เลี้ยวทันที** |
| `ReachTargetUserId` | char ของ catcher | userId เป้าล็อก | ==เรา → ไม่วิ่งตรง |
| `ReachDirection` | char ของ catcher | Vector3 เล็ง | เทียบทิศเรา |
| `TackleReadyAt` | char catcher | พร้อม dive เมื่อไหร่ | <now = อันตราย dive |
| `TackleActive`/`TackleDirection`/`TackleVariant` | char catcher | dive อยู่ | เลี้ยวออกจาก direction |
| `DaggerState`/`DaggerReadyAt` | char catcher | มีดพร้อม | Held = ฟันได้ |
| `BigDaggerActive` | char catcher | reach×2 | ห้ามเข้าใกล้เด็ดขาด |
| `Cloaked`/`Ghosted`/`HitShielded` | char ใครก็ได้ | สถานะพราง/เกราะ | |
| `GlobalPaused`/`MapChanging` | Session | หยุดเกม | idle |
| `ControlGate.reason()` | module | 20+ gate (UI/Choice/Spectating/FairPlayNotice...) | ต้อง nil ก่อนกดอะไร |
| `FairPlayNoticeOpen` | LocalPlayer | guard warning เปิดอยู่ | **ก็เป็น gate — หยุดทุกอย่าง** |

**ControlGate.reason ค่าที่พบ:** EventHostPanel/Crates/StarterPack/LikeReward/CreatorPanel/GlobalWheel/MapVote/MapChange/Emotes/AnnouncementComposer/Settings/UpdateLog/Spectating/FairPlayNotice/ConnectionQuality/Journey/BalloonOffer/Armory/ServerBrowser/AdminRefresh/AdminConsole/RobloxMenu/TextInput/ScreenTransition/Choice/ChoiceCamera · movementReason: GlobalPause/MapChange/Spectating

**MovementGuardEvent** (listen-only): `("Warning", {title,message})` → modal + ตั้ง `FairPlayNoticeOpen=true` · `("Staff",{userId,message})` → toast 18s

---

## 5. Auto-Evade design (เขียนได้เลย)

```
ทุก 0.1s:
  gate = Role==Runner, InMatch, RunState==Active, !ControlGate, !GlobalPaused, !MapChanging,
         !MovementLocked, !Ragdolled → ไม่ครบ = wait
  threat scan:
    for catcher in catchers: อ่าน ReachPhase/ReachTargetUserId/TackleActive/DaggerState/BigDaggerActive/dist
    targeted = (ReachTargetUserId == me) สำหรับ catcher ใกล้สุด
  สถานะตอบโต้:
    [ไม่ถูกล็อก & threat<0.5]  → เส้นทางข้ามปกติ (ซิกแซกเบา)
    [Targeted + Tracking]     → เพิ่ม lateral offset, ไม่วิ่งเส้นตรง, เตรียม dash
    [Targeted + Windup]       → DASH 90° ทันที (perfect-dodge window) หรือ feint-brake
    [Active]                  → เลี้ยวออกนอก cone 65°/แนวกล่อง 5.3 — ผ่านข้างตัว
    [Recovery/TackleActive พลาด] → หน้าต่าง 1.05-1.7s — วิ่งผ่าน/ตรงต่อ
    [TackleReadyAt<now + เร็ว>29.6 ใกล้] → คาด dive: หลบข้างก่อนเขาจะกด
  abilities:
    Cloak เมื่อ targeted นาน>1.5s หรือ ใกล้เส้น
    OneHitShield เมื่อเห็น Windup ชัด (0.75s เท่านั้น — ห้ามกดเร็ว)
    Ghost เมื่อ dist<6 และไม่มีทางอื่น (immune 2s จริง)
    Airhorn เมื่อ catcher ≤10 + ใน cone
    PocketDoor เมื่อผ่านจุดแคบและไล่อยู่ ≤14
    Clone เมื่อเพิ่ง spawn/ต้องการหลุดกลุ่ม
    Adrenaline เมื่อ dash ใช้ไปแล้ว + ไล่ต่อ
    RescueKit เมื่อ Caught+RescueAvailable (auto)
  rescue: เพื่อน Ragdolled+RescueAvailable ในเส้นทาง ≤7 st → Begin/Finish hold 0.3s
    (เสี่ยง: ยืนนิ่ง 0.3s — ทำเฉพาะ catcher ไกล>20)
```

**Dash usage rules:** cd 1.1s ใช้ได้บ่อย — แต่เก็บไว้ตอน `Targeted+Windup` หรือ `TackleReadyAt ใกล้หมด` — **dash เปล่า = เสีย perfect-dodge**

---

## 6. กฎเหล็ก + จุดที่ยังไม่ยืนยัน

### ห้าม
- ห้ามเขียน `RunState/GameRole/Cloaked/Ghosted/RescueAvailable/Concealed` — server-owned
- ห้ามยิง `HitReplayEvent`/`MovementGuardEvent`/`chrono.*`/`GoatAnalytics`/`SpectateEvent`
- dash ต้องผ่าน `BoostInput.request` (physics server-side — ยิง remote ปลอมไม่ได้)
- ability/gear ต้องผ่าน `GearPredictionClient.request` เท่านั้น (client-side bookkeeping + prediction — ยิง GearEvent ตรงๆ ข้าม check)
- `at` = `GetServerTimeNow()` เสมอ; position/dir จริงเสมอ (airhorn report เช็ค LOS จริง)
- โดนจับแล้วห้ามฝืน — รอ RescueKit/เพื่อน/รอบใหม่

### ยังไม่ยืนยัน (รอ live data)
- `Concealed` — เห็นแต่ false; คาดว่า server flag ตอน Cloak (คู่ `Cloaked`)
- `CatcherThreatIntensity` สเกลจริง — ต้องเป็น Runner ถึงจะขยับ
- RunState ค่ากลาง (`Waiting`/`Safe`/`Revivable`/`Revived`/`Inactive`) — ยังไม่เคยเห็นใน dump
- `CrossingState` — ยังไม่พบ attr นี้; MatchStep/Phase + zone parts น่าจะเป็นตัวบอกแทน
- BoostRequest payload ขาเข้า (มีแค่ OnClientEvent PerfectDodge — ขาออกน่าจะ fire("Dash") จากที่อื่น)

---
*รวมกับ `CATCHER_SPEC_FINAL.md` = spec ครบทั้งสองฝั่ง — พร้อมเขียน runner P0 ทันที*

---

## ภาคผนวก — LIVE FINDINGS แมตช์จริง 12:30-12:35 (ยืนยันแล้ว)

### RunState ยืนยัน 4 ค่า
`Waiting` (รอเข้ารอบ — ตัวเราเองเห็นจริง) · `Active` · `Caught` (+Ragdolled+RescueAvailable) · `Lobby`
— `Waiting` คือค่ากลางที่ spec เดิมไม่มี ระหว่าง SelectHero→Active

### char attrs เห็นจริงครั้งแรก
`MovementLocked` `DashAnimationSequence` `DashFromDirection` (บนตัวเราเอง) · `HitShielded=true @cghsdchv` (มีคนกด OneHitShield จริง!) · `RescueAvailable` `Ragdolled` @nomzmm7

### กลไกใหม่ที่เจอ: `MovementReset` + WalkSpeed=0
- attr `MovementReset` = ตัวนับจำนวน reset (เจอ 161)
- **server ตั้ง `Humanoid.WalkSpeed=0` ได้** — ตัวเราค้าง 2 รอบ (Catcher Active แต่ vel=0 ตลอด)
- น่าจะ = ผล stun/lock ค้างข้ามรอบ หรือ freeze จงใจ — **MovementLocked attr=false แต่ WS=0 จริง** → combatReady เดิมเช็ก MovementLocked เท่านั้นไม่พอ ต้องเช็ก WS>0 ด้วย
- ผลต่อบอท: steer ตั้งแล้วแต่ขยับไม่ได้ = stuck detector spam — เพิ่ม WS==0 ใน runner/catcher gate

### Auto-rescue ทำงานจริง
`Begin(uid)→hold 0.36s→Finish(uid)` = เพื่อนลุกจริง `[RES] ชุบ kidjkdb5 เสร็จ!` — contract ถูก 100%

### ยังไม่เห็น
`Concealed` ตัวจริง · `Ghosted` char attr · `RescueHelperId` · Guard payload · CrossingState attr · CatcherThreatIntensity >0 (เราเป็น catcher ตลอด)

---

## ภาคผนวก 2 — LIVE MATCH เต็ม 12:51-12:57 (หลัง rejoin, WS คืน)

### RunState lifecycle ยืนยันสมบูรณ์บนตัวเราเอง
`Lobby → Waiting → Active → Safe` (รอด) | `Active → Caught → Active` (RescueKit ชุบตัวเอง!)
— ครบทุก transition: **Caught→Active ย้อนกลับได้จริง** ผ่าน self-revive ไม่ใช่ทางเดียว

### RescueKit ใช้ได้จริง ×2
Caught → ระบบ detect `RescueAvailable` → ยิง RescueKit → ลุก Active ทันที (2/2 ครั้ง)
— auto-buy เติม stock อัตโนมัติ `[BUY] Adrenaline (60 gems)`

### Lobby WS=0 = ปกติ!
rejoin แล้ว WS=0 ตอน Lobby — คืน WS ตอน Active → **freeze เก่าคือ server ไม่ restore WS หลัง role-swap** ไม่ใช่ stun

### Phase lifecycle เต็ม
`Intermission → Prepare → SelectHero → HeroChoice → ChoiceReveal → HeroRun|GroupRun → [รอบถัดไป Prepare→GroupRun] → FinalRun → Results → RunResolution → Intermission`
— `Waiting` ตอน HeroRun/Prepare ระหว่างรอบ, `Active` เฉพาะรอบที่วิ่งจริง

### stats แมตช์นี้
รอด4 โดนจับ3(ชุบกลับ2) หลบ33 เพอร์เฟ็กต์1 สกิลหนี2 ไล่1 kill2(tackle) ชุบ2

---

## ภาคผนวก 3 — LIVE FINDINGS ต่อเนื่อง 12:58-13:04 + สรุปสุดท้าย

### ยืนยันเพิ่มจาก findings collector
- `CatcherThreatIntensity=1` (12:54:12) — มีจริง ขึ้นถึง 1 ตอนโดน REACH ล็อก คู่กับ `HitShielded=true @esihz750` ตัวเอง (shield auto-fire ทำงานตอน threat สูงจริง)
- `RescueHelperId=9838879287 @ASYr291` (12:58:58) — lock คนชุบจริง ใครช่วยใครเห็นได้
- `MovementLocked=true @esihz750` — ตัวเราเองโดนล็อกตอน Waiting/transition ยืนยัน
- `HitShielded=true` เจอทั้งบนตัวเองและคนอื่น — OneHitShield ใช้กันจริงในแมตช์

### สถิติรวม session สุดท้าย (auto ล้วน)
```
รอด 7 · โดนจับ 5 · หลบ telegraph 55 ครั้ง · เพอร์เฟ็กต์ 1
สกิลหนี 5 · ไล่ (kills เป็น catcher) 4 · auto-rescue เพื่อน 3 · RescueKit ตัวเอง 2
```
→ survival จริง ~7/9 crossings ที่วิ่ง · rescue ทำงานทั้งชุบตัวเองและชุบเพื่อน

### ตีความหมาย `Concealed` (สรุปสุดท้าย)
ไม่เคยเห็น true ในทุก dump+live — เกือบแน่ใจว่าเป็น **server-side targeting flag เท่านั้น**
(เขียนมาเมื่อ Cloak ทำงานเพื่อให้ catcher AI/ระบบเลิกล็อก) — ฝั่ง client อ่าน `Cloaked` แทน

### สิ่งที่ต้องเฝ้าต่อในอนาคต
1. `Concealed=true` — รอ catcher bot ของเกมเจอเป้า Cloak ขณะเราดูอยู่
2. `Ghosted` char attr — ต้องมีคนใช้ GhostScythe ในเฟรมเดียวกัน
3. `MovementGuardEvent` payload เต็ม — ยังไม่เคยโดน warning (ระบบเราไม่ violate)
4. `BigDaggerActive` — ต้องมี catcher ใช้ BigDagger
5. `RunState` ค่าที่อาจมีเพิ่ม (`Revivable`/`Revived`/`Inactive`) — live ไม่เคยเห็น;
   ที่เห็นจริงคือ Caught+RescueAvailable แทน Revivable และ Active แทน Revived
6. `CrossingState` attr — ไม่มีจริง; ใช้ Session.Phase + zone แทน
7. `TouchAutoMelee` set ผ่าน prefs — ยังไม่ได้ทดสอบ

---
*FINAL — spec ครบสองฝั่ง + live-verified · รวมกับ CATCHER_SPEC_FINAL.md §D*
