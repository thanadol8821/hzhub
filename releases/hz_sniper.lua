-- ============================================================
-- HZ SNIPER v4.9 — v4.8 + UI premium + กันเด้ง (retry teleport fail + ยิงสุ่ม 45-110ms human gap) + queue_on_teleport
-- ESP แยกทีม(แดง=ศัตรู/เขียว=เพื่อน/ส้ม★=bounty/⚙=บอท) + ล็อกเป้า + ยิงออโต้(click)
-- FFA* = ทุกคนศัตรูข้ามทีม | Duel/TDM/Boss = แยกทีม Team3 wildcard
-- priority: คนถือธง>bounty>ปกติ>Protecting | Device spoof = มือถือ
-- ไม่มี gc scan / patch IsKeyboard / require / melee — ศูนย์งานหนักต่อเฟรม
-- ============================================================
local G = getgenv and getgenv() or _G
G.__HZESP_GEN = (G.__HZESP_GEN or 0) + 1
local GEN = G.__HZESP_GEN
G.__HZNATIVE_GEN = (G.__HZNATIVE_GEN or 0) + 1 -- ฆ่า loop hz_native/v3 เก่าถ้าเคยรัน
pcall(function()
    if G.__HZNATIVE and G.__HZNATIVE.hold then G.__HZNATIVE.hold(false) end
end)

-- ===== auto-requeue: รันครั้งเดียว รอดการย้าย place (lobby↔arena↔เซิร์ฟใหม่) =====
pcall(function()
    if G.__HZESP_QUEUED then return end
    local q = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
    if not q then return end
    G.__HZESP_QUEUED = true
    q([[task.spawn(function()
        local pid = game.PlaceId
        if pid == 122446657157717 or pid == 126042865144779 then
            task.wait(1.5)
            local ok, f = pcall(readfile, "hz_esp.lua")
            if ok and f then local fn = loadstring(f); if fn then pcall(fn) end end
        end
    end)]])
end)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local RF = game:GetService("ReplicatedFirst")
local RS2 = game:GetService("ReplicatedStorage")
local TPS = game:GetService("TeleportService")
local lp = Players.LocalPlayer

-- ===== HZ HUB backend: พิงสถิติ + kill-switch (ไม่มีคีย์ — admin เห็นแค่ว่าใครใช้) =====
local HZ_API = "https://dry-wave-054e.thanadol821.workers.dev"; local HZ_G = "sniper"
local HZS = game:GetService("HttpService")
local HZ = { last = 0, n = 0, win = os.clock() }
local function hzPing(ev)   -- throttle ≥2s/ครั้ง · ≤45/10นาที (worker cap 60) — executor ไม่มี request = เงียบ
    local req = request or http_request or (syn and syn.request); if not req then return end
    local now = os.clock()
    if now - HZ.last < 2 then return end
    if now - HZ.win > 600 then HZ.win = now; HZ.n = 0 end
    if HZ.n >= 45 then return end
    HZ.last = now; HZ.n += 1
    task.spawn(function() pcall(function()
        req({ Url = HZ_API .. "/ping", Method = "POST", Headers = { ["Content-Type"] = "application/json" },
            Body = HZS:JSONEncode({ ev = ev, g = HZ_G, u = lp.Name, dn = lp.DisplayName, uid = lp.UserId, place = game.PlaceId }) })
    end) end)
end
local function hzMaint(msg)   -- kill-switch on:false → ฆ่าทุกลูป (GEN bump) + ปิด UI + หน้าบำรุงรักษา
    G.__HZESP_GEN = GEN + 1
    local gr = (gethui and gethui()) or game:GetService("CoreGui")
    pcall(function() local o = gr:FindFirstChild("HZESPUI") if o then o:Destroy() end end)
    pcall(function() o = lp.PlayerGui and lp.PlayerGui:FindFirstChild("HZESPUI") if o then o:Destroy() end end)
    local sg2 = Instance.new("ScreenGui"); sg2.Name = "HZESPMaint"; sg2.ResetOnSpawn = false; sg2.DisplayOrder = 9999
    local tx = Instance.new("TextLabel"); tx.AnchorPoint = Vector2.new(0.5, 0.5); tx.Position = UDim2.fromScale(0.5, 0.45)
    tx.Size = UDim2.new(0, 440, 0, 96); tx.BackgroundColor3 = Color3.fromRGB(20, 22, 38); tx.TextColor3 = Color3.fromRGB(240, 240, 255)
    tx.Font = Enum.Font.GothamBold; tx.TextSize = 16; tx.TextWrapped = true
    tx.Text = "🛠 HZ HUB — ปิดปรับปรุงชั่วคราว\n" .. (type(msg) == "string" and msg ~= "" and msg or "กลับมาใหม่เร็วๆ นี้")
    Instance.new("UICorner", tx).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", tx); st.Color = Color3.fromRGB(255, 140, 80); st.Thickness = 1.5
    tx.Parent = sg2; sg2.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    print("[HZESP] maintenance: " .. tostring(msg))
end
task.spawn(function()   -- status poll ทุก 60s — fail-open: เน็ต/worker พลาด = ใช้ต่อได้
    local req = request or http_request or (syn and syn.request); if not req then return end
    task.wait(3)
    while G.__HZESP_GEN == GEN do
        local ok, r = pcall(function() return req({ Url = HZ_API .. "/status?g=" .. HZ_G, Method = "GET" }) end)
        if ok and r and r.Body then
            local ok2, d = pcall(function() return HZS:JSONDecode(r.Body) end)
            if ok2 and type(d) == "table" and d.on == false then hzMaint(d.msg) return end
        end
        task.wait(60)
    end
end)
hzPing("gate")
task.spawn(function() task.wait(6) hzPing("loaded") end)
task.spawn(function() while G.__HZESP_GEN == GEN do task.wait(240) hzPing("alive") end end)

-- ===== auto-retry teleport: วาปพลาดแล้วเกมไม่ลองใหม่ → ลองเอง (กันเด้งตอนย้ายเซิร์ฟ) =====
pcall(function()
    local retrying = false
    TPS.TeleportInitFailed:Connect(function(player, result, msg, placeId, opts)
        if G.__HZESP_GEN ~= GEN or player ~= lp or retrying then return end
        retrying = true
        lg("teleport fail: " .. tostring(msg) .. " — retry")
        for i = 1, 3 do
            task.wait(2 * i)
            local ok = pcall(function()
                if opts then TPS:TeleportAsync(placeId, { lp }, opts)
                else TPS:Teleport(placeId, lp) end
            end)
            if not ok then lg("retry " .. i .. " fail") end
            task.wait(8) -- รอผล — ถ้าสำเร็จ process นี้ตายเอง
        end
        retrying = false
    end)
end)
local guiRoot
pcall(function() guiRoot = (gethui and gethui()) or lp:WaitForChild("PlayerGui", 3) end)
if not guiRoot then pcall(function() guiRoot = lp and lp.PlayerGui end) end
if not guiRoot then pcall(function() guiRoot = game:GetService("CoreGui") end) end
local cam = workspace.CurrentCamera

-- logger throttle — เขียนไฟล์ ≤1 ครั้ง/วิ
local log, sub = {}, nil
local logDirty, lastW = false, 0
local function logFlush()
    if not logDirty then return end
    logDirty = false
    lastW = os.clock()
    pcall(function() writefile("hz_esp_log.txt", table.concat(log, "\n")) end)
