-- HZ HUB · Mine Antarctica — Rare ESP (Highlight บน model จริง + ชื่อ + ระยะ)
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunS=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local LP=Players.LocalPlayer
local CoreGui=(gethui and gethui()) or game:GetService("CoreGui")
local G=(getgenv and getgenv()) or _G
G.__HZMINE=(G.__HZMINE or 0)+1; local GEN=G.__HZMINE
local function alive() return G.__HZMINE==GEN end
for _,g in ipairs(CoreGui:GetChildren()) do if g.Name=="HZMineUI" or g.Name=="HZMineEsp" then pcall(function() g:Destroy() end) end end

local function wr(f,s) if writefile then pcall(writefile,f,s) end end
local function slog(m) local t=os.date("%H:%M:%S")
    local old=(isfile and isfile("hz_mine_log.txt") and readfile("hz_mine_log.txt") or "")
    if #old>200000 then old=old:sub(-100000) end   -- กันไฟล์บวม: เกิน 200KB ตัดเก็บครึ่งหลัง
    wr("hz_mine_log.txt",old.."\n"..t.." "..m); print("[HZMINE]",m)
end
wr("hz_mine_log.txt","== HZ MINE "..os.date().." ==")

local C={bgTop=Color3.fromRGB(16,17,30),bgBot=Color3.fromRGB(10,11,20),edge=Color3.fromRGB(96,116,235),
    accent=Color3.fromRGB(88,140,255),accent2=Color3.fromRGB(160,110,255),accent3=Color3.fromRGB(255,110,200),
    on=Color3.fromRGB(64,224,140),off=Color3.fromRGB(62,66,88),txt=Color3.fromRGB(238,240,252),dim=Color3.fromRGB(138,146,178),
    row=Color3.fromRGB(24,26,42),rowH=Color3.fromRGB(33,36,58),opt=Color3.fromRGB(30,33,52),optH=Color3.fromRGB(40,44,68),
    sub=Color3.fromRGB(20,22,37),panel=Color3.fromRGB(19,21,34),deep=Color3.fromRGB(14,16,27),buy=Color3.fromRGB(44,128,72),opt2=Color3.fromRGB(40,44,66)}
local TIERS={"Common","Uncommon","Rare","Epic","Legendary","Mythic","Exotic","Zenith","Divine","Empyrean","Infinity","Ultima","Eldritch"}
local TCOL={Common=Color3.fromRGB(154,163,178),Uncommon=Color3.fromRGB(92,232,92),Rare=Color3.fromRGB(74,168,255),Epic=Color3.fromRGB(180,130,255),Legendary=Color3.fromRGB(255,210,60),Mythic=Color3.fromRGB(255,110,60),Exotic=Color3.fromRGB(255,74,140),Zenith=Color3.fromRGB(125,249,255),
    Divine=Color3.fromRGB(255,240,170),Empyrean=Color3.fromRGB(140,255,215),Infinity=Color3.fromRGB(150,80,255),Ultima=Color3.fromRGB(255,80,80),Eldritch=Color3.fromRGB(120,70,190)}
local function tIdx(t) for i,v in ipairs(TIERS) do if v==t then return i end end return 0 end
local function rIdx(t) local i=tIdx(t) return i>0 and i or 99 end  -- tier ไม่รู้จัก = สูงสุด (sort/เสียงแจ้ง)
local function tfont(l) l.Font=Enum.Font.GothamMedium pcall(function() l.Font=Enum.Font.Kanit end) end
local function comma(n) local s=tostring(math.floor(tonumber(n) or 0)) while true do local k s,k=s:gsub("^(-?%d+)(%d%d%d)","%1,%2") if k==0 then break end end return s end
local pickByTier={} -- Tier → ชื่อพลั่วจริง (EquippedPickaxe = เลข tier)
task.spawn(function()
    local pt=RS:WaitForChild("PickaxeTools",30)
    if pt then for _,t in ipairs(pt:GetChildren()) do local ti=t:GetAttribute("Tier") if ti then pickByTier[ti]=t.Name end end end
end)
local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o return c end
local function stroke(o,col,tr) local s=Instance.new("UIStroke"); s.Color=col; s.Transparency=tr or 0.5; s.Parent=o return s end
local function agrad(o) local g=Instance.new("UIGradient"); g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.accent),ColorSequenceKeypoint.new(0.5,C.accent2),ColorSequenceKeypoint.new(1,C.accent3)}; g.Parent=o return g end
-- ✨ UI polish helpers: hover (ปุ่ม/แถวสว่างตอนเมาส์ทาบ), chip (กล่องไอคอนมนก่อน label), polishPill (ขอบเข้มให้สวิตช์)
local function hover(b,t,base,over)  -- b=ตัวรับอีเวนต์ (ปุ่มโปร่ง) / t=ตัวที่เปลี่ยนสี (แถว)
    b.MouseEnter:Connect(function() Tween:Create(t,TweenInfo.new(0.12),{BackgroundColor3=over}):Play() end)
    b.MouseLeave:Connect(function() Tween:Create(t,TweenInfo.new(0.15),{BackgroundColor3=base}):Play() end)
end
local function chip(r,icon,col)
    local c=Instance.new("Frame"); c.Size=UDim2.new(0,24,0,24); c.Position=UDim2.new(0,5,0.5,-12)
    c.BackgroundColor3=col; c.BackgroundTransparency=0.8; c.BorderSizePixel=0; c.Parent=r; corner(c,7); stroke(c,col,0.55)
    local i=Instance.new("TextLabel"); i.Size=UDim2.new(1,0,1,0); i.BackgroundTransparency=1; i.Text=icon; i.TextSize=13; i.TextColor3=Color3.new(1,1,1); i.Parent=c; tfont(i)
end
local function shiftLbl(l) l.Position=UDim2.new(0,36,0,0); l.Size=UDim2.new(1,-140,1,0) end
local function polishPill(pl,kn) stroke(pl,Color3.new(0,0,0),0.72); stroke(kn,Color3.new(0,0,0),0.65) end
local sndSvc=game:GetService("SoundService")
local function sfx(k) pcall(function() local s=Instance.new("Sound") s.SoundId=k=="pop" and "rbxassetid://6895079853" or "rbxassetid://4499400560" s.Volume=k=="pop" and 0.4 or 0.25 sndSvc:PlayLocalSound(s) task.delay(1.2,function() pcall(function() s:Destroy() end) end) end) end

local Freed,DigEff,DigReq,Collected=nil,nil,nil,nil
local Push,SellReq,TSell,TPlot,THome,GFeed,DigRes,AltY,AltS
local CBEquip,SellRes
local MetEv,MetActive,MetPhase,MetPos,WState,WStar,MtState,MtRot,MtChoose,QuoteAll
local BuyUp,UpState; local upState=nil -- snapshot ล่าสุดจาก UpgradeState
task.spawn(function()
    local gs=RS:WaitForChild("GemSignals",30)
    Freed=gs and gs:WaitForChild("GemFreed",30)
    Collected=gs and gs:WaitForChild("GemCollected",30)
    local dg=RS:WaitForChild("DigRemotes",30)
    DigEff=dg and dg:WaitForChild("DigEffect",30)
    DigReq=dg and dg:WaitForChild("DigRequest",30)
    DigRes=dg and dg:WaitForChild("DigResult",30)
    -- ⚠️ SetDigPower = honeypot remote: ไม่มี client จริงยิง แต่ server ฟัง → ยิง = kick 267 "Suspicious activity" (ห้ามแตะ)
    local nm=RS:WaitForChild("NotifyRemotes",30)
    Push=nm and nm:WaitForChild("Push",30)
    local gr=RS:WaitForChild("GemRemotes",30)
    SellReq=gr and gr:WaitForChild("RequestSell",30)
    QuoteAll=gr and gr:WaitForChild("QuoteSellAll",30)
    SellRes=gr and gr:WaitForChild("SellResult",30)
    local cbr=RS:WaitForChild("CrystalBagRemotes",30)
    CBEquip=cbr and cbr:WaitForChild("Equip",30)
    local br=RS:WaitForChild("BackpackRemotes",30)
    TSell=br and br:WaitForChild("TeleportSell",30)
    TPlot=br and br:WaitForChild("TeleportPlot",30)
    local bm=RS:WaitForChild("BaseRemotes",30)
    THome=bm and bm:WaitForChild("TeleportHome",30)
    GFeed=RS:WaitForChild("GlobalFindFeed",30)
    AltY=RS:WaitForChild("AltitudeBaseY",30); AltS=RS:WaitForChild("AltitudeScale",30)
    local met=RS:WaitForChild("MeteorRemotes",30)
    MetEv=met and met:WaitForChild("Event",30)
    MetActive=met and met:WaitForChild("Active",30)
    MetPhase=met and met:WaitForChild("Phase",30)
    MetPos=met and met:WaitForChild("ImpactPos",30)
    local wtr=RS:WaitForChild("WeatherRemotes",30)
    WState=wtr and wtr:WaitForChild("State",30)
    WStar=wtr and wtr:WaitForChild("Starfall",30)
    local mtr=RS:WaitForChild("MountainRemotes",30)
    MtState=mtr and mtr:WaitForChild("State",30)
    MtRot=mtr and mtr:WaitForChild("RotationEnd",30)
    local smr=RS:WaitForChild("ServerMountainRemotes",30)
    MtChoose=smr and smr:WaitForChild("Choose",30)
    local ur=RS:WaitForChild("UpgradeRemotes",30)
    BuyUp=ur and ur:WaitForChild("BuyUpgrade",30)
    UpState=ur and ur:WaitForChild("UpgradeState",30)
    slog("remotes freed="..tostring(Freed~=nil).." sell="..tostring(SellReq~=nil).." met="..tostring(MetEv~=nil).." mt="..tostring(MtChoose~=nil).." w="..tostring(WState~=nil))
end)

local cfg={esp=true,minTier=1,ttl=150,pickMode=false,players=true,autodig=false,autocollect=false,autosell=false,selfOn=false,farmBot=false,botTier=1,
    met=true,runes=true,mtn=true,autoup=false,
    sub={espHl=true,espName=true,ghost=true,ghostLbl=true,        -- เรดาร์แรร์: ตัวทรง/ป้าย/ghost/ป้ายghost
         pHl=true,pName=true,pDig=true,                            -- ผู้เล่น: ตัว/ป้าย/แท็กขุด
         smartDig=true,colRange=true,                              -- ขุด:เล็งแรร์ฝัง · เก็บ:เช็คระยะ
         turboDig=false,instaPick=true,                            -- ขุดโหด:turbo · เก็บ:Hold=0
         remoteSell=false,                                         -- ขาย:ยิง RequestSell ตรงๆ ไม่วาป (ทดลอง)
         spd15=false,spd2=false,                                   -- วิ่งไว: 1.5x (ปลอดภัย) / 2x (=Pass_Speed2x จริง)
         botBest=true,botWarm=true,botPot=false,                   -- บอท: เล็งเป้าคุ้ม / กันตายหนาว / กินยาอัตโนมัติ
         hpBar=true,                                               -- แรร์: ❤HP ตอนโดนขุด
         metMark=true,metFeed=true,                                -- เมเทียร์: ป้ายจุดตก/แจ้งเตือน
         runeHl=true,runeLbl=true,                                 -- รูน: ตัว/ป้าย
         mtnAuto=false,mtnList=true,                              -- ภูเขา: auto-ขึ้นดีสุด/แผงเลือก
         upCarry=true,upWarm=true}}                               -- อัพเกรด: ซื้อ carry/warmth อัตโนมัติ
local picks={}     -- {gemName=true} — โหมดเฉพาะที่เลือก
local tracked={}   -- [model]={hl,bb,txt,name,rarity,kg}
local pings={}     -- {pos,rarity,kg,t,ghost,hl,bb,txt}
local marks={}     -- {part,bb,txt,pos,until} — ป้าย event (เมเทียร์/ดาวตก)
local rtrack={}    -- [runeModel]={hl,bb,t1,t2}
local knownPos={}  -- [model]=Vector3 — พิกัดล่าสุดที่เห็น (revalidate ตัว unstream)
local missK=setmetatable({},{__mode="k"})  -- [model]=จำนวนรอบที่พลาด (weak — model ตายก็หายเอง)
local promptSet={} -- [ProximityPrompt]=true — Pickup ทั้งแมพสำหรับ auto-collect
local buriedCache={}; local buriedT=0 -- cache เป้าขุด (refresh 2 วิ)

-- modules จริงของเกม (read-only data — ใช้สี/ชื่อ/rarity ตรงกับเกม)
local MP,RD,WD=nil,nil,nil
task.spawn(function()
    pcall(function() MP=require(RS:WaitForChild("MountainPool",20)) end)
    pcall(function() RD=require(RS:WaitForChild("RuneData",20)) end)
    pcall(function() WD=require(RS:WaitForChild("WeatherData",20)) end)
end)

-- ============ ESP layer ============
local esp=Instance.new("ScreenGui"); esp.Name="HZMineEsp"; esp.ResetOnSpawn=false; esp.IgnoreGuiInset=true; esp.DisplayOrder=98; esp.Parent=CoreGui
local hlFolder=Instance.new("Folder"); hlFolder.Name="hl"; hlFolder.Parent=esp

local feedAdd -- fwd
local wantShow,applyFilter -- fwd (ใช้ใน consider / ปุ่มก่อนประกาศ)
local lastCollect={}  -- fwd — ใช้ใน render loop ก่อน task hook ด้านล่าง
local trackRune       -- fwd — ใช้ใน DescendantAdded ก่อนประกาศจริง

local pending={}       -- คิว model รอสร้าง Highlight (กระจายงานกันสแปมเฟรม)
local pendSet={}
local known={}         -- [model]=rarity — registry เบาๆ ของทุกแรร์ที่รู้จัก (นับจำนวน ไม่สร้างภาพ)

-- ============ server-reset detector ============
-- ภูเขาหมุน/เซิร์ฟเวอร์รี → แรร์ทั้งแมพ despawn พร้อมกัน → registry ต้องล้าง ไม่งั้น ghost stale ถาวร
local wipeN,wipeT0=0,0
local wiping,wipeEnd=false,0
local function doWipe(reason)
    for m in pairs(known) do known[m]=nil knownPos[m]=nil missK[m]=nil end
    for _,e in ipairs(pings) do pcall(function() e.ghost:Destroy() e.hl:Destroy() e.bb:Destroy() end) end
    for i=#pings,1,-1 do pings[i]=nil end
    for i=#pending,1,-1 do pending[i]=nil end
    for m in pairs(pendSet) do pendSet[m]=nil end
    if feedAdd then feedAdd("🔄 "..reason.." — รีแผนที่แรร์",Color3.fromRGB(255,180,80)) end
    slog("WIPE "..reason)
end

