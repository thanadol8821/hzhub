-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-1907
-- ============================================================
local function _b(src, n)
	local f, e = loadstring(src, "=" .. n)
	if not f then error("[" .. n .. "] " .. tostring(e), 0) end
	return f()
end
local FishUI = _b([==[
-- ============================================================
-- HZ HUB UI (FishUI) — ไฟล์รวมไฟล์เดียว
-- สร้างจาก FishUI/ ด้วย tools/build.py — อย่าแก้ไฟล์นี้ตรง ๆ (แก้ที่โมดูลแล้ว build ใหม่)
-- ============================================================
-- FishUI v1 — 1:1 replica ของ Fishy Hub UI (dump จาก instance จริงในเกม)
-- ใช้: local FishUI = loadstring(readfile("FishUI.lua"))()
--   local win = FishUI.Window{ title="Fishy Hub", brand="Fishy Studios", footer="my game" }
--   local pg  = win:Page("Main")
--   local sub = pg:Sub("Combat")            -- optional; sub แรกโชว์อัตโนมัติ
--   local gb  = sub:Groupbox("Settings","Left")  -- "Left"/"Right"
--   gb:Toggle{label="Auto Parry",key=Enum.KeyCode.P,default=false,cb=fn}
--   gb:Button{label="Panic",cb=fn}
--   gb:Slider{label="Delay",min=0,max=300,default=90,suffix="ms",cb=fn}
--   gb:Dropdown{label="Mode",options={"A","B"},default="A",cb=fn}
--   gb:Input{label="Name",placeholder="...",cb=fn}
--   gb:Warn{title="!",text="careful"}
--   win:Notify{title="x",text="y"}  win:Destroy()

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunS = game:GetService("RunService")
local GuiS = game:GetService("GuiService")
local LP = game:GetService("Players").LocalPlayer
local FishUI = {}
-- ============================================================
-- HZ HUB — โหลดโมดูล (Xeno: ไม่ใช้ require ของ Roblox)
-- ============================================================
local D = {FishUI=FishUI}
local _m = {}
-- ที่เก็บคีย์ที่จำไว้ — เปลี่ยนได้ (Guard จะมาแทนด้วยแบบเข้ารหัสผูกเครื่อง): FishUI.KeyStore={load=,save=,clear=}
FishUI.KeyStore = {
	load=function() local ok,s=pcall(readfile,"FishUI/key.txt") if ok and type(s)=="string" and s~="" then return s end end,
	save=function(k) pcall(function() if makefolder and not isfolder("FishUI") then makefolder("FishUI") end writefile("FishUI/key.txt",k) end) end,
	clear=function() pcall(function() if delfile and isfile("FishUI/key.txt") then delfile("FishUI/key.txt") end end) end,
}
-- [[MODULES-INLINE]]
	_m["tokens"]=loadstring([[
-- ============================================================
-- FishUI/tokens.lua — design tokens ทั้งหมด (ข้อความ/สี/ฟอนต์/ธีม)
-- ใส่ลง D : STR, FT, TH, IMG, THEMES
-- อ่านจาก D: (ไม่มี — ไฟล์นี้ไม่ต้องการ dependency)
-- ============================================================
return function(D)
	local STR = {
	welcome="ยินดีต้อนรับสู่", update="อัปเดต",
	userInfo="ข้อมูลผู้ใช้", connected="เชื่อมต่อกับ %s แล้ว",
	svcActive="กำลังใช้งาน", svcVerified="ยืนยันแล้ว: ใช้งานได้ครบทุกฟีเจอร์",
	safeAccess="รับคีย์ครั้งเดียว ใช้ได้ทุกเกมที่รองรับ",
	keyPlaceholder="ใส่คีย์ของคุณที่นี่...", paste="วาง",
	getKey="รับคีย์", verify="ยืนยันคีย์", games="เกมที่รองรับ", settings="ตั้งค่า",
	featTitle="มีอะไรในฮับ", guide="ไม่รู้จะรับคีย์ยังไง?",
	guideSteps={"1. กดปุ่ม รับคีย์ — ระบบจะคัดลอกลิงก์ให้อัตโนมัติ",
		"2. เปิดลิงก์ในเบราว์เซอร์ ทำตามขั้นตอนจนได้คีย์",
		"3. กลับมาเกม วางคีย์แล้วกด ยืนยันคีย์"},
	stIdle="รอการยืนยันคีย์...", stCheck="กำลังตรวจสอบคีย์...", stOk="คีย์ถูกต้อง — กำลังเปิดฮับ...",
	stBad="คีย์ไม่ถูกต้อง ลองอีกครั้ง", stExp="คีย์หมดอายุแล้ว กดรับคีย์ใหม่ได้เลย",
	stFilled="เติมคีย์ที่จำไว้แล้ว — กดยืนยันคีย์", stNeed="กรุณาใส่คีย์ก่อน",
	stNet="เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ — ลองอีกครั้งในอีกสักครู่", stLock="ลองผิดหลายครั้ง — รออีก %d วินาที", stBlocked="คีย์นี้ถูกระงับการใช้งาน",
	stHwid="คีย์นี้ผูกกับเครื่องอื่นอยู่", stWrongGame="คีย์นี้ใช้กับเกมนี้ไม่ได้",
	stTamper="คำตอบจากเซิร์ฟเวอร์ไม่ถูกต้อง (อาจถูกดัดแปลง) — ลองใหม่", stEnv="ตรวจพบเครื่องมือดักจับ — ปิดเครื่องมือนั้นก่อนแล้วลองใหม่",
	expiry="เหลืออีก %s", copyLink="คัดลอกลิงก์รับคีย์แล้ว — วางในเบราว์เซอร์ได้เลย",
	noLink="ยังไม่ได้ตั้งลิงก์รับคีย์ — ใช้คีย์ทดสอบ 123 ได้ก่อน",
	pgGames="เกมที่รองรับ", pgNews="ประกาศ", pgSupport="ซัพพอร์ต", pgSettings="ตั้งค่าฮับ",
	gsPlay="ใช้ได้", gsUpdate="กำลังอัปเดต", gsDead="ใช้ไม่ได้", gsHere="กำลังเล่น",
	gsSearch="ค้นหาเกม...", gsEmpty="ไม่เจอเกมที่ค้นหา",
	newsEmpty="ยังไม่มีประกาศใหม่", changelog="บันทึกการเปลี่ยนแปลง",
	supDiscord="คัดลอกลิงก์ Discord", supLine="คัดลอกลิงก์ LINE",
	supDiag="คัดลอกข้อมูลเครื่องส่งแอดมิน", supDiagDone="คัดลอกข้อมูลเครื่องแล้ว — ส่งให้แอดมินได้เลย",
	supNoLink="ยังไม่ได้ตั้งช่องทางนี้",
	setOpacity="ความทึบพื้นหลัง", setTheme="ธีมสี", setProf="โปรไฟล์ค่าตั้ง",
	profName="ตั้งชื่อโปรไฟล์...", profSave="บันทึก", profLoad="โหลด", profDel="ลบ",
	toastCopy="คัดลอกแล้ว", toastOk="สำเร็จ", toastErr="ทำไม่สำเร็จ",
	noCopy="เครื่องนี้คัดลอกอัตโนมัติไม่ได้",
}
	local FT={xs=12,sm=13,md=14,lg=16} -- ขนาดฟอนต์กลาง (design token)

	local TH = {
	ink   = Color3.fromRGB(248,246,253),
	sub   = Color3.fromRGB(204,197,232),
	mute  = Color3.fromRGB(170,160,205),
	dim   = Color3.fromRGB(178,160,205),
	lav   = Color3.fromRGB(226,210,255),
	glass = Color3.fromRGB(222,206,255),
	acc   = Color3.fromRGB(205,145,255),
	acc2  = Color3.fromRGB(157,91,255),
	hole  = Color3.fromRGB(3,1,8),
	warn  = Color3.fromRGB(255,198,112),
	bad   = Color3.fromRGB(255,112,132),
	g0    = Color3.fromRGB(38,22,66),
	g1    = Color3.fromRGB(15,9,27),
	g2    = Color3.fromRGB(7,3,15),
}
	local IMG = {
	shadow = "rbxassetid://99623734860368",
	edge   = "rbxassetid://108437916503362",
	glow   = "rbxassetid://86707188750389",
}
	local THEMES = {
	{name="Amethyst", sub=Color3.fromRGB(204,197,232), acc=Color3.fromRGB(205,145,255), acc2=Color3.fromRGB(157,91,255),
		lav=Color3.fromRGB(226,210,255), g0=Color3.fromRGB(38,22,66), g1=Color3.fromRGB(15,9,27), g2=Color3.fromRGB(7,3,15)},
	{name="Ocean", sub=Color3.fromRGB(196,219,244), acc=Color3.fromRGB(124,208,255), acc2=Color3.fromRGB(66,140,255),
		lav=Color3.fromRGB(205,230,255), g0=Color3.fromRGB(18,38,66), g1=Color3.fromRGB(9,18,32), g2=Color3.fromRGB(3,8,16)},
	{name="Rose", sub=Color3.fromRGB(240,197,216), acc=Color3.fromRGB(255,142,194), acc2=Color3.fromRGB(240,80,150),
		lav=Color3.fromRGB(255,215,232), g0=Color3.fromRGB(66,20,44), g1=Color3.fromRGB(30,9,20), g2=Color3.fromRGB(16,3,9)},
	{name="Mint", sub=Color3.fromRGB(197,243,229), acc=Color3.fromRGB(98,242,194), acc2=Color3.fromRGB(40,200,150),
		lav=Color3.fromRGB(210,255,238), g0=Color3.fromRGB(16,58,50), g1=Color3.fromRGB(8,28,24), g2=Color3.fromRGB(3,14,12)},
}
	return {STR=STR,FT=FT,TH=TH,IMG=IMG,THEMES=THEMES}
end
]])
	_m["icons"]=loadstring([[
-- ============================================================
-- FishUI/icons.lua — ไอคอนวาดจากเฟรม (ไม่ใช้อิโมจิ) ทั้ง 22 แบบ
-- ใส่ลง D : Icon (table ฟังก์ชันวาด Icon.<name>(parent,color))
-- อ่านจาก D: new (เรียกผ่าน D.new ตอน runtime — โหลดก่อน core ได้)
-- ============================================================
return function(D)
	local Icon = {}
	local function ib(par,w,h,x,y,col,rot,r,tr)
		return D.new("Frame",{BackgroundColor3=col,BackgroundTransparency=tr or 0,Size=UDim2.new(0,w,0,h),
			Position=UDim2.new(0.5,x or 0,0.5,y or 0),AnchorPoint=Vector2.new(0.5,0.5),Rotation=rot or 0,
			ZIndex=22,BorderSizePixel=0,Parent=par},{D.new("UICorner",{CornerRadius=UDim.new(0,r or 1)})})
	end
	local function iring(par,w,h,x,y,col,r,th)
		return D.new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,w,0,h),Position=UDim2.new(0.5,x or 0,0.5,y or 0),
			AnchorPoint=Vector2.new(0.5,0.5),ZIndex=22,BorderSizePixel=0,Parent=par},{
			D.new("UICorner",{CornerRadius=UDim.new(0,r or 3)}),D.new("UIStroke",{Color=col,Thickness=th or 1.5})})
	end
	function Icon.close(p,c) ib(p,13,2,0,0,c,45) ib(p,13,2,0,0,c,-45) end
	function Icon.minus(p,c) ib(p,11,2,0,0,c) end
	function Icon.key(p,c)
		iring(p,8,8,-4,0,c,4,1.6) ib(p,8,1.6,4,0,c) ib(p,1.6,4,5,2,c) ib(p,1.6,3,8,2,c)
	end
	function Icon.monitor(p,c) iring(p,14,10,0,-2,c,2,1.5) ib(p,6,1.5,0,6,c) ib(p,1.5,3,0,4,c) end
	function Icon.device(p,c) iring(p,9,14,0,0,c,2,1.5) ib(p,3,1.5,0,4,c) end
	function Icon.calendar(p,c) iring(p,14,12,0,1,c,2,1.5) ib(p,14,3,0,-4,c,0,1) ib(p,1.5,4,-3,-6,c) ib(p,1.5,4,3,-6,c) end
	function Icon.shield(p,c) iring(p,10,11,0,-1,c,4,1.6) ib(p,2,5,0,4,c,0,1.6) end
	function Icon.save(p,c) iring(p,12,11,0,0,c,2,1.6) ib(p,6,4,0,-3,c,0,1) ib(p,5,1.6,0,3,c) end
	function Icon.gamepad(p,c) iring(p,15,9,0,1,c,4,1.5) ib(p,5,1.6,-3.5,1,c) ib(p,1.6,5,-3.5,1,c) ib(p,2.2,2.2,3.2,0,c,0,1.1) ib(p,2.2,2.2,5.6,2,c,0,1.1) end
	function Icon.swords(p,c) ib(p,12,2,-3,0,c,-45) ib(p,12,2,3,0,c,45) ib(p,4,2,-6,-6,c,45) ib(p,4,2,6,-6,c,-45) end
	function Icon.check(p,c) ib(p,6,2,-3,2,c,45) ib(p,11,2,2,0,c,-50) end
	function Icon.gear(p,c) iring(p,9,9,0,0,c,5,1.6) for i=0,3 do ib(p,2.6,14.5,0,0,c,i*45) end end
	function Icon.crown(p,c) ib(p,14,2,0,5,c) ib(p,2,8,-6,1,c,-12) ib(p,2,9,0,0,c) ib(p,2,8,6,1,c,12) ib(p,3,3,-6,-4,c,0,2) ib(p,3,3,0,-5,c,0,2) ib(p,3,3,6,-4,c,0,2) end
	function Icon.search(p,c) iring(p,10,10,-2,-2,c,5,1.6) ib(p,6,1.8,5,5,c,45) end
	function Icon.copy(p,c) iring(p,11,11,-4,-4,c,2,1.5) iring(p,11,11,3,3,c,2,1.5) end
	function Icon.logout(p,c)
		ib(p,1.8,11,-4.5,0,c) ib(p,7,1.8,-1.5,-4.6,c) ib(p,7,1.8,-1.5,4.6,c)
		ib(p,7.5,1.8,3.2,0,c) ib(p,4.2,1.8,5.8,-2.6,c,-42) ib(p,4.2,1.8,5.8,2.6,c,42)
	end
	function Icon.user(p,c) iring(p,6,6,0,-3,c,3,1.5) iring(p,12,6,0,5,c,3,1.5) end
	return {Icon=Icon}
end
]])
	_m["core"]=loadstring([[
-- ============================================================
-- FishUI/core.lua — helper กลางทั้งหมด (สร้าง instance/tween/เสียง/แก้ว)
-- ใส่ลง D : new, c3, corner, stroke, tw, sfx, pad, hlist, vlist, label,
--            lipEdge, chevron, darkwell, accgrad, sheenTop, glowImg,
--            glassBody, shadowImg, draggable, SetFont, _sndHost,
--            F_TXT, F_MONO, F_B, sndHost, sndOn, sndRnd
-- อ่านจาก D: TH, IMG (ต้องโหลด tokens ก่อน)
-- ============================================================
return function(D)
	local TweenService = game:GetService("TweenService")
	local UIS = game:GetService("UserInputService")
	local TH,IMG = D.TH, D.IMG

	local function new(c, p, ch)
		local o = Instance.new(c)
		for k,v in pairs(p or {}) do o[k] = v end
		for _,x in ipairs(ch or {}) do x.Parent = o end
		return o
	end
	local function c3(c) return c end
	local function corner(r) return new("UICorner",{CornerRadius=UDim.new(0,r)}) end
	local function stroke(col,tr,th)
		return new("UIStroke",{Color=col or TH.lav,Transparency=tr or 0.8,Thickness=th or 1})
	end
	local function tw(o,t,p,sty,dir) return TweenService:Create(o,TweenInfo.new(t or 0.18,sty or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),p) end

	-- ===== เสียงเอฟเฟกต์ (rbxasset:// builtin สไตล์เกม — นุ่ม น่ารัก โหลดทันที) =====
	local CLICKS={click="rbxasset://sounds/button.wav",tick="rbxasset://sounds/electronicpingshort.wav",
		pop="rbxasset://sounds/snap.wav",quack="rbxasset://sounds/rubber duck.wav"}
	local SFX={open="rbxasset://sounds/swoosh.wav",ok="rbxasset://sounds/rubber duck.wav",
		bad="rbxasset://sounds/uuhhh.mp3",noti="rbxasset://sounds/victory.wav"}
	if D.sndOn==nil then D.sndOn=true end
	D.sndRnd = D.sndRnd or Random.new(os.clock()*1000)
	function D._sndHost(g) D.sndHost=g end
	local function sfx(name,vol,speed)
		if not D.sndOn then return end
		local id
		if name=="click" or name=="tick" then
			id=CLICKS[name] or CLICKS.click
			speed=(speed or (name=="tick" and 1.3 or 0.9))*D.sndRnd:NextNumber(0.95,1.08)
			-- เสียงเป็ดนุ่มๆ สุ่มนานๆ ครั้ง (~6% ของ click) — น่ารักแต่ไม่รำคาญ
			if name=="click" and D.sndRnd:NextNumber()<0.06 then id=CLICKS.quack speed=2.1 vol=(vol or 0.18)*0.4 end
		else id=SFX[name] end
		if not id then return end
		local s=new("Sound",{SoundId=id,Volume=(vol or 0.18)*(D.sndVol or 1),PlaybackSpeed=speed or 1,Parent=D.sndHost})
		task.delay(3,function() pcall(function() s:Destroy() end) end)
		pcall(function() s:Play() end)
	end

	-- ===== ฟอนต์ (เปลี่ยนได้ผ่าน SetFont — D.* คือค่าปัจจุบันเสมอ) =====
	D.F_TXT = D.F_TXT or Font.new("rbxasset://fonts/families/GothamSSm.json")
	D.F_MONO = D.F_MONO or Font.new("rbxasset://fonts/families/RobotoMono.json")
	D.F_B = D.F_B or Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold)
	function D.SetFont(regId,boldId)
		if regId then D.F_TXT=Font.new(regId) end
		if boldId then D.F_B=Font.new(boldId) elseif regId then D.F_B=Font.new(regId,Enum.FontWeight.Bold) end
	end

	local function pad(t,l,b,r) return new("UIPadding",{
		PaddingTop=UDim.new(0,t or 0),PaddingLeft=UDim.new(0,l or 0),
		PaddingBottom=UDim.new(0,b or 0),PaddingRight=UDim.new(0,r or 0)}) end
	local function hlist(p,ha) return new("UIListLayout",{Padding=UDim.new(0,p or 6),FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=ha or Enum.HorizontalAlignment.Left,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder}) end
	local function vlist(p) return new("UIListLayout",{Padding=UDim.new(0,p or 9),FillDirection=Enum.FillDirection.Vertical,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Top,SortOrder=Enum.SortOrder.LayoutOrder}) end
	local function label(txt,sz,col,parent,mono)
		return new("TextLabel",{BackgroundTransparency=1,Text=txt,TextColor3=col or TH.ink,
			TextSize=sz or 13,FontFace=mono and D.F_MONO or D.F_TXT,Parent=parent})
	end
	-- เส้นไฮไลต์บนขอบแก้ว (fade 2 ข้าง)
	local function lipEdge(w,h,y,ap)
		return new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.88,
			Size=UDim2.new(1,-(w or 18),0,h or 1),Position=UDim2.new(0.5,0,1,y or 0),AnchorPoint=ap or Vector2.new(0.5,1),ZIndex=2,BorderSizePixel=0},{
			new("UIGradient",{Transparency=NumberSequence.new{
				NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)}})})
	end
	-- เชฟรอน 2 แท่งเอน (ลูกศร)
	local function chevron(z)
		return new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,10,0,10),
			AnchorPoint=Vector2.new(0.5,0.5),ZIndex=z or 3},{
			new("Frame",{BackgroundColor3=TH.sub,BorderSizePixel=0,Size=UDim2.new(0,6,0,1),Position=UDim2.new(0.5,0,0.5,-2),AnchorPoint=Vector2.new(0.5,0.5),Rotation=45,ZIndex=z or 3}),
			new("Frame",{BackgroundColor3=TH.sub,BorderSizePixel=0,Size=UDim2.new(0,6,0,1),Position=UDim2.new(0.5,0,0.5,2),AnchorPoint=Vector2.new(0.5,0.5),Rotation=-45,ZIndex=z or 3})})
	end
	-- พื้นแก้วเข้ม (track/field): ดำ 50% + gradient + ขอบ lav
	local function darkwell(z,h,r)
		return new("Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.5,
			Size=UDim2.new(1,0,0,h),ZIndex=z or 2,BorderSizePixel=0},{
			corner(r or 9),
			new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
				NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.35)}}),
			stroke(TH.lav,0.82),
			lipEdge(18,1)})
	end
	-- gradient ม่วง acc2→acc
	local function accgrad(rot)
		return new("UIGradient",{Rotation=rot or 8,Color=ColorSequence.new{
			ColorSequenceKeypoint.new(0,TH.acc2),ColorSequenceKeypoint.new(1,TH.acc)}})
	end
	local function sheenTop(z)
		return new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.55,
			Size=UDim2.new(1,0,0.5,0),ZIndex=z or 5,BorderSizePixel=0},{
			corner(11),
			new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
				NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(1,1)}})})
	end
	local function glowImg(z,tr)
		return new("ImageLabel",{BackgroundTransparency=1,Image=IMG.glow,ImageColor3=TH.acc,
			ImageTransparency=tr or 0.5,ZIndex=z or 2,Size=UDim2.new(1,26,1,22),
			Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5)})
	end
	-- surface แก้วหลักของหน้าต่าง/การ์ด
	local function glassBody(z, cornerR)
		return new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.26,
			Size=UDim2.new(1,0,1,0),ZIndex=z or 1,ClipsDescendants=true,BorderSizePixel=0},{
			corner(cornerR or 14),
			new("UIGradient",{Rotation=115,Color=ColorSequence.new{
				ColorSequenceKeypoint.new(0,TH.g0),ColorSequenceKeypoint.new(0.5,TH.g1),
				ColorSequenceKeypoint.new(1,TH.g2)},
				Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.05),NumberSequenceKeypoint.new(1,0.2)}}),
			stroke(TH.lav,0.5),
			new("ImageLabel",{BackgroundTransparency=1,Image=IMG.edge,ImageColor3=TH.lav,
				ImageTransparency=0.66,Size=UDim2.new(1,0,1,0),ZIndex=(z or 1)+49,
				ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(50,50,78,78)},{
				new("UIGradient",{Rotation=104,Color=ColorSequence.new{
					ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
					ColorSequenceKeypoint.new(0.4,Color3.fromRGB(232,224,255)),
					ColorSequenceKeypoint.new(1,Color3.fromRGB(192,166,248))},
					Transparency=NumberSequence.new{
						NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.5,0.3),
						NumberSequenceKeypoint.new(1,0.08)}})}),
			new("Frame",{Name="Sheen",BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0,
				Size=UDim2.new(1,0,0.55,0),ZIndex=(z or 1)+1,BorderSizePixel=0},{
				corner(cornerR or 14),
				new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
					NumberSequenceKeypoint.new(0,0.9),NumberSequenceKeypoint.new(0.55,0.96),
					NumberSequenceKeypoint.new(1,1)}})})})
	end
	local function shadowImg(z,fade)
		return new("ImageLabel",{BackgroundTransparency=1,Image=IMG.shadow,
			ImageColor3=TH.hole,ImageTransparency=fade or 0.55,
			Size=UDim2.new(1,44,1,44),Position=UDim2.new(0.5,0,0.5,0),
			AnchorPoint=Vector2.new(0.5,0.5),ZIndex=z or 0,
			ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(50,50,78,78)})
	end
	-- drag helper
	local function draggable(handle,frame)
		if handle:IsA("GuiObject") and not handle:IsA("GuiButton") then handle.Active=true end
		local drag,sPos,fPos
		handle.InputBegan:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
				drag=true sPos=i.Position fPos=frame.Position
			end
		end)
		handle.InputEnded:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
		end)
		UIS.InputChanged:Connect(function(i)
			if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
				local d=i.Position-sPos
				local vp=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
				local sz=frame.AbsoluteSize local an=frame.AnchorPoint
				local nx=math.clamp(fPos.X.Offset+d.X,an.X*sz.X-sz.X+80-vp.X*fPos.X.Scale,vp.X-80-vp.X*fPos.X.Scale+an.X*sz.X)
				local ny=math.clamp(fPos.Y.Offset+d.Y,an.Y*sz.Y-sz.Y+40-vp.Y*fPos.Y.Scale,vp.Y-40-vp.Y*fPos.Y.Scale+an.Y*sz.Y)
				frame.Position=UDim2.new(fPos.X.Scale,nx,fPos.Y.Scale,ny)
			end
		end)
	end

	return {new=new,c3=c3,corner=corner,stroke=stroke,tw=tw,sfx=sfx,pad=pad,hlist=hlist,vlist=vlist,
		label=label,lipEdge=lipEdge,chevron=chevron,darkwell=darkwell,accgrad=accgrad,sheenTop=sheenTop,
		glowImg=glowImg,glassBody=glassBody,shadowImg=shadowImg,draggable=draggable,
		SetFont=D.SetFont,_sndHost=D._sndHost}
