-- ═══════════════════════════════════════════════════════════
--  HZ HUB — HUSS VALLEY (ChickenOrHero) v2.2
--  สร้างจาก dump จริง HZMapDump_107535308163741_155135
--  ลายเซ็น remote ทุกตัว = ของเกมจริง (ไม่เดา)
--  ใช้: loadstring(readfile("hz_valley.lua"))()
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local WS = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local log -- forward: ถูกเรียกใน callback ก่อนบรรทัดที่นิยามจริง
local rp  -- forward: telemetry → worker (ผูกกับ BUILD.ping หลังโหลด UI)
-- guard: ครอบทุก loop/handler — error ไม่ฆ่า thread แต่ถูก log แทน
local function guard(name, f)
	return function(...)
		local ok, e = pcall(f, ...)
		if not ok then log("[ERR][" .. name .. "] " .. tostring(e)) end
	end
end

if getgenv().HZ_VALLEY then getgenv().HZ_VALLEY() end
local KILL = false
getgenv().HZ_VALLEY = function() KILL = true end

-- backup ตัวเก่าอัตโนมัติทุกครั้งก่อนรันใหม่
pcall(function()
	local old = readfile("hz_valley.lua")
	if old and #old > 100 then
		makefolder("hz_backups")
		writefile("hz_backups\\hz_valley_" .. os.date("%H%M%S") .. ".lua", old)
	end
end)

-- ─── remotes (path จริงจาก dump) ───
local CoH = RS:WaitForChild("ChickenOrHero")
local rGameAction = CoH.Game:WaitForChild("GameAction")        -- ("Tackle",{id,at,speed,direction,position})
local rMelee = CoH.Game:WaitForChild("MeleeEvent")             -- ({id,at,direction,position})
local rRescue = CoH.Game:WaitForChild("RescueEvent")           -- ("Begin"/"Finish"/"Cancel", userId)
local rClone = CoH.Weapons:WaitForChild("CloneAbilityEvent")   -- ("Activate")
local rGhost = CoH.Weapons:WaitForChild("GhostAbilityEvent")   -- ("Activate")
local rBoost = CoH.Presentation:WaitForChild("BoostRequest")   -- (fromDir, toDir)
local rSpin = CoH:FindFirstChild("SpinWheelEvent")             -- ("Spin")
local rQuest = CoH.Quests:FindFirstChild("QuestEvent")         -- (action, id)
local rMapVote = CoH.Game:FindFirstChild("MapVoteEvent")       -- ("Vote", mapId, token)
local rMapVoteState = CoH.Game:FindFirstChild("MapVoteState")  -- StringValue JSON {token, options, phase}
local rPrefs = CoH.Game:WaitForChild("PlayerPreferences")      -- ("SetAFK", bool) — เกมใช้ปิดการเข้าแมตช์
local rMeleeMode = CoH.Game:FindFirstChild("MeleeInputMode")   -- (bool isTouch) — claim touch = เกณฑ์ melee/dash กว้างกว่า
if rMeleeMode then pcall(function() rMeleeMode:FireServer(true) end) end
local rGem = CoH.Collectibles:FindFirstChild("GemEvent")       -- ("Sync")
local KnifePerks -- อ่าน perk มีดจริง (speed/cd bonus) — ใช้โชว์ในการ์ด + log ตอนสวม
pcall(function() KnifePerks = require(CoH.Weapons:FindFirstChild("KnifePerks")) end)
local rGear = CoH.Gear:FindFirstChild("GearEvent")             -- ("UseAbility", nil, dir, guid, nil, report) — สกิลสวม
local rArmory = CoH.Weapons:FindFirstChild("ArmoryEvent")      -- ("Get"/"Equip"/"EquipGear"/"ClaimLikeReward"/"CheckRewards")
local rAdmin = CoH.Admin and CoH.Admin:FindFirstChild("AdminEvent")           -- AwardAck/AwardReady/Command
local rGiveaway = CoH.Admin and CoH.Admin:FindFirstChild("GiveawayEvent")     -- ("Sync")
local rStarter = CoH.Gear and CoH.Gear:FindFirstChild("StarterPackEvent")     -- ("Get")
local rJourney = CoH.Progression and CoH.Progression:FindFirstChild("JourneyEvent") -- ("Get"/"ClaimAll"/"Claim",key,SeasonId) — รางวัล season ฟรี
local rCrate = CoH.Crates and CoH.Crates:FindFirstChild("CrateEvent")         -- ("Get"/"Open"/"Ack") — crates
local rEventHost = CoH.Admin and CoH.Admin:FindFirstChild("EventHostRemote")  -- admin event: EventState/BoostEnabled/Announcement
local conns = {} -- connections ทั้งหมด (disconnect ตอน KILL กัน listener ค้าง/ซ้อนตอน relogin)

-- ─── game modules (client-visible — ถอดจาก dump สด: require ได้ตรง) ───
local HitReplayMath, CCC, CatchGeom, TackleCfg, TackleProfile, MoveCfg
pcall(function() HitReplayMath = require(CoH.Game:WaitForChild("HitReplayMath")) end)
pcall(function() CCC = require(CoH.Game:WaitForChild("ContactCatchConfig")) end)
pcall(function() CatchGeom = require(CoH.Game:WaitForChild("ContactCatchGeometry")) end)
pcall(function() TackleProfile = require(CoH.Game:WaitForChild("TackleProfile")) end)
pcall(function() MoveCfg = require(CoH.Movement:WaitForChild("MovementConfig")) end)
pcall(function() TackleCfg = require(CoH.Game:WaitForChild("GameConfig")).Tackle end)
-- ค่า Tackle ถอดจาก GameConfig จริง (ใช้เมื่อ require พัง — ตัวเลขเดียวกับเซิร์ฟเวอร์)
local TACKLE_FALLBACK = {
	Duration = 0.4, Recovery = 0.6, Cooldown = 1.1, MaxDistance = 15,
	DistanceMultiplier = 1.15, RunDistanceMultiplier = 1.45, BoostStrength = 0.7,
	Width = 3.4, Height = 5, Reach = 4, RunnerRadius = 0.9,
	Variants = {
		{ Name = "Short Dive",  MinSpeedRatio = 0,   Reach = 4,    Distance = 2.4 },
		{ Name = "Medium Dive", MinSpeedRatio = 0.4, Reach = 4.75, Distance = 4.8 },
		{ Name = "Long Dive",   MinSpeedRatio = 0.8, Reach = 5.5,  Distance = 8.4 },
	}
}
-- fallback ค่าจาก dump (require พัง = ใช้ตัวเลขที่ถอดได้ — ไม่ใช่ค่าที่ตั้งเอง)
local CATCH = {
	far = CCC and (CCC.HandRadius + CCC.RunnerRadius + CCC.ContactPadding) or 4.3,
	height = CCC and CCC.Height or 2.8,
	commitBase = CCC and CCC.CommitBaseDistance or 2.15,
	commitLead = CCC and CCC.CommitLeadTime or 0.07,
	commitMax = CCC and CCC.CommitDistance or 5.25,
	commitAngle = CCC and CCC.CommitHalfAngle or 65,
	windup = CCC and CCC.Windup or 0.12,
	activeDur = CCC and CCC.ActiveDuration or 0.18,
}
local CAT_MAXSPD = (MoveCfg and MoveCfg.MaxSpeed or 33.6) * (MoveCfg and MoveCfg.CatcherSpeedMultiplier or 1.1) -- 36.96
local LONG_DIVE_SPD = CAT_MAXSPD * 0.8 -- ≥29.6 = Long Dive เท่านั้น (TackleProfile.select จริง)
local tackleReadyAt = 0 -- server readyAt จริงจาก TackleResult (override attr)
local meleeReadyAt = 0  -- idem จาก MeleeEvent ack
local guardSlowUntil = 0 -- MovementGuard warning → หยุดยิงชั่วคราว (ลด footprint)

-- TackleResult/MeleeEvent ack: server ส่ง readyAt จริงกลับ — คูลดาวน์ต้องอ่านตัวนี้
conns[#conns + 1] = rGameAction.OnClientEvent:Connect(guard("tackle-res", function(ev, id, ok, extra)
	if ev == "TackleResult" and ok and type(extra) == "table" and type(extra.readyAt) == "number" then
		tackleReadyAt = extra.readyAt
	end
end))
conns[#conns + 1] = rMelee.OnClientEvent:Connect(guard("melee-ack", function(id, ok) -- ack จริง: reject = log เตือนเจาะระบบ
	if ok == false then log("[!] melee ถูก server ปฏิเสธ id=" .. tostring(id)) end
end))
local eventMode, eventEndsAt = nil, 0
if rEventHost then
	conns[#conns + 1] = rEventHost.OnClientEvent:Connect(guard("evtHost", function(a, st)
		if a == "EventState" and type(st) == "table" and st.mode then
			eventMode, eventEndsAt = st.mode, st.endsAt or 0
			if eventEndsAt > WS:GetServerTimeNow() then
				log("[EVENT] LIVE: " .. tostring(st.mode) .. " เหลือ " .. math.floor(eventEndsAt - WS:GetServerTimeNow()) .. "s" .. (st.mode == "DoubleGems" and " — เพชร×2 ฟาร์มเลย!" or ""))
			end
		elseif a == "BoostEnabled" then
			log("[BOOST] เปิด: " .. tostring(st and (st.mode or st.kind) or st))
		elseif a == "Announcement" and type(st) == "table" then
			log("[ประกาศ] " .. tostring(st.text or st.title or "ประกาศจาก host"))
		end
	end))
	task.delay(3, function() pcall(function() rEventHost:FireServer("PublicSync") end) end) -- ถาม event ที่กำลังรัน
end

local cfg = {
	Enabled = true,
	AutoPlay = true,     -- บอทเล่นเอง: Runner วิ่งข้าม / Catcher ไล่จับ
	AutoTackle = true,   -- catcher: tackle runner ใกล้สุด (≤15) ทุก cooldown 1.1s
	AutoMelee = true,    -- catcher: melee runner ใกล้สุด (≤5 ระยะมือ)
	AutoDash = true,     -- dash เดินหน้าเรื่อยๆ (cd 1.1s) เร็วขึ้น
	AutoAbility = true,  -- ใช้ Clone/Ghost เมื่อพร้อม
	AutoSpin = true,     -- หมุน SpinWheel ฟรีใน lobby ทุก 15s
	Dodge = true,        -- runner: หลบ catcher ที่บีบเข้ามา
	AutoVote = true,     -- vote แมพอัตโนมัติ
	AutoQuest = true,    -- claim เควส daily/event อัตโนมัติ
	DodgeDash = true,    -- dash หลบตามปฏิกิริยา (catcher พุ่งใส่ = dash ตั้งฉาก)
	GodMode = true,      -- อ่าน telegraph ของเกม (ReachPhase/TackleActive) หลบก่อนโดน 0.3s
	AutoGear = true,     -- ใช้สกิลสวม (Cloak/Airhorn/Leash/Ball/Dagger) ตามสถานการณ์
	AutoEquip = true,    -- สวมสกิล+มีดที่ดีสุดใน lobby อัตโนมัติ (มีด Legendary = +0.85 speed)
	SpeedTrick = true,   -- สาย dev: เซ็ต attr ฝั่ง client (GearBoost/CrossingSpeedScale) เกมอ่านค่าท้องถิ่น
	FreeClaim = true,    -- claim ของฟรีทั้งหมด: LikeReward/CheckRewards/Award/Giveaway/StarterPack
	GemFarm = true,      -- เบี่ยงเก็บเพชรเฉพาะตอนปลอดภัย (ไม่เสี่ยงตายเพื่อเพชร)
	AutoTitle = true,    -- สวม Journey title ที่ดีสุดอัตโนมัติ (VALLEY ELITE/ROYALTY เหนือหัว)
	PlayHero = false,    -- HeroChoice: true=เลือก Hero(เหยี่ยว) / false=Chicken(ไก่)
	-- ปรับค่าได้จากเมนู (stepper)
	TackleRange = 18,    -- catcher: ระยะยิง tackle (Long dive จริง ~21m = travel15+hit6 + tolerance 2.5)
	MeleeRange = 6.4,    -- catcher: ระยะยิง melee (4.1 จริง + tolerance + sweep)
	RescueRange = 7,     -- runner: ระยะชุบเพื่อน (เกมกำหนด ≤7)
	ThreatRange = 25,    -- runner: ระยะสนามผลัก catcher
	JukeNear = 9,        -- ใกล้กว่านี้ = hard cut 90°
	JukeFar = 16,        -- ไกลกว่านี้ = ไม่ juke
	GemDrift = 12,       -- เบี่ยงเก็บเพชรจากเส้นทางได้กี่เมตร
}
local DEF = {} for k, v in pairs(cfg) do DEF[k] = v end
local CFG_FILE = "hz_valley_cfg.json"
do -- โหลดค่าที่เซฟไว้ (ชนิดผิด → คืน default)
	local ok, raw = pcall(readfile, CFG_FILE)
	if ok and type(raw) == "string" and #raw > 0 then
		local ok2, t = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
		if ok2 and type(t) == "table" then for k, v in pairs(t) do cfg[k] = v end end
	end
	for k, v in pairs(DEF) do if type(cfg[k]) ~= type(v) then cfg[k] = v end end
end
local function saveCfg()
	pcall(writefile, CFG_FILE, game:GetService("HttpService"):JSONEncode(cfg))
end
-- สวิตช์ที่ผูกกัน: DodgeDash ต้องมี Dodge เปิดอยู่
local TIE = { DodgeDash = { on = { "Dodge" } } }
local function applyTies(key)
	local t = TIE[key] if not t then return end
	if cfg[key] then for _, k in ipairs(t.on or {}) do cfg[k] = true end
	else for _, k in ipairs(t.offWhenOff or {}) do cfg[k] = false end end
