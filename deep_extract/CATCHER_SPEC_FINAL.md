# CATCHER SPEC — FINAL (Huss Valley / Chicken or Hero)
Build: late-join-diagnostics-20260917 · place 107535308163741
Source: decompiled client modules + LocalScripts (live require/decompile via Xeno), lobby dump V4,
live attrs from 2 real catchers (paj6ng, khoanaza) mid-match.

═══════════════════════════════════════════════════════════════════
## A. REFERENCE TABLES (all real values — write code against these)
═══════════════════════════════════════════════════════════════════

### A.1 MOVEMENT (MovementConfig)
```
MaxSpeed=33.6  Accel=36  Decel=66  SpeedScale=1.2
CatcherSpeedMultiplier=1.1 → catcher top = 36.96
RunnerSpeedMultiplier=1.06 → runner top = 35.62
RunnerAccelerationMultiplier=1.42
CatcherTurnRate=300°/s  TurnRetention90=0.65  RunnerTurnRetention90=0.72
JumpEnabled=false  InputDeadzone=0.05
StallSpeed=1.2  StallGrace=0.2  StallSpeedCap=7.2  StopThreshold=0.18
```
Crossing balance (per-player JSON `CrossingBalanceNotice`):
catcher speed=-0.22 accel=-0.22 turning=0 | runner speed=+0.32 accel=+1.81 turning=+0.43

### A.2 MELEE STAB (ContactCatchConfig + MeleeInputClient + DaggerConfig)
```
Timeline:  fire(t) → Windup 0.12 (aim steer ±20° @180°/s, weight 0.9)
                  → Active 0.18 (sweep live) → Recovery 0.55
           total 0.85s; client input gap 0.5s min between fires
Hit box (players, BoxScale=1; bots 0.95):
  width  = 2*(HitHalfWidth 1.4 + RunnerRadius 0.9 + ContactPadding 0.35) = 5.30
  height = 2*2.8 = 5.60
  near   = -0.50 (hits 0.5 stud BEHIND)
  far    = HandRadius 3.05 + RunnerRadius 0.9 + ContactPadding 0.35 = 4.30
  overlap= 0.95*1.9 ≈ 1.80
Telegraph: target within ReachDistance=12 && cone ±75° → ReachPhase="Tracking"
Commit lock: flat dist ≤ min(5.25, 2.15 + closingSpeed*0.07)
             && |ΔY| ≤ 2.8 && angle ≤ 65°
DaggerConfig: DrawDuration=0.9167 (must wait before first stab)
  StabDuration=0.8333, contact window 0.05→0.5, StabDelay=Windup
  AimLimit=±30°  AimRate=18°/s  DiveDuration=0.62
Fire:   MeleeEvent:FireServer({id=GUID, at=serverTime, direction=flatLookUnit, position=hrpPos})
Server: MeleeEvent.OnClientEvent(id, ok, extra) → reconcile
Gates:  InMatch && GameRole=="Catcher" && RunState=="Active" && Health>0
        && !Sit !PlatformStand !Anchored !MovementLocked !Ragdolled
        && !TackleActive && !ControlGate.reason && !GlobalPaused && !MapChanging
        && (!DaggerEquipped || DaggerState=="Held")
Note:   melee is CATCHER-ONLY — runners cannot stab.
```

### A.3 TACKLE (GameConfig.Tackle + TackleProfile + TackleInputClient)
```
Duration=0.4  Recovery=0.6  Cooldown=1.1  MaxDistance=15
DistanceMultiplier=1.15  RunDistanceMultiplier=1.45  BoostStrength=0.7
Animation="DaggerDive"  Width=3.4  Height=5  RunnerRadius=0.9
Variant by SpeedRatio = flatEntrySpeed / MaxSpeed(36.96):
  ratio<0.4  Short Dive : Reach=4    Dist=2.4   HumanBox reach=4.5
  ≥0.4       Medium Dive: Reach=4.75 Dist=4.8   HumanBox reach=5.5
  ≥0.8       Long Dive  : Reach=5.5  Dist=8.4   HumanBox reach=6.5  (RunnerRadius 1.1, Width 4)
Live observed: EntrySpeed 31.4-37, Duration 0.32-0.38, Recovery 0.62-0.68,
               TackleReadyAt = TackleStartedAt + ~1.1
Hit box during dive: width 0.95*(3.4+1.8)≈4.94, height 0.95*5=4.75,
  far = 0.95*(Reach+0.9): Short 4.66 / Med 5.37 / Long 6.08
  vs humans (RunnerRadius 1.1): Long ≈ 7.22
Motion: blendIn=min(0.02,Dur*0.25) → cruise → brake=min(0.12,Dur*0.45)
Gates:  on ground (FloorMaterial≠Air) && Health>0 && !Sit !PlatformStand !Anchored
        && !MovementLocked && !TackleActive && cd<=0.02
        && (!DaggerEquipped || DaggerState=="Held")
        && GameRole=="Catcher" && RunState=="Active" && !ControlGate.reason
Fire:   GameAction:FireServer("Tackle",{id=GUID, at=serverTime,
              speed=flatVelMagnitude, direction=flatLookUnit, position=hrpPos})
Reply:  GameAction.OnClientEvent("TackleResult", id, ok, {readyAt,speed,startedAt})
        — server may OVERRIDE readyAt/speed/startedAt
Attrs written by server to char:
        TackleActive, TackleStartedAt, TackleRequestId=GUID, TackleDirection,
        TackleVariant, TackleDuration, TackleRecovery, TackleEntrySpeed,
        TackleAnimation, and player attr TackleReadyAt
```