end
]])
	_m["fx"]=loadstring([[
-- ============================================================
-- FishUI/fx.lua — เอฟเฟกต์ + widget primitives ของหน้าต่าง
-- ใส่ลง D : blurOn, blurOff, windowFX, capsule, keycap, pillBtn, kname
-- อ่านจาก D: TH, IMG, new, corner, stroke, tw, sfx, pad, lipEdge,
--            accgrad, sheenTop, glowImg, LP, FishUI
-- ============================================================
return function(D)
	local FishUI=D.FishUI
	local TH,IMG=D.TH,D.IMG
	local RunS=game:GetService("RunService")
	local LP=game:GetService("Players").LocalPlayer
	local new,corner,stroke,tw,sfx,pad=D.new,D.corner,D.stroke,D.tw,D.sfx,D.pad
	local lipEdge,accgrad,sheenTop,glowImg=D.lipEdge,D.accgrad,D.sheenTop,D.glowImg
	local draggable=D.draggable

-- เบลอพื้นหลังเกมตอนเมนูเปิด (นับจำนวนหน้าต่างที่เปิดอยู่)
local blurCount,blurObj=0,nil
local function blurOn()
	blurCount=blurCount+1
	if not blurObj or not blurObj.Parent then
		blurObj=Instance.new("BlurEffect") blurObj.Name="FishBlur" blurObj.Size=0
		blurObj.Parent=game:GetService("Lighting")
	end
	tw(blurObj,0.45,{Size=18}):Play()
end
local function blurOff()
	blurCount=math.max(0,blurCount-1)
	if blurCount==0 and blurObj then
		local b=blurObj tw(b,0.3,{Size=0}):Play()
		task.delay(0.35,function() if blurCount==0 and b then b:Destroy() end end)
	end
end

-- เอฟเฟกต์รอบหน้าต่าง: ออร่าเรืองหายใจ + ขอบวิ่งไฮไลต์ + แสงกวาดผ่านกระจก
local function windowFX(win,main)
	local function glowRect(name,pad,tr,col,z)
		return new("ImageLabel",{Name=name,BackgroundTransparency=1,Image=IMG.glow,ImageColor3=col,ImageTransparency=tr,
			Size=UDim2.new(1,pad,1,pad),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=z or 0,Parent=win})
	end
	local aura=glowRect("Aura",320,0.55,TH.acc)
	local aura2=glowRect("Aura2",140,0.7,TH.acc2)
	local halo=new("ImageLabel",{Name="Halo",BackgroundTransparency=1,Image=IMG.shadow,ImageColor3=TH.acc2,ImageTransparency=0.45,
		Size=UDim2.new(1,30,1,30),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=0,
		ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(50,50,78,78),Parent=win})
	-- กรอบนอกเรืองวิ่ง (อยู่นอกขอบหน้าต่าง)
	local ring=new("Frame",{Name="OuterRing",BackgroundTransparency=1,Size=UDim2.new(1,14,1,14),Position=UDim2.new(0.5,0,0.5,0),
		AnchorPoint=Vector2.new(0.5,0.5),ZIndex=0,Parent=win},{corner(24)})
	local rst=new("UIStroke",{Color=Color3.new(1,1,1),Thickness=2,Transparency=0.15,Parent=ring})
	local rg=new("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,TH.acc),ColorSequenceKeypoint.new(0.5,Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(1,TH.acc)},Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.9),
		NumberSequenceKeypoint.new(0.2,0.1),NumberSequenceKeypoint.new(0.4,0.9),NumberSequenceKeypoint.new(0.7,0.9),
		NumberSequenceKeypoint.new(0.85,0.1),NumberSequenceKeypoint.new(1,0.9)},Parent=rst})
	local ring2=new("Frame",{Name="OuterRing2",BackgroundTransparency=1,Size=UDim2.new(1,32,1,32),Position=UDim2.new(0.5,0,0.5,0),
		AnchorPoint=Vector2.new(0.5,0.5),ZIndex=0,Parent=win},{corner(34)})
	local rst2=new("UIStroke",{Color=TH.lav,Thickness=1,Transparency=0.6,Parent=ring2})
	local rg2=new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0.1),
		NumberSequenceKeypoint.new(1,1)},Parent=rst2})
	-- จับขอบแสงนอกกรอบลากได้ด้วย (ZIndex=0 อยู่หลังสุด ไม่บังปุ่มข้างใน)
	pcall(function() draggable(ring2,win) end)
	-- ขอบในวิ่งไฮไลต์
	local st=main:FindFirstChildOfClass("UIStroke")
	local g
	if st then
		st.Transparency=0.25
		g=new("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(0.5,TH.lav),
			ColorSequenceKeypoint.new(1,Color3.new(1,1,1))},Transparency=NumberSequence.new{
			NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.25,0.75),NumberSequenceKeypoint.new(0.5,0),
			NumberSequenceKeypoint.new(0.75,0.75),NumberSequenceKeypoint.new(1,0)},Parent=st})
	end
	local sweep=new("Frame",{Name="Sweep",BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.9,Size=UDim2.new(0.3,0,1.6,0),
		Position=UDim2.new(-0.5,0,-0.3,0),Rotation=18,ZIndex=3,BorderSizePixel=0,Parent=main},{
		new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)}})})

	-- ดาวหางวิ่งรอบกรอบ
	local orbit=new("Frame",{Name="Orbit",BackgroundTransparency=1,Size=UDim2.new(1,14,1,14),Position=UDim2.new(0.5,0,0.5,0),
		AnchorPoint=Vector2.new(0.5,0.5),ZIndex=0,Parent=win})
	pcall(function() draggable(orbit,win) end)
	local comet={}
	for i=0,5 do
		local sz=i==0 and 7 or math.max(2,6-i)
		local d=new("Frame",{BackgroundColor3=i==0 and Color3.new(1,1,1) or TH.acc,BackgroundTransparency=i==0 and 0 or 0.25+i*0.12,
			Size=UDim2.new(0,sz,0,sz),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=0,BorderSizePixel=0,Parent=orbit},{corner(4)})
		if i==0 then new("ImageLabel",{BackgroundTransparency=1,Image=IMG.glow,ImageColor3=TH.acc,ImageTransparency=0.15,
			Size=UDim2.new(0,46,0,46),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=0,Parent=d}) end
		comet[i]=d
	end
	-- ชุดสอง: เหมือนกันทุกอย่าง แต่วิ่งทวนเข็ม และอยู่ฝั่งตรงข้ามเสมอ (ห่างครึ่งวง ไม่ชนกัน)
	local comet2={}
	for i=0,5 do
		local sz=i==0 and 7 or math.max(2,6-i)
		local d=new("Frame",{BackgroundColor3=i==0 and Color3.new(1,1,1) or TH.acc,BackgroundTransparency=i==0 and 0 or 0.25+i*0.12,
			Size=UDim2.new(0,sz,0,sz),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=0,BorderSizePixel=0,Parent=orbit},{corner(4)})
		if i==0 then new("ImageLabel",{BackgroundTransparency=1,Image=IMG.glow,ImageColor3=TH.acc,ImageTransparency=0.15,
			Size=UDim2.new(0,46,0,46),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=0,Parent=d}) end
		comet2[i]=d
	end
	local function perim(t,w,h)
		local per=2*(w+h) local d=(t%1)*per
		if d<w then return d,0,0,-1 end d=d-w
		if d<h then return w,d,1,0 end d=d-h
		if d<w then return w-d,h,0,1 end d=d-w
		return 0,h-d,-1,0
	end
	local t0=os.clock()
	task.spawn(function()
		while win.Parent do
			local sc=1 local ab=orbit.AbsoluteSize
			local ui=win:FindFirstChildOfClass("UIScale") if ui then sc=ui.Scale end
			local w,h=ab.X/sc,ab.Y/sc
			local base=((os.clock()-t0)/11)
			for i=0,5 do
				local x,y=perim(base-i*0.006,w,h) comet[i].Position=UDim2.new(0,x,0,y)
			end
			for i=0,5 do
				local x,y=perim(base+0.5-i*0.006,w,h) comet2[i].Position=UDim2.new(0,x,0,y)
			end
			if g then g.Rotation=(os.clock()*45)%360 end
			rg.Rotation=(os.clock()*-60)%360 rg2.Rotation=(os.clock()*30)%360
			RunS.RenderStepped:Wait()
		end
	end)
	-- ประกายลอยออกนอกกรอบ
	local rnd=Random.new(os.clock()*1000)
	task.spawn(function()
		while win.Parent do
			task.wait(0.16)
			if win.Visible then
				local sc=1 local ui=win:FindFirstChildOfClass("UIScale") if ui then sc=ui.Scale end
				local ab=orbit.AbsoluteSize local w,h=ab.X/sc,ab.Y/sc
				local x,y,nx,ny=perim(rnd:NextNumber(),w,h)
				local s=rnd:NextInteger(2,4)
				local dot=new("Frame",{BackgroundColor3=rnd:NextNumber()<0.5 and Color3.new(1,1,1) or TH.acc,BackgroundTransparency=0.1,
					Size=UDim2.new(0,s,0,s),Position=UDim2.new(0,x,0,y),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=0,BorderSizePixel=0,Parent=orbit},{corner(2)})
				local dist=rnd:NextNumber(18,46) local life=rnd:NextNumber(1.2,2.4)
				tw(dot,life,{Position=UDim2.new(0,x+nx*dist+rnd:NextNumber(-8,8),0,y+ny*dist-rnd:NextNumber(0,16)),BackgroundTransparency=1},Enum.EasingStyle.Sine):Play()
				task.delay(life+0.05,function() dot:Destroy() end)
			end
		end
	end)
	-- ออร่าหายใจ
	task.spawn(function()
		while win.Parent do
			tw(aura,2.4,{ImageTransparency=0.72},Enum.EasingStyle.Sine):Play() tw(aura2,2.4,{ImageTransparency=0.82},Enum.EasingStyle.Sine):Play()
			tw(halo,2.4,{ImageTransparency=0.7},Enum.EasingStyle.Sine):Play() task.wait(2.4)
			tw(aura,2.4,{ImageTransparency=0.5},Enum.EasingStyle.Sine):Play() tw(aura2,2.4,{ImageTransparency=0.6},Enum.EasingStyle.Sine):Play()
			tw(halo,2.4,{ImageTransparency=0.4},Enum.EasingStyle.Sine):Play() task.wait(2.4)
		end
	end)
	task.spawn(function()
		while win.Parent do
			task.wait(5.5)
			sweep.Position=UDim2.new(-0.5,0,-0.3,0)
			tw(sweep,1.6,{Position=UDim2.new(1.3,0,-0.3,0)},Enum.EasingStyle.Sine):Play() task.wait(1.6)
		end
	end)
end

-- ============ capsule switch ============
local function capsule()
	local track = new("Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.5,
		Size=UDim2.new(1,0,1,0),ZIndex=3,BorderSizePixel=0},{
		corner(11),
		new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
			NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.35)}}),
		stroke(TH.lav,0.82),
		lipEdge(22,1)})
	local fill = new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,
		Size=UDim2.new(1,0,1,0),ZIndex=4,ClipsDescendants=true,BorderSizePixel=0},{
		corner(11), accgrad(8),
		new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0,
			Size=UDim2.new(1,0,0.5,0),ZIndex=5,BorderSizePixel=0},{corner(11),
			new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
				NumberSequenceKeypoint.new(0,0.55),NumberSequenceKeypoint.new(1,1)}})})})
	local knob = new("Frame",{BackgroundColor3=Color3.new(1,1,1),
		Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,11,0.5,0),
		AnchorPoint=Vector2.new(0.5,0.5),ZIndex=6,BorderSizePixel=0},{
		corner(8),
		new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
			NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.12)}}),
		stroke(TH.hole,0.55)})
	local cap = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,40,0,22),ZIndex=3},{
		glowImg(2,1), track, fill, knob})
	return cap, fill, knob, cap:FindFirstChildOfClass("ImageLabel")
end
-- ============ keycap ============
local function keycap(txt,w)
	local face = new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.84,
		Size=UDim2.new(1,0,1,-3),ZIndex=5,BorderSizePixel=0},{
		corner(6),
		new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
			NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.5)}}),
		stroke(TH.lav,0.55),
		new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=6,
			Text=txt or "",TextColor3=TH.ink,TextSize=11,FontFace=D.F_TXT})})
	local b = new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(0,w or 40,0,22),ZIndex=4},{
		new("Frame",{BackgroundColor3=TH.hole,BackgroundTransparency=0.45,
			Size=UDim2.new(1,0,1,0),ZIndex=4,BorderSizePixel=0},{corner(6)}),
		face})
	return b, face:FindFirstChildOfClass("TextLabel")
end
-- ============ pill button (depth+face) ============
local function pillBtn(txt,w,h)
	local face = new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.84,
		Size=UDim2.new(1,0,1,-3),ZIndex=5,BorderSizePixel=0},{
		corner(8),
		new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
			NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.5)}}),
		stroke(TH.lav,0.55),
		new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=6,
			Text=txt,TextColor3=TH.ink,TextSize=12,FontFace=D.F_TXT})})
	local b = new("TextButton",{BackgroundTransparency=1,Text="",
		Size=UDim2.new(0,w or 0,0,h or 26),ZIndex=4,AutomaticSize=w and Enum.AutomaticSize.None or Enum.AutomaticSize.X},{
		new("Frame",{BackgroundColor3=TH.hole,BackgroundTransparency=0.45,
			Size=UDim2.new(1,0,1,0),ZIndex=4,BorderSizePixel=0},{corner(8)}),
		face, pad(0,14,3,14)})
	b.MouseButton1Down:Connect(function() tw(face,0.07,{Position=UDim2.new(0,0,0,2)}):Play() end)
	b.MouseButton1Up:Connect(function() tw(face,0.12,{Position=UDim2.new(0,0,0,0)}):Play() end)
	return b
end

local kname = setmetatable({}, {__index=function(_,k)
	local s = tostring(k):match("KeyCode%.(.+)") or tostring(k)
	return ({LeftControl="LCtrl",RightControl="RCtrl",LeftShift="LShift",RightShift="RShift",
		LeftAlt="LAlt",RightAlt="RAlt",Space="Space",Return="Enter",Backspace="Bksp",
		CapsLock="Caps",Escape="Esc",Tab="Tab",Insert="Ins",Delete="Del",
		Home="Home",End="End",PageUp="PgUp",PageDown="PgDn"})[s] or s
end})

	D.blurOn,D.blurOff=blurOn,blurOff
	D.windowFX=windowFX
	D.capsule,D.keycap,D.pillBtn=capsule,keycap,pillBtn
	D.kname=kname
	return {}
end
]])
	_m["nav"]=loadstring([[
-- ============================================================
-- FishUI/nav.lua — หน้า/แท็บ/ซับเมนู/ค้นหาในหน้า ของหน้าต่างหลัก
-- ใส่ลง D : D.Nav.attach(W,C) — ติดตั้ง W:Page/showPage/_syncInd/showSub/_search
-- อ่านจาก D: TH, new, corner, stroke, tw, sfx, vlist, label, chevron,
--            darkwell, glowImg, shadowImg, Icon
-- C ที่ต้องส่ง: win, content, indicator, tabsHost
-- ============================================================
return function(D)
	local TH=D.TH
	local new,corner,stroke,tw,sfx,vlist,label,pad=D.new,D.corner,D.stroke,D.tw,D.sfx,D.vlist,D.label,D.pad
	local chevron,darkwell,glowImg,shadowImg=D.chevron,D.darkwell,D.glowImg,D.shadowImg
	local Icon=D.Icon
	local Nav={}
	function Nav.attach(W,C)
		local win,content,indicator,tabsHost=C.win,C.content,C.indicator,C.tabsHost
		-- ============ pages / tabs ============
		function W:Page(name,iconName)
			local P = {name=name, subs={}, subPages={}, firstSub=nil, W=W}
			table.insert(W.pages,P)

			local btn = new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,0,38),ZIndex=10})
			local lift = new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=1,
				Size=UDim2.new(1,0,1,0),ZIndex=9,BorderSizePixel=0},{corner(10),stroke(TH.lav,1)})
			local hov = new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=1,
				Size=UDim2.new(1,0,1,0),ZIndex=9,BorderSizePixel=0},{corner(10)})
			local ic
			if iconName and Icon and Icon[iconName] then
				ic = new("Frame",{BackgroundTransparency=1,
					Size=UDim2.new(0,17,0,17),Position=UDim2.new(0,20,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),
					ZIndex=11,Parent=btn})
				Icon[iconName](ic,TH.sub)
			else
				ic = new("Frame",{BackgroundColor3=TH.dim,BackgroundTransparency=1,
					Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,20,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),
					ZIndex=11,BorderSizePixel=0,Parent=btn},{corner(3),stroke(TH.dim,0.2,1.2)})
			end
			local lb = label(name,14,TH.mute,btn)
			lb.Position=UDim2.new(0,40,0,0) lb.Size=UDim2.new(1,-68,1,0) lb.ZIndex=11
			lb.TextXAlignment=Enum.TextXAlignment.Left
			local ch = chevron(11) ch.Position=UDim2.new(1,-16,0.5,0) ch.Parent=btn ch.Rotation=90
			lift.Parent=btn hov.Parent=btn
			btn.MouseEnter:Connect(function() tw(hov,0.15,{BackgroundTransparency=0.9}):Play() end)
			btn.MouseLeave:Connect(function() tw(hov,0.15,{BackgroundTransparency=1}):Play() end)

			local drawer = new("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,38),
				Size=UDim2.new(1,0,0,0),ClipsDescendants=true,ZIndex=10},{
				new("Frame",{BackgroundColor3=TH.lav,BackgroundTransparency=0.8,
					Size=UDim2.new(0,1,0,0),Position=UDim2.new(0,20,0,0),AnchorPoint=Vector2.new(0.5,0),
					ZIndex=10,BorderSizePixel=0}),
				vlist(2)})
			local bead = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,4,0,14),
				Position=UDim2.new(0,18,0,4),ZIndex=11,Visible=false,Parent=drawer},{
				glowImg(11,0.5),
				new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(1,0,1,0),
					Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=12,BorderSizePixel=0},{corner(2)})})
			P.bead=bead

			local tab = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38),
				ZIndex=10,Parent=tabsHost},{new("UIScale"),shadowImg(8,1)})
			btn.Parent=tab drawer.Parent=tab
			P.tab=tab P.btn=btn P.drawer=drawer P.lift=lift P.label=lb P.chev=ch P.icon=ic
			P.open=false

			local function refreshH() task.defer(function()
				local n=#drawer:GetChildren()-2
				local want = P.open and (38+n*30) or 38
				tw(tab,0.22,{Size=UDim2.new(1,0,0,want)}):Play()
				task.delay(0.26,function() if W._syncInd then W:_syncInd(false) end end)
				tw(drawer:FindFirstChildOfClass("Frame"),0.22,{Size=UDim2.new(0,1,0,math.max(0,n*30-10))}):Play()
			end) end
			P.refreshH=refreshH

			btn.MouseButton1Click:Connect(function()
				sfx("tick",0.2,1.4)
				if #P.subs>0 then
					P.open=not P.open refreshH()
					tw(ch,0.2,{Rotation=P.open and 0 or 90}):Play()
					if P.open and P.firstSub then W:showSub(P,P.firstSub) end
				else W:showPage(P) end
			end)

			function P:Sub(sname)
				local S={name=sname,P=P,groupboxes={}}
				table.insert(P.subs,S) P.firstSub=P.firstSub or S
				local sb = new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,0,28),ZIndex=11,Parent=drawer})
				local sl = label(sname,13,TH.sub,sb)
				sl.Position=UDim2.new(0,34,0,0) sl.Size=UDim2.new(1,-42,1,0) sl.ZIndex=12
				new("Frame",{BackgroundColor3=TH.dim,Size=UDim2.new(0,4,0,4),Position=UDim2.new(0,16,0.5,0),
					AnchorPoint=Vector2.new(0.5,0.5),ZIndex=12,BorderSizePixel=0,Parent=sb},{corner(2)})
				sl.TextXAlignment=Enum.TextXAlignment.Left
				S.label=sl
				-- page
				local pg = new("CanvasGroup",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=5,Visible=false,GroupTransparency=0.4})
				local hd = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,60),ZIndex=5,Parent=pg})
				label(sname,20,TH.ink,hd).Position=UDim2.new(0,18,0,0) 
				local t=hd:GetChildren()[1] t.Size=UDim2.new(1,-206,0,60) t.TextXAlignment=Enum.TextXAlignment.Left t.ZIndex=6
				local scr = new("ScrollingFrame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,60),
					Size=UDim2.new(1,0,1,-60),CanvasSize=UDim2.new(0,0,0,0),
					AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,
					ScrollBarImageColor3=TH.acc,ZIndex=5,Parent=pg},{pad(0,4,12,14),vlist(12)})
				W:_search(S,scr)
				local cols = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
					AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2,Parent=scr})
				local L = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-6,0,0),
					AutomaticSize=Enum.AutomaticSize.Y,Parent=cols},{vlist(12)})
				local R = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-6,0,0),
					Position=UDim2.new(0.5,6,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=cols},{vlist(12)})
				S.page=pg S.scroller=scr S.left=L S.right=R S.cols=cols
				pg.Parent=content
				sb.MouseButton1Click:Connect(function() sfx("tick",0.2,1.4) W:showSub(P,S) end)
				function S:Groupbox(gname,side) return W:_groupbox(S,gname,side) end
				function S:Warn(a) return W:_warnbox(S,a) end
				P.refreshH()
				return S
			end
			function P:Groupbox(gname,side) -- tab ไม่มี sub = groupbox ตรงหน้าตัวเอง
				if not self.direct then
					self.direct={name=name,P=P,groupboxes={}}
					local pg = new("CanvasGroup",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=5,Visible=false,GroupTransparency=0.4})
					local hd = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,60),ZIndex=5,Parent=pg})
					label(name,20,TH.ink,hd).Position=UDim2.new(0,18,0,0)
					local t=hd:GetChildren()[1] t.Size=UDim2.new(1,-206,0,60) t.TextXAlignment=Enum.TextXAlignment.Left t.ZIndex=6
					local scr = new("ScrollingFrame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,60),
						Size=UDim2.new(1,0,1,-60),CanvasSize=UDim2.new(0,0,0,0),
						AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,
						ScrollBarImageColor3=TH.acc,ZIndex=5,Parent=pg},{pad(0,4,12,14),vlist(12)})
					W:_search(self.direct,scr)
					local cols = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
						AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2,Parent=scr})
					self.direct.left = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-6,0,0),
						AutomaticSize=Enum.AutomaticSize.Y,Parent=cols},{vlist(12)})
					self.direct.right = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-6,0,0),
						Position=UDim2.new(0.5,6,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=cols},{vlist(12)})
					self.direct.page=pg self.direct.scroller=scr
					pg.Parent=content
					local SD=self.direct
					function SD:Groupbox(gn,sd) return W:_groupbox(SD,gn,sd) end
					function SD:Warn(a) return W:_warnbox(SD,a) end
				end
				return self.direct:Groupbox(gname,side)
			end
			return P
		end

		function W:showPage(P)
			for _,x in ipairs(content:GetChildren()) do if x:IsA("GuiObject") then x.Visible=false end end
			for _,q in ipairs(W.pages) do
				tw(q.label,0.15,{TextColor3=TH.mute}):Play()
				tw(q.lift,0.15,{BackgroundTransparency=1}):Play()
				q.lift:FindFirstChildOfClass("UIStroke").Transparency=1
			end
			tw(P.label,0.15,{TextColor3=TH.ink}):Play()
			if P.direct then P.direct.page.Visible=true P.direct.page.GroupTransparency=0.45 tw(P.direct.page,0.3,{GroupTransparency=0}):Play() end
			if P.firstSub then W:showSub(P,P.firstSub) end
			W.curPage=P W:_syncInd(true)
		end
		function W:_syncInd(anim)
			local P=W.curPage if not P then return end
			local y=(P.tab.AbsolutePosition.Y-tabsHost.AbsolutePosition.Y)/math.max(win.UIScale.Scale,0.01)
			local first=not indicator.Visible
			indicator.Visible=true
			if first or not anim then indicator.Position=UDim2.new(0,0,0,y) else tw(indicator,0.25,{Position=UDim2.new(0,0,0,y)},Enum.EasingStyle.Back):Play() end
		end
		function W:showSub(P,S)
			for _,x in ipairs(content:GetChildren()) do if x:IsA("GuiObject") then x.Visible=false end end
			for _,q in ipairs(W.pages) do
				tw(q.label,0.15,{TextColor3=TH.mute}):Play()
				tw(q.lift,0.15,{BackgroundTransparency=1}):Play()
				q.lift:FindFirstChildOfClass("UIStroke").Transparency=1
				for _,s2 in ipairs(q.subs) do s2.label.TextColor3=TH.sub end
			end
			tw(P.label,0.15,{TextColor3=TH.ink}):Play()
			S.label.TextColor3=TH.ink
			W.curPage=P W:_syncInd(true)
			S.page.Visible=true S.page.GroupTransparency=0.45 tw(S.page,0.3,{GroupTransparency=0}):Play()
			task.defer(function()
				local i=0
				for _,side in ipairs{S.left,S.right} do
					for _,c in ipairs(side:GetChildren()) do
						if c:IsA("Frame") then i=i+1
							local sc=c:FindFirstChildOfClass("UIScale") or new("UIScale",{Parent=c})
							sc.Scale=0.92 local d=i
							task.delay(0.03*d,function() if c.Parent then tw(sc,0.3,{Scale=1},Enum.EasingStyle.Quint):Play() end end)
						end
					end
				end
			end)
			P.bead.Visible=true
			local idx=0 for i,s2 in ipairs(P.subs) do if s2==S then idx=i end end
			tw(P.bead,0.2,{Position=UDim2.new(0,18,0,4+(idx-1)*30)}):Play()
		end

		-- ============ ช่องค้นหาในหน้า ============
		function W:_search(S,scr)
			S.rows={} S.gbs={}
			local holder=new("Frame",{Name="Search",BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),LayoutOrder=0,ZIndex=5,Parent=scr})
			local field=darkwell(5,34,10) field.Parent=holder
			local ic=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,8,0.5,0),AnchorPoint=Vector2.new(0,0.5),ZIndex=6,Parent=field})
			Icon.search(ic,TH.dim)
			local tb=new("TextBox",{BackgroundTransparency=1,Text="",PlaceholderText="ค้นหาฟีเจอร์ในหน้านี้...",PlaceholderColor3=TH.mute,
				TextColor3=TH.ink,TextSize=13,FontFace=D.F_TXT,Size=UDim2.new(1,-84,1,0),Position=UDim2.new(0,40,0,0),
				TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,ClearTextOnFocus=false,Parent=field})
			local cnt=label("",11,TH.mute,field) cnt.Size=UDim2.new(0,60,1,0) cnt.Position=UDim2.new(1,-66,0,0) cnt.TextXAlignment=Enum.TextXAlignment.Right cnt.ZIndex=6
			local fl=new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(0,0,0,2),Position=UDim2.new(0.5,0,1,0),AnchorPoint=Vector2.new(0.5,1),ZIndex=7,BorderSizePixel=0,Parent=field},
				{new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.2,0),NumberSequenceKeypoint.new(0.8,0),NumberSequenceKeypoint.new(1,1)}})})
			tb.Focused:Connect(function() tw(fl,0.25,{Size=UDim2.new(1,0,0,2)}):Play() end)
			tb.FocusLost:Connect(function() tw(fl,0.2,{Size=UDim2.new(0,0,0,2)}):Play() end)
			local function apply()
				local q=tb.Text:lower() local n=0
				for _,r in ipairs(S.rows) do
					local show=q=="" or r.text:lower():find(q,1,true)~=nil
					r.frame.Visible=show r.shown=show if show and q~="" then n=n+1 end
				end
				for _,g in ipairs(S.gbs) do
					local any=#g.rows==0 for _,r in ipairs(g.rows) do if r.shown~=false then any=true break end end
					g.frame.Visible=any
				end
				cnt.Text=q=="" and "" or (n.." รายการ")
			end
			tb:GetPropertyChangedSignal("Text"):Connect(apply)
		end
	end
	D.Nav=Nav
	return {}
