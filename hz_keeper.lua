-- ============================================================================
-- hz_keeper.lua — Persistent Session Controller (client-side, autoexec)
--  1) disconnect/error interception → backoff → TeleportService:Teleport(PLACE)
--  2) match-state watch (RunState/InMatch) → กลับ Lobby → requeue ผ่านเกมเอง
--  3) AFK guard — VirtualUser click ทุก ~150s (jittered)
--  4) heartbeat + state file → ให้ sentinel ฝั่ง host อ่าน
-- kill-switch: _G.HZKEEPER.stop()
-- ============================================================================
local PLACE = 107535308163741
local HB_FILE = "hz_keeper_heartbeat.txt"
local ST_FILE = "hz_keeper_state.json"
local MAX_REJOIN = 5
local COOLDOWN_S = 30
local HB_EVERY = 30
local AFK_MIN, AFK_MAX = 120, 180

local Http = game:GetService("HttpService")
local Gui = game:GetService("GuiService")
local TS  = game:GetService("TeleportService")
local PLR = game:GetService("Players")
local VU  = game:GetService("VirtualUser")
local CS  = game:GetService("CollectionService")
local CG  = game:GetService("CoreGui")
local RS  = game:GetService("ReplicatedStorage")

local function sc(fn) local ok, v = pcall(fn) return ok and v or nil end
local function logf(msg)
	local s = os.date("%X") .. " " .. tostring(msg)
	pcall(function() print("[KEEPER] " .. s) end)
	pcall(appendfile or writefile, "hz_keeper_log.txt",
		(appendfile and s .. "\n" or s))
end
local function hb()
	pcall(writefile, HB_FILE, tostring(tick()))
end
local function saveState(extra)
	local st = {place = sc(function() return game.PlaceId end),
		job = sc(function() return game.JobId end),
		user = sc(function() return PLR.LocalPlayer and PLR.LocalPlayer.Name end),
		ts = os.time()}
	if extra then for k, v in pairs(extra) do st[k] = v end end
	pcall(writefile, ST_FILE, Http:JSONEncode(st))
end

-- rejoin counter persisted (ครั้งติดต่อกัน) — เกิน MAX_REJOIN → พัก COOLDOWN_S
local function loadCounter()
	local s = sc(function() return Http:JSONDecode(readfile(ST_FILE)) end)
	return (s and s.rejoins) or 0
end
local function teleportRejoin(why)
	local n = loadCounter() + 1
	saveState({rejoins = n, lastWhy = why})
	if n > MAX_REJOIN then
		logf("rejoin cap hit (" .. n .. ") — cooldown " .. COOLDOWN_S .. "s")
		task.wait(COOLDOWN_S)
		saveState({rejoins = 0})
	end
	-- exponential backoff 3-5s
	local wait_s = math.min(3 + (n - 1), 5) + math.random()
	logf("teleport rejoin #" .. n .. " why=" .. tostring(why) .. " in " .. wait_s .. "s")
	task.wait(wait_s)
	sc(function() return TS:Teleport(PLACE, PLR.LocalPlayer) end)
end

-- wait real place (menu attach = place 0)
local t0 = tick()
while game.PlaceId ~= PLACE and tick() - t0 < 300 do task.wait(1) end
if game.PlaceId ~= PLACE then logf("wrong place " .. game.PlaceId .. " — abort") return end
logf("armed — place " .. PLACE)
saveState({rejoins = 0})
hb()

-- kill-switch / single instance
if _G.HZKEEPER and _G.HZKEEPER.alive then
	_G.HZKEEPER.stop()
	task.wait(0.5)
end
local K = {alive = true}
_G.HZKEEPER = K
function K.stop() K.alive = false end

-- ---- [1] disconnect / error interception --------------------------------------------
local ERR_PAT = {"277", "279", "268", "disconnect", "lost", "kick", "timed out", "teleport"}
local function looksErr(txt)
	txt = tostring(txt):lower()
	for _, p in ipairs(ERR_PAT) do if txt:find(p, 1, true) then return true end end
	return false
