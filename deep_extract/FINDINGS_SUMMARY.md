# FINDINGS SUMMARY — Huss Valley (Chicken or Hero) place 107535308163741
รวมทุกข้อมูลที่ขุดได้จากเซสชัน decompile + live play · ปิดงาน 2026-10-10 ~13:05

═══════════════════════════════════════════════════════════════════
## 1. เดิมคิด vs ความจริง (ตารางแก้สเปก)
═══════════════════════════════════════════════════════════════════

| เดิมเข้าใจ | ความจริง (ยืนยัน) | แหล่ง |
|---|---|---|
| RunState = Lobby/Active/Caught | **5 ค่า:** Lobby/Waiting/Active/Safe/Caught — ไม่มี Revivable/Revived/Inactive ใน live | live log |
| Caught = จบตัว | **Caught→Active ได้** ผ่าน RescueKit self-revive (2/2 สำเร็จ) | live |
| Concealed = สถานะพราง | ไม่เคย true เลย — server targeting flag; ฝั่ง client ใช้ **`Cloaked`** | dump+live |
| Ghost = หายตัว | **`GhostImmuneUntil` = จับไม่ได้ 2s** + `Ghosted` visual · knife GhostScythe cd45 | decompile |
| Cloak ห้ามยิง | **`Cloaked` ยังโดนจับได้** ("still be hit") — skip เฉพาะ immune จริง | GearCatalog |
| Clone = ?? | CloneDagger: 2 clones 12s JukeChance0.65 cd45 · `CloneAbilityReadyAt/ActiveUntil` | decompile |
| Dash ทุกคนใช้ได้ | **Runner เท่านั้น** — catcher ไม่มี dash (จุดอ่อนใหญ่) | MovementConfig+live |
| WalkSpeed=0 = บั๊ก/freeze ผิดปกติ | **Lobby WS=0 ปกติ** — แต่ server ไม่ restore หลัง role-swap บางครั้ง → rejoin | live |
| Long Dive เกณฑ์ 29.6 ตายตัว | ต้อง scale ตาม `CrossingCatcherSpeedScale` สด | CrossingBalance |
| Rescue ต้องรอเพื่อน | ชุบเพื่อนได้ 1 ครั้ง/crossing + **RescueKit ชุบตัวเอง** | live ×3 |
| MatchSummary = capture needed | ได้ payload v2 เต็ม (participants/rankings/matchId) | findings |
| CatcherThreatIntensity = 0 เสมอ | **ขึ้นถึง 1 จริง** ตอนโดนล็อกใกล้ | findings 12:54 |

═══════════════════════════════════════════════════════════════════
## 2. Attributes ทั้งหมดที่พบ (ยืนยัน live ✓ / decompile ○)
═══════════════════════════════════════════════════════════════════

### Player attrs
| Attr | ค่า | หมายเหตุ |
|---|---|---|
| GameRole ✓ | Runner/Catcher/Lobby | เปลี่ยนทันทีจบ crossing |
| InMatch ✓ | bool | |
| RunState ✓ | Lobby/Waiting/Active/Safe/Caught | ครบ 5 ค่า live-verified |
| RunNumber ✓ | int | รอบปัจจุบัน |
| CombatLife ✓ | int | lives ที่เหลือ (15/16 catcher, 2-83 runner) |
| AbilityReadyAt ○ | serverTime | cd ability |
| GearReadyAt ○ | serverTime | cd item |
| GhostAbilityReadyAt ○ | serverTime | cd 45s |
| CloneAbilityReadyAt ○ | serverTime | cd 45s |
| CloneAbilityActiveUntil ○ | serverTime | clones 12s |
| CatcherThreatIntensity ✓ | 0→1 | เห็น =1 ตอนโดนล็อก |
| CatcherThreatUpdatedAt ○ | serverTime | |
| TackleReadyAt ✓ | serverTime | server override ผ่าน TackleResult |
| TouchAutoMelee ○ | bool prefs | เห็น true บนคนอื่น |
| Concealed ○ | false เสมอ | server flag ไม่เคย true |
| HighPingWarning ○ | bool | |
| ConnectionCheckMatches ○ | int | |
| Spectating ○ | bool | gate |
| FFALives/FFADownUntil/FFAImmuneUntil/FFAInvincible ○ | | FFA mode เท่านั้น |
| EscapeStreakState ○ | JSON | {count,eligible,matchId,goal:3} |
| CrossingBalanceNotice ○ | JSON | per-player balance |
| LastMatchAdmission(At) ○ | | |
| EquippedKnife ○ | skin id | GhostScythe/CloneDagger/CluckBasher/... |
| ClientReady/StatsLoaded/EconomyLoaded/TransferReady ○ | | init flags |
| AFK ○ | bool | PlayerPreferences("SetAFK") |
| AdminLevel/AdminTier ○ | | |
| FairPlayNoticeOpen ○ | bool | **เป็น gate ใน ControlGate** |

