local CONFIG = {
    ROOT = "HZDump",
    TREE_ROOTS = {"Workspace", "ReplicatedStorage", "ReplicatedFirst", "Players", "Lighting", "StarterGui", "StarterPack", "StarterPlayer", "SoundService", "Teams"},
    MAX_DEPTH = 40,
    MAX_NODES_PER_ROOT = 500000,
    COLLAPSE_SAME = 12,
    SER_DEPTH = 6,
    SER_MAX_ITEMS = 400,
    SER_MAX_STR = 400,
    FUNC_CONSTANTS = 16,
    MAX_MODULES = 50000,
    MODULE_TIMEOUT = 2,
    DECOMPILE = true,
    MAX_DECOMPILE = 50000,
    DECOMPILE_TIMEOUT = 10,
    DECOMPILE_WORKERS = 3,
    SKIP_PATHS = {"PlayerModule", "RbxCharacterSounds", "PlayerScriptsLoader", "ChatScript", "BubbleChat", "ClientChatModules", "ChatMain", "CoreGui"},
    XREF_MAX_HITS = 30,
    KEYWORDS = {"admin", "debug", "cheat", "studio", "test", "dev", "free", "premium", "gamepass", "product", "robux", "price", "cost", "chance", "luck", "reward", "redeem", "code", "kick", "ban", "anticheat", "exploit", "sanity", "validate", "whitelist", "secret", "hidden", "multiplier", "boost", "cooldown"},
    KEYWORD_MAX_HITS = 40,
    SCRIPT_ENVS = true,
    GC_SCAN = true,
    GC_KEYS = {"cash", "coins", "money", "gems", "data", "inventory", "pets", "eggs", "level", "xp", "luck", "rebirth", "rebirths", "stats", "profile", "replica", "backpack", "currency"},
    GC_MAX_TABLES = 80,
    POI_MAX_PER_NAME = 25,
    POI_MAX_NAMES = 400,
    SPY_MINUTES = 10,
    SPY_BINDABLES = true,
    YIELD_EVERY = 300,
}

-- single-run lock: decompile ของ executor ไม่ thread-safe — 2 instance ซ้อน = เดดล็อก
if _G.__HZDUMP_RUNNING then
    warn("[HZDump] กำลังรันอยู่แล้ว — ไม่เริ่มซ้ำ")
    return
end
_G.__HZDUMP_RUNNING = true

local __ok, __err = pcall(function()
local t0 = os.clock()
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

local F = {
    writefile = writefile, makefolder = makefolder, isfolder = isfolder,
    decompile = decompile, getscripts = getscripts, getloadedmodules = getloadedmodules,
    getrunningscripts = getrunningscripts, getscripthash = getscripthash,
    getnilinstances = getnilinstances, getrenv = getrenv, getsenv = getsenv, getgc = getgc,
    getconnections = getconnections, getcallbackvalue = getcallbackvalue, getcallingscript = getcallingscript,
    hookfunction = hookfunction, hookmetamethod = hookmetamethod,
    getrawmetatable = getrawmetatable, setreadonly = setreadonly, getnamecallmethod = getnamecallmethod,
    checkcaller = checkcaller, newcclosure = newcclosure, identifyexecutor = identifyexecutor, gethui = gethui,
}
local dbgConst = (debug and rawget(debug, "getconstants")) or getconstants
local FEATURE_ORDER = {"writefile", "makefolder", "isfolder", "decompile", "getscripts", "getloadedmodules", "getrunningscripts", "getscripthash", "getnilinstances", "getrenv", "getsenv", "getgc", "getconnections", "getcallbackvalue", "getcallingscript", "hookfunction", "hookmetamethod", "getrawmetatable", "setreadonly", "getnamecallmethod", "checkcaller", "newcclosure", "identifyexecutor", "gethui"}
assert(F.writefile and F.makefolder, "executor ไม่มี writefile/makefolder")

local guiRoot = (F.gethui and F.gethui()) or lp:WaitForChild("PlayerGui")
pcall(function()
    local old = guiRoot:FindFirstChild("HZDumper")
    if old then old:Destroy() end
end)
local gui = Instance.new("ScreenGui")
gui.Name = "HZDumper"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Parent = guiRoot
local bar = Instance.new("TextLabel")
bar.AnchorPoint = Vector2.new(0.5, 0)
bar.Position = UDim2.new(0.5, 0, 0, 60)
bar.Size = UDim2.fromOffset(560, 34)
bar.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
bar.TextColor3 = Color3.fromRGB(255, 199, 46)
bar.Font = Enum.Font.GothamBold
bar.TextSize = 14
bar.Text = "HZ Dumper • เริ่ม…"
bar.Parent = gui
Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)
local barStroke = Instance.new("UIStroke")
barStroke.Color = Color3.fromRGB(255, 199, 46)
barStroke.Transparency = 0.4
barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
barStroke.Parent = bar
local function status(t)
    print("[HZDump] " .. t)
    bar.Text = "HZ Dumper • " .. t
end

local function safe(s)
    return (tostring(s):gsub("[^%w%-%.]", "_"):gsub("_+", "_")):sub(1, 90)