local function trackModel(m)
    if tracked[m] then return end
    local rarity=m:GetAttribute("Rarity") or "Common"
    local kg=m:GetAttribute("Kg") or 0
    local name=(m:GetAttribute("GemName") or m.Name):gsub("(%l)(%u)","%1 %2")
    local val=m:GetAttribute("Value") or 0
    local col=TCOL[rarity] or Color3.new(1,1,1)
    local hl=Instance.new("Highlight")
    hl.FillColor=col; hl.OutlineColor=Color3.new(1,1,1); hl.FillTransparency=0.6; hl.OutlineTransparency=0
    hl.Adornee=m; hl.Parent=hlFolder
    local bb=Instance.new("BillboardGui")
    bb.Size=UDim2.new(0,200,0,44); bb.StudsOffsetWorldSpace=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Adornee=m; bb.Parent=hlFolder

    local t1=Instance.new("TextLabel"); t1.Size=UDim2.new(1,0,0,20); t1.BackgroundTransparency=1
    t1.TextColor3=col; t1.TextStrokeTransparency=0.3; t1.TextSize=13; t1.Parent=bb; t1.Font=Enum.Font.GothamBold; tfont(t1)
    local t2=Instance.new("TextLabel"); t2.Size=UDim2.new(1,0,0,16); t2.Position=UDim2.new(0,0,0,20); t2.BackgroundTransparency=1
    t2.TextColor3=Color3.fromRGB(220,225,245); t2.TextStrokeTransparency=0.4; t2.TextSize=11; t2.Parent=bb; tfont(t2)
    local mut=m:GetAttribute("Mutations"); if mut=="" then mut=nil end
    local sz=m:GetAttribute("SizeLetter")
    t1.Text="◆ "..name..(mut and (" ✦"..mut) or "")..(m:GetAttribute("Freed") and "" or " ⛏ฝังอยู่")
    t2.Text=string.format("%s%s · %.1fkg · $%s",rarity,sz and (" ["..sz.."]") or "",kg,tostring(val))
    tracked[m]={hl=hl,bb=bb,t1=t1,t2=t2,rarity=rarity,name=name,id=(m:GetAttribute("GemName") or m.Name),kg=kg,mut=mut,sz=sz}
    known[m]=rarity
    -- เคลียร์ ping ที่ตรงจุดนี้ — ใช้ FreedPos หรือ pivot (แรร์ฝังไม่มี FreedPos แต่ตำแหน่งก็ตรง)
    local fp=m:GetAttribute("FreedPos")
    if not fp then local ok,p=pcall(function() return m:GetPivot().Position end) fp=ok and p or nil end
    if fp then
        for i=#pings,1,-1 do
            if (pings[i].pos-fp).Magnitude<18 then pcall(function() pings[i].ghost:Destroy() pings[i].hl:Destroy() pings[i].bb:Destroy() end); table.remove(pings,i) end
        end
    end
    -- เสียงแจ้งเฉพาะ Exotic+ (feed ตัดออกแล้ว — สแปม)
    if feedAdd and (m:GetAttribute("Freed") or m:GetAttribute("Dropped")) and rIdx(rarity)>=7 then sfx("pop") end
end

local function isGemModel(m)
    return m:IsA("Model") and m:GetAttribute("Placed")~=true
        and (m:GetAttribute("Freed")==true or m:GetAttribute("Dropped")==true or m:GetAttribute("BuriedAt")~=nil)
        and m:GetAttribute("Rarity")~=nil
end

local queueTrack -- fwd (ใช้ wantShow ซึ่งประกาศทีหลัง)
queueTrack=function(m)
    if not tracked[m] and not pendSet[m] then pendSet[m]=true; pending[#pending+1]=m end
end

local function consider(m)
    if wiping then return end   -- ช่วง quarantine หลัง wipe: ของเก่ายังค้างใน workspace รอ server ลบ — อย่ารับกลับ
    local r=m:GetAttribute("Rarity") or "Common"
    known[m]=r
    local ok,p=pcall(function() return m:GetPivot().Position end)
    knownPos[m]=m:GetAttribute("FreedPos") or (ok and p) or knownPos[m]
    -- สร้างภาพเฉพาะตัวที่ผ่าน filter — ไม่สร้าง Highlight ทิ้งเปล่าให้พันตัว
    if wantShow(r, m:GetAttribute("GemName") or m.Name) then queueTrack(m) end
end

local function scan()
    -- กวาดเฉพาะจุดที่แรร์อยู่จริง: SpawnedGems (ทั้งฝัง/โผล่) + root (ของทิ้ง/Dropped)
    local sgm=workspace:FindFirstChild("SpawnedGems")
    if sgm then
        for _,d in ipairs(sgm:GetDescendants()) do if isGemModel(d) then consider(d) end end
    end
    for _,d in ipairs(workspace:GetChildren()) do
        if isGemModel(d) then consider(d)
        elseif d:IsA("Model") and d:GetAttribute("RuneId") and trackRune then trackRune(d) end
    end
end

-- ประมวลผลคิวทีละนิดต่อเฟรม — ไม่สร้างเป็นร้อยในจังหวะเดียว
task.spawn(function() while alive() do
    for _=1,20 do
        local m=table.remove(pending,1)
        if not m then break end
        pendSet[m]=nil
        if m.Parent then pcall(trackModel,m) end
    end
    task.wait()
end end)

-- ============ ESP ผู้เล่น ============
local ptracked={} -- [player]={hl,bb,t1,t2,digUntil}
local function trackPlayer(p)
    if p==LP or ptracked[p] then return end
    local hl=Instance.new("Highlight")
    hl.FillColor=Color3.fromRGB(80,230,130); hl.OutlineColor=Color3.new(1,1,1)
    hl.FillTransparency=0.75; hl.OutlineTransparency=0.2; hl.Parent=hlFolder
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,180,0,40); bb.StudsOffsetWorldSpace=Vector3.new(0,3.2,0)
    bb.AlwaysOnTop=true; bb.Parent=hlFolder
    local t1=Instance.new("TextLabel"); t1.Size=UDim2.new(1,0,0,20); t1.BackgroundTransparency=1
    t1.TextColor3=Color3.fromRGB(160,255,190); t1.TextStrokeTransparency=0.3; t1.TextSize=13; t1.Parent=bb; tfont(t1); t1.Font=Enum.Font.GothamBold
    local t2=Instance.new("TextLabel"); t2.Size=UDim2.new(1,0,0,15); t2.Position=UDim2.new(0,0,0,20); t2.BackgroundTransparency=1
    t2.TextColor3=Color3.fromRGB(200,205,225); t2.TextStrokeTransparency=0.4; t2.TextSize=11; t2.Parent=bb; tfont(t2)
    t1.Text="👷 "..(p.DisplayName or p.Name)
    ptracked[p]={hl=hl,bb=bb,t1=t1,t2=t2,digUntil=0}
end
for _,p in ipairs(Players:GetPlayers()) do trackPlayer(p) end
Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(function(p)
    local e=ptracked[p]
    if e then pcall(function() e.hl:Destroy() e.bb:Destroy() end) end
    ptracked[p]=nil
end)

workspace.DescendantAdded:Connect(function(d)
    if not alive() then return end
    if isGemModel(d) then
        task.defer(function() if d.Parent then consider(d) end end)
    elseif d:IsA("ProximityPrompt") and d.Name=="Pickup" then
        promptSet[d]=true
        if cfg.sub.instaPick then pcall(function() d.HoldDuration=0 end) end  -- ทริค InstantMineClient:41 ทำ client-side ได้เลย
    elseif d:IsA("Model") then
        -- รูน/อ็อบเจกต์ RuneId โผล่ใหม่ (attr อาจมาทีหลัง → defer แล้วเช็คใน trackRune)
        task.defer(function() if d.Parent and trackRune and d:GetAttribute("RuneId") then trackRune(d) end end)
    end
end)
workspace.DescendantRemoving:Connect(function(d) if d:IsA("ProximityPrompt") then promptSet[d]=nil end end)
task.spawn(function() while alive() do scan(); task.wait(4) end end)

-- FULL-MAP SCAN: ขอ stream grid ทั้งแมพ + scan lockstep (request → รอโหลด → scan ทันทีก่อน unstream)
local streamIdx=0
local grid={}
for gx=-4000,4000,1500 do for gz=-4000,4000,1500 do grid[#grid+1]=Vector3.new(gx,700,gz) end end
local gridIdx=0

local function fullScan()
    for _,d in ipairs(workspace:GetDescendants()) do
        if isGemModel(d) then consider(d)
        elseif d:IsA("ProximityPrompt") and d.Name=="Pickup" then
            promptSet[d]=true
            if cfg.sub.instaPick then pcall(function() d.HoldDuration=0 end) end
        end
    end
end

-- burst แรก: ยิงทั้ง 36 จุดพร้อมกัน → รอโหลด → กวาดทั้ง workspace ทีเดียว (ยอมกระตุก 1 วิ)
task.spawn(function()
    task.wait(2)
    if LP.RequestStreamAroundAsync then
        for _,g in ipairs(grid) do
            task.spawn(function() pcall(function()
                LP.ReplicationFocus=CFrame.new(g)
                LP:RequestStreamAroundAsync(g,8)
            end) end)
            task.wait(0.1)
        end
    end
    task.wait(2.5)
    fullScan()
    slog("burst scan done")
    task.wait(1.5)
    fullScan()
    pcall(function() LP.ReplicationFocus=nil end)
end)

-- loop ต่อเนื่อง: ย้าย ReplicationFocus ไปแต่ละจุด → server stream พื้นที่นั้นจริง (ไกลกว่าเดิมได้) → scan ก่อน unstream
local function pullPos(pos)
    pcall(function()
        LP.ReplicationFocus=CFrame.new(pos)
        LP:RequestStreamAroundAsync(pos,8)
    end)
end
task.spawn(function() while alive() do
    if LP.RequestStreamAroundAsync then
        if #pings>0 then
            local best={}
            for _,e in ipairs(pings) do best[#best+1]=e end
            table.sort(best,function(a,b) return rIdx(a.rarity)>rIdx(b.rarity) end)
            streamIdx=streamIdx%#best
            for j=0,math.min(4,#best-1) do
                pullPos(best[(streamIdx+j)%#best+1].pos)
                task.wait(0.4)
            end
            streamIdx+=5
        end
        for _=1,4 do
            gridIdx=gridIdx%#grid+1
            pullPos(grid[gridIdx])
            task.wait(0.4)
        end
        -- รอ stream เข้า → scan → คืน focus ให้ตัวเรา
        task.wait(1.2)
        scan()
        pcall(function() LP.ReplicationFocus=nil end)
    end
    task.wait(3)
end end)

-- ghost clone: ต้นแบบทรงคริสตัลของแต่ละ tier จาก GemModels (โชว์ทรงจริงตั้งแต่ไกล)
local ghostParent=Instance.new("Folder"); ghostParent.Name="HZGhost"; ghostParent.Parent=workspace
local tierRep={}
task.spawn(function()
    local gm=RS:WaitForChild("GemModels",30)
    if not gm then return end
    for _,m in ipairs(gm:GetChildren()) do
        if m:IsA("Model") then
            local r=m:GetAttribute("Rarity") or "Common"
            if not tierRep[r] then tierRep[r]=m end
        end
    end
    slog("tierRep "..tostring(#gm:GetChildren()))
end)

local function mkGhost(pos,rarity,kg)
    -- tier ที่ไม่มีต้นแบบ → ใช้ต้นแบบ tier สูงสุดที่มี (Zenith) แทน Common
    local src=tierRep[rarity]
    if not src then for i=#TIERS,1,-1 do if tierRep[TIERS[i]] then src=tierRep[TIERS[i]] break end end end
    local cl
    if src then
        local ok,c=pcall(function() return src:Clone() end)
        if ok then cl=c end
    end
    if not cl then
        -- fallback: ทรงกลมลอยตัว — ยังเห็นจุดทะลุกำแพงได้
        local p=Instance.new("Part"); p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(4,4,4)
        p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false
        p.Material=Enum.Material.Neon; p.Color=TCOL[rarity] or Color3.new(1,1,1); p.Transparency=0.4
        local m0=Instance.new("Model"); p.Parent=m0; m0.PrimaryPart=p; m0:PivotTo(CFrame.new(pos)); m0.Parent=ghostParent
        cl=m0
    else
        for _,d in ipairs(cl:GetDescendants()) do
            if d:IsA("BasePart") then d.Anchored=true; d.CanCollide=false; d.CanQuery=false; d.CanTouch=false; d.Transparency=0.45 end
            if d:IsA("BillboardGui") or d:IsA("ProximityPrompt") or d:IsA("Attachment") then d:Destroy() end
        end
        cl:PivotTo(CFrame.new(pos)); cl.Parent=ghostParent
    end
    local hl=Instance.new("Highlight"); hl.FillColor=TCOL[rarity] or Color3.new(1,1,1); hl.OutlineColor=Color3.new(1,1,1)
    hl.FillTransparency=0.5; hl.OutlineTransparency=0.1; hl.Adornee=cl; hl.Parent=hlFolder
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,220,0,36); bb.StudsOffsetWorldSpace=Vector3.new(0,4,0)
    bb.AlwaysOnTop=true; bb.Adornee=cl; bb.Parent=hlFolder
    local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,0,1,0); t.BackgroundTransparency=1
    t.TextColor3=TCOL[rarity] or Color3.new(1,1,1); t.TextStrokeTransparency=0.3; t.TextSize=12; t.Parent=bb; tfont(t); t.Font=Enum.Font.GothamBold
    t.Text=string.format("◆ %s · %.1fkg",rarity,kg)
    return cl,hl,bb,t
end

local RAW_N=0
local function addPing(...)
    local a={...}
    RAW_N+=1
    if RAW_N<=10 then
        local parts={}; for i,v in ipairs(a) do parts[#parts+1]=typeof(v)..":"..tostring(v) end
        slog("RAW["..RAW_N.."] "..table.concat(parts," | "))
    end
    local pos,rarity,kg
    for _,v in ipairs(a) do if typeof(v)=="Vector3" then pos=v end end
    if not pos and typeof(a[1])=="number" then pos=Vector3.new(a[1],a[2] or 0,a[3] or 0) end
    for _,v in ipairs(a) do
        if typeof(v)=="string" and not rarity then rarity=v end  -- รับทุกชื่อ tier รวมอนาคต
        if typeof(v)=="number" and not kg and v>0 and v<100000 then kg=v end
    end
    rarity=rarity or "Common"; kg=tonumber(kg) or 0
    if not pos then return end
    for _,e in ipairs(pings) do if (e.pos-pos).Magnitude<10 then e.t=os.clock() return end end
    for m in pairs(known) do local fp=m:GetAttribute("FreedPos") if fp and (fp-pos).Magnitude<15 then return end end
    local cl,hl,bb,t=mkGhost(pos,rarity,kg)
    if not cl then return end
    pings[#pings+1]={pos=pos,rarity=rarity,kg=kg,t=os.clock(),ghost=cl,hl=hl,bb=bb,txt=t}
    slog(string.format("GHOST %s %.1fkg @ %.0f,%.0f,%.0f",rarity,kg,pos.X,pos.Y,pos.Z))
    -- ขอ server stream พื้นที่นี้ → model จริงโหลด → ทรง/ชื่อจริงแทน ghost
    if LP.RequestStreamAroundAsync then
        task.spawn(function() pcall(function() LP:RequestStreamAroundAsync(pos,8) end) end)
    end
end

-- ============ event markers (เมเทียร์/ดาวตก — part จิ๋วมองไม่เห็น + ป้ายบนจอ) ============
local function mkMark(pos,txt,col,ttl)
    local p=Instance.new("Part"); p.Size=Vector3.new(0.5,0.5,0.5); p.Anchored=true; p.CanCollide=false
    p.CanQuery=false; p.CanTouch=false; p.Transparency=1; p.CFrame=CFrame.new(pos); p.Parent=ghostParent
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,200,0,26); bb.AlwaysOnTop=true
    bb.StudsOffsetWorldSpace=Vector3.new(0,3,0); bb.Adornee=p; bb.Parent=hlFolder
    local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,0,1,0); t.BackgroundTransparency=1
    t.TextColor3=col; t.TextStrokeTransparency=0.3; t.TextSize=13; t.Font=Enum.Font.GothamBold; t.Text=txt; t.Parent=bb; tfont(t)
    marks[#marks+1]={part=p,bb=bb,txt=t,pos=pos,exp=os.clock()+(ttl or 120),base=txt}
    return marks[#marks]
end
local function clearMarks(match)
    for i=#marks,1,-1 do
        local e=marks[i]
        if (not match) or e.base:find(match) then pcall(function() e.part:Destroy() e.bb:Destroy() end) table.remove(marks,i) end
    end
end

-- ============ rune ESP (PlotRunes — รูนที่ปักในโลก มี RuneId/RuneMesh) ============
local function runeCol(id)
    local d=RD and RD.Runes and RD.Runes[id]
    local c=d and d.color
    if typeof(c)=="Color3" then return c end
    return Color3.fromRGB(255,170,255)
end
local function runeName(id)
    local d=RD and RD.Runes and RD.Runes[id]
    return (d and (d.name or d.Name)) or id
end
trackRune=function(m)
    if rtrack[m] then return end
    local id=m:GetAttribute("RuneId"); if not id then return end
    local col=runeCol(id)
    local hl=Instance.new("Highlight"); hl.FillColor=col; hl.OutlineColor=Color3.new(1,1,1)
    hl.FillTransparency=0.7; hl.OutlineTransparency=0.2; hl.Adornee=m; hl.Parent=hlFolder
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,170,0,36); bb.StudsOffsetWorldSpace=Vector3.new(0,4,0)
    bb.AlwaysOnTop=true; bb.Adornee=m; bb.Parent=hlFolder
    local t1=Instance.new("TextLabel"); t1.Size=UDim2.new(1,0,0,18); t1.BackgroundTransparency=1
    t1.TextColor3=col; t1.TextStrokeTransparency=0.3; t1.TextSize=12; t1.Font=Enum.Font.GothamBold; t1.Parent=bb; tfont(t1)
    local t2=Instance.new("TextLabel"); t2.Size=UDim2.new(1,0,0,14); t2.Position=UDim2.new(0,0,0,18); t2.BackgroundTransparency=1
    t2.TextColor3=Color3.fromRGB(220,225,245); t2.TextStrokeTransparency=0.4; t2.TextSize=10; t2.Parent=bb; tfont(t2)
    t1.Text="🔮 "..runeName(id)
    rtrack[m]={hl=hl,bb=bb,t2=t2,id=id}
end
local function scanRunes()
    local pr=workspace:FindFirstChild("PlotRunes")
    if pr then for _,d in ipairs(pr:GetDescendants()) do if d:IsA("Model") and d:GetAttribute("RuneId") then trackRune(d) end end end
end

-- ============ panel ============
local PW,FULL_H=300,420
local sg=Instance.new("ScreenGui"); sg.Name="HZMineUI"; sg.ResetOnSpawn=false; sg.DisplayOrder=100; sg.Parent=CoreGui
local sh=Instance.new("Frame"); sh.Name="HZShadow"; sh.Size=UDim2.new(0,PW+16,0,FULL_H+16); sh.Position=UDim2.new(0,52,0,52)
sh.BackgroundColor3=Color3.new(0,0,0); sh.BackgroundTransparency=0.55; sh.BorderSizePixel=0; sh.Parent=sg; corner(sh,20); sh=nil
local f=Instance.new("Frame"); f.Size=UDim2.new(0,PW,0,FULL_H); f.Position=UDim2.new(0,60,0,60)
f.BackgroundTransparency=0.03; f.BorderSizePixel=0; f.Active=true; f.ClipsDescendants=true; f.Parent=sg; corner(f,14); stroke(f,C.edge,0.45)
local fg=Instance.new("UIGradient"); fg.Color=ColorSequence.new(C.bgTop,C.bgBot); fg.Rotation=90; fg.Parent=f
local topBar=Instance.new("Frame"); topBar.Size=UDim2.new(1,0,0,2); topBar.BackgroundColor3=Color3.new(1,1,1); topBar.BorderSizePixel=0; topBar.Parent=f
local tg=agrad(topBar); tg.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.5),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,0.5)}
do
    local logo=Instance.new("Frame"); logo.Size=UDim2.new(0,30,0,30); logo.Position=UDim2.new(0,12,0,9); logo.BackgroundColor3=C.accent2; logo.BorderSizePixel=0; logo.Parent=f; corner(logo,15); agrad(logo)
    local lo=Instance.new("TextLabel"); lo.Size=UDim2.new(1,0,1,0); lo.BackgroundTransparency=1; lo.Text="⛏"; lo.TextSize=15; lo.TextColor3=Color3.new(1,1,1); lo.Parent=logo; tfont(lo)
end
local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-120,0,28); title.Position=UDim2.new(0,50,0,8)
title.BackgroundTransparency=1; title.Text="HZ HUB"; title.TextXAlignment=Enum.TextXAlignment.Left; title.TextSize=17; title.TextColor3=Color3.new(1,1,1); title.Parent=f; title.Font=Enum.Font.GothamBlack; agrad(title)
local sub=Instance.new("TextLabel"); sub.Size=UDim2.new(1,-120,0,14); sub.Position=UDim2.new(0,50,0,34)
sub.BackgroundTransparency=1; sub.Text="Rare ESP · v5 · เบต้า"; sub.TextXAlignment=Enum.TextXAlignment.Left; sub.TextSize=10; sub.TextColor3=C.dim; sub.Parent=f; tfont(sub)
local closeB=Instance.new("TextButton"); closeB.Size=UDim2.new(0,28,0,28); closeB.Position=UDim2.new(1,-36,0,8)
closeB.BackgroundColor3=Color3.fromRGB(190,55,70); closeB.Text="X"; closeB.TextColor3=C.txt; closeB.TextSize=14; closeB.Font=Enum.Font.GothamBold; closeB.Parent=f; corner(closeB,8); hover(closeB,closeB,Color3.fromRGB(190,55,70),Color3.fromRGB(230,75,90))
closeB.Activated:Connect(function()
    sfx("tick")
    -- ✕ = ปิดสคริปต์จริง: ฆ่า generation → ทุก loop/hook หยุด (รันใหม่ได้ปกติ)
    G.__HZMINE=G.__HZMINE+1
    sg:Destroy() esp:Destroy()
    pcall(function() ghostParent:Destroy() end)
    slog("closed+killed")
end)
-- ปุ่มพับจอสร้างหลัง body (ต้องเห็นตัวแปร) — อยู่บล็อกถัดไป
local drag,ds,sp
f.InputBegan:Connect(function(i) if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and (i.Position.Y-f.AbsolutePosition.Y)<46 then drag=true; ds=i.Position; sp=f.Position end end)
f.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-ds; f.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) local sd=sg:FindFirstChild("HZShadow") if sd then sd.Position=f.Position-UDim2.new(0,8,0,8) end end end)