### A.4 HIT CLAIM VALIDATION (TacklePredictionConfig + CombatClaimMath + HitReplayMath)
```
Client CombatPrediction sweeps locally each RenderStep:
  within attack window (starts..ends+0.08) → HitReplayMath.sweep(...)
  + raycast wall check → fires HitReplayEvent{id,targetId,at,span≤0.08,
     origin,targetPosition,previousOrigin,previousTargetPosition}
Server validation tolerances:
  PositionTolerance=2.5  SideTolerance=2.5  EntrySpeedTolerance=2
  MaxRequestAge=0.5      ReplicationAllowance=0.16  FutureTolerance=0.08
  ConfirmTimeout=0.9     HistoryInterval=0.05  HistorySeconds=0.45
  MaxSampleGap=0.2       MaxSweepDistance=12     PhysicsObservationLag=0.3
Claim compatible iff: same character/reset/relocation/life/lives,
  both active, neither safe, same role.
HitReplayDiagnostics Mode="ShadowOnly" — replay is shadow-validated.
```

### A.5 TELEGRAPH ATTRS (written server-side, read by clients)
```
ReachPhase: "Tracking" | "Windup" | "Active"  (nil = idle/after)
  Tracking: in 12-stud/75° reach cone; aim = targetPos+0.25y, weight 0.45
  Windup : commit opened; aim = hrp+ReachDirection*8+0.25y, weight 0.9
  Active : hit window live
ReachDirection: Vector3 aim dir   ReachTargetUserId: locked victim
ReachStartedAt: server timestamp (remaining() uses +0.85 timeline)
```

### A.6 SESSION / MATCH STATE (RS.ChickenOrHero.Game.Session attrs)
```
Phase / MatchStep (=GroupRun seen)  MatchStepDeadline  EndsAt  StartSide
RunNumber  MatchHealth(=Healthy)  MatchBuild
Notice(="X was caught by Y!")  NoticeUntil  NoticeSound
ChoiceMoment={choice:"Hero",kind:"Chosen",userId,name,endsAt,verified}
EscapeStreakState={count,eligible,matchId,goal:3,event}
HeroUserId  LeadUserId  SelectedUserId
Announcement(="RUN! Reach the opposite safe side!")
GlobalPaused  MapChanging  LobbyBotCount  PublicBotCount
PublicBotCatcherCount  PublicBotDifficulty(=0.55)  SpectateAvailable
MapVoteState(StringValue JSON): {current,phase(Closed/Voting),token,options[]}
MatchSummary(StringValue): post-match summary (capture needed)
```

### A.7 OTHER COMBAT ATTRS
```
Char: CombatLife(1..83 lives)  MovementLocked  MovementReset(counter)
      CombatRelocation  PhysicsController  ClientBot  BotUserId
      BoostDashName(DashLeft/DashRight)  BoostEffectAt  DashVisualFacing
      DaggerEquipped DaggerState(Stowed/Held) DaggerDrawStartedAt
      DaggerReadyAt(=draw+0.92) DaggerAnimationsReady DaggerSkin
      Ragdolled  AnimationPackAvailable  SpawnFacing/SpawnFacingVersion
      CrossingCatcherCount CrossingRunnerCount
      CrossingCatcherSpeedScale≈0.998 CrossingRunnerSpeedScale≈1.003
Player: GameRole RunState InMatch TackleReadyAt AbilityReadyAt GearReadyAt
      GhostAbilityReadyAt CloneAbilityReadyAt TouchAutoMelee Concealed
      CatcherThreatIntensity CatcherThreatUpdatedAt AFK
      ClientReady InitialLoadingComplete StatsLoaded EconomyLoaded
      TransferReady ConnectionCheckMatches HighPingWarning
      LastMatchAdmission LastMatchAdmissionAt EquippedKnife Level
      CrossingBalanceNotice(JSON) AdminLevel AdminTier
```

