-- hz_ubg.lua v9.0 — v8 core + post-v8 hardening (namespaces/inbound-suppress/high-ping dodge/block-floor) — HZ HUB: UBG combat assist (สากล ไม่แยกสไตล์ — ใช้ได้ทุกสไตล์เหมือนกัน)
-- ใช้: loadstring(readfile("hz_ubg.lua"))()  (bf_loader โหลดอัตโนมัติตาม PlaceId)
-- หลักการ: ไม่แตะ remote เอง — ยิงผ่าน BindEvent ของเกม + เขียน Occupied state ตรงๆ
--          (LockedOn/Equipped เป็น client-authoritative ตามโค้ดเกมจริง) = native 100%
-- แกนหลัก: หลบเพอร์เฟกต์ 0ms ตอน window เปิด → สวนทันทีในช่วงศัตรู slow-mo → อัลติเฉพาะจังหวะที่ศัตรูทำอะไรไม่ได้
-- ค่าทุกตัวอ้างโค้ดเกมจริง (dump/deimos2_*): Dash deimos2_8:16890-17700, Perfect window deimos2_25:15560-15700,
--   GameplaySettings deimos2_7:3030-3180 (RollbackTime 0.15 / DoubleDashingWindow 0.8), Punch deny deimos2_8:11199
local __ok, __err = pcall(function()
-- เขียนสถานะทันทีก่อนรออะไรทั้งหมด — ถ้าไฟล์นี้ไม่ขึ้นแปลว่าฮับไม่ได้ถูกรันเลย (ปัญหาที่ loader/autoexec ไม่ใช่ที่ตัวฮับ)
pcall(writefile, "hz_ubg_status.txt", "STARTED place=" .. tostring(game.PlaceId) .. " t=" .. os.date("%X"))
-- สนามสู้ที่ hub ทำงาน: Main + Ranked + Troll (+ อ่าน Places ของเกมเพิ่ม ยกเว้นล็อบบี้)
-- ล็อบบี้คิวจัดอันดับ NA/SA/EU/AS (เมนู "เข้าสู่การจับคู่") ไม่มี remote ต่อสู้เลย (ยืนยันจากเกมจริง: TryPunch/SetBlock/Replicate หายหมด)
-- → ไม่โหลดฮับที่นั่น; พอถูกเทเลพอร์ตเข้าแมตช์ (Ranked 14397772816) loader จะโหลดฮับให้เองผ่าน queue_on_teleport
local COMBAT_PLACES = {
	[13621938427] = true, -- Main
	[14397772816] = true, -- Ranked (สนามแมตช์จริง)
	[74284738287504] = true, -- Troll
	[14303967410] = true, -- Testing.Ranked
	[14975874252] = true, -- ศูนย์การค้า (States/MobileEvents/remotes ครบ — PvP เปิดได้ในมอลล์)
}
local LOBBY_PLACES = {
	[14397680739] = "NA", [14397682137] = "SA", [14397683205] = "EU", [14397684147] = "AS",
}
-- (เดิมอ่าน ReplicatedFirst.Places เพิ่ม — ตัดออก: engine call ช่วงต้นเกมเสี่ยงบน executor ที่ offsets ไม่ตรง ใช้ id ฮาร์ดโค้ดแทน)
if LOBBY_PLACES[game.PlaceId] then
	pcall(writefile, "hz_ubg_status.txt", "LOBBY place=" .. tostring(game.PlaceId) .. " region=" .. LOBBY_PLACES[game.PlaceId]
		.. " (ล็อบบี้คิวไม่มีระบบต่อสู้ — ฮับโหลดหลังเข้าแมตช์ผ่าน queue_on_teleport)")
	return
end
if not COMBAT_PLACES[game.PlaceId] then
	pcall(writefile, "hz_ubg_status.txt", "SKIPPED place=" .. tostring(game.PlaceId))
	return
end
pcall(writefile, "hz_ubg_status.txt", "LOADING place=" .. tostring(game.PlaceId) .. " (รอ remote/States ของเกม — ถ้าค้างข้อความนี้นานเกิน ~40 วิ = เกมยังโหลดไม่ครบ/หา remote ไม่เจอ)")
-- kill อินสแตนซ์เก่าก่อน (conns/loops/UI รอบที่แล้ว — รันซ้ำไม่ซ้อน)
if _G.HZUBG and _G.HZUBG.kill then pcall(_G.HZUBG.kill) task.wait(0.1) end
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
-- UI parent: gethui() (container ซ่อนของ executor — script เกมมองไม่เห็น) → fallback PlayerGui
local guiRoot = (gethui and gethui()) or LP:WaitForChild("PlayerGui")
-- ทำลาย GUI เก่าทุก container (v6.0 ทิ้งไว้ใน PlayerGui / อินสแตนซ์ที่โดน early-kill ทิ้ง pill ผี)
local function killStaleGui()
	for _, rt in ipairs({ guiRoot, LP:FindFirstChild("PlayerGui") }) do
		local old = rt and rt:FindFirstChild("HZUBG")
		if old then pcall(function() old:Destroy() end) end
	end
end
local gen = tick()
_G.HZUbgGen = gen
pcall(killStaleGui)

-- ===== config + persist =====
local CFG_FILE = "HZHub_ubg.json"
-- เลขรุ่นไฟล์เซฟ: เปลี่ยนเมื่อแก้ default สำคัญ — ไฟล์เซฟรุ่นเก่าถูกทิ้ง (เก็บแค่ตำแหน่ง UI)
-- กันค่าเก่า (เช่น FixedDelay=true / AutoSpecial=true) ค้างในไฟล์แล้วทับค่าที่ตรวจแล้ว (ต้นเหตุ "แก้โค้ดแล้วบอทยังทำตัวเหมือนเดิม")
local CFG_VER = 10
local cfg = {
	-- v9: features ใหม่ (จาก deep analysis)
	UsePSPlus = true,        -- อ่านค่าจริงจาก PrivateServerSettings (PS+ เซิร์ฟปรับค่าได้)
	UseStartupMult = true,   -- startup ×1.08/1.02/÷1.05 ตามประเภทหมัด (สูตรเกมจริง)
	UsePingDiff = true,      -- (pingเรา-pingศัตรู)/2 ปรับ predict
	VisualGloves = false,    -- ใส่นวมให้ตัวเองเห็น (local-only cosmetic)
	VisualGloveName = "Embers", -- นวมที่จะโชว์ (id จาก RS.Gloves)
	VisualUnusual = "",      -- effect (เช่น "Shards")
	AutoQueue = false,       -- auto เข้าคิว ranked เมื่อ MatchStarted=false นานเกิน
	AutoClaimDaily = false,  -- รับ daily reward อัตโนมัติเมื่อมี
	AutoSpin = false,        -- spin style อัตโนมัติ (ระวัง!)
	AutoFreeEmote = false,   -- รับอีโมตฟรี
	Enabled = true,     -- สวิตช์หลัก: ปิด = หยุดทุกระบบ (UI ยังอยู่)
	AutoPD = true,      -- auto perfect dodge (หน้าต่าง Perfect) — แดชทันที 0ms ตอน window เปิด
	AntiFeint = true,   -- ไม่หลบหมัด feint
	AutoBlock = true,   -- บล็อกหมัดที่หลบไม่ได้ (ไม่มี Perfect window)
	AutoPunish = true,  -- สวนเมื่อศัตรูหมัดหวด/พัก
	PunishAfterPD = true, -- สวนทันทีหลังหลบเพอร์เฟกต์ (ศัตรู slow-mo = ฟรีฮิต)
	AutoLock = true,    -- ล็อกออนคนที่ต่อยเราอัตโนมัติ
	Predict = true,     -- สมองคาดการณ์: frame data จริง + cadence ที่เรียนรู้เอง
	AdaptFeint = true,  -- เรียนรู้สายล่อเฟนต์: เฟนต์บ่อย>35% ของหมัดเปิด → สลับบล็อกแทนแดช
	AutoEquip = true,   -- ใส่ถุงมืออัตโนมัติ (client เขียน Equipped ได้)
	AutoM1 = true,      -- ต่อย M1 อัตโนมัติ: ฟรีฮิตตอนศัตรูเสียหลัก + เจาะช่องว่าง (ดู AutoPoke)
	AutoPoke = true,    -- เจาะต่อยทุกช่องที่ศัตรูไม่ได้กำลังชก (คอมโบ gap/นิ่ง/บล็อก) — stun-lock พลิกจังหวะ = บุกดุแบบเดิม
	AutoHeavy = true,   -- ต่อยหนักตอนศัตรูอยู่ในสภาพเสียหลักนาน (เกจสตามิน่า/บล็อกแตก/สตันหนัก)
	AutoBreak = true,   -- หนักแตกเกราะ: ศัตรูบล็อกค้าง >0.9s → ต่อยหนักทำลาย
	AutoFeint = true,   -- เฟนต์ล่อแดช: ศัตรูหลบหมัดเราบ่อย → ปล่อยหมัดหลอกเผาแดชมันแล้วต่อยจริง (ฆ่าบอทหลบเก่ง/คนหลบเก่ง)
	AutoEngage = true,  -- บุกเข้าหา: ศัตรูอยู่นอกระยะชก + ไม่ได้ชกเรา → แดชเข้าไปต่อย (DashFollowup ได้ advantage)
	AutoSpecial = true, -- กดสเปเชียลเมื่อเป้าอยู่ในระยะและเราว่าง/มันเสียหลัก (ยิงเฉพาะช่องว่างจริง — ไม่ล็อกตัวเองกลางหมัดมัน)
	AutoUlt = true,     -- อัลติเฉพาะตอนศัตรูทำอะไรไม่ได้ (เกจแตก/สตันหนัก/สโลว์โมหลังโดนหลบ) — ไม่ยิงลอย
	PanicBlock = true,  -- บล็อกฉับไวเมื่อศัตรูชกใส่เราระยะประชิด
	DodgeWindowOnly = true, -- แดชเฉพาะหมัดเปิดคอมโบ/หนัก/อัลติ — หมัดกลางคอมโบให้บล็อก ประหยัดแดชไว้เพอร์เฟกต์
	FixedDelay = false, -- บอทเทพ 0ms: ตอบสนองทันทีทุก reaction (เปิด = หน่วงคงที่ FixedDelaySec)
	FixedDelaySec = 0.05, -- หน่วงคงที่ (วินาที) ทุก reaction
	EnemyHUD = true,
	BlockLead = 0.05,   -- บล็อกก่อน land กี่วิ (บวก ping/2 อัตโนมัติ)
	BlockHold = 0.4,    -- ค้างบล็อกกี่วิ
	BlockRelease = 0.3, -- ศัตรูหยุดชกแล้วถือบล็อกต่อกี่วิก่อนปล่อย (เกมล็อกบล็อกซ้ำ 0.3s หลังปล่อย)
	PunishRange = 8,    -- ระยะสวน (studs)
	M1Range = 6.5,      -- ระยะ AutoM1
	EngageRange = 14,   -- ระยะบุก: ศัตรูอยู่นอก M1 แต่ไม่เกินนี้ → แดชเข้าหาแล้วต่อย (DashFollowup ได้ advantage)
	LockRange = 18,     -- ระยะสูงสุดที่จะล็อกออนอัตโนมัติ
	ReactRange = 5,     -- ระยะที่หมัดถึงเราได้จริง — ไกลกว่านี้ต่อยมั่วก็ไม่หลบ/บล็อก (ดูเป็นบอท)
	SpecialRange = 10,  -- ระยะ AutoSpecial
	UltRange = 6.5,     -- ระยะ AutoUlt: พุ่ง 2.7 (DefaultMoverInfo.MaxDistance) + hitbox ~4 (HitboxSize.Z+rand) ≈ 6.7 — ไกลกว่านี้พุ่งไม่ถึง = เสียเกจ 100 ฟรี
	MinStaminaFrac = 0.22, -- ห้ามต่อยถ้าสตามิน่าต่ำกว่าสัดส่วนนี้ (กันแพ้เพราะสตามิน่าหมด)
	BlockMinEnergy = 14,   -- เกจบล็อกต่ำกว่านี้ไม่บล็อก (เดี๋ยวเกจแตกแล้วสตัน)
	UltMinHP = 35,       -- เลือดเราต่ำกว่า % นี้ → เก็บอัลติไว้ยกถัดไป (อัลติตอนใกล้ตาย = เสียเปล่า — สายหลายชีวิตยิ่งไม่คุ้ม)
	AutoStrafe = true,   -- เดินออโต้: วนซ้ายขวารอบเป้า + รักษาระยะชก (ดูเป็นคนจริง + หมัดศัตรูเฉี่ยว + เข้าระยะเอง)
}
local DEF = {} -- ค่าเริ่มต้น (ก่อนโหลดไฟล์) ไว้ให้ปุ่ม 'คืนค่าปรับทั้งหมด'
for k, v in pairs(cfg) do DEF[k] = v end
do
	local ok, raw = pcall(readfile, CFG_FILE)
	if ok and type(raw) == "string" and #raw > 0 then
		local ok2, t = pcall(function() return HttpService:JSONDecode(raw) end)
		if ok2 and type(t) == "table" then
			if t.CfgVer == CFG_VER then
				for k, v in pairs(t) do cfg[k] = v end
			else
				for _, k in ipairs({ "PillPos", "Fold" }) do cfg[k] = t[k] end -- รุ่นเก่า: ทิ้งค่าต่อสู้ทั้งหมด เก็บแค่ตำแหน่งไอคอน/หมวดพับ (PanelPos ทิ้ง — anchor เปลี่ยนใน v8)
			end
		end
	end
	for k, v in pairs(DEF) do if type(cfg[k]) ~= type(v) then cfg[k] = v end end -- ชนิดค่าผิด (ไฟล์เสีย/แก้มือ) → ใช้ default
	cfg.CfgVer = CFG_VER
end
local function saveCfg()
	pcall(writefile, CFG_FILE, HttpService:JSONEncode(cfg))
end

-- สวิตช์ที่ผูกกัน: on=เปิดตามเมื่อเปิด, offWhenOff=ปิดตามเมื่อปิด
local TIE = {
	PunishAfterPD = { on = { "AutoPunish" } },               -- สวนหลัง PD ต้องเปิดสวนก่อน
	AutoPunish = { offWhenOff = { "PunishAfterPD" } },       -- ปิดสวน = สวนหลัง PD ตายตาม
}
local function applyTies(key)
	local t = TIE[key] if not t then return end
	if cfg[key] then
		for _, k in ipairs(t.off or {}) do cfg[k] = false end
		for _, k in ipairs(t.on or {}) do cfg[k] = true end
	else
		for _, k in ipairs(t.offWhenOff or {}) do cfg[k] = false end
	end
end
for k in pairs(TIE) do applyTies(k) end -- normalize ค่าที่โหลดจากไฟล์

-- kill รอบก่อน (re-run แล้วไม่ให้ซ้ำ)
if _G.HZUBG and type(_G.HZUBG.kill) == "function" then
	pcall(_G.HZUBG.kill)
end

-- ===== game handles =====
-- จำเป็น (TryPunch/SetBlock/EV.ReplicateTryAttack) รอได้นาน — ตัวเสริมรอสั้น กัน ranked โหลดช้าเพราะรอของที่ไม่มี
local function optChild(parent, name, t)
	return parent and (parent:FindFirstChild(name) or parent:WaitForChild(name, t or 4)) or nil
end
local EV = {} -- remote/event handles (namespace — ประหยัด register เพดาน 200/function)
local MobileEvents = RS:WaitForChild("MobileEvents", 20)
EV.TryPunch  = MobileEvents and MobileEvents:WaitForChild("TryPunch", 20)
EV.SetBlock  = MobileEvents and MobileEvents:WaitForChild("SetBlock", 20)
EV.UseSpecial  = optChild(MobileEvents, "UseSpecial")
EV.SwitchEquip  = optChild(MobileEvents, "TrySwitchEquip")
local Events = RS:WaitForChild("Events", 20)
EV.ForceDash  = optChild(Events, "ForceDash", 5) -- ถ้าไม่มีใช้ TryDash/TryQuickStep ของเกมแทน
EV.TryDash  = optChild(MobileEvents, "TryDash")
EV.TryQuickStep  = optChild(MobileEvents, "TryQuickStep")
local RemoteEvents = RS:WaitForChild("RemoteEvents", 20)
EV.ReplicateTryAttack  = RemoteEvents and RemoteEvents:WaitForChild("ReplicateTryAttack", 20)
-- (เดิมมี local canDash — inline ประหยัด local register: ไฟล์ชนเพดาน 200 ของ Lua)
if not (EV.TryPunch and EV.SetBlock and (EV.ForceDash or EV.TryDash or EV.TryQuickStep) and EV.ReplicateTryAttack) then
	warn("[HZ UBG] หา remote ไม่ครบ — เกมอัปเดตหรือยังไม่โหลด?")
	pcall(writefile, "hz_ubg_status.txt",
		"MISSING_REMOTES place=" .. tostring(game.PlaceId)
		.. " TryPunch=" .. tostring(EV.TryPunch ~= nil)
		.. " SetBlock=" .. tostring(EV.SetBlock ~= nil)
		.. " ForceDash=" .. tostring(EV.ForceDash ~= nil)
		.. " TryDash=" .. tostring(EV.TryDash ~= nil)
		.. " QuickStep=" .. tostring(EV.TryQuickStep ~= nil)
		.. " Replicate=" .. tostring(EV.ReplicateTryAttack ~= nil))
	return
end

local States = WS:WaitForChild("States", 20)
local Live = WS:WaitForChild("Live", 20)

-- ⚠️ ห้ามแตะ ReplicatedFirst.C0ntrolModule (anti-tamper: FireMePlease = สั่ง server เตะเรา)
-- เก็บ helper ที่ใช้ซ้ำในตาราง V9 เดียว (ไฟล์ใกล้เพดาน 200 locals) — closures เก็บเป็น upvalue
local V9 = {}

-- ===== namespaces: รวม standalone locals เข้าถุงเดียว (เพดาน 200 registers/function) =====
local STATE = { -- timers/counters/flags ของบอท — ทุกตัวอ่าน-เขียนผ่าน STATE.x
	lastSpecial = 0, lastUlt = 0, lastEngage = 0, lastM1 = 0, -- คูลดาวน์ลูปอัตโนมัติ
	lastDodge = 0, lastDashOK = 0, lastPunish = 0, lastOurPunch = 0, -- lastDodge กันแดชซ้ำ / lastOurPunch วัดศัตรูหลบหมัดเรา
	gateUntil = 0, -- มีหมัดเล็งเราจริง = แมตช์เริ่มแล้ว แม้ MatchStarted ยัง false
	pdPunishAt = 0, pdConfirm = 0, -- pdConfirm = server ยืนยันเพอร์เฟกต์ (attr PerfectDodged)
	inboundUntil = 0, -- หมัดจริงเล็งเรากำลังบินมาถึงเวลานี้ (packet arrival + startup) — m1Strike/tryPunish ห้ามเริ่มหมัดใหม่ทับ window
	pdCount = 0, blockCount = 0, punishCount = 0, feintCount = 0, foolishCount = 0, hitCount = 0, -- สถิติหัวเมนู
	ultReadyWarned = false, abiReadyWarned = false, flashUntil = 0,
	open = false, movedPanel = false, evDirty = false,
}
local MAPS = { -- tracking tables ต่อ char/tag (sweep ล้างเป็นระยะใน maint loop)
	threatMark = {}, -- char -> tick ล่าสุดที่เล็งเรา
	feintMark = {},  -- char -> tick ล่าสุดที่เห็น feint
	slowMoStart = {},-- char -> tick ที่ SlowMo เริ่ม (heavyWorthy ใช้ตัดสิน)
	breakMark = {},  -- char -> ถึงเวลานี้หมัดถัดไปควรเป็นหนัก (AutoBreak)
	heavyMark = {},  -- char -> ถึงเวลานี้ห้ามยิงหนักซ้ำ — หนัก 1 ครั้งต่อหน้าต่างเสียหลัก (หนัก whiff = recovery โดนสวน)
	learn = {},      -- char -> {n, opens, feints, times[], lastAtk, warned}
	watchedAtk = {}, -- char -> {conn,...} ~11 watchers/attacker (t0 = TTL)
	blockHolds = {}, blockMeta = {}, relMark = {}, -- tag -> hold/meta/release-stamp
	rlMark = {}, stHook = {}, EVLOG = {},
}
-- ระหว่างรอ remote/States นาน ๆ (ranked โหลดช้า) อาจมีรอบใหม่ถูกสั่งรันแทรก → รอบเก่าต้องถอยเงียบ ๆ ไม่ทับ _G.HZUBG ของรอบใหม่
if _G.HZUbgGen ~= gen then return end
-- Ranked: folder อาจมาช้ากว่าสคริปต์/ชื่อต่าง — resolve ใหม่ทุกครั้งที่อ่าน (States/Live = upvalue mutable)
function V9.liveStates()
	if not (States and States.Parent) then States = WS:FindFirstChild("States") or States end
	return States
end
function V9.liveLive()
	if not (Live and Live.Parent) then Live = WS:FindFirstChild("Live") or Live end
	return Live
end
local TeleportService = game:GetService("TeleportService")
local KILL = false
local flash
local conns = {}
-- ลงทะเบียน kill ชั่วคราวทันที — ถ้าโหลดพังกลางทาง รอบหน้ายังสั่งหยุด loop ของรอบนี้ได้ (ตัวเต็มทับตอนท้ายไฟล์)
-- ทำลาย GUI ด้วย: อินสแตนซ์ที่สร้าง UI แล้วโดน early-kill = pill ผีค้างจอ (สาเหตุ 2 pill ซ้อน)
_G.HZUBG = { kill = function() KILL = true pcall(killStaleGui) end, early = true }
-- ring buffer เหตุการณ์ล่าสุด → hz_ubg_log.txt (ส่งไฟล์นี้มาเวลาสงสัยว่าทำไมไม่ทำงาน/ทำผิด)
local function evlog(s)
	MAPS.EVLOG[#MAPS.EVLOG + 1] = string.format("%8.2f %s", tick() % 10000, s)
	if #MAPS.EVLOG > 400 then table.remove(MAPS.EVLOG, 1) end -- ไฟต์นึง atk หลายร้อยบรรทัด — 60 เดิมทิ้งเหตุการณ์สำคัญก่อนถึงไฟล์
	STATE.evDirty = true
end
-- log เหตุผลที่ "ไม่ทำ" (PD skip ฯลฯ) แบบกันรัว: key เดียวกันไม่ซ้ำเกิน gap วิ
local function evlogRL(key, s, gap)
	local now = tick()
	if now - (MAPS.rlMark[key] or 0) < (gap or 0.4) then return end
	MAPS.rlMark[key] = now
	evlog(s)
end

-- ===== decode attackString (20 chars fixed-width ตาม spec) =====
local function parseAtk(s)
	if type(s) ~= "string" or #s < 20 then return nil end
	local pn = tonumber(s:sub(3, 4))
	return {
		combo = tonumber(s:sub(1, 2)),
		punch = pn,
		special = type(pn) == "number" and pn >= 90 and pn <= 97, -- punch 90-97 = ability (PerfectDodgeAbilityGuard.IsSpecialAttack)
		heavy = s:sub(5, 5) == "1",
		ult = s:sub(6, 6) == "1",
		charge = s:sub(7, 7) == "1",
		isStart = s:sub(8, 8) == "1",
		locked = s:sub(9, 9) == "1",
		ping = tonumber("0." .. s:sub(10, 14)),
		id = tonumber(s:sub(15, 19)),
		feint = s:sub(20, 20) == "1",
	}
end
function V9.decodeArgs(v) -- (เป็น V9 field — ประหยัด local register, ไฟล์ชนเพดาน 200)
	-- EV.ReplicateTryAttack payload: {buffer, attackerChar, selfFlag?}
	local char = v[2]
	if typeof(char) ~= "Instance" then return nil end
	local buf = v[1]
	if typeof(buf) == "buffer" then
		local b: any = buf
		local id = buffer.readu16(b, 0)
		local len = buffer.readu32(b, 2)
		local s = buffer.readstring(b, 6, len)
		local a = parseAtk(s)
		if a then
			a.netId, a.char, a.selfEcho = id, char, v[3] == true
			-- f32 ท้าย buffer = startup (วิ) นับจากแพ็กเก็ตมาถึง — ตัวเดียวกับที่เกมใช้เปิด Perfect window (ยืนยันจาก bf_sniff จริง)
			if buffer.len(b) >= 6 + len + 4 then a.startup = buffer.readf32(b, 6 + len) end
		end
		return a
	elseif type(buf) == "table" then
		-- บาง build ส่ง {attackString, victim?} ตรงๆ
		local a = parseAtk(buf[1])
		if a then a.char, a.selfEcho = char, v[3] == true end
		return a
	end
	return nil
end

-- ===== character/state binding =====
local myChar, myOcc, myCharData

local function statesOf(charName)
	local st = V9.liveStates()
	local f = st and st:FindFirstChild(charName)
	return f and f:FindFirstChild("Occupied"), f and f:FindFirstChild("CharacterData"), f and f:FindFirstChild("PlayerData")
end

-- อ่านค่า state แบบปลอดภัย (child ยังไม่ replicate = nil ไม่ใช่ error — กัน loop ตาย)
local function stV(folder, name)
	local v = folder and folder:FindFirstChild(name)
	return v and v.Value
end

local function myStates()
	if not myChar then return end
	-- States คีย์ด้วยชื่อผู้เล่น (เกมเองใช้ Players.LocalPlayer.Name — char.Name อาจต่างใน ranked)
	local o, c = statesOf(LP.Name)
	myOcc, myCharData = o, c
end

local DIRVEC = {
	Left = Vector3.new(-1, 0, 0), Right = Vector3.new(1, 0, 0),
	Forward = Vector3.new(0, 0, -1), Backward = Vector3.new(0, 0, 1),
	Standing = Vector3.new(0, 0, 0),
}
local DIR_TH = { Left = "ซ้าย", Right = "ขวา", Forward = "หน้า", Backward = "หลัง", Standing = "นิ่ง" }
local function fireDash(dir)
	-- ForceDash (Events) รับ Direction ตรงๆ — ไม่มี (ranked?) ก็ใช้ pipeline BindEvent ของเกม:
	-- TryDash = แดชตามทิศเคลื่อน, TryQuickStep = สเต็ปหลบ (IsTapDash) — ทิศคำนวณฝั่งเกม
	if EV.ForceDash then
		EV.ForceDash:Fire({ Direction = dir, MoveVector = DIRVEC[dir] or DIRVEC.Left })
	elseif dir == "Forward" or not EV.TryQuickStep then
		if EV.TryDash then EV.TryDash:Fire() end
	else
		EV.TryQuickStep:Fire()
	end
end
-- reaction delay: FixedDelay=false (บอทเทพ) = 0ms ทันทีทุกจุด / เปิด = หน่วงคงที่ทุก reaction
local function hjit(scale)
	return cfg.FixedDelay and (scale or cfg.FixedDelaySec) or 0
end
local function firePunch(heavy)
	STATE.lastOurPunch = tick()
	-- ReverseInputs (Trickster debuff ฯลฯ): เกมสลับ M1↔M2 — ต้องกดผิดฝั่งให้ออกถูกท่า (CombatShared:1176)
	if myOcc then
		local ri = myOcc:FindFirstChild("ReverseInputs")
		if ri and ri.Value == true then heavy = not heavy end
	end
	if heavy then
		EV.TryPunch:Fire({ IsHeavy = true })
		task.delay(0.12, function()
			-- ปล่อยเสมอแม้ KILL — ไม่งั้นตัวละครค้างกดหนัก
			EV.TryPunch:Fire({ StopHoldingDownHeavy = true, InputType = "Heavy" })
		end)
	else
		EV.TryPunch:Fire()
	end
end
-- เฟนต์จริงของเกม: กดหมัดเบาแล้วกดหนักซ้อนใน startup window → input คนละประเภทซ้อนกัน = IsFeint
-- (deimos2_25: หมัดเก่า Light + input ใหม่ Heavy = feint) — ล่อบอทที่หลบทุกหมัดให้เผาแดชฟรี
function V9.fireFeint()
	firePunch(false)
	task.delay(0.1, function() if not KILL then firePunch(true) end end)
end
local function setBlock(on) EV.SetBlock:Fire(on) end
local function fireSpecial()
	if not EV.UseSpecial then return end
	-- UseSpecial เป็น hold-type: ต้องกด Down แล้วปล่อย Up (ดูจาก mobile UI ของเกม)
	EV.UseSpecial:Fire({ PushDirection = "Down" })
	task.delay(0.18, function()
		-- ปล่อยเสมอแม้ KILL — กันค้างกดค้าง
		EV.UseSpecial:Fire({ PushDirection = "Up" })
	end)
end

local function rootOf(char)
	return char and char:FindFirstChild("HumanoidRootPart") or char and char.PrimaryPart
end
local function distTo(char)
	local a, b = rootOf(myChar), rootOf(char)
	return (a and b) and (a.Position - b.Position).Magnitude or 9999
end
local function lockedOn()
	return myOcc and myOcc:FindFirstChild("LockedOn") and myOcc.LockedOn.Value or nil
end
local function opponentOf()
	-- เป้าหมายตามลำดับของเกมจริง (deimos2_8): Opponent (server set บนสังเวียน) > LockedOn
	local op = myCharData and myCharData:FindFirstChild("Opponent") and myCharData.Opponent.Value or nil
	if op and op.Parent then return op end
	local o = lockedOn()
	if o and o.Parent then return o end
	return nil
end
function V9.attackerOnUs(atkChar)
	-- ศัตรูล็อกออนเราอยู่ไหม (หมัดเล็งเรา)
	local o = select(1, statesOf(atkChar.Name))
	local lk = o and o:FindFirstChild("LockedOn")
	return lk and lk.Value == myChar
end
local function aimedAtUs(c)
	-- หมัดตรงหาเราจริง: เป็น Opponent ของเรา / เราล็อกมัน / มันล็อกเรา (ครอบเคส ranked ที่เราไม่ได้ lock เอง)
	return c == opponentOf() or c == lockedOn() or V9.attackerOnUs(c)
end
local function recentThreat(c)
	-- เพิ่งชกใส่เราในระยะประชิดเมื่อครู่ (ไม่ได้ล็อกใคร/ไม่ได้ล็อกเรา ก็ยังนับ — ใช้ตัดสินใจสวน)
	return MAPS.threatMark[c] ~= nil and tick() - MAPS.threatMark[c] < 3
end
local function inSafezone()
	return myCharData and myCharData:FindFirstChild("InSafezone") and myCharData.InSafezone.Value == true
end
local function equipped()
	return myOcc and myOcc:FindFirstChild("Equipped") and myOcc.Equipped.Value == true
end
local function stunned()
	return (myCharData and myCharData:FindFirstChild("Stunned") and myCharData.Stunned.Value)
		or (myOcc and myOcc:FindFirstChild("Stunned") and myOcc.Stunned.Value)
end
local MAIN_PLACE = 13621938427
local function combatWhy()
	-- เหตุผลที่ยังไม่พร้อมสู้ (nil = พร้อม) — ใช้ทั้งตัดสินใจและเขียน status ให้ดูว่าทำไมฮับนิ่ง
	if not cfg.Enabled then return "master-off" end
	if not (myChar and myOcc and myCharData) then return "no-states" end
	if inSafezone() then return "safezone" end
	if stV(myOcc, "Spectating") then return "spectating" end
	if stV(myCharData, "Cutscene") then return "cutscene" end
	if stV(myCharData, "PvPOff") then return "pvp-off" end
	-- CurrentMenu: เกม deny punch ตอนเมนูเปิด (Emotes/QuestDialog/...) — CombatShared:1160
	local menu = WS:FindFirstChild("CurrentMenu")
	if menu and menu.Value ~= "" and menu.Value ~= "None" then return "menu:" .. tostring(menu.Value) end
	-- Ranked/สนามอื่น: ช่วง Tale-of-tape/เข้าวง MatchStarted = false → ห้ามทำอะไรจนกว่าจะเริ่ม (Main ไม่เช็ก)
	if game.PlaceId ~= MAIN_PLACE and WS:GetAttribute("MatchStarted") == false and tick() > STATE.gateUntil then
		return "match-not-started"
	end
	return nil
end
local function inCombat() return combatWhy() == nil end
local function aliveInLive(c)
	-- ตัวละครที่ล็อกได้ต้องอยู่ใน Workspace.Live (ตามเงื่อนไข lock-on ของเกม)
	local lv = V9.liveLive()
	return c and lv and c.Parent == lv and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0
end
local function autoLock(c)
	-- ล็อกออนคนที่ต่อยเราเอง (client เขียน LockedOn ได้ — เกมอ่านจาก Occupied)
	if not (cfg.AutoLock and myOcc and myChar and equipped()) then return end
	local lk = myOcc:FindFirstChild("LockedOn")
	if not lk then return end
	if inSafezone() or not aliveInLive(c) then return end
	if distTo(c) > cfg.LockRange then return end
	local cur = lk.Value
	if cur == c then return end
	if aliveInLive(cur) and distTo(cur) <= distTo(c) + 2 then return end -- คง lock เดิมถ้าใกล้กว่า
	pcall(function() lk.Value = c end)
end
local function pdMeterOK()
	-- CanPerfectDodge ของเกมจริง (GameplaySettings): ActiveNPC = ผ่านเสมอ
	if myChar and myChar:GetAttribute("ActiveNPC") then return true end
	-- เกจเราหมด + ศัตรูเหลือ → slow-mo ไม่ติด (แดชยังออก แต่ไม่เพอร์เฟกต์)
	local m = myCharData and myCharData:FindFirstChild("PerfectDodgeMeter")
	if m and m.Value <= 0.01 then return false end
	-- SlowMoDebounce/DoubleDashing → เกมคืน nil (เพอร์เฟกต์ไม่ได้ช่วงนี้)
	if myChar and (myChar:GetAttribute("SlowMoDebounce") or myChar:GetAttribute("DoubleDashing")) then return false end
	return true
end
local function serverPing()
	-- เกมเองใช้ workspace.Ping/2 หักเวลา dodge window — ใช้ตัวเดียวกัน
	local p = WS:FindFirstChild("Ping")
	if p and p.Value and p.Value > 0 then return p.Value end
	return LP:GetNetworkPing() or 0
end

-- ===== v9: PS+ settings + สูตรเกมจริง (จาก ANALYSIS_PSPLUS/PREDICT) =====
-- workspace.PrivateServerSettings.<ID>.Value = ค่าจริงที่เกมใช้ตอนนี้ (เซิร์ฟเจ้าของปรับได้)
local function psv(id, def)
	if not cfg.UsePSPlus then return def end
	local f = WS:FindFirstChild("PrivateServerSettings")
	local v = f and f:FindFirstChild(id)
	local val = v and v.Value
	return (type(val) == "number" or type(val) == "boolean") and val or def
end
V9.psv = psv
-- Perfect window duration สูตรจริง (SimulateLocally): base → KD → interface → ping → PDFrameReduction
function V9.pdWindow()
	local w = psv("PerfectDodgeWindow", 0.1167)
	local _, _, pd = statesOf(LP.Name)
	local kd = pd and pd:FindFirstChild("Knockdowns") and pd.Knockdowns.Value or 999
	if kd <= 25 then w = w * 2 elseif kd <= 250 then w = w + 0.05 end
	local iface = LP:GetAttribute("Interface")
	if iface == "Touch" or iface == "Controller" then w = w + 0.025 end
	return w * (1 + 0.33 * math.clamp((serverPing() - 0.09) / 0.15, 0, 1))
end
-- Startup multiplier สูตรจริง (CalculateStartupMult): p1 light×1.08, heavy×1.02, feint÷1.05, FirstMult, PS+ speed
function V9.startupMult(atk)
	if not cfg.UseStartupMult then return 1 end
	local m = 1
	if (atk.punch or 1) == 1 and not atk.heavy and not atk.ult then m = 1.08 end
	if atk.heavy then m = 1.02 end
	if atk.feint then m = m / 1.05 end
	local fm = atk.char and atk.char:GetAttribute("FirstMult")
	if type(fm) == "number" and fm > 0 then m = m * fm end
	m = m * (atk.heavy and psv("HeavyAttackSpeedMultiplier", 1) or psv("LightAttackSpeedMultiplier", 1))
	return m > 0 and m or 1
end
-- เป้าต่อยได้จริงไหม (DashInvulnerable/PerfectDodged → whiff แน่: CombatHelper:432)
function V9.targetVulnerable(c)
	return not (c:GetAttribute("DashInvulnerable") or c:GetAttribute("PerfectDodged"))
end
-- free dash ของเกม (ClientFreeDash attr / projectile window / IsFreeDashing) — ไม่เสีย stam ไม่ติด double-dash
function V9.freeDashActive()
	if not myChar then return false end
	if myChar:GetAttribute("ClientFreeDash") or myChar:GetAttribute("IsFreeDashing") then return true end
	local t = myChar:GetAttribute("ClientProjectileFreeDashUntil")
	return type(t) == "number" and WS:GetServerTimeNow() < t
end
-- ping diff สูตรจริง (SimulateLocally): (ourPing - theirPing)/2 clamp ±0.2
function V9.pingDiff(atk)
	if not cfg.UsePingDiff or type(atk.ping) ~= "number" then return 0 end
	return math.clamp((serverPing() - atk.ping) / 2, -0.2, 0.2)
end

-- ===== สมองต่อย: สตามิน่า + เงื่อนไขเกมจริง =====
-- เงื่อนไขปฏิเสธของเกมจริง แยกต่อยกับแดช (เดิมใช้ลิสต์เดียว → แดชถูกกันเพราะ attr ที่เกี่ยวกับหมัดอย่างเดียว)
--   ต่อย: deimos2_8:11199 / แดช: deimos2_8:17000-17010 (+ SlowMo ตัวเรา: deimos2_8:17160, NoDash: deimos2_8:17290)
local PUNCH_DENY = { "BlockBroken", "StaminaBroken", "LocalSlowMo", "SlowMo", "UsingSpecial", "NoLocalPunch", "SuperStunned", "NPCInvuln", "UltimateDebounce" }
-- SlowMo ของเรา = โดนเพอร์เฟกต์หลบ (โลกช้า หมัดเรากระตุกเสียสตามิน่าเปล่า+เปิดให้สวน) → อย่าชก
V9.DASH_DENY = { "BlockBroken", "StaminaBroken", "LocalSlowMo", "SlowMo", "UsingSpecial", "DenyDash", "ChargeDashLocked", "LocalChargeDashLocked", "NoDash", "Rooted", "SpecialHoldRooted" }
-- Rooted/SpecialHoldRooted: เกมข้าม Dash() ทั้งบล็อก (deimos2_8:16980) — แดชตอนนั้น = เผาคูลดาวน์ฟรี
local function staminaOK(minFrac)
	local mx = myCharData and myCharData:FindFirstChild("MaxStamina")
	local s = myCharData and myCharData:FindFirstChild("Stamina")
	if not (s and mx) or mx.Value <= 0 then return true end
	return s.Value >= mx.Value * (minFrac or cfg.MinStaminaFrac)
end
local function canPunchNow()
	-- เลียนแบบเงื่อนไขต่อยของเกมจริง (deimos2_8:11199) + สตามิน่าตัวเอง
	if not (myOcc and myCharData and myChar and equipped()) then return false end
	-- v9: AwaitRollback = เกมกำลังรอ rollback → punch deny (DashShared:746); QuickStepRecovery เกมเช็กก่อน CanPunch (CombatShared:11199) — ใช้ flag CanPunch ครอบอยู่แล้ว
	if stV(myOcc, "AwaitRollback") then return false end
	if stV(myOcc, "Punching") or stV(myOcc, "Dashing") or stV(myOcc, "Blocking") or stV(myCharData, "Blocking") then return false end
	if stunned() or stV(myCharData, "Cutscene") or stV(myCharData, "Toxic") then return false end
	for _, a in ipairs(PUNCH_DENY) do if myChar:GetAttribute(a) then return false end end
	if not stV(myOcc, "CanPunch") then return false end
	return staminaOK()
end
-- ศัตรูทำอะไรไม่ได้นาน (เกจสตามิน่า/บล็อกแตก ~1.4-1.7s, สตันหนัก, สโลว์โมหลังโดนเราหลบเพอร์เฟกต์) = ช่องว่างจริง ต่อย/อัลติได้ไม่โดนสวน
local function longIncap(c)
	if not (c and c.Parent) then return false end
	return (c:GetAttribute("StaminaBroken") or c:GetAttribute("BlockBroken") or c:GetAttribute("SuperStunned") or c:GetAttribute("SlowMo")) and true or false
end
-- + สตันทั่วไป (โดนหมัดแล้วกำลังกระตุก 0.5-0.75s): ต่อยคอมโบต่อได้ แต่สั้นเกินจะเริ่มอัลติ
local function incapacitated(c)
	if longIncap(c) then return true end
	-- v9: PDStunUntil = โดน Perfect-dodge ability stun (PerfectDodgeAbilityGuard ตั้งบนฝ่ายโดน) — incapacitated เหมือนสตันปกติ
	local pd = c and c:GetAttribute("PDStunUntil")
	if type(pd) == "number" and WS:GetServerTimeNow() < pd then return true end
	local o, cd = statesOf(c.Name)
	return stV(cd, "Stunned") == true or stV(o, "Stunned") == true
end
-- ต่อยหนักคุ้มเฉพาะตอนศัตรูเสียหลักนาน (หนัก startup ~0.5s): เกจสตามิน่า/บล็อกแตก/สตันหนัก ~1.4-1.7s เท่านั้น
-- (slow-mo ใช้หมัดเบา — หนักช้า เผลอ = มันฟื้นก่อนเราจบท่า = สวนกลับ)
local function heavyWorthy(c)
	if not (cfg.AutoHeavy and c and c.Parent) then return false end
	return (c:GetAttribute("StaminaBroken") or c:GetAttribute("BlockBroken") or c:GetAttribute("SuperStunned")) and true or false
end
-- หนัก 1 ครั้งต่อหน้าต่างเสียหลัก: เกจแตก ~1.4-1.7s แต่หนักกิน ~0.9s/ที — ทีที่ 2-3 land หลังมันฟื้น = whiff → recovery โดนสวน
-- (claim แล้ว mark ทันที — ทุก path ที่ยิงหนักผ่านตัวนี้/เซ็ต mark เหมือนกัน เลยนับรวมทุกระบบ = หนักเดียวต่อหน้าต่างจริง)
function V9.claimHeavy(c)
	if not heavyWorthy(c) then return false end
	local now = tick()
	if (MAPS.heavyMark[c] or 0) > now then return false end
	MAPS.heavyMark[c] = now + 1.8
	return true
end
local function enemyBlocking(c)
	local o, cd = statesOf(c.Name)
	return (o and o:FindFirstChild("Blocking") and o.Blocking.Value)
		or (cd and cd:FindFirstChild("Blocking") and cd.Blocking.Value)
end
local function blockEnergyOK(ignoreCan)
	-- v9: HitRecoveryBlockUntil = โดนหนักช่วงหนึ่ง เกม deny block (HitRecovery module ตั้ง attr)
	if not ignoreCan and myChar then
		local t = myChar:GetAttribute("HitRecoveryBlockUntil")
		if type(t) == "number" and WS:GetServerTimeNow() < t then return false end
	end
	-- ignoreCan: เกมคิวคำสั่งบล็อกไว้เองจน CanBlock กลับมา (เช่นหลังแดช) — ขอไว้ล่วงหน้าได้
	if not ignoreCan and myOcc and myOcc:FindFirstChild("CanBlock") and not myOcc.CanBlock.Value then return false end
	local be = myCharData and myCharData:FindFirstChild("BlockEnergy")
	-- หมัดกำลังบินมา + เรายังแดชได้: floor +16 เผื่อ drain หมัดลูกนี้ — เกจพอบล็อกแต่ไม่พอรับครบลูก = แตกแล้ว BlockBroken (DASH_DENY = ตายต่อทั้งชุด)
	-- (ตอนสตันไม่เพิ่ม — บล็อกคือเกราะเดียวที่เหลือ แดชอยู่แล้วไม่ได้)
	local floor = cfg.BlockMinEnergy + ((tick() < STATE.inboundUntil and not stunned()) and 16 or 0)
	return not be or be.Value >= floor
end
-- บล็อกแบบ counter: หลายระบบถือบล็อกพร้อมกันได้ ปล่อยเมื่อไม่มีใครถือ
local function holdBlock(tag, on, char)
	if on then
		if not MAPS.blockHolds[tag] then STATE.blockCount += 1 end
		MAPS.blockHolds[tag] = true
		MAPS.blockMeta[tag] = { c = char, t = tick() }
		MAPS.relMark[tag] = nil
		-- บล็อกขึ้นอยู่แล้ว = ไม่ต้องยิงซ้ำ (เกมมี debounce 0.3s หลังปล่อย + คิวรอ — ยิงซ้ำมีแต่สแปม)
		if stV(myOcc, "Blocking") then return end
	else
		MAPS.blockHolds[tag] = nil MAPS.blockMeta[tag] = nil MAPS.relMark[tag] = nil
	end
	setBlock(next(MAPS.blockHolds) ~= nil)
end
local function dropAllBlocks()
	table.clear(MAPS.blockHolds) table.clear(MAPS.blockMeta) table.clear(MAPS.relMark)
	pcall(function() setBlock(false) end)
end
-- ปล่อยบล็อก tag หลัง gap วิ — ถ้าระหว่างนั้นมี holdBlock(tag,true) ใหม่ (หมัดใหม่) = ยกเลิกเอง (MAPS.relMark เปลี่ยน)
local function releaseHoldAfter(tag, gap, cond, after)
	local mark = tick()
	MAPS.relMark[tag] = mark
	task.delay(gap, function()
		if KILL or MAPS.relMark[tag] ~= mark or not MAPS.blockHolds[tag] then return end
		if cond and not cond() then return end
		holdBlock(tag, false)
		if after then after() end
	end)
end

-- ===== HZ BRAIN: คาดการณ์ + เรียนรู้จากข้อมูลจริง =====
-- frame data จริงทุกสไตล์ (Startup/MoverInfo/Stamina) จาก DarkStyles.luau
local Styles
pcall(function()
	if isfile and isfile("DarkStyles.luau") then
		Styles = loadstring(readfile("DarkStyles.luau"))()
	end
end)

local function ensureLearn(c)
	local l = MAPS.learn[c]
	if not l then l = { n = 0, opens = 0, feints = 0, times = {} } MAPS.learn[c] = l end
	return l
end
local function learnAtk(atk)
	local l = ensureLearn(atk.char)
	l.n += 1
	-- หมัดเปิด (หมัดแรกคอมโบ/หนัก ไม่ใช่ชาร์จ) = หมัดที่เกมเปิด Perfect window ให้ — เฟนต์ล่อก็ใช้หมัดชนิดนี้ จึงวัดเฟนต์เป็นสัดส่วนของหมัดเปิด
	-- (เดิมหารด้วยหมัดทั้งหมดรวมคอมโบ 7 ฮิต → สายเฟนต์จริงดูเหมือนเฟนต์น้อยเสมอ)
	-- นับเฟนต์เฉพาะหมัดเปิดเหมือนกัน — เฟนต์กลางคอมโบไม่เอามาเกี่ยว (เดิมนับเฟนต์ทุกหมัด/หารด้วยเปิด → rate เฟือย ~3 เท่า
	-- → AdaptFeint latch ผิด → PD ปิดทั้งไฟต์ = ต้นตอแพ้จริง)
	local isOpen = ((atk.punch or 1) == 1 or atk.heavy) and not atk.charge
	if isOpen then
		l.opens += 1
		if atk.feint then l.feints += 1 end
	end
	if atk.feint then return end
	local now = tick()
	l.lastReal = now
	if atk.ult then l.lastUltT = now end
	if l.lastAtk then
		local iv = now - l.lastAtk
		if iv > 0.08 and iv < 3 then
			l.times[#l.times + 1] = iv
			if #l.times > 8 then table.remove(l.times, 1) end
		end
	end
	l.lastAtk = now
end
local function cadence(c)
	-- จังหวะหมัดเฉลี่ยที่เรียนรู้จากการโจมตีจริง
	local l = MAPS.learn[c]
	if not l or #l.times < 2 then return nil end
	local s = 0
	for _, v in ipairs(l.times) do s += v end
	return s / #l.times
end
local function feintRate(c)
	-- สัดส่วนเฟนต์ต่อหมัดเปิดของคนนี้ (สายล่อ)
	local l = MAPS.learn[c]
	return (l and l.opens >= 4) and (l.feints / l.opens) or 0
end
-- สไตล์อ่านตรงตามชื่อที่เกมตั้ง (DarkStyles v3 มี key ครบทุกโหมดย่อยแล้ว เช่น FreedomHitman/FreedomSmash/JoeBurn) — ไม่ map/ไม่แยกพฤติกรรมตามสไตล์
local function styleOf(c)
	local _, _, p = statesOf(c.Name)
	local s = p and p:FindFirstChild("Style")
	return s and s.Value or nil
end
local function myStyle()
	local _, _, p = statesOf(LP.Name)
	local s = p and p:FindFirstChild("Style")
	return s and s.Value or nil
end
local function punchData(style, atk)
	-- frame data จริง: Combos[combo][punch] หรือ HeavyAttacks
	local st = Styles and Styles[style]
	if not st then return nil end
	if atk.heavy and st.HeavyAttacks and #st.HeavyAttacks > 0 then
		return st.HeavyAttacks[math.clamp(atk.punch or 1, 1, #st.HeavyAttacks)]
	end
	local combo = st.Combos and st.Combos[math.max(1, atk.combo or 1)] or st.Combos and st.Combos[1]
	return combo and combo[math.clamp(atk.punch or 1, 1, #combo)]
end
local function predictLandDt(atk)
	-- คาดเวลาโดนหมัด (วินาทีจากตอนนี้) — ชั้น0 startup จริงใน packet, ชั้น1 frame data, ชั้น2 cadence
	if not cfg.Predict then return nil end
	local su = atk.startup
	-- v9: หาร startupMult (p1×1.08/heavy×1.02/feint÷1.05/FirstMult/PS+speed) + pingDiff (our-their)/2
	-- เกมเร่งอนิเมชันด้วย mult → เวลาจริง = startup/mult; ping ต่าง = packet ช้า/เร็วกว่าที่คาด
	if type(su) == "number" and su > 0.04 and su < 3 then
		return math.max(0, su / V9.startupMult(atk) - 0.02 - V9.pingDiff(atk))
	end
	local st = Styles and Styles[styleOf(atk.char)]
	if atk.ult and st and st.Ultimate then
		-- อัลติศัตรู: เวลาโดนหมัดแรก = PreDelay + DamageTimes[1] (ข้อมูลจริง)
		local u = st.Ultimate
		local t = u.DamageTimes and u.DamageTimes[1] and u.DamageTimes[1][1]
		if t then return math.max(0, (u.PreDelay or 0) + t - 0.08) end
	end
	local pd = punchData(styleOf(atk.char), atk)
	local s = pd and (pd.Startup or pd.LandedFrame)
	if s and s > 0.05 then
		return math.max(0, s - 0.08) -- -0.08 transit: packet วิ่งถึงเราก่อนหมัด
	end
	return cadence(atk.char)
end
-- ทิศหลบเพอร์เฟกต์ตามกฎเกมจริง (deimos2_25): TargetPart ของหมัดที่จะโดน → ทิศ
local PART_DODGE = { RightFoot = "Right", LeftFoot = "Left", LeftHand = "Right" } -- นอกนั้น = Left
local function dodgeDirOf(atk)
	if type(myChar:GetAttribute("Perfect")) == "number" then
		local nd = myChar:GetAttribute("NeededDirection")
		if type(nd) == "string" then return nd end -- window สด = เชื่อ server
	end
	local pd = punchData(styleOf(atk.char), atk)
	local tp = pd and pd.TrailInfo and pd.TrailInfo.TargetPart
	return (pd and pd.PerfectDodgeDirection) or PART_DODGE[tp] or "Left"
end
local function enemyField(c, n)
	local _, cd = statesOf(c.Name)
	local v = cd and cd:FindFirstChild(n)
	return v and v.Value or nil
end
-- v6: ระยะตอบสนองตาม style ศัตรูจริง — VeryLongGuard ตีไกล 17.8 studs
-- (cfg.ReactRange=5 เดิมทำให้หมัดไกลทะลุมาโดนโดยไม่เคยหลบ/บล็อก)
local function reactRangeOf(c)
	local st = Styles and Styles[styleOf(c)]
	local r = st and st.ReachMax
	return math.max(cfg.ReactRange, (type(r) == "number" and r or 0) + 0.5)
end
-- myU: helper ของตัวเรา (รวมตารางเดียว — ประหยัด local register ใกล้เพดาน 200)
-- reach = ระยะหมัดเราจริงตามสไตล์ (ReachMax = hitbox เกมจริง median 4.15) + 0.5 margin
--   เดิมยิงที่ cfg.M1Range 6.5 เสมอ → ต่อยลมนอก reach = เสียสตามิน่า + ล็อกแดชตัวเอง (ต้นตอ "โดนขัดตลอด")
-- hp = เลือดเราเป็นสัดส่วน — ใช้เกทอัลติ (อัลติตอนใกล้ตาย = เสียเปล่า เก็บไว้ยกถัดไป)
local myU = {
	reach = function(lk)
		local st = Styles and Styles[myStyle()]
		local r = st and st.ReachMax
		local base = (type(r) == "number" and r > 0) and r + 0.5 or 4.7 -- median 4.15+0.5
		-- ล็อกเป้า: เกมลากตัวเข้าหา LockedOn ~1.8 studs ระหว่างชก (MaxDistance 2.7/1.5: deimos2_8:13100-13110)
		-- ไม่ล็อก = ลากตามหน้า → ใช้แค่ reach ดิบ (ต่อยลมไกล = เสียสตามิน่า+ล็อกแดชฟรี)
		if lk and stV(myOcc, "LockedOn") == lk then base = base + 1.8 end
		return math.min(cfg.M1Range, base)
	end,
	hp = function()
		local h = myCharData and myCharData:FindFirstChild("Health")
		local m = myCharData and myCharData:FindFirstChild("MaxHealth")
		return (h and m and m.Value > 0) and (h.Value / m.Value) or 1
	end,
}

-- ===== combat helpers: threat + ult gates =====
local function threatLive(c)
	-- ศัตรูกำลังชก/เพิ่งชกเมื่อครู่ = ยังไม่ใช่จังหวะบุก (ป้องกันก่อน — แก้แพ้เพราะยุ่งต่อย)
	local o = select(1, statesOf(c.Name))
	if o and o:FindFirstChild("Punching") and o.Punching.Value then return true end
	local l = MAPS.learn[c]
	return (l and l.lastAtk and tick() - l.lastAtk < 0.5) == true
end
-- แดช: เกมปฏิเสธถ้าห่างจากแดชก่อนหน้า < 0.8×DashDelay(0.55) ≈ 0.44s (deimos2_8:17340) และแดชซ้ำภายใน DoubleDashingWindow=0.8s
-- ถือเป็น "double dash" = ไม่ได้เพอร์เฟกต์ (CanPerfectDodge คืน nil เมื่อมี attr DoubleDashing: deimos2_7:3164) + กินสตามิน่า +30 (deimos2_7:3043)
local function dashClean() return V9.freeDashActive() or tick() - STATE.lastDashOK >= 0.85 end
local function dashBlocker()
	-- ลำดับเดียวกับ Dash() ของเกม (deimos2_8:16890-17200) — เช็กก่อนยิง ไม่เผาแล้วยังโดนปฏิเสธ
	if not (myChar and myOcc and myCharData) then return "nochar" end
	if stV(myOcc, "Dashing") then return "dashing" end
	-- v9: free dash (ClientFreeDash/IsFreeDashing/projectile window) — ไม่เสีย stam ไม่ติด double-dash/cd
	if V9.freeDashActive() then
		if stV(myCharData, "Cutscene") or stV(myCharData, "Toxic") then return "cutscene" end
		if stV(myOcc, "Stunned") then return "stunned" end
		return nil
	end
	if tick() - STATE.lastDashOK < 0.46 then return "dash-cd" end -- 0.8×DashDelay ของเกม ≈ 0.44 (deimos2_8:17340)
	if stV(myOcc, "Punching") or stV(myOcc, "StopRotate") then return "punching" end -- เกม deny ที่ Occupied.Punching/StopRotate (deimos2_8:16986)
	if stV(myCharData, "Cutscene") or stV(myCharData, "Toxic") then return "cutscene" end
	local st = myCharData:FindFirstChild("Stamina")
	if st and st.Value <= 1 then return "stamina" end
	-- สตัน: Occupied.Stunned ปฏิเสธเสมอ / CharacterData.Stunned ปฏิเสธเฉพาะเมื่อไม่มี attr CanRollback (เกมตั้งทุกครั้งที่เปิด window — ไม่เคยล้าง: deimos2_25:15640)
	if stV(myOcc, "Stunned") then return "stunned" end
	if stV(myCharData, "Stunned") and not myChar:GetAttribute("CanRollback") then return "stunned" end
	for _, a in ipairs(V9.DASH_DENY) do if myChar:GetAttribute(a) then return "attr:" .. a end end
	local arm = myChar:GetAttribute("ArmorRecoilUntil")
	if type(arm) == "number" and WS:GetServerTimeNow() < arm then return "armor-recoil" end
	return nil
end
local function panicBlockOn(c, why)
	-- แดชใช้ไม่ได้แต่หมัดมันมา → บล็อกด่วนรับแทน
	if not (cfg.PanicBlock and c and aliveInLive(c) and blockEnergyOK(true)) then return end
	local tag = "panic:" .. c.Name
	holdBlock(tag, true, c)
	releaseHoldAfter(tag, cfg.BlockHold + 0.3, function()
		return not stV(select(1, statesOf(c.Name)), "Punching")
	end)
	if why then evlog(why .. " -> block " .. c.Name) end
end
local function ultOK()
	-- เงื่อนไขอัลติแยกจาก canPunchNow (บล็อกอยู่ก็ยิงได้ — จะปล่อยบล็อกเอง)
	if not (myOcc and myCharData and equipped()) then return false end
	if stunned() or stV(myOcc, "Dashing") or stV(myOcc, "Punching") then return false end -- Punching: เกม deny อัลติกลางหมัด — เสียจังหวะ+คูลดาวน์ฟรี
	if myChar:GetAttribute("UltimateDebounce") or myChar:GetAttribute("HyperArmor") then return false end
	-- เลือดน้อยเกินเกณฑ์ → เก็บอัลติไว้ยกถัดไป (ปล่อยตอนใกล้ตาย = ถ้าตายก่อนคัตซีนจบ = เสียเกจ 100 ฟรี)
	if myU.hp() < (cfg.UltMinHP or 25) / 100 then return false end
	local ue = myCharData:FindFirstChild("UltimateEnergy")
	return ue ~= nil and ue.Value >= 100
end

-- ===== AUTO PERFECT DODGE =====
local tryPunish, ultSoon, m1Strike, ultFire -- forward declare (punishAfterPD/listener เรียกใช้ก่อนประกอบจริง)
-- 0 วิ = รันทันทีในเฟรมเดียวกัน (task.delay(0) รอเฟรมถัดไป ~16ms) / > 0 = หน่วงคงที่ (FixedDelay)
local function after(sec, fn)
	if sec > 0 then task.delay(sec, fn) else fn() end
end
-- มีหมัดใหม่จากคนนี้ที่เพิ่งมาหลังจากเราหลบไปแล้ว และมันยังชกอยู่ = ยังไม่จัดการ → อย่าต่อยเข้าไป (ติดอนิเมชันต่อย บล็อก/แดชไม่ได้)
local function newAttackSinceDodge(c)
	local l = MAPS.learn[c]
	if not (l and l.lastReal and l.lastReal > STATE.lastDashOK + 0.05) then return false end
	return stV(select(1, statesOf(c.Name)), "Punching") == true
end
-- สวนหลังหลบเพอร์เฟกต์: ศัตรูถูก slow-mo (SlowMo attr: แดช/บล็อก/ต่อยไม่ได้) = ฟรีฮิต
-- เกมค้างสถานะ Dashing ของเราจน "หมัดที่ถูกหลบถึงเวลาโดน + 0.05s" (deimos2_8:17640: task.wait(GetTimeLeftToDodge+0.05)) → ต่อยไม่ออกช่วงนั้น
-- จึงโพลทุก 0.03s แล้วต่อยทันทีที่ canPunchNow ผ่าน (เดิมยิงตามเวลาคงที่ 0.35/0.7s แล้ว threatLive ตัดทิ้งเพราะศัตรู Punching ค้างตอน slow-mo)
local function punishAfterPD(lk)
	if not (lk and lk.Parent) or tick() - STATE.pdPunishAt < 0.6 then return end
	STATE.pdPunishAt = tick()
	local t0, thrown = tick(), 0
	task.spawn(function()
		local why, engaged = "init", false
		while not KILL and tick() - t0 < 2.4 and thrown < 3 do
			task.wait(0.03)
			if not (cfg.Enabled and cfg.AutoPunish and inCombat() and lk.Parent and aliveInLive(lk)) then why = "gate" break end
			-- มันฟื้นจาก slow-mo แล้ว + มีหมัดใหม่ตามมา = ตอบโต้ได้ → หยุด (ต่อยชน = Punching lock กินหมัด)
			if not incapacitated(lk) and newAttackSinceDodge(lk) then why = "recovered" break end
			if not incapacitated(lk) then
				-- attr SlowMo มาช้ากว่าแดช ~0.1s → รอ แต่ถ้า 0.9s ยังไม่เสียหลักเลย = แดชไม่ใช่เพอร์เฟกต์จริง (ไม่มี slow-mo) → เลิกรอ
				if tick() - t0 > 0.9 then why = "no-incap" break end
				why = "wait-incap"
			elseif stunned() then
				why = "stunned" -- stun จากหมัดก่อนหลบยังค้าง ~0.5s → รอให้หมด ไม่ทิ้ง
			elseif stV(myOcc, "Dashing") then
				why = "dashing" -- เกมค้าง Dashing จนหมัดที่หลบถึงเวลา+0.05 แล้วปลด CanPunch ตามหลัง → รอ
			else
				local d = distTo(lk)
				if d > cfg.PunishRange then
					-- แดชพาออกนอกระยะต่อย: มัน frozen ใน slow-mo = แดชเข้าหาได้ฟรี แล้วค่อยต่อย
					if not engaged and lk:GetAttribute("SlowMo") and d <= cfg.EngageRange and dashClean() and dashBlocker() == nil then
						engaged = true
						STATE.lastDashOK = tick() -- บันทึก cooldown ฝั่งเกมด้วย (แดชนี้ไม่ผ่าน afterDash)
						fireDash("Forward")
						evlog("PD punish engage -> " .. lk.Name)
					end
					why = "range " .. math.floor(d)
				elseif ultSoon and ultSoon(lk) then
					-- คอมโบฆ่า: เพอร์เฟกต์ → slow-mo 2.1s → อัลติ (มันทำอะไรไม่ได้เลย) สำคัญกว่าหมัดธรรมดา
					-- เกม deny อัลติกลางหมัดเรา (Punching) → รอให้ปลดก่อนยิง ไม่งั้นเผาเกจฟรี
					if not stV(myOcc, "Punching") then
						STATE.lastUlt = tick()
						dropAllBlocks()
						EV.TryPunch:Fire({ IsUltimate = true })
						evlog("PD ULT -> " .. lk.Name)
						why = nil
						break
					end
					why = "ult-wait-punching" -- หมัดเราค้างอยู่ → poll ถัดไปยิง (มันนอนแน่ 2.1s)
				elseif canPunchNow() then
					thrown += 1
					STATE.punishCount += 1
					firePunch(V9.claimHeavy(lk)) -- หนักครั้งเดียวต่อหน้าต่าง ที่เหลือหมัดเบา — หนักซ้ำ whiff โดนสวน
					evlog("PD punish #" .. thrown .. " -> " .. lk.Name .. (lk:GetAttribute("SlowMo") and " (slowmo)" or ""))
					task.wait(0.3) -- AttackDebounce ของเกม ≈ 0.25+startup (deimos2_8:11233) — ยิงถี่กว่านี้เกมทิ้งเฉยๆ
					why = nil
				else
					why = "canPunch"
				end
			end
		end
		if thrown == 0 and why then evlog("PD punish skip: " .. tostring(why) .. " " .. lk.Name) end
	end)
end
-- ยืนยันว่าแดชออกจริง (เกมอาจปฏิเสธ: คูลดาวน์ 0.44s/สตามิน่า/สตัน) แล้วค่อยนับสถิติ + ปล่อยบล็อกสำรอง
-- (แดชทำให้ CharacterData.Blocking=false แต่ Occupied.Blocking ฝั่งเรายังค้าง → ต่อยไม่ออก ต้องปล่อยเอง)
local function afterDash(dir, kind, atkChar, wasPerfect)
	task.delay(0.06, function()
		if KILL then return end
		if stV(myOcc, "Dashing") then
			STATE.pdCount += 1
			STATE.lastDashOK = tick() - 0.06
			evlog(kind .. " dash " .. tostring(dir) .. (wasPerfect and " PERFECT" or " plain") .. " OK")
			if next(MAPS.blockHolds) or stV(myOcc, "Blocking") then dropAllBlocks() end
			if wasPerfect then
				if cfg.AutoPunish and cfg.PunishAfterPD then punishAfterPD(atkChar) end
			elseif atkChar and cfg.PanicBlock and aliveInLive(atkChar) and blockEnergyOK(true) then
				-- หลบธรรมดา (ไม่มี slow-mo): ศัตรูต่อคอมโบต่อได้ แดชซ้ำติดคูลดาวน์ → ตั้งบล็อกรอหมัดถัดไป
				-- (เกมคิวคำสั่งบล็อกไว้เองจนพ้นแดช+debounce) แล้วปล่อยเมื่อมันหยุดชก
				local tag = "panic:" .. atkChar.Name
				holdBlock(tag, true, atkChar)
				releaseHoldAfter(tag, cfg.BlockHold + 0.3, function()
					return not stV(select(1, statesOf(atkChar.Name)), "Punching")
				end)
			end
		else
			evlog(kind .. " dash " .. tostring(dir) .. " DENIED (" .. tostring(dashBlocker() or "game") .. ")")
			-- แดชไม่ออกแต่หมัดยังมา → บล็อกด่วนรับแทน ไม่ยืนกินฟรี
			panicBlockOn(atkChar)
		end
	end)
end
local function onPerfectWindow()
	if KILL or not cfg.Enabled or not cfg.AutoPD or not myChar or not inCombat() then return end
	local pv = myChar:GetAttribute("Perfect")
	if type(pv) ~= "number" or pv <= 0 then return end -- 0 = window ปลอม/feint
	-- คนที่ window นี้เปิดให้ = LockedOn (เกมเปิดเฉพาะหมัดของคนที่เราล็อกอยู่) — ไม่ใช่ Opponent เสมอไป
	local lk = lockedOn() or opponentOf()
	-- เกมเปิด window ตาม LockedOn โดยไม่เช็กระยะ → คนล็อกเราอยู่ไกลต่อยลมก็ยังเปิด → เช็กเอง ไม่งั้นแดชหลบหมัดที่โดนไม่ได้ = โป๊ะ
	-- +3.5: หมัดพุ่ง/อัลติไกลกว่า reach ปกติ (mover 2.7+hitbox) — ตัดแค่คนที่ไกลจริงๆ (เคยข้าม window อัลติตอน d=6 → กินเต็ม)
	if lk and distTo(lk) > reactRangeOf(lk) + 3.5 then
		evlogRL("pd-far", "PD skip (far) " .. lk.Name .. " d=" .. math.floor(distTo(lk)))
		return
	end
	if cfg.AntiFeint and lk then
		-- window ของ packet เฟนต์เอง (เกมเปิดได้แม้เป็นเฟนต์) — packet จริงถัดมาจะล้าง MAPS.feintMark ใน snoop (window ของมันต้องแดช)
		local fm = MAPS.feintMark[lk]
		if fm and tick() - fm < 0.9 then
			evlogRL("pd-feint", "PD skip (feint window) " .. lk.Name)
			return
		end
		-- สายล่อเฟนต์ (>35% ของหมัดเปิด): เผาแดชเสี่ยง → สลับให้บล็อกทำแทน (บล็อกไม่โดน feint bait)
		if cfg.AdaptFeint and feintRate(lk) > 0.35 then
			if cfg.EnemyHUD then flash("เป้าสายเฟนต์! บล็อกแทน", Color3.fromRGB(180, 160, 255)) end
			evlogRL("pd-adapt", "PD skip (feinter " .. math.floor(feintRate(lk) * 100) .. "%) -> block")
			return
		end
	end
	if tick() - STATE.lastDodge < 0.25 then return end -- หมัดเดียวกัน (fallback/ชั้นอื่น) จัดการไปแล้ว
	-- แดชซ้ำภายใน 0.8s = double dash: ไม่ได้เพอร์เฟกต์ + สตามิน่า -30 → บล็อกหมัดนี้แทน (บล็อกไม่ได้ค่อยยอมแดชซ้ำ)
	if not dashClean() and blockEnergyOK(true) then
		panicBlockOn(lk, "PD skip (double-dash window)")
		return
	end
	-- เกม deny dash ตอนเราชก/คัตซีน/stun/แดชอยู่ (deimos2_8:16990+) → อย่าเผา บล็อกรับแทน
	local denyWhy = dashBlocker()
	if denyWhy then
		panicBlockOn(lk, "PD skip (" .. denyWhy .. ")")
		return
	end
	-- แดช + ทิศตาม NeededDirection = เพอร์เฟกต์เสมอ (เกมเช็ก Perfect attr + ทิศ ตอนแดช)
	STATE.lastDodge = tick()
	local dir = myChar:GetAttribute("NeededDirection") or "Left"
	local meterOK = pdMeterOK()
	after(hjit(0.05), function()
		if KILL or not myChar then return end
		fireDash(dir)
		afterDash(dir, "window", lk, meterOK)
	end)
	if cfg.EnemyHUD then
		if pdMeterOK() then
			flash("หลบเพอร์เฟกต์! → " .. (DIR_TH[dir] or dir), Color3.fromRGB(120, 255, 160))
		else
			flash("แดชหลบ! (เกจ PD หมด)", Color3.fromRGB(255, 210, 120))
		end
	end
end

-- เวลาที่หมัดจะโดน (server clock): LandTime สด > startup ใน packet > frame data/cadence
-- (เดิมรอ LandTime 0.32s ก่อนค่อยคาดการณ์ แล้วนับจาก "ตอนนี้" → LandTime ไม่มา = ช้าไป 0.3 วิ ทุกหมัด)
local function resolveLandAt(atk)
	local atkChar = atk.char
	local function fresh()
		local lt = atkChar:GetAttribute("LandTime")
		-- รับเฉพาะ LandTime "สด" (อนาคต/เพิ่งผ่านไปนิดเดียว) — ค่าค้างจากหมัดก่อนข้ามไป
		if type(lt) == "number" and lt > WS:GetServerTimeNow() - 0.12 then return lt end
		return nil
	end
	local lt = fresh()
	if lt then return lt end
	-- มี startup ใน packet = รอ LandTime แค่ชั่วครู่ (เวลาไม่รอเรา); ไม่มี = รอได้นานกว่า
	local budget = (type(atk.startup) == "number" and atk.startup > 0.04) and 0.05 or 0.32
	while tick() - atk.t0 < budget do
		if KILL or not atkChar.Parent then return nil end
		task.wait(0.025)
		lt = fresh()
		if lt then return lt end
	end
	if KILL or not atkChar.Parent then return nil end
	local pdt = predictLandDt(atk)
	if pdt and pdt <= 3 then return WS:GetServerTimeNow() - (tick() - atk.t0) + pdt end
	return nil
end

-- ===== AUTO BLOCK =====
local function tryScheduleBlock(atk)
	if KILL or not cfg.Enabled or not cfg.AutoBlock or not myChar then return end
	if atk.feint or atk.selfEcho then return end
	local atkChar = atk.char
	-- ไกลเกินที่จะเดินเข้ามาทันใน startup (~14 studs) = ข้ามการวางแผน; ที่เหลือตัดสินซ้ำตอนหมัดถึงจริง
	if distTo(atkChar) > reactRangeOf(atkChar) + 8 then return end
	task.spawn(function()
		local landAt = resolveLandAt(atk)
		if KILL or type(landAt) ~= "number" then return end
		-- เกมใช้ Ping/2 หักเวลา window เหมือนกัน → บล็อกเร็วขึ้นตาม ping
		local lead = cfg.BlockLead + math.min(serverPing() / 2, 0.25)
		local dt = landAt - WS:GetServerTimeNow() - lead
		if dt > 3 then return end -- LandTime เก่า/ขยะ
		local holdT = cfg.BlockHold * (atk.heavy and 1.5 or 1) -- หมัดหนักบล็อกนานขึ้น
		task.delay(math.max(0, dt + hjit(0.05)), function() -- hjit=0 = บล็อกตรงเวลาเป๊ะ (FixedDelay จะบวกหน่วงคงที่)
			if KILL or not myChar or not inCombat() then return end
			if distTo(atkChar) > reactRangeOf(atkChar) then return end -- เช็กซ้ำตอนหมัดถึง: ยังไกล = ต่อยลม
			-- PD เคยจัดการแล้วก็ตาม — ถ้าไม่ได้แดชจริง (สตามิน่า/คูลดาวน์) ต้องบล็อกต่อ
			if cfg.AutoPD and myChar:GetAttribute("Perfect") and stV(myOcc, "Dashing") then return end
			if stV(myOcc, "Dashing") or stV(myOcc, "Blocking") then return end
			if not blockEnergyOK() then return end -- เกจบล็อกน้อย = บล็อกแล้วแตก → ปล่อยรับหมัดดีกว่า
			holdBlock("sched", true)
			task.delay(holdT, function()
				if KILL then return end
				holdBlock("sched", false)
				-- counter combo: ปล่อยบล็อกปุ๊บสวนเลย ถ้าเปิด AutoPunish
				-- (BlockDebounce 0.3s ล็อก "บล็อกซ้ำ" เท่านั้น — Occupied.Blocking เป็น false ทันทีที่ปล่อย ต่อยได้เลย: deimos2_21 TryUnblock)
				if cfg.AutoPunish then task.delay(0.06, function() if not KILL then tryPunish() end end) end
			end)
		end)
	end)
end

-- ===== AUTO PUNISH =====
-- สวนทั่วไป (ศัตรูชกจบ/เราบล็อกจบ/ต่อคอมโบหลังโดน): ต่อยเฉพาะตอนมัน "ไม่ได้กำลังกดดัน" — ชกชนกลางคอมโบ = Punching lock → แดช/บล็อกไม่ออก
-- (ข้อยกเว้น: ศัตรูเสียหลัก incapacitated → ไม่มีหมัดตอบโต้ ต่อยได้แม้ Punching ค้าง)
tryPunish = function(attacker)
	if KILL or not cfg.Enabled or not cfg.AutoPunish or not inCombat() then return end
	if tick() - STATE.lastPunish < 0.28 then return end
	-- สวนคนที่เพิ่งโจมตีเราเป็นหลัก (สับเป้าให้ถูกตัวก่อนต่อย — กันโดนรุมแล้วสวนผิดคน)
	local lk = attacker
	if not (lk and aliveInLive(lk) and distTo(lk) <= cfg.PunishRange) then lk = opponentOf() end
	if not lk or not lk.Parent then return end
	if distTo(lk) > cfg.PunishRange then return end
	-- v9: เป้า invulnerable (DashInvulnerable/PerfectDodged) → เสียหมัดฟรี
	if not V9.targetVulnerable(lk) then return end
	local incap = incapacitated(lk)
	if not incap then
		if (aimedAtUs(lk) or recentThreat(lk)) and newAttackSinceDodge(lk) then return end
		if threatLive(lk) then return end
		-- inbound suppression: หมัดใหม่ของมันกำลังบินมาแล้ว → สวนตอนนี้ = Punching ทับ window ถัดไป
		if tick() < STATE.inboundUntil and dashClean() and dashBlocker() == nil then return end
	end
	if lk ~= lockedOn() and lk ~= opponentOf() and myOcc and myOcc:FindFirstChild("LockedOn") then
		pcall(function() myOcc.LockedOn.Value = lk end) -- client เขียน lock ได้ (native path)
	end
	if not canPunchNow() then return end
	STATE.lastPunish = tick()
	local heavy = V9.claimHeavy(lk) -- งบหนักเดียวกัน: หนัก 1 ครั้งต่อหน้าต่างเสียหลัก
	task.wait(hjit(0.05)) -- บอทเทพ = 0ms สวนทันที (task.wait(0) = รอเฟรมเดียว)
	if KILL then return end
	firePunch(heavy)
	STATE.punishCount += 1
end
local function dropWatch(c)
	local l = MAPS.watchedAtk[c]
	if l then
		for _, cn in ipairs(l) do pcall(function() cn:Disconnect() end) end
		MAPS.watchedAtk[c] = nil
	end
	MAPS.slowMoStart[c] = nil
	MAPS.breakMark[c] = nil
	MAPS.heavyMark[c] = nil
end
local function watchAttacker(atkChar)
	if MAPS.watchedAtk[atkChar] or atkChar == myChar then return end
	local o = select(1, statesOf(atkChar.Name))
	local punching = o and o:FindFirstChild("Punching")
	if not punching then return end
	local tag = "panic:" .. atkChar.Name
	local list = {}
	-- ปล่อยบล็อก "ช้าลง" ให้พ้นคอมโบถัดไป: เกมล็อกการบล็อกซ้ำ BlockDebounce 0.3s หลังปล่อย (deimos2_21 TryUnblock)
	-- ปล่อยไวแล้วหมัดถัดไปมาใน 0.3s = บล็อกไม่ขึ้น. หมัดใหม่ (holdBlock on) = ยกเลิกการปล่อยที่รออยู่เอง
	local function releaseLater(gap, thenPunish)
		releaseHoldAfter(tag, gap, function() return not stV(o, "Punching") end, thenPunish and function()
			if cfg.AutoPunish and (aimedAtUs(atkChar) or recentThreat(atkChar)) then
				task.delay(0.06, function() if not KILL then tryPunish(atkChar) end end)
			end
		end or nil)
	end
	-- จังหวะฆ่าเปิด (สโลว์โม/เกจแตก/สตันหนัก) = อัลติ/หมัดสวนทันที 0ms — ไม่รอลูป
	for _, attr in ipairs({ "SlowMo", "StaminaBroken", "BlockBroken", "SuperStunned" }) do
		list[#list + 1] = atkChar:GetAttributeChangedSignal(attr):Connect(function()
			if KILL or not atkChar.Parent or not atkChar:GetAttribute(attr) then return end
			ultFire(atkChar)
			m1Strike(atkChar)
		end)
	end
	-- มันเพิ่งกดอัลติ = startup (PreDelay ~1s) ยังขัดได้ → เจาะขัดทันที 0ms
	-- (ถ้าคัตซีนเริ่มแล้วขัดไม่ได้ก็เสียแค่หมัดเดียว; ถ้าเราคือเป้า เกมล็อกเราเข้าคัตซีนอยู่แล้ว)
	list[#list + 1] = atkChar:GetAttributeChangedSignal("PerformingUltimate"):Connect(function()
		if KILL or not atkChar.Parent or not atkChar:GetAttribute("PerformingUltimate") then return end
		m1Strike(atkChar)
	end)
	list[#list + 1] = punching.Changed:Connect(function(v)
		if v == false then
			local held = MAPS.blockHolds[tag]
			-- หมัดหมด → ถือบล็อกต่ออีกนิดเผื่อคอมโบ แล้วค่อยปล่อย+สวน (ไม่ได้บล็อกอยู่ = สวนทันที)
			if held then releaseLater(cfg.BlockRelease or 0.3, true) end
			-- brain: คาดหมัดถัดไปจาก cadence → เตรียมบล็อกล่วงหน้า (เฉพาะตอนยังไม่ได้ถือ)
			if cfg.Predict and not held and not KILL then
				local cad = cadence(atkChar)
				local aimed2 = aimedAtUs(atkChar)
				if cad and aimed2 and distTo(atkChar) < reactRangeOf(atkChar) then
					task.delay(math.max(0, cad - 0.14), function()
						if KILL or not inCombat() or not cfg.PanicBlock then return end
						if distTo(atkChar) > reactRangeOf(atkChar) or stV(myOcc, "Dashing") then return end
						if not blockEnergyOK() then return end
						holdBlock(tag, true, atkChar)
						-- ping สูง: flag Punching มาช้า L + cadence แกว่ง → ถือบล็อกยาวขึ้นครอบหมัดถัดไป
						releaseLater(0.4 + math.min(serverPing() / 2, 0.2), false)
					end)
				end
			end
			if not held and (aimedAtUs(atkChar) or recentThreat(atkChar)) then
				tryPunish(atkChar)
			end
			-- มันหยุดสวิง = recovery ~0.5s (gap คอมโบ/whiff) → เจาะทันที 0ms ตัดหมัดถัดไปก่อนมันเริ่ม startup
			m1Strike(atkChar)
			return
		end
		-- เริ่มชก: ใส่เรา + ประชิด + เราว่าง → บล็อกฉับไว (สำรองของ snoop — รอ ~1 เฟรมให้ flag เฟนต์มาถึงก่อน)
		MAPS.relMark[tag] = nil
		if KILL or not cfg.Enabled or not cfg.PanicBlock or not inCombat() then return end
		task.delay(0.04, function()
			if KILL or not inCombat() or not stV(o, "Punching") then return end
			if MAPS.feintMark[atkChar] and tick() - MAPS.feintMark[atkChar] < 0.3 then return end
			if longIncap(atkChar) then return end -- สโลว์โม/เสียหลัก: มันตอบโต้ไม่ได้ ไม่ต้องบล็อก (บล็อกจะขวางหมัดสวนของเรา)
			local aimed = aimedAtUs(atkChar) or distTo(atkChar) < 7
			if not aimed or distTo(atkChar) > reactRangeOf(atkChar) then return end
			if stV(myOcc, "Dashing") or stV(myOcc, "Punching") then return end
			if not blockEnergyOK() then return end
			holdBlock(tag, true, atkChar)
		end)
	end)
	-- หนักแตกเกราะ v6: อ่าน BlockEnergy จริงของศัตรู — บล็อกค้าง>0.9s หรือเกจใกล้แตก(≤14) ตอนบล็อกอยู่ → ต่อยหนักทำลายทันที
	local blk = o:FindFirstChild("Blocking")
	local _, ecd = statesOf(atkChar.Name)
	local eBE = ecd and ecd:FindFirstChild("BlockEnergy")
	local lastBreak = 0
	local function tryBreak(reason)
		if KILL or not cfg.AutoBreak or not inCombat() then return end
		if not (blk and blk.Value) then return end
		if tick() - lastBreak < 1.2 then return end -- กันยิงถี่
		local aimed = aimedAtUs(atkChar)
		if not aimed or distTo(atkChar) > 8 then return end
		lastBreak = tick()
		-- หมัดเจาะรัวยึดช่วง canPunchNow ตลอด → ตั้งธง "หมัดถัดไปหนัก" ให้ลูป M1 หยิบยิงในช่องว่างของมันเอง (แก้บั๊กหนักไม่ออกเลย)
		MAPS.breakMark[atkChar] = tick() + 3
		if cfg.EnemyHUD then flash("หนักแตกเกราะ! " .. reason, Color3.fromRGB(255, 160, 90)) end
	end
	if blk then
		list[#list + 1] = blk.Changed:Connect(function(v)
			if v ~= true then return end
			task.delay(0.9, function()
				if KILL or not blk.Value then return end
				tryBreak("ค้างนาน")
			end)
		end)
	end
	if blk and eBE then
		list[#list + 1] = eBE.Changed:Connect(function(v)
			-- เกจบล็อกศัตรูเหลือน้อยตอนบล็อกอยู่ → หนักแตกทันที (ไม่ต้องรอ timer)
			if blk.Value and type(v) == "number" and v <= 14 then
				tryBreak("เกจเหลือ " .. tostring(math.floor(v)))
			end
		end)
	end
	-- hit-confirm: หมัดโดน (LastDamaged เด้ง) → ถ้ามันยังเปิดช่อง → ต่อคอมโบเองอัตโนมัติ
	list[#list + 1] = atkChar:GetAttributeChangedSignal("LastDamaged"):Connect(function()
		if KILL or not inCombat() then return end
		if atkChar == opponentOf() then STATE.hitCount += 1 end
		if not cfg.AutoPunish then return end
		task.delay(0.4, function()
			if KILL or not inCombat() or not aliveInLive(atkChar) then return end
			if distTo(atkChar) > cfg.PunishRange then return end
			if incapacitated(atkChar) and canPunchNow() then tryPunish(atkChar) end
		end)
	end)
	-- telemetry: วัดระยะเวลา slow-mo จริงของศัตรู (ไว้จูนช่วงสวนหลังหลบ — log "enemy SlowMo on/off dt")
	list[#list + 1] = atkChar:GetAttributeChangedSignal("SlowMo"):Connect(function()
		if atkChar:GetAttribute("SlowMo") then
			MAPS.slowMoStart[atkChar] = tick()
			evlog("enemy SlowMo ON " .. atkChar.Name)
		elseif MAPS.slowMoStart[atkChar] then
			evlog(string.format("enemy SlowMo OFF %s dt=%.2f", atkChar.Name, tick() - MAPS.slowMoStart[atkChar]))
			MAPS.slowMoStart[atkChar] = nil
		end
	end)
	-- v6: AwaitRollback ของศัตรูขึ้นตอนหมัดเพิ่งโดน rollback (เฟนต์) → บันทึก feint ทันที
	local arb = o:FindFirstChild("AwaitRollback")
	if arb then
		list[#list + 1] = arb.Changed:Connect(function(v)
			if v == true then MAPS.feintMark[atkChar] = tick() end
		end)
	end
	-- brain: นับว่ามันหลบหมัดเราบ่อยไหม (Dashing ขึ้นภายใน 0.7s หลังเราชก) → สายหลบเก่งเจอ feint bait
	local dsh = o:FindFirstChild("Dashing")
	if dsh then
		list[#list + 1] = dsh.Changed:Connect(function(v)
			if v ~= true then return end
			local l = MAPS.learn[atkChar]
			if l and tick() - STATE.lastOurPunch < 0.7 then l.dodges = (l.dodges or 0) + 1 end
		end)
	end
	-- v6: เตือนอัลติศัตรู — UltEnergy ≥85 = เกือบปล่อยอัลติ ระวังตัว
	local ue2 = ecd and ecd:FindFirstChild("UltimateEnergy")
	if ue2 then
		local warned = false
		list[#list + 1] = ue2.Changed:Connect(function(v)
			if type(v) ~= "number" then return end
			if v >= 85 and not warned then
				warned = true
				if cfg.EnemyHUD and inCombat() and distTo(atkChar) < 40 then
					flash("⚠ อัลติพร้อม! " .. atkChar.Name, Color3.fromRGB(255, 80, 80))
				end
			elseif v < 60 then warned = false end
		end)
	end
	list.t0 = tick() -- TTL tracking: เวลาที่ผูก watcher (sweep ใช้ตัด entry inactive — กัน watcher 11 conns ค้างบนคนหลุดไฟต์)
	MAPS.watchedAtk[atkChar] = list
end

-- ===== DODGE EVERYTHING: แดชทุกหมัดที่เล็งเรา (หลบแบบ v1) =====
-- windowExpected = เกมจะเปิด Perfect window ให้หมัดนี้ (LockedOn=คนชก + หมัดแรกคอมโบ/หนัก + ไม่ใช่ชาร์จ):
--   หน้าต่างเปิด ≈ LandTime+ping/2-win → onPerfectWindow แดชตอนเปิด = เพอร์เฟกต์. ตัวนี้เหลือเป็นสำรองท้ายหน้าต่างเท่านั้น
--   (เดิมแดชที่ LandTime-0.08-ping/2 = ก่อนหน้าต่างเปิดเสมอที่ ping ปกติ → แย่งแดชไปก่อน ได้แค่หลบธรรมดา ไม่ใช่เพอร์เฟกต์)
local function tryScheduleDodge(atk, windowExpected)
	if KILL or not cfg.Enabled or not cfg.AutoPD or not myChar or not inCombat() then return end
	if atk.feint or atk.selfEcho then return end
	local atkChar = atk.char
	-- ⚠️ aimed อย่างเดียวไม่พอ: คนล็อกเราแต่อยู่ไกลแล้วต่อยลม — แดชหลบ = โป๊ะเป็นบอท
	-- วางแผนไว้เฉพาะที่เดินเข้ามาทัน (~14 studs ใน startup — คนวิ่ง/แดชเข้าหาเรา) แล้วตัดสินซ้ำตอนหมัดถึงจริงข้างล่าง
	if distTo(atkChar) > reactRangeOf(atkChar) + 8 then return end
	-- ping สูง: แดชถึง server ช้ากว่า land+rollback(0.15) แน่เมื่อ startup < 2L-0.15 → เผาแดช + ติด double-dash lock ฟรีๆ
	-- ข้ามแดช ให้บล็อก/พรีบล็อกรับแทน (window ที่เกมเปิดเองยังใช้ได้ — มันไม่ผ่านฟังก์ชันนี้)
	local oneWay = math.min(serverPing() / 2, 0.25)
	if type(atk.startup) == "number" and atk.startup > 0.04 and atk.startup < 2 * oneWay - 0.15 then return end
	-- startup < 0.12 = packet มาช้ากว่าหมัดจริง (sub-packet/rollback) — แดชทีหลังไม่ทันอยู่แล้ว เผาแดช+ติด double-dash ฟรีๆ → ให้บล็อกจัดการ
	if type(atk.startup) == "number" and atk.startup > 0 and atk.startup < 0.12 then return end
	local pdata = punchData(styleOf(atkChar), atk)
	if pdata and pdata.NotDodgeable then return end -- หลบไม่ได้ (เช่น eject) → ปล่อยให้บล็อกจัดการ ไม่เผาแดช
	if windowExpected and pdata and (pdata.NoPerfectDodge or pdata.NotDodgeable) then windowExpected = false end
	-- ประหยัดแดช: เผาเฉพาะหมัดเปิดคอมโบ/หนัก/อัลติ — หมัดกลางคอมโบให้บล็อกรับ
	-- (เดิมแดชกลางคอมโบ → ติด CD → p1/อัลติถัดไป DENIED โดนฟรี — นี่คือต้นตอแพ้)
	-- opener ไม่มี window (ไม่ได้ล็อกเรา) ก็ยังแดช: หลบ p1 = หนีคอมโบทั้งชุด + ได้ช่องสวน — บล็อกเป็นแผนสำรองเท่านั้น
	-- ยกเว้น: เกจบล็อกใกล้แตก → บล็อกต่อ = แตกแล้วสตัน → แดชหนีกลางคอมโบดีกว่า
	local opener = atk.isStart or (atk.punch or 9) <= 1
	-- v9: atk.special (punch 90-97 = ability) หลบเหมือน heavy — แรงกว่า M1 ธรรมดา
	if cfg.DodgeWindowOnly and not windowExpected and not opener and not atk.heavy and not atk.ult and not atk.special and blockEnergyOK() then return end
	-- (ไม่มีเก็บแดชตามเกจอัลติ — packet atk.ult มาเองจะถูกตารางแดชแยก เหนือ DodgeWindowOnly แล้ว)
	if cfg.AntiFeint and cfg.AdaptFeint and aimedAtUs(atkChar) and feintRate(atkChar) > 0.35 then return end
	task.spawn(function()
		local landAt = resolveLandAt(atk)
		if KILL or type(landAt) ~= "number" then return end
		local ping2 = math.min(serverPing() / 2, 0.25)
		local fireAt
		if windowExpected then
			-- v9: window จริงจากสูตร (KD/interface/ping/PS+) — แดชกลางหน้าต่างเป๊ะ = เพอร์เฟกต์ชัวร์
			-- เกมเปิดที่ land - win - ping/2 + 0.195 (GetTimeLeftToDodge) → กลาง window = land - win/2 - ping/2 + 0.195
			-- เผื่อ 15ms หลังเปิด (กันแดชก่อน window) — onPerfectWindow แดชก่อนอยู่แล้ว ตัวนี้สำรอง
			local win = V9.pdWindow()
			fireAt = math.min(landAt - win / 2 - ping2 + 0.195 + 0.015, landAt - 0.04)
		else
			-- ไม่มี window (หมัดกลางคอมโบ/ไม่ได้ล็อกเรา): แดชก่อนหมัดถึงนิดเดียว (+ชดเชย ping/2)
			fireAt = landAt - (0.08 + ping2)
		end
		local dt = fireAt - WS:GetServerTimeNow()
		if dt > 3 then return end
		task.delay(math.max(0, dt + hjit(0.05)), function() -- hjit=0 = แดชตรงเวลาเป๊ะ (FixedDelay จะบวกหน่วงคงที่)
			if KILL or not myChar or not inCombat() then return end
			if distTo(atkChar) > reactRangeOf(atkChar) + ((atk.ult or atk.heavy or atk.special) and 3.5 or 0) then return end -- เช็กซ้ำตอนหมัดถึง: ยังไกล = ต่อยลม ไม่แดช (อัลติ/หนักพุ่งไกลกว่า reach ปกติ +3.5 เหมือน window path)
			if tick() - STATE.lastDodge < 0.3 then return end -- มีคนหลบไปแล้ว (Perfect window / หมัดก่อน)
			-- แดชซ้ำภายใน 0.8s = double dash (ไม่เพอร์เฟกต์ + สตามิน่า -30): หมัดธรรมดา → บล็อกแทน / หนัก-อัลติ → ยอมแดช (บล็อกหนักแดรนเกจแรง)
			if not dashClean() and not (atk.ult or atk.heavy or atk.special) and blockEnergyOK(true) then
				panicBlockOn(atkChar, "dash skip (double-dash window)")
				return
			end
			local denyWhy = dashBlocker()
			if denyWhy then
				panicBlockOn(atkChar, "dash skip (" .. denyWhy .. ")")
				return
			end
			STATE.lastDodge = tick()
			local dir = dodgeDirOf(atk)
			local pv = myChar:GetAttribute("Perfect")
			local inWindow = type(pv) == "number" and pv > 0 and myChar:GetAttribute("NeededDirection") == dir and pdMeterOK()
			fireDash(dir)
			afterDash(dir, windowExpected and "fallback" or "plain", atkChar, inWindow)
			if cfg.EnemyHUD then flash("หลบ! → " .. (DIR_TH[dir] or dir), Color3.fromRGB(120, 255, 160)) end
		end)
	end)
end

-- ===== ATTACK SNOOP =====
conns[#conns + 1] = EV.ReplicateTryAttack.OnClientEvent:Connect(function(v)
	if KILL then return end
	local okD, atk = pcall(V9.decodeArgs, v)
	if not okD or not atk or not atk.char or atk.char == myChar then return end
	local aimed = aimedAtUs(atk.char) or distTo(atk.char) < 10
	atk.t0 = tick()
	-- เกมเปิด Perfect window ตาม LockedOn ณ ตอน handler ของมันรัน (ก่อนเรา) → จดไว้ก่อน autoLock จะเปลี่ยนเป้า
	local windowExpected = lockedOn() == atk.char and ((atk.punch or 1) == 1 or atk.heavy) and not atk.charge
	-- มีหมัดเล็งเรามาจริง = แมตช์เริ่มแล้ว แม้ attr MatchStarted ยังเป็น false → เปิดประตูไว้ (กันฮับนิ่งถาวร)
	if aimedAtUs(atk.char) and WS:GetAttribute("MatchStarted") == false and game.PlaceId ~= MAIN_PLACE then
		if tick() > STATE.gateUntil then evlog("gate override: attack seen while MatchStarted=false") end
		STATE.gateUntil = tick() + 30
	end
	learnAtk(atk) -- brain: เรียนรู้จังหวะ + นิสัยเฟนต์ของคนนี้
	-- log เฉพาะหมัดที่เกี่ยวกับเรา/น่าสนใจ — ไฟต์คนอื่นห่างๆ ไหลทิ้งเหตุการณ์สำคัญเปล่าๆ
	if aimed or atk.ult or atk.feint then
		evlog(string.format("atk %s p%s%s%s%s su=%.2f aimed=%s win=%s", atk.char.Name, tostring(atk.punch), atk.heavy and " heavy" or "",
			atk.ult and " ULT" or "", atk.feint and " FEINT" or "", atk.startup or -1, tostring(aimed), tostring(windowExpected)))
	end
	if aimed then
		MAPS.threatMark[atk.char] = tick()
		autoLock(atk.char)
		-- inbound suppression: หมัดจริงกำลังบินมา → ถือไว้จน land — m1Strike/tryPunish จะไม่เริ่มหมัดใหม่ทับ Perfect window (Punching lock ~0.4s ทับ window = dash deny)
		-- ยกเว้น ult: ต้องชกขัด startup ของมันอยู่แล้ว (m1Strike interrupt ข้างล่าง) / เฟนต์: ไม่มีหมัดจริงตามมา อย่าเสียเวลาชก (กันเฟนต์ล่อแช่แข็ง)
		if not atk.ult and not atk.feint then
			local su = type(atk.startup) == "number" and atk.startup or 0.35
			STATE.inboundUntil = math.max(STATE.inboundUntil, tick() + math.clamp(su, 0, 1.2))
		end
	end
	if atk.feint then
		MAPS.feintMark[atk.char] = tick()
		STATE.feintCount += 1
		if cfg.EnemyHUD and aimed then flash("เฟนต์! อย่าหลง", Color3.fromRGB(180, 160, 255)) end
		return
	end
	MAPS.feintMark[atk.char] = nil -- หมัดจริงใหม่ = window ของมันมีผลจริง → ล้าง mark เฟนต์ก่อนหน้า (ไม่ให้บล็อกการหลบหมัดจริงที่ตามมา)
	watchAttacker(atk.char)
	-- packet อัลติมา = startup ยังขัดได้ → เจาะขัดทันที (คู่กับ listener PerformingUltimate)
	if atk.ult then m1Strike(atk.char, nil, nil, true) end -- force: ขัด startup อัลติ ไม่ให้ inboundUntil บล็อก
	-- insta-block: หมัดจริงเล็งเรา/ประชิด → กันเลยทันที ไม่รอเวลาโดน (ไวสุดเท่าที่จะไวได้)
	if cfg.PanicBlock and inCombat() then
		local aimedAt = aimedAtUs(atk.char)
		if (aimedAt or distTo(atk.char) < 6.5) and distTo(atk.char) <= reactRangeOf(atk.char) and blockEnergyOK() then
			holdBlock("panic:" .. atk.char.Name, true, atk.char)
		end
	end
	tryScheduleDodge(atk, windowExpected) -- แดชก่อน (มีบล็อกสำรองถ้าแดชไม่ออก)
	tryScheduleBlock(atk)
	if cfg.EnemyHUD and aimed then
		local tag = atk.ult and "อัลติเมท!" or atk.heavy and "หมัดหนัก!" or ("คอมโบ #" .. tostring(atk.punch))
		flash("ระวัง! " .. tag, atk.ult and Color3.fromRGB(255, 80, 255) or atk.heavy and Color3.fromRGB(255, 120, 90) or Color3.fromRGB(255, 210, 120))
	end
end)


-- ===== AUTO M1 / ULT / SPECIAL loops =====
-- อัลติ: ยิงเฉพาะตอนศัตรูทำอะไรไม่ได้นานพอให้อัลติแตะโดน (เกจสตามิน่า/บล็อกแตก ~1.4-1.7s, สตันหนัก, สโลว์โมหลังโดนเราหลบเพอร์เฟกต์)
-- อัลติมี PreDelay ~1s + startup 0.63 (DarkStyles .Ultimate) — ยิงตอนศัตรูกำลังชก/ว่างอยู่ = โดนตีขัดกลางท่า เสียทั้งเกจและเลือด
local function ultWindow(lk)
	if not longIncap(lk) then return false end
	if enemyBlocking(lk) and not (lk:GetAttribute("BlockBroken") or lk:GetAttribute("StaminaBroken")) then return false end
	return true
end
-- อัลติ "เกือบพร้อม" = เกจเต็ม + เป้าเสียหลักนาน + ในระยะ (ไม่สน Punching/Dashing) — ใช้หยุดต่อยรอยิงอัลติ ไม่ให้หมัดไปกินจังหวะ
ultSoon = function(lk, d)
	if not (cfg.AutoUlt and lk and lk.Parent) then return false end
	if (d or distTo(lk)) > cfg.UltRange or tick() - STATE.lastUlt <= 8 then return false end
	if stunned() or stV(myOcc, "Dashing") then return false end
	if myChar:GetAttribute("UltimateDebounce") or myChar:GetAttribute("HyperArmor") then return false end
	if myU.hp() < (cfg.UltMinHP or 25) / 100 then return false end -- เลือดน้อย = อย่าให้หยุดชกรออัลติ (เก็บไว้ยกถัดไป)
	local ue = myCharData and myCharData:FindFirstChild("UltimateEnergy")
	return ue ~= nil and ue.Value >= 100 and ultWindow(lk)
end
-- อัลติยิงจริง 0ms — ถูกเรียกจาก event (ศัตรูติดสโลว์โม/เกจแตก/สตันหนัก) + ลูป fallback
-- เกทยิงจริง = ultOK (รวม Punching/Dashing/สตัน/debounce) + ultWindow (เสียหลักนานพอให้ท่าลง)
ultFire = function(lk)
	if not (cfg.Enabled and cfg.AutoUlt and myChar and inCombat()) then return end
	if not (lk and lk.Parent and aliveInLive(lk)) then return end
	if distTo(lk) > cfg.UltRange or tick() - STATE.lastUlt <= 8 then return end
	-- v9: เป้า invulnerable → อัลติโดนดอดจ์/บล็อก → เสีย 100 เกจฟรี
	if not V9.targetVulnerable(lk) then return end
	if not ultOK() or not ultWindow(lk) then return end
	STATE.lastUlt = tick()
	dropAllBlocks() -- บล็อกอยู่ = เกมไม่รับอัลติ
	evlog("ULT fire -> " .. lk.Name)
	EV.TryPunch:Fire({ IsUltimate = true })
	if cfg.EnemyHUD then flash("อัลติเมท!", Color3.fromRGB(255, 80, 255)) end
end
-- m1Strike: ต่อยทันทีที่กฎเกมยอม — ถูกเรียกจาก event (หมัดเราจบ/CanPunch กลับมา/ศัตรูจบสวิง/สตันหมด) 0ms
-- + fallback จากลูป — ไม่รอ cadence ลูปเหมือนเดิม (หมัดเรา = ตัดสตันศัตรูได้ บุก = ป้องกัน)
m1Strike = function(lk, d, now, force)
	now = now or tick()
	if not (cfg.Enabled and cfg.AutoM1 and myChar and inCombat() and not stunned()) then return end
	if not (lk and lk.Parent and aliveInLive(lk)) then return end
	if now - STATE.lastM1 < 0.1 then return end -- กัน event สองตัวยิงชนกันเฟรมเดียว
	d = d or distTo(lk)
	if not d or d > myU.reach(lk) or not canPunchNow() or ultSoon(lk, d) then return end
	-- v9: เป้า DashInvulnerable/PerfectDodged → ต่อยลมเสียหมัดฟรี (เกมบล็อกแน่: CombatHelper:432)
	if not V9.targetVulnerable(lk) then return end
	local o = select(1, statesOf(lk.Name))
	local l = MAPS.learn[lk]
	-- มันอยู่ในช่วงบุก (กำลังชกอยู่ / หมัดถัดไปน่าจะมาภายใน cadence ที่เรียนมา) + เราแดชได้
	-- → อย่าผูกตัวเองด้วยหมัดใหม่: เก็บแดชไว้กินเพอร์เฟกต์ (slow-mo+3หมัด+อัลติ) คุ้มกว่าหมัดเจาะ 1 ที
	-- ยกเว้น: มันเสียหลัก (สตัน = หมัดมันตายไปแล้ว ต่อยฟรี) หรือเราแดชไม่ได้อยู่แล้ว → ชก = interrupt lottery
	local cad = l and l.lastAtk and math.clamp(cadence(lk) or 0.7, 0.55, 1.5) or 0
	local liveAtk = stV(o, "Punching")
		or (l and l.lastAtk and now - l.lastAtk < cad and (aimedAtUs(lk) or recentThreat(lk)))
	if liveAtk and not incapacitated(lk) and dashClean() and dashBlocker() == nil then return end
	-- inbound suppression: หมัดมันกำลังบินมา (packet ถึงแล้ว ยังไม่ land) → อย่าเริ่มหมัดใหม่ทับ Perfect window
	-- (Punching ล็อก ~0.4s ทับ window = dash deny → กินคอมโบ) — ยกเว้นมันเสียหลัก (ฟรีฮิต) / แดชไม่ได้อยู่แล้ว (ชกชนดีกว่าเฉย)
	if not force and now < STATE.inboundUntil and not incapacitated(lk) and dashClean() and dashBlocker() == nil then return end
	if incapacitated(lk) then -- ต่อยคนเสียหลัก = สวนกลับโดยนิยาม
		if not cfg.AutoPunish then return end
		STATE.lastM1 = now
		firePunch(V9.claimHeavy(lk)) -- ฟรีฮิต: หนักครั้งเดียวตอนเกจแตก/สตันหนัก ที่เหลือเบา (เดิมยิงหนักซ้ำทั้งหน้าต่าง = whiff โดนสวน)
		return
	end
	if not (cfg.AutoPoke and staminaOK()) then return end
	-- เหลือเคส "แดชไม่ได้แล้ว": ชกชนสวิง = interrupt lottery (ดีกว่ายืนเฉย) / มันแดช = ต่อยไม่โดน เสียสตามิน่าฟรี
	if stV(o, "Dashing") then return end
	if lk:GetAttribute("HyperArmor") then return end -- เกราะแข็ง: หมัดเราตัดสตันมันไม่ได้ → แลกเปลือง
	STATE.lastM1 = now
	local lr = ensureLearn(lk)
	-- AutoBreak: tryBreak ตั้งธงไว้ → หมัดนี้เป็นหนักแตกเกราะ (มันยังบล็อกอยู่เท่านั้น)
	-- ยกเว้นสายหลบเก่ง (dodges≥2): บล็อกมันปล่อยแล้วหลบได้ → หนัก whiff = recovery โดนสวน → หมัดเบาเท่านั้น
	local heavy = (MAPS.breakMark[lk] or 0) > now and stV(o, "Blocking") == true and (lr.dodges or 0) < 2
	if heavy then MAPS.breakMark[lk] = nil MAPS.heavyMark[lk] = now + 1.8 end -- หนักแตกเกราะก็นับเข้างบหนักต่อหน้าต่าง (กันหนักซ้ำตามมา)
	-- สายหลบเก่ง (หลบหมัดเรา ≥2 ครั้ง): เฟนต์ล่อเผาแดช แล้วต่อยจริงหลังแดชพลาด
	if not heavy and cfg.AutoFeint and (lr.dodges or 0) >= 2 and now - (lr.lastFeint or 0) > 2.5 and staminaOK(0.55) then
		lr.lastFeint = now
		V9.fireFeint()
		evlog("FEINT bait " .. lk.Name)
		task.delay(0.55, function()
			if not KILL and inCombat() and not stunned() and canPunchNow()
				and tick() >= STATE.inboundUntil -- หมัดมันกำลังมา → อย่าชกทับ window
				and lk.Parent and distTo(lk) <= myU.reach(lk) then
				firePunch(false)
			end
		end)
	else
		firePunch(heavy)
	end
end
task.spawn(function()
	while not KILL do
		-- pcall ทั้งรอบ — error ครั้งเดียว (respawn/state หาย) ไม่ให้ loop ตายถาวร
		local ok, e = pcall(function()
			if not (inCombat() and not stunned()) then return end
			local lk = opponentOf()
			if not (lk and lk.Parent) then return end
			local d = distTo(lk)
			local now = tick()
			-- อัลติ (fallback ของ event listener — event ยิงตอน attr เปลี่ยนเร็วกว่าลูปอยู่แล้ว)
			ultFire(lk)
			-- M1: event ทำเร็วกว่าลูปอยู่แล้ว (Punching/CanPunch ปลด = ชกทันที) — ลูปนี้คือ fallback เผื่อ event พลาด
			if now - STATE.lastM1 > 0.15 then m1Strike(lk, d, now) end
			-- Special: เฉพาะช่องว่างจริงเท่านั้น — ศัตรูเสียหลัก (ฟรี) หรือนิ่งไม่ชก >1.5s
			-- (เดิมยิงในช่อง 0.5s ของคอมโบมัน → UsingSpecial ล็อกตัวเองกลางหมัดมัน = ต้นตอ "หลบก็โดนต่อย")
			local idleEnough = not threatLive(lk) and (not (MAPS.learn[lk] and MAPS.learn[lk].lastAtk) or now - MAPS.learn[lk].lastAtk > 1.5)
			if cfg.AutoSpecial and d <= cfg.SpecialRange and now - STATE.lastSpecial > 4 and canPunchNow()
				and (incapacitated(lk) or idleEnough) then
				STATE.lastSpecial = now
				fireSpecial()
				evlog("SPECIAL fired")
			end
			-- บุกเข้าหา (dash-in, ปิดเป็น default): เป้าอยู่นอกระยะชก + ไม่ได้ชกเรา + แดชสะอาดพร้อม → แดชเข้าไปแล้วต่อยทันที
			-- (DashFollowupWindow ของเกมให้ advantage frames หลังแดช) แลกกับแดชสะอาด 0.8s (double-dash window) ที่ใช้หลบ
			if cfg.AutoEngage and d > myU.reach(lk) and d <= cfg.EngageRange
				and now - STATE.lastEngage > 2 and dashClean() and dashBlocker() == nil
				and canPunchNow() and staminaOK(0.3)
				-- ศัตรูเสียหลัก = แดชเข้าฟรี (มันตอบโต้ไม่ได้) — ข้ามเกทกันเดินเข้าหมัดทั้งหมด
				and (incapacitated(lk) or (not stV(select(1, statesOf(lk.Name)), "Punching") and not threatLive(lk)
					-- กันเดินเข้าหมัด: มันเพิ่งชก <2.5 วิ = กำลังบุกอยู่ → แดชเข้า = เผาแดชแล้วโดนเปิดเกม
					and not (MAPS.learn[lk] and MAPS.learn[lk].lastReal and now - MAPS.learn[lk].lastReal < 2.5))) then
				STATE.lastEngage = now
				STATE.lastDodge = now -- นับเป็นการใช้แดช (หลบถัดไปจะได้รู้ว่ายังไม่พร้อม)
				STATE.lastDashOK = now -- + cooldown ฝั่งเกม: แดช engage ไม่ผ่าน afterDash → dashBlocker ตาบอดถ้าไม่เซ็ต
				fireDash("Forward")
				evlog("engage dash -> " .. lk.Name)
				task.delay(0.28, function()
					if not KILL and inCombat() and not stunned() and canPunchNow()
						and lk.Parent and distTo(lk) <= myU.reach(lk) + 1.5 then
						firePunch(false)
					end
				end)
			end
		end)
		if not ok then warn("[HZ UBG m1] " .. tostring(e)) end
		task.wait(0.07 + hjit(0.05)) -- cadence ลูป 0.07s (บอทเทพ — event ทำหมัดไวกว่านี้อยู่แล้ว ลูปนี้คุม ult/engage/special)
	end
end)

-- ===== เดินออโต้ (AutoStrafe): วนซ้ายขวารอบเป้า + รักษาระยะชก — Humanoid.Move = เกมเห็นเป็นการเดินจริง =====
-- หยุดให้ทั้งหมดตอน: แดช (mover ของเกมคุมเอง)/อัลติ/คัตซีน/สตัน/Rooted — และไกลเกินระยะบุก (ให้ผู้เล่น/AutoEngage จัดการ)
-- (ห่อ do..end — ประหยัด local register ใกล้เพดาน 200; strafeDir/strafeUntil/stopMove อยู่เป็น upvalue ของลูป)
do
	local strafeDir, strafeUntil = 1, 0
	local function stopMove()
		local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
		if hum then pcall(function() hum:Move(Vector3.new()) end) end
	end
	task.spawn(function()
	while not KILL do
		local ok, e = pcall(function()
			local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if not (cfg.Enabled and cfg.AutoStrafe and hum and inCombat() and not stunned()) then return end
			-- ช่วงที่เกม/ระบบอื่นคุมการเคลื่อนไหวอยู่ → อย่าไปแย่ง (แดช = mover เกม, อัลติ/คัตซีน/rooted = เดินไม่ได้อยู่แล้ว)
			if stV(myOcc, "Dashing") or myChar:GetAttribute("PerformingUltimate")
				or stV(myCharData, "Cutscene") or myChar:GetAttribute("Rooted") then return end
			local lk = opponentOf()
			if not (lk and lk.Parent and aliveInLive(lk)) then return end
			local d = distTo(lk)
			if not d or d > cfg.EngageRange + 4 then return end
			local mp = myChar.PrimaryPart and myChar.PrimaryPart.Position
			local tp = lk.PrimaryPart and lk.PrimaryPart.Position
			if not (mp and tp) then return end
			local now = tick()
			if now >= strafeUntil then
				strafeDir = (math.random() < 0.5) and -1 or 1 -- สลับข้างสุ่ม — ดูเป็นคน ไม่เดินวนทางเดียวตลอด
				strafeUntil = now + 0.45 + math.random() * 0.75
			end
			local to = tp - mp
			local mag = Vector3.new(to.X, 0, to.Z).Magnitude
			if mag < 0.01 then return end
			local fwd = Vector3.new(to.X / mag, 0, to.Z / mag)
			local side = Vector3.new(-fwd.Z, 0, fwd.X) * strafeDir
			local reach = myU.reach(lk)
			-- รักษาระยะชก: ไกล = วนเข้า (side 0.6 + fwd 0.7), ใกล้เกิน = วนออก, พอดี = วนข้างล้วน
			local dir = side
			if d > reach + 0.8 then dir = side * 0.6 + fwd * 0.7
			elseif d < 2.2 then dir = side * 0.7 - fwd * 0.6 end
			hum:Move(dir.Unit)
		end)
		if not ok then warn("[HZ UBG strafe] " .. tostring(e)) end
		task.wait(0.1)
	end
	stopMove()
	end)
end

-- แมตช์ 1v1 (ranked/duel): เซิร์ฟตั้ง Opponent ให้ → ล็อกไว้ก่อนมันชกหมัดแรก
-- (เกมเปิด Perfect window เฉพาะหมัดของคนที่เรา LockedOn — ไม่ล็อกไว้ก่อน = หมัดแรกไม่มี window)
local function preLockOpponent(reason)
	if not (cfg.Enabled and cfg.AutoLock and myOcc and myCharData) then return false end
	if not (equipped() and not inSafezone() and inCombat()) then return false end
	local cur = stV(myOcc, "LockedOn")
	local op = stV(myCharData, "Opponent")
	if op and op ~= cur and aliveInLive(op) and distTo(op) <= cfg.LockRange * 1.5
		and not (cur and aliveInLive(cur) and MAPS.threatMark[cur] and tick() - MAPS.threatMark[cur] < 4) then
		pcall(function() myOcc.LockedOn.Value = op end)
		evlog("pre-lock " .. op.Name .. " [" .. tostring(styleOf(op) or "?") .. "] (" .. tostring(reason) .. ")")
		return true
	end
	return false
end
conns[#conns + 1] = WS:GetAttributeChangedSignal("MatchStarted"):Connect(function()
	evlog("MatchStarted=" .. tostring(WS:GetAttribute("MatchStarted")))
	if WS:GetAttribute("MatchStarted") == true then preLockOpponent("match-start") end
end)

-- ===== maintenance: autolock cleanup + autoequip =====
local hookStates -- forward declare (ประกอบจริงใต้ bindChar) — maintenance เรียกทุก tick ให้ listener ตาม state folder ที่ถูกสร้างใหม่
local bindChar -- forward declare (ประกอบจริงด้านล่าง) — maintenance ใช้ rebind เองถ้า LP.Character เปลี่ยนโดยไม่มี CharacterAdded
task.spawn(function()
	while not KILL do
		local ok, e = pcall(function()
		local cc = LP.Character
		if cc and cc ~= myChar and cc.Parent and bindChar then
			evlog("char changed without CharacterAdded -> rebind")
			bindChar(cc)
		end
		if cfg.Enabled and myOcc and myChar then
			-- แยก pcall: ส่วนล็อกพัง ห้ามลาก watchdog บล็อกด้านล่างตายไปด้วย
			local okL, eL = pcall(function()
				-- เคลียร์ล็อกที่เป้าหลุดจาก Live / ตาย
				local cur = stV(myOcc, "LockedOn")
				if cur and not aliveInLive(cur) then
					pcall(function() myOcc.LockedOn.Value = nil end)
					cur = nil
				end
				if cfg.AutoLock and equipped() and not inSafezone() and inCombat() then
					if preLockOpponent("tick") then cur = stV(myOcc, "LockedOn") end
					-- หา threat ล่าสุดที่ใกล้กว่าเป้าปัจจุบัน → สลับล็อกให้
					local best, bestD = cur, cur and aliveInLive(cur) and distTo(cur) or 1e9
					for c, t in pairs(MAPS.threatMark) do
						if tick() - t < 4 and aliveInLive(c) then
							local d = distTo(c)
							if d < bestD - 2 then best, bestD = c, d end
						end
					end
					if best and best ~= cur and bestD <= cfg.LockRange then
						pcall(function() myOcc.LockedOn.Value = best end)
					end
				end
			end)
			if not okL then warn("[HZ UBG lock] " .. tostring(eL)) end
			-- ใส่ถุงมือเอง — ยิง TrySwitchEquip = native path จริง (เกมจัดอนิเมชัน/LockedOn ให้)
			if cfg.AutoEquip and EV.SwitchEquip and not inSafezone() and not equipped() then
				pcall(function() EV.SwitchEquip:Fire() end)
				task.wait(0.6) -- กันสแปมระหว่าง EquipDebounce
			end
		end
		-- heal: States folder มาช้ากว่า spawn / ถูกสร้างใหม่ระหว่างรอบ → resolve ใหม่ + ผูก listener ใหม่ (กัน hub นิ่งหลังเกิด)
		if myChar and myChar.Parent and (not myOcc or not myCharData or not myOcc.Parent or not myCharData.Parent) then myStates() end
		if hookStates then hookStates() end
		-- ดักล่วงหน้า: ติด watcher ทุกตัวที่เข้าใกล้ก่อนมันชกหมัดแรก (ไม่รอ snoop)
		local lv = V9.liveLive()
		if cfg.PanicBlock and lv and inCombat() then
			for _, c in ipairs(lv:GetChildren()) do
				if c ~= myChar and aliveInLive(c) and distTo(c) < 18 then
					watchAttacker(c)
				end
			end
		end
		-- watchdog: ปล่อยบล็อกที่ค้าง (คนชกตาย/หลุด/หยุดชก/ไกลเกิน) กันตัวแข็งถาวร
		for tag, m in pairs(MAPS.blockMeta) do
			local age = tick() - m.t
			local bad = age > 3.5
			if not bad and m.c then
				bad = not m.c.Parent or distTo(m.c) > 14
				if not bad then
					local o = select(1, statesOf(m.c.Name))
					local p = o and o:FindFirstChild("Punching")
					if p and not p.Value and age > 0.9 then bad = true end
				end
			end
			if bad then holdBlock(tag, false) end
		end
		-- เก็บกวาด threat + MAPS.learn + watcher + feint เก่า
		if tick() % 5 < 0.5 then
			for c, t in pairs(MAPS.threatMark) do
				if tick() - t > 15 then MAPS.threatMark[c] = nil end
			end
			for c, t in pairs(MAPS.feintMark) do
				if tick() - t > 20 or not (c and c.Parent) then MAPS.feintMark[c] = nil end
			end
			for c, t in pairs(MAPS.slowMoStart) do
				if tick() - t > 30 or not (c and c.Parent) then MAPS.slowMoStart[c] = nil end
			end
			for c, e in pairs(MAPS.watchedAtk) do
				-- engaged = ยังเป็นเป้าสู้เรา (LockedOn/Opponent) หรือเพิ่งเล็งเราใน ≤30s (MAPS.threatMark TTL 15s อยู่แล้ว = อายุอ่อนกว่านี้เสมอ)
				-- ไม่ engaged → inactive/หลุดจากไฟต์ → disconnect watcher ทั้ง 11 conns ทันทีเมื่อผูกเกิน 30s
				-- (re-hook อัตโนมัติ: packet เล็งเราครั้งถัดไปของคนนั้นเรียก watchAttacker ใหม่เอง — drop ไม่กระทบไฟต์จริง)
				local engaged = lockedOn() == c or opponentOf() == c or MAPS.threatMark[c] ~= nil
				if not (c and c.Parent) or (not engaged and tick() - (e.t0 or 0) > 30) then
					dropWatch(c)
				end
			end
			for c, l in pairs(MAPS.learn) do
				if l.lastAtk and tick() - l.lastAtk > 60 or not (c and c.Parent) then MAPS.learn[c] = nil end
			end
		end
		end)
		if not ok then warn("[HZ UBG maint] " .. tostring(e)) end
		task.wait(0.4)
	end
end)

-- ===== HUD (v1 style: pill เด้งขวา + panel ลิสต์เดียว) =====
local TW = game:GetService("TweenService")
local function tw(o, p, d)
	TW:Create(o, TweenInfo.new(d or 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p):Play()
end
local C = {
	bg = Color3.fromRGB(16, 13, 17), head = Color3.fromRGB(28, 20, 25),
	row = Color3.fromRGB(32, 25, 30), row2 = Color3.fromRGB(24, 19, 23),
	rowH = Color3.fromRGB(44, 34, 41), hot = Color3.fromRGB(58, 30, 30),
	txt = Color3.fromRGB(240, 234, 240), dim = Color3.fromRGB(150, 142, 152),
	acc = Color3.fromRGB(255, 92, 92), acc2 = Color3.fromRGB(205, 145, 255),
	on = Color3.fromRGB(72, 205, 112), off = Color3.fromRGB(62, 50, 56),
	warm = Color3.fromRGB(255, 210, 120),
	hp = Color3.fromRGB(235, 84, 84), st = Color3.fromRGB(240, 196, 84),
	pd = Color3.fromRGB(96, 170, 255), ult = Color3.fromRGB(214, 110, 255),
	track = Color3.fromRGB(14, 11, 15),
}
local F_TH, F_TX = Enum.Font.GothamBold, Enum.Font.SourceSans

-- รอบนี้โดน kill ระหว่างสร้างโค้ดต่อสู้ (รันซ้ำ/รุ่นใหม่แทรก) → ห้ามสร้าง GUI เป็นไอคอนผีค้างจอ
if KILL or _G.HZUbgGen ~= gen then return end

local gui = Instance.new("ScreenGui")
gui.Name = "HZUBG" gui.ResetOnSpawn = false gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = guiRoot

-- HUD เหนือหัวเป้าหมาย (BillboardGui — ใช้กับ cfg.EnemyHUD)
local enemyTag = Instance.new("BillboardGui", gui)
enemyTag.Name = "EnemyTag"
enemyTag.Size = UDim2.new(0, 300, 0, 60)
enemyTag.StudsOffsetWorldSpace = Vector3.new(0, 4.8, 0)
enemyTag.AlwaysOnTop = true
enemyTag.Enabled = false
local tagLbl = Instance.new("TextLabel", enemyTag)
tagLbl.Size = UDim2.new(1, 0, 1, 0)
tagLbl.BackgroundTransparency = 0.35
tagLbl.BackgroundColor3 = Color3.fromRGB(20, 12, 16)
tagLbl.Font = F_TH tagLbl.TextSize = 15
tagLbl.TextColor3 = C.txt
tagLbl.TextStrokeTransparency = 0.5
Instance.new("UICorner", tagLbl).CornerRadius = UDim.new(0, 6)

-- ลากได้: ขยับ <12px = คลิก, มากกว่า = ลาก (กันคลิกพลาดแล้วเมนูเด้ง)
local function draggable(handle, frame, opt)
	opt = opt or {}
	local dragging, moved, ds, sp = false, false, nil, nil
	handle.InputBegan:Connect(function(io)
		if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
			if opt.dragStart then opt.dragStart() end -- ยกเลิก tween เปิด/ปิดที่ค้าง = ลากไม่สั่น
			dragging, moved = true, false
			ds, sp = io.Position, frame.Position
			local ch
			ch = io.Changed:Connect(function()
				if io.UserInputState == Enum.UserInputState.End then
					if ch then ch:Disconnect() end -- กัน listener สะสมทุกครั้งที่ลาก
					dragging = false
					if not moved and opt.click then opt.click() end
					if moved and opt.moved then opt.moved() end
				end
			end)
		end
	end)
	conns[#conns + 1] = UIS.InputChanged:Connect(function(io)
		if not dragging or not ds then return end
		if io.UserInputType ~= Enum.UserInputType.MouseMovement and io.UserInputType ~= Enum.UserInputType.Touch then return end
		local d = io.Position - ds
		if d.Magnitude > 12 then moved = true end
		if moved then
			frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
		end
	end)
end

-- เปลี่ยนเซิร์ฟเวอร์: ดึง list จาก Roblox API → สุ่มเซิร์ฟคนไม่เต็ม (API พัง = rejoin)
function V9.serverHop()
	flash("กำลังหาเซิร์ฟเวอร์ใหม่...", C.warm)
	task.spawn(function()
		local cands = {}
		local url = "https://games.roblox.com/v1/games/" .. game.PlaceId
			.. "/servers/Public?sortOrder=Asc&limit=100"
		local ok, data = pcall(function()
			local body
			if request then
				local r = request({ Url = url, Method = "GET" })
				body = r and r.Body
			end
			body = body or game:HttpGet(url)
			return HttpService:JSONDecode(body)
		end)
		if ok and data and data.data then
			for _, s in ipairs(data.data) do
				if s.id ~= game.JobId and s.playing
					and s.playing < (s.maxPlayers or 20) - 1 then
					cands[#cands + 1] = s.id
				end
			end
		end
		pcall(function()
			if #cands > 0 then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, cands[math.random(#cands)], LP)
			else
				TeleportService:Teleport(game.PlaceId, LP)
			end
		end)
	end)
end

-- ===== ชื่อเกม + ไอคอนเกมจริง (ดึงจาก Roblox API — ใช้ทั้งในไอคอนลอยและหัวเมนู) =====
local gameName = "Untitled Boxing Game"
pcall(function()
	local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
	if type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" then gameName = info.Name end
end)
local gameIcon
pcall(function() gameIcon = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150" end)

-- ไอคอนลอย HZ HUB (ลากได้ แตะเปิดเมนู) — ไอคอนเกมจริง + จุดสถานะ + ขอบเรืองหายใจ + hover ขยาย
-- (ห่อ do..end กันลิมิต 200 local — expose แค่ pill/pillDot/paintPill)
local pill, pillDot, paintPill
do
	pill = Instance.new("Frame", gui)
	pill.Size = UDim2.fromOffset(62, 72)
	pill.AnchorPoint = Vector2.new(1, 0.5)
	pill.Position = type(cfg.PillPos) == "table" and UDim2.new(unpack(cfg.PillPos)) or UDim2.new(1, -10, 0.34, 0)
	pill.BackgroundColor3 = C.bg
	pill.Active = true
	Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 16)
	do
		local g = Instance.new("UIGradient", pill)
		g.Color = ColorSequence.new(Color3.fromRGB(42, 30, 42), Color3.fromRGB(14, 11, 16))
		g.Rotation = 60
	end
	local pillStroke = Instance.new("UIStroke", pill)
	pillStroke.Color = C.acc2 pillStroke.Thickness = 1.6 pillStroke.Transparency = 0.2
	local pillScale = Instance.new("UIScale", pill)
	-- ชั้นหลัง: ตัวอักษร HZ (กันกรณีไอคอนเกมโหลดไม่ขึ้น)
	local pillBk = Instance.new("TextLabel", pill)
	pillBk.Size = UDim2.fromOffset(48, 48)
	pillBk.Position = UDim2.new(0.5, -24, 0, 4)
	pillBk.BackgroundColor3 = C.row2
	pillBk.Text = "HZ" pillBk.Font = F_TH pillBk.TextSize = 21 pillBk.TextColor3 = C.acc
	Instance.new("UICorner", pillBk).CornerRadius = UDim.new(0, 12)
	local pillImg = Instance.new("ImageLabel", pill)
	pillImg.Size = pillBk.Size pillImg.Position = pillBk.Position
	pillImg.BackgroundTransparency = 1
	if gameIcon then pillImg.Image = gameIcon end
	Instance.new("UICorner", pillImg).CornerRadius = UDim.new(0, 12)
	local pillLbl = Instance.new("TextLabel", pill)
	pillLbl.Size = UDim2.new(1, 0, 0, 13)
	pillLbl.Position = UDim2.new(0, 0, 1, -15)
	pillLbl.BackgroundTransparency = 1
	pillLbl.Text = "HZ HUB" pillLbl.Font = F_TH pillLbl.TextSize = 9 pillLbl.TextColor3 = C.acc2
	pillDot = Instance.new("Frame", pill)
	pillDot.Size = UDim2.fromOffset(13, 13)
	pillDot.Position = UDim2.new(1, -7, 0, -4)
	Instance.new("UICorner", pillDot).CornerRadius = UDim.new(1, 0)
	local pillDotSt = Instance.new("UIStroke", pillDot)
	pillDotSt.Color = Color3.new(1, 1, 1) pillDotSt.Thickness = 1.6
	local pillKey = Instance.new("TextLabel", pill)
	pillKey.Size = UDim2.fromOffset(16, 16)
	pillKey.Position = UDim2.new(0, -5, 1, -14)
	pillKey.BackgroundColor3 = C.row
	pillKey.Text = "M" pillKey.Font = F_TH pillKey.TextSize = 10 pillKey.TextColor3 = C.dim
	Instance.new("UICorner", pillKey).CornerRadius = UDim.new(0, 5)
	-- hover = ขยายนิด + เรืองแรงขึ้น / ยามว่าง = ขอบเรืองหายใจช้าๆ
	local pillHov = false
	pill.MouseEnter:Connect(function()
		pillHov = true
		tw(pillScale, { Scale = 1.09 }, 0.12)
		tw(pillStroke, { Transparency = 0, Thickness = 2.2 }, 0.12)
	end)
	pill.MouseLeave:Connect(function()
		pillHov = false
		tw(pillScale, { Scale = 1 }, 0.16)
		tw(pillStroke, { Transparency = 0.2, Thickness = 1.6 }, 0.16)
	end)
	task.spawn(function()
		while not KILL do
			if pill.Visible and not pillHov then
				tw(pillStroke, { Transparency = 0.62 }, 0.9)
				task.wait(0.95)
				tw(pillStroke, { Transparency = 0.2 }, 0.9)
			end
			task.wait(0.95)
		end
	end)
	paintPill = function()
		pillDot.BackgroundColor3 = cfg.Enabled and C.on or C.acc
	end
	paintPill()
end

-- panel แนวนอน 3 คอลัมน์ (เลื่อนได้) — หัวมีไอคอน+ชื่อเกมจริง/สถานะสด • พรีเซ็ตเร็ว • พับหมวดได้ (มี tween) • ปรับค่าเอง • แถบเลือด
-- (ห่อใน do..end + เก็บ widget ที่ loop ใช้ไว้ใน UI — ฟังก์ชันหลักใกล้ลิมิต 200 local แล้ว)
local UI = {}
local DOCK, OFFR, panel, head, closeB, paintAll
do
	local PW, PH = 700, 440
	pcall(function()
		local vp = WS.CurrentCamera.ViewportSize
		PW = math.clamp(vp.X - 24, 560, 760)
		PH = math.clamp(vp.Y - 50, 380, 560)
	end)
	DOCK = UDim2.new(0.5, 0, 1, -8)
	OFFR = UDim2.new(0.5, 0, 1, PH + 40)
	local LEFT, RIGHT = Enum.TextXAlignment.Left, Enum.TextXAlignment.Right
	local function mk(class, parent, p, radius)
		local o = Instance.new(class)
		o.BorderSizePixel = 0
		for k, v in pairs(p) do o[k] = v end
		if radius then Instance.new("UICorner", o).CornerRadius = UDim.new(0, radius) end
		o.Parent = parent
		return o
	end
	local lastTxt = {}
	function UI.setT(l, t) if lastTxt[l] ~= t then lastTxt[l] = t l.Text = t end end

	panel = mk("Frame", gui, { Size = UDim2.new(0, PW, 0, PH), AnchorPoint = Vector2.new(0.5, 1), Position = OFFR,
		BackgroundColor3 = C.bg, Visible = false, Active = true, ClipsDescendants = true }, 14)
	local pScale = Instance.new("UIScale", panel)
	UI.pScale = pScale
	do
		local pg = Instance.new("UIGradient", panel)
		pg.Color = ColorSequence.new(Color3.fromRGB(23, 18, 24), Color3.fromRGB(13, 10, 14))
		pg.Rotation = 90
		local st = Instance.new("UIStroke", panel)
		st.Color = C.acc2 st.Thickness = 1 st.Transparency = 0.5
	end

	-- หัว panel = จุดลาก + ไอคอน/ชื่อเกมจริง + แถวสถานะสด (จุดสี + สถานะ + สถิติย่อ)
	head = mk("Frame", panel, { Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = C.head }, 14)
	mk("Frame", head, { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14), BackgroundColor3 = C.head })
	do
		local hBk = mk("TextLabel", head, { Size = UDim2.fromOffset(42, 42), Position = UDim2.new(0, 10, 0, 8), BackgroundColor3 = C.row2,
			Text = "HZ", Font = F_TH, TextSize = 19, TextColor3 = C.acc }, 11)
		local hIcon = Instance.new("ImageLabel", head)
		hIcon.Size = hBk.Size hIcon.Position = hBk.Position hIcon.BackgroundTransparency = 1
		if gameIcon then hIcon.Image = gameIcon end
		Instance.new("UICorner", hIcon).CornerRadius = UDim.new(0, 11)
	end
	mk("TextLabel", head, { Size = UDim2.fromOffset(82, 22), Position = UDim2.new(0, 60, 0, 6), BackgroundTransparency = 1,
		Text = "HZ HUB", Font = F_TH, TextSize = 17, TextColor3 = C.txt, TextXAlignment = LEFT })
	mk("TextLabel", head, { Size = UDim2.fromOffset(44, 16), Position = UDim2.new(0, 146, 0, 9), BackgroundColor3 = C.row,
		Text = "v8.1", Font = F_TH, TextSize = 11, TextColor3 = C.acc2 }, 5)
	mk("TextLabel", head, { Size = UDim2.new(1, -260, 0, 20), Position = UDim2.new(0, 200, 0, 7), BackgroundTransparency = 1,
		Text = gameName, Font = F_TX, TextSize = 13, TextColor3 = C.dim, TextXAlignment = LEFT, TextTruncate = Enum.TextTruncate.AtEnd })
	closeB = mk("TextButton", head, { Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -34, 0, 7), BackgroundColor3 = C.row,
		Text = "X", Font = F_TH, TextSize = 14, TextColor3 = C.acc, AutoButtonColor = false, Selectable = false }, 7)
	closeB.MouseEnter:Connect(function() tw(closeB, { BackgroundColor3 = C.hot }, 0.1) end)
	closeB.MouseLeave:Connect(function() tw(closeB, { BackgroundColor3 = C.row }, 0.12) end)
	UI.stDot = mk("Frame", head, { Size = UDim2.fromOffset(9, 9), Position = UDim2.new(0, 60, 0, 38), BackgroundColor3 = C.on }, 4)
	UI.stTxt = mk("TextLabel", head, { Size = UDim2.new(0.5, -78, 0, 18), Position = UDim2.new(0, 76, 0, 33), BackgroundTransparency = 1,
		Text = "กำลังเริ่ม...", Font = F_TH, TextSize = 13, TextColor3 = C.on, TextXAlignment = LEFT, TextTruncate = Enum.TextTruncate.AtEnd })
	UI.stMini = mk("TextLabel", head, { Size = UDim2.new(0.5, -18, 0, 18), Position = UDim2.new(0.5, 0, 0, 33), BackgroundTransparency = 1,
		Text = "", Font = F_TX, TextSize = 13, TextColor3 = C.dim, TextXAlignment = RIGHT })
	mk("Frame", panel, { Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 62), BackgroundColor3 = C.acc2, BackgroundTransparency = 0.7 })

	-- แถบคำอธิบายล่าง (ชี้เมาส์ที่ตัวเลือกใด แสดงคำอธิบายตัวนั้น)
	local HINT_DEF = "ชี้ที่ตัวเลือกเพื่ออ่านคำอธิบาย  •  M เปิด/ปิดเมนู  •  K ปิดระบบด่วน  •  ลากหัวเมนูเพื่อย้าย"
	local hintLbl = mk("TextLabel", mk("Frame", panel, { Size = UDim2.new(1, -12, 0, 42), Position = UDim2.new(0, 6, 1, -48),
		BackgroundColor3 = C.row2 }, 8), { Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1,
		Text = HINT_DEF, Font = F_TX, TextSize = 13, TextColor3 = C.dim, TextWrapped = true, TextXAlignment = LEFT })
	local function setHint(t) UI.setT(hintLbl, t or HINT_DEF) end

	-- ลิสต์เลื่อน 3 คอลัมน์แนวนอน — วางตำแหน่งเอง (เด็กทุกตัวเป็นลูกตรงของ scroll) + tween ตอนพับหมวด
	local scroll = mk("ScrollingFrame", panel, { Size = UDim2.new(1, -16, 1, -116), Position = UDim2.new(0, 8, 0, 66), BackgroundTransparency = 1,
		ScrollBarThickness = 3, ScrollBarImageColor3 = C.acc2, CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y, VerticalScrollBarInset = Enum.ScrollBarInset.Always })
	UI.scroll = scroll
	-- เก็บสถานะเลย์เอาต์ไว้ในตารางเดียว (กันลิมิต 200 local)
	local LAY = { items = {}, col = 1, w = math.floor((PW - 16 - 24) / 3) }
	LAY.x = { 0, LAY.w + 12, (LAY.w + 12) * 2 }
	local function addItem(o, h)
		LAY.items[#LAY.items + 1] = { o = o, col = LAY.col, h = h }
		return o
	end
	local function reflow(anim)
		local cy = { 0, 0, 0 }
		for _, e in ipairs(LAY.items) do
			if e.o.Visible then
				local p = UDim2.new(0, LAY.x[e.col], 0, cy[e.col])
				if anim then tw(e.o, { Position = p }, 0.16) else e.o.Position = p end
				cy[e.col] = cy[e.col] + e.h + 4
			end
		end
		scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(cy[1], cy[2], cy[3]) + 6)
	end
	UI.reflow = reflow
	local groups, curGroup = {}, nil
	local function reg(o) if curGroup then curGroup.items[#curGroup.items + 1] = o end return o end

	-- หัวหมวด: คลิกเพื่อพับ/ขยาย (จำสถานะใน cfg.Fold) + แถวใต้เลื่อนขึ้น/ลงนุ่มๆ
	local function secHead(txt, id, defFolded)
		local g = { items = {}, folded = defFolded and true or false }
		if type(cfg.Fold) == "table" and cfg.Fold[id] ~= nil then g.folded = cfg.Fold[id] and true or false end
		local b = addItem(mk("TextButton", scroll, { Size = UDim2.new(0, LAY.w, 0, 30), BackgroundTransparency = 1, AutoButtonColor = false, Selectable = false, Text = "",
			Font = F_TH, TextSize = 13, TextColor3 = C.acc2 }), 30)
		function g.paint(anim)
			b.Text = "─  " .. (g.folded and "▶ " or "▼ ") .. txt .. (g.folded and ("  (" .. #g.items .. ")") or "") .. "  ─"
			for _, it2 in ipairs(g.items) do it2.Visible = not g.folded end
			reflow(anim ~= false)
		end
		b.MouseEnter:Connect(function() b.TextColor3 = C.txt setHint("คลิกเพื่อพับ/ขยายหมวด \"" .. txt .. "\" (จำไว้ให้)") end)
		b.MouseLeave:Connect(function() b.TextColor3 = C.acc2 setHint() end)
		b.MouseButton1Click:Connect(function()
			g.folded = not g.folded
			g.paint()
			if type(cfg.Fold) ~= "table" then cfg.Fold = {} end
			cfg.Fold[id] = g.folded
			saveCfg()
		end)
		groups[#groups + 1] = g
		curGroup = g
		return g
	end

	-- แถวสวิตช์: คลิกทั้งแถว = เปลี่ยนค่า + sync TIE ทุกตัว
	local togglePaint = {}
	paintAll = function() for _, f in pairs(togglePaint) do f() end end
	local function mkRow(txt, key, keycap, hotRow, hint)
		local r = addItem(mk("TextButton", scroll, { Size = UDim2.new(0, LAY.w, 0, 38), BackgroundColor3 = hotRow and C.hot or C.row,
			AutoButtonColor = false, Selectable = false, Text = "" }, 7), 38)
		if hotRow then
			local st = Instance.new("UIStroke", r)
			st.Color = C.acc st.Thickness = 1 st.Transparency = 0.4
		end
		r.MouseEnter:Connect(function() r.BackgroundColor3 = C.rowH setHint(hint) end) -- set ตรง (ไม่ tween) กันกระตุกตอนเลื่อนผ่านหลายแถว
		r.MouseLeave:Connect(function() r.BackgroundColor3 = hotRow and C.hot or C.row setHint() end)
		mk("TextLabel", r, { Size = UDim2.new(1, -56, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
			Text = txt, Font = F_TX, TextSize = 16, TextColor3 = C.txt, TextXAlignment = LEFT })
		local sw = mk("Frame", r, { Size = UDim2.fromOffset(46, 20), Position = UDim2.new(1, -54, 0.5, -10), BackgroundColor3 = C.off }, 8)
		local knob = mk("Frame", sw, { Size = UDim2.fromOffset(15, 15), Position = UDim2.new(0, 2, 0.5, -7.5), BackgroundColor3 = C.txt }, 6)
		if keycap then
			mk("TextLabel", r, { Size = UDim2.fromOffset(18, 16), Position = UDim2.new(1, -64, 0.5, -8), BackgroundColor3 = C.row2,
				Text = keycap, Font = F_TH, TextSize = 12, TextColor3 = C.dim }, 4)
		end
		togglePaint[key] = function()
			local on = cfg[key] and true or false
			tw(sw, { BackgroundColor3 = on and C.on or C.off }, 0.15)
			tw(knob, { Position = on and UDim2.new(1, -18, 0.5, -7.5) or UDim2.new(0, 2, 0.5, -7.5) }, 0.15)
		end
		r.MouseButton1Click:Connect(function()
			cfg[key] = not cfg[key]
			applyTies(key)
			saveCfg()
			paintAll()
			if key == "Enabled" then
				if not cfg.Enabled then dropAllBlocks() end
				paintPill()
				if flash then flash(cfg.Enabled and "HZ HUB: เปิดระบบ" or "HZ HUB: ปิดระบบ",
					cfg.Enabled and C.on or C.acc) end
			end
		end)
		togglePaint[key]()
		reg(r)
	end

	local function btnRow(txt, col, cb, hint)
		local b = addItem(mk("TextButton", scroll, { Size = UDim2.new(0, LAY.w, 0, 30), BackgroundColor3 = col or C.row2, Text = txt,
			Font = F_TH, TextSize = 14, TextColor3 = C.txt, AutoButtonColor = false, Selectable = false }, 7), 30)
		b.MouseEnter:Connect(function() b.BackgroundColor3 = C.rowH setHint(hint) end)
		b.MouseLeave:Connect(function() b.BackgroundColor3 = col or C.row2 setHint() end)
		b.MouseButton1Click:Connect(cb)
		reg(b)
	end

	-- แถวปรับค่า: [-] ค่า [+] — กดค้างเพื่อเลื่อนต่อเนื่อง, เซฟตอนปล่อย
	local TUNE = {}
	local function stepRow(txt, key, mn, mx, step, fmt, hint)
		local r = addItem(reg(mk("Frame", scroll, { Size = UDim2.new(0, LAY.w, 0, 30), BackgroundColor3 = C.row }, 7)), 30)
		r.MouseEnter:Connect(function() setHint(hint) end)
		r.MouseLeave:Connect(function() setHint() end)
		mk("TextLabel", r, { Size = UDim2.new(1, -150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
			Text = txt, Font = F_TX, TextSize = 14, TextColor3 = C.txt, TextXAlignment = LEFT })
		local val = mk("TextLabel", r, { Size = UDim2.fromOffset(50, 22), Position = UDim2.new(1, -84, 0.5, -11), BackgroundTransparency = 1,
			Text = "", Font = F_TH, TextSize = 14, TextColor3 = C.acc2 })
		local dirty = false
		local function show() val.Text = fmt(cfg[key] or mn) end
		local function bump(d)
			local v = math.clamp(math.floor(((cfg[key] or mn) + d * step) / step + 0.5) * step, mn, mx)
			cfg[key] = tonumber(string.format("%.3f", v))
			dirty = true
			show()
		end
		local function btn(sym, x, d)
			local b = mk("TextButton", r, { Size = UDim2.fromOffset(30, 26), Position = UDim2.new(1, x, 0.5, -13), BackgroundColor3 = C.row2,
				Text = sym, Font = F_TH, TextSize = 17, TextColor3 = C.txt, AutoButtonColor = false, Selectable = false }, 6)
			local gen = 0
			local function stop() gen += 1 if dirty then dirty = false saveCfg() end end
			b.MouseEnter:Connect(function() b.BackgroundColor3 = C.rowH setHint(hint) end)
			b.MouseLeave:Connect(function() b.BackgroundColor3 = C.row2 stop() end)
			b.MouseButton1Up:Connect(stop)
			b.MouseButton1Down:Connect(function()
				gen += 1
				local my = gen
				bump(d)
				task.delay(0.45, function()
					while gen == my and not KILL do bump(d) task.wait(0.07) end
				end)
			end)
		end
		btn("-", -134, -1)
		btn("+", -34, 1)
		togglePaint["step:" .. key] = show
		TUNE[#TUNE + 1] = key
		show()
	end

	-- การ์ดสถานะสด + แถบ (เลือด/สตามิน่า/เกจ)
	function V9.mkCard(h)
		return addItem(reg(mk("Frame", scroll, { Size = UDim2.new(0, LAY.w, 0, h), BackgroundColor3 = C.row }, 8)), h)
	end
	function V9.mkBar(parent, y, label, col)
		mk("TextLabel", parent, { Size = UDim2.fromOffset(56, 14), Position = UDim2.new(0, 8, 0, y), BackgroundTransparency = 1,
			Text = label, Font = F_TX, TextSize = 13, TextColor3 = C.dim, TextXAlignment = LEFT })
		local track = mk("Frame", parent, { Size = UDim2.new(1, -128, 0, 8), Position = UDim2.new(0, 66, 0, y + 3), BackgroundColor3 = C.track }, 4)
		local fill = mk("Frame", track, { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = col }, 4)
		local val = mk("TextLabel", parent, { Size = UDim2.fromOffset(56, 14), Position = UDim2.new(1, -62, 0, y), BackgroundTransparency = 1,
			Text = "--", Font = F_TH, TextSize = 12, TextColor3 = C.txt, TextXAlignment = RIGHT })
		local lf
		return function(f, t)
			f = math.clamp(f or 0, 0, 1)
			local k = math.floor(f * 200 + 0.5)
			if k ~= lf then lf = k fill.Size = UDim2.new(f, 0, 1, 0) end
			UI.setT(val, t or "--")
		end
	end

	-- ===== คอลัมน์ 1: สวิตช์หลัก + พรีเซ็ต + ป้องกัน + สมอง =====
	LAY.col = 1
	mkRow("⚡ ระบบหลัก", "Enabled", "K", true, "สวิตช์หลัก: ปิด = ฮับหยุดทุกระบบ (กด K ได้ทุกเมื่อ แม้เมนูปิดอยู่)")
	do
		local PRESETS = {
			{ name = "ตั้งรับ", hint = "เน้นป้องกัน: หลบ/บล็อก/กันเฟนต์/สวนกลับ ไม่ต่อยบุกเอง (ปลอดภัยสุด)",
				set = { AutoPD = true, AutoBlock = true, PanicBlock = true, AntiFeint = true, Predict = true, AdaptFeint = true,
					AutoPunish = true, PunishAfterPD = true, AutoLock = true, AutoM1 = false, AutoPoke = false, AutoHeavy = false,
					AutoBreak = false, AutoSpecial = false, AutoUlt = false } },
			{ name = "สมดุล", hint = "ค่าแนะนำ: ป้องกันครบ + สวนกลับ + เจาะต่อยช่องว่าง + หนักตอนเปิดจริง + อัลติเมื่อศัตรูเสียหลัก",
				set = { AutoPD = true, AutoBlock = true, PanicBlock = true, AntiFeint = true, Predict = true, AdaptFeint = true,
					AutoPunish = true, PunishAfterPD = true, AutoLock = true, AutoM1 = true, AutoPoke = true, AutoHeavy = true,
					AutoBreak = true, AutoSpecial = false, AutoUlt = true } },
			{ name = "บุกเต็ม", hint = "เปิดทุกระบบรวมต่อย M1/เจาะ/หนัก/สเปเชียลเอง ก้าวร้าวสุด (สตามิน่าหมดไวกว่า)",
				set = { AutoPD = true, AutoBlock = true, PanicBlock = true, AntiFeint = true, Predict = true, AdaptFeint = true,
					AutoPunish = true, PunishAfterPD = true, AutoLock = true, AutoM1 = true, AutoPoke = true, AutoHeavy = true,
					AutoBreak = true, AutoSpecial = true, AutoUlt = true } },
		}
		local pf = addItem(mk("Frame", scroll, { Size = UDim2.new(0, LAY.w, 0, 36), BackgroundTransparency = 1 }), 36)
		local pb = {}
		for i, p in ipairs(PRESETS) do
			pb[i] = mk("TextButton", pf, { Size = UDim2.new(1 / 3, -4, 1, 0), Position = UDim2.new((i - 1) / 3, (i - 1) * 2, 0, 0),
				BackgroundColor3 = C.row2, Text = p.name, Font = F_TH, TextSize = 14, TextColor3 = C.dim, AutoButtonColor = false, Selectable = false }, 7)
			pb[i].MouseEnter:Connect(function() setHint(p.hint) pb[i].BackgroundColor3 = C.rowH end)
			pb[i].MouseLeave:Connect(function() setHint() if togglePaint["preset"] then togglePaint["preset"]() end end)
			pb[i].MouseButton1Click:Connect(function()
				for k, v in pairs(p.set) do cfg[k] = v end
				for k in pairs(p.set) do applyTies(k) end
				saveCfg()
				paintAll()
				if flash then flash("พรีเซ็ต: " .. p.name, C.acc2) end
			end)
		end
		togglePaint["preset"] = function()
			for i, p in ipairs(PRESETS) do
				local on = true
				for k, v in pairs(p.set) do if (cfg[k] and true or false) ~= v then on = false break end end
				tw(pb[i], { BackgroundColor3 = on and C.hot or C.row2 }, 0.12)
				pb[i].TextColor3 = on and C.acc or C.dim
			end
		end
	end
	secHead("ป้องกัน", "def")
	mkRow("หลบเพอร์เฟกต์", "AutoPD", nil, nil, "แดชหลบตอนเกมเปิดหน้าต่างเพอร์เฟกต์ → ได้ slow-mo สวนฟรี (ต้องล็อกเป้าอยู่ ไม่งั้นหลบได้แค่ธรรมดา)")
	mkRow("ออโต้บล็อก", "AutoBlock", nil, nil, "บล็อกหมัดที่หลบไม่ได้ ตามเวลาหมัดถึงจริง (ระบบชดเชย ping ให้เอง)")
	mkRow("บล็อกฉับไว", "PanicBlock", nil, nil, "ศัตรูเริ่มชกใส่ในระยะประชิด → บล็อกทันที ไวกว่ารอเวลาหมัดถึง")
	mkRow("แดชเฉพาะจังหวะ", "DodgeWindowOnly", nil, nil, "แดชเฉพาะหมัดเปิดคอมโบ/อัลติ (เพอร์เฟกต์) — กลางคอมโบให้บล็อก ประหยัดแดชไว้จังหวะสำคัญ")
	mkRow("กันเฟนต์", "AntiFeint", nil, nil, "ไม่แดช/ไม่บล็อกหมัดหลอก (feint) ไม่โดนล่อ")
	secHead("สมอง", "brain")
	mkRow("สมองคาดการณ์", "Predict", nil, nil, "ใช้ frame data จริงของสไตล์ศัตรู + จังหวะที่เรียนรู้ เมื่อเกมไม่ส่งเวลาหมัดถึงมา")
	mkRow("เรียนสายเฟนต์", "AdaptFeint", nil, nil, "จำคนที่เฟนต์บ่อย (>35%) แล้วสลับไปบล็อกแทนแดช")
	-- ===== คอลัมน์ 2: โจมตี + ระบบ =====
	LAY.col = 2
	secHead("โจมตี", "atk")
	mkRow("สวนกลับ", "AutoPunish", nil, nil, "ศัตรูพักมือ/หมัดหมด → ต่อยสวนทันที ไม่ต่อยใส่คนที่บล็อกอยู่")
	mkRow("สวนหลังหลบ", "PunishAfterPD", nil, nil, "หลบเพอร์เฟกต์สำเร็จ → ต่อยสวนในช่วง slow-mo (ต้องเปิดสวนกลับ)")
	mkRow("ต่อยอัตโนมัติ (M1)", "AutoM1", nil, nil, "ต่อย M1 เอง: เจาะช่องว่างตลอด + หนักตอนมันเสียหลัก (ห้ามต่อยเฉพาะตอนมันกำลังชก)")
	mkRow("เจาะต่อยรัว", "AutoPoke", nil, nil, "ต่อยเบาเจาะทุกช่องว่าง (คอมโบ gap/นิ่ง/บล็อก) — ปิด = ต่อยเฉพาะตอนมันเสียหลัก")
	mkRow("ล็อกออนอัตโนมัติ", "AutoLock", nil, nil, "ล็อกคนที่ต่อยเราเอง — จำเป็นให้เกมเปิดหน้าต่างเพอร์เฟกต์")
	mkRow("หนักสวนสตามิน่าแตก", "AutoHeavy", nil, nil, "ศัตรูสตามิน่าแตก (StaminaBroken) → ต่อยหนักสวน")
	mkRow("หนักแตกเกราะ", "AutoBreak", nil, nil, "ศัตรูบล็อกค้างนาน → ต่อยหนักทำลายเกราะ")
	mkRow("เฟนต์ล่อแดช", "AutoFeint", nil, nil, "ศัตรูหลบหมัดเราบ่อย → หมัดหลอกเผาแดชมันแล้วต่อยจริง (อาวุธฆ่าบอทหลบเก่ง)")
	mkRow("บุกเข้าหา", "AutoEngage", nil, nil, "ศัตรูอยู่นอกระยะชก + ไม่ได้ชก → แดชเข้าไปต่อยเลย (ปิดช่องห่าง ได้ advantage หลังแดช)")
	mkRow("สเปเชียลอัตโนมัติ", "AutoSpecial", nil, nil, "ใช้ท่าพิเศษเมื่อเป้าอยู่ในระยะและเราว่าง (ทดลอง — บางสไตล์เสี่ยง)")
	mkRow("อัลติอัตโนมัติ", "AutoUlt", nil, nil, "ปล่อยอัลติเมื่อเกจเต็ม + ศัตรูเสียหลักนาน (เกจแตก/สตันหนัก/สโลว์โม) — ไม่ยิงลอย")
	secHead("ระบบ", "sys")
	mkRow("ใส่ถุงมืออัตโนมัติ", "AutoEquip", nil, nil, "ใส่ถุงมือเองเมื่อยังไม่ได้ถือ (ทดลอง)")
	mkRow("เดินออโต้ (strafe)", "AutoStrafe", nil, nil, "วนซ้ายขวารอบเป้า + รักษาระยะชกเอง — ดูเป็นคนจริง หมัดศัตรูเฉี่ยว และเข้าระยะอัตโนมัติ")
	mkRow("HUD เหนือหัวศัตรู", "EnemyHUD", nil, nil, "ป้ายเลือด/สตามิน่าเหนือหัวศัตรู + แจ้งเตือนอัลติพร้อม/ศัตรูหมดแรง")
	mkRow("หน่วงคงที่ 0.05s", "FixedDelay", nil, nil, "หน่วงทุก reaction คงที่ 0.05 วินาที — ค่าเดียวเป๊ะไม่สุ่ม (ปิด = 0ms ทันที)")
	btnRow("🎰 หมุนสไตล์ 1 ครั้ง (ยืนที่ร้าน)", Color3.fromRGB(45, 40, 62), function()
		local ok, err = pcall(function() loadstring(readfile("hz_spin.lua"))() end)
		if flash then
			flash(not ok and ("spin ERR: " .. tostring(err))
				or (_G.HZSPIN and "หมุน! (ผลใน hz_spin.txt)" or "หยุดหมุนสไตล์"),
				(ok and _G.HZSPIN) and C.on or C.acc)
		end
	end, "กด 1 ที = หมุน 1 ครั้ง: ใช้หมุนโชคดีก่อน (อัตราดีกว่า) ไม่แตะเงิน — ผล+อัตราใน hz_spin.txt")
	btnRow("⇄ เปลี่ยนเซิร์ฟเวอร์ทันที", Color3.fromRGB(70, 35, 35), V9.serverHop, "ย้ายไปเซิร์ฟเวอร์อื่นที่คนไม่เต็ม (ถ้าหาไม่ได้จะเข้าใหม่)")
	btnRow("↺ รีเซ็ตสถิติ", nil, function()
		STATE.pdCount, STATE.blockCount, STATE.punishCount = 0, 0, 0
		STATE.hitCount, STATE.feintCount, STATE.foolishCount = 0, 0, 0
		if flash then flash("รีเซ็ตสถิติแล้ว", C.warm) end
	end, "ล้างตัวเลขหลบ/บล็อก/สวน ในหัวเมนูและการ์ดสถิติ")
	-- ===== คอลัมน์ 3: ปรับค่า + สถานะสด =====
	LAY.col = 3
	secHead("ปรับค่า", "tune", true)
	do
		local F = {
			s = function(v) return string.format("%.2fs", v) end,
			n = function(v) return string.format("%g", v) end,
			p = function(v) return string.format("%d%%", math.floor(v * 100 + 0.5)) end,
		}
		stepRow("บล็อกก่อนหมัดถึง", "BlockLead", 0, 0.2, 0.01, F.s, "บล็อกล่วงหน้ากี่วินาที (ระบบบวกชดเชย ping ให้เอง) มาก = บล็อกเร็วขึ้น")
		stepRow("ค้างบล็อก", "BlockHold", 0.2, 1, 0.05, F.s, "ค้างบล็อกนานกี่วินาทีต่อหมัด")
		stepRow("ปล่อยบล็อกหลังหมัดหมด", "BlockRelease", 0.1, 0.8, 0.05, F.s, "ศัตรูหยุดชกแล้วถือบล็อกต่ออีกกี่วิ (เกมกันบล็อกซ้ำ 0.3 วิหลังปล่อย)")
		stepRow("ระยะหลบ/บล็อก (studs)", "ReactRange", 3, 14, 0.5, F.n, "หมัดเข้าใกล้แค่นี้ถึงจะหลบ/บล็อก — ต่ำ = ดูเป็นคนมากขึ้น สูง = ปลอดภัยกว่า")
		stepRow("ระยะสวน (studs)", "PunishRange", 4, 14, 1, F.n, "ไกลสุดที่จะต่อยสวน")
		stepRow("ระยะ M1 (studs)", "M1Range", 4, 10, 0.5, F.n, "ไกลสุดที่ M1 อัตโนมัติทำงาน")
		stepRow("ระยะบุก (studs)", "EngageRange", 8, 20, 1, F.n, "ศัตรูอยู่ไกลเกินระยะชกแต่ไม่เกินนี้ → แดชเข้าหาเอง")
		stepRow("ระยะล็อกเป้า (studs)", "LockRange", 8, 30, 1, F.n, "ไกลสุดที่ล็อกเป้าอัตโนมัติ")
		stepRow("ระยะสเปเชียล (studs)", "SpecialRange", 5, 20, 1, F.n, "ไกลสุดที่ใช้ท่าพิเศษอัตโนมัติ")
		stepRow("ระยะอัลติ (studs)", "UltRange", 5, 20, 1, F.n, "ไกลสุดที่ปล่อยอัลติอัตโนมัติ")
		stepRow("สตามิน่าขั้นต่ำก่อนต่อย", "MinStaminaFrac", 0, 0.6, 0.02, F.p, "สตามิน่าเราต่ำกว่า % นี้ → ไม่ต่อยเอง (กันหมดแรง)")
		stepRow("เกจบล็อกขั้นต่ำ", "BlockMinEnergy", 0, 40, 2, F.n, "เกจบล็อกต่ำกว่านี้ → ไม่บล็อก (กันเกจแตกแล้วสตัน)")
		stepRow("เลือดขั้นต่ำอัลติ (%)", "UltMinHP", 0, 80, 5, F.n, "เลือดเราต่ำกว่านี้ → เก็บอัลติไว้ยกถัดไป (กันเสียเปล่าตอนใกล้ตาย)")
		btnRow("↺ คืนค่าปรับทั้งหมด", nil, function()
			for _, k in ipairs(TUNE) do cfg[k] = DEF[k] end
			saveCfg()
			paintAll()
			if flash then flash("คืนค่าปรับเป็นค่าเริ่มต้นแล้ว", C.warm) end
		end, "คืนค่าทุกตัวในหมวดนี้กลับค่าแนะนำของฮับ")
	end
	secHead("สถานะสด", "live")
	do
		local tc = V9.mkCard(102)
		UI.tgtName = mk("TextLabel", tc, { Size = UDim2.new(1, -16, 0, 18), Position = UDim2.new(0, 8, 0, 5), BackgroundTransparency = 1,
			Text = "ยังไม่ล็อกเป้าหมาย", Font = F_TH, TextSize = 14, TextColor3 = C.txt, TextXAlignment = LEFT })
		UI.tgtFlags = mk("TextLabel", tc, { Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 8, 0, 27), BackgroundTransparency = 1,
			Text = "", Font = F_TX, TextSize = 13, TextColor3 = C.dim, TextXAlignment = LEFT })
		UI.setTHP = V9.mkBar(tc, 56, "เลือด", C.hp)
		UI.setTST = V9.mkBar(tc, 76, "สตามิน่า", C.st)
		local mc = V9.mkCard(98)
		mk("TextLabel", mc, { Size = UDim2.new(1, -16, 0, 16), Position = UDim2.new(0, 8, 0, 3), BackgroundTransparency = 1,
			Text = "ตัวเรา", Font = F_TH, TextSize = 14, TextColor3 = C.acc2, TextXAlignment = LEFT })
		UI.setMHP = V9.mkBar(mc, 28, "เลือด", C.on)
		UI.setMPD = V9.mkBar(mc, 50, "เกจ PD", C.pd)
		UI.setMULT = V9.mkBar(mc, 72, "อัลติ", C.ult)
		UI.noteLbl = addItem(mk("TextLabel", scroll, { Size = UDim2.new(0, LAY.w, 0, 34), BackgroundColor3 = C.hot,
			Visible = false, Text = "", Font = F_TX, TextSize = 13, TextColor3 = C.warm, TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = LEFT }, 7), 34)
		local pad = Instance.new("UIPadding", UI.noteLbl)
		pad.PaddingLeft = UDim.new(0, 8) pad.PaddingRight = UDim.new(0, 8) pad.PaddingTop = UDim.new(0, 5) pad.PaddingBottom = UDim.new(0, 5)
		UI.statLbl = addItem(reg(mk("TextLabel", scroll, { Size = UDim2.new(0, LAY.w, 0, 40), BackgroundColor3 = C.row,
			Text = "", Font = F_TH, TextSize = 14, TextColor3 = C.txt, RichText = true }, 6)), 40)
	end
	for _, g in ipairs(groups) do g.paint(false) end
	reflow(false)
	paintAll()
end

-- เปิด/ปิด (เลื่อนขึ้นจากล่าง + เด้งนิด; ถ้าลากไว้แล้วกลับมาที่เดิม + จำตำแหน่ง)
local function savedPanelPos()
	-- ค่าเซฟใช้คีย์ใหม่ PanelPosB (anchor ล่าง-กลาง) — ค่าเก่า anchor ขวา-กลาง ถูกทิ้งใน loadCfg
	if type(cfg.PanelPosB) ~= "table" then return nil end
	local p = UDim2.new(unpack(cfg.PanelPosB))
	-- กันตำแหน่งเซฟลอยออกนอกจอ (anchor ใหม่: จุดอ้าง = ขอบล่างของ panel)
	local ok, vp = pcall(function() return WS.CurrentCamera.ViewportSize end)
	if ok and vp then
		local by = p.Y.Scale * vp.Y + p.Y.Offset
		if by < vp.Y * 0.35 or by > vp.Y + 40 then return nil end
	end
	return p
end
local function setOpen(v)
	STATE.open = v
	if UI.posTween then UI.posTween:Cancel() UI.posTween = nil end
	if v then
		panel.Visible = true
		pill.Visible = false
		local target = savedPanelPos() or (STATE.movedPanel and panel.Position or DOCK)
		UI.pScale.Scale = 0.92
		TW:Create(UI.pScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		UI.posTween = TW:Create(panel, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = target })
		UI.posTween:Play()
		pcall(function() UI.scroll.CanvasPosition = Vector2.new(0, 0) end)
	else
		pill.Visible = true
		tw(UI.pScale, { Scale = 0.95 }, 0.16)
		UI.posTween = TW:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = OFFR })
		UI.posTween:Play()
		task.delay(0.2, function() if not STATE.open then panel.Visible = false end end)
	end
end
draggable(pill, pill, {
	click = function() setOpen(true) end,
	moved = function()
		cfg.PillPos = { pill.Position.X.Scale, pill.Position.X.Offset, pill.Position.Y.Scale, pill.Position.Y.Offset }
		saveCfg()
	end,
})
draggable(head, panel, {
	dragStart = function() if UI.posTween then UI.posTween:Cancel() UI.posTween = nil end end,
	moved = function()
		STATE.movedPanel = true
		cfg.PanelPosB = { panel.Position.X.Scale, panel.Position.X.Offset, panel.Position.Y.Scale, panel.Position.Y.Offset }
		saveCfg()
	end,
})
closeB.MouseButton1Click:Connect(function() setOpen(false) end)

-- ปุ่มลัด: M/RightAlt = เมนู, K = สวิตช์หลักด่วน
conns[#conns + 1] = UIS.InputBegan:Connect(function(io, gpe)
	if gpe then return end
	if io.KeyCode == Enum.KeyCode.RightAlt or io.KeyCode == Enum.KeyCode.M then
		setOpen(not STATE.open)
	elseif io.KeyCode == Enum.KeyCode.K then
		cfg.Enabled = not cfg.Enabled
		saveCfg()
		paintAll()
		paintPill()
		if not cfg.Enabled then dropAllBlocks() end
		if flash then flash(cfg.Enabled and "HZ HUB: เปิดระบบ" or "HZ HUB: ปิดระบบ",
			cfg.Enabled and C.on or C.acc) end
	end
end)

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
	STATE.flashUntil = tick() + 1
end

-- loop อัปเดตสถานะสด + แถบเลือด + HUD ศัตรู (0.25s)
task.spawn(function()
	local WHY_TH = {
		["master-off"] = "ปิดระบบอยู่", ["no-states"] = "รอข้อมูลเกม", safezone = "อยู่เซฟโซน", spectating = "โหมดดู",
		cutscene = "กำลังคัตซีน", ["pvp-off"] = "PvP ปิด", ["match-not-started"] = "รอแมตช์เริ่ม",
	}
	local placeTag = game.PlaceId == MAIN_PLACE and "" or (game.PlaceId == 14397772816 and "  •  RANKED" or ("  •  " .. tostring(game.PlaceId)))
	local pdMaxSeen, lastCol, noteVis = 1, nil, false
	local function frac(v, mx)
		if not (v and type(v.Value) == "number") then return 0, "--" end
		local m = mx and mx.Value
		if type(m) == "number" and m > 0 then
			return v.Value / m, string.format("%d/%d", math.floor(v.Value + 0.5), math.floor(m + 0.5))
		end
		return v.Value / 100, tostring(math.floor(v.Value + 0.5))
	end
	while not KILL do
		local ok, e = pcall(function()
		if tick() > STATE.flashUntil then flashLbl.Text = "" end
		local setT = UI.setT
		local lk = opponentOf()
		-- หัวเมนู + pill: เขียว = พร้อมสู้ / เหลือง = รอ (แมตช์ยังไม่เริ่ม ฯลฯ) / แดง = ปิดระบบ
		local why = combatWhy()
		local col = (why == "master-off") and C.acc or (why and C.warm or C.on)
		if col ~= lastCol then
			lastCol = col
			UI.stDot.BackgroundColor3 = col
			UI.stTxt.TextColor3 = col
			pillDot.BackgroundColor3 = col
		end
		setT(UI.stTxt, (why and (WHY_TH[why] or why) or "พร้อมสู้") .. placeTag)
		setT(UI.stMini, string.format("หลบ %d · บล็อก %d · สวน %d", STATE.pdCount, STATE.blockCount, STATE.punishCount))
		-- การ์ดเป้าหมาย
		if lk and lk.Parent then
			local o, c, p = statesOf(lk.Name)
			local st = p and p:FindFirstChild("Style")
			local stam = c and c:FindFirstChild("Stamina")
			local hp = c and c:FindFirstChild("Health")
			local flag = {}
			if o and o:FindFirstChild("Punching") and o.Punching.Value then flag[#flag + 1] = "กำลังต่อย!" end
			if o and o:FindFirstChild("Blocking") and o.Blocking.Value then flag[#flag + 1] = "บล็อก" end
			if o and o:FindFirstChild("Dashing") and o.Dashing.Value then flag[#flag + 1] = "แดช" end
			if c and c:FindFirstChild("Stunned") and c.Stunned.Value then flag[#flag + 1] = "สตัน" end
			local sname = st and tostring(st.Value) or ""
			setT(UI.tgtName, sname ~= "" and (lk.Name .. "  •  " .. sname) or lk.Name)
			-- brain: เตือนภัยศัตรูจาก state จริง (อัลติ/หมดแรง/ใกล้ตาย)
			local L = ensureLearn(lk)
			local ue = enemyField(lk, "UltimateEnergy")
			if ue and ue >= 85 and not L.warnUlt then
				L.warnUlt = true
				if cfg.EnemyHUD then flash("ศัตรูอัลติเกือบพร้อม! ระวัง", Color3.fromRGB(255, 80, 255)) end
			elseif ue and ue < 50 then L.warnUlt = nil end
			if stam and stam.Value <= 20 and not L.warnStam then
				L.warnStam = true
				if cfg.EnemyHUD then flash("ศัตรูใกล้หมดแรง! บุกได้", Color3.fromRGB(255, 210, 120)) end
			elseif stam and stam.Value > 35 then L.warnStam = nil end
			if hp and hp.Value <= 18 and not L.warnHP then
				L.warnHP = true
				if cfg.EnemyHUD then flash("เป้าเหลือน้อย! ปิดเกมเลย", Color3.fromRGB(120, 255, 160)) end
			elseif hp and hp.Value > 30 then L.warnHP = nil end
			-- โชว์ % เฟนต์ที่เรียนรู้ได้ (ดูสายล่อ)
			local fr = feintRate(lk)
			setT(UI.tgtFlags, (#flag > 0 and table.concat(flag, " • ") or "ปกติ")
				.. (fr >= 0.15 and string.format("  •  เฟนต์ %d%%", math.floor(fr * 100 + 0.5)) or ""))
			UI.setTHP(frac(hp, c and c:FindFirstChild("MaxHealth")))
			UI.setTST(frac(stam, c and c:FindFirstChild("MaxStamina")))
			-- BillboardGui เหนือหัว
			if cfg.EnemyHUD then
				local hd = lk:FindFirstChild("Head") or lk:FindFirstChild("HumanoidRootPart")
				if hd then
					enemyTag.Adornee = hd
					enemyTag.Enabled = true
					-- v6: เพิ่ม BlockEnergy/อัลติ/เกจพิเศษ (Focus ฯลฯ) บนป้ายเหนือหัว
					local ebe = enemyField(lk, "BlockEnergy")
					local eue = enemyField(lk, "UltimateEnergy")
					local eab = enemyField(lk, "AbilityEnergy")
					local mch = enemyField(lk, "MeterCharge")
					local extra = ""
					if type(ebe) == "number" and enemyBlocking(lk) then extra = " BL" .. math.floor(ebe) end
					if type(eue) == "number" and eue >= 60 then extra = extra .. " ⚡" .. math.floor(eue) end
					if type(eab) == "number" and eab >= 60 then extra = extra .. " 🌀" .. math.floor(eab) end
					if type(mch) == "number" and mch > 0 then extra = extra .. " 📊" .. math.floor(mch) end
					setT(tagLbl, string.format("%s  %s\nHP %s • ST %s%s",
						lk.Name, (st and st.Value) or "",
						hp and tostring(math.floor(hp.Value)) or "?",
						stam and tostring(math.floor(stam.Value)) or "?", extra))
				else
					enemyTag.Enabled = false
				end
			else
				enemyTag.Enabled = false
			end
		else
			setT(UI.tgtName, "ยังไม่ล็อกเป้าหมาย")
			setT(UI.tgtFlags, "ถูกชก/เข้าใกล้ศัตรู → ฮับล็อกให้เอง")
			UI.setTHP(0, "--")
			UI.setTST(0, "--")
			enemyTag.Enabled = false
		end
		-- การ์ดตัวเรา
		if myCharData then
			local hp = myCharData:FindFirstChild("Health")
			local pd = myCharData:FindFirstChild("PerfectDodgeMeter")
			local ult = myCharData:FindFirstChild("UltimateEnergy")
			-- แจ้งอัลติพร้อมครั้งเดียว (รีเซ็ตเมื่อเกจต่ำ)
			if ult and ult.Value >= 100 and not STATE.ultReadyWarned then
				STATE.ultReadyWarned = true
				if cfg.EnemyHUD then flash("อัลติพร้อม! รอจังหวะปล่อย", Color3.fromRGB(255, 80, 255)) end
			elseif ult and ult.Value < 80 then STATE.ultReadyWarned = nil end
			-- v6: เตือน AbilityEnergy เต็ม (Chronos Focus / เกจสไตล์อื่น)
			local ae = myCharData:FindFirstChild("AbilityEnergy")
			if ae and type(ae.Value) == "number" then
				if ae.Value >= 100 and not STATE.abiReadyWarned then
					STATE.abiReadyWarned = true
					if cfg.EnemyHUD then flash("เกจพิเศษเต็ม! ใช้สกิลได้", Color3.fromRGB(120, 220, 255)) end
				elseif ae.Value < 60 then STATE.abiReadyWarned = nil end
			end
			UI.setMHP(frac(hp, myCharData:FindFirstChild("MaxHealth")))
			if pd and type(pd.Value) == "number" then
				pdMaxSeen = math.max(pdMaxSeen, pd.Value)
				UI.setMPD(pd.Value / pdMaxSeen, tostring(math.floor(pd.Value + 0.5)))
			else
				UI.setMPD(0, "--")
			end
			if ult and type(ult.Value) == "number" then
				UI.setMULT(ult.Value / 100, tostring(math.floor(ult.Value + 0.5)))
			else
				UI.setMULT(0, "--")
			end
		else
			UI.setMHP(0, "--")
			UI.setMPD(0, "--")
			UI.setMULT(0, "--")
		end
		-- หมายเหตุสำคัญ (เพอร์เฟกต์ต้องล็อกเป้า / ฮับกำลังรออะไร)
		local note
		if cfg.AutoPD and not cfg.AutoLock and not lockedOn() then
			note = "⚠ เพอร์เฟกต์ต้องล็อกเป้า: เปิด 'ล็อกออนอัตโนมัติ' หรือกดล็อกเอง"
		elseif why and why ~= "master-off" then
			note = "⏸ ฮับรอ: " .. (WHY_TH[why] or why)
		end
		setT(UI.noteLbl, note or "")
		if (note ~= nil) ~= noteVis then
			noteVis = note ~= nil
			UI.noteLbl.Visible = noteVis
			UI.reflow(true) -- ปรับเลย์เอาต์ตาม noteLbl ที่เพิ่งโชว์/ซ่อน (กันช่องว่างดำค้าง)
		end
		setT(UI.statLbl, string.format("หลบ <b>%d</b> • บล็อก <b>%d</b> • สวน <b>%d</b> • โดนเรา <b>%d</b>\nเฟนต์เจอ <b>%d</b> • แดชเสีย <b>%d</b>",
			STATE.pdCount, STATE.blockCount, STATE.punishCount, STATE.hitCount, STATE.feintCount, STATE.foolishCount))
		end)
		if not ok then warn("[HZ UBG stat] " .. tostring(e)) end
		task.wait(0.25)
	end
end)

-- ===== character (re)bind =====
local charConns = {} -- conns ผูกกับตัวละครปัจจุบัน — เคลียร์ทุก rebind กันสะสมข้ามเกิด
-- hookStates: ผูก listener บน state child ของเราที่ยังไม่ครบ — ถูกเรียกซ้ำจาก maintenance + defer loop
-- แก้จุดตายเดิม: listener ผูกครั้งเดียวตอน bind → ถ้า child มาช้ากว่า spawn (ranked intro) = พลาดทั้งชีวิต
hookStates = function()
	if KILL or not myChar then return end
	-- หมัดเราจบ: ประเมิน panic ใหม่ + chain หมัดต่อทันที (0ms — ไม่รอลูป 0.07s)
	do
		local p = myOcc and myOcc:FindFirstChild("Punching")
		if p and MAPS.stHook.p ~= p then
			MAPS.stHook.p = p
			charConns[#charConns + 1] = p.Changed:Connect(function(v)
				if v ~= false or KILL or not inCombat() then return end
				m1Strike(lockedOn() or opponentOf()) -- chain ต่อทันทีที่เกมปลดล็อก (เกทใน m1Strike)
				if not cfg.PanicBlock then return end
				for c in pairs(MAPS.watchedAtk) do
					-- เฟนต์ = อย่าบล็อก (packet เฟนต์ตั้ง mark ไว้แล้ว — เหมือน guard ใน watchAttacker)
					if aliveInLive(c) and not (MAPS.feintMark[c] and tick() - MAPS.feintMark[c] < 0.5) then
						local o = select(1, statesOf(c.Name))
						local pw = o and o:FindFirstChild("Punching")
						local aimed = aimedAtUs(c) or distTo(c) < 7
						if pw and pw.Value and aimed and distTo(c) <= reactRangeOf(c) and blockEnergyOK() then
							holdBlock("panic:" .. c.Name, true, c)
						end
					end
				end
			end)
		end
	end
	-- CanPunch กลับมา = เกมยอมชกแล้ว → chain ต่อ 0ms (ครอบเคส Punching ปลดก่อน debounce หมด)
	do
		local cp = myOcc and myOcc:FindFirstChild("CanPunch")
		if cp and MAPS.stHook.cp ~= cp then
			MAPS.stHook.cp = cp
			charConns[#charConns + 1] = cp.Changed:Connect(function(v)
				if v ~= true or KILL or not inCombat() then return end
				m1Strike(lockedOn() or opponentOf())
			end)
		end
	end
	-- สตันหมด = สวนทันที (ไม่ยืนนิ่งรอลูป — โดนต่อยจบคอมโบแล้วตอบโต้ก่อนมันเริ่มชุดใหม่)
	do
		local st = myOcc and myOcc:FindFirstChild("Stunned")
		if st and MAPS.stHook.stn ~= st then
			MAPS.stHook.stn = st
			charConns[#charConns + 1] = st.Changed:Connect(function(v)
				if v ~= false or KILL or not inCombat() then return end
				m1Strike(lockedOn() or opponentOf())
			end)
		end
	end
	-- ปล่อยบล็อก = สวนทันที (counter หลังกัน — ไม่รอ releaseLater+0.06/ลูป)
	do
		local bl = myOcc and myOcc:FindFirstChild("Blocking")
		if bl and MAPS.stHook.blk ~= bl then
			MAPS.stHook.blk = bl
			charConns[#charConns + 1] = bl.Changed:Connect(function(v)
				if v ~= false or KILL or not inCombat() then return end
				m1Strike(lockedOn() or opponentOf())
			end)
		end
	end
	-- แดชจบ = ต่อยต่อทันที (post-dash window/engage — ไม่รอลูป)
	do
		local ds = myOcc and myOcc:FindFirstChild("Dashing")
		if ds and MAPS.stHook.dsh ~= ds then
			MAPS.stHook.dsh = ds
			charConns[#charConns + 1] = ds.Changed:Connect(function(v)
				if v ~= false or KILL or not inCombat() then return end
				m1Strike(lockedOn() or opponentOf())
			end)
		end
	end
	-- เซิร์ฟตั้ง Opponent ตอนเริ่มแมตช์/ดวล → ล็อกทันที (ไม่รอ maintenance tick)
	do
		local opv = myCharData and myCharData:FindFirstChild("Opponent")
		if opv and MAPS.stHook.opv ~= opv then
			MAPS.stHook.opv = opv
			charConns[#charConns + 1] = opv.Changed:Connect(function() preLockOpponent("opponent-set") end)
			preLockOpponent("bind")
		end
	end
	-- ไดอากนอส: เกจอัลติเราขึ้น 100 → log + แจ้ง (จะได้รู้ว่าอัลติไม่ยิงเพราะเกจไม่เต็ม หรือจังหวะไม่มา)
	do
		local ue = myCharData and myCharData:FindFirstChild("UltimateEnergy")
		if ue and MAPS.stHook.ue ~= ue then
			MAPS.stHook.ue = ue
			local ueReady = ue.Value >= 100
			charConns[#charConns + 1] = ue.Changed:Connect(function(v)
				if type(v) ~= "number" then return end
				if v >= 100 and not ueReady then
					ueReady = true
					evlog("ULT ready (energy 100)")
					if cfg.EnemyHUD then flash("อัลติพร้อม!", Color3.fromRGB(255, 80, 255)) end
				elseif v < 100 then ueReady = false end
			end)
		end
	end
	-- เกจบล็อกเราใกล้หมดขณะถืออยู่ → ปล่อยเองก่อนแตก: แตก = BlockBroken สตัน ~1.7s กินคอมโบเต็ม (ต้นตอแพ้ใน log จริง)
	do
		local be = myCharData and myCharData:FindFirstChild("BlockEnergy")
		if be and MAPS.stHook.be ~= be then
			MAPS.stHook.be = be
			charConns[#charConns + 1] = be.Changed:Connect(function(v)
				if KILL or not cfg.Enabled or type(v) ~= "number" then return end
				-- floor สูงขึ้นตอนหมัดบินมา (เหมือน blockEnergyOK): ปล่อยบล็อกก่อนลูกที่จะทำให้แตก — กินหมัดดิบแต่เก็บแดชได้
				if v < cfg.BlockMinEnergy + (tick() < STATE.inboundUntil and 16 or 0) and stV(myOcc, "Blocking") then
					dropAllBlocks()
					evlog("block drop (low energy " .. math.floor(v) .. ")")
				end
			end)
		end
	end
end
bindChar = function(char)
	for _, c in ipairs(charConns) do pcall(function() c:Disconnect() end) end
	table.clear(charConns)
	myChar = char
	evlog("bindChar " .. (char and char.Name or "nil"))
	myStates()
	table.clear(MAPS.feintMark)
	table.clear(MAPS.threatMark)
	for c in pairs(MAPS.watchedAtk) do dropWatch(c) end
	dropAllBlocks()
	MAPS.stHook = {}
	if char then
		charConns[#charConns + 1] = char:GetAttributeChangedSignal("Perfect"):Connect(onPerfectWindow)
		-- FoolishDodge = แดชเร็วเกิน (ระบบเกมลงโทษ) → นับไว้ดูว่า lead ช้ำไหม
		charConns[#charConns + 1] = char:GetAttributeChangedSignal("FoolishDodge"):Connect(function()
			if char:GetAttribute("FoolishDodge") then STATE.foolishCount += 1 end
		end)
		-- เซิร์ฟยืนยันเพอร์เฟกต์จริง: LastPerfectDodged = timestamp ของ PD ที่ server รับ (deimos2_16)
		-- เทียบ pd (นับตอนเรายิงแดช) vs pdc (server ยืนยัน) → เห็นแดชที่พลาด/โดน deny จริง
		charConns[#charConns + 1] = char:GetAttributeChangedSignal("LastPerfectDodged"):Connect(function()
			if type(char:GetAttribute("LastPerfectDodged")) == "number" then
				STATE.pdConfirm += 1
				evlog("PD CONFIRM server")
			end
		end)
		-- เราติด SlowMo = โดนศัตรูเพอร์เฟกต์หลบหมัดเรา (โลกช้า = เป้าสวนฟรี) → ตั้งบล็อกรับทันที
		-- (PUNCH_DENY มี SlowMo แล้ว → m1Strike/ชกปกติถูก deny เอง ไม่เสียสตามิน่า)
		charConns[#charConns + 1] = char:GetAttributeChangedSignal("SlowMo"):Connect(function()
			if KILL or not char:GetAttribute("SlowMo") or not inCombat() then return end
			evlog("got-PD'd (SlowMo) -> brace block")
			local lk = opponentOf()
			if lk and lk.Parent and distTo(lk) < 12 then panicBlockOn(lk, "got-PD brace") end
		end)
		-- อัลติเราจบ = คัตซีนปลดล็อก → ต่อยต่อ 0ms (ระหว่างอัลติเราชกไม่ได้อยู่แล้ว)
		charConns[#charConns + 1] = char:GetAttributeChangedSignal("PerformingUltimate"):Connect(function()
			if KILL or char:GetAttribute("PerformingUltimate") or not inCombat() then return end
			m1Strike(opponentOf())
		end)
		hookStates() -- ผูกเท่าที่มีตอนนี้ก่อน
		-- poll ต่อจน listener ครบ (States มาช้ากว่า spawn ได้ — maintenance เรียก hookStates ซ้ำเป็นเครือข่ายนิรภัย)
		task.defer(function()
			for _ = 1, 30 do
				if KILL or myChar ~= char or (MAPS.stHook.p and MAPS.stHook.opv and MAPS.stHook.ue and MAPS.stHook.cp and MAPS.stHook.stn and MAPS.stHook.dsh) then return end
				myStates()
				hookStates()
				task.wait(0.1)
			end
		end)
	end
end
conns[#conns + 1] = LP.CharacterAdded:Connect(function(c)
	task.wait(0.5)
	bindChar(c)
end)
-- ไม่บล็อกรอตัวละคร (ranked อาจเกิดช้าหลัง intro) — CharacterAdded ด้านบนจะ bind ให้เองตอนเกิด; status ต้องขึ้นทันที
if LP.Character then bindChar(LP.Character) end

-- ===== v9: ฟีเจอร์ใหม่ =====
-- ใส่นวมให้ตัวเองเห็น (local-only — server ไม่เห็น คนอื่นไม่เห็น)
function V9.visualGloves(name, unusual)
	local _, _, pd = statesOf(LP.Name)
	local g = pd and pd:FindFirstChild("Gloves")
	if not g then return "no-gloves-value" end
	local v = tostring(name or cfg.VisualGloveName or "")
	local u = tostring(unusual or cfg.VisualUnusual or "")
	if u ~= "" then v = v .. "_" .. u end
	local ok, err = pcall(function() g.Value = v .. "|" .. v end)
	return ok and ("visual:" .. v) or ("fail:" .. tostring(err))
end
if cfg.VisualGloves then
	task.delay(4, function()
		local r = V9.visualGloves(cfg.VisualGloveName, cfg.VisualUnusual)
		if type(r) == "string" and r:sub(1,5) == "fail" then evlog("visualGloves " .. r) end
	end)
end
local function autoEconomy()
	if not (cfg.AutoClaimDaily or cfg.AutoFreeEmote or cfg.AutoSpin or cfg.AutoQueue) then return end
	local ok, B = pcall(function() return require(game:GetService("ReplicatedFirst"):WaitForChild("BridgeNet2")) end)
	if not (ok and B) then return end
	local function br(n, a)
		local ok2, b = pcall(function() return B.ReferenceBridge(n) end)
		if ok2 and b then pcall(function() b:Fire(a) end) end
	end
	if cfg.AutoClaimDaily then task.spawn(function() while not KILL do br("ClaimDaily", false) task.wait(60) end end) end
	if cfg.AutoFreeEmote then task.spawn(function() while not KILL do br("GetFreeEmote", false) task.wait(90) end end) end
	if cfg.AutoSpin then task.spawn(function() while not KILL do br("TrySpin") task.wait(300) end end) end
	if cfg.AutoQueue then
		task.spawn(function()
			while not KILL do
				if game.PlaceId ~= MAIN_PLACE and WS:GetAttribute("MatchStarted") == false and tick() > STATE.gateUntil + 20 then
					br("JoinMatchmakingQueue", false) task.wait(15)
				else task.wait(3) end
			end
		end)
	end
end
task.delay(6, autoEconomy)

-- รอบที่ตายแล้วห้ามทับ _G.HZUBG ของรอบใหม่ (ไม่งั้น kill รอบหน้าหาไม่เจอ = ผี)
if KILL or _G.HZUbgGen ~= gen then return end

-- kill registry (re-run safe)
_G.HZUBG = {
	kill = function()
		KILL = true
		for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
		for _, c in ipairs(charConns) do pcall(function() c:Disconnect() end) end
		for c in pairs(MAPS.watchedAtk) do dropWatch(c) end
		dropAllBlocks()
		pcall(function() gui:Destroy() end)
		pcall(killStaleGui) -- เผื่อมี GUI ผีของอินสแตนซ์อื่นค้าง
	end,
	cfg = cfg,
	stats = function()
		return { pd = STATE.pdCount, blk = STATE.blockCount, pun = STATE.punishCount, feint = STATE.feintCount, hit = STATE.hitCount, fool = STATE.foolishCount }
	end,
	log = function() return table.concat(MAPS.EVLOG, "\n") end,
	gloves = function(n, u) return V9.visualGloves(n, u) end,
	psv = V9.psv,
	pdWindow = V9.pdWindow,
	freeDash = V9.freeDashActive,
}

-- ===== status/log writer: บอกทุก 2 วิว่าฮับ "สู้ได้ไหม" และถ้าไม่ได้เพราะอะไร (why=...) =====
local function statusLine()
	local op, lk = opponentOf(), lockedOn()
	local ue = myCharData and myCharData:FindFirstChild("UltimateEnergy")
	return string.format("ARMED place=%d t=%s why=%s MS=%s me=%s opp=%s lock=%s eq=%s states=%s live=%s ue=%s | pd=%d pdc=%d blk=%d pun=%d feint=%d hit=%d fool=%d | v8.1",
		game.PlaceId, os.date("%X"), tostring(combatWhy() or "ready"), tostring(WS:GetAttribute("MatchStarted")),
		tostring(myStyle() or "?"),
		op and (op.Name .. "(" .. tostring(styleOf(op) or "?") .. ")") or "nil", lk and lk.Name or "nil", tostring(equipped()),
		tostring(myOcc ~= nil and myCharData ~= nil), tostring(V9.liveLive() ~= nil),
		ue and tostring(math.floor(ue.Value)) or "nil",
		STATE.pdCount, STATE.pdConfirm, STATE.blockCount, STATE.punishCount, STATE.feintCount, STATE.hitCount, STATE.foolishCount)
		.. " ping=" .. math.floor(serverPing() * 1000 + 0.5)
		.. " pdWin=" .. string.format("%.3f", V9.pdWindow())
		.. (WS:FindFirstChild("PrivateServerSettings") and " [PS+]" or "")
		.. (V9.freeDashActive() and " [FREE]" or "")
		.. (myChar and myChar:GetAttribute("ActiveNPC") and " [NPC]" or "")
		.. " | v9.0"
end
task.spawn(function()
	while not KILL do
		local ok, e = pcall(function()
			writefile("hz_ubg_status.txt", statusLine())
			if STATE.evDirty then
				STATE.evDirty = false
				writefile("hz_ubg_log.txt", table.concat(MAPS.EVLOG, "\n"))
			end
		end)
		if not ok and not KILL then warn("[HZ UBG status] " .. tostring(e)) end
		task.wait(2)
	end
end)

print("[HZ UBG v9.0] loaded — place " .. tostring(game.PlaceId) .. ". M/RightAlt = menu, K = master toggle. status: hz_ubg_status.txt / hz_ubg_log.txt")
end)
if not __ok then
	warn("[HZ UBG] " .. tostring(__err))
	pcall(writefile, "hz_ubg_status.txt", "ERROR place=" .. tostring(game.PlaceId) .. " " .. tostring(__err))
end