local body=Instance.new("ScrollingFrame"); body.Size=UDim2.new(1,-20,1,-54); body.Position=UDim2.new(0,10,0,48)
body.BackgroundTransparency=1; body.Parent=f; body.ScrollBarThickness=3; body.ScrollBarImageColor3=C.accent; body.AutomaticCanvasSize=Enum.AutomaticSize.Y; body.CanvasSize=UDim2.new(0,0,0,0)
-- ปุ่มพับจอ: ย่อเหลือแถบ header คลิกขยายกลับ (state เก็บใน cfg ไม่กิน register)
do
    local minB=Instance.new("TextButton"); minB.Size=UDim2.new(0,28,0,28); minB.Position=UDim2.new(1,-68,0,8)
    minB.BackgroundColor3=C.opt2; minB.Text="-"; minB.TextColor3=C.txt; minB.TextSize=16; minB.Parent=f; corner(minB,8); tfont(minB); hover(minB,minB,C.opt2,C.optH)
    minB.Activated:Connect(function()
        cfg._fold=not cfg._fold; sfx("tick")
        body.Visible=not cfg._fold
        Tween:Create(f,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Size=cfg._fold and UDim2.new(0,PW,0,50) or UDim2.new(0,PW,0,FULL_H)}):Play()
        local sd=sg:FindFirstChild("HZShadow")
        if sd then Tween:Create(sd,TweenInfo.new(0.18),{Size=cfg._fold and UDim2.new(0,PW+16,0,66) or UDim2.new(0,PW+16,0,FULL_H+16)}):Play() end
        minB.Text=cfg._fold and "+" or "-"
    end)
end

