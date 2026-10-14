# CATCHER DEEP-DIVE — Huss Valley
Source: live dump (21 players, 2 catchers in active match) + `require()`/`decompile` of
client-visible game modules via bf_cmd channel, job live in client @2976.

## 1. COMPONENTS

### LocalScripts (PlayerScripts)
| script | role |
|---|---|
| `TackleInputClient` | tackle input → gates → `GameAction:FireServer("Tackle",…)` |
| `CatcherReachClient` | writes `ReachPhase/ReachDirection/ReachTargetUserId` onto catcher chars (match-time only) |
| `MeleeInputClient` | dagger stab input → `MeleeEvent` + DaggerState gate |
| `HitReplayClient` | replays/verifies hit events client-side |
| `CombatPrediction` (module) | local swing tracking + `HitReplayEvent:FireServer` contact reports |
| `GuardClient` | MovementGuard warnings (server→client) |
| `CatchFeedbackClient` | catch results feedback |
| `TackleDebugClient` | dev overlay (tied to `ShowDebugHitboxes` attr) |
| `PerfectDodgeClient` | perfect-dodge detection/FX |
| `RescueClient` | rescue flow (RescueConfig: Range=7, Hold=0.3s, max 1/crossing) |

### Modules (RS.ChickenOrHero.Game) — real values extracted
**ContactCatchConfig** (melee/contact catch box):
```
HandRadius=3.05  HitHalfWidth=1.4  RunnerRadius=0.9  ContactPadding=0.35
MinForward=-0.5  Height=2.8  OverlapRadius=1.9  BoxScale: player=1, bot=0.95
ReachDistance=12  ReachHalfAngle=75°  ReachFadeRate=18
TrackingWeight=0.45  WindupWeight=0.9
CommitBaseDistance=2.15  CommitLeadTime=0.07  CommitDistance=5.25  CommitHalfAngle=65°
Windup=0.12s  ActiveDuration=0.18s  Recovery=0.55s
WindupAimLimit=±20°  WindupAimRate=180°/s
MaxObservedSpeed=90  MaxSweepGap=0.15  MaxSweepDistance=12
```
→ Melee hit box (players): width=5.3, height=5.6, near=-0.5 (hits half a stud BEHIND!), far=4.3 studs, overlap=1.9.

**GameConfig.Tackle:**
```
Duration=0.4  Recovery=0.6  Cooldown=1.1  MaxDistance=15
DistanceMultiplier=1.15  RunDistanceMultiplier=1.45  BoostStrength=0.7
Animation=DaggerDive  Width=3.4  Height=5  RunnerRadius=0.9
Variants (chosen by SpeedRatio=entrySpeed/maxSpeed):
  Short  (ratio≥0):   Reach=4    Dist=2×SS(=2.4)   HumanBox Reach=4.5
  Medium (ratio≥0.4): Reach=4.75 Dist=4×SS(=4.8)   HumanBox Reach=5.5
  Long   (ratio≥0.8): Reach=5.5  Dist=7×SS(=8.4)   HumanBox Reach=6.5  (RunnerRadius 1.1, Width 4)
SpeedScale=1.2 → Long dive base travel ≈ max(9.66, entry×0.4×1.45) clamp 15 studs
```

**TacklePredictionConfig** (server-side tolerance for our tackle claims):
```
MaxRequestAge=0.5  PositionTolerance=2.5  SideTolerance=2.5  EntrySpeedTolerance=2
ReplicationAllowance=0.16  FutureTolerance=0.08  ConfirmTimeout=0.9
HistoryInterval=0.05  HistorySeconds=0.45  MaxSampleGap=0.2  MaxSweepDistance=12
PhysicsObservationLag=0.3
```

**MovementConfig:**
```
MaxSpeed=33.6  Accel=36  Decel=66  SpeedScale=1.2  StopThreshold=0.18
CatcherSpeedMultiplier=1.1   → catcher top speed ≈ 36.96 (matches live TackleEntrySpeed 36.96!)
RunnerSpeedMultiplier=1.06   → runner ≈ 35.6
RunnerAccelerationMultiplier=1.42
CatcherTurnRate=300°/s  TurnRetention90=0.65  RunnerTurnRetention90=0.72
JumpEnabled=false  InputDeadzone=0.05  StallSpeed=1.2  StallGrace=0.2  StallCap=7.2
```