end
local function lg(m)
    log[#log + 1] = os.date("%X") .. " " .. m
    if #log > 300 then table.remove(log, 1) end
    logDirty = true
    if os.clock() - lastW >= 1 then logFlush() end
    pcall(function() if sub then sub.Text = m end end)
    print("[HZ] " .. m)
end
task.spawn(function()
    while task.wait(1) do
        if G.__HZESP_GEN ~= GEN then break end
        logFlush()
    end
end)
lg("boot v4-lite gen=" .. GEN .. " guiRoot=" .. tostring(guiRoot ~= nil))

-- ---------- ค่าตาม native AutoAim ของเกม ----------
local CONE_DEG = 35
local MIN_CONE = 1.2
local PULL_HIP = 1.44
local PULL_ADS = 10.0
local SNAP_DEG = 3.5
local FIRE_GAP = 0.05 -- base; ใช้จริงสุ่ม 45-110ms ต่อนัด (กันลายเซ็นบอท 50ms เป๊ะ)

local espOn, aimOn, shootOn, mobileOn = true, false, false, true
local marks = {}
local lockTarget, lockPart
local deadMark = {} -- char -> เวลาหมดอายุ: killfeed เห็นตาย บล็อกเป้าไว้ก่อน attr sync (กันล็อกศพ)
local BUILD = select(2, ...) or {} -- release boot ส่ง {tag, wm, ping,...} มาให้; รันดิบๆ = {}

-- เคลียร์ mark/UI ของ gen เก่า (รันซ้ำไม่ซ้อน)
pcall(function()
    for _, p in ipairs(Players:GetPlayers()) do
        local c = p.Character
        if c then
            local hl = c:FindFirstChild("HZESP")
            if hl then pcall(function() hl:Destroy() end) end
            local bb = c:FindFirstChild("HZESPtag")
            if bb then pcall(function() bb:Destroy() end) end
        end
    end
end)

-- ทีมจริงของเกม: attribute "Team" ("Team1"/"Team2") อยู่บน entity model/char/Player
local function teamOf(p)
    local t
    pcall(function()
        local c = p.Character
        if c then
            t = c:GetAttribute("Team")
            if t == nil then
                -- char อาจเป็นลูกของ entity model — ปีนหา _entity
                local m, g = c, 0
                while m and m ~= workspace and g < 6 do
                    if m:GetAttribute("_entity") ~= nil then
                        t = m:GetAttribute("Team") or t
                        break
                    end
                    m = m.Parent; g = g + 1
                end
            end
        end
        if t == nil then t = p:GetAttribute("Team") end
        if t == nil then
            local ok2, pt = pcall(function() return p.Team end)
            if ok2 and pt ~= nil then t = pt end
        end
        -- normalize เป็น string — attr "Team1" กับ Instance Team ชื่อเดียวกันต้องเท่ากัน
        if t ~= nil then
            if typeof(t) == "Instance" then t = t.Name else t = tostring(t) end
        end
    end)
    return t
end

-- "enemy" | "ally" | "unknown" — ไม่รู้ = ไม่ล็อก (กันยิงเพื่อนตอน attr ยังไม่โหลด)
local myTeam -- sticky: จำทีมเราไว้ กันตอน char หาย (ตาย/กำลังเกิด) แล้วทีมหายตาม
local curMode -- โหมดห้องปัจจุบัน (roomMode loop อัปเดตทุก 2 วิ)
local modeLbl -- UI label โหมด (สร้างทีหลัง)
local function isFFA()
    return type(curMode) == "string" and curMode:sub(1, 3) == "FFA"
end
local function sideOf(p)
    if p == lp then return "self" end
    if isFFA() then return "enemy" end -- FFA/อาร์เคด: เกมใส่ Team เดียวกันหมด (Team3) → ทุกคนศัตรู
    local myT = teamOf(lp)
    if myT ~= nil then myTeam = myT else myT = myTeam end
    local hisT = teamOf(p)
    if myT ~= nil then
        -- Team3 = wildcard (FFA/Boss): ทีมเดียวกันเท่านั้นที่ไม่ใช่ศัตรู (907:36-44)
        if myT == "Team3" or hisT == "Team3" then
            return (myT == hisT) and "ally" or "enemy"
        end
        if hisT == nil then return "unknown" end
        return (myT == hisT) and "ally" or "enemy"
    end
    return "enemy" -- เราไม่มีทีม = FFA/ยังไม่ spawn → ถือเป็นศัตรู
end

local function isEnemy(p)
    return sideOf(p) == "enemy"
end

-- ---------- ตรวจโหมดห้องฟรี: char.GameRoom attr → Room.Data.Mode (09_values:26) ----------
local function roomMode()
    local m
    pcall(function()
        local rn = lp.Character and lp.Character:GetAttribute("GameRoom")
        local rooms = workspace:FindFirstChild("Room")
        if not rooms then return end
        if not rn then
            -- fallback: match World attr → Room.World ObjectValue
            local w = (lp.Character and lp.Character:GetAttribute("World")) or lp:GetAttribute("World")
            if w then
                for _, r in ipairs(rooms:GetChildren()) do
                    local wo = r:FindFirstChild("World")
                    if wo and wo.Value and wo.Value.Name == w then rn = r.Name break end
                end
            end
        end
        if not rn then return end
        local data = rooms:FindFirstChild(rn) and rooms[rn]:FindFirstChild("Data")
        local mv = data and data:FindFirstChild("Mode")
        if mv then m = mv.Value end
    end)
    return m
end

local function paintModeUI()
    if not modeLbl then return end
    pcall(function()
        local m = curMode
        if m == "Duel" then
            modeLbl.Text = "◈ โหมด: ดวล — แยกทีม (เขียว=เรา)"
            modeLbl.TextColor3 = Color3.fromRGB(120, 200, 255)
        elseif isFFA() then
            modeLbl.Text = "◈ โหมด: อาร์เคด — ทุกคนศัตรู"
            modeLbl.TextColor3 = Color3.fromRGB(255, 170, 80)
        elseif m then
            modeLbl.Text = "◈ โหมด: " .. tostring(m)
            modeLbl.TextColor3 = Color3.fromRGB(200, 200, 220)
        else
            modeLbl.Text = "◈ โหมด: —"
            modeLbl.TextColor3 = Color3.fromRGB(140, 140, 160)
        end
    end)
end

task.spawn(function()
    while task.wait(2) do
        if G.__HZESP_GEN ~= GEN then break end
        local m = roomMode()
        if m ~= curMode then
            curMode = m
            if m then lg("mode = " .. tostring(m)) end
            paintModeUI()
        end
    end
end)

local function aliveHead(char, isSelf)
    if not char or not char.Parent then return nil end
    if deadMark[char] and os.clock() < deadMark[char] then return nil end -- killfeed บอกตายแล้ว รอ attr sync
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.Health <= 0 then return nil end
        if hum:GetState() == Enum.HumanoidStateType.Dead then return nil end
    end
    local ok, dead = pcall(function()
        return char:GetAttribute("Dead") == true
            or char:GetAttribute("Alive") == false
            or char:GetAttribute("IsDead") == true
            or char:GetAttribute("State") == "Dead"
            or (char:GetAttribute("Health") ~= nil and char:GetAttribute("Health") <= 0)
            or (char:GetAttribute("HP") ~= nil and char:GetAttribute("HP") <= 0)
    end)
    if ok and dead then return nil end
    local okV, inv = pcall(function()
        -- เกมซ่อน model จริงตอนตาย แล้ว clone ศพ _Died ไป _Temp (893:72-73, 080:77)
        -- isSelf: ตัวเองอาจโดนซ่อนใน FPS cam (FakeArmController) — เช็คแค่ Health/Dead พอ
        if isSelf then return char:GetAttribute("Invisible") == true end
        return char:GetAttribute("vc_Visible") == false
            or char:GetAttribute("vc_Transparency") == 1
            or char:GetAttribute("Invisible") == true
    end)
    if okV and inv then return nil end
    local par = char.Parent
    if (par and par.Name == "_Temp") or char.Name:sub(-5) == "_Died" then return nil end -- ศพ ragdoll
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

-- ===== ESP: Highlight + ป้ายชื่อ =====
local function clear(p)
    local mk = marks[p]
    if mk then
        pcall(function() mk.hl:Destroy() end)
        pcall(function() mk.bb:Destroy() end)
    end
    marks[p] = nil
end

local function attach(p, char, ally)
    local head = aliveHead(char)
    if not head then return nil end
    -- Duel: อย่าฝากเงาไว้กับเกม — เกม Cancel(EnemyXRay_Duel) ทุก entity spawn (915:131-133)
    -- + ใส่เฉพาะตอนเรามีชีพ → เงาหายเกือบทั้งเกม → เราวาดเองทุกโหมด
    local hl = Instance.new("Highlight")
    hl.Name = "HZESP"
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
    if ally then
        hl.FillColor = Color3.fromRGB(60, 220, 110)
        hl.FillTransparency = 0.72
        hl.OutlineColor = Color3.fromRGB(120, 255, 150)
        hl.OutlineTransparency = 0.1
    else
        hl.FillColor = Color3.fromRGB(255, 40, 40)
        hl.FillTransparency = 0.6
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
    end
    local bb = Instance.new("BillboardGui")
    bb.Name = "HZESPtag"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 130, 0, 16)
    bb.StudsOffset = Vector3.new(0, 2.4, 0)
    bb.AlwaysOnTop = true
    bb.Parent = char
    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1, 0, 1, 0)
    nm.BackgroundTransparency = 1
    nm.Font = Enum.Font.GothamBold
    nm.TextSize = 12
    local bounty = false
    pcall(function() bounty = p:GetAttribute("IsBounty") == true end)
    if ally then
        nm.TextColor3 = Color3.fromRGB(90, 220, 120)
        nm.TextStrokeTransparency = 0.6
        nm.TextTransparency = 0.25
    elseif bounty then
        nm.TextColor3 = Color3.fromRGB(255, 160, 40) -- bounty = ส้ม ★
        nm.TextStrokeTransparency = 0.4
    else
        nm.TextColor3 = Color3.fromRGB(255, 80, 80)
        nm.TextStrokeTransparency = 0.4
    end
    nm.Text = (bounty and "★ " or "") .. p.Name
    nm.Parent = bb
    return { hl = hl, bb = bb, char = char, ally = ally }
end

local function sweepESP()
    local seen = {}
    for _, p in ipairs(Players:GetPlayers()) do
        seen[p] = true
        local char = p.Character
        local mk = marks[p]
        local side = sideOf(p)
        if (side == "enemy" or side == "ally") and char and char.Parent and aliveHead(char) then
            local ally = side == "ally"
            local wantHl = true -- วาดเงาเองทุกโหมด (Duel: เกมลบ XRay ตอน spawn อยู่แล้ว)
            if not mk or mk.char ~= char or mk.ally ~= ally
                or (mk.hl ~= nil) ~= wantHl
                or (mk.hl and not mk.hl.Parent) or (mk.bb and not mk.bb.Parent) then
                clear(p)
                local o1, o2 = char:FindFirstChild("HZESP"), char:FindFirstChild("HZESPtag")
                if o1 then pcall(function() o1:Destroy() end) end
                if o2 then pcall(function() o2:Destroy() end) end
                local ok, nm = pcall(attach, p, char, ally)
                if ok and nm then marks[p] = nm end
            end
        elseif mk then
            clear(p)
        end
    end
    for p in pairs(marks) do
        if not seen[p] then clear(p) end
    end
