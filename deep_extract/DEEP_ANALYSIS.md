# DEEP ANALYSIS — Huss Valley (Chicken or Hero)
Data: lobby dump V4 @ job 7975bd7b, player esihz750, place 107535308163741
Generated from live DataModel — all values verified against files in this folder.

## 1. COMPLETENESS AUDIT

| item | claimed | actual | status |
|---|---|---|---|
| nodes | ~17,420 | 17,304 (sum of tree rows) | ✓ |
| prop rows | ~19,300 | 19,303 (15,000 + 4,303 across 2 files) | ✓ |
| attributes | 3,142 | 3,142 | ✓ |
| values | 635 | 635 | ✓ |
| pivots | 1,197 | 1,197 | ✓ |
| remotes | 63 | 63 (42 game + 21 PlayEmote bindables) | ✓ |
| sounds/images/meshes | 334/874/246 | 334/869/248 | ~ match (counts drifted run to run) |
| hidden (getnilinstances) | — | 0 | game does not nil-parent anything |
| skipped nodes | 0 | 0 | ✓ safeRead clean |

### Missing / thin spots
- `state_vars.json` EMPTY — postprocess regex matched no paths; state actually lives in `Session` attrs + `MapVoteState` StringValue (found manually).
- `Maps/Teams/StarterPack` roots empty by design.
- Match-state attrs NOT captured: `ReachPhase`, `ReachDirection`, `ReachTargetUserId` exist only on characters during active match (created by `CatcherReachClient`). `TackleActive=true` snapshots, live event objects, `Concealed=true` states — all require in-match dump.
- ServerStorage/ServerScriptService — client-invisible (expected).

## 2. DUMP vs HUB CROSS-CHECK (hz_valley.lua)

### Already wired correctly (keep)
- State: `GameRole/InMatch/RunState` via `attr()` — matches dump exactly (Lobby/Runner/Catcher; Active/Lobby).
- Telegraph: `ReachPhase/ReachDirection/ReachTargetUserId/TackleActive` read from catcher characters — correct mechanism, attrs confirmed to exist (match-time).
- Cooldowns: `AbilityReadyAt/TackleReadyAt/GhostAbilityReadyAt/CloneAbilityReadyAt` — timestamps confirmed live.
- `DaggerState=="Held"` melee gate — matches dump values (Stowed/Held).
- Session: `ActiveMapId/EndsAt/AdminMatchMode/MapChanging` — confirmed on `RS.ChickenOrHero.Game.Session`.
- Remotes bound: GameAction/MeleeEvent/RescueEvent/GearEvent/ArmoryEvent/MapVoteEvent/PlayerPreferences/MeleeInputMode/GhostAbilityEvent/CloneAbilityEvent/BoostRequest/SpinWheelEvent/QuestEvent/GemEvent/JourneyEvent/CrateEvent/EventHostRemote/AdminEvent/GiveawayEvent/StarterPackEvent — all present in dump.
- Crossing events: `CrossyRoad/DonkeyKong/FFACatchers` modes — dump shows `CrossingCatcherCount=2 CrossingRunnerCount=18` + speed scales live.
- Field geometry: SafezoneASide z=-128.5 / BSide z=+128.5, walls x∈[30,206], lines z=±116.5 — hub already locates Safezone*/Field.