local row1=Instance.new("Frame"); row1.Size=UDim2.new(1,0,0,32); row1.BackgroundColor3=C.row; row1.Parent=body; corner(row1,9); stroke(row1,C.edge,0.8)
do local rl=Instance.new("TextLabel"); rl.Size=UDim2.new(1,-120,1,0); rl.Position=UDim2.new(0,10,0,0); rl.BackgroundTransparency=1; rl.Text="เรดาร์แรร์ ESP"; rl.TextSize=13; rl.TextColor3=C.txt; rl.TextXAlignment=Enum.TextXAlignment.Left; rl.Parent=row1; tfont(rl)
local pill=Instance.new("Frame"); pill.Size=UDim2.new(0,40,0,18); pill.Position=UDim2.new(1,-48,0.5,-9); pill.BackgroundColor3=C.on; pill.Parent=row1; corner(pill,9)
local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new(1,-16,0.5,-7); knob.BackgroundColor3=Color3.new(1,1,1); knob.Parent=pill; corner(knob,7)
local hit=Instance.new("TextButton"); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.Parent=row1
chip(row1,"🛰",C.accent) shiftLbl(rl) polishPill(pill,knob) hover(hit,row1,C.row,C.rowH)
hit.Activated:Connect(function()
    cfg.esp=not cfg.esp; sfx("pop")
    Tween:Create(pill,TweenInfo.new(0.15),{BackgroundColor3=cfg.esp and C.on or C.off}):Play()
    Tween:Create(knob,TweenInfo.new(0.15),{Position=cfg.esp and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
    applyFilter()
end) end

local row2=Instance.new("Frame"); row2.Size=UDim2.new(1,0,0,32); row2.Position=UDim2.new(0,0,0,38); row2.BackgroundColor3=C.row; row2.Parent=body; corner(row2,9); stroke(row2,C.edge,0.8)
local r2l=Instance.new("TextLabel"); r2l.Size=UDim2.new(0.6,0,1,0); r2l.Position=UDim2.new(0,10,0,0); r2l.BackgroundTransparency=1; r2l.Text="แสดงเฉพาะระดับ"; r2l.TextSize=12; r2l.TextColor3=C.dim; r2l.TextXAlignment=Enum.TextXAlignment.Left; r2l.Parent=row2; tfont(r2l)
chip(row2,"🏷",C.dim) shiftLbl(r2l)
local tierBtn=Instance.new("TextButton"); tierBtn.Size=UDim2.new(0.36,0,0,22); tierBtn.Position=UDim2.new(0.62,0,0.5,-11); tierBtn.BackgroundColor3=C.opt2; tierBtn.TextSize=12; tierBtn.Parent=row2; corner(tierBtn,7); tfont(tierBtn); hover(tierBtn,tierBtn,C.opt2,C.optH)
wantShow=function(rarity,name)
    if not cfg.esp then return false end
    if cfg.pickMode then return picks[name]==true end
    local idx=tIdx(rarity)
    if idx==0 then return true end  -- tier ใหม่ที่ยังไม่รู้จัก → โชว์เสมอ ไม่ให้หลุด
    return idx==cfg.minTier         -- เลือกระดับไหนเห็นแค่ระดับนั้น
end
applyFilter=function()
    -- ทำลายภาพของตัวที่ไม่ผ่าน filter + เข้าคิวสร้างตัวที่ผ่าน — ภาพมีเท่าที่แสดงจริง
    for m,e in pairs(tracked) do
        if wantShow(e.rarity,e.id) then
            e.hl.Enabled=true; e.bb.Enabled=true
        else
            pcall(function() e.hl:Destroy() e.bb:Destroy() end); tracked[m]=nil
        end
    end
    for m,r in pairs(known) do
        if m.Parent and wantShow(r, m:GetAttribute("GemName") or m.Name) then queueTrack(m) end
    end
end
local function paintTier() local t=TIERS[cfg.minTier]; tierBtn.Text="= "..t; tierBtn.TextColor3=TCOL[t] end
tierBtn.Activated:Connect(function() cfg.minTier=cfg.minTier%#TIERS+1; sfx("tick") paintTier() applyFilter() end)
paintTier()

-- toggle ESP ผู้เล่น
local rowP=Instance.new("Frame"); rowP.Size=UDim2.new(1,0,0,32); rowP.Position=UDim2.new(0,0,0,74); rowP.BackgroundColor3=C.row; rowP.Parent=body; corner(rowP,9); stroke(rowP,C.edge,0.8)
do local pl2=Instance.new("TextLabel"); pl2.Size=UDim2.new(1,-120,1,0); pl2.Position=UDim2.new(0,10,0,0); pl2.BackgroundTransparency=1; pl2.Text="ESP ผู้เล่น (ใครอยู่ไหน)"; pl2.TextSize=13; pl2.TextColor3=C.txt; pl2.TextXAlignment=Enum.TextXAlignment.Left; pl2.Parent=rowP; tfont(pl2)
local pillP=Instance.new("Frame"); pillP.Size=UDim2.new(0,40,0,18); pillP.Position=UDim2.new(1,-48,0.5,-9); pillP.BackgroundColor3=C.on; pillP.Parent=rowP; corner(pillP,9)
local knobP=Instance.new("Frame"); knobP.Size=UDim2.new(0,14,0,14); knobP.Position=UDim2.new(1,-16,0.5,-7); knobP.BackgroundColor3=Color3.new(1,1,1); knobP.Parent=pillP; corner(knobP,7)
local hitP=Instance.new("TextButton"); hitP.Size=UDim2.new(1,0,1,0); hitP.BackgroundTransparency=1; hitP.Text=""; hitP.Parent=rowP
chip(rowP,"👥",Color3.fromRGB(80,200,255)) shiftLbl(pl2) polishPill(pillP,knobP) hover(hitP,rowP,C.row,C.rowH)
hitP.Activated:Connect(function()
    cfg.players=not cfg.players; sfx("pop")
    Tween:Create(pillP,TweenInfo.new(0.15),{BackgroundColor3=cfg.players and C.on or C.off}):Play()
    Tween:Create(knobP,TweenInfo.new(0.15),{Position=cfg.players and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
end) end

-- toggle ขุดออโต้
local rowD=Instance.new("Frame"); rowD.Size=UDim2.new(1,0,0,32); rowD.Position=UDim2.new(0,0,0,110); rowD.BackgroundColor3=C.row; rowD.Parent=body; corner(rowD,9); stroke(rowD,C.edge,0.8)
do local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,-120,1,0); dl.Position=UDim2.new(0,10,0,0); dl.BackgroundTransparency=1; dl.Text="ขุดออโต้ (ถือพลั่วอยู่)"; dl.TextSize=13; dl.TextColor3=C.txt; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.Parent=rowD; tfont(dl)
local pillD=Instance.new("Frame"); pillD.Size=UDim2.new(0,40,0,18); pillD.Position=UDim2.new(1,-48,0.5,-9); pillD.BackgroundColor3=C.off; pillD.Parent=rowD; corner(pillD,9)
local knobD=Instance.new("Frame"); knobD.Size=UDim2.new(0,14,0,14); knobD.Position=UDim2.new(0,2,0.5,-7); knobD.BackgroundColor3=Color3.new(1,1,1); knobD.Parent=pillD; corner(knobD,7)
local hitD=Instance.new("TextButton"); hitD.Size=UDim2.new(1,0,1,0); hitD.BackgroundTransparency=1; hitD.Text=""; hitD.Parent=rowD
chip(rowD,"⛏",Color3.fromRGB(255,170,60)) shiftLbl(dl) polishPill(pillD,knobD) hover(hitD,rowD,C.row,C.rowH)
hitD.Activated:Connect(function()
    cfg.autodig=not cfg.autodig; sfx("pop")
    Tween:Create(pillD,TweenInfo.new(0.15),{BackgroundColor3=cfg.autodig and C.on or C.off}):Play()
    Tween:Create(knobD,TweenInfo.new(0.15),{Position=cfg.autodig and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
    slog("autodig "..tostring(cfg.autodig))
end) end

-- toggle เก็บออโต้
local rowC=Instance.new("Frame"); rowC.Size=UDim2.new(1,0,0,32); rowC.Position=UDim2.new(0,0,0,146); rowC.BackgroundColor3=C.row; rowC.Parent=body; corner(rowC,9); stroke(rowC,C.edge,0.8)
do local cl=Instance.new("TextLabel"); cl.Size=UDim2.new(1,-120,1,0); cl.Position=UDim2.new(0,10,0,0); cl.BackgroundTransparency=1; cl.Text="เก็บแรร์ออโต้"; cl.TextSize=13; cl.TextColor3=C.txt; cl.TextXAlignment=Enum.TextXAlignment.Left; cl.Parent=rowC; tfont(cl)
local pillC=Instance.new("Frame"); pillC.Size=UDim2.new(0,40,0,18); pillC.Position=UDim2.new(1,-48,0.5,-9); pillC.BackgroundColor3=C.off; pillC.Parent=rowC; corner(pillC,9)
local knobC=Instance.new("Frame"); knobC.Size=UDim2.new(0,14,0,14); knobC.Position=UDim2.new(0,2,0.5,-7); knobC.BackgroundColor3=Color3.new(1,1,1); knobC.Parent=pillC; corner(knobC,7)
local hitC=Instance.new("TextButton"); hitC.Size=UDim2.new(1,0,1,0); hitC.BackgroundTransparency=1; hitC.Text=""; hitC.Parent=rowC
chip(rowC,"✋",Color3.fromRGB(120,255,170)) shiftLbl(cl) polishPill(pillC,knobC) hover(hitC,rowC,C.row,C.rowH)
hitC.Activated:Connect(function()
    cfg.autocollect=not cfg.autocollect; sfx("pop")
    Tween:Create(pillC,TweenInfo.new(0.15),{BackgroundColor3=cfg.autocollect and C.on or C.off}):Play()
    Tween:Create(knobC,TweenInfo.new(0.15),{Position=cfg.autocollect and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
    slog("autocollect "..tostring(cfg.autocollect))
end) end

-- toggle ขายออโต้ (BagFull → TeleportSell → ขายหมด → กลับจุดเดิม)
local rowS=Instance.new("Frame"); rowS.Size=UDim2.new(1,0,0,32); rowS.Position=UDim2.new(0,0,0,182); rowS.BackgroundColor3=C.row; rowS.Parent=body; corner(rowS,9); stroke(rowS,C.edge,0.8)
do local sl=Instance.new("TextLabel"); sl.Size=UDim2.new(1,-120,1,0); sl.Position=UDim2.new(0,10,0,0); sl.BackgroundTransparency=1; sl.Text="ขายออโต้ (กระเป๋าเต็ม)"; sl.TextSize=13; sl.TextColor3=C.txt; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.Parent=rowS; tfont(sl)
local pillS=Instance.new("Frame"); pillS.Size=UDim2.new(0,40,0,18); pillS.Position=UDim2.new(1,-48,0.5,-9); pillS.BackgroundColor3=C.off; pillS.Parent=rowS; corner(pillS,9)
local knobS=Instance.new("Frame"); knobS.Size=UDim2.new(0,14,0,14); knobS.Position=UDim2.new(0,2,0.5,-7); knobS.BackgroundColor3=Color3.new(1,1,1); knobS.Parent=pillS; corner(knobS,7)
local hitS=Instance.new("TextButton"); hitS.Size=UDim2.new(1,0,1,0); hitS.BackgroundTransparency=1; hitS.Text=""; hitS.Parent=rowS
chip(rowS,"💰",Color3.fromRGB(255,220,90)) shiftLbl(sl) polishPill(pillS,knobS) hover(hitS,rowS,C.row,C.rowH)
hitS.Activated:Connect(function()
    cfg.autosell=not cfg.autosell; sfx("pop")
    Tween:Create(pillS,TweenInfo.new(0.15),{BackgroundColor3=cfg.autosell and C.on or C.off}):Play()
    Tween:Create(knobS,TweenInfo.new(0.15),{Position=cfg.autosell and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
    slog("autosell "..tostring(cfg.autosell))
end) end

-- ============ แถวใหม่ (toggle ล้วน — sub สร้างรวมทีเดียวด้านล่าง) ============
local function mkRow(icon,txt,col,on,get,set)
    local r=Instance.new("Frame"); r.Size=UDim2.new(1,0,0,32); r.BackgroundColor3=C.row; r.Parent=body; corner(r,9); stroke(r,C.edge,0.8)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-140,1,0); l.Position=UDim2.new(0,36,0,0); l.BackgroundTransparency=1
    l.Text=txt; l.TextSize=13; l.TextColor3=C.txt; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r; tfont(l)
    local pl=Instance.new("Frame"); pl.Size=UDim2.new(0,40,0,18); pl.Position=UDim2.new(1,-48,0.5,-9)
    pl.BackgroundColor3=on and C.on or C.off; pl.Parent=r; corner(pl,9)
    local kn=Instance.new("Frame"); kn.Size=UDim2.new(0,14,0,14); kn.Position=on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    kn.BackgroundColor3=Color3.new(1,1,1); kn.Parent=pl; corner(kn,7)
    local h=Instance.new("TextButton"); h.Size=UDim2.new(1,0,1,0); h.BackgroundTransparency=1; h.Text=""; h.Parent=r
    h.Activated:Connect(function()
        local v=not get(); set(v); sfx("pop")
        Tween:Create(pl,TweenInfo.new(0.15),{BackgroundColor3=v and C.on or C.off}):Play()
        Tween:Create(kn,TweenInfo.new(0.15),{Position=v and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
    end)
    chip(r,icon,col) polishPill(pl,kn) hover(h,r,C.row,C.rowH)
    return r,l
end
local rowMet=mkRow("☄","เมเทียร์ + ดาวตก",Color3.fromRGB(255,130,90),cfg.met,function() return cfg.met end,function(v) cfg.met=v end)
local rowRun,rowRunL=mkRow("🔮","รูน ESP",Color3.fromRGB(190,130,255),cfg.runes,function() return cfg.runes end,function(v) cfg.runes=v applyFilter() end)
local rowMtn,rowMtnL=mkRow("🏔","ภูเขา",Color3.fromRGB(160,220,255),cfg.mtn,function() return cfg.mtn end,function(v) cfg.mtn=v sfx("tick") end)
local rowUp,rowUpL=mkRow("⬆","อัพเกรดอัตโนมัติ",C.accent2,cfg.autoup,function() return cfg.autoup end,function(v) cfg.autoup=v slog("autoup "..tostring(v)) end)

-- HUD สถานะตัวเรา (attrs สดจาก server)
local hud=Instance.new("TextLabel"); hud.Size=UDim2.new(1,0,0,26); hud.BackgroundTransparency=1
hud.Text="—"; hud.TextSize=10; hud.TextColor3=C.txt; hud.TextXAlignment=Enum.TextXAlignment.Left; hud.TextWrapped=true; hud.Parent=body; tfont(hud)

-- ตัวนับตามระดับ (2 แถว × 4 ช่อง)
local cnt=Instance.new("TextLabel"); cnt.Size=UDim2.new(1,0,0,14); cnt.Position=UDim2.new(0,0,0,184); cnt.BackgroundTransparency=1
cnt.Text="แรร์ในเซิร์ฟเวอร์"; cnt.TextSize=10; cnt.TextColor3=C.dim; cnt.TextXAlignment=Enum.TextXAlignment.Left; cnt.Parent=body; tfont(cnt)
local tierRows=math.ceil(#TIERS/4)
local tierBox=Instance.new("Frame"); tierBox.Size=UDim2.new(1,0,0,tierRows*21+6); tierBox.Position=UDim2.new(0,0,0,200); tierBox.BackgroundColor3=C.panel; tierBox.Parent=body; corner(tierBox,8); stroke(tierBox,C.edge,0.85)
local tierLbl={}
for i,t in ipairs(TIERS) do
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(0.25,0,0,21); l.BackgroundTransparency=1
    l.Position=UDim2.new(((i-1)%4)*0.25,0,0,math.floor((i-1)/4)*21+3)
    l.Text=t..": 0"; l.TextSize=10; l.TextColor3=TCOL[t] or Color3.new(1,1,1); l.TextXAlignment=Enum.TextXAlignment.Center; l.Parent=tierBox; tfont(l)
    tierLbl[t]=l
end
-- ช่อง "อื่นๆ" รวม tier ที่ยังไม่รู้จัก (กันอนาคต)
local otherLbl=Instance.new("TextLabel"); otherLbl.Size=UDim2.new(0.25,0,0,21); otherLbl.BackgroundTransparency=1
otherLbl.Position=UDim2.new((#TIERS%4)*0.25,0,0,math.floor(#TIERS/4)*21+3)
otherLbl.Text="?: 0"; otherLbl.TextSize=10; otherLbl.TextColor3=Color3.new(1,1,1); otherLbl.TextXAlignment=Enum.TextXAlignment.Center; otherLbl.Parent=tierBox; tfont(otherLbl)

local feed=Instance.new("Frame"); feed.Size=UDim2.new(1,0,0,64); feed.Position=UDim2.new(0,0,0,252); feed.BackgroundColor3=C.panel; feed.Parent=body; corner(feed,9); stroke(feed,C.edge,0.85)
local fl=Instance.new("UIListLayout",feed); fl.Padding=UDim.new(0,1); fl.SortOrder=Enum.SortOrder.LayoutOrder
local fp=Instance.new("UIPadding",feed); fp.PaddingTop=UDim.new(0,4); fp.PaddingLeft=UDim.new(0,8)
local feedN=0
feedAdd=function(txt,col)
    feedN+=1
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-8,0,15); l.BackgroundTransparency=1; l.LayoutOrder=-feedN
    l.Text=txt; l.TextSize=11; l.TextColor3=col or C.txt; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=feed; tfont(l)
    local c=0; for _,k in ipairs(feed:GetChildren()) do if k:IsA("TextLabel") then c+=1; if c>6 then k:Destroy() end end end
end

local stat=Instance.new("TextLabel"); stat.Size=UDim2.new(1,0,0,16); stat.Position=UDim2.new(0,0,0,0); stat.BackgroundTransparency=1
stat.Text="RightShift = ซ่อน"; stat.TextSize=10; stat.TextColor3=C.dim; stat.TextXAlignment=Enum.TextXAlignment.Left; stat.Parent=body; tfont(stat)

-- ============ ฟีเจอร์ย่อย (กด ▸ ขยายใต้แถว) ============
local layout -- fwd
local function subFrame(n)
    local s=Instance.new("Frame"); s.Size=UDim2.new(1,0,0,n*30+6); s.BackgroundColor3=C.sub
    s.Visible=false; s.Parent=body; corner(s,8); stroke(s,C.edge,0.85)
    return s
end
local function mOpt(par,txt,key,y)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-16,0,26); b.Position=UDim2.new(0,8,0,3+y); b.BackgroundColor3=C.opt; b.Text=""; b.Parent=par; corner(b,6); hover(b,b,C.opt,C.optH)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-46,1,0); l.Position=UDim2.new(0,8,0,0); l.BackgroundTransparency=1
    l.Text=txt; l.TextSize=11; l.TextColor3=C.txt; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=b; tfont(l)
    local pl=Instance.new("Frame"); pl.Size=UDim2.new(0,32,0,14); pl.Position=UDim2.new(1,-38,0.5,-7); pl.Parent=b; corner(pl,7)
    local kn=Instance.new("Frame"); kn.Size=UDim2.new(0,10,0,10); kn.Parent=pl; kn.BackgroundColor3=Color3.new(1,1,1); corner(kn,5)
    local function paint() local on=cfg.sub[key]; pl.BackgroundColor3=on and C.on or C.off; kn.Position=on and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5) end
    b.Activated:Connect(function() cfg.sub[key]=not cfg.sub[key] sfx("tick") paint() end)
    paint()
end
local subEsp=subFrame(5) mOpt(subEsp,"Highlight ทรงแรร์","espHl",0) mOpt(subEsp,"ป้ายชื่อ + ระยะ","espName",30) mOpt(subEsp,"ghost จุดไกล (ทรงจำลอง)","ghost",60) mOpt(subEsp,"ป้าย ghost","ghostLbl",90) mOpt(subEsp,"❤ HP ตัวที่โดนขุด","hpBar",120)
local subP=subFrame(3) mOpt(subP,"Highlight ตัวละคร","pHl",0) mOpt(subP,"ป้ายชื่อ + ระยะ","pName",30) mOpt(subP,"แท็ก ⛏กำลังขุด","pDig",60)
local subD=subFrame(2) mOpt(subD,"เล็งแรร์ฝังใต้ดิน (smart)","smartDig",0) mOpt(subD,"🔥 Turbo ขุดเร็วขึ้น (เสี่ยง ถ้า server จับ)","turboDig",30)
local subC=subFrame(2) mOpt(subC,"เช็คระยะ prompt ก่อนยิง","colRange",0) mOpt(subC,"⚡ เก็บทันที (Hold=0 ทริค pass จริง)","instaPick",30)
local subMet=subFrame(2) mOpt(subMet,"ป้ายจุดตกบนแมพ","metMark",0) mOpt(subMet,"แจ้งเตือนใน feed","metFeed",30)
local subUp=subFrame(2) mOpt(subUp,"🎒 ซื้อ Carry (กระเป๋าใหญ่)","upCarry",0) mOpt(subUp,"🔥 ซื้อ Warmth (ขึ้นสูงได้)","upWarm",30)
local subRun=subFrame(2) mOpt(subRun,"Highlight รูน","runeHl",0) mOpt(subRun,"ป้ายชื่อรูน + ระยะ","runeLbl",30)

-- ภูเขา: sub = auto-toggle + รายการภูเขา (สร้างเมื่อ MountainPool พร้อม)
local subMtn=Instance.new("Frame"); subMtn.Size=UDim2.new(1,0,0,196); subMtn.BackgroundColor3=C.sub
subMtn.Visible=false; subMtn.Parent=body; corner(subMtn,8); stroke(subMtn,C.edge,0.85)
mOpt(subMtn,"🔁 auto ขึ้นภูเขาดีสุด (ใช้สวิตช์)","mtnAuto",0)
local mtnSw=Instance.new("TextLabel"); mtnSw.Size=UDim2.new(1,-16,0,22); mtnSw.Position=UDim2.new(0,8,0,33); mtnSw.BackgroundTransparency=1
mtnSw.Text="สวิตช์: — · หมุนใน: —"; mtnSw.TextSize=10; mtnSw.TextColor3=C.dim; mtnSw.TextXAlignment=Enum.TextXAlignment.Left; mtnSw.Parent=subMtn; tfont(mtnSw)
local mtList=Instance.new("ScrollingFrame"); mtList.Size=UDim2.new(1,-16,0,128); mtList.Position=UDim2.new(0,8,0,58)
mtList.BackgroundColor3=C.deep; mtList.ScrollBarThickness=3; mtList.ScrollBarImageColor3=C.accent; mtList.AutomaticCanvasSize=Enum.AutomaticSize.Y
mtList.CanvasSize=UDim2.new(); mtList.Parent=subMtn; corner(mtList,6)
local mtLay=Instance.new("UIListLayout",mtList); mtLay.Padding=UDim.new(0,3); mtLay.SortOrder=Enum.SortOrder.LayoutOrder

-- ขาย: sub = ขายระยะไกล + ปุ่มขายหมดตรงนี้ + รายการกระเป๋า (เลือกขายชิ้น)
local subS=Instance.new("Frame"); subS.Size=UDim2.new(1,0,0,172); subS.BackgroundColor3=C.sub
subS.Visible=false; subS.Parent=body; corner(subS,8); stroke(subS,C.edge,0.85)
mOpt(subS,"📡 ขายระยะไกล — ไม่วาป (ทดลอง)","remoteSell",0)
local sellAllB=Instance.new("TextButton"); sellAllB.Size=UDim2.new(1,-16,0,24); sellAllB.Position=UDim2.new(0,8,0,33)
sellAllB.BackgroundColor3=C.buy; sellAllB.Text="💰 ขายทั้งหมดตรงนี้ (ไม่วาป)"; sellAllB.TextColor3=C.txt
sellAllB.TextSize=11; sellAllB.Parent=subS; corner(sellAllB,6); tfont(sellAllB); hover(sellAllB,sellAllB,C.buy,Color3.fromRGB(56,150,84))
local bagList=Instance.new("ScrollingFrame"); bagList.Size=UDim2.new(1,-16,0,102); bagList.Position=UDim2.new(0,8,0,62)
bagList.BackgroundColor3=C.deep; bagList.ScrollBarThickness=3; bagList.ScrollBarImageColor3=C.accent; bagList.AutomaticCanvasSize=Enum.AutomaticSize.Y
bagList.CanvasSize=UDim2.new(); bagList.Parent=subS; corner(bagList,6)
local bagLay=Instance.new("UIListLayout",bagList); bagLay.Padding=UDim.new(0,2); bagLay.SortOrder=Enum.SortOrder.LayoutOrder

local subs={[subEsp]=true,[subP]=true,[subD]=true,[subC]=true,[subMet]=true,[subRun]=true,[subMtn]=true,[subUp]=true,[subS]=true}
local flow={row1,subEsp,row2,rowP,subP,rowD,subD,rowC,subC,rowS,subS,rowUp,subUp,rowMet,subMet,rowRun,subRun,rowMtn,subMtn,hud,cnt,tierBox,feed,stat}
layout=function()
    local y=0
    for _,el in ipairs(flow) do
        if not (subs[el] and not el.Visible) then
            el.Position=UDim2.new(0,0,0,y); y+=el.Size.Y.Offset+6
        end
    end
    body.CanvasSize=UDim2.new(0,0,0,y)
end
local function chev(row,sub)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(0,20,0,20); b.Position=UDim2.new(1,-74,0.5,-10); b.BackgroundColor3=C.opt2
    b.Text=">"; b.TextColor3=C.dim; b.TextSize=12; b.TextXAlignment=Enum.TextXAlignment.Center; b.Parent=row; corner(b,5); hover(b,b,C.opt2,C.optH); tfont(b)
    b.Activated:Connect(function() sub.Visible=not sub.Visible; b.Text=sub.Visible and "v" or ">"; b.TextColor3=sub.Visible and C.accent or C.dim; sfx("tick") layout() end)
end
chev(row1,subEsp); chev(rowP,subP); chev(rowD,subD); chev(rowC,subC); chev(rowS,subS); chev(rowUp,subUp); chev(rowMet,subMet); chev(rowRun,subRun); chev(rowMtn,subMtn)
layout()

-- ============ แถว 🧍 ตัวเรา (do-block กัน register) — อยู่หลัง ขุดออโต้ ใน flow ============
do
    local rowF=Instance.new("Frame"); rowF.Size=UDim2.new(1,0,0,32); rowF.BackgroundColor3=C.row; rowF.Parent=body; corner(rowF,9); stroke(rowF,C.edge,0.8)
    local fl=Instance.new("TextLabel"); fl.Size=UDim2.new(1,-120,1,0); fl.Position=UDim2.new(0,10,0,0); fl.BackgroundTransparency=1; fl.Text="ตัวเรา (วิ่งไว)"; fl.TextSize=13; fl.TextColor3=C.txt; fl.TextXAlignment=Enum.TextXAlignment.Left; fl.Parent=rowF; tfont(fl)
    local pillF=Instance.new("Frame"); pillF.Size=UDim2.new(0,40,0,18); pillF.Position=UDim2.new(1,-48,0.5,-9); pillF.BackgroundColor3=C.off; pillF.Parent=rowF; corner(pillF,9)
    local knobF=Instance.new("Frame"); knobF.Size=UDim2.new(0,14,0,14); knobF.Position=UDim2.new(0,2,0.5,-7); knobF.BackgroundColor3=Color3.new(1,1,1); knobF.Parent=pillF; corner(knobF,7)
    local hitF=Instance.new("TextButton"); hitF.Size=UDim2.new(1,0,1,0); hitF.BackgroundTransparency=1; hitF.Text=""; hitF.Parent=rowF
    chip(rowF,"🧍",Color3.fromRGB(140,255,220)) shiftLbl(fl) polishPill(pillF,knobF) hover(hitF,rowF,C.row,C.rowH)
    hitF.Activated:Connect(function()
        cfg.selfOn=not cfg.selfOn; sfx("pop")
        Tween:Create(pillF,TweenInfo.new(0.15),{BackgroundColor3=cfg.selfOn and C.on or C.off}):Play()
        Tween:Create(knobF,TweenInfo.new(0.15),{Position=cfg.selfOn and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        slog("self "..tostring(cfg.selfOn))
    end)
    local subF=subFrame(2)
    mOpt(subF,"🏃 วิ่งไว 1.5x (ปลอดภัย)","spd15",0) mOpt(subF,"🏃💨 วิ่งไว 2x (=pass จริง)","spd2",30)
    subs[subF]=true
    table.insert(flow,8,rowF); table.insert(flow,9,subF)   -- หลัง subD (idx7) ก่อน rowC
    chev(rowF,subF); layout()
end

-- ============ แถว 🤖 บอทฟาร์ม (do-block กัน register) — ยืนขุดวง/เก็บ/ขายเอง ============
do
    local rowB=Instance.new("Frame"); rowB.Size=UDim2.new(1,0,0,32); rowB.BackgroundColor3=C.row; rowB.Parent=body; corner(rowB,9); stroke(rowB,C.edge,0.8)
    local bl=Instance.new("TextLabel"); bl.Size=UDim2.new(1,-120,1,0); bl.Position=UDim2.new(0,10,0,0); bl.BackgroundTransparency=1; bl.Text="บอทฟาร์ม เบต้า (ยืนขุดวง/เก็บ/ขายเอง)"; bl.TextSize=13; bl.TextColor3=C.txt; bl.TextXAlignment=Enum.TextXAlignment.Left; bl.Parent=rowB; tfont(bl)
    local pillB=Instance.new("Frame"); pillB.Size=UDim2.new(0,40,0,18); pillB.Position=UDim2.new(1,-48,0.5,-9); pillB.BackgroundColor3=C.off; pillB.Parent=rowB; corner(pillB,9)
    local knobB=Instance.new("Frame"); knobB.Size=UDim2.new(0,14,0,14); knobB.Position=UDim2.new(0,2,0.5,-7); knobB.BackgroundColor3=Color3.new(1,1,1); knobB.Parent=pillB; corner(knobB,7)
    local hitB=Instance.new("TextButton"); hitB.Size=UDim2.new(1,0,1,0); hitB.BackgroundTransparency=1; hitB.Text=""; hitB.Parent=rowB
    chip(rowB,"🤖",C.accent3) shiftLbl(bl) polishPill(pillB,knobB) hover(hitB,rowB,C.row,C.rowH)
    hitB.Activated:Connect(function()
        cfg.farmBot=not cfg.farmBot; sfx("pop")
        Tween:Create(pillB,TweenInfo.new(0.15),{BackgroundColor3=cfg.farmBot and C.on or C.off}):Play()
        Tween:Create(knobB,TweenInfo.new(0.15),{Position=cfg.farmBot and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        -- บอทเปิด = เปิดลูปขุด/เก็บ/ขายให้เอง (pill เดิมไม่ต้องกด)
        slog("farmBot "..tostring(cfg.farmBot))
    end)
    table.insert(flow,10,rowB)   -- หลัง subF (idx9) ก่อน rowC
    local subB=subFrame(4)
    mOpt(subB,"🎯 เล็งเป้าคุ้มสุด (Value/ระยะ)","botBest",0)
    mOpt(subB,"🌡 กันตายหนาว (ไม่ขึ้นเกิน Warmth)","botWarm",30)
    mOpt(subB,"🧪 กินยา Mining/Luck/Coins ทุก 60s","botPot",60)
    -- ปุ่มโฟกัส tier: ฟาร์มเฉพาะแรร์ ≥ ระดับที่เลือก (กดวน)
    local btB=Instance.new("TextButton"); btB.Size=UDim2.new(1,-16,0,26); btB.Position=UDim2.new(0,8,0,93)
    btB.BackgroundColor3=C.opt2; btB.TextSize=11; btB.Parent=subB; corner(btB,6); tfont(btB); hover(btB,btB,C.opt2,C.optH)
    local function paintBT() local t=TIERS[cfg.botTier]; btB.Text="💎 โฟกัสแรร์ ≥ "..t; btB.TextColor3=TCOL[t] end
    btB.Activated:Connect(function() cfg.botTier=cfg.botTier%#TIERS+1 sfx("tick") paintBT() end)
    paintBT()
    subs[subB]=true; table.insert(flow,11,subB)
    chev(rowB,subB); layout()
end

-- ============ ภูเขา (MountainPool → รายการ + auto + เวลาหมุน) ============
local mtData={}   -- [{id,name,rarity,rank,released}] — rank = index ใน MP.Data (ยิ่งท้ายยิ่งดี)
local mtBtns={}
local function mtCur()
    local v=MtState and MtState.Value
    if (not v or v=="") and MP and MP.currentMountain then local ok,c=pcall(MP.currentMountain) if ok and c then v=c.id end end
    return v
end
local function mtColor(r) return (MP and MP.RarityColors and MP.RarityColors[r]) or TCOL[r] or C.dim end
local function mtRotTxt()
    -- เกมใช้ GetServerTimeNow (server clock) ไม่ใช่ os.time — 34_MountainClient.lua:55
    local v=MtRot and tonumber(MtRot.Value)
    if v and v>0 then
        local okT,now=pcall(function() return workspace:GetServerTimeNow() end)
        local l=v-(okT and now or os.time())
        if l>=0 and l<=7200 then return string.format("%d:%02d",math.floor(l/60),l%60) end
    end
    -- fallback เดียวกับเกม: MP.secondsUntilNext() เมื่อ RotationEnd ว่าง/หมด
    if MP and MP.secondsUntilNext then
        local okS,s=pcall(MP.secondsUntilNext)
        if okS and type(s)=="number" and s>0 and s<=7200 then return string.format("%d:%02d",math.floor(s/60),s%60) end
    end
    return "—"
end
local function refreshMtn()
    local cur=mtCur()
    rowMtnL.Text="ภูเขา: "..tostring(cur or "—")
    for id,x in pairs(mtBtns) do x.tag.Visible=(id==cur) end
    mtnSw.Text=string.format("สวิตช์: %d · หมุนใน: %s",tonumber(LP:GetAttribute("MountainSwitches")) or 0,mtRotTxt())
end
local function buildMtn()
    for _,c in ipairs(mtList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    mtBtns={}
    table.sort(mtData,function(a,b) return a.rank>b.rank end) -- ดีสุดขึ้นก่อน
    for i,e in ipairs(mtData) do
        if e.released then
            local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-6,0,26); b.BackgroundColor3=C.opt
            b.Text=""; b.Parent=mtList; b.LayoutOrder=i; corner(b,6)
            local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-34,1,0); l.Position=UDim2.new(0,8,0,0); l.BackgroundTransparency=1
            l.Text=e.name.." · "..e.rarity; l.TextSize=11; l.TextColor3=mtColor(e.rarity); l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=b; tfont(l)
            local tag=Instance.new("TextLabel"); tag.Size=UDim2.new(0,26,1,0); tag.Position=UDim2.new(1,-30,0,0); tag.BackgroundTransparency=1
            tag.Text="✓"; tag.TextSize=13; tag.TextColor3=C.on; tag.Visible=false; tag.Parent=b; tfont(tag)
            b.Activated:Connect(function()
                if not MtChoose then feedAdd("❌ ไม่มี Choose remote",Color3.fromRGB(255,120,120)) return end
                if e.id==mtCur() then feedAdd("🏔️ อยู่ "..e.name.." อยู่แล้ว",C.dim) return end
                MtChoose:FireServer(e.id); sfx("pop")
                feedAdd("🏔️ เลือก "..e.name.." ("..e.rarity..")",mtColor(e.rarity))
                slog("mtn choose "..e.id)
                task.delay(1,refreshMtn)
            end)
            mtBtns[e.id]={b=b,tag=tag}
        end
    end
end
local function mtnAutoBest()
    if not cfg.sub.mtnAuto then return end
    if (tonumber(LP:GetAttribute("MountainSwitches")) or 0)<=0 then return end
    local cur=mtCur(); local best=nil
    for _,e in ipairs(mtData) do if e.released and (not best or e.rank>best.rank) then best=e end end
    if best and best.id~=cur and MtChoose then
        MtChoose:FireServer(best.id)
        feedAdd("🏔️ auto → "..best.name,mtColor(best.rarity)); slog("mtn auto "..best.id)
    end
end
task.spawn(function()
    -- รอ MountainPool พร้อม (task ด้านบนกำลัง require) → fallback: เก็บจาก MountainsGui ของเกมเอง
    local t0=os.clock()
    while not MP and os.clock()-t0<30 do task.wait(0.5) if not alive() then return end end
    if MP and MP.Data then
        for i,v in ipairs(MP.Data) do
            local rel=true
            if MP.isReleased then local okR,r=pcall(MP.isReleased,v) rel=okR and r~=false or true end
            mtData[#mtData+1]={id=v.id,name=v.name or v.id,rarity=v.rarity or "?",rank=i,released=rel}
        end
    end
    if #mtData==0 then
        local ok,grid=pcall(function() return LP.PlayerGui:WaitForChild("MountainsGui",10):WaitForChild("Window",10):WaitForChild("Grid",10) end)
        if ok and grid then
            for _,s in ipairs(grid:GetChildren()) do
                local id=s:GetAttribute("MountainId")
                if id then
                    local nl=s:FindFirstChild("NameLabel"); local rl=s:FindFirstChild("RarityLabel")
                    mtData[#mtData+1]={id=id,name=nl and nl.Text or id,rarity=rl and rl.Text or "?",rank=#mtData+1,released=true}
                end
            end
        end
    end
    buildMtn(); refreshMtn()
    slog("mountains "..#mtData)
end)
task.spawn(function()
    while not MtState do task.wait(0.5) if not alive() then return end end
    MtState.Changed:Connect(function()
        -- ภูเขาเปลี่ยน = แรร์ทั้งเซิร์ฟเวอร์รีใหม่ → ล้าง registry ทั้งหมด ไม่เก็บของเก่า
        wiping=true; wipeEnd=os.clock()+10
        doWipe("ภูเขาเปลี่ยน → "..tostring(MtState.Value))
        refreshMtn(); task.delay(2,mtnAutoBest)
    end)
    if MtRot then MtRot.Changed:Connect(function() task.delay(3,function() refreshMtn() mtnAutoBest() end) end) end
    task.delay(4,function() if alive() then refreshMtn() end end)
end)

-- ============ ขายเลือกชิ้น (CrystalBag → Equip(BagId) → RequestSell("Held") → กลับพลั่ว) ============
do
local SL={busy=false}
function SL.bag()
    local t={}
    local cb=LP:FindFirstChild("CrystalBag")
    if cb then for _,d in ipairs(cb:GetChildren()) do if d:GetAttribute("BagId") then t[#t+1]=d end end end
    table.sort(t,function(a,b) return (a:GetAttribute("Value") or 0)>(b:GetAttribute("Value") or 0) end)
    return t
end
function SL.reequip()
    local ch=LP.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    local bp=LP:FindFirstChildOfClass("Backpack")
    if hum and bp then
        for _,t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("Cooldown") and not t:GetAttribute("BagId") then hum:EquipTool(t) break end
        end
    end
end
function SL.heldId()  -- tool ในมือมี BagId ไหน (equip จริงแล้วไหม)
    local ch=LP.Character
    if not ch then return nil end
    for _,t in ipairs(ch:GetChildren()) do
        if t:IsA("Tool") then return t:GetAttribute("BagId") end
    end
    return nil
end
-- ขาย 1 ชิ้น: ถือ → รอถือจริง → ขาย Held → (reEquip=true) กลับพลั่วตอนจบ
function SL.sellOne(item,reEquip,done)
    if not (CBEquip and SellReq) then feedAdd("❌ ไม่มี sell remote",Color3.fromRGB(255,120,120)) if done then done() end return end
    local id=item:GetAttribute("BagId")
    if not id then if done then done() end return end
    SL.busy=true
    CBEquip:FireServer(id)                              -- ถือชิ้นนั้น (server equip — HotbarClient:658)
    task.spawn(function()
        -- รอ tool โผล่ในมือจริง (server equip มี latency — เดิม delay ตายตัวทำขายพลาด)
        local t0=os.clock(); local ok=false
        while alive() and os.clock()-t0<3 do
            if SL.heldId()==id then ok=true break end
            task.wait(0.1)
        end
        if ok then SellReq:FireServer("Held")
        else feedAdd("💰 ถือไม่ทัน — ข้าม",Color3.fromRGB(255,160,80)) slog("held timeout "..tostring(id)) end
        task.wait(0.5)
        if reEquip then SL.reequip() end
        SL.busy=false
        if done then done() end
    end)
end
-- ขายทุกชิ้นในกระเป๋า (ข้าม favorited) — ถือ→ขาย ต่อเนื่องทีละชิ้น จบแล้วค่อยกลับพลั่วครั้งเดียว
function SL.each()
    if SL.busy then return end
    local queue={}
    for _,d in ipairs(SL.bag()) do if not d:GetAttribute("Favorited") then queue[#queue+1]=d end end
    if #queue==0 then feedAdd("💰 ไม่มีของขาย",Color3.fromRGB(255,160,80)) return end
    feedAdd(string.format("💰 ขายทีละชิ้น %d ชิ้น…",#queue),Color3.fromRGB(255,220,120))
    local i=0
    local function step()
        i+=1
        if i>#queue or not alive() then
            SL.reequip(); feedAdd("💰 ขายทีละชิ้นจบ",Color3.fromRGB(120,255,160)); return
        end
        SL.sellOne(queue[i],false,step)
    end
    step()
end
function SL.refresh()
    for _,c in ipairs(bagList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for i,d in ipairs(SL.bag()) do
        local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-4,0,22); b.LayoutOrder=i
        b.BackgroundColor3=C.opt; b.Text=""; b.Parent=bagList; corner(b,5)
        local r=d:GetAttribute("Rarity") or "Common"
        local nm=(d:GetAttribute("GemName") or "?"):gsub("(%l)(%u)","%1 %2")
        local fav=d:GetAttribute("Favorited") and " ⭐" or ""
        local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-46,1,0); l.Position=UDim2.new(0,6,0,0); l.BackgroundTransparency=1
        l.Text=string.format("%s%s · %.1fkg · $%s",nm..fav,r=="Common" and "" or "·"..r,d:GetAttribute("Kg") or 0,comma(d:GetAttribute("Value") or 0))
        l.TextSize=10; l.TextColor3=TCOL[r] or C.txt; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=b; tfont(l)
        local s=Instance.new("TextLabel"); s.Size=UDim2.new(0,40,1,0); s.Position=UDim2.new(1,-42,0,0); s.BackgroundTransparency=1
        s.Text="ขาย"; s.TextSize=10; s.TextColor3=Color3.fromRGB(120,255,160); s.Parent=b; tfont(s)
        b.Activated:Connect(function() SL.sellOne(d,true) end)
    end
end
sellAllB.Activated:Connect(function()
    if SellReq then SellReq:FireServer("All"); sfx("pop"); feedAdd("💰 ยิงขายทั้งหมด (ตรงนี้)",Color3.fromRGB(255,220,120)) end
end)
local sellEachB=Instance.new("TextButton"); sellEachB.Size=UDim2.new(0.5,-20,0,24); sellEachB.Position=UDim2.new(0.5,12,0,33)
sellEachB.BackgroundColor3=Color3.fromRGB(90,72,40); sellEachB.Text="📦 ขายทีละชิ้น (ข้าม⭐)"; sellEachB.TextColor3=C.txt
sellEachB.TextSize=10; sellEachB.Parent=subS; corner(sellEachB,6); tfont(sellEachB)
sellEachB.Activated:Connect(function() task.spawn(SL.each) end)
sellAllB.Size=UDim2.new(0.5,-20,0,24); sellAllB.Text="💰 ขายหมด (ตรงนี้)"
task.spawn(function() while alive() do
    if subS.Visible then pcall(SL.refresh) end
    task.wait(2)
end end)
-- SellResult → feed (count, money, itemName, err) — 16_SellerMenuClient:811
task.spawn(function()
    while not SellRes do task.wait(0.5) if not alive() then return end end
    SellRes.OnClientEvent:Connect(function(cnt,money,item,err)
        if not alive() then return end
        if err then feedAdd("💰 ขายไม่ได้: "..tostring(err),Color3.fromRGB(255,120,120))
        elseif item then feedAdd(string.format("💰 ขาย %s = $%s",item,comma(money or 0)),Color3.fromRGB(120,255,160))
        elseif (cnt or 0)>0 then feedAdd(string.format("💰 ขาย %d ชิ้น = $%s",cnt,comma(money or 0)),Color3.fromRGB(120,255,160)) end
    end)
    slog("sellres-hook")
end)
end

-- ============ render loop (อัปเดตข้อความทุก 0.25 วิ — ไม่ format ทุกเฟรม) ============
local lblAcc=0
local bagQuote=nil  -- มูลค่ากระเป๋าจาก QuoteSellAll (poller ด้านล่าง)
RunS.RenderStepped:Connect(function(dt)
    if not alive() then return end
    local cam=workspace.CurrentCamera; if not cam then return end
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local now=os.clock()
    if wiping and now>wipeEnd then wiping=false end
    lblAcc=lblAcc+(dt or 0)
    local updL=lblAcc>=0.25; if updL then lblAcc=0 end
    -- models: toggle + ระยะ (เฉพาะตัวที่เปิดอยู่)
    for m,e in pairs(tracked) do
        if not m.Parent then
            pcall(function() e.hl:Destroy() e.bb:Destroy() end); tracked[m]=nil
            -- mass-despawn detector: model หลุด >40 ตัวใน 1.5 วิ = server รีแรร์ (ภูเขาหมุน/รีเซ็ต)
            if now-wipeT0>1.5 then wipeN=0 end
            wipeT0=now; wipeN+=1
            if wipeN>40 and not wiping then
                wiping=true; wipeEnd=now+5
                doWipe("server รีแรร์ (despawn "..wipeN.."+)")
            end
            -- หายหลัง GemCollected ของชื่อนี้ <3 วิ = ถูกเก็บจริง → ลบทิ้ง ไม่ทำ ghost
            if wiping or (lastCollect[e.id] and now-lastCollect[e.id]<3) then
                known[m]=nil knownPos[m]=nil
            -- พื้นที่ unstream → แปลงเป็น ghost ค้างพิกัดเดิม เห็นต่อทั้งแมพ
            elseif e.lastPos and wantShow(e.rarity,e.id) then
                local dup=false
                for _,pe in ipairs(pings) do if (pe.pos-e.lastPos).Magnitude<10 then dup=true pe.t=os.clock() break end end
                if not dup then
                    local cl,hl,bb2,tx=mkGhost(e.lastPos,e.rarity,e.kg)
                    if cl then pings[#pings+1]={pos=e.lastPos,rarity=e.rarity,kg=e.kg,t=os.clock(),ghost=cl,hl=hl,bb=bb2,txt=tx,sticky=true,name=e.name} end
                end
            end
        else
            local on=wantShow(e.rarity,e.id)
            local hOn=on and cfg.sub.espHl; local bOn=on and cfg.sub.espName
            if e.hl.Enabled~=hOn then e.hl.Enabled=hOn end
            if e.bb.Enabled~=bOn then e.bb.Enabled=bOn end
            if on and updL and hrp then
                local ok,p=pcall(function() return m:GetPivot().Position end)
                if ok and p then
                    e.lastPos=p
                    local hpt=""
                    if cfg.sub.hpBar then
                        local hp=m:GetAttribute("Hp"); local mh=m:GetAttribute("MaxHp")
                        if hp and mh and mh>0 and hp<mh then hpt=string.format(" · ❤%d/%d",hp,mh) end
                    end
                    -- mutation เปลี่ยนได้ระหว่างทาง (weather mutate) + สถานะฝัง/ปลดเปลี่ยนได้ → refresh สด
                    local mut=m:GetAttribute("Mutations"); if mut=="" then mut=nil end
                    local fr=m:GetAttribute("Freed") and true or false
                    if mut~=e.mut or fr~=e.fr then
                        e.mut=mut e.fr=fr
                        e.t1.Text="◆ "..e.name..(mut and (" ✦"..mut) or "")..(fr and "" or " ⛏ฝังอยู่")
                    end
                    e.t2.Text=string.format("%s%s · %.1fkg · %dm%s",e.rarity,e.sz and (" ["..e.sz.."]") or "",e.kg,(p-hrp.Position).Magnitude,hpt)
                end
            end
        end
    end
    -- pings: ghost model ในโลก — อัปเดตเฉพาะตอนสถานะเปลี่ยน (sticky = ไม่มีวันหมดอายุ)
    for i=#pings,1,-1 do
        local e=pings[i]
        if (not e.sticky and now-e.t>cfg.ttl) or not e.ghost or not e.ghost.Parent then
            pcall(function() e.ghost:Destroy() e.hl:Destroy() e.bb:Destroy() end); table.remove(pings,i)
        else
            local ti=tIdx(e.rarity)
            local on=(not cfg.pickMode) and cfg.esp and (ti==cfg.minTier or ti==0)
            local vis=on and cfg.sub.ghost
            if e.shown~=vis then
                e.shown=vis; e.hl.Enabled=vis
                for _,d in ipairs(e.ghost:GetDescendants()) do if d:IsA("BasePart") then d.LocalTransparencyModifier = vis and 0.45 or 1 end end
            end
            e.bb.Enabled = on and cfg.sub.ghostLbl
            if on and updL and hrp then
                e.txt.Text=string.format("◆ %s%s · %.1fkg · %dm",e.name and (e.name.." ") or "",e.rarity,e.kg,(e.pos-hrp.Position).Magnitude)
            end
        end
    end
    -- ผู้เล่น: adornee + ระยะ + แท็กขุด
    for p,e in pairs(ptracked) do
        local ch=p.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        local on=cfg.players and hrp~=nil
        if e.hl.Adornee~=ch then e.hl.Adornee=ch; e.bb.Adornee=ch end
        e.hl.Enabled=on and cfg.sub.pHl; e.bb.Enabled=on and cfg.sub.pName
        if on and hrp and updL then
            local d=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local dist=d and (hrp.Position-d.Position).Magnitude or 0
            local dig=cfg.sub.pDig and os.clock()<e.digUntil
            e.t2.Text=string.format("@%s · %dm%s",p.Name,dist,dig and " · ⛏กำลังขุด" or "")
        end
    end
    -- marks (เมเทียร์/ดาวตก): อัปเดตระยะ + หมดอายุ
    for i=#marks,1,-1 do
        local e=marks[i]
        if not e.part.Parent or now>e.exp then
            pcall(function() e.part:Destroy() e.bb:Destroy() end); table.remove(marks,i)
        elseif updL and hrp then
            e.txt.Text=string.format("%s · %dm",e.base,(e.pos-hrp.Position).Magnitude)
        end
    end
    -- runes: adornee + ระยะ + merged
    for m,e in pairs(rtrack) do
        if not m.Parent then
            pcall(function() e.hl:Destroy() e.bb:Destroy() end); rtrack[m]=nil
        else
            e.hl.Enabled=cfg.runes and cfg.sub.runeHl
            e.bb.Enabled=cfg.runes and cfg.sub.runeLbl
            if updL and hrp then
                local ok,p=pcall(function() return m:GetPivot().Position end)
                if ok and p then
                    local mg=m:GetAttribute("Merged") or 1
                    local own=m:GetAttribute("OwnerId")==LP.UserId and " · ของเรา" or ""
                    e.t2.Text=string.format("x%d%s · %dm",mg,own,(p-hrp.Position).Magnitude)
                end
            end
        end
    end
    -- HUD สถานะตัวเรา + เตือนหนาว (สูตรจริงจาก FreezeClient)
    if updL then
        local ls=LP:FindFirstChild("leaderstats")
        local coinV=ls and ls:FindFirstChild("Coins")
        local coins=coinV and coinV.Value or 0
        local bag=LP:GetAttribute("BagKg") or 0
        local cap=LP:GetAttribute("CarryWeight") or 0
        local warm=LP:GetAttribute("Warmth") or 120
        local pt2=LP:GetAttribute("EquippedPickaxe")
        local pick=pickByTier[tonumber(pt2) or -1] or ("T"..tostring(pt2 or "?"))
        local cold=""
        if AltY and AltS and hrp then
            local w=(warm+(LP:GetAttribute("AbuseWarmthBonus") or 0))*(LP:GetAttribute("RuneWarmthMult") or 1)*2.5
            if w<=(hrp.Position.Y-AltY.Value)*AltS.Value then cold="  🥶หนาว!" end
        end
        local qt=bagQuote and (" ≈$"..comma(bagQuote)) or ""
        local wth=WState and WState.Value; local wtxt=(wth and wth~="" and wth~="NormalWeather") and ("  🌦"..wth) or ""
        local ds=LP:GetAttribute("DryStreak"); local dst=(ds and ds>0) and ("  🎲x"..tostring(ds)) or ""
        hud.Text=string.format("💰 $%s   🎒 %.1f/%dkg%s\n⛏ %s  🌡 %s%s%s%s",comma(coins),bag,cap,qt,pick,tostring(warm),cold,wtxt,dst)
        hud.TextColor3=cold~="" and Color3.fromRGB(120,190,255) or C.txt
    end
    -- นับรวม known (ทุกตัวที่รู้จัก) + ping แยกระดับ
    if updL then
        local count={}
        for m,r in pairs(known) do
            -- จำไว้ถาวร — unstream ≠ ถูกขุดไป, ยังนับเป็นของแมพ
            if m then count[r]=(count[r] or 0)+1 end
        end
        for _,e in ipairs(pings) do count[e.rarity]=(count[e.rarity] or 0)+1 end
        local oc=0
        for r in pairs(count) do if not tierLbl[r] then oc+=count[r] end end
        otherLbl.Text="?: "..oc
        for _,t in ipairs(TIERS) do tierLbl[t].Text=t..": "..(count[t] or 0) end
    end
end)

task.spawn(function()
    while not Freed do task.wait(0.3) if not alive() then return end end
    Freed.OnClientEvent:Connect(function(...) if alive() then addPing(...) end end)
    slog("hooked")
end)
task.spawn(function()
    while not DigEff do task.wait(0.3) if not alive() then return end end
    DigEff.OnClientEvent:Connect(function(...)
        if not alive() then return end
        local a={...}
        local pos
        for _,v in ipairs(a) do if typeof(v)=="Vector3" then pos=v break end end
        if not pos then pos=Vector3.new(tonumber(a[1]) or 0,tonumber(a[2]) or 0,tonumber(a[3]) or 0) end
        -- หา player ที่ใกล้จุดขุดสุด → tag กำลังขุด
        local best,bd=nil,12
        for p in pairs(ptracked) do
            local ch=p.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp then local d=(hrp.Position-pos).Magnitude if d<bd then bd=d best=p end end
        end
        if best then ptracked[best].digUntil=os.clock()+2.5 end
    end)
end)

-- ============ ติดตามการเก็บ (GemCollected) — ลบตัวที่โดนเก็บออกจากแผนที่ ============
task.spawn(function()
    while not Collected do task.wait(0.3) if not alive() then return end end
    Collected.OnClientEvent:Connect(function(...)
        if not alive() then return end
        local a={...}
        for _,v in ipairs(a) do
            if typeof(v)=="string" and not Players:FindFirstChild(v) then
                lastCollect[v]=os.clock()
                -- ถ้ามีตัวชื่อนี้ที่ unstream แล้ว (แต่ยังนับอยู่) → ถือว่าตัวนั้นโดนเก็บ ลบออก
                for m in pairs(known) do
                    if (m:GetAttribute("GemName") or m.Name)==v and m.Parent==nil then known[m]=nil knownPos[m]=nil break end
                end
                break
            end
        end
    end)
    slog("collected-hook")
end)

-- ============ ขุดออโต้ (สูตรเดียวกับ DigButtonClient) ============
local RayParams=RaycastParams.new(); RayParams.FilterType=Enum.RaycastFilterType.Include; RayParams.FilterDescendantsInstances={workspace.Terrain}
local function heldPickaxe(ch)
    -- พลั่วจริง = Tool ที่มี attr Cooldown (เช่น "Rusted Scrapper" Tier=1 Cooldown=0.4) — ตัดคริสตัล(BagId)/รูน(RuneId)
    for _,t in ipairs(ch:GetChildren()) do
        if t:IsA("Tool") and t:GetAttribute("Cooldown") and not t:GetAttribute("BagId") and not t:GetAttribute("RuneId") then
            return t
        end
    end
    return nil
end
local lastDig=0
task.spawn(function() while alive() do
    if (cfg.autodig or cfg.farmBot) and DigReq then
        pcall(function()
            if LP:GetAttribute("IsMiningGem") then return end
            local ch=LP.Character; if not ch then return end
            local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local tool=heldPickaxe(ch); if not tool then return end
            local cd=(tool:GetAttribute("Cooldown") or 0.4)
            if LP:GetAttribute("Pass_FastDig2x")==true or os.time()<(LP:GetAttribute("MiningPotionUntil") or 0) then cd=cd*0.5 end
            cd=cd/math.max(LP:GetAttribute("RuneHaste") or 1,1)
            local now=os.clock()
            -- turbo = ข้าม client cooldown ~3x (0.12s+jitter) — server อาจมี rate-limit; ถ้า feed มี error/โดนเตะ ให้ปิด
            if now-lastDig<(cfg.sub.turboDig and (0.12+math.random()*0.04) or cd) then return end
            lastDig=now
            local head=ch:FindFirstChild("Head"); local pos=head and head.Position or hrp.Position+Vector3.new(0,1.5,0)
            local lv=hrp.CFrame.LookVector; local flat=Vector3.new(lv.X,0,lv.Z)
            local unit=flat.Magnitude>0.001 and flat.Unit or Vector3.new(0,0,-1)
            local cam=workspace.CurrentCamera; local pitch=0
            if cam then local cl=cam.CFrame.LookVector; local h=math.sqrt(cl.X*cl.X+cl.Z*cl.Z); pitch=h>0.001 and math.clamp(cl.Y/h,-1.4,1) or 0 end
            local dir=(unit+Vector3.new(0,pitch,0)).Unit
            -- SMART: เล็งแรร์ฝังจาก cache (refresh ทุก 2 วิ — deep scan ทั้ง SpawnedGems)
            local target=nil
            local sgm=cfg.sub.smartDig and workspace:FindFirstChild("SpawnedGems")
            if sgm then
                if now-buriedT>2 then
                    buriedT=now; for i=#buriedCache,1,-1 do buriedCache[i]=nil end
                    for _,m in ipairs(sgm:GetDescendants()) do
                        if m:IsA("Model") and m:GetAttribute("BuriedAt") and not m:GetAttribute("Freed")
                            and rIdx(m:GetAttribute("Rarity"))>=cfg.botTier then   -- โฟกัส: ขุดเฉพาะ ≥tier ที่เลือก
                            local ow=m:GetAttribute("Owner")
                            if not ow or ow==LP.UserId then
                            local mp=m:GetAttribute("BuriedAt")
                            if typeof(mp)~="Vector3" then local ok2,p2=pcall(function() return m:GetPivot().Position end) mp=ok2 and p2 or nil end
                            if mp then buriedCache[#buriedCache+1]=mp end
                            end
                        end
                    end
                end
                local bd=42
                for _,mp in ipairs(buriedCache) do
                    local d=(mp-pos).Magnitude
                    if d<bd then bd=d target=mp end
                end
            end
            if target then
                DigReq:FireServer(target)
            elseif cfg.farmBot then
                -- 🤖 บอท: ขุดเป็นวงกลมรอบตัว — หมุนมุม 45°/hit วน 3 รัศมี (4→8→12) = ขุดรอบทิศไม่ใช่แค่ข้างหน้า
                cfg._digA=(cfg._digA or 0)+0.7854
                if cfg._digA>=6.283 then cfg._digA=0 cfg._digR=((cfg._digR or 0)+1)%3 end
                local r=4+((cfg._digR or 0)*4)
                local px=hrp.Position+Vector3.new(math.cos(cfg._digA)*r,0,math.sin(cfg._digA)*r)
                local hitT=workspace:Raycast(px+Vector3.new(0,4,0),Vector3.new(0,-10,0),RayParams)
                if hitT then DigReq:FireServer(hitT.Position) else DigReq:FireServer(px,true) end
            else
                local hitT=workspace:Raycast(pos,dir*48,RayParams)
                if not hitT then hitT=workspace:Raycast(pos,(unit+Vector3.new(0,-0.35,0)).Unit*48,RayParams) end
                if hitT then DigReq:FireServer(hitT.Position) else DigReq:FireServer(pos+dir*48,true) end
            end
        end)
    end
    task.wait(0.05)
end end)

-- ============ เก็บออโต้ (Pickup prompt) ============
task.spawn(function() while alive() do
    if (cfg.autocollect or cfg.farmBot) and fireproximityprompt then
        pcall(function()
            local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            for m in pairs(promptSet) do
                if not m.Parent then promptSet[m]=nil
                elseif m.Enabled then
                    local mm=m:FindFirstAncestorOfClass("Model")
                    local pp=m.Parent
                    local pp2=pp and (pp:IsA("BasePart") and pp.Position or pp:IsA("Attachment") and pp.WorldPosition or pp:IsA("Model") and pp:GetPivot().Position)
                    local inRange=(not cfg.sub.colRange) or (hrp and pp2 and (hrp.Position-pp2).Magnitude<=(m.MaxActivationDistance*1.5))
                    if mm and (mm:GetAttribute("Freed") or mm:GetAttribute("Dropped")) and inRange
                        and rIdx(mm:GetAttribute("Rarity"))>=cfg.botTier then   -- โฟกัส: เก็บเฉพาะ ≥tier ที่เลือก
                        fireproximityprompt(m)
                    end
                end
            end
        end)
    end
    task.wait(0.35)
end end)

-- ============ loot/discovery feed (NotifyRemotes.Push) ============
task.spawn(function()
    while not Push do task.wait(0.3) if not alive() then return end end
    Push.OnClientEvent:Connect(function(p)
        if not alive() or not feedAdd or type(p)~="table" then return end
        if p.kind=="pickup" then
            feedAdd(string.format("📥 +%s (%s) %.1fkg $%s",p.name or "?",p.rarity or "?",p.kg or 0,tostring(p.value or 0)),TCOL[p.rarity])
        elseif p.kind=="discovery" then
            feedAdd(string.format("🆕 ค้นพบ %s (%s)",p.name or "?",p.rarity or "?"),TCOL[p.rarity])
        elseif p.kind=="afford" then
            feedAdd("💵 ซื้อได้แล้ว: "..tostring(p.name or "?"),Color3.fromRGB(74,226,54))
        end
    end)
    slog("push-hook")
end)

-- ============ global feed → log only (แจ้งใน feed = สแปม เอาออกแล้ว) ============
task.spawn(function()
    while not GFeed do task.wait(0.3) if not alive() then return end end
    GFeed.OnClientEvent:Connect(function(p)
        if not alive() or type(p)~="table" then return end
        if rIdx(p.rarity)>=7 then slog(string.format("GLOBAL %s %s %.1fkg",tostring(p.rarity),tostring(p.name),tonumber(p.kg) or 0)) end
    end)
    slog("gfeed-hook")
end)

-- ============ dig feedback (server บอกเหตุที่ขุดพลาด) ============
task.spawn(function()
    while not DigRes do task.wait(0.3) if not alive() then return end end
    local lastW=0
    DigRes.OnClientEvent:Connect(function(ok,err)
        if not alive() or ok or not feedAdd then return end
        local now=os.clock(); if now-lastW<1.5 then return end; lastW=now
        feedAdd("⛏ "..tostring(err or "ขุดไม่ได้"),Color3.fromRGB(255,120,120))
    end)
end)

-- ============ ขายออโต้ (BagFull → TeleportSell → RequestSell("All") → กลับจุดเดิม) ============
local selling=false
task.spawn(function() while alive() do
    if (cfg.autosell or cfg.farmBot) and not selling and LP:GetAttribute("BagFull")==true then
        local ok=pcall(function()
            -- ขายระยะไกล: ยิง RequestSell ตรงๆ ไม่วาป (ถ้า server ไม่เช็คระยะ = ขายได้ทุกที่; fail → SellResult feed บอก)
            if cfg.sub.remoteSell and SellReq then
                selling=true
                SellReq:FireServer("All")
                task.delay(4,function() selling=false end)
                return
            end
            local ch=LP.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
            if not hrp or not TSell or not SellReq then return end
            selling=true
            local back=hrp.CFrame
            feedAdd("💰 กระเป๋าเต็ม → ไปขาย",Color3.fromRGB(255,220,120))
            TSell:FireServer()
            task.wait(1.4)
            SellReq:FireServer("All")
            task.wait(1.0)
            -- กลับจุดเดิม (client-side pivot — ไม่ผ่าน remote)
            local ch2=LP.Character
            if ch2 then pcall(function() ch2:PivotTo(back) end) end
            feedAdd("💰 ขายเสร็จ กลับจุดเดิม",Color3.fromRGB(120,255,160))
            selling=false
        end)
        if not ok then selling=false end   -- พังกลางทางเท่านั้นที่รีเซ็ต — debounce ข้างในทำงานจริง
    end
    task.wait(0.6)
end end)

-- ============ เมเทียร์ (MeteorRemotes.Event — phase: incoming/falling/impact/zone/end) ============
task.spawn(function()
    while not MetEv do task.wait(0.5) if not alive() then return end end
    local ORANGE=Color3.fromRGB(255,140,30)
    MetEv.OnClientEvent:Connect(function(p)
        if not alive() or type(p)~="table" or not cfg.met then return end
        if p.phase=="incoming" then
            if cfg.sub.metFeed then feedAdd("☄️ เมเทียร์กำลังตก!",ORANGE) end
        elseif p.phase=="falling" then
            clearMarks("เมเทียร์")
            if cfg.sub.metMark and typeof(p.target)=="Vector3" then mkMark(p.target,"☄️ เมเทียร์",ORANGE,240) end
        elseif p.phase=="impact" then
            clearMarks("เมเทียร์")
            local pp=typeof(p.pos)=="Vector3" and p.pos or (MetPos and MetPos.Value)
            if cfg.sub.metMark and typeof(pp)=="Vector3" then mkMark(pp,"☄️ เมเทียร์(ตกแล้ว)",ORANGE,120) end
            if cfg.sub.metFeed then feedAdd("💥 เมเทียร์ตกแล้ว!",ORANGE) end
        elseif p.phase=="end" then
            clearMarks("เมเทียร์")
        end
    end)
    -- เข้ากลางอีเวนต์: ยังอยู่ช่วง zone → ปักป้ายจาก ImpactPos.Value เลย
    if MetActive and MetActive.Value and MetPhase and MetPhase.Value=="zone" and MetPos then
        local v=MetPos.Value
        if typeof(v)=="Vector3" and cfg.sub.metMark then mkMark(v,"☄️ เมเทียร์",ORANGE,240) end
    end
    slog("meteor-hook")
end)

-- ============ ดาวตก (Starfall: startPos, endPos, duration → ปักจุดลง) ============
task.spawn(function()
    while not WStar do task.wait(0.5) if not alive() then return end end
    WStar.OnClientEvent:Connect(function(a,b)
        if not alive() or not cfg.met then return end
        if typeof(b)=="Vector3" and cfg.sub.metMark then
            mkMark(b,"⭐ ดาวตก",Color3.fromRGB(255,230,120),150)
        end
        if cfg.sub.metFeed then feedAdd("⭐ ดาวตก!",Color3.fromRGB(255,230,120)) end
    end)
    slog("star-hook")
end)

-- ============ สภาพอากาศ (WeatherRemotes.State → feed เมื่อเปลี่ยน) ============
task.spawn(function()
    while not WState do task.wait(0.5) if not alive() then return end end
    WState.Changed:Connect(function(v)
        if alive() and feedAdd and v~="NormalWeather" then
            feedAdd("🌦 สภาพ → "..tostring(v),Color3.fromRGB(150,200,255))
        end
    end)
    slog("weather-hook")
end)

-- ============ มูลค่ากระเป๋า (QuoteSellAll — invoke ทุก 8 วิ) ============
task.spawn(function() while alive() do
    if QuoteAll then
        local ok,v=pcall(function() return QuoteAll:InvokeServer() end)
        if ok then
            if not cfg._qLogged then   -- log โครงสร้างคำตอบครั้งเดียว (ไม่ spam ทุก 8s)
                cfg._qLogged=true
                if type(v)=="table" then local ks={} for k,x in pairs(v) do ks[#ks+1]=tostring(k).."="..tostring(x) end slog("quote table: "..table.concat(ks," | "))
                else slog("quote="..tostring(v)) end
            end
            bagQuote=tonumber(v) or (type(v)=="table" and (v.total or v.value or v.payout or v.worth or v.Total or v.TotalValue or v.coins or v.Coins)) or bagQuote
        end
    end
    task.wait(8)
end end)

-- ============ รูน: scan เริ่มต้น + เฝ้า PlotRunes ============
task.spawn(function()
    task.wait(3)
    scanRunes()
    task.spawn(function() while alive() do scanRunes() task.wait(6) end end)
    local pr=workspace:WaitForChild("PlotRunes",30)
    if pr then
        pr.DescendantAdded:Connect(function(d)
            if alive() and d:IsA("Model") then task.defer(function() if d.Parent then trackRune(d) end end) end
        end)
    end
end)

-- ============ auto-อัพเกรด (UpgradeState → ซื้อ "max" เมื่อเงินพอ) ============
task.spawn(function()
    while not UpState do task.wait(0.5) if not alive() then return end end
    UpState.OnClientEvent:Connect(function(p)
        if not alive() or type(p)~="table" then return end
        upState=p
        rowUpL.Text=string.format("อัพเกรดอัตโนมัติ (🔥%s 🎒%s)",tostring(p.warmth or "–"),tostring(p.carry or "–"))
    end)
    slog("upgrade-hook")
end)
local lastBuyT={carry=0,warmth=0}
task.spawn(function() while alive() do
    if cfg.autoup and BuyUp and upState then
        pcall(function()
            local ls=LP:FindFirstChild("leaderstats"); local cv=ls and ls:FindFirstChild("Coins")
            local coins=cv and cv.Value or 0
            local nw=os.clock()
            -- ราคาจริงจาก UpgradeClient: prices[i] = ราคาปุ่ม steps[i] (carry {1,50,10} / warmth {10,50,100})
            -- ปุ่มสุดท้าย = "max" ราคา maxCarryCost/maxWarmthCost (แพ็กใหญ่ ไม่ใช่ prices ตัวท้าย)
            -- นโยบาย: ซื้อแพ็กใหญ่สุดที่เงินพอ — max ก่อน ไม่พอค่อยไล่ step ลงมา
            local function tryBuy(kind)
                local steps=kind=="carry" and {1,50,10} or {10,50,100}
                local prices=kind=="carry" and upState.carryPrices or upState.warmthPrices
                local maxCost=kind=="carry" and upState.maxCarryCost or upState.maxWarmthCost
                if type(maxCost)=="number" and maxCost>0 and coins>=maxCost then
                    BuyUp:FireServer(kind,"max") return "max"
                end
                for i=#steps-1,1,-1 do
                    local p=prices and prices[i]
                    if type(p)=="number" and coins>=p then BuyUp:FireServer(kind,steps[i]) return "+"..steps[i] end
                end
                return nil
            end
            if cfg.sub.upCarry and nw-lastBuyT.carry>12 and type(upState.carry)=="number" then
                local bought=tryBuy("carry")
                if bought then lastBuyT.carry=nw
                    feedAdd("⬆️ อัพ Carry "..bought,Color3.fromRGB(120,255,160)); slog("buy carry "..bought.." @"..coins) end
            end
            if cfg.sub.upWarm and nw-lastBuyT.warmth>12 and type(upState.warmth)=="number" then
                local bought=tryBuy("warmth")
                if bought then lastBuyT.warmth=nw
                    feedAdd("⬆️ อัพ Warmth "..bought,Color3.fromRGB(255,180,120)); slog("buy warmth "..bought.." @"..coins) end
            end
        end)
    end
    task.wait(6)
end end)

-- ============ บอทฟาร์ม AFK: เดินไล่แรร์ (MoveTo ไม่วาป) + เลือกเป้าคุ้ม + กันหนาว + กันติด + ขายค้าง ============
task.spawn(function() while alive() do
    if cfg.farmBot then pcall(function()
        local ch=LP.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid"); local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp and hum.Health>0) then return end
        local rv=ch:FindFirstChild("variables"); if rv and rv:FindFirstChild("ragdoll") and rv.ragdoll.Value then return end -- ragdoll อยู่ อย่าสั่งเดิน
        -- มือว่าง (เช่น หลังขายชิ้นค้างอยู่) → หยิบพลั่วจาก Backpack เอง ไม่งั้น autodig นิ่ง
        if not heldPickaxe(ch) then
            local bp=LP:FindFirstChild("Backpack")
            if bp then for _,t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and t:GetAttribute("Cooldown") and not t:GetAttribute("BagId") and not t:GetAttribute("RuneId") then hum:EquipTool(t) break end
            end end
        end
        local my=hrp.Position; local now=os.clock()
        if ch~=cfg._ch then cfg._ch=ch cfg._trail={} cfg._fled=nil end   -- เกิดใหม่ = ลืมเส้นทางหนีหนาวเก่า
        -- เพดานความสูงปลอดภัย: สูตรจริงจาก 102_FreezeClient (Warmth*RuneWarmthMult*2.5 >= (Y-BaseY)*Scale)
        local maxY=1e9
        local okB,by=pcall(function() return RS.AltitudeBaseY.Value end)
        local okS,sc=pcall(function() return RS.AltitudeScale.Value end)
        if cfg.sub.botWarm and okB and okS and sc>0 then
            local w=((LP:GetAttribute("Warmth") or 120)+(LP:GetAttribute("AbuseWarmthBonus") or 0))*(LP:GetAttribute("RuneWarmthMult") or 1)
            maxY=by + w*2.5/sc - 8   -- เผื่อขอบ 8 studs ไม่ไปชนขอบหนาว
            -- 🥶 หนาวเกินแล้วตอนนี้ → ทิ้งทุกเป้า หนีลงจุดอุ่นที่จำไว้ทันที (damage ฝั่ง server หนีอย่างเดียว)
            if (my.Y-by)*sc > w*2.5 then
                cfg._trail=cfg._trail or {}
                local low=nil
                for _,p in ipairs(cfg._trail) do if not low or p.Y<low.Y then low=p end end
                if not low then
                    local sp=workspace:FindFirstChildOfClass("SpawnLocation")
                    low=(sp and sp.Position) or Vector3.new(0,by,0)
                end
                hum:MoveTo(low)
                if not cfg._fled then cfg._fled=true if feedAdd then feedAdd("🥶 หนาวเกิน! หนีลงจุดอุ่น",Color3.fromRGB(140,200,255)) end end
                return
            end
            cfg._fled=nil
        end
        -- ปลอดภัย → จำเส้นทางย้อนหลัง (trail) ไว้เป็นจุดหนีหนาว (ทุก 15 studs สูงสุด 30 จุด)
        if cfg.sub.botWarm then
            cfg._trail=cfg._trail or {}
            local lt=cfg._trail[#cfg._trail]
            if not lt or (lt-my).Magnitude>15 then
                cfg._trail[#cfg._trail+1]=my
                if #cfg._trail>30 then table.remove(cfg._trail,1) end
            end
        end
        -- โหมดนิ่ง: ไม่เดินไปไหน — ยืนขุดวงกลม+เก็บ≥tier+ขาย ตรงที่ยืน (ผู้เล่นเดินเอง)
        -- ขายค้างทุก 20s (remote ไม่วาป — เต็มแล้ว loop autosell จัดการเอง)
        if not selling and (LP:GetAttribute("BagKg") or 0)>0 and LP:GetAttribute("BagFull")~=true
            and now-(cfg._botSell or 0)>20 and SellReq then
            cfg._botSell=now; SellReq:FireServer("All")
        end
        -- กินยาบัฟทุก 60s (remote จริงจากปุ่ม USE — server เช็คว่ามียาในกระเป๋าเอง)
        if cfg.sub.botPot and now-(cfg._botPot or 0)>60 then
            cfg._botPot=now
            local up=RS:FindFirstChild("UsePotion")
            if up then for _,n in ipairs({"MiningPotion","LuckPotion","CoinsPotion"}) do up:FireServer(n) task.wait(0.3) end end
        end
    end) end
    task.wait(0.9)
end end)

-- ============ กันเหวแบบเร็ว: เช็คพื้นข้างหน้าทุก 0.15s (ลูปหลัก 0.9s ช้าเกินตอนวิ่งไว 2x = พุ่ง 29 studs/รอบ) ============
task.spawn(function() while alive() do
    if cfg.farmBot then pcall(function()
        local ch=LP.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid"); local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp) then return end
        local v=hrp.AssemblyLinearVelocity; local hv=Vector3.new(v.X,0,v.Z)
        if hv.Magnitude<5 then return end                     -- ยืน/ช้า = ไม่เสี่ยง
        local my=hrp.Position; local ah=my+hv.Unit*7          -- จุดข้างหน้าตามทิศวิ่งจริง
        if not workspace:Raycast(ah+Vector3.new(0,4,0),Vector3.new(0,-45,0),RayParams) then
            hum:MoveTo(my)                                   -- เบรกทันทีก่อนพุ่งตก
            cfg._botWp=nil; cfg._botPathT=nil                -- บังคับ path คำนวณใหม่
        end
    end) end
    task.wait(0.15)
end end)

-- ============ anti-AFK kick (Roblox 20 นาที) — VirtualUser มาตรฐาน ปลอดภัย ============
do
    LP.Idled:Connect(function() pcall(function() local VU=game:GetService("VirtualUser") VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end)
end

-- ============ ตัวเรา: วิ่งไว (client-owned physics — จำค่าจริงก่อนแกะ ปิด→คืน) ============
task.spawn(function() while alive() do
    local ch=LP.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then
        local want = cfg.selfOn and (cfg.sub.spd2 and 32 or (cfg.sub.spd15 and 24 or nil)) or nil
        if want then
            if not cfg._baseWS then cfg._baseWS=hum.WalkSpeed end
            if hum.WalkSpeed~=want then hum.WalkSpeed=want end
        elseif cfg._baseWS and hum.WalkSpeed~=cfg._baseWS then
            hum.WalkSpeed=cfg._baseWS; cfg._baseWS=nil
        end
    end
    task.wait(0.2)
end end)

-- ============ instaPick: HoldDuration=0 ทุก Pickup prompt (ทริคเดียวกับ Pass_InstantMine — client-side ล้วน) ============
task.spawn(function() while alive() do
    if cfg.sub.instaPick then
        for m in pairs(promptSet) do
            if m.Parent and m.HoldDuration~=0 then pcall(function() m.HoldDuration=0 end) end
        end
    end
    task.wait(2)
end end)

-- ============ REFRESH SWEEP ทุก 60 วิ — rescan + revalidate ของใกล้ตัว ============
task.spawn(function() while alive() do
    task.wait(60)
    if not alive() then break end
    fullScan(); scanRunes()
    -- ตัวที่ unstream แต่อยู่ใกล้เรา (<180 studs): โซนนี้ server stream แน่ๆ → model หาย = โดนเก็บ/รีจริง → นับพลาด 2 รอบแล้วลบ
    -- (เช็คเฉพาะตอน ReplicationFocus ว่าง — ตอนดึง stream ไกลของใกล้อาจหลุดชั่วคราว)
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp and LP.ReplicationFocus==nil then
        local pp=hrp.Position
        local dropped=0
        for m in pairs(known) do
            if m.Parent==nil then
                local kp=knownPos[m]
                if kp and (kp-pp).Magnitude<180 then
                    missK[m]=(missK[m] or 0)+1
                    if missK[m]>=2 then known[m]=nil knownPos[m]=nil missK[m]=nil dropped+=1 end
                end
            else missK[m]=nil end
        end
        -- ghost sticky ที่อยู่ใกล้แต่ไม่มี model จริงแถวนั้น → หายจริง → ลบ
        for i=#pings,1,-1 do
            local e=pings[i]
            if e.sticky and (e.pos-pp).Magnitude<180 then
                local found=false
                for m in pairs(known) do
                    local k=knownPos[m]
                    if k and (k-e.pos).Magnitude<15 then found=true break end
                end
                if found then e.miss=0
                else
                    e.miss=(e.miss or 0)+1
                    if e.miss>=2 then
                        pcall(function() e.ghost:Destroy() e.hl:Destroy() e.bb:Destroy() end)
                        table.remove(pings,i) dropped+=1
                    end
                end
            end
        end
        if dropped>0 then feedAdd("🧹 เคลียร์ของหายจริง "..dropped.." จุด",C.dim) slog("sweep dropped "..dropped) end
    end
end end)

UIS.InputBegan:Connect(function(i,gpe) if not gpe and i.KeyCode==Enum.KeyCode.RightShift then sg.Enabled=not sg.Enabled end end)
slog("ui ready")
print("[HZMINE] ESP พร้อม")