end

Players.PlayerRemoving:Connect(function(p)
    if G.__HZESP_GEN ~= GEN then return end
    clear(p)
end)

-- ===== บอท/entity ที่ไม่ใช่ Player (อาร์เคดมีบอท — dump: World.<id>.Entities.* _entity attr) =====
local botMarks, botList = {}, {}
local TEAM_MODES = { Duel = true, TDM = true, TDM_CaptureFlag = true, Boss = true }

local function myWorld()
    local w
    pcall(function()
        w = lp.Character and lp.Character:GetAttribute("World")
        if not w then w = lp:GetAttribute("World") end
    end)
    return w
end

local function entityTeamOf(m)
    local ok, t = pcall(function() return m:GetAttribute("Team") end)
    return (ok and t ~= nil) and tostring(t) or nil
end

local function botIsEnemy(m)
    if isFFA() then return true end -- อาร์เคด: บอททุกตัวศัตรู
    local myT = teamOf(lp) -- อ่านสดก่อน sticky ค่าเก่าอาจตกค้างข้ามโหมด
    if myT ~= nil then myTeam = myT else myT = myTeam end
    local hisT = entityTeamOf(m)
    if myT and hisT then
        if myT == "Team3" or hisT == "Team3" then return myT ~= hisT end
        return myT ~= hisT
    end
    if TEAM_MODES[curMode] then return false end -- โหมดทีมแต่ไม่รู้ฝั่งบอท = ปลอดภัยไว้
    return true -- FFA: ไม่มีทีม = ศัตรู
end

local function eachBot(fn)
    local worlds = workspace:FindFirstChild("World")
    if not worlds then return end
    local myW = myWorld()
    for _, wd in ipairs(worlds:GetChildren()) do
        local ents = wd:FindFirstChild("Entities")
        if ents then
            for _, m in ipairs(ents:GetChildren()) do
                if m:IsA("Model") and m:GetAttribute("_entity") ~= nil
                    and not Players:FindFirstChild(m.Name)
                    and (not myW or m:GetAttribute("World") == nil or m:GetAttribute("World") == myW) then
                    fn(m)
                end
            end
        end
    end
end

local function botAlive(m)
    if not m or not m.Parent then return false end
    local ok, dead = pcall(function()
        local h = m:GetAttribute("Health")
        if h ~= nil and h <= 0 then return true end
        local st = m:GetAttribute("State")
        if st == "Dead" or st == "Die" then return true end
        if m:GetAttribute("vc_Visible") == false then return true end
        if m:GetAttribute("vc_Transparency") == 1 then return true end
        return false
    end)
    if ok and dead then return false end
    return true
end

local function botName(m)
    local ok, s = pcall(function() return m:GetAttribute("_entityModel") end)
    if ok and type(s) == "string" then
        return s:match("([^%.]+)$") or s
    end
    return m.Name
end

local function clearBot(m)
    local mk = botMarks[m]
    if mk then
        pcall(function() mk.hl:Destroy() end)
        pcall(function() mk.bb:Destroy() end)
    end
    botMarks[m] = nil
end

