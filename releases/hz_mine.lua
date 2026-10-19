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
for _,g in ipairs(CoreGui:GetChildren()) do if g.Name=="HZMineUI" or g.Name=="HZMineEsp" or g.Name=="HZMineMaint" then pcall(function() g:Destroy() end) end end

-- ===== HZ HUB backend: พิงสถิติ + kill-switch (ไม่มีคีย์ — admin เห็นแค่ว่าใครใช้) =====
local HZ_API="https://dry-wave-054e.thanadol821.workers.dev"; local HZ_G="mine"
local HZS=game:GetService("HttpService")
local HZ={last=0,n=0,win=os.clock()}
local function hzPing(ev)   -- throttle ≥2s/ครั้ง · ≤45/10นาที (worker cap 60) — executor ไม่มี request = เงียบ
    local req=request or http_request or (syn and syn.request); if not req then return end
    local now=os.clock()
    if now-HZ.last<2 then return end
    if now-HZ.win>600 then HZ.win=now HZ.n=0 end
    if HZ.n>=45 then return end
    HZ.last=now; HZ.n+=1
    task.spawn(function() pcall(function()
        req({Url=HZ_API.."/ping",Method="POST",Headers={["Content-Type"]="application/json"},
            Body=HZS:JSONEncode({ev=ev,g=HZ_G,u=LP.Name,dn=LP.DisplayName,uid=LP.UserId,place=game.PlaceId})})
    end) end)
end
local function hzMaint(msg)   -- kill-switch on:false → ฆ่าทุกลูป (GEN bump) + ปิด UI + หน้าบำรุงรักษา
    G.__HZMINE=GEN+1
    pcall(function() local o=CoreGui:FindFirstChild("HZMineUI") if o then o:Destroy() end end)
    pcall(function() local o=CoreGui:FindFirstChild("HZMineEsp") if o then o:Destroy() end end)
    local sg=Instance.new("ScreenGui") sg.Name="HZMineMaint" sg.ResetOnSpawn=false sg.DisplayOrder=9999
    local tx=Instance.new("TextLabel") tx.AnchorPoint=Vector2.new(0.5,0.5) tx.Position=UDim2.fromScale(0.5,0.45)
    tx.Size=UDim2.new(0,440,0,96) tx.BackgroundColor3=Color3.fromRGB(20,22,38) tx.TextColor3=Color3.fromRGB(240,240,255)
    tx.Font=Enum.Font.GothamBold tx.TextSize=16 tx.TextWrapped=true
    tx.Text="🛠 HZ HUB — ปิดปรับปรุงชั่วคราว\n"..(type(msg)=="string" and msg~="" and msg or "กลับมาใหม่เร็วๆ นี้")
    Instance.new("UICorner",tx).CornerRadius=UDim.new(0,10)
    local st=Instance.new("UIStroke",tx) st.Color=Color3.fromRGB(255,140,80) st.Thickness=1.5
    tx.Parent=sg; sg.Parent=CoreGui
    print("[HZMINE] maintenance: "..tostring(msg))
end
task.spawn(function()   -- status poll ทุก 60s — fail-open: เน็ต/worker พลาด = ใช้ต่อได้
    local req=request or http_request or (syn and syn.request); if not req then return end
    task.wait(3)
    while alive() do
        local ok,r=pcall(function() return req({Url=HZ_API.."/status?g="..HZ_G,Method="GET"}) end)
        if ok and r and r.Body then
            local ok2,d=pcall(function() return HZS:JSONDecode(r.Body) end)
            if ok2 and type(d)=="table" and d.on==false then hzMaint(d.msg) return end
        end
        task.wait(60)
    end
end)
hzPing("gate")
task.spawn(function() task.wait(6) hzPing("loaded") end)
task.spawn(function() while alive() do task.wait(240) hzPing("alive") end end)


-- log: เก็บในหน่วยความจำ แล้วเขียนไฟล์ทีเดียว≤1 ครั้ง/วิ (เดิม readfile+writefile ทั้งไฟล์ทุกบรรทัด = I/O บวม กระตุกตอนยิง log ถี่) — Xeno appendfile ไม่เขียน จึงต้อง writefile ทั้งไฟล์
-- บัฟเฟอร์เดียวใน G.__HZLOG ทุก generation ใช้ร่วมกัน: handler ของรอบเก่าที่ค้างอยู่ (เช่น WIPE ซ้ำ 22 รอบในล็อกจริง) ไม่เขียนทับด้วยบัฟเฟอร์เก่า
local slog
do
    local L={lines={"== HZ MINE "..os.date().." =="},dirty=true,t=0}
    G.__HZLOG=L
    local function flush() local c=G.__HZLOG if c and c.dirty and writefile then c.dirty=false c.t=os.clock() pcall(writefile,"hz_mine_log.txt",table.concat(c.lines,"\n")) end end
    slog=function(m)
        local c=G.__HZLOG or L; local ls=c.lines
        ls[#ls+1]=os.date("%H:%M:%S").." "..tostring(m); c.dirty=true
        if #ls>1500 then for i=1,600 do table.remove(ls,2) end end   -- เก็บหัว + 900 บรรทัดล่าสุด
        print("[HZMINE]",m)
        if not alive() and os.clock()-c.t>1 then flush() end         -- generation ตายแล้ว (ปิด/รันซ้ำ) = เขียนทันที แต่ไม่ถี่เกิน 1/วิ
    end
    task.spawn(function() while alive() do task.wait(1) flush() end flush() end)
    flush()
end

local C={bgTop=Color3.fromRGB(16,17,30),bgBot=Color3.fromRGB(10,11,20),edge=Color3.fromRGB(96,116,235),
    accent=Color3.fromRGB(88,140,255),accent2=Color3.fromRGB(160,110,255),accent3=Color3.fromRGB(255,110,200),
    on=Color3.fromRGB(64,224,140),off=Color3.fromRGB(62,66,88),txt=Color3.fromRGB(238,240,252),dim=Color3.fromRGB(138,146,178),
    row=Color3.fromRGB(24,26,42),rowH=Color3.fromRGB(33,36,58),opt=Color3.fromRGB(30,33,52),optH=Color3.fromRGB(40,44,68),
    sub=Color3.fromRGB(20,22,37),panel=Color3.fromRGB(19,21,34),deep=Color3.fromRGB(14,16,27),buy=Color3.fromRGB(44,128,72),opt2=Color3.fromRGB(40,44,66),
    good=Color3.fromRGB(120,255,160)}
-- ระดับ+สีตรง GemData.Rarity ของเกม (อัพเดต 2026-10-19: มี Eternal=index9 แล้ว — sync สดจาก module อีกชั้นด้านล่าง)
-- ⚠️ Divine/Empyrean/Infinity/Ultima/Eldritch = ระดับ "พลั่ว" (PickaxeData.rarity) เท่านั้น ไม่ใช่ระดับคริสตัล
local TIERS={"Common","Uncommon","Rare","Epic","Legendary","Mythic","Exotic","Zenith","Eternal"}
local PK={TH_R={Common="ธรรมดา",Uncommon="พิเศษ",Rare="หายาก",Epic="เอพิค",Legendary="ตำนาน",Mythic="มิธิค",Exotic="เอ็กโซติก",Zenith="ซีนิธ",Eternal="อีเทอร์นัล"},thNames={},nameRarity={},nameCard={},TR=false}
PK.ss={t0=os.clock(),n=0,val=0,sold=0}   -- 📈 สถิติรอบนี้ (เก็บ/ขาย/ต่อชั่วโมง) แสดงใน HUD
function PK.thR(r) return PK.TH_R[r] or r or "?" end   -- โชว์ระดับเป็นไทย (ชื่อในเกมยังอังกฤษตาม server)
function PK.isPick(t)   -- พลั่ว/สว่านจริง = Tool ที่มี Cooldown (พลั่วทั่วไป) หรือ DigCooldown (Plasma Drill ใน DrillTools/Hexfang) — ตัดคริสตัล(BagId)/รูน(RuneId)
    return t:IsA("Tool") and (t:GetAttribute("Cooldown") or t:GetAttribute("DigCooldown")) and not t:GetAttribute("BagId") and not t:GetAttribute("RuneId") and true or false
end
function PK.t1(m,id,mut,fr)   -- ป้ายบรรทัดบนของแรร์: ◆ [★ของเรา] ชื่อ [✦mutation] [⛏ฝังอยู่]
    local own=m:GetAttribute("Owner")==LP.UserId
    return "◆ "..(own and "★ " or "")..PK.dispName(id)..(mut and (" ✦"..mut) or "")..(fr and "" or " ⛏ฝังอยู่")
end
function PK.dispName(id) local t=PK.thNames[id] if t then return t end return (tostring(id):gsub("(%l)(%u)","%1 %2")) end
local TCOL={Common=Color3.fromRGB(205,148,92),Uncommon=Color3.fromRGB(95,220,105),Rare=Color3.fromRGB(70,155,255),Epic=Color3.fromRGB(180,95,255),Legendary=Color3.fromRGB(255,170,45),Mythic=Color3.fromRGB(255,70,70),Exotic=Color3.fromRGB(255,216,74),Zenith=Color3.fromRGB(110,235,255),Eternal=Color3.fromRGB(255,125,230)}
local function tIdx(t) for i,v in ipairs(TIERS) do if v==t then return i end end return 0 end
local function rIdx(t) local i=tIdx(t) return i>0 and i or 99 end  -- tier ไม่รู้จัก = สูงสุด (sort/เสียงแจ้ง)
-- ขนาดคริสตัลตามเกมจริง (GemData.SizeClasses — maxKg ต่อชั้น)
PK.SIZEK={2,8,30,120,500,2000,15000,100000,1000000,math.huge}
PK.SIZEN={"Tiny","Small","Medium","Large","Huge","Giant","Massive","Enormous","Colossal","Gargantuan"}
PK.SIZETH={"เล็กมาก","เล็ก","กลาง","ใหญ่","ใหญ่มาก","ยักษ์","มหึมา","ใหญ่มากส้ม","ยักษ์ทอง","การ์แกนทัว"}
function PK.sizeIdx(kg)   -- ชั้นขนาด 1-10 ตามน้ำหนักจริง (GD.sizeClassFor ถ้ามี ไม่งั้นตารางเอง)
    for i,m in ipairs(PK.SIZEK) do if (kg or 0)<=m then return i end end
    return #PK.SIZEK
end
local function tfont(l) l.Font=Enum.Font.GothamMedium pcall(function() l.Font=Enum.Font.Kanit end) end
local function comma(n) local s=tostring(math.floor(tonumber(n) or 0)) while true do local k s,k=s:gsub("^(-?%d+)(%d%d%d)","%1,%2") if k==0 then break end end return s end
local pickByTier={} -- Tier → ชื่อพลั่วจริง (EquippedPickaxe = เลข tier)
task.spawn(function()
    local pt=RS:WaitForChild("PickaxeTools",30)
    if pt then for _,t in ipairs(pt:GetChildren()) do local ti=t:GetAttribute("Tier") if ti then pickByTier[ti]=t.Name end end end
end)
local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o return c end
local function agrad(o) local g=Instance.new("UIGradient"); g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.accent),ColorSequenceKeypoint.new(0.5,C.accent2),ColorSequenceKeypoint.new(1,C.accent3)}; g.Parent=o return g end
local sndSvc=game:GetService("SoundService")
local function sfx(k) if PK.mute then return end pcall(function() local s=Instance.new("Sound") s.SoundId=k=="pop" and "rbxassetid://6895079853" or "rbxassetid://4499400560" s.Volume=k=="pop" and 0.4 or 0.25 sndSvc:PlayLocalSound(s) task.delay(1.2,function() pcall(function() s:Destroy() end) end) end) end

local Freed,DigEff,DigReq,Collected=nil,nil,nil,nil
local PlaceC,TakeC,CfgGetR,CfgStat=nil,nil,nil,nil
local Push,SellReq,TSell,TPlot,GFeed,DigRes,AltY,AltS,TogFav,MineHitEv
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
    MineHitEv=gs and gs:WaitForChild("MineHit",30)   -- server→client hit ที่ยอมรับจริง (วัด hitrate)
    -- ⚠️ SetDigPower = honeypot remote: ไม่มี client จริงยิง แต่ server ฟัง → ยิง = kick 267 "Suspicious activity" (ห้ามแตะ)
    local nm=RS:WaitForChild("NotifyRemotes",30)
    Push=nm and nm:WaitForChild("Push",30)
    local rdr=RS:WaitForChild("RadarRemotes",30)
    PK.BuyRad=rdr and rdr:WaitForChild("BuyRadar",30)     -- ซื้อเรด้า (server เช็คเงิน+stock)
    PK.ShopSt=rdr and rdr:WaitForChild("ShopState",30)    -- push stock ทุก ~1s
    PK.PowFd=rdr and rdr:WaitForChild("PowerFired",30)    -- เรด้าพลัง: impact/zenith (เฉพาะคนถือเรด้า)
    -- ⚠️ RadarUsed = remote กำพร้า ไม่มี client จริงยิง → น่าจะ honeypot ห้ามแตะ
    local gr=RS:WaitForChild("GemRemotes",30)
    SellReq=gr and gr:WaitForChild("RequestSell",30)
    QuoteAll=gr and gr:WaitForChild("QuoteSellAll",30)
    SellRes=gr and gr:WaitForChild("SellResult",30)
    TogFav=gr and gr:WaitForChild("ToggleFavorite",30)   -- ⭐กันขาย (server เว้น favorite ตอนขาย All)
    local cbr=RS:WaitForChild("CrystalBagRemotes",30)
    CBEquip=cbr and cbr:WaitForChild("Equip",30)
    local br=RS:WaitForChild("BackpackRemotes",30)
    TSell=br and br:WaitForChild("TeleportSell",30)
    TPlot=br and br:WaitForChild("TeleportPlot",30)
    local pr2=RS:WaitForChild("PlotRemotes",30)
    PlaceC=pr2 and pr2:WaitForChild("PlaceCrystal",30)
    TakeC=pr2 and pr2:WaitForChild("TakeOut",30)
    CfgGetR=pr2 and pr2:WaitForChild("ConfigGet",30)
    CfgStat=pr2 and pr2:WaitForChild("ConfigStats",30)
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
    local shr=RS:WaitForChild("ShopRemotes",30)            -- ร้านพลั่ว: BuyPickaxe(index,"cash") · EquipPickaxe(index) · ShopState(owned[],equipped,err) (168_ShopClient:352-423)
    PK.BuyPick=shr and shr:WaitForChild("BuyPickaxe",30)
    PK.EqPick=shr and shr:WaitForChild("EquipPickaxe",30)
    PK.PickSt=shr and shr:WaitForChild("ShopState",30)
    local bmr=RS:WaitForChild("BaseRemotes",30)
    PK.THome=bmr and bmr:WaitForChild("TeleportHome",30)   -- วาปกลับฐาน (108_BaseClient:209) — ใช้ตอนหนาวจัด
    PK.UsePot=RS:FindFirstChild("UsePotion")               -- UsePotion(name) · GetPotions() → {name=n} · UpdatePotions(name,n) · SyncAllPotions({..}) (156_ShopLocalHandler:478-819)
    PK.GetPot=RS:FindFirstChild("GetPotions"); PK.UpdPot=RS:FindFirstChild("UpdatePotions"); PK.SyncPot=RS:FindFirstChild("SyncAllPotions")
    -- ==== remotes อัพเดต 2026-10-19 (dump ใหม่) ====
    local bmb=RS:WaitForChild("BombRemotes",30)
    PK.BuyBomb=bmb and bmb:WaitForChild("BuyBomb",30)        -- ซื้อระเบิดด้วยเงินเกม: BuyBomb(id,"cash") (BombShopClient:334)
    PK.BombSt=bmb and bmb:WaitForChild("ShopState",30)     -- push {stock={id=n}} ทุกรีสต็อก
    local fur=RS:WaitForChild("FusionRemotes",30)
    PK.FusOdds=fur and fur:WaitForChild("Odds",30)         -- เช็คอัตราก่อนเสียของ: Odds({BagId,BagId,BagId})
    PK.FusFuse=fur and fur:WaitForChild("Fuse",30)         -- Fuse({BagId×3 ระดับเดียวกัน}) (FusionClient:2337)
    PK.FusClaim=fur and fur:WaitForChild("Claim",30)
    PK.FusStat=fur and fur:WaitForChild("Status",30)
    local cwr=RS:WaitForChild("CauldronRemotes",30)
    PK.Cauldron=cwr and cwr:WaitForChild("Donate",30)      -- เทแคนดี้เข้าหม้อเป้ารวมเซิร์ฟเวอร์: Donate(amount)
    local crr=RS:WaitForChild("CrateRemotes",30)
    PK.CrateOpen=crr and crr:WaitForChild("Open",30)       -- เปิด Haunted Crate: Open(n) n=1/3/5 (CrateShopClient:2638)
    local drr=RS:WaitForChild("DailyRewardRemotes",30)
    PK.Daily=drr and drr:WaitForChild("Claim",30)          -- เคลมรายวัน: Claim("claim")
    slog("remotes freed="..tostring(Freed~=nil).." sell="..tostring(SellReq~=nil).." met="..tostring(MetEv~=nil).." mt="..tostring(MtChoose~=nil).." w="..tostring(WState~=nil).." pick="..tostring(PK.BuyPick~=nil).." home="..tostring(PK.THome~=nil).." pot="..tostring(PK.UsePot~=nil).." bomb="..tostring(PK.BuyBomb~=nil).." fus="..tostring(PK.FusFuse~=nil).." crate="..tostring(PK.CrateOpen~=nil).." caul="..tostring(PK.Cauldron~=nil).." daily="..tostring(PK.Daily~=nil))
end)

local cfg={esp=true,minTier=1,ttl=150,pickMode=false,players=true,autodig=false,autocollect=false,autosell=false,selfOn=false,botTier=1,
    met=true,runes=true,mtn=true,autoup=false,garden=false,radarSnipe=false,bombSnipe=false,fusion=false,halloween=false,radClone=false,bombAuto=false,
    sub={espHl=true,espName=true,espAbove=true,espLuck=false,espSize=1,espFar=true,espBld=true,streamFar=false,   -- เรดาร์แรร์: ตัวทรง/ป้าย/≥ระดับ/ค่าโชค/ขนาด/มาร์กไกล/หิน
         pHl=true,pName=true,pDig=true,                            -- ผู้เล่น: ตัว/ป้าย/แท็กขุด
         smartDig=true,colRange=true,                              -- ขุด:เล็งแรร์ฝัง · เก็บ:เช็คระยะ
         turboDig=false,instaPick=true,aoeDig=true,hitE=true,digFar=false,      -- ขุดโหด:turbo · เก็บ:Hold=0 · ขุดหลายเป้าพร้อมกัน · กด E ตีแรร์ที่ขุดโผล่

         remoteSell=true,                                          -- ขาย:ยิง RequestSell ตรงๆ ไม่วาป (ยืนยันในเกมแล้ว: ไม่เช็คระยะ — NOTES 2026-10-14)
         spd15=false,spd2=false,                                   -- วิ่งไว: 1.5x (ปลอดภัย) / 2x (=Pass_Speed2x จริง)
         jet=false,                                                -- 🚀 เจ็ทแพ็ค: clone โมเดลตัวโชว์เข้าตัว → JetpackClient ของเกมหยิบเอง (ทดลอง)
         skillAuto=true,                                           -- ⚔️ ยิงสกิล Shatter/Swarm อัตโนมัติเมื่อถือเคียว/ค้างคาว + cooldown พร้อม (gate ด้วย Holding attr ที่ server ตั้ง)
         hpBar=true,                                               -- แรร์: ❤HP ตอนโดนขุด
         snCrystal=false,snRarity=false,snBoulder=true,snRune=false,snMeteor=true,snZenith=true,  -- เรด้าสอยสต็อก: เลือกชนิดที่จะสอย
         radCloneType="ZenithRadar",
         metMark=true,metFeed=true,                                -- เมเทียร์: ป้ายจุดตก/แจ้งเตือน
         runeHl=true,runeLbl=true,                                 -- รูน: ตัว/ป้าย
         mtnAuto=false,                                           -- ภูเขา: auto-ขึ้นดีสุด
         upCarry=true,upWarm=true,upSoon=true,upPick=true,autoPot=false,coldHome=true,   -- อัพเกรด: carry/warmth · ซื้อทันที · พลั่ว · ยา | ตัวเรา: กันตายหนาว
         gdSwap=true,gdTier=3,gdKeep=true,gdTrip=true,             -- สวน: สลับชิ้นluckต่ำออก / วางเฉพาะ≥tier / เก็บชิ้นโชคกันขาย / วาปไปลงสวนเอง
         snB_ClassicBomb=true,snB_WindBomb=true,snB_IceBomb=true,  -- 💣 ระเบิดสอยสต็อก: ติ๊กแยกทีละลูก (เหมือนเรด้า) — default ถูก 3 ลูกแรก
         snB_FireBomb=false,snB_PoisonBomb=false,snB_LightningBomb=false,
         snB_VoidBomb=false,snB_NebulaBomb=false,snB_DivineBomb=false,
         fusKeep=6,                                                -- ⚗️ ฟิวส์: เว้นชิ้นระดับ ≥Mythic(6) ไว้ ไม่ฟิวส์
         autoDaily=true,crateAuto=false,crateN=1}                  -- 🎃 Halloween: เคลมรายวัน / เปิดกล่องผีอัตโน / ขนาดกล่อง (1/3/5)
         }
local picks={}     -- {gemName=true} — โหมดเฉพาะที่เลือก
local tracked={}   -- [model]={hl,bb,txt,name,rarity,kg}
local pings={}     -- {pos,rarity,kg,t,sticky?,id?,miss?} — registry พิกัดล้วน (เอา ghost visual ออกแล้ว)
local marks={}     -- {part,bb,txt,pos,until} — ป้าย event (เมเทียร์/ดาวตก)
local rtrack={}    -- [runeModel]={hl,bb,t1,t2}
local knownPos={}  -- [model]=Vector3 — พิกัดล่าสุดที่เห็น (revalidate ตัว unstream)
local missK=setmetatable({},{__mode="k"})  -- [model]=จำนวนรอบที่พลาด (weak — model ตายก็หายเอง)
local promptSet={} -- [ProximityPrompt]=true — Pickup ทั้งแมพสำหรับ auto-collect
local buriedCache={}; local buriedT=0 -- cache เป้าขุด (refresh 2 วิ)