end
]])
	_m["widgets"]=loadstring([[
-- ============================================================
-- FishUI/widgets.lua — groupbox + คอนโทรลทั้งหมดของหน้าต่างหลัก
-- ใส่ลง D : D.Widgets.attach(W) — ติดตั้ง W:_groupbox
-- อ่านจาก D: TH, IMG, new, c3, corner, stroke, tw, sfx, pad, hlist,
--            vlist, label, lipEdge, chevron, darkwell, accgrad, sheenTop,
--            glowImg, capsule, keycap, kname, Icon, LP, UIS
-- ============================================================
return function(D)
	local TH,IMG=D.TH,D.IMG
	local UIS=game:GetService("UserInputService")
	local LP=game:GetService("Players").LocalPlayer
	local new,c3,corner,stroke,tw,sfx=D.new,D.c3,D.corner,D.stroke,D.tw,D.sfx
	local pad,hlist,vlist,label=D.pad,D.hlist,D.vlist,D.label
	local lipEdge,chevron,darkwell,accgrad=D.lipEdge,D.chevron,D.darkwell,D.accgrad
	local sheenTop,glowImg=D.sheenTop,D.glowImg
	local capsule,keycap,kname=D.capsule,D.keycap,D.kname
	local Icon=D.Icon
	local Widgets={}
	function Widgets.attach(W)
		-- ============ groupbox ============
		function W:_groupbox(S,gname,side)
			local par = (side=="Right") and S.right or S.left
			local gb = new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.9,
				Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
				ZIndex=1,BorderSizePixel=0,Parent=par},{
				corner(12),
				new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
					NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.45)}}),
				stroke(TH.lav,0.85),
				new("ImageLabel",{BackgroundTransparency=1,Image=IMG.edge,ImageColor3=TH.lav,
					ImageTransparency=0.86,Size=UDim2.new(1,0,1,0),ZIndex=2,
					ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(50,50,78,78)},{
					new("UIGradient",{Rotation=104,Color=ColorSequence.new{
						ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
						ColorSequenceKeypoint.new(0.4,Color3.fromRGB(232,224,255)),
						ColorSequenceKeypoint.new(1,Color3.fromRGB(192,166,248))},
						Transparency=NumberSequence.new{
							NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.5,0.3),
							NumberSequenceKeypoint.new(1,0.08)}})})})
			gb:FindFirstChildOfClass("UIStroke"):FindFirstChildWhichIsA("UIGradient")
			new("UIGradient",{Rotation=100,Transparency=NumberSequence.new{
				NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(0.5,0.8),
				NumberSequenceKeypoint.new(1,0.45)},Parent=gb:FindFirstChildOfClass("UIStroke")})

			local body = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
				AutomaticSize=Enum.AutomaticSize.Y,ZIndex=1,Parent=gb},{pad(10,12,12,12),vlist(9)})
			-- header
			local hd = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),LayoutOrder=1,Parent=body})
			new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(0,4,0,12),Position=UDim2.new(0,2,0.5,0),
				AnchorPoint=Vector2.new(0,0.5),ZIndex=3,BorderSizePixel=0,Parent=hd},{corner(2)})
			local gl = label(gname,13,TH.ink,hd) gl.Position=UDim2.new(0,14,0,0)
			gl.Size=UDim2.new(1,-14,1,0) gl.TextXAlignment=Enum.TextXAlignment.Left gl.ZIndex=3
			-- light leak
			new("Frame",{BackgroundColor3=TH.acc,BackgroundTransparency=0.35,Size=UDim2.new(1,0,0,1),
				LayoutOrder=2,ZIndex=1,BorderSizePixel=0,Parent=body},{
				new("UIGradient",{Transparency=NumberSequence.new{
					NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.45,0.75),
					NumberSequenceKeypoint.new(1,1)}})})
			local cnt = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
				AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=3,ZIndex=1,Parent=body},{vlist(10)})

			local GB={frame=gb,content=cnt,W=W,S=S,_rows={}}
			S.rows=S.rows or {} S.gbs=S.gbs or {}
			table.insert(S.gbs,{frame=gb,rows=GB._rows})
			local function reg(f,t) local e={frame=f,text=tostring(t or "")} table.insert(S.rows,e) table.insert(GB._rows,e) end

			-- ---------- row scaffold ----------
			local function rowBase(lbl,h,tip)
				local r = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 30),
					ZIndex=1,Parent=cnt})
				local hov = new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=1,
					Size=UDim2.new(1,8,1,6),Position=UDim2.new(0.5,0,0.5,0),
					AnchorPoint=Vector2.new(0.5,0.5),ZIndex=1,BorderSizePixel=0,Parent=r},{corner(12)})
				local L = label(lbl,13,TH.ink,r) L.Size=UDim2.new(1,-96,h==44 and 18 or 1,0)
				L.Position=UDim2.new(0,0,0,0) L.TextXAlignment=Enum.TextXAlignment.Left
				L.ZIndex=2 L.RichText=true
				local acc = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,0,1,0),
					Position=UDim2.new(1,0,0.5,0),AnchorPoint=Vector2.new(1,0.5),
					AutomaticSize=Enum.AutomaticSize.X,ZIndex=3,Parent=r},{hlist(6,Enum.HorizontalAlignment.Right)})
				r.MouseEnter:Connect(function() tw(hov,0.15,{BackgroundTransparency=0.92}):Play()
					if tip and W.showTip then local m=UIS:GetMouseLocation() W.showTip(tip,m.X,m.Y) end end)
				r.MouseLeave:Connect(function() tw(hov,0.15,{BackgroundTransparency=1}):Play() if W.hideTip then W.hideTip() end end)
				if tip and UIS.TouchEnabled and not UIS.KeyboardEnabled then
					-- มือถือไม่มี hover → เพิ่มปุ่ม "?" แตะเพื่อดูคำอธิบาย (แตะซ้ำหรือรอ 4s = ซ่อน)
					local ib = new("TextButton",{BackgroundColor3=TH.glass,BackgroundTransparency=0.8,Text="?",
						TextColor3=TH.acc,TextSize=12,FontFace=D.F_TXT,Size=UDim2.new(0,22,0,22),
						LayoutOrder=-100,ZIndex=4,Parent=acc},{corner(11),stroke(TH.lav,0.5,1)})
					local tipT=nil
					ib.MouseButton1Click:Connect(function() sfx("tick",0.15,1.5)
						if tipT then tipT=nil if W.hideTip then W.hideTip() end return end
						local p=ib.AbsolutePosition
						if W.showTip then W.showTip(tip,p.X+8,p.Y-40) end
						local t=os.clock() tipT=t
						task.delay(4,function() if tipT==t then tipT=nil if W.hideTip then W.hideTip() end end end)
					end)
				end
				reg(r,lbl) return r,acc,L
			end
			GB._row=rowBase

			-- ---------- Toggle ----------
			function GB:Toggle(a)
				a=a or {}
				local r,acc,L = rowBase(a.label or "Toggle",30,a.tip)
				local hit = new("TextButton",{BackgroundTransparency=1,Text="",
					Size=UDim2.new(1,0,1,0),ZIndex=5,Parent=r})
				local cap,fill,knob,glow = capsule() cap.Parent=acc cap.LayoutOrder=1000
				local kBtn,kLbl
				if a.key then
					kBtn,kLbl = keycap(kname[a.key],34) kBtn.Parent=acc kBtn.LayoutOrder=500
				end
				local st = a.default and true or false
				local function paint()
					tw(fill,0.16,{BackgroundTransparency=st and 0 or 1}):Play()
					tw(knob,0.16,{Position=st and UDim2.new(0,29,0.5,0) or UDim2.new(0,11,0.5,0)}):Play()
					tw(glow,0.16,{ImageTransparency=st and 0.5 or 1}):Play()
				end
				local kbRef
				local function set(v,quiet)
					st=v and true or false paint()
					if kbRef then kbRef() end
					if not quiet and a.cb then task.spawn(a.cb,st) end
				end
				if a.key then
					kbRef=W:_kbRow(a.label or "Toggle",function() return a.key end,function() return st end)
					table.insert(W.kbRefresh,kbRef)
				end
				hit.MouseButton1Click:Connect(function() sfx("click",0.3,1.2) set(not st) end)
				if kBtn then
					local cap2=false
					kBtn.MouseButton1Click:Connect(function() sfx("tick",0.15,1.5)
						kLbl.Text="..." cap2=true
					end)
					table.insert(W.conns,UIS.InputBegan:Connect(function(i,gpe)
						if cap2 and i.UserInputType==Enum.UserInputType.Keyboard then
							cap2=false
							if i.KeyCode==Enum.KeyCode.Escape then kLbl.Text=kname[a.key] return end -- Esc = ยกเลิก
							a.key=i.KeyCode kLbl.Text=kname[i.KeyCode] if kbRef then kbRef() end
						elseif not gpe and i.KeyCode==a.key and not cap2 then set(not st) end
					end))
				end
				paint()
				local T={set=set,get=function() return st end,row=r,label=L}
				-- คีย์ลัดของสวิตช์ถูกบันทึก/โหลดคู่กับ flag (flag..":key")
				if a.flag and kLbl then
					T.keyEl={get=function() return a.key and a.key.Name or "" end,
						set=function(v) local kc=Enum.KeyCode[v] if kc then a.key=kc kLbl.Text=kname[kc] if kbRef then kbRef() end end end}
				end
				return T
			end

			-- ---------- Button ----------
			local function glassButton(a,parent,n)
				local b = new("TextButton",{Name="Button",BackgroundTransparency=1,Text="",
					Size=n and UDim2.new(1/n,-8*(n-1)/n,1,0) or UDim2.new(1,0,1,0),ZIndex=1,Parent=parent},{new("UIScale")})
				local body = new("Frame",{Name="Body",BackgroundColor3=TH.glass,BackgroundTransparency=0.9,
					Size=UDim2.new(1,0,1,0),ZIndex=1,ClipsDescendants=true,BorderSizePixel=0,Parent=b},{
					corner(9),
					new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
						NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.5)}}),
					new("UIStroke",{Color=TH.lav,Transparency=0.55,Thickness=1},{
						new("UIGradient",{Rotation=100,Transparency=NumberSequence.new{
							NumberSequenceKeypoint.new(0,0.05),NumberSequenceKeypoint.new(0.5,0.7),
							NumberSequenceKeypoint.new(1,0.3)}})}),
					new("Frame",{Name="Specular",BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.5,
						Size=UDim2.new(1,-18,0,1),Position=UDim2.new(0.5,0,0,1),AnchorPoint=Vector2.new(0.5,0),
						ZIndex=3,BorderSizePixel=0},{new("UIGradient",{Transparency=NumberSequence.new{
							NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)}})})})
				local lb = label(a.label or "ปุ่ม",13,a.danger and TH.warn or TH.ink,body)
				lb.Position=UDim2.new(0,6,0,0) lb.Size=UDim2.new(1,-12,1,0) lb.ZIndex=4
				local fuse = new("Frame",{Name="Fuse",BackgroundColor3=TH.warn,BackgroundTransparency=0,
					Size=UDim2.new(0,0,0,2),Position=UDim2.new(0.5,0,1,0),AnchorPoint=Vector2.new(0.5,1),
					ZIndex=4,BorderSizePixel=0,Parent=body})
				local sc=b:FindFirstChildOfClass("UIScale")
				b.MouseEnter:Connect(function() tw(body,0.15,{BackgroundTransparency=0.82}):Play() tw(sc,0.15,{Scale=1.02}):Play() end)
				b.MouseLeave:Connect(function() tw(body,0.15,{BackgroundTransparency=0.9}):Play() tw(sc,0.15,{Scale=1}):Play() end)
				local holding=false
				b.MouseButton1Down:Connect(function()
					tw(sc,0.08,{Scale=0.97}):Play()
					if a.danger then
						holding=true
						local t=tw(fuse,a.hold or 0.7,{Size=UDim2.new(1,0,0,2)},Enum.EasingStyle.Linear) t:Play()
						task.delay(a.hold or 0.7,function()
							if holding then holding=false fuse.Size=UDim2.new(0,0,0,2)
								if a.cb then task.spawn(a.cb) end end end)
					end
				end)
				local function release()
					tw(sc,0.12,{Scale=1.02}):Play()
					if holding then holding=false tw(fuse,0.15,{Size=UDim2.new(0,0,0,2)}):Play() end
				end
				b.MouseButton1Up:Connect(release)
				b.MouseLeave:Connect(release)
				b.MouseButton1Click:Connect(function() sfx("click") if not a.danger and a.cb then task.spawn(a.cb) end end)
				return b
			end
			function GB:Buttons(list)
				local row = new("Frame",{Name="Buttons",BackgroundTransparency=1,Size=UDim2.new(1,0,0,32),
					ZIndex=1,Parent=cnt},{new("UIListLayout",{Padding=UDim.new(0,8),FillDirection=Enum.FillDirection.Horizontal,
						SortOrder=Enum.SortOrder.LayoutOrder})})
				local nm={} for i,a in ipairs(list) do glassButton(a,row,#list).LayoutOrder=i nm[#nm+1]=a.label or "" end reg(row,table.concat(nm," "))
				return row
			end
			function GB:Button(a) return GB:Buttons{a} end
			function GB:Divider()
				local d = new("Frame",{Name="Divider",BackgroundTransparency=1,Size=UDim2.new(1,0,0,10),ZIndex=1,Parent=cnt})
				local function ln(ap,x,rot) new("Frame",{BackgroundColor3=TH.lav,BackgroundTransparency=0.55,
					Size=UDim2.new(0.5,-9,0,1),Position=UDim2.new(x,0,0.5,0),AnchorPoint=Vector2.new(ap,0.5),
					ZIndex=1,BorderSizePixel=0,Parent=d},{new("UIGradient",{Rotation=rot,Transparency=NumberSequence.new{
						NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0.3)}})}) end
				ln(0,0,0) ln(1,1,180)
				new("Frame",{BackgroundColor3=TH.acc,BackgroundTransparency=0.15,Size=UDim2.new(0,5,0,5),
					Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),Rotation=45,ZIndex=1,
					BorderSizePixel=0,Parent=d},{new("UICorner",{CornerRadius=UDim.new(0,1)})})
				return d
			end

			-- ---------- Slider ----------
			function GB:Slider(a)
				a=a or {}
				local r,acc,L = rowBase(a.label or "Slider",44,a.tip)
				L.Size=UDim2.new(1,-96,0,18)
				local val = new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.9,
					Size=UDim2.new(0,0,0,18),AutomaticSize=Enum.AutomaticSize.X,
					Position=UDim2.new(1,0,0,0),AnchorPoint=Vector2.new(1,0),ZIndex=2,Parent=r},{
					corner(9),stroke(TH.lav,0.8),pad(0,7,0,7)})
				local vl = label("",11,TH.ink,val) vl.AutomaticSize=Enum.AutomaticSize.X
				vl.Size=UDim2.new(0,0,1,0) vl.TextXAlignment=Enum.TextXAlignment.Left vl.ZIndex=3
				local area = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),
					Position=UDim2.new(0,0,1,0),AnchorPoint=Vector2.new(0,1),ZIndex=2,Parent=r})
				local tube = darkwell(2,6,3) tube.Size=UDim2.new(1,-14,0,6)
				tube.Position=UDim2.new(0,7,0.5,0) tube.AnchorPoint=Vector2.new(0,0.5) tube.Parent=area
				local fill = new("Frame",{BackgroundColor3=Color3.new(1,1,1),Size=UDim2.new(0,0,1,0),
					ClipsDescendants=true,ZIndex=3,BorderSizePixel=0,Parent=tube},{corner(3)})
				local ramp = new("Frame",{BackgroundColor3=Color3.new(1,1,1),Size=UDim2.new(0,200,1,0),
					ZIndex=3,BorderSizePixel=0,Parent=fill},{accgrad(0),corner(3),
					new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.55,
						Size=UDim2.new(1,0,0.5,0),ZIndex=4,BorderSizePixel=0},{corner(3),
						new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
							NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(1,1)}})})})
				for k=1,12 do
					new("Frame",{BackgroundColor3=TH.lav,BackgroundTransparency=0.55,Size=UDim2.new(0,2,0,2),
						Position=UDim2.new(k/12,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=4,
						BorderSizePixel=0,Parent=tube})
				end
				local sglow = new("ImageLabel",{BackgroundTransparency=1,Image=IMG.glow,ImageColor3=TH.acc,
					ImageTransparency=0.45,Size=UDim2.new(0,34,0,22),ZIndex=4,
					AnchorPoint=Vector2.new(0.5,0.5),Parent=tube})
				local bead2 = new("Frame",{BackgroundColor3=Color3.new(1,1,1),Size=UDim2.new(0,14,0,14),
					AnchorPoint=Vector2.new(0.5,0.5),ZIndex=6,BorderSizePixel=0,Parent=tube},{
					corner(7),stroke(TH.acc,0.1,1.5),
					new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(0,4,0,4),
						Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),
						ZIndex=7,BorderSizePixel=0},{corner(2)})})
				local bub = new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(0,0,0,20),
					AutomaticSize=Enum.AutomaticSize.X,AnchorPoint=Vector2.new(0.5,1),
					Position=UDim2.new(0,0,0,-12),ZIndex=8,Visible=false,Parent=area},{
					corner(6),pad(0,8,0,8),new("UIScale",{Scale=0.8})})
				local bubL = label("",11,Color3.new(1,1,1),bub) bubL.AutomaticSize=Enum.AutomaticSize.X
				bubL.Size=UDim2.new(0,0,1,0) bubL.TextXAlignment=Enum.TextXAlignment.Left bubL.ZIndex=9
				local hit = new("TextButton",{BackgroundTransparency=1,Text="",
					Size=UDim2.new(1,0,1,12),Position=UDim2.new(0,0,0,-6),ZIndex=10,Parent=area})

				local min,max = a.min or 0, a.max or 100
				if max<min then min,max=max,min end
				local span = (max-min)>0 and (max-min) or 1 -- กันหารศูนย์เมื่อ min==max
				local function snap(v)
					v=math.clamp(tonumber(v) or min,min,max)
					if a.step and a.step>0 then v=math.clamp(math.floor((v-min)/a.step+0.5)*a.step+min,min,max) end
					return v
				end
				local st = snap(a.default or min)
				local suf = a.suffix or ""
				local function fmt(v)
					local s=tostring(math.floor(v*100+0.5)/100)
					return s..(suf~="" and (" "..suf) or "")
				end
				local function render(v)
					local p = math.clamp((v-min)/span,0,1)
					fill.Size=UDim2.new(p,0,1,0)
					ramp.Size=UDim2.new(0,math.max(tube.AbsoluteSize.X,60),1,0)
					bead2.Position=UDim2.new(p,0,0.5,0) sglow.Position=UDim2.new(p,0,0.5,0)
					bub.Position=UDim2.new(p,0,0,-12)
					vl.Text=fmt(v) bubL.Text=fmt(v)
				end
				local dragging=false
				local function fromX(x)
					local tw2=tube.AbsoluteSize.X local tx=tube.AbsolutePosition.X
					local p=math.clamp((x-tx)/math.max(tw2,1),0,1)
					local v=snap(min+(max-min)*p)
					if v==st then return end
					st=v render(v) if a.cb then a.cb(st) end
				end
				hit.InputBegan:Connect(function(i)
					if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
						dragging=true bub.Visible=true fromX(i.Position.X)
					end
				end)
				table.insert(W.conns,UIS.InputChanged:Connect(function(i)
					if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
						fromX(i.Position.X) end end))
				table.insert(W.conns,UIS.InputEnded:Connect(function(i)
					if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
						dragging=false bub.Visible=false end end))
				render(st)
				local S2={get=function() return st end,set=function(v) st=snap(v) render(st) end,row=r}
				return S2
			end

			-- ---------- Dropdown ----------
			function GB:Dropdown(a)
				a=a or {}
				local holder = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,54),
					ZIndex=1,Parent=cnt})
				reg(holder,a.label or "") local L = label(a.label or "Select",13,TH.sub,holder)
				L.Size=UDim2.new(1,0,0,18) L.TextXAlignment=Enum.TextXAlignment.Left L.ZIndex=1
				local field = new("TextButton",{BackgroundTransparency=1,Text="",
					Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,1,0),AnchorPoint=Vector2.new(0,1),
					ZIndex=2,Parent=holder})
				darkwell(2,32,9).Parent=field
				local vl = label(a.default or "—",13,TH.ink,field)
				vl.Position=UDim2.new(0,12,0,0) vl.Size=UDim2.new(1,-60,1,0)
				vl.TextXAlignment=Enum.TextXAlignment.Left vl.ZIndex=3
				local ch2 = chevron(3) ch2.Position=UDim2.new(1,-14,0.5,0) ch2.Parent=field ch2.Rotation=90
				local sel = a.default
				field.MouseButton1Click:Connect(function() sfx("tick",0.2,1.3)
					W:closePop()
					local opts = a.options or {}
					local h = math.min(#opts*30+10,220)
					local list = new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.08,
						Size=UDim2.new(0,field.AbsoluteSize.X,0,h),ZIndex=170,BorderSizePixel=0,
						ClipsDescendants=true,Parent=W.popLayer},{
						corner(10),
						new("UIGradient",{Rotation=115,Color=ColorSequence.new{
							ColorSequenceKeypoint.new(0,TH.g0),ColorSequenceKeypoint.new(0.5,TH.g1),
							ColorSequenceKeypoint.new(1,TH.g2)}}),
						stroke(TH.lav,0.6)})
					local scr2 = new("ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
						CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
						ScrollBarThickness=2,ScrollBarImageColor3=TH.acc,ZIndex=171,Parent=list},
						{pad(5,5,5,5),vlist(2)})
					for _,op in ipairs(opts) do
						local ob = new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,0,26),
							ZIndex=172,Parent=scr2},{
							new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=op==sel and 0.85 or 1,
								Size=UDim2.new(1,0,1,0),ZIndex=172,BorderSizePixel=0},{corner(7)}),
							label(op,12,op==sel and TH.ink or TH.sub)})
						local ol = ob:GetChildren()[2]
						ol.Position=UDim2.new(0,10,0,0) ol.Size=UDim2.new(1,-10,1,0)
						ol.TextXAlignment=Enum.TextXAlignment.Left ol.ZIndex=173
						local hl=ob:GetChildren()[1]
						ob.MouseEnter:Connect(function() tw(hl,0.12,{BackgroundTransparency=0.85}):Play() end)
						ob.MouseLeave:Connect(function() tw(hl,0.12,{BackgroundTransparency=op==sel and 0.85 or 1}):Play() end)
						ob.MouseButton1Click:Connect(function() sfx("click",0.3,1.2)
							sel=op vl.Text=tostring(op) W:closePop()
							if a.cb then task.spawn(a.cb,op) end
						end)
					end
					local fp=field.AbsolutePosition local fh=field.AbsoluteSize.Y
					local vp=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
					local y = fp.Y+fh+6+h>vp.Y and (fp.Y-h-6) or (fp.Y+fh+6)
					list.Position=UDim2.new(0,fp.X,0,y)
					W.popScrim.Visible=true
					tw(ch2,0.15,{Rotation=270}):Play()
					list.Size=UDim2.new(0,field.AbsoluteSize.X,0,0)
					tw(list,0.18,{Size=UDim2.new(0,field.AbsoluteSize.X,0,h)}):Play()
				end)
				local D={get=function() return sel end,set=function(v) sel=v vl.Text=tostring(v) end}
				return D
			end

			-- ---------- Input ----------
			function GB:Input(a)
				a=a or {}
				local holder = new("Frame",{Name="Input",BackgroundTransparency=1,Size=UDim2.new(1,0,0,56),
					ZIndex=1,Parent=cnt})
				reg(holder,a.label or "") local L = label(a.label or "ช่องกรอก",13,TH.sub,holder)
				L.Size=UDim2.new(1,-50,0,18) L.TextXAlignment=Enum.TextXAlignment.Left
				local fieldw = darkwell(2,34,9) fieldw.Name="Field" fieldw.Position=UDim2.new(0,0,1,0)
				fieldw.AnchorPoint=Vector2.new(0,1) fieldw.ClipsDescendants=true fieldw.Parent=holder
				local tb = new("TextBox",{BackgroundTransparency=1,Text=a.default or "",
					PlaceholderText=a.placeholder or "",PlaceholderColor3=TH.mute,
					TextColor3=TH.ink,TextSize=13,FontFace=D.F_TXT,Size=UDim2.new(1,-24,1,0),
					Position=UDim2.new(0,12,0,0),TextXAlignment=Enum.TextXAlignment.Left,
					ZIndex=3,ClearTextOnFocus=false,Parent=fieldw})
				local fl = new("Frame",{Name="FocusLine",BackgroundColor3=TH.acc,Size=UDim2.new(0,0,0,2),
					Position=UDim2.new(0.5,0,1,0),AnchorPoint=Vector2.new(0.5,1),ZIndex=4,BorderSizePixel=0,Parent=fieldw},{
					new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),
						NumberSequenceKeypoint.new(0.2,0),NumberSequenceKeypoint.new(0.8,0),NumberSequenceKeypoint.new(1,1)}})})
				local fg = new("ImageLabel",{BackgroundTransparency=1,Image=IMG.glow,ImageColor3=TH.acc,ImageTransparency=1,
					Size=UDim2.new(0.8,0,0,22),Position=UDim2.new(0.5,0,1,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=3,Parent=fieldw})
				tb.Focused:Connect(function()
					tw(fl,0.25,{Size=UDim2.new(1,0,0,2)}):Play() tw(fg,0.25,{ImageTransparency=0.55}):Play() end)
				tb.FocusLost:Connect(function(ent)
					tw(fl,0.2,{Size=UDim2.new(0,0,0,2)}):Play() tw(fg,0.2,{ImageTransparency=1}):Play()
					if a.cb then task.spawn(a.cb,tb.Text,ent) end end)
				return {get=function() return tb.Text end,set=function(v) tb.Text=tostring(v) end,box=tb}
			end

			-- ---------- Label / divider ----------
			function GB:Label(txt,col)
				local l = label(txt,12,col or TH.sub,cnt) reg(l,txt)
				l.Size=UDim2.new(1,0,0,16) l.TextXAlignment=Enum.TextXAlignment.Left
				l.RichText=true l.AutomaticSize=Enum.AutomaticSize.Y l.TextWrapped=true
				return l
			end
			function GB:Keybind(a)
				a=a or {}
				local r,acc2 = rowBase(a.label or "Keybind",30,a.tip)
				local kBtn,kLbl = keycap(kname[a.key or Enum.KeyCode.Unknown],46)
				kBtn.Parent=acc2 kBtn.LayoutOrder=500
				local cap2=false
				local function setKey(kc,quiet)
					a.key=kc kLbl.Text=kname[kc]
					if not quiet and a.onChange then task.spawn(a.onChange,kc) end
				end
				kBtn.MouseButton1Click:Connect(function() sfx("tick",0.2,1.4) kLbl.Text="..." cap2=true end)
				table.insert(W.conns,UIS.InputBegan:Connect(function(i,gpe)
					if cap2 and i.UserInputType==Enum.UserInputType.Keyboard then
						cap2=false
						if i.KeyCode==Enum.KeyCode.Escape then kLbl.Text=kname[a.key or Enum.KeyCode.Unknown] return end -- Esc = ยกเลิกการจับคีย์
						setKey(i.KeyCode)
					elseif not gpe and a.key and i.KeyCode==a.key and a.cb then
						task.spawn(a.cb) end end))
				return {row=r,get=function() return a.key and a.key.Name or "" end,
					set=function(v) local kc=Enum.KeyCode[v] if kc then setKey(kc,true) end end}
			end
			for _,nm in ipairs({"Toggle","Slider","Dropdown","Input","Keybind"}) do
				local f=GB[nm]
				GB[nm]=function(self,a)
					local el=f(self,a)
					if type(a)=="table" and a.flag and el then
						W:_reg(a.flag,el,nm=="Toggle",nm~="Keybind" and a.cb or nil)
						if el.keyEl then W:_reg(a.flag..":key",el.keyEl,false,nil) end
					end
					return el
				end
			end
			return GB
		end

	end
	D.Widgets=Widgets
	return {}
end
]])
	_m["window"]=loadstring([[
-- ============================================================
-- FishUI/window.lua — หน้าต่างหลักทั้งก้อน (ยังไม่แตกย่อย ไว้รอบหน้า)
-- ใส่ลง D : blurOn, blurOff, windowFX, capsule, keycap, pillBtn
--            FishUI.Window (ผ่าน D.FishUI)
-- อ่านจาก D: TH, IMG, STR, FT, F_TXT/F_MONO/F_B, THEMES, sndOn/sndHost,
--            new, c3, corner, stroke, tw, sfx, pad, hlist, vlist, label,
--            lipEdge, chevron, darkwell, accgrad, sheenTop, glowImg,
--            glassBody, shadowImg, draggable, Icon, FishUI
-- ============================================================
return function(D)
	local FishUI=D.FishUI
	local TH,IMG,STR,FT=D.TH,D.IMG,D.STR,D.FT
	local TweenService = game:GetService("TweenService")
	local UIS = game:GetService("UserInputService")
	local RunS = game:GetService("RunService")
	local GuiS = game:GetService("GuiService")
	local LP = game:GetService("Players").LocalPlayer
	local new,c3,corner,stroke,tw,sfx=D.new,D.c3,D.corner,D.stroke,D.tw,D.sfx
	local pad,hlist,vlist,label=D.pad,D.hlist,D.vlist,D.label
	local lipEdge,chevron,darkwell,accgrad=D.lipEdge,D.chevron,D.darkwell,D.accgrad
	local sheenTop,glowImg,glassBody,shadowImg,draggable=D.sheenTop,D.glowImg,D.glassBody,D.shadowImg,D.draggable
	local Icon=D.Icon
	local blurOn,blurOff,windowFX,capsule,keycap,pillBtn,kname=D.blurOn,D.blurOff,D.windowFX,D.capsule,D.keycap,D.pillBtn,D.kname

--  WINDOW
-- ============================================================
function FishUI.Window(o)
	o = o or {}
	local W = {pages={}, pageObjs={}, subs={}, curPage=nil, destroyed=false, conns={}}
	local gui = new("ScreenGui",{Name=o.name or "FishUI",ResetOnSpawn=false,
		DisplayOrder=60,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
	pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end
	FishUI._sndHost(gui)
	W.gui = gui

	-- overlay สำหรับ tooltip/dropdown popup
	local overlay = new("Frame",{Name="Overlay",BackgroundTransparency=1,
		Size=UDim2.new(1,0,1,0),ZIndex=150,Visible=true,Parent=gui})
	local tooltip = new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.92,
		Visible=false,ZIndex=200,AutomaticSize=Enum.AutomaticSize.XY,BorderSizePixel=0,Parent=overlay},{
		corner(8), stroke(TH.lav,0.6), pad(6,10,6,10),
		new("UIGradient",{Rotation=115,Color=ColorSequence.new{
			ColorSequenceKeypoint.new(0,TH.g0),ColorSequenceKeypoint.new(1,TH.g2)}}),
		new("TextLabel",{BackgroundTransparency=1,Text="",TextColor3=TH.sub,TextSize=11,
			FontFace=D.F_TXT,AutomaticSize=Enum.AutomaticSize.XY})})
	local function showTip(txt,x,y)
		local l=tooltip:FindFirstChildOfClass("TextLabel") l.Text=txt
		tooltip.Visible=true tooltip.Position=UDim2.new(0,x+14,0,y+16)
	end
	local function hideTip() tooltip.Visible=false end
	W.showTip,W.hideTip = showTip,hideTip

	-- dropdown popup layer
	local popLayer = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
		ZIndex=160,Visible=true,Parent=overlay})
	W.popLayer = popLayer
	local popScrim = new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,1,0),
		ZIndex=160,Visible=false,Parent=popLayer})
	W.popScrim = popScrim
	function W:closePop() popScrim.Visible=false for _,c in ipairs(popLayer:GetChildren()) do if c~=popScrim then c:Destroy() end end end
	popScrim.MouseButton1Click:Connect(function() sfx("tick",0.15,0.9) W:closePop() end)

	-- ============ main window ============
	local win = new("Frame",{Name="Window",BackgroundTransparency=1,
		Size=UDim2.new(0,o.w or 760,0,o.h or 600),Position=o.pos or UDim2.new(0.5,0,0.5,0),
		AnchorPoint=Vector2.new(0.5,0.5),ZIndex=1,Parent=gui},{
		new("UIScale"), shadowImg(0,0.55)})
	W.win = win W.gui = gui
	local main,HttpS
	function W:SetOpacity(v,noSave)
		v=math.clamp(v or 25,0,40)
		if main then main.BackgroundTransparency=0.32-v*0.006 end
		if not noSave then W.saved.Opacity=v W:Save() end
	end
	local wBlur=true blurOn()
	main = glassBody(1,14) main.Name="Main" main.Parent=win windowFX(win,main)

	-- specular top
	new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.35,
		Size=UDim2.new(1,-56,0,1),Position=UDim2.new(0.5,0,0,1),AnchorPoint=Vector2.new(0.5,0),
		ZIndex=49,BorderSizePixel=0,Parent=main},{
		new("UIGradient",{Transparency=NumberSequence.new{
			NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)}})})

	-- ambient: 16 จุดเล็กลอยช้าๆ (เหมือนต้นฉบับ)
	local ambient = new("Frame",{Name="Ambient",BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
		ClipsDescendants=true,ZIndex=2,Parent=main})
	for i=1,16 do
		local rnd=Random.new(i*31)
		local sz=rnd:NextInteger(2,3)
		local dot = new("Frame",{BackgroundColor3=TH.acc,BackgroundTransparency=rnd:NextNumber(0.3,0.95),
			Size=UDim2.new(0,sz,0,sz),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=2,BorderSizePixel=0,
			Position=UDim2.new(rnd:NextNumber(-0.02,1.02),0,rnd:NextNumber(-0.03,1),0),Parent=ambient},{corner(8)})
		task.spawn(function()
			while gui.Parent do
				local d=rnd:NextNumber(7,14)
				tw(dot,d,{Position=UDim2.new(rnd:NextNumber(-0.02,1.02),0,rnd:NextNumber(-0.03,1.0),0),
					BackgroundTransparency=rnd:NextNumber(0.3,0.95)},Enum.EasingStyle.Sine):Play()
				task.wait(d)
			end
		end)
	end

	-- brand header
	local brand = new("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,20,0,14),
		Size=UDim2.new(0,176,0,42),ZIndex=6,Parent=main})
	label(o.title or "Fishy Hub",16,TH.ink,brand).Position=UDim2.new(0,0,0.5,-8)
	label(o.brand or "",11,TH.mute,brand).Position=UDim2.new(0,0,0.5,10)
	for _,t in ipairs(brand:GetChildren()) do
		t.Size=UDim2.new(1,0,0,t.TextSize==16 and 20 or 14) t.AnchorPoint=Vector2.new(0,0.5)
		t.TextXAlignment=Enum.TextXAlignment.Left
	end

	-- drag ด้วย header
	draggable(brand,win)
	local topDrag = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,56),ZIndex=4,Parent=main})
	draggable(topDrag,win)

	-- ============ sidebar ============
	local sidebar = new("ScrollingFrame",{BackgroundTransparency=1,
		Position=UDim2.new(0,12,0,68),Size=UDim2.new(0,184,1,-168),
		CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
		ScrollBarThickness=0,ZIndex=5,ClipsDescendants=true,Parent=main})
	W.sidebar = sidebar
	local tabsHost = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
		ZIndex=5,Parent=sidebar},{vlist(6)})
	W.tabsHost = tabsHost

	-- indicator (เลนส์แก้วสไลด์ตามแท็บ)
	local indicator = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38),
		ZIndex=6,Visible=false,Parent=sidebar},{
		new("Frame",{Name="Lens",BackgroundColor3=TH.glass,BackgroundTransparency=0.86,
			Size=UDim2.new(1,0,1,0),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),
			ZIndex=6,BorderSizePixel=0},{corner(10),stroke(TH.lav,0.7),
			new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{
				NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.4)}})})})
	W.indicator = indicator

	-- divider
	new("Frame",{Name="Divider",BackgroundColor3=TH.lav,BackgroundTransparency=0,Size=UDim2.new(0,1,1,-60),
		Position=UDim2.new(0,208,0,22),AnchorPoint=Vector2.new(0.5,0),ZIndex=4,BorderSizePixel=0,Parent=main},{
		new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),
			NumberSequenceKeypoint.new(0.15,0.86),NumberSequenceKeypoint.new(0.85,0.86),NumberSequenceKeypoint.new(1,1)}})})

	-- โปรไฟล์ผู้เล่นมุมล่างซ้ายของ sidebar (กะทัดรัด — ไม่เว้นที่ตายด้านขวา)
	do
		local pc=new("Frame",{Name="Profile",BackgroundColor3=TH.glass,BackgroundTransparency=0.9,Size=UDim2.new(0,168,0,46),
			Position=UDim2.new(0,12,1,-86),ZIndex=6,BorderSizePixel=0,Parent=main},{corner(12),stroke(TH.lav,0.75),
			new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.45)}})})
		local pav=new("ImageLabel",{BackgroundColor3=TH.g1,Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,8,0.5,0),AnchorPoint=Vector2.new(0,0.5),
			ZIndex=7,Image="",Parent=pc},{new("UICorner",{CornerRadius=UDim.new(0.5,0)}),stroke(TH.acc,0.2,1.5)})
		task.spawn(function() pcall(function() pav.Image=game.Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end) end)
		new("Frame",{BackgroundColor3=Color3.fromRGB(98,242,194),Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,30,0.5,11),AnchorPoint=Vector2.new(0,0.5),
			ZIndex=9,BorderSizePixel=0,Parent=pc},{new("UICorner",{CornerRadius=UDim.new(0.5,0)}),stroke(TH.g1,0,1.5)})
		local pn=label(LP.DisplayName,12,TH.ink,pc) pn.Position=UDim2.new(0,46,0,6) pn.Size=UDim2.new(1,-80,0,15) pn.TextXAlignment=Enum.TextXAlignment.Left pn.ZIndex=7 pn.TextTruncate=Enum.TextTruncate.AtEnd
		local ps=label("@"..LP.Name.." · ออนไลน์",9,TH.mute,pc) ps.Position=UDim2.new(0,46,0,22) ps.Size=UDim2.new(1,-80,0,13) ps.TextXAlignment=Enum.TextXAlignment.Left ps.ZIndex=7 ps.TextTruncate=Enum.TextTruncate.AtEnd
		W._profileSub=ps
		local lo=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-7,0.5,0),
			AnchorPoint=Vector2.new(1,0.5),ZIndex=9,Parent=pc},{new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.85,
			Size=UDim2.new(1,0,1,0),ZIndex=9,BorderSizePixel=0},{corner(9),stroke(TH.lav,0.6)})})
		local loi=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,18,0,18),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=10,Parent=lo})
		Icon.logout(loi,TH.bad)
		lo.MouseEnter:Connect(function() tw(lo.Frame,0.12,{BackgroundTransparency=0.7}):Play() end)
		lo.MouseLeave:Connect(function() tw(lo.Frame,0.12,{BackgroundTransparency=0.85}):Play() end)
		lo.MouseButton1Click:Connect(function() sfx("click") W:Logout() end)
	end

	-- ============ content ============
	local content = new("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,208,0,0),
		Size=UDim2.new(1,-208,1,-28),ZIndex=5,ClipsDescendants=true,Parent=main})
	W.content = content

	-- footer
	local fname=o.footer
	if fname==nil then pcall(function() fname=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end) fname=fname or ("แมพ "..game.PlaceId) end
	label(fname,12,TH.mute,main).Size=UDim2.new(1,-160,0,28)
	local ft = main:GetChildren()[#main:GetChildren()]
	ft.Position=UDim2.new(0.5,0,1,0) ft.AnchorPoint=Vector2.new(0.5,1) ft.ZIndex=15 ft.Name="Footer"

	-- ============ top-right controls ============
	local function dot(par,col,x,y,s,z)
		return new("Frame",{BackgroundColor3=col,Size=UDim2.new(0,s,0,s),Position=UDim2.new(0.5,x,0.5,y),
			AnchorPoint=Vector2.new(0.5,0.5),ZIndex=z or 21,BorderSizePixel=0,Parent=par},{corner(3)})
	end
	local function bar(par,col,w,h,x,y,rot,ap)
		return new("Frame",{BackgroundColor3=col,Size=UDim2.new(0,w,0,h),Position=UDim2.new(0.5,x,0.5,y),
			AnchorPoint=ap or Vector2.new(0.5,0.5),Rotation=rot or 0,ZIndex=21,BorderSizePixel=0,Parent=par},{corner(1)})
	end
	local function topBtn(name,xoff,glyph)
		local b = new("TextButton",{Name=name,BackgroundTransparency=1,Text="",Size=UDim2.new(0,28,0,28),
			Position=UDim2.new(1,xoff,0,14),AnchorPoint=Vector2.new(1,0),ZIndex=20,Parent=main},{
			new("Frame",{Name="Plate",BackgroundColor3=TH.glass,BackgroundTransparency=0.9,
				Size=UDim2.new(1,0,1,0),ZIndex=20,BorderSizePixel=0},{corner(14),stroke(TH.lav,0.7)}),
			new("UIScale")})
		glyph(b)
		local plate,sc = b.Plate,b:FindFirstChildOfClass("UIScale")
		b.MouseEnter:Connect(function() tw(plate,0.15,{BackgroundTransparency=0.8}):Play() tw(sc,0.15,{Scale=1.08}):Play() end)
		b.MouseLeave:Connect(function() tw(plate,0.15,{BackgroundTransparency=0.9}):Play() tw(sc,0.15,{Scale=1}):Play() end)
		b.MouseButton1Down:Connect(function() tw(sc,0.08,{Scale=0.92}):Play() end)
		b.MouseButton1Up:Connect(function() tw(sc,0.12,{Scale=1.08}):Play() end)
		return b
	end
	local btnMin = topBtn("Minimize",-14,function(b) bar(b,TH.ink,11,2,0,0) end)
	local btnThemes = topBtn("Themes",-48,function(b)
		dot(b,TH.acc,-3,-3,5) dot(b,Color3.fromRGB(124,208,255),3,-3,5)
		dot(b,Color3.fromRGB(255,142,194),-3,3,5) dot(b,Color3.fromRGB(98,242,194),3,3,5) end)
	local btnPalette = topBtn("Palette",-82,function(b)
		local g = new("Frame",{BackgroundColor3=TH.ink,BackgroundTransparency=0.72,Size=UDim2.new(0,18,0,15),
			Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=21,BorderSizePixel=0,Parent=b},
			{new("UICorner",{CornerRadius=UDim.new(0.5,0)})})
		local function pd(col,x,y,s) new("Frame",{BackgroundColor3=col,Size=UDim2.new(0,s,0,s),
			Position=UDim2.new(x,0,y,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=22,BorderSizePixel=0,Parent=g},
			{new("UICorner",{CornerRadius=UDim.new(0.5,0)})}) end
		pd(TH.g1,0.72,0.68,4) pd(TH.acc,0.3,0.36,3) pd(TH.warn,0.54,0.27,3) pd(TH.acc2,0.76,0.4,3) end)
	local btnAttach = topBtn("Attachments",-116,function(b)
		bar(b,TH.ink,13,3,0,-7,0,Vector2.new(0.5,0)) bar(b,TH.ink,9,3,0,-2,0,Vector2.new(0.5,0))
		bar(b,TH.ink,13,3,0,3,0,Vector2.new(0.5,0)) end)
	local btnCursor = topBtn("Cursor",-150,function(b)
		bar(b,TH.ink,3,13,0,0,26)
		local d=dot(b,TH.acc,3,4,4) d.UICorner.CornerRadius=UDim.new(0,2) end)

	-- resize grip
	local grip = new("TextButton",{Name="ResizeGrip",BackgroundTransparency=1,Text="",
		Size=UDim2.new(0,18,0,18),Position=UDim2.new(1,-5,1,-5),AnchorPoint=Vector2.new(1,1),ZIndex=25,Parent=main})
	local function gl(w,h,x,y,rot) new("Frame",{BackgroundColor3=TH.dim,BackgroundTransparency=0.35,
		Size=UDim2.new(0,w,0,h),Position=UDim2.new(0,x,0,y),AnchorPoint=Vector2.new(0.5,0.5),
		Rotation=rot or 0,ZIndex=26,BorderSizePixel=0,Parent=grip}) end
	gl(9,1,9,9,45) gl(5,1,10,13) gl(1,5,13,10)
	do
		local rs,rsz
		grip.InputBegan:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
				rs=i.Position rsz=win.AbsoluteSize/win.UIScale.Scale end end)
		table.insert(W.conns,UIS.InputChanged:Connect(function(i)
			if rs and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
				local d=(i.Position-rs)/win.UIScale.Scale
				win.Size=UDim2.new(0,math.clamp(rsz.X+d.X,560,1400),0,math.clamp(rsz.Y+d.Y,420,900)) end end))
		table.insert(W.conns,UIS.InputEnded:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then rs=nil end end))
	end

	-- ============ bubble (ย่อเป็นบาร์ลอย) ============
	local bubble = new("Frame",{Name="Bubble",BackgroundTransparency=1,
		Size=UDim2.new(0,340,0,44),Position=UDim2.new(0.5,0,1,-60),
		AnchorPoint=Vector2.new(0.5,0.5),ZIndex=200,Visible=false,Parent=gui},{
		new("UIScale"), shadowImg(1,0.55)})
	local bb = glassBody(2,22) bb.Parent=bubble bb.Name="Body"
	-- signal bars
	local sig = new("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,16,0.5,7),
		Size=UDim2.new(0,10,0,13),AnchorPoint=Vector2.new(0,1),ZIndex=60,Parent=bb})
	local sigBars={}
	for i=1,3 do
		sigBars[i]=new("Frame",{BackgroundColor3=TH.dim,BackgroundTransparency=0.72,
			Size=UDim2.new(0,3,0,2+i*4),Position=UDim2.new(0,(i-1)*4+2,1,0),
			AnchorPoint=Vector2.new(0,1),ZIndex=60,BorderSizePixel=0,Parent=sig},{corner(1)})
	end
	local bbTitle = label(o.title or "Hub",14,TH.ink,bb)
	bbTitle.Position=UDim2.new(0,40,0,0) bbTitle.Size=UDim2.new(0,80,1,0)
	bbTitle.TextXAlignment=Enum.TextXAlignment.Left bbTitle.ZIndex=60
	local function seg(x,w,txt,col,mono)
		new("Frame",{BackgroundColor3=TH.lav,BackgroundTransparency=0.78,
			Size=UDim2.new(0,1,0,18),Position=UDim2.new(0,x-8,0.5,0),AnchorPoint=Vector2.new(0,0.5),
			ZIndex=60,BorderSizePixel=0,Parent=bb})
		local l = label(txt,12,col or TH.sub,bb,mono)
		l.Position=UDim2.new(0,x,0,0) l.Size=UDim2.new(0,w,1,0) l.ZIndex=60
		l.TextXAlignment=Enum.TextXAlignment.Left
		return l
	end
	local bbPing = seg(124,52,"-- ms",TH.ink)
	local bbFps  = seg(188,52,"-- fps")
	local bbSess = seg(248,80,"00:00:00",TH.ink,true)
	local bbHit = new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,1,0),ZIndex=70,Parent=bb})
	draggable(bbHit,bubble)

	-- ============ edge rail (บับเบิลลากชิดขอบจอ = พับเก็บเป็นแถบข้าง) ============
	local rail = new("Frame",{Name="EdgeRail",BackgroundTransparency=1,Size=UDim2.new(0,52,0,120),
		Position=UDim2.new(0,0,0.5,0),AnchorPoint=Vector2.new(0,0.5),ZIndex=180,Visible=false,Parent=gui},{
		new("UIScale"),shadowImg(0,0.55)})
	local rbody = glassBody(2,16) rbody.Name="Body" rbody.Parent=rail
	new("Frame",{Name="Grabber",BackgroundColor3=TH.acc,BackgroundTransparency=0.45,Size=UDim2.new(0,3,0,26),
		Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=30,BorderSizePixel=0,Parent=rbody},{corner(2)})
	local rhit = new("TextButton",{Name="Hitbox",BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,1,0),ZIndex=40,Parent=rail})
	local function dock(side)
		rail.AnchorPoint=Vector2.new(side=="L" and 0 or 1,0.5)
		rail.Position=UDim2.new(side=="L" and 0 or 1,side=="L" and -60 or 60,0.5,0)
		rail.Visible=true bubble.Visible=false
		tw(rail,0.3,{Position=UDim2.new(side=="L" and 0 or 1,0,0.5,0)},Enum.EasingStyle.Back):Play()
	end
	rhit.MouseEnter:Connect(function() tw(rbody:FindFirstChild("Grabber"),0.15,{BackgroundTransparency=0.1,Size=UDim2.new(0,3,0,34)}):Play() end)
	rhit.MouseLeave:Connect(function() tw(rbody:FindFirstChild("Grabber"),0.15,{BackgroundTransparency=0.45,Size=UDim2.new(0,3,0,26)}):Play() end)
	rhit.MouseButton1Click:Connect(function() sfx("open",0.4) rail.Visible=false W:setVisible(true) end)
	bbHit.InputEnded:Connect(function(i)
		if i.UserInputType~=Enum.UserInputType.MouseButton1 and i.UserInputType~=Enum.UserInputType.Touch then return end
		task.defer(function()
			local vp=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
			local cx=bubble.AbsolutePosition.X+bubble.AbsoluteSize.X/2
			if cx<100 then dock("L") elseif cx>vp.X-100 then dock("R") end
		end)
	end)

	local t0=os.clock()
	task.spawn(function()
		while gui.Parent do
			task.wait(1)
			local t=math.floor(os.clock()-t0)
			bbSess.Text=string.format("%02d:%02d:%02d",t/3600,(t/60)%60,t%60)
			if W._profileSub then W._profileSub.Text="@"..LP.Name.." · "..string.format("%02d:%02d",(t/60)%60,t%60) end
			pcall(function()
				local p=LP:FindFirstChild("PlayerGui") and game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
				if p then
					local pv=math.floor(p:GetValue()) bbPing.Text=pv.." ms"
					local lit=pv<=80 and 3 or pv<=160 and 2 or 1
					local col=lit==3 and Color3.fromRGB(98,242,194) or lit==2 and TH.warn or TH.bad
					for i,b in ipairs(sigBars) do b.BackgroundColor3=i<=lit and col or TH.dim
						b.BackgroundTransparency=i<=lit and 0.12 or 0.72 end
				end
			end)
			bbFps.Text=math.floor(1/math.max(RunS.RenderStepped:Wait(),0.001)).." fps"
		end
	end)

	-- ============ visibility ============
	local shown=true
	function W:setVisible(v)
		sfx("open",0.35,v and 1 or 0.75)
		shown=v win.Visible=v bubble.Visible=not v
		if v and not wBlur then wBlur=true blurOn() elseif not v and wBlur then wBlur=false blurOff() end
		if v then
			local full=win.Size
			win.Size=UDim2.new(0,full.X.Offset*0.94,0,full.Y.Offset*0.94)
			tw(win,0.3,{Size=full},Enum.EasingStyle.Back):Play()
		else
			bubble.UIScale.Scale=0.8 tw(bubble.UIScale,0.25,{Scale=1},Enum.EasingStyle.Back):Play()
		end
	end
	function W:toggle() W:setVisible(not shown) end
	bbHit.MouseButton1Click:Connect(function() sfx("open",0.4) W:setVisible(true) end)
	btnMin.MouseButton1Click:Connect(function() sfx("open",0.3,0.75) W:setVisible(false) end)

	-- ============ theme (สแกนสีเก่า → สีใหม่ ทั้ง GUI) ============
	local THEMES = D.THEMES
	local themeIdx = 1
	local function remap(map)
		local pairsList={} for from,to in pairs(map) do pairsList[#pairsList+1]={from,to} end
		local function swap(c) for _,p in ipairs(pairsList) do if c==p[1] then return p[2] end end return c end
		for _,d in ipairs(gui:GetDescendants()) do
			pcall(function()
				if d:IsA("GuiObject") then d.BackgroundColor3=swap(d.BackgroundColor3) end
				if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then d.TextColor3=swap(d.TextColor3) end
				if d:IsA("ImageLabel") then d.ImageColor3=swap(d.ImageColor3) end
				if d:IsA("UIStroke") then d.Color=swap(d.Color) end
				if d:IsA("UIGradient") then
					local ks=d.Color.Keypoints local nk={}
					for i,k in ipairs(ks) do nk[i]=ColorSequenceKeypoint.new(k.Time,swap(k.Value)) end
					d.Color=ColorSequence.new(nk)
				end
			end)
		end
	end
	function W:SetTheme(i)
		local new2 = THEMES[i]
		if not new2 or i==themeIdx then return end
		-- แมปจากสี "ปัจจุบัน" ใน TH (ไม่ใช่สีธีมเดิม) — กันกรณีเปลี่ยนสีเน้นไปแล้วค่อยเปลี่ยนธีม สีเน้นค้าง
		remap({[TH.acc]=new2.acc,[TH.acc2]=new2.acc2,[TH.lav]=new2.lav,[TH.g0]=new2.g0,[TH.g1]=new2.g1,[TH.g2]=new2.g2,[TH.sub]=new2.sub})
		for _,k in ipairs({"acc","acc2","lav","g0","g1","g2","sub"}) do TH[k]=new2[k] end
		themeIdx=i
	end
	local function nextTheme() sfx("tick",0.2,1.4)
		local n=themeIdx%#THEMES+1 W:SetTheme(n) W:Notify{title="ธีม",text=THEMES[n].name,dur=2} end
	btnThemes.MouseButton1Click:Connect(nextTheme)
	W.CycleTheme=nextTheme
	local ACCS = {Color3.fromRGB(205,145,255),Color3.fromRGB(124,208,255),Color3.fromRGB(255,142,194),Color3.fromRGB(98,242,194),Color3.fromRGB(255,198,112)}
	local accIdx=1
	local function nextAccent() sfx("tick",0.2,1.4)
		local n=accIdx%#ACCS+1
		remap({[TH.acc]=ACCS[n]}) TH.acc=ACCS[n] accIdx=n
		W:Notify{title="สีเน้น",text=string.format("RGB %d,%d,%d",ACCS[n].R*255,ACCS[n].G*255,ACCS[n].B*255),dur=2} end
	btnPalette.MouseButton1Click:Connect(nextAccent)
	W.CycleAccent=nextAccent

	-- ============ keybinds panel ============
	local kbPanel = new("Frame",{Name="Keybinds",BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.08,
		Position=UDim2.new(0,16,0.4,0),Size=UDim2.new(0,210,0,0),AutomaticSize=Enum.AutomaticSize.Y,
		ZIndex=150,Visible=false,BorderSizePixel=0,Parent=gui},{
		corner(12),
		new("UIGradient",{Rotation=115,Color=ColorSequence.new{ColorSequenceKeypoint.new(0,TH.g0),
			ColorSequenceKeypoint.new(0.5,TH.g1),ColorSequenceKeypoint.new(1,TH.g2)},
			Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.05),NumberSequenceKeypoint.new(1,0.2)}}),
		stroke(TH.lav,0.5), pad(10,12,10,12), vlist(6)})
	kbPanel.UIListLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
	local kbt=label("Keybinds",12,TH.ink,kbPanel) kbt.Size=UDim2.new(1,0,0,18) kbt.TextXAlignment=Enum.TextXAlignment.Left kbt.LayoutOrder=1 kbt.ZIndex=151
	local kbRows = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
		LayoutOrder=2,ZIndex=151,Parent=kbPanel},{new("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder})})
	draggable(kbt,kbPanel)
	function W:_kbRow(name,getKey,getState,kind)
		local r = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),ZIndex=151,Parent=kbRows})
		local st = new("Frame",{BackgroundColor3=TH.acc,BackgroundTransparency=0.6,Size=UDim2.new(0,6,0,6),
			Position=UDim2.new(0,0,0.5,0),AnchorPoint=Vector2.new(0,0.5),ZIndex=152,BorderSizePixel=0,Parent=r},{corner(3)})
		local nl = label("",12,TH.ink,r) nl.Position=UDim2.new(0,14,0,0) nl.Size=UDim2.new(1,-60,1,0)
		nl.TextXAlignment=Enum.TextXAlignment.Left nl.ZIndex=152
		local kl = label(kind or "Toggle",11,TH.mute,r) kl.Position=UDim2.new(1,0,0,0) kl.Size=UDim2.new(0,50,1,0)
		kl.AnchorPoint=Vector2.new(1,0) kl.TextXAlignment=Enum.TextXAlignment.Right kl.ZIndex=152
		local function refresh()
			nl.Text="["..kname[getKey()].."]  "..name
			local on=getState()
			st.BackgroundTransparency=on and 0 or 0.6
			st.BackgroundColor3=on and TH.acc or TH.dim
			nl.TextColor3=on and TH.ink or TH.sub
		end
		refresh()
		return refresh
	end
	W.kbRefresh = {}
	function W:ToggleKeybinds() kbPanel.Visible=not kbPanel.Visible
		for _,f in ipairs(W.kbRefresh) do f() end end
	table.insert(W.conns,UIS.InputBegan:Connect(function(i,gpe)
		if not gpe and i.KeyCode==Enum.KeyCode.RightAlt then W:ToggleKeybinds() end end))

	-- ============ satellites (การ์ดข้อมูลลอยข้างหน้าต่าง) ============
	local sats,satOn={}, false
	local function satellite(key,title,y)
		local card = new("Frame",{Name="Satellite_"..key,BackgroundTransparency=1,Size=UDim2.new(0,176,0,100),
			ZIndex=90,Visible=false,Parent=gui},{new("UIScale"),shadowImg(0,1)})
		for _,cy in ipairs({25,75}) do
			new("Frame",{BackgroundColor3=TH.glass,Size=UDim2.new(0,16,0,5),Position=UDim2.new(0,-5,0,cy),
				AnchorPoint=Vector2.new(0.5,0.5),ZIndex=1,BorderSizePixel=0,Parent=card},{
				new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),
					NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)}}),
				new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(1,-2,0,2),Position=UDim2.new(0.5,0,0.5,0),
					AnchorPoint=Vector2.new(0.5,0.5),ZIndex=2,BorderSizePixel=0})})
		end
		local body = new("CanvasGroup",{Name="Body",BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=2,Parent=card})
		local surf = glassBody(1,12) surf.Name="Surface" surf.BackgroundTransparency=0.96 surf.Parent=body
		new("Frame",{Name="Wash",BackgroundColor3=TH.g2,BackgroundTransparency=0.62,Size=UDim2.new(1,0,1,0),
			ZIndex=2,BorderSizePixel=0,Parent=body},{corner(12)})
		new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(0,5,0,5),Position=UDim2.new(0,12,0,14),
			ZIndex=3,BorderSizePixel=0,Parent=body},{corner(3)})
		local t=label(title,11,Color3.fromRGB(228,225,238),body) t.Position=UDim2.new(0,23,0,8) t.Size=UDim2.new(1,-50,0,16)
		t.TextXAlignment=Enum.TextXAlignment.Left t.ZIndex=3
		for _,dx in ipairs({164,159,154}) do
			new("Frame",{BackgroundColor3=TH.dim,BackgroundTransparency=0.35,Size=UDim2.new(0,3,0,3),
				Position=UDim2.new(0,dx,0,15),AnchorPoint=Vector2.new(1,0),ZIndex=3,BorderSizePixel=0,Parent=body},{corner(2)})
		end
		draggable(t,card)
		return card,body
	end
	local function sline(body,txt,sz,x,y,w,col,mono)
		local l=label(txt,sz,col or TH.ink,body,mono) l.Position=UDim2.new(0,x,0,y) l.Size=UDim2.new(0,w,0,sz+4)
		l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=3 return l
	end
	local subc=Color3.fromRGB(228,225,238)
	do
		local c,b=satellite("Session","เวลาเล่น")
		local big=sline(b,"00:00:00",20,12,28,120) local sub=sline(b,"เซิร์ฟเวอร์ 0 นาที",11,12,56,150,subc)
		sats[#sats+1]={card=c,upd=function()
			local t=math.floor(os.clock()-t0) big.Text=string.format("%02d:%02d:%02d",t/3600,(t/60)%60,t%60)
			local up=math.floor(workspace.DistributedGameTime) sub.Text=string.format("เซิร์ฟเวอร์ %d นาที %d วิ",up/60,up%60) end}
	end
	do
		local c,b=satellite("Performance","ประสิทธิภาพ")
		local big=sline(b,"0",22,12,26,70) sline(b,"fps",11,12,56,40,subc)
		local ms=sline(b,"0 ms",12,0,56,70,Color3.fromRGB(223,218,236)) ms.Position=UDim2.new(1,-82,0,56) ms.TextXAlignment=Enum.TextXAlignment.Right
		local bars={}
		for i=1,12 do bars[i]=new("Frame",{BackgroundColor3=TH.acc,BackgroundTransparency=0.35,Size=UDim2.new(0,3,0,2),
			Position=UDim2.new(0,12+(i-1)*5,1,-2),AnchorPoint=Vector2.new(0,1),ZIndex=4,BorderSizePixel=0,Parent=b}) end
		local hist={} 
		sats[#sats+1]={card=c,upd=function()
			local fps=math.floor(1/math.max(RunS.RenderStepped:Wait(),0.001)) big.Text=tostring(fps)
			pcall(function() ms.Text=math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()).." ms" end)
			table.insert(hist,fps) if #hist>12 then table.remove(hist,1) end
			for i=1,12 do local v=hist[i] or 0 bars[i].Size=UDim2.new(0,3,0,math.clamp(v/60*14,2,16)) end end}
	end
	do
		local c,b=satellite("Server","เซิร์ฟเวอร์")
		local big=sline(b,"0/0",20,12,28,100) sline(b,"ผู้เล่น",11,12,56,60,subc)
		local reg=sline(b,"TH  ·  "..(identifyexecutor and identifyexecutor() or "Executor"),11,12,76,150,subc)
		sats[#sats+1]={card=c,upd=function()
			big.Text=#game.Players:GetPlayers().."/"..game.Players.MaxPlayers end}
	end
	do
		local c,b=satellite("Location","พิกัด")
		local vs={}
		for i,ax in ipairs({"X","Y","Z"}) do
			sline(b,ax,10,12,28+(i-1)*20,12,subc)
			vs[ax]=sline(b,"0",12,28,26+(i-1)*20,78,TH.ink,true)
		end
		local nrow=sline(b,"N",9,148,52,12,subc)
		sats[#sats+1]={card=c,upd=function()
			local ch=LP.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
			if hrp then local p=hrp.Position vs.X.Text=math.floor(p.X) vs.Y.Text=math.floor(p.Y) vs.Z.Text=math.floor(p.Z) end end}
	end
	do
		local c,b=satellite("Radar","เรดาร์")
		local big=sline(b,"0",22,12,26,60) sline(b,"ใกล้ตัว",11,12,56,60,subc) sline(b,"รัศมี 220 เมตร",10,12,76,120,subc)
		sats[#sats+1]={card=c,upd=function()
			local n=0 local ch=LP.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
			if hrp then for _,p in ipairs(game.Players:GetPlayers()) do
				local c2=p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if c2 and (c2.Position-hrp.Position).Magnitude<=220 then n=n+1 end end end
			big.Text=tostring(n) end}
	end
	local function layoutSats()
		local wp,ws=win.AbsolutePosition,win.AbsoluteSize
		for i,s in ipairs(sats) do
			s.card.Position=UDim2.new(0,wp.X+ws.X+14,0,wp.Y+(i-1)*112)
			s.card.UIScale.Scale=win.UIScale.Scale
		end
	end
	local function toggleSats() sfx("tick",0.2,1.4)
		satOn=not satOn layoutSats()
		for _,s in ipairs(sats) do s.card.Visible=satOn
			if satOn then s.card.UIScale.Scale=0.85 tw(s.card.UIScale,0.25,{Scale=win.UIScale.Scale},Enum.EasingStyle.Back):Play() end end
		if satOn then for _,s in ipairs(sats) do pcall(s.upd) end end
	end
	btnAttach.MouseButton1Click:Connect(function() sfx("click",0.25) toggleSats() end)
	W.ToggleSatellites=toggleSats
	task.spawn(function()
		while gui.Parent do task.wait(0.5)
			if satOn then for _,s in ipairs(sats) do pcall(s.upd) end end end end)

	-- ============ custom cursor ============
	local curOn=false
	local curF = new("Frame",{Name="Cursor",BackgroundTransparency=1,Size=UDim2.new(0,32,0,32),
		AnchorPoint=Vector2.new(0.5,0.5),ZIndex=9000,Visible=false,Parent=gui},{
		new("ImageLabel",{BackgroundTransparency=1,Image=IMG.glow,ImageColor3=TH.acc,ImageTransparency=0.55,
			Size=UDim2.new(1,0,1,0),ZIndex=9000}),
		new("Frame",{BackgroundColor3=TH.ink,Size=UDim2.new(0,6,0,6),Position=UDim2.new(0.5,0,0.5,0),
			AnchorPoint=Vector2.new(0.5,0.5),ZIndex=9001,BorderSizePixel=0},{corner(3),stroke(TH.acc,0.1,1.5)})})
	table.insert(W.conns,RunS.RenderStepped:Connect(function()
		if curOn then local m=UIS:GetMouseLocation() curF.Position=UDim2.new(0,m.X,0,m.Y) end end))
	local function setCursor(on,quiet)
		curOn=on curF.Visible=on
		pcall(function() UIS.MouseIconEnabled=not on end)
		if not quiet then W:Notify{title="เคอร์เซอร์",text=on and "เปิดเคอร์เซอร์แบบกำหนดเอง" or "ใช้เคอร์เซอร์ปกติ",dur=2} end
	end
	W.SetCursor=function(_,on) setCursor(on,true) end
	btnCursor.MouseButton1Click:Connect(function() sfx("tick",0.2,1.4) setCursor(not curOn) end)

	W.toggleKey = o.toggleKey or Enum.KeyCode.RightShift
	function W:SetToggleKey(kc,noSave)
		if not kc then return end
		W.toggleKey=kc
		if not noSave then W.saved.ToggleKey=kc.Name W:Save() end
	end
	table.insert(W.conns, UIS.InputBegan:Connect(function(i,gpe)
		if not gpe and i.KeyCode==W.toggleKey then W:toggle() end
	end))

	-- responsive scale
	local function rescale()
		local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
		local s = math.clamp(math.min(vp.X/(o.w or 760)*0.92, vp.Y/(o.h or 600)*0.92), 0.55, 1.15)
		win.UIScale.Scale = s
	end
	rescale()
	if workspace.CurrentCamera then
		table.insert(W.conns, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale))
	end

	-- ============ notify ============
	local notif = new("Frame",{BackgroundTransparency=1,Position=UDim2.new(1,-16,0,74),
		Size=UDim2.new(0,292,1,-32),AnchorPoint=Vector2.new(1,0),ZIndex=300,Parent=gui},{vlist(8)})
	function W:Notify(n)
		if W.destroyed then return end
		sfx("noti",0.3,1.15)
		n=n or {}
		local card = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
			AutomaticSize=Enum.AutomaticSize.Y,Parent=notif},{
			shadowImg(0,0.7),
			new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.1,
				Size=UDim2.new(1,0,1,0),ZIndex=2,BorderSizePixel=0},{
				corner(12),
				new("UIGradient",{Rotation=115,Color=ColorSequence.new{
					ColorSequenceKeypoint.new(0,TH.g0),ColorSequenceKeypoint.new(0.5,TH.g1),
					ColorSequenceKeypoint.new(1,TH.g2)}}),
				stroke(TH.lav,0.6),
				new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(0,4,0,12),
					Position=UDim2.new(0,10,0,12),ZIndex=4,BorderSizePixel=0},{corner(2)}),
				label(n.title or "Notice",13,TH.ink),
				label(n.text or "",11,TH.sub)})})
		local inner = card:GetChildren()[2]
		local tl,bl = inner:GetChildren()[5], inner:GetChildren()[6]
		tl.Position=UDim2.new(0,22,0,10) tl.Size=UDim2.new(1,-30,0,16) tl.TextXAlignment=Enum.TextXAlignment.Left tl.ZIndex=4
		bl.Position=UDim2.new(0,22,0,28) bl.Size=UDim2.new(1,-30,0,0) bl.TextXAlignment=Enum.TextXAlignment.Left
		bl.TextYAlignment=Enum.TextYAlignment.Top bl.AutomaticSize=Enum.AutomaticSize.Y
		bl.TextWrapped=true bl.ZIndex=4 bl.RichText=true
		new("UIPadding",{PaddingBottom=UDim.new(0,12),Parent=inner})
		card.BackgroundTransparency=1
		inner.Position=UDim2.new(1,20,0,0)
		tw(inner,0.35,{Position=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back):Play()
		task.delay(n.dur or 4,function()
			local t=tw(inner,0.3,{Position=UDim2.new(1,20,0,0)},Enum.EasingStyle.Back)
			t.Completed:Connect(function() card:Destroy() end) t:Play()
		end)
	end

	D.Nav.attach(W,{win=win,content=content,indicator=indicator,tabsHost=tabsHost})

	D.Widgets.attach(W)
	-- ============ config (หลังบ้าน: บันทึก/โหลดค่าอัตโนมัติ) ============
	W.flags,W.saved,W.cfgName={}, {}, nil
	HttpS = game:GetService("HttpService")
	-- snapshot = ค่าที่บันทึกไว้เดิม (รวม Opacity/ToggleKey/flag ที่ยังไม่ถูกสร้าง) ทับด้วยค่าสดของทุก flag
	function W:Snapshot()
		local snap={}
		for k,v in pairs(W.saved) do snap[k]=v end
		for k,el in pairs(W.flags) do
			local ok,v=pcall(el.get)
			if ok and v~=nil then snap[k]=v end
		end
		return snap
	end
	local lastSaved=""
	function W:Save(force)
		if not W.cfgName then return end
		local snap=W:Snapshot()
		local ok,enc=pcall(HttpS.JSONEncode,HttpS,snap)
		if not ok then return end
		W.saved=snap
		if force or enc~=lastSaved then
			if pcall(function()
				if makefolder and not isfolder("FishUI") then makefolder("FishUI") end
				writefile("FishUI/"..W.cfgName..".json",enc)
			end) then lastSaved=enc end
		end
	end
	function W:Config(name)
		W.cfgName=name
		pcall(function() if makefolder and not isfolder("FishUI") then makefolder("FishUI") end end)
		local ok,raw=pcall(readfile,"FishUI/"..name..".json")
		if ok and raw then local ok2,t=pcall(HttpS.JSONDecode,HttpS,raw) if ok2 and type(t)=="table" then W.saved=t lastSaved=raw end end
		if W.saved.Opacity then W:SetOpacity(W.saved.Opacity,true) end
		if W.saved.ToggleKey then W:SetToggleKey(Enum.KeyCode[W.saved.ToggleKey],true) end
		task.spawn(function()
			while gui.Parent do
				task.wait(2)
				W:Save()
			end
		end)
	end
	-- ใช้ชุดค่า (เช่นโปรไฟล์) ทันที: ตั้งค่าทุก flag ที่มีอยู่ + ยิง cb ของตัวที่ไม่ใช่สวิตช์ (สวิตช์ยิง cb ใน set เอง)
	function W:ApplyFlags(t)
		local n=0
		for k,v in pairs(t or {}) do
			local el=W.flags[k]
			if el then
				local ok=pcall(el.set,v)
				local meta=W._flagMeta[k]
				if ok and meta and not meta.isToggle and meta.cb then task.spawn(meta.cb,v) end
				if ok then n=n+1 end
			end
			W.saved[k]=v
		end
		W:Save()
		return n
	end
	W._flagMeta={}
	function W:_reg(flag,el,isToggle,cb)
		W.flags[flag]=el
		W._flagMeta[flag]={isToggle=isToggle,cb=cb}
		local v=W.saved[flag]
		if v~=nil then
			pcall(el.set,v)
			if not isToggle and cb then task.spawn(cb,v) end
		end
	end

	-- warning banner
	function W:_warnbox(S,a)
		a=a or {}
		local wb = new("Frame",{BackgroundColor3=TH.warn,BackgroundTransparency=0.9,
			Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=1,
			ZIndex=1,BorderSizePixel=0,Parent=S.scroller},{
			corner(12),stroke(TH.warn,0.45),pad(10,12,10,12)})
		local hd2=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),ZIndex=2,Parent=wb})
		local bd=new("Frame",{BackgroundColor3=TH.warn,BackgroundTransparency=0,Size=UDim2.new(0,20,0,20),
			Position=UDim2.new(0,0,0.5,0),AnchorPoint=Vector2.new(0,0.5),ZIndex=3,BorderSizePixel=0,Parent=hd2},{corner(10)})
		local bt=label(a.title or "!",13,Color3.fromRGB(30,20,5),bd) bt.Size=UDim2.new(1,0,1,0) bt.ZIndex=4
		local tl=label("คำเตือน",13,TH.warn,hd2) tl.Position=UDim2.new(0,28,0,0) tl.Size=UDim2.new(1,-28,1,0) tl.ZIndex=3 tl.TextXAlignment=Enum.TextXAlignment.Left
		local d = label(a.text or "",12,Color3.fromRGB(228,225,238),wb)
		d.Position=UDim2.new(0,0,0,24)
		d.Size=UDim2.new(1,0,0,0) d.AutomaticSize=Enum.AutomaticSize.Y
		d.TextXAlignment=Enum.TextXAlignment.Left d.TextYAlignment=Enum.TextYAlignment.Top
		d.TextWrapped=true d.RichText=true d.ZIndex=3
		return wb
	end

	function W:Logout()
		pcall(FishUI.KeyStore.clear)
		local cb=o.onLogout
		W:Destroy()
		if cb then task.spawn(cb) end
	end

	function W:Destroy()
		if W.destroyed then return end
		pcall(function() W:Save() end) -- flush ค่าก่อนปิด (ไม่ต้องรอรอบ 2 วิ)
		W.destroyed=true
		if wBlur then wBlur=false blurOff() end
		pcall(function() UIS.MouseIconEnabled=true end)
		for _,c in ipairs(W.conns) do pcall(function() c:Disconnect() end) end
		gui:Destroy()
	end

	-- ใช้ค่าจาก setup.json (ธีม/เคอร์เซอร์) หลังสร้างหน้าครบ
	task.defer(function()
		pcall(function()
			local t=HttpS:JSONDecode(readfile("FishUI/setup.json"))
			if t.Theme and t.Theme~=1 then W:SetTheme(t.Theme) end
			if t.Cursor=="Custom" then W:SetCursor(true) end
		end)
	end)

	-- เปิดหน้าแรก
	task.defer(function()
		local p1=W.pages[1]
		if p1 then
			if #p1.subs>0 then p1.open=true p1.refreshH() W:showSub(p1,p1.firstSub)
			else W:showPage(p1) end
		end
	end)
	return W