### Discovered but NOT used by hub (gap list)
| data | where | meaning / opportunity |
|---|---|---|
| `CombatLife` | char attr (per player) | HP/lives remaining (5..83 seen) → target/catcher prioritization, "low HP" detection |
| `CatcherThreatIntensity`, `CatcherThreatUpdatedAt` | LP attr | SERVER's own threat metric for runners — read directly instead of recomputing |
| `TackleReach` (5.5 Long / 4 Short), `TackleDuration` (~0.32-0.4), `TackleRecovery` (~0.65), `TackleEntrySpeed` (31-37), `TackleVariant` | char attrs | EXACT dive geometry per catcher — replace constants with live values |
| `TackleRequestId` (GUID per tackle) | char attr | dedupe tackles by id instead of timing heuristics |
| `DaggerReadyAt`, `DaggerDrawStartedAt`, `DaggerAnimationsReady` | char attr | draw cooldown — don't melee before ready |
| `BoostDashName` (DashLeft/DashRight), `BoostEffectAt` | char attr | know which dash anim/cooldown active |
| `TouchAutoMelee` | LP attr | game has BUILT-IN auto-melee flag — may be settable via PlayerPreferences remote (safer than custom melee loop) |
| `Concealed` | LP attr | stealth/concealment state — currently always false; check which gear sets it |
| `ClientReady`, `InitialLoadingComplete`, `EconomyLoaded`, `StatsLoaded`, `TransferReady` | LP attrs | full readiness gate — safer action gating than timers |
| `HighPingWarning`, `ConnectionCheckMatches` | LP attrs | latency telemetry — throttle risky actions when flagged |
| `LastMatchAdmission`, `LastMatchAdmissionAt` | LP attrs | join outcome tracking |
| `AFK`, `AdminAuthorized`, `AdminLevel`, `AdminTier`, `CreatorAuthorized` | LP attrs | permission/flags — AdminEvent calls will fail as `AdminLevel=0` |
| `MapVoteState` JSON | RS.Game StringValue | `phase:Closed/current:Map1/token/options[]` — hub can read vote phase directly |
| `Session.LobbyBotCount`, `PublicBotCatcherCount`, `SpectateAvailable`, `MatchBuild` | Session attrs | bot presence + server build string |
| `CrateId` on CratePrompt (Celestial/Emote/Ember) | WS crates | farmable crate prompts via `fireproximityprompt` |
| `EventId=1296607916534661769` on JoinEventPrompt | WS + StarterPlayer | event join pad — keeper requeue target |
| `CrossingBalanceNotice` JSON | LP attr | per-player event balance data |
| `CrossingCatcherSpeedScale` (~0.998), `CrossingRunnerSpeedScale` (~1.003) | char attrs | exact speed modifiers during crossing |
| `Emotes.Daily*` attrs | RS | daily emote rotation (FastDancer/YaYaYing/DaBabyDance) |
| `GemBoostEndsAt`, `CoinBoostEndsAt` | LP attrs | active boost windows — prioritize gem runs while boosted |
| `JourneySeason=season_1`, `JourneyBadge`, `JourneyTitle` | LP attrs | season state for JourneyEvent claims |

### Remotes found but unused (42 total game remotes)
| remote | likely role | risk |
|---|---|---|
| `Game.MovementGuardEvent` | server→client anti-cheat warnings | LISTEN ONLY — hub already logs it; never fire |
| `Game.HitReplayEvent` | hit replay/validation channel | high — firing fake hits = obvious anti-cheat signal |
| `Game.HitboxDebugEvent` | dev hitbox visualization (`ShowDebugHitboxes` attr exists!) | safe to READ attr; firing may draw hitboxes |
| `Game.CrossyRoadEvent`, `Game.DonkeyKongEvent` | mini-event state/actions | medium — needed if automating events |
| `Game.LastRunnerChatEvent` | "last runner" chat | low |
| `Presentation.SpectateEvent` | spectate cam control | low — useful for scouting |
| `Presentation.SettingsEvent` | game settings (MusicMuted etc.) | low |
| `Presentation.ServerBrowserEvent` | server hop UI | low |
| `Presentation.ScreenTransition` | visual transitions | cosmetic |
| `Presentation.PrivateServerSettingsEvent` | PS admin settings | fails on non-VIP |
| `chrono.*` (ClientHeartbeat/ClientLoaded/SafeReplicate/ReplicateFull/ClientClockRelay/Stats) | replication layer | DO NOT fire — heartbeat/anticheat adjacent |
| `GoatAnalyticsEvent` | analytics | ignore |
| `Audio.Events`, `Audio.PresentationCues`, `Emotes.EmoteEvent`, `Weapons.ArmoryNavigation` | presentation | cosmetic |

## 3. KEY MECHANICS (extracted numbers)

