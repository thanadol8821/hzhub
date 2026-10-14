-- hz_deimos_dump.lua v2 — DEIMOS/UBG DEEP DUMP (ลึกกว่ารอบเดิมหลายเท่า)
-- ใช้: loadstring(readfile("hz_deimos_dump.lua"))()  — รันในเกม (ล็อบบี้/แมตช์/มอลล์ ทำซ้ำได้หลายรอบ)
-- หยุดทั้งหมด: getgenv().HZDD = false
-- ผลลัพธ์: HZDD_<HHMMSS>/ — ส่งทั้งโฟลเดอร์ให้ dev
--
--   ══ ชั้นพื้นผิว (Dex) ══
--   meta.txt        = เกม/ผู้เล่น/env capabilities/สถิติ
--   tree.txt        = instance tree ครบ + attrs + values (ทุก service สำคัญ)
--   remotes.txt     = ดัชนี Remote*/Bind* ทั้งหมด
--   gui.txt         = PlayerGui tree + ข้อความราคา
--   states.txt      = Workspace.States snapshot + ข้อมูลตัวเรา
--   econ.txt        = เสียเงิน: products/passes/ราคา/shop/ค่าตัวเลขเงินทุกจุด
--
--   ══ ชั้นซอร์ส (ลึกกว่า corpus เดิม — เอา LocalScript ด้วยไม่แค่ Module) ══
--   mods/*.luau     = decompile ModuleScript ทุกตัว
--   locals/*.luau   = decompile LocalScript ทุกตัว ← ★ใหม่ (ตรรกะ client จริงอยู่นี่)
--   scripts_idx.txt = Server Script ทั้งหมด (list ทิ้งไว้ — server ถอดไม่ได้แต่ path บอกโครง)
--   nil_inst.txt    = getnilinstances() — instance ลับที่ parent=nil (เกมซ่อนไว้)
--
--   ══ ชั้น runtime (ของจริงที่คนอื่นใช้) ══
--   gc_tables.txt   = getgc: ตารางที่มี key เกมเพลย์ (Cooldown/Damage/Window/Price/Speed…)
--   gc_funcs.txt    = getgc: ฟังก์ชัน + source path + nups/nparams (หา handler จริง)
--   combat_funcs.txt= constants+upvalues ของฟังก์ชันที่ source อยู่ใน Punch/Dash/Block/Combat
--   conns.txt       = getconnections บนทุก Remote → ฟังก์ชันไหนฟัง remote ไหน (ผูก spy↔ซอร์ส)
--   anims.txt       = Animation ทั้งหมด + track ที่เล่นอยู่ + keyframe markers
--
--   ══ ชั้นสด (rspy + timeseries) ══
--   spy.txt         = remote traffic จริง: OUT (__namecall) + IN (OnClientEvent) + args เต็ม
--   st_ts.txt       = ★ timeseries — state/attr เปลี่ยนเมื่อไหร่ระดับ ms (ดูจังหวะ dodge window)
--   prop.txt        = property เปลี่ยนบน State nodes (Value changes)

if getgenv().HZDD then getgenv().HZDD = false task.wait(0.6) end
getgenv().HZDD = true

local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local MPS = game:GetService("MarketplaceService")
local SPS = game:GetService("StarterPlayer")
local LP = Players.LocalPlayer

local DIR = "HZDD_" .. os.date("%H%M%S")
pcall(makefolder, DIR) pcall(makefolder, DIR .. "/mods") pcall(makefolder, DIR .. "/locals")

local function W(name, s) pcall(writefile, DIR .. "/" .. name, s) end

-- ════════════ serializer ════════════
local function deep(v, d)
	d = d or 0
	if d > 6 then return "…" end
	local t = typeof and typeof(v) or type(v)
	if t == "table" then
		local n = 0 for _ in pairs(v) do n = n + 1 end
		if n > 40 then return "{…" .. n .. " keys…}" end
		local o = {}
		for k, x in pairs(v) do o[#o + 1] = tostring(k) .. "=" .. deep(x, d + 1) end
		return "{" .. table.concat(o, ",") .. "}"
	elseif t == "Instance" then return "@" .. v:GetFullName()
	elseif t == "Vector3" then return string.format("V3(%.2f,%.2f,%.2f)", v.X, v.Y, v.Z)
	elseif t == "Vector2" then return string.format("V2(%.2f,%.2f)", v.X, v.Y)
	elseif t == "CFrame" then local p = v.Position return string.format("CF(%.1f,%.1f,%.1f)", p.X, p.Y, p.Z)
	elseif t == "Color3" then return string.format("C3(%.2f,%.2f,%.2f)", v.R, v.G, v.B)
	elseif t == "UDim2" then return string.format("UD2(%.2f,%.0f,%.2f,%.0f)", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
	elseif t == "EnumItem" then return tostring(v)
	elseif t == "buffer" then return "buf:" .. tostring(buffer.len(v)) .. "B"
	elseif t == "function" then return "fn:" .. tostring(v):sub(-12)
	elseif t == "string" then
		local s = v:gsub("\n", "\\n")
		if #s > 200 then s = s:sub(1, 200) .. "…" end
		return '"' .. s .. '"'
	end
	return tostring(v)
end

local function attrs(i)
	local ok, a = pcall(function() return i:GetAttributes() end)
	if not ok or not a or not next(a) then return "" end
	local o = {}
	for k, v in pairs(a) do o[#o + 1] = k .. "=" .. deep(v) end
	return " ATTR{" .. table.concat(o, ",") .. "}"
end

local function valStr(i)
	local ok, v = pcall(function()
		if i:IsA("ValueBase") then return " = " .. deep(i.Value) end
		if i:IsA("TextLabel") or i:IsA("TextButton") or i:IsA("TextBox") then
			return ' TEXT="' .. i.Text:gsub("\n", " "):sub(1, 140) .. '"'
		end
		return ""
	end)
	return ok and v or ""
end

local stats = {}

-- ════ A1. TREE ════
task.spawn(function()
	local out = { "== TREE " .. os.date("%X") .. " place=" .. game.PlaceId .. " ==" }
	local function emit(i, dep)
		out[#out + 1] = string.rep("  ", math.min(dep, 20)) .. i.Name .. "  [" .. i.ClassName .. "]" .. valStr(i) .. attrs(i)
	end
	for _, r in ipairs({ RS, SPS, game:GetService("StarterPack"), game:GetService("StarterGui"),
		game:GetService("Lighting"), game:GetService("Teams"), game:GetService("SoundService"),
		game:GetService("ReplicatedFirst"), game:GetService("Chat") }) do
		pcall(function()
			emit(r, 0)
			for _, d in ipairs(r:GetDescendants()) do
				emit(d, select(2, d:GetFullName():gsub("%.", "")))
			end
		end)
	end
	out[#out + 1] = "== WORKSPACE (เฉพาะโหนดข้อมูล — ข้าม geometry) =="
	pcall(function()
		for _, d in ipairs(WS:GetDescendants()) do
			local cn = d.ClassName
			if cn:find("Value") or cn:find("Remote") or cn:find("Bind") or cn:find("Module")
				or cn == "Folder" or cn == "Configuration"
				or d:GetFullName():find("States") then
				emit(d, 0)
			end
		end
	end)
	W("tree.txt", table.concat(out, "\n"))
	stats.tree = #out
end)

-- ════ A2. REMOTES index ════
task.spawn(function()
	local out = { "== REMOTES ==" }
	for _, d in ipairs(game:GetDescendants()) do
		local cn = d.ClassName
		if cn:find("Remote") or cn:find("Bind") then
			out[#out + 1] = cn .. "  " .. d:GetFullName() .. attrs(d)
		end
	end
	W("remotes.txt", table.concat(out, "\n"))
	stats.remotes = #out - 1
end)

-- ════ A3. DECOMPILE ทุกสคริปต์ (Module+Local+Script) ════
task.spawn(function()
	local idxM, idxL, idxS = {}, {}, {}
	local nok, nfail = 0, 0
	local function tryDump(d, sub, idx)
		local safe = (d:GetFullName():gsub("[^%w%.%-_]", "_")):sub(1, 90)
		local src, how = nil, "none"
		if decompile then
			local ok, r = pcall(decompile, d)
			if ok and type(r) == "string" and #r > 5 then src, how = r, "decompiled" end
		end
		if not src and getscriptbytecode then
			local ok, bc = pcall(getscriptbytecode, d)
			if ok and bc and #bc > 0 then
				src = "-- bytecode " .. #bc .. "B — decompile ไม่ได้\n-- " .. d:GetFullName()
				how = "bytecode"
			end
		end
		if src then
			W(sub .. "/" .. safe .. ".luau", "-- " .. d:GetFullName() .. " [" .. d.ClassName .. "] (" .. how .. ")\n" .. src)
			nok = nok + 1
			idx[#idx + 1] = "[OK:" .. how .. "] " .. d:GetFullName()
		else
			nfail = nfail + 1
			idx[#idx + 1] = "[FAIL] " .. d:GetFullName()
		end
	end
	for _, d in ipairs(game:GetDescendants()) do
		if d:IsA("ModuleScript") then tryDump(d, "mods", idxM)
		elseif d:IsA("LocalScript") then tryDump(d, "locals", idxL)
		elseif d:IsA("Script") then idxS[#idxS + 1] = "SERVER " .. d:GetFullName() .. (d.Enabled and "" or " (disabled)") end
	end
	W("mods/_INDEX.txt", table.concat(idxM, "\n"))
	W("locals/_INDEX.txt", table.concat(idxL, "\n"))
	W("scripts_idx.txt", table.concat(idxS, "\n"))
	stats.decomp = nok .. "/" .. (nok + nfail)
end)

-- ════ A4. ECONOMY เสียเงิน ════
task.spawn(function()
	local out = { "== ECONOMY ==" }
	pcall(function() out[#out + 1] = "PLACE: " .. deep(MPS:GetProductInfo(game.PlaceId)) end)
	local MONEY = { "price", "cost", "robux", "pass", "product", "gem", "cash", "coin",
		"shop", "buy", "purchase", "crate", "bundle", "vip", "premium", "donate", "boost",
		"spin", "crate", "emote", "skin", "glove" }
	pcall(function()
		for _, d in ipairs(game:GetDescendants()) do
			local nm = d.Name:lower()
			for _, kw in ipairs(MONEY) do
				if nm:find(kw) then
					out[#out + 1] = "HIT(" .. kw .. ") " .. d.ClassName .. "  " .. d:GetFullName() .. valStr(d) .. attrs(d)
					break
				end
				-- ค่าตัวเลขใน attr ที่มีคำว่า price/cost
				local ok, a = pcall(function() return d:GetAttributes() end)
				if ok and a then
					for k, v in pairs(a) do
						if type(k) == "string" and (k:lower():find("price") or k:lower():find("cost") or k:lower():find("robux")) then
							out[#out + 1] = "ATTR$ " .. d:GetFullName() .. " → " .. k .. "=" .. deep(v)
						end
					end
				end
			end
		end
	end)
	pcall(function()
		local pages = MPS:GetDeveloperProductsAsync()
		local g = 0
		while pages and g < 50 do
			g = g + 1
			for _, p in ipairs(pages:GetCurrentPage()) do out[#out + 1] = "DEVPRODUCT " .. deep(p) end
			if pages.IsFinished then break end
			pages:AdvanceToNextPageAsync()
		end
	end)
	local seen = {}
	pcall(function()
		for _, d in ipairs(game:GetDescendants()) do
			if d:IsA("ValueBase") and type(d.Value) == "number" and d.Value > 1000 then
				local nm = d.Name:lower()
				if nm:find("pass") or nm:find("product") then
					if not seen[d.Value] then
						seen[d.Value] = true
						local ok, i = pcall(function() return MPS:GetProductInfo(d.Value, Enum.InfoType.GamePass) end)
						if not ok then pcall(function() i = MPS:GetProductInfo(d.Value) end) end
						out[#out + 1] = "PASSINFO id=" .. d.Value .. " → " .. deep(i)
					end
				end
			end
		end
	end)
	W("econ.txt", table.concat(out, "\n"))
	stats.econ = #out - 1
end)

-- ════ A5. STATES snapshot ════
task.spawn(function()
	local out = { "== STATES " .. os.date("%X") .. " ==" }
	local st = WS:FindFirstChild("States")
	if st then
		for _, f in ipairs(st:GetChildren()) do
			out[#out + 1] = "-- " .. f.Name .. " --"
			pcall(function()
				for _, d in ipairs(f:GetDescendants()) do
					out[#out + 1] = "   " .. d:GetFullName():gsub("Workspace%.States%.", "") .. " [" .. d.ClassName .. "]" .. valStr(d) .. attrs(d)
				end
				out[#out + 1] = "   folder attrs: " .. deep(f:GetAttributes())
			end)
		end
	else
		out[#out + 1] = "ไม่มี Workspace.States"
	end
	pcall(function()
		local ch = LP.Character
		if ch then
			for _, d in ipairs(ch:GetDescendants()) do
				if d:IsA("ValueBase") or d.ClassName:find("Data") or d.ClassName == "Folder" then
					out[#out + 1] = "ME " .. d:GetFullName() .. valStr(d) .. attrs(d)
				end
			end
		end
		out[#out + 1] = "LP attrs: " .. deep(LP:GetAttributes())
	end)
	W("states.txt", table.concat(out, "\n"))
end)

-- ════ A6. GUI ════
task.spawn(function()
	local out = { "== GUI ==" }
	local function walk(i, dep)
		local vis = ""
		pcall(function() if i.Visible == false then vis = " (hidden)" end end)
		out[#out + 1] = string.rep("  ", math.min(dep, 16)) .. i.Name .. " [" .. i.ClassName .. "]" .. valStr(i) .. vis .. attrs(i)
		for _, c in ipairs(i:GetChildren()) do walk(c, dep + 1) end
	end
	pcall(function()
		local pg = LP:FindFirstChild("PlayerGui")
		if pg then for _, g in ipairs(pg:GetChildren()) do walk(g, 0) end end
	end)
	W("gui.txt", table.concat(out, "\n"))
	stats.gui = #out - 1
end)

-- ════ A7. ★ GC SCAN — ตาราง/ฟังก์ชัน runtime ทั้งหมด ════
task.spawn(function()
	if not getgc then stats.gc = "no getgc" return end
	local KEYS = { "cooldown", "damage", "window", "speed", "range", "price", "cost", "mult",
		"stun", "dodge", "block", "punch", "dash", "ult", "perfect", "timer", "duration",
		"health", "stamina", "combo", "knockback", "iframe", "rollback", "hitbox", "reward" }
	local tOut, fOut = { "== GC TABLES (มี key เกมเพลย์) ==" }, { "== GC FUNCS ==" }
	local nT, nF = 0, 0
	pcall(function()
		for _, o in ipairs(getgc(true)) do
			local ty = type(o)
			if ty == "table" then
				local hit, sample = nil, nil
				for k in pairs(o) do
					local ks = tostring(k):lower()
					for _, kw in ipairs(KEYS) do
						if ks:find(kw) then hit = kw break end
					end
					if hit then sample = k break end
				end
				if hit then
					nT = nT + 1
					tOut[#tOut + 1] = "HIT(" .. hit .. ") @" .. tostring(o):sub(-14) .. " " .. deep(o)
					if nT > 900 then break end
				end
			elseif ty == "function" then
				local info = nil
				pcall(function() info = debug.getinfo(o) end)
				if info and info.source and info.source ~= "" then
					nF = nF + 1
					fOut[#fOut + 1] = string.format("%s%s:%s  nups=%s nparams=%s vararg=%s",
						info.name or info.short_src or "?", " ← " .. tostring(info.source),
						tostring(info.linedefined or "?"), tostring(info.nups or "?"),
						tostring(info.numparams or "?"), tostring(info.is_vararg or "?"))
					if nF > 4000 then break end
				end
			end
		end
	end)
	W("gc_tables.txt", table.concat(tOut, "\n"))
	W("gc_funcs.txt", table.concat(fOut, "\n"))
	stats.gc = nT .. " tables / " .. nF .. " funcs"
end)

-- ════ A8. ★ COMBAT FUNCS — constants/upvalues ของฟังก์ชันที่น่าสนใจ ════
task.spawn(function()
	if not (getgc and debug and debug.getinfo) then stats.cfuncs = "no api" return end
	local WANT = { "punch", "dash", "block", "combat", "dodge", "stun", "ult", "hit",
		"rollback", "perfect", "state", "occu", "equip", "lock", "target" }
	local out = { "== COMBAT FUNCS (constants+upvalues) ==" }
	local n = 0
	pcall(function()
		for _, o in ipairs(getgc(true)) do
			if type(o) == "function" then
				local ok, info = pcall(debug.getinfo, o)
				if ok and info and info.source then
					local src = tostring(info.source):lower()
					for _, w in ipairs(WANT) do
						if src:find(w) then
							n = n + 1
							local line = string.format("-- %s [%s:%s] nups=%s", tostring(o):sub(-14),
								tostring(info.source), tostring(info.linedefined or "?"), tostring(info.nups or 0))
							local det = {}
							pcall(function()
								if getconstants then
									local cs = getconstants(o)
									if cs and #cs > 0 then
										local cl = {}
										for i, c in ipairs(cs) do if i > 25 then break end cl[#cl + 1] = deep(c) end
										det[#det + 1] = "  consts: " .. table.concat(cl, ",")
									end
								end
							end)
							pcall(function()
								if getupvalues then
									local ups = getupvalues(o)
									if ups then
										local ul = {}
										for k, v in pairs(ups) do ul[#ul + 1] = tostring(k) .. "=" .. deep(v) end
										det[#det + 1] = "  upvals: " .. table.concat(ul, ",")
									end
								end
							end)
							pcall(function()
								if getname and getname ~= "" then det[#det + 1] = "  name: " .. tostring(getname(o)) end
							end)
							out[#out + 1] = line .. "\n" .. table.concat(det, "\n")
							break
						end
					end
					if n > 600 then break end
				end
			end
		end
	end)
	W("combat_funcs.txt", table.concat(out, "\n"))
	stats.cfuncs = n
end)

-- ════ A9. CONNECTIONS — remote ←→ ฟังก์ชัน ════
task.spawn(function()
	if not getconnections then stats.conns = "no getconnections" return end
	local out = { "== CONNECTIONS (remote → script) ==" }
	pcall(function()
		for _, d in ipairs(game:GetDescendants()) do
			local cn = d.ClassName
			if cn == "RemoteEvent" or cn == "BindEvent" then
				local sig = (cn == "RemoteEvent") and d.OnClientEvent or d.Event
				local ok, cs = pcall(getconnections, sig)
				if ok and cs then
					for _, c in ipairs(cs) do
						local fn = "?"
						pcall(function()
							if c.Function then
								local i = debug.getinfo(c.Function)
								fn = (tostring(i.short_src or "?") .. ":" .. tostring(i.linedefined or "?"))
							end
						end)
						out[#out + 1] = d:GetFullName() .. " → " .. fn .. (c.Enabled == false and " (disabled)" or "")
					end
				end
			end
		end
	end)
	W("conns.txt", table.concat(out, "\n"))
	stats.conns = #out - 1
end)

-- ════ A10. ANIMATIONS ════
task.spawn(function()
	local out = { "== ANIMATIONS ==" }
	pcall(function()
		for _, d in ipairs(game:GetDescendants()) do
			if d:IsA("Animation") then
				out[#out + 1] = "ANIM " .. d:GetFullName() .. " id=" .. tostring(d.AnimationId)
			elseif d:IsA("KeyframeMarker") then
				out[#out + 1] = "KEYMARK " .. d:GetFullName()
			end
		end
		local ch = LP.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum then
			local an = hum:FindFirstChildOfClass("Animator")
			if an then
				for _, t in ipairs(an:GetPlayingAnimationTracks()) do
					out[#out + 1] = "PLAYING " .. t.Name .. " " .. tostring(t.Animation and t.Animation.AnimationId) ..
						" t=" .. string.format("%.2f", t.TimePosition) .. "/" .. string.format("%.2f", t.Length)
				end
			end
		end
	end)
	W("anims.txt", table.concat(out, "\n"))
end)

-- ════ A11. NIL INSTANCES ════
task.spawn(function()
	if not getnilinstances then stats.nilinst = "no api" return end
	local out = { "== NIL INSTANCES (ซ่อนไว้) ==" }
	pcall(function()
		for _, d in ipairs(getnilinstances()) do
			out[#out + 1] = d.ClassName .. "  " .. (pcall(function() return d:GetFullName() end) and d:GetFullName() or d.Name) .. attrs(d) .. valStr(d)
			if d:IsA("ModuleScript") and decompile then
				pcall(function()
					local r = decompile(d)
					if type(r) == "string" then
						W("mods/__nil_" .. d.Name:gsub("[^%w]", "_") .. ".luau", "-- nilparent " .. d:GetFullName() .. "\n" .. r)
					end
				end)
			end
		end
	end)
	W("nil_inst.txt", table.concat(out, "\n"))
	stats.nilinst = #out - 1
end)

-- ════════════ LIVE (rspy + timeseries) ════════════
local SPYF = DIR .. "/spy.txt"
local buf, nIn, nOut, nTs = {}, 0, 0, 0
local function slog(dir, remote, args)
	buf[#buf + 1] = string.format("%s %s %s %s", os.date("%X"), dir, remote, args)
end

-- IN: OnClientEvent + OnClientInvoke + Bind .Event
local function hookIn(d)
	local cn = d.ClassName
	if cn == "RemoteEvent" then
		pcall(function()
			d.OnClientEvent:Connect(function(...)
				if getgenv().HZDD then nIn = nIn + 1 slog("IN ", d:GetFullName(), deep({ ... })) end
			end)
		end)
	elseif cn == "RemoteFunction" then
		pcall(function()
			local old = d.OnClientInvoke
			d.OnClientInvoke = function(...)
				local a = { ... }
				if getgenv().HZDD then nIn = nIn + 1 slog("IN?", d:GetFullName(), deep(a)) end
				if old then return old(table.unpack(a)) end
			end
		end)
	elseif cn == "BindEvent" then
		pcall(function()
			d.Event:Connect(function(...)
				if getgenv().HZDD then nIn = nIn + 1 slog("BIN", d:GetFullName(), deep({ ... })) end
			end)
		end)
	end
end
for _, d in ipairs(game:GetDescendants()) do hookIn(d) end
pcall(function() game.DescendantAdded:Connect(hookIn) end)

-- OUT: hookmetamethod __namecall
local hookedOut = false
pcall(function()
	if not (getrawmetatable and getnamecallmethod) then return end
	local mt = getrawmetatable(game)
	local old_nc = mt.__namecall
	local ro = isreadonly and isreadonly(mt) or false
	if setreadonly then setreadonly(mt, false) end
	local WATCH = { RemoteEvent = { FireServer = true, Fire = true },
		RemoteFunction = { InvokeServer = true },
		BindEvent = { Fire = true }, BindFunction = { Invoke = true },
		UnreliableRemoteEvent = { FireServer = true } }
	mt.__namecall = newcclosure(function(self, ...)
		local m = getnamecallmethod()
		local ok, cn = pcall(function() return self.ClassName end)
		if ok and WATCH[cn] and WATCH[cn][m] and getgenv().HZDD then
			local a = { ... }
			task.spawn(function()
				nOut = nOut + 1
				slog("OUT", self:GetFullName() .. ":" .. m, deep(a))
			end)
		end
		return old_nc(self, ...)
	end)
	if setreadonly and ro then setreadonly(mt, true) end
	hookedOut = true
end)

-- ★ STATE TIMESERIES — ทุก attr/value บน State nodes เปลี่ยนเมื่อไหร่ (ms)
local tsBuf = {}
local TSF = DIR .. "/st_ts.txt"
local function tsLog(node, key, v)
	tsBuf[#tsBuf + 1] = string.format("%.3f %s %s=%s", os.clock(), node, key, deep(v))
	nTs = nTs + 1
end
local function watchNode(f)
	-- attributes ทั้งหมดบน folder (Occupied/CharacterData/PlayerData = attrs หรือ values)
	pcall(function()
		f.AttributeChanged:Connect(function(k)
			if getgenv().HZDD then tsLog(f:GetFullName(), "attr." .. k, f:GetAttribute(k)) end
		end)
	end)
	-- value children เปลี่ยน
	pcall(function()
		for _, d in ipairs(f:GetDescendants()) do
			if d:IsA("ValueBase") then
				d:GetPropertyChangedSignal("Value"):Connect(function()
					if getgenv().HZDD then tsLog(d:GetFullName(), "Value", d.Value) end
				end)
			end
		end
		f.DescendantAdded:Connect(function(d)
			if d:IsA("ValueBase") then
				d:GetPropertyChangedSignal("Value"):Connect(function()
					if getgenv().HZDD then tsLog(d:GetFullName(), "Value", d.Value) end
				end)
			end
		end)
	end)
	-- folder attr อีกชั้น (d deep) — attrs บน Occupied/CharacterData folder เอง
	pcall(function()
		for _, d in ipairs(f:GetDescendants()) do
			if d.ClassName == "Folder" or d.ClassName == "Configuration" then
				d.AttributeChanged:Connect(function(k)
					if getgenv().HZDD then tsLog(d:GetFullName(), "attr." .. k, d:GetAttribute(k)) end
				end)
			end
		end
		f.DescendantAdded:Connect(function(d)
			if d.ClassName == "Folder" or d.ClassName == "Configuration" then
				d.AttributeChanged:Connect(function(k)
					if getgenv().HZDD then tsLog(d:GetFullName(), "attr." .. k, d:GetAttribute(k)) end
				end)
			end
		end)
	end)
end
local st = WS:FindFirstChild("States")
if st then
	for _, f in ipairs(st:GetChildren()) do watchNode(f) end
	st.ChildAdded:Connect(watchNode)
end
-- ของตัวเอง (char attrs — Stunned/CanRollback etc)
pcall(function()
	local function hookChar(ch)
		ch.AttributeChanged:Connect(function(k)
			if getgenv().HZDD then tsLog("MYCHAR", "attr." .. k, ch:GetAttribute(k)) end
		end)
		for _, d in ipairs(ch:GetDescendants()) do
			if d:IsA("ValueBase") or d.ClassName == "Folder" then
				pcall(function()
					(d.AttributeChanged or d:GetPropertyChangedSignal("Value")):Connect(function(k)
						if getgenv().HZDD then
							local v = d:IsA("ValueBase") and d.Value or (k and d:GetAttribute(k))
							tsLog("MYCHAR/" .. d.Name, tostring(k or "Value"), v)
						end
					end)
				end)
			end
		end
	end
	if LP.Character then hookChar(LP.Character) end
	LP.CharacterAdded:Connect(hookChar)
end)

-- flush ทุก 1.5s
task.spawn(function()
	while getgenv().HZDD do
		if #buf > 0 then
			local chunk = table.concat(buf, "\n") .. "\n"
			buf = {}
			local old = ""
			pcall(function() old = readfile(SPYF) end)
			pcall(writefile, SPYF, old .. chunk)
		end
		if #tsBuf > 0 then
			local chunk = table.concat(tsBuf, "\n") .. "\n"
			tsBuf = {}
			local old = ""
			pcall(function() old = readfile(TSF) end)
			pcall(writefile, TSF, old .. chunk)
		end
		task.wait(1.5)
	end
end)

-- meta ทีหลัง (รอ dump A เสร็จ)
task.delay(12, function()
	local cap = {}
	for _, fn in ipairs({ "decompile", "getgc", "getconnections", "getnilinstances", "getloadedmodules",
		"getscriptbytecode", "hookmetamethod", "getrawmetatable", "getconstants", "getupvalues", "newcclosure" }) do
		local okf, vf = pcall(function() return getfenv(0)[fn] end)
		cap[#cap + 1] = fn .. "=" .. tostring(getgenv()[fn] ~= nil or _G[fn] ~= nil or (okf and vf ~= nil))
	end
	W("meta.txt", table.concat({
		"HZ DEIMOS DUMP v2 — " .. os.date("%Y-%m-%d %X"),
		"place=" .. game.PlaceId .. " job=" .. game.JobId,
		"player=" .. LP.Name .. " (" .. LP.UserId .. ")",
		"caps: " .. table.concat(cap, " "),
		"stats: " .. deep(stats),
		"spy: OUT=" .. tostring(hookedOut) .. " IN+TS running",
		"หยุด: getgenv().HZDD=false",
	}, "\n"))
	print("[HZDD] พร้อม → " .. DIR .. "/ — spy+timeseries ทำงานต่อจนหยุด")
end)

print("[HZDD v2] เริ่มดั้มลึก " .. DIR .. " (OUT=" .. tostring(hookedOut) .. ")")