end
for k in pairs(TIE) do applyTies(k) end
local S = { last = "-", stats = "", _bought = {}, steerWhy = "-" }
-- สถิติแยก หนี vs ไล่ (ดู log ท้ายเกม)
local stats = { safe = 0, caught = 0, dodge = 0, gearFlee = 0, gearChase = 0, rescue = 0, ghost = 0, perfect = 0 }
local lastTackle, lastMelee, lastDash = 0, 0, 0
-- log append ไม่ลบทิ้ง — auto-trim ตอนโหลด: ไฟล์ >800KB เหลือแค่ tail 4,000 บรรทัด (กันบวม+ดูย้อนได้)
pcall(function()
	local raw = readfile("hz_valley_log.txt")
	if raw and #raw > 800 * 1024 then
		local lines = {}
		for l in raw:gmatch("[^\n]+") do lines[#lines + 1] = l end
		local keep = {}
		for i = math.max(1, #lines - 4000), #lines do keep[#keep + 1] = lines[i] end
		writefile("hz_valley_log.txt", "... (ตัดเก่าทิ้ง " .. (#lines - #keep) .. " บรรทัด) ...\n" .. table.concat(keep, "\n"))
	end
end)
-- appendfile ใน Xeno มีแต่เขียนไม่ลงจริง -> เขียนผ่าน readfile+writefile อย่างเดียว
-- buffer แล้ว flush ทุก 1.5s (ไฟล์ถูก trim 800KB อยู่แล้ว เขียนทับทั้งก้อนปลอดภัย)
local _logBuf = {}
local function flushLog()
	if #_logBuf == 0 then return end
	local chunk = table.concat(_logBuf)
	for i = #_logBuf, 1, -1 do _logBuf[i] = nil end
	pcall(function()
		local ok, prev = pcall(readfile, "hz_valley_log.txt")
		writefile("hz_valley_log.txt", (ok and type(prev) == "string" and prev or "") .. chunk)
	end)
end
task.spawn(function() while not KILL do task.wait(1.5) guard("logIO", flushLog)() end guard("log", flushLog)() end)
table.insert(_logBuf, "\n═══ HZ VALLEY LOG " .. os.date("%c") .. " ═══\n")
function log(m)
	S.last = os.date("%H:%M:%S") .. " " .. m
	S.tail = S.tail or {}
	S.tail[#S.tail + 1] = S.last
	if #S.tail > 80 then table.remove(S.tail, 1) end
	print("[HZV] " .. m)
	table.insert(_logBuf, S.last .. "\n")
	-- error ภายในส่งขึ้น worker (ชื่อระบบเดียวกันไม่เกิน 1 ครั้ง/5นาที — กันสแปม)
	if rp and m:sub(1, 5) == "[ERR]" then
		local nm = m:match("%[ERR%]%[(.-)%]") or "?"
		S._errPing = S._errPing or {}
		if os.clock() - (S._errPing[nm] or -999) > 300 then S._errPing[nm] = os.clock() rp("err", nm) end
	end
end

-- ─── helpers ───
local function hum() local c = LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function hrp() local c = LP.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function alive() local h = hum() return h ~= nil and h.Health > 0 end
local function attr(i, n, d) local v = i:GetAttribute(n) return v == nil and d or v end
local function now() return WS:GetServerTimeNow() end
local function myRole() return attr(LP, "GameRole", "Lobby") end
local function inMatch() return attr(LP, "InMatch", false) end
local function runState() return attr(LP, "RunState", "Lobby") end
local Http = game:GetService("HttpService")
local function guid() return Http:GenerateGUID(false) end
local function flatDir(cf)
	local l = cf.LookVector * Vector3.new(1, 0, 1)
	return l.Magnitude < 0.01 and Vector3.new(0, 0, -1) or l.Unit
end

-- ─── ARMORY/GEAR: ดึงคลังสกิล + ใช้สกิลสวม (ลายเซ็นจริงจาก GearPredictionClient) ───
local armory = {} -- state จาก server: {abilities={id=true}, equippedAbilities={role=id}, equippedAbility}
if rArmory then
	conns[#conns + 1] = rArmory.OnClientEvent:Connect(guard("armory", function(a, st)
		if type(st) == "table" then
			armory = st
			if not S._armLogged then -- debug ครั้งแรก: รู้ว่ามีอะไรในคลังจริง
				S._armLogged = true
				local na, no = 0, 0
				for _ in pairs(st.abilities or {}) do na = na + 1 end
				for _ in pairs(st.owned or {}) do no = no + 1 end
				log(string.format("[ARMORY] loaded=%s สกิล=%d มีด=%d equipped=%s", tostring(st.loaded), na, no, tostring(st.equipped)))
			end
		end

	end))
	-- ขอ state ซ้ำจนกว่าจะ loaded (server ตอบช้า/ไม่ตอบบางที)
	task.spawn(function()
		for i = 1, 8 do
			if armory.loaded then break end
			pcall(function() rArmory:FireServer("Get") end)
			task.wait(3)
		end
	end)
end
-- อันดับสกิลที่ดีที่สุดต่อ role (จาก GearCatalog จริง)
local BESTGEAR = {
	Runner = { "EmergencyAirhorn", "Cloak", "InflatableDecoy", "PocketDoor", "RocketShoes", "BananaPeel", "Adrenaline" },
	Catcher = { "RufusLeash", "BowlingBall", "BigDagger", "RocketShoes", "Adrenaline", "BananaPeel" },
}
-- ราคา gems จริงจาก GearCatalog
local GEAR_PRICE = { Adrenaline = 60, BananaPeel = 60, RescueKit = 90, PocketDoor = 400,
	BowlingBall = 750, InflatableDecoy = 750, RocketShoes = 850, BigDagger = 900,
	Cloak = 1000, EmergencyAirhorn = 1000, RufusLeash = 1200 }
local function equippedGear(role)
	local e = armory.equippedAbilities
	return (type(e) == "table" and e[role]) or armory.equippedAbility
end
-- มีดดีสุดต่อ role (Legendary = +0.85 speed, -0.85s cd; GhostScythe = ภูมิคุ้มจับสำหรับ Runner)
local BESTKNIFE = {
	Runner = { "GhostScythe", "SolarPhoenix", "VoidSovereign", "GlacialCrown", "CelestialDragon",
		"MoltenFang", "SpectralReaper", "StormTalon", "Moonfang" },
	Catcher = { "SolarPhoenix", "VoidSovereign", "GlacialCrown", "CelestialDragon",
		"MoltenFang", "SpectralReaper", "StormTalon", "Moonfang", "CloneDagger", "GhostScythe" },
}
-- ─── DASH จริง: กด Space ผ่าน VIM = pipeline เดียวกับคนเล่นจริง (พิสูจน์แล้วเหมือน WASD) ───
local boostMod
pcall(function() boostMod = require(CoH.Movement:WaitForChild("BoostInput")) end)
local dashFlickUntil, dashFlickSide = 0, 1 -- ฉีกทิศชั่วครู่: dash ต้องการเปลี่ยนทิศ ≥25-35° ใน buffer (redirectsTravel)
local function flicked(d) -- หมุน steer 42° ขณะกด dash → travelHistory เห็น intent turn = dash เข้าแน่
	if not d or os.clock() >= dashFlickUntil then return d end
	local a = math.rad(42) * dashFlickSide
	local c, s = math.cos(a), math.sin(a)
	return Vector3.new(d.X * c - d.Z * s, 0, d.X * s + d.Z * c).Unit
end
-- dive จำลอง: TacklePrediction เกมทำ LinearVelocity พุ่งจริง — remote เปล่า = ยืนอ้าง tackle = ไม่จับ
local diveDir, diveUntil, diveSpd = nil, 0, 0
local function startDive(dir, travel) -- พุ่งตามระยะ dive จริง (Long≈15 studs ใน ~0.45s)
	diveDir = dir diveUntil = os.clock() + 0.45 diveSpd = math.clamp((travel or 10) / 0.45, 25, 60)
end
local function doDash(dir)
	-- readiness จริง: DashCooldownUntil (os.clock ฝั่งเกม) — แม่นกว่าเดา 1.1s
	local c = LP.Character
	local cdUntil = c and c:GetAttribute("DashCooldownUntil") or 0
	if os.clock() < cdUntil or now() - lastDash < 0.6 then return false end
	lastDash = now()
	dashFlickUntil = os.clock() + 0.28 -- ฉีกทิศ 0.28s ครอบ InputBuffer (0.18) ให้เกมเห็น turn แน่
	dashFlickSide = -dashFlickSide
	pcall(function() if boostMod then boostMod.request(true) end end) -- request แบบ touch = เกณฑ์ง่ายกว่า (25°/0.32s)
	-- กด Space จริง — เกมอ่าน input เอง → dash ผ่าน movement model เต็ม (แรง+แอนิเมชัน+remote)
	pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
	task.delay(0.1, function()
		pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
	end)
	-- ยืนยัน 0.6s: DashCount ไม่ขยับ = input ไม่เข้า → ยิง remote ตรงเป็น fallback
	local before = c and c:GetAttribute("DashCount") or -1
	task.delay(0.6, function()
		local c2 = LP.Character
		local after = c2 and c2:GetAttribute("DashCount") or -1
		if after == before and dir then
			pcall(function() rBoost:FireServer(dir, dir) end)
		end
	end)
	return true
end

local lastGearFire = 0
-- Airhorn = client-reported blast (เกมส่ง list เป้าใน arg 6): รัศมี 14m |dy|≤6 + raycast LOS
-- event mode (CrossyRoad/DonkeyKong/FFACatchers) เป่าโดนทุกคน ไม่ใช่แค่ catcher
local function airhornTargets()
	local me = hrp() if not me then return nil end
	local excl = {}
	for _, p in ipairs(Players:GetPlayers()) do if p.Character then excl[#excl + 1] = p.Character end end
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude rp.RespectCanCollide = true rp.FilterDescendantsInstances = excl
	local mm = attr(CoH.Game:FindFirstChild("Session"), "AdminMatchMode", "")
	local all = mm == "CrossyRoad" or mm == "DonkeyKong" or mm == "FFACatchers"
	local t = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local r = p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if r and attr(p, "RunState", "") == "Active" and (all or attr(p, "GameRole", "") == "Catcher")
			and attr(p, "FFAInvincible", false) ~= true then
			local d = r.Position - me.Position
			if math.abs(d.Y) <= 6 and (d * Vector3.new(1, 0, 1)).Magnitude <= 14 and not WS:Raycast(me.Position, d, rp) then
				t[#t + 1] = { userId = p.UserId, position = r.Position }
				if #t >= 32 then break end
			end
		end
	end
	return #t > 0 and t or nil
end
local function gearUse(dir, role) -- ช่อง ABILITY (RoleItem): "UseAbility" + cd AbilityReadyAt
	if not (rGear and armory.loaded) then return false end
	local eq = equippedGear(role or (myRole() == "Catcher" and "Catcher" or "Runner"))
	if not eq or eq == "" then return false end
	local nowT = now()
	if nowT < attr(LP, "AbilityReadyAt", 0) or os.clock() - lastGearFire < 0.7 then return false end
	lastGearFire = os.clock()
	pcall(function() rGear:FireServer("UseAbility", nil, dir or Vector3.new(0, 0, -1), guid(), nil, eq == "EmergencyAirhorn" and airhornTargets() or nil) end)
	return true
end
-- ช่อง ITEM (BananaPeel/RescueKit/Adrenaline): action "Use" + cd GearReadyAt + stock>0
local function itemUse(dir)
	if not (rGear and armory.loaded) then return false end
	local it = armory.equippedGear
	if not it or it == "" then return false end
	if armory.gear and (armory.gear[it] or 0) <= 0 then return false end
	local nowT = now()
	if nowT < attr(LP, "GearReadyAt", 0) or os.clock() - lastGearFire < 0.7 then return false end
	lastGearFire = os.clock()
	pcall(function() rGear:FireServer("Use", nil, dir or Vector3.new(0, 0, -1), guid(), nil, nil) end)
	return true
end

-- ผู้เล่นตาม role
local function eachRole(role)
	local t = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and attr(p, "InMatch", false) and attr(p, "GameRole", "") == role then
			local c = p.Character
			local r = c and c:FindFirstChild("HumanoidRootPart")
			local h = c and c:FindFirstChildOfClass("Humanoid")
			if r and h and h.Health > 0 then
				table.insert(t, { p = p, root = r, state = attr(p, "RunState", "?") })
			end
		end
	end
	return t
end
local function nearest(list, from)
	local best, bd = nil, math.huge
	for _, e in ipairs(list) do
		local d = (e.root.Position - from).Magnitude
		if d < bd then bd, best = d, e end
	end
	return best, bd
end

-- ─── AUTOPILOT: เดินจริง = h:Move ทุก event + VIM กด W + ล็อกกล้อง ───
local Session = CoH.Game:WaitForChild("Session")
local steer = nil           -- ทิศเป้าหมาย (unit)
local steerActive = false   -- กำลังเดินอยู่ไหม
local function drive()
	if KILL then return end
	-- dive override: tackle พุ่ง = velocity ตรงหน้าค้างตลอด dive (เหมือน LinearVelocity ของเกมเป๊ะ)
	if diveDir and os.clock() < diveUntil then
		local me2, h2 = hrp(), hum()
		if me2 and h2 then
			pcall(function()
				local v = me2.AssemblyLinearVelocity
				me2.AssemblyLinearVelocity = Vector3.new(diveDir.X * diveSpd, v.Y, diveDir.Z * diveSpd)
				h2:Move(diveDir, false)
			end)
		end
		return
	end
	if not steer then return end
	local h = hum() if h then pcall(function() h:Move(flicked and flicked(steer) or steer, false) end) end
end
conns[#conns + 1] = RunService.Heartbeat:Connect(guard("drive", drive))
conns[#conns + 1] = RunService.PreSimulation:Connect(guard("drive", drive))
conns[#conns + 1] = RunService.Stepped:Connect(guard("drive", drive))
-- กล้องหันหน้า camFace (เป้าหมาย) แยกจากทิศเดิน → ทิศเดินแตกเป็นแกนกล้อง → กด W/A/S/D ผสมจริง (8 ทางเหมือนคน)
local camFace = nil
local keyCodes = { W = Enum.KeyCode.W, A = Enum.KeyCode.A, S = Enum.KeyCode.S, D = Enum.KeyCode.D }
local heldKeys, keyRefresh = {}, 0
local function setKeys(want)
	for k, on in pairs(heldKeys) do
		if on and not want[k] then pcall(function() VIM:SendKeyEvent(false, keyCodes[k], false, game) end) heldKeys[k] = false end
	end
	for k in pairs(want) do
		if not heldKeys[k] then pcall(function() VIM:SendKeyEvent(true, keyCodes[k], false, game) end) heldKeys[k] = true end
	end
end
pcall(function() RunService:UnbindFromRenderStep("HZSteer") end) -- กัน error ชื่อซ้ำตอน relogin (cleanup ของ instance เก่าอาจยังไม่ทัน unbind)
RunService:BindToRenderStep("HZSteer", Enum.RenderPriority.Camera.Value + 2000, function()
	if KILL or not steer or not steerActive then setKeys({}) return end
	local me, cam = hrp(), WS.CurrentCamera
	if not (me and cam) then return end
	local face = camFace or steer
	local look = me.Position + face * 10
	cam.CFrame = CFrame.new(cam.CFrame.Position, Vector3.new(look.X, cam.CFrame.Position.Y, look.Z))
	local f = cam.CFrame.LookVector * Vector3.new(1, 0, 1)
	local r = cam.CFrame.RightVector * Vector3.new(1, 0, 1)
	if f.Magnitude < 0.01 or r.Magnitude < 0.01 then return end
	local eff = flicked and flicked(steer) or steer -- dash flick: กด A/D เฉียงชั่วครู่ให้เกมเห็นเปลี่ยนทิศ
	local fz, rx = eff:Dot(f.Unit), eff:Dot(r.Unit)
	local want = {}
	if fz > 0.25 then want.W = true elseif fz < -0.25 then want.S = true end
	if rx > 0.25 then want.D = true elseif rx < -0.25 then want.A = true end
	setKeys(want)
	if os.clock() - keyRefresh > 0.8 then -- refresh กัน key หลุด
		keyRefresh = os.clock()
		for k, on in pairs(heldKeys) do
			if on then pcall(function() VIM:SendKeyEvent(true, keyCodes[k], false, game) end) end
		end
	end
end)
local function setSteer(d)
	if not d and steerActive then setKeys({}) end
	steerActive = d ~= nil
	steer = d
	camFace = d -- กล้องตามทิศเดินเสมอ = speedPenalty 0% (เดิมหันโซนตอนหลบข้าง = โดนหักเร็ว 10-25%)
end
-- เกมบล็อกการเคลื่อนที่เมื่อ UI เปิด (ControlGate จริง) — เช็กก่อนเดิน
local function moveBlocked()
	-- ครบตาม ControlGate.reason จริงของเกม (dump 1789) — มี blocker พวกนี้ = input ตายหมด
	if attr(Session, "GlobalPaused", false) or attr(Session, "MapChanging", false) then return "session" end
	for _, a in ipairs({"MapVoteOpen","CrateOpen","GlobalWheelOpen","StarterPackOpen","GiveawayPickerOpen",
		"Spectating","EmoteWheelOpen","LikeRewardOpen","ArmoryOpen","AnnouncementComposerOpen",
		"CreatorPanelOpen","ServerBrowserOpen","EventHostPanelOpen","BalloonOfferOpen",
		"SettingsOpen","UpdateLogOpen","FairPlayNoticeOpen","ScreenPresentationActive","ReleaseCursorForControls"}) do
		if attr(LP, a, false) then return a end
	end
	-- เลือกฮีโร่ = เกมบล็อก input ทั้งหมด (Choice/ChoiceCamera) — ยิง combat/dash ตอนนี้ = เสียเปล่า
	if attr(LP, "ChoiceSpotlightActive", false) then
		local ph = attr(Session, "Phase", "")
		if ph == "SelectHero" or ph == "HeroChoice" or ph == "ChoiceReveal" then return "ChoiceCamera" end
	end
	local ok1, menuOpen = pcall(function() return game:GetService("GuiService").MenuIsOpen end)
	if ok1 and menuOpen then return "RobloxMenu" end
	local ok2, tb = pcall(function() return UIS:GetFocusedTextBox() end)
	if ok2 and tb then return "TextInput" end
	return nil
end
local applyUnstuck = function(d) return d end -- ถูกแทนที่หลัง stuck detector โหลด
local function field()
	local m = WS:FindFirstChild(attr(Session, "ActiveMapId", "Map1"))
	return m and m:FindFirstChild("Field")
end
local function targetSide() -- Runner: วิ่งไปฝั่งตรงข้ามจาก StartSide
	local f = field() if not f then return nil end
	local a, b = f:FindFirstChild("SafezoneASide"), f:FindFirstChild("SafezoneBSide")
	if attr(Session, "StartSide", "A") == "B" then return a else return b end
end
-- ─── waypoint routing: เส้นตรงชนตึก/กำแพง → เดินตาม Nodes ของแมพ (Map3 HOMETOWN = สามเหลี่ยม ต้องเลี้ยว) ───
local nodeCache = {} local nodeCacheMap = nil
local function mapNodes()
	local mid = attr(Session, "ActiveMapId", "Map1")
	if nodeCacheMap == mid then return nodeCache end
	nodeCache, nodeCacheMap = {}, mid
	local m = WS:FindFirstChild(mid)
	local n = m and m:FindFirstChild("Nodes")
	if n then
		for _, c in ipairs(n:GetChildren()) do
			if c:IsA("BasePart") then nodeCache[#nodeCache + 1] = c.Position end
		end
	end
	return nodeCache
end
local wallRP = RaycastParams.new()
wallRP.FilterType = Enum.RaycastFilterType.Exclude wallRP.RespectCanCollide = true
local function wallClear(from, toFlat) -- เส้นตรงถึงเป้าไหม (ray ที่ระดับตัว — ข้ามตัวผู้เล่นทุกคน นับแค่ตึก/กำแพง)
	local to = Vector3.new(toFlat.X, from.Y, toFlat.Z)
	local excl = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then excl[#excl + 1] = p.Character end
	end
	wallRP.FilterDescendantsInstances = excl
	return WS:Raycast(from, to - from, wallRP) == nil
end
local function nextWaypoint(mePos, meFlat, goalFlat)
	local best, bs = nil, -math.huge
	for _, np in ipairs(mapNodes()) do
		local nf = Vector3.new(np.X, 0, np.Z)
		local dMe = (nf - meFlat).Magnitude
		-- node ต้องเดินตรงถึงได้ + ทำให้ใกล้โซนกว่าเดิม (ไม่วนกลับ)
		if dMe > 5 and wallClear(mePos, nf) then
			local dGoal = (goalFlat - nf).Magnitude
			local score = -dGoal - dMe * 0.4 -- ใกล้โซนเป็นหลัก ใกล้เรารอง
			if dGoal < (goalFlat - meFlat).Magnitude - 8 and score > bs then bs, best = score, nf end
		end
	end
	return best
end
-- จุดเข้าโซนฉลาด: กวาด 5 จุดบนเส้นเซฟโซน เลือกจุดที่ catcher ใกล้สุดน้อยที่สุด
local function bestGoalPoint(zone, from)
	if not zone then return nil end
	local zc = zone.Position
	local catchers = eachRole("Catcher")
	local bestX, bestScore = zc.X, -math.huge
	for _, ox in ipairs({-80, -60, -40, -20, 0, 20, 40, 60, 80}) do
		local px = zc.X + ox
		local p, fp = Vector3.new(px, 0, zc.Z), Vector3.new(from.X, 0, from.Z)
		local threat, pathBad = 0, 0
		for _, c in ipairs(catchers) do
			local cf = c.root.Position + c.root.AssemblyLinearVelocity * 0.5 -- ตำแหน่งมันใน 0.5s
			local cf2 = Vector3.new(cf.X, 0, cf.Z)
			threat = threat + 1 / ((p - cf2).Magnitude + 4) -- รวม threat ทุกตัว (ฝูง = แย่)
			-- เส้นทางเรา→จุด ตัดผ่านมันไหม (ระยะต่ำสุดบน segment)
			local seg = p - fp
			local t = math.clamp((cf2 - fp):Dot(seg) / math.max(seg.Magnitude ^ 2, 0.01), 0, 1)
			local cross = (fp + seg * t - cf2).Magnitude
			if cross < 12 then pathBad = pathBad + (12 - cross) end
		end
		local score = -threat * 400 - pathBad * 8 - math.abs(px - from.X) * 0.25
		if score > bestScore then bestScore, bestX = score, px end
	end
	return Vector3.new(bestX, zc.Y, zc.Z)
end
-- เป้าจับได้จริง: runner Active (ไม่นับ FFAInvincible) — โหมด FFACatchers เหยี่ยวตีเหยี่ยวได้ด้วย
local function liveTargets()
	local t = {}
	for _, e in ipairs(eachRole("Runner")) do
		if e.state == "Active" and attr(e.p, "FFAInvincible", false) ~= true then t[#t + 1] = e end
	end
	if attr(Session, "AdminMatchMode", "") == "FFACatchers" then
		for _, e in ipairs(eachRole("Catcher")) do
			if e.state == "Active" and attr(e.p, "FFAInvincible", false) ~= true then t[#t + 1] = e end
		end
	end
	return t
end
-- เลือกไก่เป้าหมาย: ใกล้เราก่อนเป็นหลัก (×0.85) — ใกล้เส้นชัยเป็น tie-break เล็กน้อย (×0.15)
local function pickRunner(runners, mePos)
	local goal = targetSide()
	local gp = goal and goal.Position
	local best, bs = nil, math.huge
	for _, e in ipairs(runners) do
		local dUs = (e.root.Position - mePos).Magnitude
		local dGoal = gp and (Vector3.new(e.root.Position.X, 0, e.root.Position.Z)
			- Vector3.new(gp.X, 0, gp.Z)).Magnitude or 0
		local sc = dUs * 0.85 + dGoal * 0.15
		if sc < bs then bs, best = sc, e end
	end
	return best, best and (best.root.Position - mePos).Magnitude or math.huge
end
local jukeSide = 1 local jukeT = 0
-- lock จุดเข้าโซนต่อรอบ (กัน bestGoalPoint กระโดดตาม catcher = วิ่งวน)
local lockedGoal, lockedGoalT = nil, 0
local function goalPoint(zone, from, active)
	if not active then lockedGoal = nil return nil end
	if not lockedGoal then
		lockedGoal = bestGoalPoint(zone, from) lockedGoalT = os.clock()
	elseif os.clock() - lockedGoalT > 1.5 then
		-- ประเมินใหม่ช้าๆ และเปลี่ยนเฉพาะถ้าจุดใหม่ต่างชัดเจน (hysteresis)
		local cand = bestGoalPoint(zone, from)
		if cand and (cand - lockedGoal).Magnitude > 30 then lockedGoal = cand end
		lockedGoalT = os.clock()
	end
	return lockedGoal
end
local function dodgeDir(dir, from)
	-- หลบ catcher "ทุกตัว" รอบ 25m = สนามผลักถ่วงน้ำหนัก (ไม่ใช่แค่ตัวใกล้สุด → ไม่วิ่งเข้าฝูง)
	if not cfg.Dodge then return dir end
	local out, closest, closestAway = dir, math.huge, nil
	for _, e in ipairs(eachRole("Catcher")) do
		local away = (from - e.root.Position) * Vector3.new(1, 0, 1)
		local d = away.Magnitude
		if d < cfg.ThreatRange and d > 0.1 then
			local w = 1 - d / cfg.ThreatRange -- น้ำหนักผลักตามระยะจริงที่ผู้ใช้ตั้ง (เดิม hardcode 25)
			out = out + away.Unit * w * 1.7 -- ผลักออกถ่วงตามความใกล้
			-- มันกำลังพุ่งเข้าหาเราจริง (vel ชี้มาทางเรา) → ผลักหนักขึ้นอีก
			local cv = e.root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
			if cv.Magnitude > 5 and cv.Unit:Dot(-away.Unit) > 0.5 then
				out = out + away.Unit * w * 1.3
			end
			if d < closest then closest, closestAway = d, away.Unit end
		end
	end
	-- juke สับขาเฉียงเมื่อมีคนไล่: ใกล้ยิ่งสับถี่ — ใกล้มาก = HARD CUT 90° จริง
	-- (runner เลี้ยว 90° เสียเร็วแค่ 28% แต่ catcher TurnRate จำกัดเลี้ยวตามไม่ทัน = juke ที่แพ้ทางสุด)
	if closest < cfg.JukeFar and closestAway then
		local perp = Vector3.new(-closestAway.Z, 0, closestAway.X)
		if closest < cfg.JukeNear then
			-- ตัดแข็ง: ทิศ = ตั้งฉาก±ออกจากมัน เกือบล้วน — สลับทุก 0.24s (คนเล่นกด A/D สลับแบบนี้คือ juke โหด)
			if os.clock() - jukeT > 0.24 then jukeSide = -jukeSide jukeT = os.clock() end
			out = (perp * jukeSide * 1.9 + closestAway * 0.75).Unit
		else
			if os.clock() - jukeT > 0.45 then jukeSide = -jukeSide jukeT = os.clock() end
			out = out + perp * jukeSide * 0.8
		end
	end
	return out.Unit
end

-- ═══ GOD MODE: อ่าน telegraph การจับของเกม — หลบก่อนโดนจริง ═══
-- catcher ทุกตัวมี attr บน character: ReachPhase("Tracking"/"Windup"/"Active") + ReachDirection + ReachTargetUserId + TackleActive
-- เกมยิง catch = commit cone: ระยะ ≤10.5m, มุม ≤65° จาก ReachDirection → เราอ่านออกในช่วง Windup (เหลือ ~0.3s ก่อนโดน)
local COMMIT_DIST, COMMIT_COS = 12.0, math.cos(math.rad(72))
local godDir, godUntil = nil, 0   -- override steer ขณะหลบฉุกเฉิน
local lastGodLog = 0              -- กัน log spam (log ครั้งเดียวต่อช่วง telegraph)
local function catcherThreat(char, me) -- -> "REACH"|"DIVE"|"TRACK", dir, threatPos
	local cr = char and char:FindFirstChild("HumanoidRootPart")
	if not cr then return nil end
	local toUs = (me.Position - cr.Position) * Vector3.new(1, 0, 1)
	local dist = toUs.Magnitude
	if dist < 0.1 or dist > 40 then return nil end
	local rp = char:GetAttribute("ReachPhase")
	local rd = char:GetAttribute("ReachDirection")
	-- BigDaggerActive = reach ×2 หวดถัดไป — danger zone กว้างขึ้นเยอะ เตือนเร็วกว่าปกติ
	local bigD = char:GetAttribute("BigDaggerActive") == true
	local reachDist = COMMIT_DIST * (bigD and 1.9 or 1)
	if (rp == "Windup" or rp == "Active") and typeof(rd) == "Vector3" then
		local rdf = Vector3.new(rd.X, 0, rd.Z)
		if rdf.Magnitude > 0.1 and dist <= reachDist and rdf.Unit:Dot(toUs.Unit) >= COMMIT_COS then
			return "REACH", rdf.Unit, cr.Position -- เราอยู่ใน cone จับของมัน!
		end
	elseif rp == "Tracking" then
		if char:GetAttribute("ReachTargetUserId") == LP.UserId and dist <= (bigD and 24 or 15) then
			return "TRACK", nil, cr.Position -- มันกำลังเล็งเรา
		end
	end
	if char:GetAttribute("TackleActive") then
		-- dive จริง: Duration 0.4s, ระยะ = min(15, entrySpeed×0.4×1.45) ≈ vel×0.42 (cap 15)
		local vel = cr.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
		local landPos = cr.Position + (vel.Magnitude > 1 and vel.Unit * math.min(15, vel.Magnitude * 0.42) or vel * 0.35)
		local land = (landPos - me.Position) * Vector3.new(1, 0, 1)
		if land.Magnitude <= 7 then
			return "DIVE", vel.Magnitude > 1 and vel.Unit or nil, landPos
		end
	end
	return nil
end

local function autopilotTick()
	if not (cfg.Enabled and cfg.AutoPlay and inMatch() and alive()) then setSteer(nil) return end
	local me = hrp() if not me then setSteer(nil) return end
	local role, st8, phase = myRole(), runState(), attr(Session, "Phase", "")
	if st8 ~= "Active" then
		setSteer(nil) lockedGoal = nil camFace = nil S._firedStart = nil
		if st8 == "Caught" then S.steerWhy = "โดนจับ — RescueKit ชุบเอง" end
		return
	end
	local blk = moveBlocked()
	if blk then setSteer(nil) S.steerWhy = "เกมล็อก: " .. blk return end -- UI เปิด → เกมบล็อก
	if role == "Runner" and phase:find("Run") then
		local goal = targetSide()
		if not goal then setSteer(nil) S.steerWhy = "หาโซนไม่เจอ(map?)" return end
		local gp = goalPoint(goal, me.Position, true) -- lock จุดเข้าโซนกันวิ่งวน
		if not gp then setSteer(nil) S.steerWhy = "จุดโซน=nil" return end
		local meFlat = Vector3.new(me.Position.X, 0, me.Position.Z)
		local gpFlat = Vector3.new(gp.X, 0, gp.Z)
		local gpTo = gpFlat - meFlat
		-- กล้องตาม steer (setSteer เซ็ต camFace เอง) = เต็มความเร็วทุกทิศ ไม่โดน side/back penalty
		if gpTo.Magnitude < 6 then
			-- ถึงจุดเข้าโซนแต่ server ยังไม่ flip Safe → ห้ามหยุด! ดันต่อเข้าไปในโซนลึกอีก
			-- (เดิม setSteer(nil) = ยืนนิ่งที่ขอบโซน → โดนจับทั้งที่ถึงแล้ว)
			local deep = gpFlat + gpTo.Unit * 14
			local d2 = deep - meFlat
			if d2.Magnitude > 1 then
				setSteer(d2.Unit) S.steerWhy = "ดันเข้าโซนลึก"
			else
				setSteer(nil) S.steerWhy = "ถึงเซฟโซน!"
			end
			return
		end
		-- waypoint: เส้นตรงไปโซนชนตึก/กำแพง → เดินตาม Nodes ของแมพ (Map3 สามเหลี่ยม ต้องเลี้ยวขวา/ซ้าย)
		local moveTarget, viaNode = gpFlat, false
		if not wallClear(me.Position, gpFlat) then
			local wp = nextWaypoint(me.Position, meFlat, gpFlat)
			if wp then moveTarget, viaNode = wp, true end
		end
		local to = moveTarget - meFlat
		-- immune จริง (Ghost 2s / FFA respawn / HitShield 0.75s): จับไม่ได้ → วิ่งตรงเข้าโซนเต็มเร็ว
		local ghostImmune = now() < attr(LP, "GhostImmuneUntil", 0)
			or now() < attr(LP, "FFAImmuneUntil", 0)
			or (me.Parent and me.Parent:GetAttribute("HitShielded") == true)
		local d = ghostImmune and to.Unit or dodgeDir(to.Unit, me.Position)
		local nc, ncd = nearest(eachRole("Catcher"), me.Position)
		-- เพชร = โบนัสเท่านั้น: เก็บเฉพาะเมื่อ "ปลอดภัยสมบูรณ์" (catcher ไกล >30m)
		--   และเพชรเกือบอยู่บนเส้นทางเดิม (หัน ≤45°, เบี่ยง ≤12m) — ไม่เสี่ยงวิ่งออกทางเก็บ
		--   ตอน DoubleGems คุ้ม×2 → เบี่ยงได้ถึง 18m
		-- โหมดใกล้ชนะ (CleanEscapesToWin=3): เหลืออีก 1 ครั้ง = เพชรปิดสนิท + dash เก็บไว้เร็วขึ้น
		local winSoon = S.streakLeft == 1
		local gemDrift = (winSoon or ghostImmune) and 0
			or ((eventMode == "DoubleGems" and eventEndsAt > WS:GetServerTimeNow()) and cfg.GemDrift * 1.5 or cfg.GemDrift)
		if cfg.GemFarm and gemDrift > 0 and not (nc and ncd < 30) then
			local gf = WS:FindFirstChild("LocalRunnerGems")
			if gf then
				local bestGem, bestScore = nil, -math.huge
				for _, g in ipairs(gf:GetChildren()) do
					local gp2 = g.Position * Vector3.new(1, 0, 1)
					local to2 = gp2 - Vector3.new(me.Position.X, 0, me.Position.Z)
					local dd = to2.Magnitude
					if dd > 4 and dd < 40 and to2.Unit:Dot(to.Unit) > 0.7 then -- แทบอยู่บนเส้นทางเดิม
						local cross = (gp2 - (Vector3.new(me.Position.X, 0, me.Position.Z) + to.Unit * to2:Dot(to.Unit))).Magnitude
						if cross < gemDrift then -- เบี่ยงออกจากเส้นทางไม่เกิน gemDrift
							local amt = 1
							local bb = g:FindFirstChild("GemBillboard")
							if bb and bb:FindFirstChild("Amount") then amt = tonumber(bb.Amount.Text:match("%d+")) or 1 end
							local sc = amt * 10 - dd
							if sc > bestScore then bestScore, bestGem = sc, gp2 end
						end
					end
				end
				if bestGem then d = (bestGem - Vector3.new(me.Position.X, 0, me.Position.Z)).Unit end
			end
		end
		-- สกิลเปิดเกม: catcher ใกล้ตั้งแต่ต้น <25 → ใช้สกิลทันที (Decoy ล่อ/Airhorn เคลียร์/Shoes พุ่ง)
		if cfg.AutoGear and not S._firedStart then
			S._firedStart = true
			if rGem then pcall(function() rGem:FireServer("Sync") end) end -- ขอ layout เพชร (nil-safe)
			if nc and ncd < 25 and gearUse(d, "Runner") then
				stats.gearFlee += 1
				log("[สกิล] เปิดเกม " .. tostring(equippedGear("Runner")))
			end
		end
		-- dash ใช้ตลอดเพื่อความเร็ว/หนี — สำรองเฉพาะตอน catcher เข้าโซนจับ <12 (dive/reach ถึงได้) เก็บไว้หลบ telegraph
		if cfg.AutoDash and me.AssemblyLinearVelocity.Magnitude > 2 then -- ตัวนิ่ง(ติดกำแพง/เกตปิด) = อย่าเผา dash เปล่า

			local reserve = cfg.GodMode and nc and ncd < (winSoon and 16 or 12) -- ใกล้ชนะ = เก็บ dash ไว้หลบเร็วขึ้น
			-- เก็บ dash อีกชั้น: catcher ตัวไหนเล็งเรา/windup/dive อยู่ในระยะ 30m = ห้ามใช้เพล่นๆ
			if not reserve and cfg.GodMode then
				for _, e in ipairs(eachRole("Catcher")) do
					local ch = e.p.Character
					local r = ch and ch:FindFirstChild("HumanoidRootPart")
					if r and (me.Position - r.Position).Magnitude < 30 then
						local rp = ch:GetAttribute("ReachPhase")
						if ch:GetAttribute("TackleActive") or (rp and rp ~= "Tracking")
							or (rp == "Tracking" and ch:GetAttribute("ReachTargetUserId") == LP.UserId) then
							reserve = true break
						end
					end
				end
			end
			if not reserve then
				local dd, kind = d, "dash เร็ว"
				if nc and ncd < 26 then -- มีคนใกล้: dash เฉียงหนีมัน เอนเข้าโซน สับข้าง
					local away = (me.Position - nc.root.Position) * Vector3.new(1, 0, 1)
					if away.Magnitude > 0.1 then
						local side = Vector3.new(-away.Unit.Z, 0, away.Unit.X) * jukeSide
						dd = (away.Unit * 0.6 + d * 0.5 + side * 0.3).Unit
						kind = "dash หนี"
					end
				end
				if doDash(dd) then
					log(kind .. (nc and (" " .. nc.p.Name .. " @" .. math.floor(ncd)) or " ไปโซน"))
				end
			end
		end
		-- GOD override: telegraph จับพุ่งใส่ → หลบตั้งฉากสำคัญกว่าทิศเซฟโซน
		local godOn = cfg.GodMode and os.clock() < godUntil and godDir
		setSteer(godOn or applyUnstuck(d, me))
		S.steerWhy = godOn and "GODหลบ" or (viaNode and "เดินตาม node" or "วิ่งเข้าโซน")
	elseif role == "Catcher" then
		-- ไล่เป้าที่จับได้จริง (FFA = เหยี่ยวด้วยกันเอง) + นำหน้าด้วยความเร็ว
		local tgt, dist = pickRunner(liveTargets(), me.Position)
		if not tgt then setSteer(nil) S.steerWhy = "ไม่มีเป้าrunner" return end
		-- ดักทางอัจฉริยะ: แก้ "เราไปถึงจุด X ทันเป้า" — intercept ไม่ใช่ไล่ตามตูด
		local tpos = tgt.root.Position
		local tvel = tgt.root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
		local ourSpd = math.max(me.AssemblyLinearVelocity.Magnitude, 20)
		local aim = tpos
		for tt = 0.2, 3, 0.2 do
			local pp = tpos + tvel * tt
			if (pp - me.Position).Magnitude / ourSpd <= tt then aim = pp break end
		end
		if dist < 3.5 then aim = tpos end -- ประชิดแล้ว aim ตรง กัน overshoot วนรอบเป้า
		local to = (aim - me.Position) * Vector3.new(1, 0, 1)
		-- camFace = steer อัตโนมัติ (setSteer) — catcher เลี้ยวหนักอยู่แล้ว ห้ามเสียเร็วเพิ่ม
		local d = to.Magnitude > 0.1 and to.Unit or nil
		-- สกิลเปิดเกม Catcher: เห็นเป้า <30 → BowlingBall/Leash ใส่ตั้งแต่แรก
		if cfg.AutoGear and not S._firedStart then
			S._firedStart = true
			if d and dist < 30 and gearUse(d, "Catcher") then
				stats.gearChase += 1
				log("[สกิล] เปิดเกม " .. tostring(equippedGear("Catcher")) .. " -> " .. tgt.p.Name)
			end
		end
		-- หมายเหตุ: dash ใช้ได้เฉพาะ Runner (BoostInput gate จริง) — Catcher ยิง = server ปฏิเสธ
		setSteer(d and applyUnstuck(d, me) or nil)
		S.steerWhy = d and ("ไล่ " .. tgt.p.Name .. " @" .. math.floor(dist)) or "ทิศไล่=nil"
	else
		setSteer(nil) S.steerWhy = "phaseไม่ใช่Run/roleอื่น"
	end
end

-- ─── GOD REACTION 0ms: อ่าน telegraph เกมทุกเฟรม (Heartbeat) → ghost/dash/steer หลบทัน windup ───
conns[#conns + 1] = RunService.Heartbeat:Connect(guard("god", function()
	if KILL then return end
	do
		if cfg.Enabled and cfg.GodMode and myRole() == "Runner" and runState() == "Active" and inMatch() then
			local me = hrp()
			local immune = now() < attr(LP, "GhostImmuneUntil", 0)
				or now() < attr(LP, "FFAImmuneUntil", 0)
				or (me and me.Parent and me.Parent:GetAttribute("HitShielded") == true)
			if me and not immune then
				for _, e in ipairs(eachRole("Catcher")) do
					local kind, tdir, threatPos = catcherThreat(e.p.Character, me)
					if kind == "REACH" or kind == "DIVE" then
						local nowT = now()
						if cfg.AutoAbility and attr(LP, "GhostAbilityReadyAt", 0) > 0 and attr(LP, "GhostAbilityReadyAt", 0) <= nowT then
							pcall(function() rGhost:FireServer("Activate") end) stats.ghost += 1
							log("[GHOST] กัน " .. kind .. " ของ " .. e.p.Name)
						end
						local goal = targetSide()
						local gdir = goal and (Vector3.new(goal.Position.X, 0, goal.Position.Z) - Vector3.new(me.Position.X, 0, me.Position.Z))
						local perp = tdir and Vector3.new(-tdir.Z, 0, tdir.X) or Vector3.new(1, 0, 0)
						-- ข้างเดิมก่อน (กันพลิกกลางเทียว = วน), ไม่งั้นเลือกข้างที่เข้าหาโซน
						if os.clock() < godUntil and godDir and perp:Dot(godDir) < 0 then perp = -perp
						elseif gdir and gdir.Magnitude > 0.1 and perp:Dot(gdir.Unit) < 0 then perp = -perp end
						-- หนี = ตั้งฉากหลัก + ออกจากจุดภัย (จุดลง dive/ตำแหน่งจับ) + เอนเข้าโซนเบาๆ
						local awayT = threatPos and (Vector3.new(me.Position.X, 0, me.Position.Z) - Vector3.new(threatPos.X, 0, threatPos.Z)) or Vector3.zero
						if awayT.Magnitude < 0.1 then awayT = perp end
						-- DIVE: dive เลี้ยวไม่ได้ + recovery 0.55s → ตัดย้อนหลังทิศพุ่งมัน = ปลอดภัยสุด
						local back = (kind == "DIVE" and tdir) and (-tdir * 0.85) or Vector3.zero
						godDir = (perp * 1.1 + awayT.Unit * 0.55 + back + (gdir and gdir.Magnitude > 0.1 and gdir.Unit or Vector3.zero) * 0.25).Unit
						godUntil = os.clock() + 0.45
						setSteer(godDir) -- หันทิศทันทีให้ dash จริงพุ่งถูกทาง (ทิศ = move dir ตอนกด)
						if cfg.DodgeDash then doDash(godDir) end -- dash หลบ telegraph — แยกจาก AutoDash วิ่งเร็ว
						-- สกิลสวมฉุกเฉิน: Cloak/Airhorn/Decoy/Shoes ช่วยรอดทุกแบบ — กดตอน telegraph จริง
						if cfg.AutoGear and gearUse(godDir, "Runner") then
							stats.gearFlee += 1
							log("[สกิล] " .. tostring(equippedGear("Runner")) .. " กัน " .. kind)
						end
						stats.dodge += 1
						if now() - lastGodLog > 1.2 then lastGodLog = now(); log("[GOD] หลบ " .. kind .. " <- " .. e.p.Name) end
						break
					elseif kind == "TRACK" then
						-- มันกำลังเล็งเรา: สับข้างแรงทุก 0.3s — aim windup จำกัด 30°/อัตรา 18°/วิ ตามไม่ทัน
						if os.clock() - jukeT > 0.3 then jukeSide = -jukeSide jukeT = os.clock() end
						local goal = targetSide()
						if goal then
							local to = Vector3.new(goal.Position.X, 0, goal.Position.Z) - Vector3.new(me.Position.X, 0, me.Position.Z)
							if to.Magnitude > 0.1 then
								godDir = (to.Unit + Vector3.new(-to.Unit.Z, 0, to.Unit.X) * jukeSide * 0.9).Unit
								godUntil = os.clock() + 0.2
							end
						end
						break
					end
				end
			end
		end
	end
end))

-- ─── stuck detector: steer เซ็ตแต่ vel≈0 → เบี่ยงข้างชั่วคราว ───
local lastPos, stuckT, sideUntil, sideDir = nil, 0, 0, Vector3.zero
applyUnstuck = function(d)
	if os.clock() < sideUntil then return sideDir end
	return d
end
task.spawn(function()
	while not KILL do
		guard("stuck", function()
			local me = hrp()
			if me and steer then
				local hh = me.Parent and me.Parent:FindFirstChildOfClass("Humanoid")
				if hh and hh.WalkSpeed < 1 then stuckT = 0 -- server freeze (WS=0) ไม่ใช่ติดกำแพง — อย่าสแปม
				elseif lastPos and (me.Position - lastPos).Magnitude < 0.4 and me.AssemblyLinearVelocity.Magnitude < 3 then
					stuckT = stuckT + 0.2
					if stuckT > 0.8 then
						sideDir = (steer + Vector3.new(-steer.Z, 0, steer.X) * (stuckT % 2.4 > 1.2 and 1.5 or -1.5)).Unit
						sideUntil = os.clock() + 0.7
						if stuckT % 1.6 < 0.2 then log("ติดกำแพง! เบี่ยงข้าง") end
					end
				else stuckT = 0 end
				lastPos = me.Position
			else
				stuckT, lastPos = 0, nil
			end
		end)()
		task.wait(0.2)
	end
end)
task.spawn(function() while not KILL do guard("autopilot", autopilotTick)() task.wait(0.1) end end)

-- kill verify: ยิงแล้วจับตาเป้า 3s — เปลี่ยน Caught = จับจริง / ไม่เปลี่ยน = พลาด
-- map ต่อเป้าหมาย: tackle+melee ทับซ้อนกันได้ (เดิม slot เดียว → hit แรกหายไม่ได้เช็ก)
local pendingKills = {} -- [userId]={p, deadline, kind}
local rescueJob = nil -- {uid, p, t, done} — งานชุบเพื่อนที่กำลังกดค้าง (hold 0.3s จริง)
local function watchKill(p, kind)
	if not p then return end
	pendingKills[p.UserId] = { p = p, deadline = os.clock() + 3, kind = kind }
end
local function checkKill()
	for uid, pk in pairs(pendingKills) do
		local st = attr(pk.p, "RunState", "")
		if st == "Caught" then
			log("[KILL] จับสำเร็จ " .. pk.p.Name .. " (" .. pk.kind .. ")")
			if rp then rp("kill", pk.kind) end
			pendingKills[uid] = nil
		elseif os.clock() > pk.deadline then
			log("[!] " .. pk.kind .. " พลาด " .. pk.p.Name .. " — server ไม่ยอมรับ hit")
			pendingKills[uid] = nil
		end
	end
end


-- ─── P0 helpers: preflight sweep ด้วยคณิตเกมจริง + เลือกเป้าตาม CombatLife ───
local function meleeSweepOk(mePos, meVel, vicPos, vicVel, dir)
	-- จำลอง sweep ตัวเอง: lunge ไปข้างหน้าระหว่าง active 0.18s + เป้าเคลื่อนที่ต่อเนื่อง
	if not (HitReplayMath and CCC) then return true end
	local box = HitReplayMath.bounds("Melee", CCC)
	local reach = math.max(meVel.Magnitude, 4) * CATCH.activeDur
	local aTo = mePos + dir * reach
	local vTo = vicPos + vicVel * CATCH.activeDur
	local ok = HitReplayMath.sweep(mePos, aTo, vicPos, vTo, dir, box)
	return ok == true
end
local function tackleSweepOk(mePos, vicPos, vicVel, dir, cfgSel)
	if not (HitReplayMath and cfgSel) then return true end
	local box = HitReplayMath.bounds("Tackle", cfgSel)
	local dur = cfgSel.Duration or 0.4
	local travel = math.min(cfgSel.Distance or 8, cfgSel.MaxDistance or 15)
	local aTo = mePos + dir * travel
	local vTo = vicPos + vicVel * dur
	local ok = HitReplayMath.sweep(mePos, aTo, vicPos, vTo, dir, box)
	return ok == true
end
local function losClear(from, toPos, ignoreA, ignoreB)
	local rp2 = RaycastParams.new()
	rp2.FilterType = Enum.RaycastFilterType.Exclude rp2.RespectCanCollide = true
	rp2.FilterDescendantsInstances = { ignoreA, ignoreB }
	return WS:Raycast(from, toPos - from, rp2) == nil
end
-- เลือกไก่เป้าหมาย P0: CombatLife น้อยสุด → ใกล้สุด → ไม่มี ghost — ข้ามตัวที่เหยี่ยวอื่นล็อก/Concealed
local function pickRunnerP0(runners, mePos)
	local claimed = {}
	for _, e in ipairs(eachRole("Catcher")) do
		local ch = e.p.Character
		local t = ch and ch:GetAttribute("ReachTargetUserId")
		if type(t) == "number" then claimed[t] = true end
	end
	local nowT = now()
	local best, bs = nil, -math.huge
	for _, e in ipairs(runners) do
		local ch = e.p.Character
		if ch and e.p ~= LP and not claimed[e.p.UserId] and attr(e.p, "Concealed", false) ~= true then
			-- กันจริงตอนนี้ = ข้าม: GhostImmune/Ghosted (จับไม่ได้) / HitShielded (ดูดหวดแรก)
			-- Cloaked ไม่ข้าม — สเปกยืนยัน "still be hit" แค่เดาทิศยากขึ้น
			local immune = nowT < attr(e.p, "GhostImmuneUntil", 0)
				or ch:GetAttribute("Ghosted") == true or ch:GetAttribute("HitShielded") == true
			if not immune then
				local life = attr(ch, "CombatLife", 99)
				local d = (e.root.Position - mePos).Magnitude
				local ghost = attr(e.p, "GhostAbilityReadyAt", 0) > nowT and 40 or 0 -- ghost พร้อม = จับไม่ได้
				local sc = -life * 100 - d - ghost
				if sc > bs then bs, best = sc, e end
			end
		end
	end
	return best, best and (best.root.Position - mePos).Magnitude or math.huge
end
-- gate เพิ่มของ P0: DaggerState Held + Ragdolled + UI gate (moveBlocked มี GlobalPaused/MapChanging/Choice ครบ)
local function combatReady()
	local c = LP.Character if not c then return false end
	local h = c:FindFirstChildOfClass("Humanoid") if not (h and h.Health > 0) then return false end
	if h.WalkSpeed < 1 then return false end -- server freeze จริง (เจอสด: WS=0 ค้างข้ามรอบ MovementReset attr)
	if c:GetAttribute("MovementLocked") or c:GetAttribute("Ragdolled") then return false end
	if c:GetAttribute("DaggerEquipped") and c:GetAttribute("DaggerState") ~= "Held" then return false end
	if h.Sit or h.PlatformStand then return false end
	local r = c:FindFirstChild("HumanoidRootPart")
	if r and r.Anchored then return false end
	if moveBlocked() then return false end
	if os.clock() < guardSlowUntil then return false end -- โดน guard เตือน = หยุดยิง
	return true
end

-- ─── combat: tackle + melee (args จริงจาก TacklePrediction/MeleeInputClient) ───
local function combatTick()
	-- RescueKit ชุบตัวเอง — ต้องทำงานตอน Caught! (เดิมอยู่หลัง gate Active = dead code ไม่เคยยิง)
	if cfg.Enabled and cfg.AutoGear and inMatch() and runState() == "Caught" then
		local c = LP.Character
		if c and c:GetAttribute("RescueAvailable") == true and armory.equippedGear == "RescueKit"
			and not S._selfRevived then -- เกมจำกัด 1 ครั้ง/รอบ — กันยิงซ้ำเผาชาร์จ
			if itemUse() then S._selfRevived = true stats.rescue += 1 log("[RES] RESCUE KIT ชุบตัวเอง!") end
		end
	elseif runState() ~= "Caught" then
		S._selfRevived = nil -- รีเซ็ตเมื่อไม่ได้โดนจับ (รอบถัดไปชุบได้ใหม่)
	end
	if not (cfg.Enabled and inMatch() and alive() and runState() == "Active") then return end
	local me = hrp() if not me then return end
	local role = myRole()
	local nowT = now()

	if role == "Catcher" then
		if not combatReady() then return end -- P0 gate: Held/Ragdolled/Locked/UI-guard — ไม่ครบไม่ยิง
		local tgt, dist = pickRunnerP0(liveTargets(), me.Position)
		if not tgt then return end
		local vicVel = tgt.root.AssemblyLinearVelocity
		local myVel = me.AssemblyLinearVelocity
		local mySpd = Vector3.new(myVel.X, 0, myVel.Z).Magnitude
		local tgtFuture = tgt.root.Position + vicVel * 0.35
		local hum2 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		local onGround = not hum2 or (hum2.FloorMaterial ~= Enum.Material.Air and not (hum2.Sit or hum2.PlatformStand))

		-- TACKLE: บังคับ Long Dive เท่านั้น (speed ≥0.8×maxSPD) — ต่ำกว่า = เร่งต่อ ห้ามเสีย Short Dive
		-- cooldown อ่านจาก server readyAt (TackleResult) → fallback attr TackleReadyAt
		-- rubber-band สด: CrossingCatcherSpeedScale ทำ maxSPD เราเคลื่อน → เกณฑ์ Long ต้องตาม
		local catScale = attr(LP, "CrossingCatcherSpeedScale", 1)
		local catMax = CAT_MAXSPD * (type(catScale) == "number" and catScale or 1)
		local longSpd = catMax * 0.8
		-- เป้ากำลัง dash (BoostEffectAt ภายใน 0.55s): vel ~38.6+recovery 0.2 — dive จะพลาด รอ recovery จบ
		local boostAt = tgt.root.Parent and (tgt.root.Parent:GetAttribute("BoostEffectAt") or 0) or 0
		local tgtDashing = (nowT - boostAt) < 0.55
		local readyT = math.max(tackleReadyAt, attr(LP, "TackleReadyAt", 0))
		local canTackle = cfg.AutoTackle and mySpd >= longSpd and dist > 4.5 and dist <= 15.5
			and readyT <= nowT + 0.03 and not attr(LP.Character, "TackleActive", false) and onGround
			and not tgtDashing
		if canTackle then
			local dir = (tgtFuture - me.Position) * Vector3.new(1, 0, 1)
			if dir.Magnitude > 0.1 then
				local sel = TackleProfile and TackleProfile.select(TackleCfg or TACKLE_FALLBACK, mySpd, catMax)
				-- preflight: sweep ด้วย bounds("Tackle",cfg ที่เกมจะเลือกจริง) + raycast กำแพง — ไม่โดนไม่ยิง
				if (not sel or tackleSweepOk(me.Position, tgt.root.Position, vicVel, dir.Unit, sel))
					and losClear(me.Position, tgtFuture, LP.Character, tgt.p.Character) then
					pcall(function()
						rGameAction:FireServer("Tackle", {
							id = guid(), at = nowT,
							speed = mySpd,
							direction = dir.Unit, position = me.Position
						})
					end)
					startDive(dir.Unit, sel and math.min(sel.Distance, sel.MaxDistance or 15) or 9.66)
					setSteer(dir.Unit)
					watchKill(tgt.p, "tackle")
					lastTackle = nowT log("tackle -> " .. tgt.p.Name .. " @" .. math.floor(dist) .. " LONG")
				end
			end
		end
		-- MELEE: commit preflight ตามสเปก — dist ≤ min(5.25, 2.15+closingSpeed*0.07), cone ≤65°, |ΔY|≤2.8
		-- + sweep จำลอง box จริง + LOS — cadence 0.86s (timeline windup+active+recovery ของเกม)
		if cfg.AutoMelee and nowT - lastMelee > 0.86 and nowT >= meleeReadyAt
			and not attr(LP.Character, "TackleActive", false) then
			local toT = tgt.root.Position - me.Position
			local flat = toT * Vector3.new(1, 0, 1)
			local closing = math.max(0, (myVel - vicVel):Dot(flat.Magnitude > 0.01 and flat.Unit or Vector3.zero))
			local commit = math.min(CATCH.commitMax, CATCH.commitBase + closing * CATCH.commitLead)
			local dY = math.abs(toT.Y)
			local ang = flat.Magnitude > 0.01 and math.deg(math.acos(math.clamp(
				(flatDir(me.CFrame)):Dot(flat.Unit), -1, 1))) or 180
			local bigD = attr(LP.Character, "BigDaggerActive", false) and 2 or 1
			if flat.Magnitude <= commit * bigD and dY <= CATCH.height and ang <= CATCH.commitAngle
				and dist <= CATCH.far * bigD + vicVel.Magnitude * CATCH.activeDur + 1 then
				local dir = flat.Unit
				if meleeSweepOk(me.Position, myVel, tgt.root.Position, vicVel, dir)
					and losClear(me.Position, tgt.root.Position, LP.Character, tgt.p.Character) then
					pcall(function()
						rMelee:FireServer({ id = guid(), at = nowT, direction = dir, position = me.Position })
					end)
					watchKill(tgt.p, "melee")
					lastMelee = nowT meleeReadyAt = nowT + 0.85
					log("melee -> " .. tgt.p.Name .. " @" .. math.floor(dist) .. (bigD > 1 and " BIG" or ""))
				end
			end
		end
		-- สกิลสวม Catcher (ระยะจริง): Leash ปาดึง≤10 / Ball กลิ้งสกิด≤25 / RocketShoes พุ่ง64เหมาะไล่ไกล>10 / BigDagger×2 melee≤9 / อื่นๆ≤8
		if cfg.AutoGear and tgt then
			local gd = equippedGear("Catcher")
			local rng = gd == "RufusLeash" and 10 or gd == "BowlingBall" and 25
				or gd == "RocketShoes" and 60 or gd == "BigDagger" and 9 or 8
			local want = dist <= rng and (gd ~= "RocketShoes" or dist > 10) -- Rocket ใช้ตอนไล่ไกล 10-60 ไม่ใช่ตอนประชิด
			if want then
				local gdir2 = (tgt.root.Position - me.Position) * Vector3.new(1, 0, 1)
				if gdir2.Magnitude > 0.1 and gearUse(gdir2.Unit, "Catcher") then
					stats.gearChase += 1
					log("[สกิล] " .. tostring(gd) .. " -> " .. tgt.p.Name .. " @" .. math.floor(dist))
				end
			end
		end
	else -- Runner (self-revive ทำตอน Caught อยู่บนสุดแล้ว — ตรงนี้เฉพาะ Active)
		-- สกิลสวม Runner: catcher จ่อ <10 → กดทันที (Cloak หายตัว/Airhorn เป่ากระเด็น/Decoy ล่อ)
		if cfg.AutoGear then
			local nc, ncd = nearest(eachRole("Catcher"), me.Position)
			if nc and ncd < 10 then
				local away = (me.Position - nc.root.Position) * Vector3.new(1, 0, 1)
				if gearUse(away.Magnitude > 0.1 and away.Unit or nil, "Runner") then
					stats.gearFlee += 1
					log("[สกิล] " .. tostring(equippedGear("Runner")) .. " หนี " .. nc.p.Name)
				end
			end
			-- ช่อง ITEM ตามสถานการณ์: BananaPeel ทิ้งตอนเหยี่ยวไล่ตูด (<9 = มันเหยียบแน่) / Adrenaline ตอนจ่อ (<16)
			local it = armory.equippedGear
			if nc and it then
				if it == "BananaPeel" and ncd < 9 then
					if itemUse() then log("[ITEM] ทิ้งกล้วยล่อ " .. nc.p.Name) end
				elseif it == "Adrenaline" and ncd < 16 then
					if itemUse() then log("[ITEM] ADRENALINE accel×1.6 หนี " .. nc.p.Name) end
				end
			end
		end
		-- AUTO-RESCUE เพื่อน: RescueAvailable+Ragdolled ≤6.5 + LOS + เหยี่ยวไกลพอ (≥16)
		-- contract จริง: Begin(userId) → hold 0.3s+ → Finish(userId) · เป้าไม่ valid → Cancel
		if cfg.AutoPlay then
			if rescueJob then
				local vc = rescueJob.p.Character
				local vr = vc and vc:FindFirstChild("HumanoidRootPart")
				local okT = vr and vc:GetAttribute("Ragdolled") and vc:GetAttribute("RescueAvailable")
					and (vr.Position - me.Position).Magnitude <= 7.5
					and (vc:GetAttribute("RescueHelperId") or LP.UserId) == LP.UserId
				if not okT then
					if not rescueJob.done then
						pcall(function() rRescue:FireServer("Cancel", rescueJob.uid) end)
					end
					rescueJob = nil
				elseif os.clock() - rescueJob.t >= 0.36 and not rescueJob.done then
					rescueJob.done = true
					pcall(function() rRescue:FireServer("Finish", rescueJob.uid) end)
					stats.rescue += 1 log("[RES] ชุบ " .. rescueJob.p.Name .. " เสร็จ!")
				end
			else
				local nc2, ncd2 = nearest(eachRole("Catcher"), me.Position)
				if not (nc2 and ncd2 < 16) then -- เหยี่ยวใกล้เกิน = ชุบ=ตายคู่ อย่าเสี่ยง
					for _, e in ipairs(eachRole("Runner")) do
						if e.p ~= LP then
							local ch = e.p.Character
							if ch and ch:GetAttribute("Ragdolled") and ch:GetAttribute("RescueAvailable")
								and not ch:GetAttribute("RescueHelperId") then
								local d = (e.root.Position - me.Position).Magnitude
								if d <= 6.5 and losClear(me.Position, e.root.Position, LP.Character, ch) then
									pcall(function() rRescue:FireServer("Begin", e.p.UserId) end)
									rescueJob = { uid = e.p.UserId, p = e.p, t = os.clock(), done = false }
									log("[RES] เริ่มชุบ " .. e.p.Name .. " @" .. math.floor(d))
									break
								end
							end
						end
					end
				end
			end
		end
	end

	-- abilities: ฉลาดขึ้น — เก็บไว้ใช้ตอนจำเป็น (Runner ใช้ตอน catcher จ่อ / Catcher ใช้ตอนเข้าประชิด)
	if cfg.AutoAbility then
		local danger = false
		if role == "Runner" then
			local nc, ncd = nearest(eachRole("Catcher"), me.Position)
			danger = nc ~= nil and ncd < 12 -- ผู้จับจ่อแล้ว → กดสกิลรอด
		else
			local _, rd = nearest(liveTargets(), me.Position)
			danger = rd ~= nil and rd < 18 -- เข้าประชิดเป้า → กดสกิลช่วยจับ
		end
		if danger then
			if attr(LP, "GhostAbilityReadyAt", 0) <= nowT and attr(LP, "GhostAbilityReadyAt", 0) > 0 then
				pcall(function() rGhost:FireServer("Activate") end) log("ghost! (" .. role .. ")")
			end
			if attr(LP, "CloneAbilityReadyAt", 0) <= nowT and attr(LP, "CloneAbilityReadyAt", 0) > 0 then
				pcall(function() rClone:FireServer("Activate") end) log("clone! (" .. role .. ")")
			end
		end
	end

	-- dash ถูกย้ายไปใช้เชิงสถานการณ์ใน autopilotTick (หนี/ไล่)
end
-- combat diag: บอกว่า gate ไหนบล็อก (ทุก ~5s ตอน Active+Catcher) — จบปัญหาเงียบ
local cbtDiagT = 0
local function combatTickSafe()
	local ok, err = pcall(combatTick)
	if not ok then log("[!] combatTick error: " .. tostring(err)) end
	checkKill()
	if inMatch() and alive() and runState() == "Active" and myRole() == "Catcher" and os.clock() - cbtDiagT > 5 then
		cbtDiagT = os.clock()
		pcall(function()
			local me2 = hrp()
			local tgt2, d2
			if me2 then tgt2, d2 = pickRunner(liveTargets(), me2.Position) end
			local c = LP.Character
			local h2 = hum()
			log(string.format("[CBT] tgt=%s d=%s ready=%.1f tActive=%s mLock=%s floor=%s",
				tgt2 and tgt2.p.Name or "none", tgt2 and math.floor(d2) or "-",
				math.max(0, attr(LP, "TackleReadyAt", 0) - now()),
				tostring(c and c:GetAttribute("TackleActive")), tostring(c and c:GetAttribute("MovementLocked")),
				h2 and tostring(h2.FloorMaterial) or "?"))
		end)
	end
end
task.spawn(function() while not KILL do guard("combat", combatTickSafe)() task.wait(0.12) end end)

-- ─── spin wheel (เฉพาะ lobby — ขอ State แล้ว Spin ทุก 15s) ───
task.spawn(function()
	while not KILL do
		guard("spin", function()
			if cfg.Enabled and cfg.AutoSpin and rSpin and not inMatch() then
				pcall(function() rSpin:FireServer("State") end)
				task.wait(0.5)
				pcall(function() rSpin:FireServer("Spin") end)
				task.wait(14.5)
			end
		end)()
		task.wait(3)
	end
end)

-- ─── anti-AFK + auto ตอบ HeroChoice = "Chicken" + auto VOTE แมพ (0.5s ลูป) ───
local choiceAnswered = false
local votedToken = nil
local freeDone = {} -- free-claim timestamps
task.spawn(function()
	while not KILL do
		guard("afk+equip", function()
		if cfg.Enabled and attr(LP, "AFK", false) then
			pcall(function() rPrefs:FireServer("SetAFK", false) end)
			log("ปิด AFK — จะได้เข้าแมตช์")
		end
		local ph = attr(Session, "Phase", "")
		-- auto สวมสกิล+มีดที่ดีสุดต่อ role (เฉพาะนอกแมตช์) — รู้จาก armory state จริง
		if cfg.Enabled and cfg.AutoEquip and rArmory and not inMatch() then
			local role = myRole() == "Catcher" and "Catcher" or "Runner"
			if armory.abilities then
				local cur = equippedGear(role)
				local curRank = math.huge
				for i, id in ipairs(BESTGEAR[role]) do if cur == id then curRank = i break end end
				-- อัพเกรดเท่านั้น: เลือกตัวที่ rank ดีกว่าตัวที่สวมอยู่เสมอ (กันสลับของวน/ping-pong)
				for i, id in ipairs(BESTGEAR[role]) do
					if i >= curRank then break end
					if armory.abilities[id] == true then
						pcall(function() rArmory:FireServer("EquipGear", id) end)
						log("[EQUIP] สกิล " .. role .. ": " .. id)
						break
					end
				end
			end
			-- ช่อง ITEM: ล็อก RescueKit อย่างเดียว (ชุบตัวเองตอน Caught) — ไม่วนเลือกอย่างอื่น
			if type(armory.gear) == "table"
				and (armory.gear.RescueKit or 0) > 0 and armory.equippedGear ~= "RescueKit" then
				pcall(function() rArmory:FireServer("EquipGear", "RescueKit") end)
				log("[EQUIP] ไอเทม RescueKit")
			end
			if type(armory.owned) == "table" then
				local curRank = math.huge
				for i, id in ipairs(BESTKNIFE[role]) do if armory.equipped == id then curRank = i break end end
				for i, id in ipairs(BESTKNIFE[role]) do
					if i >= curRank then break end
					if armory.owned[id] == true then
						pcall(function() rArmory:FireServer("Equip", id) end)
						log("[EQUIP] มีด " .. role .. ": " .. id)
						break
					end
				end
			end
			-- auto-buy: เพชรพอ → ซื้อทีละชิ้น ห่าง 5s (state อัพเดตช้า กันเผาเพชรเกิน)
			-- consumable (อยู่ใน armory.gear = ชาร์จ) = ใช้แล้วหมด ต้องซื้อซ้ำเมื่อ stock=0 — RescueKit ก่อนสุด (ชุบตัวเอง)
			if os.clock() - (S._buyT or 0) > 5 then
				local gems = armory.gems or 0
				local owned = function(id) return (armory.abilities and armory.abilities[id] == true) or (armory.owned and armory.owned[id] == true) or (armory.items and armory.items[id]) end
				S._buyCd = S._buyCd or {}
				for _, id in ipairs({ "RescueKit", "Adrenaline", "BananaPeel", "PocketDoor", "BowlingBall", "RocketShoes", "InflatableDecoy", "BigDagger", "Cloak", "EmergencyAirhorn", "RufusLeash" }) do
					local price = GEAR_PRICE[id]
					local isConsumable = armory.gear and armory.gear[id] ~= nil
					-- consumable: ซื้อเฉพาะตอน stock หมดจริง + เผื่อ cooldown 45s/ชิ้น (server reject = state ไม่อัปเดต กันยิงซ้ำรั่ว)
					local cdOk = (os.clock() - (S._buyCd[id] or -999)) > 45
					local need = (isConsumable and (armory.gear[id] or 0) <= 0 and cdOk) or (not isConsumable and not owned(id))
					-- consumable ไม่ใช้ _bought (ใช้แล้วหมด ต้องซื้อซ้ำ) — เดิม _bought บล็อกซื้อซ้ำถาวร
					if price and gems >= price and need and (isConsumable or not S._bought[id]) then
						if isConsumable then S._buyT = os.clock() S._buyCd[id] = os.clock()
						else S._bought[id] = true S._buyT = os.clock() end
						pcall(function() rArmory:FireServer("BuyGearGems", id) end)
						task.delay(1.5, function() pcall(function() rArmory:FireServer("Get") end) end) -- refresh state หลังซื้อ
						log("[BUY] " .. id .. " (" .. price .. " gems, เหลือ " .. math.floor(gems - price) .. ")" .. (isConsumable and " [stock " .. tostring(armory.gear and armory.gear[id]) .. "]" or ""))
						break
					end
				end
			end
		end
		-- ของฟรีทั้งหมด (ยิงซ้ำทุก 90s — server เช็กเอง ไม่มีให้รับก็ไม่เป็นไร)
		if cfg.Enabled and cfg.FreeClaim and not inMatch() then
			local t = os.clock()
			local function free(key, fn)
				if not freeDone[key] or t - freeDone[key] > 90 then
					freeDone[key] = t
					pcall(fn) log("[FREE] ขอของ: " .. key)
				end
			end
			free("LikeReward", function() rArmory:FireServer("ClaimLikeReward") end)
			free("CheckRewards", function() rArmory:FireServer("CheckRewards") end)
			if rAdmin then free("AwardReady", function() rAdmin:FireServer("AwardReady") end) end
			if rGiveaway then free("Giveaway", function() rGiveaway:FireServer("Sync") end) end
			if rStarter then free("StarterPack", function() rStarter:FireServer("Get") end) end
			-- Journey season: Get state + ClaimAll รางวัลทุก tier ที่ทำถึง (ฟรี)
			if rJourney then
				free("Journey", function()
					rJourney:FireServer("Get")
					rJourney:FireServer("ClaimAll") -- claim ทุก tier ที่ปลดล็อกในคำสั่งเดียว
				end)
			end
			-- Crate: ขอ state ดูมี crate ฟรีค้างไหม (เปิดของจริงต้องซื้อ — แค่เช็ก)
			if rCrate then free("CrateGet", function() rCrate:FireServer("Get", "Ember") rCrate:FireServer("Get", "Celestial") end) end
		end
		-- AutoTitle เปิดแต่ FreeClaim ปิด → ยังขอ journey state ทุก 90s (จะได้รู้ badge ที่มี)
		if cfg.Enabled and cfg.AutoTitle and not cfg.FreeClaim and rJourney and not inMatch() then
			if not S._jrGet or os.clock() - S._jrGet > 90 then
				S._jrGet = os.clock()
				pcall(function() rJourney:FireServer("Get") end)
			end
		end
		-- สาย dev: attr ที่ movement model อ่านฝั่ง client — ตั้งเองได้ server ไม่เช็ก
		if cfg.Enabled and cfg.SpeedTrick and inMatch() and runState() == "Active" then
			pcall(function()
				if LP:GetAttribute("GearSlow") == true then LP:SetAttribute("GearSlow", false) end
				if LP:GetAttribute("GearBoost") ~= true then LP:SetAttribute("GearBoost", true) end -- +60% accel (MovementProfiles จริง)
				local k = myRole() == "Catcher" and "CrossingCatcherSpeedScale" or "CrossingRunnerSpeedScale"
				-- clamp จริงของเกม: Runner[1, 1.12] Catcher[0.92, 1] → runner ดันเต็ม +12%, catcher ล้าง -8% เหลือ 1
				local want = myRole() == "Catcher" and 1 or 1.12
				local v = LP:GetAttribute(k)
				if type(v) == "number" and v < want then LP:SetAttribute(k, want) end
				-- melee gate จริง (MeleeInputClient): DaggerEquipped ต้อง DaggerState=="Held" — มีดสลัมค้าง = ฟันไม่ได้
				local c = LP.Character
				if c and c:GetAttribute("DaggerEquipped") == true and c:GetAttribute("DaggerState") ~= "Held" then
					c:SetAttribute("DaggerState", "Held")
				end
			end)
		end
		if ph ~= "HeroChoice" then choiceAnswered = false end
		if cfg.Enabled and ph == "HeroChoice" and not choiceAnswered then
			choiceAnswered = true
			local cm = attr(Session, "ChoiceMoment", nil)
			local chosen = nil
			if type(cm) == "string" then
				local okJ, j = pcall(function() return Http:JSONDecode(cm) end)
				if okJ and j then chosen = j.userId end
			elseif type(cm) == "table" then chosen = cm.userId end
			if chosen == LP.UserId or chosen == nil then
				local pick = cfg.PlayHero and "Hero" or "Chicken"
				pcall(function() rGameAction:FireServer("HeroChoice", pick) end)
				log("เลือก " .. pick .. " อัตโนมัติ")
			else
				log("HeroChoice ของ " .. tostring(chosen) .. " — ไม่ใช่เรา รอดู")
			end
		end
		-- auto vote แมพ: MapVoteState JSON มี token+options — vote ครั้งเดียวต่อ token
		if cfg.Enabled and cfg.AutoVote and rMapVote and rMapVoteState then
			local okJ, mv = pcall(function() return Http:JSONDecode(rMapVoteState.Value) end)
			if okJ and type(mv) == "table" and mv.token and mv.options and
				(attr(LP, "MapVoteOpen", false) or mv.phase == "Voting" or ph == "MapVote") then
				if mv.token ~= votedToken then
					votedToken = mv.token
					local pick = mv.options[math.random(1, #mv.options)]
					if pick and pick.id then
						pcall(function() rMapVote:FireServer("Vote", pick.id, mv.token) end)
						log("[VOTE] แมพ: " .. tostring(pick.name or pick.id))
					end
				end
			end
		end
		end)()
		task.wait(0.5)
	end
end)

-- ─── auto claim เควส: state จาก server → claim อันที่ complete ───
local questClaimed = {}
if rQuest then
	conns[#conns + 1] = rQuest.OnClientEvent:Connect(guard("quest", function(a, st)
		if KILL or not (cfg.Enabled and cfg.AutoQuest) then return end
		if a ~= "State" or type(st) ~= "table" then return end
		if st.daily and st.daily.quests then
			for id, q in pairs(st.daily.quests) do
				if q.complete and not q.claimed and not questClaimed["d" .. tostring(id)] then
					questClaimed["d" .. tostring(id)] = true
					task.delay(0.6, function()
						pcall(function() rQuest:FireServer("ClaimDaily", id) end)
						log("[CLAIM] daily quest " .. tostring(id))

					end)
				end
			end
		end
		if st.event and st.event.weapons then
			for id, w in pairs(st.event.weapons) do
				if w.claimable and not w.claimed and not questClaimed["e" .. tostring(id)] then
					questClaimed["e" .. tostring(id)] = true
					task.delay(0.6, function()
						pcall(function() rQuest:FireServer("ClaimEvent", id) end)
						log("[CLAIM] event quest " .. tostring(id))
					end)
				end
			end
		end
	end))
	task.delay(2, function() pcall(function() rQuest:FireServer("Get") end) end) -- ขอ state ตอนโหลด
end

-- ─── MovementGuard listener: server เตือน fair-play → log เพื่อรู้ว่าโดนจับสปีดไหม ───
local rGuard = CoH.Presentation:FindFirstChild("MovementGuardEvent")
if rGuard then
	conns[#conns + 1] = rGuard.OnClientEvent:Connect(guard("guard-evt", function(a, b)
		-- payload dump ครั้งแรก — spec ยังขาดรูปจริงของ MovementGuardEvent
		pcall(function()
			local prev = ""
			pcall(function() prev = readfile("hz_findings.txt") or "" end)
			writefile("hz_findings.txt", prev .. "\n[GUARD-EVT] " .. os.date("%X") .. " a=" .. tostring(a)
				.. " b=" .. Http:JSONEncode(type(b) == "table" and b or { v = tostring(b) }))
		end)
		if a == "Warning" then
			guardSlowUntil = os.clock() + 15 -- หยุดยิง 15s = cadence หายทันที (P0: ลด footprint ตอนโดนจับตา)
			log("[!] FAIR-PLAY WARNING: " .. tostring(type(b) == "table" and (b.title .. " " .. (b.message or "")) or b) .. " — หยุดโจมตี 15s")
			if rp then rp("warn") end
		elseif a == "Staff" then
			guardSlowUntil = os.clock() + 30
			log("[!] STAFF ALERT: " .. tostring(type(b) == "table" and b.message or b) .. " — หยุดโจมตี 30s")
			if rp then rp("warn", "staff") end
		end

	end))
end

-- ─── award auto-ack: server ส่ง Awards มา → ack รับรางวัลทันที ───
if rAdmin then
	conns[#conns + 1] = rAdmin.OnClientEvent:Connect(guard("admin", function(a, list)
		if a == "Awards" and type(list) == "table" then
			for _, aw in ipairs(list) do
				if type(aw) == "table" and type(aw.id) == "string" then
					task.delay(0.8, function()
						pcall(function() rAdmin:FireServer("AwardAck", aw.id) end)

					end)
					log("[AWARD] รับ: " .. tostring(aw.label or aw.id))
				end
			end
		end
	end))
end

-- ─── P0 collectors: เก็บข้อมูลที่ spec ยังขาดอัตโนมัติ → hz_findings.txt ───
local function finding(tag, data)
	pcall(function()
		local prev = ""
		pcall(function() prev = readfile("hz_findings.txt") or "" end)
		writefile("hz_findings.txt", prev .. "\n[" .. tag .. "] " .. os.date("%X") .. " " .. tostring(data))
	end)
	log("[FIND] " .. tag .. " " .. tostring(data):sub(1, 120))
end
local seenConcealed, seenSummary, prefsTested = {}, false, false
-- live-only sightings: char attrs ที่ dump lobby ไม่เคยเห็น (ยืนยันว่าใช้จริงตอนแมตช์)
local seenCharAttr, seenRunStates, threatNoted = {}, {}, false
local CHAR_WATCH = { "Cloaked", "Ghosted", "HitShielded", "BigDaggerActive", "RescueAvailable",
	"RescueHelperId", "Ragdolled", "MovementLocked", "DashAnimationSequence", "DashFromDirection" }
task.spawn(function()
	while not KILL do
		guard("collect", function()
			-- Concealed: ใครหายตัวจริง → บันทึกทันที
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LP and attr(p, "Concealed", false) == true and not seenConcealed[p.UserId] then
					seenConcealed[p.UserId] = true
					finding("CONCEALED", p.Name .. " role=" .. tostring(attr(p, "GameRole", ""))
						.. " gear=" .. tostring(attr(p, "EquippedGear", "")))
				end
				-- RunState transitions: ค่ากลางที่ยังไม่เคยเห็น (Waiting/Safe/Revivable/Revived/Inactive?)
				local st = attr(p, "RunState", "")
				if st ~= "" and not seenRunStates[st] then
					seenRunStates[st] = true
					finding("RUNSTATE", st .. " first-seen @" .. p.Name)
				end
				-- char attrs: ครั้งแรกที่เห็นแต่ละค่า — ยืนยัน semantics จริง
				local ch = p.Character
				if ch and inMatch() then
					for _, a in ipairs(CHAR_WATCH) do
						local v = ch:GetAttribute(a)
						if v ~= nil and v ~= false and v ~= 0 and not seenCharAttr[a] then
							seenCharAttr[a] = true
							finding("CHAR-ATTR", a .. "=" .. tostring(v) .. " @" .. p.Name)
						end
					end
				end
			end
			-- CatcherThreatIntensity: สเกลจริงบนเรา (เป็น Runner ถึงขยับ)
			local ti = attr(LP, "CatcherThreatIntensity", 0)
			if type(ti) == "number" and ti > 0 and not threatNoted then
				threatNoted = true
				finding("THREAT", "CatcherThreatIntensity=" .. ti)
			end
			-- MatchSummary: เนื้อหาจบแมตช์เต็มรูปแบบ
			local ms = CoH.Game:FindFirstChild("MatchSummary")
			if ms and ms.Value ~= "" and not seenSummary then
				seenSummary = true
				finding("MATCH-SUMMARY", ms.Value)
			end
		end)()
		task.wait(2)
	end
end)
-- BoostRequest events ทั้งหมด (ไม่ใช่แค่ PerfectDodge — payload อื่นยังไม่เคยเห็น)
conns[#conns + 1] = rBoost.OnClientEvent:Connect(guard("boost-evt", function(a, b)
	if a ~= "PerfectDodge" then
		finding("BOOST-EVT", tostring(a) .. " | " .. tostring(b):sub(1, 100))
	end
end))
-- TouchAutoMelee: ยิงครั้งเดียวตอน lobby — server ยอม/ไม่ยอม → attr พิสูจน์เอง
task.delay(8, function()
	guard("prefs-test", function()
		if prefsTested or inMatch() or not rPrefs then return end
		prefsTested = true
		local before = attr(LP, "TouchAutoMelee", false)
		pcall(function() rPrefs:FireServer("TouchAutoMelee", true) end)
		task.delay(3, function()
			finding("TOUCH-AUTO-MELEE", "before=" .. tostring(before) .. " after=" .. tostring(attr(LP, "TouchAutoMelee", false)))
		end)
	end)
end)

-- ═══ UI — FishUI (หน้าต่างกระจก เด้งลอยได้ รองรับมือถือ) ═══
local FishUI = ...
if type(FishUI) ~= "table" or type(FishUI.Window) ~= "function" then
	local src
	for _, p in ipairs({ "FishUI.lua", "dist/FishUI.lua", "FishUI/init.lua" }) do
		local ok, s = pcall(readfile, p)
		if ok and type(s) == "string" and #s > 1000 then src = s break end
	end
	if not src then error("hz_valley: ไม่พบ FishUI — วาง FishUI.lua (+โฟลเดอร์ FishUI/) หรือ dist/FishUI.lua ไว้ใน workspace", 0) end
	local f, e = loadstring(src, "=FishUI")
	if not f then error("hz_valley: FishUI compile ไม่ผ่าน: " .. tostring(e), 0) end
	FishUI = f()
end
local BUILD = select(2, ...) or {} -- จาก release bootstrap: {tag, wm, onLogout, discord, forgetKey, ping}
-- เชื่อม telemetry → worker: ทุกเหตุการณ์ติด tag = build|wm (หลังบ้านเห็นว่าจากคีย์ไหน — throttle อยู่ใน boot)
rp = (type(BUILD.ping) == "function") and function(ev, x) pcall(BUILD.ping, ev, x) end or function() end

local C = {
	bg = Color3.fromRGB(16, 13, 17), txt = Color3.fromRGB(240, 234, 240), dim = Color3.fromRGB(150, 142, 152),
	acc = Color3.fromRGB(255, 92, 92), acc2 = Color3.fromRGB(205, 145, 255),
	on = Color3.fromRGB(72, 205, 112), warm = Color3.fromRGB(255, 210, 120),
}
local F_TH, F_TX = Enum.Font.GothamBold, Enum.Font.SourceSans
local flash -- banner กลางจอ (ประกาศในแมตช์)

-- ScreenGui ของตัวเอง: flash banner (แยกจาก GUI ของ FishUI — ไม่โดนทำลายตอนปิดหน้าต่าง)
local gui = Instance.new("ScreenGui")
gui.Name = "HZValley" gui.ResetOnSpawn = false gui.IgnoreGuiInset = true gui.DisplayOrder = 100
pcall(function() gui.Parent = LP:WaitForChild("PlayerGui") end)
if not gui.Parent then gui.Parent = game:GetService("CoreGui") end

local gameName = "Chicken or Hero"
pcall(function()
	local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
	if type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" then gameName = info.Name end
end)

-- ─── หน้าต่างหลัก ───
local win = FishUI.Window{
	title = "HZ HUB",
	brand = gameName .. " · " .. (BUILD.tag or "v2.1"),
	w = 740, h = 560,
	toggleKey = Enum.KeyCode.RightShift,
	onLogout = function()
		KILL = true
		if type(BUILD.onLogout) == "function" then task.spawn(BUILD.onLogout)
		else task.delay(0.35, function() pcall(function() loadstring(readfile("hz_valley.lua"))() end) end) end
	end,
}
win:Config("hz_valley") -- เซฟธีม/ความทึบ/ปุ่มเปิดเมนูอัตโนมัติ

-- ─── ผูกสวิตช์ ↔ cfg (cfg เป็นแหล่งจริงเดียว — เซฟลง hz_valley_cfg.json เหมือนเดิม) ───
local LIVE = {} -- ป้ายสถานะสด
local REFRESH = {}
local function refreshAll() for k, f in pairs(REFRESH) do pcall(f, cfg[k]) end end
local saveTimer = 0
local function saveSoon()
	local t = os.clock() + 0.6
	saveTimer = t
	task.delay(0.7, function() if saveTimer <= t and not KILL then saveCfg() end end)
end
local function notify(t, s) pcall(function() win:Notify{ title = t, text = s or "", dur = 3 } end) end

local function tog(gb, lbl, k, tip, kcap)
	local el = gb:Toggle{ label = lbl, tip = tip, key = kcap, default = cfg[k] and true or false, cb = function(v)
		cfg[k] = v
		applyTies(k)
		saveCfg()
		refreshAll()
		if k == "Enabled" then
			if not v then setSteer(nil) end
			flash(v and "HZ HUB: เปิดระบบ" or "HZ HUB: ปิดระบบ", v and C.on or C.acc)
		end
	end }
	REFRESH[k] = function(v) el.set(v, true) end
	return el
end
local SLIDERS = {}
local function sld(gb, lbl, k, mn, mx, step, tip)
	local el = gb:Slider{ label = lbl, tip = tip, min = mn, max = mx, step = step, suffix = "m", default = cfg[k], cb = function(v)
		cfg[k] = v
		saveSoon()
	end }
	SLIDERS[#SLIDERS + 1] = { k = k, el = el }
	return el
end

-- ─── หน้า: ภาพรวม ───
do
	local pg = win:Page("ภาพรวม", "monitor")
	local sub = pg:Sub("สถานะสด")
	local gLive = sub:Groupbox("แมตช์", "Left")
	LIVE.head = gLive:Label("<b>กำลังเริ่ม...</b>")
	LIVE.state = gLive:Label("-")
	LIVE.team = gLive:Label("-")
	LIVE.streak = gLive:Label("-")
	local gGear = sub:Groupbox("คูลดาวน์ & ของที่สวม", "Right")
	LIVE.cd = gGear:Label("-")
	LIVE.gear = gGear:Label("-")
	LIVE.knife = gGear:Label("-")
	LIVE.title = gGear:Label("-")
	local gStat = sub:Groupbox("สถิติเซสชัน", "Left")
	LIVE.stat = gStat:Label("-")
	local gLast = sub:Groupbox("ท่าล่าสุด", "Right")
	LIVE.last = gLast:Label("-")
	local gAct = sub:Groupbox("ทางลัด", "Right")
	gAct:Buttons{
		{ label = "รีเฟรชคลัง", cb = function()
			pcall(function() rArmory:FireServer("Get") end)
			S._bought = {}
			flash("ขอคลังใหม่ — auto-buy ทำงานรอบถัดไป", C.acc2)
		end },
		{ label = "เปลี่ยนเซิร์ฟเวอร์", cb = function()
			flash("กำลังหาเซิร์ฟเวอร์ใหม่...", C.warm)
			task.spawn(function()
				local cands = {}
				local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
				local ok, data = pcall(function()
					local body
					if request then local r = request({ Url = url, Method = "GET" }) body = r and r.Body end
					body = body or game:HttpGet(url)
					return game:GetService("HttpService"):JSONDecode(body)
				end)
				if ok and data and data.data then
					for _, s2 in ipairs(data.data) do
						if s2.id ~= game.JobId and s2.playing and s2.playing < (s2.maxPlayers or 20) - 1 then
							cands[#cands + 1] = s2.id
						end
					end
				end
				pcall(function()
					if #cands > 0 then
						game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, cands[math.random(#cands)], LP)
					else
						game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
					end
				end)
			end)
		end },
	}
	gAct:Buttons{
		{ label = "เซิร์ฟคนเยอะสุด", cb = function()
			flash("กำลังหาเซิร์ฟเวอร์ที่คนเยอะสุด...", C.warm)
			task.spawn(function()
				local bestId, bestN = nil, -1
				local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
				local ok, data = pcall(function()
					local body
					if request then local r = request({ Url = url, Method = "GET" }) body = r and r.Body end
					body = body or game:HttpGet(url)
					return game:GetService("HttpService"):JSONDecode(body)
				end)
				if ok and data and data.data then
					for _, s2 in ipairs(data.data) do
						if s2.id ~= game.JobId and s2.playing and s2.playing > bestN and s2.playing < (s2.maxPlayers or 20) then
							bestId, bestN = s2.id, s2.playing
						end
					end
				end
				pcall(function()
					if bestId then
						flash("ย้ายไปเซิร์ฟ " .. bestN .. " คน!", C.on)
						game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, bestId, LP)
					else
						game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
					end
				end)
			end)
		end },
		{ label = "รีเซ็ตสถิติ", cb = function()
			stats.safe, stats.caught, stats.dodge, stats.gearFlee, stats.gearChase, stats.rescue, stats.ghost, stats.perfect = 0, 0, 0, 0, 0, 0, 0, 0
			flash("รีเซ็ตสถิติแล้ว", C.warm)
		end },
	}
	local function buildReport(withLog)
		local L = {
			"HZ VALLEY report · build " .. tostring(BUILD.tag or "dev") .. " · key " .. tostring(BUILD.wm or "-"),
			"place " .. tostring(game.PlaceId) .. " · " .. gameName,
			string.format("role=%s state=%s phase=%s", myRole(), runState(), attr(Session, "Phase", "-")),
			string.format("stats: safe=%d caught=%d dodge=%d perfect=%d flee=%d chase=%d ghost=%d",
				stats.safe, stats.caught, stats.dodge, stats.perfect, stats.gearFlee, stats.gearChase, stats.ghost),
			"exe=" .. tostring((pcall(identifyexecutor) and identifyexecutor()) or "?"),
			"",
		}
		local c = {}
		for k, v in pairs(cfg) do
			if k ~= "Fold" and k ~= "PillPos" and k ~= "PanelPosB" then c[#c + 1] = k .. "=" .. tostring(v) end
		end
		table.sort(c)
		L[#L + 1] = "cfg: " .. table.concat(c, " ")
		if withLog and S.tail then
			L[#L + 1] = ""
			L[#L + 1] = "--- log tail ---"
			for i = math.max(1, #S.tail - 39), #S.tail do L[#L + 1] = S.tail[i] end
		end
		return table.concat(L, "\n")
	end
	gAct:Buttons{
		{ label = "คัดลอกรายงานบัค (พร้อม log)", cb = function()
			local txt = buildReport(true)
			local ok = pcall(setclipboard, txt)
			notify("รายงานบัค", ok and "คัดลอกแล้ว — ส่งให้แอดมินได้เลย (log 40 บรรทัดล่าสุดอยู่ในนั้น)" or "เครื่องนี้คัดลอกไม่ได้ — เปิด hz_valley_log.txt แทน")
		end },
		{ label = "คัดลอก log", cb = function()
			local ok = pcall(setclipboard, table.concat(S.tail or {}, "\n"))
			notify("log", ok and "คัดลอก log ล่าสุดแล้ว" or "คัดลอกไม่ได้ — ไฟล์อยู่ที่ hz_valley_log.txt")
		end },
	}
	gAct:Label("<b>build:</b> " .. tostring(BUILD.tag or "dev") .. "   <b>key:</b> " .. tostring(BUILD.wm or "local"))
end

-- ─── หน้า: ไก่ ───
do
	local pg = win:Page("ไก่", "gamepad")
	local sub = pg:Sub("วิ่งหนีรอด")
	local gp = sub:Groupbox("พรีเซ็ต (กดทีเดียวจบ)", "Left")
	local PRESETS = {
		{ name = "ไก่หนี", set = { AutoPlay = true, Dodge = true, DodgeDash = true, GodMode = true, AutoDash = true,
			AutoGear = true, AutoAbility = true, GemFarm = true, AutoTackle = false, AutoMelee = false } },
		{ name = "เหยี่ยวล่า", set = { AutoPlay = true, AutoTackle = true, AutoMelee = true, AutoGear = true, AutoAbility = true,
			Dodge = false, DodgeDash = false, GodMode = false, AutoDash = false, GemFarm = false } },
		{ name = "สมดุล", set = { AutoPlay = true, Dodge = true, DodgeDash = true, GodMode = true, AutoDash = true,
			AutoGear = true, AutoAbility = true, AutoTackle = true, AutoMelee = true, GemFarm = true } },
	}
	gp:Buttons((function()
		local l = {}
		for _, p in ipairs(PRESETS) do
			l[#l + 1] = { label = p.name, cb = function()
				for k, v in pairs(p.set) do cfg[k] = v applyTies(k) end
				saveCfg()
				refreshAll()
				flash("พรีเซ็ต: " .. p.name, C.acc2)
				notify("พรีเซ็ต", p.name)
			end }
		end
		return l
	end)())
	local gr = sub:Groupbox("ระบบหลัก", "Left")
	tog(gr, "เปิดระบบทั้งหมด (K)", "Enabled", "สวิตช์ใหญ่: ปิด = หยุดทุกระบบ + ปล่อยปุ่มทันที (กด K ได้แม้เมนูปิด)", Enum.KeyCode.K)
	tog(gr, "บอทเล่นเอง", "AutoPlay", "วิ่งข้ามสนามเข้าเซฟโซนฝั่งตรงข้ามเอง + กด WASD จริง 8 ทิศ — ปิด = เล่นเอง")
	tog(gr, "GOD อ่านใจเหยี่ยว", "GodMode", "อ่าน ReachPhase/TackleActive/ReachDirection → หลบก่อนโดนจับ ~0.3s + ตัดหลัง dive (ระบบสำคัญสุดของแมพนี้)")
	tog(gr, "สนามผลัก + juke", "Dodge", "เหยี่ยวในระยะ Threat ผลักเราออก + juke สับข้างอัตโนมัติ — ใกล้จริง = ตัด 90°")
	tog(gr, "dash หลบปฏิกิริยา", "DodgeDash", "เหยี่ยว reach/push ใส่ → dash ตั้งฉากทันที (ต้องเปิดสนามผลัก)")
	tog(gr, "dash เร่งความเร็ว", "AutoDash", "กด Space ผ่าน pipeline เกมทุก 1.1s — เก็บไว้หลบอัตโนมัติตอนเหยี่ยวเข้าโซนจับ <12m")
	tog(gr, "เก็บเพชรข้างทาง", "GemFarm", "เบี่ยงเก็บเพชรเฉพาะตอนปลอดภัย (เหยี่ยวห่าง >30m) — ชนะสำคัญกว่าเพชรเสมอ")
	tog(gr, "เลือกฝั่ง Hero (เหยี่ยว)", "PlayHero", "HeroChoice: เปิด = เล่นเหยี่ยวไล่จับ · ปิด = เล่นไก่วิ่งหนี (default)")
	local gi = sub:Groupbox("วิธีอ่านสถานะ", "Right")
	gi:Label("• <b>[RES] RESCUE KIT</b> ชุบตัวเองอัตโนมัติตอนโดนจับ (ใส่กล่องชุบไว้ช่องไอเทม)")
	gi:Label("• <b>[KILL] จับสำเร็จ</b> = server ยืนยันฆ่าจริง ส่วน <b>[!] พลาด</b> = server ไม่รับ hit")
	gi:Label("• <b>เดินตาม node</b> = Map3 กำลังอ้อมตึกตามจุดนำทางของเกม")
	gi:Label("• แผงคีย์ลัด: RightAlt • ซ่อนเมนู: RightShift • ปิดระบบด่วน: K • ปิดฮับ: Del")
	gi:Label("• มือถือ: ย่อเมนูแล้วแตะแถบลอย HZ HUB เปิดกลับ (ลากชิดขอบ = พับเก็บ)")
end

-- ─── หน้า: เหยี่ยว ───
do
	local pg = win:Page("เหยี่ยว", "swords")
	local sub = pg:Sub("ไล่จับไก่")
	local gc = sub:Groupbox("โจมตี", "Left")
	tog(gc, "tackle พุ่งจับ", "AutoTackle", "ยิง Tackle ใส่ไก่ที่ predict ล่วง 0.35s ในระยะ TackleRange — dive พุ่งจริงตาม remote เกม")
	tog(gc, "melee ฟันใกล้", "AutoMelee", "ฟันไก่ในระยะ MeleeRange (ยิงล่วงตาม windup + hitbox sweep ตามการวิ่ง)")
	tog(gc, "ใช้สกิลไล่", "AutoGear", "Leash ดึง ≤11m / Ball ขว้าง ≤25m / BearTrap วางดัก — อัตโนมัติตามระยะเป้าหมาย")
	local gn = sub:Groupbox("เกณฑ์ server (จาก dump)", "Right")
	gn:Label("• Tackle จริง: travel ≤15m + hit 6m ≈ ยิงได้ถึง ~21m")
	gn:Label("• Melee จริง: 4.1m + tolerance ~2.3m")
	gn:Label("• ยิงเกินระยะที่เกมยอม = server เตะ hit ทิ้ง (ดู [!] พลาด ใน log)")
	gn:Label("• kill นับเฉพาะที่เป้าเปลี่ยนเป็น Caught — ไม่ใช่ยิงออกแล้วนับ")
end

-- ─── หน้า: สกิล & ฟาร์ม ───
do
	local pg = win:Page("สกิล", "crown")
	local sub = pg:Sub("อัตโนมัติ")
	local gg = sub:Groupbox("สกิล & อาวุธ", "Left")
	tog(gg, "สกิลมีด Clone/Ghost", "AutoAbility", "ใช้ Clone/Ghost เมื่อพร้อม (ต้องมีมีดที่มีสกิลนั้น — Legendary มักมี)")
	tog(gg, "สวมของดีสุดอัตโนมัติ", "AutoEquip", "lobby: สวมสกิล+มีดดีสุดในคลัง + ซื้อ RescueKit/สกิลเติมเองเมื่อเพชรพอ")
	tog(gg, "SpeedTrick (ทดลอง)", "SpeedTrick", "เซ็ต attr ฝั่ง client ที่เกมอ่านท้องถิ่น — เสี่ยงโดนจับได้ ปิดไว้ถ้าไม่ชัวร์")
	local gf = sub:Groupbox("ฟาร์มอัตโนมัติ", "Right")
	tog(gf, "claim เควส", "AutoQuest", "ClaimDaily + ClaimEvent อัตโนมัติเมื่อเควสสำเร็จ")
	tog(gf, "หมุนกงล้อ", "AutoSpin", "SpinWheel ฟรีใน lobby ทุก ~15s")
	tog(gf, "claim ของฟรีทั้งหมด", "FreeClaim", "LikeReward/CheckRewards/Award/Giveaway/StarterPack/Journey — รับทุกอย่างฟรี")
	tog(gf, "โหวตแมพ", "AutoVote", "โหวตแมพอัตโนมัติตอนเปิดโหวต")
	tog(gf, "สวม title ดีสุด", "AutoTitle", "สวม badge สูงสุดที่ปลดล็อก (ROYALTY>ELITE>VETERAN>...) เหนือหัว")
end

-- ─── หน้า: ปรับค่า ───
do
	local pg = win:Page("ปรับค่า", "gear")
	local sub = pg:Sub("ระยะ & จังหวะ")
	local gt = sub:Groupbox("เหยี่ยว", "Left")
	sld(gt, "ระยะ tackle", "TackleRange", 6, 22, 0.5, "ยิง tackle ไกลสุด (จริง ~21m — เกินนี้ server ปฏิเสธ)")
	sld(gt, "ระยะ melee", "MeleeRange", 3, 9, 0.2, "ฟันไกลสุดตอน predict (4.1 จริง + tolerance ~2.3)")
	local gr2 = sub:Groupbox("ไก่", "Right")
	sld(gr2, "ระยะสนามผลัก", "ThreatRange", 15, 40, 1, "ผลัก/หลบ catcher ที่อยู่ใกล้กว่านี้")
	sld(gr2, "juke สับแข็ง <", "JukeNear", 5, 14, 0.5, "catcher ใกล้กว่านี้ = ตัด 90° ถี่")
	sld(gr2, "juke เบา <", "JukeFar", 10, 25, 0.5, "catcher ในระยะนี้ = juke โค้งเบาๆ")
	sld(gr2, "เบี่ยงเก็บเพชร", "GemDrift", 0, 25, 1, "เพชรห่างเส้นทางได้กี่เมตรถึงเบี่ยงเก็บ (0 = บนเส้นทางเท่านั้น)")
	local gd = sub:Groupbox("อันตราย", "Left")
	gd:Buttons{ { label = "↺ คืนค่าแนะนำทั้งหมด", cb = function()
		for _, k in ipairs({ "TackleRange", "MeleeRange", "ThreatRange", "JukeNear", "JukeFar", "GemDrift" }) do cfg[k] = DEF[k] end
		saveCfg()
		for _, s2 in ipairs(SLIDERS) do s2.el.set(cfg[s2.k]) end
		flash("คืนค่าปรับเป็นค่าเริ่มต้นแล้ว", C.warm)
	end } }
	gd:Button{ label = "ปิดฮับถาวร (กดค้าง)", danger = true, cb = function()
		KILL = true
		pcall(function() gui:Destroy() end)
		pcall(function() win:Destroy() end)
	end }
end

-- ─── หน้า: คู่มือ (อธิบายทุกฟีเจอร์ว่าทำงานยังไง) ───
do
	local pg = win:Page("คู่มือ", "search")
	local sub = pg:Sub("ฟีเจอร์ทำงานยังไง")
	local g1 = sub:Groupbox("บอทเล่นเอง / GOD / การเคลื่อนที่", "Left")
	g1:Label("<b>บอทเล่นเอง (AutoPlay)</b> — ไก่: วิ่งข้ามสนามไปเซฟโซนฝั่งตรงข้าม เลือกโซนที่เหยี่ยวน้อยสุด กด WASD จริงผ่าน VirtualInputManager (เกมเห็นเหมือนคนกด) มี raycast เช็กกำแพง + เดินตาม node ของแมพตอนเส้นตรงชนตึก · เหยี่ยว: ไล่ไก่ตัวใกล้สุดโดยคิดทิศล่วงหน้าจากความเร็วเป้า")
	g1:Label("<b>GOD อ่านใจเหยี่ยว (GodMode)</b> — อ่าน attribute ของเหยี่ยวทุกตัว (ReachPhase / TackleActive / ReachDirection / ReachTargetUserId) ทุกเฟรม · เหยี่ยวเริ่มเงื้อจับ = dive ตั้งฉากทันทีก่อน server นับ hit ~0.3s · เหยี่ยว dive พุ่งมา = ตัดหลังจุดที่มันจะไปถึง ทำให้พุ่งพลาด")
	g1:Label("<b>สนามผลัก + juke (Dodge/DodgeDash)</b> — เหยี่ยวเข้าใกล้กว่า ThreatRange = เบี่ยงทิศออกห่าง · ใกล้จริง (JukeNear) = ตัด 90° สับขา · DodgeDash = กด Space dash ตั้งฉากทันทีตอนเหยี่ยว reach")
	g1:Label("<b>dash เร่งความเร็ว (AutoDash)</b> — กด Space dash ทุก ~1.1s ผ่าน input pipeline ของเกม · ระบบเก็บ dash ไว้เองเมื่อเหยี่ยวเข้าโซนจับ <12m (เอาไว้หลบจริง)")
	local g2 = sub:Groupbox("ต่อสู้ / สกิล / ไอเทม", "Right")
	g2:Label("<b>tackle พุ่งจับ (AutoTackle)</b> — เหยี่ยว: ยิง Tackle remote ใส่ไก่ที่ predict ล่วง 0.35s · server ยอมรับเฉพาะเป้าในระยะจริง (~21m) จึงเช็กระยะ+ทิศก่อนยิงทุกครั้ง ไม่สแปม")
	g2:Label("<b>melee ฟันใกล้ (AutoMelee)</b> — ฟันเมื่อไก่อยู่ในระยะ (ค่าเริ่ม 6.4m) ยิงล่วงตาม windup ของอนิเมชัน · kill นับเฉพาะตอนเป้าเปลี่ยนเป็น Caught จริง — ไม่ใช่ยิงแล้วนับเอง")
	g2:Label("<b>ใช้สกิล (AutoGear)</b> — ไก่หนี: Cloak/Airhorn เมื่อเหยี่ยวเข้าใกล้, Decoy ล่อ · เหยี่ยวไล่: Leash ดึง ≤11m / BowlingBall ขว้าง ≤25m / BearTrap วางดักจุดเดิน")
	g2:Label("<b>สกิลมีด Clone/Ghost (AutoAbility)</b> — Ghost = จับไม่ได้ 2s (วิ่งฝ่าตรงเข้าโซนได้เลย) / Clone = แยกร่างล่อ · ใช้เมื่อ cooldown พร้อมเท่านั้น อ่านจาก attr GhostAbilityReadyAt/CloneAbilityReadyAt")
	g2:Label("<b>RescueKit</b> — โดนจับ (Caught) = กดไอเทมชุบตัวเองทันที ถ้าใส่ไว้ในช่องไอเทม · ระบบซื้อเติมเองเมื่อของหมด (AutoEquip)")
	local g3 = sub:Groupbox("ฟาร์ม / รางวัล / เซิร์ฟเวอร์", "Left")
	g3:Label("<b>ฟาร์มอัตโนมัติ</b> — เควสรายวัน+อีเวนต์เคลมเอง · กงล้อหมุนฟรี · LikeReward/StarterPack/Journey/CheckRewards กดรับทุกอย่าง · โหวตแมพเอง · สวม title สูงสุดที่ปลดล็อก")
	g3:Label("<b>สวมของดีสุด + ซื้ออัตโนมัติ (AutoEquip)</b> — นอกแมตช์: เทียบ rank ของในคลังแล้วสวมตัวดีสุด (อัพเกรดอย่างเดียว ไม่สลับของวน) · เพชรพอ = ซื้อสกิล/ไอเทมที่ยังไม่มี ทีละชิ้นห่าง 5s")
	g3:Label("<b>เพชรข้างทาง (GemFarm)</b> — เบี่ยงเก็บเพชรเฉพาะตอนปลอดภัยสมบูรณ์ (เหยี่ยวห่าง >30m และไม่มี reach) · ชนะรอบสำคัญกว่าเพชรเสมอ — ใกล้ชนะเพชรปิดสนิท")
	local g4 = sub:Groupbox("ปุ่มลัด / ความปลอดภัย", "Right")
	g4:Label("<b>RightShift</b> ซ่อน/แสดงเมนู · <b>RightAlt</b> แผงคีย์ลัดทั้งหมด · <b>K</b> เปิด/ปิดระบบด่วน (ไม่ต้องเปิดเมนู) · <b>Del</b> ปิดฮับถาวร · <b>M</b> เปิดเมนู")
	g4:Label("<b>มือถือ</b> — ย่อเมนูแล้วแตะปุ่มลอย HZ HUB เพื่อเปิดกลับ · ลากแถบไปชิดขอบจอ = พับเก็บอัตโนมัติ · แตะปุ่ม ? ข้างสวิตช์เพื่ออ่านคำอธิบาย")
	g4:Label("<b>ความปลอดภัย</b> — ทุก remote ถูกยิงด้วยค่าที่ server ยอมรับ (ระยะ/ทิศ/สถานะจริง) ไม่สแปม · ปิดระบบด่วน (K) ปล่อยปุ่ม WASD ทั้งหมดทันที · log ทุกเหตุการณ์อยู่ที่ hz_valley_log.txt")
	if BUILD.forgetKey then
		local gk = sub:Groupbox("คีย์ทดสอบ", "Right")
		gk:Label("<b>สถานะ:</b> ใช้งานด้วยคีย์ที่ผูกเครื่องนี้แล้ว (wm=" .. tostring(BUILD.wm or "-") .. ")")
		gk:Button{ label = "ลืมคีย์ที่จำไว้", cb = function()
			pcall(BUILD.forgetKey)
			notify("คีย์", "ลืมคีย์แล้ว — รอบหน้าจะถามคีย์ใหม่")
		end }
	end
end

FishUI.StandardPages(win, {
	brand = "HZ HUB", version = BUILD.tag or "2.1",
	games = { { name = gameName, placeId = game.PlaceId, status = "play", note = "แมพนี้" } },
	changelog = {
		{ "v2.3", "เอา ESP ออก + เสียงคลิกนุ่มน่ารักทุกปุ่ม + กันรันซ้อน + แก้บั๊ก" },
		{ "v2.2", "telemetry เชื่อมหลังบ้าน (win/kill/warn/alive) + เลือกฝั่ง Hero + แก้บั๊ก" },
		{ "v2.1", "UI ใหม่ FishUI + รองรับมือถือ + คัดลอกรายงานบัคในตัว" },
		{ "v2.0", "tackle/melee พิสูจน์ฆ่าจริง · ชุบตัวเองอัตโนมัติ · Map3 เดินอ้อมตึก" },
	},
	discord = BUILD.discord,
})

-- flash banner กลางจอ
local flashLbl = Instance.new("TextLabel", gui)
flashLbl.Size = UDim2.new(0, 580, 0, 48)
flashLbl.Position = UDim2.new(0.5, -240, 0.16, 0)
flashLbl.BackgroundTransparency = 1
flashLbl.Text = ""
flashLbl.Font = Enum.Font.GothamBold flashLbl.TextSize = 26
flashLbl.TextStrokeTransparency = 0.35
flash = function(txt, col)
	flashLbl.Text = txt
	flashLbl.TextColor3 = col or Color3.new(1, 1, 1)
	S.flashUntil = os.clock() + 1
end

-- ปุ่มลัด: M = เมนู (RightShift ของ FishUI ใช้ได้เหมือนกัน), Del = ปิดฮับถาวร, K = ผูกกับสวิตช์ระบบหลักแล้ว
conns[#conns + 1] = UIS.InputBegan:Connect(guard("input", function(io, gpe)
	if gpe then return end
	if io.KeyCode == Enum.KeyCode.M then
		win:toggle()
	elseif io.KeyCode == Enum.KeyCode.Delete then
		KILL = true
		pcall(function() gui:Destroy() end)
		pcall(function() win:Destroy() end)
	end

end))

-- ─── ลูปสถานะสด → ป้ายในหน้า ภาพรวม (ต่อท้ายไฟล์ หลัง journey) ───

-- ─── PERFECT DODGE: server ยืนยันเองทาง BoostRequest → นับของจริง + flash ทอง ───
conns[#conns + 1] = rBoost.OnClientEvent:Connect(guard("boost", function(a)
	if a == "PerfectDodge" then
		stats.perfect += 1
		log("[PERFECT] หลบสวย! (" .. stats.perfect .. ")")
		if rp then rp("perfect") end
		flash("PERFECT DODGE!", Color3.fromRGB(255, 218, 111))
	end

end))

-- ─── JOURNEY TITLE: อ่าน state จริง (badges owned) + auto-equip ตัวดีสุด ───
-- rank ตาม tier ปลดล็อก (premium เหนือ free tier เดียวกัน): ELITE=ทอง tier30 free / ROYALTY=tier30 premium
local journey = { tier = 1, xp = 0, badge = "", owned = {} }
local BADGE_RANK = { FirstSteps = 1, QuickFeet = 2, NightRunner = 3, CornerArtist = 4,
	Untouchable = 5, CrownChaser = 6, ValleyVeteran = 7, ValleyElite = 8, ValleyRoyalty = 9 }
local BADGE_NAME = { FirstSteps = "FIRST STEPS", QuickFeet = "QUICK FEET", NightRunner = "NIGHT RUNNER",
	CornerArtist = "CORNER ARTIST", Untouchable = "UNTOUCHABLE", CrownChaser = "CROWN CHASER",
	ValleyVeteran = "VALLEY VETERAN", ValleyElite = "VALLEY ELITE", ValleyRoyalty = "VALLEY ROYALTY" }
if rJourney then
	conns[#conns + 1] = rJourney.OnClientEvent:Connect(guard("journey", function(a, st)
		if a ~= "State" or type(st) ~= "table" then return end
		journey.tier, journey.xp = st.tier or journey.tier, st.xp or journey.xp
		journey.badge = st.badge or ""
		journey.owned = st.badges or {}
		if cfg.Enabled and cfg.AutoTitle then
			local bk, bv = nil, BADGE_RANK[journey.badge] or 0
			for k, on in pairs(journey.owned) do
				local r = BADGE_RANK[k] or 0
				if on == true and r > bv then bk, bv = k, r end
			end
			if bk then
				pcall(function() rJourney:FireServer("EquipBadge", bk) end)
				log("[TITLE] สวม: " .. (BADGE_NAME[bk] or bk))
				flash("TITLE: " .. (BADGE_NAME[bk] or bk), Color3.fromRGB(247, 214, 133))
			end
		end

	end))
end

-- cleanup ตอน KILL: ปล่อยปุ่ม + ตัด connections + ทำลาย GUI
task.spawn(function()
	while not KILL do task.wait(0.3) end
	setKeys({}) steerActive = false steer = nil
	pcall(function() RunService:UnbindFromRenderStep("HZSteer") end)
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	pcall(function() gui:Destroy() end)
	pcall(function() win:Destroy() end)
end)

-- ─── ลูปสถานะสด → ป้ายในหน้า ภาพรวม (FishUI) ───
local function setT(l, t) if l and l.Text ~= t then l.Text = t end end
task.spawn(function()
	local PHASE_TH = { Intermission = "พักรอบ", Prepare = "เตรียมตัว", SelectHero = "เลือกไก่/เหยี่ยว",
		HeroChoice = "เลือกฝั่ง", ChoiceReveal = "เปิดเผยฝั่ง", GroupRun = "วิ่งกลุ่ม",
		FinalRun = "วิ่งตัดสิน", RunResolution = "สรุปผลวิ่ง", Results = "ผลลัพธ์" }
	local ROLE_TH = { Runner = "ไก่", Catcher = "เหยี่ยว", Lobby = "ล็อบบี้" }
	while not KILL do
		guard("statusUI", function()
		local role, st8 = myRole(), runState()
		local runners, catchers = #eachRole("Runner"), #eachRole("Catcher")
		local phaseRaw = attr(Session, "Phase", "-")
		local phase = PHASE_TH[phaseRaw] or phaseRaw
		local gems = armory.gems and tostring(math.floor(armory.gems)) or "-"
		local esc = attr(Session, "EscapeStreakState", nil)
		if type(esc) == "string" then
			local okJ, j = pcall(function() return Http:JSONDecode(esc) end)
			esc = okJ and j or nil
		end
		local escS = ""
		if type(esc) == "table" and esc.count and esc.goal then
			S.streakLeft = math.max(0, (esc.goal or 3) - (esc.count or 0))
			escS = S.streakLeft == 1 and "เหลือ 1 = ชนะ!" or string.format("หนีรอด %s/%s", tostring(esc.count), tostring(esc.goal))
		else
			S.streakLeft = nil
		end
		local knife = attr(LP, "EquippedKnife", "-")
		local pk = KnifePerks and KnifePerks.forSkin and KnifePerks.forSkin(knife) or nil
		local knifeS = knife .. (pk and pk.Key ~= "None" and string.format(" (%s +%.2f)", pk.Key, pk.SpeedBonus) or "")
		local endsAt = attr(Session, "EndsAt", 0)
		local timeLeft = (type(endsAt) == "number" and endsAt > 0) and string.format("%.0fs", math.max(0, endsAt - now())) or ""
		local icon = role == "Catcher" and "<font color='rgb(255,120,120)'>●</font>" or (role == "Runner" and "<font color='rgb(120,255,160)'>●</font>" or "<font color='rgb(160,160,170)'>●</font>")
		local liveCol = not cfg.Enabled and C.acc or (inMatch() and C.on or C.warm)
		setT(LIVE.head, string.format("<b>%s %s · %s %s</b>", icon, ROLE_TH[role] or role, phase, timeLeft))
		setT(LIVE.state, string.format("สถานะ: <b>%s</b>%s", st8, escS ~= "" and (" · " .. escS) or ""))
		setT(LIVE.team, string.format("<font color='rgb(120,255,160)'>●</font> ไก่ %d · <font color='rgb(255,120,120)'>●</font> เหยี่ยว %d · เพชร %s", runners, catchers, gems))
		setT(LIVE.streak, string.format("<font color='rgb(%d,%d,%d)'>●</font> %s",
			math.floor(liveCol.R * 255), math.floor(liveCol.G * 255), math.floor(liveCol.B * 255),
			cfg.Enabled and (inMatch() and "ระบบทำงาน" or "รอแมตช์") or "ปิดระบบอยู่"))
			local nowT2 = now()
		local function cd(a) local v = attr(LP, a, 0) if v <= 0 then return "-" end
			return v <= nowT2 and "พร้อม" or string.format("%.1fs", v - nowT2) end
		setT(LIVE.cd, string.format("Tackle: %s · Ghost: %s · Clone: %s",
			inMatch() and cd("TackleReadyAt") or "-",
			cd("GhostAbilityReadyAt"), cd("CloneAbilityReadyAt")))
		setT(LIVE.gear, "สกิล: " .. tostring(equippedGear(role == "Catcher" and "Catcher" or "Runner")))
		setT(LIVE.knife, "มีด: " .. knifeS)
		setT(LIVE.title, string.format("Journey T%s/30 %s", tostring(journey.tier or 1),
			journey.badge ~= "" and (BADGE_NAME[journey.badge] or journey.badge) or "(ยังไม่มี title)"))
		setT(LIVE.stat, string.format("รอด %d · โดนจับ %d · หลบ %d · เพอร์เฟ็กต์ %d\nสกิลหนี %d · ไล่ %d · ghost %d · ชุบ %d",
			stats.safe, stats.caught, stats.dodge, stats.perfect, stats.gearFlee, stats.gearChase, stats.ghost, stats.rescue))
		setT(LIVE.last, "» " .. tostring(S.last))
		-- flash banner: แสดงครู่เดียวแล้วหาย (S.flashUntil ตั้งใน flash())
		if S.flashUntil and os.clock() > S.flashUntil and flashLbl.Text ~= "" then flashLbl.Text = "" end
		end)()
		task.wait(0.25)
	end
end)


-- ─── logger ละเอียด: เฝ้าเปลี่ยนสถานะ + snapshot ทุก 5 วิ ───
local prev = {}
task.spawn(function()
	local snap = 0
	while not KILL do
		guard("logger", function()
		local role, st8, phase = myRole(), runState(), attr(Session, "Phase", "-")
		if role ~= prev.role then log("ROLE → " .. role) rp("role", role) prev.role = role end
		if st8 ~= prev.st8 then
			local mid = attr(Session, "ActiveMapId", "?")
			if st8 == "Safe" then stats.safe += 1 rp("win", mid) elseif st8 == "Caught" then stats.caught += 1 rp("lost", mid) end
			log(string.format("STATE → %s (%s) | รอด%d โดนจับ%d หลบ%d เพอร์เฟ็กต์%d สกิลหนี%d ไล่%d ghost%d ชุบ%d",
				st8, role, stats.safe, stats.caught, stats.dodge, stats.perfect, stats.gearFlee, stats.gearChase, stats.ghost, stats.rescue))
			prev.st8 = st8
		end
		if phase ~= prev.phase then log("PHASE → " .. phase) prev.phase = phase end
		if inMatch() ~= prev.match then log("MATCH → " .. tostring(inMatch())) prev.match = inMatch() end
		if os.clock() - snap > 5 then
			snap = os.clock()
			-- heartbeat: แจ้ง worker ว่ายังเล่นอยู่ (ทุก ~4นาที ตอนในแมตช์ — admin เห็นผู้ใช้ที่แอคทีฟจริง)
			if inMatch() and os.clock() - (S._aliveT or -999) > 240 then S._aliveT = os.clock() rp("alive") end
			local me = hrp()
			local h = hum()
			local nc, cd = nearest(eachRole("Catcher"), me and me.Position or Vector3.zero)
			local nr, rd = nearest(eachRole("Runner"), me and me.Position or Vector3.zero)
			log(string.format("tick role=%s st=%s ph=%s | pos=%s vel=%.0f hp=%s | catcherใกล้=%s runnerใกล้=%s | steer=%s | last=%s",
				role, st8, phase,
				me and string.format("(%.0f,%.0f,%.0f)", me.Position.X, me.Position.Y, me.Position.Z) or "?",
				me and me.AssemblyLinearVelocity.Magnitude or 0,
				h and math.floor(h.Health) or "dead",
				nc and math.floor(cd) or "-", nr and math.floor(rd) or "-",
				steer and string.format("(%.2f,%.2f)", steer.X, steer.Z) or "nil",
				tostring(S.steerWhy or "-")))
		end
		end)()
		task.wait(0.5)
	end
end)

log("HZ VALLEY loaded — role: " .. myRole() .. " | M=เมนู K=ปิดด่วน Del=ปิดถาวร | log -> hz_valley_log.txt")