local function sweepBots()
    local nw, seen = {}, {}
    eachBot(function(m)
        if botIsEnemy(m) and botAlive(m) then
            nw[#nw + 1] = m
            seen[m] = true
            local mk = botMarks[m]
            local wantHl = true
            if not mk or (mk.hl ~= nil) ~= wantHl
                or (mk.hl and not mk.hl.Parent) or (mk.bb and not mk.bb.Parent) then
                clearBot(m)
                local head = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
                if head then
                    pcall(function()
                        local hl
                        if wantHl then
                            hl = Instance.new("Highlight")
                            hl.Name = "HZESP"
                            hl.Adornee = m
                            hl.FillColor = Color3.fromRGB(255, 40, 40)
                            hl.FillTransparency = 0.6
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.OutlineTransparency = 0
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = m
                        end
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "HZESPtag"
                        bb.Adornee = head
                        bb.Size = UDim2.new(0, 150, 0, 14)
                        bb.StudsOffset = Vector3.new(0, 2.4, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = m
                        local nm = Instance.new("TextLabel")
                        nm.Size = UDim2.new(1, 0, 1, 0)
                        nm.BackgroundTransparency = 1
                        nm.Font = Enum.Font.GothamBold
                        nm.TextSize = 11
                        nm.TextColor3 = Color3.fromRGB(255, 110, 110)
                        nm.TextStrokeTransparency = 0.5
                        nm.Text = "⚙ " .. botName(m)
                        nm.Parent = bb
                        botMarks[m] = { hl = hl, bb = bb }
                    end)
                end
            end
        end
    end)
    botList = nw
    for m in pairs(botMarks) do
        if not seen[m] or not espOn then clearBot(m) end
    end
end

task.spawn(function()
    while task.wait(1) do
        if G.__HZESP_GEN ~= GEN then break end
        if espOn then pcall(sweepESP); pcall(sweepBots)
        else
            for p in pairs(marks) do clear(p) end
            for m in pairs(botMarks) do clearBot(m) end
        end
    end
end)

-- ===== AimLock + AutoShoot =====
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
pcall(function() rayParams.CollisionGroup = "CanCollide" end)

local rayFilter = {}
local function visible(char, part)
    local n = 0
    if lp.Character then n = n + 1; rayFilter[n] = lp.Character end
    n = n + 1; rayFilter[n] = char
    rayFilter[n + 1] = nil
    rayParams.FilterDescendantsInstances = rayFilter
    local dir = part.Position - cam.CFrame.Position
    local hit = workspace:Raycast(cam.CFrame.Position, dir, rayParams)
    return hit == nil
end

-- hitbox จริงของเกมก่อน: Collider.Head (1.2³) → Collider.Body → part ปกติ
local PART_ORDER = { "Head", "UpperTorso", "Torso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "Left Arm", "Right Arm" }
local function aimPart(char)
    local col = char:FindFirstChild("Collider")
    if col then
        for _, n in ipairs({ "Head", "Body", "HumanoidRootPart" }) do
            local pt = col:FindFirstChild(n)
            if pt and pt:IsA("BasePart") and visible(char, pt) then return pt end
        end
    end
    for _, n in ipairs(PART_ORDER) do
        local pt = char:FindFirstChild(n)
        if pt and pt:IsA("BasePart") and visible(char, pt) then return pt end
    end
    return nil
end

local function angErr(pos)
    local dir = (pos - cam.CFrame.Position).Unit
    return math.deg(math.acos(math.clamp(cam.CFrame.LookVector:Dot(dir), -1, 1)))
end

local function coneDeg(dist)
    return math.max(MIN_CONE, CONE_DEG / math.max(dist / 24, 1))
end

local function findTarget()
    local best, bestErr, bestPart
    local minV = math.min(cam.ViewportSize.X, cam.ViewportSize.Y) * 0.15
    local cand = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character then cand[#cand + 1] = { char = p.Character, pl = p } end
    end
    for _, m in ipairs(botList) do
        if botAlive(m) then cand[#cand + 1] = { char = m } end -- กันบอทค้างตายระหว่าง sweep/ตอนปิด ESP
    end
    for _, c2 in ipairs(cand) do
        local char = c2.char
        local head = aliveHead(char)
        if head then
            local dist = (head.Position - cam.CFrame.Position).Magnitude
            if dist <= 1000 then
                local err = angErr(head.Position)
                local lim = coneDeg(dist) * ((char == lockTarget) and 1.5 or 1)
                local nearOk = true
                if dist > 60 then
                    local v, onScr = cam:WorldToViewportPoint(head.Position)
                    if not onScr then nearOk = false end
                    if nearOk then
                        local c = Vector2.new(v.X - cam.ViewportSize.X / 2, v.Y - cam.ViewportSize.Y / 2)
                        if math.abs(c.X) > minV or math.abs(c.Y) > minV then nearOk = false end
                    end
                end
                if nearOk and err < lim then
                    -- score ปรับตามเป้าพิเศษ (917:151-170 flag ใต้ HRP, 898:13-15 Protecting attachment)
                    local score = err
                    local okS, flag = pcall(function()
                        local r = char:FindFirstChild("HumanoidRootPart")
                        return r and r:FindFirstChild("Flag")
                    end)
                    if okS and flag then score = score * 0.5 end -- คนถือธง = เป้าหลัก
                    local okP, prot = pcall(function()
                        return char:FindFirstChild("Protecting", true)
                    end)
                    if okP and prot then score = score * 2 end -- เพิ่งเกิด ป้องกันอยู่ = ไม่คุ้ม
                    if c2.pl then
                        local okB, bunty = pcall(function() return c2.pl:GetAttribute("IsBounty") end)
                        if okB and bunty == true then score = score * 0.7 end
                    end
                    if not bestErr or score < bestErr then
                        local ap = aimPart(char)
                        if ap then best, bestErr, bestPart = char, score, ap end
                    end
                end
            end
        end
    end
    return best, bestPart
end

local function clickFire()
    if mouse1press and mouse1release then
        pcall(mouse1press)
        task.delay(0.02, function() pcall(mouse1release) end)
        return
    end
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(1, 1, 0, true, game, 1)
        task.delay(0.02, function()
            VIM:SendMouseButtonEvent(1, 1, 0, false, game, 1)
        end)
    end)
end



-- ===== TargetDetect debug: เกมบอกเองว่าเล็งชี้ใคร (ทุก 3 วิ) =====
task.spawn(function()
    while task.wait(3) do
        if G.__HZESP_GEN ~= GEN then break end
        pcall(function()
            local td = RF:FindFirstChild("TargetDetect")
            if not td then return end
            local tv = td:FindFirstChild("Target")
            local v = tv and tv:IsA("ObjectValue") and tv.Value
            if typeof(v) == "Instance" then
                lg("TD -> " .. tostring(v.Parent and v.Parent.Name or v.Name))
            end
        end)
    end
end)

-- ===== Device spoof: ยิง Remote.Any.Device("Mobile") → server เซ็ต attr → คนอื่นเห็นมือถือ =====
local devRem, devLogged = nil, false
task.spawn(function()
    while task.wait(3) do
        if G.__HZESP_GEN ~= GEN then break end
        pcall(function()
            if not mobileOn then return end
            if not devRem then
                local r = RS2:FindFirstChild("Remote")
                r = r and r:FindFirstChild("Any")
                local d = r and r:FindFirstChild("Device")
                if d and d:IsA("RemoteEvent") then devRem = d end
            end
            if devRem and lp:GetAttribute("Device") ~= "Mobile" then
                devRem:FireServer("Mobile")
                if not devLogged then
                    task.delay(0.6, function()
                        pcall(function()
                            lg("device = " .. tostring(lp:GetAttribute("Device")))
                        end)
                    end)
                    devLogged = true
                end
            end
        end)
    end
end)

local lastShot = 0
local nextShot = 0 -- นัดถัดไป = สุ่ม human-like gap
local fireT, fireN = nil, 0 -- นับยิงต่อเป้า — log สรุปตอนเปลี่ยนเป้า/หยุดยิง (กัน spam)
local function fireFlush()
    if fireN > 0 then lg("FIRE x" .. fireN .. " -> " .. tostring(fireT)) end
    fireT, fireN = nil, 0
end

-- ===== Killfeed -> ปลดล็อกทันที: Remote.GameService.GameClient.Killed (025:55-72) =====
-- args = (Killer, Victim, time, extra); Victim อาจเป็น Player หรือ GameClient wrapper (.Instance)
task.spawn(function()
    local r = RS2:FindFirstChild("Remote")
    r = r and r:FindFirstChild("GameService")
    r = r and r:FindFirstChild("GameClient")
    local k = r and r:FindFirstChild("Killed")
    if not (k and k:IsA("RemoteEvent")) then return end
    k.OnClientEvent:Connect(function(_, victim)
        if G.__HZESP_GEN ~= GEN then return end
        pcall(function()
            local inst = typeof(victim) == "Instance" and victim
                or (victim and (victim.Instance or victim.Player))
            local nm = typeof(inst) == "Instance" and inst.Name
                or (type(victim) == "table" and victim.Name) or nil
            if type(nm) ~= "string" then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == nm and p.Character then
                    deadMark[p.Character] = os.clock() + 3
                end
            end
            if lockTarget and lockTarget.Name == nm then
                lg("KILL -> " .. nm)
                fireFlush()
                lockTarget, lockPart = nil, nil
            end
        end)
    end)
    lg("killfeed hooked")
end)

pcall(function() RS:UnbindFromRenderStep("HZAim") end) -- กันซ้อนจาก gen เก่า
RS:BindToRenderStep("HZAim", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if G.__HZESP_GEN ~= GEN then return end
    pcall(function()
        cam = workspace.CurrentCamera
        if not cam then return end
        if not (aimOn or shootOn) then lockTarget = nil; return end
        if not aliveHead(lp.Character, true) then lockTarget = nil; return end -- กันยิงตอนตาย/spectate
        lockTarget, lockPart = findTarget()
        if not lockTarget then return end
        if fireN > 0 and os.clock() - lastShot > 2 then fireFlush() end
        local head = aliveHead(lockTarget)
        if not head then fireFlush(); lockTarget = nil; lockPart = nil; return end
        local aimPt = lockPart or head
        local aimPos = aimPt.Position
        local root = lockTarget:FindFirstChild("HumanoidRootPart")
        if not root then
            local col = lockTarget:FindFirstChild("Collider")
            root = col and col:FindFirstChild("HumanoidRootPart") or lockTarget.PrimaryPart
        end
        if root then
            local vel = root.AssemblyLinearVelocity or root.Velocity
            local dist = (aimPos - cam.CFrame.Position).Magnitude
            aimPos = aimPos + vel * math.clamp(dist / 900, 0, 0.25)
        end
        local goal = CFrame.lookAt(cam.CFrame.Position, aimPos)
        local err = angErr(aimPos)
        if shootOn and err <= SNAP_DEG then
            -- micro-snap + ยิงเฟรมเดียว — gap สุ่ม 45-110ms เหมือนคลิกมือ (กัน anti-cheat เห็น 50ms เป๊ะ)
            if os.clock() >= nextShot then
                lastShot = os.clock()
                nextShot = lastShot + 0.045 + math.random() * 0.065
                cam.CFrame = goal
                pcall(clickFire)
                local tn = lockTarget.Name
                if tn ~= fireT then fireFlush(); fireT = tn end
                fireN = fireN + 1
            end
        else
            -- ดูดนุ่มแบบ native aim assist
            local rate = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and PULL_ADS or PULL_HIP
            cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(rate * dt, 0, 0.25))
        end
    end)
end)

-- ============================================================
-- UI — HZ HUB premium v4.9c: layered glass depth + live strip
--   wipe intro · staggered reveal · rotating accent beams
--   shine sweep · breathing halo 2 ชั้น · pill toggles · fold
--   tri-stop accent ramp · Kanit Thai font · aura glow · pill breathe
-- ============================================================
pcall(function()
    local old = guiRoot and guiRoot:FindFirstChild("HZESPUI")
    if old then old:Destroy() end
    local oldN = guiRoot and guiRoot:FindFirstChild("HZNative")
    if oldN then oldN:Destroy() end
end)

local Tween = game:GetService("TweenService")
local C = {
    bgTop    = Color3.fromRGB(21, 26, 44),    -- panel navy บน
    bgBot    = Color3.fromRGB(10, 13, 22),    -- panel navy ล่าง (gradient ตั้ง)
    sect     = Color3.fromRGB(15, 19, 32),    -- section ชั้นใน (recessed)
    card     = Color3.fromRGB(26, 31, 50),    -- การ์ดแถว
    cardHov  = Color3.fromRGB(38, 45, 70),    -- การ์ดตอน hover
    edge     = Color3.fromRGB(64, 73, 108),   -- ขอบเส้นบาง
    edgeSoft = Color3.fromRGB(40, 46, 70),    -- ขอบนุ่มชั้นใน
    accent   = Color3.fromRGB(90, 140, 255),  -- accent น้ำเงิน #5A8CFF (คำว่า HUB)
    accent2  = Color3.fromRGB(158, 112, 255), -- accent ม่วง #9E70FF (gradient กลาง)
    accent3  = Color3.fromRGB(224, 108, 240), -- accent แมเจนตา #E06CF0 (gradient ปลาย)
    amber    = Color3.fromRGB(255, 190, 92),  -- accent แถว autofire
    teal     = Color3.fromRGB(94, 220, 200),  -- accent แถว mobile
    off      = Color3.fromRGB(46, 52, 74),    -- pill off
    txt      = Color3.fromRGB(236, 240, 251),
    dim      = Color3.fromRGB(133, 143, 168),
    dimIcon  = Color3.fromRGB(150, 160, 190), -- ไอคอน off สว่างขึ้น อ่าน glyph ง่าย
    ok       = Color3.fromRGB(84, 222, 132),  -- พร้อม
    lock     = Color3.fromRGB(255, 96, 104),  -- ล็อกเป้าอยู่
}
local function tw(obj, t, props, style, dir)
    Tween:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end
local function corner(obj, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = obj; return c
end
local function stroke(obj, col, tr)
    local s = Instance.new("UIStroke"); s.Color = col; s.Transparency = tr or 0.5; s.Thickness = 1; s.Parent = obj; return s
end
local function agrad(obj, rot) -- accent gradient น้ำเงิน→ม่วง→แมเจนตา (tri-stop)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.accent),
        ColorSequenceKeypoint.new(0.5, C.accent2),
        ColorSequenceKeypoint.new(1, C.accent3),
    })
    if rot then g.Rotation = rot end
    g.Parent = obj
    return g
end
-- ฟอนต์ไทย: Kanit อ่านสระ/วรรณยุกต์ชัด — env เก่าไม่มี enum → pcall เงียบ fallback GothamMedium
local function tfont(lbl)
    lbl.Font = Enum.Font.GothamMedium
    pcall(function() lbl.Font = Enum.Font.Kanit end)
end
-- เสียงกดน่ารักๆ — pop นุ่มสำหรับ toggle / tick เบาๆ สำหรับปุ่มหัว (เล่น local ไม่กระทบเกม)
local sndSvc = game:GetService("SoundService")
local function sfx(kind)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = kind == "pop" and "rbxassetid://6895079853" or "rbxassetid://4499400560"
        s.Volume = kind == "pop" and 0.45 or 0.3
        sndSvc:PlayLocalSound(s)
        task.delay(1.5, function() pcall(function() s:Destroy() end) end)
    end)