- Tackle: reach 5.5 (Long Dive) / 4 (Short Dive), duration ~0.32-0.4s, recovery ~0.62-0.68s, entry speed 31-37, per-tackle GUID.
- Map1 field: crossing corridor x∈[30,206], A→z=-128.5, B→z=+128.5, goal lines z=±116.5. Water hazard exists.
- Balance: 2 catchers / 18 runners, speed scale ~0.998 catcher / ~1.003 runner.
- Voteable maps this session: Map1 THE VALLEY, Map3 HOMETOWN (phase was Closed — vote happens between matches).
- Crates: Celestial/Emote/Ember — each `CratePrompt` on Attachment with `CrateId` attr.
- SpinTheWheel prizes: 250Coins, 500Coins, 2xCoins, 2xGems.
- Replication: `chrono` custom replicator tags chars `CHRONO_MODEL_REPLICATOR` + `__CHRONO_PRIMARY=HumanoidRootPart`.
- UI system: dual UI (OldUIReskin + NewUI) selected by `UIVersion` attr (`Switchable` on root, per-player `OldUIReskin`/`OldUI`).

## 4. UPGRADE PLAN (prioritized)

### P0 — correctness vs live data
1. Replace hardcoded tackle constants with char attrs: `TackleReach`, `TackleDuration`, `TackleRecovery`, `TackleVariant` — dodge distance/duration becomes exact per catcher.
2. Use `TackleRequestId` to dedupe tackle telegraphs (currently inferred).
3. Add `DaggerReadyAt` + `DaggerAnimationsReady` to melee gate (hub already gates on `DaggerState`).
4. Read `CombatLife` for target selection (runner chasing weak runners / catcher avoiding strong ones).

### P1 — new capabilities from discovered data
5. `CatcherThreatIntensity` — display server's threat metric in HUD/status line.
6. `Session.EndsAt` countdown + `MapChanging` guard — pause actions during transitions.
7. `MapVoteState.phase` — auto-vote only during `Voting` phase with current `token`.
8. `BoostDashName`/`BoostEffectAt` — correct dash direction selection.
9. Readiness gate: `ClientReady && InitialLoadingComplete && StatsLoaded` before firing remotes.
10. `GemBoostEndsAt/CoinBoostEndsAt` — bias gem/coin routes while boosted.

### P2 — farm/features
11. Crate farmer: fire `CratePrompt` (CrateId Celestial/Emote/Ember) when `Armory`/crate cooldown ready — currently zero crate automation.
12. `TouchAutoMelee` — test setting true via `PlayerPreferences`; if honored, native auto-melee beats custom loop (lower anti-cheat footprint).
13. `ShowDebugHitboxes`/`HitboxDebugEvent` — visualize server hitboxes for tuning dodge ranges.
14. Event handlers: `CrossyRoadEvent`/`DonkeyKongEvent` state read for event-mode tactics (already detect mode via `AdminMatchMode`).
15. `LastMatchAdmission` — log join outcomes for keeper requeue diagnostics.

### P3 — watch-only / do-not-touch
16. `MovementGuardEvent` — keep listen-only (already done).
17. `HitReplayEvent`, `chrono.*`, `GoatAnalyticsEvent` — never fire.
18. `SpectateEvent`/`SettingsEvent`/`ServerBrowserEvent` — optional QOL.

## 5. DEPTH ASSESSMENT

- Captured: full client DataModel — 17.3k nodes, every attr/value/remote/asset/pivot/GUI tree. Nothing client-visible was skipped (0 errors).
- Not reachable client-side: ServerStorage/ServerScriptService internals, server-side hit validation code, RNG tables behind remotes.
- Requires in-match state for: ReachPhase telegraph attrs, live gem layout (`LocalRunnerGems` populated per-match), event objects, `Concealed`, TackleActive=true telemetry, post-vote map variants (Map2/Map3 trees load only when that map wins).
- Conclusion: lobby layer is at full depth; match layer is the remaining frontier — the armed dumper will complete it when `InMatch=true`.