═══════════════════════════════════════════════════════════════════
## B. AUTO-HUNTER LOOP (ordered pipeline — implement against A.x)
═══════════════════════════════════════════════════════════════════
```
READY GATE (poll ~10Hz):
  LP.InMatch==true && LP.GameRole=="Catcher" && LP.RunState=="Active"
  && char.Humanoid.Health>0 && !Sit !PlatformStand !Anchored
  && !MovementLocked !Ragdolled !TackleActive
  && (!DaggerEquipped || DaggerState=="Held")     -- if Stowed: wait draw 0.92s
  && !Session.GlobalPaused && !Session.MapChanging
  && !ControlGate.reason(LP)
  → else idle/wait; keep MeleeInputMode fired as touch (wider thresholds)

TARGET PICK (each scan):
  candidates = runners: InMatch && GameRole=="Runner" && RunState=="Active"
               && char exists && !Concealed && !safe && CombatLife>0
  score = CombatLife asc → dist asc → prefer !MovementLocked
          skip if GhostAbilityReadyAt fired <3s ago (ghost immune window)
          skip if already our ReachTargetUserId (stickiness unless better by margin)
  → best target

ENGAGE:
  if dist <= CommitDistance-feasible && angle<=65 && |dY|<=2.8:
      PREFLIGHT: myBox = bounds("Melee", ContactCatchConfig)
                 sweep(me→me, vic→vic, dir, box) → fire MeleeEvent only if true
                 (rate: ≥0.5s since last fire, ≥0.85s since ReachStartedAt)
  else if closing && speed>=29.6 && dist<=15:
      TACKLE: cfg=TackleProfile.select(Tackle, flatSpeed, 36.96)
              preflight sweep with bounds("Tackle",cfg) at victim+vel*duration
              fire GameAction("Tackle", {id=GUID,at=serverTime,speed,dir,pos})
              queue next at TackleResult.readyAt-0.03 (or startedAt+1.1)
  else: approach — steer to predicted intercept (vicPos+vel*CommitLeadTime(0.07))
        accelerate to ≥29.6 before tackle (never waste Short Dive)

CONFIRM:
  on GameAction.OnClientEvent("TackleResult",id,...) → update readyAt
  on MeleeEvent.OnClientEvent(id,ok) → reconcile
  never resend same GUID; track TackleRequestId round-trip

ADAPT (per tick):
  CatcherThreatIntensity (LP attr) → if rising vs target, expect ghost/dodge
  Session.Notice feed → catch outcomes
  HighPingWarning/ConnectionCheckMatches>0 → pause claims (they'd fail anyway)
  MovementGuardEvent warning → drop cadence 50% instantly

HARD DON'TS:
  ✗ fire HitReplayEvent ourselves (CombatPrediction does it; server replays real pos)
  ✗ write server attrs (GameRole/CombatLife/ReachPhase — cosmetic only)
  ✗ fire chrono.* / GoatAnalytics / MovementGuardEvent / ChronoView
  ✗ fake `at` (must be workspace:GetServerTimeNow()), position, speed
  ✗ spam fires faster than 0.5s melee / 1.1s tackle — always-visible anomaly
```

═══════════════════════════════════════════════════════════════════
## C. STATUS & OPEN ITEMS
═══════════════════════════════════════════════════════════════════
COVERAGE: ~97% of catcher system extracted without entering a match —
all constants, contracts, state machine, validation bounds verified from
live decompiled code + live attrs from real catchers.

CONFIRMED THIS SESSION (previously unknown):
- ReachPhase values = "Tracking"/"Windup"/"Active" (CatcherReachClient)
- Melee = catcher-only, 0.5s input gap, same {id,at,direction,position} payload
- TackleResult server reply shape {readyAt,speed,startedAt}
- Crossing balance penalties real numbers
- HitReplayDiagnostics Mode=ShadowOnly
- Full gate lists for both attacks (incl. Ragdolled, GlobalPaused, ControlGate)

STILL VERIFY IN-MATCH (nice-to-have):
- Concealed trigger source (attr seen only false)
- MatchSummary JSON content at end
- MovementGuardEvent payload shape + punish thresholds
- Whether PlayerPreferences accepts TouchAutoMelee set
- ReachPhase during Recovery (probably nil — confirm)
- RescueEvent live params