end
-- เก็บ transparency เดิมของ element + ลูกทั้งหมด (ใช้ทำ staggered reveal)
local function stash(el)
    local items = {}
    local function add(d)
        if d:IsA("GuiObject") then
            items[#items + 1] = { o = d, k = "BackgroundTransparency", v = d.BackgroundTransparency }
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                items[#items + 1] = { o = d, k = "TextTransparency", v = d.TextTransparency }
            end
        elseif d:IsA("UIStroke") then
            items[#items + 1] = { o = d, k = "Transparency", v = d.Transparency }
        end
    end
    add(el)
    for _, d in ipairs(el:GetDescendants()) do add(d) end
    return items
end

local PW, FOLD_H, FULL_H = 300, 56, 400
local HOME = UDim2.new(0, 60, 0, 60)
local sg = Instance.new("ScreenGui")
sg.Name = "HZESPUI"
sg.ResetOnSpawn = false
sg.DisplayOrder = 100
pcall(function() sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling end)

-- aura accent จางๆ หลัง panel — ใหญ่กว่า shadow 18px/ข้าง, pulse alpha ช้าๆ (loop ด้านล่าง)
local glow = Instance.new("Frame")
glow.Size = UDim2.new(0, PW + 64, 0, FULL_H + 64)
glow.Position = UDim2.new(0, 28, 0, 28)
glow.BackgroundColor3 = C.accent2
glow.BackgroundTransparency = 0.96
glow.BorderSizePixel = 0
glow.ZIndex = 1
glow.Parent = sg
corner(glow, 30)
local glowG = agrad(glow, 55)
glowG.Transparency = NumberSequence.new({ -- จางทั้งสองปลายทแยง → rim นุ่มไม่เป็นก้อนสีทึบ
    NumberSequenceKeypoint.new(0, 0.9),
    NumberSequenceKeypoint.new(0.5, 0.15),
    NumberSequenceKeypoint.new(1, 0.9),
})

-- เงานุ่มรอบ panel + ขอบเรืองจาง (ลาก/พับแล้วตามไปด้วย)
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(0, PW + 28, 0, FULL_H + 28)
shadow.Position = UDim2.new(0, 46, 0, 46)
shadow.BackgroundColor3 = Color3.fromRGB(1, 2, 8)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
shadow.ZIndex = 1
shadow.Parent = sg
corner(shadow, 22)
stroke(shadow, Color3.fromRGB(90, 110, 200), 0.94)

local f = Instance.new("Frame")
f.Size = UDim2.new(0, PW, 0, FULL_H)
f.Position = HOME
f.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- สีจริงมาจาก gradient bgTop→bgBot
f.BackgroundTransparency = 0.03
f.BorderSizePixel = 0
f.Active = true
f.ClipsDescendants = true
f.ZIndex = 2
f.Parent = sg
corner(f, 14)
stroke(f, C.edge, 0.45)
local fg = Instance.new("UIGradient")
fg.Color = ColorSequence.new(C.bgTop, C.bgBot)
fg.Rotation = 90
fg.Parent = f

-- accent beam บนสุดของ panel — gradient หมุนวนช้า (loop ด้านล่าง)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 2)
topBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
topBar.BorderSizePixel = 0
topBar.ZIndex = 3
topBar.Parent = f
local topG = agrad(topBar)
topG.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.5),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(1, 0.5),
})

-- header 56px (ลากย้ายได้เฉพาะโซนนี้) + clip ให้ shine sweep ไม่ล้น
local head = Instance.new("Frame")
head.Size = UDim2.new(1, 0, 0, 56)
head.BackgroundTransparency = 1
head.ClipsDescendants = true
head.Parent = f

-- wash แสง accent จางๆ ฝั่งซ้ายหัวการ์ด (fade หายไปทางขวา)
local headGlow = Instance.new("Frame")
headGlow.Size = UDim2.new(0, 160, 1, 0)
headGlow.BackgroundColor3 = C.accent
headGlow.BackgroundTransparency = 0.88
headGlow.BorderSizePixel = 0
headGlow.Parent = head
local hgw = Instance.new("UIGradient")
hgw.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(1, 1),
})
hgw.Parent = headGlow

local halo2 = Instance.new("Frame") -- วงเรืองชั้นนอก สวนเฟสกับ halo ใน (ripple)
halo2.AnchorPoint = Vector2.new(0.5, 0.5)
halo2.Size = UDim2.new(0, 30, 0, 30)
halo2.Position = UDim2.new(0, 24, 0, 28)
halo2.BackgroundColor3 = C.accent2
halo2.BackgroundTransparency = 0.95
halo2.BorderSizePixel = 0
halo2.Parent = head
corner(halo2, 15)

local halo = Instance.new("Frame") -- วงเรือง pulse รอบ dot
halo.AnchorPoint = Vector2.new(0.5, 0.5)
halo.Size = UDim2.new(0, 18, 0, 18)
halo.Position = UDim2.new(0, 24, 0, 28)
halo.BackgroundColor3 = C.accent
halo.BackgroundTransparency = 0.82
halo.BorderSizePixel = 0
halo.Parent = head
corner(halo, 12)

local dot = Instance.new("Frame")
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Size = UDim2.new(0, 9, 0, 9)
dot.Position = UDim2.new(0, 24, 0, 28)
dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dot.BorderSizePixel = 0
dot.Parent = head
corner(dot, 5)
agrad(dot)
stroke(dot, Color3.fromRGB(255, 255, 255), 0.85)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -166, 0, 18)
title.Position = UDim2.new(0, 40, 0, 10)
title.BackgroundTransparency = 1
title.Text = "HZ HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีจริงคุมด้วย tri-stop gradient (ไหลทั้งคำ)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = head
local titleG = agrad(title) -- น้ำเงิน→ม่วง→แมเจนตา ทั้ง "HZ HUB" + หมุน/ไหล (loop ด้านล่าง)
titleG.Rotation = -18 -- เอียงนิดให้แสงตัดทแยงสวยขึ้น

local cap = Instance.new("TextLabel")
cap.Size = UDim2.new(1, -166, 0, 12)
cap.Position = UDim2.new(0, 40, 0, 32)
cap.BackgroundTransparency = 1
cap.Text = "SNIPER ARENA · ASSIST SUITE"
cap.TextColor3 = Color3.fromRGB(255, 255, 255) -- คุมสีด้วย gradient เทา→ม่วงจาง
cap.Font = Enum.Font.GothamMedium
cap.TextSize = 9.5
cap.TextXAlignment = Enum.TextXAlignment.Left
cap.Parent = head
local capG = Instance.new("UIGradient") -- caption ไล่เทาสว่าง→โทนม่วง accent เงาๆ
capG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 160, 190)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(122, 112, 182)),
})
capG.Parent = cap

-- shine sweep — แถบแสงเฉียงวิ่งข้าม header ทุก ~3.6 วิ (loop ด้านล่าง)
local shine = Instance.new("Frame")
shine.AnchorPoint = Vector2.new(0.5, 0.5)
shine.Size = UDim2.new(0, 30, 0, 92)
shine.Position = UDim2.new(0, -50, 0.5, 0)
shine.Rotation = 16
shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shine.BackgroundTransparency = 0.45
shine.BorderSizePixel = 0
shine.ZIndex = 5
shine.Parent = head
local shG = Instance.new("UIGradient")
shG.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.2),
    NumberSequenceKeypoint.new(1, 1),
})
shG.Parent = shine

-- เส้น gradient บางใต้ header (จางที่ขอบสองข้าง)
local hdiv = Instance.new("Frame")
hdiv.Size = UDim2.new(1, 0, 0, 1)
hdiv.Position = UDim2.new(0, 0, 1, -1)
hdiv.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
hdiv.BorderSizePixel = 0
hdiv.Parent = head
local hg = agrad(hdiv)
hg.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.12, 0.15),
    NumberSequenceKeypoint.new(0.88, 0.15),
    NumberSequenceKeypoint.new(1, 1),
})

local bodyEls = {}

-- BETA chip — แอมเบอร์ มุมขวาหัวการ์ด (เวอร์ชันภายใน ไม่โชว์)
local betaChip = Instance.new("Frame")
betaChip.Size = UDim2.new(0, 44, 0, 17)
betaChip.Position = UDim2.new(1, -118, 0, 20)
betaChip.BackgroundColor3 = Color3.fromRGB(52, 40, 18)
betaChip.BorderSizePixel = 0
betaChip.Parent = f
corner(betaChip, 6)
stroke(betaChip, Color3.fromRGB(255, 194, 75), 0.45)
local betaLbl = Instance.new("TextLabel")
betaLbl.Size = UDim2.new(1, 0, 1, 0)
betaLbl.BackgroundTransparency = 1
betaLbl.Text = "BETA"
betaLbl.TextColor3 = Color3.fromRGB(255, 194, 75)
betaLbl.Font = Enum.Font.GothamBold
betaLbl.TextSize = 9
betaLbl.Parent = betaChip