-- modules จริงของเกม (read-only data — ใช้สี/ชื่อ/rarity ตรงกับเกม)
local MP,RD,GD=nil,nil,nil
task.spawn(function()
    pcall(function() MP=require(RS:WaitForChild("MountainPool",20)) end)
    pcall(function() RD=require(RS:WaitForChild("RuneData",20)) end)
    pcall(function() PK.PD=require(RS:WaitForChild("PickaxeData",20)) end)   -- ตารางพลั่วจริง: price/power/radius/mineSize/limited (dump_2026-10-14/06_modules_all.txt)
    -- sync ระดับ+สีจาก GemData จริง — เกมเปลี่ยนสีเราตามอัตโนมัติ
    pcall(function()
        GD=require(RS:WaitForChild("GemData",20)); local R=GD and GD.Rarity
        if R then
            local nt={}
            for name,info in pairs(R) do
                local c=info.color
                TCOL[name]=(typeof(c)=="Color3") and c or (type(c)=="table" and Color3.new(c[1] or c.r or 1,c[2] or c.g or 1,c[3] or c.b or 1)) or TCOL[name]
                if type(info.index)=="number" then nt[info.index]=name end
            end
            for i in pairs(TIERS) do TIERS[i]=nil end
            for i=1,20 do if nt[i] then TIERS[i]=nt[i] end end
            -- ทาบสีให้ของที่ track อยู่แล้วด้วย
            for m,v in pairs(tracked) do local c=TCOL[v.rarity]; if c then v.hl.FillColor=c v.t1.TextColor3=c end end
        end
    end)
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
    for _,e in ipairs(pings) do if e._a then pcall(function() e._a:Destroy() end) end end
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
    local lk=""   -- 🍀 ค่าโชคของชิ้นนี้ (สูตรเกมจริง) — ใส่บนป้ายเมื่อ espLuck เปิด
    if cfg.sub.espLuck and GD and GD.effectiveLuck then
        local ok,l=pcall(GD.effectiveLuck,rarity,kg,mut,nil,m:GetAttribute("CoreLuck"),m:GetAttribute("GemName"))
        if ok and type(l)=="number" then lk=(" · 🍀%.0f"):format(l) end
    end
    t1.Text=PK.t1(m,m:GetAttribute("GemName") or m.Name,mut,m:GetAttribute("Freed"))
    t2.Text=string.format("%s%s · %.1fkg · $%s%s",PK.thR(rarity),sz and (" ["..sz.."]") or "",kg,tostring(val),lk)
    tracked[m]={hl=hl,bb=bb,t1=t1,t2=t2,rarity=rarity,name=name,id=(m:GetAttribute("GemName") or m.Name),kg=kg,mut=mut,sz=sz,core=m:GetAttribute("CoreLuck"),owner=m:GetAttribute("Owner")}
    known[m]=rarity
    -- 🎯 เจาะจง: ชื่อที่เลือกเกิด → แจ้งใน feed + เสียง
    if feedAdd and picks[tracked[m].id] then
        sfx("pop")
        feedAdd(("🎯 %s เกิด! (%.1fkg %s)"):format(PK.dispName(tracked[m].id),kg or 0,PK.thR(rarity)),TCOL[rarity])
    end
    -- เคลียร์ ping ที่ตรงจุดนี้ — ใช้ FreedPos หรือ pivot (แรร์ฝังไม่มี FreedPos แต่ตำแหน่งก็ตรง)
    local fp=m:GetAttribute("FreedPos")
    if not fp then local ok,p=pcall(function() return m:GetPivot().Position end) fp=ok and p or nil end
    if fp then
        for i=#pings,1,-1 do
            if (pings[i].pos-fp).Magnitude<18 then local pe=pings[i] if PK.rmFar then PK.rmFar(pe) end table.remove(pings,i) end
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
    if wantShow(r, m:GetAttribute("GemName") or m.Name, m:GetAttribute("Kg")) then queueTrack(m) end
end

local function scan()
    -- กวาดเฉพาะจุดที่แรร์อยู่จริง: SpawnedGems (ทั้งฝัง/โผล่) + root (ของทิ้ง/Dropped)
    local sgm=workspace:FindFirstChild("SpawnedGems")
    if sgm then
        for _,d in ipairs(sgm:GetDescendants()) do if isGemModel(d) then consider(d) end end
    end
    local blf=workspace:FindFirstChild("Boulders")   -- 🪨 หินก้อนใหญ่ (ค่าเดียวกับ BoulderRadar อ่าน)
    if blf then for _,d in ipairs(blf:GetChildren()) do if PK.isBoulder(d) then PK.trackBoulder(d) end end end
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
Players.PlayerAdded:Connect(function(p) if alive() then trackPlayer(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if not alive() then return end
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
workspace.DescendantRemoving:Connect(function(d) if alive() and d:IsA("ProximityPrompt") then promptSet[d]=nil end end)
task.spawn(function() task.wait(1) while alive() do pcall(scan); task.wait(4) end end)   -- รอ 1s ให้ chunk โหลดครบก่อน (เดิม scan รอบแรกรันตอนโหลด wantShow/isBoulder ยังไม่ประกาศ → error ฆ่าลูปนี้ตั้งแต่เริ่ม)

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

-- burst แรก: (ถ้าเปิด streamFar) ขอ stream ทั้ง 36 จุด → รอโหลด → กวาดทั้ง workspace (fullScan เก็บ prompt/แรร์ — ทำเสมอ)
-- ⚠️ เดิม `LP.ReplicationFocus=CFrame.new(..)` = ผิดชนิด (property เป็น Instance) → error ใน pcall → บรรทัด RequestStreamAroundAsync ถัดไปไม่เคยรัน
--    ฟีเจอร์ดึงแมพไกลเลยไม่เคยทำงานจริง · แก้เป็นเรียก RequestStreamAroundAsync(Vector3) ตรงๆ + ซ่อนหลังสวิตช์ streamFar (หนัก/อาจกระตุก ปิดเป็นค่าเริ่ม)
local function pullPos(pos)
    if cfg.sub.streamFar and LP.RequestStreamAroundAsync then pcall(function() LP:RequestStreamAroundAsync(pos,4) end) end
end
task.spawn(function()
    task.wait(2)
    if cfg.sub.streamFar then
        for _,g in ipairs(grid) do task.spawn(pullPos,g); task.wait(0.15) end
    end
    task.wait(2.5)
    fullScan()
    slog("burst scan done")
    task.wait(1.5)
    fullScan()
end)

-- loop ต่อเนื่อง (เฉพาะเปิด streamFar): ดึง ping 3 จุด + grid 1 จุด/รอบ → รอโหลด → scan ก่อน unstream
task.spawn(function() while alive() do
    if cfg.sub.streamFar and LP.RequestStreamAroundAsync then
        if #pings>0 then
            local best={}
            for _,e in ipairs(pings) do best[#best+1]=e end
            table.sort(best,function(a,b) return rIdx(a.rarity)>rIdx(b.rarity) end)
            streamIdx=streamIdx%#best
            for j=0,math.min(2,#best-1) do
                pullPos(best[(streamIdx+j)%#best+1].pos)
                task.wait(0.5)
            end
            streamIdx+=3
        end
        gridIdx=gridIdx%#grid+1
        pullPos(grid[gridIdx])
        task.wait(1.2)
        pcall(scan)
    end
    task.wait(3)
end end)

-- โฟลเดอร์จอด marker (เหลือไว้สำหรับ event marks — ghost clone เอาออกแล้วเน้นบอท AFK)
for _,n in ipairs({"HZGhost","HZFar"}) do local o=workspace:FindFirstChild(n) if o then pcall(function() o:Destroy() end) end end   -- รันซ้ำ: ล้างโฟลเดอร์ของรอบก่อน (เดิมค้างซ้อนกันเรื่อยๆ)
local ghostParent=Instance.new("Folder"); ghostParent.Name="HZGhost"; ghostParent.Parent=workspace

-- 📡 far markers: part มองไม่เห็น + billboard ต่อ ping — เห็นได้ทุกระยะ (model ไม่ stream ก็ยังมีป้าย)
local farFolder=Instance.new("Folder"); farFolder.Name="HZFar"; farFolder.Parent=workspace
function PK.mkFar(e)   -- สร้าง anchor+billboard ให้ ping e (ทำครั้งเดียวต่อจุด)
    local a=Instance.new("Part"); a.Anchored=true; a.CanCollide=false; a.CanQuery=false; a.CanTouch=false
    a.Size=Vector3.new(1,1,1); a.Transparency=1; a.Position=e.pos; a.Parent=farFolder
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,190,0,34); bb.StudsOffsetWorldSpace=Vector3.new(0,2.5,0)
    bb.AlwaysOnTop=true; bb.Adornee=a; bb.Parent=hlFolder
    local l1=Instance.new("TextLabel"); l1.Size=UDim2.new(1,0,0,16); l1.BackgroundTransparency=1
    l1.Font=Enum.Font.GothamBold; l1.TextSize=12; l1.TextStrokeTransparency=0.25; l1.Parent=bb; tfont(l1)
    local l2=Instance.new("TextLabel"); l2.Size=UDim2.new(1,0,0,14); l2.Position=UDim2.new(0,0,0,16); l2.BackgroundTransparency=1
    l2.TextSize=10; l2.TextStrokeTransparency=0.35; l2.TextColor3=Color3.fromRGB(215,220,240); l2.Parent=bb; tfont(l2)
    e._a=a; e._t1=l1; e._t2=l2
end
function PK.rmFar(e) if e._a then pcall(function() e._a:Destroy() end) e._a=nil e._t1=nil e._t2=nil end end

local RAW_N=0
local function addPing(...)
    local a={...}
    RAW_N+=1
    if RAW_N<=10 then
        local parts={}; for i,v in ipairs(a) do parts[#parts+1]=typeof(v)..":"..tostring(v) end
        slog("RAW["..RAW_N.."] "..table.concat(parts," | "))
    end
    local pos,rarity,kg,owner
    if typeof(a[1])=="Vector3" and typeof(a[2])=="string" and typeof(a[3])=="number" then   -- รูปแบบจริงจาก log: (Vector3, rarity, kg, ownerUserId) — kg ไม่จำกัดขนาด (เดิมตัด ≥100000kg เป็น 0)
        pos,rarity,kg,owner=a[1],a[2],a[3],(typeof(a[4])=="number" and a[4] or nil)
    else
        for _,v in ipairs(a) do if typeof(v)=="Vector3" then pos=v end end
        if not pos and typeof(a[1])=="number" then pos=Vector3.new(a[1],a[2] or 0,a[3] or 0) end
        for _,v in ipairs(a) do
            if typeof(v)=="string" and not rarity then rarity=v end  -- รับทุกชื่อ tier รวมอนาคต
            if typeof(v)=="number" and not kg and v>0 and v<100000 then kg=v end
        end
    end
    rarity=rarity or "Common"; kg=tonumber(kg) or 0
    if not pos then return end
    for _,e in ipairs(pings) do if (e.pos-pos).Magnitude<10 then e.t=os.clock() return end end
    for m in pairs(known) do local fp=m:GetAttribute("FreedPos") if fp and (fp-pos).Magnitude<15 then return end end
    pings[#pings+1]={pos=pos,rarity=rarity,kg=kg,t=os.clock(),owner=owner}   -- registry ล้วน — ไม่มี ghost model แล้ว (owner = UserId เจ้าของ → ป้าย ★ ถ้าเป็นของเรา)
    slog(string.format("PING %s %.1fkg @ %.0f,%.0f,%.0f%s",rarity,kg,pos.X,pos.Y,pos.Z,owner==LP.UserId and " ★ของเรา" or ""))
    -- ขอ server stream พื้นที่นี้ → model จริงโหลด → ทรง/ชื่อจริงแทน ghost
    if LP.RequestStreamAroundAsync then
        task.spawn(function() pcall(function() LP:RequestStreamAroundAsync(pos,8) end) end)
    end
end

-- ============ 🪨 Boulder ESP — intel เดียวกัน BoulderRadar (ชื่อ/สี/พลั่วที่ต้อง/ฝัง) + HP + เทียบพลั่วเราขุดได้ไหม ============
PK.btracked={}
function PK.isBoulder(m) return m:IsA("Model") and m:FindFirstChild("Mesh_0")~=nil end
function PK.trackBoulder(m)
    if PK.btracked[m] or m:GetAttribute("Broken") then return end
    local mesh=m:FindFirstChild("Mesh_0")
    local col=m:GetAttribute("LabelColor") or (mesh and mesh.Color) or Color3.fromRGB(170,150,120)
    local geode=m:GetAttribute("IsGeode")==true
    local hl=Instance.new("Highlight")
    hl.FillColor=col; hl.OutlineColor=Color3.new(1,1,1); hl.FillTransparency=0.68; hl.OutlineTransparency=0.2
    hl.Adornee=m; hl.Parent=hlFolder
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,210,0,38); bb.StudsOffsetWorldSpace=Vector3.new(0,4.5,0)
    bb.AlwaysOnTop=true; bb.Adornee=m; bb.Parent=hlFolder
    local t1=Instance.new("TextLabel"); t1.Size=UDim2.new(1,0,0,18); t1.BackgroundTransparency=1
    t1.Font=Enum.Font.GothamBold; t1.TextSize=13; t1.TextStrokeTransparency=0.3; t1.TextColor3=col; t1.Parent=bb; tfont(t1)
    local t2=Instance.new("TextLabel"); t2.Size=UDim2.new(1,0,0,14); t2.Position=UDim2.new(0,0,0,18); t2.BackgroundTransparency=1
    t2.TextSize=11; t2.TextStrokeTransparency=0.4; t2.TextColor3=Color3.fromRGB(225,225,240); t2.Parent=bb; tfont(t2)
    t1.Text=(geode and "💎 " or "🪨 ")..(m:GetAttribute("DisplayName") or (tostring(m:GetAttribute("BoulderId") or "?").." Boulder"))
    PK.btracked[m]={hl=hl,bb=bb,t1=t1,t2=t2,geode=geode}
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

-- ===== UI-V6-BEGIN (สร้างจาก ui/*.lua ด้วย build_ui.py — แก้ที่ต้นทาง อย่าแก้ตรงนี้) =====
-- ============ 🎨 UI v6 (PC) — หน้าต่างสำหรับคอม ============
-- แท็บ(ภาพรวม/ฟาร์ม/เรดาร์/ตัวเรา/โลก/กระเป๋า/ตั้งค่า) · ค้นหา · ปุ่มลัด(ตั้งเองได้) · tooltip · toast+บันทึกกิจกรรม · จำค่า(hz_mine_cfg.json) · ลาก/ปรับขนาด/ซูม/โปร่งใส
-- cfg.* คือแหล่งความจริงเดียว — UI แค่สะท้อน + สั่ง (callback เรียก logic เดิมเหมือนเดิมทุกจุด)
wantShow=function(rarity,name,kg)
    if cfg.pickMode and picks[name] then return true end  -- 🎯 ชื่อที่เลือก track เสมอ แม้ ESP ปิด (ยังแจ้งเตือน/ขุดได้)
    if not cfg.esp then return false end
    if cfg.pickMode then return false end  -- pickMode ON แต่ไม่ใช่ชื่อที่เลือก → ซ่อน
    local idx=tIdx(rarity)
    local pass=(idx==0) or (cfg.sub.espAbove and idx>=cfg.minTier) or idx==cfg.minTier   -- ≥ หรือ เฉพาะเท่ากับ
    if pass and (cfg.sub.espSize or 1)>1 then pass=PK.sizeIdx(kg or 0)>=(cfg.sub.espSize or 1) end   -- 📏 กรองขนาดเหมือนเกม
    return pass
end
applyFilter=function()
    -- ทำลายภาพของตัวที่ไม่ผ่าน filter + เข้าคิวสร้างตัวที่ผ่าน — ภาพมีเท่าที่แสดงจริง
    for m,e in pairs(tracked) do
        if wantShow(e.rarity,e.id,e.kg) then
            e.hl.Enabled=true; e.bb.Enabled=true
        else
            pcall(function() e.hl:Destroy() e.bb:Destroy() end); tracked[m]=nil
        end
    end
    for m,r in pairs(known) do
        if m.Parent and wantShow(r, m:GetAttribute("GemName") or m.Name, m:GetAttribute("Kg")) then queueTrack(m) end
    end
end


local UI={}; PK.ui=UI
do
local HttpS=game:GetService("HttpService")
local WHITE=Color3.new(1,1,1)
C.side=Color3.fromRGB(12,13,24); C.warn=Color3.fromRGB(255,190,80); C.bad=Color3.fromRGB(255,110,110); C.line=Color3.fromRGB(40,44,70)
UI.paints={}; UI.cards={}; UI.tabList={}; UI.tabBy={}

-- ───────── helpers ─────────
local ords=setmetatable({},{__mode="k"})
local function nxt(p) local n=(ords[p] or 0)+1 ords[p]=n return n end
local function mk(cls,props,parent)
    local o=Instance.new(cls)
    if props then for k,v in pairs(props) do o[k]=v end end
    if parent then o.Parent=parent end
    return o
end
local function lbl(parent,p)
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1; l.TextSize=12; l.TextColor3=C.txt; l.TextXAlignment=Enum.TextXAlignment.Left; l.BorderSizePixel=0
    tfont(l)
    for k,v in pairs(p) do l[k]=v end
    l.Parent=parent return l
end
local function btn(parent,p)
    local b=Instance.new("TextButton")
    b.AutoButtonColor=false; b.BackgroundTransparency=1; b.BorderSizePixel=0; b.Text=""; b.TextSize=12; b.TextColor3=C.txt
    tfont(b)
    for k,v in pairs(p) do b[k]=v end
    b.Parent=parent return b
end
local function stroke(o,col,tr)   -- UIStroke แบบขอบ (Border) — ค่า Contextual บน TextButton/TextLabel จะวิ่งรอบ "ตัวอักษร" ไม่ใช่กรอบ
    local s=Instance.new("UIStroke"); s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Color=col; s.Transparency=tr or 0.5; s.Parent=o return s
end
local function guard(sig,f)   -- ต่อสัญญาณแล้วถอดตัวเองเมื่อ generation ตาย (รันสคริปต์ซ้ำ/กดปิด) — ไม่ให้ handler เก่าสะสมใน UserInputService
    local c
    c=sig:Connect(function(...) if not alive() then c:Disconnect() return end f(...) end)
    return c
end
local function tw(o,t,props) pcall(function() Tween:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad),props):Play() end) end
local function hoverFx(b,target,base,over)
    b.MouseEnter:Connect(function() tw(target,0.1,{BackgroundColor3=over}) end)
    b.MouseLeave:Connect(function() tw(target,0.14,{BackgroundColor3=base}) end)
end
local function hex(c) return string.format("%02x%02x%02x",math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5)) end
local function esc(s) s=tostring(s) s=s:gsub("&","&amp;") s=s:gsub("<","&lt;") s=s:gsub(">","&gt;") return s end
local function trim(s) s=tostring(s or "") s=s:gsub("^%s+","") s=s:gsub("%s+$","") return s end
UI.mk,UI.lbl,UI.btn,UI.tw,UI.nxt,UI.guard=mk,lbl,btn,tw,nxt,guard

-- ───────── 🎮 ไอคอนจากเกมจริง (require โมดูลข้อมูลของเกม — อัปเดตตามเวอร์ชันเอง · fail/mock → fallback emoji) ─────────
UI.icon={coin="rbxassetid://15589362394"}
pcall(function()
    local okR,RS=pcall(function() return game:GetService("ReplicatedStorage") end)
    if not okR or not RS then return end
    local function req(n) local m=RS:FindFirstChild(n) if not m then return nil end local ok2,v=pcall(require,m) return ok2 and v or nil end
    local GD=req("GemData"); if GD and type(GD.Icons)=="table" then UI.icon.gem=GD.Icons end          -- Rarity_*/Size_*/Luck_*/Value_<ระดับ>
    local RD=req("RadarData"); if RD then UI.icon.radar={} for _,e in pairs(RD.ById or RD.List or {}) do if type(e)=="table" and e.id then UI.icon.radar[e.id]=e.icon end end end
    local MD=req("MountainData"); if MD then UI.icon.mtn={} for _,e in pairs(MD) do if type(e)=="table" and e.id and e.image and e.image~="" then UI.icon.mtn[e.id]=e.image end end end
    local PD=req("PlotData"); if PD and type(PD.Icons)=="table" then UI.icon.garden=PD.Icons end    -- crystal/clover/arrow
    local SD=req("ScytheData"); if SD and SD.Icon then UI.icon.scythe=SD.Icon end
    local BD=req("BatwingData"); if BD and BD.Icon then UI.icon.batwing=BD.Icon end
end)
function UI.gemIcon(t) local G=UI.icon.gem return G and G["Rarity_"..tostring(t)] end
function UI.szIcon(t) local G=UI.icon.gem return G and G["Size_"..tostring(t)] end
function UI.radarIcon(id) return UI.icon.radar and UI.icon.radar[id] end
function UI.mtnImage(id) return UI.icon.mtn and UI.icon.mtn[id] end
function UI.gdIcon(k) return UI.icon.garden and UI.icon.garden[k] end
-- มี asset → ImageLabel / ไม่มี → TextLabel emoji (fallback เสมอ)
function UI.iconOrEmoji(parent,asset,emoji,pos,size,textSize,z)
    if asset then
        return mk("ImageLabel",{BackgroundTransparency=1,Image=asset,Position=pos or UDim2.new(0,0,0,0),Size=size or UDim2.new(1,0,1,0),ZIndex=z or 3,ScaleType=Enum.ScaleType.Fit},parent)
    end
    return lbl(parent,{Text=emoji or "",Position=pos or UDim2.new(0,0,0,0),Size=size or UDim2.new(1,0,1,0),TextSize=textSize or 15,ZIndex=z or 3,TextXAlignment=Enum.TextXAlignment.Center})
end

-- ───────── 💾 ตั้งค่าถาวร (hz_mine_cfg.json) ─────────
cfg.ui={x=60,y=60,w=700,h=520,scale=1,opacity=0.04,tab="dash",sound=true,toast=true,pill=true,autosave=true,autostart=false,open={},
    keys={ui="RightShift",autodig="F1",autocollect="F2",autosell="F3",autoup="F4",garden="F5",esp="F6",selfOn="F7",panic="F8"}}
local FLAGS={"esp","minTier","players","autodig","autocollect","autosell","selfOn","botTier","met","runes","mtn","autoup","garden","radarSnipe","radClone","bombSnipe","bombAuto","fusion","halloween","pickMode"}
local ACT={autodig=1,autocollect=1,autosell=1,selfOn=1,autoup=1,garden=1,radarSnipe=1,bombSnipe=1,bombAuto=1,fusion=1,halloween=1,radClone=1}   -- สวิตช์ที่ "ลงมือทำ" — คืนค่าเฉพาะเมื่อเปิด autostart (ESP/ฟิลเตอร์คืนเสมอ)
UI.DEF={flags={},sub={},ui={}}
for _,k in ipairs(FLAGS) do UI.DEF.flags[k]=cfg[k] end
for k,v in pairs(cfg.sub) do UI.DEF.sub[k]=v end
for k,v in pairs(cfg.ui) do if type(v)~="table" then UI.DEF.ui[k]=v end end
UI.DEF.keys={} for k,v in pairs(cfg.ui.keys) do UI.DEF.keys[k]=v end
UI.FILE="hz_mine_cfg.json"
function UI.snapshot()
    local t={v=6,flags={},sub={},ui={},picks={}}
    for _,k in ipairs(FLAGS) do t.flags[k]=cfg[k] end
    for k,v in pairs(cfg.sub) do local ty=type(v) if ty=="boolean" or ty=="number" or ty=="string" then t.sub[k]=v end end   -- string ด้วย (radCloneType)
    for k,v in pairs(cfg.ui) do if type(v)~="table" then t.ui[k]=v end end
    t.ui.keys={} for k,v in pairs(cfg.ui.keys) do t.ui.keys[k]=v end
    t.ui.open={} for k,v in pairs(cfg.ui.open) do if v then t.ui.open[k]=true end end
    for nm in pairs(picks) do t.picks[#t.picks+1]=nm end
    table.sort(t.picks)
    return t
end
function UI.save()
    if not writefile then return false end
    local ok,js=pcall(function() return HttpS:JSONEncode(UI.snapshot()) end)
    if not ok or type(js)~="string" then return false end
    return pcall(writefile,UI.FILE,js)
end
function UI.apply(t)   -- ใส่ค่าที่โหลดมา (เช็คชนิดทุกค่า — ไฟล์เก่า/เสียไม่ทำให้พัง)
    if type(t)~="table" then return false end
    local fl=type(t.flags)=="table" and t.flags or {}
    for _,k in ipairs(FLAGS) do
        local v=fl[k]
        if v~=nil and type(v)==type(UI.DEF.flags[k]) then
            if ACT[k] then UI.pendM=UI.pendM or {} UI.pendM[k]=v else cfg[k]=v end
        end
    end
    if type(t.sub)=="table" then for k,v in pairs(t.sub) do if UI.DEF.sub[k]~=nil and type(v)==type(UI.DEF.sub[k]) then cfg.sub[k]=v end end end
    local u=type(t.ui)=="table" and t.ui or {}
    for k,v in pairs(u) do if k~="keys" and k~="open" and UI.DEF.ui[k]~=nil and type(v)==type(UI.DEF.ui[k]) then cfg.ui[k]=v end end
    if type(u.keys)=="table" then for k,v in pairs(u.keys) do if type(v)=="string" then cfg.ui.keys[k]=v end end end
    if type(u.open)=="table" then for k,v in pairs(u.open) do if v==true then cfg.ui.open[k]=true end end end
    if type(t.picks)=="table" then for _,nm in ipairs(t.picks) do if type(nm)=="string" then picks[nm]=true end end end
    cfg.ui.scale=math.clamp(tonumber(cfg.ui.scale) or 1,0.7,1.5); cfg.ui.opacity=math.clamp(tonumber(cfg.ui.opacity) or 0.04,0,0.6)
    cfg.ui.w=math.clamp(tonumber(cfg.ui.w) or 700,560,1400); cfg.ui.h=math.clamp(tonumber(cfg.ui.h) or 520,400,1000)
    return true
end
function UI.load()
    if not (readfile and isfile) then return false end
    local ok,s=pcall(function() if isfile(UI.FILE) then return readfile(UI.FILE) end end)
    if not ok or type(s)~="string" or s=="" then return false end
    local ok2,t=pcall(function() return HttpS:JSONDecode(s) end)
    if not ok2 then return false end
    return UI.apply(t)
end
function UI.dirty() UI.dT=os.clock() end
task.spawn(function()
    while alive() do
        task.wait(1)
        if UI.dT and os.clock()-UI.dT>1.5 and cfg.ui.autosave then UI.dT=nil UI.save() end
    end
    if UI.dT and cfg.ui.autosave then UI.save() end
end)
if G.__HZSAVE then pcall(G.__HZSAVE) end   -- รันสคริปต์ซ้ำ: เซฟส่วนที่ generation ก่อนหน้ายังค้างอยู่ก่อนโหลดค่า (ไม่งั้นการตั้งค่าล่าสุดหาย)
G.__HZSAVE=function() if UI.dT and cfg.ui.autosave then UI.dT=nil UI.save() end end
UI.loaded=UI.load()
PK.mute=(cfg.ui.sound==false)

-- ───────── สวิตช์หลัก (แหล่งเดียว: การ์ด / ไทล์ภาพรวม / ปุ่มลัด ใช้ get/set ชุดเดียวกัน) ─────────
local function slogSet(k,v) slog(k.." "..tostring(v)) end
UI.M={
 {id="esp",tab="radar",icon="🛰",col=C.accent,name="เรดาร์แรร์ ESP",short="ESP",desc="Highlight + ป้ายชื่อ/ระยะ/น้ำหนัก ของแรร์ทุกตัวที่เห็น",
    get=function() return cfg.esp end,set=function(v) cfg.esp=v applyFilter() end},
 {id="autodig",tab="farm",icon="⛏",col=Color3.fromRGB(255,170,60),name="ขุดออโต้ + ตีแรร์",short="ขุด",desc="ขุดแรร์ฝังของเรา · กด E ตีจนแตก+เก็บให้",
    get=function() return cfg.autodig end,set=function(v) cfg.autodig=v PK.rc.pr=nil slogSet("autodig",v) end},
 {id="autocollect",tab="farm",icon="✋",col=Color3.fromRGB(120,255,170),name="เก็บแรร์ออโต้",short="เก็บ",desc="กด E เก็บของที่ตก/แรร์ที่ขุดโผล่ในระยะ",
    get=function() return cfg.autocollect end,set=function(v) cfg.autocollect=v slogSet("autocollect",v) end},
 {id="autosell",tab="farm",icon="💰",col=Color3.fromRGB(255,220,90),name="ขายออโต้",short="ขาย",desc="ขายเมื่อกระเป๋าเต็ม/≥92% (ข้ามชิ้น ⭐)",
    get=function() return cfg.autosell end,set=function(v) cfg.autosell=v slogSet("autosell",v) end},
 {id="autoup",tab="farm",icon="⬆",col=C.accent2,name="อัพเกรดอัตโนมัติ",short="อัพ",desc="ซื้อกระเป๋า/ความอบอุ่น/พลั่วให้ตามเงินที่มี",
    get=function() return cfg.autoup end,set=function(v) cfg.autoup=v slogSet("autoup",v) end},
 {id="garden",tab="farm",icon="🌱",col=Color3.fromRGB(90,230,140),name="สวนโชคออโต้",short="สวน",desc="วางแรร์โชคสูงลงสวนให้เอง",
    get=function() return cfg.garden end,set=function(v) cfg.garden=v slogSet("garden",v) end},
 {id="selfOn",tab="self",icon="🧍",col=Color3.fromRGB(140,255,220),name="ตัวเรา",short="ตัวเรา",desc="วิ่งไว · เจ็ทแพ็ค · สกิลเคียว/ค้างคาวออโต้ · กันตกเหว",
    get=function() return cfg.selfOn end,set=function(v) cfg.selfOn=v slogSet("self",v) end},
 {id="players",tab="radar",icon="👥",col=Color3.fromRGB(80,200,255),name="ESP ผู้เล่น",short="ผู้เล่น",desc="ใครอยู่ไหน · ใครกำลังขุด",
    get=function() return cfg.players end,set=function(v) cfg.players=v end},
 {id="runes",tab="radar",icon="🔮",col=Color3.fromRGB(190,130,255),name="รูน ESP",short="รูน",desc="รูนที่ปักในโลก (ชื่อ/ระยะ/ของเรา)",
    get=function() return cfg.runes end,set=function(v) cfg.runes=v applyFilter() end},
 {id="pickMode",tab="radar",icon="🎯",col=Color3.fromRGB(255,120,120),name="เจาะจงชื่อแรร์",short="เจาะจง",desc="ESP/ขุด/เก็บ เฉพาะชื่อที่เลือก",
    get=function() return cfg.pickMode end,set=function(v) cfg.pickMode=v if UI.paintPick then UI.paintPick() end applyFilter() slogSet("pickMode",v) end},
 {id="radarSnipe",tab="radar",icon="📡",col=Color3.fromRGB(90,200,255),name="เรด้าสอยสต็อก",short="สอยเรด้า",desc="สต็อกเรด้ามา + เงินพอ = ซื้อทันที",
    get=function() return cfg.radarSnipe end,set=function(v) cfg.radarSnipe=v slogSet("radarSnipe",v) end},
 {id="radClone",tab="radar",icon="📡",col=Color3.fromRGB(90,235,255),name="เรด้าโคลน ใช้ฟรี",short="เรด้าโคลน",desc="โคลนเรด้าจริงจากเกม — HUD+สแกนทำงาน เวลาไม่หมด ขุดได้",
    get=function() return cfg.radClone end,set=function(v) PK.radClone(v) task.delay(0.7,function() if UI.syncAll then UI.syncAll() end end) end},
 {id="met",tab="world",icon="☄",col=Color3.fromRGB(255,130,90),name="เมเทียร์ + ดาวตก",short="เมเทียร์",desc="ป้ายจุดตก + แจ้งเตือนอีเวนต์",
    get=function() return cfg.met end,set=function(v) cfg.met=v end},
 {id="bombSnipe",tab="farm",icon="💣",col=Color3.fromRGB(255,140,70),name="ระเบิดสอยสต็อก",short="ระเบิด",desc="สต็อกระเบิดมา + เงินพอ = ซื้อทันที (ราคาจริง BombData 2026-10-19)",
    get=function() return cfg.bombSnipe end,set=function(v) cfg.bombSnipe=v slogSet("bombSnipe",v) end},
 {id="bombAuto",tab="farm",icon="💥",col=Color3.fromRGB(255,100,60),name="ระเบิดออโต้ (ซื้อ+โยนวน)",short="ระเบิดวน",desc="หมด → ซื้อลูกดีสุดเอง · มี → ถือ+โยนอัตโนมัติ วนไม่หยุด (ของจริงเท่านั้น)",
    get=function() return cfg.bombAuto end,set=function(v) cfg.bombAuto=v slogSet("bombAuto",v) end},
 {id="fusion",tab="farm",icon="⚗",col=Color3.fromRGB(140,200,255),name="ฟิวส์คริสตัลออโต้",short="ฟิวส์",desc="รวมชิ้นระดับเดียวกัน 3 ชิ้นที่เล็กสุด → ชิ้นใหม่ดีกว่า (เว้นระดับสูง+⭐)",
    get=function() return cfg.fusion end,set=function(v) cfg.fusion=v slogSet("fusion",v) end},
 {id="halloween",tab="world",icon="🎃",col=Color3.fromRGB(255,150,60),name="อีเวนต์ Halloween",short="🎃",desc="เคลมรายวัน · เปิดกล่องผีอัตโน · เทหม้อแคนดี้",
    get=function() return cfg.halloween end,set=function(v) cfg.halloween=v slogSet("halloween",v) end},
}
UI.mBy={} for _,m in ipairs(UI.M) do UI.mBy[m.id]=m end
function UI.setM(id,v)
    local m=UI.mBy[id]; if not m then return end
    if v==nil then v=not m.get() end
    local ok,err=pcall(m.set,v and true or false)
    if not ok then slog("setM "..id.." error: "..tostring(err)) feedAdd("❌ สลับ "..m.name.." ไม่สำเร็จ: "..tostring(err),C.bad) end
    sfx("pop"); UI.syncAll(); UI.dirty()
end
function UI.panic()   -- ⛔ ปิดสวิตช์ที่ "ลงมือทำ" ทั้งหมดทันที (ปุ่มลัดฉุกเฉิน)
    for _,m in ipairs(UI.M) do if (ACT[m.id] or m.id=="radClone") and m.get() then m.set(false) end end
    sfx("pop"); UI.syncAll(); UI.dirty(); feedAdd("⛔ หยุดทุกระบบแล้ว",C.bad)
end
function UI.farmOn()   -- ▶ เปิดชุดฟาร์มหลัก (ขุด+เก็บ+ขาย)
    for _,id in ipairs({"autodig","autocollect","autosell"}) do local m=UI.mBy[id] if not m.get() then m.set(true) end end
    sfx("pop"); UI.syncAll(); UI.dirty(); feedAdd("▶ เปิดชุดฟาร์ม: ขุด + เก็บ + ขาย",C.good)
end
local function activeCount()
    local n=0
    for _,id in ipairs({"autodig","autocollect","autosell","autoup","garden","selfOn","radarSnipe","radClone"}) do if UI.mBy[id].get() then n+=1 end end
    return n
end

-- ───────── ปุ่มลัด ─────────
UI.act={{id="ui",name="ซ่อน/แสดงหน้าต่าง",fn=function() UI.show(not UI.win.Visible) end},
    {id="panic",name="⛔ หยุดทุกระบบ (ฉุกเฉิน)",fn=function() UI.panic() end},
    {id="farmOn",name="▶ เปิดชุดฟาร์ม (ขุด+เก็บ+ขาย)",fn=function() UI.farmOn() end}}
for _,m in ipairs(UI.M) do UI.act[#UI.act+1]={id=m.id,name="สลับ: "..m.name,fn=function() UI.setM(m.id) end} end
UI.actBy={} for _,a in ipairs(UI.act) do UI.actBy[a.id]=a end
function UI.rebuildKeys()
    UI.keyMap={}
    for id,k in pairs(cfg.ui.keys) do if type(k)=="string" and k~="" and UI.actBy[id] then UI.keyMap[k]=id end end
end
function UI.keyOf(id) local k=cfg.ui.keys[id] return (k and k~="") and k or nil end
UI.rebuildKeys()

-- ───────── หน้าต่างหลัก ─────────
local sg=Instance.new("ScreenGui"); sg.Name="HZMineUI"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true; sg.DisplayOrder=100
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=CoreGui
local root=mk("Frame",{Name="Root",BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)},sg)
local uiScale=mk("UIScale",{Scale=cfg.ui.scale},root)
UI.sg,UI.root,UI.uiScale=sg,root,uiScale
local SB,FOOT,BAR=150,24,46
local function vp()   -- ขนาดจอในหน่วยของ root (หารซูมแล้ว)
    local a=sg.AbsoluteSize; local s=uiScale.Scale
    if not a or a.X<=0 then local cam=workspace.CurrentCamera local v=cam and cam.ViewportSize a=v or Vector2.new(1280,720) end
    return a.X/s,a.Y/s
end
function UI.applyScale(s)
    s=math.clamp(s,0.7,1.5); cfg.ui.scale=s; uiScale.Scale=s; root.Size=UDim2.new(1/s,0,1/s,0)
end
UI.applyScale(cfg.ui.scale)

local shadow=mk("Frame",{Name="Shadow",BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.78,BorderSizePixel=0,Size=UDim2.new(0,cfg.ui.w+12,0,cfg.ui.h+12),Position=UDim2.new(0,cfg.ui.x-6,0,cfg.ui.y-6)},root)
corner(shadow,19)
local win=mk("Frame",{Name="Window",BackgroundColor3=WHITE,BackgroundTransparency=cfg.ui.opacity,BorderSizePixel=0,Active=true,ClipsDescendants=true,
    Size=UDim2.new(0,cfg.ui.w,0,cfg.ui.h),Position=UDim2.new(0,cfg.ui.x,0,cfg.ui.y)},root)
corner(win,13); stroke(win,C.edge,0.4)
mk("UIGradient",{Color=ColorSequence.new(C.bgTop,C.bgBot),Rotation=90},win)
UI.win,UI.shadow=win,shadow
local function syncShadow()
    shadow.Position=UDim2.new(win.Position.X.Scale,win.Position.X.Offset-6,win.Position.Y.Scale,win.Position.Y.Offset-6)
    shadow.Size=UDim2.new(0,win.Size.X.Offset+12,0,win.Size.Y.Offset+12)
    shadow.Visible=win.Visible
end
UI.syncShadow=syncShadow
local function clampWin()
    local vx,vy=vp()
    local w=win.Size.X.Offset
    local x=math.clamp(win.Position.X.Offset,-(w-140),vx-140)
    local y=math.clamp(win.Position.Y.Offset,0,vy-BAR)
    win.Position=UDim2.new(0,x,0,y); cfg.ui.x=x; cfg.ui.y=y
end

-- เส้นไล่สีบนสุด
do
    local tb=mk("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=WHITE,BorderSizePixel=0,ZIndex=5},win)
    local g=agrad(tb); g.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.5),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,0.5)}
end
-- แถบหัว (ลากเพื่อย้าย)
local bar=mk("Frame",{Name="Bar",Size=UDim2.new(1,0,0,BAR),BackgroundTransparency=1,Active=true},win)
do
    local logo=mk("Frame",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,12,0,9),BackgroundColor3=C.accent2,BorderSizePixel=0,ClipsDescendants=true},bar); corner(logo,15); agrad(logo)
    UI.iconOrEmoji(logo,UI.gemIcon("Zenith"),"⛏",UDim2.new(0,4,0,4),UDim2.new(1,-8,1,-8),16)   -- พื้นหลัง = ไอคอนซีนิธ (fallback ⛏) ระหว่างรอโหลดไอคอนแมพ
    local gico=mk("ImageLabel",{Name="GameIcon",BackgroundTransparency=1,Image="",Size=UDim2.new(1,0,1,0),ZIndex=4},logo)   -- ไอคอนแมพจริงทับข้างบน
    local ti=lbl(bar,{Text="HZ HUB",Position=UDim2.new(0,50,0,6),Size=UDim2.new(0,110,0,22),TextSize=17,TextColor3=WHITE,Font=Enum.Font.GothamBlack}); agrad(ti)
    local sub=lbl(bar,{Text="Mine Antarctica · v6 PC",Position=UDim2.new(0,50,0,28),Size=UDim2.new(0,150,0,14),TextSize=10,TextColor3=C.dim})
    task.spawn(function()   -- ดึงไอคอน+ชื่อแมพจริงจาก MarketplaceService (วิธีเดียวกับ UI เก่า FishUI) — ไม่โหลด = โชว์ซีนิธต่อ
        local ok,info=pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
        if ok and info then
            if info.IconImageAssetId and info.IconImageAssetId>0 then gico.Image="rbxassetid://"..info.IconImageAssetId mk("UICorner",{CornerRadius=UDim.new(0.5,0)},gico) end
            if info.Name and info.Name~="" then sub.Text=info.Name.." · v6 PC" end
        end
    end)
end
-- ชิปสถานะ (ทำงานกี่ระบบ) — ย่อหน้าต่างแล้วโชว์สรุปแทน
local chipSt=mk("Frame",{Size=UDim2.new(0,128,0,24),Position=UDim2.new(0,208,0,11),BackgroundColor3=C.opt,BorderSizePixel=0},bar); corner(chipSt,12); stroke(chipSt,C.edge,0.7)
local chipLbl=lbl(chipSt,{Text="○ หยุดอยู่",Size=UDim2.new(1,0,1,0),TextSize=11,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Center})
UI.chipSt,UI.chipLbl=chipSt,chipLbl
local miniL=lbl(bar,{Text="",Position=UDim2.new(0,208,0,0),Size=UDim2.new(1,-208-120,1,0),TextSize=11,TextColor3=C.txt,Visible=false,TextTruncate=Enum.TextTruncate.AtEnd})
UI.mini=miniL
-- แถบสถานะลอย (โผล่ตอนซ่อนหน้าต่าง — ดูสถานะ AFK ได้โดยไม่ต้องเปิดหน้าต่าง · คลิก = เปิดหน้าต่างกลับ)
local pill=mk("TextButton",{Name="Pill",AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,46),Size=UDim2.new(0,0,0,26),AutomaticSize=Enum.AutomaticSize.X,
    BackgroundColor3=C.panel,BackgroundTransparency=0.1,BorderSizePixel=0,AutoButtonColor=false,Text="",TextSize=12,TextColor3=C.txt,Visible=false,ZIndex=120},root)
tfont(pill); corner(pill,13); stroke(pill,C.edge,0.45)
mk("UIPadding",{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)},pill)
UI.pill=pill
-- ปุ่มปิด/ย่อ
local closeB=btn(bar,{Name="CloseBtn",Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-36,0,9),BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(190,55,70),Text="×",TextSize=17,Font=Enum.Font.GothamBold})
corner(closeB,8); hoverFx(closeB,closeB,Color3.fromRGB(190,55,70),Color3.fromRGB(230,75,90))
local minB=btn(bar,{Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-70,0,9),BackgroundTransparency=0,BackgroundColor3=C.opt2,Text="–",TextSize=16})
corner(minB,8); hoverFx(minB,minB,C.opt2,C.optH)
-- ช่องค้นหา
local qBox=mk("Frame",{Size=UDim2.new(0,180,0,26),Position=UDim2.new(1,-70-180-8,0,10),BackgroundColor3=C.opt,BorderSizePixel=0},bar); corner(qBox,8); stroke(qBox,C.edge,0.75)
lbl(qBox,{Text="🔍",Position=UDim2.new(0,7,0,0),Size=UDim2.new(0,18,1,0),TextSize=12,TextColor3=C.dim})
local q=mk("TextBox",{Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,26,0,0),BackgroundTransparency=1,Text="",PlaceholderText="ค้นหาฟีเจอร์…  (Ctrl+F)",PlaceholderColor3=C.dim,
    TextSize=11,TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,BorderSizePixel=0},qBox); tfont(q)
local qClr=btn(qBox,{Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-23,0.5,-10),Text="×",TextSize=13,TextColor3=C.dim,Visible=false})
UI.q,UI.qClr=q,qClr
-- เส้นคั่นใต้แถบหัว
mk("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,BAR),BackgroundColor3=C.line,BackgroundTransparency=0.3,BorderSizePixel=0},win)

-- แถบข้าง (แท็บ)
local side=mk("Frame",{Name="Side",Size=UDim2.new(0,SB,1,-BAR-1-FOOT),Position=UDim2.new(0,0,0,BAR+1),BackgroundColor3=C.side,BackgroundTransparency=0.2,BorderSizePixel=0},win)
mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},side)
mk("UIPadding",{PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},side)
mk("Frame",{Size=UDim2.new(0,1,1,-BAR-1-FOOT),Position=UDim2.new(0,SB,0,BAR+1),BackgroundColor3=C.line,BackgroundTransparency=0.4,BorderSizePixel=0},win)
local content=mk("Frame",{Name="Content",Size=UDim2.new(1,-SB-1,1,-BAR-1-FOOT),Position=UDim2.new(0,SB+1,0,BAR+1),BackgroundTransparency=1,ClipsDescendants=true},win)
local foot=mk("Frame",{Name="Foot",Size=UDim2.new(1,0,0,FOOT),Position=UDim2.new(0,0,1,-FOOT),BackgroundColor3=C.side,BackgroundTransparency=0.1,BorderSizePixel=0},win)
local footL=lbl(foot,{Text="",Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-190,1,0),TextSize=10,TextColor3=C.dim,TextTruncate=Enum.TextTruncate.AtEnd})
local footR=lbl(foot,{Text="",Position=UDim2.new(1,-170,0,0),Size=UDim2.new(0,150,1,0),TextSize=10,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right})
local grip=btn(win,{Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-20,1,-20),Text="◢",TextSize=11,TextColor3=C.dim,ZIndex=20})
UI.side,UI.content,UI.foot,UI.footL,UI.footR,UI.grip=side,content,foot,footL,footR,grip

-- ลาก/ปรับขนาด (หาร scale — i.Position เป็นพิกเซลจอ)
local drag,rsz
local function isDown(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
local lastClk=0
bar.InputBegan:Connect(function(i)
    if not isDown(i) then return end
    local now=os.clock()
    if now-lastClk<0.35 then lastClk=0 UI.fold(not UI.folded) return end   -- ดับเบิลคลิกหัวหน้าต่าง = ย่อ/ขยาย
    lastClk=now
    drag={m=i.Position,x=win.Position.X.Offset,y=win.Position.Y.Offset}
end)
grip.InputBegan:Connect(function(i) if isDown(i) then rsz={m=i.Position,w=win.Size.X.Offset,h=win.Size.Y.Offset} end end)
guard(UIS.InputChanged,function(i)
    if not (drag or rsz) then return end
    if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
    local s=uiScale.Scale
    if drag then
        local d=(i.Position-drag.m)/s
        win.Position=UDim2.new(0,drag.x+d.X,0,drag.y+d.Y); clampWin(); syncShadow()
    elseif rsz then
        local d=(i.Position-rsz.m)/s
        local vx,vy=vp()
        local w=math.clamp(rsz.w+d.X,560,math.min(1400,vx-win.Position.X.Offset))
        local h=math.clamp(rsz.h+d.Y,400,math.min(1000,vy-win.Position.Y.Offset))
        win.Size=UDim2.new(0,w,0,h); cfg.ui.w=w; cfg.ui.h=h; syncShadow()
    end
end)
guard(UIS.InputEnded,function(i) if (drag or rsz) and isDown(i) then drag=nil rsz=nil UI.dirty() end end)

function UI.show(v)
    win.Visible=v and true or false; syncShadow()
    pill.Visible=(not win.Visible) and cfg.ui.pill~=false
    if not v then UI.tipObj=nil end
end
pill.Activated:Connect(function() sfx("tick") UI.show(true) end)
function UI.fold(v)
    UI.folded=v and true or false
    side.Visible=not UI.folded; content.Visible=not UI.folded; foot.Visible=not UI.folded; grip.Visible=not UI.folded
    chipSt.Visible=not UI.folded; miniL.Visible=UI.folded; qBox.Visible=not UI.folded
    minB.Text=UI.folded and "+" or "–"
    local h=UI.folded and BAR or cfg.ui.h
    tw(win,0.16,{Size=UDim2.new(0,cfg.ui.w,0,h)})
    tw(shadow,0.16,{Size=UDim2.new(0,cfg.ui.w+12,0,h+12)})
end
minB.Activated:Connect(function() sfx("tick") UI.fold(not UI.folded) end)
closeB.Activated:Connect(function()
    sfx("tick")
    pcall(UI.save)
    G.__HZMINE=G.__HZMINE+1   -- ✕ = ปิดสคริปต์จริง: ฆ่า generation → ทุก loop/hook หยุด (รันใหม่ได้ปกติ)
    sg:Destroy() esp:Destroy()
    pcall(function() ghostParent:Destroy() end)
    pcall(function() farFolder:Destroy() end)
    slog("closed+killed")
end)
UI.kill=function() closeB.Activated:Fire() end

-- ───────── tooltip ─────────
local tipF=mk("Frame",{Name="Tip",Visible=false,BackgroundColor3=Color3.fromRGB(8,9,18),BackgroundTransparency=0.04,BorderSizePixel=0,ZIndex=200,
    AutomaticSize=Enum.AutomaticSize.XY,Size=UDim2.new(0,0,0,0)},root)
corner(tipF,7); stroke(tipF,C.edge,0.35)
mk("UIPadding",{PaddingLeft=UDim.new(0,9),PaddingRight=UDim.new(0,9),PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6)},tipF)
local tipL=lbl(tipF,{Text="",TextSize=11,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.XY,Size=UDim2.new(0,0,0,0),ZIndex=201})
mk("UISizeConstraint",{MaxSize=Vector2.new(300,500)},tipL)
function UI.tip(o,text)
    if not text or text=="" then return end
    o.MouseEnter:Connect(function() UI.tipObj=o UI.tipText=text UI.tipT=os.clock()+0.45 end)
    o.MouseLeave:Connect(function() if UI.tipObj==o then UI.tipObj=nil end end)
end
task.spawn(function()
    while alive() do
        task.wait(0.07)
        local o=UI.tipObj
        if o and win.Visible then
            local now=os.clock()
            if not tipF.Visible and now>=UI.tipT then
                tipL.Text=UI.tipText; tipF.Visible=true; UI.tipShown=now
            end
            if tipF.Visible then
                local m=UIS:GetMouseLocation(); local s=uiScale.Scale
                local ap=root.AbsolutePosition or Vector2.new(0,0)
                local sz=tipF.AbsoluteSize or Vector2.new(200,40)
                local vx,vy=vp()
                local x=math.clamp((m.X-ap.X)/s+16,4,math.max(4,vx-sz.X/s-6))
                local y=(m.Y-ap.Y)/s+20
                if y+sz.Y/s>vy-6 then y=(m.Y-ap.Y)/s-sz.Y/s-10 end
                tipF.Position=UDim2.new(0,x,0,math.max(4,y))
                if now-UI.tipShown>12 then UI.tipObj=nil end
            end
        elseif tipF.Visible then tipF.Visible=false end
    end
end)