### Character attrs (match-only)
| Attr | หมายเหตุ |
|---|---|
| Ragdolled ✓ | ล้ม — ใช้ rescue gate |
| RescueAvailable ✓ | ชุบได้ |
| RescueHelperId ✓ | userId คนชุบ — เจอจริง 9838879287 |
| HitShielded ✓ | OneHitShield 0.75s — เจอทั้งตัวเอง+คนอื่น |
| Cloaked ○ | Cloak gear (โดนจับได้!) |
| Ghosted ○ | GhostScythe visual |
| BigDaggerActive ○ | catcher reach×2 |
| MovementLocked ✓ | ขยับไม่ได้ — บนตัวเราเอง |
| MovementReset ✓ | ตัวนับ reset (161→201 ขณะ freeze) |
| TackleActive/TackleStartedAt/TackleDirection/TackleVariant/TackleDuration/TackleEntrySpeed/TackleRecovery/TackleAnimation/TackleRequestId ✓ | dive state |
| DaggerEquipped/DaggerState/DaggerReadyAt/DaggerDrawStartedAt/DaggerSkin/DaggerAnimationsReady ✓ | Held/Stowed |
| BoostDashName/BoostEffectAt ✓ | DashLeft/DashRight + stamp |
| DashCooldownUntil/DashAnimationSequence/DashFromDirection/DashToDirection/DashVisualFacing ✓ | dash data (DashCooldownUntil=os.clock!) |
| CombatRelocation/PhysicsController/ClientBot/BotUserId ○ | |
| CrossingCatcherCount/CrossingRunnerCount/CrossingCatcherSpeedScale/CrossingRunnerSpeedScale ✓ | rubber-band สด |
| SpawnFacing(Version)/AnimationPackAvailable ○ | |

### Session attrs (RS.ChickenOrHero.Game.Session)
`Phase` ✓ (ครบ: Intermission/Countdown/Prepare/SelectHero/HeroChoice/ChoiceReveal/HeroRun/GroupRun/RunResolution/FinalRun/Results/MapVote) · `MatchStep` `MatchStepDeadline` `RunNumber` `MatchHealth` `MatchBuild` `ActiveMapId` `StartSide` `EndsAt` `GlobalPaused` `MapChanging` `HeroUserId` `LeadUserId` `SelectedUserId` `Notice`/`NoticeUntil`/`NoticeSound` `Announcement` `ChoiceMoment` `EscapeStreakState` `LobbyBotCount` `PublicBotCount` `PublicBotCatcherCount` `PublicBotDifficulty` `SpectateAvailable` `AdminMatchMode` `MapVoteState` `MatchSummary` ✓(v2 เต็ม)

═══════════════════════════════════════════════════════════════════
## 3. Remotes (ยิง/รับ)
═══════════════════════════════════════════════════════════════════
| Remote | ทิศ | ใช้ในระบบ |
|---|---|---|
| `Game.GameAction` | →("Tackle",{id,at,speed,direction,position}) / ←("TackleResult",id,ok,{readyAt,speed,startedAt}) | ✓ tackle |
| `Game.MeleeEvent` | →({id,at,direction,position}) / ←(id,ok,extra) | ✓ melee |
| `Game.RescueEvent` | →("Begin"/"Finish"/"Cancel", userId) | ✓ auto-rescue |
| `Gear.GearEvent` | →("UseAbility"/"Use", nil, dir, guid, nil, report?) | ✓ gear |
| `Weapons.GhostAbilityEvent` | →("Activate") / ←("Activated",userId) | ✓ |
| `Weapons.CloneAbilityEvent` | →("Activate") | ✓ |
| `Presentation.BoostRequest` | →(fromDir,toDir?) / ←("PerfectDodge") | listen+telemetry |
| `Game.PlayerPreferences` | →("SetAFK",bool) | prefs |
| `Game.MeleeInputMode` | →(bool) | touch claim |
| `Game.MapVoteEvent`/`MapVoteState` | →("Vote",id,token) / StringValue JSON | ✓ vote |
| `Weapons.ArmoryEvent` | →("Get"/"Equip"/"EquipGear"/"ClaimLikeReward"/"CheckRewards") | ✓ lobby |
| `Gear.StarterPackEvent` `Crates.CrateEvent` `Quests.QuestEvent` `Progression.JourneyEvent` `Admin.AdminEvent` `Admin.GiveawayEvent` `Admin.EventHostRemote` `Collectibles.GemEvent` `SpinWheelEvent` | free-claim/quests | ✓ lobby loop |
| **ห้ามยิง:** `HitReplayEvent` `MovementGuardEvent` `chrono.*` `GoatAnalytics` `ChronoView` | — | read-only เท่านั้น |