end
	return {}
end
]])
	_m["sidebar"]=loadstring([=[
-- ============================================================
-- FishUI/sidebar.lua — แผงซ้ายหน้าคีย์ (ข้อมูลผู้ใช้/อวาตาร์/แถว/เวลา/ปิง)
-- ใส่ลง D : Sidebar (table: Sidebar.build(main,ctx) -> {gname})
-- อ่านจาก D: TH, IMG, STR, FT, new, corner, stroke, tw, sfx, Icon, LP
-- ctx ที่ต้องส่ง: P, card, txt, setStatus, gui, H0
-- ============================================================
return function(D)
	local TH,IMG,STR,FT=D.TH,D.IMG,D.STR,D.FT
	local UIS = game:GetService("UserInputService")
	local LP = game:GetService("Players").LocalPlayer
	local new,corner,stroke,tw,sfx,Icon=D.new,D.corner,D.stroke,D.tw,D.sfx,D.Icon
	local Sidebar={}
	function Sidebar.build(main,o,ctx)
		local P,card,txt,setStatus,gui,H0=ctx.P,ctx.card,ctx.txt,ctx.setStatus,ctx.gui,ctx.H0
		local chipUsr=P(card(main,20,18,34,26,13))
		local uic=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=7,Parent=chipUsr}) Icon.user(uic,TH.sub)
		txt(main,STR.userInfo,FT.xs,TH.sub,62,24,140,14)
		local av=P(new("Frame",{BackgroundColor3=TH.g1,Size=UDim2.new(0,100,0,100),Position=UDim2.new(0,93,0,89),ZIndex=6,
			BorderSizePixel=0,Parent=main},{new("UICorner",{CornerRadius=UDim.new(0.5,0)}),stroke(TH.acc,0.1,2)}))
		local avImg=new("ImageLabel",{BackgroundTransparency=1,Size=UDim2.new(0,94,0,94),
			Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=6,Image="",Parent=av},
			{new("UICorner",{CornerRadius=UDim.new(0.5,0)})})
		task.spawn(function() pcall(function()
			avImg.Image=game.Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end) end)
		local avGlow=new("ImageLabel",{BackgroundTransparency=1,Image=IMG.glow,ImageColor3=TH.acc,ImageTransparency=0.6,
			Size=UDim2.new(0,150,0,150),Position=UDim2.new(0,143,0,139),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=5,Parent=main})
		task.spawn(function() while gui.Parent do tw(avGlow,1.6,{ImageTransparency=0.4},Enum.EasingStyle.Sine):Play() task.wait(1.6)
			tw(avGlow,1.6,{ImageTransparency=0.65},Enum.EasingStyle.Sine):Play() task.wait(1.6) end end)
		local dot=new("Frame",{BackgroundColor3=Color3.fromRGB(98,242,194),Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,181,0,176),
			ZIndex=8,BorderSizePixel=0,Parent=main},{new("UICorner",{CornerRadius=UDim.new(0.5,0)}),stroke(TH.g1,0,2)})
		task.spawn(function() while gui.Parent do tw(dot,0.9,{Size=UDim2.new(0,10,0,10),Position=UDim2.new(0,183,0,178)},Enum.EasingStyle.Sine):Play() task.wait(0.9)
			tw(dot,0.9,{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,181,0,176)},Enum.EasingStyle.Sine):Play() task.wait(0.9) end end)
		txt(main,LP.DisplayName,18,TH.ink,20,196,250,22,Enum.TextXAlignment.Center,true)
		txt(main,"@"..LP.Name,FT.xs,TH.mute,20,220,250,14,Enum.TextXAlignment.Center)
		local exe=pcall(identifyexecutor) and identifyexecutor() or "ไม่ทราบ"
		local hw="—" pcall(function() hw=(gethwid and gethwid()) or "—" end)
		local hwFull=hw
		hw=#hw>16 and (hw:sub(1,8).."…"..hw:sub(-6)) or hw
		local gname="—" pcall(function() gname=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
		local rows={{"monitor","ตัวรันสคริปต์",exe},{UIS.TouchEnabled and "device" or "monitor","อุปกรณ์",UIS.TouchEnabled and "มือถือ" or "คอมพิวเตอร์"},
			{"calendar","อายุบัญชี",LP.AccountAge.." วัน"},{"shield","รหัสเครื่อง",hw},{"gamepad","เกมปัจจุบัน",gname}}
		for i,r in ipairs(rows) do
			local c=P(card(main,20,246+(i-1)*52,232,40,10))
			local ic=new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.85,
				Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,8,0.5,0),AnchorPoint=Vector2.new(0,0.5),ZIndex=7,
				BorderSizePixel=0,Parent=c},{corner(14),stroke(TH.lav,0.55)})
			Icon[r[1]](ic,TH.sub)
			txt(c,r[2],FT.xs,TH.sub,44,6,170,12)
			local v=txt(c,tostring(r[3]),FT.sm,i==5 and Color3.fromRGB(98,242,194) or TH.ink,44,19,176,16,nil,true) v.TextTruncate=Enum.TextTruncate.AtEnd
			if i==4 then
				local cb2=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(0,26,0,26),
					Position=UDim2.new(1,-8,0.5,0),AnchorPoint=Vector2.new(1,0.5),ZIndex=9,Parent=c},{
					new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.85,Size=UDim2.new(1,0,1,0),
						ZIndex=9,BorderSizePixel=0},{corner(8),stroke(TH.lav,0.5)})})
				local ci=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,24,0,24),Position=UDim2.new(0.5,0,0.5,0),
					AnchorPoint=Vector2.new(0.5,0.5),ZIndex=10,Parent=cb2}) Icon.copy(ci,TH.sub)
				cb2.MouseButton1Click:Connect(function() sfx("click")
					if setclipboard then pcall(setclipboard,hwFull) setStatus(STR.toastCopy,Color3.fromRGB(98,242,194),"ok")
					else setStatus(STR.noCopy,TH.warn,"warn") end end)
			end
		end
		local sess=P(card(main,20,H0-64,232,34,10))
		local st0=os.clock()
		local sT=txt(sess,"เวลา 00:00",FT.xs,TH.sub,12,0,100,38)
		local pT=txt(sess,"ปิง -- ms",FT.xs,TH.sub,120,0,100,38)
		local gdot=new("Frame",{BackgroundColor3=Color3.fromRGB(98,242,194),Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,24,0,H0-80),
			ZIndex=7,BorderSizePixel=0,Parent=main},{corner(3)})
		new("ImageLabel",{BackgroundTransparency=1,Image=IMG.glow,ImageColor3=Color3.fromRGB(98,242,194),ImageTransparency=0.5,
			Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,27,0,H0-77),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=6,Parent=main})
		task.spawn(function() while gui.Parent do tw(gdot,0.9,{Size=UDim2.new(0,4,0,4),Position=UDim2.new(0,25,0,H0-79)},Enum.EasingStyle.Sine):Play() task.wait(0.9)
			tw(gdot,0.9,{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,24,0,H0-80)},Enum.EasingStyle.Sine):Play() task.wait(0.9) end end)
		txt(main,string.format(STR.connected,o.brand or "HZ HUB"),FT.xs,Color3.fromRGB(98,242,194),38,H0-83,200,12)
		task.spawn(function() while gui.Parent do task.wait(1)
			local t=math.floor(os.clock()-st0) sT.Text=string.format("เวลา %02d:%02d",t/60,t%60)
			pcall(function() pT.Text="ปิง "..math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()).." ms" end) end end)

		new("Frame",{BackgroundColor3=TH.lav,BackgroundTransparency=0.9,Size=UDim2.new(0,1,1,-60),Position=UDim2.new(0,272,0,30),
			ZIndex=4,BorderSizePixel=0,Parent=main})
		return {gname=gname}
	end
	D.Sidebar=Sidebar
	return {}
