-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-keyserver
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
local PACK = {id="valley", salt="ClXTL+V89fhLfTwBcCzycw==", ct=[[
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]], sha="8fd9780caae8a3a072c43de4891c5ca70e73173509a68bfbacc388696d09a013", tag="7fdd883c8578211a91844b199c244f6500cc1fae45a9673d5796a3b6e41978e5", blockOn="never", keyMode="auto", wraps={{n="Gp6haPoxZ/trO+6c",w="Zvb1E5lZD1C7Gqp9aVjCGohUYIkoB21SXA4vF+VLTIo="},{n="HDkbkz/m9d6wQUDb",w="IkdrAdEMEp7rFhopWIPjkGOBsMFFZWez2+Nooo19QpU="},{n="tkM8Iij9vDB+7rQA",w="NNSHg279Lfo0ZbsE1bMmZ+6cEkGiyVlw2Sze9c9+O+M="},{n="WBRiS4l2fNL71qZd",w="nrweWSBqsk1KcwDyzzpxxMZdqLYVRhoFDqGZQIxSf0o="}}}
local BUILDTAG = "v261008-keyserver"
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
			Headers = { ["Content-Type"] = "application/json" },
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
		return game:HttpGet(API .. "/status?g=" .. PACK.id .. "&t=" .. tostring(os.time()))
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
		Headers = { ["Content-Type"] = "application/json" },
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