end
local placeName = "Place"
pcall(function() placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
local OUT = CONFIG.ROOT .. "/" .. safe(placeName) .. "_" .. game.PlaceId .. "/" .. os.date("%Y%m%d_%H%M%S")
local function mkdirs(path)
    local acc = ""
    for part in path:gmatch("[^/]+") do
        acc = acc == "" and part or (acc .. "/" .. part)
        pcall(function()
            if not (F.isfolder and F.isfolder(acc)) then F.makefolder(acc) end
        end)
    end
end
mkdirs(OUT .. "/modules")
mkdirs(OUT .. "/scripts")

local written, writtenOrder, report = {}, {}, {}
local function save(name, lines)
    local body = type(lines) == "table" and table.concat(lines, "\n") or tostring(lines)
    pcall(F.writefile, OUT .. "/" .. name, body)
    if not written[name] then writtenOrder[#writtenOrder + 1] = name end
    written[name] = #body
end

local ticks = 0
local function breathe()
    ticks += 1
    if ticks % CONFIG.YIELD_EVERY == 0 then task.wait() end
end
local function fullName(i)
    local ok, n = pcall(function() return i:GetFullName() end)
    return ok and n or tostring(i)
end
local function skipPath(path)
    for _, p in ipairs(CONFIG.SKIP_PATHS) do
        if path:find(p, 1, true) then return true end
    end
    return false
end

local function short(v)
    local t = typeof(v)
    if t == "Vector3" then return string.format("(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z) end
    if t == "Vector2" then return string.format("(%.1f, %.1f)", v.X, v.Y) end
    if t == "CFrame" then
        local p = v.Position
        return string.format("CF(%.1f, %.1f, %.1f)", p.X, p.Y, p.Z)
    end
    if t == "Color3" then return string.format("rgb(%d,%d,%d)", math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5)) end
    if t == "string" then return string.format("%q", #v > 160 and (v:sub(1, 160) .. "…") or v) end
    if t == "Instance" then return fullName(v) end
    if t == "number" then return (v == math.floor(v) and math.abs(v) < 1e15) and string.format("%d", v) or tostring(v) end
    if t == "buffer" then
        local n = buffer.len(v)
        local hex = {}
        for i = 0, math.min(n, 48) - 1 do hex[#hex + 1] = string.format("%02x", buffer.readu8(v, i)) end
        return string.format("buffer[%d] %s%s", n, table.concat(hex, " "), n > 48 and " …" or "")
    end
    return tostring(v)
end
local function funcConsts(f)
    if not dbgConst or CONFIG.FUNC_CONSTANTS <= 0 then return nil end
    local ok, c = pcall(dbgConst, f)
    if not ok or type(c) ~= "table" then return nil end
    local out = {}
    for _, v in pairs(c) do
        if type(v) == "string" and #v > 1 and #v < 60 then
            out[#out + 1] = string.format("%q", v)
            if #out >= CONFIG.FUNC_CONSTANTS then break end
        end
    end
    return #out > 0 and out or nil
end
local function fmtFunc(f)
    local name, src, line, nparams, vararg
    pcall(function() name, src, line = debug.info(f, "nsl") end)
    pcall(function() nparams, vararg = debug.info(f, "a") end)
    local s = string.format("function %s(%s%s) @%s:%s", (name and name ~= "") and name or "anon", tostring(nparams or "?"), vararg and ", ..." or "", tostring(src or "?"), tostring(line or "?"))
    local c = funcConsts(f)
    if c then s ..= "  consts{" .. table.concat(c, ", ") .. "}" end
    return s
end
local function scalar(v)
    local t = typeof(v)
    if t == "string" then
        return string.format("%q", #v > CONFIG.SER_MAX_STR and (v:sub(1, CONFIG.SER_MAX_STR) .. "…(" .. #v .. " chars)") or v)
    end
    if t == "Instance" then return "<" .. v.ClassName .. "> " .. fullName(v) end
    if t == "function" then return fmtFunc(v) end
    if t == "number" or t == "boolean" or t == "nil" or t == "EnumItem" then return tostring(v) end
    return t .. "(" .. short(v) .. ")"
end
local function ser(v, depth, maxDepth, seen, indent)
    if type(v) ~= "table" then return scalar(v) end
    if seen[v] then return "<cycle>" end
    if depth >= maxDepth then return "{…}" end
    seen[v] = true
    local keys = {}
    pcall(function()
        for k in pairs(v) do keys[#keys + 1] = k end
    end)
    table.sort(keys, function(a, b)
        local ta, tb = type(a), type(b)
        if ta ~= tb then return ta < tb end
        if ta == "number" or ta == "string" then return a < b end
        return tostring(a) < tostring(b)
    end)
    local head = type(getmetatable(v)) == "table" and "{ -- มี metatable" or "{"
    if #keys == 0 then
        seen[v] = nil
        return head == "{" and "{}" or "{} -- มี metatable"
    end
    local pad = string.rep("  ", indent + 1)
    local out = {head}
    for i, k in ipairs(keys) do
        if i > CONFIG.SER_MAX_ITEMS then
            out[#out + 1] = pad .. "… +" .. (#keys - i + 1) .. " รายการ"
            break
        end
        local ks = (type(k) == "string" and k:match("^[%a_][%w_]*$")) and k or ("[" .. scalar(k) .. "]")
        local okV, val = pcall(function() return v[k] end)
        out[#out + 1] = pad .. ks .. " = " .. (okV and ser(val, depth + 1, maxDepth, seen, indent + 1) or "<อ่านไม่ได้>") .. ","
    end
    out[#out + 1] = string.rep("  ", indent) .. "}"
    seen[v] = nil
    return table.concat(out, "\n")
end
local function S(v, maxDepth) return ser(v, 0, maxDepth or CONFIG.SER_DEPTH, {}, 0) end
local function compact(v, depth)
    if type(v) ~= "table" then return short(v) end
    if depth >= 3 then return "{…}" end
    local parts, n = {}, 0
    for k, x in pairs(v) do
        n += 1
        if n > 24 then
            parts[#parts + 1] = "…"
            break
        end
        parts[#parts + 1] = tostring(k) .. "=" .. compact(x, depth + 1)
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

local PROPS = {
    {"BasePart", {"Position", "Size", "Anchored", "CanCollide", "CanTouch", "Transparency", "Material", "Color"}},
    {"MeshPart", {"MeshId", "TextureID"}},
    {"SpecialMesh", {"MeshId", "TextureId", "Scale"}},
    {"Model", {"PrimaryPart"}},
    {"ValueBase", {"Value"}},
    {"GuiObject", {"Visible", "Position", "Size"}},
    {"TextLabel", {"Text"}}, {"TextButton", {"Text"}}, {"TextBox", {"Text", "PlaceholderText"}},
    {"ImageLabel", {"Image"}}, {"ImageButton", {"Image"}},
    {"LayerCollector", {"Enabled"}}, {"ScreenGui", {"DisplayOrder"}},
    {"BillboardGui", {"Adornee", "MaxDistance", "AlwaysOnTop"}}, {"SurfaceGui", {"Adornee", "Face"}},
    {"ProximityPrompt", {"ActionText", "ObjectText", "KeyboardKeyCode", "HoldDuration", "MaxActivationDistance", "RequiresLineOfSight", "Enabled"}},
    {"ClickDetector", {"MaxActivationDistance"}},
    {"Sound", {"SoundId", "Volume", "Looped", "Playing"}},
    {"Humanoid", {"WalkSpeed", "JumpPower", "HipHeight", "Health", "MaxHealth", "RigType", "DisplayName"}},
    {"Tool", {"ToolTip", "RequiresHandle", "CanBeDropped"}},
    {"Decal", {"Texture"}}, {"Texture", {"Texture"}},
    {"ParticleEmitter", {"Texture", "Rate", "Enabled"}}, {"Beam", {"Texture", "Enabled"}}, {"Trail", {"Texture", "Enabled"}},
    {"Highlight", {"Adornee", "FillColor", "Enabled"}},
    {"JointInstance", {"Part0", "Part1"}}, {"Constraint", {"Attachment0", "Attachment1", "Enabled"}},
    {"Script", {"Enabled", "RunContext"}}, {"LocalScript", {"Enabled"}},
    {"Light", {"Brightness", "Range", "Enabled"}},
    {"Attachment", {"WorldPosition"}},
    {"Player", {"UserId", "DisplayName", "Team", "AccountAge"}},
    {"Team", {"TeamColor", "AutoAssignable"}},
    {"Animation", {"AnimationId"}},
    {"Shirt", {"ShirtTemplate"}}, {"Pants", {"PantsTemplate"}},
    {"Seat", {"Disabled"}},
    {"Camera", {"CFrame", "FieldOfView"}},
}
local function propParts(inst)
    local parts = {}
    for _, e in ipairs(PROPS) do
        if inst:IsA(e[1]) then
            for _, p in ipairs(e[2]) do
                local ok, v = pcall(function() return inst[p] end)
                if ok and v ~= nil and v ~= "" then parts[#parts + 1] = p .. "=" .. short(v) end
            end
        end
    end
    if inst:IsA("Model") then
        local ok, p = pcall(function() return inst:GetPivot().Position end)
        if ok then parts[#parts + 1] = "Pivot=" .. short(p) end
    end
    return parts
end
local function attrParts(inst)
    local ok, a = pcall(function() return inst:GetAttributes() end)
    if not ok or not next(a) then return nil end
    local parts = {}
    for k, v in pairs(a) do parts[#parts + 1] = k .. "=" .. short(v) end
    table.sort(parts)
    return parts
end
local function tagsOf(inst)
    local ok, t = pcall(function() return CS:GetTags(inst) end)
    return (ok and #t > 0) and t or nil
end
local function posOf(inst)
    local pos = ""
    pcall(function()
        if inst:IsA("BasePart") then pos = short(inst.Position)
        elseif inst:IsA("Attachment") then pos = short(inst.WorldPosition)
        elseif inst:IsA("Model") then pos = short(inst:GetPivot().Position) end
    end)
    return pos
end

local ASSET_PROPS = {
    {"ImageLabel", "Image"}, {"ImageButton", "Image"}, {"Sound", "SoundId"}, {"MeshPart", "MeshId"}, {"MeshPart", "TextureID"},
    {"SpecialMesh", "MeshId"}, {"SpecialMesh", "TextureId"}, {"Decal", "Texture"}, {"Texture", "Texture"}, {"Animation", "AnimationId"},
    {"Shirt", "ShirtTemplate"}, {"Pants", "PantsTemplate"}, {"ParticleEmitter", "Texture"},
}
local idx = {class = {}, models = {}, attrs = {}, values = {}, prompts = {}, remotes = {}, remoteObjs = {}, modules = {}, scripts = {}, buttons = {}, assets = {}, poi = {}, poiN = 0}
local REMOTE_CLASSES = {RemoteEvent = true, UnreliableRemoteEvent = true, RemoteFunction = true, BindableEvent = true, BindableFunction = true}
local seenMod, seenScript = {}, {}
local function addModule(m)
    if not seenMod[m] then
        seenMod[m] = true
        idx.modules[#idx.modules + 1] = m
    end
end
local function addScript(s)
    if not seenScript[s] then
        seenScript[s] = true
        idx.scripts[#idx.scripts + 1] = s
    end
end
local function indexAll(root, rootName)
    local ok, all = pcall(function() return root:GetDescendants() end)
    if not ok then return 0 end
    for _, d in ipairs(all) do
        breathe()
        local cn = d.ClassName
        idx.class[cn] = (idx.class[cn] or 0) + 1
        local a = attrParts(d)
        if a then idx.attrs[#idx.attrs + 1] = fullName(d) .. "  [" .. cn .. "]\n    " .. table.concat(a, "\n    ") end
        if REMOTE_CLASSES[cn] then
            idx.remotes[#idx.remotes + 1] = string.format("%-22s %s", cn, fullName(d))
            idx.remoteObjs[#idx.remoteObjs + 1] = d
        elseif d:IsA("ValueBase") then
            local okV, v = pcall(function() return d.Value end)
            idx.values[#idx.values + 1] = fullName(d) .. "  [" .. cn .. "] = " .. (okV and short(v) or "?")
        elseif d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then
            idx.prompts[#idx.prompts + 1] = fullName(d) .. "  [" .. cn .. "] @" .. posOf(d.Parent) .. "  " .. table.concat(propParts(d), " ")
        elseif d:IsA("Model") then
            idx.models[d.Name] = (idx.models[d.Name] or 0) + 1
            if rootName == "Workspace" then
                local list = idx.poi[d.Name]
                if not list then
                    if idx.poiN < CONFIG.POI_MAX_NAMES then
                        list = {}
                        idx.poi[d.Name] = list
                        idx.poiN += 1
                    end
                end
                if list and #list < CONFIG.POI_MAX_PER_NAME then list[#list + 1] = posOf(d) .. "  " .. fullName(d) end
            end
        elseif d:IsA("ModuleScript") then
            addModule(d)
        elseif d:IsA("LocalScript") or d:IsA("Script") then
            addScript(d)
        elseif d:IsA("GuiButton") then
            idx.buttons[#idx.buttons + 1] = d
        end
        for _, ap in ipairs(ASSET_PROPS) do
            if cn == ap[1] then
                local okA, id = pcall(function() return d[ap[2]] end)
                if okA and type(id) == "string" and id ~= "" then
                    local e = idx.assets[id]
                    if e then e.n += 1 else idx.assets[id] = {n = 1, kind = cn .. "." .. ap[2], ex = fullName(d)} end
                end
            end
        end
    end
    return #all
end

local function dumpTree(rootInst, lines, skip)
    local nodes = 0
    local function walk(inst, depth, prefix)
        if nodes >= CONFIG.MAX_NODES_PER_ROOT then return end
        nodes += 1
        breathe()
        local line = prefix .. inst.Name .. "  [" .. inst.ClassName .. "]"
        local p = propParts(inst)
        if #p > 0 then line ..= "  " .. table.concat(p, "  ") end
        local a = attrParts(inst)
        if a then line ..= "  @{" .. table.concat(a, ", ") .. "}" end
        local t = tagsOf(inst)
        if t then line ..= "  #" .. table.concat(t, " #") end
        lines[#lines + 1] = line
        local ok, kids = pcall(function() return inst:GetChildren() end)
        if not ok or #kids == 0 then return end
        if depth >= CONFIG.MAX_DEPTH then
            lines[#lines + 1] = prefix .. "  … (ลึกเกิน MAX_DEPTH, ลูก " .. #kids .. " ชิ้น)"
            return
        end
        local groups, order = {}, {}
        for _, c in ipairs(kids) do
            if not (skip and skip[c]) then
                local key = c.Name .. "\0" .. c.ClassName
                if not groups[key] then
                    groups[key] = {}
                    order[#order + 1] = key
                end
                table.insert(groups[key], c)
            end
        end
        for _, key in ipairs(order) do
            local g = groups[key]
            local show = #g > CONFIG.COLLAPSE_SAME and 2 or #g
            for i = 1, show do walk(g[i], depth + 1, prefix .. "  ") end
            if #g > show then
                lines[#lines + 1] = prefix .. "    … +" .. (#g - show) .. " ชิ้นชื่อเดียวกัน \"" .. g[1].Name .. "\" [" .. g[1].ClassName .. "] (ย่อ — ตำแหน่งครบใน 22, attribute ใน 04)"
            end
        end
    end
    walk(rootInst, 0, "")
    if nodes >= CONFIG.MAX_NODES_PER_ROOT then lines[#lines + 1] = "!! ถึงลิมิต MAX_NODES_PER_ROOT = " .. CONFIG.MAX_NODES_PER_ROOT end
    return nodes
end

local function withTimeout(sec, fn, ...)
    local args = table.pack(...)
    local done, ok, res = false, false, nil
    task.spawn(function()
        ok, res = pcall(fn, table.unpack(args, 1, args.n))
        done = true
    end)
    local s = os.clock()
    while not done and os.clock() - s < sec do task.wait(0.05) end
    if not done then return "timeout" end
    return ok and "ok" or "error", res
end
local function top(map, n, valueOf)
    local arr = {}
    for k, v in pairs(map) do arr[#arr + 1] = {k, valueOf and valueOf(v) or v} end
    table.sort(arr, function(a, b) return a[2] > b[2] end)
    local out = {}
    for i = 1, math.min(n, #arr) do out[#out + 1] = string.format("%8d  %s", arr[i][2], tostring(arr[i][1])) end
    return table.concat(out, "\n")
end

local corpus = {}
local function addCorpus(name, text)
    if type(text) == "string" and #text > 0 then corpus[#corpus + 1] = {name = name, text = text} end
end

local roots, rootCount = {}, {}
for i, name in ipairs(CONFIG.TREE_ROOTS) do
    local svc
    pcall(function() svc = game:GetService(name) end)
    if svc then
        status(string.format("สแกน %s (%d/%d)", name, i, #CONFIG.TREE_ROOTS))
        roots[#roots + 1] = {name = name, inst = svc}
        rootCount[name] = indexAll(svc, name)
    end
end
local nilList = {}
pcall(function() nilList = F.getnilinstances() or {} end)
for _, n in ipairs(nilList) do
    pcall(function()
        if n:IsA("ModuleScript") then addModule(n) elseif n:IsA("LocalScript") or n:IsA("Script") then addScript(n) end
    end)
end
local loaded, running = {}, {}
pcall(function()
    for _, m in ipairs(F.getloadedmodules()) do
        loaded[m] = true
        addModule(m)
    end
end)
pcall(function()
    for _, s in ipairs(F.getrunningscripts()) do running[s] = true end
end)

for i, r in ipairs(roots) do
    status(string.format("เขียน tree %s (%d/%d)", r.name, i, #roots))
    local lines = {"== " .. r.name .. " — " .. (rootCount[r.name] or 0) .. " instance (ชิ้นชื่อซ้ำเกิน " .. CONFIG.COLLAPSE_SAME .. " ถูกย่อ) =="}
    local skip = nil
    if r.name == "Players" then
        skip = {}
        pcall(function() skip[lp:FindFirstChildOfClass("PlayerGui")] = true end)
    end
    dumpTree(r.inst, lines, skip)
    save(string.format("03_tree_%s.txt", r.name), lines)
end

status("remotes / attributes / tags / prompts / values / assets / จุดสำคัญ")
do
    table.sort(idx.remotes)
    local body = table.concat(idx.remotes, "\n")
    save("01_remotes.txt", {"== Remote / Bindable ทั้งหมด (" .. #idx.remotes .. ") — ใครรับ/ใครยิงดู 16, ใช้ที่ไหนในโค้ดดู 18 ==", body})
    local attrBody = table.concat(idx.attrs, "\n")
    save("04_attributes.txt", {"== Instance ที่มี Attribute (" .. #idx.attrs .. ") ==", attrBody})
    addCorpus("04_attributes", attrBody)
    local tagLines = {}
    pcall(function()
        local tags = CS:GetAllTags()
        table.sort(tags)
        tagLines[1] = "== CollectionService tags (" .. #tags .. ") =="
        for _, tag in ipairs(tags) do
            local list = CS:GetTagged(tag)
            tagLines[#tagLines + 1] = string.format("#%s  (%d)", tag, #list)
            for i = 1, math.min(#list, 150) do tagLines[#tagLines + 1] = "    " .. fullName(list[i]) .. "  " .. posOf(list[i]) end
            if #list > 150 then tagLines[#tagLines + 1] = "    … +" .. (#list - 150) end
            breathe()
        end
    end)
    save("05_tags.txt", tagLines)
    save("08_prompts.txt", {"== ProximityPrompt / ClickDetector (" .. #idx.prompts .. ") ==", table.concat(idx.prompts, "\n")})
    local valBody = table.concat(idx.values, "\n")
    save("09_values.txt", {"== ValueBase ทั้งหมด (" .. #idx.values .. ") ==", valBody})
    addCorpus("09_values", valBody)
    local poi = {"== จุดสำคัญใน Workspace: ชื่อ Model → ตำแหน่ง (ใช้ทำวาป) — สูงสุด " .. CONFIG.POI_MAX_PER_NAME .. " ตำแหน่ง/ชื่อ =="}
    local names = {}
    for n in pairs(idx.poi) do names[#names + 1] = n end
    table.sort(names)
    for _, n in ipairs(names) do
        poi[#poi + 1] = string.format("%s  (%d ชิ้น)", n, idx.models[n] or 0)
        for _, e in ipairs(idx.poi[n]) do poi[#poi + 1] = "    " .. e end
    end
    save("22_positions.txt", poi)
    save("23_assets.txt", {"== Asset ID ที่ใช้ (" .. (function() local c = 0 for _ in pairs(idx.assets) do c += 1 end return c end)() .. ") — จำนวนครั้ง / id / ชนิด / ตัวอย่าง ==",
        (function()
            local arr = {}
            for id, e in pairs(idx.assets) do arr[#arr + 1] = {id, e} end
            table.sort(arr, function(a, b) return a[2].n > b[2].n end)
            local out = {}
            for _, x in ipairs(arr) do out[#out + 1] = string.format("%6d  %-44s %-26s %s", x[2].n, x[1], x[2].kind, x[2].ex) end
            return table.concat(out, "\n")
        end)()})
end

status("world / ผู้เล่น / GUI")
do
    local function props(inst, list)
        local out = {}
        for _, p in ipairs(list) do
            local ok, v = pcall(function() return inst[p] end)
            if ok then out[#out + 1] = "  " .. p .. " = " .. short(v) end
        end
        return table.concat(out, "\n")
    end
    local L = game:GetService("Lighting")
    local wl = {
        "== Workspace ==", props(workspace, {"Gravity", "StreamingEnabled", "StreamingTargetRadius", "StreamingMinRadius", "FallenPartsDestroyHeight", "DistributedGameTime"}),
        "== Terrain ==", props(workspace.Terrain, {"MaxExtents", "WaterColor", "WaterWaveSize", "WaterTransparency"}),
        "== Camera ==", props(workspace.CurrentCamera, {"CFrame", "FieldOfView", "CameraType"}),
        "== Lighting ==", props(L, {"ClockTime", "TimeOfDay", "Brightness", "Ambient", "OutdoorAmbient", "FogEnd", "FogColor", "GlobalShadows", "ExposureCompensation"}),
    }
    for _, c in ipairs(L:GetChildren()) do
        wl[#wl + 1] = "  • " .. c.Name .. " [" .. c.ClassName .. "] " .. table.concat(propParts(c), " ")
    end
    wl[#wl + 1] = "== Players =="
    wl[#wl + 1] = props(Players, {"MaxPlayers", "RespawnTime", "CharacterAutoLoads"})
    for _, p in ipairs(Players:GetPlayers()) do
        local a = attrParts(p)
        wl[#wl + 1] = string.format("  • %s (@%s) UserId %d Team %s%s", p.DisplayName, p.Name, p.UserId, tostring(p.Team), a and ("  @{" .. table.concat(a, ", ") .. "}") or "")
    end
    wl[#wl + 1] = "== Teams =="
    for _, t in ipairs(game:GetService("Teams"):GetChildren()) do wl[#wl + 1] = "  • " .. t.Name .. " " .. table.concat(propParts(t), " ") end
    save("15_world.txt", wl)

    local ov = {"== ลูกชั้นแรกของ Workspace ==", string.format("%-34s %-16s %8s  %s", "ชื่อ", "class", "ลูกหลาน", "ตำแหน่ง")}
    for _, c in ipairs(workspace:GetChildren()) do
        local n = 0
        pcall(function() n = #c:GetDescendants() end)
        ov[#ov + 1] = string.format("%-34s %-16s %8d  %s", c.Name, c.ClassName, n, posOf(c))
    end
    save("14_map_overview.txt", ov)

    local pl = {
        "== LocalPlayer ==",
        string.format("Name=%s  DisplayName=%s  UserId=%d  AccountAge=%d  Team=%s  Membership=%s", lp.Name, lp.DisplayName, lp.UserId, lp.AccountAge, tostring(lp.Team), tostring(lp.MembershipType)),
        "", "== Attributes ของผู้เล่น ==", S(lp:GetAttributes()),
    }
    pcall(function()
        local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        local r = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        pl[#pl + 1] = ""
        pl[#pl + 1] = "== ตัวละคร =="
        pl[#pl + 1] = "Humanoid: " .. (h and table.concat(propParts(h), "  ") or "ไม่มี")
        pl[#pl + 1] = "RootPart: " .. (r and short(r.Position) or "ไม่มี")
        pl[#pl + 1] = "Character attrs: " .. S(lp.Character:GetAttributes())
    end)
    pl[#pl + 1] = ""
    pl[#pl + 1] = "== Tree ของผู้เล่น (ไม่รวม PlayerGui → ดู 07_gui.txt) =="
    local plSkip = {}
    pcall(function() plSkip[lp:FindFirstChildOfClass("PlayerGui")] = true end)
    dumpTree(lp, pl, plSkip)
    save("06_player.txt", pl)
    local gl = {"== PlayerGui (ข้อความในปุ่ม/ร้านค้า/เมนู อยู่ในนี้) =="}
    pcall(function() dumpTree(lp:FindFirstChildOfClass("PlayerGui"), gl) end)
    save("07_gui.txt", gl)
    addCorpus("07_gui", table.concat(gl, "\n"))
end

local handlerCount, buttonCount = 0, 0
if F.getconnections then
    status("getconnections: ใครรับ remote / ปุ่มเรียกอะไร")
    local function connInfo(c)
        local parts = {}
        local fn
        pcall(function() fn = c.Function end)
        if type(fn) == "function" then
            parts[#parts + 1] = fmtFunc(fn)
            pcall(function()
                local scr = getfenv(fn).script
                if typeof(scr) == "Instance" then parts[#parts + 1] = "script=" .. fullName(scr) end
            end)
        end
        pcall(function() if c.ForeignState then parts[#parts + 1] = "(foreign)" end end)
        pcall(function() if c.Enabled == false then parts[#parts + 1] = "(disabled)" end end)
        return #parts > 0 and table.concat(parts, "  ") or "(executor ไม่คืน function)"
    end
    local function connsOf(sig)
        local ok, list = pcall(F.getconnections, sig)
        return (ok and type(list) == "table") and list or {}
    end
    local hl = {"== ใครรับ remote/bindable (getconnections) — function + script + ค่าคงที่ในฟังก์ชัน =="}
    for _, r in ipairs(idx.remoteObjs) do
        breathe()
        local sig
        pcall(function()
            if r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent") then sig = r.OnClientEvent elseif r:IsA("BindableEvent") then sig = r.Event end
        end)
        local list = sig and connsOf(sig) or {}
        local cb
        if r:IsA("RemoteFunction") and F.getcallbackvalue then
            pcall(function() cb = F.getcallbackvalue(r, "OnClientInvoke") end)
        end
        if #list > 0 or type(cb) == "function" then
            handlerCount += 1
            hl[#hl + 1] = string.format("%s  [%s]  %d connection", fullName(r), r.ClassName, #list)
            for _, c in ipairs(list) do hl[#hl + 1] = "    ← " .. connInfo(c) end
            if type(cb) == "function" then hl[#hl + 1] = "    ← OnClientInvoke: " .. fmtFunc(cb) end
        end
    end
    save("16_handlers.txt", hl)
    local bl = {"== ปุ่ม GUI → ฟังก์ชันที่ถูกเรียก (getconnections) — ดู consts จะเห็นชื่อ remote ที่ปุ่มยิง =="}
    for _, b in ipairs(idx.buttons) do
        breathe()
        local txt = ""
        pcall(function()
            if b:IsA("TextButton") and b.Text ~= "" then txt = b.Text
            else
                local l = b:FindFirstChildWhichIsA("TextLabel", true)
                if l then txt = l.Text end
            end
        end)
        local lines = {}
        for _, ev in ipairs({"MouseButton1Click", "Activated", "MouseButton1Down", "MouseButton1Up"}) do
            local sig
            pcall(function() sig = b[ev] end)
            for _, c in ipairs(sig and connsOf(sig) or {}) do lines[#lines + 1] = "    " .. ev .. " ← " .. connInfo(c) end
        end
        if #lines > 0 then
            buttonCount += 1
            bl[#bl + 1] = fullName(b) .. (txt ~= "" and ("  \"" .. txt:sub(1, 60) .. "\"") or "")
            for _, l in ipairs(lines) do bl[#bl + 1] = l end
        end
    end
    save("17_gui_handlers.txt", bl)
end
report[#report + 1] = string.format("Handlers: remote ที่มีคนรับ %d • ปุ่มที่มี handler %d%s", handlerCount, buttonCount, F.getconnections and "" or " (ไม่มี getconnections)")

do
    local RF = game:GetService("ReplicatedFirst")
    local modIndex = {"== ModuleScript (" .. #idx.modules .. ") — ok/error/timeout/skip ==", "skip = ยังไม่ถูกเกมโหลด และไม่ได้อยู่ใน ReplicatedStorage/First (กันไปรันโค้ดที่เกมยังไม่ได้เรียก) หรือเป็นสคริปต์มาตรฐานของ Roblox", ""}
    local okN, errN = 0, 0
    for i, m in ipairs(idx.modules) do
        if i > CONFIG.MAX_MODULES then
            modIndex[#modIndex + 1] = "… ถึงลิมิต MAX_MODULES"
            break
        end
        if i % 10 == 1 then status(string.format("require modules %d/%d", i, math.min(#idx.modules, CONFIG.MAX_MODULES))) end
        local path = fullName(m)
        local allowed = not skipPath(path) and (loaded[m] or m:IsDescendantOf(RS) or m:IsDescendantOf(RF))
        if not allowed then
            modIndex[#modIndex + 1] = string.format("%-8s %s", "skip", path)
        else
            local st, res = withTimeout(CONFIG.MODULE_TIMEOUT, require, m)
            local fname = string.format("modules/%03d_%s.txt", i, safe(path))
            if st == "ok" then
                local body = S(res)
                save(fname, {"-- " .. path, "-- type: " .. typeof(res), "", body})
                addCorpus("module:" .. path, body)
                modIndex[#modIndex + 1] = string.format("%-8s %s  →  %s", "ok", path, fname)
                okN += 1
            else
                modIndex[#modIndex + 1] = string.format("%-8s %s  %s", st, path, st == "error" and tostring(res) or "")
                errN += 1
            end
        end
    end
    save("02_modules_index.txt", modIndex)
    report[#report + 1] = string.format("Modules: require ได้ %d • พัง/ค้าง %d • ทั้งหมด %d", okN, errN, #idx.modules)
end

if CONFIG.DECOMPILE and F.decompile then
    local queue, seenHash, sIndex = {}, {}, {}
    local dupN = 0
    for _, s in ipairs(idx.scripts) do queue[#queue + 1] = s end
    for _, m in ipairs(idx.modules) do queue[#queue + 1] = m end
    pcall(function()
        for _, s in ipairs(F.getscripts()) do
            if typeof(s) == "Instance" and not seenScript[s] and not seenMod[s] then queue[#queue + 1] = s end
        end
    end)
    local jobs = {}
    for _, s in ipairs(queue) do
        local path = fullName(s)
        if not skipPath(path) and #jobs < CONFIG.MAX_DECOMPILE then
            local h
            if F.getscripthash then pcall(function() h = F.getscripthash(s) end) end
            if h and seenHash[h] then
                dupN += 1
                sIndex[#sIndex + 1] = string.format("dup      %s  (โค้ดเหมือน %s)", path, seenHash[h])
            else
                if h then seenHash[h] = path end
                jobs[#jobs + 1] = {inst = s, path = path}
            end
        end
    end
    local nextJob, done, finished, okN, failN = 0, 0, 0, 0, 0
    local function worker()
        while true do
            nextJob += 1
            local i = nextJob
            local j = jobs[i]
            if not j then return end
            local st, src = withTimeout(CONFIG.DECOMPILE_TIMEOUT, F.decompile, j.inst)
            if st == "ok" and type(src) == "string" and #src > 0 then
                local fname = string.format("scripts/%03d_%s.lua", i, safe(j.path))
                save(fname, "-- " .. j.path .. "  [" .. j.inst.ClassName .. "]" .. (running[j.inst] and "  (กำลังรัน)" or "") .. "\n" .. src)
                addCorpus(j.path, src)
                j.res = "ok       " .. j.path .. "  →  " .. fname
                okN += 1
            else
                j.res = string.format("%-8s %s", st, j.path)
                failN += 1
            end
            done += 1
            if done % 3 == 0 then status(string.format("decompile %d/%d (ทำพร้อมกัน %d)", done, #jobs, CONFIG.DECOMPILE_WORKERS)) end
        end
    end
    for _ = 1, math.max(1, CONFIG.DECOMPILE_WORKERS) do
        task.spawn(function()
            pcall(worker)
            finished += 1
        end)
    end
    repeat task.wait(0.25) until finished >= math.max(1, CONFIG.DECOMPILE_WORKERS)
    local out = {string.format("== Decompile: ok %d • fail %d • ซ้ำ(ข้าม) %d • ข้ามสคริปต์มาตรฐาน Roblox ==", okN, failN, dupN)}
    for _, j in ipairs(jobs) do out[#out + 1] = j.res or ("?        " .. j.path) end
    for _, l in ipairs(sIndex) do out[#out + 1] = l end
    save("10_scripts_index.txt", out)
    report[#report + 1] = string.format("Decompile: ok %d • fail %d • ซ้ำ %d", okN, failN, dupN)
else
    report[#report + 1] = "Decompile: ไม่รองรับ/ปิด"
end

status("cross-reference remote + keyword")
do
    local function linesOf(e)
        if not e.lines then
            local t = {}
            for l in (e.text .. "\n"):gmatch("(.-)\n") do t[#t + 1] = l end
            e.lines = t
        end
        return e.lines
    end
    local function search(term, maxHits, ci, out)
        local hits = 0
        local needle = ci and term:lower() or term
        for _, e in ipairs(corpus) do
            breathe()
            local hay = e.text
            if ci then
                e.lower = e.lower or hay:lower()
                hay = e.lower
            end
            if hay:find(needle, 1, true) then
                for ln, l in ipairs(linesOf(e)) do
                    if (ci and l:lower() or l):find(needle, 1, true) then
                        hits += 1
                        out[#out + 1] = string.format("    %s:%d  %s", e.name, ln, (l:gsub("^%s+", "")):sub(1, 220))
                        if hits >= maxHits then
                            out[#out + 1] = "    … (ตัดที่ " .. maxHits .. ")"
                            return hits
                        end
                    end
                end
            end
        end
        return hits
    end
    local xr = {"== Remote/Bindable ถูกใช้ที่ไหนในโค้ด (decompile + module) — ดู args ที่ส่งจริงตรงบรรทัด FireServer/InvokeServer =="}
    local seenName = {}
    for _, r in ipairs(idx.remoteObjs) do
        local n = r.Name
        if #n >= 3 and not seenName[n] then
            seenName[n] = true
            local block = {}
            local hits = search(n, CONFIG.XREF_MAX_HITS, false, block)
            xr[#xr + 1] = string.format("%s  [%s]  %s  — %d จุด", n, r.ClassName, fullName(r), hits)
            for _, l in ipairs(block) do xr[#xr + 1] = l end
        end
    end
    save("18_remote_usage.txt", xr)
    local kw = {"== Keyword ที่น่าสนใจ (ไม่สนตัวพิมพ์เล็กใหญ่) — หา admin/debug/ราคา/โอกาส/anti-cheat =="}
    for _, k in ipairs(CONFIG.KEYWORDS) do
        local block = {}
        local hits = search(k, CONFIG.KEYWORD_MAX_HITS, true, block)
        if hits > 0 then
            kw[#kw + 1] = string.format("#%s — %d จุด", k, hits)
            for _, l in ipairs(block) do kw[#kw + 1] = l end
        end
    end
    save("19_keywords.txt", kw)
    report[#report + 1] = string.format("Cross-ref: ค้นใน %d แหล่ง (สคริปต์+module+attribute+value+GUI)", #corpus)
end

if CONFIG.SCRIPT_ENVS and F.getsenv then
    status("getsenv ของ LocalScript")
    local el, n = {"== ตัวแปร global ของ LocalScript ที่รันอยู่ (getsenv) — ตัวแปร/ฟังก์ชันที่ไม่ได้ประกาศ local =="}, 0
    for _, s in ipairs(idx.scripts) do
        local path = fullName(s)
        if s:IsA("LocalScript") and not skipPath(path) then
            local ok, env = pcall(F.getsenv, s)
            if ok and type(env) == "table" then
                local keys = {}
                pcall(function()
                    for k in pairs(env) do
                        if k ~= "script" and k ~= "_G" and k ~= "shared" then keys[#keys + 1] = k end
                    end
                end)
                if #keys > 0 then
                    n += 1
                    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
                    el[#el + 1] = path
                    for _, k in ipairs(keys) do
                        local okV, v = pcall(function() return env[k] end)
                        el[#el + 1] = "    " .. tostring(k) .. " = " .. (okV and (type(v) == "table" and S(v, 2):gsub("\n", "\n    ") or scalar(v)) or "?")
                    end
                end
            end
            breathe()
        end
    end
    save("20_script_envs.txt", el)
    report[#report + 1] = "Script envs: " .. n .. " สคริปต์"
end

if CONFIG.GC_SCAN and F.getgc then
    status("getgc: หาตารางข้อมูลใน memory")
    local found = {}
    pcall(function()
        local gc = F.getgc(true)
        local want = {}
        for _, k in ipairs(CONFIG.GC_KEYS) do want[k] = true end
        local seen = {}
        for i, v in ipairs(gc) do
            if i % 3000 == 0 then task.wait() end
            if type(v) == "table" and not seen[v] and v ~= CONFIG and v ~= idx then
                seen[v] = true
                local hit, n = nil, 0
                pcall(function()
                    for k in pairs(v) do
                        n += 1
                        if n > 200 then break end
                        if type(k) == "string" and want[k:lower()] then
                            hit = k
                            break
                        end
                    end
                end)
                if hit then
                    found[#found + 1] = {t = v, key = hit}
                    if #found >= CONFIG.GC_MAX_TABLES then break end
                end
            end
        end
    end)
    local gl = {"== ตารางใน memory ที่มี key น่าสนใจ (" .. table.concat(CONFIG.GC_KEYS, ",") .. ") — มักเป็นข้อมูลผู้เล่นฝั่ง client =="}
    for i, f in ipairs(found) do
        gl[#gl + 1] = string.format("#%d  (เจอ key \"%s\")", i, f.key)
        gl[#gl + 1] = S(f.t, 3)
        breathe()
    end
    save("21_gc_tables.txt", gl)
    report[#report + 1] = "GC scan: เจอ " .. #found .. " ตาราง"
end

status("nil instances / globals")
if #nilList > 0 then
    local nl = {"== Nil instances (" .. #nilList .. ") — ของที่เกมถอดออกจาก tree แต่ยังอยู่ใน memory =="}
    for i, n in ipairs(nilList) do
        if i > 3000 then break end
        pcall(function()
            local a = attrParts(n)
            nl[#nl + 1] = string.format("%-24s %s%s", n.ClassName, n.Name, a and ("  @{" .. table.concat(a, ", ") .. "}") or "")
        end)
    end
    save("11_nil_instances.txt", nl)
end
if F.getrenv then
    pcall(function()
        local renv = F.getrenv()
        save("12_globals.txt", {"== _G ของเกม ==", S(renv._G), "", "== shared ของเกม ==", S(renv.shared)})
    end)
end

local spyMode = "ปิด"
if CONFIG.SPY_MINUTES > 0 then
    local lines = {"== HZ Spy " .. os.date("%X") .. " — C>S = เกมยิงไป server, S>C = server ยิงกลับ, B = Bindable ภายในเกม, from = สคริปต์ที่ยิง =="}
    local on, dirty, rate = true, true, {}
    local function log(dir, remote, args, from)
        if not on then return end
        local path = fullName(remote)
        local key = dir .. path
        local now = os.clock()
        local r = rate[key]
        if not r or now - r.t > 5 then
            if r and r.drop > 0 then lines[#lines + 1] = string.format("         (%s %s ยิงถี่ ตัดไป %d ครั้ง)", dir, path, r.drop) end
            r = {t = now, n = 0, drop = 0}
            rate[key] = r
        end
        r.n += 1
        if r.n > 15 then
            r.drop += 1
            return
        end
        local parts = {}
        for i = 1, args.n do parts[i] = compact(args[i], 0) end
        lines[#lines + 1] = string.format("%s %-10s %s | %s%s", os.date("%X"), dir, path, table.concat(parts, " | "), from and ("   ← from " .. from) or "")
        dirty = true
        if #lines > 30000 then
            on = false
            lines[#lines + 1] = "!! ถึงลิมิต 30000 บรรทัด หยุด spy"
        end
    end
    local conns = 0
    for _, re in ipairs(idx.remoteObjs) do
        pcall(function()
            if re:IsA("RemoteEvent") or re:IsA("UnreliableRemoteEvent") then
                re.OnClientEvent:Connect(function(...) log("S>C", re, table.pack(...)) end)
                conns += 1
            elseif CONFIG.SPY_BINDABLES and re:IsA("BindableEvent") then
                re.Event:Connect(function(...) log("B event", re, table.pack(...)) end)
                conns += 1
            end
        end)
    end
    local DIRS = {FireServer = "C>S", InvokeServer = "C>S invoke", Fire = "B fire", Invoke = "B invoke"}
    local function onCall(self, m, ...)
        if not on then return end
        local dir = DIRS[m]
        if not dir or typeof(self) ~= "Instance" then return end
        if (m == "Fire" or m == "Invoke") and not CONFIG.SPY_BINDABLES then return end
        if F.checkcaller and F.checkcaller() then return end
        -- กรองก่อน spawn (กัน thread flood จาก remote ยิงถี่)
        local path = fullName(self)
        local key = dir .. path
        local now = os.clock()
        local r = rate[key]
        if r and now - r.t <= 5 and r.n >= 15 then
            r.drop += 1
            r.n += 1
            return
        end
        local from
        if F.getcallingscript then
            pcall(function()
                local s = F.getcallingscript()
                if typeof(s) == "Instance" then from = s:GetFullName() end
            end)
        end
        task.spawn(log, dir, self, table.pack(...), from)
    end
    local hooked = nil
    if F.hookmetamethod and F.getnamecallmethod then
        pcall(function()
            local old
            local fn = function(self, ...)
                onCall(self, F.getnamecallmethod(), ...)
                return old(self, ...)
            end
            old = F.hookmetamethod(game, "__namecall", F.newcclosure and F.newcclosure(fn) or fn)
            hooked = "hookmetamethod"
        end)
    end
    if not hooked and F.hookfunction then
        pcall(function()
            local list = {
                {Instance.new("RemoteEvent"), "FireServer"}, {Instance.new("RemoteFunction"), "InvokeServer"},
                {Instance.new("UnreliableRemoteEvent"), "FireServer"},
            }
            if CONFIG.SPY_BINDABLES then
                list[#list + 1] = {Instance.new("BindableEvent"), "Fire"}
                list[#list + 1] = {Instance.new("BindableFunction"), "Invoke"}
            end
            local n, done = 0, {}
            for _, e in ipairs(list) do
                pcall(function()
                    local m = e[2]
                    local target = e[1][m]
                    if done[target] then return end
                    done[target] = true
                    local old
                    local fn = function(self, ...)
                        onCall(self, m, ...)
                        return old(self, ...)
                    end
                    old = F.hookfunction(target, F.newcclosure and F.newcclosure(fn) or fn)
                    n += 1
                end)
            end
            if n > 0 then hooked = "hookfunction (" .. n .. " method)" end
        end)
    end
    if not hooked and F.getrawmetatable and F.setreadonly and F.getnamecallmethod then
        pcall(function()
            local mt = F.getrawmetatable(game)
            local old = mt.__namecall
            F.setreadonly(mt, false)
            mt.__namecall = function(self, ...)
                onCall(self, F.getnamecallmethod(), ...)
                return old(self, ...)
            end
            F.setreadonly(mt, true)
            hooked = "getrawmetatable"
        end)
    end
    spyMode = string.format("ฟังขาเข้า %d ตัว • ดักขาออก: %s • %d นาที", conns, hooked or "hook ไม่ได้ (เห็นแค่ S>C/B event)", CONFIG.SPY_MINUTES)
    task.spawn(function()
        local deadline = os.clock() + CONFIG.SPY_MINUTES * 60
        while on and os.clock() < deadline do
            task.wait(3)
            if dirty then
                dirty = false
                pcall(F.writefile, OUT .. "/13_spy.txt", table.concat(lines, "\n"))
            end
        end
        on = false
        lines[#lines + 1] = "== จบ spy " .. os.date("%X") .. " =="
        pcall(F.writefile, OUT .. "/13_spy.txt", table.concat(lines, "\n"))
        print("[HZDump] spy จบแล้ว → " .. OUT .. "/13_spy.txt")
    end)
end

local feats = {}
for _, n in ipairs(FEATURE_ORDER) do feats[#feats + 1] = n .. (F[n] and " ✓" or " ✗") end
feats[#feats + 1] = "debug.getconstants" .. (dbgConst and " ✓" or " ✗")
local exec = "?"
pcall(function() exec = tostring(F.identifyexecutor()) end)
local streaming = "?"
pcall(function() streaming = tostring(workspace.StreamingEnabled) end)
local rc = {}
for _, r in ipairs(roots) do rc[#rc + 1] = string.format("%8d  %s", rootCount[r.name] or 0, r.name) end
local files = {}
for _, n in ipairs(writtenOrder) do
    if not n:find("^modules/") and not n:find("^scripts/") then files[#files + 1] = string.format("  %-28s %10d bytes", n, written[n]) end
end
files[#files + 1] = "  modules/ + scripts/  (ไฟล์ย่อยแยกตาม module/สคริปต์)"
files[#files + 1] = "  13_spy.txt           (เขียนต่อเรื่อยๆ ระหว่าง spy ทำงาน)"
pcall(function()
    save("index.json", HttpService:JSONEncode({
        place = {name = placeName, placeId = game.PlaceId, gameId = game.GameId, jobId = game.JobId, time = os.date("%Y-%m-%d %H:%M:%S")},
        remotes = idx.remotes,
        files = writtenOrder,
        report = report,
    }))
end)
save("00_summary.txt", {
    "HZ Dumper — " .. os.date("%Y-%m-%d %H:%M:%S"),
    "Place: " .. placeName .. "  |  PlaceId " .. game.PlaceId .. "  |  GameId " .. game.GameId .. "  |  JobId " .. game.JobId,
    "Player: " .. lp.Name .. " (" .. lp.DisplayName .. ")  UserId " .. lp.UserId,
    "Executor: " .. exec,
    "StreamingEnabled: " .. streaming .. "   (true = ของที่อยู่ไกลตัวอาจยังไม่โหลด → เดินรอบแมพแล้วดั้มซ้ำจะได้ครบขึ้น)",
    string.format("ใช้เวลา: %.1f วิ", os.clock() - t0),
    "",
    "== ผลแต่ละส่วน ==",
    table.concat(report, "\n"),
    "Spy: " .. spyMode,
    "", "== executor functions ==", table.concat(feats, "  "),
    "", "== จำนวน instance ต่อ root ==", table.concat(rc, "\n"),
    "", "== Remote " .. #idx.remotes .. " | Module " .. #idx.modules .. " | Script " .. #idx.scripts .. " | ปุ่ม GUI " .. #idx.buttons .. " | Attribute " .. #idx.attrs .. " | Value " .. #idx.values .. " | Prompt " .. #idx.prompts .. " | Nil " .. #nilList,
    "", "== Class ที่เจอบ่อย (top 40) ==", top(idx.class, 40),
    "", "== ชื่อ Model ที่ซ้ำเยอะ (top 60) — มักเป็นไข่/NPC/ของเก็บได้ → ตำแหน่งดู 22 ==", top(idx.models, 60),
    "", "== เริ่มอ่านตรงไหน ==",
    "  หา API ของเกม: 01 remotes → 18 remote_usage (args จริงจากโค้ด) → 16 handlers / 17 gui_handlers → 13 spy (ค่าที่ยิงจริง)",
    "  หาข้อมูลเกม (ราคา/โอกาส/สเตตัส): 02 modules_index → modules/",
    "  หาของแปลก/ช่องโหว่: 19 keywords, 20 script_envs, 21 gc_tables, 11 nil_instances",
    "  ทำวาป: 22 positions, 08 prompts, 14 map_overview",
    "", "== ไฟล์ ==", table.concat(files, "\n"),
})

status("เสร็จ! → Xeno/workspace/" .. OUT)
print("[HZDump] ไฟล์ทั้งหมดอยู่ที่: Xeno/workspace/" .. OUT)
task.delay(12, function() gui:Destroy() end)
end)
if not __ok then
    warn("[HZDump] ERROR: " .. tostring(__err))
    pcall(function() writefile("hzdump_error.txt", tostring(__err)) end)
end