-- ───────── toast + บันทึกกิจกรรม ─────────
local toastBox=mk("Frame",{Name="Toasts",BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,54),Size=UDim2.new(0,310,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=150},root)
mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Right},toastBox)
UI.toasts={}; UI.toastN=0
function UI.toast(text,col)
    if not cfg.ui.toast then return end
    UI.toastN+=1
    col=col or C.accent
    local t=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.panel,BackgroundTransparency=0.06,BorderSizePixel=0,LayoutOrder=-UI.toastN,ZIndex=151},toastBox)
    corner(t,8); stroke(t,col,0.45)
    mk("Frame",{Size=UDim2.new(0,4,1,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=152},t)
    local body=mk("Frame",{Size=UDim2.new(1,-14,0,0),Position=UDim2.new(0,12,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,ZIndex=152},t)
    mk("UIPadding",{PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,7),PaddingRight=UDim.new(0,6)},body)
    local l=lbl(body,{Text=tostring(text),TextSize=12,TextWrapped=true,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=153})
    local list=UI.toasts; list[#list+1]=t
    while #list>4 do local o=table.remove(list,1) pcall(function() o:Destroy() end) end
    local hit=btn(t,{Size=UDim2.new(1,0,1,0),ZIndex=154}); hit.Activated:Connect(function() pcall(function() t:Destroy() end) end)
    task.delay(4.5,function()
        if not t.Parent then return end
        tw(t,0.35,{BackgroundTransparency=1}) tw(l,0.35,{TextTransparency=1})
        task.delay(0.4,function() pcall(function() t:Destroy() end) end)
    end)
end
local TOAST_PAT={"🆕","❌","⚠","⛔","🥶","🌱 พา","🌱 ลงสวน","🔄","💰 ขาย","⬆","⛏ ซื้อ","⛏ ใส่","🧪","🎯","☄","💥","⭐ ดาวตก","🏔","📡 เรด้า","🛡","💡","📏","🌦"}
local function wantToast(s) for _,p in ipairs(TOAST_PAT) do if s:find(p,1,true) then return true end end return false end
UI.logs={}
feedAdd=function(txt,a,b)   -- รับทั้ง (txt,สี) และ (txt,วินาที,สี) — signature เดิม
    if not alive() then return end   -- generation ตายแล้ว (กดปิด/รันซ้ำ) UI ถูกทำลาย → ห้ามสร้าง toast/บรรทัดใหม่ (Parent ถูกล็อก)
    txt=tostring(txt)
    local col=typeof(a)=="Color3" and a or (typeof(b)=="Color3" and b) or nil
    local nowF=os.clock()
    if txt==PK.lastFeed and nowF-(PK.lastFeedT or 0)<8 then return end   -- ข้อความเดิมซ้ำใน 8s = ไม่ต่อบรรทัดใหม่
    PK.lastFeed=txt; PK.lastFeedT=nowF
    local e={t=os.date("%H:%M:%S"),s=txt,c=col}
    local L=UI.logs; L[#L+1]=e; if #L>150 then table.remove(L,1) end
    if UI.logRender then UI.logRender(e) end
    if wantToast(txt) then UI.toast(txt,col) end
end

-- ───────── ส่วนประกอบ (สวิตช์ · แถวตัวเลือก · ชิปเลือกระดับ · ปุ่ม · สไลเดอร์ · การ์ด) ─────────
local function mkSwitch(parent,w,h,get,pos)
    local pad=2; local k=h-pad*2
    local pill=mk("Frame",{Size=UDim2.new(0,w,0,h),AnchorPoint=Vector2.new(1,0.5),Position=pos,BackgroundColor3=C.off,BorderSizePixel=0},parent); corner(pill,h/2); stroke(pill,Color3.new(0,0,0),0.7)
    local kn=mk("Frame",{Size=UDim2.new(0,k,0,k),BackgroundColor3=WHITE,BorderSizePixel=0,Position=UDim2.new(0,pad,0.5,-k/2)},pill); corner(kn,k/2)
    local last
    local function paint(instant)
        local on=get() and true or false
        if on==last then return end
        last=on
        local p=on and UDim2.new(1,-(k+pad),0.5,-k/2) or UDim2.new(0,pad,0.5,-k/2)
        local c=on and C.on or C.off
        if instant==true then pill.BackgroundColor3=c kn.Position=p else tw(pill,0.14,{BackgroundColor3=c}) tw(kn,0.14,{Position=p}) end
    end
    paint(true)
    UI.paints[#UI.paints+1]=paint
    return paint,pill
end
UI.mkSwitch=mkSwitch

function UI.toggleRow(parent,text,get,set,tip,after,img)   -- img=rbxassetid ไอคอนเกมจริงหน้าข้อความ (ไม่บังเมื่อไม่มี)
    local r=mk("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=C.opt,BorderSizePixel=0,LayoutOrder=nxt(parent)},parent); corner(r,7)
    local tx=10
    if img then mk("ImageLabel",{BackgroundTransparency=1,Image=img,Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,8,0.5,-9),ZIndex=2},r) tx=32 end
    local l=lbl(r,{Text=text,Position=UDim2.new(0,tx,0,0),Size=UDim2.new(1,-tx-52,1,0),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd})
    local paint=mkSwitch(r,34,18,get,UDim2.new(1,-8,0.5,0))
    local h=btn(r,{Size=UDim2.new(1,0,1,0)})
    hoverFx(h,r,C.opt,C.optH)
    h.Activated:Connect(function() local v=not get() set(v) sfx("tick") UI.syncAll() if after then pcall(after,v) end UI.dirty() end)
    UI.tip(h,tip)
    local c=UI.curCard; if c then local t=text:lower() c.kw=c.kw.." "..t c.okw=c.okw.." "..t end
    return l,paint,r
end
function UI.opt(parent,text,key,onFlip,tip,img)   -- แถวตัวเลือก ผูก cfg.sub[key] — คืน label (ให้ logic อัปเดตข้อความสด เช่นสต็อกเรด้า) · img=ไอคอนเกมจริง
    return UI.toggleRow(parent,text,function() return cfg.sub[key] end,function(v) cfg.sub[key]=v end,tip,onFlip,img)
end
function UI.note(parent,text,col)
    return lbl(parent,{Text=text,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextSize=11,TextColor3=col or C.dim,LayoutOrder=nxt(parent)})
end
function UI.group(parent,title)
    local g=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.opt,BorderSizePixel=0,LayoutOrder=nxt(parent)},parent); corner(g,8)
    mk("UIPadding",{PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,9),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},g)
    mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},g)
    if title then
        lbl(g,{Text=title,Size=UDim2.new(1,0,0,14),TextSize=11,TextColor3=C.dim,LayoutOrder=nxt(g)})
        local c=UI.curCard; if c then c.kw=c.kw.." "..title:lower() c.okw=c.okw.." "..title:lower() end
    end
    return g
end
function UI.grid(parent,cols,h,pad)
    pad=pad or 8
    local g=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=nxt(parent)},parent)
    local lay=mk("UIGridLayout",{CellSize=UDim2.new(1/cols,-math.ceil(pad*(cols-1)/cols),0,h),CellPadding=UDim2.new(0,pad,0,pad),SortOrder=Enum.SortOrder.LayoutOrder},g)
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()   -- กันพลาด: ถ้า AutomaticSize ใช้กับกริดไม่ได้ ให้ตั้งความสูงจากเนื้อหาเอง
        local y=lay.AbsoluteContentSize.Y
        if y>0 then g.Size=UDim2.new(1,0,0,y) end
    end)
    return g
end
function UI.chips(parent,items,get,set,cols,h)   -- items={{ข้อความ,สี},..} · เลือก 1 ใน N (index) · วางเป็นกริด
    local box=UI.grid(parent,cols or 4,h or 26,6)
    local bs={}
    for i,it in ipairs(items) do
        local b=btn(box,{BackgroundTransparency=0,BackgroundColor3=C.panel,Text=it[1],TextSize=11,LayoutOrder=i,TextColor3=it[2] or C.txt}); corner(b,7)
        if it[3] then   -- it[3]=rbxassetid ไอคอนเกมจริง (ชิดซ้าย ข้อความขยับ)
            b.TextXAlignment=Enum.TextXAlignment.Left
            mk("UIPadding",{PaddingLeft=UDim.new(0,24)},b)
            mk("ImageLabel",{BackgroundTransparency=1,Image=it[3],Size=UDim2.new(0,15,0,15),Position=UDim2.new(0,5,0.5,-7),ZIndex=2},b)
        end
        local st=stroke(b,it[2] or C.accent,1); st.Thickness=1.5
        b.Activated:Connect(function() set(i) sfx("tick") UI.syncAll() UI.dirty() end)
        bs[i]={b=b,st=st}
    end
    local function paint()
        local cur=get()
        for i,x in ipairs(bs) do
            local on=(i==cur); local col=items[i][2] or C.accent
            x.b.BackgroundColor3=on and col or C.panel; x.b.BackgroundTransparency=on and 0.72 or 0
            x.st.Transparency=on and 0.05 or 0.85
            x.b.TextColor3=on and WHITE or (items[i][2] or C.txt)
        end
    end
    UI.paints[#UI.paints+1]=paint; paint()
    return box,paint
end
function UI.button(parent,text,col,cb,tip,h)
    local base=col or C.opt2
    local b=btn(parent,{Size=UDim2.new(1,0,0,h or 30),BackgroundTransparency=0,BackgroundColor3=base,Text=text,TextSize=12,LayoutOrder=nxt(parent)})
    corner(b,8); stroke(b,C.edge,0.8)
    hoverFx(b,b,base,Color3.new(math.min(1,base.R+0.07),math.min(1,base.G+0.07),math.min(1,base.B+0.07)))
    b.Activated:Connect(function() sfx("tick") cb(b) end)
    UI.tip(b,tip)
    return b
end
function UI.row2(parent,h)   -- แถวปุ่มคู่ (ซ้าย/ขวา เท่ากัน)
    local r=mk("Frame",{Size=UDim2.new(1,0,0,h or 30),BackgroundTransparency=1,LayoutOrder=nxt(parent)},parent)
    mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},r)
    return r
end
function UI.half(row,text,col,cb,tip)   -- ปุ่มครึ่งแถวใน row2
    local base=col or C.opt2
    local b=btn(row,{Size=UDim2.new(0.5,-4,1,0),BackgroundTransparency=0,BackgroundColor3=base,Text=text,TextSize=11,LayoutOrder=nxt(row)})
    corner(b,8); stroke(b,C.edge,0.8)
    hoverFx(b,b,base,Color3.new(math.min(1,base.R+0.07),math.min(1,base.G+0.07),math.min(1,base.B+0.07)))
    b.Activated:Connect(function() sfx("tick") cb(b) end)
    UI.tip(b,tip)
    return b
end
function UI.confirmButton(parent,text,col,cb,tip)   -- กดครั้งแรก = ขอยืนยัน (3 วิ) กันกดพลาด
    local b; local armed=false
    b=UI.button(parent,text,col,function()
        if not armed then armed=true b.Text="⚠ กดอีกครั้งเพื่อยืนยัน" task.delay(3,function() if armed then armed=false b.Text=text end end) return end
        armed=false b.Text=text cb()
    end,tip)
    return b
end
function UI.slider(parent,title,min,max,get,set,fmt,after,deferApply)   -- deferApply: ลากแค่โชว์ค่า แล้วค่อยใช้ตอนปล่อยเมาส์ (ซูมเปลี่ยนเลย์เอาต์ ถ้าใช้ระหว่างลากรางจะวิ่งหนีเมาส์)
    local row=mk("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.opt,BorderSizePixel=0,LayoutOrder=nxt(parent)},parent); corner(row,8)
    lbl(row,{Text=title,Position=UDim2.new(0,10,0,5),Size=UDim2.new(0.6,-10,0,16),TextSize=11})
    local vl=lbl(row,{Text="",Position=UDim2.new(0.6,0,0,5),Size=UDim2.new(0.4,-10,0,16),TextSize=11,TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Right})
    local track=mk("Frame",{Size=UDim2.new(1,-20,0,6),Position=UDim2.new(0,10,0,29),BackgroundColor3=C.off,BorderSizePixel=0},row); corner(track,3)
    local fill=mk("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.accent,BorderSizePixel=0},track); corner(fill,3)
    local kn=mk("Frame",{Size=UDim2.new(0,14,0,14),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=WHITE,BorderSizePixel=0,ZIndex=2},track); corner(kn,7)
    local pending
    local function paint()
        local v=pending or get(); local a=math.clamp((v-min)/(max-min),0,1)
        fill.Size=UDim2.new(a,0,1,0); kn.Position=UDim2.new(a,0,0.5,0); vl.Text=fmt and fmt(v) or tostring(v)
    end
    local hit=btn(row,{Size=UDim2.new(1,-10,0,26),Position=UDim2.new(0,5,0,20)})
    UI.sliders=UI.sliders or {}; UI.sliders[title]={hit=hit,track=track,min=min,max=max}
    local dragging=false
    local function setX(x)
        local ap=track.AbsolutePosition; local as=track.AbsoluteSize
        if not ap or not as or as.X<=0 then return end
        local a=math.clamp((x-ap.X)/as.X,0,1)
        local val=min+(max-min)*a
        if deferApply then pending=val else set(val) end
        paint()
        if after then pcall(after) end
    end
    hit.InputBegan:Connect(function(i) if isDown(i) then dragging=true setX(i.Position.X) end end)
    guard(UIS.InputChanged,function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setX(i.Position.X) end end)
    guard(UIS.InputEnded,function(i)
        if dragging and isDown(i) then
            dragging=false
            if pending then local v=pending pending=nil set(v) paint() end
            UI.dirty()
        end
    end)
    paint(); UI.paints[#UI.paints+1]=paint
    local c=UI.curCard; if c then c.kw=c.kw.." "..title:lower() c.okw=c.okw.." "..title:lower() end
    return paint,row
end
function UI.section(page,text)
    local s=mk("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=nxt(page)},page)
    local b=mk("Frame",{Size=UDim2.new(0,3,0,13),Position=UDim2.new(0,2,0.5,-6),BackgroundColor3=C.accent,BorderSizePixel=0},s); corner(b,2)
    lbl(s,{Text=text,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-12,1,0),TextSize=12,TextColor3=Color3.fromRGB(176,184,214)})
    return s
end
function UI.pageHead(page,icon,title,desc)
    local h=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=nxt(page)},page)
    mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},h)
    lbl(h,{Text=icon.." "..title,Size=UDim2.new(1,0,0,24),TextSize=16,LayoutOrder=1})
    lbl(h,{Text=desc,Size=UDim2.new(1,0,0,16),TextSize=11,TextColor3=C.dim,LayoutOrder=2})
end

