-- ============================================================================
-- hz_deepdump.lua v4 — Ultra-Deep Data Serialization (Safe Execution ครบทุกข้อ)
-- ข้อ1 ทุก Instance read ผ่าน safeRead (pcall) — dead instance ข้ามทันที
-- ข้อ2 place-gate: รอ PlaceId == PLACE_ID + Workspace โหลดจริง ก่อนเริ่ม
-- ข้อ3 attributes + class-specific props + getnilinstances(cap) + tree(depth,parent)
-- ข้อ4 chunk <=15,000 แถว/ไฟล์ + dd_progress.txt ทุก stage + dd_summary.txt ปิดท้าย
-- ข้อ5 ไม่มีจุดไหนอ่านค่าดิบ — เจอข้อมูลเสียเท่าไรก็รันต่อจนจบ
-- ============================================================================
local PLACE_ID  = 107535308163741
local MAX_DEPTH = 14
local MAX_LINES = 30000      -- tree txt ต่อไฟล์
local PROPS_CHUNK = 15000    -- jsonl ต่อไฟล์ (ตามสเปก)
local NIL_CAP   = 2000
local MAX_NODES = 250000
local NODE_TIMEOUT = 3       -- วินาทีต่อ node — เกินถือว่าค้างข้าม (ใช้ task.defer watchdog)

local Http = game:GetService("HttpService")
local CS   = game:GetService("CollectionService")

-- ---- progress ----------------------------------------------------------------------
local function progress(msg)
	pcall(writefile, "dd_progress.txt", os.date("%X") .. " " .. tostring(msg))
end

-- ---- [1] safe accessors — ทุก read ผ่าน pcall --------------------------------------
local function safecall(fn)
	local ok, v = pcall(fn)
	return ok and v or nil
end
local function safeRead(i, prop)
	return safecall(function() return i[prop] end)
end
local function sname(i)  return safeRead(i, "Name") or "?" end
local function sclass(i) return safeRead(i, "ClassName") or "?" end
local function isDead(i) return safeRead(i, "ClassName") == nil end
local function spath(i)  return safecall(function() return i:GetFullName() end) or "?" end
local function skids(i)  return safecall(function() return i:GetChildren() end) or {} end
local function isA(i, c) return safecall(function() return i:IsA(c) end) == true end
local function sparent(i)
	local p = safeRead(i, "Parent")
	return p and safecall(function() return p.Name end) or "?"
end
local function svc(n)
	return safecall(function() return game:GetService(n) end)
end

-- ---- [2] place gate + workspace-load check ------------------------------------------
progress("v4 waiting place ...")
local t0 = tick()
while safeRead(game, "PlaceId") ~= PLACE_ID do
	if tick() - t0 > 300 then
		progress("ABORT place timeout")
		return
	end
	task.wait(1)
end
progress("place ok — waiting workspace content ...")
local WS = svc("Workspace")
local wt = tick()
repeat
	local n = #skids(WS)
	if n >= 3 then break end
	if tick() - wt > 60 then
		progress("ABORT workspace not loaded (kids=" .. n .. ")")
		return
	end
	task.wait(1)