local function headBtn(txt, x, bgc, tc, hov)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 24, 0, 24)
    b.Position = UDim2.new(1, x, 0, 16)
    b.BackgroundColor3 = bgc
    b.AutoButtonColor = false
    b.Text = txt
    b.TextColor3 = tc
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.ZIndex = 10
    b.Parent = f
    corner(b, 8)
    stroke(b, C.edge, 0.7)
    b.MouseEnter:Connect(function()
        if G.__HZESP_GEN ~= GEN then return end
        tw(b, 0.12, { BackgroundColor3 = hov })
    end)
    b.MouseLeave:Connect(function()
        if G.__HZESP_GEN ~= GEN then return end
        tw(b, 0.12, { BackgroundColor3 = bgc })
    end)
    return b
end
local btnFold = headBtn("–", -66, C.card, C.dim, C.cardHov)
local btnX = headBtn("×", -38, Color3.fromRGB(78, 34, 46), Color3.fromRGB(255, 132, 138), Color3.fromRGB(102, 42, 56))

-- section panel ชั้นในหลังแถว toggle (recessed — layered depth)
local sect = Instance.new("Frame")
sect.Size = UDim2.new(1, -16, 0, 200)
sect.Position = UDim2.new(0, 8, 0, 132)
sect.BackgroundColor3 = C.sect
sect.BackgroundTransparency = 0.35
sect.BorderSizePixel = 0
sect.Parent = f
corner(sect, 12)
stroke(sect, C.edgeSoft, 0.8)
table.insert(bodyEls, sect)

-- mode badge: accent tab ซ้าย + modeLbl (paintModeUI เขียน text/สีทุก 2 วิ) + gradient bg จาง
local badge = Instance.new("Frame")
badge.Size = UDim2.new(1, -24, 0, 30)
badge.Position = UDim2.new(0, 12, 0, 62)
badge.BackgroundColor3 = C.card
badge.BorderSizePixel = 0
badge.Parent = f
corner(badge, 10)
stroke(badge, C.edge, 0.6)
local bgrad = Instance.new("UIGradient") -- depth เบาๆ: card → sect บนลงล่าง
bgrad.Color = ColorSequence.new(C.card, C.sect)
bgrad.Rotation = 90
bgrad.Parent = badge
table.insert(bodyEls, badge)

local btabGlow = Instance.new("Frame") -- pulse accent หลัง tab ซ้าย (loop ด้านล่าง, สร้างก่อน btab ให้อยู่ใต้)
btabGlow.Size = UDim2.new(0, 7, 1, -10)
btabGlow.Position = UDim2.new(0, -1, 0, 5)
btabGlow.BackgroundColor3 = C.accent2
btabGlow.BackgroundTransparency = 0.82
btabGlow.BorderSizePixel = 0
btabGlow.Parent = badge
corner(btabGlow, 4)
agrad(btabGlow, 90)

local btab = Instance.new("Frame")
btab.Size = UDim2.new(0, 4, 1, -14)
btab.Position = UDim2.new(0, 0, 0, 7)
btab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
btab.BorderSizePixel = 0
btab.Parent = badge
corner(btab, 2)
agrad(btab, 90)

modeLbl = Instance.new("TextLabel")
modeLbl.Size = UDim2.new(1, -22, 1, 0)
modeLbl.Position = UDim2.new(0, 15, 0, 0)
modeLbl.BackgroundTransparency = 1
modeLbl.Text = "◈ โหมด: —"
modeLbl.TextColor3 = C.dim
tfont(modeLbl)
modeLbl.TextSize = 13
modeLbl.TextXAlignment = Enum.TextXAlignment.Left
modeLbl.TextTruncate = Enum.TextTruncate.AtEnd
modeLbl.Parent = badge

-- live status strip: จุดสถานะ + จำนวนเป้า + เป้าที่ล็อก + tag LIVE ขวา (loop 0.7 วิอัปเดต)
local strip = Instance.new("Frame")
strip.Size = UDim2.new(1, -24, 0, 26)
strip.Position = UDim2.new(0, 12, 0, 98)
strip.BackgroundColor3 = C.sect
strip.BorderSizePixel = 0
strip.Parent = f
corner(strip, 9)
stroke(strip, C.edgeSoft, 0.65)
table.insert(bodyEls, strip)

local statGlow = Instance.new("Frame")
statGlow.AnchorPoint = Vector2.new(0.5, 0.5)
statGlow.Size = UDim2.new(0, 13, 0, 13)
statGlow.Position = UDim2.new(0, 15, 0.5, 0)
statGlow.BackgroundColor3 = C.ok
statGlow.BackgroundTransparency = 0.84
statGlow.BorderSizePixel = 0
statGlow.Parent = strip
corner(statGlow, 7)

local statDot = Instance.new("Frame")
statDot.AnchorPoint = Vector2.new(0.5, 0.5)
statDot.Size = UDim2.new(0, 7, 0, 7)
statDot.Position = UDim2.new(0, 15, 0.5, 0)
statDot.BackgroundColor3 = C.ok
statDot.BorderSizePixel = 0
statDot.Parent = strip
corner(statDot, 4)

local statLbl = Instance.new("TextLabel")
statLbl.Size = UDim2.new(1, -94, 1, 0)
statLbl.Position = UDim2.new(0, 26, 0, 0)
statLbl.BackgroundTransparency = 1
statLbl.Text = "เป้า: 0 · ล็อก: —"
statLbl.TextColor3 = C.dim
tfont(statLbl)
statLbl.TextSize = 12
statLbl.TextXAlignment = Enum.TextXAlignment.Left
statLbl.TextTruncate = Enum.TextTruncate.AtEnd
statLbl.Parent = strip

local liveLbl = Instance.new("TextLabel")
liveLbl.Size = UDim2.new(0, 44, 1, 0)
liveLbl.Position = UDim2.new(1, -54, 0, 0)
liveLbl.BackgroundTransparency = 1
liveLbl.Text = "LIVE"
liveLbl.TextColor3 = C.dim
liveLbl.Font = Enum.Font.Code
liveLbl.TextSize = 9
liveLbl.TextXAlignment = Enum.TextXAlignment.Right
liveLbl.Parent = strip