-- การ์ดฟีเจอร์: หัว(ไอคอน+ชื่อ+คำอธิบาย+ปุ่มลัด+ลูกศรกาง+สวิตช์) + พื้นที่ตัวเลือกย่อย (กาง/พับ จำค่าไว้)
function UI.card(page,s)
    local c={id=s.id,page=page,kw=((s.title or "").." "..(s.desc or "").." "..(s.kw or "")):lower(),okw=""}
    local fr=mk("Frame",{Name="Card_"..s.id,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.row,BorderSizePixel=0,LayoutOrder=nxt(page)},page)
    corner(fr,10); stroke(fr,C.edge,0.82)
    mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},fr)
    local H=s.desc and 56 or 44
    local head=mk("Frame",{Size=UDim2.new(1,0,0,H),BackgroundTransparency=1,LayoutOrder=1},fr)
    local col=s.col or C.accent
    local ic=mk("Frame",{Size=UDim2.new(0,32,0,32),Position=UDim2.new(0,10,0.5,-16),BackgroundColor3=col,BackgroundTransparency=0.82,BorderSizePixel=0},head); corner(ic,9); stroke(ic,col,0.55)
    UI.iconOrEmoji(ic,s.iconImg,s.icon or "•",UDim2.new(0,4,0,4),UDim2.new(1,-8,1,-8),16)   -- iconImg=rbxassetid ไอคอนเกมจริง (fallback emoji)
    local swW=s.get and 52 or 0
    local chW=s.subs and 32 or 0
    local kbW=s.act and 36 or 0
    local rightW=8+swW+chW+kbW
    local title=lbl(head,{Text=s.title,Position=UDim2.new(0,52,0,s.desc and 8 or 0),Size=UDim2.new(1,-52-rightW,0,s.desc and 20 or H),TextSize=14,TextTruncate=Enum.TextTruncate.AtEnd})
    local desc=s.desc and lbl(head,{Text=s.desc,Position=UDim2.new(0,52,0,29),Size=UDim2.new(1,-52-rightW,0,18),TextSize=11,TextColor3=C.dim,TextTruncate=Enum.TextTruncate.AtEnd}) or nil
    local hit=btn(head,{Size=UDim2.new(1,0,1,0),ZIndex=1})
    hoverFx(hit,fr,C.row,C.rowH)
    if s.get then mkSwitch(head,42,22,s.get,UDim2.new(1,-10,0.5,0)) end
    local chev
    if s.subs then
        chev=btn(head,{Size=UDim2.new(0,26,0,26),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-(10+swW),0.5,0),BackgroundTransparency=0,BackgroundColor3=C.opt2,
            Text=">",TextSize=13,TextColor3=C.dim,ZIndex=3}); corner(chev,7)
        UI.tip(chev,"ตัวเลือกเพิ่มเติม — คลิกเพื่อกาง/พับ (จำค่าไว้)")
    end
    local kb
    if s.act then
        kb=lbl(head,{Text="",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-(10+swW+chW),0.5,0),Size=UDim2.new(0,30,0,18),TextSize=10,TextColor3=C.dim,BackgroundTransparency=0,
            BackgroundColor3=C.opt2,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=3}); corner(kb,5)
    end
    local sub
    if s.subs then
        sub=mk("Frame",{Name="Sub",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=2,Visible=false},fr)
        mk("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},sub)
        mk("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,10)},sub)
        UI.curCard=c; s.subs(sub,c); UI.curCard=nil
    end
    c.frame=fr; c.home=page; c.ord=fr.LayoutOrder; c.title=title; c.descL=desc; c.sub=sub; c.head=head
    function c.setOpen(v,temp)
        if not sub then return end
        v=v and true or false
        sub.Visible=v; chev.Rotation=v and 90 or 0; chev.TextColor3=v and C.accent or C.dim
        if not temp then cfg.ui.open[s.id]=v or nil UI.dirty() end
    end
    function c.keyUpd()
        local k=s.act and UI.keyOf(s.act)
        if kb then kb.Text=k or "" kb.Visible=k~=nil end
        c.tipText=(s.tip or (s.title..(s.desc and (" — "..s.desc) or "")))..(k and ("\nปุ่มลัด: "..k) or "")
    end
    c.keyUpd()
    hit.MouseEnter:Connect(function() UI.tipObj=hit UI.tipText=c.tipText UI.tipT=os.clock()+0.5 end)
    hit.MouseLeave:Connect(function() if UI.tipObj==hit then UI.tipObj=nil end end)
    hit.Activated:Connect(function()
        if s.get then
            if UI.mBy[s.id] then UI.setM(s.id)
            else s.set(not s.get()) sfx("pop") UI.syncAll() UI.dirty() end
        elseif sub then c.setOpen(not sub.Visible) sfx("tick") end
    end)
    if chev then chev.Activated:Connect(function() c.setOpen(not sub.Visible) sfx("tick") end) end
    if sub and (cfg.ui.open[s.id] or (s.open and cfg.ui.open[s.id]==nil)) then c.setOpen(true,true) end
    UI.cards[#UI.cards+1]=c
    return c
end

-- ───────── แท็บ ─────────
local function makePage(id)
    local page=mk("ScrollingFrame",{Name="Page_"..id,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,ScrollBarImageColor3=C.accent,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false},content)
    mk("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,16),PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,14)},page)
    mk("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},page)
    return page
end
local function addTab(id,icon,name,tip)
    local page=makePage(id)
    local b=btn(side,{Size=UDim2.new(1,0,0,38),LayoutOrder=#UI.tabList+1,BackgroundTransparency=1,BackgroundColor3=C.rowH}); corner(b,9)
    local ind=mk("Frame",{Size=UDim2.new(0,3,0,20),Position=UDim2.new(0,0,0.5,-10),BackgroundColor3=C.accent,BorderSizePixel=0,Visible=false},b); corner(ind,2)
    lbl(b,{Text=icon,Position=UDim2.new(0,10,0,0),Size=UDim2.new(0,24,1,0),TextSize=16,TextXAlignment=Enum.TextXAlignment.Center})
    local nl=lbl(b,{Text=name,Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,-72,1,0),TextSize=12,TextColor3=C.dim,TextTruncate=Enum.TextTruncate.AtEnd})
    local badge=mk("Frame",{Size=UDim2.new(0,20,0,16),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),BackgroundColor3=C.on,BorderSizePixel=0,Visible=false},b); corner(badge,8)
    local bl=lbl(badge,{Text="0",Size=UDim2.new(1,0,1,0),TextSize=10,TextColor3=Color3.fromRGB(8,30,18),TextXAlignment=Enum.TextXAlignment.Center})
    local t={id=id,page=page,btn=b,ind=ind,name=nl,badge=badge,badgeL=bl}
    UI.tabList[#UI.tabList+1]=t; UI.tabBy[id]=t
    b.MouseEnter:Connect(function() if UI.curTab~=id or UI.searching then tw(b,0.1,{BackgroundTransparency=0.7}) end end)
    b.MouseLeave:Connect(function() if UI.curTab~=id or UI.searching then tw(b,0.12,{BackgroundTransparency=1}) end end)
    b.Activated:Connect(function() sfx("tick") if UI.searching then q.Text="" UI.search("") end UI.go(id) end)
    UI.tip(b,tip)
    return page
end
UI.resPage=makePage("search"); UI.resPage.Name="Page_search"
UI.resNote=lbl(UI.resPage,{Text="",Size=UDim2.new(1,0,0,18),TextSize=11,TextColor3=C.accent,LayoutOrder=1})
function UI.go(id)
    local t=UI.tabBy[id] or UI.tabBy.dash
    if UI.capturing then UI.capturing.restore() UI.capturing=nil end
    UI.curTab=t.id; cfg.ui.tab=t.id; UI.tipObj=nil; UI.resPage.Visible=false
    if UI.last and UI.hud then UI.hud(UI.last) end   -- เปลี่ยนแท็บแล้วอัปเดตตัวเลขทันที ไม่ต้องรอรอบถัดไป
    for _,x in ipairs(UI.tabList) do
        local on=(x==t)
        x.page.Visible=on; x.ind.Visible=on
        x.btn.BackgroundTransparency=on and 0.3 or 1
        x.name.TextColor3=on and C.txt or C.dim
    end
    UI.dirty()
end

-- ───────── ค้นหา: ย้ายการ์ดที่ตรงมาไว้หน้า "ผลค้นหา" (ยังกดใช้ได้ปกติ) · ล้างคำค้น = คืนที่เดิม ─────────
function UI.search(text)
    local qs=trim(text):lower()
    if qs=="" then
        if UI.searching then
            for _,c in ipairs(UI.cards) do
                if c.frame.Parent==UI.resPage then c.frame.Parent=c.home c.frame.LayoutOrder=c.ord end
                c.setOpen(cfg.ui.open[c.id]==true,true)
            end
            UI.searching=false
            UI.go(UI.prevTab or cfg.ui.tab)
        end
        UI.qClr.Visible=false
        return
    end
    UI.qClr.Visible=true
    if not UI.searching then UI.searching=true UI.prevTab=UI.curTab end
    local n=0
    for _,c in ipairs(UI.cards) do
        if c.kw:find(qs,1,true) then
            n+=1; c.frame.Parent=UI.resPage; c.frame.LayoutOrder=n+1
            c.setOpen(c.okw:find(qs,1,true)~=nil,true)
        elseif c.frame.Parent==UI.resPage then
            c.frame.Parent=c.home; c.frame.LayoutOrder=c.ord; c.setOpen(cfg.ui.open[c.id]==true,true)
        end
    end
    UI.resNote.Text=n>0 and ("พบ "..n.." รายการที่ตรงกับ \""..trim(text).."\"") or ("ไม่พบ \""..trim(text).."\" — ลองคำอื่น เช่น ขุด / ขาย / เรด้า / ปุ่มลัด")
    for _,x in ipairs(UI.tabList) do x.page.Visible=false x.ind.Visible=false x.btn.BackgroundTransparency=1 x.name.TextColor3=C.dim end
    UI.resPage.Visible=true; UI.tipObj=nil
end
q:GetPropertyChangedSignal("Text"):Connect(function() UI.search(q.Text) end)
qClr.Activated:Connect(function() q.Text="" UI.search("") end)

-- ───────── สถานะรวม (ชิปหัว · ป้ายแท็บ · สรุปตอนย่อ) ─────────
function UI.updMini()
    local ic={}
    for _,m in ipairs(UI.M) do if m.get() and m.tab~="radar" and m.tab~="world" or (m.id=="radClone" and m.get()) then ic[#ic+1]=m.icon end end
    local h=UI.last
    local money=h and ("  💰 $"..comma(h.coins)) or ""
    local hr=(h and h.hrate and h.hrate>0) and string.format("  ⚔ %.1f/วิ",h.hrate) or ""
    local sumTxt=(#ic>0 and table.concat(ic," ") or "○ หยุดอยู่")
    miniL.Text=sumTxt..money..hr
    if pill.Visible then
        local pct=(h and h.cap and h.cap>0) and string.format("  🎒 %d%%",math.floor(h.bag/h.cap*100)) or ""
        pill.Text="HZ  "..sumTxt..money..pct..hr
    end
end
function UI.syncAll()
    for _,p in ipairs(UI.paints) do p() end
    local per={}
    for _,m in ipairs(UI.M) do if m.get() then per[m.tab]=(per[m.tab] or 0)+1 end end
    for _,t in ipairs(UI.tabList) do local n=per[t.id] or 0 t.badge.Visible=n>0 t.badgeL.Text=tostring(n) end
    local n=activeCount()
    chipLbl.Text=n>0 and ("● ทำงาน "..n.." ระบบ") or "○ หยุดอยู่"
    chipLbl.TextColor3=n>0 and C.on or C.dim
    UI.updMini()
end

-- ───────── ตัวช่วยสร้างรายการระดับ/ขนาด (สี+ชื่อไทยตามเกม) ─────────
local function tierItems()
    local t={} for i,n in ipairs(TIERS) do t[i]={PK.thR(n),TCOL[n],UI.gemIcon(n)} end return t
end
local function sizeItems()
    local t={} for i,n in ipairs(PK.SIZETH) do t[i]={n,C.accent} end return t
end

-- ═════════════ 📊 ภาพรวม ═════════════
local P=addTab("dash","📊","ภาพรวม","สถานะสด · สวิตช์ด่วน · บันทึกกิจกรรม")
UI.pageHead(P,"📊","ภาพรวม","สถานะสดของตัวละคร · สวิตช์ด่วน · บันทึกกิจกรรม")
do
    local r=UI.row2(P,34)
    UI.half(r,"⛔ หยุดทุกระบบ",Color3.fromRGB(150,45,60),function() UI.panic() end,"ปิดสวิตช์ที่ลงมือทำทั้งหมด (ขุด/เก็บ/ขาย/อัพ/สวน/ตัวเรา/สอยเรด้า/เรด้าฟรี) — ปุ่มลัดฉุกเฉิน")
    UI.half(r,"▶ เปิดชุดฟาร์ม (ขุด+เก็บ+ขาย)",C.buy,function() UI.farmOn() end,"เปิด ขุดออโต้+ตีแรร์ / เก็บแรร์ออโต้ / ขายออโต้ พร้อมกันในคลิกเดียว")
end
UI.section(P,"สวิตช์ด่วน — คลิก หรือกดปุ่มลัด")
do
    local g=UI.grid(P,4,48,8)
    for i,id in ipairs({"autodig","autocollect","autosell","autoup","garden","esp","selfOn","radarSnipe","bombSnipe","bombAuto","fusion","halloween"}) do
        local m=UI.mBy[id]
        local t=mk("Frame",{BackgroundColor3=C.row,BorderSizePixel=0,LayoutOrder=i},g); corner(t,10)
        local st=stroke(t,C.edge,0.8)
        lbl(t,{Text=m.icon,Position=UDim2.new(0,8,0,0),Size=UDim2.new(0,28,1,0),TextSize=20,TextXAlignment=Enum.TextXAlignment.Center})
        lbl(t,{Text=m.short or m.name,Position=UDim2.new(0,40,0,7),Size=UDim2.new(1,-44,0,16),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd})
        local sl=lbl(t,{Text="ปิด",Position=UDim2.new(0,40,0,25),Size=UDim2.new(1,-44,0,14),TextSize=10,TextColor3=C.dim,TextTruncate=Enum.TextTruncate.AtEnd})
        local h=btn(t,{Size=UDim2.new(1,0,1,0)})
        h.Activated:Connect(function() UI.setM(id) end)
        h.MouseEnter:Connect(function() UI.tipObj=h UI.tipText=m.name.." — "..m.desc..(UI.keyOf(id) and ("\nปุ่มลัด: "..UI.keyOf(id)) or "") UI.tipT=os.clock()+0.5 end)
        h.MouseLeave:Connect(function() if UI.tipObj==h then UI.tipObj=nil end end)
        UI.paints[#UI.paints+1]=function()
            local on=m.get() and true or false
            local k=UI.keyOf(id)
            sl.Text=(on and "● เปิด" or "○ ปิด")..(k and ("  "..k) or "")
            sl.TextColor3=on and C.on or C.dim
            st.Color=on and C.on or C.edge; st.Transparency=on and 0.25 or 0.8
            t.BackgroundColor3=on and C.rowH or C.row
        end
    end
end

UI.section(P,"สถานะตอนนี้")
UI.w={}
do
    local g=UI.grid(P,3,64,8)
    local function tile(i,key,icon,title,bar,img)   -- img=rbxassetid ไอคอนเกมจริงแทน emoji
        local t=mk("Frame",{BackgroundColor3=C.row,BorderSizePixel=0,LayoutOrder=i},g); corner(t,10); stroke(t,C.edge,0.85)
        if img then mk("ImageLabel",{BackgroundTransparency=1,Image=img,Size=UDim2.new(0,13,0,13),Position=UDim2.new(0,10,0,6)},t) end
        lbl(t,{Text=(img and "" or (icon.." "))..title,Position=UDim2.new(0,img and 27 or 10,0,6),Size=UDim2.new(1,img and -31 or -14,0,14),TextSize=10,TextColor3=C.dim})
        local v=lbl(t,{Text="—",Position=UDim2.new(0,10,0,21),Size=UDim2.new(1,-14,0,20),TextSize=15,Font=Enum.Font.GothamBold,TextTruncate=Enum.TextTruncate.AtEnd})
        local s=lbl(t,{Text="",Position=UDim2.new(0,10,0,43),Size=UDim2.new(1,-14,0,14),TextSize=10,TextColor3=C.dim,TextTruncate=Enum.TextTruncate.AtEnd})
        local w={v=v,s=s}
        if bar then
            local tr=mk("Frame",{Size=UDim2.new(1,-20,0,4),Position=UDim2.new(0,10,1,-8),BackgroundColor3=C.off,BorderSizePixel=0},t); corner(tr,2)
            w.bar=mk("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.on,BorderSizePixel=0},tr); corner(w.bar,2)
        end
        UI.w[key]=w
    end
    tile(1,"money",nil,"เงิน",nil,UI.icon.coin)
    tile(2,"bag","🎒","กระเป๋า",true)
    tile(3,"pick","⛏","พลั่ว")
    tile(4,"warm","🌡","ความอบอุ่น")
    tile(5,"hit","⚔","หมัดแรร์ / วิ")
    tile(6,"reach","📏","ระยะ ขุด / E")
    tile(7,"got","📥","เก็บได้ (เซสชันนี้)")
    tile(8,"sold","💵","ขายได้ (เซสชันนี้)")
    tile(9,"mtn","🏔","ภูเขา / รอบหมุน")
    tile(10,"misc","🌦","สภาพอากาศ")
    tile(11,"dry","🎲","DryStreak (โชคแห้ง)")
    tile(12,"time","⏱","เวลาที่รันสคริปต์")
end

UI.section(P,"แรร์ในเซิร์ฟเวอร์ — คลิกชิปเพื่อกรองระดับที่แสดงบนเรดาร์")
UI.tierC={}
do
    local g=UI.grid(P,3,44,8)
    local function chip(i,key,name,col)
        local b=btn(g,{BackgroundTransparency=0,BackgroundColor3=C.row,LayoutOrder=i}); corner(b,9)
        local st=stroke(b,col,0.75); st.Thickness=1.5
        local im=UI.gemIcon(key)
        if im then mk("ImageLabel",{BackgroundTransparency=1,Image=im,Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,7,0,4)},b) end
        local nl=lbl(b,{Text=name,Position=UDim2.new(0,im and 26 or 10,0,5),Size=UDim2.new(1,im and -30 or -14,0,14),TextSize=11,TextColor3=col,TextTruncate=Enum.TextTruncate.AtEnd})
        local vl=lbl(b,{Text="0",Position=UDim2.new(0,10,0,20),Size=UDim2.new(1,-14,0,20),TextSize=16,Font=Enum.Font.GothamBold})
        UI.tierC[key]={b=b,st=st,nl=nl,vl=vl,idx=i}
        return b
    end
    for i,t in ipairs(TIERS) do
        local b=chip(i,t,PK.thR(t),TCOL[t] or C.accent)
        b.Activated:Connect(function() cfg.minTier=i sfx("tick") applyFilter() UI.syncAll() UI.dirty() end)
        UI.tip(b,"คลิก = แสดงเรดาร์เฉพาะระดับ "..PK.thR(t).." ขึ้นไป (ตั้งใน ‘เรดาร์ → ระดับ/ขนาดที่แสดง’ ได้เหมือนกัน)")
    end
    chip(#TIERS+1,"?","อื่นๆ",C.dim)
    UI.paints[#UI.paints+1]=function()
        for i,t in ipairs(TIERS) do
            local x=UI.tierC[t]
            if x then local on=(cfg.minTier==i) x.st.Transparency=on and 0.05 or 0.75 x.b.BackgroundColor3=on and C.rowH or C.row end
        end
    end
end
function UI.counts(count,oc)
    for i,t in ipairs(TIERS) do local x=UI.tierC[t] if x then x.vl.Text=tostring(count[t] or 0) elseif count[t] then oc+=count[t] end end
    local o=UI.tierC["?"]; if o then o.vl.Text=tostring(oc) end
end

UI.section(P,"บันทึกกิจกรรม")
do
    local box=mk("Frame",{Size=UDim2.new(1,0,0,240),BackgroundColor3=C.deep,BorderSizePixel=0,LayoutOrder=nxt(P)},P); corner(box,10); stroke(box,C.edge,0.85)
    local sc=mk("ScrollingFrame",{Size=UDim2.new(1,-8,1,-8),Position=UDim2.new(0,4,0,4),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.accent,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),ScrollingDirection=Enum.ScrollingDirection.Y},box)
    mk("UIListLayout",{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder},sc)
    mk("UIPadding",{PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,2)},sc)
    local lines={}; UI.logSc=sc
    UI.logRender=function(e)
        local near=true
        pcall(function() near=sc.CanvasPosition.Y>=sc.AbsoluteCanvasSize.Y-sc.AbsoluteWindowSize.Y-40 end)
        local l=lbl(sc,{Text=string.format('<font color="#6b7396">%s</font>  <font color="#%s">%s</font>',e.t,hex(e.c or C.txt),esc(e.s)),RichText=true,TextWrapped=true,
            Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextSize=11,LayoutOrder=nxt(sc)})
        lines[#lines+1]=l
        while #lines>120 do local o=table.remove(lines,1) pcall(function() o:Destroy() end) end
        if near then task.defer(function() pcall(function() sc.CanvasPosition=Vector2.new(0,1e6) end) end) end
    end
    for _,e in ipairs(UI.logs) do UI.logRender(e) end   -- ข้อความที่มาก่อนสร้างแผง
    local r=UI.row2(P,28)
    UI.half(r,"🧹 ล้างบันทึก",nil,function() for _,l in ipairs(lines) do pcall(function() l:Destroy() end) end lines={} UI.logs={} end)
    UI.half(r,"📋 คัดลอกทั้งหมด",nil,function()
        local t={} for _,e in ipairs(UI.logs) do t[#t+1]=e.t.." "..e.s end
        if setclipboard then pcall(setclipboard,table.concat(t,"\n")) feedAdd("📋 คัดลอกบันทึก "..#t.." บรรทัดแล้ว",C.good) else feedAdd("❌ executor ไม่มี setclipboard",C.bad) end
    end,"คัดลอกบันทึกกิจกรรมไปคลิปบอร์ด (ใช้ส่งให้ช่วยดูปัญหา)")
end

-- ═════════════ ⛏ ฟาร์ม ═════════════
P=addTab("farm","⛏","ฟาร์ม","ขุด · ตีแรร์ · เก็บ · ขาย · อัพเกรด · สวน")
UI.pageHead(P,"⛏","ฟาร์มอัตโนมัติ","ขุด → ตีแรร์ (E) → เก็บ → ขาย → อัพเกรด → ลงสวน ทำเองทั้งหมดขณะ AFK")
UI.section(P,"ขุดและตีแรร์")
do
    local m=UI.mBy.autodig
    UI.card(P,{id="autodig",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="autodig",kw="dig mine e hit ขุด ตี แรร์",
        tip="ยิงขุดดินรอบตัวและที่ตำแหน่งแรร์ฝังของเรา แล้วกด E (Pickup prompt) ตีแรร์ที่โผล่จนแตก + เก็บให้",
        subs=function(sub)
            UI.opt(sub,"เล็งแรร์ฝังใต้ดิน (ของเราเท่านั้น)","smartDig",nil,"ยิงขุดที่ตำแหน่งแรร์ฝังที่ Owner = เรา ก่อนขุดทั่วไป")
            UI.opt(sub,"⚔ ขุดหลายเป้าพร้อมกัน (AoE ≤10)","aoeDig",nil,"ยิงขุดแรร์ฝังได้สูงสุด 10 เป้า/รอบ — เรียงแรร์สูงก่อน แล้วใกล้ก่อน")
            UI.opt(sub,"🔥 Turbo ขุดถี่ขึ้น ~3x (เสี่ยง)","turboDig",nil,"ยิงถี่กว่า cooldown ~3 เท่า + สุ่มจังหวะ — server คุมต่อหมัดอยู่แล้ว เสี่ยงโดนจับ ใช้เมื่อจำเป็น")
            UI.opt(sub,"🅴 กด E ตีแรร์ที่ขุดโผล่ให้เอง","hitE",nil,"กด Pickup prompt ของแรร์ที่ขุดโผล่ (= หมัดตีแรร์) จนแตก แล้วกดเก็บ")
            UI.opt(sub,"🔭 ปลดแรร์ไกลเกินระยะ E ด้วย","digFar",nil,"ปกติขุดเฉพาะในระยะที่กด E ถึง — เปิด = ขุดเต็มระยะที่ server รับ (แรร์ที่โผล่ไกลต้องเดินไปเก็บเอง)")
            local g=UI.group(sub,"🎯 ขุด/ตีเฉพาะแรร์ ≥ ระดับ")
            UI.chips(g,tierItems(),function() return cfg.botTier end,function(i) cfg.botTier=i buriedT=0 end,4,26)
        end})
    m=UI.mBy.autocollect
    UI.card(P,{id="autocollect",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="autocollect",kw="collect pickup เก็บ",
        subs=function(sub)
            UI.opt(sub,"เช็คระยะ prompt ก่อนกด","colRange",nil,"กดเฉพาะแรร์ที่อยู่ในระยะ prompt (ปิด = กดทุกตัวที่เห็น ไม่จำกัดระยะ)")
            UI.opt(sub,"⚡ เก็บทันที (Hold = 0)","instaPick",nil,"ตั้ง HoldDuration ของ prompt เป็น 0 (ทริคเดียวกับ pass Instant Mine) — ฝั่งเราเท่านั้น")
        end})
end
UI.section(P,"ขาย · อัพเกรด · สวน")
do
    local m=UI.mBy.autosell
    UI.card(P,{id="autosell",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="autosell",kw="sell ขาย",
        subs=function(sub)
            UI.opt(sub,"📡 ขายระยะไกล — ไม่วาป (ยืนยันในเกมแล้ว)","remoteSell",nil,"ยิง RequestSell ตรงๆ ไม่ต้องวาปไปร้าน และขายก่อนเต็มที่ ≥92% (ปิด = วาปไปขายตอนเต็มแล้วกลับจุดเดิม)")
            UI.note(sub,"ปุ่มขายมือ/รายการกระเป๋าอยู่แท็บ ‘กระเป๋า’ · ชิ้นติด ⭐ จะไม่ถูกขาย")
        end})
    m=UI.mBy.autoup
    local cu=UI.card(P,{id="autoup",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="autoup",kw="upgrade pickaxe potion อัพเกรด พลั่ว ยา",
        subs=function(sub)
            UI.opt(sub,"🎒 ซื้อกระเป๋าใหญ่ (Carry)","upCarry",nil,"ซื้อแพ็กใหญ่สุดที่เงินพอ (ราคาจริงจาก UpgradeState)")
            UI.opt(sub,"🔥 ซื้อความอบอุ่น (ขึ้นสูงได้)","upWarm",nil,"อุ่นขึ้น = ขึ้นที่สูง/หนาวได้ไกลขึ้น (สูตรเดียวกับ FreezeClient)")
            UI.opt(sub,"💸 ซื้อทันทีที่ราคาอัพเดต","upSoon",nil,"ซื้อทุกครั้งที่ server ส่ง UpgradeState ใหม่ (ถี่ 1.2s) แทนรอ poll")
            UI.opt(sub,"⛏ ซื้อ+ใส่พลั่วที่ดีสุดที่เงินพอ","upPick",nil,"อ่านราคา/พลัง/รัศมีจริงจาก PickaxeData · เก็บเงินให้พลั่วถัดไปก่อน (งดซื้อกระเป๋าเมื่อเงิน ≥25% ของราคาพลั่ว)")
            UI.opt(sub,"🧪 กินยา (Mining ตามเวลา · Luck/Coins ทุก 15 นาที)","autoPot",nil,"ใช้ยาที่มีในคลัง (ไม่ซื้อให้) — Mining ใช้เมื่อหมดฤทธิ์ · Luck/Coins เว้น 15 นาที")
        end})
    PK.upLbl=cu.descL
    m=UI.mBy.garden
    local cg=UI.card(P,{id="garden",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="garden",kw="garden luck สวน โชค",iconImg=UI.gdIcon("clover"),
        subs=function(sub)
            UI.opt(sub,"🔄 สวนเต็ม: ถอนชิ้นโชคต่ำ → วางชิ้นดีกว่า","gdSwap",nil,"ชิ้นในกระเป๋าที่โชคสูงกว่าตัวอ่อนสุดในสวน ≥20% จะสลับเข้าไป")
            UI.opt(sub,"⭐ เก็บชิ้นโชคสูงกันขาย (ขุดเจอ = เก็บไว้ลงสวน)","gdKeep",nil,"ติด ⭐ ชิ้นที่คุ้มลงสวนอัตโนมัติ เพื่อไม่ให้ขายทิ้ง")
            UI.opt(sub,"🌱 ชิ้น ⭐ ครบ → วาปไปลงสวนแล้วกลับเอง","gdTrip",nil,"สะสมชิ้น ⭐ ≥3 และอยู่ไกลสวน → TeleportPlot → วาง/สลับจนหมด → กลับจุดขุด")
            local g=UI.group(sub,"💎 วางเฉพาะแรร์ ≥ ระดับ")
            UI.chips(g,tierItems(),function() return cfg.sub.gdTier end,function(i) cfg.sub.gdTier=i end,4,26)
        end})
    cfg._gLbl=cg.descL
end

-- 💣 ระเบิด + ☢️ นิวเคลียร์ (อัพเดต 2026-10-19 — BombData จริง)
do
    local m=UI.mBy.bombSnipe
    UI.card(P,{id="bombSnipe",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="bombSnipe",kw="bomb ระเบิด ซื้อ",
        subs=function(sub)
            for i,b in ipairs(PK.BOMBS) do   -- ติ๊กแยกทีละลูกเหมือนเรด้าสอยสต็อก
                UI.opt(sub,"💣 "..b.n.." · "..({"50K","400K","2M","8M","12M","25M","1B","10B","25B"})[i],"snB_"..b.id,nil,
                    "สต็อกมา + เงินพอ → BuyBomb ทันที (server คุม stock/ราคาเอง)"..(b.id=="DivineBomb" and " — การันตี Legendary×4/ลูก" or ""))
            end
            UI.note(sub,"☢️ EXTREME NUKE = DevProduct 699R$ เท่านั้น (server เช็คของจริง เงินเกม/โคลนไม่ได้)",C.dim)
            UI.button(sub,"💣 ใช้ระเบิดลูกแรงสุดในกระเป๋า",Color3.fromRGB(200,90,50),function() task.spawn(PK.useBomb) end,"ถือระเบิดจริงลูกแพงสุดแล้วกระตุ้น — script server ใน tool ระเบิดเอง (ต้องซื้อจริงก่อน)",26)
            UI.bomStat=UI.note(sub,"📦 สต็อก: —",C.accent)
            UI.button(sub,"📦 log สต็อกลงบันทึก",C.opt2,function()
                local parts={} for _,b in ipairs(PK.BOMBS) do parts[#parts+1]=b.n.."="..(PK.bombStock[b.id] or "?") end
                feedAdd("💣 "..table.concat(parts," · "),C.dim)
            end,"เขียนสต็อกล่าสุดทั้งหมดลงบันทึก",28)
        end})
end

-- 💥 ระเบิดออโต้ — แยกจากสอยสต็อก: วนถือ+โยนระเบิดจริงเอง หมดแล้วซื้อลูกดีสุดอัตโนมัติ
do
    local m=UI.mBy.bombAuto
    UI.card(P,{id="bombAuto",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="bombAuto",kw="bomb auto throw ระเบิด ออโต้ โยน วน ฟาร์ม",
        tip="วนจริง: กระเป๋ามีระเบิด → ถือลูกแรงสุด+Activate (server ระเบิดเอง) → คืนพลั่วขุดต่อ → รอ fuse ~2-4s → วน · หมด → ซื้อลูกดีสุดที่ติ๊กไว้+สต็อกมี+เงินพอเอง",
        subs=function(sub)
            UI.note(sub,"⚠️ ระเบิดโคลนใช้ไม่ได้ (server เช็คของจริง) — ระบบนี้ใช้ของจริงเท่านั้น · ลูกที่ซื้อ = ติ๊กแยกลูกในการ์ดสอยสต็อกด้านบน",C.dim)
            UI.note(sub,"ระเบิดดีดตัว (knockback) เป็นของเกม — ถ้าถูกดีดไกลเกินลองลดระดับ หรือปิดกลุ่มแพง",C.dim)
            UI.button(sub,"💣 โยนลูกแรงสุดตอนนี้ (มือ)",Color3.fromRGB(200,90,50),function() task.spawn(PK.useBomb) end,"ถือ+กระตุ้นลูกแพงสุดทันที ไม่รอลูป",26)
        end})
end

-- ⚗️ ฟิวส์คริสตัล (FusionClient: 3 ชิ้นระดับเดียวกัน → ชิ้นใหม่)
do
    local m=UI.mBy.fusion
    UI.card(P,{id="fusion",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="fusion",kw="fusion fuse ฟิวส์ รวม",
        subs=function(sub)
            UI.note(sub,"อัตโน: มีชิ้นระดับเดียวกันครบ 3 → ฟิวส์ชุดต่ำสุดเองทุก 20 วิ (เว้น ⭐)",C.dim)
            local g=UI.group(sub,"🛡 เว้นชิ้นระดับ ≥ นี้ไว้ (ไม่ฟิวส์)")
            UI.chips(g,tierItems(),function() return cfg.sub.fusKeep or 6 end,function(i) cfg.sub.fusKeep=i end,4,26)
            local r=UI.row2(sub,30)
            UI.half(r,"⚗ ฟิวส์ชุดต่ำสุดตอนนี้",C.buy,function() task.spawn(PK.fuseOnce) end,"Fuse({BagId×3 ระดับเดียวกัน เล็กสุด}) → Claim ทันที")
            UI.half(r,"📊 เช็คสถานะเครื่อง",C.opt2,function() task.spawn(PK.fuseStatus) end,"Status:InvokeServer() — ดูว่าเครื่องค้างผลไว้ไหม")
        end})
end

-- ═════════════ 🛰 เรดาร์ ═════════════
P=addTab("radar","🛰","เรดาร์","ESP แรร์/ผู้เล่น/รูน · เรด้า · เจาะจงชื่อ")
UI.pageHead(P,"🛰","เรดาร์ & ESP","เห็นแรร์/ผู้เล่น/รูน ทะลุกำแพง · เรด้าซื้อ/เดินฟรี · เจาะจงชื่อแรร์")
UI.section(P,"เรดาร์แรร์")
do
    local m=UI.mBy.esp
    UI.card(P,{id="esp",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="esp",kw="esp radar เรดาร์ แรร์ highlight",iconImg=UI.gemIcon("Zenith"),
        subs=function(sub)
            UI.opt(sub,"Highlight ทรงแรร์","espHl",nil,"ไฮไลต์ตัวโมเดลจริง (สูงสุด 24 ตัวที่ใกล้สุด — เพดาน Highlight ของ Roblox)")
            UI.opt(sub,"ป้ายชื่อ + ระยะ","espName",nil,"ป้ายเหนือแรร์: ชื่อ/ระดับ/น้ำหนัก/ระยะ")
            UI.opt(sub,"❤ HP ตัวที่โดนขุด","hpBar",nil,"โชว์เลือดแรร์ที่กำลังโดนตี")
            UI.opt(sub,"🍀 โชว์ค่าโชคชิ้นนั้นบนป้าย","espLuck",nil,"ค่า effectiveLuck ของชิ้นนั้น (ใช้ตัดสินใจลงสวน)")
            UI.opt(sub,"📡 มาร์กไกล (ตำแหน่งทุกจุด ไกลไม่จำกัด)","espFar",nil,"วาดป้ายจากพิกัดที่ server ประกาศ แม้โมเดลยังไม่ stream เข้ามา (สูงสุด 80 ป้าย)")
            UI.opt(sub,"🪨 ESP หินก้อนใหญ่ (ค่าเดียวกันเรด้าหิน)","espBld",nil,"ชื่อ/พลั่วที่ต้องใช้/เลือด/ฝังอยู่ — เทียบกับพลั่วที่ถืออยู่")
            UI.opt(sub,"🛰 ดึงแมพไกลเข้าเครื่อง (หนัก/อาจกระตุก)","streamFar",nil,"RequestStreamAroundAsync ทั่วแมพเพื่อเห็นแรร์ไกล — กินเครื่องมาก เปิดเมื่อจำเป็น")
        end})
    UI.card(P,{id="espfilter",icon="🏷",col=C.dim,title="ระดับ / ขนาดที่แสดง",desc="กรองแรร์ที่โชว์บนเรดาร์ (ใช้กับ ESP ทุกแบบ)",open=true,kw="filter tier size กรอง ระดับ ขนาด",
        subs=function(sub)
            local g=UI.group(sub,"แสดงแรร์ระดับ")
            UI.chips(g,tierItems(),function() return cfg.minTier end,function(i) cfg.minTier=i applyFilter() end,4,26)
            UI.opt(sub,"⬆ โชว์ ≥ ระดับที่เลือก (ไม่ใช่แค่เท่ากับ)","espAbove",applyFilter,"เปิด = ระดับที่เลือกขึ้นไป · ปิด = เฉพาะระดับนั้นระดับเดียว")
            local g2=UI.group(sub,"📏 โชว์ขนาด ≥ (ชั้นขนาดตามเกม)")
            UI.chips(g2,sizeItems(),function() return cfg.sub.espSize or 1 end,function(i) cfg.sub.espSize=i applyFilter() end,5,26)
        end})
    m=UI.mBy.players
    UI.card(P,{id="players",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="players",kw="player ผู้เล่น",
        subs=function(sub)
            UI.opt(sub,"Highlight ตัวละคร","pHl"); UI.opt(sub,"ป้ายชื่อ + ระยะ","pName"); UI.opt(sub,"แท็ก ⛏ กำลังขุด","pDig",nil,"โชว์เมื่อผู้เล่นนั้นขุดอยู่ใกล้ (จับจาก DigEffect)")
        end})
    m=UI.mBy.runes
    UI.card(P,{id="runes",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="runes",kw="rune รูน",
        subs=function(sub) UI.opt(sub,"Highlight รูน","runeHl"); UI.opt(sub,"ป้ายชื่อรูน + ระยะ","runeLbl") end})
end

UI.section(P,"เจาะจงชื่อแรร์")
do
    local m=UI.mBy.pickMode
    local cp
    cp=UI.card(P,{id="pickMode",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="pickMode",kw="pick name เจาะจง ชื่อ ดัชนี",iconImg=UI.gdIcon("crystal"),
        tip="เลือกชื่อแรร์จากดัชนีเกม (398 ชื่อ) — ESP/ขุด/เก็บ เฉพาะชื่อที่เลือก · ชื่อที่เลือกจะติด ⭐ กันขาย",
        subs=function(sub)
            local top=mk("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,LayoutOrder=nxt(sub)},sub)
            local qq=mk("TextBox",{Size=UDim2.new(1,-66,1,0),BackgroundColor3=C.opt,Text="",PlaceholderText="🔍 พิมพ์ชื่อแรร์ (ไทย/อังกฤษ)…",PlaceholderColor3=C.dim,TextSize=11,TextColor3=C.txt,
                TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,BorderSizePixel=0},top); tfont(qq); corner(qq,7)
            mk("UIPadding",{PaddingLeft=UDim.new(0,8)},qq)
            local clr=btn(top,{Size=UDim2.new(0,58,1,0),Position=UDim2.new(1,-58,0,0),BackgroundTransparency=0,BackgroundColor3=C.off,Text="ล้างที่เลือก",TextSize=10}); corner(clr,7)
            hoverFx(clr,clr,C.off,C.optH)
            local st2=UI.note(sub,"—")
            local lst=mk("ScrollingFrame",{Size=UDim2.new(1,0,0,230),BackgroundColor3=C.deep,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.accent,
                AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),LayoutOrder=nxt(sub)},sub); corner(lst,8)
            mk("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},lst)
            mk("UIPadding",{PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},lst)
            local rowBtns={}
            local function nPicked() local n=0 for _ in pairs(picks) do n+=1 end return n end
            function UI.paintPick()
                cp.descL.Text=("%s · เลือกไว้ %d ชื่อ"):format(cfg.pickMode and "เปิด" or "ปิด",nPicked())
            end
            local function paintRow(nm,b,cnt)
                local on=picks[nm]==true
                b.BackgroundColor3=on and C.buy or C.opt
                b.Text=(on and "✓ " or "")..PK.dispName(nm)..((cnt or 0)>0 and ("  ×"..cnt) or "")..(PK.ownedCard(nm) and "  ✅" or "  🔒")
            end
            local function rebuild(filter)
                for _,b in ipairs(lst:GetChildren()) do if b:IsA("TextButton") then b:Destroy() end end
                rowBtns={}
                local arr={}
                for nm in pairs(PK.nameRarity) do
                    local pretty=nm:gsub("(%l)(%u)","%1 %2"):lower()
                    local th=(PK.thNames[nm] or ""):lower()
                    if not filter or filter=="" or nm:lower():find(filter,1,true) or pretty:find(filter,1,true) or th:find(filter,1,true) then arr[#arr+1]=nm end
                end
                table.sort(arr,function(a,b)
                    local ra,rb=rIdx(PK.nameRarity[a]),rIdx(PK.nameRarity[b])
                    if ra~=rb then return ra>rb end
                    return a<b
                end)
                local cc=PK.liveCounts()
                for i,nm in ipairs(arr) do
                    local b=btn(lst,{Size=UDim2.new(1,0,0,24),BackgroundTransparency=0,BackgroundColor3=C.opt,Text="",TextSize=11,TextColor3=TCOL[PK.nameRarity[nm]] or C.txt,
                        TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=i}); corner(b,6)
                    mk("UIPadding",{PaddingLeft=UDim.new(0,8)},b)
                    b.MouseEnter:Connect(function() if not picks[nm] then tw(b,0.1,{BackgroundColor3=C.optH}) end end)
                    b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=picks[nm] and C.buy or C.opt}) end)
                    b.Activated:Connect(function()
                        picks[nm]=(not picks[nm]) or nil
                        sfx("tick"); paintRow(nm,b,PK.liveCounts()[nm]); UI.paintPick(); applyFilter(); UI.dirty()
                    end)
                    paintRow(nm,b,cc[nm]); rowBtns[nm]=b
                end
                local own=0 for nm in pairs(PK.nameRarity) do if PK.ownedCard(nm) then own+=1 end end
                st2.Text=("รวม %d ชื่อ · ✅ มีแล้ว %d · ⭐ กันไว้ %d (ไม่ขาย · สวนวางให้)"):format(#arr,own,nPicked())
            end
            qq:GetPropertyChangedSignal("Text"):Connect(function() rebuild(trim(qq.Text):lower()) end)
            clr.Activated:Connect(function() for k in pairs(picks) do picks[k]=nil end UI.paintPick() sfx("tick") applyFilter() rebuild(trim(qq.Text):lower()) UI.dirty() end)
            sub:GetPropertyChangedSignal("Visible"):Connect(function() if sub.Visible then PK.loadNames() PK.localizeNames() rebuild(trim(qq.Text):lower()) end end)
            task.spawn(function() while alive() do
                if sub.Visible then
                    PK.loadNames()
                    if PK.localizeNames() then rebuild(trim(qq.Text):lower())
                    else local cc=PK.liveCounts() for nm,b in pairs(rowBtns) do paintRow(nm,b,cc[nm]) end end
                end
                task.wait(4)
            end end)
        end})
    UI.paintPick()
end

UI.section(P,"เรด้า")
do
    local m=UI.mBy.radarSnipe
    UI.card(P,{id="radarSnipe",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="radarSnipe",kw="radar snipe buy เรด้า ซื้อ สต็อก",iconImg=UI.radarIcon("ZenithRadar"),
        tip="ShopState ของเกม push ทุก ~1 วินาที — สต็อกมา + เงินพอ = ยิง BuyRadar ทันที (ติ๊กเลือกชนิดที่จะสอย)",
        subs=function(sub)
            cfg._rLab={}; PK.RBASE={}
            cfg._rLab.ZenithRadar=UI.opt(sub,"ซีนิธ · 1T","snZenith",nil,"เรด้าซีนิธ (1T · สต็อกสูงสุด 1) — จับแรร์มิธิค/เอ็กโซติก/ซีนิธ",UI.radarIcon("ZenithRadar"))
            cfg._rLab.MeteorRadar=UI.opt(sub,"อุกกาบาต · 150M","snMeteor",nil,"เรด้าอุกกาบาต (150M · สต็อกสูงสุด 2) — แจ้งจุดฝังพิเศษส่วนตัวของเรา",UI.radarIcon("MeteorRadar"))
            cfg._rLab.BoulderRadar=UI.opt(sub,"หินใหญ่ · 12M","snBoulder",nil,"เรด้าหินขนาดใหญ่ (12M · สต็อกสูงสุด 4) — หินมุเทชันการันตี",UI.radarIcon("BoulderRadar"))
            cfg._rLab.RuneRadar=UI.opt(sub,"รูน · 35M","snRune",nil,"เรด้ารูน (35M · สต็อกสูงสุด 3)",UI.radarIcon("RuneRadar"))
            cfg._rLab.RarityRadar=UI.opt(sub,"ความหายาก · 3M","snRarity",nil,"เรด้าความหายาก (3M · สต็อกสูงสุด 6)",UI.radarIcon("RarityRadar"))
            cfg._rLab.CrystalRadar=UI.opt(sub,"คริสตัล · 300K","snCrystal",nil,"เรด้าคริสตัล (300K · สต็อกสูงสุด 10)",UI.radarIcon("CrystalRadar"))
            for id,l in pairs(cfg._rLab) do PK.RBASE[id]=l.Text end
        end})
    m=UI.mBy.radClone
    UI.card(P,{id="radClone",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="radClone",kw="clone radar โคลน เรด้า ฟรี hud",iconImg=UI.radarIcon("ZenithRadar"),
        tip="โคลน template จริง RS.RadarTools → RadarClient ของเกมหยิบไปใช้เอง: HUD+ping+สแกนทำงานจริง · server ไม่รู้จักของโคลน = เวลาไม่มีวันหมด · ฆ่า stop() ให้ปล่อยทูลแล้ว HUD ค้าง ขุดได้ตลอด",
        subs=function(sub)
            UI.note(sub,"⚠️ ที่ไม่ได้: buff ฝั่ง server (luck surge/spawn ×2/จุดขุดส่วนตัว) — ที่ได้จริง: HUD+beep+สแกนคริสตัล/หิน/รูน/อุกกาบาตทั้งหมด",C.dim)
            UI.chips(sub,{{"ซีนิธ",Color3.fromRGB(255,215,90)},{"อุกกาบาต",Color3.fromRGB(90,235,255)},{"หินใหญ่",C.accent},{"รูน",Color3.fromRGB(190,130,255)},{"หายาก",C.accent},{"คริสตัล",C.accent}},
                function() local ids={"ZenithRadar","MeteorRadar","BoulderRadar","RuneRadar","RarityRadar","CrystalRadar"}
                    for i,v in ipairs(ids) do if cfg.sub.radCloneType==v then return i end end return 1 end,
                function(i) cfg.sub.radCloneType=({"ZenithRadar","MeteorRadar","BoulderRadar","RuneRadar","RarityRadar","CrystalRadar"})[i] end,3,26)
            UI.button(sub,"🧪 โคลนเข้ากระเป๋าเฉยๆ (ถือเอง)",C.opt2,function() PK.cloneRadar(cfg.sub.radCloneType or "ZenithRadar") end,"โคลนไว้ในกระเป๋าโดยไม่เปิดระบบ — ถือเองเมื่ออยากใช้",26)
        end})
end

-- ═════════════ 🧍 ตัวเรา ═════════════
P=addTab("self","🧍","ตัวเรา","วิ่งไว · เจ็ทแพ็ค · สกิล · กันตายหนาว")
UI.pageHead(P,"🧍","ตัวเรา","ปรับตัวละคร: วิ่งไว / เจ็ทแพ็ค / สกิลออโต้ และระบบกันตาย")
UI.section(P,"ความสามารถตัวละคร")
do
    local m=UI.mBy.selfOn
    UI.card(P,{id="selfOn",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="selfOn",kw="speed jet skill วิ่ง เจ็ท สกิล เคียว ค้างคาว",open=true,
        subs=function(sub)
            UI.opt(sub,"🏃 วิ่งไว 1.5x (ปลอดภัย)","spd15",nil,"WalkSpeed 24 — ฟิสิกส์ฝั่งเรา ปิด = คืนค่าเดิมที่จำไว้")
            UI.opt(sub,"🏃💨 วิ่งไว 2x (= pass จริง)","spd2",nil,"WalkSpeed 32 เท่า Pass_Speed2x ของเกม (ถ้าเปิดคู่ 1.5x จะใช้ 2x)")
            UI.opt(sub,"🚀 เจ็ทแพ็ค = ตัวโชว์ร้าน (ทดลอง)","jet",nil,"โคลนโมเดลเจ็ทแพ็คตัวโชว์เข้าตัวให้ JetpackClient ของเกมหยิบไปใช้ + น้ำมันไม่จำกัด (กดโดดค้างกลางอากาศ)")
            UI.opt(sub,"⚔️ สกิลเคียว/ค้างคาวออโต้ (ถ้ามีของ)","skillAuto",nil,"ยิง Shatter/Swarm เมื่อถืออยู่และ cooldown พร้อม (อ่านจาก attr ที่ server ตั้ง ไม่ยิงมั่ว)")
            UI.note(sub,"ต้องเปิดสวิตช์หลักของการ์ดนี้ก่อน ตัวเลือกข้างบนถึงจะทำงาน (รวมระบบกันตกเหวตอนวิ่งไว)")

        end})
end
UI.section(P,"ความปลอดภัย")
do
    UI.card(P,{id="coldHome",icon="🥶",col=Color3.fromRGB(120,190,255),title="กันตายหนาว → วาปกลับฐาน",desc="หนาวจัด + เลือด <45% = TeleportHome อัตโนมัติ",
        get=function() return cfg.sub.coldHome end,set=function(v) cfg.sub.coldHome=v end,kw="cold home freeze หนาว วาป ฐาน",
        tip="ใช้สูตรหนาวเดียวกับ FreezeClient — ทำงานเมื่อเปิดขุด/เก็บ/ตัวเรา อย่างใดอย่างหนึ่ง · วาปแล้วต้องเดินกลับจุดขุดเอง"})
    UI.card(P,{id="antiidle",icon="🛡",col=C.on,title="กันหลุด (Anti-idle)",desc="ทำงานอัตโนมัติ — กันเกมเด้งออกเมื่อ AFK 19 นาที",kw="afk idle kick หลุด",open=true,
        subs=function(sub)
            UI.note(sub,"เกมมี AntiIdleClient ที่ยิง rejoin เมื่อไม่มี input 1140 วินาที — สคริปต์ส่งสัญญาณ WindowFocused ให้เกมทุก 3 นาที (ไม่มี argument) และใช้ VirtualUser กัน kick 20 นาทีของ Roblox ด้วย")
        end})
end

-- ═════════════ 🌍 โลก ═════════════
P=addTab("world","🌍","โลก","เมเทียร์ · ดาวตก · ภูเขา")
UI.pageHead(P,"🌍","โลก & อีเวนต์","เมเทียร์/ดาวตกบนแมพ · เลือกภูเขา · เวลาหมุนภูเขา")
UI.section(P,"อีเวนต์")
do
    local m=UI.mBy.met
    UI.card(P,{id="met",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="met",kw="meteor star อุกกาบาต ดาวตก",
        subs=function(sub)
            UI.opt(sub,"ป้ายจุดตกบนแมพ","metMark",nil,"ปักป้ายจุดเมเทียร์/ดาวตกบนโลก (เห็นทะลุกำแพง)")
            UI.opt(sub,"แจ้งเตือนในบันทึก/มุมจอ","metFeed",nil,"แจ้งตอนเมเทียร์กำลังตก/ตกแล้ว (โซนโชค x5)")
        end})
end
do
    local m=UI.mBy.halloween
    UI.card(P,{id="halloween",icon=m.icon,col=m.col,title=m.name,desc=m.desc,get=m.get,set=m.set,act="halloween",kw="halloween candy crate cauldron ฮาโลวีน แคนดี้ กล่อง หม้อ daily",
        subs=function(sub)
            UI.opt(sub,"🎁 เคลมรางวัลรายวันอัตโนมัติ","autoDaily",nil,"Claim:InvokeServer(\"claim\") หลังเข้าเกม 25 วิ + ตรวจทุก 5 นาที")
            UI.opt(sub,"📦 เปิด Haunted Crate อัตโนมัติ","crateAuto",nil,"แคนดี้พอ → Open:InvokeServer(n) เองทุก 8 วิ")
            local g=UI.group(sub,"ขนาดกล่อง (CrateData: 1=2,000 · 3=5,700 · 5=9,000 แคนดี้)")
            UI.chips(g,{{"×1",C.accent},{"×3",C.accent},{"×5",C.accent}},function() return cfg.sub.crateN==3 and 2 or cfg.sub.crateN==5 and 3 or 1 end,function(i) cfg.sub.crateN=({1,3,5})[i] end,3,26)
            UI.candyStat=UI.note(sub,"🍬 แคนดี้: —",C.accent)
            local r=UI.row2(sub,30)
            UI.half(r,"🍬 เทเข้าหม้อ 10%",Color3.fromRGB(200,110,40),function() task.spawn(PK.cauldronPour,0.10) end,"หม้อ = เป้ารวมทั้งเซิร์ฟเวอร์ (~350M CandyCorn) — เทของเราเข้าตาม % · server คืน accepted")
            UI.half(r,"🍬 เท 50%",Color3.fromRGB(160,80,30),function() task.spawn(PK.cauldronPour,0.50) end,"เทแคนดี้ครึ่งหนึ่งเข้าหม้อ — ระวังหมด")
        end})
end
UI.section(P,"ภูเขา")
do
    UI.mtCard=UI.card(P,{id="mtn",icon="🏔",col=Color3.fromRGB(160,220,255),title="ภูเขา — ขึ้นดีสุดอัตโนมัติ",desc="ภูเขา: —",open=true,
        get=function() return cfg.sub.mtnAuto end,set=function(v) cfg.sub.mtnAuto=v end,kw="mountain ภูเขา หมุน rotation",
        tip="สวิตช์ = ขึ้นภูเขาที่ดีที่สุดให้อัตโนมัติเมื่อมีโควตาสวิตช์ (MountainSwitches) · คลิกชื่อภูเขาด้านล่างเพื่อเลือกเอง",
        subs=function(sub)
            UI.mtInfo=UI.note(sub,"สวิตช์: — · หมุนใน: —",C.accent)
            local lst=mk("ScrollingFrame",{Size=UDim2.new(1,0,0,200),BackgroundColor3=C.deep,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.accent,
                AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),LayoutOrder=nxt(sub)},sub); corner(lst,8)
            mk("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},lst)
            mk("UIPadding",{PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},lst)
            UI.mtList=lst
        end})
end

-- ═════════════ 🎒 กระเป๋า ═════════════
P=addTab("bag","🎒","กระเป๋า","ขายเอง · รายการของ · มูลค่า")
UI.pageHead(P,"🎒","กระเป๋า & ขาย","ดูของในกระเป๋า ขายเป็นชิ้น/ทั้งหมด · ชิ้นติด ⭐ ถูกกันไว้ไม่ขาย")
UI.section(P,"สรุป")
do
    local box=mk("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=C.row,BorderSizePixel=0,LayoutOrder=nxt(P)},P); corner(box,10); stroke(box,C.edge,0.85)
    lbl(box,{Text="🎒 น้ำหนักในกระเป๋า",Position=UDim2.new(0,12,0,7),Size=UDim2.new(0.5,0,0,14),TextSize=10,TextColor3=C.dim})
    UI.bagTxt=lbl(box,{Text="—",Position=UDim2.new(0,12,0,22),Size=UDim2.new(0.55,0,0,22),TextSize=16,Font=Enum.Font.GothamBold})
    UI.bagVal=lbl(box,{Text="",Position=UDim2.new(0.5,0,0,22),Size=UDim2.new(0.5,-12,0,22),TextSize=13,TextColor3=C.on,TextXAlignment=Enum.TextXAlignment.Right})
    local tr=mk("Frame",{Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,1,-14),BackgroundColor3=C.off,BorderSizePixel=0},box); corner(tr,3)
    UI.bagBar=mk("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.on,BorderSizePixel=0},tr); corner(UI.bagBar,3)
end
UI.section(P,"ขายมือ")
do
    local r=UI.row2(P,32)
    UI.btnSellAll=UI.half(r,"💰 ขายทั้งหมด (ตรงนี้)",C.buy,function() PK.sellAllNow() end,"ยิง RequestSell(\"All\") ทันที — ไม่วาป ข้ามชิ้น ⭐")
    UI.btnSellEach=UI.half(r,"📦 ขายทีละชิ้น (ข้าม ⭐)",Color3.fromRGB(90,72,40),function() task.spawn(PK.sellEach) end,"ถือ → ขาย ทีละชิ้น (เห็นราคาแต่ละชิ้นในบันทึก) จบแล้วกลับถือพลั่ว")
    UI.toggleRow(P,"📡 ขายระยะไกล — ไม่วาป (ยืนยันในเกมแล้ว)",function() return cfg.sub.remoteSell end,function(v) cfg.sub.remoteSell=v end,
        "ใช้กับ ‘ขายออโต้’: ยิง RequestSell ตรงๆ ไม่วาปไปร้าน และขายก่อนเต็มที่ ≥92%")
end
UI.section(P,"ของในกระเป๋า — คลิกชิ้นเพื่อขายชิ้นนั้น")
do
    local box=mk("Frame",{Size=UDim2.new(1,0,0,280),BackgroundColor3=C.deep,BorderSizePixel=0,LayoutOrder=nxt(P)},P); corner(box,10); stroke(box,C.edge,0.85)
    local lst=mk("ScrollingFrame",{Size=UDim2.new(1,-8,1,-8),Position=UDim2.new(0,4,0,4),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.accent,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0)},box)
    mk("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},lst)
    mk("UIPadding",{PaddingRight=UDim.new(0,6)},lst)
    UI.bagList=lst
    UI.bagEmpty=lbl(lst,{Text="กระเป๋าว่าง",Size=UDim2.new(1,0,0,24),TextSize=11,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Center,LayoutOrder=0,Visible=false})
end

-- ═════════════ ⚙ ตั้งค่า ═════════════
P=addTab("settings","⚙","ตั้งค่า","หน้าตา · ปุ่มลัด · บันทึก/รีเซ็ต · ความเข้ากันได้")
UI.pageHead(P,"⚙","ตั้งค่า","ปรับหน้าตา · ตั้งปุ่มลัด · บันทึก/โหลด/รีเซ็ตค่า")
UI.section(P,"หน้าตาและการใช้งาน")
do
    UI.slider(P,"🔎 ขนาดหน้าต่าง (ซูม) — ปล่อยเมาส์แล้วค่อยมีผล",70,150,function() return math.floor(cfg.ui.scale*100+0.5) end,
        function(v) UI.applyScale(math.floor(v/5+0.5)*5/100) clampWin() syncShadow() end,function(v) return math.floor(v+0.5).."%" end,nil,true)
    UI.slider(P,"💧 ความทึบพื้นหลัง",40,100,function() return math.floor((1-cfg.ui.opacity)*100+0.5) end,
        function(v) cfg.ui.opacity=1-math.floor(v+0.5)/100 win.BackgroundTransparency=cfg.ui.opacity end,function(v) return math.floor(v+0.5).."%" end)
    UI.toggleRow(P,"🔊 เสียงคลิก/สวิตช์",function() return cfg.ui.sound end,function(v) cfg.ui.sound=v PK.mute=not v end,"เสียงคลิกเบาๆ ตอนกดปุ่ม/สวิตช์ และเสียงแจ้งตอนชื่อที่เจาะจงเกิด")
    UI.toggleRow(P,"📌 แถบสถานะลอยตอนซ่อนหน้าต่าง",function() return cfg.ui.pill end,function(v) cfg.ui.pill=v UI.show(UI.win.Visible) end,"ซ่อนหน้าต่างด้วยปุ่มลัดแล้วยังเห็นสถานะย่อๆ (ระบบที่ทำงาน · เงิน · กระเป๋า · หมัด/วิ) กลางบนจอ — คลิกเพื่อเปิดหน้าต่าง")
    UI.toggleRow(P,"🔔 แจ้งเตือนมุมจอ (toast)",function() return cfg.ui.toast end,function(v) cfg.ui.toast=v end,"เด้งแจ้งเฉพาะเรื่องสำคัญ (ขาย/ซื้อ/เตือนหนาว/เหตุผิดพลาด) — ทุกข้อความยังอยู่ในบันทึกกิจกรรม")
    UI.toggleRow(P,"💾 บันทึกค่าอัตโนมัติ",function() return cfg.ui.autosave end,function(v) cfg.ui.autosave=v end,"เก็บการตั้งค่าลง hz_mine_cfg.json ทุกครั้งที่เปลี่ยน (หน่วง 1.5 วินาที)")
    UI.toggleRow(P,"▶ เปิดสวิตช์ระบบฟาร์มที่บันทึกไว้อัตโนมัติ",function() return cfg.ui.autostart end,function(v) cfg.ui.autostart=v end,
        "ค่าเริ่มต้นปิด = โหลดสคริปต์แล้วระบบฟาร์ม (ขุด/เก็บ/ขาย/อัพเกรด/สวน/ตัวเรา/สอยเรด้า) เริ่มปิดเสมอ · เปิด = คืนสถานะเดิมตามที่บันทึก")
end
UI.section(P,"ปุ่มลัด — คลิกช่องแล้วกดคีย์ใหม่ (Backspace = ยกเลิกปุ่ม · Esc = ไม่เปลี่ยน)")
UI.keycaps={}
do
    local box=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.row,BorderSizePixel=0,LayoutOrder=nxt(P)},P); corner(box,10); stroke(box,C.edge,0.85)
    mk("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},box)
    mk("UIPadding",{PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)},box)
    for i,a in ipairs(UI.act) do
        local r=mk("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=C.opt,BorderSizePixel=0,LayoutOrder=i},box); corner(r,7)
        lbl(r,{Text=a.name,Position=UDim2.new(0,10,0,0),Size=UDim2.new(1,-110,1,0),TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd})
        local kb=btn(r,{Size=UDim2.new(0,86,0,22),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),BackgroundTransparency=0,BackgroundColor3=C.opt2,Text="—",TextSize=11}); corner(kb,6); stroke(kb,C.edge,0.6)
        hoverFx(kb,kb,C.opt2,C.optH)
        UI.keycaps[a.id]=kb
        kb.Activated:Connect(function()
            sfx("tick")
            if UI.capturing then UI.capturing.restore() end
            kb.Text="กดคีย์…"; kb.TextColor3=C.accent
            UI.capturing={id=a.id,t=os.clock(),restore=function() kb.Text=UI.keyOf(a.id) or "—" kb.TextColor3=C.txt end}
        end)
    end
end
UI.section(P,"จัดการค่า")
do
    local r=UI.row2(P,32)
    UI.half(r,"💾 บันทึกตอนนี้",C.buy,function() local ok=UI.save() feedAdd(ok and "💾 บันทึกค่าแล้ว (hz_mine_cfg.json)" or "❌ บันทึกไม่ได้ (executor ไม่มี writefile?)",ok and C.good or C.bad) end,"เขียนค่าทั้งหมดลง hz_mine_cfg.json ในโฟลเดอร์ workspace ของ executor")
    UI.half(r,"📂 โหลดจากไฟล์",nil,function()
        local ok=UI.load() UI.refreshKeys() applyFilter() UI.syncAll()
        if UI.applyWindow then UI.applyWindow() end
        feedAdd(ok and "📂 โหลดค่าจากไฟล์แล้ว" or "❌ ไม่พบไฟล์ค่า/อ่านไม่ได้",ok and C.good or C.bad)
    end,"โหลดค่าที่บันทึกไว้ (สวิตช์ฟาร์มจะไม่เปิดเอง ยกเว้นเปิด ‘เปิดสวิตช์…อัตโนมัติ’)")
    UI.confirmButton(P,"♻ รีเซ็ตทุกอย่างเป็นค่าเริ่มต้น",Color3.fromRGB(110,60,60),function() UI.reset() end,"ปิดระบบฟาร์มทั้งหมด คืนตัวเลือก/ปุ่มลัด/ขนาด/ซูมเป็นค่าเริ่มต้น และล้างรายชื่อที่เจาะจง")
    UI.confirmButton(P,"⏻ ปิดสคริปต์ (หยุดทุกลูป)",Color3.fromRGB(150,45,60),function() UI.kill() end,"เหมือนปุ่ม × ที่หัวหน้าต่าง: หยุดทุก loop/hook และลบ UI+ESP (รันใหม่ได้ปกติ)")
end
UI.section(P,"ความเข้ากันได้ของ executor")
do
    local items={
        {"กด E ให้เอง (fireproximityprompt)",fireproximityprompt~=nil,"จำเป็นสำหรับตีแรร์/เก็บ — ถ้าไม่มี ต้องกด E เอง"},
        {"ดึงสัญญาณของเกม (getconnections)",getconnections~=nil,"ใช้กับ เรด้าเดินฟรี / เจ็ทแพ็คน้ำมันไม่จำกัด / กันหลุด"},
        {"บันทึกไฟล์ (writefile/readfile)",(writefile~=nil and readfile~=nil),"ใช้เก็บบันทึกกิจกรรม + การตั้งค่า"},
        {"hook ฟังก์ชัน (hookfunction)",hookfunction~=nil,"ใช้กับโหมดตัดสายเรด้า (สำรอง)"},
        {"คลิปบอร์ด (setclipboard)",setclipboard~=nil,"ใช้ปุ่ม ‘คัดลอกทั้งหมด’ ของบันทึกกิจกรรม"},
        {"พื้นที่ซ่อน UI (gethui)",gethui~=nil,"ถ้าไม่มี UI อยู่ใน CoreGui (บางเกมตรวจ)"},
    }
    local box=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.row,BorderSizePixel=0,LayoutOrder=nxt(P)},P); corner(box,10); stroke(box,C.edge,0.85)
    mk("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},box)
    mk("UIPadding",{PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},box)
    for i,it in ipairs(items) do
        local l=lbl(box,{Text=(it[2] and "✅  " or "❌  ")..it[1],Size=UDim2.new(1,0,0,20),TextSize=11,TextColor3=it[2] and C.txt or C.bad,LayoutOrder=i})
        local h=btn(l,{Size=UDim2.new(1,0,1,0)}); UI.tip(h,it[3])
    end
end
UI.section(P,"เกี่ยวกับ")
do
    UI.note(P,"HZ HUB · Mine Antarctica · UI v6 สำหรับคอมพิวเตอร์\nลากหัวหน้าต่าง = ย้าย · ลากมุมขวาล่าง = ปรับขนาด · Ctrl+F = ค้นหาฟีเจอร์ · วางเมาส์ค้างบนปุ่ม = คำอธิบาย\n⚠ เกมเตือนว่าการใช้สคริปต์อาจโดนแบนถาวร — ใช้ระยะ/จังหวะที่ server ยอมรับ และอย่ายิง remote ถี่เกินจำเป็น")
end

-- ═════════════ ส่วนท้าย: รีเซ็ต · ปุ่มลัด · สถานะท้ายหน้าต่าง · เริ่มทำงาน ═════════════
function UI.applyWindow()
    UI.applyScale(cfg.ui.scale); win.BackgroundTransparency=cfg.ui.opacity
    win.Size=UDim2.new(0,cfg.ui.w,0,UI.folded and BAR or cfg.ui.h); win.Position=UDim2.new(0,cfg.ui.x,0,cfg.ui.y); clampWin(); syncShadow()
    PK.mute=(cfg.ui.sound==false)
end
function UI.reset()
    for _,m in ipairs(UI.M) do if (ACT[m.id] or m.id=="radClone") and m.get() then m.set(false) end end
    for k,v in pairs(UI.DEF.flags) do if not ACT[k] then cfg[k]=v end end
    for k,v in pairs(UI.DEF.sub) do cfg.sub[k]=v end
    for k in pairs(picks) do picks[k]=nil end
    for k,v in pairs(UI.DEF.ui) do if k~="x" and k~="y" and k~="w" and k~="h" and k~="tab" then cfg.ui[k]=v end end
    cfg.ui.open={}
    for k in pairs(cfg.ui.keys) do cfg.ui.keys[k]="" end
    for k,v in pairs(UI.DEF.keys) do cfg.ui.keys[k]=v end
    for _,c in ipairs(UI.cards) do c.setOpen(false,true) end
    UI.applyWindow(); applyFilter(); if UI.paintPick then UI.paintPick() end
    UI.refreshKeys(); UI.syncAll(); UI.dirty()
    feedAdd("♻ รีเซ็ตเป็นค่าเริ่มต้นแล้ว",C.good)
end
function UI.refreshKeys()
    UI.rebuildKeys()
    for _,c in ipairs(UI.cards) do if c.keyUpd then c.keyUpd() end end
    for id,b in pairs(UI.keycaps) do b.Text=UI.keyOf(id) or "—" b.TextColor3=C.txt end
    footL.Text="🖱 ลากหัว = ย้าย · ลากมุมขวาล่าง = ปรับขนาด · "..(UI.keyOf("ui") or "ไม่มีปุ่ม").." ซ่อน/แสดง · Ctrl+F ค้นหา · วางเมาส์ค้าง = คำอธิบาย"
    UI.syncAll()
end
guard(UIS.InputBegan,function(i,gpe)
    if UI.capturing and (os.clock()-UI.capturing.t>8 or i.UserInputType==Enum.UserInputType.MouseButton1) then   -- รอคีย์เกิน 8 วิ/คลิกที่อื่น = ยกเลิก (ไม่งั้นปุ่มถัดไปที่กดจะถูกผูกโดยไม่ตั้งใจ)
        UI.capturing.restore(); UI.capturing=nil
    end
    if UI.capturing then
        if i.UserInputType==Enum.UserInputType.Keyboard then
            local cap=UI.capturing; UI.capturing=nil
            local name=i.KeyCode.Name
            if name=="Escape" then cap.restore() return end
            if name=="Backspace" or name=="Delete" then cfg.ui.keys[cap.id]=""
            else
                for id,k in pairs(cfg.ui.keys) do if k==name and id~=cap.id then cfg.ui.keys[id]="" end end
                cfg.ui.keys[cap.id]=name
            end
            UI.refreshKeys(); UI.dirty()
        end
        return
    end
    if gpe or i.UserInputType~=Enum.UserInputType.Keyboard then return end
    if i.KeyCode==Enum.KeyCode.F and win.Visible and not UI.folded and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
        local old=q.Text; q:CaptureFocus(); task.delay(0.05,function() if q.Text~=old then q.Text=old end end) return
    end
    local id=UI.keyMap[i.KeyCode.Name]
    if id and UI.actBy[id] then
        local ok,err=pcall(UI.actBy[id].fn)
        if not ok then slog("hotkey "..tostring(i.KeyCode.Name).." error: "..tostring(err)) end
    end
end)
-- FPS/Ping มุมขวาล่าง
do
    local acc,n=0,0
    guard(RunS.RenderStepped,function(dt)
        acc+=dt; n+=1
        if acc>=0.5 then
            local fps=n/acc; acc=0; n=0
            if win.Visible and not UI.folded then
                local ok,pg=pcall(function() return LP:GetNetworkPing() end)
                footR.Text=string.format("FPS %d  ·  Ping %s",fps,ok and tonumber(pg) and (math.floor(pg*1000+0.5).."ms") or "—")
            end
        end
    end)
end
-- กราฟิกตอนเริ่ม: ใส่ค่าที่โหลดมา · autostart คืนสวิตช์ฟาร์ม
do local vx,vy=vp() cfg.ui.w=math.min(cfg.ui.w,math.max(560,vx-20)) cfg.ui.h=math.min(cfg.ui.h,math.max(400,vy-20)) end
UI.applyWindow()
UI.refreshKeys()
if cfg.ui.tab=="search" or not UI.tabBy[cfg.ui.tab] then cfg.ui.tab="dash" end
UI.go(cfg.ui.tab)
applyFilter()
if cfg.ui.autostart and UI.pendM then for id,v in pairs(UI.pendM) do local m=UI.mBy[id] if m and v==true and not m.get() then m.set(true) end end end
UI.pendM=nil
UI.syncAll()
UI.show(true)
if UI.loaded then slog("ui: โหลดค่าจาก "..UI.FILE) end
task.delay(2,function()   -- ตรวจเลย์เอาต์จริงของ engine หลังขึ้นจอ 2 วิ (log ไว้ให้ดูเมื่อหน้าตาเพี้ยน)
    if not alive() then return end
    pcall(function()
        local a=win.AbsoluteSize; local c=content.AbsoluteSize; local pg=UI.tabBy[UI.curTab].page
        local first for _,x in ipairs(pg:GetChildren()) do if x:IsA("Frame") and tostring(x.Name):find("^Card_") then first=x break end end
        local fs=first and first.AbsoluteSize
        slog(("ui check: win=%dx%d content=%dx%d canvasY=%d firstCard=%s scale=%.2f"):format(a.X,a.Y,c.X,c.Y,pg.AbsoluteCanvasSize.Y,fs and (math.floor(fs.X).."x"..math.floor(fs.Y)) or "-",uiScale.Scale))
        if (fs and fs.Y<20) or (first==nil and pg.AbsoluteCanvasSize.Y<60 and UI.curTab~="dash") then
            feedAdd("⚠ เลย์เอาต์ UI อาจผิดปกติ (การ์ดสูงเป็นศูนย์) — ส่งไฟล์ hz_mine_log.txt ให้ผู้พัฒนา",C.warn)
        end
    end)
end)
if not UI.loaded then feedAdd("💡 ยินดีต้อนรับ — "..(UI.keyOf("ui") or "RightShift").." ซ่อน/แสดง · Ctrl+F ค้นหา · คลิก > ที่การ์ดเพื่อกางตัวเลือก · ปุ่ม ⛔ = หยุดทุกระบบ",C.accent) end
end   -- do (UI v6)

-- ============ 📊 อัปเดตสถานะสด (เรียกจาก render loop ทุก 0.25 วิ) ============
function UI.bagVisible() return UI.win.Visible and UI.curTab=="bag" and not UI.searching and not UI.folded end
function UI.hud(h)
    UI.last=h
    UI.updMini()
    if not UI.win.Visible or UI.folded or UI.searching then return end
    local w=UI.w
    if UI.curTab=="dash" then
        local ratio=h.cap>0 and math.clamp(h.bag/h.cap,0,1) or 0
        w.money.v.Text="$"..comma(h.coins); w.money.s.Text=h.quote and ("กระเป๋า ≈ $"..comma(h.quote)) or "Coins"
        w.bag.v.Text=string.format("%.1f / %d kg",h.bag,h.cap); w.bag.s.Text=h.full and "⚠ เต็ม!" or string.format("%d%%",ratio*100)
        w.bag.bar.Size=UDim2.new(ratio,0,1,0); w.bag.bar.BackgroundColor3=(h.full or ratio>=0.92) and C.bad or (ratio>=0.7 and C.warn or C.on)
        w.pick.v.Text=h.pick; w.pick.s.Text=h.pickSub
        w.warm.v.Text=tostring(h.warm); w.warm.v.TextColor3=h.cold and Color3.fromRGB(120,190,255) or C.txt; w.warm.s.Text=h.cold and "🥶 หนาวอยู่!" or "ปลอดภัย"
        w.hit.v.Text=(h.hrate and h.hrate>0) and string.format("%.1f /วิ",h.hrate) or "—"; w.hit.s.Text=h.hitSub
        w.reach.v.Text=h.reachV; w.reach.s.Text=h.reachS
        local ss=h.ss
        w.got.v.Text=ss.n.." ชิ้น"; w.got.s.Text=string.format("⏱ %d:%02d ที่ผ่านมา",math.floor(h.el/60),math.floor(h.el%60))
        w.sold.v.Text="$"..comma(ss.sold); w.sold.s.Text=(h.el>90 and ss.sold>0) and ("≈ $"..comma(ss.sold/(h.el/3600)).." /ชม.") or "ยังไม่พอคำนวณ"
        local mc,mr; if PK.mtNow then mc,mr=PK.mtNow() end
        w.mtn.v.Text=mc and tostring(mc) or "—"; w.mtn.s.Text="หมุน/รีแรร์ใน "..(mr or "—")
        w.misc.v.Text=h.weather~="" and h.weather or "ปกติ"; w.misc.s.Text="สภาพอากาศตอนนี้"
        w.dry.v.Text=h.dry and ("x"..h.dry) or "0"; w.dry.s.Text="ขุดไม่เจอแรร์ติดกัน (ตัวนับของเกม)"
        local el=h.el; w.time.v.Text=string.format("%d:%02d:%02d",math.floor(el/3600),math.floor(el%3600/60),math.floor(el%60)); w.time.s.Text="นับตั้งแต่โหลดสคริปต์"
    elseif UI.curTab=="bag" then
        local ratio=h.cap>0 and math.clamp(h.bag/h.cap,0,1) or 0
        UI.bagTxt.Text=string.format("%.1f / %d kg",h.bag,h.cap); UI.bagVal.Text=h.quote and ("≈ $"..comma(h.quote)) or ""
        UI.bagBar.Size=UDim2.new(ratio,0,1,0); UI.bagBar.BackgroundColor3=(h.full or ratio>=0.92) and C.bad or (ratio>=0.7 and C.warn or C.on)
    end
end

-- 📡 เรด้าเดิน ฟรี: fire Equipped connection ตรงๆ → RadarClient เปิด HUD+scan จริง แต่ tool ค้างกระเป๋า
-- = TimeLeft ไม่ไหม้ (server เห็นว่าไม่ถือ) + พลั่วยังถือ = ขุดได้ · SetAttribute TimeLeft=3600 ให้ HUD โชว์ 60 นาที
PK.hudVis=function()
    local gui=LP:FindFirstChild("PlayerGui"); gui=gui and gui:FindFirstChild("RadarHudGui")
    local fr=gui and (gui:FindFirstChild("Panel") or gui:FindFirstChildWhichIsA("GuiObject"))
    return fr and fr.Visible or false
end
-- ตัด conn Unequipped ของ RadarClient → เกมไม่มีทาง stop() HUD ได้อีก
-- 3 ชั้น: Disable → Disconnect → hookfunction ตัว listener เป็น no-op (ชั้นสุดท้ายรับประกันแน่)
PK.sever=function(t)
    local n=0; cfg._radSevered=cfg._radSevered or {}
    for _,c in pairs(getconnections(t.Unequipped)) do
        n+=1; table.insert(cfg._radSevered,c)
        pcall(function() c:Disable() end) pcall(function() c:Disconnect() end)
        pcall(function()
            local f=c.Function
            if f and hookfunction then hookfunction(f,function() end) end
        end)
        if not cfg._sevQuiet then slog("sever conn "..n.." fn="..tostring(c.Function~=nil).." en="..tostring(c.Enabled)) end
    end
    return n
end
-- 🎯 โหมดถาวรจริง: หา RadarClient.stop() ใน GC แล้ว hookfunction เป็น no-op
-- stop เป็นฟังก์ชัน Lua ที่เกมเรียกตอน Unequipped/AncestryChanged/CharacterRemoving → Frame.Visible=false + t3=nil
-- upvalues ของมัน: {t3(ref), v8(Color3), Frame=RadarHudGui.Panel, UIStroke} — 4 ตัว ไม่มีฟังก์ชัน (start มี stop เป็น upvalue → เกิน 8 ตัว+มีฟังก์ชัน ตัดทิ้ง)
-- ฆ่า stop → ถือแล้วปล่อยทูลจริงครั้งเดียว: start() ทำงาน → HUD+scan(t3) ค้างถาวรไม่มีทางถูกซ่อน (server เผาเวลาแค่ช่วงถือ ~0.4s)
PK.hookRadarStop=function()
    if cfg._stopFn then return cfg._stopFn end
    if not (getgc and hookfunction) then return nil end
    local gui=LP:FindFirstChild("PlayerGui"); gui=gui and gui:FindFirstChild("RadarHudGui")
    local fr=gui and gui:FindFirstChild("Panel")
    if not fr then return nil end
    local isl=isluaufunction or islclosure
    local getup=(debug and debug.getupvalue) or getupvalue
    if not (isl and getup) then return nil end
    for _,f in ipairs(getgc(true)) do
        if type(f)=="function" and isl(f) then
            local hasF,hasS,hasFn,n=false,false,false,0
            for i=1,10 do
                local r={pcall(getup,f,i)}
                if not r[1] then break end
                local v=r[#r]; if v==nil then break end   -- debug.getupvalue คืน (name,value) → เอาตัวสุดท้าย
                n+=1
                if v==fr then hasF=true
                elseif typeof(v)=="Instance" and v:IsA("UIStroke") then hasS=true
                elseif type(v)=="function" then hasFn=true end
            end
            if n>=3 and n<=8 and hasF and hasS and not hasFn then
                local ok,orig=pcall(hookfunction,f,function() end)
                if ok and orig then
                    cfg._stopFn=f; cfg._stopOrig=orig; slog("radar gc: hook stop() สำเร็จ")
                    return f
                end
            end
        end
    end
    return nil
end
PK.unhookRadarStop=function()
    if cfg._stopFn and cfg._stopOrig then pcall(hookfunction,cfg._stopFn,cfg._stopOrig) end
    cfg._stopFn=nil; cfg._stopOrig=nil
end
-- ยิง Equipped ทุกช่องทาง (Fire + Function ตรง) เผื่อ executor รองรับแบบใดแบบหนึ่ง
PK.fireEq=function(t)
    local n=0
    for _,c in pairs(getconnections(t.Equipped)) do
        n+=1
        pcall(function() c:Fire() end)
        pcall(function() local f=c.Function if f then f() end end)
    end
    return n
end
-- 📡 เรด้าโคลนเต็มระบบ: cloneRadar (รีเฟรช TimeLeft เอง = เวลาไม่หมด) → ฆ่า stop() → ถือครั้งเดียว → ปล่อย → HUD+scan ค้าง ขุดได้
-- ของโคลน server ไม่รู้จัก → ไม่เผาเวลาอยู่แล้ว · watchdog รีโคลนถ้าทูลหาย/HUD หล่น (respawn)
function PK.radCloneGo()
    local id=cfg.sub.radCloneType or "ZenithRadar"
    local t=cfg._rcT; if not (t and t.Parent) then t=PK.cloneRadar(id) end
    if not t then return false end
    cfg._rcT=t
    local ch=LP.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    PK.hookRadarStop()                                             -- ฆ่า stop() (Panel สร้างตอน RadarClient บูต → hook ได้ตลอด)
    if not cfg._stopFn and getconnections then PK.sever(t) end     -- hookfunction ไม่มี → ตัด conn Unequipped ของโคลนแทน
    pcall(function() hum:EquipTool(t) end)
    task.wait(0.35)
    if PK.hudVis() then
        pcall(function() hum:UnequipTools() end)
        task.wait(0.15)
        local bp=LP:FindFirstChild("Backpack")
        for _,tt in ipairs((bp and bp:GetChildren()) or {}) do
            if PK.isPick(tt) then pcall(function() hum:EquipTool(tt) end) break end   -- คืนพลั่ว ขุดต่อได้
        end
        cfg._rcHud=true   -- HUD เคยขึ้นแล้ว → watchdog มีสิทธิ์ซ่อมเมื่อหล่น
        return true
    end
    cfg._rcHud=false      -- HUD ไม่เคยขึ้น → อย่าให้ watchdog ดีดพลั่วจากมือทุก 2.5s
    return false   -- HUD ไม่ขึ้น = ทูลยังถืออยู่ในมือ ใช้ได้อยู่ดีแค่ขุดไม่ได้ชั่วคราว
end
function PK.radClone(on)
    if on then
        cfg.radClone=true
        task.spawn(function()
            local ok=PK.radCloneGo()
            if feedAdd then feedAdd(ok and "📡 เรด้าโคลน ON — HUD+scan ทำงาน เวลาไม่หมด ขุดได้ตลอด" or "📡 โคลนเรด้าแล้ว — HUD ไม่ขึ้น ถือเรด้าค้างใช้เอง",4,ok and Color3.fromRGB(90,235,255) or C.dim) end
            slog("radClone on hud="..tostring(ok))
        end)
        if not cfg._rcLoop then cfg._rcLoop=true   -- watchdog: ทูลโคลนหาย (respawn)/HUD หล่น → โคลน+เปิดใหม่
            task.spawn(function()
                while alive() do
                    local t=cfg._rcT
                    if cfg.radClone and (not (t and t.Parent) or (cfg._rcHud and not PK.hudVis())) then PK.radCloneGo() end
                    task.wait(2.5)
                end
            end)
        end
        sfx("pop")
    else
        cfg.radClone=false
        local orig=cfg._stopOrig; PK.unhookRadarStop()
        if orig then pcall(orig) end   -- คืน stop จริง → เกมปิด HUD เอง
        for _,pa in ipairs({LP:FindFirstChild("Backpack"),LP.Character}) do
            if pa then for _,t in ipairs(pa:GetChildren()) do
                if t:IsA("Tool") and t:GetAttribute("_hzclone") and t:GetAttribute("RadarType") then pcall(function() t:Destroy() end) end
            end end
        end
        cfg._rcT=nil; cfg._rcHud=nil; slog("radClone off"); if feedAdd then feedAdd("📡 เรด้าโคลน OFF",C.dim) end
    end
end


function PK.pickOn() return cfg.pickMode and next(picks)~=nil end
-- อ่านชื่อ+rarity จากดัชนีเกมจริง (IndexGui.Window.Grid.<Name> {Rarity}) + ชื่อไทยจาก Translator
function PK.loadNames()
    local n=0
    local grid=LP:FindFirstChild("PlayerGui")
    local ig=grid and grid:FindFirstChild("IndexGui")
    local g=ig and ig:FindFirstChild("Window") and ig.Window:FindFirstChild("Grid")
    if g then for _,c in ipairs(g:GetChildren()) do
        if c:IsA("Frame") then PK.nameRarity[c.Name]=c:GetAttribute("Rarity") or "?" PK.nameCard[c.Name]=c n+=1 end
    end end
    -- fallback: ชื่อที่เคยเจอในแมพ (tracked/known)
    for m,r in pairs(known) do local nm=m:GetAttribute("GemName") or m.Name if not PK.nameRarity[nm] then PK.nameRarity[nm]=r n+=1 end end
    return n
end
-- ดัชนีจริง: การ์ดที่ "มีแล้ว" เกมโชว์ชื่อ การ์ดที่ยังไม่เคยได้โชว์ "???"
function PK.ownedCard(nm)
    local c=PK.nameCard[nm] local l=c and c:FindFirstChild("GemName")
    return l and l.Text~="???" or false
end
function PK.localizeNames()
    if not PK.TR then
        if PK.TRt and os.clock()-PK.TRt<15 then return false end   -- translator ยังไม่พร้อม → รอ 15 วิค่อยลองใหม่
        PK.TRt=os.clock()
        local ok,t=pcall(function() return game:GetService("LocalizationService"):GetTranslatorForPlayerAsync(LP) end)
        PK.TR=(ok and t) or false
    end
    local changed=false
    for nm,card in pairs(PK.nameCard) do
        if not PK.thNames[nm] then
            local pretty=nm:gsub("(%l)(%u)","%1 %2")
            local lbl=card and card:FindFirstChild("GemName")
            local res=nil
            if PK.TR then local ok2,r=pcall(function() return PK.TR:Translate(lbl or card, pretty) end) if ok2 and type(r)=="string" then res=r end end
            if (not res or res==pretty or res=="") and lbl then
                local ok3,lt=pcall(function() return lbl.LocalizedText end)   -- property localize ของ label (ถ้า Roblox เติม)
                if ok3 and type(lt)=="string" and lt~="" then res=lt end
            end
            if res and res~="" and res~=pretty then PK.thNames[nm]=res changed=true end
        end
    end
    -- ชื่อไทยมาแล้ว → repaint ป้าย ESP ที่วาดไปแล้วด้วย
    if changed then for m,e in pairs(tracked) do
        e.t1.Text=PK.t1(m,e.id,e.mut,m:GetAttribute("Freed"))
    end end
    return changed
end
function PK.liveCounts()  -- นับสดทั้งแมพครั้งเดียว → map (O(n) แทน 398×n)
    local t={}
    for m in pairs(known) do local nm=m:GetAttribute("GemName") or m.Name t[nm]=(t[nm] or 0)+1 end
    return t
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
PK.mtNow=function()   -- (ชื่อภูเขาตอนนี้, เวลาหมุนถัดไป) — ใช้โชว์ในภาพรวม
    local cur=mtCur(); local nm=cur
    for _,e in ipairs(mtData) do if e.id==cur then nm=e.name break end end
    return nm,mtRotTxt()
end
local function refreshMtn()
    local cur=mtCur()
    local rot=mtRotTxt()
    UI.mtCard.descL.Text="ตอนนี้: "..tostring(cur or "—").." · หมุนใน "..rot
    for id,x in pairs(mtBtns) do x.tag.Visible=(id==cur) x.b.BackgroundColor3=(id==cur) and C.buy or C.opt end
    UI.mtInfo.Text=string.format("โควตาสวิตช์ภูเขาที่เหลือ: %d · หมุนรอบถัดไปใน: %s",tonumber(LP:GetAttribute("MountainSwitches")) or 0,rot)
end
local function buildMtn()
    for _,c in ipairs(UI.mtList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    mtBtns={}
    table.sort(mtData,function(a,b) return a.rank>b.rank end) -- ดีสุดขึ้นก่อน
    for i,e in ipairs(mtData) do
        if e.released then
            local b=UI.btn(UI.mtList,{Size=UDim2.new(1,0,0,30),BackgroundTransparency=0,BackgroundColor3=C.opt,LayoutOrder=i}); corner(b,7)
            local im=e.img or UI.mtnImage(e.id)
            if im then UI.mk("ImageLabel",{BackgroundTransparency=1,Image=im,Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,6,0.5,-10),ZIndex=2},b) end
            UI.lbl(b,{Text=e.name,Position=UDim2.new(0,im and 32 or 10,0,0),Size=UDim2.new(1,-(im and 172 or 150),1,0),TextSize=12,TextColor3=mtColor(e.rarity),TextTruncate=Enum.TextTruncate.AtEnd})
            UI.lbl(b,{Text=PK.thR(e.rarity),Position=UDim2.new(1,-140,0,0),Size=UDim2.new(0,90,1,0),TextSize=10,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right})
            local tag=UI.lbl(b,{Text="✓ อยู่ที่นี่",Position=UDim2.new(1,-62,0,0),Size=UDim2.new(0,56,1,0),TextSize=10,TextColor3=C.on,Visible=false,TextXAlignment=Enum.TextXAlignment.Right})
            b.MouseEnter:Connect(function() if e.id~=mtCur() then UI.tw(b,0.1,{BackgroundColor3=C.optH}) end end)
            b.MouseLeave:Connect(function() UI.tw(b,0.12,{BackgroundColor3=(e.id==mtCur()) and C.buy or C.opt}) end)
            b.Activated:Connect(function()
                if not MtChoose then feedAdd("❌ ไม่พบช่องทางเลือกภูเขา",Color3.fromRGB(255,120,120)) return end
                if e.id==mtCur() then feedAdd("🏔️ อยู่ "..e.name.." อยู่แล้ว",C.dim) return end
                MtChoose:FireServer(e.id); sfx("pop")
                feedAdd("🏔️ เลือก "..e.name.." ("..PK.thR(e.rarity)..")",mtColor(e.rarity))
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
        feedAdd("🏔️ ขึ้นอัตโนมัติ → "..best.name,mtColor(best.rarity)); slog("mtn auto "..best.id)
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
            mtData[#mtData+1]={id=v.id,name=v.name or v.id,rarity=v.rarity or "?",rank=i,released=rel,img=v.image}
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
        if not alive() then return end   -- generation เก่าไม่ทำงานซ้ำ (ล็อกจริงเคย WIPE ซ้ำ 22 ครั้งในวินาทีเดียว)
        -- ภูเขาเปลี่ยน = แรร์ทั้งเซิร์ฟเวอร์รีใหม่ → ล้าง registry ทั้งหมด ไม่เก็บของเก่า
        wiping=true; wipeEnd=os.clock()+10
        doWipe("ภูเขาเปลี่ยน → "..tostring(MtState.Value))
        refreshMtn(); task.delay(2,mtnAutoBest)
    end)
    if MtRot then MtRot.Changed:Connect(function() if not alive() then return end task.delay(3,function() if alive() then refreshMtn() mtnAutoBest() end end) end) end
    task.delay(4,function() if alive() then refreshMtn() end end)
end)
task.spawn(function() while alive() do   -- เวลาหมุนนับถอยหลังสด (วินาทีละครั้ง เฉพาะตอนเปิดดูแท็บโลก)
    if UI.win.Visible and UI.curTab=="world" and not UI.folded and #mtData>0 then pcall(refreshMtn) end
    task.wait(1)
end end)

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
            if PK.isPick(t) then hum:EquipTool(t) break end
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
    if not (CBEquip and SellReq) then feedAdd("❌ ไม่พบช่องทางขาย",Color3.fromRGB(255,120,120)) if done then done() end return end
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
    local lst=UI.bagList
    for _,c in ipairs(lst:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local items=SL.bag()
    UI.bagEmpty.Visible=(#items==0)
    for i,d in ipairs(items) do
        local r=d:GetAttribute("Rarity") or "Common"
        local col=TCOL[r] or C.txt
        local b=UI.btn(lst,{Size=UDim2.new(1,0,0,30),BackgroundTransparency=0,BackgroundColor3=C.opt,LayoutOrder=i}); corner(b,7)
        UI.mk("Frame",{Size=UDim2.new(0,3,0,18),Position=UDim2.new(0,4,0.5,-9),BackgroundColor3=col,BorderSizePixel=0},b)
        local fav=d:GetAttribute("Favorited") and " ⭐" or ""
        UI.lbl(b,{Text=PK.dispName(d:GetAttribute("GemName") or "?")..fav,Position=UDim2.new(0,14,0,0),Size=UDim2.new(1,-200,1,0),TextSize=11,TextColor3=col,TextTruncate=Enum.TextTruncate.AtEnd})
        UI.lbl(b,{Text=string.format("%s · %.1fkg",PK.thR(r),d:GetAttribute("Kg") or 0),Position=UDim2.new(1,-186,0,0),Size=UDim2.new(0,100,1,0),TextSize=10,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right})
        UI.lbl(b,{Text="$"..comma(d:GetAttribute("Value") or 0),Position=UDim2.new(1,-84,0,0),Size=UDim2.new(0,78,1,0),TextSize=11,TextColor3=C.on,TextXAlignment=Enum.TextXAlignment.Right})
        b.MouseEnter:Connect(function() UI.tw(b,0.1,{BackgroundColor3=C.optH}) end)
        b.MouseLeave:Connect(function() UI.tw(b,0.12,{BackgroundColor3=C.opt}) end)
        b.Activated:Connect(function() sfx("tick") SL.sellOne(d,true) end)
    end
end
PK.sellAllNow=function()
    if SellReq then SellReq:FireServer("All"); sfx("pop"); feedAdd("💰 ยิงขายทั้งหมด (ตรงนี้)",Color3.fromRGB(255,220,120)) end
end
PK.sellEach=function() SL.each() end
task.spawn(function() while alive() do
    if UI.bagVisible() then pcall(SL.refresh) end
    task.wait(2)
end end)
-- SellResult → feed (count, money, itemName, err) — 16_SellerMenuClient:811
task.spawn(function()
    while not SellRes do task.wait(0.5) if not alive() then return end end
    SellRes.OnClientEvent:Connect(function(cnt,money,item,err)
        if not alive() then return end
        if err then PK.sellHold=os.clock()+30; slog("sell fail: "..tostring(err)); feedAdd("💰 ขายไม่ได้: "..tostring(err),Color3.fromRGB(255,120,120))   -- ขายไม่ได้ (เช่นมีแต่ ⭐ ในกระเป๋า) → เว้น 30s ไม่ยิงซ้ำถล่ม
        elseif item then feedAdd(string.format("💰 ขาย %s = $%s",item,comma(money or 0)),Color3.fromRGB(120,255,160))
        elseif (cnt or 0)>0 then feedAdd(string.format("💰 ขาย %d ชิ้น = $%s",cnt,comma(money or 0)),Color3.fromRGB(120,255,160)) end
        if not err and (tonumber(cnt) or 0)>0 then PK.ss.sold+=tonumber(money) or 0 end
    end)
    slog("sellres-hook")
end)
end
-- ===== UI-V6-END =====

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
            if wipeN>40 and not wiping and now-(PK.moveT or -99)>15 then   -- วาป/ขายทิ้งโมเดลหลุด stream พร้อมกัน ≠ server รีแรร์
                wiping=true; wipeEnd=now+5
                doWipe("server รีแรร์ (despawn "..wipeN.."+)")
            end
            -- หายหลัง GemCollected ของชื่อนี้ <3 วิ = ถูกเก็บจริง → ลบทิ้ง ไม่ทำ ghost
            if wiping or (lastCollect[e.id] and now-lastCollect[e.id]<3) then
                known[m]=nil knownPos[m]=nil
            -- พื้นที่ unstream → ค้างพิกัดเดิมใน registry (บอทยังนำทางไปได้) — ไม่มี ghost visual แล้ว
            elseif e.lastPos and wantShow(e.rarity,e.id) then
                local dup=false
                for _,pe in ipairs(pings) do if (pe.pos-e.lastPos).Magnitude<10 then dup=true pe.t=os.clock() break end end
                if not dup then
                    pings[#pings+1]={pos=e.lastPos,rarity=e.rarity,kg=e.kg,t=os.clock(),sticky=true,id=e.id,owner=e.owner}
                end
            end
        else
            local on=wantShow(e.rarity,e.id,e.kg)
            local hOn=on and cfg.sub.espHl; local bOn=on and cfg.sub.espName
            e.on=on
            local hlWant=hOn and e.near==true    -- Roblox วาด Highlight ได้สูงสุด 31 อัน → เปิดเฉพาะ 24 ตัวที่ใกล้สุด (ป้ายชื่อยังโชว์ทุกตัว) · ตัวใหม่รอจัดอันดับ ≤0.25s ก่อนเปิด
            if e.hl.Enabled~=hlWant then e.hl.Enabled=hlWant end
            if e.bb.Enabled~=bOn then e.bb.Enabled=bOn end
            if on and updL and hrp then
                local ok,p=pcall(function() return m:GetPivot().Position end)
                if ok and p then
                    e.lastPos=p; e.dist=(p-hrp.Position).Magnitude
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
                        e.t1.Text=PK.t1(m,e.id,mut,fr)
                    end
                    local lk=""
                    if cfg.sub.espLuck and GD and GD.effectiveLuck then
                        local ok2,l=pcall(GD.effectiveLuck,e.rarity,e.kg,e.mut,nil,e.core,e.id)
                        if ok2 and type(l)=="number" then lk=(" · 🍀%.0f"):format(l) end
                    end
                    e.t2.Text=string.format("%s%s · %.1fkg · %dm%s%s",PK.thR(e.rarity),e.sz and (" ["..e.sz.."]") or "",e.kg,(p-hrp.Position).Magnitude,hpt,lk)
                end
            end
        end
    end
    if updL and hrp then   -- จัดอันดับระยะ → 24 ตัวใกล้สุดได้ Highlight · ตรวจวาป (>120 studs ใน 0.25s) กัน mass-despawn detector เข้าใจผิดว่า server รีแรร์
        local arr={}
        for _,e in pairs(tracked) do if e.on and e.dist then arr[#arr+1]=e end end
        table.sort(arr,function(a,b) return a.dist<b.dist end)
        for i,e in ipairs(arr) do e.near=(i<=24) end
        local lp2=PK.lp2; if lp2 and (hrp.Position-lp2).Magnitude>120 then PK.moveT=now; wipeN=0 end
        PK.lp2=hrp.Position
    end
    -- pings: registry พิกัดล้วน (ไม่มี ghost visual) — เคลียร์ตัวหมดอายุ, sticky ค้างถาวร
    for i=#pings,1,-1 do
        local e=pings[i]
        if not e.sticky and now-e.t>cfg.ttl then PK.rmFar(e) table.remove(pings,i) end
    end
    while #pings>600 do PK.rmFar(pings[1]) table.remove(pings,1) end   -- เพดาน 600 จุด (sticky สะสมไม่จำกัดเมื่อ AFK เป็นชั่วโมง) — ทิ้งตัวเก่าสุดก่อน
    -- 📡 far markers: วาดป้ายทุก ping ที่ผ่าน filter — model ไม่ต้อง stream (ไกล 5000m ก็เห็น ทะลุกำแพง)
    local nFar=0
    for _,e in ipairs(pings) do
        if cfg.sub.espFar and nFar<80 and wantShow(e.rarity,e.id or "",e.kg) then
            if not e._a then pcall(PK.mkFar,e) end
            if e._a and hrp then
                e._t1.Text="◆ "..(e.owner==LP.UserId and "★ " or "")..PK.dispName(e.id or e.rarity); e._t1.TextColor3=TCOL[e.rarity] or C.txt
                e._t2.Text=string.format("%s · %.1fkg · %dm",PK.thR(e.rarity),e.kg or 0,(e.pos-hrp.Position).Magnitude)
            end
            nFar=nFar+1
        elseif e._a then PK.rmFar(e) end
    end
    -- 🪨 boulders: ป้ายเรด้าหิน — NeedPickaxe ✅/❌เทียบพลั่วเรา (EquippedPickaxe attr จริง) + HP% + ฝังอยู่ + ระยะ
    for m,e in pairs(PK.btracked) do
        if not m.Parent or m:GetAttribute("Broken") then
            pcall(function() e.hl:Destroy() e.bb:Destroy() end) PK.btracked[m]=nil
        else
            local on=cfg.sub.espBld
            if e.hl.Enabled~=on then e.hl.Enabled=on end
            if e.bb.Enabled~=on then e.bb.Enabled=on end
            if on and updL and hrp then
                local mesh=m:FindFirstChild("Mesh_0"); local p=mesh and mesh.Position
                if p then
                    local need=m:GetAttribute("NeedPickaxe") or "?"
                    local can=(m:GetAttribute("NeedTier") or 1)<=(LP:GetAttribute("EquippedPickaxe") or 1)
                    local hp,mh=m:GetAttribute("Hp"),m:GetAttribute("MaxHp")
                    local hpt=(hp and mh and mh>0 and hp<mh) and string.format(" · ❤%.0f%%",hp/mh*100) or ""
                    local bur=(m:GetAttribute("Revealed")~=true) and " · ฝังอยู่" or ""
                    e.t2.Text=string.format("%s⛏%s · %dm%s%s",can and "✅ " or "❌ ",tostring(need),(p-hrp.Position).Magnitude,hpt,bur)
                    e.t2.TextColor3=can and Color3.fromRGB(150,255,150) or Color3.fromRGB(255,150,150)
                end
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
    -- HUD สถานะตัวเรา + เตือนหนาว (สูตรจริงจาก FreezeClient) → ส่งตัวเลขให้ UI วาด
    if updL then
        local ls=LP:FindFirstChild("leaderstats")
        local coinV=ls and ls:FindFirstChild("Coins")
        local coins=coinV and coinV.Value or 0
        local bag=LP:GetAttribute("BagKg") or 0
        local cap=LP:GetAttribute("CarryWeight") or 0
        local warm=LP:GetAttribute("Warmth") or 120
        local pt2=LP:GetAttribute("EquippedPickaxe")
        local pd=PK.PD and PK.PD[tonumber(pt2) or 0]
        local pick=(pd and pd.name) or pickByTier[tonumber(pt2) or -1] or ("T"..tostring(pt2 or "?"))
        if pd and pd.radius then pick=pick.." r"..pd.radius end
        local wth=WState and WState.Value
        local ds=LP:GetAttribute("DryStreak")
        local rc0=PK.rc
        local eR=math.floor(math.max(PK.eBase or 12,(PK.eOk or 0)*1.3))
        local ss=PK.ss; local el=os.clock()-ss.t0   -- 📈 สถิติรอบนี้ (เก็บจาก Push pickup · ขายจาก SellResult)
        local hn=os.clock()   -- ⚔ หมัดแรร์ที่ server รับจริง/วิ (MineHit ที่เราเพิ่งกด E ใส่) เฉลี่ยทุก 5s
        if hn-(PK.hrT or 0)>=5 then if PK.hrT then PK.hrate=((PK.eHitTot or 0)-(PK.hrN or 0))/(hn-PK.hrT) end PK.hrT=hn PK.hrN=PK.eHitTot or 0 end
        UI.hud({coins=coins,bag=bag,cap=cap,full=LP:GetAttribute("BagFull")==true,warm=warm,pick=pick,
            pickSub=pd and ("พลัง "..comma(pd.power or 0).." · จังหวะ "..string.format("%.2f",PK.eInt or 0.4).."s") or "—",
            cold=PK.isCold(hrp) and true or false,quote=bagQuote,
            weather=(wth and wth~="" and wth~="NormalWeather") and tostring(wth) or "",dry=(ds and ds>0) and ds or nil,
            hrate=cfg.autodig and (PK.hrate or 0) or 0,
            hitSub=cfg.autodig and ("E ติด "..(PK.eHit or 0).." / กด "..(PK.eFire or 0).." (30 วิล่าสุด)") or "เปิดขุดออโต้เพื่อเริ่ม",
            reachV=cfg.autodig and string.format("ขุด %s%dm",(rc0.ceil or rc0.lo>=rc0.R) and "" or "~",rc0.R) or "—",
            reachS="กด E ได้ ≤ "..eR.."m",ss=ss,el=el})
    end
    -- นับรวม known (ทุกตัวที่รู้จัก) + ping แยกระดับ
    if updL and now-(PK.cntT or 0)>=1 then   -- นับตัวเลขแรร์แค่วินาทีละครั้ง (ไม่ต้อง 4 ครั้ง/วิ)
        PK.cntT=now
        local count={}
        local pl=pings
        -- hash พิกัด ping เป็นช่อง 15 studs → เช็คซ้ำ O(1)/ตัว (เดิม/ร่างแรกวน known×pings = หลักล้านเมื่อ AFK นานๆ)
        local ph={}
        for _,e in ipairs(pl) do
            local p=e.pos
            ph[math.floor(p.X/15)*73856093+math.floor(p.Y/15)*19349663+math.floor(p.Z/15)*83492791]=true
        end
        for m,r in pairs(known) do
            -- จำไว้ถาวร — unstream ≠ ถูกขุดไป, ยังนับเป็นของแมพ
            -- แต่ตัวที่ unstream แล้วมี ping (sticky) ที่จุดเดียวกัน = ตัวเดียวกัน → นับครั้งเดียว (เดิมนับซ้ำ model+ping)
            local dupe=false
            if m.Parent==nil then
                local kp=knownPos[m]
                if kp then
                    local cx,cy,cz=math.floor(kp.X/15),math.floor(kp.Y/15),math.floor(kp.Z/15)
                    for dx=-1,1 do for dy=-1,1 do for dz=-1,1 do
                        if ph[(cx+dx)*73856093+(cy+dy)*19349663+(cz+dz)*83492791] then dupe=true end
                    end end end
                end
            end
            if not dupe then count[r]=(count[r] or 0)+1 end
        end
        for _,e in ipairs(pl) do count[e.rarity]=(count[e.rarity] or 0)+1 end
        local oc=0
        local isT={} for _,t in ipairs(TIERS) do isT[t]=true end
        for r,n in pairs(count) do if not isT[r] then oc+=n end end
        UI.counts(count,oc)
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
        do  -- DigEffect ตรงช็อตที่เรายิงใน 2s = server รับช็อตนั้นแล้ว → ระยะของช็อตนั้นใช้ได้ (สัญญาณบวกแน่นอน ผูกช็อตได้)
            local rc=PK.rc; local now=os.clock(); local s=rc.shots; local bs,bd2=nil,3
            for i=#s,1,-1 do
                local e=s[i]
                if now-e.t>2 then break end
                if not e.m then local dd=(e.p-pos).Magnitude if dd<bd2 then bd2=dd bs=e end end
            end
            if bs then bs.m=true rc.acc+=1 PK.rcAcc(rc,bs.d) if rc.pr and rc.pr.p==bs.p then rc.pr=nil end end
        end
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
        if PK.isPick(t) then return t end
    end
    return nil
end
function PK.cloneRadar(id)   -- โคลนเรด้าจริงจาก RS.RadarTools — RadarClient hook RadarType เอง → HUD+scan ทำงานฝั่ง client · TimeLeft รีเฟรชเองไม่หมด (server ไม่รู้จัก = ไม่เผาเวลา)
    local src=RS:FindFirstChild("RadarTools") and RS.RadarTools:FindFirstChild(id)
    if not src then feedAdd("📡 ไม่มี template "..tostring(id).." ใน RS.RadarTools",C.dim) return nil end
    local bp=LP:FindFirstChild("Backpack"); if not bp then return nil end
    for _,t in ipairs(bp:GetChildren()) do   -- เคลียร์โคลนเก่าชนิดเดียวกันกันซ้ำ
        if t:IsA("Tool") and t:GetAttribute("_hzclone") and t:GetAttribute("RadarType")==id then pcall(function() t:Destroy() end) end
    end
    local c=src:Clone(); c:SetAttribute("_hzclone",true)
    local dur=c:GetAttribute("Duration") or 90
    c:SetAttribute("TimeLeft",dur) c:SetAttribute("Count",1)
    c.Parent=bp
    task.spawn(function()   -- server ไม่เขียน TimeLeft ให้ของโคลน → เรารีเฟรชเอง ทำให้ client countdown ไม่มีวันหมด
        while alive() and c.Parent do pcall(function() c:SetAttribute("TimeLeft",dur) end) task.wait(45) end
    end)
    feedAdd("📡 โคลน "..id.." เข้ากระเป๋า — ถือแล้ว HUD+สแกนทำงานจริง (เวลาไม่หมด)",4,Color3.fromRGB(90,235,255))
    slog("cloneRadar "..id) return c
end
-- เรด้าตัวดีสุดในกระเป๋าที่ยังเหลือเวลา (จัดลำดับ Zenith→Crystal) — ถือเฉพาะตอนเดิน = TimeLeft ไหม้แค่ตอนเดิน
function PK.radBest()
    local bp=LP:FindFirstChild("Backpack"); if not bp then return nil end
    for _,id in ipairs({"ZenithRadar","MeteorRadar","BoulderRadar","RuneRadar","RarityRadar","CrystalRadar"}) do
        for _,t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("RadarType")==id and (t:GetAttribute("TimeLeft") or 0)>1 then return t end
        end
    end
end
-- ===== RC-BEGIN: ระยะขุดที่ server รับจริง (reach) — เรียนรู้จากสัญญาณที่ผูกกับช็อตได้แน่นอนเท่านั้น (ไม่เดา) =====
-- DigEffect ตรงจุดที่เรายิง = รับแล้ว (บวกแน่) · "Too far away" ระหว่าง probe (ช่วงเงียบ ไม่มีช็อตอื่น) = เกินระยะ
-- "Too far away" ที่ไม่มี probe = ช็อตปกติเกิน → หดแบบมี debounce  (เดิม: error มาช้า+ผูกผิดช็อต → รัศมีรูดเหลือ ~12m ทั้งที่ server รับไกลกว่า)
PK.rc={R=24,lo=0,ceil=nil,cap=500,pr=nil,lastProbe=-99,lastShrink=-99,lastShot=0,win=1.6,gap=2.5,bad=0,hold=0,ang=0,
    fired=0,acc=0,farN=0,shots={},err={}}
function PK.rcReset(rc) rc.R=24 rc.lo=0 rc.ceil=nil rc.pr=nil rc.lastProbe=-99 rc.bad=0 rc.hold=0 end
function PK.rcAcc(rc,d)        -- ช็อตระยะ d ถูกรับ (DigEffect ยืนยัน) → พิสูจน์ว่าระยะ ≥ d
    rc.bad=0
    if d>rc.lo then rc.lo=d end
    if rc.ceil and d>=rc.ceil then rc.ceil=d+2 end                 -- เพดานเดิมผิด (เปลี่ยนพลั่ว/ตำแหน่ง) → ขยับ
    if rc.lo>rc.R then rc.R=rc.ceil and math.min(rc.lo,rc.ceil-1) or rc.lo end
end
function PK.rcFar(rc,now)      -- ได้ "Too far away"
    rc.farN+=1
    local p=rc.pr
    if p and now-p.t<=rc.win then                                   -- ระหว่างช่วงเงียบของ probe = error ของ probe แน่
        rc.ceil=math.min(rc.ceil or 1e9,p.d); if rc.R>=rc.ceil then rc.R=math.max(8,math.floor(rc.ceil-1)) end
        rc.pr=nil; rc.bad=0; return "probe"
    end
    if now-rc.lastShrink>1 then                                     -- ไม่มี probe = ช็อตปกติเกินระยะ → หด 15% (debounce 1s กัน error ที่ตามมาช้ารูดซ้ำ)
        rc.lastShrink=now
        rc.ceil=math.min(rc.ceil or 1e9,rc.R)
        rc.R=math.max(8,math.floor(rc.R*0.85)); if rc.lo>rc.R then rc.lo=rc.R end
        return "stray"
    end
end
function PK.rcNext(rc,now)     -- ถึงเวลา probe ไหม → ระยะที่จะลอง | nil
    if rc.pr or now<rc.hold or now-rc.lastProbe<rc.gap then return nil end
    -- ยังไม่เจอเพดาน = ไล่ขึ้นจาก max(พิสูจน์แล้ว, R) · เจอเพดานแล้ว = binary search ระหว่าง "พิสูจน์แล้ว"(lo) กับเพดาน (R ที่เดาเองไม่นับเป็นหลักฐาน)
    local L=rc.ceil and rc.lo or math.max(rc.lo,rc.R); local H=math.min(rc.ceil or rc.cap,rc.cap)
    if H-L<3 then                                                   -- ลู่เข้าแล้ว: ใช้ระยะที่พิสูจน์แล้ว ไม่ใช้ค่าเดา
        if rc.lo>0 and rc.R>rc.lo then rc.R=math.max(8,rc.lo) end
        return nil
    end
    return rc.ceil and (L+H)/2 or math.min(H,L*1.5+4)
end
function PK.rcStart(rc,now,d,p) rc.pr={d=d,t=now,p=p}; rc.lastProbe=now end
function PK.rcLose(rc,now)     -- probe ไม่ได้ข้อสรุป (จุดขุดไม่ได้/เงียบ) — ครบ 3 ครั้งพัก 20s ใช้ R เดิม ไม่เดาผล
    rc.pr=nil; rc.bad+=1
    if rc.bad>=3 then rc.bad=0 rc.hold=now+20 end
end
function PK.rcTick(rc,now)     -- หมดหน้าต่าง probe โดยไม่มีสัญญาณ
    local p=rc.pr
    if p and now-p.t>rc.win then PK.rcLose(rc,now) return true end
end
function PK.rcOther(rc,now)    -- error อื่น (safe zone / ไม่ใช่ glacier) ระหว่าง probe = จุดลองใช้ไม่ได้ → ลองมุมอื่น
    local p=rc.pr
    if p and now-p.t<=rc.win then PK.rcLose(rc,now) return true end
end
-- RC-END
function PK.shot(p,from,now,probe)   -- ยิง DigRequest + จดไว้จับคู่กับ DigEffect (accepted telemetry + เรียนรู้ระยะ)
    DigReq:FireServer(p)
    local rc=PK.rc; rc.fired+=1; rc.lastShot=now
    local e={p=p,d=(p-from).Magnitude,t=now,probe=probe}
    local s=rc.shots; s[#s+1]=e; if #s>60 then table.remove(s,1) end
    return e
end
function PK.probePt(from,d)    -- จุดบนภูมิประเทศที่ห่างจากตัว ≈ d (3D) — raycast ลงจากเหนือจุด วนมุมกระจายรอบตัว
    local rc=PK.rc; rc.ang+=2.399
    for i=0,3 do
        local a=rc.ang+i*1.571
        local dir=Vector3.new(math.cos(a),0,math.sin(a)); local h=d
        for _=1,2 do
            local hit=workspace:Raycast(from+dir*h+Vector3.new(0,120,0),Vector3.new(0,-300,0),RayParams)
            if not hit then break end
            local D=(hit.Position-from).Magnitude
            if math.abs(D-d)<=d*0.08 then return hit.Position,D end
            h=math.max(2,h*d/math.max(D,1))
        end
    end
end
PK.eBase=12; PK.eOk=0   -- ระยะ E ตามป้าย prompt (MaxActivationDistance จริงอัพเดตตอนสแกน) / ระยะไกลสุดที่ MineHit ยืนยันแล้ว (ใช้ในลูปขุด+ลูป E)
PK.bl=setmetatable({},{__mode="k"}); PK.fk=setmetatable({},{__mode="k"})   -- blacklist เป้าที่ยิงเท่าไหร่ก็ไม่ปลด / นับช็อตต่อเป้า
local lastDig=0
task.spawn(function() while alive() do
    if cfg.autodig and DigReq then
        pcall(function()
            local ch=LP.Character; if not ch then return end
            local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local tool=heldPickaxe(ch)
            local bp=LP:FindFirstChild("Backpack")                    -- ⛏ จับพลั่ว Tier สูงสุดเองทุก 1.5s (แรงสุด = ขุดไวสุด)
            if bp and os.clock()-(cfg._pickT or 0)>1.5 and not (tool and tool:GetAttribute("DrillPower")) then   -- ถือ Drill (Plasma Drill ฯ) อยู่ = ผู้เล่นเลือกเอง ไม่สลับเป็นพลั่ว
                cfg._pickT=os.clock(); local best,bt=nil,tool and (tool:GetAttribute("Tier") or 0) or -1
                for _,t in ipairs(bp:GetChildren()) do
                    if PK.isPick(t) then
                        local ti=t:GetAttribute("Tier") or 0 if ti>bt then bt=ti best=t end
                    end
                end
                if best then local h=ch:FindFirstChildOfClass("Humanoid") if h then pcall(function() h:EquipTool(best) end) tool=best end end
            end
            if not tool then return end
            local rc=PK.rc
            if PK.rcTool~=tool.Name then   -- เปลี่ยนพลั่ว → เรียนรู้ระยะใหม่ · เริ่มที่รัศมีของพลั่ว (attr DigRadius ของ Drill หรือ PickaxeData[Tier].radius 7→30 · log จริง: server รับ ~11-12m) แล้ว probe ขยายต่อ
                PK.rcTool=tool.Name; PK.rcReset(rc)
                local pd0=PK.PD and PK.PD[tonumber(tool:GetAttribute("Tier")) or 0]
                local dr=tonumber(tool:GetAttribute("DigRadius")) or (pd0 and tonumber(pd0.radius)); if dr and dr>=6 then rc.R=dr end
            end
            local cd=(tool:GetAttribute("Cooldown") or tool:GetAttribute("DigCooldown") or 0.4)
            if LP:GetAttribute("Pass_FastDig2x")==true or os.time()<(LP:GetAttribute("MiningPotionUntil") or 0) then cd=cd*0.5 end
            cd=cd/math.max(LP:GetAttribute("RuneHaste") or 1,1)
            local now=os.clock()
            -- turbo = ถี่กว่า cooldown ~3x + jitter (0 ms ล้วน = ยิง >100 req/s ผิดปกติ เสี่ยงโดน server จับ — NOTES: "ใช้ 0.12s+jitter")
            local step=cfg.sub.turboDig and math.max(0.06,cd*0.35)*(0.85+math.random()*0.3) or cd
            PK.step=step; PK.cd=cd
            if now-lastDig<step then return end
            PK.rcTick(rc,now)
            if rc.pr then return end                                 -- probe รอผลอยู่: เงียบ ไม่ยิงอย่างอื่น (แยก error ว่าเป็นของ probe ได้แน่)
            if LP:GetAttribute("IsMiningGem") then return end        -- อยู่ในเซสชันตีแรร์: สวิงพลั่วโดนบล็อก (บอทเก่าก็หยุดเหมือนกัน)
            if now<(rc.hold2 or 0) then return end                   -- ที่นี่ขุดไม่ได้ (safe zone/ไม่ใช่ glacier ซ้ำๆ ไม่มีช็อตไหนรับ) → พักสั้นๆ ไม่ยิงถล่ม server
            local from=hrp.Position
            local eR=math.max(PK.eBase,PK.eOk*1.3)   -- ระยะที่ "กด E ถึง" (ป้าย prompt / ที่ MineHit ยืนยัน ×1.3)
            -- 🔭 probe ระยะ: ถึงเวลา → รอเงียบ 0.45s (server cooldown ไม่กลืนช็อต) → ยิงจุดเดียว → รอสัญญาณ
            -- probe เฉพาะเมื่อมีประโยชน์: เปิด 🔭 ปลดไกล หรือระยะขุดที่รู้ยังสั้นกว่าระยะ E (ปกติขุดแค่ในระยะ E อยู่แล้ว ไม่ต้องยิงสำรวจไกลๆ ทิ้งหลุมไกลตัว)
            local pd=(cfg.sub.digFar or rc.R<eR) and PK.rcNext(rc,now) or nil
            if pd then
                if now-rc.lastShot<math.max(0.45,cd*1.3) then return end   -- เงียบอย่างน้อย 1.3× cooldown พลั่ว (server ทิ้งช็อตที่มาติดกัน → จะกลายเป็น inconclusive)
                local pp,D=PK.probePt(from,pd)
                if pp then PK.rcStart(rc,now,D,pp) PK.shot(pp,from,now,true) lastDig=now else rc.lastProbe=now end
                return
            end
            lastDig=now
            -- 🎯 เป้าแรร์ฝัง = ของเราเท่านั้น (Owner==เรา) ที่ยังไม่ Freed — ยิงที่ pivot ตรงๆ เหมือนบอทเก่าที่พิสูจน์แล้วว่าตีติด
            -- (เดิม: ยิงจุดผิว raycast + รวมแรร์คนอื่น + พิกัด ping ของ Freed ที่ไม่ใช่เป้าฝัง → ไม่เคยโดน แถมระยะรูด)
            local sgm=workspace:FindFirstChild("SpawnedGems")
            if sgm and now-buriedT>0.8 then
                buriedT=now; table.clear(buriedCache)
                local uid=LP.UserId
                PK.ownCnt={}
                for _,m in ipairs(sgm:GetChildren()) do
                    if m:IsA("Model") and m:GetAttribute("BuriedAt")~=nil and not m:GetAttribute("Freed") and not m:GetAttribute("Dropped") then
                        local ow=m:GetAttribute("Owner"); local ri=rIdx(m:GetAttribute("Rarity"))
                        PK.ownCnt[tostring(ow)]=(PK.ownCnt[tostring(ow)] or 0)+1
                        if (ow==nil or ow==uid) and ri>=cfg.botTier and (PK.bl[m] or 0)<now then
                            local ok2,cf=pcall(m.GetPivot,m)
                            if ok2 then buriedCache[#buriedCache+1]={p=cf.Position,m=m,r=ri} end
                        end
                    end
                end
            end
            local R=rc.R
            -- ปลดแรร์ฝังเฉพาะที่ "กด E ถึง" (ระยะ E = MaxActivationDistance×1.5 หรือที่ MineHit ยืนยัน) — ปลดไกลเกินระยะ E = แรร์โผล่ค้างตีไม่ได้ (เสี่ยงหายตาม FreedAt/โดนแย่ง)
            -- เปิด "🔭 ปลดไกลถึงระยะขุด" (digFar) ถ้าอยากปลดไว้ก่อนแล้วค่อยเดินไปเก็บ
            local Dmax=cfg.sub.digFar and R or math.min(R,eR)
            local nG=0
            if sgm and now-(PK.digDbg or 0)>10 then PK.digDbg=now
                local tot,inE,inR=#buriedCache,0,0
                for _,e in ipairs(buriedCache) do local d=(e.p-from).Magnitude if d<=eR then inE+=1 end if d<=R then inR+=1 end end
                local ow={} for k,v in pairs(PK.ownCnt or {}) do ow[#ow+1]=k..(k==tostring(LP.UserId) and "(me)" or "").."×"..v end
                table.sort(ow,function(a,b) return a<b end)
                if inE==0 and inR>0 and feedAdd and now-(PK.hintT or 0)>60 then PK.hintT=now
                    feedAdd(("💡 แรร์ฝังของเรา %d ตัวอยู่ในระยะขุดแต่ไกลเกินระยะ E (%dm) — เดินเข้าใกล้ หรือเปิด 🔭 ปลดไกล"):format(inR,eR),Color3.fromRGB(255,215,120))
                end
                slog(("dig dbg: แรร์ฝังของเรา %d ตัว | ≤ระยะE(%dm) %d | ≤ระยะขุด(%dm) %d | ยิงถึง ≤%dm | Owner ที่เห็น (me=%d): %s"):format(tot,eR,inE,R,inR,Dmax,LP.UserId,#ow>0 and table.concat(ow," ") or "-"))
            end
            if sgm and (cfg.sub.aoeDig or cfg.sub.smartDig) and #buriedCache>0 then
                local cand={}
                for _,e in ipairs(buriedCache) do
                    local d=(e.p-from).Magnitude
                    if d<=Dmax and e.m.Parent and not e.m:GetAttribute("Freed") then cand[#cand+1]={e=e,d=d} end
                end
                table.sort(cand,function(a,b) if a.e.r~=b.e.r then return a.e.r>b.e.r end return a.d<b.d end)   -- แรร์สูงก่อน แล้วใกล้ก่อน
                for i=1,math.min(#cand,cfg.sub.aoeDig and 10 or 1) do
                    local m=cand[i].e.m
                    PK.shot(cand[i].e.p,from,now); nG+=1
                    local k=PK.fk[m] or {n=0}; PK.fk[m]=k; k.n+=1
                    if k.n>=14 then PK.bl[m]=now+25; PK.fk[m]=nil; slog(("blacklist เป้าที่ยิงไม่ปลด %s %s @%dm"):format(tostring(m:GetAttribute("GemName") or m.Name),tostring(m:GetAttribute("Rarity")),cand[i].d)) end
                end
                if nG>0 then
                    cfg._aoeN=nG
                    if feedAdd and now-(cfg._aoeLT or 0)>=3 then cfg._aoeLT=now
                        feedAdd(string.format("⚔ ขุดแรร์ฝัง %d เป้า (≤%dm)",nG,Dmax),Color3.fromRGB(255,200,120))
                    end
                end
            end
            -- 🌐 วงขุดผิว 360° ควบคู่ (ลุ้นคริสตัลหลุมระเบิด/สุ่มโชค) — จุดอยู่ภายในระยะที่ server รับ (R) เสมอ ไม่ยิงเกินจนเกิด "Too far away"
            -- วงขุดตามนโยบายเดียวกับเป้าแรร์: ปกติขุดเฉพาะในระยะที่ "กด E ถึง" (ไม่งั้นแรร์ที่โผล่จากหลุมไกลตีไม่ได้) — เปิด 🔭 ปลดไกล = ขุดเต็มระยะที่ server รับ
            local ringR=cfg.sub.digFar and R or Dmax
            local nr=math.max(1,math.floor(math.min(36,ringR*0.75)/6))
            local nY=math.max(1,math.min(3,math.floor(ringR*0.8/8)))   -- ชั้นแนวตั้ง ±nY×8m เฉพาะที่อยู่ในรัศมี (เดิมคงที่ ±24m → ระยะ E สั้นแล้วชั้นส่วนใหญ่ตกรัศมี = ลูปเปล่า)
            for _=1,(nG>0 and 2 or 5) do
                cfg._digA=(cfg._digA or 0)+1.0472
                if cfg._digA>=6.283 then cfg._digA=0 cfg._digR=((cfg._digR or 0)+1)%nr
                    if (cfg._digR or 0)==0 then cfg._digY=((cfg._digY or 0)+1)%(2*nY+1) end
                end
                local r=6+((cfg._digR or 0)*6)
                local vy=(math.min(cfg._digY or 0,2*nY)-nY)*8
                local px=from+Vector3.new(math.cos(cfg._digA)*r,vy,math.sin(cfg._digA)*r)
                local hitT=workspace:Raycast(px+Vector3.new(0,8,0),Vector3.new(0,-20,0),RayParams)
                if hitT and (hitT.Position-from).Magnitude<=ringR*0.97 then PK.shot(hitT.Position,from,now) end   -- ยิงเฉพาะชนพื้นในระยะ
            end
        end)
    end
    task.wait(0.02)
end end)

-- ============ 🅴 ตีแรร์ / เก็บ (Pickup prompt = ปุ่ม E ของเกม) ============
-- ข้อเท็จจริงจาก dump (03_tree_workspace): แรร์ฝัง = ไม่มี Hp ไม่มี prompt · ขุดโผล่ → Freed=true + มี Hp/MaxHp + ProximityPrompt "Pickup"
-- กด E บน prompt นั้น = หมัดตีแรร์ (MineHit) จน Hp หมด → ของ Dropped → E อีกที = เก็บ  ⇒ ถ้าไม่กด E "ขุดอย่างเดียว" ไม่มีแรร์ลงกระเป๋า
-- เดิมลูปนี้ผูกกับสวิตช์ "เก็บแรร์ออโต้" ที่ปิดอยู่ (บอทฟาร์มเดิมเปิดให้เองตอนออโต้) → ตอนนี้ ขุดออโต้ + 🅴 = ตีแรร์ให้เลย
PK.eT=setmetatable({},{__mode="k"}); PK.eOk=0; PK.eFire=0; PK.eHit=0; PK.eExp=0; PK.eDbg=0; PK.eLT=0
-- จังหวะกด E = cooldown พลั่ว + margin เล็กน้อย (นับเวลาประมวลผลรอบนั้นรวมด้วย) · log จริง: พลั่วทุกอัน cooldown 0.4 (PickaxeData) ↔ hitrate คงที่ 2.4/s ≈ 1/0.41
-- กดเร็วกว่า cooldown = server ทิ้งหมัดที่มาถึงก่อนเวลา แล้วจังหวะเลื่อนไปอีกรอบ (ช้าลงเท่าตัว) · ช้ากว่าไปนิดเดียวเสียแค่ ~2% — จึงเอา margin แค่ 8ms (+ granularity ของ task.wait)
PK.eMargin=0.008; PK.eRec=setmetatable({},{__mode="k"}); PK.eMulti=0
-- EI-BEGIN
PK.eHitTot=0; PK.fm={mode="base",t0=0,h0=0,untilT=0,sig=""}; PK.eInt=0.4
function PK.eInterval()   -- ช่วงหมัดต่อครั้ง: HitInterval (พลั่วพิเศษ: Plasma Drill 0.28 / Hexfang 0.25) ไม่งั้น Cooldown พลั่ว (0.4)
    -- FastDig2x/ยา Mining/RuneHaste ลดช่วงขุดฝั่ง client (PickaxeClient) แต่ไม่รู้ว่า server ใช้กับหมัดแรร์ด้วยไหม → ลองกดถี่ครึ่งช่วง 20s วัด hits/s จริง: ได้เกิน 1.25× ของช่วงปกติ = server รับ ใช้ต่อ · ไม่งั้นกลับช่วงปกติ (ทบทวนทุก 10 นาที)
    local ch=LP.Character; local tool=ch and heldPickaxe(ch)
    local b=tool and (tonumber(tool:GetAttribute("HitInterval")) or tonumber(tool:GetAttribute("Cooldown") or tool:GetAttribute("DigCooldown"))) or 0.4
    local ff=(LP:GetAttribute("Pass_FastDig2x")==true or os.time()<(LP:GetAttribute("MiningPotionUntil") or 0)) and 0.5 or 1
    ff=ff/math.max(tonumber(LP:GetAttribute("RuneHaste")) or 1,1)
    local fm,now=PK.fm,os.clock()
    local sig=(tool and tool.Name or "?")..":"..ff
    if fm.sig~=sig then fm.sig=sig fm.mode=(ff<1) and "probe" or "base" fm.t0=now fm.h0=PK.eHitTot fm.untilT=now+600 end
    if ff>=1 then PK.eInt=b return b end
    if fm.mode=="probe" and now-fm.t0>=20 then
        local rate=(PK.eHitTot-fm.h0)/(now-fm.t0)
        fm.mode=(rate>=1.25/b) and "fast" or "base"; fm.untilT=now+600
        slog(("E จังหวะ: ลองกดถี่ ×%.2f (ทุก %.2fs) ได้ %.2f หมัด/วิ (ช่วงปกติคาด %.2f) → %s"):format(ff,b*ff,rate,1/b,fm.mode=="fast" and "server รับ ใช้ต่อ" or "server ไม่รับ กลับช่วงปกติ"))
    elseif fm.mode~="probe" and now>fm.untilT then fm.mode="probe" fm.t0=now fm.h0=PK.eHitTot end
    local v=(fm.mode=="base") and b or b*ff
    PK.eInt=v; return v
end
-- EI-END
task.spawn(function() while alive() do
    local passT0=os.clock()
    local hitE=cfg.autodig and cfg.sub.hitE
    if (cfg.autocollect or hitE) and not fireproximityprompt and not PK.fppW then
        PK.fppW=true; slog("⚠️ executor ไม่มี fireproximityprompt — กด E ให้ไม่ได้")
        if feedAdd then feedAdd("⚠️ executor ไม่มี fireproximityprompt — ต้องกด E เอง",Color3.fromRGB(255,160,80)) end
    end
    if LP:GetAttribute("IsMiningGem") then   -- 🩺 เซสชันตีแรร์ค้าง: IsMiningGem นานเกิน 60s แต่ไม่มี MineHit 25s → log เตือน (ลูปขุดหยุดตลอดที่ค้าง)
        local t0=os.clock(); PK.sessT=PK.sessT or t0
        if t0-PK.sessT>60 and t0-(PK.hitT or 0)>25 and t0-(PK.sessW or 0)>60 then PK.sessW=t0 slog("⚠️ IsMiningGem ค้าง >60s และไม่มี MineHit 25s — ลูปขุดหยุดรอ (ลองยืนใกล้แรร์ที่กำลังตีให้ติด E)") end
    else PK.sessT=nil end
    if (cfg.autocollect or hitE) and fireproximityprompt then
        pcall(function()
            local ch=LP.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local now=os.clock(); local uid=LP.UserId
            local list={}
            for m in pairs(promptSet) do
                if not m.Parent then promptSet[m]=nil
                elseif m.Enabled then
                    local mad=m.MaxActivationDistance if mad>PK.eBase then PK.eBase=mad end   -- เรียนรู้ระยะ E จากป้าย prompt จริง
                    local mm=m:FindFirstAncestorOfClass("Model")
                    if mm and mm:GetAttribute("Placed")~=true and (mm:GetAttribute("Freed") or mm:GetAttribute("Dropped") or mm:GetAttribute("Hp")~=nil)   -- Placed = ชิ้นในสวน (ห้ามกด E ไม่งั้นถอนออกจากสวน)
                        and rIdx(mm:GetAttribute("Rarity"))>=cfg.botTier then
                        local ow=mm:GetAttribute("Owner")
                        if mm:GetAttribute("Dropped") or ow==nil or ow==uid then   -- Freed = ของเราเท่านั้น (ไม่แย่งแรร์คนอื่น) · Dropped = หยิบได้ทุกอัน เหมือนเดิม
                            local pp=m.Parent
                            local p2=pp and (pp:IsA("BasePart") and pp.Position or pp:IsA("Attachment") and pp.WorldPosition or pp:IsA("Model") and pp:GetPivot().Position)
                            if p2 then list[#list+1]={m=m,mm=mm,d=(hrp.Position-p2).Magnitude,r=rIdx(mm:GetAttribute("Rarity")),hp=mm:GetAttribute("Hp") or 0} end
                        end
                    end
                end
            end
            if #list==0 then return end
            table.sort(list,function(a,b) if a.r~=b.r then return a.r>b.r end if a.hp~=b.hp then return a.hp<b.hp end return a.d<b.d end)   -- แรร์สูงก่อน · เลือดน้อยก่อน (แตกไว) · ใกล้ก่อน
            local n,exp=0,nil
            for _,e in ipairs(list) do
                -- ระยะ E: เริ่มที่ MaxActivationDistance×1.5 แล้วขยายตามที่ MineHit ยืนยันว่า server ยอมจริง (PK.eOk) — colRange ปิด = ไม่จำกัด
                local reach=math.max(e.m.MaxActivationDistance*1.5,PK.eOk*1.1)
                if (not cfg.sub.colRange) or e.d<=reach then
                    if n<4 then
                        fireproximityprompt(e.m); n+=1
                        PK.eT[e.mm]={d=e.d,t=now}
                    end
                elseif not exp and e.d<=math.min(150,reach*3) then exp=e end
            end
            -- 🔭 ลองกด E ใส่ตัวที่ไกลกว่าระยะที่รู้ 1 ตัว/3s: ถ้า MineHit ตอบกลับ = server ยอม → ระยะ E ขยายเอง (ไม่เดินก็ตีไกลขึ้นได้ถ้าเกมไม่เช็ค)
            if exp and now-PK.eExp>3 then
                PK.eExp=now; fireproximityprompt(exp.m); n+=1
                PK.eT[exp.mm]={d=exp.d,t=now}
            end
            if n>0 then
                PK.eFire+=n
                if hitE and feedAdd and now-PK.eLT>=4 then PK.eLT=now
                    feedAdd(string.format("🅴 กด E ตีแรร์ %d ตัว (เป้าหลัก %dm)",n,list[1].d),Color3.fromRGB(255,215,120))
                end
            end
            -- 🩺 รายงานสภาพแรร์ที่รอ E ทุก 20s — ดูใน log ว่า prompt/Hp/ระยะ จริงเป็นยังไง (หลักฐานแทนการเดา)
            if now-PK.eDbg>20 then PK.eDbg=now
                for i=1,math.min(3,#list) do
                    local e=list[i]; local m=e.m
                    slog(("E dbg %s %s hp=%s/%s freed=%s drop=%s owner=%s(me=%d %s) mining=%s d=%dm prompt=%s hold=%s maxd=%s"):format(
                        tostring(e.mm:GetAttribute("GemName") or e.mm.Name),tostring(e.mm:GetAttribute("Rarity")),tostring(e.mm:GetAttribute("Hp")),tostring(e.mm:GetAttribute("MaxHp")),
                        tostring(e.mm:GetAttribute("Freed")),tostring(e.mm:GetAttribute("Dropped")),tostring(e.mm:GetAttribute("Owner")),uid,e.mm:GetAttribute("Owner")==uid and "✓" or "✗",tostring(e.mm:GetAttribute("Mining")),e.d,m.Name,tostring(m.HoldDuration),tostring(m.MaxActivationDistance)))
                end
            end
        end)
    end
    task.wait(hitE and math.max(0.05,PK.eInterval()+PK.eMargin-(os.clock()-passT0)) or 0.35)   -- E ตาม cooldown พลั่ว + margin (หมัดละ 1 ครั้ง · turbo ไม่เร่ง E เพราะ server คุมต่อหมัด) — เดิมตายตัว 0.35s
end end)

-- ============ loot/discovery feed (NotifyRemotes.Push) ============
task.spawn(function()
    while not Push do task.wait(0.3) if not alive() then return end end
    Push.OnClientEvent:Connect(function(p)
        if not alive() or not feedAdd or type(p)~="table" then return end
        if p.kind=="pickup" then
            PK.ss.n+=1; PK.ss.val+=tonumber(p.value) or 0
            feedAdd(string.format("📥 +%s (%s) %.1fkg $%s",p.name or "?",PK.thR(p.rarity),p.kg or 0,tostring(p.value or 0)),TCOL[p.rarity])
        elseif p.kind=="discovery" then
            feedAdd(string.format("🆕 ค้นพบ %s (%s)",p.name or "?",PK.thR(p.rarity)),TCOL[p.rarity])
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

-- ============ 📡 เรด้าสอยสต็อก: ShopState push ~1s → stock มา + เงินพอ → BuyRadar ทันที (รอบเดียว/รอบ restock) ============
local RPRICE={CrystalRadar=3e5,RarityRadar=3e6,BoulderRadar=12e6,RuneRadar=35e6,MeteorRadar=15e7,ZenithRadar=1e12}
local RKEY={CrystalRadar="snCrystal",RarityRadar="snRarity",BoulderRadar="snBoulder",RuneRadar="snRune",MeteorRadar="snMeteor",ZenithRadar="snZenith"}
PK.RTH={CrystalRadar="เรด้าคริสตัล",RarityRadar="เรด้าความหายาก",BoulderRadar="เรด้าหินขนาดใหญ่",RuneRadar="เรด้ารูน",MeteorRadar="เรด้าอุกกาบาต",ZenithRadar="เรด้าซีนิธ"}
task.spawn(function()
    while not PK.ShopSt do task.wait(0.5) if not alive() then return end end
    PK.ShopSt.OnClientEvent:Connect(function(p)
        if not alive() or type(p)~="table" then return end
        if p.message then   -- ผลซื้อ/แจ้งร้าน (เกมแปลไทยให้เอง)
            if cfg.radarSnipe and feedAdd then feedAdd("📡 "..tostring(p.message),Color3.fromRGB(150,220,255)) end
            return
        end
        local st=p.stock; if type(st)~="table" then return end
        local ls=LP:FindFirstChild("leaderstats"); local cn=ls and ls:FindFirstChild("Coins")
        local coins=cn and cn.Value or 0
        -- repaint สต็อกสดบนเมนูทุก push
        if cfg._rLab then for id,l in pairs(cfg._rLab) do
            local n=st[id] or 0
            l.Text=(PK.RBASE[id] or id).." · เหลือ "..n
            l.TextColor3=n>0 and Color3.fromRGB(120,255,170) or C.txt
        end end
        -- ซื้อทั้งสต็อก: push ทุก ~1s → ยังเหลือ+เงินพอ = ยิงซ้ำทุก push จนหมด (cooldown 1.05s/ครั้ง)
        local now=os.clock()
        cfg._radarT=cfg._radarT or {}
        for id,key in pairs(RKEY) do
            local n=st[id] or 0
            if n>0 and cfg.radarSnipe and cfg.sub[key] and coins>=(RPRICE[id] or math.huge) and now-(cfg._radarT[id] or 0)>=1.05 then
                cfg._radarT[id]=now
                if PK.BuyRad then PK.BuyRad:FireServer(id) end
                cfg._eqR=id            -- รอ tool เด้งเข้ากระเป๋า → ถือใช้เอง (ลูปด้านล่าง)
                if feedAdd then feedAdd(string.format("📡 สอย %s! (เหลือ %d · $%s)",PK.RTH[id] or id,n,tostring(RPRICE[id])),Color3.fromRGB(120,255,200)) end
                sfx("pop"); slog("snipe "..id.." stock="..n.." coins="..tostring(coins))
            end
        end
    end)
    slog("radar-hook buyrad="..tostring(PK.BuyRad~=nil))
end)

-- 🖐 ซื้อเรด้าได้ → แค่ log ยืนยัน Tool มาถึง (ไม่ถือให้ — user ติ๊กเรด้าเดินฟรีเอง หรือถือเอง)
task.spawn(function()
    local bp=LP:WaitForChild("Backpack",30); if not bp then return end
    bp.ChildAdded:Connect(function(t)
        if not alive() or not cfg._eqR then return end
        if not (t:IsA("Tool") and t:GetAttribute("RadarType")==cfg._eqR) then return end
        local id=cfg._eqR; cfg._eqR=nil
        if feedAdd then feedAdd("🖐 "..(PK.RTH[id] or id).." เข้ากระเป๋าแล้ว — ติ๊กเรด้าเดินฟรีเพื่อใช้",Color3.fromRGB(120,255,200)) end
        slog("bought radar arrived "..id)
    end)
    -- หมดเวลารอ 15s ไม่มี tool มา = ซื้อไม่สำเร็จ → เคลียร์
    while alive() do task.wait(15) if cfg._eqR then cfg._eqR=nil end end
end)



-- ============ 📡 PowerFired: buried impact waypoint เฉพาะเจ้าของเรด้า (intel เดียวที่ ESP แทนไม่ได้) ============
task.spawn(function()
    while not PK.PowFd do task.wait(0.5) if not alive() then return end end
    PK.PowFd.OnClientEvent:Connect(function(p)
        if not alive() or type(p)~="table" then return end
        if p.kind=="impact" and typeof(p.pos)=="Vector3" then
            local ttl=math.max(30,(tonumber(p.untilT) or os.time()+360)-os.time())
            pcall(function() mkMark(p.pos,"💎 จุดฝังพิเศษ (5x luck)",Color3.fromRGB(90,235,255),ttl) end)
            if feedAdd then feedAdd("💎 เรด้าเจอจุดฝังพิเศษ! "..tostring(p.text or ""),Color3.fromRGB(90,235,255)) end
            sfx("pop"); slog("impact @ "..tostring(p.pos))
        elseif p.kind=="zenith" then
            if feedAdd then feedAdd("📡 "..tostring(p.text or "เรด้าเจอ Zenith!"),TCOL.Zenith) end
            sfx("pop"); slog("zenith ping "..tostring(p.text))
        elseif p.text and feedAdd then feedAdd("📡 "..tostring(p.text),C.dim) end
    end)
    slog("powerfired-hook")
end)

-- ============ dig feedback (server บอกเหตุที่ขุดพลาด) ============
task.spawn(function()
    while not DigRes do task.wait(0.3) if not alive() then return end end
    local lastW=0
    DigRes.OnClientEvent:Connect(function(ok,err)
        if not alive() or ok then return end
        local rc=PK.rc; local now=os.clock()
        local es=tostring(err or "ขุดไม่ได้")
        if rc.err[es] then rc.err[es]+=1 elseif (rc.errK or 0)<20 then rc.errK=(rc.errK or 0)+1 rc.err[es]=1 end   -- นับชนิด error ไว้รายงานใน log ทุก 30s (รู้ว่า server ปฏิเสธเพราะอะไรบ้าง)
        local low=es:lower()
        if low:find("far") or low:find("range") or low:find("distance") or es:find("ไกล") then   -- "Too far away" (NotifyClient:376)
            local kind=PK.rcFar(rc,now)
            if kind=="stray" then
                slog(("ไกลเกิน (ไม่มี probe) → R หด %dm ceil=%s lo=%d"):format(rc.R,tostring(rc.ceil and math.floor(rc.ceil)),rc.lo))
                if feedAdd then feedAdd(string.format("📏 ไกลเกิน → ระยะขุดเหลือ %dm",rc.R),Color3.fromRGB(255,160,80)) end
            elseif kind=="probe" then
                slog(("probe ไกลเกิน → เพดาน≈%dm R=%d lo=%d"):format(rc.ceil,rc.R,rc.lo))
            end
            return
        end
        if low:find("safe zone") or low:find("glacier") or low:find("nothing to break") then   -- ขุดตรงนี้ไม่ได้: ถ้าซ้ำ ≥8 ครั้ง/3s และไม่มีช็อตไหนรับ → พัก 10s (ไม่ยิงถล่ม server ตอนยืนในเซฟโซน/บนฐาน)
            if now-(rc.szT or 0)>3 then rc.szT=now rc.sz=0 rc.szA=rc.acc end
            rc.sz=(rc.sz or 0)+1
            if rc.sz>=8 and rc.acc==rc.szA and now>(rc.hold2 or 0) then rc.hold2=now+10 rc.sz=0 slog("ขุดไม่ได้ซ้ำๆ (safe zone / ไม่ใช่ glacier) และไม่มีช็อตไหนรับ → พักยิง 10s") if feedAdd then feedAdd("⛔ ตรงนี้ขุดไม่ได้ (เซฟโซน/ไม่ใช่ธารน้ำแข็ง) — พักยิง 10s",Color3.fromRGB(255,160,80)) end end
        end
        PK.rcOther(rc,now)                                            -- error อื่นระหว่าง probe = จุดลองใช้ไม่ได้ (ไม่ใช่เรื่องระยะ)
        if not feedAdd or now-lastW<1.5 then return end; lastW=now
        feedAdd("⛏ "..es,Color3.fromRGB(255,120,120))
    end)
end)

-- ============ hitrate telemetry: MineHit = hit ที่ server รับจริง → log อัตราทุก 30s ============
task.spawn(function()
    while not MineHitEv do task.wait(0.3) if not alive() then return end end
    cfg._hits=0
    MineHitEv.OnClientEvent:Connect(function(g)   -- payload = โมเดลแรร์ที่โดนหมัด (MiningClient:705 → triggerCrystalShake)
        cfg._hits=(cfg._hits or 0)+1; PK.hitT=os.clock()
        if typeof(g)=="Instance" then   -- หลักฐาน: หมัดลง "คนละตัวภายใน 0.3s" ได้ไหม → ถ้าได้ = cooldown ต่อแรร์ (กดหลายตัวพร้อมกันคุ้ม) · ไม่ได้ = ต่อผู้เล่น (กดตัวเดียวพอ)
            PK.eRec[g]=PK.hitT; local k=0
            for gg,tt in pairs(PK.eRec) do if PK.hitT-tt<0.3 then k+=1 else PK.eRec[gg]=nil end end
            if k>PK.eMulti then PK.eMulti=k end
        end
        local t=typeof(g)=="Instance" and PK.eT[g]   -- เราเพิ่งกด E ใส่ตัวนี้ → ระยะตอนกดคือระยะที่ server ยอมรับ E จริง
        if t and os.clock()-t.t<3 then
            PK.eHit+=1; PK.eHitTot+=1
            -- สกิลเคียว/ค้างคาวตีแรร์จากไกลได้เอง (MineHit เหมือนกัน) → ตอนถือสองอันนี้ไม่เอาระยะมาเรียนรู้ระยะ E
            if t.d>PK.eOk and not (LP:GetAttribute("HoldingScythe") or LP:GetAttribute("HoldingBatwing")) then PK.eOk=t.d; slog(("E ตีติดที่ระยะ %dm (ใหม่สุด)"):format(t.d)) end
        end
    end)
    while alive() do
        task.wait(30)
        local rc=PK.rc
        if cfg.autodig or cfg.autocollect or (cfg._hits or 0)>0 then
            local es={} for k,v in pairs(rc.err) do es[#es+1]=k.."×"..v end
            slog(string.format("30s | ขุด ยิง=%d รับ=%d (DigEffect) R=%dm lo=%dm ceil=%s ไกลเกิน=%d | E กด=%d ติด=%d (MineHit รวม %d) ระยะE≤%dm จังหวะ=%dms หมัดพร้อมกันสูงสุด=%d | err: %s",
                rc.fired,rc.acc,rc.R,rc.lo,tostring(rc.ceil and math.floor(rc.ceil)),rc.farN,PK.eFire,PK.eHit,cfg._hits or 0,PK.eOk,(PK.eInt+PK.eMargin)*1000,PK.eMulti,#es>0 and table.concat(es," ; ") or "-"))
        end
        cfg._hits=0; rc.fired=0; rc.acc=0; rc.farN=0; PK.eFire=0; PK.eHit=0; PK.eMulti=0
        for k in pairs(rc.err) do rc.err[k]=nil end; rc.errK=0
    end
end)

-- ============ ขายออโต้ (BagFull → เก็บ⭐ชิ้นโชคสูง → TeleportSell/ยิงตรง → RequestSell("All") → กลับจุดเดิม) ============
local selling=false
PK.protectBag=nil   -- fwd: นิยามจริงอยู่ในส่วนสวนด้านล่าง (ติด⭐ชิ้นควรเก็บ กันโดนขายทิ้ง)
task.spawn(function() while alive() do
    -- ขายตอนกระเป๋าเต็ม (BagFull) · โหมดขายระยะไกล (ไม่วาป) ขายก่อนเต็มที่ ≥92% ด้วย (ไม่ให้ E เก็บแรร์ใหม่ไม่ได้เพราะเต็ม) — เว้น 45s กันยิงซ้ำเมื่อ ⭐ หนักค้างกระเป๋า
    local full=LP:GetAttribute("BagFull")==true
    local near=false
    if cfg.autosell and cfg.sub.remoteSell and not full and os.clock()>(PK.sellHold or 0) then
        local k,c=LP:GetAttribute("BagKg"),LP:GetAttribute("CarryWeight")
        near=type(k)=="number" and type(c)=="number" and c>0 and k/c>=0.92
    end
    if cfg.autosell and not selling and not PK.gTrip and (full or near) and os.clock()>(PK.sellHold or 0) then
        local ok=pcall(function()
            -- กันโดนขายทิ้งก่อนเสมอ: ชิ้นโชคสูงที่จะลงสวน → ติด⭐ (server เว้น favorite ตอนขาย All)
            if PK.protectBag then local n=PK.protectBag() if n>0 then feedAdd(("⭐ เก็บ %d ชิ้นโชคไว้ลงสวน"):format(n),Color3.fromRGB(140,255,140)) end task.wait(0.6) end
            -- ขายระยะไกล: ยิง RequestSell ตรงๆ ไม่วาป (ถ้า server ไม่เช็คระยะ = ขายได้ทุกที่; fail → SellResult feed บอก)
            if cfg.sub.remoteSell and SellReq then
                selling=true; PK.sellHold=os.clock()+(full and 6 or 45)
                SellReq:FireServer("All")
                task.delay(full and 4 or 2,function() selling=false end)
                return
            end
            if not full then return end   -- โหมดวาป: ขายเฉพาะตอนเต็มจริง (ไม่วาปเล่นๆ)
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
            cfg._metHot=true                                          -- ☄️ โซน luck x5 เปิด → บอทวิ่งไป (botMet)
            local pp=typeof(p.pos)=="Vector3" and p.pos or (MetPos and MetPos.Value)
            if cfg.sub.metMark and typeof(pp)=="Vector3" then mkMark(pp,"☄️ เมเทียร์(ตกแล้ว)",ORANGE,120) end
            if cfg.sub.metFeed then feedAdd("💥 เมเทียร์ตกแล้ว! โซนluck x5",ORANGE) end
        elseif p.phase=="zone" then
            cfg._metHot=true
        elseif p.phase=="end" then
            cfg._metHot=false
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
            bagQuote=tonumber(v) or (type(v)=="table" and (v.payout or v.total or v.value or v.worth or v.Total or v.TotalValue or v.coins or v.Coins)) or bagQuote
        end
    end
    task.wait(8)
end end)

-- ============ 🌱 สวนโชคออโต้ — ConfigGet → วาง/สลับของ luck สูงสุด ============
local function gLuck(rarity,kg,muts,coreLuck,name)
    if GD and GD.effectiveLuck then
        local ok,l=pcall(GD.effectiveLuck,rarity,kg,muts,nil,coreLuck,name)
        if ok and type(l)=="number" then return l end
    end
    local rm=(GD and GD.LuckRarityMult and GD.LuckRarityMult[rarity]) or 1
    return 0.095*(kg^0.35)*rm
end
local function gBag()   -- ของในกระเป๋าที่วางได้ (Tool + BagId) sort luck มาก→น้อย
    local bp=LP:FindFirstChild("Backpack"); local t={}
    if bp then for _,d in ipairs(bp:GetChildren()) do
        if d:IsA("Tool") and d:GetAttribute("BagId") then
            t[#t+1]={id=d:GetAttribute("BagId"),kg=d:GetAttribute("Kg") or 1,rarity=d:GetAttribute("Rarity") or "Common",
                name=d:GetAttribute("GemName") or d.Name,
                luck=gLuck(d:GetAttribute("Rarity") or "Common",d:GetAttribute("Kg") or 1,d:GetAttribute("Mutations"),d:GetAttribute("CoreLuck"),d:GetAttribute("GemName"))}
        end
    end end
    table.sort(t,function(a,b) return a.luck>b.luck end)
    return t
end
local gdPosN=0  -- หมุนตำแหน่งวาง (กันทับชิ้นเดิม)
PK.gWorst,PK.gCount,PK.gCap=0,0,0   -- state สวนล่าสุด (luck ต่ำสุด/ชิ้น/ช่อง) — ใช้คัดชิ้นเก็บ⭐ + ตัดสินใจเดินทาง
local function gPos()
    local idx=LP:GetAttribute("PlotIndex") or 0
    local p=idx~=0 and workspace:FindFirstChild("PlotPlacePart"..idx)
    if not p then return nil end
    local cf=p.CFrame; local s=p.Size
    local ux,uz=math.max(8,s.X-10),math.max(8,s.Z-10)
    local cols=math.max(1,math.floor(ux/8))
    local i=gdPosN; gdPosN=gdPosN+1
    local r=math.floor(i/cols)%math.max(1,math.floor(uz/8)); local c=i%cols
    local lx=-ux/2+4+c*8; local lz=-uz/2+4+r*8
    return (cf*CFrame.new(lx,0,lz)).Position
end
function PK.tierOk(r) local ti=tIdx(r) return ti<=0 or ti>=cfg.sub.gdTier end   -- ผ่าน tier ขั้นต่ำ (unknown→ผ่าน)
function PK.placeOne()   -- วาง/สลับ 1 ชิ้น → คืน true ถ้าทำอะไรสักอย่าง (ใช้ร่วมกัน ลูปปกติ + รอบเดินทาง)
    local st=CfgGetR:InvokeServer()
    if type(st)~="table" then return false end
    local placed=st.crystals or {}
    PK.gCount=#placed; PK.gCap=st.capacity or 0
    PK.gWorst=math.huge
    for _,c in ipairs(placed) do
        local l=(PK.pickOn() and not picks[c.name]) and -1 or gLuck(c.rarity,c.kg,c.mutations,c.coreLuck,c.name)
        if l<PK.gWorst then PK.gWorst=l end
    end
    if PK.gWorst==math.huge then PK.gWorst=0 end
    local items=gBag()
    for i=#items,1,-1 do if not PK.tierOk(items[i].rarity) then table.remove(items,i) end end
    if PK.pickOn() then for i=#items,1,-1 do if not picks[items[i].name] then table.remove(items,i) end end end
    if #items==0 then return false end
    if PK.gCount<PK.gCap then
        local pos=gPos()
        if pos then PlaceC:FireServer(items[1].id,pos,0)
            slog(("garden+ %s %.1fkg luck %.2f"):format(items[1].name,items[1].kg,items[1].luck)) return true end
    elseif cfg.sub.gdSwap and TakeC then
        local wId=nil
        for _,c in ipairs(placed) do
            local l=(PK.pickOn() and not picks[c.name]) and -1 or gLuck(c.rarity,c.kg,c.mutations,c.coreLuck,c.name)
            if l==PK.gWorst then wId=c.id break end
        end
        if wId and items[1].luck>PK.gWorst*1.2 then
            TakeC:FireServer(wId); task.wait(0.7)
            local pos=gPos()
            if pos then PlaceC:FireServer(items[1].id,pos,0)
                slog(("garden~ out %.2f → in %s %.2f"):format(PK.gWorst,items[1].name,items[1].luck)) return true end
        end
    end
    return false
end
task.spawn(function() while alive() do
    if cfg.garden and PlaceC and CfgGetR then pcall(PK.placeOne) end
    task.wait(4)
end end)

-- ============ ⭐ auto-favorite: ชื่อที่เลือกใน 🎯 + ชิ้นโชคสูงสำหรับสวน → ติดดาวกันขาย ============
-- บอทขุด/เก็บทุกอย่าง → ขายหมด → ชิ้นที่เลือก+ชิ้นโชคดีรอดเพราะติด ⭐ → สวนหยิบไปวางเอง
local favByBot={}  -- [BagId]=GemName — เฉพาะตัวที่เราติด ⭐ เอง (ของ user ติดเองไม่แตะ)
PK.favLuck={}         -- [BagId]=true — ตัวที่เราติดเพราะ "โชคสวน" (ถอดได้เมื่อไม่คุ้มแล้ว)
function PK.luckWorthy(l)  -- ชิ้นนี้คุ้มเก็บไว้ลงสวนไหม: ว่าง→เก็บ / เต็ม→ต้องชนะตัวอ่อนสุด 20%
    if PK.gCap>0 and PK.gCount>=PK.gCap then return l>PK.gWorst*1.2 end
    return true
end
function PK.wantOf(d)      -- คืน nil / "pick" / "luck" — เหตุผลที่ควรเก็บชิ้นนี้
    local nm=d:GetAttribute("GemName") or d.Name
    if PK.pickOn() and picks[nm]==true then return "pick" end
    if cfg.garden and cfg.sub.gdKeep and d:GetAttribute("BagId") and PK.tierOk(d:GetAttribute("Rarity") or "Common") then
        local l=gLuck(d:GetAttribute("Rarity") or "Common",d:GetAttribute("Kg") or 1,d:GetAttribute("Mutations"),d:GetAttribute("CoreLuck"),nm)
        if PK.luckWorthy(l) then return "luck" end
    end
end
PK.favT={}   -- เวลาที่สลับ ⭐ ล่าสุดต่อ BagId
PK.protectBag=function()   -- ติด⭐ชิ้นควรเก็บทันที (ใช้ก่อนขาย — กันโดนขายทิ้ง) → คืนจำนวนที่ป้อง
    local n=0
    if not TogFav then return n end
    local bp=LP:FindFirstChild("Backpack")
    if bp then for _,d in ipairs(bp:GetChildren()) do
        if d:IsA("Tool") then
            local bid=d:GetAttribute("BagId")
            local w=bid and PK.wantOf(d)
            if w and d:GetAttribute("Favorited")~=true and os.clock()-(PK.favT[bid] or -99)>4 then
                PK.favT[bid]=os.clock()
                TogFav:FireServer(bid); favByBot[bid]=d:GetAttribute("GemName") or d.Name
                if w=="luck" then PK.favLuck[bid]=true end; n=n+1
            end
        end
    end end
    return n
end
task.spawn(function() while alive() do
    if TogFav then pcall(function()
        local bp=LP:FindFirstChild("Backpack")
        local seen={}
        if bp then for _,d in ipairs(bp:GetChildren()) do
            if d:IsA("Tool") then
                local bid,nm=d:GetAttribute("BagId"),d:GetAttribute("GemName") or d.Name
                local w=bid and PK.wantOf(d)
                if bid then
                    seen[bid]=true   -- (เดิมตั้งเฉพาะกิ่ง elseif → favByBot ถูกเคลียร์ทุกรอบ = ฟีเจอร์ถอด ⭐ ตัวที่ไม่คุ้มแล้วไม่เคยทำงาน)
                    local recent=os.clock()-(PK.favT[bid] or -99)<4   -- เพิ่งสลับไป: attr ยังไม่ replicate กลับ → ห้ามสลับซ้ำ (ToggleFavorite = สลับ จะถอดดาวทิ้ง)
                    if w and d:GetAttribute("Favorited")~=true then
                        if not recent then
                            PK.favT[bid]=os.clock(); TogFav:FireServer(bid); favByBot[bid]=nm
                            if w=="luck" then PK.favLuck[bid]=true end
                        end
                    elseif favByBot[bid] and not recent then
                        if d:GetAttribute("Favorited")~=true then favByBot[bid]=nil PK.favLuck[bid]=nil   -- user ถอดเอง → เคารพ
                        elseif not w then PK.favT[bid]=os.clock(); TogFav:FireServer(bid); favByBot[bid]=nil PK.favLuck[bid]=nil end   -- ไม่คุ้มแล้ว → ถอด ⭐ ที่เราติด
                    end
                end
            end
        end end
        for bid in pairs(favByBot) do if not seen[bid] then favByBot[bid]=nil PK.favLuck[bid]=nil end end   -- ออกจากกระเป๋าแล้ว → เคลียร์ record
    end) end
    task.wait(3)
end end)

-- ============ 🌱 รอบสวน: ชิ้น⭐สะสม ≥3 + อยู่ไกลสวน → TeleportPlot → วาง/สลับจนหมด → กลับจุดขุด ============
PK.gTrip=false
task.spawn(function() while alive() do
    if cfg.garden and cfg.sub.gdTrip and TPlot and not PK.gTrip and not selling then if not pcall(function()
        local nP=0; local bp=LP:FindFirstChild("Backpack")
        if bp then for _,d in ipairs(bp:GetChildren()) do
            if d:IsA("Tool") and PK.favLuck[d:GetAttribute("BagId")] then nP=nP+1 end
        end end
        if nP<3 then return end
        local idx=LP:GetAttribute("PlotIndex") or 0
        local pp=idx~=0 and workspace:FindFirstChild("PlotPlacePart"..idx)
        local ch=LP.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if not (pp and hrp) then return end
        if (hrp.Position-pp.Position).Magnitude<40 then return end   -- อยู่ใกล้สวนแล้ว ลูปปกติจัดการ
        PK.gTrip=true
        local back=hrp.CFrame
        feedAdd(("🌱 พา %d ชิ้น⭐ไปลงสวน"):format(nP),Color3.fromRGB(140,255,140))
        TPlot:FireServer(); task.wait(2.2)
        for i=1,15 do local ok,did=pcall(PK.placeOne) if not (ok and did) then break end task.wait(0.6) end
        local ch2=LP.Character
        if ch2 then pcall(function() ch2:PivotTo(back) end) end
        feedAdd("🌱 ลงสวนเสร็จ กลับจุดขุด",Color3.fromRGB(140,255,140))
        PK.gTrip=false
    end) then PK.gTrip=false end end
    task.wait(8)
end end)

-- HUD สวน: โชว์ luck รวม/ช่อง บนแถว (ConfigStats invoke ทุก 15 วิ)
task.spawn(function() while alive() do
    if cfg._gLbl then
        local txt="วางแรร์โชคสูงลงสวนให้เอง"
        if CfgStat then
            local ok,st=pcall(function() return CfgStat:InvokeServer() end)
            if ok and type(st)=="table" and st.totalLuck then
                txt=("🌱 สวน 🍀+%.1f%%  %d/%d"):format(st.totalLuck,st.count or 0,st.capacity or 0)
            end
        end
        pcall(function() cfg._gLbl.Text=txt end)
    end
    task.wait(15)
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

-- ============ auto-อัพเกรด (UpgradeState → ซื้อแพ็กใหญ่สุดที่เงินพอ) ============
-- ราคาจริงจาก UpgradeClient: prices[i] = ราคาปุ่ม steps[i] (carry {1,50,10} / warmth {10,50,100}) · ปุ่มสุดท้าย = "max" ราคา maxCarryCost/maxWarmthCost
-- นโยบาย: max ก่อน ไม่พอค่อยไล่ step ลงมา (แพ็กใหญ่ก่อน = ใช้เงินได้เต็ม/คำสั่ง · ราคาสะสมเท่ากัน ไม่เสียเปรียบ)
-- 💸 upSoon: ซื้อทันทีทุกครั้งที่ UpgradeState ใหม่มา (ราคาสด ไม่ซื้อซ้ำบนราคาเก่า) แทนรอ poll — เดิมแก้เป็น "แพ็กเล็กสุดก่อน" ซึ่งช้ากว่าและวนไปแตะปุ่ม max ผิดดัชนี
PK.upT=0; PK.lastBuy={carry=0,warmth=0}
PK.upInfo={carry={"⬆️ อัพกระเป๋า",Color3.fromRGB(120,255,160)},warmth={"⬆️ อัพความอบอุ่น",Color3.fromRGB(255,180,120)}}
function PK.upTry()
    if not (cfg.autoup and BuyUp and upState) then return end
    local ls=LP:FindFirstChild("leaderstats"); local cv=ls and ls:FindFirstChild("Coins")
    local coins=cv and cv.Value or 0
    local nw=os.clock()
    local function tryBuy(kind)
        local steps=kind=="carry" and {1,50,10} or {10,50,100}
        local prices=kind=="carry" and upState.carryPrices or upState.warmthPrices
        local maxCost=kind=="carry" and upState.maxCarryCost or upState.maxWarmthCost
        if type(maxCost)=="number" and maxCost>0 and coins>=maxCost then BuyUp:FireServer(kind,"max") return "max" end
        for i=#steps-1,1,-1 do
            local p=prices and prices[i]
            if type(p)=="number" and coins>=p then BuyUp:FireServer(kind,steps[i]) return "+"..steps[i] end
        end
    end
    local gap=cfg.sub.upSoon and 1.2 or 5
    -- 💾 เก็บเงินซื้อพลั่ว: "max" ของ carry/warmth ใช้เงินทั้งกระเป๋าทุกรอบ → ไม่เคยพอซื้อพลั่ว (ราคาเพิ่ม ~4x/ขั้น) · เงิน ≥25% ของราคาพลั่วถัดไปแล้ว = งดซื้อ carry (warmth ยังซื้อได้ถ้าหนาว)
    local saving,svName=false,nil
    if cfg.sub.upPick and PK.PD then
        local best=PK.pkState(); local np,ni=PK.pkNext(best)
        if np and coins>=np*0.25 then saving=true svName=PK.PD[ni] and PK.PD[ni].name end
    end
    local rowUpL=PK.upLbl
    if rowUpL then   -- บรรทัดอธิบายของการ์ดอัพเกรดบอกสถานะ "กำลังเก็บเงินซื้อพลั่ว" (ไม่งั้นดูเหมือนบอทหยุดซื้อ carry/warmth เฉยๆ)
        local base=string.format("🔥 ความอบอุ่น Lv%s · 🎒 กระเป๋า Lv%s",tostring(upState.warmth or "–"),tostring(upState.carry or "–"))
        rowUpL.Text=saving and (base.." · 💾 เก็บเงินซื้อ "..tostring(svName or "พลั่วถัดไป")) or base
    end
    for _,k in ipairs({"carry","warmth"}) do
        local on=(k=="carry" and cfg.sub.upCarry) or (k=="warmth" and cfg.sub.upWarm)
        if saving and not (k=="warmth" and PK.isCold(LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))) then on=false end
        local lb=PK.lastBuy[k]
        -- ซื้อซ้ำได้เมื่อมี UpgradeState ใหม่หลังซื้อครั้งก่อน หรือรอครบ 5s ถ้า server ไม่ push
        if on and type(upState[k])=="number" and nw-lb>gap and (PK.upT>lb or nw-lb>5) then
            local bought=tryBuy(k)
            if bought then
                PK.lastBuy[k]=nw
                feedAdd(PK.upInfo[k][1].." "..bought,PK.upInfo[k][2]); slog("buy "..k.." "..bought.." @"..coins)
            end
        end
    end
end
task.spawn(function()
    while not UpState do task.wait(0.5) if not alive() then return end end
    UpState.OnClientEvent:Connect(function(p)
        if not alive() or type(p)~="table" then return end
        upState=p; PK.upT=os.clock()
        if PK.upLbl then PK.upLbl.Text=string.format("🔥 ความอบอุ่น Lv%s · 🎒 กระเป๋า Lv%s",tostring(p.warmth or "–"),tostring(p.carry or "–")) end
        if cfg.sub.upSoon then task.defer(function() pcall(PK.upTry) end) end
    end)
    slog("upgrade-hook")
end)
task.spawn(function() while alive() do
    pcall(PK.upTry)
    task.wait(2)
end end)

-- ============ ⛏ ซื้อ+ใส่พลั่วที่ดีที่สุดที่เงินพอ (ราคา/พลัง/ระยะขุดจริงจาก PickaxeData — radius 7→30, power 25→3M) ============
-- โปรโตคอลจริง (168_ShopClient): BuyPickaxe:FireServer(index,"cash") · EquipPickaxe:FireServer(index) · ShopState(owned[],equipped,err)
-- เราเข้าเกมทีหลัง ไม่ทันรับ ShopState รอบแรก → อ่านสถานะที่ถือจริงจากการ์ดใน PickaxeShopGui (OwnedButton.Visible / Label="Equipped") แทน
PK.pkTry={}; PK.pkLast=0
function PK.pkRead()   -- → (owned{[i]=true}, equippedIndex) | nil
    if not PK.PD then return nil end
    local pg=LP:FindFirstChild("PlayerGui"); local g=pg and pg:FindFirstChild("PickaxeShopGui")
    local win=g and g:FindFirstChild("Window"); local sh=win and win:FindFirstChild("Shelf")
    if not sh then return nil end
    local own,eq={},nil
    for i=1,#PK.PD do
        local c=sh:FindFirstChild("Card_"..i); local ob=c and c:FindFirstChild("OwnedButton")
        if ob and ob.Visible then
            own[i]=true
            local l=ob:FindFirstChild("Label"); if l and l.Text=="Equipped" then eq=i end
        end
    end
    return own,eq
end
function PK.pkState()   -- → best(สูงสุดที่มี), eq(ที่ใส่อยู่), own
    local own,eq=PK.pkRead()
    if not own then own=PK.pkOwn or {}; eq=PK.pkEq end
    eq=math.max(eq or 0,tonumber(LP:GetAttribute("EquippedPickaxe")) or 1)   -- attr จาก server คือความจริง (การ์ดใน GUI อาจยังไม่ refresh)
    local best=0 for i in pairs(own) do if i>best then best=i end end
    if best<eq then best=eq end
    return best,eq,own
end
function PK.pkNext(best)   -- พลั่วถัดไปที่ซื้อได้ด้วยเงิน (ข้ามของอีเวนต์ limited/ไม่มีราคา) → ราคา,index | nil
    for i=(best or 0)+1,#PK.PD do
        local d=PK.PD[i]
        if d and not d.limited and type(d.price)=="number" and d.price>0 then return d.price,i end
    end
end
function PK.coins() local ls=LP:FindFirstChild("leaderstats"); local cv=ls and ls:FindFirstChild("Coins"); return cv and cv.Value or 0 end
function PK.pickTry()
    if not (cfg.autoup and cfg.sub.upPick and PK.PD and PK.BuyPick) then return end
    local now=os.clock(); if now-PK.pkLast<3 then return end
    local best,eq,own=PK.pkState()
    if best>eq and (own[best] or PK.pkOwn and PK.pkOwn[best]) and PK.EqPick then       -- มีของดีกว่าที่ยังไม่ได้ใส่ → ใส่
        PK.pkLast=now; PK.EqPick:FireServer(best)
        local d=PK.PD[best]; feedAdd("⛏ ใส่พลั่ว "..tostring(d and d.name or best),Color3.fromRGB(255,215,120)); slog("equip pickaxe "..best.." "..tostring(d and d.name))
        return
    end
    local coins=PK.coins()
    for i=#PK.PD,best+1,-1 do                                                           -- ซื้ออันที่ดีที่สุดที่เงินพอ (ไล่จากบน)
        local d=PK.PD[i]
        if d and not d.limited and type(d.price)=="number" and d.price>0 and coins>=d.price and (PK.pkTry[i] or 0)<now then
            PK.pkTry[i]=now+60; PK.pkLast=now
            PK.BuyPick:FireServer(i,"cash")
            feedAdd(("⛏ ซื้อพลั่ว %s (radius %s · power %s)"):format(tostring(d.name),tostring(d.radius),tostring(d.power)),Color3.fromRGB(255,215,120))
            slog(("buy pickaxe %d %s @%s price=%s"):format(i,tostring(d.name),tostring(coins),tostring(d.price)))
            return
        end
    end
end
task.spawn(function()
    while not PK.PickSt do task.wait(0.5) if not alive() then return end end
    PK.PickSt.OnClientEvent:Connect(function(owned,eq,err)
        if not alive() then return end
        if err then slog("shop: "..tostring(err)) end
        if type(owned)=="table" then PK.pkOwn={} for _,i in ipairs(owned) do PK.pkOwn[i]=true end end
        if eq then PK.pkEq=eq end
        PK.pkLast=math.min(PK.pkLast,os.clock()-2.5)                                 -- ได้สถานะใหม่ → ตรวจรอบถัดไปได้เร็ว
    end)
    slog("shop-hook")
end)
task.spawn(function() while alive() do pcall(PK.pickTry) task.wait(3) end end)

-- ============ 🧪 กินยา (opt-in) — UsePotion(name) · server เช็คเองว่ามียา · Mining ใช้เวลาจริง MiningPotionUntil · Luck/Coins ไม่รู้ระยะเวลา → เว้น 15 นาที ============
PK.potN={}; PK.potT={}
function PK.potLoad(t) if type(t)=="table" then for k,v in pairs(t) do if type(v)=="number" then PK.potN[k]=v end end end end
function PK.potTry()
    if not (cfg.sub.autoPot and PK.UsePot) then return end
    local now=os.time()
    for _,n in ipairs({"MiningPotion","LuckPotion","CoinsPotion"}) do
        local have=PK.potN[n] or tonumber(LP:GetAttribute("Potion"..(n:gsub("Potion",""))))  or 0   -- จำนวนยา: จาก GetPotions/UpdatePotions ไม่งั้น attr ผู้เล่น PotionMining/PotionLuck/PotionCoins (server ตั้ง)
        local last=PK.potT[n] or 0
        if have>0 and now-last>20 then
            local active=(n=="MiningPotion") and now<(LP:GetAttribute("MiningPotionUntil") or 0) or (n~="MiningPotion" and now-last<(cfg._potGap or 900))
            if not active then
                PK.potT[n]=now; PK.potN[n]=have-1; PK.UsePot:FireServer(n)
                feedAdd("🧪 กิน "..n.." (เหลือ "..(have-1)..")",Color3.fromRGB(200,150,255)); slog("use potion "..n.." left="..(have-1))
                return
            end
        end
    end
end
task.spawn(function()
    task.wait(2)
    if PK.GetPot then local ok,t=pcall(function() return PK.GetPot:InvokeServer() end) if ok then PK.potLoad(t) end end
    if PK.UpdPot then PK.UpdPot.OnClientEvent:Connect(function(n,c) if alive() and type(n)=="string" and type(c)=="number" then PK.potN[n]=c end end) end
    if PK.SyncPot then PK.SyncPot.OnClientEvent:Connect(function(t) if alive() then PK.potLoad(t) end end) end
    while alive() do pcall(PK.potTry) task.wait(15) end
end)

-- ============ 🥶 หนาวจัด + เลือดต่ำ → วาปกลับฐาน (กันตายตอน AFK) — สูตรหนาวเดียวกับ FreezeClient.inTheCold ============
function PK.isCold(hrp)
    if not (AltY and AltS and hrp) then return false end
    local w=((LP:GetAttribute("Warmth") or 120)+(LP:GetAttribute("AbuseWarmthBonus") or 0))*(LP:GetAttribute("RuneWarmthMult") or 1)*2.5
    return w<=(hrp.Position.Y-AltY.Value)*AltS.Value
end
PK.homeT=-99
task.spawn(function() while alive() do
    if cfg.sub.coldHome and (cfg.autodig or cfg.autocollect or cfg.selfOn) then pcall(function()
        local ch=LP.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid"); local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp and PK.THome) or hum.MaxHealth<=0 then return end
        local hp=hum.Health/hum.MaxHealth
        if hp>0 and hp<0.45 and PK.isCold(hrp) and not LP:GetAttribute("Ragdolled") and os.clock()-PK.homeT>25 then
            PK.homeT=os.clock(); PK.THome:FireServer()
            feedAdd(("🥶 หนาวจัด เลือด %d%% → วาปกลับฐานกันตาย"):format(hp*100),Color3.fromRGB(120,190,255))
            slog(("cold-home hp=%d%% warmth=%s y=%d"):format(hp*100,tostring(LP:GetAttribute("Warmth")),hrp.Position.Y))
        end
    end) end
    task.wait(1)
end end)

-- ============ 🛡 กันเกม rejoin ตอน AFK: AntiIdleClient ยิง AntiIdleRejoin เมื่อไม่มี input 1140s (19 นาที) → สคริปต์ตายตามไปด้วย ============
-- bump() ของเกมผูกกับ InputBegan/InputChanged/TouchMoved/WindowFocused/Mouse.Move → ยิงเฉพาะ WindowFocused (ไม่มี arg ปลอดภัย) ทุก 3 นาที รีเซ็ตตัวนับของเกม
function PK.antiIdle()
    local n=0
    if getconnections then
        local ok,cs=pcall(getconnections,UIS.WindowFocused)
        if ok and type(cs)=="table" then for _,c in ipairs(cs) do if pcall(function() c:Fire() end) then n+=1 end end end
    end
    if n==0 then pcall(function()   -- สำรอง: ขยับเมาส์ผ่าน VirtualInputManager → UIS.InputChanged → bump
        local vim=game:GetService("VirtualInputManager"); local m=UIS:GetMouseLocation()
        vim:SendMouseMoveEvent(m.X+1,m.Y,game); vim:SendMouseMoveEvent(m.X,m.Y,game); n+=1
    end) end
    PK.idleN=(PK.idleN or 0)+1
    if PK.idleN<=2 or PK.idleN%20==0 then slog("anti-idle bump x"..n.." (#"..PK.idleN..")") end
end
task.spawn(function() task.wait(20) while alive() do pcall(PK.antiIdle) task.wait(180) end end)

-- ============ กันเหวแบบเร็ว: เช็คพื้นข้างหน้าทุก 0.15s (ลูปหลัก 0.9s ช้าเกินตอนวิ่งไว 2x = พุ่ง 29 studs/รอบ) ============
task.spawn(function() while alive() do
    if cfg.selfOn then pcall(function()
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
    LP.Idled:Connect(function() if alive() then pcall(function() local VU=game:GetService("VirtualUser") VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end end)
end

-- ============ เจ็ทแพ็ค: เติมน้ำมันไม่จำกัด — เข้าถึง t9.fuel (upvalue ของสคริปต์เกมเอง) ============
function PK.makeJet(hrp2)   -- สร้างเจ็ทแพ็คเองจาก primitives — เกมเลิกขายแล้ว (JetpackGamepass หายจากแมพ 2026-10-19) · โครงตามของจริงใน dump_2026-10-14/03_tree_workspace.txt
    local m=Instance.new("Model"); m.Name="Jetpack"
    local function part(n,size,cf,col,shape)
        local p=Instance.new("Part"); p.Name=n; p.Size=size; p.CFrame=cf
        p.Color=col; p.Material=Enum.Material.Metal; if shape then p.Shape=shape end
        p.Anchored=false; p.CanCollide=false; p.Massless=true; p.Parent=m; return p
    end
    local base=hrp2.CFrame*CFrame.new(0,0.15,0.9)
    local root=part("Root",Vector3.new(1.5,2.2,0.55),base,Color3.fromRGB(52,55,62))
    local cy=Enum.PartType.Cylinder; local tk=Color3.fromRGB(88,92,105); local up=CFrame.Angles(0,0,math.rad(90))
    part("TankL",Vector3.new(1.9,0.85,0.85),base*CFrame.new(-0.55,0,0.28)*up,tk,cy)
    part("TankR",Vector3.new(1.9,0.85,0.85),base*CFrame.new(0.55,0,0.28)*up,tk,cy)
    part("BandL",Vector3.new(0.3,0.92,0.92),base*CFrame.new(-0.55,0.5,0.28)*up,Color3.fromRGB(255,140,40),cy)
    part("BandR",Vector3.new(0.3,0.92,0.92),base*CFrame.new(0.55,0.5,0.28)*up,Color3.fromRGB(255,140,40),cy)
    local ball=Enum.PartType.Ball
    part("Light_Green", Vector3.new(0.24,0.24,0.24),base*CFrame.new(-0.5,1.3,0.2),Color3.fromRGB(80,255,120),ball)
    part("Light_Orange",Vector3.new(0.24,0.24,0.24),base*CFrame.new(0,1.33,0.2),   Color3.fromRGB(255,170,60),ball)
    part("Light_Red",   Vector3.new(0.24,0.24,0.24),base*CFrame.new(0.5,1.3,0.2),  Color3.fromRGB(255,80,80),ball)
    for i,x in ipairs({-0.55,0.55}) do   -- หัวพ่นใต้ถัง — JetpackVisuals emit Bottom → ไฟพุ่งลง
        local a=Instance.new("Attachment"); a.Name=i==1 and "NozzleL" or "NozzleR"
        a.WorldCFrame=base*CFrame.new(x,-1.15,0.28); a.Parent=root
    end
    local bm=Instance.new("Attachment"); bm.Name="BackMount"; bm.Parent=root
    for _,d in m:GetDescendants() do
        if d:IsA("BasePart") and d~=root then
            local w=Instance.new("WeldConstraint"); w.Part0=root w.Part1=d w.Parent=d
        end
    end
    local w=Instance.new("WeldConstraint"); w.Part0=hrp2 w.Part1=root w.Parent=root
    m.PrimaryPart=root
    m:SetAttribute("Display",false); m:SetAttribute("StandIn",true)
    m:SetAttribute("FuelPct",1); m:SetAttribute("Thrusting",false); m:SetAttribute("_hzclone",true)
    return m
end
function PK.jetFuelMax()
    if not cfg._jetMax then
        local ok,m=pcall(function() return require(RS:WaitForChild("JetpackSystem"):WaitForChild("Config")) end)
        cfg._jetMax=(ok and type(m)=="table" and m.FUEL_MAX) or false
    end
    return cfg._jetMax or nil
end
function PK.jetSess()                                                 -- หา session table (t9) ของ JetpackClient — สแกน signature ทุก Heartbeat connection (ไม่พึ่งรูปแบบ source)
    local ok,conns=pcall(getconnections,RunS.Heartbeat)
    if not ok or not conns then return end
    for _,cn in conns do
        local f=cn.Function or cn.func
        if type(f)=="function" then
            for i=1,30 do
                local n,v=debug.getupvalue(f,i)
                if not n then break end
                if type(v)=="table" and rawget(v,"fuel")~=nil and rawget(v,"lv")~=nil and rawget(v,"conns")~=nil then return v end
            end
        end
    end
end

-- ============ ตัวเรา: วิ่งไว (client-owned physics — จำค่าจริงก่อนแกะ ปิด→คืน) ============
-- (ห่อ pcall: error ครั้งเดียวเคยฆ่าลูปนี้ถาวร → วิ่งไว/คืน WalkSpeed ค้าง)
task.spawn(function() while alive() do
    pcall(function()
    local ch=LP.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then
        local want = cfg.selfOn and (cfg.sub.spd2 and 32 or (cfg.sub.spd15 and 24 or nil)) or nil
        if want then
            if not cfg._baseWS then cfg._baseWS=hum.WalkSpeed end
            if hum.WalkSpeed~=want then hum.WalkSpeed=want end
        elseif cfg._baseWS and hum.WalkSpeed~=cfg._baseWS then
            hum.WalkSpeed=cfg._baseWS; cfg._baseWS=nil
        end
        if cfg.selfOn and cfg.sub.jet then
            local exJ=ch:FindFirstChild("Jetpack")
            if exJ and exJ:GetAttribute("_hzclone") and not exJ:FindFirstChildWhichIsA("BasePart",true) then
                pcall(function() exJ:Destroy() end) exJ=nil   -- เจ็ทเปล่าค้างจากรอบก่อน → ลบแล้วหาโมเดลจริงใหม่
            end
            if not exJ then
                -- หาโมเดลเจ็ทแพ็คจริงจากหลายแหล่ง (อัพเดต 2026-10-19: JetpackGamepass = folder → .Model ข้างใน)
                local pk=nil
                local jg=workspace:FindFirstChild("JetpackGamepass")
                if jg then
                    pk=jg:FindFirstChild("Jetpack")
                    if not pk then
                        local mdl=jg:FindFirstChild("Model")
                        if mdl and mdl:IsA("Model") then
                            pk=mdl:FindFirstChild("Jetpack",true) or mdl
                        end
                    end
                    if not pk then pk=jg:FindFirstChildWhichIsA("Model",true) end
                end
                if not pk then   -- ขโมยจากผู้เล่นคนอื่นที่สวมเจ็ทจริงอยู่
                    for _,pl in ipairs(Players:GetPlayers()) do
                        if pl~=LP and pl.Character then
                            local j=pl.Character:FindFirstChild("Jetpack")
                            if j and j:IsA("Model") then pk=j break end
                        end
                    end
                end
                if not pk then pk=RS:FindFirstChild("Jetpack",true) end   -- template ใน ReplicatedStorage ถ้ามี
                local hrp2=ch:FindFirstChild("HumanoidRootPart")
                if not pk and hrp2 then
                    -- เกมเลิกขายแล้ว → สร้างเจ็ทแพ็คเองจาก primitives (ถังคู่+ไฟ+หัวพ่น) — visuals ของเกมวาดไฟให้
                    local m=PK.makeJet(hrp2)
                    m.Parent=ch; cfg._jetPack=m
                    pcall(function() game:GetService("CollectionService"):AddTag(m,"Jetpack") end)
                    feedAdd("🚀 สร้างเจ็ทแพ็คเอง (ร้านปิดแล้ว — โมเดลปลอม+ไฟจริง)",3,C.good)
                elseif pk and hrp2 then
                    local c=pk:Clone()
                    c.Name="Jetpack"   -- client เช็คชื่อเป๊ะ "Jetpack" + IsA Model (JetpackClient:tryPack)
                    c:SetAttribute("Display",false)                       -- ปิดโหมดตัวโชว์ (เอฟเฟกต์เต็ม)
                    c:SetAttribute("StandIn",true)
                    c:SetAttribute("FuelPct",1) c:SetAttribute("Thrusting",false)
                    c:SetAttribute("_hzclone",true)
                    for _,d in c:GetDescendants() do
                        if d:IsA("BasePart") then d.Anchored=false d.CanCollide=false d.Massless=true
                        elseif d:IsA("ParticleEmitter") or d:IsA("PointLight") or d:IsA("Sound") then d:Destroy()
                        elseif d:IsA("ProximityPrompt") or d:IsA("Script") or d:IsA("LocalScript") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then d:Destroy() end
                    end                                                -- ของเดิมเผาค้าง + prompt/GUI ร้านตัวโชว์ออก (ไม่งั้นป้ายซื้อลอยติดหลัง)
                    local root=c:FindFirstChild("Root") or c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart",true)
                    if root then
                        if not c.PrimaryPart then pcall(function() c.PrimaryPart=root end) end
                        c:PivotTo(hrp2.CFrame*CFrame.new(0,0.15,0.9))     -- ย้าย "ทั้งโมเดล" มาหลัง — เดิมย้ายแค่ Root → part ลูกค้างที่ร้าน = bounding กาง = สเกลไฟพุ่งเป็นระเบิด
                        for _,d in c:GetDescendants() do
                            if d:IsA("BasePart") and d~=root then
                                local w=Instance.new("WeldConstraint")    -- part ลูกเชื่อมเข้า root (ของเดิมอาศัย anchor อยู่นิ่ง ไม่มี weld กันเอง)
                                w.Part0=root w.Part1=d w.Parent=d
                            end
                        end
                        local w=Instance.new("WeldConstraint")            -- ติดหลังเหมือนของจริง
                        w.Part0=hrp2 w.Part1=root w.Parent=root
                    end
                    c.Parent=ch        -- JetpackClient ของเกมจับ ChildAdded → startSession เอง = ระบบบิน+น้ำมันจริง
                    pcall(function() game:GetService("CollectionService"):AddTag(c,"Jetpack") end)   -- JetpackVisuals วาดไฟผ่าน tag (0134:316)
                    cfg._jetPack=c     -- จำ ref ไว้ — ถ้าโดนย้าย parent FindFirstChild จะหาไม่เจอ
                    feedAdd("🚀 เจ็ทแพ็คพร้อม — กดโดดค้างตอนอยู่กลางอากาศ (ทดลอง)",3,C.good)
                end
            end
            local _,mx=pcall(PK.jetFuelMax)                              -- น้ำมันไม่จำกัด: เติม t9.fuel ให้เต็มทุก 0.2s
            if not mx then mx=100 end                                   -- fallback ถ้า require Config ไม่ได้ (ค่าทั่วไป ~100)
            local ok4,s=pcall(PK.jetSess)
            if ok4 and s then
                if s.fuel<mx then s.fuel=mx end
                if not cfg._jetSessOK then cfg._jetSessOK=true feedAdd("⛽ น้ำมันไม่จำกัด เชื่อมแล้ว",3,C.good) end
            elseif ok4 and not s and not cfg._jetSessMiss then
                cfg._jetSessMiss=true feedAdd("⚠️ หาเซสชันเจ็ทไม่เจอ — น้ำมันยังจำกัด",4,Color3.fromRGB(255,180,60))
            end
            local pk2=ch:FindFirstChild("Jetpack")                        -- ซ่อนแพ็คตอนไม่บิน (ดีเลย์ 0.8s กันกะพริบ)
            if pk2 and pk2:GetAttribute("_hzclone") then pcall(function()
                local hrp3=ch:FindFirstChild("HumanoidRootPart")
                local lv=hrp3 and hrp3:FindFirstChild("JetpackThrust")    -- LV ที่เกมสร้างจริง — Enabled = พ่นอยู่ตอนนี้เป๊ะ (ไม่พึ่ง attr ที่อาจค้าง)
                local flying=(lv and lv.Enabled==true) or (pk2:GetAttribute("Thrusting")==true and hum.FloorMaterial==Enum.Material.Air)
                if flying then cfg._jetOffT=os.clock() end
                local hidew=(os.clock()-(cfg._jetOffT or 0))>0.8
                if cfg._jetHideSt~=hidew then
                    cfg._jetHideSt=hidew
                    feedAdd(hidew and "🫥 ซ่อนแพ็ค" or "🚀 โชว์แพ็ค",1.5,C.dim)
                    for _,d in pk2:GetDescendants() do
                        if d:IsA("BasePart") then
                            if hidew then
                                if d:GetAttribute("_t0")==nil then d:SetAttribute("_t0",d.Transparency) end
                                d.Transparency=1 d.LocalTransparencyModifier=1
                            else
                                d.Transparency=d:GetAttribute("_t0") or 0
                                d.LocalTransparencyModifier=0
                            end
                        end
                    end
                end
            end) end
        else
            if cfg._jetPack then pcall(function() cfg._jetPack:Destroy() end) cfg._jetPack=nil cfg._jetHideSt=nil end
            local left=0
            for _,d in ch:GetChildren() do
                if d.Name=="Jetpack" then
                    if d:GetAttribute("_hzclone") then d:Destroy() else left+=1 end   -- ของเรา=ลบ / ของเกมจริง=นับรายงาน
                end
            end
            if left>0 and not cfg._jetWarn then cfg._jetWarn=true feedAdd("⚠️ เหลือ Jetpack "..left.." ตัวที่ไม่ใช่ของเรา — อาจเป็นของเกมให้จริง/ตัวโชว์ ลบไม่ได้",4,Color3.fromRGB(255,180,60)) end
        end
    end
    end)
    task.wait(0.2)
end end)

-- ============ สกิลเคียว/ค้างคาว: ยิงอัตโนมัติเมื่อถือ + cooldown พร้อม (Holding*/ReadyAt = server ตั้ง ยิงมั่วไม่ได้) ============
task.spawn(function() while alive() do
    if cfg.selfOn and cfg.sub.skillAuto then pcall(function()
        local holdS=LP:GetAttribute("HoldingScythe")==true
        local holdB=LP:GetAttribute("HoldingBatwing")==true
        if holdS or holdB then
            local now=workspace:GetServerTimeNow()
            local dir
            local ch=LP.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
            local sg=workspace:FindFirstChild("SpawnedGems")
            local bd,bp=1/0,nil
            if hrp and sg then
                for _,g in sg:GetChildren() do
                    local ok2,cf=pcall(function() return g:GetPivot() end)   -- PrimaryPart มักไม่ถูกตั้งในโมเดลแรร์ (เดิมข้ามหมด → เล็งกล้องแทน) → ใช้ pivot
                    if ok2 and cf then local d=(cf.Position-hrp.Position).Magnitude if d<bd then bd=d bp=cf.Position end end
                end
            end
            dir=(bp and hrp) and (bp-hrp.Position).Unit or (workspace.CurrentCamera and workspace.CurrentCamera.CFrame.LookVector) or Vector3.new(0,0,-1)
            pcall(function()
                if holdS and now>=(LP:GetAttribute("ScytheReadyAt") or 0) then
                    RS:WaitForChild("ScytheRemotes"):WaitForChild("Shatter"):FireServer(dir)
                    feedAdd("⚔️ Shatter → "..(bd<1e9 and math.floor(bd).."m" or "?"),2,C.good)
                end
                if holdB and now>=(LP:GetAttribute("BatwingReadyAt") or 0) then
                    RS:WaitForChild("BatwingRemotes"):WaitForChild("Swarm"):FireServer(dir)
                    feedAdd("🦇 Swarm → "..(bd<1e9 and math.floor(bd).."m" or "?"),2,C.good)
                end
            end)
        end
    end) end
    task.wait(0.5)
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
    pcall(function()
    fullScan(); scanRunes()
    local nd=0 for m in pairs(known) do if m.Parent==nil then nd+=1 end end
    if nd>2500 then   -- AFK เป็นชั่วโมง: known สะสมโมเดลที่หายไปแล้ว (ถือ reference โมเดลที่ถูกทำลาย = กินหน่วยความจำ) → ล้างตัวที่ไม่มีใน registry ping
        for m in pairs(known) do if m.Parent==nil then known[m]=nil knownPos[m]=nil missK[m]=nil end end
        slog("known trim "..nd)
    end
    -- ตัวที่ unstream แต่อยู่ใกล้เรา (<180 studs): โซนนี้ server stream แน่ๆ → model หาย = โดนเก็บ/รีจริง → นับพลาด 2 รอบแล้วลบ
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
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
                        PK.rmFar(e) table.remove(pings,i) dropped+=1
                    end
                end
            end
        end
        if dropped>0 then feedAdd("🧹 เคลียร์ของหายจริง "..dropped.." จุด",C.dim) slog("sweep dropped "..dropped) end
    end
    end)
end end)

-- ============ 💣 ระเบิดสอยสต็อก + ☢️ นิวเคลียร์ (อัพเดต 2026-10-19 — ค่าจริง BombData/BombShopClient) ============
-- ระเบิด 9 แบบซื้อด้วยเงินเกม: BuyBomb:FireServer(id,"cash") · stock จำกัด push ผ่าน ShopState {stock={id=n}} · restock ทุก 3600s
-- Nuke = DevProduct 699R$ เท่านั้น (price=0 stock=0 ในตาราง) — ซื้อ/ใช้ด้วยเงินเกมไม่ได้ (server เช็คของจริง)
PK.BOMBS={
    {id="ClassicBomb",  n="คลาสสิค",    price=50000,   g="lo"},
    {id="WindBomb",     n="หิมะ",       price=400000,  g="lo"},
    {id="IceBomb",      n="น้ำแข็ง",    price=2000000, g="lo"},
    {id="FireBomb",     n="ไฟ",         price=8000000, g="mid"},
    {id="PoisonBomb",   n="พิษ",        price=12000000,g="mid"},
    {id="LightningBomb",n="สายฟ้า",     price=25000000,g="mid"},
    {id="VoidBomb",     n="โวิด",       price=1e9,     g="hi"},
    {id="NebulaBomb",   n="เนบิวลา",    price=1e10,    g="hi"},
    {id="DivineBomb",   n="ศักดิ์สิทธิ์", price=2.5e10,  g="hi"},
}
PK.bombStock={}; PK.bombTry={}
task.spawn(function()
    while not PK.BombSt do task.wait(0.5) if not alive() then return end end
    PK.BombSt.OnClientEvent:Connect(function(st)
        if not alive() or type(st)~="table" then return end
        local sk=st.stock or st.Stock
        if type(sk)~="table" then return end
        for k,v in pairs(sk) do if type(v)=="number" then PK.bombStock[k]=v end end
        if UI.bomStat then
            local parts={}
            for _,b in ipairs(PK.BOMBS) do if (PK.bombStock[b.id] or 0)>0 then parts[#parts+1]=b.n.."×"..PK.bombStock[b.id] end end
            UI.bomStat.Text="📦 สต็อกล่าสุด: "..(#parts>0 and table.concat(parts," · ") or "หมดทุกชนิด")
        end
        pcall(PK.bombTick)   -- สต็อกเพิ่งเข้า → สอยทันที (เร็วกว่ารอ poll)
    end)
    slog("bomb-hook")
end)
function PK.bombTick()
    if not (cfg.bombSnipe and PK.BuyBomb) then return end
    local coins=PK.coins(); local now=os.clock()
    for _,b in ipairs(PK.BOMBS) do
        local on=cfg.sub["snB_"..b.id]
        if on and (PK.bombStock[b.id] or 0)>0 and coins>=b.price and (PK.bombTry[b.id] or 0)<now then
            PK.bombTry[b.id]=now+15
            pcall(function() PK.BuyBomb:FireServer(b.id,"cash") end)
            feedAdd("💣 สอยระเบิด "..b.n.." ($"..comma(b.price)..")",Color3.fromRGB(255,160,80)); slog("buy bomb "..b.id.." @"..coins)
        end
    end
end
task.spawn(function() while alive() do pcall(PK.bombTick) task.wait(3) end end)

-- 💣 ระเบิดออโต้ (ซื้อ+โยนเอง) — ของจริงเท่านั้น: โคลนใช้ไม่ได้ (server แนบ Script ตอนให้ของจริง / ไม่มี client path)
PK.BOMBMAP={} for _,b in ipairs(PK.BOMBS) do PK.BOMBMAP[b.id]=b end
function PK.bombBest()   -- → Tool | nil — ระเบิดจริงลูกแพงสุดในกระเป๋า/มือ (ข้าม _hzclone)
    local best,bs=nil,-1; local bp=LP:FindFirstChild("Backpack"); local ch=LP.Character
    for _,pa in ipairs({bp,ch}) do if pa then for _,c in ipairs(pa:GetChildren()) do
        if c:IsA("Tool") then local bt=c:GetAttribute("BombType")
            local p=(PK.BOMBMAP[bt] and PK.BOMBMAP[bt].price) or (bt=="Nuke" and 9e18) or 0
            if bt and not c:GetAttribute("_hzclone") and p>bs then best,bs=c,p end
        end
    end end end
    return best
end
function PK.bombBuyBest()   -- → id | nil — ซื้อลูกแพงสุดที่ติ๊กไว้+สต็อกมี+เงินพอ (ใช้กลุ่มเดียวกับสอยสต็อก)
    if not PK.BuyBomb then return nil end
    local coins=PK.coins(); local now=os.clock()
    for i=#PK.BOMBS,1,-1 do local b=PK.BOMBS[i]
        local on=cfg.sub["snB_"..b.id]
        if on and (PK.bombStock[b.id] or 0)>0 and coins>=b.price and (PK.bombTry[b.id] or 0)<now then
            PK.bombTry[b.id]=now+15
            pcall(function() PK.BuyBomb:FireServer(b.id,"cash") end)
            feedAdd("💣 ซื้อระเบิด "..b.n.." ($"..comma(b.price)..")",Color3.fromRGB(255,160,80)); slog("bombAuto buy "..b.id.." @"..coins)
            return b.id
        end
    end
    return nil
end
function PK.useBomb()   -- ถือ+กระตุ้นระเบิดจริงลูกแพงสุด → server script ใน tool ระเบิดเอง · คืนพลั่วหลังโยน
    local best=PK.bombBest()
    if not best then feedAdd("💣 ไม่มีระเบิดในกระเป๋า — เปิด 💣 ระเบิดสอยสต็อก/ออโต้ให้ซื้อเอง",C.dim) return false end
    local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and best.Parent~=LP.Character then pcall(function() hum:EquipTool(best) end) task.wait(0.2) end
    local ok,err=pcall(function() best:Activate() end)
    feedAdd("💣 กระตุ้น "..tostring(best:GetAttribute("BombType")).." "..(ok and "" or "พลาด:"..tostring(err)),3,ok and C.good or C.bad)
    slog("useBomb "..tostring(best:GetAttribute("BombType")).." ok="..tostring(ok))
    if hum then task.delay(0.4,function()   -- คืนพลั่วให้ขุดต่อ (ระเบิดไม่ต้องถือค้าง)
        local bp=LP:FindFirstChild("Backpack")
        for _,tt in ipairs((bp and bp:GetChildren()) or {}) do if PK.isPick(tt) then pcall(function() hum:EquipTool(tt) end) break end end
    end) end
    return ok
end
task.spawn(function()   -- ลูปออโต้: มีของ → โยนวน · ไม่มี → ซื้อลูกดีสุดเอง (รอ fuse ก่อนช็อตถัดไป)
    while alive() do
        if cfg.bombAuto then pcall(function()
            local t=PK.bombBest()
            if not t then PK.bombBuyBest() task.wait(3)
            else
                PK.useBomb()
                local w=0; while t.Parent and w<9 do task.wait(0.5) w+=0.5 end   -- รอ server กิน tool หลัง fuse (2-4s)
            end
        end) else task.wait(1) end
        task.wait(0.5)
    end
end)

-- ============ ⚗️ ฟิวส์คริสตัล (FusionClient: Fuse({BagId,BagId,BagId} ระดับเดียวกัน) → Claim() · Status() เช็คเครื่อง) ============
PK.fusBusy=false
function PK.bagGems()
    local bp=LP:FindFirstChild("Backpack"); local out={}
    if not bp then return out end
    for _,t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then
            local id,g=t:GetAttribute("BagId"),t:GetAttribute("GemName")
            if id and g then out[#out+1]={id=id,name=g,rarity=t:GetAttribute("Rarity") or "Common",kg=t:GetAttribute("Kg") or 0,
                fav=t:GetAttribute("Favorited")==true,t=t} end   -- Favorited = attr ⭐จริงของเกม (HotbarClient:1180 / FusionClient:1301)
        end
    end
    return out
end
function PK.fusePick()   -- → {BagId×3},rarity | nil — ชิ้นระดับเดียวกัน ≥3, เล็กสุดก่อน, เว้น ⭐ และระดับ ≥fusKeep
    local keep=cfg.sub.fusKeep or 6; local by={}
    for _,g in ipairs(PK.bagGems()) do
        local ri=tIdx(g.rarity)
        if not g.fav and ri>0 and ri<keep then by[g.rarity]=by[g.rarity] or {} table.insert(by[g.rarity],g) end
    end
    local bestR,bestL=nil,nil
    for r,l in pairs(by) do
        if #l>=3 and (not bestL or tIdx(r)<tIdx(bestR)) then bestR,bestL=r,l end
    end
    if not bestL then return nil end
    table.sort(bestL,function(a,b) return (a.kg or 0)<(b.kg or 0) end)
    return {bestL[1].id,bestL[2].id,bestL[3].id},bestR
end
function PK.fuseOnce()
    if PK.fusBusy then return end
    if not PK.FusFuse then feedAdd("⚗️ ไม่มี remote ฟิวส์",C.bad) return end
    local ids,r=PK.fusePick()
    if not ids then feedAdd("⚗️ ไม่มี 3 ชิ้นระดับเดียวกันที่ฟิวส์ได้",C.dim) return end
    PK.fusBusy=true
    local ok,res=pcall(function() return PK.FusFuse:InvokeServer(ids) end)
    if ok and type(res)=="table" and res.ok then
        feedAdd("⚗️ ฟิวส์ "..PK.thR(r).." สำเร็จ!",C.good); slog("fuse ok "..tostring(r))
        task.wait(0.8)
        if PK.FusClaim then
            local ok2,r2=pcall(function() return PK.FusClaim:InvokeServer() end)
            if ok2 and type(r2)=="table" and r2.ok then feedAdd("⚗️ เก็บผลฟิวส์แล้ว",C.good) end
        end
    else
        feedAdd("⚗️ ฟิวส์ไม่ผ่าน: "..tostring(type(res)=="table" and (res.err or res.reason) or res),C.bad)
        slog("fuse fail "..tostring(res))
    end
    PK.fusBusy=false
end
function PK.fuseStatus()
    if not PK.FusStat then feedAdd("⚗️ ไม่มี remote Status",C.bad) return end
    local ok,res=pcall(function() return PK.FusStat:InvokeServer() end)
    local txt="?"
    if ok and type(res)=="table" then
        txt=res.pending and ("ค้างผล: "..tostring(res.pending)) or res.stage and ("ขั้น: "..tostring(res.stage)) or "ว่าง"
    elseif ok then txt=tostring(res) end
    feedAdd("⚗️ เครื่องฟิวส์: "..txt,C.dim); slog("fusStatus "..tostring(res))
end
task.spawn(function() while alive() do    -- โหมดอัตโน: มีชิ้นซ้ำฟิวส์ได้ → ฟิวส์เองทุก 20s
    if cfg.fusion and not PK.fusBusy and PK.FusFuse and PK.fusePick() then pcall(PK.fuseOnce) end
    task.wait(20)
end end)

-- ============ 🎃 Halloween 2026 (CrateData/CauldronClient/CrateShopClient จริง) ============
PK.CRATE_COST={[1]=2000,[3]=5700,[5]=9000}   -- แคนดี้ต่อกล่อง (Haunted Crate · อีเวนต์ถึง ~Nov 3)
function PK.candy() return math.floor(tonumber(LP:GetAttribute("CandyCorn")) or 0) end
function PK.cauldronPour(frac)
    if not PK.Cauldron then feedAdd("🍬 ไม่มี remote หม้อ",C.bad) return end
    local amt=math.floor(PK.candy()*(frac or 0.1))
    if amt<1 then feedAdd("🍬 แคนดี้ไม่พอเท",C.dim) return end
    local ok,res=pcall(function() return PK.Cauldron:InvokeServer(amt) end)
    if ok and type(res)=="table" and res.ok then
        feedAdd("🍬 เท "..comma(res.accepted or amt).." เข้าหม้อ"..(res.filled and " — เต็มแล้ว!" or ""),Color3.fromRGB(255,170,80))
    else
        feedAdd("🍬 เทไม่ได้: "..tostring(type(res)=="table" and res.reason or res),C.dim)
    end
end
task.spawn(function() while alive() do    -- อัปเดตยอดแคนดี้ + เปิดกล่องอัตโน (เฉพาะเมื่อแคนดี้พอ — server คุมราคา/ผลเอง)
    if UI.candyStat then pcall(function() UI.candyStat.Text="🍬 แคนดี้: "..comma(PK.candy()) end) end
    if cfg.halloween and cfg.sub.crateAuto and PK.CrateOpen then
        local n=cfg.sub.crateN or 1; local cost=PK.CRATE_COST[n] or 2000
        if PK.candy()>=cost then
            local ok,res=pcall(function() return PK.CrateOpen:InvokeServer(n) end)
            if ok and type(res)=="table" and res.ok~=false then
                feedAdd("📦 กล่องผี ×"..n.." → "..tostring(res.name or res.item or res.rarity or res.ok or "เปิดแล้ว"),Color3.fromRGB(255,170,80))
                slog("crate x"..n.." "..tostring(res.name or res.item or res.rarity or res.ok))
            elseif not ok then slog("crate err "..tostring(res))
            else slog("crate denied "..tostring(res.reason or res.err or res.ok)) end
        end
    end
    task.wait(8)
end end)
task.spawn(function()    -- 🎁 เคลมรางวัลรายวัน: Claim("claim") — รอเกมโหลดแล้วเคลม + ตรวจทุก 5 นาที
    task.wait(25)
    while alive() do
        if cfg.halloween and cfg.sub.autoDaily and PK.Daily then
            local ok,res=pcall(function() return PK.Daily:InvokeServer("claim") end)
            if ok and type(res)=="table" and res.ok then
                feedAdd("🎁 เคลมรางวัลรายวัน: "..tostring(res.reward or res.name or res.day or "สำเร็จ"),Color3.fromRGB(255,200,90))
                slog("daily claim "..tostring(res.reward or res.name or res.day))
            end
        end
        task.wait(300)
    end
end)

slog("ui ready")
print("[HZMINE] ESP พร้อม")