**DaggerConfig:**
```
DrawDuration=0.9167s   (matches live: DaggerDrawStartedAt→DaggerReadyAt ≈ +0.92)
StabDuration=0.8333s   StabContactStart=0.05  StabContactEnd=0.5
StabDelay=Windup(0.12)  WindupRate=0.8  AimLimit=±30°  AimRate=18°/s
DiveDuration=0.62  GripInwardStuds=0.25  FadeIn=0.07  FadeOut=0.14
```

**RescueConfig:** Range=7, Hold=0.3s, MoveTolerance=14, MaxRescuesPerCrossing=1, FinishGrace=1.5
**ConnectionQualityConfig:** HighPingMs=180, 18 samples/3s, ChatPromptCD=120, PromptCD=600
**DonkeyKongMotion:** Radius=4, HitRadius≈5.98, Scale=2.5

### Remotes (catcher-relevant)
| remote | dir | payload | notes |
|---|---|---|---|
| `Game.GameAction` | C→S | `("Tackle",{id=GUID, at=serverTime, speed=flatVelMag, direction=flatLookUnit, position=hrp.Position})` | server replies OnClientEvent `("TackleResult",id,true,{readyAt,speed,startedAt})` |
| `Game.MeleeEvent` | C→S | `({id,at,direction,position})` | stab request |
| `Game.HitReplayEvent` | C→S | `{id,targetId,at,span≤0.08,origin,targetPosition,previousOrigin,previousTargetPosition}` | **client reports hits it computed locally** — server validates by replaying positions |
| `Game.HitboxDebugEvent` | ? | — | pairs with `ShowDebugHitboxes` attr |
| `Presentation.MovementGuardEvent` | S→C | warning payload | anti-cheat notice — listen only |
| `Game.ChronoView` | Unreliable | replication view | do not touch |
| `chrono.ClientHeartbeat` etc. | C→S | replication layer | never fire |

### Char attrs (live match, from real catchers paj6ng/khoanaza)
`TackleReach=5.5 TackleVariant="Long Dive" TackleAnimation=DaggerDive`
`TackleDuration≈0.32-0.38 TackleRecovery≈0.62-0.68` (scaled per-tackle by distance ratio)
`TackleEntrySpeed=31.4-37.0 TackleDirection=flatUnit TackleRequestId=GUID`
`TackleStartedAt/TackleActive/TackleReadyAt(player)=StartedAt+~1.1 (Cooldown)`
`DaggerState=Stowed/Held DaggerDrawStartedAt DaggerReadyAt=draw+0.92 DaggerEquipped DaggerAnimationsReady`
`CombatLife=1..83 (lives remaining)` `MovementLocked MovementReset(counter)`
`BoostDashName=DashLeft/DashRight BoostEffectAt DashVisualFacing`
`CrossingCatcherCount=2 CrossingRunnerCount=18 SpeedScale catch≈0.998 run≈1.003`
`__CHRONO_PRIMARY=HumanoidRootPart PhysicsController=Player ClientBot(bot flag)`
`SpawnFacing/SpawnFacingVersion CombatRelocation`

### Player attrs
`GameRole=Catcher/Runner/Lobby RunState=Active/Lobby InMatch`
`TackleReadyAt` (player-level cd) `AbilityReadyAt GearReadyAt`
`TouchAutoMelee=true` on most in-match players — **native auto-stab is a real toggle**
`CrossingBalanceNotice` JSON: `{"baseline":bool,"id":N,"role":"Catcher","turning":0,"speed":-0.22,"acceleration":-0.22,"catchers":2,"runners":18,"expiresAt":t}` — catchers get **−0.22 speed/accel penalty** in crossing balance; runners +0.32 speed +1.81 accel +0.43 turning.