-- ไอคอนเวกเตอร์ — วาดจาก Frame ล้วน คมทุกเครื่อง ไม่พึ่ง glyph/ฟอนต์
--   คืน setColor(col) — recolor ทุกชิ้น (Frame bg / UIStroke)
local function mkIcon(kind, parent)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(0.5, -8, 0.5, -8)
    box.BackgroundTransparency = 1
    box.Parent = parent
    local parts = {}
    local function bar(w, h, x, y, ax, ay, rot) -- แท่งมน (ax/ay=anchor)
        local b = Instance.new("Frame")
        b.AnchorPoint = Vector2.new(ax or 0, ay or 0)
        b.Size = UDim2.new(0, w, 0, h)
        b.Position = UDim2.new(0, x, 0, y)
        b.BackgroundColor3 = Color3.new(1, 1, 1)
        b.BorderSizePixel = 0
        b.Rotation = rot or 0
        b.Parent = box
        corner(b, math.min(w, h) / 2)
        parts[#parts + 1] = b
    end
    local function ring(s, th) -- วงแหวน stroke (s=เส้นผ่านกลาง)
        local r = Instance.new("Frame")
        r.Size = UDim2.new(0, s, 0, s)
        r.Position = UDim2.new(0.5, -s / 2, 0.5, -s / 2)
        r.BackgroundTransparency = 1
        r.BorderSizePixel = 0
        r.Parent = box
        corner(r, s / 2)
        local st = stroke(r, Color3.new(1, 1, 1), 0)
        st.Thickness = th or 1.5
        parts[#parts + 1] = st
    end
    if kind == "esp" then -- ตา: วงแหวนใหญ่ + ม่านตา
        ring(13, 1.7)
        bar(4.4, 4.4, 8, 8, 0.5, 0.5)
    elseif kind == "aim" then -- เป้า: crosshair 4 ขีด + จุดกลาง
        bar(1.7, 5, 8, 0, 0.5, 0)
        bar(1.7, 5, 8, 16, 0.5, 1)
        bar(5, 1.7, 0, 8, 0, 0.5)
        bar(5, 1.7, 16, 8, 1, 0.5)
        bar(3.4, 3.4, 8, 8, 0.5, 0.5)
    elseif kind == "auto" then -- ยิงแตก: จุดกลาง + รังสีแฉลบ 4 เส้น (ดูเป็น "fire")
        bar(3.8, 3.8, 8, 8, 0.5, 0.5)
        bar(1.9, 5, 12.4, 3.6, 0.5, 0.5, -45)  -- เส้นบนขวา ↗
        bar(1.9, 5, 3.6, 3.6, 0.5, 0.5, 45)    -- บนซ้าย ↖
        bar(1.9, 5, 12.4, 12.4, 0.5, 0.5, 45)  -- ล่างขวา ↘
        bar(1.9, 5, 3.6, 12.4, 0.5, 0.5, -45)  -- ล่างซ้าย ↙
    elseif kind == "dev" then -- มือถือ: กรอบโทรศัพท์ + ลำโพง + ปุ่ม
        local ph = Instance.new("Frame")
        ph.Size = UDim2.new(0, 8.6, 0, 13)
        ph.Position = UDim2.new(0.5, -4.3, 0.5, -6.5)
        ph.BackgroundTransparency = 1
        ph.BorderSizePixel = 0
        ph.Parent = box
        corner(ph, 2.6)
        local st = stroke(ph, Color3.new(1, 1, 1), 0)
        st.Thickness = 1.6
        parts[#parts + 1] = st
        bar(3, 1.3, 8, 3, 0.5, 0.5)
        bar(2.2, 2.2, 8, 13.2, 0.5, 0.5)
    end
    return function(col)
        for _, p in ipairs(parts) do
            if p:IsA("UIStroke") then p.Color = col else p.BackgroundColor3 = col end
        end
    end
end

-- แถวการ์ด 42px: icon chip + label + status dot + pill toggle
--   (knob เลื่อน + gradient สีประจำแถวตอน on · squash ตอนกด · hover glow)
local rows = {}
local function mkRow(y, icon, text, acc, get, set)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -32, 0, 42)
    card.Position = UDim2.new(0, 16, 0, y)
    card.BackgroundColor3 = C.card
    card.BorderSizePixel = 0
    card.Parent = f
    corner(card, 10)
    local cardSt = stroke(card, C.edge, 0.8)
    table.insert(bodyEls, card)

    local chip = Instance.new("Frame")
    chip.Size = UDim2.new(0, 26, 0, 26)
    chip.Position = UDim2.new(0, 8, 0, 8)
    chip.BackgroundColor3 = acc
    chip.BackgroundTransparency = 0.9
    chip.BorderSizePixel = 0
    chip.Parent = card
    corner(chip, 8)
    local chipSt = stroke(chip, acc, 0.85)

    local setIc = mkIcon(icon, chip)
    setIc(C.dimIcon)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -140, 1, 0)
    lbl.Position = UDim2.new(0, 44, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.txt
    tfont(lbl)
    lbl.TextSize = 13.5
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = card

    -- จุด status เล็กของแถว: สี acc ตอน on / เทาตอน off
    local flag = Instance.new("Frame")
    flag.AnchorPoint = Vector2.new(0.5, 0.5)
    flag.Size = UDim2.new(0, 6, 0, 6)
    flag.Position = UDim2.new(1, -72, 0.5, 0)
    flag.BackgroundColor3 = C.edge
    flag.BorderSizePixel = 0
    flag.Parent = card
    corner(flag, 3)

    local s = Instance.new("TextButton")
    s.Size = UDim2.new(0, 46, 0, 24)
    s.Position = UDim2.new(1, -56, 0, 9)
    s.BackgroundColor3 = C.off
    s.AutoButtonColor = false
    s.Text = ""
    s.BorderSizePixel = 0
    s.Parent = card
    corner(s, 12)
    local pillSt = stroke(s, C.edge, 0.75)
    local pillGlow = stroke(s, acc, 1) -- ON glow: rim accent หนา หายใจเบาๆ (loop ด้านล่าง)
    pillGlow.Thickness = 2.5
    local pg = agrad(s) -- gradient สีประจำแถว → accent2 → accent3 (เปิดเฉพาะตอน on)
    pg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, acc),
        ColorSequenceKeypoint.new(0.55, C.accent2),
        ColorSequenceKeypoint.new(1, C.accent3),
    })
    pg.Enabled = false

    local k = Instance.new("Frame")
    k.Size = UDim2.new(0, 18, 0, 18)
    k.Position = UDim2.new(0, 3, 0, 3)
    k.BackgroundColor3 = Color3.fromRGB(244, 247, 253)
    k.BorderSizePixel = 0
    k.Parent = s
    corner(k, 9)
    stroke(k, Color3.fromRGB(28, 32, 50), 0.8) -- inner shadow บางบน knob
    local kg = Instance.new("UIGradient") -- knob มีมิติ: ขาว → เทาอ่อน
    kg.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(196, 204, 224))
    kg.Rotation = 90
    kg.Parent = k

    local function paintRow(anim)
        local on = get()
        local dur = anim == false and 0 or 0.18
        tw(s, dur, { BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or C.off })
        pg.Enabled = on
        tw(pillSt, dur, { Transparency = on and 0.25 or 0.75 })
        tw(k, dur, { Position = on and UDim2.new(0, 25, 0, 3) or UDim2.new(0, 3, 0, 3) })
        lbl.TextColor3 = on and C.txt or C.dim
        setIc(on and acc or C.dimIcon)
        tw(pillGlow, dur, { Transparency = on and 0.5 or 1 })
        tw(chipSt, dur, { Transparency = on and 0.45 or 0.85 })
        tw(chip, dur, { BackgroundTransparency = on and 0.74 or 0.9 })
        tw(flag, dur, { BackgroundColor3 = on and acc or C.edge })
        tw(cardSt, dur, { Transparency = on and 0.55 or 0.8 })
    end
    s.MouseButton1Click:Connect(function()
        if G.__HZESP_GEN ~= GEN then return end
        sfx("pop")
        set(not get())
        paintRow()
    end)
    s.MouseButton1Down:Connect(function()
        if G.__HZESP_GEN ~= GEN then return end
        tw(k, 0.08, { Size = UDim2.new(0, 20, 0, 17) }) -- press squash
    end)
    s.MouseButton1Up:Connect(function()
        if G.__HZESP_GEN ~= GEN then return end
        tw(k, 0.14, { Size = UDim2.new(0, 18, 0, 18) })
    end)
    s.MouseEnter:Connect(function() -- hover glow: ขอบ pill สว่างขึ้น
        if G.__HZESP_GEN ~= GEN then return end
        tw(pillSt, 0.1, { Transparency = get() and 0.1 or 0.45 })
    end)
    s.MouseLeave:Connect(function()
        if G.__HZESP_GEN ~= GEN then return end
        paintRow()
    end)
    card.MouseEnter:Connect(function()
        if G.__HZESP_GEN ~= GEN then return end
        tw(card, 0.12, { BackgroundColor3 = C.cardHov })
    end)
    card.MouseLeave:Connect(function()
        if G.__HZESP_GEN ~= GEN then return end
        tw(card, 0.12, { BackgroundColor3 = C.card })
    end)
    paintRow(false)
    table.insert(rows, { paint = paintRow, get = get, glow = pillGlow })
    return s
end

mkRow(140, "esp", "ESP แยกทีม", C.accent, function() return espOn end, function(v)
    espOn = v
    lg("esp=" .. tostring(v))
    if not v then
        for p in pairs(marks) do clear(p) end
        for m in pairs(botMarks) do clearBot(m) end
    end
end)
mkRow(188, "aim", "ล็อกเป้า (AimLock)", C.accent2, function() return aimOn end, function(v)
    aimOn = v
    lg("aim=" .. tostring(v))
end)
mkRow(236, "auto", "ยิงออโต้ (Auto)", C.amber, function() return shootOn end, function(v)
    shootOn = v
    lg("shoot=" .. tostring(v))
end)
mkRow(284, "dev", "โชว์มือถือ (Device)", C.teal, function() return mobileOn end, function(v)
    mobileOn = v
    lg("mobile=" .. tostring(v))
end)

-- footer: divider gradient + keychip บอก keybind + status ล่าสุด (lg เขียนมาที่ sub)
local fdiv = Instance.new("Frame")
fdiv.Size = UDim2.new(1, -24, 0, 1)
fdiv.Position = UDim2.new(0, 12, 0, 340)
fdiv.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fdiv.BorderSizePixel = 0
fdiv.Parent = f
local fdivG = agrad(fdiv)
fdivG.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.15, 0.55),
    NumberSequenceKeypoint.new(0.85, 0.55),
    NumberSequenceKeypoint.new(1, 1),
})
table.insert(bodyEls, fdiv)

local keyChip = Instance.new("Frame")
keyChip.Size = UDim2.new(0, 46, 0, 17)
keyChip.Position = UDim2.new(0, 12, 0, 350)
keyChip.BackgroundColor3 = C.card
keyChip.BorderSizePixel = 0
keyChip.Parent = f
corner(keyChip, 5)
stroke(keyChip, C.edge, 0.55)
table.insert(bodyEls, keyChip)

local keyLbl = Instance.new("TextLabel")
keyLbl.Size = UDim2.new(1, 0, 1, 0)
keyLbl.BackgroundTransparency = 1
keyLbl.Text = "RShift"
keyLbl.TextColor3 = C.accent
keyLbl.Font = Enum.Font.GothamBold
keyLbl.TextSize = 9
keyLbl.Parent = keyChip

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -80, 0, 17)
hint.Position = UDim2.new(0, 64, 0, 350)
hint.BackgroundTransparency = 1
hint.Text = "ซ่อน/แสดง · ลากหัวการ์ดเพื่อย้าย"
hint.TextColor3 = C.dim
tfont(hint)
hint.TextSize = 11
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.TextTruncate = Enum.TextTruncate.AtEnd
hint.Parent = f
table.insert(bodyEls, hint)

sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -24, 0, 14)
sub.Position = UDim2.new(0, 12, 0, 374)
sub.BackgroundTransparency = 1
sub.Text = "…"
sub.TextColor3 = C.dim
tfont(sub) -- lg() เขียน log ผสมไทย (เช่น "FFA ทุกคนศัตรู") → Kanit อ่านชัดกว่า Code
sub.TextSize = 10.5
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.TextTruncate = Enum.TextTruncate.AtEnd
sub.Parent = f
table.insert(bodyEls, sub)

local folded = false
btnFold.MouseButton1Click:Connect(function()
    if G.__HZESP_GEN ~= GEN then return end
    sfx("tick")
    folded = not folded
    btnFold.Text = folded and "+" or "–"
    for _, el in ipairs(bodyEls) do el.Visible = not folded end
    tw(f, 0.25, { Size = UDim2.new(0, PW, 0, folded and FOLD_H or FULL_H) }, Enum.EasingStyle.Quint)
    tw(shadow, 0.25, { Size = UDim2.new(0, PW + 28, 0, (folded and FOLD_H or FULL_H) + 28) }, Enum.EasingStyle.Quint)
    tw(glow, 0.25, { Size = UDim2.new(0, PW + 64, 0, (folded and FOLD_H or FULL_H) + 64) }, Enum.EasingStyle.Quint)
end)
btnX.MouseButton1Click:Connect(function()
    if G.__HZESP_GEN ~= GEN then return end
    sfx("tick")
    sg.Enabled = false
end)
UIS.InputBegan:Connect(function(i, g)
    if G.__HZESP_GEN ~= GEN then return end
    if not g and i.KeyCode == Enum.KeyCode.RightShift then sg.Enabled = not sg.Enabled end
end)

local dragging, dStart, fStart
local function setPanelPos(p)
    f.Position = p
    shadow.Position = UDim2.new(p.X.Scale, p.X.Offset - 14, p.Y.Scale, p.Y.Offset - 14)
    glow.Position = UDim2.new(p.X.Scale, p.X.Offset - 32, p.Y.Scale, p.Y.Offset - 32)
end
head.InputBegan:Connect(function(i)
    if G.__HZESP_GEN ~= GEN then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dStart = i.Position
        fStart = f.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if G.__HZESP_GEN ~= GEN then return end
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        setPanelPos(UDim2.new(fStart.X.Scale, fStart.X.Offset + d.X, fStart.Y.Scale, fStart.Y.Offset + d.Y))
    end
end)
UIS.InputEnded:Connect(function(i)
    if G.__HZESP_GEN ~= GEN then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- breathing halo 2 ชั้นสวนเฟส + dot (loop ~1.2 วิ — guard gen, ไม่มีงานต่อเฟรม)
task.spawn(function()
    local big = false
    while task.wait(1.2) do
        if G.__HZESP_GEN ~= GEN then break end
        big = not big
        tw(halo, 1.05, {
            Size = big and UDim2.new(0, 26, 0, 26) or UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = big and 0.95 or 0.82,
        }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        tw(halo2, 1.05, {
            Size = big and UDim2.new(0, 22, 0, 22) or UDim2.new(0, 32, 0, 32),
            BackgroundTransparency = big and 0.9 or 0.97,
        }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        tw(dot, 1.05, { BackgroundTransparency = big and 0.3 or 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    end
end)

-- หมุน accent gradient ช้าๆ 6 วิ/รอบ: top beam + ตัวหนังสือ HZ
task.spawn(function()
    while task.wait(6) do
        if G.__HZESP_GEN ~= GEN then break end
        tw(topG, 6, { Rotation = topG.Rotation + 360 }, Enum.EasingStyle.Linear)
        tw(titleG, 6, { Rotation = titleG.Rotation + 360 }, Enum.EasingStyle.Linear)
    end
end)

-- shimmer: gradient ไหลซ้าย↔ขวาบนตัวอักษร + caption (ping-pong นุ่มๆ)
task.spawn(function()
    local to = false
    while task.wait(2.8) do
        if G.__HZESP_GEN ~= GEN then break end
        to = not to
        tw(titleG, 2.6, { Offset = Vector2.new(to and 0.55 or -0.55, 0) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        tw(capG, 2.6, { Offset = Vector2.new(to and 0.4 or -0.4, 0) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    end
end)

-- shine sweep ข้าม header ทุก ~3.6 วิ (รีเซ็ตจุดเริ่มแล้ววิ่งซ้ำ)
task.spawn(function()
    while task.wait(3.6) do
        if G.__HZESP_GEN ~= GEN then break end
        shine.Position = UDim2.new(0, -50, 0.5, 0)
        tw(shine, 1.5, { Position = UDim2.new(0, PW + 50, 0.5, 0) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    end
end)

-- aura หลัง panel หายใจช้าๆ (alpha pulse ~2.6 วิ — guard gen)
task.spawn(function()
    local hi = false
    while task.wait(2.6) do
        if G.__HZESP_GEN ~= GEN then break end
        hi = not hi
        tw(glow, 2.4, { BackgroundTransparency = hi and 0.93 or 0.972 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    end
end)

-- accent pulse เล็กๆ บน tab ซ้ายของ mode badge (~1.8 วิ — guard gen)
task.spawn(function()
    local hi = false
    while task.wait(1.8) do
        if G.__HZESP_GEN ~= GEN then break end
        hi = not hi
        tw(btabGlow, 1.6, { BackgroundTransparency = hi and 0.58 or 0.88 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    end
end)

-- pill ON glow หายใจเบาๆ เฉพาะแถวที่เปิดอยู่ (~1.7 วิ — guard gen + pcall กัน get() พัง)
task.spawn(function()
    local hi = false
    while task.wait(1.7) do
        if G.__HZESP_GEN ~= GEN then break end
        hi = not hi
        for _, r in ipairs(rows) do
            pcall(function()
                if r.get() then
                    tw(r.glow, 1.5, { Transparency = hi and 0.3 or 0.58 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                end
            end)
        end
    end
end)

-- status strip updater (loop เดียว ~0.7 วิ — guard gen, คำนวณถูกจาก marks/botMarks)
task.spawn(function()
    while task.wait(0.7) do
        if G.__HZESP_GEN ~= GEN then break end
        pcall(function()
            local n = 0
            for _, mk in pairs(marks) do
                if type(mk) == "table" and not mk.ally then n = n + 1 end
            end
            for _ in pairs(botMarks) do n = n + 1 end
            local lk = lockTarget
            local lkName = (lk and lk.Parent) and lk.Name or nil
            statLbl.Text = "เป้า: " .. n .. " · ล็อก: " .. (lkName or "—")
            local col = lkName and C.lock or C.ok
            statDot.BackgroundColor3 = col
            statGlow.BackgroundColor3 = col
            liveLbl.TextColor3 = col
        end)
    end
end)

if not guiRoot then
    lg("UI FAIL: guiRoot nil — panel ไม่แสดง")
else
    -- intro: wipe ความสูง + slide ขึ้น + fade (เซ็ต state ก่อน parent กัน flash)
    f.Size = UDim2.new(0, PW, 0, FOLD_H)
    f.BackgroundTransparency = 1
    shadow.Size = UDim2.new(0, PW + 28, 0, FOLD_H + 28)
    shadow.BackgroundTransparency = 1
    glow.Size = UDim2.new(0, PW + 64, 0, FOLD_H + 64)
    glow.BackgroundTransparency = 1
    setPanelPos(UDim2.new(0, 60, 0, 80))
    -- stash การ์ดทุกใบ → เริ่มโปร่ง + เลื่อนลง เตรียม staggered reveal
    local stashes = {}
    for i, el in ipairs(bodyEls) do
        stashes[i] = { el = el, pos = el.Position, items = stash(el) }
        for _, it in ipairs(stashes[i].items) do it.o[it.k] = 1 end
        el.Position = stashes[i].pos + UDim2.new(0, 0, 0, 8)
    end
    sg.Parent = guiRoot
    tw(f, 0.45, {
        Size = UDim2.new(0, PW, 0, FULL_H),
        Position = HOME,
        BackgroundTransparency = 0.03,
    }, Enum.EasingStyle.Quint)
    tw(shadow, 0.45, {
        Size = UDim2.new(0, PW + 28, 0, FULL_H + 28),
        Position = UDim2.new(0, 46, 0, 46),
        BackgroundTransparency = 0.7,
    }, Enum.EasingStyle.Quint)
    tw(glow, 0.55, {
        Size = UDim2.new(0, PW + 64, 0, FULL_H + 64),
        Position = UDim2.new(0, 28, 0, 28),
        BackgroundTransparency = 0.96,
    }, Enum.EasingStyle.Quint)
    for i, st in ipairs(stashes) do
        task.delay(0.08 + i * 0.045, function()
            if G.__HZESP_GEN ~= GEN then return end
            tw(st.el, 0.32, { Position = st.pos }, Enum.EasingStyle.Quint)
            for _, it in ipairs(st.items) do
                tw(it.o, 0.32, { [it.k] = it.v })
            end
        end)
    end
    lg("ui built")
end
paintModeUI()
pcall(sweepESP)
lg("ready HZ HUB v4.9c | " .. (BUILD.wm and ("key wm=" .. tostring(BUILD.wm) .. " · ") or "") .. "FFA ทุกคนศัตรู / Duel แยกทีม")
pcall(function() if BUILD.ping then BUILD.ping("loaded_sniper") end end)