end
]=])
	_m["keyscreen"]=loadstring([=[
-- ============================================================
-- FishUI/keyscreen.lua — หน้าใส่คีย์ทั้งก้อน (สถานะ/ปุ่ม/คู่มือ/verify)
-- ใส่ลง D : (ไม่มี — ตั้ง FishUI.KeyScreen ผ่าน D.FishUI อย่างเดียว)
-- อ่านจาก D: TH, IMG, STR, FT, F_TXT/F_MONO/F_B, sndOn/sndHost, Sidebar,
--            new, c3, corner, stroke, tw, sfx, pad, hlist, vlist, label,
--            lipEdge, chevron, darkwell, accgrad, sheenTop, glowImg,
--            glassBody, shadowImg, draggable, Icon, blurOn, blurOff,
--            windowFX, capsule, keycap, pillBtn, FishUI
-- ============================================================
return function(D)
	local FishUI=D.FishUI
	local TH,IMG,STR,FT=D.TH,D.IMG,D.STR,D.FT
	local TweenService = game:GetService("TweenService")
	local UIS = game:GetService("UserInputService")
	local RunS = game:GetService("RunService")
	local GuiS = game:GetService("GuiService")
	local LP = game:GetService("Players").LocalPlayer
	local new,c3,corner,stroke,tw,sfx=D.new,D.c3,D.corner,D.stroke,D.tw,D.sfx
	local pad,hlist,vlist,label=D.pad,D.hlist,D.vlist,D.label
	local lipEdge,chevron,darkwell,accgrad=D.lipEdge,D.chevron,D.darkwell,D.accgrad
	local sheenTop,glowImg,glassBody,shadowImg,draggable=D.sheenTop,D.glowImg,D.glassBody,D.shadowImg,D.draggable
	local Icon=D.Icon
	local blurOn,blurOff,windowFX=D.blurOn,D.blurOff,D.windowFX
	local capsule,keycap,pillBtn=D.capsule,D.keycap,D.pillBtn

function FishUI.KeyScreen(o)
	o=o or {}
	local validate=o.validate or function(k) return k=="123" end
	local HttpS=game:GetService("HttpService")
	local K={conns={}}
	local gui=new("ScreenGui",{Name="FishKey",ResetOnSpawn=false,DisplayOrder=70,IgnoreGuiInset=true,
		ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
	pcall(function() gui.Parent=game:GetService("CoreGui") end)
	if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end
	FishUI._sndHost(gui)
	K.gui=gui

	local setup={SoundEnabled=true,SoundVolume=0.6,RememberKey=true}
	D.sndOn=(setup.SoundEnabled~=false)
	pcall(function() local t=HttpS:JSONDecode(readfile("FishUI/setup.json")) for k,v in pairs(t) do setup[k]=v end end)
	D.sndVol=setup.SoundVolume or 1 -- ผูกสไลเดอร์เสียงเข้ากับ sfx จริง (เดิมตั้งแล้วไม่เปลี่ยน)
	local function saveSetup() pcall(function() if makefolder and not isfolder("FishUI") then makefolder("FishUI") end
		writefile("FishUI/setup.json",HttpS:JSONEncode(setup)) end) end

	local W0,H0=o.w or 900,o.h or 600
	local win=new("Frame",{Name="Window",BackgroundTransparency=1,Size=UDim2.new(0,W0,0,H0),
		Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),Parent=gui},{new("UIScale"),shadowImg(0,0.55)})
	local main=glassBody(1,16) main.Name="Main" main.Parent=win
	local kBlur=true blurOn() windowFX(win,main)
	local function rescale()
		local vp=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
		win.UIScale.Scale=math.clamp(math.min(vp.X/W0*0.9,vp.Y/H0*0.9),0.5,1.1) end
	rescale()
	pcall(function() table.insert(K.conns,workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)) end)
	draggable(new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,60),ZIndex=4,Parent=main}),win)

	-- particles
	local amb=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ClipsDescendants=true,ZIndex=2,Parent=main})
	for i=1,18 do
		local rnd=Random.new(i*13) local s=rnd:NextInteger(2,3)
		local d=new("Frame",{BackgroundColor3=TH.acc,BackgroundTransparency=rnd:NextNumber(0.3,0.95),
			Size=UDim2.new(0,s,0,s),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=2,BorderSizePixel=0,
			Position=UDim2.new(rnd:NextNumber(0,1),0,rnd:NextNumber(0,1),0),Parent=amb},{corner(8)})
		task.spawn(function() while gui.Parent do local t=rnd:NextNumber(7,13)
			tw(d,t,{Position=UDim2.new(rnd:NextNumber(0,1),0,rnd:NextNumber(0,1),0)},Enum.EasingStyle.Sine):Play() task.wait(t) end end)
	end

	local function txt(par,t,sz,col,x,y,w,h,al,bold)
		local l=new("TextLabel",{BackgroundTransparency=1,Text=t,TextColor3=col or TH.ink,TextSize=(sz<=11 and sz+1 or sz),
			FontFace=bold and D.F_B or D.F_TXT,Position=UDim2.new(0,x,0,y),Size=UDim2.new(0,w,0,h or sz+4),
			TextXAlignment=al or Enum.TextXAlignment.Left,ZIndex=6,Parent=par}) return l end
	local function card(par,x,y,w,h,r)
		return new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.84,Position=UDim2.new(0,x,0,y),
			Size=UDim2.new(0,w,0,h),ZIndex=5,BorderSizePixel=0,Parent=par},{corner(r or 12),stroke(TH.lav,0.7),
			new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.45)}})})
	end

	-- title
	local ti=txt(main,STR.welcome.." "..(o.brand or "HZ HUB"),20,TH.ink,0,10,W0-40,26,Enum.TextXAlignment.Center,true) ti.Position=UDim2.new(0,20,0,10)
	txt(main,STR.update.." "..(o.version or "v1.0"),FT.xs,TH.sub,0,38,W0,12,Enum.TextXAlignment.Center)

	-- top-right min / close
	local function ctl(xoff,glyph,cb)
		local b=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,xoff,0,14),
			AnchorPoint=Vector2.new(1,0),ZIndex=20,Parent=main},{
			new("Frame",{Name="Plate",BackgroundColor3=TH.glass,BackgroundTransparency=0.9,Size=UDim2.new(1,0,1,0),
				ZIndex=20,BorderSizePixel=0},{corner(14),stroke(TH.lav,0.7)}),
			})
		Icon[glyph](b,TH.ink)
		b.MouseEnter:Connect(function() tw(b.Plate,0.15,{BackgroundTransparency=0.78}):Play() end)
		b.MouseLeave:Connect(function() tw(b.Plate,0.15,{BackgroundTransparency=0.9}):Play() end)
		b.MouseButton1Click:Connect(function() sfx("click") cb() end) return b
	end
	local sizeFull=win.Size
	ctl(-14,"close",function() K:Close() end)
	local pill=new("Frame",{Name="Pill",BackgroundTransparency=1,Size=UDim2.new(0,230,0,42),Position=UDim2.new(0.5,0,1,-60),
		AnchorPoint=Vector2.new(0.5,0.5),ZIndex=200,Visible=false,Parent=gui},{new("UIScale"),shadowImg(1,0.55)})
	local pb=glassBody(2,21) pb.Parent=pill
	local pdot=new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,18,0.5,0),AnchorPoint=Vector2.new(0,0.5),
		ZIndex=60,BorderSizePixel=0,Parent=pb},{corner(4)})
	local plab=new("TextLabel",{BackgroundTransparency=1,Text=(o.brand or "HZ HUB").." — ใส่คีย์",TextColor3=TH.ink,TextSize=13,FontFace=D.F_TXT,
		Position=UDim2.new(0,34,0,0),Size=UDim2.new(1,-46,1,0),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=60,Parent=pb})
	local phit=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,1,0),ZIndex=70,Parent=pb})
	draggable(phit,pill)
	local function showWin(v)
		win.Visible=v pill.Visible=not v
		if v and not kBlur then kBlur=true blurOn() elseif not v and kBlur then kBlur=false blurOff() end
		if v then local t=win.UIScale.Scale win.UIScale.Scale=t*0.94 tw(win.UIScale,0.3,{Scale=t},Enum.EasingStyle.Back):Play()
		else pill.UIScale.Scale=0.8 tw(pill.UIScale,0.25,{Scale=1},Enum.EasingStyle.Back):Play() end
	end
	phit.MouseButton1Click:Connect(function() sfx("open",0.4) showWin(true) end)
	ctl(-48,"minus",function() showWin(false) end)

	-- ===== เอฟเฟกต์เข้าฉาก (stagger) =====
	local pops={} local function P(x) if x then pops[#pops+1]=x end return x end
	-- ===== left: user info =====
	local setStatus
	local sb=D.Sidebar.build(main,o,{P=P,card=card,txt=txt,setStatus=function(...) return setStatus(...) end,gui=gui,H0=H0})
	local gname=sb.gname

	-- ===== right =====
	local RX=318
	local logo=P(txt(main,(o.logo or "HZ HUB"),28,Color3.new(1,1,1),RX,104,120,34,nil,true))
	new("UIGradient",{Rotation=90,Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(1,TH.lav)},Parent=logo})
	new("ImageLabel",{BackgroundTransparency=1,Image=IMG.glow,ImageColor3=TH.acc,ImageTransparency=0.6,
		Size=UDim2.new(0,140,0,20),Position=UDim2.new(0,RX+52,0,142),AnchorPoint=Vector2.new(0.5,0.5),ZIndex=5,Parent=main})
	txt(main,STR.svcActive,FT.xs,TH.mute,RX+112,100,200,12)
	local hubTxt=o.hub or ((o.brand or "HZ HUB")..(gname~="—" and (" — "..gname) or ""))
	txt(main,hubTxt,16,TH.ink,RX+112,114,400,20,nil,true)
	txt(main,STR.svcVerified,FT.xs,TH.sub,RX+112,138,300,12)
	txt(main,STR.safeAccess,FT.xs,TH.sub,RX,204,300,12)

	local field=P(darkwell(5,48,12)) field.Position=UDim2.new(0,RX,0,226) field.Size=UDim2.new(0,554,0,52) field.Parent=main
	local kic=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,14,0.5,0),
		AnchorPoint=Vector2.new(0,0.5),ZIndex=6,Parent=field}) Icon.key(kic,TH.dim)
	local tb=new("TextBox",{BackgroundTransparency=1,Text="",PlaceholderText=STR.keyPlaceholder,PlaceholderColor3=TH.mute,
		TextColor3=TH.ink,TextSize=13,FontFace=D.F_TXT,Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,48,0,0),
		TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,ClearTextOnFocus=false,Parent=field})
	local fl=new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(0,0,0,2),Position=UDim2.new(0.5,0,1,0),AnchorPoint=Vector2.new(0.5,1),
		ZIndex=7,BorderSizePixel=0,Parent=field},{new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),
		NumberSequenceKeypoint.new(0.2,0),NumberSequenceKeypoint.new(0.8,0),NumberSequenceKeypoint.new(1,1)}})})
	tb.Focused:Connect(function() tw(fl,0.25,{Size=UDim2.new(1,0,0,2)}):Play() end)
	tb.FocusLost:Connect(function() tw(fl,0.2,{Size=UDim2.new(0,0,0,2)}):Play() end)
	tb.Size=UDim2.new(1,-60,1,0)
	-- สถานะคีย์: จุดไอคอนสี + ข้อความ + เวลาคงเหลือ
	local stDot=new("Frame",{BackgroundColor3=TH.acc,Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,RX+2,0,296),
		ZIndex=7,BorderSizePixel=0,Parent=main},{corner(4)})
	local status=P(txt(main,STR.stIdle,FT.sm,TH.sub,RX+16,292,460,16))
	local expT=txt(main,"",11,TH.sub,RX+476,292,78,16,Enum.TextXAlignment.Right)
	function setStatus(t,col,kind)
		status.Text=t status.TextColor3=col or TH.sub
		stDot.BackgroundColor3=kind=="ok" and Color3.fromRGB(98,242,194) or kind=="bad" and TH.bad
			or kind=="warn" and TH.warn or kind=="load" and TH.acc or (col or TH.sub)
	end
	-- ลิงก์คู่มือรับคีย์
	local showPanel
	local guideB=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(0,160,0,18),
		Position=UDim2.new(0,RX+394,0,290),ZIndex=7,Parent=main})
	local gl=txt(guideB,STR.guide,FT.xs,TH.acc,0,0,160,18,Enum.TextXAlignment.Right) gl.ZIndex=8
	guideB.MouseEnter:Connect(function() tw(gl,0.15,{TextColor3=Color3.new(1,1,1)}):Play() end)
	guideB.MouseLeave:Connect(function() tw(gl,0.15,{TextColor3=TH.acc}):Play() end)
	guideB.MouseButton1Click:Connect(function() sfx("click") showPanel(STR.guide,o.guideSteps or STR.guideSteps) end)

	local function bigBtn(x,y,w,t,accent,cb,h,icon)
		h=h or 47
		local b=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(0,w,0,h),Position=UDim2.new(0,x,0,y),
			ZIndex=6,Parent=main},{new("UIScale")})
		if pops then pops[#pops+1]=b end
		local body=new("Frame",{Name="Body",BackgroundColor3=accent and TH.acc2 or TH.glass,BackgroundTransparency=accent and 0.35 or 0.9,
			Size=UDim2.new(1,0,1,0),ZIndex=6,BorderSizePixel=0,ClipsDescendants=true,Parent=b},{corner(12),
			stroke(accent and TH.acc or TH.lav,accent and 0.2 or 0.55),
			new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.5)}}),
			new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.5,Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0.5,0,0,1),
				AnchorPoint=Vector2.new(0.5,0),ZIndex=8,BorderSizePixel=0},{new("UIGradient",{Transparency=NumberSequence.new{
				NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)}})})})
		local l=txt(body,t,13,TH.ink,icon and 50 or 0,0,icon and (w-60) or w,h,icon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,true) l.ZIndex=9
		if icon then local ic=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,16,0.5,0),AnchorPoint=Vector2.new(0,0.5),ZIndex=9,Parent=body}) Icon[icon](ic,TH.ink) end
		local sc=b.UIScale
		b.MouseEnter:Connect(function() tw(sc,0.15,{Scale=1.015}):Play() tw(body,0.15,{BackgroundTransparency=accent and 0.2 or 0.82}):Play() end)
		b.MouseLeave:Connect(function() tw(sc,0.15,{Scale=1}):Play() tw(body,0.15,{BackgroundTransparency=accent and 0.35 or 0.9}):Play() end)
		b.MouseButton1Down:Connect(function() tw(sc,0.08,{Scale=0.97}):Play() end)
		b.MouseButton1Up:Connect(function() tw(sc,0.12,{Scale=1.015}):Play() end)
		b.MouseEnter:Connect(function() sfx("tick",0.08,1.7) end)
		b.InputBegan:Connect(function(io)
			if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
				local p=body.AbsolutePosition
				local r=new("Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.55,Size=UDim2.new(0,0,0,0),
					Position=UDim2.new(0,io.Position.X-p.X,0,io.Position.Y-p.Y),AnchorPoint=Vector2.new(0.5,0.5),
					ZIndex=10,BorderSizePixel=0,Parent=body},{corner(80)})
				local big=math.max(w,h)*2.4
				tw(r,0.55,{Size=UDim2.new(0,big,0,big),BackgroundTransparency=1},Enum.EasingStyle.Quad):Play()
				task.delay(0.6,function() pcall(function() r:Destroy() end) end)
			end
		end)
		b.MouseButton1Click:Connect(function() sfx("click") cb() end) return b,l
	end

	local function shake() local p=win.Position for i=1,6 do
		win.Position=p+UDim2.new(0,(i%2==0 and 8 or -8),0,0) task.wait(0.04) end win.Position=p end

	function K:Close() K.closed=true if kBlur then kBlur=false blurOff() end for _,c in ipairs(K.conns) do pcall(function() c:Disconnect() end) end gui:Destroy() end
	local showExpiry
	local function success(key,info)
		sfx("open",0.4,1.1)
		setStatus(STR.stOk,Color3.fromRGB(98,242,194),"ok")
		if setup.RememberKey and o.keyMode~="always" then pcall(FishUI.KeyStore.save,key) else pcall(FishUI.KeyStore.clear) end
		showExpiry(key,info)
		task.wait(0.6)
		tw(win.UIScale,0.35,{Scale=0.9},Enum.EasingStyle.Back,Enum.EasingDirection.In):Play()
		task.delay(0.4,function() pcall(function() K:Close() end) end) if o.onSuccess then task.spawn(o.onSuccess,key,info) end
	end
	local verifying=false
	local refreshHot
	local fails,lockUntil=0,0
	-- validate(key) คืนได้: true | false | "expired" | "blocked" | "hwid" | "game" | "net"
	--   หรือ (false,"reason") | table {ok=bool, reason=str, info=any}   — error/throw = ถือเป็น "net" (ไม่นับเป็นคีย์ผิด)
	local function parseRes(r1,r2)
		if type(r1)=="table" then return r1.ok==true, r1.reason or (r1.ok and "ok" or "bad"), r1.info end
		if r1==true then return true,"ok",r2 end
		if type(r1)=="string" then return false,r1 end
		return false,(type(r2)=="string" and r2 or "bad")
	end
	local function verify(key)
		task.spawn(function()
			if verifying then return end
			key=(key or tb.Text):gsub("^%s+",""):gsub("%s+$","")
			if key=="" then setStatus(STR.stNeed,TH.warn,"warn") return end
			local left=math.ceil(lockUntil-os.clock())
			if left>0 then setStatus(string.format(STR.stLock,left),TH.warn,"warn") sfx("bad",0.4,0.55) return end
			verifying=true refreshHot() setStatus(STR.stCheck,TH.acc,"load")
			local t0=os.clock()
			local okc,r1,r2=pcall(validate,key)
			if os.clock()-t0<0.5 then task.wait(0.5-(os.clock()-t0)) end -- หน่วงขั้นต่ำให้ UI ไม่กระตุก
			verifying=false refreshHot()
			local ok,reason,info
			if okc then ok,reason,info=parseRes(r1,r2) else ok,reason=false,"net" end
			if ok then
				fails=0 sfx("ok",0.4,1.15) success(key,info)
				return
			end
			sfx("bad",0.4,0.55)
			local map={expired={STR.stExp,TH.warn,"warn"},blocked={STR.stBlocked,TH.bad,"bad"},hwid={STR.stHwid,TH.bad,"bad"},
				game={STR.stWrongGame,TH.warn,"warn"},net={STR.stNet,TH.warn,"warn"},
				tamper={STR.stTamper,TH.bad,"bad"},env={STR.stEnv,TH.bad,"bad"},rate={string.format(STR.stLock,60),TH.warn,"warn"}}
			local m=map[reason] or {STR.stBad,TH.bad,"bad"}
			if reason~="net" and reason~="env" and reason~="tamper" and reason~="rate" then -- เน็ตหลุดไม่นับ; คีย์ผิด/ถูกระงับนับ → ล็อกชั่วคราวกันเดา
				fails=fails+1
				if fails>=5 then lockUntil=os.clock()+30 fails=0 m={string.format(STR.stLock,30),TH.warn,"warn"} end
			end
			setStatus(m[1],m[2],m[3]) task.spawn(shake)
		end)
	end
	-- เวลาคงเหลือ: o.getExpiry(key,info) -> "3 วัน" / nil (เรียกหลังยืนยันสำเร็จ เพราะรู้คีย์แล้ว)
	function showExpiry(key,info)
		local d
		pcall(function() if o.getExpiry then d=o.getExpiry(key,info) end end)
		if d then expT.Text=string.format(STR.expiry,d) end
	end
	local half=(554-18)/2
	local btnGet=bigBtn(RX,322,half,STR.getKey,true,function()
		if setclipboard and o.getKey then pcall(setclipboard,o.getKey) setStatus(STR.copyLink,Color3.fromRGB(98,242,194))
		else setStatus(STR.noLink,TH.warn) end end,nil,"key")
	local btnVer=bigBtn(RX+half+18,322,half,STR.verify,true,function() verify() end,nil,"check")
	-- ความเด่นตามสถานะ: ยังไม่มีคีย์ → รับคีย์เด่น | พิมพ์แล้ว → ยืนยันเด่น
	local function hot(b,on)
		local body=b:FindFirstChild("Body") if not body then return end
		tw(body,0.2,{BackgroundColor3=on and TH.acc2 or TH.glass,BackgroundTransparency=on and 0.35 or 0.9}):Play()
	end
	local function dim(b,off)
		b.Active=not off local body=b:FindFirstChild("Body")
		if body then tw(body,0.2,{BackgroundTransparency=off and 0.96 or 0.35}):Play() end
	end
	if not o.getKey then dim(btnGet,true) end
	function refreshHot()
		local has=#tb.Text>0
		hot(btnVer,has) hot(btnGet,not has and o.getKey~=nil)
	end
	tb:GetPropertyChangedSignal("Text"):Connect(refreshHot)
	local panel
	function showPanel(title,lines)
		if panel then panel:Destroy() panel=nil end
		panel=card(main,RX,436,554,100,12) panel.ZIndex=20
		local psc=new("UIScale",{Parent=panel,Scale=0.8}) tw(psc,0.35,{Scale=1},Enum.EasingStyle.Back):Play()
		sfx("open",0.35,1.1)
		txt(panel,title,12,TH.ink,14,8,300,16,nil,true).ZIndex=21
		local y=30 for _,s in ipairs(lines) do local l=txt(panel,s,11,TH.sub,14,y,540,14) l.ZIndex=21 y=y+16 end
		local x=ctl(-8,"close",function() if panel then panel:Destroy() panel=nil end end) x.Parent=panel x.Position=UDim2.new(1,-8,0,8)
		x.Size=UDim2.new(0,22,0,22)
	end
	bigBtn(RX,380,half,STR.games,false,function()
		showPanel(STR.games,o.games or {"เกมทั้งหมดที่เพิ่มในฮับของเรา"}) end,nil,"gamepad")
	bigBtn(RX+half+18,380,half,STR.settings,false,function()
		showPanel("ตั้งค่า",{})
		local function row(y,text,key)
			local r=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-28,0,24),Position=UDim2.new(0,14,0,y),ZIndex=21,Parent=panel})
			local l=txt(r,text,12,TH.ink,0,0,400,24) l.ZIndex=22
			local cap,fill,knob,glow=capsule() cap.Position=UDim2.new(1,-40,0,1) cap.ZIndex=22 cap.Parent=r
			local function paint() tw(fill,0.16,{BackgroundTransparency=setup[key] and 0 or 1}):Play()
				tw(knob,0.16,{Position=setup[key] and UDim2.new(0,29,0.5,0) or UDim2.new(0,11,0.5,0)}):Play()
				tw(glow,0.16,{ImageTransparency=setup[key] and 0.5 or 1}):Play() end
			paint()
			local hit=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,1,0),ZIndex=30,Parent=r})
			hit.MouseButton1Click:Connect(function() sfx("click",0.25,1.2) setup[key]=not setup[key] paint() saveSetup() end)
		end
		row(32,"เปิดเสียงแจ้งเตือน","SoundEnabled")
		if o.keyMode~="always" then row(62,"จำคีย์อัตโนมัติ (ไม่ต้องใส่ซ้ำ)","RememberKey") end
	end,nil,"gear")

	-- การ์ดฟีเจอร์ (แทนบล็อก Premium)
	txt(main,STR.featTitle,13,TH.sub,RX,H0-118,300,16)
	local feats=o.features or {
		{"swords","ระบบต่อสู่อัตโนมัติ","ปัดป้อง หลบ และตั้งการ์ดให้เองตามจังหวะ"},
		{"gear","ปรับละเอียดทุกค่า","สไลเดอร์ความถี่ คีย์ลัด และโหมดเลือกเป้าหมาย"},
		{"save","จำค่าตั้งค่าเอง","บันทึกทุกสวิตช์อัตโนมัติ เปิดใหม่มาใช้ต่อได้ทันที"},
	}
	for i,f in ipairs(feats) do
		local fw=(554-16)/3
		local c=P(card(main,RX+(i-1)*(fw+8),H0-98,fw,84,12)) c.ZIndex=6
		local ic=new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.85,Size=UDim2.new(0,30,0,30),
			Position=UDim2.new(0,12,0,10),ZIndex=7,BorderSizePixel=0,Parent=c},{corner(15),stroke(TH.acc,0.4,1.5)})
		Icon[f[1]](ic,TH.acc)
		local t=txt(c,f[2],13,TH.ink,52,10,120,16,nil,true) t.ZIndex=7 t.TextTruncate=Enum.TextTruncate.AtEnd
		local d=txt(c,f[3],FT.xs,TH.sub,52,28,118,44) d.ZIndex=7 d.TextWrapped=true d.TextYAlignment=Enum.TextYAlignment.Top d.RichText=true
		local zi=c.ZIndex c.Parent=nil c.Parent=main
		c.MouseEnter:Connect(function() tw(c,0.15,{BackgroundTransparency=0.76}):Play() end)
		c.MouseLeave:Connect(function() tw(c,0.15,{BackgroundTransparency=0.84}):Play() end)
		local hit=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,1,0),ZIndex=9,Parent=c})
		hit.MouseButton1Click:Connect(function() sfx("click")
			if f.cb then f.cb() elseif showPanel then showPanel(STR.settings,{}) end end)
	end

	tb.FocusLost:Connect(function(ent) if ent then verify() end end)

	-- เปิดตัวแบบ pop
	win.UIScale.Scale=win.UIScale.Scale*0.92
	local target=win.UIScale.Scale/0.92
	tw(win.UIScale,0.4,{Scale=target},Enum.EasingStyle.Back):Play()

	-- เอฟเฟกต์เข้าฉาก: เด้งทีละชิ้น
	for i,el in ipairs(pops) do
		local sc=el:FindFirstChildOfClass("UIScale") or new("UIScale",{Parent=el})
		sc.Scale=0.55
		local p0=el.Position el.Position=UDim2.new(p0.X.Scale,p0.X.Offset,p0.Y.Scale,p0.Y.Offset+14)
		task.delay(0.045*i,function() if el.Parent then
			tw(el,0.55,{Position=p0},Enum.EasingStyle.Quint):Play()
			tw(sc,0.55,{Scale=1},Enum.EasingStyle.Back):Play() end end)
	end

	-- โหลดคีย์ที่เคยบันทึกไว้ — keyMode: "always"=ถามทุกครั้ง | "fill"=เติมให้รอกด | "auto"=ตรวจให้เลย
	task.defer(function()
		if o.keyMode=="always" then return end
		local ok,saved=pcall(FishUI.KeyStore.load)
		if ok and saved and saved~="" and setup.RememberKey then
			tb.Text=saved
			if o.keyMode=="auto" then
				setStatus("กำลังตรวจคีย์ที่จำไว้อัตโนมัติ...",TH.sub,"load")
				task.delay(0.6,function() if not K.closed then verify(saved) end end)
			else setStatus(STR.stFilled,TH.sub) end
		end
	end)
	return K