until false
progress("workspace ready kids=" .. #skids(WS))

-- match gate: รอจน LocalPlayer.InMatch == true (สแน็ปสถานะในเกมจริง) — เกิน 15 นาที dump ให้อยู่ดี
local PLR = svc("Players")
local LP = PLR and safeRead(PLR, "LocalPlayer")
progress("waiting InMatch=true ...")
local mt = tick()
repeat
	local im = LP and safecall(function() return LP:GetAttribute("InMatch") end)
	if im == true then break end
	if tick() - mt > 900 then
		progress("InMatch timeout — dumping anyway")
		break
	end
	task.wait(2)
until false
progress("scan begin — InMatch=" .. tostring(LP and safecall(function() return LP:GetAttribute("InMatch") end)))

-- ---- encoders -----------------------------------------------------------------------
local function enc(v)
	local t = typeof(v)
	if t == "string" then return v end
	if t == "number" or t == "boolean" then return tostring(v) end
	if t == "Vector3" then return string.format("%.3f,%.3f,%.3f", v.X, v.Y, v.Z) end
	if t == "Vector2" then return string.format("%.3f,%.3f", v.X, v.Y) end
	if t == "Color3" then return string.format("%.3f,%.3f,%.3f", v.R, v.G, v.B) end
	if t == "CFrame" then
		local cp = safecall(function() return {v:GetComponents()} end)
		if not cp or #cp < 12 then return "?" end
		return string.format("%.2f,%.2f,%.2f|%.3g,%.3g,%.3g,%.3g,%.3g,%.3g,%.3g,%.3g,%.3g",
			cp[1],cp[2],cp[3],cp[4],cp[5],cp[6],cp[7],cp[8],cp[9],cp[10],cp[11],cp[12])
	end
	if t == "UDim2" then return string.format("%.3g,%.3g,%.3g,%.3g", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset) end
	if t == "UDim" then return string.format("%.3g,%.3g", v.Scale, v.Offset) end
	if t == "BrickColor" then return tostring(v) end
	if t == "EnumItem" then return tostring(safeRead(v, "Name") or v) end
	if t == "NumberRange" then return tostring(v.Min) .. "-" .. tostring(v.Max) end
	if t == "NumberSequence" then
		local ks = safecall(function() return v.Keypoints end)
		if not ks then return "?" end
		local o = {}
		for _, k in ipairs(ks) do o[#o+1] = string.format("%.2f:%.2f", k.Time, k.Value) end
		return table.concat(o, ";")
	end
	if t == "ColorSequence" then
		local ks = safecall(function() return v.Keypoints end)
		if not ks then return "?" end
		local o = {}
		for _, k in ipairs(ks) do
			local c = k.Value
			o[#o+1] = string.format("%.2f:%.2f,%.2f,%.2f", k.Time, c.R, c.G, c.B)
		end
		return table.concat(o, ";")
	end
	if t == "Rect" then return string.format("%.1f,%.1f,%.1f,%.1f", v.Min.X, v.Min.Y, v.Max.X, v.Max.Y) end
	return tostring(v)
end

-- ---- [3] probe sets ตาม class ---------------------------------------------------------
local PROBE_CORE = {
	"Name","ClassName","Archivable",
	"Transparency","Color","Material","Anchored","CanCollide",
	"Value","Text","Visible","Enabled","Disabled","Playing","Looped",
}
local PROBE_PART = {
	"Size","Position","Rotation","Orientation","CFrame","Color","BrickColor","Material","MaterialVariant",
	"Transparency","Reflectance","Anchored","CanCollide","CanTouch","CanQuery","Massless",
	"CollisionGroup","AssemblyMass","CastShadow","RootPriority","TextureID","MeshId",
}
local PROBE_GUI = {
	"Text","TextSize","TextColor3","TextTransparency","TextScaled","Font","RichText",
	"Visible","ZIndex","BackgroundColor3","BackgroundTransparency","LayoutOrder",
	"AbsolutePosition","AbsoluteSize","AbsoluteRotation","AnchorPoint","Position","Size",
	"ClipsDescendants","Active","Selectable","Image","ImageColor3","ImageTransparency",
	"ImageRectOffset","ImageRectSize","Rotation","AutomaticCanvasSize","CanvasSize","ScrollBarThickness",
	"MaxDistance","AlwaysOnTop","StudsOffset","Adornee","Face",
}
local PROBE_SOUND = {
	"SoundId","Volume","PlaybackSpeed","Looped","Playing","IsLoaded","IsPlaying","IsPaused",
	"TimePosition","RollOffMinDistance","RollOffMaxDistance","EmitterSize","MaxDistance",
}
local PROBE_FX = {
	"Enabled","Texture","Rate","Speed","Lifetime","RotSpeed","Rotation","SpreadAngle",
	"LightEmission","LightInfluence","Size","Transparency","Color","Brightness",
	"Intensity","Range","Angle","Shadows","Density","Offset","Decay","Haze","Threshold","Spread",
	"Width0","Width1","CurveSize0","CurveSize1","Attachment0","Attachment1","TextureLength",
	"Heat","SparkleColor","SecondaryColor",
}
local PROBE_CHAR = {
	"Health","MaxHealth","WalkSpeed","JumpPower","JumpHeight","HipHeight","RigType",
	"AutoRotate","FloorMaterial","Sit","DisplayDistanceType","NameDisplayDistance",
	"MaxSlopeAngle","BreakJointsOnDeath","Occupant","SeatPart",
	"FieldOfView","CameraType","Neutral","Duration","Disabled",
	"ActionText","ObjectText","HoldDuration","MaxActivationDistance","RequiresLineOfSight",
	"KeyboardKeyCode","RequiresHandle","ToolTip","CanBeDropped",
	"Part0","Part1","C0","C1","Transform","AnimationId","Priority","Speed","IsPlaying","Length",
	"TeamColor","AutoAssignable","RespawnLocation","Character",
}
local PROBE_MODEL = {"PrimaryPart","WorldPivot","PivotOffset","ExtentsCFrame"}

local function probeSet(i)
	if isA(i, "GuiObject") then return PROBE_GUI
	elseif isA(i, "BasePart") then return PROBE_PART
	elseif isA(i, "Sound") or isA(i, "SoundGroup") then return PROBE_SOUND
	elseif isA(i, "ParticleEmitter") or isA(i, "Trail") or isA(i, "Beam") or isA(i, "Fire")
		or isA(i, "Smoke") or isA(i, "Sparkles") or isA(i, "PostEffect") or isA(i, "Light")
		or isA(i, "Atmosphere") or isA(i, "Sky") then return PROBE_FX
	elseif isA(i, "ValueBase") then return {"Value"}
	elseif isA(i, "Humanoid") or isA(i, "Seat") or isA(i, "Tool") or isA(i, "Camera")
		or isA(i, "SpawnLocation") or isA(i, "ProximityPrompt") or isA(i, "ClickDetector")
		or isA(i, "JointInstance") or isA(i, "Animation") or isA(i, "AnimationTrack")
		or isA(i, "Player") or isA(i, "Team") then return PROBE_CHAR
	elseif isA(i, "Model") then return PROBE_MODEL
	else return PROBE_CORE end
end

local function deepProps(i)
	local ps = probeSet(i)
	local out, n = nil, 0
	for _, p in ipairs(ps) do
		local v = safeRead(i, p)
		if v ~= nil then
			out = out or {}
			out[p] = safecall(function() return enc(v) end) or "?"
			n = n + 1
			if n >= 60 then break end
		end
	end
	return out
end

local function attrTable(i)
	local a = safecall(function() return i:GetAttributes() end)
	if type(a) == "table" and next(a) ~= nil then
		local t = {}
		for k, v in pairs(a) do
			t[tostring(k)] = safecall(function() return enc(v) end) or "?"
		end
		return t
	end
	return nil
end

local function tagList(i)
	local t = safecall(function() return CS:GetTags(i) end)
	if type(t) == "table" and #t > 0 then return t end
	return nil
end

-- ---- collectors ----------------------------------------------------------------------
local remotes, values = {}, {}
local assets = {sounds={}, images={}, meshes={}, anims={}}
local attributes, cframes = {}, {}
local classCount, tagCount = {}, {}
local propFiles, propBuf, propN = 0, {}, 0
local skipped = 0

local function flushProps()
	if propN == 0 then return end
	propFiles = propFiles + 1
	pcall(writefile, "dd_props_" .. propFiles .. ".jsonl", table.concat(propBuf, "\n"))
	progress("props chunk " .. propFiles .. " (" .. propN .. " rows)")
	propBuf, propN = {}, 0
end
local function emitProps(row)
	propN = propN + 1
	propBuf[propN] = row
	if propN >= PROPS_CHUNK then flushProps() end
end

local function assetId(s) return type(s) == "string" and s:match("rbxassetid://%d+") end
local function collectAssets(i)
	local p
	local sid = safeRead(i, "SoundId")
	if assetId(sid) then p = p or spath(i); assets.sounds[#assets.sounds+1] = {id=sid, path=p} end
	local img = safeRead(i, "Image")
	if assetId(img) then p = p or spath(i); assets.images[#assets.images+1] = {id=img, path=p} end
	local tex = safeRead(i, "Texture")
	if assetId(tex) then p = p or spath(i); assets.images[#assets.images+1] = {id=tex, path=p} end
	local mid = safeRead(i, "MeshId")
	if assetId(mid) then p = p or spath(i); assets.meshes[#assets.meshes+1] = {id=mid, path=p} end
	local aid = safeRead(i, "AnimationId")
	if assetId(aid) then p = p or spath(i); assets.anims[#assets.anims+1] = {id=aid, path=p} end
end

-- tree line: depth | [Class] name | parent | ATTR | TAG
local function line(i, depth)
	local s = string.format("%sd%02d [%s] %s | par=%s",
		string.rep("  ", depth), depth, sclass(i), sname(i), sparent(i))
	local a = attrTable(i)
	if a then
		local p = {}
		for k, v in pairs(a) do p[#p+1] = k .. "=" .. tostring(v) end
		table.sort(p)
		s = s .. " ATTR{" .. table.concat(p, ",") .. "}"
	end
	local t = tagList(i)
	if t then s = s .. " TAG{" .. table.concat(t, ",") .. "}" end
	return s
end

local emit_cur
local function perNode(i, depth, rootName)
	emit_cur(line(i, depth))
	local cls = sclass(i)
	classCount[cls] = (classCount[cls] or 0) + 1
	local tg = tagList(i)
	if tg then for _, t in ipairs(tg) do tagCount[t] = (tagCount[t] or 0) + 1 end end
	local p = spath(i)
	local a = attrTable(i)
	if a then attributes[p] = a end
	local dp = safecall(function() return deepProps(i) end)
	if dp then
		local js = safecall(function() return Http:JSONEncode({p=p, c=cls, pr=dp}) end)
		if js then emitProps(js) end
	end
	if isA(i,"RemoteEvent") or isA(i,"RemoteFunction") or isA(i,"BindableEvent") or isA(i,"BindableFunction") then
		remotes[#remotes+1] = cls .. "  " .. p
	end
	if isA(i, "ValueBase") then
		values[#values+1] = {p=p, c=cls, v=enc(safeRead(i, "Value") or "?")}
	end
	if rootName == "Workspace" and (isA(i,"BasePart") or isA(i,"Model")) then
		local cf = safecall(function() return isA(i,"Model") and i:GetPivot() or i.CFrame end)
		if cf then cframes[#cframes+1] = {p=p, c=cls, cf=enc(cf)} end
	end
	pcall(collectAssets, i)
end

local index = {ts=os.date("%c"), place=safeRead(game,"PlaceId"),
	job=safecall(function() return game.JobId end), roots={}}

-- ---- main scan loop -------------------------------------------------------------------
for _, r in ipairs({
	{"Workspace","Workspace"},{"ReplicatedStorage","ReplicatedStorage"},
	{"ReplicatedFirst","ReplicatedFirst"},{"Lighting","Lighting"},
	{"StarterPack","StarterPack"},{"StarterPlayer","StarterPlayer"},
	{"StarterGui","StarterGui"},{"SoundService","SoundService"},
	{"Teams","Teams"},{"Players","Players"},
}) do
	local rootName, svcName = r[1], r[2]
	local root = svc(svcName)
	if not root then
		index.roots[rootName] = {nodes=0, files=0, err="service unavailable"}
	else
		progress("root " .. rootName .. " scanning ...")
		local nodes, buf, bufN, fileN = 0, {}, 0, 0
		local function flush()
			if bufN > 0 then
				fileN = fileN + 1
				pcall(writefile, "dd_" .. rootName .. "_tree_" .. fileN .. ".txt", table.concat(buf, "\n"))
				buf, bufN = {}, 0
			end
		end
		emit_cur = function(s)
			bufN = bufN + 1; buf[bufN] = s
			if bufN >= MAX_LINES then flush() end
		end
		local function rec(i, depth)
			if nodes >= MAX_NODES then return end
			if isDead(i) then skipped = skipped + 1; return end
			nodes = nodes + 1
			if not pcall(perNode, i, depth, rootName) then skipped = skipped + 1 end
			if nodes % 2000 == 0 then
				progress(rootName .. " nodes=" .. nodes .. " last=" .. spath(i))
			end
			if depth >= MAX_DEPTH then return end
			for _, c in ipairs(skids(i)) do rec(c, depth + 1) end
		end
		for _, c in ipairs(skids(root)) do rec(c, 0) end
		flush()
		index.roots[rootName] = {nodes=nodes, files=fileN}
		progress("root " .. rootName .. " done nodes=" .. nodes)
	end
end
flushProps()

-- ---- getnilinstances (fully guarded, capped) -------------------------------------------
local hidden = {}
progress("stage: nil instances")
if getnilinstances then
	local nils = safecall(getnilinstances)
	if type(nils) == "table" then
		index.hiddenTotal = #nils
		for j, i in ipairs(nils) do
			if j > NIL_CAP then break end
			if not isDead(i) then
				local e = {c=sclass(i), n=sname(i)}
				local par = safeRead(i, "Parent")
				e.par = (par and spath(par)) or "nil"
				e.attr = attrTable(i)
				e.kids = #skids(i)
				hidden[#hidden+1] = e
			else
				skipped = skipped + 1
			end
			if j % 500 == 0 then progress("nil instances " .. j) end
		end
	end
	index.hiddenCount = #hidden
else
	index.hiddenErr = "getnilinstances unavailable"
end

-- ---- globals --------------------------------------------------------------------------
local globals = {env={}, shared={}, genv={}}
local function scanTbl(src, dst, depth)
	if type(src) ~= "table" or depth <= 0 then return end
	for k, v in pairs(src) do
		local t = typeof(v)
		local key = tostring(k)
		if t == "table" then
			dst[key] = {__t="table"}
			if depth > 1 then
				local sub, n = {}, 0
				for k2, v2 in pairs(v) do
					sub[tostring(k2)] = typeof(v2); n = n + 1
					if n >= 40 then break end
				end
				dst[key].keys = sub
			end
		elseif t == "string" and #v <= 200 then dst[key] = v
		elseif t == "number" or t == "boolean" then dst[key] = v
		else dst[key] = t end
	end
end
progress("stage: globals")
local env = getrenv and safecall(getrenv) or nil
if type(env) == "table" then
	if type(env._G) == "table" then pcall(scanTbl, env._G, globals.env, 2) end
	if type(env.shared) == "table" then pcall(scanTbl, env.shared, globals.shared, 2) end
else
	pcall(scanTbl, _G, globals.env, 2)
	pcall(function() if type(shared) == "table" then scanTbl(shared, globals.shared, 2) end end)
end
local genv = getgenv and safecall(getgenv) or nil
if type(genv) == "table" then pcall(scanTbl, genv, globals.genv, 1) end

-- ---- artifacts -------------------------------------------------------------------------
progress("stage: artifacts")
local function wj(name, tbl)
	local js = safecall(function() return Http:JSONEncode(tbl) end)
	if js then pcall(writefile, name, js) end
end
local written = {}
local function w(name, content)
	if pcall(writefile, name, content) then written[#written+1] = name end
end
wj("dd_attributes.json", attributes); written[#written+1] = "dd_attributes.json"
wj("dd_hidden.json", hidden);         written[#written+1] = "dd_hidden.json"
wj("dd_globals.json", globals);       written[#written+1] = "dd_globals.json"
wj("dd_map_cframes.json", cframes);   written[#written+1] = "dd_map_cframes.json"
wj("dd_values.json", values);         written[#written+1] = "dd_values.json"
wj("dd_assets.json", assets);         written[#written+1] = "dd_assets.json"
w("dd_remotes.txt", table.concat(remotes, "\n"))
for i = 1, propFiles do written[#written+1] = "dd_props_" .. i .. ".jsonl" end
for k, v in pairs(index.roots) do
	for i = 1, (v.files or 0) do written[#written+1] = "dd_" .. k .. "_tree_" .. i .. ".txt" end
end

local attrN = 0; for _ in pairs(attributes) do attrN = attrN + 1 end
index.classes = classCount
index.tags = tagCount
index.propFiles = propFiles
index.skipped = skipped
index.counts = {remotes=#remotes, values=#values, attrs=attrN, cframes=#cframes,
	sounds=#assets.sounds, images=#assets.images, meshes=#assets.meshes, anims=#assets.anims}
wj("dd_index.json", index); written[#written+1] = "dd_index.json"

-- ---- [4] final summary (Lua-side) -------------------------------------------------------
local SL = {"=== DEEPDUMP v4 SUMMARY ===",
	"place=" .. tostring(index.place) .. " job=" .. tostring(index.job),
	"files written: " .. table.concat(written, ", "),
	"prop chunks=" .. propFiles .. " remotes=" .. #remotes .. " values=" .. #values ..
	" attrs=" .. attrN .. " cframes=" .. #cframes .. " hidden=" .. #hidden ..
	" skipped=" .. skipped}
for k, v in pairs(index.roots) do
	SL[#SL+1] = string.format("  %-20s nodes=%d files=%d %s", k, v.nodes or 0, v.files or 0, v.err or "")
end
w("dd_summary.txt", table.concat(SL, "\n"))

progress("DONE")
print("[DEEPDUMPv4] complete — " .. #written .. " files, skipped=" .. skipped)