### Session attrs (live)
`Phase=GroupRun MatchStep=GroupRun MatchStepDeadline EndsAt StartSide=A RunNumber=1`
`Notice="paj6ng was caught by khoanaza!" NoticeUntil` — catch feed
`ChoiceMoment={choice:"Hero",kind:"Chosen",userId,name,endsAt,verified}` — hero pick
`EscapeStreakState={count,eligible,matchId,goal:3,event:"Reset"}`
`HeroUserId LeadUserId SelectedUserId MatchHealth=Healthy MatchBuild`
`Announcement="RUN! Reach the opposite safe side!"`
`HitReplayDiagnostics Mode=ShadowOnly` — hit-replay runs shadow-validated, not authoritative-blocking
`PublicBotCount=0 PublicBotDifficulty=0.55`

## 2. STATE MACHINE

**Melee/contact catch** (from ContactCatchConfig + CombatPrediction):
```
Tracking ─(target in ReachDistance=12 & cone 75°)→ Windup
Windup   0.12s — dir steers toward target ±20° limit @180°/s; ReachPhase="Windup"
Active   0.18s — sweep box live (5.3w×5.6h, near=-0.5..far=4.3); ReachPhase="Active"
Recovery 0.55s — vulnerable, no hits
Total swing ≈ 0.85s. Server needs commit: dist≤CommitDistance(2.15+lead≤5.25)
& angle≤65° & |ΔY|≤2.8 at commit moment.
```

**Tackle** (TackleProfile.select at fire time):
```
Gate: on ground (FloorMaterial≠Air), !MovementLocked !TackleActive,
      DaggerEquipped→DaggerState=="Held", GameRole==Catcher, RunState==Active,
      !ControlGate.reason, cd remaining ≤0.02
Fire: dir=flat LookVector, speed=flat velocity mag → variant by speed/maxSpeed
      ratio≥0.8 (i.e. ≥~29.6 studs/s) → Long Dive
Dive:  Duration 0.4 scaled by distance ratio (observed 0.32-0.4)
       motion: blendIn=min(0.02,Dur*0.25) → cruise → brake=min(0.12,Dur*0.45)
Recovery: 0.6 + (Duration₂−scaledDur)  (observed 0.62-0.68)
Cooldown: ReadyAt = startedAt + 1.1 (server may override via TackleResult.readyAt)
Hit box during dive: 0.95×(Width3.4 + 2×0.9) ≈ 4.9w, height 4.75,
       far 0.95×(Reach+0.9): Short≈4.66 / Med≈5.37 / Long≈6.08 (vs humans +0.95)
```

**Hit claim path**: client CombatPrediction sweeps locally → raycast wall check →
fires `HitReplayEvent{id,targetId,at,span≤0.08,origin,targetPos,prevOrigin,prevTargetPos}` →
server validates via CombatClaimMath (replays positions, needs same reset/relocation/life/lives,
both active, neither safe) within tolerances (±2.5 studs, request ≤0.5s old).

## 3. ATTACK PARAMETERS — hard numbers

| param | value | source |
|---|---|---|
| Catcher max speed | 33.6×1.1 = **36.96** | MovementConfig |
| Runner max speed | 33.6×1.06 = **35.62** | same — catcher only +1.34 faster! |
| Tackle entry for Long Dive | ≥ 29.6 studs/s (0.8×36.96) | TackleProfile.select |
| Tackle cooldown | **1.1s** | GameConfig.Tackle.Cooldown |
| Tackle dive window | 0.4s base (0.32-0.4 scaled) | live attrs |
| Tackle reach (hit far) | 4.66/5.37/6.08 (+0.95 vs humans≈7.03 Long) | HitReplayMath.bounds |
| Tackle travel | up to 15 studs | MaxDistance |
| Melee far | 4.3 studs (box), plus 0.5 behind | ContactCatchConfig |
| Melee commit lock | ≤5.25 studs & ≤65° cone | canCommit |
| Reach telegraph begins | ≤12 studs & ≤75° cone | inReach |
| Dagger draw | 0.92s before first stab possible | DaggerConfig |
| Stab active window | 0.05→0.5 of 0.833s stab anim | DaggerConfig |
| Server position tolerance | ±2.5 studs, ≤0.5s old, sweep ≤12 studs | TacklePredictionConfig |
| Turn rate | catcher 300°/s (retention 0.65 at 90°) | MovementConfig |

## 4. BOT ADVANTAGES (what a god catcher does with this)