end
	return {}
end
]=])
	_m["pages/games"]=loadstring([[
-- ============================================================
-- FishUI/pages/games.lua — หน้าเกมที่รองรับ (ค้นหา/สถานะ/ไฮไลต์แมพปัจจุบัน)
-- ใส่ลง D : D.Pages.games (ฟังก์ชันสร้างหน้า)
-- อ่านจาก D: TH, IMG, STR, FT, F_TXT/F_B, new, corner, stroke, tw,
--            pad, vlist, label, Icon, LP, FishUI
-- ============================================================
return function(D)
	local TH,IMG,STR,FT=D.TH,D.IMG,D.STR,D.FT
	local LP=game:GetService("Players").LocalPlayer
	local new,corner,stroke,tw,pad,vlist,label=D.new,D.corner,D.stroke,D.tw,D.pad,D.vlist,D.label
	local Icon=D.Icon
	D.Pages=D.Pages or {}
	local function statCol(st)
		return st=="play" and Color3.fromRGB(98,242,194) or st=="update" and TH.warn or TH.bad
	end
	local function statTxt(st)
		return st=="play" and STR.gsPlay or st=="update" and STR.gsUpdate or STR.gsDead
	end
	function D.Pages.games(win,o)
			local pg=win:Page(STR.pgGames)
			local sb=pg:Sub("ทั้งหมด")
			local list=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
				LayoutOrder=2,ZIndex=5,Parent=sb.scroller},{vlist(8)})
			-- ช่องค้นหาของตัวเอง
			local sf=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,40),LayoutOrder=0,Parent=list})
			local sfw=new("Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.55,Size=UDim2.new(1,0,1,0),
				ZIndex=2,BorderSizePixel=0,Parent=sf},{corner(10),stroke(TH.lav,0.7)})
			local sib=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,10,0.5,0),
				AnchorPoint=Vector2.new(0,0.5),ZIndex=3,Parent=sfw}) Icon.search(sib,TH.mute)
			local stb=new("TextBox",{BackgroundTransparency=1,Text="",PlaceholderText=STR.gsSearch,PlaceholderColor3=TH.mute,
				TextColor3=TH.ink,TextSize=13,FontFace=D.F_TXT,Size=UDim2.new(1,-48,1,0),Position=UDim2.new(0,40,0,0),
				TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3,ClearTextOnFocus=false,Parent=sfw})

			local rows={}
			local data=o.games or {}
			local function build()
				for _,r in ipairs(rows) do r.card:Destroy() end rows={}
				local q=stb.Text:lower()
				local shown=0
				for i,g in ipairs(data) do
					if q=="" or (g.name or ""):lower():find(q,1,true) then
						shown=shown+1
						local cur=g.placeId==game.PlaceId
						local c=new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=cur and 0.82 or 0.9,
							Size=UDim2.new(1,0,0,54),ZIndex=2,BorderSizePixel=0,Parent=list,LayoutOrder=i},{
							corner(12),stroke(cur and TH.acc or TH.lav,cur and 0.3 or 0.75,cur and 1.5 or 1),
							new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.5)}})})
						local ic=new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.85,Size=UDim2.new(0,34,0,34),
							Position=UDim2.new(0,10,0.5,0),AnchorPoint=Vector2.new(0,0.5),ZIndex=3,BorderSizePixel=0,Parent=c},
							{corner(17),stroke(cur and TH.acc or TH.lav,0.5),ClipsDescendants=true})
						local gimg=new("ImageLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=4,Image="",Parent=ic},
							{new("UICorner",{CornerRadius=UDim.new(0.5,0)})})
						task.spawn(function() local ok,info=pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(g.placeId or game.PlaceId) end)
							if ok and info and info.IconImageAssetId and info.IconImageAssetId>0 then gimg.Image="rbxassetid://"..info.IconImageAssetId
							else Icon.gamepad(ic,cur and TH.acc or TH.sub) end end)
						local nm=label(g.name or "ไม่ทราบชื่อ",13,cur and TH.acc or TH.ink,c) nm.Position=UDim2.new(0,54,0,10) nm.Size=UDim2.new(1,-160,0,18) nm.TextXAlignment=Enum.TextXAlignment.Left nm.ZIndex=3
						local sub=label((cur and STR.gsHere.." · " or "")..(g.note or statTxt(g.status or "play")),11,TH.mute,c)
						sub.Position=UDim2.new(0,54,0,28) sub.Size=UDim2.new(1,-160,0,14) sub.TextXAlignment=Enum.TextXAlignment.Left sub.ZIndex=3
						-- badge สถานะ
						local bd=new("Frame",{BackgroundColor3=statCol(g.status or "play"),BackgroundTransparency=0.85,
							Size=UDim2.new(0,0,0,24),Position=UDim2.new(1,-12,0.5,0),AnchorPoint=Vector2.new(1,0.5),
							AutomaticSize=Enum.AutomaticSize.X,ZIndex=3,BorderSizePixel=0,Parent=c},{corner(12),stroke(statCol(g.status or "play"),0.4),pad(0,10,0,10)})
						local bt=label(statTxt(g.status or "play"),11,statCol(g.status or "play"),bd) bt.Size=UDim2.new(0,0,1,0) bt.AutomaticSize=Enum.AutomaticSize.X bt.ZIndex=4
						rows[#rows+1]={card=c}
						c.MouseEnter:Connect(function() tw(c,0.15,{BackgroundTransparency=cur and 0.75 or 0.84}):Play() end)
						c.MouseLeave:Connect(function() tw(c,0.15,{BackgroundTransparency=cur and 0.82 or 0.9}):Play() end)
					end
				end
				if shown==0 then
					local e=label(STR.gsEmpty,13,TH.mute,list) e.Size=UDim2.new(1,0,0,40) e.LayoutOrder=1
					rows[#rows+1]={card=e}
				end
			end
			stb:GetPropertyChangedSignal("Text"):Connect(build)
			build()
	end
	return {}
end
]])
	_m["pages/announce"]=loadstring([[
-- ============================================================
-- FishUI/pages/announce.lua — หน้าประกาศ + changelog
-- ใส่ลง D : D.Pages.announce (ฟังก์ชันสร้างหน้า)
-- อ่านจาก D: TH, IMG, STR, FT, F_TXT/F_B, new, corner, stroke, tw,
--            pad, vlist, label, Icon, LP, FishUI
-- ============================================================
return function(D)
	local TH,IMG,STR,FT=D.TH,D.IMG,D.STR,D.FT
	local LP=game:GetService("Players").LocalPlayer
	local new,corner,stroke,tw,pad,vlist,label=D.new,D.corner,D.stroke,D.tw,D.pad,D.vlist,D.label
	local Icon=D.Icon
	D.Pages=D.Pages or {}
	local function mkcard(par,h)
		local c=new("Frame",{BackgroundColor3=TH.glass,BackgroundTransparency=0.9,AutomaticSize=Enum.AutomaticSize.Y,
			Size=UDim2.new(1,0,0,h or 0),ZIndex=2,BorderSizePixel=0,Parent=par},{corner(12),stroke(TH.lav,0.7),
			new("UIGradient",{Rotation=90,Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.5)}})})
		return c
	end
	function D.Pages.announce(win,o)
			local pg=win:Page(STR.pgNews)
			local sb=pg:Sub(STR.pgNews)
			local list=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
				LayoutOrder=2,ZIndex=5,Parent=sb.scroller},{vlist(8)})
			local ann=nil
			pcall(function() if o.getAnnouncements then ann=o.getAnnouncements() end end)
			ann=ann or {{tag="ประกาศ",title="ยินดีต้อนรับ",date="วันนี้",body="ระบบประกาศพร้อมใช้งาน — แอดมินแก้ได้โดยไม่ต้องอัปเดตสคริปต์ (o.getAnnouncements)"}}
			local tagCol={["ประกาศ"]=TH.acc,["ซ่อมบำรุง"]=TH.warn,["อัปเดต"]=Color3.fromRGB(98,242,194)}
			for i,a in ipairs(ann) do
				local c=mkcard(list,0) c.LayoutOrder=i
				local inner=new("Frame",{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,-24,0,0),
					Position=UDim2.new(0,12,0,10),ZIndex=3,Parent=c},{vlist(6)})
				local hd=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),Parent=inner})
				local tg=new("Frame",{BackgroundColor3=tagCol[a.tag or "ประกาศ"] or TH.acc,BackgroundTransparency=0.8,
					Size=UDim2.new(0,0,0,20),AutomaticSize=Enum.AutomaticSize.X,ZIndex=3,BorderSizePixel=0,Parent=hd},
					{corner(10),stroke(tagCol[a.tag or "ประกาศ"] or TH.acc,0.4),pad(0,8,0,8)})
				label(a.tag or "ประกาศ",11,tagCol[a.tag or "ประกาศ"] or TH.acc,tg).Size=UDim2.new(0,0,1,0)
				local tt=label(a.title or "",14,TH.ink,hd) tt.Position=UDim2.new(0,(a.tag and (#a.tag*8+18) or 10)+56,0,0) tt.Size=UDim2.new(1,-120,0,20) tt.TextXAlignment=Enum.TextXAlignment.Left
				local dt=label(a.date or "",11,TH.mute,hd) dt.Position=UDim2.new(1,0,0,0) dt.AnchorPoint=Vector2.new(1,0) dt.TextXAlignment=Enum.TextXAlignment.Right dt.AutomaticSize=Enum.AutomaticSize.X
				local bd=label(a.body or "",12,TH.sub,inner) bd.Size=UDim2.new(1,0,0,0) bd.AutomaticSize=Enum.AutomaticSize.Y bd.TextWrapped=true bd.TextXAlignment=Enum.TextXAlignment.Left bd.RichText=true
				new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,4),Parent=inner})
			end
			-- changelog
			local cl=mkcard(list,0) cl.LayoutOrder=99
			local inner=new("Frame",{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,-24,0,0),
				Position=UDim2.new(0,12,0,10),ZIndex=3,Parent=cl},{vlist(6)})
			label(STR.changelog,13,TH.ink,inner).TextXAlignment=Enum.TextXAlignment.Left
			for _,v in ipairs(o.changelog or {{"v1.0","เปิดตัวครั้งแรก"}}) do
				local r=label("<b>"..v[1].."</b>  "..v[2],12,TH.sub,inner) r.Size=UDim2.new(1,0,0,0) r.AutomaticSize=Enum.AutomaticSize.Y r.TextWrapped=true r.TextXAlignment=Enum.TextXAlignment.Left r.RichText=true
			end
			new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,4),Parent=inner})
	end
	return {}