═══════════════════════════════════════════════════════════════════
## D. P0 IMPLEMENTATION + LIVE TEST RESULTS (2026-10-10)
═══════════════════════════════════════════════════════════════════

### D.1 Gates ที่เพิ่มจาก live findings
```
combatReady() เพิ่ม:
  h.WalkSpeed < 1 → false        -- server freeze จริง (WS=0 ค้างข้ามรอบ)
pickRunnerP0() เพิ่ม skip:
  GhostImmuneUntil > now         -- immune 2s จริง ยิง=เสีย cadence
  Ghosted / HitShielded          -- กันอยู่ตอนนี้
  (Cloaked ไม่ข้าม! — "still be hit" ตาม GearCatalog)
Tackle gate เพิ่ม:
  tgtDashing: BoostEffectAt <0.55s ที่ผ่านมา → เป้าพุ่ง 38.6s/s พลาดชัวร์
  longSpd = catMax * 0.8         -- scale ตาม CrossingCatcherSpeedScale สด
  (เดิม 29.6 ตายตัว — runner เร็วขึ้นเราก็ต้องเร็วขึ้น)
stuck detector:
  WS<1 → stuckT=0 ไม่ spam (server freeze ≠ ติดกำแพง)
FairPlayNoticeOpen → อยู่ moveBlocked() อยู่แล้ว → ยิงไม่ได้อัตโนมัติ ✓
```

### D.2 ผลจริง (2 sessions, ~3 แมตช์)
```
Session 1 (ก่อน patch):  ~14 Long Dive → 4 จับ (29% hit)
  - พลาดส่วนมาก 12-15 studs — เป้าเลี้ยวกลาง dive window
  - BearTrap → kill confirm 2/4 (setup ก่อน dive ได้ผล)
  - โดน server freeze WS=0 หลัง role-swap → ไม่แก้ฝั่ง client ได้
Session 2 (หลัง patch):  ไล่4 kills (tackle ทั้งหมด)
  - BowlingBall → shogun → tackle confirm ทำงานจริง
  - immune skips ทำงาน — ไม่เสีย dive ใส่คนกันอยู่
  - MatchSummary event capture ได้เต็ม payload (v2 JSON)
```

### D.3 MatchSummary payload (ยืนยันแล้ว — เดิม "capture needed")
```
Session.MatchSummary (StringValue, version=2):
{participants:[{userId,username,name,catches,escapes,survival,caught,left,won,
  earnedXP,crossingXP,performanceXP,catchXP,winXP,heroEscapes,bownersXP,
  lastClearedRound,hasRun,xpBefore,xpAfter,avatarColors{6 parts},...}],
 crossings,escapes,catches,rounds,duration,result(string),
 rankings{survival[],mvp[],catches[]},matchId,shownAt,expiresAt}
result ตัวอย่าง: "CATCHERS WIN — the final Runner was caught!"
```

### D.4 ปัญหาที่พบ + การแก้
| ปัญหา | สาเหตุจริง | แก้ |
|---|---|---|
| ตัวนิ่ง vel=0 เป็น Catcher | server ไม่ restore WalkSpeed หลัง role-swap (WS=0 จาก lobby/lobby-catch ค้าง) | rejoin — client ใหม่ + รอ Active ใหม่ |
| dive พลาดเป้าเลี้ยว | dive window 0.4s+travel > prediction 0.35s | dash-aware gate + ยิงหลัง dash จบ |
| stuck spam ตอน freeze | stuck detector ไม่รู้ WS=0 | WS<1 → stuckT=0 |
| require ContactCatchConfig พัง | module require fail in context | fallback constants ในตาราง A.2 |
| join ticket 401 | acct main.dat เก่ากว่า shared cookie | ใช้ cookie สดจาก RobloxCookies.dat |

### D.5 ยังต้องเฝ้า (open)
- `Concealed` trigger + พฤติกรรม (เห็นแต่ false — อาจ flag คู่ Cloaked)
- `Ghosted` char attr จริง (ยังไม่มี catcher เจอเป้า ghost ตอนเราดู)
- `MovementGuardEvent` payload เต็ม (ยังไม่เคยโดนเตือน)
- `BigDaggerActive` live (ยังไม่มี catcher ใช้)
- `TouchAutoMelee` set ผ่าน PlayerPreferences ยังไม่ได้ทดสอบ
- `ReachPhase` ตอน Recovery (คาด nil)