1. **Exact hit envelope**: bot knows far≈6.08/7.03 — humans guess. Tackle only when
   predicted victim sweep lands inside box (we can run HitReplayMath.sweep ourselves pre-fire!).
2. **Perfect dive timing**: entry speed ≥29.6 → always Long Dive — hold accel until threshold,
   never waste a 4-stud Short Dive.
3. **Dedup by TackleRequestId** + server `TackleResult.readyAt` → exact cooldown, zero wasted input.
4. **Lead-time targeting**: CommitLeadTime=0.07 + victim velocity → commit point = victimPos+vel×0.07;
   also steer ±20° during windup already built-in — just aim near, the game finishes it.
5. **Target selection by CombatLife** (1-83) → hit weakest first; prefer low-MovementReset
   (stable replication → claims validate easier).
6. **CatcherThreatIntensity** — server tells us OUR threat level vs each runner pair.
7. **TouchAutoMelee** — native auto-stab; hub could enable via PlayerPreferences instead of
   custom loop (server-endorsed melee = no anomaly).
8. **1.1s cycle**: at Long-Dive cadence a perfect catcher gets ~0.9 tackles/sec ceiling —
   track `TackleReadyAt` exactly instead of polling.
9. **Dive recovery punish-window on OTHER catchers** (as runner): their 0.6s+ recovery +
   1.1s cd → free passage after whiff.

## 5. UPGRADE PLAN (catcher side)

### P0 — live values (replace constants)
- `cfg = TackleProfile.select(GameConfig.Tackle, entrySpeed, maxSpeed)` locally → exact
  variant/reach/duration BEFORE firing; gate on ratio≥0.8 for guaranteed Long Dive.
- Read `TackleReadyAt`(player attr) + server `TackleResult.readyAt` as sole cooldown source.
- `DaggerReadyAt` + `DaggerState=="Held"` gate already partially in hub — keep + add draw wait 0.92s.

### P1 — smarter play
- Preflight sweep: run our own `HitReplayMath.sweep(me→me+dir×travel, victim→victim+vel×t, dir, box)`
  — fire tackle only when it returns true; ~100% hit rate vs human dodges.
- Target pick: `CombatLife` asc, distance ≤(Reach+vel×duration), prefer `MovementLocked=false`
  & no active Ghost (`GhostAbilityReadyAt` recently used → skip 3s).
- Track `TackleRequestId` of OUR request → reconcile `TackleResult`, drop stale.

### P2 — beyond human
- Threat radar: server-side `CatcherThreatIntensity` on each runner tells who panics.
- `EscapeStreakState`/`ChoiceMoment`/`Phase` — play around streak-breaks & hero moments.
- Perfect-cycle: input queue next tackle at `readyAt−0.03` → server sees max legal cadence.
- `ConnectionCheckMatches`/`HighPingWarning` → skip claims while flagged (they'd fail tolerance anyway).

### P3 — stay clean / hard don'ts
- **NEVER fire `HitReplayEvent` ourselves** — server replays real positions; fake claims = instant flag.
- Never touch `chrono.*`, `ClientHeartbeat`, `ChronoView`, `GoatAnalyticsEvent`.
- `MovementGuardEvent` = read-only; if warnings arrive, back off speed/teleports.
- Keep `at=workspace:GetServerTimeNow()` (server time!), real `position`, real `speed` —
  tolerance checks (±2.5 studs, ≤0.5s) mean lies fail anyway.
- Don't set attrs server owns (`GameRole`, `CombatLife`) — cosmetic only, server ignores/overwrites.

## 6. STILL NEEDED FROM MATCH DUMP
- `ReachPhase/ReachDirection/ReachTargetUserId` values live on catcher chars (CatcherReachClient
  writes them only mid-match) — confirm exact phase strings & timing vs config (Windup/Active).
- `Concealed` behavior (gear? ghost?) — seen only as false.
- `ClientBot`/`BotUserId` on `PublicBotCount>0` sessions — bot victim path differs (BotDirectory poses).
- `MatchSummary` StringValue content at match end.
- `TouchAutoMelee` — verify whether `PlayerPreferences:FireServer("SetTouchAutoMelee",true)` is honored.
- `MovementGuardEvent` actual payload shape (need a real warning).
- `HitReplayEvent` server ack path (reject reasons, if any).
