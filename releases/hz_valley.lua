-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-ua
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
	local CLICKS={"rbxasset://sounds/button.wav","rbxasset://sounds/snap.wav",
		"rbxasset://sounds/electronicpingshort.wav"}
	local SFX={open="rbxasset://sounds/swoosh.wav",ok="rbxasset://sounds/rubber duck.wav",
		bad="rbxasset://sounds/uuhhh.mp3",noti="rbxasset://sounds/victory.wav"}
	if D.sndOn==nil then D.sndOn=true end
	D.sndRnd = D.sndRnd or Random.new(os.clock()*1000)
	function D._sndHost(g) D.sndHost=g end
	local function sfx(name,vol,speed)
		if not D.sndOn then return end
		local id
		if name=="click" or name=="tick" then
			id=CLICKS[D.sndRnd:NextInteger(1,#CLICKS)] speed=(speed or 1)*D.sndRnd:NextNumber(0.95,1.1)
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
local PACK = {id="valley", salt="aqZXX16AFQZC88lFeisQNA==", ct=[[
eLiNP3cwdSglw+UMMU3XiHR9BzZF7EbqvaHqpU4b0GM9JIs6OXtk2zZrZn17myQw13B403HPOGwk3o+rPt2QBtKeBcJ88P6qRkip3pgJTr+wZRFUD/Ny3h7tqnGOzOFIwoTNA2DS6ePKdyy2aCwZ6VaG3f3ByeVpQb/lcT+nXocS/d0D/Rz8wQRxGZjIOYyB5s0+iNJOyWFoqA10JecNe9/JqgtLqxsrQof+q4Ca566ZZZ0ysnnbpK9Ng880FgqDWufmhINlyMQ4V7g/8pLPmTtuRi7/hzPflpe7oGavb9/4eifJP214+f5nrp74ixRg8q55C+Uf1C7lRK8yQN5gnpjeeU6F5Ksft+zFuqyIYWwrAEd3+oHTalf9MjiP6J3SngXTFbrzIBAOdvk8Idc/2nJfUF4zCTElbpMv+Va4S5D6pXixQGaSUBezvqHJPpryuWj00ttxeMsyWYk3bT5WJWwqK4BUxDIU1/0Kh6CaJ2cUFfgRcvCDFPvAYvDIaBsaz0hEC0DelnuLd0ptEL4sA32WNjcxOLB+a5wdMfxUqCoGw1QQmPIEnWRUxI5dv1TKXntpw5L1aY2fJl4YbWyyvhxSEiVF+zUqLtQ2HGOk6FYriewG6AMUqvJaPEe+/C6HzqyXRhPG/DWxpTUTY6VMIufke05mgFEOuevU2YfeJ6t3EbmdBWxF8bE43l2K7ikCWveqZvTldh2tvdZIerE5KFup8YuYXJr1d0QMSY2Ab4TGEn3qL1xnA2xsKTdYeDp3pKKxI2JEzoBiCPynayTUHPSX2t28WQn/awB5cZgGbI5pVrH++foK/EYDsQG92BUN7eUi2/O4WNAjj1uppEwVnAK/Z5HGtH/nQtp36Ilqzu+i7RNzUKd+rF4hfC3PbcpPx1VcHODxGeZ4WaIA1s70L4DpIPKKKQgHINYhszXUuoG7ICoNPg4FbCG73swi9Dp6725fN3/HvWFKyCY0IEFqodiqrUnG/bL99MYvxhppjsVAKYpA7OfCOqyfPaKG8F/ysGOcDjKl9ojeomz9+x7oSPepxIw4INoEjPdfLDx7wCq9f7L1K1MFU+98YwAAS6EiF3K1bIJ8v410+XLwKr/6EkslrJj8hy3KEQJ98wP0ZNXXmAOER8qsjwhuwB8yEBh6oeqiZ9g8Uvjbma1ne01KLraD7CLupyUdg9B20DK6+kynMbxtX8m4DlixzV7wCKzLQ7Gx4sDTW58Nsr0fBa3V/f3U38IH5TsBjsQzoO++06Xls8WzyR9FOlgRGzj8xPY12l5FpiWxg+2S0P9rPvrFjt4eHtjP60xpJNrT3hY1sJtS0CM8AdxMVR5xdUVmvJyWf3BvmPOYeU4qE0Oq+cEP1EvrjptNPUztkvgTo481xUkN7FkSSKrkjBfWHMfxwniP0r3+g8i1rVVEprVVGdUiJnQ0LSejMbvB164z64AK0xTv5mv1QZttDZkM9iW+YVQroR+sHr9n+5YJJ116aaNjp/PXgzz3Sv4m7IS9d80CvUJ13oXvfTpzDf9iqZTVFxoXsyTDaJHXErv9AHWq8ShEEd6HbN0d0Q/YSOp6v+9Hv0DPFBtucvQUhpmyqIo1bfrGbGkzITnTZBt7fcnt4lJHcUGPRk+RIbklb9vrcbVhWKDyuR8ZalxMZZup4Gu0NLQoojs7tqqa6hZuMtQc8bxG3rJb9P8yK/3H5ggoLOqoCvyNpRzDFYxCFRuqT30uV9UxC30Z9xTMICFbdqJ7srwmE2PO6IavIsZ8ZBJzuFteKcrbFJTW2AvG6c1jaTbG5+YSwUMY58D9Rqg9ZurlfjRjsoB3C/bO4U9BY96dz9wscImRNKkS/CugJFuzF/GTZpI4Ec9AypYI12B0tV9NPYO+oGziFs1moZYtM/u36Z24PVHSFlS2tzFs8qmvXSvIcCfXQzi2t8+LE4ekV8Gw1GEpmwlW23l/n1gVnYb4m+OwNpbdvuubRZh3E2HyZ75hmL5a/e+L4dEPxJrB+FnLDtPMH+lD8SkN/uTJLb2D9CWRAOMmFWXlF8VJGEySd3r/zNMWWtgbWx4GZ5uaidP3Exo4PWfAYai5hKf1mPZpy8cPHgWvy5gfn2pD7Ejl4FC+I4yBws1Log4Gi/RO/vXTOVZCgHstDizuVH4vWoLFJYDFxg1I46jQMgx9feLmt44E/wRHiR/f/IPCMYE/lDoHfd0rPwWlu9K1Ca34wx0nIfDkomGISd+UHNQ+sNlz+PbeZ2+MMfrYebiaK/ZXJaDtaDYJlvHrzjKsCvFulovH/q/TSMpouIsWYaHeHDGbrbtkwTBqsiEn5lPfirqMDHn4sl6C5e+ItE+bv89K6Wrjv1ef/NaR+B20um5v5REEYtzoj6juzSKSD1T1PzbLWN8lH/6uxU4/j+NJMUF/M+IRAFIgQ2whLitVn7/oAlbfWGqAlvGU9hHI7ki6c//DMfuuC7JaKNIULx+XEH8+zO2e+kqj/03QacnWQ7MWZCvrC90UQ0CEb7AKvhIwyJtWsbFmG8Hiev8eRCuVRffiKQjRywzzny9/nWna93/hpTF9Lxbp71JTD9f5aZJlrTkNqNDmBVYT8ZZasbdJIuW7vJGmlTIfFsg4+ksA6PyKokxkRK5XKm7g5s/EHGIR9u3GAkGY5No0/nLDSiSkaoMR0SLG7xM3iRyLJFvCdstRYG38O1GBzi03Sm2m0g9YCYyiryUAqbn9WeIe89WWqLTJRx+jzNwooOMtbNIs0Qe8W3/hFLHV6kv+yL01pKdNRGl/HCXtcBEtkU59c3Yq+CAdGiotRZ5t2sY2zRBDvlnN7rT1ZNDE/Axp0BEn8khauF/wUZsZcz0DOzrH1N80DIwChlpCV64qvL/7nR9nWMpZAEx4gMCjphC96MFoZtUC9z43nBjLP6z2aD6UEePG1rHsmnx4YvNHBq6O/zJ/ILtwbFyMNFp1deew4HPknFmEyKebwb4QYExH8bti7Z5a19QckWwgU1K5sQMmhjdf6VU58E90bQFxauW8bCb+6N1ttSDN/AC15xTKdeaetaVBCSi9ieBgfSmEQx0ZLpA6HEmPhX2khYpibv0S6jaPdM8Sbk2xTzSLYrs0IXTCVTuoZJTFuEOUvzJwMM67mKbTqeqAadk6DLi2NRBHkRuETu3p2+0aGg5cSm2+uRdmYWQDTDFAb8NJRop7n7gH/OVdpicu9kH7MBOMSJmvknNeDeiKvkQdXFlvUu8kQ6/esXAcEljqHdlRav7wgTpSh9jCG5B4AEJ4kZyJqXoiX3R7NO3gbYdtq8Shagu1CPaRFSuzwrCKcknhaEQUj/zjb1VNKwIZ/Z5jpFfhusmyR6hvMjlSevWL4vamLN+z50f99AYtavwDAGw2BvMcxCdVnkokPYXd3ntvzip2VE+TGXvy5ia+XCpQp0HC2cSQdG8fspFEt1zayZmfoMTNAY09mWrylZrUKz/NzEtuFTAtKzDoLs2AxPV4eMpzlxKUx9gxX0spZ5QhTefd7HGLVPErc203HNp/CSjWB3aIC2UjMwPH/rBtUlcABhTichoswWHK/vJ/Up5YJSpLDe9m2cW8Us5U9EH2ZPcdQjdnK8AJo5e14IcQN1tNFyp7FK3CBnNo4YxC/RPzIChdQw5h/t9/OIByizS8CY0qNTIf3YLneKNjO6jHpvhOFffxOKXII8NGgzF4qqvhofdo/MhuGPZrO+qPz8yHCArD2EUxkL87WPc1j4aT2WKbc/db3gxLeS/gTpyzZjG0nyRoBIN+U+U677PHW4K3BuZcmcTDeimAa8c6DdgUZl5Kje0hGTOf4j42i7jWAGJA/TJmkyxdkuYaONYhsKi2hWXbbOrPFs6M//kZvGqCeIh4txxdle7zOSDKaojA2+xsuJlLhDqX6puoyZfOM5xZ+wISuOFW7uY3XvXqTqwjpFZCvgmODzUTtVLmmrD6cm7ThvmXQI7+XxZahiX36l6xBN4TLgwrYIF57lCztRzggfTIH/K65SDN8/FHJ985PKf9FaMtO8CdUHtJVIV84wo/BbDABqbejQgv31v31lzpyRE2IKUyOlgVjhsoBom+kXqNhv7FUtBglvews5IRfpsPEm/ulzWE7nEPm0WsviKIa7KGn2vGSnuMZmU9gXNaIj2nOB66T4eO800Z/YL0evZRThldltqnR4kQoa+gYs5v6mpwQbN41M1er756632jVVBVm6k8GstfFJrxi72VZH4v3a1makXKtv6Z5QvyUOrFDIxYech4w3X98QwoJFT2I1LkpnttdpoZW4Nx9v+DWAQH1ZAXoRTvodk5OcLFg+z6JIA/zhs1r+43XRM6AqYJLiwZyt677lfI5JfkRVgvhK6snSmEwuj75c2sGOzDB8hsjzeASdFwhwV7DruRmfwf+dTZAgkQ6earLYGbSPXuSCcUZrrNkCffVCwLT1azW75nKDwZjzAEdToEU61HdmBjc4eg3QtxOhZsSn2RMd7KLEnVcrZxEwCDNC67pWCs/enKyYMHE5NGvXLn983PK6TmyT2Vu2W9/glE+6wHPBiE/ygxfjV5KTA7LBXlSVmKl8hIqY82E7Vaaf1h81g2BKmtWK66WDz0WNKrxcrjNLr/lIfEJQ6nq/lmWXUB+9xlIq2gkTsvXDo2wEAtJYqhzciI3OYzUb5bcsqVtldoI+pelv1E4NSYRloUkWKkEMingHkMB08vL/0no6+vS0aPqHyIBV/rhXzeioEyb6vE5EohwO6xxY2C/787NfIIXUQ2KaLa2teZjJT6jF9t7BQG6ge7ATJ7UujsRzvwpmnyoD0/xGOP3vz+tFvZrfy4brzpnbnzmMLZU2Ba9TI6Bx9en3nymIhiKx2odRPKH51q1UdY97DGPC+nAOb1OY3FRMi0oemm0I6WDTNnM0iUueDqAW8JES6hRoZqWv7/lGngPcO0TYYnR0N9VmhPWnV56fZw2opp3puMPxdIE79I+TmT/UnkZlgAlI41b5wyahwYjgjBG1nsvj73P//vmbmaypPDF4QxRdfRAnWYc+I87aeVeVDIQXNAyO3y2rBFPn2OYLwuIwmJw7SeDSS7rBHmpY2OJv3LjoFT3IidqnUbjNYZidlHnwN5LiKPS3kJxs9wp2kTqSX42RGtHbGiQRRaaFeNbTusLCqGAeQ396aX1e736mP2pktsatuNHkxH7wDm12Zg/O5hZBJfqE+CHe5DgGW29xU/FAxp5mYLQnQipmoHBnXe0OoZzjTR8JrCp9GT8aTROLMfxz+LTx5FIizOe1r7SJizDl3mptWrSsYsKMZ11+C04zVkGFcqFHi/X7UT2zkrL/r5WwOm2jMq9fdrlJGSxp2wzBgdeYyUMerWBFVo1JCKmQGe7rCyndVJOUZL5+CBAKBnnqHAvt4BcvGxmDE+vjASLQ+WZW/LllHTC218g8szt730+YUQF9g0RQ20KYZg/pvbAU6zHOXSNIZkeoNfnAAxQCauE7P1Jek2+vhVIUpPmdXTTGeuG98J5RGtMscADL3L8/0n9zve3amd4VaQLJPS5qWXorvfQlkNkuPlBMlZ6Td0+aepJdXnkCPYPzHPN1SiumrNfQO6Gz0rhTeoVOKwyifu0ES1cFKD3x05PwdkIAb1SvgQWpVFS3GkAClLo3z6xE4bVVW4+SERQQXj5CB7jm+SEKMkF+FAWSE3ERcADI+3RVy6YiJFHODzwZSpYcJn4JYbC55Y8tFAZSq+A0AeiiGPlqLtxDf6mpypblzGwNGDgSDIcHF2abkiyAGp6XWSVINWCpK4NwwrzOZuk5j9MZ5203KICQXUVW2FC4xzXS2eOemABJvHYDswBQlXU/lKb1wR5pNJX08HLup32HZr1NfYMxwLnmanOToV4vF0vw3XBRYbzLQsdp9A2lUsQClcuzRkDI3+JBrjugG5ZpwNOoLhdemtUu2OQNBl6T9+mKKicqksqrF7c/rMVbaeZvDRkezO0rluoUrvt/af4ApX2hza0ru7VzSoJnZde5Qh1pmYixsBRuoSBp3yGZRDqBbp409KXlL5DjTA0AMKIODKMxiMCfmeI2sGVJMneGnlch7dlm8jVH/oWji8yJ+re8i60NCrxH/RM9XNlBQu5eyu9qHGqgSih1hqjtBN6bQpVrJe7aO5rkKFSTyVJVc4NTFqzRPPY4U3T3Wk17Oex/LJ2DLh1HVruuOCCQvnUZj9EFCcevurTPFOQU961/G4zlxpr4jW23JrU1JOXwyP2MJ6VozmNqc9lM5cATZryKK48gv2GmFoM/Tq9za5s7WqnlZ0MJVOSK+s3jn2IGI4B8f62xMgPlRXQKA5eZ4uiJQPU7B/XSkSKIJqRlo2Sh9vD2R3gkTTPvoSIYU0yTBvUh9OroPTeklNikD5BaGgCB8568YN+TzMky0jUxG4F9J+s9E+KTg7a/UuNXhbCJYThXIImgiey9/NigAA2vN15Zzj5N8k1mYsYeYCIMtNPW0l4o85P1B3nk61b42/lONL0lnqvb4z8ckiMVj6UWnsbtRA2YaSLW671tUir76udiGYaWIBXvt7PtmLbnY2cg6uapy2Lbz5Oe1fTIXUecUf590Btbs+syB8KWC4MMNoPWVunKxh71fsyrqui9+GaieyhLcLZW56tzfMPSe846FJ0FH30tIKJ6HCEZ8LKmXl/s8MUoDbCyET5d6nsEneRUgf76BfVTj6cQZF07GZulUDDpYAlak3sRraUQ4DFPeXW76TzvGPr8SR830ik9Ltn0KGMdAbs7UalzOQyg+tdtnQmHoiQ8z/lr2yNmhnBZ6JEM/Xy/yoY1FK7EJrImbDMvcKpBE0htXNQ8QksLNVEKbcriYZ2bbH9Rd0dyuhpaaFQOr2IroRWRdO3AQmUOny1bItr2vtelGU1rL7Gw4DK8y+Shg9N8kyo0bQvjGBCQ585XpjU4PdvZbj39EPiOpnD+76kXHww0M+mjaAj6g8DRNA3bcbpalQYMq+ew7y0jz6p8kOO2+bfXra+PErK1QLQb28whk+8ryjJPHdLB7ZeivIBwnpyF95QQOMzs6BPGV0Khx+PwKROfY2gIcQnidZ/h2oAfOlePerYXi2XIdb5AFd6ZnED6I45dEnJJqYlXUFzANWfh1WM8zRgMt366RBAGfXFJmSxfizmH54q6hOGLVp/4UkmabW1F7yFT0oDq0bflIiwyBslCoGn2HManpakygzQl/tBvxlGf8db/LjXCA0yupcU8uiE6xQ7eO8VEvDRS/isgDIOGziKPU8blyJkDu3MC8Kpy9Fcoi7lJj3tkcjkos2dXhTCfZvY7dSwSWvN/qoiBauJFNQ6I/QZKuhIT85tdPqlv8x1r+mMBJMiBlwjN1LnhzII+S/08JuMXz462K02Pr5hcAS9bi9DyN3nHWxIUgHRtfE4s5DbxecgKznnBQ1vCghGUpJyBrfTtz8s+elDdTXL+Yi2UKbsMcvEJ/yoRv3QmSs+8SadoNYtGSbnQkdIG1dTI6qSRo+U7J+GH9XaaeBt/c7iS+Q+rt2ImFCElcKURLq+NSQNWlTqkxyfjSIDP9U+Zjt88S3LA+/K4AgtQ+/dnhdxSeyXpyttSC0L2cXJADfxcQ3VVTwT830h3VTfHHgiXLOG8jFjdB+argf4K4SHWvdapwU32p/QlIMumFQoyHXHtHp3gd5JKufsSpLjwo3PTTMndS+ayyjmc0jQbSMiuXy2SjWiJJVc/AyZkDjMtWyU5TXxQL1xm3sCyA3O9FTwdt625V28rIBWBNi5lZ4dI6IG1przFdxf9+qX5UlqdUtL0VT1kELnYNHae1MXzqSQY5ZT7usOxuTUEQkXpIAYZqUef725G4ZHo0FYYzThsbTDCh7fho1p0FuzRneMHlXTFehz96NtHHkpsqAw4i6WZSQ+senGSEsVVKTPFXesUgDM7NF2kN6ymS7lQ0bvQzqLxd6biFit7vpE/HmX5kgunT8Of8O9MZjACb0X1b0Y4yHVBGbG6VL/odBUnmxsrqTMiNtVa9IMCR+81wEuCbqTauRXcgHDG/8gjekZxbkVDUOhK+P/aXP2veqbtBDaAu/ApqVaryXyha9m1q5FYQvaA33F2vfS5iiIBueMNzgUByHo9DZ44+o/z5DzxhWftEkwyShX/Rxhl/4GPQLZvv8zx9vC3aNFX3JTtvQQ7UHvDXs4t2WLylpdRBPiJacnOIIZRHJSrDALmb3CBNSfEicoor+d2Rfvqmh62hDtSyUqSMlXH59V5xO1enw93PZEq+nQk001jvEqNDiJLod1J1ZQUiGBp6KdHWXuYP/91InvzGTCMQSb5vEwWRiQUAHrsVJgI61STLycGSi0yQdCVyAqFapMGkoKt4lHShkjQOz5kxalW6wlmfRzjTE8AhRSC026EvI0QGfrzahy4xx8AIcdOGmacYDLpY22/jwmeXH9eLFr/GdcyfVSf1NWPkdWeNXngMzhauG8xBvXZKP1KC+hhlEeioMxaDh2oZFGGTcKGUMatId3TyNjuKAII9h2d2Pnj5PCe+Dp2ork2zbUrIQgZlZHN+Io63iSEMczqhZnQS5BukxW4StUFsRI62YCeu52cW8QkUr0yLae3VRA+0Pjjo4LQgK1lYDbRv1P86txbARVWeCTpfTUqciGqwelQS9y50Bu38CR9FheeA21CIsvTrLqLe/vR8g/+2xSfOsZ/XWIeZ2DB5s/JAblpLtj+I6TAx0cRL5VZq68TJPDXV4H4x6btINCSRNzvLrbqGFT1vSyuNZeinGFBjVvGuwN6H3xztYS3iPJ9UFQ4S+PcsfvNV5j0oMQ9WCWecrz0rw2mrXzgiSrbr6SoyYPJOhpdfZdlAQJ6py/9SPwgAy8ULccjGDGeCxAbUqp1sMw3b2/M0X7+18ZGoLfbMMXlHbyI60yCVBx/d8VLLhdWuKidA3U5smabrYNW+5eY509uwY0x3yQLoOCxvbhsxSmU3b9G8uWSIDq5sLvEhz+nmQDQGar9rXxHvjHHi2NubgydlkyS4xm4vPgibx2weqdns8tqTIjtCbFsQlzE3w2CG6XGm2N6g20k43Fiti/93JIGZUr70fSLiJ2cL6GQQV3PNrozx9QRT7laQIyosB6/DP0zE2jWGj8JdZT+EGnrIJsHgPMNVBWDtIkDd4OWVy5QnqcMjUbYOXFVdeAQpvM5z/9kpgIeWtU85gbMtonJhMi9HwUgqt1Pi+AtQcwQdGXGnIBC9jbKusnBQfnUCYQexX0RgmIeDbAjVuEhUI6uRTQly0wUQ9mn4QO8ANjduXB6iA2tSFEam3BlNioKJAo+v+5UrJi6EJoCH7I/+OV8TEN/ihBYcoM2DIWvjE7DYwi4FTWJvZhcZ3pOsoiS6IAl0VoYY2tdgU8t/PRkjLYBiIVt3ucuzytTpCBheH4EkHCnERmQYSUFcbYbyh8l2shzBPtcrZxh3/+bNpn6pj5LDblhoa1X61L+oOk9dR1fUO2l2XbZ/CtihIwYVLaMsK8fTOlWnNhi5Ykc36WQDO/2lsDQv+lxax0f2MMJKxFJkCQhJ3y3uVdnUoC9RO5UJMO3kuQjb5nFcHHthoYIpCsJN1lRMHnHrLQU67gC47B+vuDZRWq768D+DJ0uSm1035qCO6MBrFUrPvPu52BMn5oq/CatBOmj0WoUEz74Pxyt90Q9o4FAQIKIuoh90MjMDCS4tO4acPUgWnjFNQQtxKOPlN1vlgcMPVPqcOoAhNTZ7r9sjmLP5/FrAfCX4zdt3kzcTQd/B1MtZDMDag2sc8i7n6Vt5JphP6s/ysTvguyTBCnZLi34J4L9ut2uLeecJtbZ4QC3M7xj1Qmu5O/FQSZbVmzZAcO1d0xPbmajDOtQal1xQwj8N5fi9DMwDb+waRnYDLmsDTW2uan2ZFFS+A5i8X5k9bIagFuOzu0GBTbe7Nh9DxPKxwnCYTr+PzKEw8O8TW/lQfklPjYt3fQr6Uglo9SghydsvW9y8C7R6EwUNocEmTo70Q3FN/LTeqkc/ptCOYy8npeqNsswDuWCVsMyaj5rAXfYqn5buiNDLj44BRRJJ0J26AcPuFKkDdJQ38NcxOt8YRh/T7A4gZXzNG1uUbfvnXGxPrUo1rrWW8+P5FcutOUj2h+CypCTcQ5QPgWWoEHNwYhudyJFLgDwY7MlnhaDMKmkVqVigCX93+U3oZB0PhW5lUGnt5fgFpLJithI4K37Xu+tsqDqKlzkS0TBr+a+RMV/IMsYlIo7pgv2M9sIqztNrw3UYXFZQB+vifEfWdsBxDXt0xvq0HW+MGeD5/t+GjfCPG+wE4Cr9EGGSu+aItxveXAm2RRE/hq0J10YNz3m6fYHMQ3aowQvhTuJ+nPg97wPD4TxZ7ViL/t4Hiuh6D2SjjAnHnnD7UIuDKVrdmkYSRcMJSgkbAhT3W4S933JEuMJpCvBsHPGJha0yiPCVtEeVPUHj6lFJDjRDN/gsohgLiqkQnWtb+wU4CpORzTQq6t/DHcFySiqz8C7UD3aP3XYh6zx/JQp3BILN21l8EiOiN/9twS9pwqOyDV6iC658u/qBB17yti3jDOyWPyV3lKMQ0/RB02lYaGiBdIc9vRFyA1svelDMnLEl8L2KZtx01NMdQT1701Pe8QtytlEGG0K5aCzJkCdpmvRK4cXgDwwxhCfjnfEIy8hxhVjfcV7YEo3yCVcHww3HXiJFf2ZR9wYBgJgC01MVlvXXnYqmHTzPmGEP9LuaGfswKxWVLZh84TC2zl2zO8Qxpdt+Ho4Cm/LqBp/dT+di8oIcVmUH19sK8HZFPN1sHgqeCwZ2gor7t0RjaEJWl+i9tN7oCQTfBkrypPKNfI8vJlSfzZueV1TjUsKMmGGVwJt4U3B5vnTmn+RGO0MITCdonQQWnwpdt9AA59OQJzLo/Ui/upQpL2+9G6rOrlq0Oi5sh9RW5eySfCsM4OXT32FqkE+kN6bfUc6CuQuv4FRZRGoA5mK/PpzUNjcR54Dg4fVP+ubsg5OkmB4L/BaM9lX/JlybECv+L5nd6DaNukDyeNCHIDfdapBefh/+owxaJOnhZid/FaoMpxwwvcTJTfLBJrUuMK9W1g+8jC8RHzDr0RT+3tZkTFBvEW84LYxHaWdneidUDUNOBC4NWIJHEx8kWHVZkmIlAFzSNuU3ji64BHNGxohR/Z7a8uL3W04o8rpckB+tHobD98yJX+sLTrqQyjFnxyHOIBHcU1ouBbI6mpp1Ijf8WYPt4i69o4hARK24H043ToVdSQo31wwnzZ91hClgE5gCEnHCMhyIHHGMzgKBQFtTFYVAJUiK1crNY1QXBimKrNjp3xb+0mneml9Jn6PDgytwejhrARf+sN/5ZNtlQ/mZSd2yGbGgoL2tditV//7Si6PMfNhV6zUPGyjZvLFIET5RNIhY0a8K2F1HifqvN/b0OX4tAVZkQ6HvPheXYLKBOSGSlptiNSEso9rqPeGYPY/nRiQbm4Jz+f057Z1oFgHLJYY1i20fpB39jfNY2LeiXdIVbBviLQRvslgK+OVAWts8LknOx0E6fZ79J/z/1HzsrMuTub3F3Y3bn7U128fW8vkT5x9QzjLrMFTa1R1oc/RLJlGIZpQwPWPiayZG/QxTbJfbZN+NnrPS5j48Z577MQT/BlDooKF75rQeIh0LZKet8hoVlA6BqarzAEb9vWjix2ZdHd19E7G3aBa5t2b7AseVjbK3Qd26we29tZDX3sHFgV3P6PhFrIZqI7c4AEI6X2py9S3Pj8deJrFZ92JFj9yCZIPc5a0xJ8vtJraN4dGKCwL3jATGaGjgNagVctMeyYJRqRJog7tvTNdB13IMOxors8f4rs82WsUFheYeFZ1AvAsFNDrCbJYbTkzU79iXvuZYyt+jJ41atZEtwzkXw+zrxRI7c+z/Zs4PSZYSVBwOd3MqFLTUrP+C9Kl33NbcHFBFBRcbxbXG2ID8OXw5n+xjka/YwCSC3HbhlCpo8QNo0VNZcOPELaWXA6Wh5oliCujOTbipstYgnlT/l51UDAU6ZzFYXxuLmBZ7PcgBnYaN1ARVKPDJtbEgpGx6KrNBfuEgcRrNUKrZ8U/Bb34Aj+Goq4rrELqe2YPKTkzeUDDVueR8wpHjm0WhF7sG3qdAH4GwRg0qSExCvADLGFPSZZMkeZFuFf97jeKlvah/h3KBQ3fCrV62mIc5TzsPG5ec2mH4sMBGOXQ6na1kw/XkXs3qcFC9OfUh7J2PX6ybrqFWax7OixFl6b007GyZA3OtJPDPC+UG44G/EXeej5GpcbSs3i0BAvGPpMe46MGf3PUI9hiEp3I5pIj4QVSi5v4pVfIxko1WsZEOpwB/X739cG158eRv21V14WVBRI46fxVjBF+6hJ5orQ0IrEk7JyX6gQDj7LnuTMsm34CNqCJvRZvUA7U8K4yeZKX5NVRchpp/2qXGBsl+tiSQrNjrsU5bEXK7Nj7SZf35s+jmd1YCLWsi+p0smEHgDxo+3G5hMTRlW/cPjIUI9dL8RxHj8MEyHWR0yC2QtyFQI6vzrsgbohMy171GBMEkk53k0kLt01SBXSuvvosApXkZ6aE5/bBSoyr3XYFW5j6MDRPV0xCOVnpFpqLvw3/g5QK6ET7/EW+ooyqtw70OuS+ZOKSeSMaEC/Ub3NSC4iyLEXVDzZmhhTSnW4NuemDNvj/MQxCcnpYnMVeycUSvLO1qVo5nUMYp7dv9Kk41n0eZ0NYjDyIkVPyHitxmcbIEVPU+PS0yqXfycUGwg03FhrYgyyvN5iMS+5L/gjUk2FJ0wd/gz5IiwLwU4DFun5knLlMhG69nT6/amYnMgTSIVrl7nk3RKnOK98jYUV6wjNtRyUCn6N8061ew+Dua3MlvnhAhj3VZNZyAmP7DMimXAuj7P+GbWl0wEMmjt6iqGal21TpnzzMqDlQXSsCOGGfQFWqPysn4ilUVbwBpC5cXVck704E7eoLYPUQeG8D3rrTLqCvdAViGtjeYTPXlXlFSCS/N2S8NRajD3Dyn+dhlyLtQb2/VR9RO2i8/YEoR2sT6vM98yUyUGrPIESB/QLCGaFLfiA49jvWQ9fQuUd6U1AA434nhv9TXVTFsFnFCWesZ7M7OAK+XSjV7lrFpX6hqqZ6x+JsVfU+CWGo8RFSfBR8l2YUY77rny2J+qawsOV9+TxHE1cnUZlrzBPSZA+/mDIH9O2oKkkUN9KndxrF7MtO6J4P59ENcG1gUbRIbv8x4NghgKwr0LE8+qKuAV3ugP4BEMqX92uQKRo/lbNzQCPHm6ZGDdDeJjEgTI9vkuEyxeX3x0B6mVXK2IbDwtfiZd5W9lL7B2boOEk0B9+UfSVXG+VSq1eTFw5vA2GO9ipjsB/kLkn/BEkMKVcGVmQSTvSc0adpFERZSo109DGqmnC8EjcoLAgRNkDmO8C+eVRSlMZ3GG7r02ChtwCCbHJNLEBrGiuWYqjNAJMfGO66R1u0sApctyl0pVBV7BwHxol8iwHoW+SeRYUhA9sNbAQVEAT4J0HkXrOLZFOJA64ccOIf92K79FasueLFe3XdqIEYMGx1OAtt13w33tflb00ZSb/5uFi1+UKcmDzMaPubpL9oPiRfKaXS6D0bLhbsCu7VOKkStmDGQYxCMH6ygl25XmdKEY+XdBRfdgGyUI8+hPnclwAGxQ/FpIc/V/X+p0ij5fKJAhnNzG/LsAGymFIhzdYBQicfvsX5/shPHuLaJYWiVRrzPiplixb+Vvc1fE/AOeLDrLphps5Tp3kU2OhK/0DEngilajcb1hghpMKoZF8HyLBjrlrXDBii9l3XdXT68/3EBR5dAAj6XHvH3m+AA41s5QPpeMe/Bt9ia6HSmNX2aTMUfaA8VJsPMs9eX5337Yp9eP2QlnooInFtPUBumyn0gu0wDEymOTF9lP1Wvr0N/I4gkus3QxvZXpkvuoTHFIBTyNx87u0vjI3LPZA1NR17fPgNDuPXXIWiiChFE/6l1z2jDc7VA8e574ZCbUBSzTw9d89JvO7rVDckN+yhxQnWO0CDaqXy6UcNnJuJGXo7nsjdsgKBgkmy00VYU7uZrMGbVddb1fKyRdMyZMQDCVOzhQ/s0lCE4S1tQvLuVBZh7OhihJ9tmzJsokTct0QZEZ928g8bytxg5R3sV9kkL2q50LNZVHm2ewpbGuW9hHpDiw+s0ZRA4SgkmbRDFC6UmlzlNvIX3D96IvTl+HNwjjxvbLjwL2dCKER9x41O0BSthOqw9WjbMAVX/XpAORBQF8Mz6gAb45YwSie82ZWHRGCfYZBsBaVJxe4CXcrAImNzJWJSz+V8CuUvpJvSO7xX0sjuCLh7RGXN+FAiCCKEHMVSr4kLkrodGQX47lsez5EVCyOyzCQhlfrA5fEkffE1j/lxx7LoqKcRCQ2fG/f/TWEvZNTD+QuJCvlhdUE0siLxjRildiz37Rh2TUV/fymYtoESyKl1I9g1jk8B0pE114NnX8i+kWtMmIV8XqAyDlBj107LU6rEuq/nLfN/PylFUkKV/e9Xh3lcbpuJ0jBZnBoolHL825LJCUrCbWVxmS89pTAYFQb1M9PjTiLRscC2OgkctRbpIfktqPVHtxj0AMfpPo8nepiZI3+Hdr1wUK4AbIvq6L7uA4w5qME4QWoHK96B1l+Q2ryHnsNTdT6J+AKiWN5brl/vQCJP2WajfbWhvpqcH7lv77CyzPqhyFwmR9LxjBG252PNnYvqcY2fmBP4gXRJzytDZ2pdpk+kdN4C7/58V2O6fRVS8nK5XAbyNPGi9p8l1xm1qummToAUsY4ke78okOXEbMHyc6mwRm0gihp+zXx2+Daidu0NQMDfmTzMOTZa9zASVG/g/9Q2+puWb3uWqGQMI8WXyjSmTP/fY+f3DGxdQrW+uhULj3+qUwi7HoSjk0bmclYAhKvL1iaKppV19UzIKRP3axDPz/cIZy+jO3RvLjQIjtHwk69KPQriYye7dC6O/9k0JUMBUBM37ul7Y+ZT1ha0rd160zIeexK3/GJRNOntUaIFGUtMvtERC6n/CKJOvliT7Sq8B2PsMcDx1PH1LOtZHAvWhzWllzWe4yW24+fjps2dnq/JEVkyculAvdgUMHLUk8O8mM1WSumYBfK5WqPvr1M/MXj53SU8IZAkIlpJMyu6QzVfGgVsO9QSOPMt+5yrvKqsjxg/i+HMoc6JcXMV9MBaKQhQm84HrYz+eb1bwlb6HuBOoWF+GVpBluvY4nO0O8ieiRlspC9S0xu9u3rd0FQdB9lcOYgqe5pj2ZNRFqXJCid7TiMlizUcYQFuwD96STADar2fnjdOQwSIAPEobpnCsIYFX2Dt6FZnjJYiVM3CXLjXTmWsYmkpweiiZgAU4mzGJ9wWq2zWvSkUqy3+7400JOuoyOBJD3UPOpaL/MCAZl3OnK4W7ZzsSi9RE9f257IZztFxyw5YQOpE7yhFIPiAFCp1HZVJcqtnpEcXsNQAczjsh6TzpTPzLOG14GtnjNA+RMTbaCZkC36Chof0hxZPuuhklRLae1xOQ2AAXimrVfTQF6YStxl9zu+p+D6BDsQkogoRd5j4vE9pfxgbvP21PGs15ytdgFvPZeAriqTlK55PnEKm9RXYzlvM4pOtNuqoywqXAoJw1aqWxQfvI8oAUWlGVr86XgVyzAJzjJmvPKS+RK+232pXXQ0Yy222yntilYw2iGuXrT2BYHcuKA2EuVA2WFZJ7Omr+Rmbgg0OUzrofv76lAXELFQFYFzy0w5OyfW1glNSef8bCztRdpCylNaXn3ImO7/cOnPARUQvqiMEX1d74o/21QBkCzdy0Uck5CRVxPMLM7GP0JKDSsKAbqyPHCCPZiIjOjmP7C+vhz6WnWgDTW1NVfzbXcT1GucR//PpoikPXEdoDCqCYwzNX/p88DE5u1lFmvGbpUYzunsvx1ZFyM0IvaNRQYFzu7dRIBOZwZ5jGi9HPkDNi9vX1BS2rAJJeWjHL8+LVcuwuh9J4oJSUPN10fL/6C5SzcZj/HeFbtRLs/MwNtoYX+iui96NsqFbm/juiVdY9QyPeLsHEaVMNwJtrw/UJoGzoDncBV9I4C0xKCUGV+Ldc8j6RscQy+1TeY61tfmpwBBYZL2yBkQN8JjriCeGeP9ZdaB0Iktxax/Pbg9Q95yb7JDuJp2tehKvCvP7Zrq62V6eQN66UHsUiaeNtDC17Pvp6gGM8RXRAKHI40poq+ZNutfqCbWHqL2phIfB8nI/IjGYar9J4k+VM87QZoeHSywSWSG4rAzYCwsHYkldVQoORkp5h/xdPCrwkIlv9ZrQ/5OgbreaBJ2YGWC72euaw+AQLEj7wscfrOvUTyLZ4jzTmtVknL9WcJzvyKMfrZ4/ccDzeI1uJVyaxCt+IIaaOX/GgkgPFj06FcBzD9mYN6XJEK2MLnVOZ4R1ffR/rVNdXoi+TSMc7YP/wQgn3GiRgsq30FNDNKk77ip7wBfbctC/xtzEBO/0rXqQJPAG2fdBzuO0or1WE9+N6rIRObXIUN6VCfGTDx5Lv4bb6R0Y4cRNaAEBGDs6LHP4GhoOkc+KchW1+mCeExqCfhWAR8HPvc9TK/2n7XDH7K8E02KZNG8uWyNLuFdAw8lajuqw/PqW44drtOMLkh1ZpMc+1FWLgHNhacYOdG38RMp3S5YUz4a75vvSoQgZuHUoVp7f04vtEJI3Neyos94Jxj/uHAC8u33yAA5tC8WMoA3eDiNoHTM/dCEPC3ski8xnfCbcErurXYUbtT5LmukgpzaKw5VPDKCWMmG796n/Hy6gTWDe5dpfTlnkWadm0MEJ0fQ1rcdUtS5JmBVjUR5zDCvtu+qklzLafG/0y0kmh8fiW/qc74KCem3w0Q/GLjAOXo/oHd9rLaBYHSS57E2rd1CemjKIdXvxAvd9SOSOP9/m1Qt8hwVL47st4oJ47xjX2zDFfpsxE0G3yNNN77tvk4aiXfLW2/0hdKzDaJMyL/pAqp77g8UUULA8B7X0DMDTNV6JguZe8i/nbf4rvxQyV25U0nZ6WF79ztz2JxjBmVYNRHMSseYvliM0YlZCEBWuwovQ7FXQsm6o1mcztfpqvuRwRy+Wz08ESGsXm+pg8v7ksaHs9zXza7q5O7yI64N0UHX4wXcHtUfawBk4izLSTk+pN98p1Xcu1ZZVv0Sl7R9pRETgm5mKyjGL9Z/z8mziGiDZHYi0FM7vkHme5ABAc+HaYthjNEkP7H9eMk+SKHK8Zf2WTrbgB9LTM77eZKqPjwiYAbbwi8jvfRlIxm58BY7iaCQ6VGrn4wSByJgm+j0h1GMxiZADTSxS55/1Ly9nzI9IVyT26UVRLc1kZjCrkewjoXwUK0qgDeydFAIWnyr84iON3YXKmVuwDCwnisfoLni35kv3UP2Dw43+846BTarpPF+Ke4b2aw4lPeCQZGLDS/WNObjndcSyx48yUHPBthSe7337hvQExq5KoM8PC6Ef40M2OHTcdN6gAlb8ugN7FvZlX0t6iGr5d6dvSgm7HcinIv33kr5kTTzE6FjqROAYmUSkOSgYNFTpNXaV6AxLkxeUcn313L/Dp9rrVKUdhpj9HBwz1dfiFJVjNi3XCTP+h1ZgTf4Av5lk3eVeRNOIWdSoyKynQ4OPb7LD1S5rAVK7QEDjRQgrvpk6YJPsThgT0OsiCmQU38shF6UUUcxKYKW4LTvaz8IYovXhrsYiUJGfIASWncQ0RCUvdlzi6d/7sxic2bqa8DqB8Sa7ZzkonK0UYPsMgX2Al5HFnBC+K2hpIdM9rtHj/O3hzCPluGkSFDCHi1UlTbgdkCHRwDzvOTVzoWzx+gG46B7JI41PAosLXsyoJQcJblF484ySdv+hu3A9HTpIfoem9CqTqAdLXHa+s3CAWG21skO1CtzHFRYsy4iiJkxjomkYD52Ud0N0LyEN1jCxsM82GXKg0R8bKsKp9czqrY6S9eVY5Ocl5MsODfXa8XhZSxh6r98jccHvWRO3UM/8xQKBfGPLh4n9eFGrJsI96ARbZ41ZkLYWDEteGKXTAy2uxhUhg1pu5pESSvMk0lNSO11O9sPPr9H7rzpd9aGJLc9eksnGOGVy8ejhRBHZ2zGXyGj6hYo+mLS8YHVqhfFiT6nwgi2ozxTvjYhHUC2jydDryNW161z7sSgBu3sSntcLp6s/xloTy+vHh14y2+MbKfF+birVAae0nbu9ngTK1f3r+PRHfdJ/R7zmzYZVCyZsaJfUOfmN7yz3y1X+lcojcLfFscPLUplB/XitSdL+ZENNjYaV3JP6t+h5JJpLVURkKVxbBcHXBLhkgP3cXS3vdFz6/OhqJ0t0echpMXTOMLq/ba8YDLt23dYBZ/g/MF9xIzK0oKZeYTch/er2py63+12n5QaBjr2J/UIPBJnPNCPNx3LzXqJQqaCuI6+uKxgxL0Qik8VNPsCos2JXa+obKmCRi/IyzSuZeCo9kPGRAuAgFbi6ObaQY9QVW8fLRA4ECbOeQPgmhiVI5VYaikkPdEKkWQ/BnWHrlH67PM7sZUnMweB90toyrerzHmoz60eC2e+cqXKtvv5rCK63zYc/GmyVR0VFcni7iobNZ+PCdfMTeECzSYAMzb+inmX+3W3hw2MYkTgKsNIr0UYqkZxyn2rKmOGzH3mIkOZ3D9rMMF31FjM62r1tbOcXq4f5JpHEX0+vCB6dtmuFFzKdRF1KH+M1F0KGOuerPn9VQIMNrVZAydrAENVE02S4ucyqLfVR9JlgWyovpDkp2jb0Drcc3S4OCrCk6MNGinEUagTponnnwemra+3yUQMTLJltHkOokp6B22noSDIGjxedEwroYfkAS7CKATPBX5ZWTDRIcNOWU4V1vbdwCYoaYZCmcJOGdeCr6c4n3SXSIJqjHg5CcOT7V8oZVyZp2CMozbwN+Xz1dyWnfoVpcunsdUKMQuHtLEU81KwYlRS6v8Jjhv0CxeK/dmmXaWj4HqQuB3c8qUwbPScgQtpX+tX+2hZDh21M+eVDeVCwZxICLiEVZC1IBHEPbfwMb4WgJOzQC7SRNS0jQ2y+YAL58ibpFKX/qNUEBxOz6nQlnVAJIUkHDbRcFwl5Oia91qxzjVFOxBATlSeiFfUD9g5R1gc18g7ahVF2MOVUvUW98C/YUSEj6hhYDhtaMxlQ9NFfVi1K+UGHgw7iBeFUY6LIsN52WRFzjx9WuUm//VdHu4QQ+bzCxZR37/kc/ZUXmDkWE26FR06H5i4hsAIqjBDXbmtRel+azX2CTo9QGnDbohksD7YVlRomshv3/Qf6PvcA8LmqgGpgYK6HDU9eQ3qHyfUDiOyThJ53arX6HpeOY2h1qILvSPKBh6JodQMdg1dw8UaIORWDbenoUqyso5fqeyj8GvvfDOPgcM/eCjnnDnLXoF5/n6NPI17wsqc1Y0Hh8x4uVVM8ukUcneYeOOBs/dXgbrwmPNtU0uiKDaDbIrlQd6pIq8bEGKuY4RHeU6c9fzEowjgyBT87KDx2mq0caZ06zVAVcK7sMG6Og9ebfvVXQw1JEBG4hOxdh3j3KH18/GRxOPH85myvsgjfaoPA31c+efcf6PpsJYMGyL+ZrCYSFpic515DuTIwAv4pFSiuIIb9pT5RlWQGDB7nEvj2pa3E18hm3XiQIWCKv/DSpy5OuGQmcimobgQ2hXCedSgs34odN91taGh8DqtLIrBWZ/3g5HwXnzc/9Dp35dLfL8sH6aikLy+Q36ejLchGIJCbQ0vJOx0gKo4FMqG1n9Lb1YNn7HmmXFeNyE3YIddj4hCi/m3hs7FyYHmcahcNMmqiCIqgXjgfg4R06vH8aclP/s3GuXO3k9iepnaqK4vjg5vWPjSzdLst+EhDSh0qZiIAO1RscracEatuJgjmcMTNIwaHXpwKG28d6kyZ+FM4zn2cZRWMpGwlPcdUpNGF8+Fw0aKBXwwi9pYrfpuOIWzcUkZyG4J1bFvhR0lfLS7jFmQMP3cs86JdtolpmeA/wQOQjCN0oggyddocs7VWiOXtUGj9Z3BtK3aAvSTO6GMDqaUmnWVg3T5ROzXy7JY803KOQj+iH0WzXZRdN8/WYJWJpWZ4ew3NNkvTuucx0KCtQvYf75l1rNwIWFkoM5Kru95kteW3QModTD2Txjfsrv11MgPF7W1jVkA2PRkYk7rPQDcPJi4LIZuFLE9xVEk36jlo3FSwwgZnU8ZYP6vGhyCYmSeyqAzucjhak+tZJQywNedh/agibAk1WBHhr9S3o9B9huKkdPHH0Bt6bm9sfmV+OWAaGCfxBH0P3kbiYj+FDcnH2XoYNOP+Qjgl6L2OvDDOfrjYaHgngd0rveCpf7p3quSJ2BfUHiIjvr4RTUb8j9jnpyYNoyqMhHvnYLFW3g40jGN+Lu//sz5JJKWb6nPuIh8Rg+KX63GWCH9IjrwwluWgi9G+sODRjS/rgg073L/iIDuxAFLl5C+KNWlFyK4sFqQrtKfNxKg4u5Zo5rXF+fUYzDwZ34b/c0ncAO00EupkyFUejbXmoXxYcS1M+AYER/BHfQgIwDGlBwmRn8P9mRcPgzqBWL2R1Dowvo2TL6PFNA/cImX1YKRrqpL/YS0hyedSEZgUdDsUeTpR2/7z59Q2m6AF1ixwCA4V/x6Z7AzOWRp/tA4DaMEILhczTfB1bP06sKN5ffaQOTyXYwYAA35Jg2Zpu6/zbAzr6gXAEs/2zl1yxMhIBlbuteTO14pa2lQo0aIhlRNhGZlQBhcVclD3r0D0gNBrlUke+ONaLOmw+pg/2+kYkCK66rPsc2YlP6Twwat1MIJopDzNhj5UGI6HNfOPp6RnhBL1zuA24oDDAg1zIJIoJb4cekw4mHg4EC85HRkjryapcat5up076taWuHfSInKJjlMlBojyxedWrJqXlQb1KECPlRpCJAQGn1nhT3jNrBoSxjn1pnmVPkpjx9d1XZ09GTTk0Gnxe8eIrRR2WfnHHubMiBaQEXAa+VdOxBELAG03YDcFgFZQcNOhPtapweQbU9s/aZcn3cTJr+o7DYMZwm3s2TgYSSHi38rqjOIOJ2zcj67MTUbW/zWzvYl+aqp/YyOFohTgAxFy6MihPJjcPkOBaErBq/Qn43Tn/RLFydzd26Dme3rjNNtUGaf4sBT0q3uE7Ov8dMqDVCMC0vGyzrX2gpqU5BJI5G8T+DtSYz1a4exBoBAwGBAVOQJm50AQQukJtuo7FwmVXHt5MOw6ISSOHmwHDUVzilJRQNDHdv+jmhmLw7HgA56dco0i70porRJO5mCkJawHyeYBZoPc3elQE9CFdm1wKDxQq0M3mlfxBtopgPlS7SaMYsnKaN83UOgyxivtnOEo0oVrDKVdKvknNUbFHxojcl3+3eAyQdsPUf9EZaOfSUabCyZEIhfe6CI3HwSPtjzFV879a/oNewuwKUGN5TXHS9q8BFU6YgNay0c4MFqP/53UIhS8k8JZZNcXsEvi888wgX3zwv9rLhpdvUTsQPSmS+n+ph/l+5v5jTq/+vvZqpxpKduvkEMAEQSr7SqPZq7rC1pryLfSS6U1kvmuCCfbXaG4VX+EmWeuXIrQVsUMzbnD9/HdoLvALrBX+35pyQ7dq9OZQEfCM0Ft3LDzNcKmLnfGYzg501GC/8GlHHsBb62f+pmAAcIBEvNLC0k35/oTRxjEg6RzwT3Ck3yeHQnVmDVUFugwg/NX5Ik5QIwGR9JwAKl7g4nKdFKRmcmQop0mZGH8InPhCQVqvnhR/5KCUSzGgiPnVNiDnCQQGExpPH5Bj8NrQr2cARe22h0olTSu4asSZNXK57ds49uD1tl1iJzAJi2aPlXN7wEGj32LE7jUAzTXhYJuHph0evShwYHEEWii5m2LsZwbEkNHnfee34nrGunmCMRf/VycLdv2g1KvY1PZa78DpoZ+hdJUtHDmHbECESgBbIJ1fDTNl0lz75yrdLOaTfK/lFKZmPYUj021jEBYQlC1opix8SJxke90DKsAiBOfLdUYRSa4wa8nVpTJDRr1yqZ0frakAQmxvf4j5Io1HNqZUzVFiQ+nG9LRBcuFIcZaexpR83Gke6hhMa5d1iNomRxDgUWzkXbdn0vrYxulBovxZJoYvrVHW43+a4SgHUxdnuoFQag7Fvcoc+WA34nlIYePXzVWeDL41BZ5LO+smah6NuCuEOfQk+UqMkAtOL5GyIXz4ZWLDTbCEIihLTZBqMnXUWHDEm5iUPNAEY2eD1C80+kw/Q82j9fMrGtDEoMte+HGDgyW5MVelpBhBtKHjkOQeY4Pq89W6PGnsv07Todm7PpZ2A4CIZyTI025fV+C//+m7z2+noSmptrJbJwPp8bPwuiYEy4PhJKAV+ONfcxfTzj7A+3PfXyNKJph6E+738OlnUY+0VnhYf2nAIyoLrgTul3UjCoKxx+2RpsLsr7OxBSC7YNAdJzXDkQ7d+0nVDSI1aNxCZjGaSNDWfPmL5nHLswKeYiXOvixzzdyg/Er2mOwYPJtS4m22ylhjAiDbewrcv2cPx+LSUOUhcFIm0OIigOdiqqW3UwzqxtG0RXobGEsXm1T5ZCSF9xkljnVKITLQoBBU0jzG80mHTFUEBvn5aE9+Dn0kiuWV7OFfVMyo99Iz9hU7fdsHibqk6+8yLnFVMyQ0B7PAYxT5BENdFQ8HJaSY5ecJyB1HRwe/zGpsl+HffKaQdtEpjoqBMdehln8mrSa9EuRMAc7HckRYmlzDyVE3gT/l6Kew3h4KiZihRFOdadavZ8ofWupz5sa2qM3vlFourxW/TDvt+SZsZrgUAXApm5DLibWNYhnzGWdUFaXQ0TCXPqktm4ynzZGzHNbmdcGwvCKLlbOG8te7uXbpGLJTGfeeVi31I1n88qraSqSUbrG36ElfMUr8Ow+wqNmihb3rD4ItyjYExxjrYT2a87wcSJbV9oz9tLedQM5B9Ah9m/Y8Dqi8OuoUU3yYo7xJ3JX2N3yfhEZBijl08fcd0YpQkGqy3IPUdf6YgLi7hJWDnyPPUQm+3GX3sIraZQqk4Oqa4NFE9gJOSqux8vMW0IrZL67PUuocC5n7EfLP2dgiIMCzqUKzH9gY9e12gL4l4sVFnfAIjSLyJWg/OcAyCqBrya4uuvcUL9X7JxTAHgoXSzSizQOuUg0sM8xwUx7i4qZVgxsfkd7s8VPrkobqQ4BoR52YR0Vo1wepmrpR9gOQ1knsQvZFon++DoUPPEZSrxP+ni7t1bhVevJRjeLsXvE/PpnKuXete5NFwMX8XqW8b815x277lt4EKabcEBJtmBeQnyEG8Z2YQeCDkKm7S4Yg7/5MPuASRcnftrwo5PX9r2ysk8U0eKX8CB1nt3AJEZQ5wgwl1eXxvfKrKINY0stusMCqMhOHpOtY5PxHhV9688cWVzfaUo+0+fRf/mAJuDB3cOMMkZv9CaokkQzlYNNMraVR4KJesUx6+JCnZzyRnM+vViqpMgXv5WExtqpf18dHPAOHT01O8MGvNJkD2XSBcZ+UObCOAIuH5Pjf9Ss9YqDJzVcCBbvOE0yJ9HWwDYdavW2JwYiLDtG5fpnwJFaB/BfvZB28bY+oWxHTLwGkYVo1qQgckOyNXBRHNVwyMTtiq7pW4SMAFlDmdEPPVKzWp1VSRB4eFyLqdHgP+Wembe1/w1U2LkAxUAfn5+8eAjWnD6xqpF7HRG6qvaZoxMqVYIgv4P9XQlzg0S8l1pDjfF4IH1xcvn47+of3Y4RlPJGs0EGTJeQdNogSA8ajVIjT38XspGMvaFAkEqSfyCPv7mmMefscli2PH4KlAX5xnpbUK6R69xs6o/rP9mlUxvUUGY4+lwh9BOOn7X6mo2iQFC3KZS32kVUQHaFb7cJ5jPaHPnKzVIB/eHw2+uS99RXAwKVXvAPMk1ZoaYKiVPTfxzqL7S5wpsSox4XoQVev9VG/ipC2Q5luvcDv4gyHUwGxS8fvY8Pg/aYJn4fmMjQRUC7yUve0O+195uebpggFUON6vGUBuoPncDfIbHDwpQgLSLAR8zTqdyQ36sLb8V0fn7K8gZ9Ljdjea0vuCqpVLIihOv8FgffoFZycuXMxyMzjMijARGHWFp2vvGplUnwgT71vvIyjjhD29K43Ha7/jnxWo+8IrziD6GTKL4rShhO1un4R5TJTSl/EVeHNh33G++iPiHFDRcZObcP/OkpLFpx8N8r/XnP6+8wIZtFtqA+BfBSQyrCooeMWkxF3DtDbD8Ld4/NBQuI28/dozsa6LILmEH5SoME2J7kQfWvmyBN3s3u9txNRPryyft7IGZuPutrqwiwl0Fn5vViLHZSiifiRL5e643q9us+1Tf0V6HTC7Bq9xCVt097XCSDwDOyAkR5rVwZqsLOcewYCLiTtGe3W1axzdHHEvpXr5XUgNheHmroJu5vnMTH7m7B/XLyANuEgKZl2hHXkSPO3VX0RIlr1byfDU0dOnkSozHufO2CVoK1U8X+4RfCkTKhr5x9dDOknMLxi+hOD58eNuSswakuayucl2qAcrmR5OSmADHlKr1bP0Mmnayt5xyzc93pYF0N+S8rtFVjtzSwMid2ZrewU7z5Da6E/2gSPCLIszCsxf78W6Ca5AE74tBmJZnjiIddvjGg+ViGB9C3oFhxmcsafNnGTHI6lIXTmwaCF2p3OCIpDc3+s8fyMLMssR+T5pwBxoRWdZccbbViGdgDMNiOpfX/EDm9KSZv0WnrlwwjNBZdwoctZQgTIF5wqh6+2xhKnvG2YBqSgywjN9+HjiRLD+Mku3kVN9Jfa14yO+Ag3HRkdB3aq573hu+bJO/P/b+EPVsbzAu/dpyup4bzzoKa4L4jWmvEhw5iaK0BGNuxeYu0M4mux7/HUKcVeWctetqaUMOfmi5iJt/KgVZB/zmqNZAZqylK8xgJ9t7QJHEk3tOSdLzsp8YcF69lvZ5G/iFs9UKSX2M0Q1r0ao9C6WRmaaYZaGjibjPhf+wzWa8242ac+tWJeDrKv5LJEjm0QBGLuvn3MUWdwBCkaan1Gte+NTX92JOu8slMpT5Puyn1N19TymcwJxxP8y1baOr9CfWqxJ3ear1ZSMOePSxEgN8mfEm7Ttct8+TvUHCw8JAV9lU99vOjj/uPq/fSpg7LfFwsJzROu5YVzhx6zh39+AFj7HXxUMb7wB6td582EA6sHQXWK2JGi6+6WfbBzYflhbEcAn8R0tJE7ud2BgfMSHTfh3JHj4NVOrKd9gULNGoNd4OsyyCk0LhaH1Wwx9MyxbwaFaBtF2r+AJN/BTg24k88Jnwbs3J9nZIaQEyUk2yI3djmi4kYRtF/QCALF5Dyz/79oPiq72d9hQjZRTaO2352b99RKOaJwK3iB5Mz8vl7CFpvKOV9hsRhUqCqvUt3EoRd9Ujwm0HJFYP/BlGXLXHA4WwB45hhH987GHHct3WLGDikr/a7fm5Sj+7Os4ZBJ4vOcXb/gkKO5mFJnsADB2z2OzECqCg0XHP0LdMya1PckZyrvdnZOK4vbq9niQdNtuOyQIxdFLn2z8LwavE1fmj4RC8FClnYmWSocI2WVhisWEu4khNqRkAGqx/wbPUIKAH+zzUssp8EyGbmHJ2v1Ih7Jzls15dFsMn9eJTXzdW+QBh3LfBhH3qkA6okVQy4V5CDCdmSC5qQJhmW643yw+M5TogkR6zaplK107zXZ2r6SqHDJEWeQunTumpl/wwN8niNhe1mfrznj1ysreiCvuRdoAuHCO9aa1yRKk5+4za1sDiXI74OlhAkfOj+WMZqh05VB+WqS+JO99E8qDtXxw/RyfMeXMay0B3qvTp6FYapWV3rjv3QA4wjvzstYisDZX1H6fQmEsI538chLCqn/V+Pe2UdnY13+xfS8lB6YSTO+Htw23Bon0uF4iId0bjpvw9OdmyW1ykC2U+eOp8iP7m7vwpnjYS8UinuEO5CrZrW2Gsx6VwSPnaKbUQNF+Ip/FzFDIEp6PMDxu/c3PfVZMfr7Oww8mCn8gnlZcGh7ygY/c18lxQrowne8mAuUaDmzGS2QBrvPQw9az9oBHj/4KFHgB9Bm6CNXnpJHkTwwNa9UVSGj8izAJALsS2x38S6YiuIciruTeIL3MYrGqSmGLfBbOjgJFXcOVutBhU2Ju5lQ47IqbiYo2dVcNb/3UBq0Eirms1nRFcVBysDVetPevS7HtDiJ0q9hceRSwm7BAN41X95uZJOvTZjHQLyHnD4sQZewX+hl+yWqBrS4A0fBEYEyrcV1Ssks2mELUesBJqvlX5lzQdpB7UnkhIEeLLOOeI3fPbdXYKEFpXdEX1KMspRmuiUWDfN6bQsy9z9FzLOVziH2svABHejPJr9kb7/TtKpg4O1w8AfxUHh+dt56ES2bFd4wqgw81K7jvlIQdPkG6QSZDZWwMu1T+d1gTUgKJkxiPkp4yQvwZumDrIfHFkRFxL1nOBSrpqCwxxxuykXM1WRaGoTns5Y+Oy77q9bxNajpYRQcYVmwSMlT9C7O/EtmNKwhrC8NA7F+65Zf3hgS2DtmOyJEHW8nQm4gNqzmHFyideLHNKAJcKV6c9jlmLNuaD0T4ZzbOkA4nL9sgmtvC4SzNVqhwjtJvyXWomcLnAJ/l/RzxgsKjn5g/srt2I9b/CZSCZuGY9JvTT/tp0I7FhsOHGQyWYyQVezn/76hYNcu4MQSfvb0MSvZZnqER3lqh1kzzmVyi5WnYXaElkc6KPC7N9ZnomoYAoHRmh5EJYMY9JByH+cxxuMqsVJ1ARskJhiwAQ7n1CR6Lm8r3JiZO2DT68gTypTaiOWCxcKm1BYg2L13QxoanqV6f6h8jlB1HDOuB8L4o03CrDycucihI/dVSDGBkE5T0IjyCN3hUhRTgwFUo0suPnBkO4+OuWynydptWXwSanDlDxlR0mqY4AB+fOq/jMWsGIIwTaiIBUNkFB9aa2/7IsrSZc9DtOhD2/rlkMw+e8FVEdHcEIJU6d+9n8ZUzA3tA/eqOCQFzPPk9IcU8s+q4QzzL6Gy3SEhOtmQ138RauCIZ/aN0NSOqB0gpckKNUvi2DUaH/duh3jLIdBph3Q5di7UZBrKUC165FCaVNk46kzwCyVmfiwBx+c06tr8hVgEKTvluG3b8M0vkxAt74DUQZWdSmO1uLdLqOx6ZgI0h06rEGNCP3XBaiD0TKJ4U7b68pxKIMrLgtFuiTp0ehaYdMKS+xFgTvFlfivU8CSGmiou/waV7F0FjNrfXEeINk7QVVBxrvYsknR7y29XEEeVM6ukBoEmCozSq5Pb4QkLS0QkR1EjszXRKCz5KluvOuR7XRhc88yFrIQkHEwIlj8EVCs1WQAI7Lv8U1nDBN0nvZYfn/4F3E5egUI2aLF3ELcFUYeBo65RvcgdvBnQYmCpMBlt5YM+DOS0r7SJvezRLwi3NrwcCyKrSZuJYF+IF7U0RWLQaDw7eLGIGi0Pbcoi3tKctEV/rYHVs0A9qfi52ILPkpc5kdfYjw2ukKDKpv+k7M1cMkFb8bLlMYGnVfovK2Mc7TnHybTLeVonoEDseLETELdCXfKVF2z8zGgo6GhJjwOKKZD0ONqE02B2p1le8w7UGkgDQp77XKMAdyDEqIkhhFvhmmCayvRTVkC1Z5RsLsarL6i3vSy1QDvc642fRoyJVw1socoApyDfbPUos0ZC1kvXcGH+CHrBtxC+Q8ej+ick5/0GpXjJjPmJTYT3Az42WLP5+xohQ1sqNq/ly1fmo+ZsGMM/4Jfb8Zeo0MkURxhkEldwcPmWCe4uTljAKpIC0to29bnuQVGUzsCM8EX2XseiDNbeG0N7CwX942MrpKijfyHMp9C+4jc1wxniWYpZEGusGcDCAZuW4tYMQVp/+IYV/EqBig+QWdaqxlrOz1s0bpVueaSA7KIEWmn3SH1EjSOQelhcNZduKvxxUKYcijyyIVOu72I4UgZHQTfANZXGmjqnFjEU1rsCCGtjlK/VSwZv3svaV+8n17VWyo6t3nmiKOOLaG/1cri8GZJmp9xRNMXMFyN6kNrgrzQtloiTsh9TsPzquEqUNYZfbSiTCnm62a8fOqcKPZU670F4y4zheFrxy1eDhLPoBPo2p5RmyiaftQ42InWBWj6rLDhViihEvcBAonHNmRjloko2JZ1JQkhnc62P4pxt9x/6Lp2gxgE2vMOyBlzjdE9h/Sj/EitvKv0GgBzNVtg9duDogX+ZdLy48Unu9rLYy4x8Ul4vWmZwT4DzpHEgoOLv5RzpBmd0ulwaW5uYPE3lRkzNRF38oVkJw8VXEUyqFSzcish9iCcvPkwUUHMuMW0beIk0BrnW5iy5dIxG9eVUjwH2qHjA474Jte0hP4MGB5K95rDtKUmcZjpZZrMxxpxd26gdA9qaO4IpxMuJvj4Y7khsy8WBDeDJTs9pc066yXMY2///E8YUuCgiURhux+6kpqXIE9oVuanB+OF4WinrA8UdUDcL5b1gv8Onbx+LT8UK4IqI0cuxLAlNVuC5cygEt+sHSaDYQcufHAY6Y5TTJe28OuZsNne+/EmgH7owcsENjq+xjvTnRCSKYV/C4Y0LCWHzexU6s2MbMK9vhZZT9Tm+2MdQW5MXbQJvmoAO59UVMraB6/HXQyRWGUgNn7rWyCvPyNHw1ms7LrhsCZ6eH2+w1AslVVFoFPOSpRfcKR+BKP5EUEcpDumve0WIzqTRbKU72lcxsBy2EyxPCLa4lCxbQuUpqwF0LSUEk5HvHbMiyoPV86VOZnOdNNkDkuTJeBtLGOfztFJ9pra3Z2Y3qW6wtq1KgbCkxgeghnaV3TkJvuNxuZ5l4RIBic7IPfZ04EsGLd8dTDlPD0bcuMEBIPS9LFNZ/qmPbfjrZ1MYgkfGH99OwZL5sGfuhGhR5eSm6rtNePu/Fxa8rUuVxltfH1cGiUrKhsAqHpFORz31iSlMx43Tdu4MDrdf47oGLBKhbpG+eOGMPedPXTRalmUzO46UwPpmwnHjB9av0xu8oi1a2V5dYc3YvPe8QXJYKNxB+W8PVX428ERyLnQOfsDQsbQKwn781C9G0XoXZuhw+QhEmaRQ1tLpnVpKqPzpesn3oiT2EIt2OjNpKnZX51gozx/TF/qQCUl1J/gpKaws6C8pPul7lnbGNLWNrLRLwKto87Nj1ZEO6smfnKDzoK6dKfYDAwmUcWzcgXk/E2SxzRjXpW9Mk28iuMfzLi3defL40BOm2r3H8pFDpHvlYHlRmgkQkrzVSlVhQu2xE8E0I/1Ow3aQFd59PNYo2Q0eGtlUXhGDJaLhuQlS3uJBQyldv+ZxVFu9tkN/z/It+PhRVmNmxnRRHjxiV6MAKMzBYonzTU3RUZDGAfOQOvJk5THUv+hwKzS9uWFfw9NWj/eHxLNtSbswW23Y6XOjsYRjy3NOoy+SzrbW0DxCGel/7mYKODENayB0PElkAS/tq5GXzOnnL6m7g/eAWIDx9qz4b0jS6c/cgfr59E5qnxi4AFZ2XWjaOCAxPdySlMEPj5SW9BWowCWnBj38914UaIXELQoSBE7c9lXuhV1HXOs4kaEY5wYjXb+vlj00HgKOFAXmLKg/ZYT0LFNHBZSGTonPpEY3+PBQbc0sEFyqnLuT+h3KBEZduNWJxuj5NLhukMsVkxqwXlcMUtChuQyogvIGg9XWPNRkJ/2dWVNW+XGMFeaeVKFaduEWPRhRpA3lG8qUc31y4aW3iex0UiHUWSdOMeFqcqJrhgzHtNyfFX2tXNhIOPTqoiDhwbevmKn6qm5YEEGSYFdV9r/B6pFautEJmCYn7ruqUwVk/bmwQ+3wQASGJLYmM9p5EKdz8BZQfWRdQEN1ySm9JDHBh46+6VSLk4hF4ZWMtSmiPyAsDvVlubyggj9jktNkUfRXzBDm+NbhkwNpyfATmTMh7Brf121gFg4ZfES6R9+NKqUg196RHGH/Dg01nDJc+JSXRorUdrLZ285kwQyUiDWATPCwu8SslhCfJoq3gAwcxbtm0MR6mpJ1xhQKTGwZoe7OmUspy/7SmmEDCHDU/r3TPG39eFCZ/xTv8yuBGqrghl9LwU+fK0wiXaUFuD00qFWMHp0duk3RdyJSWzbPaBusHYlv9UPX+WW8AklYevG6ER0GevIdcU7np3PUD2JcylIxluU/VhY53PfcC2MhrBP/ulTR7gjbLdy660WI17unmZQEhfXEHjJ6RuCz+32lm9nVcW0DR4ym3mRXJ1nCCjglx/LCciNvkJTJkxRXwKx3hq/75X73MaJ7lC1XcDU8YmRy7A9uFc8sq4XB8iyFNpub1Yp85SqCoQ9hLWDe3j+5eluSzNg4yP9DlCIfkNXuNutg/DwvB0iWu0BZywCNvzVFSJx9r/XpLm2Fl5UHp14LgCCj8vzL1lXKbNMMAW2SLB98r2SlkUVgRWAMsMU769wfJ0f3laGNqHA//nNLsawukDqNluY3J3rcWoOGmUQvsUrOWn56dREwCPLk1YZJuV8N5gLfSe7JFF8qKdG8BlCghitGvZfm33kcW4p3XxRFHavoP36iKCgTH3vlEftmfTAsZ5QepObf6VbPy0R9QKPdqwYyZ/oY+4f0gUf5Q8X4wjSv8xZ9PJhYC2i3Tu8JscPOXP/lWL/l+WPiIFPlGpi6XNcu1Z2aZcrF3aw1HoK8X7IGXgI11G/DwrhqVbfkd9fi8+sVBhWJsaePy0Y7dR6HFLvFJJzLBppnAGUJTgebnrmVyTe56Ng6PWwvUXXNC3pC093gt03kw0A6Tj8JhOtEa5XiC5hnT20jz9M1zxN+B4pFffmevufVUcfXF4TR/mwLbnCmjIuBJlqBpVlgZwH6YFOcdg7xy9Pkaok6R/JttsKeWBzwZOOdrSbGUiIAcNRS7swil3uJJZwY1BHPL9uRXxK+GQqkCtU7v6pa2MbY/48a0XKdirc3swJa0KFWlhmyKsf8HzcZotf3K4Le1fFodFFSD1RWbwOlwr75NmddrHUWybyrTtG3G+1zO9g0vlKw3Z86IPHBuooIA79fZk9gYaky7N0zvFXDJEvm6MCs3ub3xeiQF85UHCdpnh9q+n2ugwxyxIld0FIXe2A6X+P7GfuVj76RnMh3L/Sm7owoXrkxzd6eB3+PouGHlQttm5Zq7QdfCElQyUXxp2YPlYuyjYHL67zQRaj99dbQYs20IQewGuqiN3oMyJzG4gNWAjl3itelqkenIqG7jotPnM7SYRxQixC8LNUcCAM43uqccW/bDB11FcEK0W8EK1HAibkg+mh/U0oDyV2tJeq7Lp4WHrFFrI3ifJQTeke/XVVxo/INSLJBfBAvGqYvkg1D+SAH2ZNjT6tqBHhdpXsg/u11hSVBCZL3Eprx456r513ZrEy7kUO/RgpODZ6Q8Ppg+vhCLoJbQ6CCMjHpHdU2D2A38qxklvvAHsdQp6ocxRNtxx8aa4eQOZEPKp+l136Cb1goAvAvcpJHHF8Ko4Dv6jgFZA5+owYLRYo1uHDFB5jjj5+UdX8IdQhADblzet6ve9yKqZYTg4B6glCdgiVj19Tw+DEOJP3etdncDLKt0SmCiYT5gayVLVErcKL92eyPMZBDPvTFb5LNpfeNk8XpUJwNgKqw3onUWVaSaH8AO09wvmGt55XM9I/TuTVfArJXvb6ZK+poAYcM8Xlyd8qUn2dh+26BFCipuBDsQ7YN78dLzpPJIH05yQc9mZBYpFq/A4pzSVOOhZAbxGFOsDg6Qgyexjhnox4Ib2DLSgTHty8cQucPPvSmXPilT2SVWd9TVSO36/ziGR0UwM9H7ZjBPyYltHcV5owhebAqWPwcY9ESN26kqmSS9T2x7LYt+IAulnZMIRTRVG627Bl5eJ+a/LUBSEUd4UUy5XewiyTq9He480q6tK1GLarFhFuGGdvs/q2llFuLUUzoKAmz8d4LIAe1s58onTsrZlPhjTySuhO+jlzSzIrkEKO2BOi3DFabgLAwoSx2aXCoBJdDikNVVeFmQQKLbUrVvHgoglaWliYD6vWMHUxmbuXaXC92U+iez+nBQHcpS6aAdDjXi9S/8iqzC/0xBcMxamI3p6CfcP6+T/bOezZBCIzZwg0Pq8hn58N1sNNOK5m6nTfPkbsyBJrow/50v0zVabBVVpT1zmYC976SRr/bQIE9MWIKJGX3zGONBf7pAyV+r5F7p1AX21bX1bRXGZ2kyNXJejfFC/WusGSigKoBLELquhj8ivMZPAdVBNVPmXwcjCAO3yt+T1aeOHSNfYIZwVLnAjITCOqUoWULNmsDfSIcjc5kIb6Y5mS5HRy7wKg2cEM1Jm66MfmQM4JqBlAip5nZyJmL+yOod239nx1yI72t9FMP9FzIi5fStbeTSYmNDdmA8OrZeW5BGyPD9XsJpFr1QtFpVEDMgQc65zjXmQJ8+XjmVTwiPggcmufZT1KZ0fwGg9e4EZPV0WkdEvnkDcpSBhRPZWPfWxDZD0MFQcCUe9id6MRk2/tPKZkd8waLLKarwBfZ0Ln7k+9JXDzf6lu/B8Du5KOFC1hVIn0P1BcKLQN3o+WpBRHSaxnIBlqwB8xKfRzMR67d4bupFdTNXeh0TxFD2WCEH56cU88+TYM1LZuT6E6yV3cnhsclwgJJz4B6GKrzDZ/BMS/nWp5XcGEXNO67sH5jBzLGhGjByjw4u6wyDwPq6nC3oWeFUCWPoS3zcsM/dBxH8HEbV5TshifbZP5p4C/K9coQjQRgYZFV4WG7Af6WDHEpu1DqVhqjw7cSlJUhjM7nRjY8JUH8ja9f0wLaFhrvkJLKbWhkvqEhd7wnbjoyDEPniXUpYFlirgU71fJP+1rn6/EbTAs6y3aqOsZZuaWgEcs3IVgnVqnrgrU7SVfNZUo+ZO2JhBCPpdBrOtJ3u0oEOQJmAJ/NkGSlhICtqeYZnTgrGAEZypwnC7Fii1801tmuB5qbk8xaQQPHpeqbqlRVnpyJG05jQdRuiNV5u4Z2kAiDQ44wnWsbnrBf+u/Jcl6/oYjhsrW51N0ZWlG+yYYpQQuFABmCVe5ur+kl6g1sap6imQbY2osIhloyDVWowks6/VRKoO6153rerhi8LEVqswLE/VQHD2CeCdJPyXH4F2+0VkkMGaZG9MA8Sc6QItG3WRI7wRhwn09H7J5mwxfS00IcdKZqdPAOnCJ3yGYB5FYK+CCfMrohoVOLz+AJQ+vGz76s0OOXLcZbcjJsG412CUsImnzYpP9/6F0yfWy4by0HRxICnYj+i7GQHY29EJRNfxBJH8nW+rifulzKMBflv6QCBQ7OQ2saF1wMNyGqfSO5/eZ8o8UY/Ui0Dv7yiTnF2Fst4/2QtzDniZf1vAXC5qnh8e663RoEQsoOCFBb1QjEM/Csrq9TVrvetPz1uqvPpxUgcXyhNz9ry6Pe/UjN+/4B8RsiDfxQiYaATbO+QO8aGU+Ou7gvU+KOgXoyla4VHyem3rNtv/oXpPe3EtcQc5pV7rke2LKC+NliMgN6BA4XcdMre7RDoAFa9PJsqZkcsgVAlG2TGL18iFJzg6aZ25lzkDFdGlVveOjM0VRC4lmHFRZFBRUUqUHZ0gNEjtcEEzM6CmdBcMchofQM6JPnN/oSZF4hODd0MELocosn/+DBlWqPK/lZA6J6cD2oDN4XenWmOUR2qhIdT+tKToSlxFqwYQjMy3GfmzvoCzVoFT8BSgN4Ho8407srJVN16hm8LQ6mvW+Hkd19yXMwXi+uK6F0CPdgMM7XlPJQakJIP072ivXcrrlYJXwxUfCsmNzEzEaLOie/TE/9K6dgF3WD9XxkgRuP1hatIYhi7fX1n4OQrMmNNSAcZl2f+WmyujtApDBDF73c/3zpTYYUfFfRyUK+u46IJei1fEqKauMBKOu7npaGX7J9UHJSt1ZQiQP4JX1RVVNXBlTAlwu40OHyZcAgOQvscl85ODBmnsqCmltGBn1kX2ZOSENcfTgrLP4n493+pRE6hEhVKVjE/Dt3WWXOsxo9opIOBaWAwakS50KaXKcpbwnSE7X9YTbj65XT/2qoFXEaWEjIlgvoTUoWfsJHi1yfg47qpAgMM9JgVv4pSzKBLESPW//I2R78Rofwyye04JiM1gR8k3LfdybOIiDKEVd9Ynk0dqNccqSUV6MGX/n2CcpHSWzjlgsmYhqKu/BOpE0QlwYSVIQdSUPBUrtmyhv0RCVuzXorxW3bQmhpBYWlkobNJaJ8Qg1Xi/0V9eFiyGaYgXou+B2AcaXmA10/QknNtgotjnWtFy65XlWNmGRxPCz/Ef+08EQR1gS3+62B+TN8dURRtB7hmr/CwmmKvXJwodnd2i646DD4VbtOC8+yRJHFr9XyFqVMbVn85bbuJ645wRm7/uB0fzJR39g9ESo/uLE+DG+3Frnf3WdqUsZsPO6pFgMvwv9sxxo5vOgHqXt7jFFd+cozaF3lwTlUVvzkBfd/MepV0o+yyY4ldxlNg1PWZYsd5L4bHa0oqEjpTBXO+m/P5NAhYlFQcZ3aRXRw6u26F6bVQ1LoZZ9tTYXZigecY/gooXHVNxVieD6T8JwNmUpUd2F9RwTiMiITgBfa2GxqxoiQiPPqoIzb9AJD6iCW4afgI+I9vYJx03QWsQbqyj9fm7AxLyDJEcTf4eSmOJHQU5bPTcc794hkY+mF/BzKsThcrYOVVT6FP/gEP64ZGOVTZTKP8SPtB6Q+YFKXYoGCB1Pxlx2+7aP/EIKmAX2rwRqaQhCe9atMfQToDarnl2jR3w5RFDC6h4cvATu8Mx5GpUyHipurh812Uy5o0dVRAjO7bGovLoqHacegzHvG5sCm0e99NaQPMmfbd+stz+xwBacsXvSvSA+fYlV32rjNt44A9PhHafn2yacm1WWdzg/MV/C5JTy2cXVaPCBhvtU9OXuqz6dxITDQKi7sykGbf47X6lSfZHX5OxpvaqSvOJyjHX2e1mafSDscSOcpMq8cB5V9gJv/PS5GIvA42QqOMD9JlekXJPG+QUvMxdaBsM4QTcNFTDxp/b09azrKWQUjvQ2bYSniZODcmeuMEvxWDBdK3DZtzy3VkvCjb62H4A8t1i0MKvf4s1L015jzxa6/FkLAnW4K6G4tFAKFyVz9MAeq/eoJ/+b36OH0PA90I/6ib9Op+kHj+ZX5pqMzQmIS15PNPiqjJczefyb6dPDN905m2F5Vt6GSNw2H+0VvaXtnJsCVIbAmqsJHoAZy9q24cIa47kz6d65/VuSTnwRZZX79VUwe03I+rCo7MjcHuGy+IDTJMyoR9gIwaBSKiuD+imSDm+PnIaXXmANso7LYBBn9PRZZ7A635xEE/hPKIEuFVIxtoLI3/ww93N86B2n06EejcM/Mvubbro2p/wO5i2Cv9kKXs/WyasxoKDtL+KshmR97HIk6lIaXVQMnHWhwnzA1VIn2XTqNXQymrOWvzIFv23cmu9kLJZlw6r3rFB1UY8x8e4wvx1QG9lY6DEcwUYbNmGSZX6jImUfsl7SA3olndnHJgzm9JfFXR2/p8dC/gR+Bdriz8O9J0fbmoGFGnZa5WYrVsvJ0ujwaTikkYOnFZqRA4mlhlsLLXWWwUE5jgTAFC1yKxYqHuiUevSt9Movk6mEHTwtCVRAKXdE505/tzcSosvK0gMHAawWfM5bPyFrEMBbn5kjsieJ6of8y+A3uVGU5Ou0D1JdjB9awkJJwokYsVIL5gHr884J/6dYvqng56/J193mWHGhNS19XahtwamjiBn5PsBuqbr4G7R/X/Tg4wep3ghGnskf1eYluj8qVGFP9wZywLzYsVwKLrjOhQlmhdJTObt3gf8TNJS/08EmgwX4uKlM/63zPuk6hrEs1mlMO6Jb5bkyzbe0tkK3M0nYkT09XsZVuhgDBijN4NYw8n8cSI9CG/HkRxhtM+28qZAH+dlC9CfcwyE/WPEM1HBQynvKaw6qu/yZFEsIjSjU6yRQ2sdwQAOEysDIoNTTM+B9cVDspsjrfGLLQ9Esu50/GN+0HReQPXo96BwpEAwE1nnZEzpmphaI1CVzLXe0vSZ/9FDO7WAAYApKxGMPHCVNuCgW04VnFipZcC4q5f4XyX4IIWoKWLpxAPiDHvbcEaSQb4ECw1qLSgewAXdkPXSdOqxOnjtIFPE6M4ZS7q0sztLPtBd31cR0nFC7r1rUnxHgp9qk37G5r/24p2LWnfJune2HoQrH4ZpwDk/JgdcztjXZXAdgsQuLIB+RX9KGaROrsE8vpAU8pNWDNVflmWzSKv0rUWw1MrQaamZPPiGdPnUtuEApfDcsBAcdfQlZEzZiITc4oiLavI8CnmFspfIArd5tCVCW7JYZr8U2YkeNlklohqC1SqfG2M2z80y4X86/f95RbukEJNxaa7eJ5WQZ4q2/rNltUGFRI1BjTA18XcojJ03QmIdt16Pd5q1fS02k5bA6laGl46ryxgWz5x5SppKlU616rqBBAKtKwTWQUxGKbER6BhE9gtmGXzTpSW7Q5RnsJBAkPn3tXI0w6hBwBis/qVjRMbWxBypcDmlBjN0xehLRwuDQNN/Ef0kZ3n/VefUVZmR2j3qQxGCFnFCCTog3P0Z/PCOiZOHM/h0Kl7N4loA2AuQv+AEppQYpPxkCU17et/dJImrzzxlhSELStdrVs2djntGxWEUu3mtnm45Hv/YgPylg181jipLhWXKcI3GCcMi/oidLGETCwb62eWDtJk4x3FobeGKoule8PH0PrX8zLAAjOIVYTsowP3XEP7Zi1sV1prSdlCiX/srAAYf2VsY68zKcONN8bEMdDaYsZcFzXhOVCDe7h3oEk5GQvMPrjc2UFu4if1eVD25M93gEdhicLe1QVuebNKqzPE63fO2L8JjhHrUAUpSN51icVY1F18rKlIRLQvLlLS//i/w8vbAGk1Rj/vn5HrBKB9ob7GfBVRpwC1tgMKaTvEQZZPwNSVkmvioGhY135BsnblkpEcMVqKITDvWe3X5+F9uRmfoJi80VHpnN99njVU9UqcSekPt9PwiyM4HAgDkTnAeOA1J0KFvhckGn2lWw9JaZSqdxXIJ5e69luQB8gxTHXaDfJVYixBkGh8bjbk3gFsb9whO/S325cBxbxgvyRZ8JiJzMejQ0wm3Qt4AuIPmuvOL1Yz7sPes04onylpXfFO2pC6eAnMymqOQ9mOrAcPdq2ZRAZrU1QebO09h2rpuXibElup11MStWif9W9eAmJ6Bo5DoUce3DrkQAQHhSlIIN3p1tkEL8YX7D3TS5LmDc5dz+cE7f8qGYxE8n79dGvR/3Q3qOgojjBywWNAwGwtDmABKbsKYyFzxHmQxAowRULfXPiGe80Yl8Dfl3RSLI9oPkx3FEvWBvPW5+HLkwPzU2/zFOfzY0a6H+V7HBV8Oxp25ew4aLDezyRReZ+/geHljEefoSl3S6mbmIOLvrerLaBbcZtiYCE9Tg7wchDS3QUG9mR9cz5JZxtO0CWcFrU1mmo8h81TxyOGxbnJj/8r4L+YYjXzCeJ1pj44Xo68jhnnl5qHc2qAC/B3IaTnNn5ehw/dzQ2SuN5gegEmiyR9aNhQqgcv8OsnwSvyz24CIWPbheERH4HfpvmCM3Nx8qjQNE14+X+nWGuvAMv5pNarbcn1hA5Nbk+0pfyIhOzO16o9Gd+/NdkWwF5X/TqvEykV+XVP1tagjgUlRiIRwpVAg0mJiNyVvXuiO1BTCJ+EZ8qUT3I9/TDvKTxnwe6hb9ygcIk282ynwEp0HItk/Ay1watSxHi9xax5Ft6UK4YECuOhsiSJRKPege84P7IRWuFBal1DC3cKCtrQVomxv6V2/V96vZ36+F3BROX9Wj2bKvqrOOfuXzL2dqIle4Xv4lpZAwPmZQJgEw9H4amUsKo3UClHht2vtyLP0c+g+KkZXPAj1yItKj5PKez24DzjU0evtS/psP51u1oIQqTodzZCdTINhEQx0GwgXFwB+AUTX70uOU8zeS0DjNT7p6FZrmwNZcN3YqnygN5UF8yvaDjRON8FuwXqkqtJqEH+h7y+unzuwL4HpPa+OIi/fHKQL6VeB4+wrPXPMHWs2ewV1hRRNRY6VkB7z2O6tyPtrjgsDBfeJC6PLiciV32cDDbNOqAiMUWTDtosXKVkhVPfzFfdrLpPYNAjXGhSu/Gtk/VbdAe/Tmcj0OhFnxJqWjRs74UW+GZ/POi1I+rDCKdfkUnV0m+0ZoXFXRnauUagAxoXsXzxn8XEDnjWnADsGtJo+AvCU4z2rgMXh+yWrOk5m1QFv58Z3iSuceZtljO1vGDZhdiUmDyobdprudW6XNREm4YxS4Zkoyly+gVQKQmAISAZC8hwh71BQLrLNvt544OxUIRcIwdCh6CcDE1t9RYxl0vKLQCkft1tbbUlgsVNWgtXyt5mHId1qM0pMogBusfiRydnBlioU7Fuzu7rLUtO+Fvr8pg9FWoNQ/TaGq1P3O5TyEdhfNdlsbDkYaXQ+oIOzLcNP8fJky8Z9roe+euBgbBN+yrE3QXhZZziwz/y7pUqwtwZ8ss5zPDQAIDZuoWx/NURieQS/qMmNmotG8Xw6SAryZHFzIMlkugHnahKAXQZ0kjeb088rait33SVfPW/d6xAZMQGZqXgsLdK4G3ByfrS6Eu/i8UQpJq2m1yGPsASI9n513lHXJxPn+xKiK+6sBvXt1zzazAlCm+aEE1S3tEcRp8p6aHWQQCDknSBPSq9FUWpj7FpzcNMjD25xqlYxvm/b2+IpIJ6UKPwbiIe0SrKdZ1vDDNJbCW+HmemtzwuWpdtZPtFuT/C4YhcSjjPQRs5D9oo42O8B5ynsHRRgn7FLNMLYS54eD1leAi68BEuKJXC6n5eVFWUnW2My32rPTe1nxwOL++WaRGtXinxyklfkCsQIlAyqh3dxWlJ5EW0ktkthZGvqnzaV8dLwnU++S81k/pAVES4+42edH7zsqdaeIki34WZKz5i6rR+r2eStW6eRuPam0TDnPp4vAEM41ejiRFqriFepSYwMqHvrhuThsYSBbe05vUz7TommKthZDITfMAMp2NAvkhlOWAW4Vbq0w2tcoibK4VF72AsFUANB2HFgDYzzhqOG5VrtZmN/QuplZ69FL5WLeJN9auwag6VyPX9HXaDSwemcx7l6VE+AZ7I1dJTBN4fGKgrn3TpuAFKyDIjpsN09XWIjBK4+6tlQ3bVf3WFsHgPpSkiZuhGe78NFE8afg7rqts+GiMib9zwMRoxBAhHy8K8FjgUCpMEZhSk+EXJVcFAoj2bEf91bhVMfxa5qeBBXfdbvLJverHGr0Alc3mUZqsgNX/wnqNDRGWPN6bvYt4ynV6ATcX9EEwcLLYebdflY6NE8DVKyDdnfUMIXav1yRpogd9HjrRcbtyXGY7N4YG1rIB8foTOEK0Qg6YVCtqJkFovUwGypfO07ku3TC1WLck8TR05jCgqEuczjYgXbTkA5WEWKax1fGLB6N90kcgZJParcKWfghtMBZ5iZyeU+EbXZ+SoepDAdzRLetGo0eF3gEl55bL4cdxhGD9X2e4sZPmeXw4l+yXKYV+Pau6NMCIIugImP/5Ck+8uDKQEvvSaSnlyHVkFVKLEqEyDISBFZd5veBanIZ8+AbquxnxjGjkzuoimsXpH2rf6PEw6eF3thYJcQAnqGEQ4vyLPYiVhlZt3O+8sgkNnj+Vq+QuqCy4JHqoVRWUYqhe6oZM6nLB/4PYWk0DrrHWQkb8SpR56NXQxGq6BWf+agZVAUeG11V+HEN4USrwjC1uF0Fa8uAPvnSA8L4QIEa7a1TttxHu1cf+hwluF/iFK01W0DWAZzTu/4593q0LQ8Y7HhfLVjMXT0HFPBpVMl8NL+SmuX6Usit7wAe15z7ggb3/9YE6Mw7Q5uo4o3ykza30J4yDuIJzjGsA8kE66h/IQSZ7yqwcRQryGyGudISYkM48jQN98DGjd+9XIq6y4MvEWz6xtIhzKLkASQkqZmqVrCTexclVm7Zn9JD2j9Q/Om0vaDOG2+p5Vpow0JkC/Bcycr6LvcCBLewYhDkANlw4g+JTwu3L7fuWaSR4Xbu1LJ0/ThxE2BP3wt2SM0QyIF7sqKB36IGLXeHB94fIOHBHUyXduOl6xpX51rQMh+l/CxRBrCWvmMZr5MEcSTlTVMg9ZvvlSekbjOhSiz7CPgY2vBVzMtWBdPJZvuadyFlxvZTrexfz1C63qbBxDbnCA/cBq36p2dPrDrp67lxqIoI7s7jW3LxOuo/dXZoMK+GzJanNLxp+lbB7hCOU4dgUSPNMMF8laIOmEQph+JOH+63gRh95tErlvOuXepdKKp9Fb2nucCkEpXuQm3NgNsQukpRHdUBmN4u+1LoZDeIOAHIgwn6CYHFQuCnzZBcDAfKTD8gNz4tIZ5dnTTY6+kjWoVywtqySKmdmGqpUNwt0YH5dpwo00G34iIrMyYT9jQ/A290ZJjoVsxgAWo16z0KzHInxScFYRQlK4Af4Z4lTJtrCoq9KDwq65MhivDBUNDQDT9kZkBxdetLl78gA4PNEE15uJwSUdB7ypyPr/nTanLs2SUPACrOD+25mJvrsd246YlCLNzu4W26sP0KUS/j05lbtharMt9EZzJkgckbx7sK4XJTm4CZWJPtB3DD0/uH7ibNq20Ixr29QtFTzla1LviUD+N82LtWdzQiKrS1hfUIbs54MnPLV442/0oTZfrj4nv3Ge8K6rjfXwMsElWzADCaek6ZfOX5owpS10RZOb/t+G8Oj7f8RwxUk1LXE9k1q/hH+Wx6MiPjB2k/0497Eezf0r0TgfC9ckelIdYokWBlnvqPA8sOTjDYAE1sgIdMhYgOFEmm+dplkat2ZnqCmht0ZMlNp1WwSVHI7RFpGrENJmmyWDdyZGWf9BKL7qQNlVCeb9n0jzyCPOqVz167k4l1meFyC+k+9/NsHwJYZwp98LeyQ7xoTgybZcpy4udpdubX/xBGlXxGbozZhEtxuP1KbuKVr5xevTm3VlhYuoXSjD3C758IpgDAVKqcW1Or+7eLI2enZf9gy07HfRHbWNarqgLsw50+pDm5FJoBOMb49Z1/pJ240+NRO1/x7Tg1FyXVkk6Ne4H1D8k67BAyZf/HLXX58qQzsiTw15GSkfC4lU9GKp4nr9oLBAIXQViYMyEpo9B+EfVxUD000ag0KLsBptjjZF6ui5GEl3zKmRorVVwS7xbXA0AF+Nz/J6XmFYO8AAjVVYMCgKAOUP+3D5ykA/0fKSsPLxTs+Pd1OEvgSGHJR6empNVdTEos4pWDnJnn7vxNtlk9bnS9QKnETxS3hEz7HwiLia9BS0fAiIW85ifdR1oylarjm/WZCZ473uhuAieC/Yk1N7X6Gg8hUv/IsPs+HR3PK1mxQAvW3WH1qswnlECKjnh8+T5Hy+zdpuRwh5SRlcENrXF6REdIp/UnwP0FnSy5+fCbRt9elwlfc+Q8ygHjMpFcdQBORFYzscPJ3gAid1vVEAhpRRWX3p+qjqZSARSsgOyR2cJvvBxO33gkxroi4BTnKoTTp/iK26rX3KuNyPNo6pOilGmhw0yeD9NhM1azS7/aWhnIsHwrBwJ8c47mbNAzexAAx9K9jrY4OMA5tgHxKKD80OxMhM7OlxnWcWB7gsQImIsWIS7lfFdqv8NlR7j3Ckc2ximBii9/25iu+Z2CdvKOHFxtNq2+PWeI+GFV+sn2In9qRGuMbCqIdJ6dlB1Ns380OeFJPCz6TJ/XhoL7VXoOnJFT59WAg13KHLNfliLcH8GM+qOBmxpkX97XTfyYCoee9q6GJJbePkyoy8W6Si1iLj7aRAZhyI2ZT0Fp6zg9moeCi24ItJUgXgcxWnrKyBvkamFV2FJv6gXRIQwJ7qM4AsgwQ3UCGR36HQ7O/c8iun3DGZG+naLlsorvVcHTFO7GiSH8SYzJFgDczWrP2IhDcy725l2YIVapMFJykX2MmVkzceEG5RtCK2oDGw0RSdTWve6DbI7FPXEPGZ0HPC0rmQAOH8GhbFWeXz6eSjhRJ+j5x6+9zWWdIWCnbeMDNDrlHcikSUOMBNFbQAFiK670sbfoAA9uUQw5xKXAydMAruXJIFA1C0wTv9hE6UlfvhmpAzEfg0NbNwA4DhfjZBUqN2ch+vAv77VsETDMJmkkAGQTfIjbbyoWwnd086LrC2S+ysq7LSCFu3AnMmqxkjrCNUyknJvnMMVV5uv6ZAdJj3uBPiBkrY8Of3I0xjH3m30qXo0ZxFNGjwTteReGk8sSwNed9l1mjM/BWvfpiFyUXENB/7zrHThdmD6EWJvdiMOBpCYe3JOUCLBTv7cyrf5IgWf9t03/38Iwt5qzM97lhPV4ClfeFizbsEje7d5ALWA137H6v2kYqif1ETASBoeixh6JHM/liGRSlkWQULFT7FTscSI4oLl/aI14mxVSpsC5hmR3J7abKHowFqI6HEgBEskF0OTSnPgeO8ntuv40PhDrkFU64wLW+CPG/Up3VxjJpkAQ8HFz+ku3LzEPr+yJZCEuNxPWrhLF5upJkrLKVxVvac0UpkKi6I4MiIdIMjWIgEl5lDCPSPSg90NyKYs3Gh4j8Bq+FYue/0952pBMrAqe0EYMJh+MgyWV39t+ju56sUGOMKOChn1Y5xKM60wAJ0QKvZcOMQLMWe3t+whqqTUlm7OUxkfLI1UOsWg1s2GQUXX995hqg1Je7g3A0Iy7SAJQDeDWCc+vv31D1X0CHelr93NmbSCdqvvBDevmjzXD04yyTkcOm+/uahJAVqMenOqLbdnQEJIgcRN15h6ghKLHC1iWyJNgmFlFML5f+UWHWgfwc29Ju0YyXA3WMTef/ROSptnGhux7liyQ1NTFsXyYm8Vp7JzmDqChqGnyBv56OBVboQ5waj8j7ELV+v59b1UqHIYoT/DU0uwAMDhuRLNGMiPRkTk1qHz0KKDAibEVX3Kopm6XzzQImTGZRjEMLq8zrzQkw2p3lfslkuqxBEXXx5hDbg/2RacDXW1Tu5zyDIf1dexnBEf5GW0+1jxmnUKvPhMpcT/Q1jftABjRAVdc+pfpVrDbRh/mFeZSkkYgEXqXr5NxIo+GKrohkjteqV6k1T5QO2OBgQJbeckpuI3D9ZIiZvBSpl/5FQl4yxX0ZAXvS31BgjhBd3avFSFyTvaJHjXCbXkVgBR23eWUlPNLqo+ZEdwx+A1OPx9OiPUtnXl4MtiZgdaulrlFjV/52SA7kKZQp3R8noGXNJUD9SKuz4DmXuxqBF6M0zQiuuOl71E4QNx4TTf9SpQ3wTyWvdT0yDsrAHKH7cYBYAfYo3TKexdVA/cN899VU6eLSi7MW4FmRumZGdt5jCKbxx9aljCzwNdJHu/jN550+AuaoerB+lWcZKUstgtaO2dNIpFshY/BhdruMJTgr3VTlDGLQhCHg53TDVBssCFWPDNShMagnpU0igFWKzy5Zrb/feSZ+QaPC7VqFC5pqL4r0gISGHZ93QPizhyrb1wP8HXzJC46k6/8xKTughrQ++KrA2mcxjUURa5F05jfZDM9JISV6h7byDIJtgPRopPijCsFTxsx2DcIBLl96Zc/Ic6gR2pn0p1C2ct8VjiDBKtcJ2z+QUj8SP8zsVwIWF62ThE1M9JZ1EfGWJXk2rXjINi69kk3Ijs9+1FMPX6t+DYBLJgN9k1+Jcl9vkSMWYCdu8oAHk/oYDglHrawl0v23JrplK1aajE47W2g9pKCBsUfvYu5BjUNgLLN9ODTJ76VCTqZauxWi0vpXuLfZi9GjCgHOX1Smf2lzIoHTOhH6nOgBpqDDRrBW+1c1HXoV7x91MIihfQwRnCbZ+FWhKESJrQLM5Wt2C7B2UySdpG5d03GvM//MBpEnWL7evIqJfsXcpDL9ww3xEJ+e5rwGs4JKFpq4lPgs1YXdv5dPxwW7FvKQAEHrxuPaCBenjSUMaLWxpC9q4AZvhj2RHK07zAWJHdKbznLPROwXSBMYk4LovJlu3529rd3GS42yx/8CZ2tfLqHm/fFxbCRa+IaYTa53vBeXBkkUXnXr3bT8WgJXT0HHDVqEUka0SyCJr/CL6rjFNx57aX2q48kv1H6PSQkUI9X+ZEi9HK8U4zyGe6BQjaTYNt9G0/nu3ZKPuuaZSr7Yd2V7KNC4N7tbWrzrcg/z+sUVK94f5oZNruFw1o5tUuxMxcnPh5DQiGH3DXYDZl25Eu8EudjzXAiDYKyI0h6y7MTRTZR6uIqaHZgK/m61HP0mtsU0RxQWs4gDc73GgH221lRjmdepnLGdnOA8vcN0tME50FLDT7jYZXZC7hAYMHVg1+ddsBmO0qol9rEhIBEjJ5drHXRTAbwaXDVSW3GmKnIipAvbeXXYusjunBaNSlkOD1ciZ7fHwuUFhKP5UGL/l4wzDphRoNp5Nj/FOnkoFEI5U51Loz04Gfa8qvAMsbljlySDuVE/qBd435SRoCoAp+pJL590tWrTP7/Qx8ED0er367N+P6ee96VnvlLct6yfE0hO21J6XarG/TrnyVM8tuwEVjC3C5Xfqo50zYWLVEKMx3nRTzzBPJePKS7GmXbyz0W3Ym/RCkkXQV60sFvi41FWe0LHlS7Q/NeaNBuLruef+27HT6UnaNyYM4o37Ww77tuzu8qA1MB+/m4Hro3gPAimNNsgcjVrLwbqErSmTbjTgPkMr3Ketj988BAJlfaDzWj8RU4uJxtNRZu3+H8mFD1PTVB/BT8AebPmDdO0up+Rt4PcTOdC5ch3KbhZgE9T8JuwQIXS45koqQsddGhC3c+02KoKldd5drxJ/OCD1Qs9TVz9Ih9LsAG65jF8j26z41KZnVw37hjzaVOWswctgfPIghvkSe5V+4zT+OAcgBtCTOHMsyyZDaPBpjPTEn3/P8z/nZ/+CpiTjtEEttRe8NrOaGGUXjwfpHu/R6CZhUMY+/SEOmWokJ52D9XDtMFpGCn61F6mnV83amnLTltZKP325yeq+yOe0CpdZB7U0v4MeBsCkHTGRncYqZxyn0u3JS3vDqtdCqyuQGuLEZiut/IW4zqnMSjc+faUzC/Y4bIJaXZ0b3TxncQ3FK/iNsFj3ROdPEOu6Cmn+gnKoLFCKqIi+hJNh+Cys4t30m5N4BfhcDm79xWBkxFQnOtu16ZfQQ5Lbpc3EoHjfoTxyJXsw75jFei9WyNxSyJsjf9lSP3Gpwd+4nUI3+zjMvgn8CUf9iaBz9r9KwXKepkh0cghl5k0EepgCs9UQtD3Yvw9UXKcTwGIousw/GeFJeN+jU2rXbwrTWpIeNXrShY95aElTU19ODIJHPN+qOv/be7WxjfecLFGs3U5XCg8POrU0s1iQ1DFazKqBRMJR1SdKCbEt85g7IXJpjhP0f4ffcBUkJA6G5lBsf6wszHueouY4gK98LL+Ka4tw+nWgpvu0jwF+bllo3AqIVb+hnR3K/NFyvbEMG1+VsiEoQe4f5vso0gCmqc5+ID8fFyI7IsrYQRrcxneRk6D4BssQLOSF1rcHFT8tc805GXs2t6HXYHAUJnSTz5vdMQeEQ8bdj41r65wifiqzCDXPEwn1pO6X6F4EnbCsRCUv2TlD3GyVMFiQHGQ4Bd36UePQM4aXvornK82quWc8RaOblwes+LghHLnZNQnBdAffLUOlXe3f55kNlCqG4YZi0OF93lC+ODxBvgRa2itXN0yFXQN+6GzdDPh6VJ2LkWcIQMuaAEQVpcSDqEg5kyHJ9puO5qy+oX9tSjVdhNKZz1rdX7lKe7Ra/NhMi3ZNTfykYPcOqt4LdNHnudvwa69xel4yOrwWwF6N/oR1TfMJH6ntkHj5GAEd/gdxGJX/LKV7QjcOmce+y8Pj8w/bvx4a3OLFpAF6jtFMrZajSz1+qAh05JIChTHbVXBCKRfShGLSh2yhONsi3GDwKQpBiLDG52WjZymw3VTVmz23pPWBopCniAe5fPB7uI92KbtYovKo7RZa598VKYt/qRTV4fpNXSySpDRcs2F3XTVEJYuQoS8PbuMwbGaYwLF4fQSt6mmHTE4GCuk/ATBS3DBSuc1Fopobv+ZnPZ2ap1o7LfBAT7YpqMa+yLO1Lswc3mr96GJ4GHyOvQ+KWl4n2+uuOsMGoAJjE8N1eFRKs95sST68RIF+rrdKfDvBYPAe5RZLbss+zNCgP0JbVE0d6EagaXek3Bg+eJhPZlT8WREgp4/Aelz1Y2FYR2CMZFhz3xYuDk8Hy9dBFFUO8CsBvPJrnnXTmP6c64bFd58NR8fR0nM2g0LqW1KcotgIEgxc3EFYaCLtYEVJdJEkPn/6W+JFx77F2Smh4ZyluQH61RmP6AHAl3MEWbPvhqDWVoBk+X+oajeErDC7qNkix3CTZteK96ShcFtENDsRRazTSeqnqsJhQzMSfOgpb733g25gOt8dVz/Y5Ii/Tijd9caIrm8gRo09eNlqotRkdcw7F7N8pUFrfRlFCy1lhs0tqu8zU9vmj15/njKlNDk5Bkkecb0ZJfqXUrOfrMhD5NYdjzWhaFPuiw69mkv05sf0uaTyeqteM2SelAlcpWMrUYQKq7HtwyvKmewyksBFsM4gdkEsil2IuEEGUDxIperI6o/Q0j5OMItZ7R4Srqfcq2d95+pPaQakOimkTVuBR/Ng0P/kmuF797HQgw52DIIXwJtUnm9SRqzz3OQXroFStv/xsvKr7tzMNc8906QCtRc4mSjw3G9eTXplh4vR5lo1NYKLi191BgFrVpCL1wgfAj12y2CXkin5MQWBvkdXRipdeh1MehIVaYd0FMapBhYpjeMl5JQTH+PSFk61OtfvvPdkdEN+S18l0TpXtgfRNBYoImcmW6hQFKlGH2B9FUGHYq/CikNX94OJ+EwUnqUiQmj4JqDx8+B1vNHLcT1P+3fr5cfyxQHoMBpFyf4uhE6BJq+h3WU1fn0iAcYbQpJx6SmNvOlTOd6EVyGi/6+BJ7lORs/jUwGSHGPbDObBBmXM7htMBa5mkYXULIdQwUzZmI6u1lVbgNNj6/iW6VMWx+BKVi5gZyWhwBpo3LQrPtjtDrlRAw78N2xy4ugkmMcTYhCjYVZWgMAaEKnfmzvrKve0RM1ud0nv0DcyvxIb6q1qMux69Qv1ZA4N+Uejal5KQN7LZpEL7cOhtHfwK4NGltjIZ/rSJBTMl6nc/V4NASi07kMDLh9cbSJACL9yxhYJ0kXJFLireJeyWv+m1P25m96pd7UBdkHnr7dWkdu1xvcW1q7+++oy37RcNhPiNeJD82qsByyaibyW8l7w4vOJLD+13pOupBt452wdetGWQmk51V+83ewdKB+hmMHW2w1FRHFXZP/2qyR3ofgeg78krsZifjg/5BtEBZgBX21uluYuVbxcTT/iuAP2yeutwBvUtSt0XHNyItngXGzoWsnf6XL43s8Aav87tUV0d/40SsprxdUXodeSlWa9P4vTj7qxWZfU/bfl2qrMMbTj1IBpEaXkagGL3Osy096r1TyCBQywwTjAiSsEENFyLsdkgZuM0xzke/6wv41E2n5vDIxznxho4fBgAeBVOIqen2m8uIovrnH/z/fMrzMciJGxEf9cWR01bfB/LHpnZ9Vg4sjVlit5yIFu6T+bQo/meVgAajSAWSqvWCC/1Y4mJNpGa+9807QvfBNRx7P7r58SWvUn29O8Rh21801KOE0oGwUz4im9IfyMDSoQlQbyqBxNLKD6hp+MiypwIY6DtDERXeMlLQwrB/g70ZR8vPCUQFfc4r3TvyNk4NghOmaMJ7YscZQdvfpQz12/CR4eT4IOTABTIZSbyxsCicVqKq5ISw0J+nOtdbVPOK93HWBAOuYs7J+wy1jHUYYC1py5HS1L0VUcujCuFw9+DDLPAAhcnq0Gcmg38dGClZZzcbOeD15DhaKXJ3FTRYCBNBt8UoNAXTD9Y6owEZSxWYpI74jfhnePTbO8CquASATvIPOM3MxIfE/w1vnyfftW++Y7Kw1mVMz+bqdiM8JHI8b5cztBbYfFPNjehZCap0D84sUWjAH2aGlGNjxUwQd+RwFgCVnQYp19S45BzGtitGdqm23hrT2yX7sjle6+vLZG2Vj8112w2oCPwzNqNTJRkiyC5uAfDC/BtsICLQoBno6OFY7SIrc4BW9aQXXOvi8RruLgElu+g6LjgR/2E6jYobh6pSFgm//rzMOMaxt9MKdZ8xQtMWLFSFLMdl6sPw02/nm8p5R7EI94glYyQ3B+nrUT/WweuhXrNlnhtNb/AIoRul1AJ8kNqFi0Ok0O24o9P5TbX7GgEP/j3gi8OPXpb2r0fyblF0DKlfzy4AU3KMtl9Ge1q5ipDb6bveIJhf80PYV7XRrQfqyRbQQ/bmx91vc6jT8c4UfyKfKSg28Eh0UjGL6GoisKy+ni+9oOxp5HF65Ij2kfnMTn5gvacST8cNXxFPJiXoBim9TDTarSv/BvNVOXSQsw3GZmSqTKSgTOPAxarBRCoFVG0KdwoVmcZu04P7AN50gbilMDrokRCbL6ycvux/9MWeChf2vx/kaT1LqgZJ8kL0F5YH27qNCfmz4qDhWKvQK1GASSH9hNDT/9+EKwm//BqwyPnt7DmoS0kc8meYLYF4AeXrN2vCctHSop2lZcmAz+PRnKqDk9+HDqex7x9LZCOKmppiCiiAQ4PTUaLHvKLKQKXgTKIFiIJvsKh9MEIpE7SFAvbv6R05omUVQ7F0KbeiDJDsqmBUyErqQ9EBm1L0asaXDDvY8W/uhq0IgXLnR2vU5Q/Uxybm346yebmN5D+Pmt+7gA9CQ3MwaoHuYi6oet2BFlOr7RaTzjl4hPjjZacUb0KKrKJit+bUHtipSXtLm0qr0gI+Cgg29TOUNVlPx7V1x3vMfcDd/wszFALmcjnMWLA1ETB4hx257ATwQr7IGdI8sis1F/cIUUepMBTHQQgM5O8WRN6H8Pqw2Bk+yhI/9Dg89UmA2EOH/ewVEJy7lZVrbH5wpn0jpXif9qFSvmwvTgTVdtzUS2o0UnaUguS9Qv2FVzxTqy6huzScu2HVwQDQ+V3//s8m9aivI/lMs/xAdxV8RDcU0dNY0iOXZonsiuHehLzsdUrJ5E09vJB0p7HXCzQ/P1YwIOs61khMNzBWrpuXhP420NZ9Iwqk4PKbncu2JonNuTcpvzZchiT+sDsYmZyn8p3/A3kv9vnscZwRpeBEP/sh3QT+2hC0zVFj021Ggty7PwHtKDHA0qGQOKklzcAKOCbUlfZ2KXwzd8WkfsU0YNvyKr8i9Z1w+Y4kvkm/4bUA25E+BsXqW1F+KHm8GyncEdAZa6kjt+IeKJFnD68Ev9fflNt61PFx2gmMTWjgScTwCdWnwLDB8QNcT4Ldmm0hKzW1N6YAMYWzORrSyz7DojvT/D07bEz3+9a4141U4dJXgBYQWIPnFD7z9QsGHnUZwosP4wLPtREx3NeYYtIuVKb7F+8qUjEpaP8SA8SCGqQPOMSxIiZcAlCvPzhCdH45P8h+Xzk/8vYvmtrPojNiNd5Ildr0J0dSsXdAiB8pMgv9p06rwZl9WySD0b257M4FTo4DkMFey+HiKcez3pxDSJ2ivDb5aRYomE+EnW6NXEisbzLHdwda7qpcGxEjuYuoKc8gaVn9DtoGHvMEqnvTNb9M6JH1ZN4WfBGxzZJtGACbWlVl1ugzpkcvk0EaGfWRV1Yhai9JCdW4wfmkcniTUG9U6n+fQpJxPBS2f9wjCRlB38elUS2ch/V9KeViMSWA6p/dnjKz9ZNK22gOo/1jM6ntSGvD5zmcs4ksCbx3ifycEZwropDtDkxkhEzX07liuEu5wc8IXHZrT8M1QoBFJ2GLMeZSr879ALVPLXqkBit/40a37YGnjJSPp5rKhFM386GW4dTD8t9leC3YEDboGQVcr2nt7kXDpOEG0eCHsNsftuGsPvodqphTIh0VhPZqM/fR7kroxm88ieXQHva9Qa5kaIQMRXn/jQxqKm5FYjYG+f6P+i9HPyiSNr8nGQXPLKrDwTV7xU+U/FVPIky3h7/sYqhluwO0UVeXNnG5FoP79h2w3/DW+visl6hDX5D9+5tiDAG7/U16QQgx4nKOnn6vc5FhNxLEBu3dyTGptd2Vzh4zD58Xh90nUB/wWJHwB7IjzlEtdgWkh/jDMIdNadI2NSyys76LxMX6IEGQxQiNEl7qVbtGc32L7XE3gJit1298H/RGPTImJUzBl8Zkvt4hqYOVG77RQ9dv/zKXrH08NZsz6asNWqdj9oWeUrz2Mr9VOtqn3Iz5kr3eXO6+d3NRqC+5J1EBtfBAa2rE/37/dQZQ1ZgmqVZrPV90YX7Snt7vYfu6nk5qDGYHi7+wkOfpQ1WJPVNGDrL6ix2YsC+VULaqgyNCuMEPJlj3aauuFEn76DsnaoImmoPOQGV2BMtQzDfKgxZJHMEGY4Ykh5h795YBi6oxpnZQJr5BvAhDejLkPEWfslDhOb/FQppoB2Ypv4Is6CzFaff6yKSlo78TAPjQ/X6Pf57RLAa8Ida/XyQUaeVv1rshzXXOKByXsR9H6jeGPtsfEKloV5s1seq7mzXaMJ6lQ85hAmBQZIWW6vqXykLht7+qrvUOgK8MhJDN/q5YAWwrkACmUu/hQYHfh5G3I+e914VeTsMc70DzgYtIH4KsaYxR03dlAfYiOI+qxij5F84tyAY1E9sOj5NBqkpJ+xJi/cYmv7sNllTGnBwGqCOH/sauzo/JYkbVKrJ8rQgFhDvsv7Lb7Cnomy74AO9G7OGLv/DYG5JksTm6rr+LWBJ5zKAwYfLkyhuLnNd0r43MO73xPqk4QPWKPwjYrJP7rvYf8ecftV1sPZWkZlYQdzvfwSve+/ukBQCE1rCeHvG4wwY9ZP4M9GFL5jRwa3XI2yK++a3hCI8k0GrW9YEe52FyMCGYLEIvDoAMpLHqosg6XkGzy3b+kQ0YxTRW3Bfi7pO09ME4vJDvN5cEDPL45bmh31Mhka1f2RmhGWrOeQjDx26LijyLWwntAsHqgWESHXtD49g/wIggZXv0j0CIxThf9Ez7Nk2byrjOQZ1UUQ11jSo9sl2F/MYf4F1gX8/0yel5mOW+m953nrQzY12/Q60eZZVdvaa41fm7n4i2z5pPi9iEJgVJguZVVHcHUewmoIc+Mb40XFI+OEyA3a88Wkeu5TwaxYDNJmz6Vk567WhQY+pZSsPqixOhmgONbRJJH46uxtQ1qUlsmcV7RJjV/crR1UInq73vy5qDQd3uiqfxGBOYHTB3dkGJmOR1QVBDzihc/ZA3p/Um0btZIMJRLznzrt1YYSwtsKIncFNAW+cb0zKNTLR4zFDXp3Qr+dNdxhfyI+bSRyUn5xQLaRWa4v4jxjoQO9hWzeOjHSTntd44xtfCbAK45+9YcKvMTufutY20bO2OWbmHLKQvsnPQg/BhKLZnTO8SntccQwxqWX2pzDnV+bSrYm96RvgGw0xdjeNe6WM7c5UCtVkJOolFHP3MiG3YKWz7uKk9yf98NgqSmJLBBvSHfjrWEzx3vuwa5PZXjxUUxh4wwBjTX+JNO34dqh8c5t9flF5rHiKGkl4/dNP/Fh+e6YG8cq4c9oHyDRtzFKlLQ65T4Hn3kUFAqkP/A5YirmfEPBPk0YMSwUAQTHzjQHmmZYBqUNUEqhzz2OkRJHPyzYYAyaYIlCSBK0A3GRQa1Z1svud2dZkBuF0E5ntFVlMnqKpv333/G738cCveL16HgNXxzK4OMM2ndJsJ4EvJapKQZc39dbb362bGVH1ttsYVEYzcsCKtMI8urpvVRC9wCQBCfsUP1jjy0r2BlmDyBVPElSduuEH26usZsDwEl6+bODh6ssaWy+2KbLSY/frJN82LVO0v3NjqEF87xsOV6++GnKbY9qoQbEMrvh76GyQhLgd/TwPf/lpKOgSJKHCQHsjCsWXWsWwd0JzlK4Sj5yHh5KO1xjDfWKR4mbjXEWrIfz7Ik+zxoeUFJ6LZgjpodfRNZEzzUdLQt8v8S4unQWgEy4ok7NtT7D2+n413Hgtw7nPIcCx0MipocVh0s38pfeaMSJbxUhz4gdO2BHfl6sZVh29/xWFP23SE5VBSMSIKRa+yGVpVm75x5okCBysI44XGdSGCt2YA6k5jZbzWSNC34ifwMp1tQC7Ro4g9pTTFRTDRyGu3wAQ37gSD/2BKD26cINtsh/UZ9z8qfADYG9eiqqACgJk6cTUHDtJ+CZ0dbrfd8kRt2f5puG8GMww8C9HugkOlRB6WQTk1dvevy7AVux9G1Okb+rPO2m+VDa2vq2xlXlZZcS0a2gtrhQHfgOuwYGUWAnjyWeT5HHL0Yr85UNxSSlBjDQK2tWyH6t/yey2hrKI0LB5FtQ98flnWg3yt9hgaz9LTzwObA4Djt+xYbqv1CDzIlmN5gXkEq1cMDi4Y2GbuEEcwGfN//eVeDBua1kd13qC/3cc61o0lLqcqF4iUNd4GMT48JR7PFfqENbL2BchHmIKqZhgAkMJG7IxVvGWR110e0NZzp8pLNl8kp2KbPfD7PkiCsVHVj0VS4KeSKV/W3mgZa1HwsIdX++1MftZo1l47iR0s0wJe0Z3GU2vgKEAF4d10js2QM1kwspyu64bZSIw0r0uZMbVlQkKEtX+dPsSrWc9RRzZL7k17WFz0Y5pFpwueyDFT45tkLbW4TQOTrFnGEyel3BQrUz7adZMxV3fHbfnkFczIynPrHQi8wozOi4/xcCjbP2Qy8wFV2/41CzAFrw1HvdQ9Ue4hzCmwsoYQ1ZrKq+2K1KnPhr7gXpKBOJRig/VzQ9F+p87XPGZED/I6Um46plWIAszlcOVgX7/oi4rNZeYJ9VueQ0OY5bYUtYOnlEUYIWZPLYaSTBA+jsFQ8XXwRs3MI0Kj7UzDh+GpfclQBhkshXoeufQ5DTft0LVHxluTPSTsN0cid0Mjc+8F9/4SldKMT5tgb1F42ES1Rgyeb9vk9JLooDen00J58UpGu7jol+qB6vWmz0Te1vZCZDUg1AhFWbGX+Lc2qyQxP7RogIzOyyVSwCV46/QC7eHHtY7Of+QonQFW8PkLWeFikpPv1sHFSSjzODsxK5WxW1XW8jG6ny0NxyEGwbUBEQGF7OIyL7av70yMYn9xqFzZc5VocuR6m2hK9mZGzZobYN25fURLiTBiXZmu7s6X9iKzEtcI4+GV53JY4tDQNe2HikJQ96jBmHnO5dx8Id0/IeVes7NOeuCnjiJAqjS6tjb/cB1bRm2Lu5N52igLdypbyimO8LjvKEzcHKjBsc7cCE+9BD2WEpjroVyuIXIY1RjYmBn+NUpANpD6WLvO7fr96XwwHqHatjtYqqk7hMs7h3p9Sxlp2cNe2KvhyyI6aTbqNUzU2CTaWyOI5OgKrsV3a2zAMo7h9i3Y6+ekSUbjBxHXU9vPPpFKv6PR+yBdWrUPPGq/p2cEc5gTPHFt4b0KGSiuQGipBZ4icVZCBeCcEdPZfMcwPWymAegYlJquu9MypB/ua8zpdnDAn58eztFjop7VorbW67hfQhzfL227GYa482jXMMtwFuoiuUQl9/4bEx5SDgBDcIQ9smirDfZbHS4lAb/HRI51LUc4G8C4IjkhG+t+MuI6tDIs+pK8R9JWEZEM0JM+YBDIbN6/GKTkLCwhdmrAmZ9zEJw1eER6FitcVcpOdraVUmsqJBcXqKxrQdjF4KzbIVrm51wrc6SOAvideggFVjTIOf2skJFF0IbvoDaDlHxsZhc/4vpURKD+fXWcHmitzz8jba0WhBWYb3Z120zpEzoM5ru5l9b8FjnWaEbv1DqammFQq072yZjFGg1o04yO4Giko3JGm/K55wdvmyqcdmz1nrTsIvCrYIUO4pmgS9rigXnFdQ4VXrgs6e1rGqmxCdlb2JOLcjczz8nh3wxpJgoWYTdRiPsJHYeeHiypPYCFgTkySX3PU1WtXAhXCqlO5N849R3l8RPNMI3kDx09L0w056059YtfsF2fF9x5elVJ9g2KDGF1Gr/6E+XUWfnDctcLV8WT1CokciSzcTiBUeELrP2CyUMsHlL/E2zv8vyDbJF/ugL3BOQBoXF83RsxFLMoz6IZz4GXqrUXjPA7ZfzPsil31pRDUCEKaPHGVCmxE8XU1+600GMliDAHL+7JX5DDN8iaOtpbYrroNpiwOp7KMieLtWMfnXREJaiOLJeUHqZE5EfLwOsCRjr2eIfroAmDsT4q9NcGtzXc9K1i+pjxW+Ej1mCX30nHK5toaF94WrNli1sKcayOUax5/ks6JGeSQtu6D49OHwu6aj09SDaNl6Px2CIAnuwc7+Htf0TJKkdfWlsduJd0BSoNgTOesYNVCiPjT1VH3XzFenE5/F8vTd9z2kTX3HnZEurRx52KC6F529IvhYJdUauUCTa18X/iPHf0gryQWPSBLAkrrz6f4ZiQSk8f18bWBKKoBXghGpHsUd8HH0zujZu21Px/OyU7tSN1jSO0WI4AAHsxDof2g0lt1JSTnx7EXH7RHJMIMmWIzdmXnKx4wWyuHgVfl4B0mAmILwIZm4j61H8L0JvkTIY9Yub81lcdPJs2+eWUkOmUQB3zeJLJ7GTTdLkxnCdvB2NK1whEppzWG5kHy8Vu6dmLQyA6zeDO51IXmBwVdhMWkc28xEjDJ9T+nff+6X5ZcVSvPALoFmW9k2KBYbRP4n/gj2Vv+DoUQtRmRx8BuwWak+59qPKbjQWlJdy1VzCuI+thF2QbZzeFth5Snu28REBSd32HoGExFzkPmBAbi0MH9DHDLiQYfLGCXl3tUnjCMolrjPz5rIXnCJHpVzKSBE//am3TGWz8hGLpObFWy2Be0qfEfaHyoEnM2CVb04q81/FO81cG567oJHg7ZJMXx27XHP+LwnTyM40dmcO6rXENVFwFYKMELkrsqB7PFo/jPMGu7XaWMJFV8XS3ITAWFWXBDwW3Dx/K3F4Ux24mP3ei3YpOzDhf+co2KlmDSw3stwCLIQ2wq41VTyeXoj7GPoFHfme1dbJmyXSM6/pMHx82LEp+pVcg7TEx555oj4A7lM07CXhOjWC+uSzC+BnVj23fZWGox9uVyx8aZfoKRegI8Uk0hdudD3yMvbiEHmBhDhWHC4PaWZa6//aH3ZKtX56wy+DE1/L8ChQySm6LYLoOcbfmyM4X1fpGz6DOXhVJOhrTdYCxX8BsB2UCoEmsLPDId7A7KNpzJhOkSQCOwldY89bG+sJOf9Ix2FDcwAKxk1DZ2viBI1UEkF3x1wCM2ds1KI8YenTWtfMSFjO3sYMPSCih/fDt8iuhUdWDyfb3D7NjqUUs+bDGCSG9qpYunggi4Al3Ht2soNBw7NQ674VfSoDNjnCydXuTxZKWfWOBzgwYSeDsJ9TbQrpfJ8+Iq+oxvRM8VXNUAAal3+xHiXl7ZnKH/iFWkbcjI23ZCwGXxkBqCrItjHb89e1OBfm1Hbnhk5V2Ptnqdc6I9C14SJAzcLXRZvJKxgzfhc2xP9QgqaMC34v6iBc+BhfAj8RoKHyuui+/2gbuIJ+xHMijFxUIAczIA1NnKgOhPH/MuqOpn3+5nmAa8spJe5IYJmtTfzLKxRObbgxJIcdjSPHSLBMlDEWA97F95JiaSHZNKWG8YqiNK5h9QhxSqtMqLM2SoXApeuCvxaJf7U4HSblPh+gBa54MPg+Lzzx28Xk5x8UnafdK1jnLq4sOac1xZv0RvzhCW05r1EsgLaUqZdBnZBzV1KLRiF3vw6PiRje6YInM3qKDda9Is1OlaFPW0cPeOmNh3b5uTYhpMlC5y4+YEmP+OLmcHwIAM8GRgU26REkpyZSzjaBpDgJ5SlN0AnM474MWTwVQtOQDU0Z3eVrLugMRAaLZFSSFg60RZIma5BElZRgduHsFKHFjjuewllhx5uIKG8oBQvF8eC0zdExnoTD6SuZp5w7aZ8XQllOUgEeubJuDe5ov7BFAsHT35jpzIUuLleTWJ5l40ZXjkGekRsHei46xs8zim5pjNPSvBZzFX4u3cvh51rPYTTP7TK6jGZPKalifSHzvrazA6Y79uQtFBOgxmnbvg5qQnb7ZuViBFJMCRReAF36emKsh3NU5nAy+WbO1zWimezxkeOIuhkhdZIJSwRQvB+eHykqnSjtP+EV8rMBC9wq9dx8Ow0gXXg+yogUhPdIw7RuHXM4A3NUBCqBuMvG0wmAC/u3HMfGzDEHUG442VwoixJDh9AaKr6487UYfSMeNBS9D3GV5Vak9O70z0of+pGR6P8xLAna8NUTQRwOfp97nyFO//kZtDmJTnTpY0lpAlZg+Hd3i/gI2br8A0UpaeXszPAl6vuv8rWWDcZjAQiQ16176rg5YEnMYzCXK27ghxzFrRu6rtiggnPKdHEslSx8CmL43fgcIkgsXGXHytxcbQsMs0FhPHZDPJtC878Krr5hdqtmQM9prrurSr0B3AGqP6lSbMwdsHZlwmfBwhpAtVHLirGbVgVIKyCjZHqHdL38u+F1svXZLzRmIe7T/etr8j8U5unOAdhBjshWWM2BiUVE8UqPskEwlalYKqLbN39EUoon9Bc5lZ6lFrLpjaiRFoTwYnmEvXlRZnFwz9N1bP5Msn4BK55ioDqBXqnH65r3Oj8Pwjuh+bTTmX0og2+R6LLt/xMqcmwzIN9V2PmoGvy4dZvlgnAM5aDw6kbX82HVo/DauB448NDE9aXHY4goCkFXm1w/CgXR2xHZPHT1rdhTf5S9cFHriVqfGxU/3A0/t2olMolMvQYpw+HNNaTYxXa4/L4DSTxNpQZPTOjvbjjJ3Ad7xA8HXoqxybmJKIGJ1E74Z0UcPHbnhaXb/ycPvOK6tPJbX4rwLUs2XhDVDnqWythroUEOIQnbGqbjHzBLLVNZ+6edsGoBa8KJI2IsyQ6aOmrsB9kemYhL9tMx9y8bHviO2I4niY12w2dL2UgRsaaE4bZoAVzBtG1x5tT1npAzoUnnVJhaAu3h3N7KZTsJaPMjfVgedLLKxqIGmNEUEBrvIvVPvFbo9nuaHAJJ4iFoeWW2YXblpAlajuOl9i23fnhpVKl5T15726lH13tF69w9YVLP8PS8djY0Fj+TtXMLUrlUmIXF/KbKOmmCH3fh/NuSfGd65G0CAzwgFRmRcX8O65LgwFDD+gYH5ZuEkG3ZR4kISZ5nFWdxhUdVwvirRfWgyQJB9HiJ1haTUBLbDmMK0Wwm8BQ6vTHgm1Q58QibrGAyI7V7KnqufCmvtaKis3bEASuvIpZUtallkuKp6daJrdtAYLjWc15aM5fY7IPaJz7nsqeLz/baHDtKtYgmuM9vv6kZvs+9h7IGxJCCMPUk46dZyOi3E1Po1nl9qq/HnGTXuEIHwtAY4zqVFNsebQH7GS0wGYglQeltInoKAbaBCUIDGOrRMQIHgrhfcktnrpQsK+qsxH6ZaKKDVDHdxRcMaH3foSEY2MCtO10V9W+6s99LrG8QuL0uKU2DsZ8ImhLwiFnDOzgKjF6yD2vgyOdrCoX+voYbFmJnzVzQTNBwDKnRVFFa5NU2R4wpD0UfLWhh/SZ+WFq+SsCg7EKCQqgEZDA5UhY/3ikHRMY0vgjllUIxOn9kVYAuH45GHMgMtrzyYFGmkIWHTtklBvrkbLzdOzH3asFqT54gg+LEkslKGkXmiuIHFs50+sn/Sw/MZgwmnfqPntyOUVB4FhxUIHdEtY4RAHXL05KAf6U764rBYLwWvD13h9tfHmJit6dUrqu5MtUvhv4PfspoQqyi13SmkEDSvS5HWGrDmzMXYjIaXeJ8OrX2GEDIbtqclQDx0ni1zr6A6I6+04aHRoFCbXmEMsLOGen8XomhQ9cFuAdI2RBV7UO2o9KxmDhXzH/kd9RyymCjY5e7HNprap0Cz7hI577tLPb8ei6s26ZdRTSDsqfBS4/rv3uSFxuG0oQwKiAAGt0/vG+J4u5n3wSv6uBosvxhA7X2q0naW7vN4wdl8d5Yw+8jn6bdKfIvy5/JbnfRJhEtb9P0L25/KeYQAcGlVZbMFqW3e2wwqVMgmNQf08PF6esBq8quZiLHlLCJydB7lbsFlLt75soFK/dHSy4kJkuYZexweDT96H0xYIEJcXTFPDVzhIOBBuFUmORaNHlZBkNDkgrsDjtsF3ipDkYT3Z30JZWbHqO2Om/wt/Y7ampQLleV25KfpYtvLkmjHAd0CUuI71HCs9ckNVVmn894C8jK4KTShKN1G/MbiRiVQMnRABZBVDIx0EkoztXYO95L2QzKAEiuC/5LeTLLefAl9jLMnkx9VTtmLT4aqh/wNzNyGaZff5l4yfrBio+rDByppBc7kKmgiYQpReWs+1k4Ob4oe1cl64M8azPcTRvgBwp+YD3A5ZrV641VupUXFub0dU70U/4a01WTGb1Bm6PcdosgxYr5n+rhg5Jrf1eWs0flTo4ToUy8xyQomk8+QUjRbB0ZB9drIIGyTJ8ACXDynPukGXwDvEwHowsO0GHmtzQJa+ZMnvKDaYif6YQVrYV2JHGdphOqSvUqf3UPvqoWwKfdgev1a+SloAz9XTBedcIKniE8gunaCxlUwcZwS89Teca25nPy9ZlSthvfWC4RSQsnLOLjIpJPmnuW2sQY6T1Shw49soKCHdTIspxZe5I8ZOFiYY17amqOefg+QB0c3yndIixy84c2YGbm8qgCC8Q0dDarhMRoAkyrGoT7oetZN7e686SR+XgXoN2KxgZoNNS8bnTFexYwWKkIs/aIQHee2JIz59OMBgPRRctIQhNkdDcs6ZYF7FUpTziyTVcGkj4FzTooTKkN+vclQ8U755DKhGH7rZ4TuRCy8tGTcbz5RfWbOXyYgcYKsuLLD8KFLiavyPwO+9232Uaf/0WCqrslakc9Outt5aLHDjwVGRSHWLMX9cNJJlomf+JnoTr71dHC6fXV5yYdHiGGXWUc38D5V3nIbVl3vMpnIhargekPG0/qSDKiIh5ywcZu0hVNFbBz4i9uk1p/jQrpCf7Wa56RSU5QjUlA1CK6ZGpne83tpymhd3UZv6dCeNNuWMJz6BSMW1j3xSX8FLkL6Z/9ZpNII3PtPQV1bocSGfAxx0jczv6aP87bQ1iKdYkpi3A2Qcyhgv0ZoxIYc5fa+KX8sstTIZGEK7UUobhoEOVUrdwL+1+2GVsJNw7f7AlwABClzXssyefkGf0SZdH6ZogxVrzDmTG/kGA/n9zikJDMXtOHLwJRHC0A3peYCGNAvYhhInCRW5p9osiENQtbhAdxKiNDKYvVAiZ4m9mlOuhaKwEIciN2qEGciqTGZMn4uFTj4tei2gLtekHfgiUvh7IctU+rJhXxBJVj9CBQ9sMvu/SELsA6DGspTcKE4DPHOXKCnKSBcwfI6QbCAcQcFlfp5w0JrtlBGJ7OMuPCmIP1Biy90XtRgTcvM1c+hz2UDPDbpOV4Y6B0ejuZ4YHGD2ALoTTmu25e3hQtj6PUuys6fxW/aVl+snxWwSQ+dabH1Y9YGxN0SK0NCAj1n+Wa1vCOE9wTKL3iuwS2dC5wmTtBOFC7MdqOa4wCxIgGtSffj71FVmMtPz4pLZCtOuhjlTeTslqSGoA2wY29swBmJ6HOmmxGKkukV2ajevSIzfvJkKDzMtf2jGiap1LRUeAm6tM3z3xHDFp4Lh+TpOpjwyUnk/mIqkUEHw8STKvdFAaXrzRLBwP2yv83XAD3kUP0D15mWByik42qFf4xUHRhKnyCqjbjjZAS0OkFqjZacYN8h6DFalbz3X4MTSJXgNEdx50Y3a8/ENjCou444oq0LdtjFOYoWFceNCCPDZbrfhq+IheAbS/WO75CKFiitWIngaFIRcWjNOCeZ9QbbWvLY4xJVTTb5p0rH6RmHNZXsJ2Y2tR8Qd89udjydvFbEVYZcCUkAw/91Z2HXWe1M5ncZSo/gS87u4YKoW8fir3Cf+rW+5SM4CTbrRn+Hf48dJuO/AuQGzpLhddhVOYhK/ILAWSBL0hS4OrXPphaIp5BOb3SWszsVXEKPiRuGhOHHZtwNGslZFFhWNNABfLTcug9NVO0zW9tu54MrSnBh7OZ/sMlwCmwm8Vqsrb++awm47GfswubqB5D2l/Ekx6DLxerxYCBusteaYtfM3HKIXhyoA07lFOJjsC73iI2/kSTciuvdoSIZvKY1ECHLE9/nuvI3SivYF6Di/wZGG6HzIbmhKdURRfu9DTGCL+mIqssYRJMZTx1t3nVRLYT6dIf2JIzrQm722QvoQkeMmcqZvZVIhfS+6U3VlP3S0vPVVDyQ+Lj8GM9n0yeo/tmQ6q8B7sGNaVwDSKPvPTRwi/8AB8OkNu1aWn5/H+eL5s/VV1f/OHZWhjnuNIlAcCccqOvb1lAvh7lu/d72fEnVjtFP+ubaimkrudDCvT3uNdLEeC/voEqsA/Dc+6l+vvb51fk6NryHj7lJHwth5w0VofEzuL4G2OBGjTABJ2lo0L+pNDGdZ6Xk3DdDlZZj6lWxT5Di7BSvQBOF+58W88mqu8jiCoxabXGkVwNOqFFFbn2P/7WgVQKNNTwBmwIyEjr8iR9JmS+qsoiEqByEAaMU5tB+3/knwcNkOMbp/bkjkTPbc/A85uvexMNl7XNDUZKhzHY0gLIVJIDB27U6huXInvzJnzzuj2uhK/MyNzHFcs2aAM7xHocMIJGDk8Fo3//k3Rf9VJ3FGo2cf5uun/HAlR9rhDVEzsAcMOxEYvHbiShnJMw/Ku07pK9LXpMuWT1yyaYdmJVXnpmA6Ud2vfNARstAEeVbarLnwY8LrIrq9QiI/EZbNwXP4JunM6rCQgxVoV91dVaFSrmleFNpjgKowuQPprIaeImD6/f2Vk9pYzpfKwuZzs3poOUK0dYQcoDfT9KaVN3co4p52p4rAo/RW6UAMzeLzhWEgbMF0SIsKzqmG9z/RirMV+1H3cZKBzcPVBqHkdSXl6dw9L3L9EhZbKu4panswix07Kb1mWiafp9/qFl+6r5CPSur7Qn5hyW+rUI2dYeN3nQelL30b28JPZrrIpTN3xkXAPx1yZ+HiyWYlfg/tQvRwRUGNmxu6d6Sp+OOa+kdrrXt4exawJqrWTB1NmnNdD2H7znlrxDHe/14wPOfNozEXd1x14r7hbTMnqF9RkrLJbKDbF+T4AIfv0ujzue6HLW2n4leAgEZ0hJGKoM0aLTUTqBCmmFzQ0TAi2eyUMHBL/Y1lnV1DQOjH9QotqGqERJ7j8TqmSO9F0aBL60ptmHd2YAoi4iLseSrbrMuFz5GrkENG68l1F0IVVPV+IqBqoPM/B7sT+uUEBbmpI4mDrPkixGwG/o68nthIoVs0yIiD8HgbBDtakGMzZ153ipvGQuAbXDjZcE+26Q92arvCMcWcq9PKv8n7T/iWcTCS8rHnZse4oyeSXyuy90YKqSV0qk4e3iuecF3RgzXuw8fksya+aYGsgCn6z3XOhYr9xvD3wp0des21QNwPauNkHEmGqZWHJjBggl50MfNz/yL63bfAyAxfOHb/tRCxUvAhpbiiTsaiHqiUu+ef9rQxIYARfqwhf02S25m7S+q7OS7juOaQKFByIbdzOaL3iO510veactR/yvPs43CTVIWm7uDriGWAmj/0exPY/xZXDKaUiZgs7ZjU4t7t8tcqVBOtEmsYmrQNtY2UI0aJyoBY38ZbdfSC+SfPqSSr4lwXf84kFPAGEvf2FO9xx0pj1/zShRA43MOyBANAX2EHQUOA1GpJHeVtC0Ag7iSMpr7MoEqdCldjFbqTdUvGMHZ3x8k2V8xJSrrocSCRq5S2rXOspZCB6rY9j3XnkTE28rMwbnilxNKVDeyaeUNKAW9i8lw77pRjYMo0Lc/kTjtpRBmBsSeHAQceGsYFDMyetkA9Qy0MH8xNhgVoK9GX9ALJ8yyiLXknI4D7eNMdymiM8LzJaE0uMvSq29KzeGE3/vwLTRcvDVFWYSY8Ekk2kX69d+68wBEk9ysf0xyTlnf0t2UGNps7tvhQimZzs0xxVKHWIqo2qO2A6DSBMXG9VDSejdMfe2vn+PudUuaUmcdEvbJsu4pfTE1IH+uKxngzHMENwCQJqmnLN+FOPvl0OeJWN8wW6mxSSmGztr824hB32JS4D0GGLE9FZZ+PmMz3VzNK1ReaKqY4oWayw8j7Nu5Uf6bPKCfFTHLTjbyye184uX+gNLVMfjYksV+nEPKltub3yPXYiIvpkUNQ/IYWEvevVzkOjxM68lYycQTwlA+ivplPpqFIRIfU7OTT1OE3RSkm+Len7fLm3WDhOOp7NhlXegtpwN9MxFpStpylsXYCEBXfEizmmJ7JwzbrSv0xQleve4obtCn+qrFPwoQWwvjatCQjKQfdaDuY0Z902yWuCQrDCX7QE24Ztqy1s81G3qOcxjOpmge/ScZaQXNnEWc5civ9S4lYV2RByjconvMv9Binv+UR9Nb4D0vHJ8qmcB0oCsLu7dN7mtHayJ3k0qQt8/LUyTS1vpMYmTsMjqJIz5rYOSb4caVQpkLPmiYLx7fdllhkGHUYpd32VPDZ7qmPCODrnCFTaxVouVXmB4gqvFptX/L5Z6XbvUIsPukPvuRFPG/1gt5QgRQTXLzF1hoobtT67j7e8EDwQ0pjF+ossk/lxHaLZ2xWx/vM1tMky3MTCgj0gP8mCtuIN79z+K1yQLrMDj1R7A1nfSQEWkEM/aQQCRyNRU6j3zgvkJaOQm1y6YRJ01Dft+IrO+wKKhwgdkfYYv2G931fWC2pP/REF60SA7u59mv7Q3lJ6FKDevIsP8vSy5VGFrR2vVhQLOgSnCDtL/JoeophcjzcNyRORcCUd7Tr/F7hIQsbMNMcp8o3UTlBseFzt7rNEuOWPtyfoDSQdEVfN54R8X+VIH/SYRQIaA8sqiipg3AERNAKcsn9u/36CqVvI95EK6bv9ghdIpLvzpts7Uk7J6KhMuU7ex8eXmupv5p5TbqAtCxkqTLWiq/IsFUbpAt2ueG6OqyDkEMXSnFn/1vo4EATWA+sCwMvXyT2jJpdYJJI7omU423o+Uk3pe5TqS6spBvxtj9uuzj8tJO35EI2sFdxkvFZzbq1gJIANh+u29MKI/1ZIqH4sjrXNQV0Mu/IgGNb+rwe/2Vo5fTIYNp9yPTWtcqyCpIOvdWyHMXjMX3EMx7vhgA5h+ZE7jVd/Netw9vAjbIiaRPG8WwBLIeQoQZfIZrCfx35sc8aT6tLezyFNhx8/gMtVTqmnFLKcilArXpvnw2StVKVHnupL3ggsBDfNUtOsnTS3XqkQ9PtdZIPsatLs820ZFiwZRnsbrgrUeek3QHwIcKs08WOBlnnLb0hJATgNHR91O66rFTINLQd/THdKrimLqmBr5Qk/eRC/unH32DXWpdH0x0Xwmdi74GyX4ZoRvHCrzJv/9utH0ctPqQ7JW5L+6VZBg0/N/2up6jtqlb7JD2NNS9BAegO3v259n41jSL2MgA4yD/1GxEr5iLLE0Lm+DNuPChatH+yByl4GOyEERaXv74llr9sni0qlDRueufkV1VGIDgQ1HvRRqHBf5QOKBFzvQa02PG1/LalpgSyYngDuKxQs9C4rglHiTgW231Sy6h4yDSyJbp4/GEAEsZrH2OpBLJnwqTEMzLfBx3CaA6yMzEsZBvSlKPJM46vHZBXKzpWe/4kg08/3RUihakw2ynVAhTzgdnJuTuB8/zj26qnmxDuxmlGKg/wNEnTWXtOBCcznso74IWYDB0mnYkNyL9FvvRaMlFh2EHqMVMMulfbVW6WL3s9fodWMOiM9AzcibsgQv/GbRdsSXLGv9DuDXm+zn9dThZJ0YNhdc/X9HsZc8mOEt9x8CAzcHyNyNt7FeVMKduNh7Vktyoj1NvmQW0C4Vd5QymrvNdzAmT8OPznDrzJBG4JHbWmmwn8OeW6ehmUvKJMFcAC+yW1wzWKQLvHML/Rn8UP+H8kanHYmXAUc+bVvhmndJlEg2tii4234Pdz4ivXZsUWygTYMMhj64mAiLxZ4s3OdJrrAj09mffSzWIHOFOxkq1ZWNBSSx/8oRHwd+snSrBemC5r7Nb4UY+q4EwL640xF4aHwktYC2ioYCQFBXjlvUN0hiJ7ucgUac/2WVMXyo1df5Qkv0txDURB6+rGrh6/XOnWtKDa+Pd1TsHd451e0VAoj9OFQPBSv86Xh6IZH2ezGFZZeWwRk5zSzSpgWuLMV4fjOdhBnu/B34v4RFsrdYSV8icCnAeDZu6PHlLIWm0UxdsIP0Q658otqT3SURy+UbJ9jjcLLNRTotFhPg29dUO/ksWLBB7bwJqSn+GS9uFhlHl/wAp5XjMWa6Cc1mnAiHN8cmN2mOov5s3zLbqr3UPtaVg2WRVx1LLVYakkKLYXbKnTDcN2HmBk3WpluUxi6CtSGNe9HuOEKRtMRmotcUtAfuOgVFRb1BSgaNTFSY8qut1k+i9kxeUL75KNdW1SNs8jh1/EjyObdhug5eo7/Zc6GLkSpuGRP8yqMFolWCWomIvCr3axuzY1HvJTachDt6p0egBKhYMEmecPYsKSYQn5YV3R1o672pkXdA3/wDzHdfG7YP5EI9bSXMztQz0/Xwi+fOFZbCPvYaDPFNbTC6FyOF8XvYk69tIUQfRfxID03wxwuCow+OxHOBHbXIa7ehvk1b8CRLtN0gac5RVNBDpPNJ4Z4F6goMeO6rxSxEIUzydk2WD5qmrVYdklufJVyBr9I3hsBqm0kXq8QR1vLPrIcdtzeapte4H6vaHzSpnD7AVexoHhbSJiDC3zz93QaPWDMJ7R039Oscc8qSgW61zpV/WU8fTcaI5wFCvRBKMV0wA337v0ugY0spoQ9yG+4aQfv4SzMtf1HvxmdC/A7Jf0CILoWvyylosEQVffHPsYsgqLYn+ZRHp3YSkh+gwcFaozuy7ebuLnD2YmOs6r74Xk5QCLZkUjd5jdlIwOTRZQbojNL/Dc313Z89XjdGZe3ByxgZzsrL31+DxfKpAMt0PHiZ8S70rmSXvhV6T6ZDkWOeEuJSYQI1dcntGtF4fcCnuuveefiK36s3wOOEYc5f76NAnxFGR0mpj5pLJkU0p1pXMkIQV11/MCzkwwKKqmtLfz7MfCNpSQbnZ2CQxeAdalAh67P6A5Cbm1TFvZ4zPkPmiJOn13sN/3GupIQooXo3dK3MCNmmUMR5SbdjPtV63hFxngzmRwn0T8Ei/73c3hBVLOU82DM1dkkZMIc057NVnfjb574LvzLsn1sPnxVTOtYWwr/KtLya0PE2aAlaBhF3T+hsjJcmeosJiXQTtt19+AUQwlIbBtxB7/5d8Boh8edLOgd/ioSIYhbgvC21NDazFq+GFDahw+gGSSPfKR+4re9rNJSlOj5xLxSMODfHboiZoTFPMfEe0Owacm/yjzbcBQJCwxAK80shKIwAh157JwR/4tAwxxkEhUTpUCzLc5OAN8kwnZE8A7Y8HSjQZNmRUrfg+6OvpIqgZfmRN5XJmkCqJXuRRKSDANbJRjoudmLpG7BkAi6NimXPOZxwuu+OOImRVDAO66nh5hLOxgabVmsF1tR0pdvDzGwaa6VeuZoQ1Mh9xhXarpXLipYrcVz5tKZrmxpnSLc14T0MlnnIVZuQejxzJzOVXjfk3IPuS8BPBa5XdlbCNwqRyOmQ8l7mEnZxUpulOLzDkvEPxX4YUWtrkjTddbPwpc3SZ90UvD35oz/ELCMYvMZXrHkRitqLnrQeIADndYFcArh1HxHrMVPn0P+G2X2WTDQTl5pfsf6AIEhen7vJ8zNc9C7Y+Xiopvx+F5YPzPSrjwYhW+lLHc+81oHASduguW6wkgcuVuyrMW3brOMRe/Ye9+Es/Ow5gGUqKs9hmaiikWD+XHAJhcIRryE7I3wVjwPOprpXSLynLPbtBxM88SMYOSvQRSupXmfYN9KTIaybUYsxYj8uOErZ+dWkMP9InNwurPQcvUHdVEiokTKHuzc8TtBvmHHnr5UlnXITyVeBJZ3F0X1yA0q6Iw4UYe3p6Rf/4IB6Jeel8oVPLE3oT7H1mEX4qQ0fko4Qi8BAx3+NwWCSAnJt2nPlzpLGIovKfC94AqW9wXeNVU2bYSJNYxvzzy1GSnNfAfiaHJ+ZHqM1rwQjgANc2pZibgTxk1mWIkEzr8LyHajMBXuK17fNCn4BpBgfw++bsYTMMuivUiGKDk/2/hB04UCEU5Os5rD910OqsC0wW3h20F0dwIMeOFEjnrXUJzFQ10VhrASlSoyCMG9fAni0Thf0rWrIxsT0JLBGoJqqI8MdUAGVAMs28OOsTJjRpxz3Q6cGOrVfpleckCTBXvkE/ZxbEU+ARPE+dhz4phtzwyyfGE110O+cia4tCWAPJZHKCRhNolar5QdsF0aSsTUhl7+NxeYd65Q6nTYKv+TlgV0Z9pFfsNmvtM1U4kU1MM3jqlFqGCRv2wSiC+1L/dI//ZPmOlbeC7/oLShcZJeR/dXlLt4w7WVIByWE3dit1LkCQH9H8ZfyN3oY4Y+nYBOTgQyrwOHpc0ha+lkynNvJhcy8+6EbDnoOHL0BDs/e6UoKPUa18Y5x33TEUFqb271FhFmr7LjOlXTxbMRbrA0wxgS+SM5uU7TA96TBtj9LZmELGDvoSiqop+QXD9zI5akjMHElHzPb4thtKIrHTevo1HT5TzR7SYjeTb5KrU/7vA1xFDML1MRpY6PHxi/TD4ZnrLLCHo/QAbLVOyJr0LRNpw8D28jFQTForO7+D0v/yAJa+/WhK6gnYeKbuC282ukRwbIP1z5xyxw9mSo5DcQrZ0/VOF8NvV6eRl5mK0k+MNbQ8rnGZHhRSDWccYHOWIAXmqPPzRupDIPcHVwRgyJCDamGNl3mlTaTbXqPMxgoguGGeBtVV+aXaBF3qGOPj86MuEHiPaiRXC5u3MB04QW/TDM9b1RXvSELQpso9GfXK376AqQqGRmcvkHeVsfpj+yhp1MXJZi1aOCyZCfNb+R7PVG7s9yYCGPdQ2NzXt1yEZ3b7lX8QaPuiChYb8OnT3c0AwjYSUKiFM31tXZpsmz68R3GyIH66ttR16O2Ob/ESySr2bWK3fAoHEYNWh6mMvA1NG87+JYQvRRgLwiCF/2/mKI70EpmOCRZkDUiiE6srcX94D7UmQGc8763yiqxt+D4tIu5MkDCkOUY9okkQ0Je+UNBoYdXXoSxnu+XUF0mK3EVD+nC3PceuIVwgYcG1/FGCPTUyhMpfPqH97jK3Q3cP2f7DdHVcxHGpw2gX6M7AnrxrE3K3Mkrwly5eDz9nta/XvD5gdRkF395c5r4/rC4TJsv2N+4216FIyewqE2ONX7ArihcDA5aGVdzouN+m2kvCQ8DS6QtK1DGKdfPFkWU63NKd+BOpuP61DzXbb7nNtB6t/lQcGUa/XG+8PnDuBuA7xf6ZfvgOLsk3s+aste8nZ7sCI9tKmxLVSeFsf2Ev4UErNcE5QUhxhJDyk3nYCs3Nhf7pBPLcOvmBjIGNfLt7dUwgHCKJX+ne0A0tpkU5ce73rVnsPpvg8fRWy23SyU7jNfSw/YLlFz4PXDofWFOhg9iVPUvvtsaCoplm4MNFSI+7n0TBlcbcOTT2cwFLh1Xk7vx6sGG9PXxZsIW/l/ZDbU944jjpbnsmeKPwTndQ2AieaZ6PgCzozALZwLEel6uWI1a+15RYrCDwqW9p1D6ahiyPksfxcV3oEp5gWpEJ5CetFyw35ECU8JxlrKDpu0nGcUAzfLRWjxl2iKJsuzRLVmi1pjvFnf0kXQmqChhvLeKISG9lE+y7zQzz6vqISA62z9lzGLe3TlMie4t7o44iLWhx6QGQ6I3ehieRPERhdRxlsYGenHgwBZmkWiVgDysszg/nbC32eM4W8E4pKPyMKd8nblwSpR0YfIaYAL3ig33xL0yarmD3rqhJIDWMWnIfEpkHuVfrWlvWospN/7NQZVhl0X0anwfe3DywdgWumrth/FqSn0yX1Ki9HoZGBSufu1AJdwfhYcvu2Za17Ak9rWDKyUou8jUwFA2ru/woAdd2J1TrCryP4WolnE/scMV/TP0XxqTOKrP3jYPCyNeER41ndSNthX8FXph0fVc45QMMhlT/xRPGlJE0SajYsW3O50KMDjbqampBQr6AKPZ5BaFKVJkW+FsohogqXHkjXuuHd8BXwCPmotgBqHsB/ZTtShwbiGjClDolyrQN+qlGBvAcCdL417IIy+YbMgAGF//8Uo7YMVk1ZT7O5dNaSX2xhcXenKyF12h9J5kBR2dkYlcgSFl9I+VXhsm+WzIA7nWKKkLk7LH4v091tzfn+YspIQrQwMX9nRkr89ChyM2f8PT7WowK8LF9jiHqplVmAj1xafii95iOXMzHhAp12DUPS+JGVihkJu2RQKqiloF0ofuJEXeDqaNOUctPaoICuwnFG46JWVHMRvGFHzge+Ek0/3lHe0Duu5d2CrJe13cuCdH2KXG6e8DiKthPQO2jNjhQRR3f9xdtITxfUr/dFXmQi97DYVUMrpsyf7AhQR3WHDMgioGH6IPGO5+pEXfk5q+Ntstl239NZ29iFGFr2fjxZ1CPZM9d0y6AK1QIY7Asoi/pRl4sYdwkos4o1kmbWvg2+vqlLQCMmNvgBpiHVpD0NJ8yOMPS11GKrwneO7wgEMukXMHHEjXnQJwqMfFO80fUAMMKobXgBZyC3iH9B/QAnhD2tcijBVEjRN+koGjwD/e7lNKXXEFsjrB6YbQNBTllhy/0o5aUDnDzqx6OSAEm9AK8J3OvaCkQ+Na4lxy1IVLPkVqogiEGNBiDgZKPWff+whiH0GFBohdVFSKI9pf9R9dzW5tfULpD+9Pa+St40C9zPKg6jL7xnSVG+RoYVEsD/WSgMcyfqXoj/wZFCl4R1BWsbLRaiuVHGfxS3U0J1kmibBl06PsmdJIzejoX5XGoT73Uh3LarB0BwEqcDOYTPTFlLBWOHcY1D/utu5o/UORHQyT1iAU3xOeSZ/xj2fIAkxfdlSEto+2HTARcs8Hm8awlllvzWKzgEwaZTVYfYsyQG9SVRx5G6/K+1nfLyXruq3EmsLoa/zjmLHz2txuNOC9laVWUWJOErI24I5eV40D0BE9ZI8uVVRIs8K73ejqDEQpuIEpp4Ajf9Ku63PVM2xoHLgruhW8excvZE3qz7QABt6eo+/dh2TDLB1VWToye9os3MCaBMpgacS6+5eEMarxD1jceQ2de46bZFlZs28qGVx9PUzBaCg5YRay7T3zAvPvVuP654L8Il/AfMsT50HXgxkKoTqOXM3Jb1WkWkoPtcYQeM5d5eFr4uNpzSrrWMadWmHpWfBrqygMPgShuILKUkBzz7wByIUpVUfr+pIsh9xUzSHEGqrEAlFoWezqB8X7/G0sQIYwwrwRfv70zpCDW3RJeGqGu9f78ktaVR5mm2f6++Wva3Zh+ItWw0EQFXPMz/ofE41A62jFdVpTE/sbPkqXD5xX0QLw4Hf1Xj0cBaZjCKGnDcxCsUaM+daY0juaU/DlmfBfhSqb4mqKU5vJkJIe6Cl6SvSbo72VuT/h6t5wsIb/xORzUk4QWmq2uMRlG3bs6HNTzyvvvVBg9U8Ep0+q5DJVxrC3agG1HWdHiEIzuEkPPjQACzoKLZBpCNaaStC5NRYvlJjlZyZm7qcGexS3vfkvDFAPyF9+53wVUBFagb6Cn13F6H2RpRFeoJPiRJ7dtLhJV2xLlV9nY6RErlSYX6gubs1TM222+eqUsQPXy+648d+qSndF8WAMx+UgNq9uYOU/JR8yWQ67LsumiNHf0FSjDynjifVjNI90HdjZpM+zXzDhE63Eup28MTN6Xw8HA49p2M8ouxYvWeAlsNIUYhCblDs8W0Zo8OGWhi1NdYtoy42Re0N2Gqgg4x34g+86PKtrZu+QeAgPxEl03Wo3q98Y9M9I111dCM/hODkMfUN59C/AY0D+PUiN1sechaC1LSJ71zMEn01+mtGbNInz7XSLGHSH4zEgSMdB2kbDfymf3jX1/iL858FShfar2Dp1aOk99MxCFUy2HX+vBBsVNU04UHjtsndAhjeD0CA9g3f+zheS2DLoHDvXmW/9XQvRI3T3i0Pk6z49Qi2p/D80PiBW5QZ9MkwNjtf13+axoHUCCIrvoCetDbwJNeBnQMopViR0nGDODfGXPWfh+cqPqhZMxxtNTsA1yLRqIQc///XMhv2iPOZhYpE9Co+WcS19Pk0QnFs9gCCD8xM4GhL/xVCqDBFsc5OU8wEPwTdMVXPa4guWQgrmBbuBVRLvGeIpr00W5vQoQKf/R9DFpkXKf2osT3EzLjklQMx0iLSIILgWfVxQUzI8a4AEsB8KXzhKvrARiUCycMRf+M4Ze1dNjFKB7Rf9rN+p5wPVtIUQuD1y56i8un/wt6ygJBq633Az7CNIJE+QYi7/pPfn2jYgREG8ny2H2eBhtJvF6JaG/Z04FrN4IBe9ua5bXk6Ea3eCn56Pgm9jIsVJ3x+frI6oOew+hR9W0Z/4Hpx0O93pCjYcVb9CbSkR9MBo3BR9i8mII4UfitfuEi+0lXAIEK/4Gl8+ioND0+mlz8I/Jl9SwWoYI0ohFFQLH7jD/jvAR5Vy4vvKAHg04xCmRpJ2Tpdf8n5A6p+bLCPmHvMBAKmTTYMkhWIDhC/td8/zu6Su8KIjA1lFpLmj2WplEXAFnVz1LoqwRiA1fFX/IJ20xVF7T22k5NRmqtK2iQyt1QgE8T4sFmEuK1D/MNR4ilswkMAW+TNc6SJBLnMByTZ9mNoDBB93YlnWvyvbbinUIdTiSH/+OvU/YGSC5hBdogQ9n4JJv7XgkcQg6/2QEWrh+hylpVLbHGDS57ZmyQJPLWRv7ngSl+OTD4wLWBmva116z4y72ljuJQDQ0JuJh3KoXoMJ8LJyie1GeWzieRVxjuXyg65etzuIIE3iBhfCfjcI9wTpiFe8yxsEWPjzzWzpirXfpnpbQ96a2coeu0xZhP3sPT8/qOwgVsXHfNylIs6Weshj1DRrdZK2m8UsGJ5uD2iAdKkFsPh9JdMzJYQf/jaoOBO9q1ciklU17AqnlynV2NG32vMswlKhoJKSL39LDlf+OoiJf3jB9AaopxiwlXGPHXe2TRDscj/GrMwE2EBX1cMhqZiZJ37XSlQth8y9/vR+uxRAdYvHNnALEtpWeaGgy/QGqGgx0LeBZ5lKhwq/7OjSrB8EfxFil93ksLFud0ON6+hKKjURsQz7vgcEpvooe8owh4py2Za5gRT6czyAEnPxrEPk3rQPEf4js6zeoHMG2NnEurLpzVZSZQVTK3i3FkUwdAMBB31Yagd3HWpSLg+aTUUwUDW3sebVgroaSXZyWCii0UlSjkYgR+NtAlUtWxdvxVROc+etaM/A8aEU/nliIzHN7259/CFreGfjOPoewBBji5d2WcXER/TUGkO+/+nA+ZdWg8TgVI1RqQwo20rKJZFpt0J7RMCqfo4wCybGK7fcFN4gvTfJhV6LP66IBgZ+V63E7t2H6t6VhvyMsbb4BMHftwDoB+8u/1ROQTfmCzEeNBc8rph/lBx4/OVnLWwlmbsLhy3/qhz8Nz3tr/AOPebRkHezP1cnEI5gKcjyCw+wvA7HjrDOCf9x7K/yiSnXwuQbi2eqHEveYq15H/sQJFC02AYRONAlQmxZ5YdjDthT4nD/gkIitUnXvgrQmSBAn0kz0DMmqaxnjeuSfNd/v6NYaeL5WyZwrb/w1DkBS4MZCMvlBRQPf65mndKUtBKAPwpxzbR1QFCDHwFQMSZRVqR7hFS2jBVQBKFAMpNIDDRPxfPw9HEFLoEwIxtVQp/g8UQUcZJymDuDuN8CHmoAAd5jejjp2nCRDKAHxd1qB25fLlqm8CehJFxN0+cNokl9acVsu+s6MPXLjYIlzDWx+9eo31Zw6p6LrnRXgVsjsoEoafGNxmqxv6nzXJP3OhKAQYFi3Ej68y6Dddve/Xo2vaKFkr6oJwJzkr/3sLHJ0TZ864BX0yoptOO+ZcOVK+Qpjx53pPRdoL30iDHWngReQpZIC5UD7ruds6ymm7IL+U8MSTR1gXONHOpgEDprXo9Moxe3w2nu5GYLoWCA8pmTRTjeKbLypl5H0l5JnvQh5D+ngiQ4ZHYTtjBORART5HuOJ2KRz7zvvRnrbGrYyk8Rj++V2hFynuBpolcE3pobTeXaTmi8oodKEA0bkCCOabBmRX4uhm0h9hz1pUBhVdb0yqQQgMScSrcAFrDA9WXHNNncoHlvzId0bSg6SdMBpmuf0VofT8mt1AJukiglhizeq+HVYeYCpiT6vH8v/y/JubrvI5Bg5VXgE+0H0VSeO8+z+v/4BE8BmyUcnWiYuerbEEGt8IkpeiUIoqGyvQvwk1zCc+G8MVtP3spWlP+t0Jfhe7H6aEldasG+kNGJLTOb2bZra+g6/mpHPUSqFJ3irLWeCC9sgqcB5AlMV/p7b7hRbw0n+IUE6RWIFFPmF28ty7sPU/Pby9BCtaO4ByOfbspJt5ShrxdMFECzj8LTi4oUKIx53nUgREsEyczeCTNRKOGRHPdehrCd7r6XgGDxqf3NMGPWXr86m+cphibhQ9PD+DQgTohdISCHC4s0/nKv78nOd9UYXqEP0vWAtwCl3YsPg7XeasZ4n5jL4WYt0sTf5PwTWXnM0Kg9+xfUt8sgGAXyPT65j4mserMpIlGpApz5T70BOGHGK3yAhh8Dy/mvI7nlivvlg9MYkbE0iXvqoJAHNHETjGD7oWRqYjGMJXKQeB3/k37jRCLDl1EHlrr9auvh9LmZ96a4KH4Btx5J7bNBpiQzvBqTxlcxzjxnJTjF5yGBIa/aGAsexT1alEW4DLnJhexBfssgQtjAYa9onADH8xiELfG1SeESgYgTt312aMwn/b0jc9+1lOhWXnK0+c9meKTOn3knES0mi9N9O7rKtFrcp1s8x22Vilow32T/dCm883U7O2dFAzEXI1P9uZMyWcDkrZ/vtC0BeZiKiGwc6RNIli3egZGLLKj1twNcIr6YotgpuwD4pep7N63m5qBbd1SGnpFo/ZiJ04kSzuPeVuBu47fI3yMg1uxR60p5GJoHFQQ6QCT0vKJY+fXKAU24WYWQKOCwHeCd0dO0eO/oWQjFkdSkKdZiLk0hklLdjlfej5acTJRuyt2fLZWiDjqLnD9ADujkdDv94hWZPJ7zXJpjUTiS4oro9BswSepx2ekvz0oBa+I5v0RuLH3i3BdqALedSBBFHiysaTMExUZ36B9LPPjKH9oNkYq4v12gDr41OCVg3x5yJMqAPINAKVv2KFAT1i1sYNq4j5Zyiczbjwlso2Re+NqC0EEEfCQEYaBk514nslXvTEimPuNazEGX6mM48C3oDj6Byk3kJinZwxC9N4WNh0g0Vazb5b7LItaSQ0xxWs1wrvLxjCMXezgVSYztESvSevcckte9T7FVjzF49SyN+q5DSTH5SdzW5od3dua7OPEPPh63oXCr+WYjlnCwUsDtcdlm1fNc1nWi6GQ2u/myM+qBCjf+HqyBwzJ/q/7Dy09fz3Lzrp/9KL9TKuFRe9zPcvvxuH8y7+ZRzhApe4AM53wu4urXfdsbH+MEgxnvQxnDALD/2bXfbWdYLcP79+5XN3SCjk6j6tm8ClkF0uijMiVKmDsETqFc51zbTV9Xpos5QiaiTwDIRgWRcT0zQ6FibiRb4z1jD7BmlHBH1KncI50lL9iZ9NFM7erjM+8C9pHJa4M+IjvLd7RrbVYMFl60FXzDiJsxXJiijspi3bw8I+3MMSxyXzkMT+M+akDxgebWMe7eC40wxPSU0A8zKlcJ0kQnFy0XDHLMNwSicDZygK5omwpXO1oxNtE1JuL7FoZfcvP9dVixuvokkfqo9XLCPHKLptxl2eLXhkpIhiogulUPIYye1s+itFmw09uFc9RDLyHkfEd1F9kPf1QXJ48Ru5p6fnJIy3dipPV6zXKKtvzzp/LXgxMGRGcKTbzXSO6Glq3ufgMgcygG0yVh8S2Mb4JcuFabuIxUBSqRY8ssuA+SoIw7xmMLSwvCCh1s4ln13dA3/TV7bPwUWvBJ3Jl3+/TBP8La6wfUP6yz5KYEuNmgbh3syEPSltWxfOcWOZP6yRZPzYS0LmJshJyf2AKQ4O+l0F8wTfgW45m6RAJuuuwDn6M4hLeJsOAGr5tIKAAUQcP6iLw3VvXX2DiklAm/NIZkHDIiXGab7cMDkRohjmmSaDbNi/G1KF3C5R90esoIqcTFugEtd2+uln8RfJjdAe/07ys4G6S64eYZofDRd9sNmYEECTwkRsnLlw50uQQ8PMweYzjS1xy08Oa9Fob0RK5KDRbGRy4M4KrlBb0bJ90MIbJHpW3O6YypiaMquK6QCtns228JGRrOD+vPIIdv9+mxGj7/YP5XRuhcFP7PukoSPiN/73qvSoSBowUH6S4ke6cdVg5MJK7Uvm3doLyNROa/hojRy8t51VXYQmmdU+Sg66DgzanniqNMDJZf65RKVQ/cxBrsCGNXPtPtUep7m44HQi9P+XLsF5mUn/PonkeQXLr2h6ljBxo9/zZxPwE/YJwsW5eTigxBp2U6+7CjeQXQzgPViN/g5LSTUEjPU/tVp9QfITVuJAzRjDmBmq8QWKJHGEnfA5JYvKfEc/f0fyQaDz2tulmAe4DAXsAYlyc4gHpcAcyAo1uu/fRW47u7gBoOCY02YJNNna9/UpVokrdKfqrbyqjJpcpCS67yjsiSFJq0GhiMn5goIXZjxs+s8M/sc4okYcvQrGp+bOQw+HZJatOihnFS0R3TeWqkdHcM5MzQimau6ZvTAvxs8MXe34izjg+Vi2EvZ5Gq/72pG60T/poicM7D9PRP8bi7E7DA02T5DCQtJ1PKIRxXGgi385Ubhs0LcpQKyYOcDvNiNPesK5kA2dLNV/BkS40ypMcoJF6Cu2YS1/++APcJ1xj1QfTez+s4Z9UvhHT7ufVRzYoTNlLOrpqH0dpivVdfxmC9RsW4RKaBF0Fxn0VwfEgFeut75LkyVn8nojctKCOVVeUmFnsig5v9UTzc23HMa/IsmRsfAzO5/wFAMNfmKpad1bOpef1BbRjDO+9sMQT5myo3WfnRgF4z7fwGZpG9/usGVx412D/HGrCP4jd65qptnaGdrws13BC7ifG7e41697sbRQlCjz3wNUpT4rJyoeEiqA50sE2veV8mDb7THZiYfPRxVOdEZqC57V5YXBcRszBVdVFLp2yZdVWmWmMUp+en7zzhKNYI6jSzEurHbhvY01cWtQDrTzoFGboNm7U+/VjMs/9V5o3utUfwxK98TSMRTP9LTdAIn63L+yxWue4xnacy/wAMZw5qZuyzT29flF3yLk6w8jHI9BuStl/Vxlm1ZXdkQr2jy750UkPCYx4CRiDJ5nuqDCQU7q4HxctyHrl4tbZ5No0lU0T8Tnue4eJ4Sj5NM3ChvHSdQH/l24McxLamHHm4wUaBechoVAT6v4fNHVQJZifc5wdjZywlVN9oGlyvskIfWEonS1Bmc8R0fmr9oGzibYxudrkrDa+bg819MZ6kI5Pvh87d27kI0XILrymN8++oZia8ASKJKHbzFDEUdBkOB66TRrWeZH2KZ8tm8B3jTP0irEDHSc+xvuB49DKxi93fuPs5rjf+3ZJhHf7NufoPTid0A5wAqoxxr/1R+1HIQcP6SWhyIDX4FpVPef+FbD0C31r9/uSPDrPH4EjBv8gJ52fEH+EumnhWVaeaYEZbUfpBwxVmNatFI7oecSxVd73+3iLw/LG8/HArKNzKo8WOLuUnlBPlMAEjAd8tSIEqlnljUAhpwtHcwcafhRl1oxH11Up8BfV2rIbxWhn68HdZccurcqZGHlLQMIRavGSvkhaYXpB7PvdsCJm61hxObotP/9PRJPQOrdT8hytqs8CkRe+2pp3/vqkYF5ZUnHNAMFN+MxAtchm3OvMf9LCEjNjbEQ7xNta+sTsZmmR/StH4Mh/uYU1ZKijHRNsdpfyy1eyOsFuMouI1Pnfj7aKbUnYSAu5zum/ZcZTbo6lhzyyBjCgaQXqgEaVkcBajubmYCQIx+LP+kDzpgcZebNWmRwpX2J4vh1lQNxla7E9Bwh8R2mkWq7cXyd5PYL4kQSWlqWngXw+dhHRZUtoiUvDR3SMsYJZG8T/dOjTdlXzUQJfeZEHMpO8RO7NT42Blxhn9PqA6ldqZwqnrNmWNloZTxYCwpgth2bnExDJiqMSInh/qg+F3sOeEo1Ztq2zvd19LFUCPT9nAqGLjSoHSxa7eWdNMbxL3kS4rfDBbi9dueam1AgzbFqQ25GZ3JABCPuh3FOmP8i3Cmz/pYdBIB7MCSMpyhK0PXlvxfxiEx8jntN9qRz49ZG8+I6zAgOeiuX99WpbvzGUlSL1cKumcH2xHvZFobMkFnxdYk2b7djxwQb/qQrZm8v+okJsRQmCUr0DzOpqk7HytdvhlTF0Jyzgch6B3bE49/j4dsIIo0DeuN34NUsEdnDe0rDLlf7xUpXI4XrZjNA57ppn4VX08PGno54YIfnQk+fgcWHh/2HgR/Iins4hz0P9D2bmN5vZU560Tu4/Zui42gzTk6XXYgnKAS87HjL9HRY4bvlkk2u2gICLElzH+1RLq2Il9Bg0UFLEadn+v+iTaixfYkRXjNGTcVbKBfNpcfRG/vtd3DLd9B9IL6FOi0uLgMwfu+NQvXw7RbrNRTqIFhnwSLbDpajm9VNMdNPyH2hD+IDQ2pKs2Ozpbv072CP5adkztdFC1CnsQz1wjlleJKoWC+qzC5cVfTzMXu08fKHzgA6PCFHYE2gkZB9itPqq+1ccYZ6HqlGBByL7tCcyiA58yOcLAdrBuN+uFKRPIb1A5/RzpuVyAAJxBKw4PkcVerwxaS7vj/ShkWDPGKontQD0CLmw2aDQRBpYzx+rHmO7JPgn8hWl+1XiDB0PlJ2EKZKf9E0VCU0ksYMBhBY+9QVb9mxCV6YanK7SvNo7VDACmRau2uvvlOE5t8obkioMuuPbk1GzVNydzP8x5kzpm7aIOgbzMxclDNagDduggy8GuFKLj1epgK2KT2J1/gAMbRX4dvq79d2GlZcthspFAc5GaZsdcYbcIJVQ9EUof11HNpEFYK8KZ+I+lC/ls4golj4BC77F+aRbJek6wcL71tH9ym70ZHvqdtepMmlF90OHYQz9OCqHFYX8S6wPyIud9E2aFtZEXd0gO4lLrHHoqz7Wj2u3P++lxmGMo4wK3hdjm6KcqspitNHZQ2wrFz7hYzQiPCNNr1hWo7R2awxcPXEIQfY92DUUgiXae0oVpVBG9yUGLs2WuynoWe1QkCqWtE7UfU5R8A/+hFzg6Pr5YY710iDpJI5Wy3SODEE4uY3mEWHsjWgGm7qPZfdxzpAVf5W7m7O3x0NUKIzPchYdng2yrnLK+lY6gnQSVAj55sIAyrcPOmXD7AIzYEAJWaEbXDcSEUMCymKcmrBzEpGeODrCLF0E2ODu9bddwfYFYTrpDwXkf8sU3bfOwBIGHrJ+MuqfS1brYIbDTQsunHDCSZ/pBrPalaOOtkDyG1VmhBZ1O1BVJpm/W3BKrBvCGC7SxFKxpqZ76pF0cfco4OVnXkDyMDKkDRDMoJo9xNsedaqErMz1vJUZms6sJlYcX2GfWRzewkL1RPmW64Kh98LPIRnKDqIdonVphvaHweCqjvF9a2+YWs6ixXR9MMZUdB2nzod9umErXbci9bA2hxYRrIcNvAjHXgi9LI+moeJt9SwU8i69quGpkJ1gfccRMZieEbc0vrHEUWmNVrMi22AWUT7Wvd2nHL/cGlX7TT4kEGEpHvMgtPBwtjQncP7W7kcTA0MY5F4v/GPn5FjaH8ydytKCAgoqEmGJquJCo1gw4wa2sJoQNsarYafx9+piMH+YJ3nvbrFvUndSt9t4RCf9p8ySqRCnLRsC/4dAePlMlSj2PdDxVpo+AVLUBUTQ6WXGdX1r/1mpOTOsVNXl+BxLlOI6usM08Zr+F1kaYLPFtJA0pUP+AecEHoRD/yb6V3GxSqVtgNuJohCUmQp/1LdkzERuOk5hB0EvdKRp5si7rQZLqIhs42PKoYSR76naoLDcu0FiI5uDaE3Ng/be5z9ygccNgnhVTvxcaoq9jddVeYEe09hatzdHbY1TxuMhU+mCKdYKFlOBhS/v/lJJxtJI1Tr2WeEoIBDM4IHlkoBYIQdjx3sGRen/WwowoDREf9ub4WarG0bm9oAj38DCLKp/1ceQwwtPm6i8DP+J9Zz2jeG7uQRFX9X6PEKROz/vf2HF3uSswhFjKzz1EJqheKfmFiz6gkGrhvTiuJ808OfOUx/lPOIoTEUkqVyNYnT8Qn+zKDECKX6o4W5TpJA2Ywwq0ksg01J+/omzSvnhZDYsFlkYaHCrAVFaZ99BjFtpgQSF+0eOVvTSkgRv+e2vmj7nZqcpjKnYDRkLImlU0ggOx+SY+yMb+OMY3xhx7kpb09FqiYpbLZicmB5nRVGbnQAHxsh7PBFo0TH7ibyBugG/4RcQ2SkLiajnEvtPerBzMLnXwSJ23DHV58dD7DUKCc9462Z7FUDtx9fBuN9o2KB0tzuCRvnqqI7DWVjUj+FPUQWn0mgrnoVYOW8ynJRfZemyjP5+7jiMMTo9/Fx/HWqBgEe3GZndpL9EQV3zRwpBRJg3vsjqAywGhUragCql+0ogcepPjFUEKjY31urkZYQF9egZ4JTbzL8LsoBtp3hjP/V5XR9D+Z8wHaMKIDrIrrCudA3X1/uBj4O+9cL185K34kMTDTklgZHESGDNb1b4IT2bpHIo0Oh4hR2QvRSA0ccevDm3MbZkpAfKQauFjTTMZwa4RJ0w9Hod8IpJkkph7OudwIcunre5kW3iS1Gbw2AKm92Pzc38/GPBJ15w8ydoPYY/gGboeT2RS20cXkBino0NFr/QsCZUqzWQdytG6f78YEYUjDw5K9IIEGdq3WhylIZAo8FOyAspjPxtfKP+EkpyySndFq2XWL1/ldk/+u+kmCrCZj0phnRoMgijt06XRwa8IcNyml8yiZ+dbm0CBX0E2mxEwZ3Fss2q6Soa/Mc9fa0Hc8UCBLpjw7NggBMIZtGNhsXPkttGxIOTKbbbjzEWrUri7JnhPJIggf5rTmuu5fGXEr9XWxEEtLyB5WkRRxHNc5slhW23P02v0m0E6K8bHRKB52P9hmaqsGdGOKvrjM/s/tntvvYfCYZDUlK1UxozkwQbyeaJHfBIJcDiX6JOEb381Ew9V+RhThIaH9Mc7EpwLUgmxdL2Bqw+MpehBjMGfnTbCKbKskvWZwhR5DcVG04GJaWZ1b6Ih3k/4NGVWlLiHSkAWK0TWJqXhn9tdymflIMb7R5V0+PhgS5FeMz/vdKDp2KDAetkLQxffLpBylTdaUMuCI3Lbf2ha+g0mSF492yyoVbB6TAWvniCRvIuP0Va2ORYRn14hrEn3Tzr4SGnJq1v4iCyrolgLN90vol/RDL+IrV3AjjH7Xw2F2JmIWNCaOYkzhqMHAsz4qa81bew6f1ViA2SNfqwuPdpAB3wr+6Mwy1E+B3sZYABC0HpqYbv+JCmXLESPJeK8gJ6K5Wv9yPfgdqkgjMIBS3RUl8BDaotzuIUWw1a7lUffcIj2Obqe66345qUxCHHz6S+bl3pp4QxLJEapaNDFsdXU+4zMkFxE9AAVxuePO5nC5bcZIsYDc6P77R42FKS6varUnxXEwcc2IIJE2H70EFrhJZIBdp7Hrn8SVaXVYp5Pf2as2d8drsvqBRdh7+FBYI/g00B0wBUIG36AvVPX1DVlCtppN128qVqoSTZ725Pk3reVHMe4Y/2VwuZtCvEYYWMwDRKuA0VZE+TCmeB1Knp+b0/znEiqh9Vg2LKxXqB31gf5WWjGyfuf2tD2Gu4b/8VGGZt421PBopH8c8UIi8TP6suWPHUp9mdLd3iOVn4Shin6zIsioKbZOOQYujE2tb6jOAzXtz3Aq5K5pF6RFDtdhPCsCNRrykTErAFpwOfw22n/3VrowH/4m2+C0XehX2vNqomH4SMLHDGUn6/Vfj9VyNKpgEmkKqxg1nk43ywa+oYaE0qRpM1X102yYfzQUaiu44G9Wuj2zFa861xd8KlxE+gpneiIIbShPqfx4zk+UdmOAcDWMyQIwGuuFJ7ChtN+/W6f1p3Fhv4xMHcBGBHDmMA6ivtgxIDW5ag30QRxNf6A5BRWDvnSVoajhv86HAqaHs4zIxGp0h9wzSQ5L6yjj2UgXA+x+SmaYwS98+1KE0TfVmtpBi8eRVJ//X8UDu5PREdsC5DHjGQNrRNAVYDCHnEC1d/hVBlQY3uGlMaPECeP4AWP5iyaSQaa0Cci0iKNZfTesq9Hj2TLdmSp6ul+8T5FfIByvniDgmUP4Jt8kLDIA8axytnjeDBXynYQf2jSHWJYuoOHvNNnHmdg6/bmFCBNYYg5aK7jX7U6cY06Mfw6n5CLnjNxx8d0vNvLiMxJbomDcLvRi9h+D4UC7JCECjwqopQs1NDslMsHKED9BDzivsXED7Ks+z17//u4V8abpsFFzCRE+rNZx5HpCwoucfKmYsXB1jnz4rfA7lM6E1mKdDUU8Kyfgfj96XOYtFLswCAy87Z2WmqUHL2AroNfsf5CXJHhYC5Op/bqkTGanYaFd6XWvj2C5XVLRa6mFzH1FqDZrM59vGo0nc0f6JHi8BKlsE6Mx2gLh6sK5STDUD2EzA7ITmVz5LX4tx12zN01JLztj+PmninBbUJhFdqxBXmr0IbApzcA/rvYysGGaah8h3kNKH2n5a79qgVf9RjoTqX9hAg1ayym77OwhVDpUbpIQBHCKZsM6QrKkdPUdUb2oL6Y2QcON72XcGSaOwQDlLDQLyyC15i3jLNJjfWA2A9qeRMWoSRKAFxn2pDuL8Jr931VPRBFfXBiRD/D/5GFOfib5LY3RUeXY04e8WqXAibDvbj7dpJpFrTyXCPI10nczozdDeLbGNrmJykmLirSVRElwuey5fgOJ2X4iKzXARrNMS0HvTGkjlYW/fxf7/JojRqIuCUFT6PGIs9gcKVwLc/Is00APxulD6mtjZ1pQ75oVOZaqKDoTNHgC2yMeRn6jxCya84XOOJZIy9PNdbDFZxLMzw5B58nor6E5x7frPH1BWUWAd2711zzf8wg5qgpaAjNiYLMVdJuoCsqciNAMZcHPvI335ys+1Jl4FV0FYcjJa24T5Vl/HwhoGDOFIJwtEHYvCn/Nt3LcsLgSagvbk3sCMdm6PjFqg0nhPQobwjxUaVryoiVgymDotNEdJZJzMQ0LcE0ASLFTI0XMFEmJNmmj+XTwEcaoVkQNfQXrU/vFN/NZmeQx1AWmGnC7BBiphxrWJLy2VVSl+sxpGFYlzNvBhvFZKKwnQbSboewoDQWiNPFLXIuKmA4sTXlrNGXumdsYn2x4R6EjmlL9i2cqoDoQqiJNESKcW/LZJ6HCd0tFFznvY6LyXEePXsf67ImYv5KPPK3OHjaCj+FajjLdi+zCrhNt+XQrNzcR07l3hqaA6jLR43f2ozZckIgB0r1QBpRfUcaeEeSZ0hqLLfRjspwlvghJ+PyGkQA0haDx7/+nEQecn/3JAaKUeO5m0lJlgGp2n1Ukma6FIY5nU91BZhaHRFIFhw958cFM+7KhEOl0Km1o27Bu9le0E2PzcPBUA6SLgSRaD6NwAVY6piveQ2k7xbVCIORR5YXf1VIRosqz1thH6jtyFijN/RusqDE75LKj/ykdQmC6/BWFxTktHGm7xiy77CfNNRICgxsV61eKpkiwsbF0xEBKVZMpUxLZ11igj549ujUKgyHxEQxJ29tUOAC6m1JxcLX+SeAjGlQ+jxnOPh/MoL/ksV4EbvJ+sbqPG2/VkqMC0vmtQMH7WB+j060tbpunSbGWXOXY4vrusMG92NTpNLNEZRb5RlqnntFelgSy4JP8NJQwQFY+to/QV9STX7uBK6z7y6pjnEyiNpZ5DDB7M5MNHboeeTbspjOcpFPyfihhD75z3yaqcnruU2G6ftwvB03njTa8liIFTH/tLOJQrtqbtRQxvqZz4pEhbXOT8Y9qXF4bl/khxQEU6Iy37D64Xbm38ZC+JQDk2Npd9F0Et30VklJXtCySTx1AaJ1oE/ESPkOlRBCrtBgGe6+QDIIMVPpeyQcQ2lCR0l3j1wwvX/iQhocQ3/LYqxIe1gb+Oprye7QAHUBc4a5OYC+jMmAA9jvyHdlWfsmvG/KErja8tF20Go4zJl15EAVWNBgzuNVV9djXUK40z22z3EikEfbaZLvF1qALPHlcFzhtZPcSIOnPHFweZZQwxgeEPO3kOfQSzzyOGa+fGLfB9tioP4roQEbMqwGJZeOtrf9UpQIeB1/eCkS6s8a+HLyoM43e4ODE8iug8MQNjn6tIlqmP3AI6i5c+hyF/e2wA46EGQKrC7kf1DLC/1AzAHs0HNAHti60IH5XXtaovOlxoaZ7/z37zWIViIvoYgaDuUI6GGeLflg/mjpUQAZI2twDe4htsfNzowpTGb5KL5xnBcHZW6M6dM2OG12KzFRjPp/4PgneJ+gK+zkUv5yD7CHOzuNCva0SXDs+jE2z/94RuB8NE9A/m2hOl4PCo+8UUXsEdCJkNHplQFSNwpeSHnSYTOHAFQXPFfHOZbOgAYCUh8XtARm3HFquR7PtYm4KCFPcr50f+H1XKjgfHalyHdxz+b05vWP99VuOZRDCfGK6DsWAjBJoV0HCNUEg1ycYxVBSz+pIR25tKdr0tC5oHuuNO9osZcfzrL3xWHEmvXiuQWK79XohXsNALXhllCk7CisjGB2ot3YbA6B+/WiEjm71bbAWle/SX/4ey0ybHvs0veW3dZnBGknxG+Dtw0s/K4tafroonvXlO9XkGszGjmgrS7zla3aibAkY2EAWj+b88G1u7/D8SrJbTG3YoLVXbqfx3tj0MJ2JYgYQnp0Ph3yFcCaiw8NfuWzV8K29dSnT53D7NSj82qAMEzxxx7NEw+REDL7mmD0MKX+FVcT6nKJ3ypvg84PfdcmJxl2xnviBYEHDvK878K5rHB4mnJSQe2seojgkFb/iRhntRH4wEBvoexPn52RwQ/eiN3aH6nPB31enjFQnqGSLu9BpV8CpGjFdL9dw/vDPUZ5l3UgLj0/lpiYsetptgecKBnMi421L2AcZz7To+x1yJ08N4OoDTajUoPjaFJrkUIDvpzJXUnVoQAffHsQiR1h6PDmqodcO0VX2CJ1j3IwijBTZQgYpIcEDAR5B33XEayFUVnDQg3JwS9/oASky2QosCyWBc/Yb2w3tEWuRixPu3JcR6i6RU2HSEYFgzDUmEesyLHA2HPPXvPEUs6o8zo5nChXCRYvH8115zBvXqPnjTgB19lqkeMNxQdCEyRRq5bKo+MUkPOor0RAMuX+IM0G0c+mQ1zNH9JD5Y55Wypzt1HCYinJLrq6VTq6Fzs+i42otl6EIc5LVHapq1yfh7LEpomOu3UPew124+k2ktSUFkbgiiFRHZEF+Z+KLKh2BR1AoMvZ5g08hkc8C79ie2x9reVLnyXoFZPan2A/0JWNpwBsOcD9evnMatX5mCtGp4rimPOSqzekIXk1Zq6ChZmzXgsAyuoDI5bgJrVO86ViFt6B3Ls7tTeSQ6ihEijYT7g79YLpahP3tHn5DJRSPKst66zqT0wihalCnMJqxtml9A1/ruXqs5AWgwJOqw4VBOKHLrwzMTYOS0IkWtUfrWaDZMVi1J0iQ7jIhmiLCHtX1r8UrzBHlGyjc5zxYaVSGlTxyv7vFDZ2mXbfHpRR+xt4A+ax/Q+/utV6AJDHBHLAYH+W9xL0FWtIA3VDwWahfSSiBhQQdfHg81jiyTBXj2QIPP/uGFbYQ5VM2DeDFnVUQPdvUQsaMapxD4pBOV+wm/+FrCM8yya2tMmsiff5PoQr/m3iHhhubWW4acTzxF55pvSA0D+sFOSxpAv6RZ3WF1/wN9XgBWoN7CLkrAA2VtAcCOyS4WqOhIvY5N5dmn0aGiQvL4wRD7J4UJ9IAYPzQ8X+xQXhjw8gN+OjoeTpth7NPRKsyz5/ojYA3s2tm4WuULId48vOerQuZ5WPmjAU6oZd9CkMi6lNJoeB5ebtHhkgL0AryHzBbDlCF9R5DntoprY/PG5OxrNaoDq9xpT8qu2zpfintV408QwSlU15gBNuSq87eYEEUIS8vSvPuBC82WBoi5mbpENnyH8CcftvRev2JRATBzqdCWwio6I18iQASIlmKU+A7xow04ALIcJihJzM+LErtgP5gEsv5T/slnnYV2zjObJ32eU7WYxah94p9nkW/BQqkXNA6lCC6s5Mo4djrfVxJBcH4r0sLCn8QE2ZNIWix5p+TurVTOZJtdYxQFbuT+HR3GkCJLecxSXdR2c9L2zd3TdxMo6z3S0khYuNbIlszQni1pdoE1CzAjdnfalkr7c2cMXYcKKdSAZAy2rmmrZKh5GW4ienFxCgnT5X7TFHw4/GFm3FHrNVpEDTcWHJIv99huwpij7QOFDR2RRJVTtmCEX2CB+nTWvVnGJOAhsu8ZXaZKPCQ4PWcb7yP61f50ynmw6yKa2WI20B2hN+kzEZp4WPSkO8pgWDFBKrXF5CDVQXH0bO13YswAcT0w7lu/lkfQvT2fcqej3Z3FBS/bHKXVeX/T9hSC0UxrKfrr2RoScIbW619XHxUiUpJTs5ua5WNhbzcAgVO6VpX0dyAxwJRhBlmzr7bozBNEcR8ImBazwUugW/GAgTjiVoI9dr6+VnX2Qpzg2oVML8mw2XwU8WizR/cl4SLUYEytfgoLPrVb8AVNAZDUbdhyC4u/H+JOAwe5n0aa6ce6a5FqeLWbX3A8soRbbe4W/T4l3ULYypw0U5JYm9kqzMa/wUJbBTbThO2mRNymFOI6cC60wkj8ryRn0IFkJQGEoydDzRw8LgeVOuWl8XLgLOSseZLqej6yuXA3NbJQEN1DmduraBcEJrH7ouvWFq2W6d/qI/677wWa2YTDscTIGifr+Kq1VTsaVqd22ypS51sO8VvNJ9kEt1Zr6OeumbavobGM3BMzytPDflV5LksbKldCMe3+aJ+FkPuDC44Ks/rp+Sk0C8+2nKBG0dRR6xe2VDtaC8XRNikowaTu/nz8BUGK9DVRU0ZjQLxQct0optXqzumHuWCCrCO0hTwSA3vsCRfk+z3gg7KZzwWvJJdMo2P7AckPDFkvotZh4G9jOTrUgu3/nWksDEW0t0JiofVVBvsVuDBCfGRFm/75aZ3uRiCHgsOSo6qfzNIJqRHq16HpLDEApcL2uy1Fn8h/hF9NBSpOGzFew7IqDUV7/ioAbhtBCVAZygR553ej2ghRwUS5VZ5r+9QTUxBG9pShoB6exsu8+mBnMVk3XFOpxNPmBBvwwAX07wYfBQ+2tI9ZYUJtgs28O3Gfqov1Xj65KsYjNw5a9/0e+WBcCN3i+mly7fnQFdC9G/oEl7LzUMLBN7FpCwRqXEW/Maq3bxpPlJlou85TjSmXgo2SuYAn5PytL5qT6dUhRiesIsUF+ezGYm6REHvgjKQY7nezzRb8klbmm3hcc3LUVV3wy1OqGaww6aGS1O4o4qHjYdNBP5m8JYoe6oCHgfErRDQykVTnRY7gDLbWXNxFnsXod9yqxzIkp3LD/LD0Qt7Jf/a8gKL4Dishj84p6C4biinFJ/OVf+k6x0uSE/F917urOHQgyPdWkWT2HQB+gM/wkLKG5r7IAUDdAqVZZjGvHhQPifY6oh4vemjClTmIUhVdta0do5e+aK8C4vJMfSJ9rR4JwWNIjYCMcP40VqW+sWx6oCVbk2YBYGf5V5nFQv5kDf2g6S/2Aip9UqW0iMDeQiZafzlV25EwWBB/dwcQNjK8pocz4eKn0o4L0zTsZctC/TXO/iqWQ/ZmMLETviwdGbYR4FeqhKdVMeCfgLVwBiJ3zHLkkEFTV2xUytNyFvZeu3lSs2XyRlyOT7g3nA9qMjppU5lt/t5uO9smMwbFYNtRSRyzxCtuB6RN2Mr+rz5dMEJ/UkYwQwcQyOHBT/rGayu2poHQmZKjaPWUBSmF6ewnTmsErMaSAWrKZPqrL0YERVf5369ovbhwojPcLH7hgx3oX7OGQB79jSTm+EYYm9xg+1N7BoQXKcojNKp8crFlCOE9ELzDjmToxoHY/4xXxSvM3v4Fyz9MPGJfC/8QFJH/SLZ2U8tfW2v5+jqsIKSYNMnFR76de6MWcm4KT+gZ0FI/6KLttK/wmfSQE1ribHDj1GDpdHVS+LkNvHrC5bFqgBvea/zS372wmxKZlPvjMbgrt80w/wd6eaTv5veeQEsInwvKej1ZlsYlC3KgVUyuseR0UwTfdIlZpni/Pkh7PJ9jUDfvwT0iM66i7o8fmOfuYG5Vp1E3TiJCr/xI9HJBhWKEitdMT/s3p3M9eBARvACc77kN1pvdCYsirv1dja/iunQBPDijNRQfjzlPa3ESYJuiLfU6HC9Cq7/Y3zNhNCQCphB/zdzP6ZxmfqflRxmkRz5MKfzEAPc1XAquNJOlTfKIdJLuIMRyf5hJMG1ELb2B+XmPKC4XeHGOCIiTVBjgSBzbsNXXNhTD3LjJhn6AR7bSY3LcssYRrZWKMX5MLLTGQChV1ezDng5anaKnUw7tjcHAxCcofCRbsfg/RrcBRAufUqAUbSlVEo2be00OXia0UiLqYuaB4cRpbB+ZADpxDusXIIYwMNmX29Cx1Ha5hUSDpFEsK4lDzDz27acolLRHSM2ddc55M/4tTzPvoz430cKFk6IQZW3K6n5g3uE+WeAWBPla+Iugh+wZfADRuVxNFt07szt3E27AhLi20Sw4wJldVPg1AHqJDVITeATELHeBix62NkixBWpFjiOMmH3j+5bHtjxGl1FDt3KUugcJKoZDvQPebTrrwL3sBl8rGl0JdUlbCmdJjlGPRJwkm5SzObKwejAMWPZ9olmGawP0nyT38Y8leB8bq1y1gmO/33ITyAfPLcf8PlUq2Ofa6LFYolZ6R9VE/Dfr1AujiJGx0Io1Pkqtmvsk8tV1fmeqI7PuZ0KsnqiVw+4vmDzQIZRtImN7WPbsuNTC8EGNaP2IHqneGzzLq3NbE53SDR8OyW0lLGIMt7juvpRko8jYgqk9d702veu8pBcQMfR6fVv3YrYFMWU0zac4jugrV9MCWydUwcHd6g16IQz2NKZ1y6GNLj9U1HQZvD380I1SjenaQE1vtdvFg5gDllJjiNdD3M7XsQeLYEkWnSZrTLjGHNIFhkYN+OPtd0p9NEXN+n/VnAFd4oZpvYV50u5Ki3sY4NjcyFsts9cGamk/7LGBScuvyyDD9Rv9P8wkeXgLYWBaaw/lZSX6+w4Izg/VRcYSDE1PvPgZ0+NfvtapIbo4c0gkPXp0MQHV+4eHsJPU4Ow5KFt60lwYeSA1qdkNl1asHj6XcKv4pishgAAQyD5Ct1xiyybKjHHLdnR5Dcgok9DNrgNt6MQ5EuArGmGSKHQAdSKgcSSXJsTDj4PzvZUxQc4FCr5RuJBIpdmww8xb6JI+CC85ToyvYxFVHgbH/lCo0Og/jFbNs3juFd6I3cLeCDFAZUYKM/+uhOC5R8rROFhTW6uoXX4uR/xbM5Bx07HpwR3GqR18ipSnHok57Ae3qgrJjkGIQQdM6jd6UOsfZTk3Ile6r2JeWt6rf5tJOLpM1OFQ+WCIaowLjyth57Jp+SQblDL3ajAefq8aeIaUkuUWN04KXwxvrOJ8v2urremHLkQvPCr0QKPkqDPssq+U9rzuxQf4S3OjIOcQxSWrXOTmU98PofP2v7Km2ORAzn6r4M9iRy2m6BtYrgBgmj5VPdSgSwYmAQ91/gYOoW9sZZgLA6wuy0k97RMBMbVZQP90uhyOhUTfewWBSJmJa6q/8wBYHsYdSxPkGGlvqmSzDXvt9/onDHuj6MyA5QprL+jHPdI6aOePqasBrkkz2rnpgYJkVWUIC+H5NRRYfZQoM0o8Re5y0Okepkt0Jlj87DxKPmG5pD7yOm8WFkF9A61DD/hn6a+Tprfib87t0kTNrDMgreG5jDTMZjMqE9Y1d8UXSeLBpwUDpTFKLqZaTocbYANIK+WJRmSJWnJpTRtAkNH2hj9gROL7HiMsDdtXsGXpaO9Q5so2ukelcTMnE8VBU9lVaQ0lV0uXV/zYYjQ5ihQxs89c0lrhc/iH59s1YJU0mSAbxK+ZgUIwjYDdIYhisBfTsloonffqY6fEx10xb/sUNR7Zvux+eSSzqBaCSQZR9DWsyopSN6UKAmSjuy0YpUx/PLfMw/myhGuj21BIiemidT+wgo4MI43Hl7FW2NJeJK82oAqE4uXVNV3J9OS3kt+vLYU5FzOjRfYM80BFtHOzJBQb3zBZhEhFwMH31pb8Z0Ti9YjIImOAoolpvuPevoUAApS0/8RT4Cp/f3jNYpsvPWIDYJLoc4ANJr/Rh2yJZx3qNDzgXJm7lQx+BSK2VkqUzHAgEqk7Ggk6UgQtJqbalAMjgng9QkH89w0vcNzPY8qVDSoB1nG+ykm03JXz7IEeY0NGROZgW+IlHDMZ15oBF+qBzEe79GQqGjwrrkAfFfbvtqpLntxlINiqrhRHC3FG7IR8a0N+NMAK9IL1IitFbFXX5912gKGlQz/7JbLQ2o9qLz6ixnLuHaiXeVZiFwjwaa/zlKXdCDuIxgkAE7Cn0lBdjitXcgoLQvRh6QZOuOq25Z5arwjYudNzyods6jhKMnsSnpyIQlM19arfpp9idLnaeZb0XD46R4itEbBcR+K8kC9mDmWOhO0csoC1lRpPMzSyfUemmTPyuJptNdkdVz1cE0UxnAU0404x2dTGSIHNIfEysCCD9hVidJ+nmD7NJRkBM5h4SAsepSWRQkQb0A6q+XxaAKv7SfYxuDHd14/5tIvzn6auzw67kdBnJi4zq74j8o2vLcmR2ZV0+I2UuAAO/EFW4lCAgIOz4JJ3Zo4/6AN+rtOCXrWqyg92PXsr2EwaJcz8tO7bvDMx9GMEMQWHewnkR8N9Y5YtF7EVODnSQ7nTLq0uHiXkucWfr4zI/qiRaRdh14B1AzqPWX0b4iIwyEdZWaGmRzP2xrdZ+fLzPUGNbC8m8waMWRXotSshGyfAZGMfDmFf/HJOmbhDaFH7mhJQEOwalPDINXcdkx2AbOV9k6mQ4n2ujWcaXAIW4w8kaGfkCEWkGkNwPvlLKqrVEN4xSUopuvtj3AoAmZVMkHFldD4Yf8yTUYuPE29TDMXfa3+CC0vepvBab2TATOUUp/LGyT0p8hmFeFyw9ckU0FNgpYqCDo3/15p0Ruq+hmX/KtfPubbbU2GJvFNuyhkK/VrgdqGRim95oveScufEARBNcA3mhdsYP9xJe+m3EcmXETNWiUfR2qAt1hxxBaBln3wOOtl8m6d6vO7SUUDCKx75hQospO52CAFtHgCSJbgTFsuZKzmkDqt2La77vCNersXgxlPn5LVlGKCDTp1Qo5/wuMhKvCiwoaZvGDxqCkxQk+4CLtoeZV/0Gs6Ny1Ybs9yWhohDC1Nsx2aJ6Ug/SJ4DrbuocOc5j6zdsP1Uk8aCgdGYYtUT/RNoHudJt8udwCZOtUqBhGD4Oulh8hJEL87V9bI8yP8/s/h2Gxiv4pBBoV22/HVIXMN4mSGSz4jxBHgKWZJgqzcy0q1sccQT6NFC7HwoFYbCE/CXVrsBMqfDoW5O9ymUzu5JykCF+/hw6+e/CHo0bYYsdpZOFopeSAbtWYWfkNn4nqUsLTso5MnWyALOOXRfWm6NhyJvqv78sFtYh4o/PKGuGVigy5ED4NfmIvR7T4KdQiLoSz+duxJFJsCtFdZO3c2s9Zk01SqTGI0SBF6i3t49m7yi4u9Eedd/j8jk4EqLEJ2nR8w+YhFNUv8tvdtlXacSlmbm4pGiiP/9XPXEuDEYSkBkFQcpsD6b9b5AAfA/vAYJTMhxx5tkkZuIeznrv5IR+YWkXS9MbiKvEUieFa9LaSwYOeViBQJH7AAYaqVPX+7qJZrPpKlXKIqK4bsakQkraIYSLzoporAbccQXAX2Ipb05ju6xyxZEEtw6t07pbQA9yaLHBuS6mxJHbgrYG4jDw41KzMHCbl6EO/E6K4fZHMHuqAUr3Vxc4MwTgBL0ej//PHrY77dN7UnSFJaPktkIQ8XKq4QUp1Y6WPGqVfFvi1vvl3t9Btys1E5d9NcTdnOemF5JwkM0M9ueOunnKtxL6uTA4qYZsxR82DWMmdLjpN1pFA86GKqoTy0hhoOS3jEryVGBPgCnAdYmo8HqSLkGlRbqzQGo8TGws9Rt7oFoF6mFTsUd8RWJ+aXvXznH/j+8pWkWOHHmJzvWEjMz9NrTpEesl0Sf9uAzxDp5xWKwmpsBr4Yj/cM+awOWtBK0ukz31jf3085gXLurjiquUljJ2dmY2MMYqxiikOhD1+YCminvODXpCiB6xtoUYy+xtqiSkteq41GAAHa+zBYKEh8dSPlmckvRVjd056//RtxG4OmSSy4Q5qkIZmfmf84aYSPpUUvQx1CtsE9xFq722RbWYR2c8lUPl9AEKO29jNhMmuQ5AduixajOllXtbani3yJd+F1FmR7tdjur1ypqWOuvfp/YyUAylk0/ZtXTTThtYt1Xc+GiNhdDajSLwtuBhH6TWRR+20LDv6MHrrQFHMn9TuIo8f/OAm+uWxl4I3JolfTrt3rAmy3h8o6mDJj5Z7qw3MNPWTHWBDoLqydiaFn/wk0xGnNZXWgh/CJ7h6Y5/qb3JexJPk0UQ5bQmGcs1/7iJxEYv5ja+Ci6qrG4mghe5Zqj0CxzvduC/v7Q53i50AsE9qzU9b/P1D5TVcbOTvhJBQH5GswX+GFptMei6Xf5+wwZ/ENI+p14j5yI4u2+OZHzIygb/LWeqrip8rA9Cl/hZNaNgoIIkRKh0U/eD6Tz3VEERNAzS0U8Ynyuj8lzK0F9hB4Kf3d6c/yHBl8JMf35VXYrR6kpuN3FULmI89l+gmrgIJZ1eisVk4nV81IqJAOvQ4wTokowHAESsR73idzEgCOeQNrNniPI5FFqDYtUN1ujQtj4kN9pmnV2VbFKburA1NwBHPa5oD2WnIY6HZ66SFrFeOto0J5F0zdJKLP0etqujTNpqUDfy9nsKnuKZe2Pjzm1ZEfTn+LcS94Bc4BgyNVXXFTrqtA/7zrZ9HXZVLPUIS10O3L9OhnqIf6NseYi41VfqMImodD6OgDfDrFxx+LnABF+G/LDWwwyOSR/NxPJgjQLAWcpgYKBtn5OCtdiRJVGxuM15M4PzJxQv4/htbaYWYXYrMquUwRb3r7UR2fWldbNBEhnAksxQWQdIplAhuK0v4u/472Rlsw6PUlQWmc4zSwD2r4oSKnO1nLpUrvCEY3WALB8FOuQRa8YvWoDwH1+DncPEkCfhfRPCYUvD8BUXDxFFqiRyY8MGD4/6emPWWmlYZH48acbrvDNTIjtk05r1TTUXr7rzj/9mrH7ZEZduIYB1Oezf3VoC+PbiC0PTiOyR8PgNW1RR6D32wci8A73z+TYg/8OEQ3AlmzbqTRSKIHgCuOaA1aTi6fkpClpGEboRNWGHq/w7oeEkHKjZK5xfucNmZRwchaw/gbwvvvUu3NI7OfLYHglNlO6vWJgYub/Z2ruyhiUlnoLgoYR1GwxCDcySzAS3nzKj/q5XNI3DJ8uXgj16i6VndEjKnOMAHMkWAnn92AcrkoMLsc0aDigLce8Kq0TfQZABRvK8BXwQLIXxGAq2A1EgaVbv/6u249imfct+WURg6PCgoD4+02IsD8LgsCMfF8d42AmwMmSEDn9ExgEYpwG63AGHzYLzQdDjQbenNAdzOSKColXKXdx40HfiluFPbYo4XYit5shP+sQM1RM1M0E2bQs6//Q7URjG+Dcy/9o5WBhX2FT9ryvOurPLerc3I4ZEhXDwRCQuQt1CENyJ0/TkuQCgdZFs/oQl9QSwiq83rUSo0x/tSZBfwe17NZ5R8sJ19nRGHiiMKRNShI2lyyN1v9lMLrpYksIiwJYMM97IPDXRVx6ft7PhoBwqw/io+F8VWZKD5dVe/WSDzO7ZclDeCZMcV50ZUPQSbVx4VjXGJwUPszmnHgIIme51f7SzaaeVOKr3dEDwltZnvaMtYfiT8QfWls3ZDBJ/Iso0/+UAbwvi3tKlIO1M2Iy6Cew4w2bkBNOejZU7B2BQgpKSakqRjUbf/GjzrqUgBLEVjceVcbe/IJf1ooDU7KE5MbknjGDM0oqZP9AWzT1MoJhgZTcxows3QybkoEnQEPSQXAp/5i81KSIrMa+zAb2DysH/vgEN6cSP/y3xXuZNHstvWTugJdqDGKAWvY2g30sc67ZrlAiFUtdY2sdZsD2wTt3aw+xadqMeOSV84Hs3cfkAAUcFKkPb1sHyB9h7vWfzxB0omBfYxvAYPX1dpob7sZJwOLsqaO09/SMiMhMr0xPRXZLmwKKhz3Y/GF5W6bhzCeYDGRu1ysGXwVjEI6p3BcbVBqNdbrKxiHZxlNe2fAlox3F+O2gZ7U5dVIS8KXn1+xQTwUuhKPCzq0sPSB0BZojfIzP5tsMKlGAE+tpz6yXvM1ROUdey9se6dOEXjbEFxFIQ3EoRerHkGy/L/PSgAWBoPYTz2hCfBnJ1p5GgrUjSq+8M21tpSpWGHb3g7PjMMZDzIbI9QXMiyhpwzRTktXobkjWK2BZUXBsB4Sfyx8VfpzUHVMijsMJq4cNiKBk7IBDaR6wLpILOkmv2xQTxIXmAY6Qj01gZMGSkAGbuDNS8xpK3HzcDyFhqcKy3pCOr/+d0iC4i48sjmy7xjgMxhR15VixBDGEIUo7HXBPmjsdP9ZlL74wmLQcwQdBz6A0hKGD+BRRBLlZgP1mdJvcC6feScWo/1+heAvuYoZDV+MkZbyNWZ+exGV1le+ngPdL3iIxkSIA3MyEGlFC3ULO5gxRl0BjP5r+QXsFsewm7A0zEUqcZ+7hxg5a0SZ5YkkcfNQtKyI/Q9U1cRVXH1/pBYBDVSI3WOOHrQTbRT6m7cGivBm0do+0mRBf/bpNahm1IS+JAO0cW6uQ9pAnKpA+VbXW+HSWk0wV6D8k2b4HuL/73B79tdTT+u1gl28Urn7u8f0y/xmLUODsO29vpmnEk3OAoRy83fyxkOxlX4V5m2p8CBFXlLcd5fKKKdnz+RpV6MfWzGs0UqrWSIiV1QW45w453B+wSlsdzCEFJy4cbn2sZlyj/yaV0jlobT5qwBSHOU+BKQa0G08Tz43wOyYf7XHzDfzuc6b0aNP9+wPSul7EKtRgN+4C4A5DzWmmuPzTCnjRtU1ZlDCCyeiI+noCOw2buHo4K1bla+NAU4jxDDMgfFeUTPqXq6AKgM1ZsPW1fI58agiJDlWbKE1JL6icjO8eVkwG/vA199yV6sAw63O8lXfFWILT/2EC/j1+AzDsfcfkh8efroi6bt6+CXREs3wu84Ic4oGOfJL77DEkglUXp+Gnj6TbBFnJ2VeJUjRYomQ3mjsgHdjziR3sLIV/2+CEwgk8Lf5aiHrtcFwyZLyyC/GIXhqDNDZAHXzw7zAghxSfUbdb1nz9mX5k5yWinqh6dQSEuSUAi+GNDSKVLgkKUqVdGAnOyf1sl7U8CIshSdtf/GxdCy/xIjGVA5dSt5XuDlTwzIc1JyPToMUwwIGm4rZZOOsnlD2k9HFL9IEpafFe1rHnm0os/OhaDB/e6AgNxlpiEOWhoSzgP/WB2TxyZ3iQOAY8HLDmAarOJ0creB9UR7an6ugX1cswxwCxMweLIROgkMvlwA/F6uVpC2X2dL+tXJ2KSaZIt/meHpQEJcqUQwniwfXiPGMZ1jvi7vyVTpW6yAmMzbVyLbEH1B4j8P9JpJiYAwZ8kAaUG+P/q7CX2/km9HXK6sVHarwX+CWlADTI9KqugxdrC2Xk6pDJ0trCgRxD3MM9udKPolEZKMYU0Ezy9rE+RalUllHoDokJNBJhDllR8kSYHnhCTz4c5Mte6WMnS3B7+4BvZKBGL/MdDjeTgDN/3EpaePg0UetKO9gjirNwxmnpBSAzfqifvrlDMGDZC77rkl63hFHVaIL6Xgp61LIYJe1fJPNJ8NdO6WKhIMA0xsROmCelQBi3S+gXdypbdlB3h2CGpVfQaH/t109NiYYaDF8rF35kS9+wum6eJB/PtnYGihJokYyJh5jgzag2RexFGZozMKBxlUMnS5wfE1YnuItAqpA7GNJ+BTguPIGDg1QMeHVRVxIS8rDLfsS9H8CGyHRlaHqyzFEHs5sk2qktUsss/5wlzBPBsbu8Xu8VAG+oj4Uy23IAyh9FlMb9Uq7gOCGO2PWsOJJP2kNyPll93Od8hsJRBzOaFja06Xh2C19nNiJR+e4/xt/iuKw4oCCwKe5JH3b+WJZXF6dkmQCQQcuAFJBIc2edzFwUJGpBDIeNRZ5IYQjmWKPcxNlaXHfopAM2rjpIhW5KlWkf6T2TI86cerfg5GTSoL+KO2tuvHFQX5mwazlFsef+UddwO1MMOlb9VIxx0ipirP0k+Wsr9SQatk5voNgPUX+HW7qczZBmyB5pFkoLJEZlq4Wtt+8ZFiV7OScIUEYtraUddzgH3hv88vsEljenqKk1OqTz6WMwKHmEmrO7k1djG+t3Ik2uF2i6oMd8iS4a0fhLGd+2FtzNy2QcEd85BXEVylJ5ybBx0pjLBwHnAWw+iJpXVF9VqYs3GIgMng0E85wKs9KzuDlXpa00MtBH6wCBLp9B/Fmm12t+57m2CvpZ0lSLaOY72d9F2SaBp+IuKZ64ki269ojFaCp9DJtuHIy5d9pl/SbW6ewjSKwhkFxzimwKai7cN4/rplYqLMB2Pxcf1LfUKQ2mxhAZ0XdxGckPET3Co6HWBamH5bP0v55gA6bEO7llEKI2TVzDGGyjph6FQ3RXQlpaoSeO74g7rZLbI3TOp2n74Nr/1f1k5balsWrg/TQfSAHYkCaR8NXuApLZgDVGPKaDD0Li/lA9CdOoqLnoY41DgdSgJJ7o1EFfGgDrK86QB2SDRSyA8Lj75Fy1zeWsnNR9djgGb2ZD8h4RjEnOF2smFz47aaA0H0aCJ5lP/ZMFApLNAtZtghhjBJqR/uF3BiUQNzaFQVHMxMe8JsCg6G3FRRaLwe0Dzsxmh+rDC3JjdSDtzMxuTEFutYGlhV9Dh07IJlFERBGHBLAeO/BjjwaLtLItJgZMAGvESrpPFm+NwbqxeTB5+yzWZRO5EdUBlx+xk505ptKGjpee8qtgpM2q3Zs0tNuTGchS47TH39J9CWI1GW65OANcRmrc4UZiBcP5ClkHtm9QojniOrywnVeiC9sgmEOhYCS1ngVe1OPdetrCZBv2dVHfuIgrU/v2jwRJlQr0ZWwlj1cl71i6l1L92/ie1Z3I0cTibbVOCHd1Lduj9lSwjVMMzSEuc9WHhWR1JnNBuu9puAMw3M8s8veK5W0/7lRqqpkFZUs/CTfEIPo1N1GxAZFipjhb8uMFsbk7Fvia/iUOhx+wjPt7A58z8KtMc4ofngi03tyl3FlWjvw7H5zL1hoq09MDatMx+j7dg54Kg0B8hxvykhN751D6L5+XrjeOvCoXPtde69tT58N69NC5qcaVexhe321BzTi8/xCikLqvQblQUHjU4ep3O8REpojS4OL6z3d/aNF72HY0DdNsKvh7FSTS3P0b4qr6LRb8peWJsf4YojchYXO89P7fmmBDNXHlzVIRHKkwoVVC/bggm4ixPkv+VNoXfpA5nmvZ0oHQ2WxjfuLk/lq4w3fKVapDLnWsL6OoyN+5m0gTwFMoTITzJbvWgUWF+GxwM3yVUzZHtPA6ztQ0iDO67ruaVbHo+EFHqBb3+wiTM2ltbFQCiug4JvX8GLkC4/CgwDe7WBv6YACL1rKEM8j3cVMtTju2UfoU7f2rjLkmGXyibDoVCqloSKl3OZ1/sIAUyXMXAKd2ts15FsxM2nr5UMy3yV0YVFrSWdWZcwSRoheLBEEyzyWhpR9QCptfzq2F3vNr0yNGhWLrbr1OyGHv7YqeoiO9/7si04GGtmq9iZqs/ZEMNjz6MEs7Yo3WBCpOmabdGhKoJ8kkEUWSZipCx6sfj9hsgxsR3qrXhY1CYy7USfqIL4Af3GB7tIHKXT1JcCeLAU6ja1ZJQha5OpMHqV+YzuWbMXFZ8PgGd/Q7NkBEz+0sHJhfRcZFwEkUeZOTjAgKSrnKstAjIhfZfkHiM9m/6Qib4U5Az9eOx8aN/4Tv++0DxVIfRfAbp5qVhNOasxZUpnEQCB4e94bx4xnAqYuLGGOQWXaz9h/hyPvm82D+TkL+5xePa3+4ET0EeCA21AoJcyArZdb7F2Pgv7jCtR+InnHPYmeGldQV+ecp+k1p2fpnPhzXEFzAxH7ZC/ZAXv5wXaXp8Pg8Z12DLfzO4vbHteK0HMNWr7SWFlPcZloRcCddQPHIo3HM4oujRs1LRHOpK27O/20wLGaB99C/aarhUR8Aa/FW79XrEy61a0HRiK/teODwP9raaF+httUMsE3BMl2jOHlml5yZgtGGXltwTB9QilSpIW60lVXe+eUmnYqkYfxA16r44XOil4Igy7BnJSQHYBszNuM8sLlu7rUsw2B4AJSkc77TzT4RryHD4vdyLUka5eupJfph/42kiQT7tbLbIQlQ2YlzBuWI410N8z6IPlf1AP1z/XqxO43HGCsWF2ik3l2ZSFONA54yLN8syoejNcsGIjL5+viKaxVkL/JtoA4CpbvGkdSxZ2HiQHMG2pi1J9AYzGZ3X0g2rN8Jsv5wmJ8JAbcHvWnk9+lp4++3BJYEdVMHm//wrbyoL3rxS353u1hH4sPBZ8CP+cS+Nis7fsNiPQBWIu52x49vdNFO+f5DkP9jnNH3lPdfq/MRGUq99ZbUTfpj/7I7hdz1ihG29FGzz+SeTM3Ycx9ar4eoZBG5DhCj/AQkdaQTfCAZtKLH91CYqoTBksIkiqy3//yzuB9ZQuxXQ3sAH5CVkw1PFjp9hzaHyR3nrfVlRoC02gsLigLtqk443QEmNmX3urOZ+RaTUgPSzJO7L4ou/LjwALuB36Ao1znWjeGCCqbqlCDItDr06LTezCN++AbKONzQ0psNZpiHTHSBFSRWtfWq6d5Ybrx1+fqOvtzZFjGr2IO+TzNFVo5NJF0Sd9KtGfsN0lFd1xHCZfy4p1LiNUUG0/0nhHL/Ng0uNmV/S94TOWDnVJlhATvzbgbySBNtc+JuSV102RYoH6h9dXBs7yxpvHp5yv5U+R2/4MqNKnH5TYR8tCpZs1nUam/LdZD9RayQ1nsflOb4wpscVqpYxkAP7MGETrXBUsZnWsA2o9lhQQPwkABY0MGnKZFdw2NDAl6O+aVvVhtzthidwKpTHEtjhsWxfWELHEAJI1KEs/5FymZzOOoztgP//X9C6iIt9pcss8BnrdTdrdFt2VBxpyoqfIEk53SdhsXYl5Z0oxurK5ZYLTrmYcwHx62UOrKqwSP1U34KmqPqSpLRUqgcZGqbWviSsbXZU0j801KJv5122iGWvdD/uahjBEfPwSPafEkNzrOai7dz39wjlHbQ7dVbXOsG8xz94Wta9dbl7fVg0zliVZ2NsM7toVWe0a/DQm4spw4NhwhF6exLMhEeLWfQO+u8H5gPG1mCVkZLkltDuWE2kJEiCcBNR6n1JXmtP9Z/XmK+BK2Vzb9qlG05KSZ46kjpn/bjp01TGeK/O3RS7vKHmT9VGZSWVY03BvoXCQbHrcgmTsiQKJVlnqTSCdA5SVZjYVy/mhuJzd2Rg5rkfa+78BdPaNlTM8kcTNzGd8q5EVKAUFQONWRXNvRvo49svxYzECf4kcjqM1ht+NjosqO2pWvCW49tX3d7Y3j7YuUPgj47Yj7VDlmzAVPceCUThJMCcpxqMDKTKkdLoa1ZarFsUhC3mIszyF8gKFevZ+qKcQVVHmZI7OZn5Pus/bIVWuMZ3PUDi9S2gqcijL/mfOq8CNAD8eERZ//vs4VaEaIkCrF0w5mF2x57wQ9iSHbHqAMkmOyI/DoYQwHllW4hmXrpotDpENDKuSAWzv7bXe9sOYCrgOrJEEr2L+aGchIj9Ogviovafv4mzWC03SB/qlRz2HaVkbCcoDOuUtgGlkHpzsLDd0UIaWKqjs4F37ERXCVIFSNJOTFLSHqJhZrvPZnawOcYmHRNPStDJhR4h8GYSdajYxa8iMdYj8A/64F5Z16TRUbaziDySsTnbuKlGAEtPBrvXzXN66m2YNUnyBWPU76Ar9EgZeVLGBF8acbaCaEW5klbLCjm+yo9mTvSqjKa1bp2qPLk0tLTXr0xd6TefqDefuhpRtJYdxmaiUDbBwLAUUvNRz293tkEu5un3uErioNEOOrQTMm3bd7cyW5XgDXNozXAMJWzmWhdHOSVTHD1757a1hfvcS0ZCTkesAkqUSfRSPMv0Df1GNVlPXv4T9HPGY7vnOzHEQUHdEcn7KvF9DW3Xd4vxJKQDb08bSuNUSFt5W/KC6KFf/MDDlBTn0aoIM94jdkACfrYZ6+24RX+ttsQrtC/tRRDKfQLdSQTwZn06dZqCM1LFa6i7q14s0hpxsJxfQmKMQvLEn3piVqitUY6GQsKYEm0ZvY8QswR20lTcwoEJ6KWNwHCQesvcv6cAietHRJ/GNbOg9stRob7AOnkBvscUbt99XUaIqNi32NHVynU8I3TdjspNF2hZY/df0TgmopeiLorWCXpM7O2yo1NYnvqQxjLrT3BpJgoBpkfqcnWYySQO7++XC03h3F/+cWEVlMAw8k7pbI24mpIg5/5IiLf4MAdJgNqZKe7XvtFdh24z/j4sHCerIJlNCNEOAG1CaXyjOlh63vLORAPDD1utM4nynbLrDDdo6Kow8D+7OgvRAOlGwstVFBXgoIsSqQ0LjXsF4YgMeIqCnsvT+B214pqgBcGsK+xj6SovzDpl76LWxAtygduJJRYWElvgGeESK4yLcTp5Dwbb8VWVaZyZOGfSJaFbISyRb4RqTivY2jqxI3CQ8oQOqfisicfVDJX+BwMvXCLfvD2ovhyMg36pngY5VQL2rsCRMSGJFl6ks2ce26G7Ba0bavXmtECKxsQwWwyyhrH2Qf/4KL+BmtVqLAaA1Zpiqt9Pc/UpgdUsX3aQnIe2mYMqOpbU21ih5wE/6/wHyOC4e15sUiSQMcKkkbHV3+KINsa5TB2K4zx1AsHpYQVR/y6eq5eCcKSHPF65gtCfISkYTTsxARcLllIKC43c5lSziNvoSYCEe4M1XGTM4RJTH+GukxNbh0b1UWG0QBDJ75RIfIAnUdYgQ+4lhzT8D+2vWMo3j8iLkM9bO4bfUfP375e1yMZBqmnDI5PRKeOxAjM+N/vzqNZT3pJxA08Xi5II1lvcW9drJ4BgLYYdQlK6hwwmoYBx3E5oQT5+nO9bAoJDNEEq1JK5wd9FsJ+Wby9bP2LAHWk0HeJIX3NlKYNndGfbAsTBAbU3eKOFqiZqKgWn2P8UXJ0eE++mCP/AG73UprOR28vrBfq9Q3BoFUC1zBXPUCsePdSO+Wh6hX06tVmutoxRoYNPsVHOzKVfs/u8hQemNprQWKvkj7nrop7ci9PgIXIBtbnC20nI5/O3TYpl2wd4miTzPEG4OUt3EekN5mZ4WmsjbZXZYJ1+KWn6KcXM1So55rwAGNsp27LXwfzL/ylZtKtNIU0DFeCNli0rf7rxwJhCVKqUkJmoekpXB1UYHRUIymSXcBfM/97cSa47rqO+IL2LszHfCehRajx7ZWIXVDFOGExrtNAqLSL50CMRzCns/ugJATnQ53pbouyPTp+dmh6u5kEqO8TO92gGe4whLpdvOxWiVklskYpFpQMS1EM2lcbKrv7HufipP78zl8gE+c8hgonhetVZL/FnYfOGwZsjJrGjR8JhlLl1V/hPp/izuyw4Ue7HyeGkKeq8BA724l7LAQ1fWWvX5sh6erwb78cVa6OVRjoEy6TtXiIOfCSOQkHrIGJYk3rAO5TPYZhC3Y5keASNR54dTEgwGpnowOXKT1fkzMPLUPtMtbdcewMg7e7lpjP5utuqM/MPRPefabezhav9OeT99h482tUGubbJML2UjOmwmh67mv9dPlnrE7EULuhjD/cmQGdKVDGzCdV/96u+aWXVNi6KrXTka0cprqIHTIJVVuTMa+vRM4zSMASNYzEsRz6eGXnxWm9NaJisiR6dymJ1w74C9kC++KDtEK3US/56Iv6XKTidNTx281gRYMY/isgUCwfzJCJHGrOS1g3qGpK5oczfB/F2v6awaWyjwuW7j4errUEeLuS470CCqzOJpeZHvjcFyM0Y0W2S65dFJDvpnC3UqJjjgmsHPzRM2WfAb/KO1tAa1HigR1FXfkO1NY7YbOdz74Qm+CZuRzpsFVrlY2jOiGSkL9TnuUPhaHZh9MWnZ9Z8ElCtDgWjcJ972ldlG5EceF4xvyaP04OPP7rHVUhWgUfja6VECLRWs7sdJ/CEEwkJdLLIDFU/1Ju+1guYPYM+q4ciwEU8cVZuZv6cwjbT+MyjeuFzLn3kwOLMOtIVB4QkZ1oUKDgPsc3w/imz9ArsCRNCOPkcV7YI+kxMS6uByK9dQ3nyXj2h959jJpAhsy/WVNx5mIZkn4sFXl/5cDnB3893EtKDZ4GbV10ClXvMIAQ8ty+s5FAP4rRf3o091S9ZM5or1DlAUAYwA5msjO5QK63Ub6Ud/jI/75X4+3Xw2RK1ny+e2UYIiXAirIsoVB0e1pVW0uyic645yxnvpqYvB8qyom1xvXKasjHj31rKS0PvSIF63RM+yinUxxRgIWJx9rc6zGQ9a6/kgorW/4j8KKtkhUlOkJlkeB2dbleX7Xihe/y4ulkstSwrqgTShl/728EkdA6+LkQrlLIu29fxKRdI6JYxBzrbE13UhQnMDxuV9uQoIpwD2xy7zoJtpXadxxpIrAvnSqbnJx93WmPQQ2BfFPRPRWjGVGEvD3JWlzioMkWNPuqPRrqFOPKM+L5IGRPyQPWuz8hi8QWl32UCqSISl8YoYTJQd8wbNlRAH59fjnLYdJh5NBEZ9QP743CCS1VhzBSR/HgTfDZoH44yQZQASobfplUUy94WLJrZL4G0ZDMfsVQg+rSUAFloTx7kr+UCzIZMog5a+kYI7SS5NfXIFPY9rCKXv5744KqH8gE3qlu1mL3sJoW3RDQs9k//uMEKC0GjpMbvSbk+RntqEbnQAx5+nlLCt0ZIFgRC4yPPMZccgzaKaQAgbllyxrRfRSyluokRUCg1hQe6BrAUE4rhUt9GYPUdnqdSYshhuDD5wKfwI1NeNljXciyL4sUsdSdi7pijxl4L8n7nVDREriYMrK7muKqFGlQWavn7PZ1Lw1gcby5nYIjYyUlrY7Qw0Ujev23Lc/jMouQy+PWVjxzuw8iI+/4Kzg8oITjwoI/m1iMfHGYq5Ww1kyZFukPRs89ZXwpyFJtJiaKONaqwYfGL2Jow3ddLCRj1VfFXwgX5g4q3aSB61ngrb8bN+GXAfLES5HfpcOsTxLtlzHRwt9Xu6ORBK/i+lGBrJH86cVSJPK8Sznvxe7UYJeY8u4Du+DI5MZfuOa5yrANRKGKAC5tan4nVtqMHyaF85w0KwoVifwwvnv6BjRjamcD44jTTlPrMIpjGq1tuHCf0NKZMk2NYXcV+M2O5Cce/4ZRO6kA+jJGLGDCRCiEgMuuC/VaWPXGoz1KHapSpHCc1bb6o0fG37H1F+kUL8RvIS2VZRjC912VpQatoqinhhjdB1/Mz6HtawK2rCY1MzGb9TdqtxRJ87KFo/df1EozhrVSR0fh2DpRXd8MYDLNaOVZxEc7q8TDgHWoE7uj6appJo+IJy96bd0Afk/0wVN9dtpl8etfg8K3IiX/Fx4STbGfusEFIiFoojQalJSYqibdPTp+C6KK3se2Gxf4I6BB8zKscmcmVFLVlDkFyP49J6m57gaJPSsjCm5vnotsUZYaLjBiXlZguO0lO9n2rKKhgsMXcdpAkxuhbWWGdYNgRKUlcVsWYqukWbElL+CCHYdk3eMWDK651zjoEEc30o97dMVYsiMseycDoni7b2mkJwxi8vDHmwlHuZ5ZpxS7tqsd45UZ0Phl1nDRNPkzZlZE6bHR8+e6hX4rSCRz1Ihl1amx4oiu1Sb5+XE0O4p/RW/usFPlGK8pC3nI61Kk+fn+1QULnLyQaZ7pPCQVu+gUMArZAg3Nwei9zxnNsDjpkS4q9pMmBlByNuk4dKZcJ8tXKeV3DbLshxTKjWyuvs9lNFyfyrtsNBUXx3fwNhEsN5DeN/Bfxn2lAQbDaphgPM+tE0Lb5JVCyobZJ6LazVzfpOHNrmGvWXNr9VtZf5uySNK6TD/U72bMeNIla5gjQJdlVJPPYzYgHE47WWheWNaAITyAXpYSjQEIajhueG1RkF4wNajn0cswMgSM+eck3DZGZ762cgEjmC8Ng+OsSK+P6saESozo2HOZ68qrd9lECgYJ9DIM7xT7lvoMc8lZiXt5Mi5f9L8y8i5BEB3DWFi+FTYMC1QB/C7UvWRSiVT3GMd0FJsI4EcwzWlE4UrS6XDI5DU///KLTt0/IhlNFYyEHHJ1RIpUMEOGKzuy9FSoIS6QGbbFToEKfe0E/qw414uSAx5BRohqtuu8gZXWHlQIUH/qROnR2UPUeeLZQlnYEjE7we2xfkZAvkOnsIm41t5GGqqjl9iEowVpyP2UCEDnHZlkizJsT02PsKFPHhc7LMiOdOB4HOHvzcGbee5smTpzHWRmW+HEET0fq1psQYMsJXpq1N+vuoTSCQ4cHTte4b2gUBx9CA+pgqgYxFjDMP0BsFxc62k8z91RBp1/xyIJ3UtdGXi1L8LidC3lCa8EUW+vWEzEnu4GiwAFTRPTqKhbzw2S17tiAiolUdQaw0gmnkCxE0Y3CXc8Vi2R3YzWm7v4uIKhlmvc9EiUIsPGEnv74PLRbBSaQvjFaq6lQ70y1oSxgMdSs9kL33zw0wuzaUJXmXE7EVsfeMZeALZh8V5QYheIeUfh3n4EoKCoJdlvFsoa/cz0YiU4eCiPYYC8kpbwKJghLQRnmmU5A2j+0ajpQWJrDRcO0pF4BgXq8It5450jSanW2hDgjIZop86030j51m7zNy3VsCEUPr4/WMzOpSIgBpUYTil/tibburlp5UAYYYVdo4723cyOVMnn4tpAdPqXgIn+10GuL/PtrxFBNFn50UD1KbqoziYVv9w56mrdvF625G/46FmB9M33YXbsiUpU61DYyCnSr7wXCpaH7v3A1g1Ptyc1BbM5K/1Gt/p1OMeMqxo/paiHt6wXXMe9dWGXgBXK0kcT8jUmJcr9FEThwKlwNXVPTPtxZLvzFUQRT0HUhLIWBH76UEjsLTtj4WirBECY+BUxCwoilZCL+mWtYMhO1UQMGItQ1i195amjpfQx0AAINrBsEOlH/SXj1vVVjN4Hs3uU5eOrWLMsW6rjAwlQsl905Cefxu8Vm0Bykil3U1emhgRyJ3uoDf3svibJr4q45sEzHuAosejawZjNf39EZrBGJYY4tOqez4YiwA7wWlEUQ/Khlp6Kvr2ex3GLHiGXJVD8mMA2xYP3QzMOTh9W771VvusETHMJ7r0+2dEOWmzRa4r0MAijCA+Det9qrphLk5/nAZlkcKNEo/1IGx988w0qAF9vHLg4RM2ec28+1X5NPKg7s9QQWGzwRGYb3tlA1TvRXfyt2+0HL0ja+WhSpLy8zmvUurvmgLedD1Ij6VljOu1OLf11wBJLt7bSQjcW/ZwaLBQFd+g9lmKWD2ctS9pRmvX3U8m69qjvVSADIxjB+OrntJ6Br+fzIr8NoPa4qpcgdvefgBpyLSkyM/pAHC5TcZD+ZphaLiUM71Boony1kZtTCMyLrlXdKdkdgMe3wzcKJ1v+8FP5rHvRwx2AViq7JlQYtvdqz6RvGSehuQPkLbz9wQ1cLhdQIJO04+5J079lAjLPE5KyOgXfvgGGIdbDYIjVH5nd0RBOFu+pN95pa5HBi/Zr/22Un9sJo46y/ofSfoBsx9hc95GcpST/JDoV2DZszqTTc/EupO8TU5BKeJwtF1fphgnwu1Earf51OtUJF9mEpjNs6nDBJEuNEvr8Hy/OySmUuPy8+YOjhhZpMZ4GuqnRmWz+W+PzTqC7JP8YjSCfFE4uRM9eV2sc7atLHUTlCAOH9gEEEg3LJVcIXISjNVGJj9StrVHPE3FW+/TBkGS4aaknfkAgQa6AH14I0F5s9J3QBaWes01w/yE1H1aZQ3TrqG8YRejj3xkFLi8VDSUMrZuhuLdzVQHwbEQrIUPRaAH9HAgP8RXK8EOFP5xC5Icl/6Vc1lqdA0k3+FV32HHO8CNbGeN4BkRwhRyPa0tKo1g9ThKpfQYOhp5uV5DwMHdAsTeYGM8kV7JKRPF5+mOdBHOzhQ8YrU4SN3CVXmwtf1osawksk5VRthPcTa1pkEkkiq2BM3ZxPrCinqsaOPe2phqf4wel7qfAqriiBqFfYGaxjGB4km2ky77+bovatq8qUUFKA5RPdq6kNfG+UGqGKEifNkKe0mmx5gDzxYLcKV4t3IVWh2t5wfgeDTyjeQcYeCh+WGKl/NbTVsxgXIib/cNjbJqAiDCOzamV+EXXs085PmjKZyA5+Lbrh6PJxhbGDn0NObt9y7dAUuPb6uAIRDyQXKN3pfoVm8QPAI6hZG5iFjLCuSp/lJh3PemYoOH/Ts5vF/hNe9q6sdPRcDm3GRPMfeOkCVP9fcD/xgstxMhnI5xi4CjtqJ0TDKuICmeqKF/Z8OBNaMLBujXnwcZLqjM2zVB+IRJ/sWfBVtLPtiS56JK5T+bTICeCIp/iZ5yIGClw8nQ2UzB/wIBSs0EdOJBnRpC1YiOZ4u1fs4L56lizqg/lc+JnN0TKj/4vzvAs3AaGooKNiAFrA3A62UDe2j46ZTY2CasWqkXLgPq7aq6HbcGRHzRN/RhYe0XkR9BJbt014e/6Qh3W5DPiv4iBffBTpnVWDyPi4eW5YAVM8yH4tbD3c3m0mQjz1LHGgutCMGQccG2OHNXpvS8CBZbgN+u4J2V+YOJ24ncHNnFLmnvSnrNwg1S9BbzxphFvHj4Jc8bsbyw68XW//vz/wYLMQzG8vNfX74I/iTC4TDWHjcML7ZHrt5XyT20J/V+3TFJqjk12/dZF61Vd/HUjpXG6m+4gSm0n73KMatq+4o246FbDrQLv5b85JPTRgwuOXWZQzDM41nRiRvCbBPY1YWepCF+QNnPqXa1cIJTEz9sX6b8qlCw23HiPISIIccnf4jxcw1KDoxNKEHVD4oo22C8gyx3JDmAE5sXZUilHSLbVbzgC5yrjDUA2Bo2YPdUsbKsFxh3h96aboQLc0MfItLCIjlvW7x09fckTUklMZQKuO6fUI4hJK12vsmCeZ1n7M7QVTRZsW15BwlkK/MGCcXDXohv3dfCU+ZVpkPhyLmVUIqVMgy4sg+OMCQ/l2vzr9GhT0bdbZJsUTTE6R1cDdtDh3sMFHf+PcZ2gPBBs4ugt23yD5xMqewdIaFIeQlVhbMI8T8Q9X5JYQOi4dwvvf9yNX3MLakiz6wm63+WkacbUzB4zNwXegFQisQU5aOwdp3i+5SnFH3w2D/jV/AH78q0bsxCnBUixutJJSQhYUTwYuKG2PJ6ebs4Wlvqi2tYcrTCCnLL1rZUZVKhK93Fb+HjURe0eA2MdrDOM4JcrCpNsVWswCXx0E6r6tNcSvLYxZO5FcyPvG3fMvQ7QipGF6jK+A6U/TeNpTgBMOygzQcOXz4W591lRKnsQrNZuMB75A0gp20Ck+eBtKU2jzWthYUqK+vCWGicaLvBsI74zCWMNjd4gtf4KEm34a/e/sJbTzfQpDj3zggRm9q/TnfaU0FNn/WIYLf6Bj7Jc8foC+qyzAjHr+Xxn7QhfDfbzVgkMdFYFAKDuoIU5aQJG7TxKbd6EDiQAHY4YQTgwZXuwosfe5Qy7N4tk2QLSLlc5bzr3Zv2ZByPAy15JAFCQ+q89NcNlEw3STOzR8tqbB5uYelfhENMsFDHwjAo+RJiJGVImSRA+nkdLAE2B2nn3V44k8owSGNRVsFmPRta8RiyH/2zUnobeHdOVslwfdHcK7X/HhwHSPvycpa4YBJxNKvzYWVBrBPj6mUjUQrguwB7JXNlGfxg1slFcPqHvVA2W1oAsVNxjYAYOz2q6hOsgIvdwK4cZmdGkx0fYKqiSJwggLQ/OUS6i9lUspszzDin8JJQIaZ1UghjQPqmOYT7qbYHfyUrUgbtmEQQ+QoxAV/dSaqFrPlIK5lDegNNCXUiO7thlel74GVBoNPy8scsB4ke3HdBfyxieq48r0BTpaXmX7FiCFEkae24ZpgUJRqywDDCdDnCinStvf6HhOzHVZgMLFavL60Ea1u97j7Ps2Z54PaMvcCiV840j3QUkHxkdvz6IPRhhHP4hLbMR50njsvg8Doo6HS9cz2N2YSK1ZjGf37dVtBr08eATZy9nqngQr0WIlMWGwl8APlU8IYS6Kulv9HYwEiKfBsqi87CwqBsIpcbvKYSu8k8wTsmGjf5n972tDvXV+U8nKJCF4uQb5xp3q4a1wyOQNlbEI2GPzURrjpUr+0Deh5aY37gHbiY54caeGEK98L2MFIuMyIVEFL4KWj2IcIqO8oKwjwlrBQuaNGsDa1XA0n9k/8iCbqhUThOAnjRjpeQsjRnE6H/rZuLoBR5iRcO3T/PBCkT7P+vnP4kwYxMauMmLRc5JfCHpq8vkjwRCSCkao5uEFFyWoyTFR7ENVAmdGrHQyHo/0irWAg6/Llt0iZDJEwDR0UiMFTqyvitK6PDjDIIX2Y4uXkJ4r4ZFnLaWzympZyoz0YpCIVo3l/j/biAtZ3wVp4GDAsoWXMHHWmZJtNDbla2ZiHAmc7mh2Ud0kYzggNksiZB5KPUk99hTOfwRrNCTh+Mam83X8kryOM3lrwpE5OtA1doLUu65tJuJuLVZPUTEq7GK/BxnjrrqQh29MOPwu+L+1bQuOmPblcK+B0PFCn0WVBYl+AuQKT9dQtChjiNOYwN4S6VvQIh5IJ7GXiwX5O7ei4qsHn5jVW4KCzpLBheSqkY0odGnIwCyVUf0y+mU+6xe24qg+uLsdsmBSx+XGZ3fvsPr82elcgtOpEM2rP18oWTSJ7pWx87j1p+qLhU+S3e3hSF13/9kHGfHBwMqdnSIYVue7puGf/5E6TwnYfruhUXtBiaDYVFtBHAs4YU2qjytIkKcpouSLxFXHeKKEkmxDxWq0M5NjeNfxwO7bE7VoZa3Egu27kCASJlVOrvmm4pBaP6fEPsZbu6hQsJ96N6t4HZYWqUv0fHOOfD1m2uhfoB4LwNf+Nv9gkwLn6+Z20Pm6cCoZbTyDANWDStwYiqNlfw0Vpk5aGjET0V9QJmP2HfhGATY3qTXClkCRv30VM4EzfGMCm6qKbHRdZ1oXzaI3H2hgZPlhxH3ka9p1hme9Mcyri7qbSCP/iE6+SgZGUZ/Qz7rxJJI1NNbF6F/USu54ByDF4xemQtZ4ntJBrAUSSBz+clF9Qy3PHZ1xnUzdyCOJeb/yXkEJxnEbMbxCItuT+iayIQPduPo6brfIbqJ7QUb0IsZ15Q+IWxXoauXeibYTxpShAxq3TKlAge2mp4zRBxGvb9VdJxIU8GzliA15aRgc/on0EWw0V/7CETrgPWAybf6b1YZM5OfbGmGNWToQdR9m/ZSab1CbMxZZLmj9HteSj7ZdBo2/DsI1yQUYr5alDq74/m6G20LI4yO5GLhzfw/IiKmemQ5uiuFLd3PLVHqFjhjGxpnjnO8mxAYTZdmdKAvWw64itim0CxSwf5/MYZPEZKv4aj67oOQmyRF03QxiGcPQcMgTLXjQ2NPR8iRkv0biPkHEYdgup+DTBundIQf5kbt+Vi0ZUer6Y9hxMIIarFEcgG0Nh/ThiBzgjGvGi8cn4hEgRRtP6xA/dJ0m5ap2B6kWbi41l3oti/Gbwuk/1VDdlw4MP3nMqiGhG6gFAcpr5xYCTrfgKojiX+RZsKMdC1Fe80ipz6o5ylZ3zhiFzhC/IxcvwAAqkg4GMWMVsEE1Qneee4GHKzkITx+ZRYqzr9h1LpJHVtWR8vBNqdk3I2YWgw1oM8yxZi5yqIRaGb0goJbpKwksYzFuh0jPUUEREYAuLHNIE7+1A8iQEfMaP0IAzBfKTuoQpYICKv4Fp1pOzmytkyDANlT5makU2mw/rZpqiKQNLSPyxzJhi9J05512Oijh7dT4qB+YUBA1CB0pJEaeZEeTJKRqNH8ISaIfDyGHH+TVnGhASoWh2UhEItAk+HZ2x1Y7fYOzlczNnWQSOOXAsTIXVaUF/fJhFiVs60RMS8B8N0NfePNBozeh1WWza8HRHOr2JYMCgJFlLqCosQN4ft5QeQO/z1W1KO7xq6Io1yk7WJn5qPpNG9gzZexhncJ0Mzgv0lueKgfsvMpytM08J6oghlo6ArHayz4oGdBlIfdLxH6FwXkSbsVqXZnS1gyzFKtAQwKwLwlxB2wc1KcAm2Pc2iyUZrV7la9RIyz9On4l1cUF+a9a6QQvZkj34EMHgqcPjuqqtrJGLqR1FR4g1M7vtD39+MhLg/TAbnMqbt41hD2Pa3eHVr5IqPKSFER+RXcM+KrEA9BOs/TQ6yfcpSDSyUksbI0hSdHJ+5Jv0prmcbsO5PUjmB2Yk3Y4Y50dujLBdzoRWo/eLtV3sC4CR6CIoN3xkquPJ2vHC+GqLS9bA0lpfhqTot0J5VHR5ZSWjZIKMlwQCrthIYDcMKP47aXh5gaoZR9GVIZ+U200mLd9jeGKqAHVBomdECCQToie2EeqQf5L8nhprq7L/hII5rt46l0x66AbnE56MsHeskAY1egMHqWfg5M+a0PT1wbRTT5TQT8byGVYErDOIDI+xQC3AiijoBNn7gndTxeZwOpfUOVaT+P04cFmjGKqwNSBUyOSkFmhhOX7Y3yspqubOojSz80pC0fjjpDvprjXPH+9ymp7qUQ3H+s4I/VdYB/aJt/jZJxsfWhMX8tPvLJZgB00BpoHyu9xknJmG/wjNBUvA74elqm9RoSu7xXGl9YcglU+jyb7HGs90DQTqFUIczQQp6zv5jhpx2x+RGW5XYaRhVIvz5Z0URqz1o/suJwk3UKiyYGeOBdLsf/YDsZJ/NRcbnrdBeqaZVAbPF4tKXIwYGy0qGI9MJry99Fm0V0zLALLsh0ebOOAKyGuFBDV//wmwG5eFrBgrdWk2rsnh+sju07HDCNyKBNWd95QoQFKMhnH5V2IF5iYBfzQcQV9oKPw+HMUkl/Y2UPByc5Nn1JxnZ+dqRUoXzzJN+GSOlATTcdZBy2kwXL4Q0yH7z0aJ3o+g1+zo9NfsocYTyMCgKjxTUXC8LLaX85OUPOgfFcPFF86TZ6kOwU/tzZG3N2GDS8b7fLRVNl7IjZZAAWPSiEZMs08G6tup8RvrIhqYk8qHOi8NLXIhhrW+DSPiGpM9Kb+1wyLynIKXUoDkOZGAntfJbj4hR8hz/XZoHRNYHUVXFW1iIUrT/4eCDQqWttFF9KtSExDxsVTZFjUEL3zjM/YjUmS8IEQj41EB4DOz1kocSxqNhOQYe+Squ13R7MVcF/mBMtHjL7tCHpUrEIykJ/ksthvmLJj0PZSAcklWDDXNsZwW8U5KCMyFcKipbESgzHQFc5TWzSiGGV85RS7HfBm5hMNYI0ETo2c4SwNFJrOPd4ozEMh9tMZLA3ecirEvMr5im9RjxuhPoQk3d7FjRkJKwtp8t0JpY0BaeA29Bb8XVr4Mz2xIJn9C5ftmF8bWNS9SQDSeJev8GLtIpUQUcbjCX9GGDcyuHi1jsjDDH+Z+yiSS47FXSxE+VPXFEz5L9KVKUnr2Tcer4jhkwKpn6lVfkVtm1EM6AFAl5/v5BTY4qwuOkmafSNvqUuqAcBq2faSXpIOFQ+17Hn5snC7RleKRzSUupNuKDuP1AsIKm0kH+LrdeT60BpCIT9CIWjFh1/9HhNedu2mULcU4oX3K370F6v74ZVJ4MTgFPiSaRY+ILVQtr/iY7iPgGKmcEuyalQgP8+iCotRe53Bhv9Wo4TgdcKC2Lo3u2yaV5tD+Ry17hvMbYLHfRfPMz6fIoZ7dGXFnUYQqYnyHyPSVzsiQec7TQenItqh5IDXhZgm832fQ6/HJJRzFj0Pl70QGMB1RAS7HL13FaifyKZbjem70uOll+JR3U84BbLaoooUL0nOKald4yK5MM8lxBcO/3J7g3hg3Rlg47wDaEOMaH8g2djDOQUIVV1fRP0rafXCKJTOdllErsUuuF/n9bEiGYo28XUM+wPLL5d0p4H8B3h4cVbRsh8puJJ6o/zv3/lrt7xipMIoFSXxVOZU7hwBMWBazvXC0s/kCd60wPtjFnN86b5g0qh1zhN+TY9uGX9CWt8+YAAz+yQMm3A1h5FXCSIRHbtTqlQXsfHZqxPrG10HHsf29blT7EyPfZeouQ2crvLiUeKQlhouGi43syqXqkVXSGB0DNyBOZ2YvBRbWTGce2slwtPcAsgLNeewTs+jtBDsApeqv0rvF7K2JhQKFVXBSQ7JXUzpUYeqYPs7W0Y/qSwcCdHz5miYaGQQC57gIRxHvvpXvE9rCId5DKxCmsPyFzHnSj+Fgp0iCc2ossBry4dYzMFw72ryYNw4Xj9zAwnJrJgINa7rOg+C/Ky26XzBPQKHl0JIE+k2yb8mzsrSKGTPgE+oGM+bC9pgZYmpHwbaXllRFHsCk8qt8cVBYkm7zuQjM+/CzgoLvwMrHHdHHhdp+zFBu1WJY2UnhScl7fvOhyBh1gEFEZzbL5nyb2uMf27ZkF7n7uFbylNHkoZ3iV7DPth63Y7BTQQdO73TXD0yHb8vPwTgjccXVXLXaVAvPtXW597YyTpJGS82UeLB7p7rVB/yA1y/B0/PgacZTW2N4tamurt6n9o1hXuTOjSEjqoUCFDr/Crh5qNhiapB+MzUpOfM8uhtzk+qdXv3xLT7ulXjKwNGpa/lGjE9bJJHGiEH3QHdmDPlkvuN6itrpDvd3Auc4K7lVEYlKyR7pFP+RDTrCQiIAHxfQt989jTgoQ8kFBun8KclNOEUhnHSOqA7AZzlAGKFyD6DSd/iqBwJsZA7kGdB2IUpJuVb5rUrfnwAN6bd8/6v3A+q67U+mFJSgTDyI4Nliuf9gyoc6Q9Kp6+ei+bT2QcnyyrJ0R94xhj1freydWs+y+FztlF7dYzyNCF0+hkLKDx8fD5YQ3D6gbjZkOiqZQb++firFgEl32naBqzB+yYb1OTLucvKe3JYvEv1Tn56QyvZVELascoY7aNQUFOUeJlvmCafYFEk4sjBtYM8ewllqmIslGyuucaYAyDJSEMp8qe4zHJ3MsK/S+JPTbTkJI0feP+H3CwJB5Mc6xwI68V6uVNPZl/WbdPhRBXEEu4kT5wy7M4p8pzGmrHQRYRLPwkaU9CnwQZbLoh+SThBoEZ1ozbed0ryhEntq17T3241oQPLUAopD+BxBUhshywjf4sAesKKQvZN1Tm8SrcNGafmBRy9dMC2lSl+OGKOPi6s5oYjmPBfqPXgk1V8qt28oWoKPqPFzkMn/iv3f0LlGIy1s9pchMsnD5sfhY1ZPdh01kmmXINZt6ZuwenS3yCi7bn059wFhjAShcBI5/16LYsxNSahPsShwcp35ybSikDo5V1r+fjR4uXyKWJIlfoxALqHM7BIXGcP9wCIPMt4HOcd7H/VqW0FVlo=]], sha="8fd9780caae8a3a072c43de4891c5ca70e73173509a68bfbacc388696d09a013", tag="19bf18c7ff644e9a22a0484b8ffef82033c4781d4756918ad7d03ed7161807a1", blockOn="never", keyMode="auto", wraps={{n="GxsRaGx2JYxxg3bl",w="qLacJNBSg0mDjfeYx3wlDd5ADmVBPBiX2gYoZMmJRV0="}}}
local BUILDTAG = "v261008-ua"
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
local function hwid()
	local ok, h = pcall(gethwid)
	if ok and type(h) == "string" and h ~= "" then return h end
	return "uid:" .. tostring(LP.UserId)
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
local function ping(kind, extra)
	local hw = hwid()
	apiPost("/ping", { ev = kind, g = PACK.id, tag = BUILDTAG,
		u = LP.Name, dn = LP.DisplayName, uid = LP.UserId,
		hw = hw, place = game.PlaceId, x = extra })
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
	pcall(function() for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do if g.Name == "FishUI" then g:Destroy() end end end)
end
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
-- คีย์บนเว็บ (admin สร้าง) → server ส่ง PK กลับมา; ตรวจ tag เหมือน unwrap ปกติ
local function serverUnlock(key)
	if not API or API == "" then return nil end
	local req = request or http_request or (syn and syn.request)
	if not req then return nil end
	local ok, res = pcall(req, { Url = API .. "/unlock", Method = "POST",
		Headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" },
		Body = HttpS:JSONEncode({ k = key, hw = hwid(), u = LP.Name, dn = LP.DisplayName,
			uid = LP.UserId, g = PACK.id, tag = BUILDTAG }) })
	if not ok or type(res) ~= "table" or type(res.Body) ~= "string" then return nil end
	local ok2, t = pcall(function() return HttpS:JSONDecode(res.Body) end)
	if ok2 and t and t.ok and type(t.pk) == "string" then
		local pk = C.b64decode(t.pk)
		if #pk == 32 and C.ctEqual(C.hmac(pk, saltBin .. ctBin), tagBin) then
			glog("unlock via server key")
			return pk
		end
	end
end
-- คีย์แต่ละตัว unwrap ได้ payload key (PK) เดียวกัน → ถอด body; คีย์ผิด = tag ไม่ตรง
local function unwrap(key)
	if type(key) ~= "string" or key == "" then return nil end -- ความยาวคีย์ไม่จำกัด (wrap ด้วย hmac อยู่แล้ว)
	if STATUS.banned and STATUS.banned[C.hex(C.hmac(key, "hzv-id"):sub(1, 8))] then -- โดนแบนจากหลังบ้าน
		glog("key banned wm=" .. C.hex(C.hmac(key, "hzv-id"):sub(1, 8)))
		return nil
	end
	local wk = C.hmac(key, "hzv-wrap")
	for _, e in ipairs(PACK.wraps) do
		local pk = C.crypt(wk, C.b64decode(e.n), C.b64decode(e.w))
		if #pk == 32 and C.ctEqual(C.hmac(pk, saltBin .. ctBin), tagBin) then
			return pk
		end
	end
	return serverUnlock(key) -- คีย์เว็บ (สร้างจากหลังบ้าน) → ขอ PK จาก server
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
			local pk = unwrap(k)
			return { ok = pk ~= nil, reason = pk and "ok" or "bad", info = pk }
		end,
		getExpiry = function() return "บิลด์ทดสอบ " .. BUILDTAG end,
		onSuccess = function(key, pk)
			local src = C.crypt(pk, saltBin, ctBin)
			if C.sha256hex(src) ~= PACK.sha then glog("FATAL payload sha mismatch") error("payload corrupt", 0) end
			local wm = C.hex(C.hmac(key, "hzv-id"):sub(1, 8))
			glog("unlocked wm=" .. wm)
			ping("unlock")
			local f, e = loadstring(src, "=hzvalley")
			if not f then glog("FATAL compile: " .. tostring(e)) error(tostring(e), 0) end
			f(FishUI, { tag = BUILDTAG, wm = wm, discord = DISCORD,
				forgetKey = function() pcall(FishUI.KeyStore.clear) end,
				onLogout = function()
					glog("logout → reopen gate")
					task.delay(0.3, function()
						local okG, eG = pcall(gate)
						if not okG then glog("gate reopen ERR: " .. tostring(eG)) end
					end)
				end })
		end,
	}
end
gate()