end
sc(function()
	Gui.ErrorMessageChanged:Connect(function(msg)
		if not K.alive then return end
		if msg and msg ~= "" and looksErr(msg) then
			logf("ErrorMessageChanged: " .. tostring(msg))
			teleportRejoin("gui-error")
		end
	end)
end)
-- CoreGui error prompt fallback — สแกน prompt ที่เกิดใหม่
sc(function()
	local rg = CG:FindFirstChild("RobloxPromptGui") or CG:WaitForChild("RobloxPromptGui", 5)
	if rg then
		rg.DescendantAdded:Connect(function(d)
			if not K.alive then return end
			if d:IsA("TextLabel") and looksErr(d.Text) then
				task.delay(1.5, function()
					if K.alive then teleportRejoin("prompt:" .. d.Text:sub(1, 40)) end
				end)
			end
		end)
	end
end)

-- ---- [2] match-state watch → requeue -------------------------------------------------
local GameAction = RS:WaitForChild("ChickenOrHero", 10)
	and RS.ChickenOrHero:WaitForChild("Game", 10)
	and RS.ChickenOrHero.Game:FindFirstChild("GameAction")
local function requeue()
	-- ทาง 1: proximity prompts ที่เกม tag ไว้ (JoinEventPrompt/Interactable) — ช่องทางเกมเอง
	local fired = false
	for _, p in ipairs(game:GetDescendants()) do
		if p:IsA("ProximityPrompt") then
			local tg = CS:GetTags(p)
			local tagged = false
			for _, t in ipairs(tg) do
				if t:find("Join") or t:find("Interact") then tagged = true break end
			end
			local anc = p.Parent
			while anc and not tagged do
				for _, t in ipairs(CS:GetTags(anc)) do
					if t:find("Join") or t:find("Interact") then tagged = true break end
				end
				anc = tagged and anc or anc.Parent
				if not anc then break end
			end
			if tagged and fireproximityprompt then
				sc(function() fireproximityprompt(p) end)
				fired = true
				logf("requeue via prompt: " .. p:GetFullName())
			end
		end
	end
	-- ทาง 2: GameAction remote (ถ้ามี) — best-effort ไม่รู้ args ชัวร์
	if not fired and GameAction then
		sc(function() GameAction:FireServer("JoinMatch") end)
		logf("requeue via GameAction remote")
	end
	if not fired then logf("requeue: no channel found") end
end

local LP = PLR.LocalPlayer
local lastRole, lastInMatch = nil, nil
local function watchAttr(name)
	sc(function()
		LP:GetAttributeChangedSignal(name):Connect(function()
			if not K.alive then return end
			local v = sc(function() return LP:GetAttribute(name) end)
			logf("attr " .. name .. " -> " .. tostring(v))
			saveState({[name] = v})
			if name == "RunState" and (v == "Lobby" or v == "End") and lastRole ~= v then
				lastRole = v
				task.delay(4, function() if K.alive then requeue() end end)
			else
				lastRole = v
			end
			if name == "InMatch" and v == false and lastInMatch ~= false then
				lastInMatch = false
				task.delay(4, function() if K.alive then requeue() end end)
			elseif name == "InMatch" then
				lastInMatch = v
			end
		end)
	end)
end
if LP then watchAttr("RunState"); watchAttr("InMatch"); watchAttr("GameRole") end

-- ---- [3] AFK guard ---------------------------------------------------------------------
task.spawn(function()
	-- เชื่อม Idled signal ด้วย (ช่องทางทางการของเกมกันแอฟเค)
	sc(function()
		LP.Idled:Connect(function()
			if K.alive then
				sc(function() VU:CaptureController() end)
				sc(function() VU:ClickButton2(Vector2.new()) end)
				logf("Idled -> anti-afk click")
			end
		end)
	end)
	while K.alive do
		local wait_s = AFK_MIN + math.random() * (AFK_MAX - AFK_MIN)
		local e = tick() + wait_s
		while K.alive and tick() < e do task.wait(2) end
		if K.alive then
			sc(function() VU:CaptureController() end)
			sc(function() VU:ClickButton2(Vector2.new()) end)
		end
	end
end)

-- ---- [4] heartbeat + state loop ---------------------------------------------------------
task.spawn(function()
	while K.alive do
		hb()
		saveState({alive = true})
		task.wait(HB_EVERY)
	end
end)

logf("keeper loop running (hb=" .. HB_EVERY .. "s afk=" .. AFK_MIN .. "-" .. AFK_MAX .. "s)")