end
]])
	_m["pages/support"]=loadstring([[
-- ============================================================
-- FishUI/pages/support.lua — หน้าซัพพอร์ต (ลิงก์/คู่มือ/คัดลอกข้อมูลเครื่อง)
-- ใส่ลง D : D.Pages.support (ฟังก์ชันสร้างหน้า)
-- อ่านจาก D: TH, IMG, STR, FT, F_TXT/F_B, new, corner, stroke, tw,
--            pad, vlist, label, Icon, LP, FishUI
-- ============================================================
return function(D)
	local TH,IMG,STR,FT=D.TH,D.IMG,D.STR,D.FT
	local LP=game:GetService("Players").LocalPlayer
	local new,corner,stroke,tw,pad,vlist,label=D.new,D.corner,D.stroke,D.tw,D.pad,D.vlist,D.label
	local Icon=D.Icon
	D.Pages=D.Pages or {}
	local gname="—" pcall(function() gname=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
	function D.Pages.support(win,o)
			local pg=win:Page(STR.pgSupport)
			local sb=pg:Sub(STR.pgSupport)
			local g1=sb:Groupbox("ช่องทางติดต่อ","Left")
			local function copyLink(link,what)
				if link and link~="" and setclipboard then pcall(setclipboard,link) win:Notify{title=STR.toastCopy,text=what,dur=3}
				else win:Notify{title=STR.supNoLink,text=what,dur=3} end
			end
			g1:Button{label=STR.supDiscord,cb=function() copyLink(o.discord,"Discord") end}
			g1:Button{label=STR.supLine,cb=function() copyLink(o.line,"LINE") end}
			local g2=sb:Groupbox("ช่วยเหลือ","Right")
			for i,st2 in ipairs(o.guideSteps or STR.guideSteps) do g2:Label(st2) end
			g2:Divider()
			g2:Button{label=STR.supDiag,cb=function()
				local hw="—" pcall(function() hw=(gethwid and gethwid()) or "—" end)
				local exe=pcall(identifyexecutor) and identifyexecutor() or "ไม่ทราบ"
				local diag=string.format("[%s %s] ผู้เล่น: %s (@%s) | เครื่อง: %s | เกม: %s (%d) | ตัวรัน: %s | ปิง: %s",
					o.brand or "HZ HUB",o.version or "v1.0",LP.DisplayName,LP.Name,hw,gname,game.PlaceId,exe,
					tostring(math.floor((pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end) and game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) or 0)))
				if setclipboard then pcall(setclipboard,diag) end
				win:Notify{title=STR.toastOk,text=STR.supDiagDone,dur=3}
			end}
	end
	return {}
end
]])
	_m["pages/settings"]=loadstring([[
-- ============================================================
-- FishUI/pages/settings.lua — หน้าตั้งค่าฮับ (ความทึบ/ธีม/keybind/โปรไฟล์/ระบบ)
-- ใส่ลง D : D.Pages.settings (ฟังก์ชันสร้างหน้า)
-- อ่านจาก D: TH, IMG, STR, FT, F_TXT/F_B, new, corner, stroke, tw,
--            pad, vlist, label, Icon, LP, FishUI
-- ============================================================
return function(D)
	local TH,IMG,STR,FT=D.TH,D.IMG,D.STR,D.FT
	local LP=game:GetService("Players").LocalPlayer
	local new,corner,stroke,tw,pad,vlist,label=D.new,D.corner,D.stroke,D.tw,D.pad,D.vlist,D.label
	local Icon=D.Icon
	D.Pages=D.Pages or {}
	local HttpS=game:GetService("HttpService")
	function D.Pages.settings(win,o)
			local pg=win:Page(STR.pgSettings)
			local sb=pg:Sub(STR.pgSettings)
			local ui=sb:Groupbox("หน้าตา","Left")
			ui:Slider{label=STR.setOpacity,min=0,max=40,default=(win.saved and win.saved.Opacity) or 25,suffix="%",cb=function(v)
				if win.SetOpacity then win:SetOpacity(v) end
			end}
			ui:Label(STR.setTheme..":")
			ui:Buttons{{label="Amethyst",cb=function() win:SetTheme(1) end},{label="Ocean",cb=function() win:SetTheme(2) end},
				{label="Rose",cb=function() win:SetTheme(3) end},{label="Mint",cb=function() win:SetTheme(4) end}}
			ui:Keybind{label="ซ่อน/แสดงเมนู",key=win.toggleKey or Enum.KeyCode.RightShift,onChange=function(kc) win:SetToggleKey(kc) end}
			ui:Button{label="แผงคีย์ลัด (RightAlt)",cb=function() win:ToggleKeybinds() end}

			local pf=sb:Groupbox(STR.setProf,"Right")
			local nameBox=pf:Input{label=STR.profName,placeholder=STR.profName}
			local profOpts={"—"}
			local sel=pf:Dropdown{label="เลือกโปรไฟล์",options=profOpts}
			local function profPath(n) return "FishUI/profiles/"..n..".json" end
			local function refreshList()
				for i=#profOpts,1,-1 do profOpts[i]=nil end profOpts[1]="—" local names=profOpts pcall(function()
					if listfiles then for _,f in ipairs(listfiles("FishUI/profiles")) do
						local n=f:match("([^/\\]+)%.json$") if n then names[#names+1]=n end end end end)
				
			end
			refreshList()
			local function cleanName(n) return (tostring(n or ""):gsub("[%/%\\:%*%?\"<>|%.]+",""):gsub("^%s+",""):gsub("%s+$","")) end
			pf:Buttons{{label=STR.profSave,cb=function()
					local n=cleanName(nameBox.get()) if n=="" then win:Notify{title=STR.toastErr,text="ใส่ชื่อโปรไฟล์ก่อน",dur=3} return end
					local data={} for k,el in pairs(win.flags or {}) do local ok,v=pcall(el.get) if ok and v~=nil then data[k]=v end end
					local ok=pcall(function() if makefolder and not isfolder("FishUI/profiles") then makefolder("FishUI/profiles") end
						writefile(profPath(n),HttpS:JSONEncode(data)) end)
					refreshList() win:Notify{title=ok and STR.toastOk or STR.toastErr,text=ok and ("บันทึกโปรไฟล์ "..n) or "บันทึกโปรไฟล์ไม่ได้",dur=3} end},
				{label=STR.profLoad,cb=function()
					local n=sel.get and sel.get() if not n or n=="—" then return end
					local cnt
					local ok=pcall(function() local t=HttpS:JSONDecode(readfile(profPath(n))) cnt=win:ApplyFlags(t) end)
					win:Notify{title=ok and STR.toastOk or STR.toastErr,text=ok and ("ใช้โปรไฟล์ "..n.." แล้ว ("..tostring(cnt).." ค่า)") or "อ่านโปรไฟล์ไม่ได้",dur=3} end},
				{label=STR.profDel,cb=function()
					local n=sel.get and sel.get() if not n or n=="—" then return end
					pcall(function() if delfile then delfile(profPath(n)) end end) refreshList()
					win:Notify{title=STR.toastOk,text="ลบโปรไฟล์ "..n,dur=3} end}}
			local sys=sb:Groupbox("ระบบ","Right")
			sys:Button{label="ล็อกเอาท์ (กลับไปใส่คีย์)",danger=true,cb=function() win:Logout() end}
			sys:Button{label="ปิดเมนู",danger=true,cb=function() win:Destroy() end}
	end
	return {}
end
]])

local function load(name)
	local f=_m[name]
	if f then return f() end
	local ok,m = pcall(function() return loadstring(readfile("FishUI/"..name..".lua"))() end)
	if not ok or type(m)~="function" then error("HZ HUB: โหลดโมดูลไม่ได้ — FishUI/"..name..".lua") end
	return m
end
local function use(name)
	local t=load(name)(D)
	for k,v in pairs(t or {}) do D[k]=v end
end
use("tokens") use("icons") use("core") use("fx") use("nav") use("widgets") use("window") use("sidebar") use("keyscreen") use("pages/games") use("pages/announce") use("pages/support") use("pages/settings")
local STR=D.STR local FT=D.FT local TH=D.TH local IMG=D.IMG
local F_TXT=D.F_TXT local F_MONO=D.F_MONO local F_B=D.F_B
local new=D.new local c3=D.c3 local corner=D.corner local stroke=D.stroke local tw=D.tw
local pad=D.pad local hlist=D.hlist local vlist=D.vlist local label=D.label
local lipEdge=D.lipEdge local chevron=D.chevron local darkwell=D.darkwell local accgrad=D.accgrad
local sheenTop=D.sheenTop local glowImg=D.glowImg local glassBody=D.glassBody local shadowImg=D.shadowImg
local draggable=D.draggable local sfx=D.sfx
local Icon=D.Icon
local blurOn,blurOff,windowFX=D.blurOn,D.blurOff,D.windowFX
local capsule,keycap,pillBtn=D.capsule,D.keycap,D.pillBtn
FishUI.Theme=D.TH FishUI.Img=D.IMG FishUI.SetFont=D.SetFont FishUI._sndHost=D._sndHost

-- ============================================================
--  KEY SCREEN (หน้าใส่คีย์ — โคลนหน้า Welcome ของ Fishy, ข้อความไทยล้วน)
--  FishUI.KeyScreen{ brand="ชื่อแบรนด์", hub="ชื่อฮับ", version="v1.0",
--     validate=function(key) return key=="123" end, getKey="https://...",
--     games={"เกม 1","เกม 2"}, onSuccess=function(key) end }
-- ============================================================
-- ============================================================
--  SETUP (วิซาร์ดตั้งค่าครั้งแรก: ธีม / เสียง / เคอร์เซอร์) — บันทึกที่ FishUI/setup.json
--  FishUI.Setup{ onDone=function(setup) end }   ข้ามเองถ้าเคยตั้งค่าแล้ว (Done=true)
-- ============================================================
function FishUI.Setup(o)
	o=o or {}
	local HttpS=game:GetService("HttpService")
	local setup={SoundEnabled=true,SoundVolume=0.6,Cursor="Default",Theme=1,SkipTheme=false,Done=false}
	D.sndOn=(setup.SoundEnabled~=false)
	pcall(function() for k,v in pairs(HttpS:JSONDecode(readfile("FishUI/setup.json"))) do setup[k]=v end end)
	if setup.Done and not o.force then if o.onDone then task.spawn(o.onDone,setup) end return end
	local function save() pcall(function() if makefolder and not isfolder("FishUI") then makefolder("FishUI") end
		writefile("FishUI/setup.json",HttpS:JSONEncode(setup)) end) end

	local gui=new("ScreenGui",{Name="FishSetup",ResetOnSpawn=false,DisplayOrder=80,IgnoreGuiInset=true,
		ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
	pcall(function() gui.Parent=game:GetService("CoreGui") end)
	if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end
	FishUI._sndHost(gui)
	local W0,H0=540,420
	local win=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,W0,0,H0),Position=UDim2.new(0.5,0,0.5,0),
		AnchorPoint=Vector2.new(0.5,0.5),Parent=gui},{new("UIScale"),shadowImg(0,0.55)})
	local main=glassBody(1,16) main.Parent=win
	local sBlur=true blurOn() windowFX(win,main)
	draggable(new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,70),ZIndex=4,Parent=main}),win)
	local function T(par,t,sz,col,x,y,w,h,al,b) return new("TextLabel",{BackgroundTransparency=1,Text=t,TextColor3=col or TH.ink,
		TextSize=sz,FontFace=b and D.F_B or D.F_TXT,Position=UDim2.new(0,x,0,y),Size=UDim2.new(0,w,0,h or sz+4),
		TextXAlignment=al or Enum.TextXAlignment.Left,ZIndex=6,Parent=par}) end
	T(main,"ตั้งค่าเริ่มต้น",20,TH.ink,0,18,W0,26,Enum.TextXAlignment.Center,true)
	local stepL=T(main,"",10,TH.mute,0,46,W0,12,Enum.TextXAlignment.Center)
	local area=new("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,28,0,84),Size=UDim2.new(1,-56,1,-150),ZIndex=5,Parent=main})
	local step=1
	local STEPS={"ธีม","เสียง","เคอร์เซอร์"}
	local function glassCard(par,x,y,w,h,sel)
		local c=new("TextButton",{BackgroundColor3=TH.glass,BackgroundTransparency=sel and 0.78 or 0.92,Text="",
			Position=UDim2.new(0,x,0,y),Size=UDim2.new(0,w,0,h),ZIndex=6,BorderSizePixel=0,AutoButtonColor=false,Parent=par},{
			corner(12),new("UIStroke",{Color=sel and TH.acc or TH.lav,Transparency=sel and 0.2 or 0.7,Thickness=1})})
		return c
	end
	local themeCols={{205,145,255,"อเมทิสต์"},{124,208,255,"มหาสมุทร"},{255,142,194,"กุหลาบ"},{98,242,194,"มิ้นต์"}}
	local render,nextB
	function render()
		for _,c in ipairs(area:GetChildren()) do c:Destroy() end
		stepL.Text="ขั้นที่ "..step.." จาก "..#STEPS.."  ·  "..STEPS[step]
		if step==1 then
			T(area,"เลือกธีมสีของเมนู",12,TH.sub,0,0,400,16)
			for i,tc in ipairs(themeCols) do
				local col=Color3.fromRGB(tc[1],tc[2],tc[3])
				local c=glassCard(area,((i-1)%2)*226,28+math.floor((i-1)/2)*84,214,72,setup.Theme==i)
				new("Frame",{BackgroundColor3=col,Size=UDim2.new(0,34,0,34),Position=UDim2.new(0,16,0.5,0),AnchorPoint=Vector2.new(0,0.5),
					ZIndex=7,BorderSizePixel=0,Parent=c},{corner(17),stroke(TH.lav,0.5)})
				T(c,tc[4],14,TH.ink,64,0,140,72,nil,true).ZIndex=7
				c.MouseButton1Click:Connect(function() sfx("click") setup.Theme=i render() end)
			end
		elseif step==2 then
			T(area,"เสียงแจ้งเตือนของเมนู",12,TH.sub,0,0,400,16)
			local c=glassCard(area,0,28,440,60,setup.SoundEnabled)
			T(c,setup.SoundEnabled and "เสียง: เปิด" or "เสียง: ปิด",14,TH.ink,18,0,300,60,nil,true).ZIndex=7
			c.MouseButton1Click:Connect(function() setup.SoundEnabled=not setup.SoundEnabled D.sndOn=setup.SoundEnabled sfx("ok",0.5) render() end)
			T(area,"ระดับเสียง  "..math.floor(setup.SoundVolume*100).."%",12,TH.sub,0,104,300,16)
			local tube=darkwell(6,8,4) tube.Position=UDim2.new(0,0,0,130) tube.Size=UDim2.new(0,440,0,8) tube.Parent=area
			local fill=new("Frame",{BackgroundColor3=Color3.new(1,1,1),Size=UDim2.new(setup.SoundVolume,0,1,0),ZIndex=7,BorderSizePixel=0,Parent=tube},
				{corner(4),accgrad(0)})
			local hit=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,-10),ZIndex=9,Parent=tube})
			local function set(x) setup.SoundVolume=math.clamp((x-tube.AbsolutePosition.X)/tube.AbsoluteSize.X,0,1)
				D.sndVol=setup.SoundVolume
				fill.Size=UDim2.new(setup.SoundVolume,0,1,0) end
			local drag=false
			hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true set(i.Position.X) end end)
			hit.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then set(i.Position.X) end end)
			hit.InputEnded:Connect(function() if drag then drag=false render() end end)
		else
			T(area,"รูปแบบเคอร์เซอร์เมาส์",12,TH.sub,0,0,400,16)
			for i,nm in ipairs({{"Default","เคอร์เซอร์ปกติของ Roblox"},{"Custom","เคอร์เซอร์เรืองแสงของเมนู"}}) do
				local c=glassCard(area,0,28+(i-1)*72,440,60,setup.Cursor==nm[1])
				T(c,nm[2],14,TH.ink,18,0,380,60,nil,true).ZIndex=7
				c.MouseButton1Click:Connect(function() sfx("click") setup.Cursor=nm[1] render() end)
			end
		end
		nextB.Text=step==#STEPS and "เสร็จสิ้น" or "ถัดไป"
	end
	local function foot(x,w,txt,accent,cb)
		local b=new("TextButton",{BackgroundColor3=accent and TH.acc2 or TH.glass,BackgroundTransparency=accent and 0.35 or 0.9,Text=txt,
			TextColor3=TH.ink,TextSize=13,FontFace=D.F_B,Position=UDim2.new(0,x,1,-58),Size=UDim2.new(0,w,0,38),ZIndex=8,
			BorderSizePixel=0,AutoButtonColor=false,Parent=main},{corner(10),stroke(accent and TH.acc or TH.lav,accent and 0.2 or 0.6)})
		b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundTransparency=accent and 0.2 or 0.82}):Play() end)
		b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundTransparency=accent and 0.35 or 0.9}):Play() end)
		b.MouseButton1Click:Connect(function() sfx("click") cb() end) return b
	end
	local function finish()
		setup.Done=true save()
		tw(win.UIScale,0.3,{Scale=0.9},Enum.EasingStyle.Back,Enum.EasingDirection.In):Play()
		task.delay(0.35,function() if sBlur then sBlur=false blurOff() end pcall(function() gui:Destroy() end) end) if o.onDone then task.spawn(o.onDone,setup) end
	end
	foot(28,150,"ข้ามทั้งหมด",false,finish)
	nextB=foot(W0-28-150,150,"ถัดไป",true,function()
		if step<#STEPS then step=step+1 render() else finish() end end)
	render()
	win.UIScale.Scale=0.92 tw(win.UIScale,0.4,{Scale=1},Enum.EasingStyle.Back):Play()
end


-- ============================================================
--  STANDARD PAGES — หน้ามาตรฐานของฮับ (เกมที่รองรับ/ประกาศ/ซัพพอร์ต/ตั้งค่าฮับ)
--  FishUI.StandardPages(win,{
--    games={{name="ชื่อ",placeId=123,status="play"|"update"|"dead"},...},
--    getAnnouncements=function() return {{tag="ประกาศ",title="..",date="..",body=".."}} end,
--    changelog={{"v1.0","ข้อความ"},...},
--    discord="ลิงก์", line="ลิงก์",
--  })
-- ============================================================
function FishUI.StandardPages(win,o)
	o=o or {}
	if D.Pages then
		for _,n in ipairs({"games","announce","support","settings"}) do
			if D.Pages[n] then D.Pages[n](win,o) end
		end
	end
end

return FishUI
]==], "FishUI")
local G = {}
_b([[
-- ============================================================
-- Guard/crypto.lua — SHA-256 / HMAC-SHA256 / stream cipher (CTR จาก SHA-256) / base64 / hex
-- ล้วน Luau (bit32 + string.pack) — ไม่พึ่ง API ของ executor ตัวไหน ใช้ได้ทั้งในเกมและในเทสด้วย luau.exe
-- ต้องตรงกับ tools/hzcrypto.py (ฝั่ง Python) ทุก byte — มีเทสเวกเตอร์ข้ามภาษาใน tools/test/test_guard_crypto.lua
-- ใส่ลง G : G.Crypto
-- ============================================================
return function(G)
	local bxor,band,bnot,rrot,rshift,lshift,bor = bit32.bxor,bit32.band,bit32.bnot,bit32.rrotate,bit32.rshift,bit32.lshift,bit32.bor
	local spack,sunpack,schar,sbyte,srep,ssub = string.pack,string.unpack,string.char,string.byte,string.rep,string.sub
	local concat = table.concat
	local C = {}

	local K = {
		0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
		0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
		0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
		0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
		0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
		0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
		0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
		0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
	}

	-- คืน raw 32 bytes
	function C.sha256(msg)
		local len = #msg
		msg = msg .. "\128" .. srep("\0", (55 - len) % 64) .. spack(">I8", len * 8)
		local h0,h1,h2,h3,h4,h5,h6,h7 = 0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19
		local w = table.create and table.create(64, 0) or {}
		for pos = 1, #msg, 64 do
			w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],w[10],w[11],w[12],w[13],w[14],w[15],w[16] = sunpack(">I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4", msg, pos)
			for i = 17, 64 do
				local a,b = w[i-15], w[i-2]
				local s0 = bxor(rrot(a,7), rrot(a,18), rshift(a,3))
				local s1 = bxor(rrot(b,17), rrot(b,19), rshift(b,10))
				w[i] = (w[i-16] + s0 + w[i-7] + s1) % 4294967296
			end
			local a,b,c,d,e,f,g,h = h0,h1,h2,h3,h4,h5,h6,h7
			for i = 1, 64 do
				local S1 = bxor(rrot(e,6), rrot(e,11), rrot(e,25))
				local ch = bxor(band(e,f), band(bnot(e),g))
				local t1 = (h + S1 + ch + K[i] + w[i]) % 4294967296
				local S0 = bxor(rrot(a,2), rrot(a,13), rrot(a,22))
				local maj = bxor(band(a,b), band(a,c), band(b,c))
				local t2 = (S0 + maj) % 4294967296
				h = g g = f f = e e = (d + t1) % 4294967296
				d = c c = b b = a a = (t1 + t2) % 4294967296
			end
			h0 = (h0 + a) % 4294967296 h1 = (h1 + b) % 4294967296 h2 = (h2 + c) % 4294967296 h3 = (h3 + d) % 4294967296
			h4 = (h4 + e) % 4294967296 h5 = (h5 + f) % 4294967296 h6 = (h6 + g) % 4294967296 h7 = (h7 + h) % 4294967296
		end
		return spack(">I4I4I4I4I4I4I4I4", h0,h1,h2,h3,h4,h5,h6,h7)
	end

	function C.hex(s)
		return (s:gsub(".", function(c) return string.format("%02x", sbyte(c)) end))
	end
	function C.unhex(h)
		if #h % 2 ~= 0 or h:find("[^%x]") then return nil end
		return (h:gsub("%x%x", function(x) return schar(tonumber(x, 16)) end))
	end
	function C.sha256hex(msg) return C.hex(C.sha256(msg)) end

	function C.hmac(key, msg)
		if #key > 64 then key = C.sha256(key) end
		key = key .. srep("\0", 64 - #key)
		local ip, op = {}, {}
		for i = 1, 64 do
			local k = sbyte(key, i)
			ip[i] = schar(bxor(k, 0x36)) op[i] = schar(bxor(k, 0x5c))
		end
		return C.sha256(concat(op) .. C.sha256(concat(ip) .. msg))
	end

	function C.xor(a, b) -- ยาวเท่ากัน
		local out, n = {}, #a
		for i = 1, n, 4096 do
			local j = math.min(i + 4095, n)
			local ba = {sbyte(a, i, j)}
			local bb = {sbyte(b, i, j)}
			for k = 1, #ba do ba[k] = bxor(ba[k], bb[k]) end
			out[#out + 1] = schar(table.unpack(ba))
		end
		return concat(out)
	end

	-- ความยาว n bytes จาก SHA256(key||nonce||ctr) ต่อกัน
	function C.keystream(ek, nonce, n)
		local parts, got, i = {}, 0, 0
		while got < n do
			parts[#parts + 1] = C.sha256(ek .. nonce .. spack(">I4", i))
			got = got + 32 i = i + 1
		end
		return ssub(concat(parts), 1, n)
	end
	function C.crypt(ek, nonce, data) return C.xor(data, C.keystream(ek, nonce, #data)) end

	function C.ctEqual(a, b)
		if #a ~= #b then return false end
		local d = 0
		for i = 1, #a do d = bor(d, bxor(sbyte(a, i), sbyte(b, i))) end
		return d == 0
	end

	-- base64
	local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local enc, dec = {}, {}
	for i = 1, 64 do local c = ssub(B64, i, i) enc[i - 1] = c dec[sbyte(c)] = i - 1 end
	function C.b64encode(s)
		local out = {}
		for i = 1, #s, 3 do
			local a, b, c = sbyte(s, i, i + 2)
			local n = a * 65536 + (b or 0) * 256 + (c or 0)
			out[#out + 1] = enc[rshift(n, 18)] .. enc[band(rshift(n, 12), 63)] .. (b and enc[band(rshift(n, 6), 63)] or "=") .. (c and enc[band(n, 63)] or "=")
		end
		return concat(out)
	end
	function C.b64decode(s)
		s = s:gsub("[%s\r\n]", "")
		if #s % 4 ~= 0 or s:find("[^%w%+/=]") then return nil end
		local out = {}
		for i = 1, #s, 4 do
			local a, b, c, d = sbyte(s, i, i + 3)
			local pad = (c == 61 and 2) or (d == 61 and 1) or 0
			local va, vb, vc, vd = dec[a], dec[b], dec[c] or 0, dec[d] or 0
			if not va or not vb then return nil end
			local n = va * 262144 + vb * 4096 + vc * 64 + vd
			local chunk = schar(rshift(n, 16), band(rshift(n, 8), 255), band(n, 255))
			out[#out + 1] = pad == 0 and chunk or ssub(chunk, 1, 3 - pad)
		end
		return concat(out)
	end

	-- สุ่ม n bytes: ใช้ crypt.generatebytes ของ executor ถ้ามี ไม่งั้นผสมหลายแหล่ง
	local counter = 0
	function C.random(n)
		local out = ""
		local ok, r = pcall(function()
			local cr = getgenv and getgenv().crypt
			if cr and cr.generatebytes then return C.b64decode(cr.generatebytes(n)) end
		end)
		if ok and type(r) == "string" and #r == n then return r end
		while #out < n do
			counter = counter + 1
			local seed = tostring(os.clock()) .. tostring(os.time()) .. tostring(counter) .. tostring({}) .. tostring(math.random(0, 2147483647))
			pcall(function() seed = seed .. game:GetService("HttpService"):GenerateGUID(false) end)
			out = out .. C.sha256(seed)
		end
		return ssub(out, 1, n)
	end

	G.Crypto = C
	return C
end
]], "Guard/crypto")(G)
_b([[
-- ============================================================
-- Guard/env.lua — ตรวจสภาพแวดล้อมที่น่าสงสัย (ฮุกฟังก์ชันหลัก/เครื่องมือแกะที่รู้จัก)
-- คืน findings = { {id=,sev="high"|"medium"|"low",msg=}, ... } — นโยบายว่าจะทำอะไรกับแต่ละระดับอยู่ที่ init.lua
--   high   : ฟังก์ชัน built-in หลักถูกห่อด้วยโค้ด Lua (ถูกฮุก)
--   medium : พบ GUI ของเครื่องมือดักจับ/ดีบักที่รู้จัก (RemoteSpy/Dex ฯลฯ) หรือ __namecall ถูกห่อ
--   low    : ข้อมูลประกอบ (executor ไม่รู้จัก ฯลฯ)
-- ข้อจำกัด: ตัวฮุกที่ใช้ newcclosure ห่อดีๆ ตรวจไม่เจอ — นี่คือ speed bump ไม่ใช่กำแพง
-- ใส่ลง G : G.Env
-- ============================================================
return function(G)
	local E = {}

	-- ฟังก์ชันที่ต้องเป็น C เสมอ (ถ้าเป็น Lua closure = มีคนห่อ/ฮุก)
	local BUILTINS = {
		{"pcall", function() return pcall end}, {"xpcall", function() return xpcall end},
		{"tostring", function() return tostring end}, {"tonumber", function() return tonumber end},
		{"type", function() return type end}, {"typeof", function() return typeof end},
		{"setmetatable", function() return setmetatable end}, {"rawequal", function() return rawequal end},
		{"string.format", function() return string.format end}, {"string.sub", function() return string.sub end},
		{"string.char", function() return string.char end}, {"table.insert", function() return table.insert end},
		{"bit32.bxor", function() return bit32.bxor end}, {"Instance.new", function() return Instance.new end},
	}
	local EXEC_FUNCS = {"request", "http_request", "loadstring", "readfile", "writefile", "getgenv", "hookfunction", "hookmetamethod"}
	local SPY_NAMES = {"SimpleSpy", "SimpleSpyV3", "RemoteSpy", "Hydroxide", "Dex", "DarkDex", "DexExplorer", "Cobalt", "ScriptDumper", "Spy"}

	function E.isNative(f)
		if type(f) ~= "function" then return false end
		if not (type(debug) == "table" and debug.info) then return true end -- ตรวจไม่ได้ = ไม่ตัดสิน
		local ok, s = pcall(debug.info, f, "s")
		return ok and s == "[C]"
	end

	function E.executor()
		local name, ver
		pcall(function() name, ver = identifyexecutor() end)
		return name or "unknown", ver
	end

	-- opts: nativeCheck(bool,default true) spyCheck(bool,default true) metaCheck(bool,default true)
	function E.check(opts)
		opts = opts or {}
		local out = {}
		local function add(id, sev, msg) out[#out + 1] = {id = id, sev = sev, msg = msg} end
		if opts.nativeCheck ~= false then
			for _, b in ipairs(BUILTINS) do
				local ok, f = pcall(b[2])
				if ok and f and not E.isNative(f) then add("hook:" .. b[1], "high", b[1] .. " ไม่ใช่ฟังก์ชัน native (ถูกห่อ/ฮุก)") end
			end
			for _, n in ipairs(EXEC_FUNCS) do
				local ok, f = pcall(function() return getfenv and getfenv(0)[n] or _G[n] end)
				if ok and type(f) == "function" and not E.isNative(f) then add("wrap:" .. n, "low", n .. " เป็น Lua closure (บาง executor ทำแบบนี้ปกติ)") end
			end
		end
		if opts.spyCheck ~= false then
			local roots = {}
			pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
			pcall(function() if gethui then roots[#roots + 1] = gethui() end end)
			pcall(function() roots[#roots + 1] = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") end)
			for _, root in ipairs(roots) do
				for _, n in ipairs(SPY_NAMES) do
					local ok, hit = pcall(function() return root:FindFirstChild(n) end)
					if ok and hit then add("spy:" .. n, "medium", "พบ GUI เครื่องมือดักจับ: " .. n) end
				end
			end
		end
		if opts.metaCheck ~= false then
			pcall(function()
				if getrawmetatable then
					local mt = getrawmetatable(game)
					local nc = mt and rawget(mt, "__namecall")
					if type(nc) == "function" and not E.isNative(nc) then add("meta:__namecall", "medium", "__namecall ของ game ถูกแทนด้วยโค้ด Lua (อาจมี remote spy)") end
				end
			end)
		end
		local exe = E.executor()
		if exe == "unknown" then add("exec:unknown", "low", "ไม่รู้จัก executor") end
		return out
	end

	function E.worst(findings)
		local rank = {low = 1, medium = 2, high = 3}
		local w
		for _, f in ipairs(findings) do if not w or rank[f.sev] > rank[w] then w = f.sev end end
		return w
	end

	G.Env = E
	return E
end
]], "Guard/env")(G)
local C, Env = G.Crypto, G.Env
local PACK = {id="valley", salt="pPL5lqsHCS8ZMSHB62VNXQ==", ct=[[
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]], sha="fcd1967b54acd9951cf8cace2e6822ee6a58e60733f11c942d1ce4a1e64db7fc", tag="4ea7ea4cb7081200cdb897f5eb60175b3b693eb28617bfd14eb6bd3cae6341e4", blockOn="never", keyMode="auto", wraps={{n="Jnjd7AAcvB9Q82+d",w="wdBqisICpGEv1IbI9JP2Gj7a9X3eNjEfJdLg39jT/xc="}}}
local BUILDTAG = "v261008-1907"
local DISCORD = nil
local API = "https://dry-wave-054e.thanadol821.workers.dev" -- backend worker (เช่น https://xxx.workers.dev) — ว่าง = ปิด telemetry/status
local HttpS = game:GetService("HttpService")
local LP = game:GetService("Players").LocalPlayer

local _gl = {}
local function glog(m)
	local line = os.date("%H:%M:%S") .. " " .. m
	table.insert(_gl, line)
	pcall(function() -- appendfile ใน Xeno ไม่เขียนจริง → เก็บ buffer แล้ว writefile ทับรวม
		local ok, prev = pcall(readfile, "hz_gate_log.txt")
		writefile("hz_gate_log.txt", (ok and type(prev) == "string" and prev or "") .. line .. "\n")
	end)
end
glog("gate start build=" .. BUILDTAG .. " place=" .. tostring(game.PlaceId))

-- ============ telemetry + kill-switch (backend worker — API ว่าง = ปิดทั้งระบบ) ============
local _hw
local function hwid() -- คงที่ทั้งเซสชัน — anti-share ฝั่ง server นับเครื่องจากค่านี้
	if _hw then return _hw end
	local ok, h = pcall(gethwid)
	_hw = (ok and type(h) == "string" and h ~= "") and h or ("uid:" .. tostring(LP.UserId))
	return _hw
end
local function apiPost(path, body)
	if not API or API == "" then return end
	local req = request or http_request or (syn and syn.request)
	if not req then return end
	task.spawn(function() pcall(function()
		req({ Url = API .. path, Method = "POST",
			Headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" },
			Body = HttpS:JSONEncode(body) })
	end) end)
end
-- throttle: worker จำกัด /ping ที่ 60/10นาที/IP — ฝั่งนี้กันไว้ 45/10นาที + ห่าง ≥2s (event เกินโควตาตกเงียบๆ)
local _pt = { last = 0, n = 0, win = 0 }
local function ping(kind, extra, tag)
	local t = os.clock()
	if t - _pt.last < 2 then return end
	if t - _pt.win > 600 then _pt.win, _pt.n = t, 0 end
	if _pt.n >= 45 then return end
	_pt.last, _pt.n = t, _pt.n + 1
	apiPost("/ping", { ev = tostring(kind):sub(1, 32), g = PACK.id, tag = tostring(tag or BUILDTAG):sub(1, 32),
		u = LP.Name, dn = LP.DisplayName, uid = LP.UserId,
		hw = hwid(), place = game.PlaceId, x = extra })
end

local STATUS = { on = true, msg = "" }
local function fetchStatus()
	if not API or API == "" then return end
	local ok, raw = pcall(function()
		return game:HttpGet(API .. "/status?g=" .. PACK.id .. "&hw=" .. tostring(hwid()) .. "&t=" .. tostring(os.time()))
	end)
	if not ok or type(raw) ~= "string" then return end -- เน็ตดับ = fail-open ไม่บล็อก
	local ok2, t = pcall(function() return HttpS:JSONDecode(raw) end)
	if ok2 and type(t) == "table" then
		STATUS.on = (t.on ~= false)
		STATUS.msg = type(t.msg) == "string" and t.msg or ""
		STATUS.banned = {}
		if type(t.banned) == "table" then
			for _, w in ipairs(t.banned) do STATUS.banned[tostring(w)] = true end
		end
	end
end
local maintGui
local function showMaint()
	if maintGui then return end
	maintGui = Instance.new("ScreenGui")
	maintGui.Name = "HZMaint" maintGui.ResetOnSpawn = false maintGui.DisplayOrder = 99
	pcall(function() maintGui.Parent = game:GetService("CoreGui") end)
	if not maintGui.Parent then maintGui.Parent = LP:WaitForChild("PlayerGui") end
	local f = Instance.new("Frame", maintGui)
	f.Size = UDim2.new(0, 340, 0, 130) f.Position = UDim2.new(0.5, 0, 0.5, 0) f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.BackgroundColor3 = Color3.fromRGB(24, 20, 34) f.BorderSizePixel = 0
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
	local st = Instance.new("UIStroke", f) st.Color = Color3.fromRGB(255, 120, 120) st.Thickness = 1.5
	local t1 = Instance.new("TextLabel", f)
	t1.Size = UDim2.new(1, -24, 0, 30) t1.Position = UDim2.new(0, 12, 0, 16)
	t1.BackgroundTransparency = 1 t1.Text = "HZ HUB — ปิดปรับปรุงชั่วคราว"
	t1.TextColor3 = Color3.fromRGB(255, 140, 140) t1.TextSize = 16 t1.Font = Enum.Font.GothamBold
	local t2 = Instance.new("TextLabel", f)
	t2.Size = UDim2.new(1, -24, 0, 40) t2.Position = UDim2.new(0, 12, 0, 50)
	t2.BackgroundTransparency = 1 t2.TextWrapped = true t2.TextXAlignment = Enum.TextXAlignment.Left
	t2.Text = (STATUS.msg ~= "" and STATUS.msg or "ทีมงานกำลังอัปเดต — ลองใหม่ภายหลัง") .. "\n(ระบบจะเช็กใหม่เองทุก 60 วินาที)"
	t2.TextColor3 = Color3.fromRGB(200, 195, 215) t2.TextSize = 12 t2.Font = Enum.Font.Gotham
end
local function killRuntime()
	pcall(function() if getgenv and getgenv().HZ_VALLEY then getgenv().HZ_VALLEY() end end) -- KILL=true ของสคริปต์
	pcall(function()
		for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
			if g.Name == "FishUI" or g.Name == "FishKey" or g.Name == "HZMaint" then g:Destroy() end
		end
	end)
end
-- กันรันซ้อน: โหลดใหม่ทับตัวเก่า (autoexec + รันเอง / รันซ้ำ) — ตัวเก่าต้องตาย ไม่งั้นเห็น UI/ฟีเจอร์เวอร์ชันเก่าค้าง
killRuntime()
fetchStatus()
glog("status check on=" .. tostring(STATUS.on) .. (STATUS.msg ~= "" and (" msg=" .. STATUS.msg) or ""))
if not STATUS.on then showMaint() else ping("gate") end -- นับคนที่มาถึงหน้าคีย์
-- เฝ้า status ทุก 60 วิ — ปิดกลางทางได้ทั้งตอนค้างหน้าคีย์และตอนกำลังเล่น
task.spawn(function()
	while true do
		task.wait(60)
		fetchStatus()
		if not STATUS.on then
			showMaint() killRuntime()
		elseif maintGui then
			maintGui:Destroy() maintGui = nil glog("service resumed")
		end
	end
end)

-- ที่เก็บคีย์เข้ารหัสผูกเครื่อง (HWID) — เหมือน Guard.keyStore: ก๊อปไฟล์ไปเครื่องอื่นเปิดไม่ได้
do
	local ek, mk = C.hmac(hwid(), "ks-enc"), C.hmac(hwid(), "ks-mac")
	local path = "hz_" .. PACK.id .. ".key"
	FishUI.KeyStore = {
		save = function(k)
			pcall(function()
				local n = C.random(12)
				local ct = C.crypt(ek, n, k)
				writefile(path, C.hex(n) .. ":" .. C.b64encode(ct) .. ":" .. C.hex(C.hmac(mk, n .. ct)))
			end)
		end,
		load = function()
			local ok, raw = pcall(readfile, path)
			if not ok or type(raw) ~= "string" then return nil end
			local n, c, t = raw:match("^(%x+):([%w%+/=]+):(%x+)$")
			if not n then return nil end
			local nonce, ct, tag = C.unhex(n), C.b64decode(c), C.unhex(t)
			if not (nonce and ct and tag) then return nil end
			if not C.ctEqual(C.hmac(mk, nonce .. ct), tag) then return nil end
			return C.crypt(ek, nonce, ct)
		end,
		clear = function() pcall(function() if isfile and isfile(path) then delfile(path) end end) end,
	}
end

local saltBin, ctBin, tagBin = C.b64decode(PACK.salt), C.b64decode(PACK.ct), C.unhex(PACK.tag)
-- เหตุผลจาก server → ข้อความบนหน้าคีย์ (map เข้า reason ที่ FishUI.KeyScreen รู้จัก)
local REASON = { banned = "blocked", expired = "expired", bound = "hwid", ["no-hw"] = "hwid",
	rate = "rate", ["no-key"] = "bad", ["no-pk"] = "net", ["kv-down"] = "net" }
-- คีย์บนเว็บ (admin สร้าง) → server ส่ง PK กลับมา; ตรวจ tag เหมือน unwrap ปกติ
-- คืน (pk, why): why = เหตุดิบจาก server เมื่อ ok=false (เช่น banned/expired/bound)
local function serverUnlock(key)
	if not API or API == "" then return nil end
	local req = request or http_request or (syn and syn.request)
	if not req then return nil, "net" end
	local ok, res = pcall(req, { Url = API .. "/unlock", Method = "POST",
		Headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" },
		Body = HttpS:JSONEncode({ k = key, hw = hwid(), u = LP.Name, dn = LP.DisplayName,
			uid = LP.UserId, g = PACK.id, tag = BUILDTAG }) })
	if not ok or type(res) ~= "table" or type(res.Body) ~= "string" then return nil, "net" end
	local ok2, t = pcall(function() return HttpS:JSONDecode(res.Body) end)
	if ok2 and t and t.ok and type(t.pk) == "string" then
		local pk = C.b64decode(t.pk)
		if #pk == 32 and C.ctEqual(C.hmac(pk, saltBin .. ctBin), tagBin) then
			local myWm = C.hex(C.hmac(key, "hzv-id"):sub(1, 8))
			if t.wm and t.wm ~= myWm then glog("WARN server wm mismatch: " .. tostring(t.wm) .. " ~= " .. myWm) end
			glog("unlock via server key wm=" .. myWm)
			return pk, nil
		end
		return nil, "tamper" -- pk/tag ไม่ตรง = ของไม่แท้ (ไม่นับเป็นคีย์ผิด)
	end
	return nil, (ok2 and type(t) == "table" and t.why) or "net"
end
-- คีย์แต่ละตัว unwrap ได้ payload key (PK) เดียวกัน → ถอด body; คีย์ผิด = tag ไม่ตรง
local function unwrap(key)
	if type(key) ~= "string" or key == "" then return nil end -- ความยาวคีย์ไม่จำกัด (wrap ด้วย hmac อยู่แล้ว)
	if STATUS.banned and STATUS.banned[C.hex(C.hmac(key, "hzv-id"):sub(1, 8))] then -- โดนแบนจากหลังบ้าน
		glog("key banned wm=" .. C.hex(C.hmac(key, "hzv-id"):sub(1, 8)))
		return nil, "banned"
	end
	local wk = C.hmac(key, "hzv-wrap")
	for _, e in ipairs(PACK.wraps) do
		local pk = C.crypt(wk, C.b64decode(e.n), C.b64decode(e.w))
		if #pk == 32 and C.ctEqual(C.hmac(pk, saltBin .. ctBin), tagBin) then
			return pk, "ok"
		end
	end
	local pk, why = serverUnlock(key) -- คีย์เว็บ (สร้างจากหลังบ้าน) → ขอ PK จาก server
	return pk, why
end

-- ตรวจสภาพแวดล้อม (ฮุก builtin / เครื่องมือดักจับ) — บล็อกตาม PACK.blockOn (ค่าเริ่มต้น high)
local envBlocked = false
do
	local rank = { low = 1, medium = 2, high = 3 }
	local blockOn = PACK.blockOn or "high"
	local ok, findings = pcall(Env.check, { nativeCheck = true, spyCheck = true, metaCheck = true })
	if ok and type(findings) == "table" then
		for _, f in ipairs(findings) do glog("env[" .. f.sev .. "] " .. f.id .. " " .. f.msg) end
		local w = Env.worst(findings)
		if blockOn ~= "never" and w and (rank[w] or 0) >= (rank[blockOn] or 3) then envBlocked = true glog("env blocked: " .. w) end
	end
end

-- keyMode: "always" = ถามคีย์ทุกครั้ง (ล้างของเก่าทิ้งก่อน) | "auto"/"fill" = จำคีย์ผูกเครื่องได้
if PACK.keyMode == "always" then pcall(FishUI.KeyStore.clear) end

local function gate()
	FishUI.KeyScreen{
		brand = "HZ HUB", version = "tester " .. BUILDTAG,
		keyMode = PACK.keyMode,
		getKey = DISCORD,
		games = { { name = "Huss Valley (Chicken or Hero)", placeId = game.PlaceId, status = "play" } },
		features = {
			{ "gamepad", "บอทเล่นอัตโนมัติ", "ไก่วิ่งเข้าโซน / เหยี่ยวไล่จับ — ตาม role ที่เกมมอบให้" },
			{ "shield", "GOD อ่านใจเหยี่ยว", "หลบก่อนโดนจับจาก telegraph จริงของเกม" },
			{ "crown", "ฟาร์มครบวงจร", "เควส กงล้อ ของฟรี เพชร มีด/สกิล — เก็บให้หมด" },
		},
		validate = function(k)
			if envBlocked then return { ok = false, reason = "env" } end
			local pk, why = unwrap(k)
			-- why จาก server → reason ที่หน้าคีย์แปลเป็นข้อความอ่านรู้เรื่อง (แบน/หมดอายุ/ผูกเครื่อง/เร็วเกิน)
			return { ok = pk ~= nil, reason = pk and "ok" or (REASON[why] or "bad"), info = pk }
		end,
		getExpiry = function() return "บิลด์ทดสอบ " .. BUILDTAG end,
		onSuccess = function(key, pk)
			local src = C.crypt(pk, saltBin, ctBin)
			if C.sha256hex(src) ~= PACK.sha then glog("FATAL payload sha mismatch") error("payload corrupt", 0) end
			local wm = C.hex(C.hmac(key, "hzv-id"):sub(1, 8))
			local wtag = (BUILDTAG .. "|" .. wm):sub(1, 32) -- tag พิเศษ: build|wm → หลังบ้านเห็นว่า event มาจากคีย์ไหน
			glog("unlocked wm=" .. wm)
			ping("unlock", nil, wtag)
			local f, e = loadstring(src, "=hzvalley")
			if not f then glog("FATAL compile: " .. tostring(e)) error(tostring(e), 0) end
			f(FishUI, { tag = BUILDTAG, wm = wm, discord = DISCORD,
				ping = function(ev, x) -- ช่อง telemetry ของ payload: win/lost/kill/perfect/warn/alive/err
					ping(tostring(ev) .. (x ~= nil and (":" .. tostring(x):sub(1, 12)) or ""), nil, wtag)
				end,
				forgetKey = function() pcall(FishUI.KeyStore.clear) end,
				onLogout = function()
					glog("logout → reopen gate")
					task.delay(0.3, function()
						local okG, eG = pcall(gate)
						if not okG then glog("gate reopen ERR: " .. tostring(eG)) end
					end)
				end })
			ping("loaded", nil, wtag) -- payload รันจบจริง (gate→unlock→loaded = funnel ครบ)
		end,
	}
end
gate()