═══════════════════════════════════════════════════════════════════
## 4. โมดูลที่ถอด (decompiled)
═══════════════════════════════════════════════════════════════════
MovementConfig ✓ · TackleProfile ✓ · TackleMotion ✓ · TacklePredictionConfig+TacklePrediction ✓ · ContactCatchConfig (require fail→fallback) · ContactCatchGeometry ✓ · HitReplayMath ✓ · CombatPrediction ✓ · CombatClaimMath ✓ · GameConfig ✓ · CrossingBalance ✓ · GearCatalog ✓ · GearPredictionClient (63KB) ✓ · GearUseClient ✓ · AbilityUseClient ✓ · AbilityBuffVisuals ✓ · AirhornCone ✓ · ControlGate ✓ · BoostInput(+Client) ✓ · LocalLocomotion(Client) ✓ · GhostAbility(Client) ✓ · CloneAbility(Client+Config) ✓ · PerfectDodgeClient ✓ · RescueClient+RescueConfig ✓ · CatcherReachClient ✓ · MeleeInputClient ✓ · TackleInputClient ✓ · FFALivesClient ✓ · SafezoneSignsClient ✓ · GuardClient ✓ · CrossingBalanceNotice handler

═══════════════════════════════════════════════════════════════════
## 5. สถิติทดสอบจริงรวม (auto 100%)
═══════════════════════════════════════════════════════════════════
| Session | Runner | Catcher | หมายเหตุ |
|---|---|---|---|
| 11:52-11:54 | — | 4 kills/14 dives (29%) | ก่อน patch — พลาดเป้าเลี้ยวกลาง dive |
| 12:30-12:35 | rescue สำเร็จ + shield + perfect dodge | (freeze WS=0) | patch ใหม่ทำงาน |
| 12:51-12:57 | รอด4 จับ3(ชุบกลับ2) หลบ33 PD1 | 2 kills | rejoin แล้ว เต็มระบบ |
| 12:58-13:11 | **รอด15 จับ8 หลบ139 PD3 สกิล9** | ไล่4 ชุบ5 | ยาวต่อเนื่อง — รอด≈65% ของ crossings |

═══════════════════════════════════════════════════════════════════
## 6. ยังขาด (live-only) + เหตุผล
═══════════════════════════════════════════════════════════════════
1. `Concealed=true` — ไม่มี catcher เจอเป้า Cloak ตอนเราดู (server flag)
2. `Ghosted` attr — ไม่มีใครใช้ GhostScythe ในเฟรมที่ scan
3. `MovementGuardEvent` payload — ระบบเราไม่ violate เลยไม่เคยโดน
4. `BigDaggerActive` — ไม่มี catcher ใช้ BigDagger ตอนอยู่ด้วยกัน
5. `TouchAutoMelee` set — ยังไม่ได้ทดสอบเขียน prefs
6. BoostRequest payload ขาออกเต็ม — เห็นแค่ listener

## 7. คำแนะนำผู้สานต่อ
- **ระวัง:** ทุก action ต้องผ่าน gate เดิม — อย่าลด gate เพื่อความไว (Guard จับ timing)
- **ขยายได้:** route planner (ตอนนี้ greedy → เพิ่ม waypoint map จาก `dd_map_cframes.json`), gear sequencing ตอน chase (BearTrap→dive เห็นผลแล้ว), Multi-account เทส `FFACatchers` mode
- **ข้อมูลดิบ:** `dd_attributes.json`/`dd_values.json`/`dd_remotes.txt`/`dd_map_cframes.json`/`dd_index.json` ยังอยู่ใน backup — props/tree raws ถูกลบ (อยู่ใน backup เท่านั้น)
- **อัปเดต spec:** เจอค่าใหม่ → เพิ่มท้าย spec เป็น "ภาคผนวก N" ตามรูปแบบเดิม
