-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-telemetry
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
local PACK = {id="valley", salt="SrV338UkoKxq7BXc5WJG2A==", ct=[[
ClUcLzfm4da0RqkE+orLkZyyyhsV6nNIa/e9euSf6FH797qiqGC1OrD+XuNLt/G+IEeXH3XfQnDt8AokvItJtlH3dPYStjm89C8lf+8jTsCGdcdv6PC3y27tMlTuybvDZRvuBk5ZS1B2efe2vNWV8SWo6xAWelza4ty7vLGSaNg8f8IpkwS3FyPm8zUzsrjogIV/+bU8rbiZoxU3APyi6M5P0kmgpNonWcnHh5x5pfn3L+jM4LsgVz+IlDTXF8xvCFS+/D5GfGV+2gDG39ZgIxkGWuZOuhgbHOt4oZy9TrhGsHBK3VhqViBxz9gsB5DUxdV59E+CD1YJQKhlCgUt5uynSmwB6AwEVjSu7NdK1AMrULPdObtOS0Oo0Imb5vJeJTdfILiurD0jWzeqfUxGqWDqLl0dF3urbu5Z8E4/By7nKKD813lN97pVkVU8kP6SxcIcyKVv8P5gec8AIO4N4VvzeXXhuHo7qFSiQISg/StiYANxhfspFEOM1LWMprf5vyK6iBRVqKr4/39bDLsvkNZGiwf028o/fcekshdus2EFCs5f2kFnc+RlnnF/oxZQR5ogsexPHz0YbAdkMLmNWaQyMe8ly5dp3abeOXlR3CfjmbDvGSvU+dm4Tcw/sBmLNcp1F9j1FfahTSoyLokYzHUr3vMaw9cijI3W+pRypUzrljRBRJ8wzdxCwkPDrXJZ2M6KincFyejAi3apWQDqp4NUA7ypiVq09x82ElkKButA3ORw27PY8O3xqMLuKKTgidLbqcBNzroRStpRNr6vmPV4J9yqDtX7KnbobCA58v2XHmugO/aQfYTONJ2rzAslrSnHaF6WRccsYtKsaYrGC3d1ve2CsSAw9oc+JpXXp680c4IjPCGl7BXZsEp9bVP6qHt/xpIei5pGdyO9ufSqLqH4cwssw7jPRAqn3pjaI1KghSNLMLW+6NxityeTo2SkR6d+4kE3mvLrlzA/39uuv/Jx1q5hUpUi++9bj0sk+hMlYlYoAPFkHNSG1nY8ioBeabCMOIGm82XE2q15Kf2HE9HpWQpKbEv26l1O0/F/8brt29lgwoG4s/4lE+LfHTGj/WTa5dGDFovDtIFbCp8FiUP7TuM0p1OPKgpVxqGRN/vTHxFf25x2h0WIBTs8NYL9nXAa+RwsghcwzTzrSw0yeaagBn+4G2UgFyQKr/LqTMZUt0syK1/c+u5qVhcOs4/cuTNhhwYXgRNFxhaDGaPvf02JU8HkMuHhUiW/uRRCq3DWOhk3wlrHyJZwN4XXBHUm2uFyC730EkNTFJtk5t2lS3eJxO6yWBClD4R0YJCbKIPGne2oriKpjy7FDpOkgz4VViNet477bN+oB24dxotr/adpeKiTZznTPpG94w5xbscDXS1qhucKjMZFFXZzOY9hv32SWgAFIu2u/8uyA9eKJVcmRwEz1QCh7qjkDE8WrZJ8seF5BvU2U+0tH9rM9dQliBiPK1JRGs18q49wdzjSGkgl31oeSNzRm5Hq2srGwoVp4V/YvW2EcwgBZmnRpth4DMb2CRNft2L9bfccrSWVzZBHn8xujL0/SzHQLU7WpcoswA1tNZ6SvwV//lKDrf+95UMWBq4c41TyxS6UYHmhaBEIbRt5sJ65oY/PhKrnU7hAQuTvFI07DeFHOch1As+/NcMarE/TNmkIkonUd3Li5OId1OiFLrdNreo6Vlag6clPtf4QNLuILdaXr1H5hYvt5yazkHmyLKM4paI6UUL1E2phDO6JMUAMbWRHQ74grRPUEwFQn7ttYkyLMQ4BtaLVw6IzDc2JABMDFHnZIBd6Mni4QsJlcAPp+NAzPbUKHeZ/XmPfYNV6gACe83rbRZFKTqJl9z1gh18WFfrb+SQ6R1HiHUAesUj8Nbt2/F+Mqs2WmPIZ/udGNnkZHRHmqXHPQztv8JuBLQcslx61G/wsfRqP1ojWh99TFBbaiElJjeLfYQib5l06agfTwwR2ZOfeKBc4sm/U62NXLPLRB+Sd1NxdHHs5KIGKiTphz8rP/VDyPVliElLCyO/wF/ju6DkR2vyZd9R22KQaLy8eJt/h2G+H43D+Kyke1mmdYQB1ny01TvFfqfip5M3nkgJ3x8aPVaKtQnnAnBMg/LuCLraVMoTdi+H8S9Jle+XdIunC5r9ImUyCyLJ0Tm1VvknTXakYq8FItypLvNlzGPzrnF3Q3QXQ+SNIlBnZruE2yWZbQHu80HpfgbW6s6ycDNIOiF0lXy2GxXcHWAsvrHymaMH/9L9i6n4rpNnyDFe6pIvBP895nu+I3TK2Mg3vLwRyTcsJ4avHXirJ3lNNE/5+qHS4zmC9ic3MOwJuzCbap8+SaLu8XDD6cl+MulMFpm41W58jEjLOS2Ck+Kro82kPut9VN98kK+I3GsLvqW/cJeWD2qO2700JVu/UrlLOcfOQhKli3XTuP2k1YQcCXoecqVjuFeVDB/qdKBnfNTLmYxb1/qklmxmmu6AjsKIfO52Hj6Ka243JsBwVUSGTOcZtTNGrgj5oOpQHbXveMr4cfzlWUeY0jMKjEaSz24H2laJnpwf/5gkWzAtV9ff+tP3mthuVLxgwQoA0jsWmqS3pyPX4qqnhB0UvrKzWwFEUKLeOtHn8vyhbZiXs602jlyGcROMIrawQu+3Axvmzx+Cm0rS5BCz0rvFEiGWHMPKZPDYCERa/9ytzqDL+Y9lOn5TmFiuz8ZFHbup99e4zdiSE1dFz4ELy59nrvrAV0ND1vOEIgtkIefdUpG0uD1Jq9Bb/LZkHst9910GEJQQJCCuG+vC/OvSwgaDYuSf/TJUmx+7OkDvhvHfMXnOcAZQgxgqPDx50K7I0Z4D5PmFy78dXp6ADLXKk5CrU1ebL+k4rtYSdM2J8b8PMjPUWURLf+HKGMvrJsgCSTIWdaJ19jeBLTyakOhhGTWUe0AmrI6tFb4VXy4jri7lT0g9CwKSLUTIn8iHU+UMBeEHhNi4EModxnHTQ1bzwEAdTq3jSnEPFNHKrFQw4TEleEth/olHLW6Bou4rnj7VAPfDvQFefn4gDSexe3PFxaGKYXBpI+xP3howm+L7ALAxRBaeWR/YdXDuOAVTg4P4YjHjJKfRTuLWa0OIqH6kKijhbYpEWKKjV5Z8DF6JT/zKvdE9hsuWIkg5aVbA9x46QS+btMPBhSmR0LufNHIwjW6x5YAmTpwHixP7HIu/ZNodEYm1XwR32YIWTULIViCSMDR/v51IMi/M9hWvXajrxINHFlqy9e7da4F3loSkXhVhyOCYfkNtzu3rKHcAh3QLtMP5/CmsyE46h2+zuPYIRI3OhwntAmP0iv8kTM/z0fjLP6dMIn7XE8w0cB1NlQDs77UIOJoda/Hz5aXPgXnGF+TtYzqZpWkyfXH+z6RGcDglcRBozBEFrMsYf3TT4ha0O9/tvok72zESfBEOMuJGxEI+KQcrbCcLiLlh7gnkA9g77/1tJzT888x6ouz/r3yD+4q2wqFCPbggcfpWEbXjWPjnGAZotuA0j3Mh29Z/s5hnigO96v+15ZV8Iw8Jg7CBDJee8xFMb95+Yx9T1lflGuudD3RmCPc76KiZSnGEkcOJbmQ1sMYDEJ59rlxUNG8S52RZ7ZKa/zIQ2upHug2CyMrwmtg3ekFKVOgGsZjIL4oMmltyK+axFiTLH3fmT6Q/ynnf3QJ3oq98hAUB+hPU2qpPfTgW3FB1vl3ZpRqjuaVbq2Z1jWbTZjfgovvpf+Km5gbcN3fNKzpf67/1t/ZqWj7j2Umf3LNesD83oCowarNeNKm0lfHBC+nIUvNRtminaTAsKR9QMFKbBKnA8MkcqosrZNXv3ijtpqnlaYKwKXy4tYhCgl+m4J2gxfJnWd6s1t/T9hgyml7s4P8/21DF0k+CmLenr9LakHVPPdBagOHbsp9Cz4T0BCrpDzLBHbEcOCp3JLdl3IhgQ/ib5re5qdNsshnZvMEUQd3a7VCf89eNrQvfcCCA0wXqc14/k7kN/yrGA7LnDzllu5addguaeJ/xY/Rl2sa+5lzueUV+gvqW+Gu8b1Rbd36n8y8jygwHPWpYIZA30RdMKZQrPOOEHxVAwqXJmaNdDOddTnE4KVtNRra+bxb2ra+QutGQlvU1vVuzHeoAMmsxD+3m6JV7poaLlHufgn89IIZAj1Eldxgdmcn8GypbCCRkbl/LS55w4OdGQxP+G2/j+RnGj6qljDkIcq8ZXnxpa43ntehQHjprfVvHYhrwRrNYQGgNG+taPhFtV2PsuGqZ/PKZh1reaBL5MZA8rU4jFSBeXpqqXFIkmFBe2T9O439yPAEAj3IJY1reb07SmN6+t+HZzlUk+nINM70ayRfnshFzWst1bGTUBOIAyykRgBGWLW+csNHREYe/QsUGivT1gqdkq4tGs+o4B8rkuHVTbH+vm7QrEBRcOPopJW9u0+17JO5vSs6PPnbLzP94gAJzwuQtDqU+EzAK3ObZWhBaT3pdtyMX89Z3Sa+Ty1C5I3djwbVZlTGz62b5mqWdCsbeEffqAo7l5Gb+fzGqQZKwDIc2esKMXIfuEt7osXnrPUYrJauOVwCMLvUYJ80tDMAy2SpBHH0sqXAjsHPMB/ik9x1S1m5JkGiy9q0QrA36E7uVXw0shFQDx1lAdZMvQWfjGQaVyI9/JubxQDx8kA8+uKQ/EtzhlyI2WwdyDw7ty7kPGCmXYRO8l5JHJ3+n301uhPvtS4Stt1U32jseVpx/JdYMmKhkgM8Prhb4IWAzFDPmPsJ6oXmn7Lu0tEShfiaDDo9YSLp39koco+W5hHKsdlfYtK3/rbDNXx/6Yd7cbLKmR1oc8xZ1e1MN9vYSbSNA3YVX6CYyfayGsmUqHIhl10BAzOMr781hzgcaPUmYZZ8zGYOHzYkt8IK+e+GudgvFVJLkyXxRC5ciXScehxAJEJUbu9YXKgxV0f8GAkuoOYUehpZkdrtjlUOrP5yAKIjE1GBZYsJ+l5hAmCh84Fwal0uYxU2byhUbjJ+em3CNF+qvDq4h9TrJ+Z7pel02E8QYbw5gEm5q1dQ64KlH3RkYWxHMqSxuii4JbaLXHm3DvP6WNyS5g/ElxPb0Snv45KitPASr273/mmStnquBNDhyjywAXW4jSXhlkMTj4pV26bqoI6bPzhgl1eEPq/S1mEdfpMU7QtGzmlCnNqp4W02TbWfqaWwjPZzCw7lPztyaT4+z9jNxIbu9R0oG48xps6XVK8Tqsl//GbVAb3G53iGF5yFWLb3W9ADYmcHxyR+bSoiRAgo+vMbJemLdmU9z6DDOBNd56GhRAPXMwHwvILYU+ziHrOvNWaGl9sms2jBwa4YUuYxDwclZPQFbBwZWf5YFtIrY975cjLYueQC855lpCG3Zss4i05QBmMXLXLZAFYQKc5h+GFZOGk+t4xT8RAOSi1LVXibrhCW7qTTfpNInNzEeiYWpBMcl50a72bjyC9bdrVn+nm+t9KXajT4ZaS6Jzuq5yjtSQYic5alhaBzBnvSYg/ie30CcWh1a/50XHaKjtx2WlCAYYywTNHbvmSsxQuZGX4fu8Dn1DRt1P/IzGd8tQIBCepwIGgo6y6TG6TGh6/2X5DyOPk71Te/mxiAkZBSebuowxkwAOdbq3Qj1KI3IwfpkTrZ73ssiLSiBG6BAwbk7EtLJTbfLb7E/ABMheprglvvZ4PEyNPmQ3wugVHRiq2XNozj4iRN/porsrmY1qujJHUB48V1p42S5IwnHlB8W1svPkH2gQdnGkZP7OYeqOXjX+JqY0C/ORmvq7rF776fvGNmVv2SlJLLhnuTqMfrSABksGWkz0DzDyQ/ZlFAn0N1X3Us5PmPu2iVb7GUvkuht1e5fB+JsFXM/xg6H13sRsjjshC/Xe35HYNDjdgN00AyRp1EEE2rMJ1Un4j0he6F9qN993kRnL3O3w6auzwrHzY8S0ygOYWcXyz+J0CzLhhr54CFRC2m1HmjggF0yOnw5m24gj7RUMF/u1MaA1lZisT1ZqDTgwN5g0fy1V/2mSIyo9eK2swGk52lAMFuxCNAESOYP0S9kHnMLE6pqx28ue3IwwLJGJQQq8m5EzoctMCrSgX7V89MMBC/ue1w9rS88WDn2aD53TjxolVkl5j4sSpYMlRN8JK8EyrYcZa8reogk3bcaCtgCB/rW1uMRRWksr93wzLzszrJHstqpyTldJKX1qM+CLC/RH/BfwaYH9ZPosCsbJYOdbQ0kr5rk0tJZxkZxdEytON98vmbqymjaZ72RlZsF7rbEFaeyhyLLfE09nvZAAp8FquIqC+oMbxzDH857ic5bBz+ywu+muJ/t8dctuOHAIex2LpyGrWa6IlZQIOtR1PvNbR4+gmW31Prd5eMHxoCIJkj8sPs5s9vSTNFSwr8IQvumCNCSjFD0ht1e2rhSL5DgP3slwlSKlVucnliiP0W+6bugruHUUAJC0RyYDiMeMEa7MQ4xm1yNIgdw4PVdDKn8ydLRshVja2ResyeMBRps+y1bWVNnX0manP6qFG+Q+V5VbcQDbMdwMEly/868Faw65RSWT+F4gH9qux51jqtDN4JQw4C1HMEBlYnXrrhSB2PuqkOlWSEnaupemjVS4hk8xzzOJUSVxhkto/aez/d9znMu6FHbrrBtVVzE5ntDQBGfENYf0pFTcMHLp3BY0INYui3g7rqEM9hrwit1OATHli1u50kINNiNsg4kxC1aLJrcafud7z8E3DKIAS5CQoyBPhzLUKXSm4iuH3H1qTIqMmA03G+8cMr0GtehcF6XQlIbOiSfgm3g3difnuwUYYzCf3HDIvQQ78oxcmIehWHRfEYxnUsMRR24RLDcbt1p5ta6FjrV4XecNMP4YCCArrkfQi/ts8EvFmtQFd/W8JCXrwfELOTa/tPKjNVE45QmPF1KSyeKyFJl1n/tiVRyQNEyXdZI76Cr67flfjT7d/dSbSYf9ryyrwevyM1pXpqHi87f86J+tlixXZO6m02yMKBasftj0wOA9fxiOjiYbjpVQjjW+n7yv+qor/W7MKBtRNtu9/GGPWiJ0a7azKEh9v4x0tSadZJ44gz1cuPpuPVLizBlUSPKPg5/zNG3yKjP0O5hPfwtvsb7hJ9PpwA7sP/X6Fq8yLnI7dTeawlWNFgDzKRVwQ9LZMo7R36t4B0lT5022i6WnnXX6gkhooMv+BfpcC3bFYotDHrT2/8QBnzlsj//eq2M/3Y9KFo+EsI4BpWQKkBjG+8TYM/Tj5QFVxwrjzw3DRcwQQUpPSmgomFphSUdowLt6DIbboNqL+u3I94OgqCWUEm4IkuWJH9O2Z3BwBWc0P9zeSZszYOPSqqyczYTgKAWwUKPElW9R+M4IGMYPt79Re0SNfEeWZGAZ2+lQTTSbfaGsqYlJ6B6/mSAAN2wxz5ESs9aT8AbPYRBS9gK/UcX4OV8xKDpdlv3nocHaVDNJw/AcbUKFgG5zFFtK1S4XZbErd4SwLs7mhpccDIxXZDVlAlFFXia2wJeBSI7x4N76v7CY84STaiXsXWyovbdjMbtBPlrpM61onr60W9zyWuiGO6ezyuelZw8njU7mMSOYin0A0X/6F6v13JtqnyYSACaWnHFjcLsal3XDXftQqGl7qntd5PS03yTm5/5V2CgKpMgcof39yUwxGHxoB6g2jw3b9nlL3TWMeSkyCrIsIKgiX7FNPrGEWLBHxBxXcuiAF65x73YFALS0Ylz7PS9S3mdPPoVDjBRltFxCJQMHX0VlZsGrpiHuuGH0uYELxCCSiVCz6pOg0OQQAPlYKq+yenjKYWZEYOlQjzw5bUsn+6nhshmSKF8/eAAEvHGR0cXzpwl4jBvHnmjOMDvyx2E0jicL/wiTasSI5WaGJmQeByo3YdiQR3uenvkXw+7SnlmvIJZdQOVNemS/EsWKUiIWWxfYaUmub5jqZZcvJu7pgSBSgu6rrBwt8xVLOaVDwCN7VvDPed0fv4L6q3f6H00ZzGn+rc6ROCBuMmgKt05qArpKMdjUtno9dMQWkIq29tyMemJsIU3WPebQlqtPVzBvCcWAXaPVGIxpdnc6LRfC0Fy8SuwT0QkoMq+KFvIJLwxk211ErX2T7qwk5fOwyINi6wNpL1FXP90GFnDZXbNWZdKEoTbR0zTOPcJVOTJsXA52SahWHxmrQC6HF1JjquHxaOyQy6J6XQc7oTEceoGb1KPZ6Mw4rOTIfiTNv9nhoRAQGSaNAr3zNPuuhqH42qt0ugn7YHGxSl6iEtont+AFaelCTbcwXm5nPIZx1FFRcjjqAYB+mGJdw3U5ScgpJtoYH+I/ogqjkpq3qMds8q9fwNseJw1YdnDLzNpGM1cnkbdnw/8uxkXCqnbQslGZ16FYE6EpEnBuP70J9k1EUWNtnXrWfVEba9LbF7SZZbX8qa3mOzRvnxOkWMQUZrD61NOAFXc4uW1W/aQjoABLiMMZg2LLiJGkmR0HmLBsmAODNl07F5KrSmmpIaL3xJuHG0OoEmufKKng0IvSRFc5Bki1KpVeW7VLwjLxNLVlzWYqPjwY+sSH9ETjmWTcH1lrAUnXK62qbrAEoxhp6lQ6n/S7429u5K/tHFayXTQpYsfZl6orecxl68sisM0FkkZuytncooBo4EtMw1X/7hKl37WKwodB6yoav8EHNHLIcwvATIBiqs5zl1j+LMipJLn/xpQ5fnRSWfCLLFW5qLQcukdOb3jHcNb+cCCZ/QuS/H/efob9o4YncjHMl/ao1bnHtYR/kdUkwnnFW3a7gg7W8mwGoumMKzcSgLaHWo9/EvqqaBWVIdnl0e0grRr7HWE4VkrN1id5vQuprsDnJdw+WeNEW6+isUswxAoJxpbJDW4+ASetpNQnCxh6rl9gQ0SQvocSkiRlPQ1+eZ+Un7bbCeUB9Fa7jaH/BbtRyxrmys7Yhv87K1huAZDa6f04ceDRyY7nzVPhRaRy6wcaqio+OujUmlNvhoNgQt+mUkhPi8Ovxn9FdNoA684SMwR6O0AEUr+SG4c/0XcdC8V5uR1G3LE/W87Xl0u+z78KR2000bogzeuljYKY47InfOTjelQZEiKXdhIz1bL5xzX6qxgXDP52N6XsoPnjvncGV08yvnG8vlrLTAmYOxa5bKoz/5R8+678a9NG5ky/xHCCQexnXLdNAIaTPSMUIAJl6YXP4NQGu+niLT3W3GXjxTzSlK2h0yOlzpXWmx0UW6xfRwzyXRrD000mYgTexk1bAENSFMnNBG+plEDwHBjHFtEqCwNGOqoXDE6deV/ZjTU1138eGHRFQYMpDKZrP+R+UB0pxyu8HY00Imq8gAiHwzVuOrS6yWQG9J5DEQOF3AsqgmciWufahFbsPyGzmkmcLmvrw3VJyS9gCLl4AcvzOcQggUsLrOdruDtSw7GZkTbKWjEN7O8xBSN1COTFaWkamy7CYK9eX8bp0/ZkzG9C4+S8Q8jqFpOYhlUNijQBLh1qcBkLhJiAoY0ROxCtFnhBoMwNZmszbgmGrpnE/1tV2ElrFAxDTkeJmII0pW9nM3xSlP/MaT+vaaljK49msx1zHa+QLN9hLFMRkP8YNpLvqZmlUp8bik28rB0IseD+pLTApP8W0jcYPJ8d0Uzb/g1K9jwsXlOmOH3skRIZ5lGs3GX2jJJCPpZ6BwpiDSkmxFTwo5vzZv0Po9K6yP827WytOeUYh16BRJUzdKHs0N3SccPlkqRbJdEulJyqa+8fZjbAn/jNsM5Qamn4c14n/WIUaL7PL3dicAed7LLB7t8gggF1hBwS/JHymp2SxTrsgCH+Q6sIAa7cnsY7eltEw7WokR8YdTArpfdI1xjZmHi5uwpaV4k3kriyMytaG9weS4LL/7HATosxvNOlriA9qoObrr5v4DbbyXXz5S25M2B3Y9e1qTlNCmbCzNnH/LwLkdZnX4Hoe2ycR9Qskv5ZYJAGqKvwIuyTROXcSLbUjllfLsf3XLiq1z7FZMfa6wejwpqu3EWqgbyaWb+HtobJRUhC3PRAU/BrHm5nnQtZdcZKZpab6Apus7BxbteIbHTSgGT80cLVFU9Mylov/gpxzGFTYeMPRcqwzFWJwD9GqXETyxTcXOhT+ls2kw6/5nQfFqlWK7KruuuxJjmfSkJRZF41WL0P885k6QSXesOD7i7sdZ56TIh+6nL9Y7HPW1WNKZ++sm60f92lcs7Z1u9VheVcWDXn760yjihieSqI+PO+QYEQbGLGYTaLy8fE5eVDGZ39Vrvx/JMlVQqZH5i1DWOvufhcNhT82HFLGvnE0SXostZXq/83uIvJVKp1TpZq+lfO6smuDTp23jKIr3mInsyW3d/h3lakLeZxNjFQGx7aRUBcSIdCMkMxSM+bzBfP7aF4srrU2zb7zf3dX6SoY4NANO+2F89A7MEmERjUqoG/lUjT3uQHULDVJHCUbTBYpJP3FjcmDJUaE10GKD5LG3XPeGOrjMJMklqWaBbV+xu0CO1p3KHPUBNNGuFe3a7fbE0QVLQvrSSIzmDaKCISEHpCgguRjpm9vCujc+CnSLLb2IW112SxWeVb4b5ZeI4xa5z3nse2/I7zxtrMOsHxSh4w5+j5VxcrFItHW3Ypgo7KTxgOMQaI2UCWu2TMHCVR7BXrSUzVM3Q8YVIlQ8qerkCDFQyhUpBmAGqUX/USLAbgOLPUBIkPALG8aQx3H9nuZl+uITt4dNh7ZEltWvRBX+k9mUxUiWt72crR2fZJsJ53ax3qfECkXsXLVnrOhlCxafspwYX3SPc3l5jBQiJ4WkLYhCXdpG4D95JJJfSs+oIZbPaeyCNQL6nf39OEij4PKer604tFcYWcaIZHxP6a0zbelqYuMAJFAju8ZDHKDJZyW66RiWZwnbOo7DbGFfJvr8wFZLAyMjPW9RF5x1OV7oCuHSFVIKprclZsyKmDcU+zMfVKMc+/DZSg96cjhAg98LRIO1bCCKJRlvsOp9zeJHy5Gsb+MUKzxDEc9DpyoFBRGfICmJGAgQG5lQDkwas6KLLiNYxDOYOkKQr9ORAF4Gie35sb+q9i+UhSrGjMCmNEvBVt+jqJivH1ZlIPXSzMzKp/0iUGs30O/p4KEi4WD4WuPT5FU9c2kOGlzL6JayrN3Rr5rFW8fXkAk1SuT2xpHBY1+QUjZbPhh9jEfYMi24JMmfpHwi0orFaMrLI6YQ1Do2BxsaWBLQHCPFt6ROZtzmXl3lYC8bIW4MXArohOKNKBTv/TVgbMPG66ahT1DwrsD7M6io2YUgxwEFgGsT1nLtk5ds3ESTu5EtMH9wOsdCx52sTItYaTFQUTFTRcdFdfr9sd/0uSHi2QpuIRZPbdSKGBApXuuVdVPltiqOpXgbLU3cwOnHge5AGS+mLexQHpfUECrVmEFWLtz7VaH0+XZQN2oYTePwtAVYOPfjqii9knuZw3BGnngM5SQnbvxovn4z1tnmgLxFXDD7WtTthw7oKLj9lot0wgjYdMETgE7ZP2wy+JYCHvCUJr6lrOUqGV+3eij8qBFoUtC/vBi7LhKDBEDOeduizULHRyuakqUb/3V+AdqCRYWA2ZoKpX88PcHN8LOE8QDv36sxTpkwvZWSHgm1hJoDtJS/n+qBJPKe0xRyKL2H5GHtjhqOq4vXWpsoiZoeEvsLtSSX6WtmhypcGZonk3VdM4k2T0xJ2ujr2YyWIa6k2Nfx90xwg7cXFey1QzHk5SEdeJhsmNn5qGPrF0o/XgbCKhE1DG0JJLQ1mArs3qJOb5kFTI+6PwEUWE+AkdxxEi+qhFNGkcwKhbUUl5XQ9bzmP6gABCl84RosKC9shErkaekNt49kB0c0I/LkiG38ztDehlTQKHBRlRXjqUK8mMoZ7EJw9JiD9ZK2JlQ+3zCmpHdKgmk0GQXd0rp2YAPyWFr9YYVAmchAydleXqa7sdZtOgyQSWwiDddK3kN7S56lmrvOtRUvhXGpR0G08IGRKrI03xY4bnqcHYOZYl4MVth/mJ65tZkrRrmVCMXpAi4YWCa9xJQCpJ4jo0602fOf8MtrFzmPZBt//J2aZR4bKTNZlzhMeDJjOUmeUXeEYA57bnCivaP8XY6ne1JUwK0EINO0bd1ZHhazIxvXEgQyxO/YZA/yJFcav+EX9zNnV6UpeTlxk9u7ogxGB5s/Y8ziOHA2MB0ZrZ/gf/p76q82KURqsC7pC/eyZPIEK3qHAeXZPJijAU4KvUh1XzYFmUYNRZmEdQFhYA7wVpR/zrCkEDDxn4lhy3iM3SycyCJH7YOl+FQ1xmjz6Lo30g9EUIfaK7DMvDmpiu0X9BN1CIEHHc8ylnEGWdiONKQnubOisYq2C1oi6TTXPP8oT0HZZ2PP50BqlYAEpU2C5I3JFi0dGiFDs0Gmr8Fwy79oxa7Gav0WjwEFFUN+pW3sscwJN1HmuJdELICFvbSeGGzFINNTPrBWiQMdLIcOSelYxKyOS9pNzMUAWN25FxeyjWsSkolo7HHJKPSltaAjNhR+OTtyPiC+P5y4a2y2MPreF3hCvUtq0IqJgwXzwgZfmUUYI/NpMD9XGrPp3+30BMKok12ngTzJ2dbt7nH8V6P5NX/4EE2UQGVOJ/JfU41NW7a54sfdca8vwn6JXWOEPQTu7kuKxGfteV5WVIPW+eDXFhxokunP0MeJH6i8L+17y0E3EHGNVA14rc3D8uBYGHq4F70E0MTtVY4t2FhS38WMBR7ruOnN+zNKTA5I0j7v+hogteIg/GFux+Ww2Xv5f1Vwt31Zg+7zPgCppdKYt6jZ0RLru4nXafGK4SPS2gWzRGDV3XBtuclHVwceULxnt9syQ9EPyyDbg6MZRBiqrxDlauYidhVCY1hcbPzkko4xgRez2iKQZPSQeh4uvQl9i6LGTf1WOVirsAbTgNKhUUZ/oIiWnSFXTO2XWn5waRW2I8eoZ1ciyyhHRDqji5TFY6YThqSLExHelHgsJkKLNMktZhPznHcGVbUlNORNcYjApsDFuy6SMKQTlY/N1K9dV9j6GaAbqDYycWgs0RyjNuz7IoZpX6yxw1N4tXyKHFQuEYkH6YLxkxkqfIwEZK5vFESeYWkjfc3FAjK9PGYohxU/gAeUna5o55sSynbzZ8zLpygoOMYJieBZf3iZPpNfXORq+Xma+ksZSR3vXHZB7PJQncCnCHqMnqAZLGV10avoCNSZWCexc4Q/ugj7i1biIRAa8opsKa0DeB6Pi8LdXEllP0c9t4kMF8a09DXNqimHiA4a4bYbbaZeNV7ke3uIJZ9OQjF4xPWZsLK2qvzpI+kuV4eSeRQRiLNmoKaVUr20JZRny/I+N44TzDfPB8LhRGFzI8IKOMMhmhAilAH5DN8GRq/4i/RIoCP7Xo+s/nxPYwoHewQS0Fc28aYbgFOjIUPzKa5k5+TAZyHM9yz+f98NgMtkSXJj2a0WQafzJHePTl2MYQTVkmLVGezXP2EUnA4mVvrrw001NQ6kEAodAgMVS9Tmyp8lZAJ29CFgtiREG5KTQvFGuG5qz+BR6/aRtom+EL3jb2600cezwVVPvtdcAjDF5Jb1lstD8lVf8DTGXvGhF5/K5357DcE1QboZ+hUE7JPwV9J3y709Rrc2jPk5UK1iyqzRBlXTkOP245eni1cPj4o2vRPpMWu8ZR/WtCD5iOC7I+74tftmi65KymqGSYYCSqN04+YCUZ6D1GusHRHz1cpqjdGeHkMexuN4RjnpuKkLgbjt6Lb8ufEAYcDCTf1YniZeeLwcgXz+nPzkRNolvgJ2zXM7BxiKBQX3q+jWhgX9dqmapRy4x6gwpOZAHlmyhJi7E0rVyv7PfAn6vPN/0C/yWI0xlXAy8Qhd20VeOmP5GSCaoWimV7Ysb7R7bZF3O/YOUqxGtAgLVshvLP9PSJLi23DrxfZWrspGz7L72uCuf78ukxKQDbC8yhJAv64GBXv2E6SlQVS/LvQAGzfL9x0iXe1FB5mpkqqeWyT3kQ4Mv4VbFHh+EMGiZH7U67AEWdrpNO6mdeoAyajQ3PQHorJrcX58Jd6d+gGpBHFgDLqQVTeHhfuD1b+nUciW7jFIaI2LROOuCiBYMo2AMBASgw4QfVPIW4wT8cg5z20TGsgxnS5yY9uRhOFZYjHfKI9BLrgntUeTi/mN4EdMzObt2OvqC9dpMnTzqXwCWdj+xX4JBmMKngmUIWuTPberiuvyZtD+xPZMbmwz+Ocea2YQPTsGJ96uQzE3x/GylC3N3utVYembgjeqKhrGuPtPxOqo7/S5OnFQABjWzI6eRDdCV4O52+gYiKDbGHQhrCfzZ1+3Ue1RhWirEepeqc0A/clACrrOAZVRAiTYDdpjb+5BpZR09V1pH+KEAVVJFq5z34s8rAcahfW+4pgjHKlfR8Mcwts2YWPmixFWgcWEsr/DxqK9bfhAcvDNZVmyH575NbCjTnExLkAF+AiGMK7IDLkw/vXfpVCh7DRSsNjFYw3RC2XoocZshO7YAiARK5zFWNaEdMK7uOK3Qi2wedv9eKbV8+mdDdFmtPB0JWe8F5bpFrTH3SwqcIQGU1NBXoJ+y3BYFA0foQkqoJrKxa7rf5RUmycH/oKXCTw0jxUzr726fj1ZvPB6Yr2RJoTWq91MxMuH/fUz9qXvyZiKRXyltZDGYCxQaaIygJT0QgGHnsGxAJzQYKykjM+Wan4Ues/sPzT8LGjMWbiqIcrn6W5vLJ3Gx4jYJ0iw0GdOoFl6iWddtmuNTndbeTjNev3meyTeiNAd9lZikcV5Tsvql77YuBsvHjNKlaF6atXMvCNVjSUpSlj8/+u5Ni6V5IxinLzRYqHo75ZYzJB619w913N+ck4H+wwWKJK2vI+nkzAZ3zfVFgBkPWtlKTkc+ztR3/0DObFfppWSZf0boulIt9yKEnM/VIeJbzCVY4dB1o+ppn9gtKb21J12qrx40vE/EeMQZ8AZjHZrWi7kvSi9s1DNi6kA58qt27rmO7Rz/F9y3evVb+xSNY4/XZM+5s2Y/up89MM5AZM0KgGLw7ZHHNxaZG108ejSsrcPNXFRbCfvTLtTPdtEGsIbK/FF6kAx6rUojm9BXi30N1XJ/bmFUQ8Ke36PyYFEasVITfXMNYN87ylRE2de5cEBe9ICJBIv5CjnLgESHzFpCWrATT1RHDAWgrchTcHQ6d9/nr4Muy16lZMgF0L5RSk6irzrtdjR/4Znb5DIMH9z+hOTdTZaiKI3soStjb9PAR4rx1Ll/fg17c8UX7Ekr2KSl5K7OHujVJ2ZWOYKds6sNqLG5NpAki+ate8sOhM+vZKTyVB26bGYwvzxvfKnKlemGs5tWgVg3wxS9+7I3qDM+VEzhErYStDDN1CQ8ymB5HTZVWdfzHSjYl7XWMQvSBHJQI019B3Lxy3FHI9q3EV7MNiqJ0njsIFv7fW3jB4lhVc9oUwLfVCy5Yl/1dKLfWNBvMsGmvDLhgKfd/w3XlZYgTN3XYMHgAA8FYfahnqbBVJKCVVERqwI43J4vUYwvICtCrYQn79/2Bghd/nlngTWp3rXOhmvKVs/iufHh40H/reI9Ie7hXUCkLPQ8vRuvKEMhVqN8rjJSc6ACRnS7konxWPilPxgC8YKF8jLm+8NCTNSUefyUbWTe6zpLUSw6mb2uidp5YZwTAQU9OiqbCCJZj8CWORYK4RxuErmlykBbajha3WFOBipSvuMw7e2ljDJfe367X5keP5qDfwsSt0vTcxuiBidzb3D2OTxtSSy0mW0y/b/5bg0Iq2C+B0A60TWsQ01s0Eb7W1FltqZMFdV4bQ/aza9ZGUTJZ6bmg24lDhG4u8h3hMa4DljDVjg0r8wMFZq3hbXc7F8RE41Fq2MJdODKyYdbz31it5G8yTar7Vr3p58/avGQku9+nnAQF9AMELW0yFOvOPWrsEsoWr47zwQzdY9TurqivUjoxBQFE6WRESn3ujBiwbEMmi1MVNQiy2VCFH0FLRRr9qu2pGan9KRpgl2nN6j2T5wwRXMgb+XqfQLd+UoHJu8XqkpFBy7Ohfk3U2s4LfvMkQXYY8AdSUIknXc2XcQ2ugUMQ96R0Yug/VPD+94E95sYd/sHR/hI7LFVkjDdS7S3ZA1A5sPN2Grf5aN41AznrsdpZV1O353q4geeVodyUOiP5OYZ3jE0UpV1tQIYgA2mmOeR6z3Lms3VLFhA2LzGHJnreWdvS0cvLdSx/tOx6hf3Z3csBOIjBsv41l6aBn3PoNNxzP8E7v96dsXMxSsXTrKJPECkLUtFYvPg/hylrSeU5DedGjB0loQdXMGwtLReJjx+vgwVrXSz9IyJ/o7oJg8nkJEtuhxCl4Ac1oDJl+iM2MF79TPT6bAuqiQTmON8Lmx2dOfjov7Csow3ZNCNKRV8NIi4Lx342PkrcbvtS7MnrOcSuMw+/tJQ1bMQkdhvPlgVM491iIBR5vgJyYSj8gAJFC/GCwCcf16+2ifEmh+GIxDjPI/z1TxCseYSmSrrCWJkQjk0xpmvEshKamC9lizjBSNOzSsN19p2f2mDbJOS7TUafrRuw9rUVi0HBR0CxE5/fT5zob8SMJNTJY++o4CCgAlPmVjrBGiw+7jbZgG4bLz4OcA2rozGNipGIeD9+ai44Ag/YlPndtPI32FLV0kUmRqkBaw0WXo2/QK8qIdjspiTGIF295c3UGeoVkdrSy+eizNPzGS3nv6EGffir6XFYpeO8fdkMAthGncBaLGPwMyb6xeA7VNVTOGYtzdjPJQwtvMOSoTB5WU642p+jHOp2G2CrEUPJtjBRyqAYL7B2nAUrFWw1LyQhdZFmEmIpAkocFyPPjysqH7kdXw99fVWpcIirgk+wcDXRIXvzOqfmiUXPASH0kDYm69zXnh8C/mvzqsX/vfvKkgeY03lwHoAChtDYAyLADbYurnukFj88dwFChoJVSKQUhTzIE3fHLPQ4UZKvlP33QwMbf9zsZ9JbQp0cfrG+2TvClzjegwUP8djYzSFtveAPaPqXGdICs7VfT/pLA3A6dK++it8Tv5MALm6Z1IGSnDR7YU2vynPAQUoBGG5B/h1UKRNx3fukVXtkYLbM9TybXsIFJ664FYScjekD+gtEeo0cvxzwAJYCkyl8DEQkC1DLvKKFVJdm2p+P9UZGKPJgNdTV9tEPRRPFkId/lIIGCk4zEcKcL8G2rbiJEr/mnX4Qt9/m3Q42YGv2ifwSvyuEPobtW+wzj1AgMdYyZxsXwZlAKCJyfoI+GJR1jryBYi4Akxd3I8ykO02BjvNajrVCQztOkIcRB7KRY62kutI8DzVdUjGKCcb2+SnZyT2T5Bk3lqbcAPO+2KxQ5e9OHZcTXeXzPzQPy9RSCL2x+qEUnu4+ZChG/7+XvfQZImjrVa8t4i/AmSyhG7sLcKy87uhHlyLVk89hHK6CZpjut+WDyKp77+dbUDvBSbJSj8kSqUEbAUhlXvQQtx8xRtCxi2Qc9KwRhpNpHf8ldLRgQqTSZUR2XcbGFADwhfu5XhyA1MO7dMq4cZM5oh2Rsz9A6IFQjWNADf+R3OpRTQQr6LAUQdUbz0MwIbsgg0Xx5ZZn0Xv5lDSCxZv9Tu3T0r2y0h50UnvHtVFdvC1bPiJjB22yUrh+dpYFUrQcmx6TtK4I4ShBn7dKi4gCfU3/+Lf9OABjVHjPCZntfKNai2fECOWSUr478Xj5RV2P9tnxo2sHLV2VC3Jc1WvCtEErfWKcfzDbT2Q4FO9qrOiqJLMtIZbBmR8r1sAO/DbK1s2IB942xOxpn6y1Nx+Q61YrD/cwxKy3sfDX9oHNM7q4Lav3kVu8uGjz9SBHoJpELM3Kp8OrOlqcF79fcVKb2KsuAkjMSUUe/or9sGvjzAC51WaONycRgLoM5bbIXNSEuZ1W1nlYwvLbnhumexfHxUjIb/YQ17+IW+3ZfZpdaN2F+J4DU57rItWlfV3YKtyAaUAGVVkqKnLZk/KNySzYM2sc9ZtCXJNLNJdiiF5CzpRhRP3HDZcjD/pYO719NzCJqTqF27E1F0MZfz3wcq8ZowgvR9IzvqLic9zdnBtDPETupQ8LzFkgqwV7OQKr7LejneTaElriywQbgk3oTC/GEM+QtpTb+PH9eU9tkLROhAoHR4WNkxxqf5aZ/ohfsFIeQTgKKD6GDR55j/QAJ9TW9BsHKSOOPjNUYwishwdfeU+sGfdXAXiLGPuR+43gHHTb4IhN4q1NDtGRurzYjDEdet+SPXWOY1ehaSz3J1+mNoAoPBI2GhPtJ/peueCO7ILsa2EiI8Q0VWaszcMinIf7ZhEmHDLAKNAhZrVoL9WXkIsPbG9O1iQKe6uUTvO3v7oe65pffyCIf602mbRBA692jKHEI9ooTOEH6h0Pg+OZysTGQd1RpmPlbCuZuHTFMVNc35EB9wOj6RvQtBke6W21hmf9jEXx4xi8Vnics3ab1teZgGSy/RNe70RyxFWe93hU2kQDFVDAvG2NooAP57dbaWfGAIQE+zMKx+9oMn+kWhVcZBkvBihnCfRNwwWzp/vBAQLNXVtHvi8hAJvg5tVmYHCklnOALT8eQUjURRrOKkc1sQuLYtoqRM+aRpmmEulfXFCVlMvNy2k1YD3xsJXMMrVwTnx/Lx1yRZK/L3jgsNQZtySkAEvnkr2y4vC5/iH8vaoHYCoTRvpl8w8NWBTpzmeS9/Us+Ij4/x1G4xMbElMMQqX4j/idH6iOjDDaWHPyAmQ0kJYE8CYinu2NQqTCpmhQgBGTUykq67/uHXv9JKPSk7btn+zOAvBQDgPw8cA52OxZz5iLLLz2YDEXjdYekQFPcHz1ip5X+zfL6f+W2uT2JlcyfDu0Aj2CXgne/OA/GD/avCuJcQfsAklvTIsFrc0gEw2MdpOgCrNU8iz4sh85AsTsVUl2PV9cG0KFWPse6xZcNr1Dp0GFBGfNcmlT/DF5QD52Zc6xENo8EwL2PBVDOYB55Oe452ZVLSTt7xyjKH//Q8bZwMQMPmcKQSiVO5Xc4ww3U1plV9wMi/8WwCPxxnJHq/jx27wcZ4WM0RHzyIriANVdebnM+daW6tFZc/PUnMNjj5wP5g16WO29aLnnps+QTLka0mMYbeVPWgCA8uaEoQB3K9tzw98yYZrELC0I95Qzm0iMm7Y2F9gpg3WhkGcUET+P8wPxhrhCa61rWJ/xjqV3Gx8NfvUfQ7+4df0I8vJip9OKWlbIjgiStf8W2SIBiwDxxgGCIboGTJYVuhh9reB5KuMwMN9jbQVowNQBrgfxN4W/0U8O/9QXxdUrwtwmr6+MYCu7nCOIalNQu0SSCVPhBza3fbiIGODaEapj3slzPsny9BUwNCUqdqe9K1xCzZ4AvUANIJRuLYc+xdwp6MDMEK0ZtDrt2QEYAZjpPBYivRPhExddURrSgQaO3cR0cTDY8jnHxMCenHxkOBdMVazYBrtBxymXEPwN004c+Jb8Q8qDwnvq8MxHvvfhjv062mvfF1n8oXN0ZAJciBElqHnVUuzxnq0Lx/+9olZBzmhqO18QHu4nJdfQTiX9uldOfLw241GfZ148eFEdsalkHoaNwkAbEhChdlXdSaHacyAxDMn/vfELoSIJz7HkaMBHo4jJAPVpZQ83GhKvqHp0vJvE/1lqSnxRndoi14ZkLhy9iuxJl4gHxW3UgDYkbrnHGySoCC1t8kKb/i+zUt9R7Dsrki+7REQOVIgq0dSlXYZeg15Z+sW62B78oQ5l5Z6xZScxAmO18jqyl4cuiTLi9QxhIuw/3TQ0KCCDLBmCNKk6IW+sfxxUucOui8bsDu7HEizBOX69ANZPaBwyyNYo7WLgEAzNHnTB/4x4PHlQQtjoN43/7uac+muUDStbH8Ce6D0wMUB7Hnti/XeqahYflhGoNvN0BBVsfCgP4bw7VkHv9UusytuM03e3kFbMjwGetJBP0+7zcYv/qN5J9yVZo/qIkQDzEUwFU7lEl+yWXQ6XfB6Ix+ekRJDeVf6t/18TIjzPhydfQjM62OjAlbf+kj/8EGnsXZGQ+uZlDvrm6O2yRis6zyT0pOz6xZlm+t+QvwEF/zlyAMjRrIDVvqA33smsknlL6niyd+4a72q++1dRnYNyEUgtDArCjFEmmA0JXgpfyo0bst9ycBsdh+4JivD8PdmeQ6aU79coPEHI2WaFH1h1jID3mpvPBMOrLVM+30Ts/dMyQPN4Ml49FCS/UbFkagnkItCOv36xG+OIoOCeaGxoVNZJC1zycNnjgZF3qvJ6dv80hxMfMBiLICYzR3ngvhyYLCgWOowf3FZKQioNpL5V2BiUeAdRM3l3R7gJa/Ni3vgvlKu7ihQbzJhziBcRbaL0HonvawF2PKkX7SvEeCQ6Fo3zo6ujYewZZ1jWO8+Yg36WqPFm8b0/TQq4NSWZnJkf3V1SEvlKPfg93GiWB2P91qVDWt7JJojNuXxHuLKwEVGqMfEr/OTb3BUY/wVOMIYKUR7drOT8W10w0Ms40FSaroWe4nYMXlSxbvowgR1CNyFPFiuxWLJ3Nf64+8Kw7rDG4SSOMQRORzNvYnkwJ9GZzxxltcYnLEWFfQBtqifZk3PJu8six4bawIVc2CFXzkNA2MpdwNTcQxv814Id0gGTlJI3khbBlQTfD65HvIabx+kOxAPiH4bd3pYkjYWeHGJBie14NUGFt17+IPqbrLgyWRK5fqIhINnoj35PDGtUwyTaQ5xJNsYRgcMfokRLNUT9Rbczq7QvS2nTpENnp5xezcgDyOykvaEEbD2HtBNyZKr6nQ/YY98oCDg7HOWK37qpqehx3iyt97fuMEfeKCMp/csAPpodFz1OTpB/tngfBtqUg+wUoHODDkUJoyNML+1Vww1hNwwddWn8E+uh9i6fxaaJE9sjtPkZWJoYe/i+VOVs9atrbecIKjDx2vmvQTBfXv9fFI8CF8BDvBICAKA5eU/KvfKuT6SxjOaYbJzci2UG14vCA1oCLUsFd0vBtMhzm7OlneOkh8/n1D5a8NLaSZqzFrxvBI3tPt/fO2MC72eaDHQ8nGz9eCVeH/vPOamoecWe56aIQ55YQaFV2zZY7N/iqaEqHj0ONoxIAf4Ccrx6ox3e+gYIibQeKz7FDrbxzMJ5zcaanSOW9cI0qWqXvYI+8z8dEi96zM94Da9Vk7wilQ60KSLqUoaXOPmfIYc4b5gRiGu9zd54ApllxTO596EeLdodbvOWkWuFICiZc8zMtrOHvZuApBttueS1Tgis944Fjh7kT//s0Bfz4zPtR9D0berWdFUAjaGtn3+nG+60/RUAjB3HVEbmye6f9G34PN+3WTDezVEAs4wVWAgKlWFB3O4oQbHpwI9AKGLzwYDARgH+wu1ZGT8EutxG4p3a1Jg0sm4BDsekXz7aYSXv9iSGFpdrKE+G8emn7SNpjXpaD2264pW9MCsj9bDh/83rftdvlyLMZ3+floqM65oQGT2SEab+FtR25Bh3mrSwAyMHPK1SvEMn4PC5QgKOt4Pjp0nqIFVaAuMqupkUHnc4lFk9eu85Ew3wrgiVLTcM9uKlpIZRQt70ouMu+QwIVbzhTQUKk6Lpq9daKvlAySIYa0eMPePliAVGy60LrgV/rurET1PHSdttQUQcSO44o8YkmDUCmAKDsQKRn7RH+sWsMPCJBLbhcDOmP9gXeplz9n3gJpEK0jzhXanwHaL6roojd8S/ETdCnpz5hKu4hg3Ei72hLfXXobx1x+1n+6zhhtGBeFr0mmCo+rPl8R/aKLCM5xfCXKXA8W3tjCZ+UAe8/ni09ZYm5ADk7p80PHqOI5DSLw9Ngpp/Jv1+Ft+gGLi3mkou3HSY9AEWdESb6K9tYmRv9NruD8DMpqNMsoxbFc07GEh8s7sJlb4IoGj9cX5nmUgVOwqvJnUA3EfPW+R638KfxxPfs2MxFQZhL9PSWOPqu2rVv61kbDcziPDsSuxx03jUj3BgUyMGwtFGPctDmELgNQcS/PaFfLqLz2X9uFlwZP8YhvhhRL4SQfoXLfd4XQUmDkgkHUHwzAB/qAY2OUs3dAxeLZI8kKfEJf9yDhgKxTEj8TFYgKbpYiTI7Kxjn0nDfvWvUy1IS5YOS+ZFOI6hrIVPmzmv2OhZW6aJOM790RzNlzEd8z8TZP0oJOd7PhWWjlH1nTP14r7Fv2Red5FQioSTztu30W5T0vKaCV18Wk0HUR/m22YJFdT8Gol0+cblScSFa0UIIRo3YlSZzQDh8WF8sjiGJWhyOsyTs1y+Tkj4qqYGG0tQklC0HBNcLizzF/uaTFjKqSmdZFR233o4MFUvbeATUs9Y+gUCktWBQbIAa5092HGCv/U/7eKbwKEP/9LxwA+fTgvY7txm+acPXe9bs7UXIbdv0kvONeqf+qU/PZasr8xGs6om7VdwZ25RBFaCFP0quCKLcRXA19kjlxWJ6ZpSOh+UTp1cn6EALvWZyGQijH7KoDdp0j6EwWpWGk29FQuaBZtENgTjEKRPzpSElELasn5Vgd70ShvfMV+hHI+lT9H8nUklof3N1w07YkpTM0f1OiyY1MMN8szzO+lYMQgvxe5DIsK6E2L7jH2PtDl6eug5Zr1zjLUVNTl4jHVjSRswQjTvPcrd8kDCbqKirbFsfJUikDhGtSi4TQ7Tkp1893gBe5Y1EwDZhF9kq3Vc+4Ml0dJ5NAU1g9lMgd5l/2vjTMufr0SkCfE00VK9hqoN399m7gBmwM/o9dLZJETapuRvO2kzJkX4X+oEEL1xFDyAnlEFy/0XrVvK1sCAY7jStzIMP5Rzh/mtbXUo5SdojfB/SIt7gDEBUK4lgIsR3Sx5td5/uYps9qbSZv+KnCGx0PJUwYfaOt/Ua2JdyX0k5OCHhvxAs0yOg0eko0yJ3WW+Kdry5/76Kyje4zJfoOfV65Itcxyf1TngqCzTeg6cS9vIUn5uJ3T3jERAlN95wR3nQhjyg53hERJ9wBf9zoCVZrOH8bz4O5Bx5SeXQDKscRUMhQ2ad8Hwz8lARnDLjyGCnVliixCsEEmFzbX48VVQ9E0+6df8YAbISRAsFUeA8qMlOhT46hMWZ+2VEe9oFgbBO/SFrnZ9KjLFSjy8VpjUlKRKHKwz2Pcpf4ctHHI/MCoKIqy86mP0WfHt/Vv7Q/4BkMCL00GmphXvhyhuQO/ozDhjhtqyLysPxS63o932zybTLh3kgXdYoG+dVMcHyUh9mkmpI1wiRuscBsfCat7apvLILrMD122ACTVzxPRIvOmucRWVUQ4qQ3futJ6DC5G0bG95HhmkzzEzCv4sYlo9nTbyA9Q1YHRlUIkdxg3HN0jUZ/hW9IQprvWCWDZ7TUrsLoFkhbbnCKzipUf7bxCfjQtvciJmVdol0K610ccjW1sRN3rw3Eac+Zh235D6DeA1FU78ANBs6tLWF/LSOC6HBuWBem9eTFF3QGo5fQ5pBnvSE3FH0k+ZXbWIDvF79AMSnfASVcCQGrqZyxMi1AJmfm9eC8vTWxrtJxfuHFV/1JK/jYN+vhuMgQaoh4HDiBrG1RxM5zk0QTuygOwsjwFHs6DTmP11cHl8hCvpKG5j7DEhDcXJWdLfiQXin686Bx3fFwUJc2S8+yVsyedG78zbh7V+T2sDBctzajo61Bd8Yi3DUsAWjH7lracl3y6O3T7Pi7GazpKJ7K5qYub8LcyScFh0H5UjbwIeTn93nT1daHLO+ILqiarBTlo3PotJTEYymWfd2LSB7Pmq7hS5dpX4NyHfpCQBys7xRPO1WYQjSn0Ozyk8jx+ohgVoQw0PE+Jbmx5fwlremu+1WnbY7XMyW6Y4kCE9c5gTZk5f3t0GZnaJ+1KSAKRDC5oJVpPBfYEL/LG47Kkl7m29z5ykXiASmoWhr3AMOm2BhQYKcdwwAGn6USZ3d98RmCXPuyBQJBSP27drdXAffjoTmyNLjIBK8Pt1CCe/9fZe3cmhAXqiU8DczDhf7Bv9+aYs7wzqyvEq/4QtRCgFyDcRMHX5rQW4lW9F5kTLDZeQhEhaNrNgYhWrkPAFWZxCsJPg212X1x9uuo9DlCzo7ODvwHLuAluxWuJwlTrwlHWJZaMfAhawnpVlHHfX1yErlnSEWtEDhDYeIG2OYgBs9Ob5/P2mGQA9fmVBxvboO6mA6D4YTtf++N3etd8fvlOuOIeb5efrd80JwUJrBRqRnHql9wurPzmGdVKvcXjQX7CLGqmrlw6vhsOWLGeOXRMnj9xPq7WNnizJqXpT8j52C9kg4HqmahifO7aZk9BovZl6SErrbSa1JBqwPMvtsaOVnKpKycxzA/WJ0eCeSvwI2Ts/gWy92JX9ojwP/vFmMVHBC3QFUEIEER3I1fgvXjbzEEKZFAL5JuMTVd10Vc7z2axegj8c102ZlPx5hkz+wDyH0fTjSHq2XSG4gf/u5OcSD8FLI6a1MUM6v+Cbv1Cm/JNQeffwCbhL57Uf1OLKh8K1Jx2Rl7d9o074TrZ5ta4ZkiOKl+FQVCwD/K94iopFNxDF7scuAKMLUPiPxALO0xTZoc3lGFpJoz5gqeIfjxcYSlNwByNWDilpOekVMzTqDCtIkne8QuJPQj0167C+f20vOGYC6Ms7ntjoy1TuHnUjHzGqRW/zd4/zlILGiMY3mxFVoHRvKeATIZbH80sU17GrRCMKLv48wqB3wgQWeMOVqkqQ/oexAJdUZecDmWwVI/qyKNI1qWGH5WrkuazB2noXUpbyGil2ofzRP/2h0KADxOJbt3svsTjAEmfYdH2fq/hvzpJw+tfkz5NB74XRxIx0Rp91DsvdAiWVXBo2pd//HSkehTvNdl0v6OLO3PHrMCudQfoA6XFa7tltJpItkTJ5nJOkz/WIYdPHziDWwpyVZLtBGCVTd2hVWfe73bMHjKLE41R97XfyLqirk9+Ih2E5g5AuudCxbpkbImqGwezXgz20mi/YbZPJo5Tnon8PFyrNsRRnZ6PjqmNaR/W4/AsMarGeYa3hHTMkC31EJ18gm4nRhZvJyvvuibCEF9ur9+AOQEbBDxLPDypszg7LvusdzXSfTq8M6okJWGd05Y9LAxRbvWVZzuxkU+DT3MYsM6Yn/zph35RIFhqFQepm5YoCY5b+ZoGQaOH5C3u8qV7phEKgUMtz7cabzUfk1TDE0mGJThZBmn2sJ1o9AwJI0/P414ZBnV5N1Xvc9VQFiTV2Par17kjPGJOqN1Wwy/8JxcFfDNo/vd5GNXJ75slNTFr+VZpNJoBL0QMXi8IrFH+rBedMTAyC5J8ZvSLYF3Lx6zxrzndYVlK3ozuIaW6OxAWbPIHv3Rh4YSBXlWkbxMHFHyDYRiIjlZvlEckZdBDjfgDryS/NnA9StgPdrkuzhGC0AflJkgANFaB+T1qoUN+Op3VLsxjcQd0mj2cCAFxtfj+5Pq1kvD4pR4UML5iPh46o0X73AAbgAqZg3O45RVglT9sx2A07BR5h17IpM7Q+t9Kjgh6I3rhEBOaTEeRtGGpl781/WZFNyj9e2ld6Vbq+dTIGI71vY0+fLDCg25Te15qPCUbkVtSVE3pm7N44MEhlj/yfDsWSzOUDNREZxNRdhCej9wDaKVU+Y21r2180AebndcNCLSuybQ1i42hpPEr0P3PY6t1letrOqcBqC/65X6CvgvWXzWfmJHD8n63xZtze0DlUijlGHAxv32MRmEV1kbm1suRDbK++0QKV0hDSnhm8EHKDOUG92IpjqBS7yafT8bqoyK/u0pgOVxP7upKsr9d9p4EQHFnIC2G15kMeVu9WcOXq78vdpAkDHTDK0J65ahDuEzIZGVaxULFIH+F81T++E51w61YHqQd783eE3sWthI7eTWxWIyexucgLQKa+ihb9IDdIKPE4VWhSJ3OO/H/ChxLZ4VcR4tCAWNE0rmUlIKzVxIzRhfMTuuFCEEerXHxOMxki41+Tn1HAT8xv2CzJbHd+WRiFG/y0js9V691Do4OOUxeUMJNWxT9KS/VTMA6Wp8C9opJT23/rTT/1LPlYQ3PK6iHp+1j1F1lWFLnH5S5mXDeHAgFUBDpgz94UvGa7n/zsrJmWt/aRHx757WsYmFe5NQRB8oBD2SwlPeZYyQxTd/zkGPgX95ATRfgPv7IrXz8WbQ+eHChoVDwvSkbEOlarnL1s2q+vUvMhN6aNZN1tL6Wn9VGi2+Iy/I0xYUBw2IwstL7/uNmMhdvXVj9K7md4DAy/NNYk20ZYWpPT2mOhVoOQokXQ7XLTilH8odHPQBpPWpoFo+KZ1SvFxREEZ+W/tG4CjVQwWYRAwJodwn1hjRg7FnSxxMwdW77b+kUmVdF+hpKq/A2c8gTlU4fXGI6gQRNX3UdMsgf7wlM3PgZz0/ZXyv+rC8iOa+XZ8UNmIDrYg23AAeq6eJRtqXE1lWTrwBXxcPu+x74VH4G/JfXbOYBkRqTtg63WQVkgGfcjQqVBJm6eR+5iTIm4bHV3pFwnPiOpna4ZoR5Jpi9NTL7AgbX1th9CNf94cLKzLWwVKHaem1nf1MS6CQ2dYrJmWTjab5sZqn1kzqVQU26QXs2rEBefBAcwAfWfABNQlif1uTWK0JcIwynManCCtJxXl2KXllgtyJI5U1BfbXPbjDhMqcitZ6Vbde2wP4O0g7QQjYclnrYLk5fVfsZb5lLm1qxqo0yZoe9kFBkt+6FBAuwABjoFt6yAg6cZz6UvL8Qm0xJF35NccANf3GnSracKzEzOHloaxP+yKwBIG7Az19hu6E+Q+EjJn8axeYvs7pwJhArn55b6JtREdT+vyuj2kznKV7Akzmam4lhQdh3OY50EC7mVRySCSOs07VsxMsMUSYdJyqwzGpeeB7t+PDabqFFk6HdrZVe9GrPrUiOMoriws+ia3xoVZ3j8Y/1V8kuX43mIfcr8PlQ51be2B65TYAeUBwUyN8TfnI4kNTg5nMOfuvMIQeWMylWP6BXrgimp6I91Ws9DPoSNZYeo6MBXf/Ljc462BwndX1hSakRBiGA+LFFzid7FobVOI7PraVGEpRMAFfC4gsJqg4LjBCAkqTYzKJEbTknZnXnEH3XoE9PaGfjMiA4oAJZMXu2qnoWMLH2CmYPANXDH5jIIX1OKv7xQorjR14vpSHryy1QpZsvx6FFWoWSjDsrtqrrF8m7RhEeuowrtyR/xxEbocKTNFXQmUFa6kVxcVvHFu8CI4VMkO3y38pBufzd5WfEo1JbGJwvzYBaHd+k+4UYoq6B+IRpaLnS8UB1R/wxa+uj53IX1CxGJGOcbr8rQjUsE1NN3dK034ik4CJxu6Lrpjl0xIUrxxlaDXTUr56qRyp5DluKAjQ7rM9eP0oTRtiHR8wM9osR06ZZDg94Dk0lDJZZqnsNEASb7c6AOTVHYvn+XlDp/bGO+ZPZvqfvMnv7SeCrYHILRbZUqwnwGdICupfLgjfZhaosj8sTEsb5fDU85fmZUB4G6O8eSrhPnlcOLBJl+St3HtHWrMxNpd974RIhvF4nfW+kc4DdM1kMsF7JwT6L6zmq3Uel5LfBuz2xOTZiOs5kmcLkJbraAEfzNBu7P0Z8jjT3lLbltaala8xv8jQK6oh+i/nJZ/Hws02s9wIiU+saHGAN3zLDhMDNhOPv04yzrc8qWb5Vw373dKawqiwahtTjLImejvyRixkuXsthwTsd/yQHNK9j+GEtBab2LYqMqKxdDBAs51O9uExhywSZDsn+8a2vYQCQ/8aG1JE9iptaJJlWSTg+XplcbMBkcGoFA0GarRvYNY1qQhICyeFOmTGasDdGDj532rmtl9aUqqlSKuH/bYnZwjtywEiLBi1LrR3US32mbYRQtw7I9o1OJ4NPKrSivAje1/bGSguZhXBSQdmIhom+g5YV8eQLDXIssFiCB1ARaansH1N48U07lyIUsL7bUO6GhNs9YrBOZyoiZBLUkHP+1p2DR3BlOtTdYHW+EwAVrTXxKv/BjmxF+KGtWGQcYnUCpuVfhvPTG24zJwfE1zZlKcPp4UKoE1Lba213m0A5ALdAhGVPK2VWleAFh+PMg9AYa6MYHlst5CAY9FFMSCKJXQsyiHZZiotoepykPVF4x5GILzgNmOMd85VIRPRWgi79dduAI+lMRI3+L7Gv82AA/32oR9HccAXayGSRH29TgL4nQnxZyk36TMogQ6DY2vkNySk+QiZT682OEUMmYj/C60CzTohxInZ2pNBAJSKcgVZ7yU+FZhegAWeuyCC6LXyoznr6PWFXqGdCdvs+beElFHigiN+ojregYDKHCVNwJwnnKmUMqdeqlppFRSyUIh/3LtJmIIqws/Cplhd8wMPYvAk388pn7QZN1rPP+S7F5f0aao57WIDIZ8swqEPJguxImYgYUXBafrjXnyUeYFX3GnFvZgsH5Ukx1+5g8yps8Tm3kYq+Jo9Qcuqtc6ul1bH68lNcuMVyzcDR/EAu1XN9kyYt3cidQb+vaMg2CxcVG720ocT580+lAvQFI5OTI/WMIYwFRONhc3ersMoFhkHsIo0zkGaPfit/lTPo4GTwQbT1b81nMz+StyWLA3FdYvrNVIe0Z4c3WeY2mrPwOUNO1ydJGG5TuwdYnfQidGlZ7kgVZg0u349poWpiSGFl750Vux5PZWRV9j1opizrgTReM31I8DWpFam9Gh1DoAXtozQVg3MTOtlvs4r8aqyQQ97edMtyYcO3TufgnsZcKqBDbDhfgogQV6gwroJm2B+FG79f568qqwtxVl9cQCbAPcZP2UKqwCaDLNtX8NV1mQB5qKZPXRQyg2hQUc3F/WRRfLVNbQ8Qtixf0vq5NisvDHXQLh+N0xlgdYO2dhJmFlcqRFVtFSZKGIuFb+xu+0KEFSxzxXTiy4Ot1x6D4G4lz3jdWpJpMLus6csAPR/f2xau9M/PUOEuNRkh6GCV7Q1aXXyQt3Ali4zFjI6T49q+ChNWHIa0q/bzmbHv7TzJs1s9fcj/0bJkGxuPnpwfEpevA4GI660gWy47LTtLMKPRgAlz+xpfr+b61jyNF4RsF+BgHnkh4svE9/UCXXDOlg4bTJYUeGMV1Q1orNE92oJvmFcM3Fj56IIAdhXmFhfJvEb95ehwZsMmGWwyYg+K+xDYbQQX7rb+bZWK38y2ymhbhhPkjGROXqtfIGN2RfknBVmgITeAxIRWT5oJCUw4YFPra7Vf1njA6pLjpFBDrNoU1Bpcvc4wtNO7Dw37OYU9+1TTbwP9KG4f5HCg9Gj+aKhc8n0CJYwoc+4rMxO61L0545TAyRLo5RyLyCSqhg7y90YRna/GX94e1BN9WmDMtlUB9xcn1MPGp9FaNsP5RT9E3ZD13a1jFpQO08yfPuZA/gNsPPxLnkjM+KG5BXOWVourOHA+hIGyVUGS2jogViaAtoQD/4VNH0Rd3L7vbwBDXBZYugUXXZJoJWL0l+h8pPYy5K9hwAmuNAlJRqgPtk1EYkA4fAlUyAlxpdNdsvHx759BBmmrepIwkt1R198K/KN3zgDTCztlM+6s+IP2ksL+IfrcCG+pIQtM+OXVhpXHfNWG78GzGlwiqwPqUTxHSq36yp2NAa2P+l8Us+XDb7S7VwFsxvKmfEowSht1LzqMQ2ghIy5L1D1fzN+iLP6MTCljeqkAS/IGkDi+tP6LyiL8z5vzvICvjXyQSgT9VUqZB3WMLvUd7I5U3JDjp37s0AxyTTnVpm1FbNSdGayCyqcOraOTxdlgiZtgZNgubMEOpvfBCmGQAD8NtjDt0U5e4zyK4bVn26rDLQeQF7/MotUwXEZ1Xm6CIVzfEeObJclGc2+7Kk192uQkAox9f9kX2/d9HLRUvMrowPhkfn5kDJ2hZTRxHA/r7Iq3jqDqa15TvVslFs8+GbJ094PaeH+au09SR5bbHc3pT5JvNDyc1WqsETbH9D6HeVl4IRn0xMULbilDgL7nADvm8lnn+6h+2fAHkMG1cgBM9Xt5T9jXT0q7lVgIECDB+Zrkvdpy8eXKSu55AmS99aWIwxL8WavlkcWU3/4NYNSmx046Oy90hfK7h2nW3VaghUmNWUlX6kup15mFvuuC+mgdkpoRiU+o3oJTZ35PPuHpvfbbSdvXMUOimZUM95QXR8yY0qbMEW1V33jegqI2oPfEa5c+PIgJ7IMW7A2dE9JWKf67nREBaJa1z5ASoxvXv4O+A3oFT0Tb1fcwerSExp/jK0DGelskkf24noLUKkVtOnUYR7GW/EdMBSpniuDLJFWZ58z1twCGmnJNGmACKGvJSArb1K7aphNxjGCDPdk9adJgbV4JEHbh/KrWACOfryNBmGoYRnFdbzJEt5mDBNerKXtIy6ns5dsh/vZ1qGK61bqkGwdaIBuwSVAxPgg302SxHgtDrp7VMWCXHcYM6B87lL86rYI4t9s1J0xfs1r8kLdX0RzinahTYyHf7tAKvtsM/L8KZ67HOZKrP18zfONxhC/2dqvUZF5aps0oSjYwJ+fsW5AhQj88lFdplGB5C3KFTfckkjmCsxMAa3hRVqFeNqRHU7bETBjFOEIOWUBs6dHxjiWifIih1jN9Ppw4JPM5qOZ1wFnVADCqPhYpWaWgjQCZqffoC1p0UYdxLrS6CpJTJ8Fn/SxnRID+1q9Au5r1h6/jUg6n56hPgvi262QVgB/9bT+ZXZuw7eHrNJxGlXw17HSRH0uehEFCiZyijtnNzTcOKheY6INg64ngeg9usO27R59Lg6UvGXC3Sn8x9pCu6HTasKnK4XXLvVm9ny/gIdOWEIqKI/dvNtNaq5aTR8FGSS+yafoZHfLsrUF9W4+GYP76Lu1UWF6Pg/zsy7sFoRteDqymnS5//vWNA1CzYxsGePVDUiBdzzBwrmHbdOYdP/eg4NjM2SNOZmxzDA+iOqXQbKKOh4Pg/epUM3r6wIqMBZhKBf27kJrlpIO/g5/f4VQ34R7yzukBOCOZQdgdGJ09QFJMRP56Db256NtKDgnnBN0FPLIvixhoa/P7E9rtzISqt5Jd/dsJniNB6h8wg5fNvfODVe5ZwiBGgiU1tewlqvrGhVH9ZOVzh5NXCF2PsG8Xnu8DT49Qngnvj3wNVgCBGI4Y+JgH0TND7lcvXJNYV7GvpqxAkl1C1sSA4FwLYK0QkLd4kqJ3sRi3NKEPed9E6NIqPbO8ov6llvNW9OwxOf7cVG9tJe3E4NvV6lxxyI6GyRUVDNPGgJGXT1QnlKbzBRT3Xp5+YJarhLsf9guaBxhnlhKa0fc3+9TtDNU2dmpRatek7vfZH6t88Wnta9MMTEmHP/79ARqqpr6YOBd7WM1+cXpBTf/43BqK4sdIfQfDyBPEEM/J7V4S5LX5TVYUJunN8AojBy3tIexJyRvCV8CsqU5FtNVNp4MClDlE5jL29kelDrtszMROTsrDJ1DRJz/QD+Bz+ABsMgcUfG4mJZajuuBBaqOboxCGtex3CODI766SyA4UqwNaju32cl07x/6eiuYz+sUugmJq7Gms/luXo7yOyh5ve/AwPCVr5kVmIALod2J7wvp6X+c/P2G+ct+dSE7VmZVKwFi9q7bYtG2pka5TbGF5FD2U89IB2vdvz2XoaFtI6K12tM4z0mbvK4wSRC9k1aV5VCH94KZEaVcUHBHsxDRTbp9JW0DTMSVv6pRFP71NDo047o32HGMhhe5LEigHAbAnSTS6rfyxZQgi6ZNihE1iXFi7n3gRrkBUDBDr1BRXlOVTq5np2Szv0MCk8tTHHTrGjZpo5gU8FHcqdTDleRonEe8CyNyew0vo418dLxyIe43GsuIDC2SZSYoFKAY6FlNePHE3g5ABw+3zAW35h7XzS2n5t9c7enpQJ3RxC/fBPM/1ynE2le2gdxHEp2wzaX5GNPgEzvfM+1tCthIrSeNUOY1DwR0+n25z1DRcDSXLPrFfsBtceGTMNKVj6nqXwyhLHn54PdBMoOwBIceV5qS5yxiqq69+rijPBxqdLtlunK+OglhFCQBPuFesEnbKLaQpkE6R8airtjlNbeB/N54akapjLwMeClLVrATb3umFgYJDTe86TpYh47KG/WA2RhvoeOGr9jS7csATS/wsYC/4/wP6B0kAKLuWjC4N9Z+I78p1+KIaCYkRzsE9kA9nFofdnX+5FX5AqJmVZcricDRdzrc47vamWUv5/A6M++PxbQsi3WyDAg6Sw5C/6Hd8lBdhZ6sdLbEMFZwlu5NFL1niaEJ7driLZAFaqNzoE5ZUNkZj11ledzb56WNz7CSzvW27bHpbzWsWHyLZZfsZBgED45EXrXplZGtZb+/HZfBbaZXwqFB+/YWCbt+toBW1d2c/+tBZ04f2+0ze0Yq+Prtibwo6ovDv4GdwW+fQgC5ZBV77ytEN9kqSMKrCXGx0z08qN4nqgXeO/aW5UspItfShsdTG63R4opxkPKnaNhRBw69QZCKfH/vynzFxecEIWPrm3MtVzVUople4N3ms7tAoPv0myXH41AzK2I6clK+pTC2DXsSxl+uCfVpw67tiD/EwN9JYwFrvMGrvvCU2jBHQhvz/R4oUYohfVp7lpsZnihb7B4SCRF8LY+o6FcFg4/RuiDlmme9CSG/IQxg46qkxEMO3Hy/a5V/PnuehtPFNlLRJTMl6k31C2KM6Jq37LMiNhUZZGXA4Ijoq0WPnd2nAkXyzy2QrVPW+JjWEC/76KYvMTs1HQBd/PcpvlpvbLn4mBeR54a1H+GOkYRvJ6bWZiW/xJf7GJfhYnRjW6iElk1ybgXIjo0pSoo+rZnH7u5HIKqdbfiDpOKM/ReGQpL8F5YwV8/SyGCaoC6C3YJ1wVkYD4IjUK1QUZ1TLLTCasnXTVnxUHQtbNnmsliFGpYH9f0dRSN1uIt6KXc7XmvtK+TNqAWxPy9gq5uitAw0XFs6Hhmogv92vI+SID41e+VKNABPUDe/K3mgQdVczdMM6HWJ79lCB8wtQVOMj994O3wj5yXy+nxRwO50Cf/zetCJ91qBVB19QKJcbILIybNdjvSpgVEsKyTuS5jRn57dYgGmwb8cI5IfKuIlhlBDmzi0Sqr2uh2NyYVXmlIqjaiTjNUm1iya559rdoIhC4yGdXngvHNL7q0QxxOL0PkK5pAsYgVnGQ2S1utZ+vzq1wb45et/TY0liPLV+7jMRc2A1uJDxxkZ5rkiug57GhmnglXJG/UXCRHwJuQvA8jiaB0rVJohOBeOQr2+2J/+i3WJVyVWvlf9rdeFfFd4LoeCF82VRIQ7o5R6OsrsTxXHOP6mea1nU3m4dzPnxOPKAhOI1NThpQShNBVLE6twjBNOaNRMtiU+lilMmSulKGPMMBrERquTPaWz4UmOvOpHu4J3SVAuK1LF1qF9vEx9UeRPGUTf1islaTsLJY4pQeMBIpxrkZjQBEtiljMWDrG7wHIi5e+QLznzZy7+nJYuePU6xoRDZ8bUPowz8P2RRVOFVcSzooxK1ejQXqZkBNWH34fD3l/yvsZrKzxbix0YBAkc9KglYssDOGKRBvaqj4S8IoUfkihQm71XS/MYp4cItx8IvbaXwgu3FVpeqbQpVYhVTsfoWtIYyWQ3kndDfhweNUKQTqpaKQj6o4nKz9Vb70OtuSV6RpCtLW6WBPNgo7ssIr1oNbDCOuvcJUWw1JKLu4CjrJepi1HsY+rpC6tl9SIvw4NtTRedqMxtHGcnmVypzGerW8snTmuxW91yzOenF/2J+IekUyJJOFg1R9mB5DFem9LG0BQlzXIlSjEbwOb58bfDGnmlFisAF72IoM68GsqmwDmuK/QgwvpDCnYQNmsF11gNZRkXBjxfNH2xoSwx1HV9Pm6x6twa3WKi9vVovdt5XZR2nVBxXr77lQQW+ZOWD7zSAUFZqbQ9B1aMlktCxkTC+Q7Wo0PJHgk3HMl4AwGMwInLY37bwg1PZHB+lXI0oSauXM47IPFSw5xsbviU3jk376Bt5ZHFQFYoZM3jeSBNlPhYvEW8h4vwCgha60kF83YjqH+SwRF84f8Fty3b1vuz8+d+dfdYZ36qSHgknnqQpmRoFFzRRdEW5ouj3+crcBV7MhNGv0U2jBUNNGvb1tIMnjmQn5PagUQITelIMBQEmsWW3yT31GcRFrcyfZ4kQ4naGRwmA8CuXRuJvGPQs7kyQfbmFbnaLyZLvvu8dKPGf3XAutyHyyYkjLSePzJ8HPrvpCbaq2GDeric/q/3olZ5Cet1+Q0Aa1nHEe0TmWjOgIC0/cJIzzcg+AsS5pUhVIS8lRAJ6YRDxpWuOTtUTNuu+aUcQ1Ill9e6mFXxI5U7jZN1EXhXxypVZ7Hlhy1EiCLO2GVHyZUOfo8O8xTu0ec30B8yOQqbxdVDlLq4DbLXwYLcTvY4TlBS7YlFUGprcmwn/C9Nt8g3LfgjdO+VUBOZlJiNR8vcA9+nHnu9jpEiMQQPTlb5il0sjrflgNTY3hFrJ/sdstqgWwW5lT+MPOLSAmqXIu/4ZqaH2AQiLA7v0Cq1vrdH+s1k4qiPiRrFB0ZJyK/O+nh+Qxie01CD0lyDjw4APj4LXzoOfVCrmpKquexdCcRCrnKwY4d/erGHb1RZLZDzljxAebQCVdYdYSUKJV9kfl2EhEqoyGdq6hz73/8MCu+C9MUSf1yD/mCfYlL1BnhbjP/atWVuuJXvsQqAOZcpTIrLtjZibHGtelgdQFhmCt4uhvU/6Jzr0t+6YsMIRaQSAfh+nnkucsXCKP2P8DLAMSBx04dV6NuFnnzkifLzz2vz5k/C2L4uCjgx+h5dCVSx4pM168b5yyWwShyzch0W2moaxhYmc+5R7HL/f83p8WoUedUFZHNe9N/BIHypBeTXgpyyCQStIL5XxuaqyKHuQqIEcVtkAk89ZiG/bqM95BIx3eZgYgcB7GX9A1YTggucyACgzCXfGBP8zdRkQmaO0ldkFgmP+jXDYhTDOaacCBBchHdJ4yvdVPDkZIY87UAW1MdGxj8OStjRX42fBP2FmNuWJs1H8YwpA6D2QYpRI/uQvkaUMq4rRX/VRGt94Z9E1mFAcj8BhnOvxGeUvcQI/lN4kfq9qsZGUv2v5ekPw4B3WizhH1myWOuv0nDBAbJxXDKCTmFH5Fi67svEVYIg50fjPXwzGEBT0Ny8UJzezXX8W/iwEQbUUaD8hpEXOkNSk7bvmfAlo1ok3xb+kcUxOVnm2nuw5D8TUXK3T+pwxuTlMCcDxgGA7wT13uHg8dI1k5oyOA2yapAcFS6L1wlEx7xawLnCW4tbbedt9mGTjNhWJSOx1K4aK/y0+/x56CY+ZNq0g9muSWYuLBDixryghRc9isv10hcG+foTW5uAVftdW+sdruuEoPaa5ztR0q0bDzxo+cDJ95H/jt0T6Y6gjZnz1p2vSiMOtAnJeBsVfY5rqxAs91QPR3ah9diH9RNo4fP8VYIRET/YRu4o/hq1oJJ5uo7mblA0iDG4e+P4VMnuGyPjJmsw/8L8K0feOQo2WhdS696WO8evy/bb73t6fVWVVK3R1yEKH7gnbCPaFksiezZt3JQ43G5MH43e5lMPF4b4h2uDxoSw7cfCzWzqo1l78fwAktRBOFjWBAafSH9T5y7zJmKYy66iFc8EFVFjP96zB5W4nud6MgQ7S7IMDJPtXIolNK2Bty9I3ts7oqfQxipqs5RdABywvUx9t4A/V6s70FdkEaS5ZZpd/Ylp31cgH4baHav98N+9A1HJuEW7/y77aIIPC4wsJK9c6ZxDOVCv0MhRQtgun0VJT7g7J2445L3OgmaSntnTWrmiNjhQ7OKWeVQ4RZ1eQkSxY13rkRFi3cQbVkgrse/YPAJG1BVQkthJNBo3hTsquNQBYtTomAtcgqtMa+/9Swqn5yqaIfww7OrPtL2ZxqZzmFGtiO216J2iJjyuLbm1r74BdSjlEKA7sXQgqPvy2XE9lbzOOeDuedKz3r40yS4bau02GsJZtFF4lDxvKQmHJEgL1CnXnyYHoLiA0GbblzajiXGoD6v0BEaUD6wOVgVyWwg7hcgJ7QWha9iXW11toVEIGBHROnMx+fFqmmQNTFhRBA7Aw692y+xAMHgna2wCxoimOSBk4VOx1WnioscYz1O3WSJ7i0qgIFpaxK0xVr2tibS2HwByJzrQZ5ENwnzAPxLDzpqzo2AxnTkV2IsqFkQp6x2JLBtXpid3bvxZk9NawG6YmQgnU+cyF/0kD1X0Fye8JUtd5QvBCRBvW0V55NCbwoEhw1zMbnxU084ebeQaxdbcLSidpajPmlKOUHBRgNuFu4ZxavNS6TKiz9QvUnO+F4oEYfGPPhEsAnTx7UFxKyOcKTY0eWiQA5guBlBNpw+brA8vCB5vUMQRuFNPwIkdZsG6MuTI0p8oYmgTDAllS63XdvHPnPQsC2j0QpXDRnU21vnIbtDny4jthZNQSSy+GRwLJhrXB8DglHiHPvfUrF+aWOu6dBtwHJqQDN8Z99fu2rPDHhDeoSddTRg6SyceoM2h94n6OxT5I13AM+hEb+HizfzOw6K8IugBSvsbw2HSiIoMM/38WjNnfGopkh2qyr9HbqRK+8T5pwgNjCSoTI98ZyQcO3B9gI3ai17fVK/x/9eB8e2m42jO0EdcxaUiqYkouPIPTTwqKBKRPf8dVe+59/ceEbbi8wvCAjd7EPbzAQfVo8qahIGIosiALZGSud7vH95Nb8R8/Qr6+hOXf0jygn+tnsgmqwTX1EXIzq9irQXHIucTlEIkbo8MNz3a8mlIepZTjODqBqH1QwtYOul4P7t54gK7FbrKxK7VHHcaY3YOLwgJedoGtxwOTE3VrzM9GzKQldWiJxuO/Epj5qhnNyrq76+aX36kA9yz1VZHV94pKft/o8nz0yQBqkU7bwCjKzo+5bZbsQcnzcDte6MdH6999SP8euK6rsHob4PP9l20K4vfqh3M+jYmYsiL75c7d50GVEgc6MShRi2asfnX41F66iXdWcdO2B/mBoVXfJp0g1/1OyuUR8J0+5ovSt+/b8lmR/alcWuexSz5pfft3+j2qu0N9nCQ7YCf4J0V32y9Toa1ZKC806zRi0PMfFYdadtVg2QUsF8y3ghuj3xbI7Pb0e+Xd9/TofrT+2hIPzVUIZ5C10i/2oiEbq/NQj7fjSYnaeXdgm2o5Q8dgF8GD19gWVzYp6m5vdGtaPtvlGC9WX4fSDtat3xVCfnVhaOzERwgmowk4JbU2wrgZZoxFQIvlx7Ivzjlmpw0qOIWD0qfCkYLZyDNmteAHAcci4rNUJOnhkZXDDNJQBWZy8AuHp1Nn4m9mIzgUDkE+GFdnBfRA1sxLCjq8KUo/175i7OkStnWd44HWN/JHMnK+9zrIux3npJxvGhDDsH800frjmkXbp0bUHtJaqpBs/kNxZxSqAHlPBTNTEYfUvF3Xmzfrxenl4/yB49PnXBiyKOuHHtvYPQK+Mq9PW/z0hwElkFKSzjRjrXj/tvGPhPBoa3mMRFxbcJNalpPez1KNqRqezs7y9B7ZlFWw4b8RdWMktlQVw8v50FkS1mUpg0HhLu14rm6rT03VNMMKJsraMrW4z0vS/ALg9XkV7eQDru96xVo6GxAs001HCjBskL9+6+Or1muVOKP59FMqM24nQyZkt8LOgyyorPhADdBT8igsGHGSlsd65w6Y2qns3OGZES7pjFv0qkrtUSpU2t1sac+fYpzfka3o8NMhHbQRMvlzEFN+H4ydS2kq3SCvEDa3hY09zvCcdM2DtzxUdzeARcZA7ot6NyU8I9TDq6Jw1M4uzZa0uBECIATurxZGdZFtDi56f0ndwkYilG33VpS434fymHOWtH9jdvCp3Sy7ZNxA1Lt3yVYfWdAIlC7GL9Ls8FU7cv1O3l2cH6d4xlVmn4W4RsKKu6ezjeGgWkC5RUV80sFa5kCjU/BtZ6BaT1sLInl145D4B35wJgbZcX7GGmDX8Xro8j9dN7Z/pd268vQRgQxb1qm8A5tKO4QFaHaUq3sQVk1Q+QhQlJ1ijzrlMyiaWp67Kl6BrnPc13kvujgLxMzyt0D/UmlUjvBkrqYJIBIB1Ct8yytnKbUiicFeUETOdo1aA4ZbMI3p+NXIpW96uohmXV5e7Eh1uu9nzkMJ3+MDwUaOilyHYS9QidNrv+lYDpi/yPjT+BZst3Gl1rCcs5LZZLXq+oO1ZNPlJjafnyJgUZ8VQ3ObPxwy2gp0HAspjWjY68DZLulILf7A+cW1mosId+m15VSI8yxwaBccEGAo9s34Dtagei7i1aiLTXwws9rrU8JWmllrDtTUgwvid9E0M8yJI0zLv6kmwGpo/nESHkGSfXL1WlY9imGbcoUm7oC1lk+mD8YtL0b4M9+pmuIp9XD2t7H7Hq+qMtatzsAgon2arvvwMAovG9N3L2R3J6gYO5QeEY3/KluXFN6IvByaS/X+bypEwC/VbITPYASfPqjS5hlFBciAvO9bOGkV3ztPETVerbDi6AfJvrvHtad/QBT+mTJ1945rlVZUyqtfRsaCQldKjhxPBmgkNmmmSlg4rQlVL0MJjRCyjcck7jQdbgAz1QfZDSUN4rTQAOgDNALMUK6pnoJcBmnw8RxbEC+HhiU2z7WVeBOWqZXxI2X33hpgi+0fQ6AXC8vy3kdCIDbn5Psl2Fl/aO2CJnjtWSAetwyQIA/RLxMuO3KC5FRqgsVf8sK6pttZjCd0zW3MnBSk3td+NT5O/Tq7fKJ+4551z4mW9lmLYt5A1q3ZNNLFpra6VsZUSm+Hdm2NzuucUf0EA2aCarPXHA5ZIyA6iCeYfdBXuHv48GBIhnT4GplUL1yxYufEirFNxtYGFajUuBjhRVIuZm21Phb8r75XKJe/nQ6GAfhMKd6xdHDHdiSjQ/T7I1vXhMnOIRsQ4IZqsbKLH3poqiCwGR+UXBvqWVE/fiESfDVWAjkpwb1O6XJnjQO83dQPSN8M7+mf/qvERtqi49c6MFrVi0DX1vxYcNJvJtU/NCTWdtLmQiUnAc0W2JQ1iuFiopJZClGh3ZhpdFAJNXQX4NfyX4iw4aRqnyGIgVL67NihNLKtsFNiYEUm2HghW35zp483lL1GDOM+E9GVLddbtGXEfEspsZusd2WpNjV50LPWSJyWTVO5l3vcv0NankuIiHsLxuC2GKwRgmN01klZVIvj+UJUvkfpgyFmq2MT3rkFpWbgIWLcZtBKIr/qdQzCP0yp6x6c8yr+T1GFeWphdFlDrIg/bUft/6Du5O5GJGCO6vWXp3XUb5kXrEzW2pSIReSY75ZOe1cPS+dnJ2weUUpm3ikMquwvFoVzf0RzfWAF8opOK4r9AWkxW7dNkQdZfT/rVYYP1YX/vvaSn01Q2xuTIcvUdCGu0v62W6vkDGLOp8Z6WVo8/LA9L4RG90b9UinLMKtgQKgrqjDrSDGnk5Ich6btpiMa5JQLqu2ums2YtMUg+EzNWweqFo1kENFc5SQgQPFx9yYRkvBq/EXao8E6lUVuYV5ql4yPWh+6MO2tZSbadOAWDa7cxOWZFDpc4gU+7agaP21fDIicoCznK9rymDhmUtaez1XI17NZHWgVfc6qFIaAJkg70Zw6QrQZt1PMwcrgn7UfeEzLSS9quLT9fvz2FlZBPJTgAloYsVkiNWLQHq0ZF53dAKSh6fMOfKGs/pRp7qxw0/E7oYPLPimwCS2/s1r6G/y+8YCjhWDw05jKJZEAtFJGFJKahUiOWOUbl+xskMMbmWgGkj/ti2NHtSSixiJpOc800qz6tlrfN6E5S59hXITEro+0fvTcb9gvuguqg3FPSjCbsyYqaaXdSePBU1UFx/4KePpTc+jutCXv4QFiyfhj5mgWfqdoHnCfKUXEzJ1YIYWk+gsSJmQIw10kybuUdYpqdzmlQLFdQPWwqE6UjJfGRFEVKGAdDWIW+ksWMcb9I8w3KitQNQeIafuSUPmmIVKTOQbPpYU5meqaxK9mLldRYI79TwoT0wGd4EdZXeE5NjofZzqIRfAm/ZoiBAdVQ/U4w2ton1E+y9zhLFR8EzRKYdGKxT4g1yfDxd14z0aF9U9W9vgc4T2u7M+WUP0V7Py5yWBj4r4nOwoTTHMWFi1e+kxM03tMiqhDChTPpVFigoJ6nDK4nxlfk2brZ9nN26dY/4IQjvh9X4dgpdpoVqDTAEI77zxdLYqS16Su6Pw9yc91JNEzGn5PiIQkZC9HVxH7chAYFlmvY10O+0+5+tEsSi/i9GPRu3yMJk2F1Ns9wwPMJ/L081kKcRd8Y+uHiaEOBJxgqm1xv+htBHTLmCUoYOwuoW0yum3og4tTdei0be5lT08mVbHzZ6B/VzIYQlLP/ctzYu/fFAQencrNYdpj89PNwcJ+52Cltd4BWLZTYnLx49iikXcZ1/OtN6FBKyi+97TThKnnFndONPK++4fLFPoB3t5rg5mt4AkmACqvjQH0h5xK6ZTUFo5snhewh5PrVFxngblM1Ys/EO7L8WkTk9WL7l/jttLRuxyhbHrmrDcNgepaLvQ87aywjXvITtTFKd7JBd5MypO+/h54If8CKpTqhKMD0xi3rAAjGwxP9IZaZsNXwOKGu2vNlBKCsaG9MzoI15DI8UGklHZ/l0v7QfNWVx4wch9IqeYAg44Db7EnBMYizcwYKLjj2d3hiQb0UX0oOFMMkyxtfUF2Vkxwxtydfsjvc6VRtOsQBTC1VtZCL+bn76hcRDWj0F9EkFsGH4h3+a/SZgGbkCp11AquRzDyhArpeUmD4peAQj73NFZhFty85KgDJ7FI5lIPpdljPiolWVSjH2LT5XQJyvLtNE7R3gC0rcy7jUOEkNOqe4gWBILlBf/lpqfEiSBY3JOLbhd6GEfLSbWJ16UlsvV/fPubx6Q+TXcchrb+VKxnpEqKzSWuHACgxv4osF8mr8hdydZvrTwhicJlObOrrG6hxEMe3L6JNymllZsRAIg03Jf2MacJ0R2VQkeh7XRJWSjUpgcIObz+3HDdEUpsQpsDZQaHEKSwe03i8WcpurtHXQIBolFfwDLK7VM0zX3lHyorL8ZryK3HalDpCLkWotzsD7vT4vzAO7w74ixFD9wDm28S0IJw2jYZwyU2dN77k+gEkgbvq5Tv45bmOJvW7giUal+Tdq5u9sS7gXBueFNS7lIjmPGOGzQW2svHu/GhXiwIiFpge8jicpwEuIHIo//F64KBm3ufb8JWUKaVTyMfs/fBznvKP2sgZxgYJvCzmL4k0PJ3BfckKpXNujvvIluqO1BMhZakYROMiO2MgkC3ZHSwsTDsjXWGgabDtTqxPg9fDzuN0o5vg8K6gfYIhea8ccHs04yw6G+bDstuFlrMKoeEUF7M+v8nFguu7mIDSWZ6Z/k2mRLNt/il89rPZGjned/ovVjUZlegUwG0yYrK/XDjOtzuUUVDAg/wV6l/x6OD3+l8+zGSih9l/Yx9JEn3x2Tz0zyWhh2110A6wECPIZhPaLRrKdV84gmHtA5MrgAPRyyrUQ3egIrTk3luRwgXTO2IHXyLo30a5V4xiVgbtEzDqnXnxQ5png2ux6XJolZ6ZUZMr392xtpLZ3MyJauFD+H5kjp3NM5ZoCpxWMt3HTEWbUnhgDUO1C5QFGYHP1rmCPj3LM7daELuO2qgVzoRPxV04Ixmg/Sg9/phECVWcQlrfexDfVZiSe2XXkZlUu/jrFmud+E1Hh4KhV8OW/7e8aV7DSBOKwG2gy5RrwLkO61WkZOIzIe8mkbIFX6pdVxrmGZgubAijmiXilrzeQJyJ+2yhkNzT5HxdDkV0Q+1L4I3FpF51jfoYjhbTU112HnQ3Vra/CEQTNwfyRpV3s2N2rpSdISNymJY8Ap+K041vhEryYqqIbWZ5HX/39Phj9U0ZVNlpRjqOzFti3Zr10DuPNltBergtvUU6mxOqxteQVPf0nYV5IgXsVHQroyB1Slyh1XdMHuc4F4nVrTH9V6CCpcGrvz5TXsrVuO63UJrl4lEJAiFFrMRPNwHmTf1wPU/2gdNi7/pIGgRMms9IhuqGmzpiqMpNvH2N4mSKjTVqhaIHpAHXdgd8o0bAN704uEe8fl9om+sr3Cg97z0Gcv3xda63Y4uS0otoSGeRatyWK14IfI1QLQZgu20FVfE+UgLGlQCAPmrQiIHHGibR6mTEfUDNwgWPnJS8RwaJx8zCxo0PbfWzs5hmCV7krXBZd6sDAy1CjE6Gy4bXWEDWMaVbsAqADPSoT9xdyjvGUSvllS16wgmHgWGSC3TjCSvC3ZTOYJn9cRMDe5ogHaCpl4vAfdNpQCci63mdMSFPLTIZg8+Z2mBXOTjYg/9UyK9cZad1g6e1VFZE09cOfi7x79WE5KNN1PZk10MzmIJRSew4zlE4G7eeBI3niMCByINATV0a42LRx6UXxmamNissRQm6vsrg/R/BB4O4kDljcmN42u4l8LsG06f+1L1XVbWI1Kseykstcfz7fIh5pqt3McOf62xukujnYNMxwHnF1x+9txmge+ci7RNG+Z8ufLv+s8El402sBVHp7V+rsTcdR/5nMq0LPOyhAgs7A9NWs2ysUKC0N5UUPvkoHDppyBTc1w2vvftqPdQlaIKJ91w1e+8C61GMZ7CMMkhgdofe0sORGh6MESjAE6WrSmFWjW+v+sId9rc7RZlA8mBIRIj+07dWxraCoR95Wags4tWipKRbyIA6dHsEu9d7k3UdN5LgWB77CDtZHXdDqE2caZ/h7y5c46UeGVnM+oAPmIJg5fPD46BV+f3fjkEAzkXX2OiYsUdkegr/xt830uy8ymaH4V+5bjw/mg7WpbNjRFVwsZ+Wnnf1pqnD1PoXroEh+OlsKubdsrS+rjDF1GLV76Kh+F59IiOEc8VkR+pC4HICden0PzMQFrxgIId6WRiZSfcuWsXSelIDz7mMU7CsinARMJTAL/tZyX8jKLJ/Iq1g7tmaxDUnJCuiPh31sS4c/W5E+1iA2W2k4caQ9CihSKpvOS+8+cJQRcMTbrverkDeGVVeFIngY1K6BFvvWHyOMf2YCUT2aDtXWaWZX+GTaJF1ljbOiAr3dT8yvp8VQGkyf4MwWcLL18pDHTZqHeZmaT3vI7x9xZLk91kp0QkK83BzrMcTw285Wg4WLyWgrJRqK2Y/d3HQZBcUiOFmQqYaOgV9Q0wQyl1unwRgjVzpldFnaVrG6HF4PMtsXLjUPB4DtFZ1dNzh/ilJq6vQTfUyXOX3O/yKtZN7+nbsSi7qXzhy00Iu44+H7xS3p+7x6abNJZrFi9OHYine10dvh4//+b9A8AoJp2OujNF69rrKe4CV1yB0IPYfTLXQ/9LsvvZhhLi60bkbIskZPUEzveSrthDxZBXRUp+ryhAbUVHpWH4qyFgum/qJWxa52cE5O5fzNYDffRqJ3ItH5tNE8/7rTe0usGqhO1er/iCR7w8JF0QuZbp+Vzey2/bnb8409ED+bDEwX5MGOM0zgrQfq3GexyOGuGTpW/dRQE11OnjMNXkC+bQL/vm79vGoXZSnNpcagr58bI4cCGWClIvwbRm1oRe8j7DSHyYxHwmZnBEneLXj/3nL0LSDqMOaX/KXaGYROoaCd0wn/8QnFQAfiBkSYLMD9ZmMbEdv07G+GL5JQyeUAZi4R3pb18AntDUhRDC/4x+JrGdIN8+6MrY1T4yVMnebRtzMkLqCtXMJLqtjB7q21i/KlBT6Bp+wZAXwG+cWwFQOHZJPkN6Yf/dncvlPDdUzaXfxnryFzsOO21UC+tN1XfC058m+aFY6d1MrTs5WmHL6RX6/VTwiDIdmtctN99LMuHurB5LLmC4EI6h9CE0yNmh26N58ZpNBkdUMOy/xlX7MsIrVx2nJPKEA3dSgC4Llqw0qlNh96NQyjNh9/2TsWcW4Vi+YB9ZXrpuTyRh9oXtG44GQqkqlWhbLo9aH0yOXzl+MKaoV85Ja1Q5cGWI71WPTHbeiFwlugspxUYi1D5ZYOVhvMboBR8llliUEy1YyWsPRS1x1Q2Bh2skoct5krnKv/5I4WPSV1h/WuELhxKf1Dn4b0AmEThn/TWva0lAh1Ux6rOMUWiO8+h69SQrmPkStnbeZE7akohehBmbtCAZn3+MfrljFrc/hJJTUBic9GHExxuRVOqxAv+J1ofTDAsFvPEUnwtnuSrSjMn5aWPFyPkun/gdQiYedHn1vkX0up0Nr10h48aJ25RzOdBQ603myvWPE52eZZ0QU91Md8GDaImKkj4eLz8EgOYtoPuFkYGZ8UfZ0zxBOSPJJ0rcfSZZCQ/YVBafAPIo4sC+ScG8Wz/sht9TiMXircteSP310S5I36/b2haJTi2Kbvhl5Y7uXA0TtcYimuH+VQWwnRhbaOGC5NiXr8mbRWBvrkO+6ZUSc3RzCG779zQS8Tw5KzcMU+0OhbvPpB7zIT478hRqbxB08eKYE9m8ljDbWSCirbjBuA4ANfbaFY/MelPuUBtATPiTT9MrZD5fkFJAwKTjal9B5WpGBumw1zjwgQId5tgZfhS9O7jQk/IIEhBHpXJakR7VU0vHvol3JcND+LajWe+RRroQfS4w8TtW5spXtSM1/aynqMryWOaB1lh2ghqPXUxcPhHtIavbA5HHEbwcac+IfXcbVm6qrss6/7O4JqatilKT/R0vBy+qRYV9SUNA8vPEB2Po2Zb+d6i/P/esCgH1XGFJcH9D2/EMhUpq+x3HNkKSAQREJXrjjSAFcG7apWvKaFvo75d8WZO+g7YCkrq5OgqChxciBCIp6KpdrU3ttMITcLCbiHKlgZ9XVaNa+PpmsiGO0xB1/oPBhFaPafOtV+9RFyFBP/bvug33oDFw02XVUZhocCm+pOlJML1aGIYrIu8OkanOrbnL7D3hMO9RMyp/CkH6FMK08npE8wqmMEDyj3+fuicF+HSmmy1H/6YTB1nc/7olEA2OrLia9DZenFV7TI8Kg1kAPj29XawCCefenDlw1st2k+Uk0qKonlP9j5eXhqtfeWiYU3xzeFgfz+SLu+FuTdbBQl/YE+j5kHmnjJa+VW1KV3/OMmTASEm2qIUeyaB0lIVdTO1YQsj/M0NfNPTckb0sMH9ADgbGTiKzUrPkd6/B0Wa/QQij2QBwuCW8c3mQnnZ5+LkeDmweREv5fSjCymLdEdTD2H2cJa84CupGDtpmiZ7YOWagFmKbm3YySR01uRA6EqzglgKYwEWWdc+lfkUOHyONOksVM69ZMee4S1Gxw2ATSFkq4eywjs8WJKVnYv4635+RHZ5W3gLGCCkb42VLR+ALvasobg7+4am7EdQGI8pp5nCsCDXt1zjFWj3RZucVWBFGHJYWHQSw2mb2wVAonSjPB1np4Oyz+sP4Gh1c85giGePKRL7HVL80wkvssBYCwI5Cf9P3bJ2Gz2OdZtkzDkxqQSyLdvl6RPSSEI4CDwHncC78dDC5L8AVBX/h4byJlgP5EH1InJkOc4ZryPLAZ2m/p/c9pqtgvp/GhMyugtoSmxiCOGTJpos7/r375nzRCjKQlawqbJh58bDwCyakAO12t26U8dpKdq3R99COTPgsAlI5aqtHwistn4fN2xVifwh8tCZc+R7p9Rz7dBGEfP0gkfpnp3bneICKGB2Oc4/k2HnMgYycy1yGFW7UYYqXET/Y13/CJrV2+cy46AqbetchZVc1ftYiN+0TeunvLlo74s6HHWDafPIJjXKuW4e9oIUVQ6aNtkFr6cXY7UhJ7b879m5Hc1vJ5DiEFY4cfIyGFPrFk72TWF53xMxQ9VbcXZ+kt45WNuQZizThiBQXOK/lV7if3QwMrT9r60CMr4TuQKjmuGELkwKE7AOakTY5IN71up3vbdwlzL3kD7c4rv/KXyhoYzCiJwJaV5fgxPbUMYNspt/7mZFIhQZOZEj5nHBlFgFZpGaYrJ0n9DvAbBJ1TZNCdORcbfS4mJP1fsWp374LrKT76APoPfo40PWZvzP14yhIL5FoJ06OIUSw5l4fNe+99wwkY8SWIzNOCzatCIfFHyaFbKBBm+dO5zKTXL2TzNGs/sAtoIAWV3czx/9fcxdhsjC49SwSkIUb3zEjMF6vOCxm17Im6u7lSy4C8ZRcrM6U4X++ZQMl14HurH2vjuFFCF014fuRlnE//StX9cFSfCGfEBLlE7SDL7N0POdOepzSdwF619cxDdrxZYhVyk72m07m0Sxxg213xjR9xYF8DckN9RoVzxTe9pyy0QX9qJnSmz8N/zWMIlY0+75pyN2E/UqI1rmJTuJhwwN9E/P3WXDijygXYEVC7nKXw+oGbQJsSCDAW7MYzdBM1y+jpwGt6n+vTNgg3EslaFj8M6yyB9PVYCIWkxA4e5Gx4mg/MKU48qJHJaZGHS8WEZ0JvczeG65IoJgP8eIf4xZZokkHCSM/hRHiRTolbl2M5uT8XMhUjHh0HZJ/GqPpFzbDGTOvL/xv1mOCrwGB0SxP7nOzveKt0gi20jY/FLw1FEWbx74z7j4SrT9nnfgJFmEwG754hn83rmQNOmEUwbwHTFXQ4X/UGlUEJGhbjqo8YBw1/5HToeihgvtZYIEoqm44hcZkR+BOPpCXfJaeAoH4bEsQIPCmdXF5knMsWNX86pszawzt6XKktufbfOIo6xiA41Kj894TbUBiyigU8XjfXSo4lZ7dxG3ZVvgWxcxBetJeznAEYXNwBXvdC4nu2vsXraLtb0bGIHBpks+5VonMKNunr/Y7OMiOWe8w0c2QcC0MlJdUlLiWl1tX9bsQYKyI83PEzkFIRWmv+OAwEDRInQkh27A+RIihL/IOsR2CeQAqESpz62TL9eW55MILNljbbHsDQQ29Z1t/4rpj2auVWxEovcer79Ce51Y+ckkc3fOIkcyAPnf+VceEuu/GidmdRuBARcESjMy78XsyV08KRqB3ysD+KPCMUh9Q24uMZn1jBgjh0PNw266y5f1pE/O7WuVRmXUu84yOTiJxPd1+dpBDM6D2HNoZtP413ch/ZURiU1dJuvw+E5nmnJ0LJz4Y4Y+G3UFd5BOnNiqSDJ7OzsRO6YOx2ES4WZ8kxGWvA41DhTROX+zXQ2auhZ4sURA/0H045LNwfWBGI/W+2GME30f6bMxtw0aa5ki770XssLoqYMpvVTeCNgsJIPkA7U1JS8g65ycPm9hOlPIyvTXEdm84fzGQZqge+fkhLF47vsw2BXPta78Zov5ucOMDz0t3Y9xoJ7jAcct+WAI6owJIhkai0B1hb3e0apW4VLMtrCWwWplz2kFCgAhnUEDW+Ntc7UxbJf9I5h5AfCKkIp0h0ohscvtNzCGBfGJMXfpj6oAaIXsd1YiBCANPcMgM53fU/hl2d5bab82Jxe6edR4CHHOuF1S5QR+m+Nph+RDTr3n758Gfngr5gia7gsHBDp8a2ZeQYglpadwNmjev3TWWiQK7DfpSgYomwFxAqugiSVyDz0dtIAAX5NISsmMdbnKUJC2KSXKyCHb+SH54HpC2zUyHVfp8nLdOh90t0G3PCI2qdSgp+/u80svUXx3gRLBQ2qT+AmzxwQqKIm1ZW+Xhr0U/oEEdArnlKMfBM7jpXDiS5pIdOAnLcroG0Vkk0d+GjZDQVPfibcGR/Ia5EaNM+cEINQkRj6mB3h2Zfp7DVnIoQ6v+sp3c2kW721haeEzGFyxRtJaFDNhIG+zgN1hfVNqrB7CBn2RBBOT4IkfsnYbGyFW9HnNGidHOGFJlljhplRxlRiiJ3ooGXgU42zh3V0naMCWppvZ+qkLDJswMPY3KoAKg5uPBn+vXTf60YS5bUT/ebIVehbNGafDP5JvwHKwm1YhBimbd+97nFo5eGaOfnZyaLV2NQ0WZE5rDiz9JGn9R1dyQCeb+BjHAkEWm8WrFo0EPxW88K+oOydQ/fRCSCUXdvd/2a8u/p3j2vOzxSqxupZFtlQlNO9SHvv3+aD2XqGnlWrod0OU05cpjwSyWaFb8NYsOIogiMFEWH0gfaBAROmVOzuiIoDds6GGs94+mQ8X0g3fsZo2as6QEIR/JGcfipUMwlE/iP43CS/4l5z7KC0iuyJ5tzoiqP8/yyP29azvLzFioadjijaUb6QXRkkTHCXDzhcv2VQZxqzDppyD0nYbPEGn8spp0wdr/JfhQ2hxSmZb7m5RKRcUtqNezTPH2DUXzUiaiR4pZ+tVn9LjtSvIaWy4+GnbI9LdCMce1DUb1Ph88mhM8kxDDnjuEQtXgB45W4y8zhiVIkfKsV4wriF6DXycJ3uNA8UvRCedc15yeKnO0zQ8FNWtLYpUJY8ddtgqw07mERmXIZQRRG9RGLG9k6hS7GmbD5txe18cJqdCsh8ISaPQ9ApRYIrq0wJqsrNxe4C63Wclxcuv2PpGVKt3QBOqvFHjECpURBX7aMz+patF3iWAJIPQWD5NDb0LaPzmw8Dmy1J/GwiROCPsDQ2dN3Z2l5Vzby8qoaRGgW9NBIF1ErPqv6Zu1DstsngkJM8tx+Ddifge0PVUfa/Jnvjy2pXVJs5Ceq9C6L8uzOo7DIi+nh5lbxOgTo2F9IZd70w37lM7ndhV/3Ry7F6QbY2Ko4uLMGDqlyr9W1WNmcjmclwi4HDtA6muRwOLmm69/mchfxZEaunpT0jr7Dn+m6bJ1s+s4uJ2msxOP0DjtuQrhpgjPwWsqNuucr4NUN3bA3POhEWQStDfYBg3DmyES5kCuIHy5q8lGMSakJhlD84oRKuHe8Wz6x67VWuQd64lM3YA50LzSOKUa4Hzv/2N9WyM+1g7osi3HQ+06vQ9yrLwZwn2ZoYA+/N1RoIWEH2J2b7R6GBDCUbEgCsE7z6pOL6tS/83jIceD3XrZvZvrh4efk12oaTwxqnYx+m+/8J9hvCIc/nrFt2epeLyMPk2LeirtQ7pObtPTgVn+m4cA1xzKv8Zevc3WokUDP+2obkuPypqMWmo3RszAuX/ZysZtx5wxJdqjMkxWYuvbkdIuJR7jFBiMicKVUH+sbGZeeF2c1QDzwVWo8AaRqowwC80HTkxG6t8JT3OGrEk9ezAkKCAHWa3WQNGMlROZTMoPFVcn5uOmi+CLkmam8fwPKsJ0aCCmAF8Sc4L5NEY8JjrFT3s3IHVECiXBpMGJNNurSW1BYu5zmMmTp6JUqHuztnKvl61oDdGusbWarGMoGu+dzt/fBkzj6q7aVP67/9afIdKtJ4raVS/pfQzyGR6z8tuw+lZVkdeZPOoWuyrj9ta2AW3kMCLO8cvoOv6MEkc0vNz3XMpbm/bPxblVx/4OSOjZlQtoqn5uHQTeOEy/BfhFHeGmj/1/lHR0Ol7zAJukpmYF5qstbtAohpoljHjnS45R6jpdGVa7vUdINEHux3iLDm0U1F/LIe2fGz0Y1e4/Fpsa2lsGC89qVDNElkWVvhlSR/nsQGtGhBvFxCVWA8Xxo/uW5zn1srfLbZM6briA2wyEHGhXMkxaJNxkdLqV72CkfFj5DGOTefXw62SmyR4IJ+beK6UoWRjQtd720XVdSJycimGg4cLb/wxy+nSK5W7U97fmJMQHELdfAt14rtNomAxDXNqD5uyQaecpl4XSSSJj505v1LlO4iMMMQWDG6EyDVq2cJ3baVKbS3DOAhAVBuUhOTpiHuaTs2Y0+jVBHKtWwB8mzFeXvfUDK3zlX6DnqISriBVIx4C5OR6N0ZU6CWQc+AUksqqWImKNWLK+4ZQVVrnare0Ca30PZ7AWM5PvVURsyA572RJLoVi9adCZOD7+kIwcuOLPlWaL/+U24sJnC5owpUQxrHkris4bXSZMj9nvc/T3LZPTq2yjmcb24RnIh3+dzITprZOHMm0PrCFikAMom0dJwYgw/kzPt0fKuABob6eEhFG+I+2hOBG/VGghaOpPmiSbq/sDat/TYFSbCcM8KiJODfpifuE+GctjebnbydxfVB6HiW86mXYKPEs6uukO0qBBa/efqXlXkOWSzvQg1clmBulu8cDiCLHZu3rrwdyTL4L8vjTy0D5F/IS2PfANCBe9xE5OenMDoBSdMk5vb5+V9CUSEKTjsuXnKtkhdUk0uQqJs1W4CBieP/NUn2BfJN9OiU4bzSoEAvg2uNFu/yv/YCMaJbz1VvMFpPVcVlRZ0m3Rq85m2dxhDH+yjt5CJ6ZhS2VZudKF9T17SFwQECIIHEqjfT+DyBxS7IrE0k9hiWx7udSHGNTZJ33SDWfFMRoGAkOKbWvkxiJLnH28Lrl9HbpV3j90vpwdqR4tFUpuvoo0mIDIrVlRjWfA0U3StOqvliJDemu/8r2uxVIgBPmOrBvd80QdS5mMkqLfdzH7Nm22bX5xty9VHg//R6Q8kJ7LIsvP0U5Kspbxf9HV/6CBZD8aauy0Z4VmbTY9GoHS03vWDI6s4QvL7nTukaOCjM5Tv68MjmaOhh8BGt5Bs/D6DbeJkpY75OqepKRuMnjMR6JHz12xymjyzrweF3FvARbwzY8Wks21UXyY2n8XBFhEaYZ4Xh45H3iubHbq9RP32lBkrWi04OfTDz8SMrUH/GzDycyBoEZiwRTCrb4BAFWhgMd3JjqnJG0PhaGn4wSZsgsWl7huGdv/+LSBcUPz0vBFTFTdm3YfeMw5CjBGKTJyeHzC6WP12ilej6dnfaMzdCAQ8aRp+0fpaDF551aY5d78369MXihqtvUkFcZkzCdypInxtdGdo7vXAttg+EW3eEA4SyK2zT6ElZNjOgRi9HjHAwKykEqrYmJApP1kPV9IgklMEfuGXr51rKsP8q7T+gk/Ko5pZE6bVeIeNakbRcUkDQx+1/kFqn1/aB6Mmn0nC0EMv0UJzYgn7PYH6mPOETRMxkdKJrjG0fpJJyN26NcSiinq0qa8FkW6DX2mqqSi1DqecAevk01xRCSCKX7gdAJYMOCbsAzOwNy6k53zzhqlaNsVNmvYrT/YrwYwmYNyydpY3aI7HPrhF8QocBIU6JlTO47P7iV4jRRtCLb0hO1mmo2e/Vs9A8EkaE/m6iIur7sptuHqsHYeEx6HhgkKwuZYmIoiWhSNjy3oTQBR8bFzDnBglaKKSvEzTt0XrzIRR0WveGRmeHUsHlI1e5rBE10a7wyJhRuOJyxUOZvdbcT0XHevVisUEfgyYCPApsqLuLCGbBL4MCNdJ9n3xvlieKCsGHMMOo+qh3uBmjojpo3I4NGrBX8g5k2En9+GjmpXJvhWnmXNINhR9I7gYfHXRA0i4e2qEPxhMamIQ7L8j0nqUKpuJTx5eYqRbNa1iH7AlDFvKupsfQKCpH3fOyuVsFaoQ3PlQlFPXs4MhM5NkEg1O7sgd9aULv3wDSHe1EP4334tO7FrqoQXzNMBX3x8O/7lrTnLdPFVokyqC7S+MFAIo/rb5AjzRawWZbFNAimnqb51dcBnOku2Wpon1t+87BTMaYJJuLbswaoHl5CjqDgEYaPAtbg6B4EUf+peoU6ASO5+LFopE4k0GPfos6VENNwaGteuRl4PBvW1qa8J0PUAbEVHy539Xclwo0hZs9exwv17sIS7jQFHCWa5zhzTOKvojx3hsheZwOHvmfoVIUvJDEZpZZ+5CuxCnqY8wleg9bMKB5I/Z66MH1gz6ZHs9nYjQqRV57SzYBNl5/TI2dQjWJjj7yk2mfl6XJFNCM551pjGDF9dpAtfasvHXzk1wkdcBarb3jWGDpLh/f05m2fs42s92j1Vk6Hr71ev0qIB39D9AAJyxITMbdxPh13cPAf7DztZL5fc2/5mWp+Db+KxQ9xGNZ/hbFbl2eYuUhkwjEhslL7r90V9qqWb9UIOHKV+sdLrSUbIc+SNX7FhDMdUZkYl6MP8UyPcxaH9esDAWc0zgvrPErvQ3gNW6rxb9hSuVl4Vxb7qmoWVUhyMPpIB4HPfJI4D2AzD2nx8ZD62qlIp2T/SNYCaGnyIoAejzL0fNqmUax9d4HmKQSnn/p24fv8e8TgnDAkj0fPdz7nfUIHg/lLgWZBgAN/plILQsSgkqjBjzqW1gGftE9MSb6EJsmLT3YGE6eGdVaf7i7wGWDHsgOqSE3NSEH33yjjHbQRaDq87/wGkzvU9OYqoESk2cfcjtHAiXwluKrK1+LLIlwnXZKLTXc6IAUv8ov4Q1AtPiw2hHeRjbW/dZmaz5JeA8FY4dgQbYHJQKdoERs1kOGVVuTtmW1LKDb1lpJRaxQuf6IoebeKP8YOYv0XUBBKvQERqIFas1lUi7kKj3C7Az2L+4rJIW7EX0TLuVopxID2I8ELJHejl3pV7lYFRG2ig7dvI2DjoxUvPKsqjZy9fOV9MR4TA1Lk3ipP5XEF5sxTYgFf80gm/DHAflQoVNaSiGaFyQqRuCUmEarOYX6OxvQBR5by+Zq/fxKE/Mxvu6RyCo5TGK91V2FkbyCllzheBICfiXozI/CockAwQrF6ei1DAdhT0AtO6k2vKQi4KBBgu/JfFLDYTJ0wkbAYoge+2kgOvGHYTt3ow2s6uyz6DbGBgNLxziOJn1pjF3zjYF/oGw9j3vzcZBFXqfxeKzBKby/PsDgUA1EQHRBqBvRRB+/JU1HxNqIbucFILjqAOb89domb4bWfdvITD4lJnaUyVvczgoAJcdxrmoP7NI9N/uz5cyh335xv6poJOOPlF+wcBc39Zyr70UkF/GxUqXj1y64dQR+fKHPTPTTHZPY7U17o5czTWxkvM9uXqdh6k9fRxr5yKEj41UWAls8tXLL9pyy7ucoeitRIJmZcqMNMCH7ansqViRS8ldMEDLFupO4ra5mqteU58UsH/l3yihgT0QC6DNpx6NfwPxvTFF1ImdrrbPf5E83j9Q9K+45s3TvQqg7D1zdB4d+DSKO8SBpt3CVU3IjaaHLfGJPJHEgdo/Zn8w0z/idvnmC11f50n1Ut51TbsLDW3z4sXEmv5quMaU4jdR+neHqA8QqQ68OnajqDQdyzR4P93C6mnAvvfLqduRXTRKZIvq7p71kVOuvPrqVf0O8oG2eVIDikzVkmMUko0BQi/jv6vCX+GlJj03MpRhVavCWTzHmKWEoyHKNAQsWwhobaRz8x+JihyDTj8KBaOoroavzbA49/2N3J5rR4B43TbVGPcpU6APpfHN96LLqa/wywfkkJx0KHOm9mAcqZ8tz/tYlBUkwTV9fIajHDl3TSk1Vll7LWXpPvEjD6XjiSufnLCLk/PF1chal1CxZATv2aQ4iE/wm57ftqccK5dTl8houFlVu8ALt2Fj05lhb6//pVuSdO8LZTizwEgzYwenGY+NmIJUaRNXknseLP4TY1ip+ZB5JhvS4sZY+jk3+FQEUmCLqanJEoie3idWLkam5rB42+v9WbWSHTtmefcgo0NltKBOh5Vrc35LZ59Xcu9h3ik3Q31U2Uf4fBcRKoqezBlcJnM2a0HsWUfiGil4FkREr4XFlE5baMKngZj70ZAsxR4Sl3HHYyJw+SODeBf059W/RmMT/MA/M3kZj2DFVr4XorMoRPhWJ0zvg2GPGZF/De3TzPIujAeGMf5a5Pm2Ocqol/t29UzmzsxGTO3VYb5mQlkGaLQqp/nhQHz0rfDfFefrtrSY4Aw/sGR02tNadUEnBM5yxY2XR8yyz70k3JscP2mUzpMT6fKEdIyvf0/CafjvHA0k83tm3vnSHiNROdOoc6zOFG56L0ZQ4ZomYCJIeRqhQAhY5tEsjKOseY5WqzogsRSkH3lErMMISViI8a7ZDCwii0KSVSdAvNDMGbRE6XN+/qmmiQ+SBgOCcJUE16+g7gaINFk9eiCtuK3yaAThim+tEPLgMn96EIaBb5sxB0u3i0EVAygV5mMzqJKzyF6OJJVLE/4i+sXKqx4e3pqWPHMJ5NPcg5mPEV6Evye8mvt5TZImeNuolmDpEKXdkeppLIJ57we60OIRc8nozRs79ecsMqBoSwTjG9Q6mL6+2yhcJw1Rox0Wwedn9aUv57+swc8Ko3+Sy31u9eqpLMHRlrchHanok3Yb6l3h4iBaoyjhZFmfwtTRRIkfOcuo1f89Bk4wnhEyIGvqZHuDo55rlBZ9jhTTBuC1c8dg7phgx/4wom5b57Uy4iE0LKuneMMMc46HasfWniun48US6b0HCXgVkqBtlE7MS4WwWip0e+noVlkouP9StBe+f95ldvZ78y4Jb27P1fComzQVmrXWU6iRzo5n+yh96Csb7y+X53KukxohNpW8oWl/F5KCqXeJcK6kURGtJ3H3b+y9ajwbGsyRVtgEyVDU2MecIF8E+7FKYx36aK+nEFbgNu/QkJ9BrK498rDhtjzL/BNAvLqLp1wwOiGaYDmT1/UIVgbHUjlbW8LhyoCBUkqGkZtaqA1m0Y07F+yiaU2EOLT/+YAlH2o70r/KZ7Yqa00OtGUsMXx2+RFLd5JDAGvqPpE9k7I8n+gldTjK9ZSNC9lLuqtss+cQ2rawPkR0/8lAicUM3TN+T8+cnHLal6v4p62y1LClY9Ef/1RPWMKZt5Jfrw4OB4VOpZ4dcRAVPp9YJ90EVpE6ral8abRTYSQRLEv+1SXTd47cgzLbBXB1v74fMtkTvFQKvhNnzs1xRum39XeeeU5Vh7tnt2Z5HRtZhE7eQHDsr9nmnMui29negcEZo82+Mo3HM68a417IiWzmnix1lmJdhuaowcYFBPunmCtT+yAcWpgQJ2T4L/SPIqodKErPv+FgJP5sD92VfQNid6huPh7e84zD9oq5DQWQtK+vxqAs2FVmxtcOLaXfF7XdwF37Z0UoJZTDf4ZkKAPiNoWPNemvQCcBUHqLRSs8hKylRJwasdXqZEtWRCbzG7qfuBNgfIA8MDwWoVfha1nGt5AHcEMRLPJKWA8QnUEXLg5luIdY9lG7MZEvT0s6cvbozQ90+x276mP7DXv1iTscyTd0N1KauDA13SMbm+X+xdyI2dqt62cCODM1Y43ZMqhvG5G+GqCJk6e6rIYx1bj3NghFmfuLWKylMq2MCs87Ql6LIfHe5e6c+upjQ9X54GHsgJj6C4fQXcp9hq63CVlc9aPWh2vG03n4xZp6V/x3rpftmK60E0MSK2zh3ZHWV8/ZTYYSUZti9vZK5sribuYH8V5gJ7Qn+ksOaq4asRX3d/5lveCzv11qmdXv+xBG1Ui6vQiCVrxnoIfzXkHjsH4g77beFLixR/9WkEhvd40PK+XbaftZwx84RJ9XjcU+sMHTQF8UW6OO2PqD6qKauuuMytk7DY50eHA67Xlz7Qx0fkPrpLU5PNepzVZ3dKVuWZrAslQNvq5csD1RbcZpNx5XFTnPtoXZ7lKDsLH/uP4OFGBlnW+dY7ddzLITXYJcMEhvsCjdB52daVsTDMfVXwDiFLkTVwwcFUICSYmsixuLOnn7RUUt1K5gp9ig1qUqBFzaSkdFc+Fk8Eo2kZEw/45UZVlFkRWlggjlSADKLDQ+ZmW2MYbjtzRkTHcAkMEZvr2K6Q9tIwa4uQNhFlm/gwr6zKhNOEkwmTO6iu2EwZVOmFFa+fG3YiO0tJ1hDBcIoee+XSzeoMZgGZqoE4GYbYOoE3LYln/qP+Bq6GiNeU//pl55QsZJ6N3XqrwCW8i1x9FbICT1UKmdVGyHc20/zL4ZZ4QQcR63KDzCliZ08ney1de6qffXoUL4RA22GEVM2Tq3qudneWyZuvaR3/C7Kp1GaIAMXAM30O8XtYBur/im77n0c6yBevTnLZJtLRFIa7geH5DAWWT7JR9IgrAlXJYek5JaUqnYhxs3d/7K8JYXSXnD4Z6wXqtrZmYLUrB7SWt3nN0gydA75JjuvnwoA4lKDC3iXmpMrPSe8IL+WPuxeJuWA6gwZMqqEW/M78eOgOWtgEq9HEte9DRMT+Mw3XWwc/TBkFOBvaYx9GHIuv8GkEmsX7XVt+GsBE0AADks//PiAdg3ldjThG2sxoEgSw/4aKz8ZmJ7N7krmu6DJb5F73S0IHTMs7ZzjuIhS/VBSdWoZ+DIARW8Mt1XDrjNZIM2il0powtA0T1T5dQmF6vdEl6jhcmWePsvxootIq3kOcfBdVn2Rjbhkdxx01eGjhXbmpSQky0Vs0TVVATjrQmR2ahPmIGB6T0G5+Wl0t3m3ssVVdoc4StH/h+syZR2a2KipMH+Fn0meeDoWZNrujSLmFTnzGSlIBLK59pv55xa5RiCqhrx/PBgb3WomCBO/kcHU0mThnIOWyppmogw+wzyR6WNa+iiXNOx7ZhZXRmyOuKZ24V9nYa8m3lyuMoYmLfWWe0enFqrErrmq1IZNI1iLNY3SlA7KZJvSTVk+0AuipxQKjjumePy5410I/Rtb6oc6LyeC+6NJknoZF057X6Iu5D11B0xJh750LI5Xf7n3o7mxJHaSatCu4jNu+Uqj4TMu9ctL9qRnZ18GsJiuhVZweFGHZz0g1JOk82NFj899m55Lpsdb+bLd/oku6QpUiDxD5w8P96NxfEQ5nLmZVNcJuje5kCXlyPSQglLBfLK+2UndvZESAyfopHYNcmXf7+jVwqizXAgoHWwg5vZramIto2eTELNvGUHHZfHIcMXeRIWiUicpkev27v1ygPKIh98PF64MaWS5USBLc1/9D/GZI7AkV4r0IMAjUFGvs4K7Xt8uPfhyqi/LlFCGffnsZUaZm3FicaG2igQsYi6ZiwakZaPIkUD+akYwtIks7Tf4uo0ByVaApAeU9uI7tNWvEIKvSaNCQ0EI3CrAvUE+kdghw94eX6D84fWWE0H4YjiNtjLdLLqKne+Gz3vBbsRPUUTNDCoTj1F7CFHcrCXOhue7GFIXEnvhDqMdN3tdfaVDl//IERFHiVy7lsyz1o/dq1waNXKMynPzQsay+ROXrLZmeynmx4h3QYaUN03qF3oCnwhnU0Cq3lnKP+ltB/tnobYhq+VhmHSUqigIZQfIfGBSZqeZBySrMVjYe8YUwD8d7E3Tq2ehvn+IWYmSDRXs9GYdrUVs/TRd36t8pwMq2Tlgu3JnGMH/U4A30Fh4feyDGtNsleNeAJyRBCd0cHNpi+qQIdq+kItmLycrL94GMgNehV+OSMgOn+4AGqxd28jTfeRGFiXXLf8CJb/DzAKSYUBpQW4rae8nfRcGjzZonrxAR1QbBAY0FeqWLtSxGqzBZ5VVfCARovSIjeo+/F79Tzf8PGc1q4+GDviTgygjhr0Y5SXFlFNlZsazZarufoZrEdafwRTYNfz2FSi92F7SZqo0ZqxAXwB+h/0yOQRhvwvBhj0eLuZuEqAU6A/GuVllcY+Cm2dpVkJJcAPMHJ+gkFclZv82/uQTjYY6GdB2PEOSsJawjObilxY2mT4SRBxn900kugXlOJ/Ru4cG90qJaNnQ3J5SWUrq3o3ndqyfufUBmdts+3u3rHMQBvABfgh5k7bKBDSgqKqfG1avqYb8uDbp+U/kiahNohY6852HI7Eeyaixtn2VHV5ZYJtEA8kfalMNrdy+wFCBZxdDjUep7zeKryXBPDFZjGqPSQLSmROAGH2TWbKMAUKY4ofHEJSdYXMXGlyuO67+U2SSQGwO87Yk2J7cwdnkZOZ6JKLqVOKUEkYPF+CiY6xRxOl8uEtbjN+EvTjmRxhXjlb156BYr634fu+pepT1LrFzIIGcTY7Z1YK7wmldCFZhO2RSmxo47obifwGBPHyKqoKNDq9UWTt92FEkvg5rTyouPgLrWRqFXRWpFDgVa9o0Ue2KyGHQyK0XB9BCbj17pq2885GYDUud0NDBZU4WZdtZeUUiyRI1rBCRCQSfnLDYKMPZdN+efzi/F8F8ZTkZfmsSwKMJB4DWDkMdRdZz+lS5oO3P/M4S7JGya81dgp4UnnqDRWoCHqGvzFmKKBtprVqxFQ3rAx9zDtR6SMYrzFxjxw+FGC5SSXviYxctcyuAHl94AS2YjI+BC7slmEzxJfVJFkWlcf67J78T0LxGglgsVD6znZtZqO+9z39IFglWmCJuPammGFnNQjjh296Ed1YFvIEHJIWNLLw0XIOvDBQlgQtIot4UMNTMnbaPBDWOXqt0gCxE8M6i8oKiUw5hPTAMfhAIZjmAcXSYy6wFJzEhLprMDJ6LW1JItySHpbqZkstiZBtQHjaZazRt1Z0Rl4PCL8A723/9wrsQrl7aucmKP31XvKT+ZxiARpigxu0vLXpaMoaLlxoCnNay6yY8BJsCU0QfIkvUXi8THXt+SWb2D6sayYRReacq38cZcL9ODvjjjJsJG6q3Q1pGgG8OZGJGbd//cUaucrL97NsapldeLI5eomvghrVhnJC2uB6qy9W1Q1P0MPOQhWbR7k7VhC0uT/kEgRWXoAThbs9EYymgPvABeQQfvEWBaQnWtSIKTQe6TFLMCmKU3TrPEczk9dxJASGMcAKmt/JumJSeOYrCCp5jh/p/K0G30eng+2Vg+0naB6YeQpASXM0wJ6V5cHjAngUn66VdMKsA5qJO4g19I7nGo4k+1A78WAr4k1SpjMG5f0PmdLNXAoDIEek6+AabnH3OxwVpHeXoUYi0zZbbL22ogVZSVvqI5igOmNE17F6jxDW8nOrAOcRfySg0jL/NizaSF2onjmgXvfBDk8bYoEofj/gOTJNbtM+yBcqp8YwkiUyhI3gclUYzZ+DPEo9KlzN4Ig8UvQho5dDYDPEtF+0yIMs+YRnxkDoZuwh+joVQn1LOSW/VfxH+w7SbkBZNcENt+GhRIN9mpBguGlJ0Fu81Hm4Nu8GjqHARtihAF/qwtOhqtHWXzNZFMVwd2fJC4USulM1haRv8h/K0jgUg3OUz7wCjOkNt5NLmtMpflYqkPT+ELNHeO/N/CvbKQlWUGrmltuAvNlqc0H6Qz3L9V/GsfCTKScpeJ/bLPsR06VcnemrSAdIeI6wsORn7QCLhvb083maRCBit/f0znnMUtlgPHMClgtP26n4IWDi4SvF5QpPiWwIPJ8QvM9a4cB8czQ/LCGNk5lVTFq8bmadHO2vAYbJhNhFY9UvWRs2vKe6k+oJUW9S0EC9DqDHVoer1qMzIIydVfCjxE1b/guLQOWkug2Z2+Edj/L69w/lCS+NHnVcE4Q8vz0+iq+Ub5k62JVO3uaA7IlAeMfC7QnY9x4AZjeValq5avzHSds0plPZQpGwasjDULCinvY/FDBc22yQXMNLzgoNQHG915JeNR6hyw5W71/QL6jhRE1yQV5ZRJyA9oOrsXiKypZiFV+LuhcxiBNd0JgEe8JDtJsxqthbFCOxO27klhl33avGZn7zhhCY6mqVFQZe3YacjuC44Ro0jKSiu9wKLXYuyMxeOdQiFGwWcoKiiLi5kvKiyRZ5vNWp3oCGYsE6KpBvlFY7aS4HvgbTrLN5D9NBGilkfQTZMeRAXndiZk6DorxqgyHyjRyhNS/70hDcK+1dt6+26XCsFbcxT6V6xEunXGY75rahyJVk/xNlLijk+ZCfDSvFP3ba9zN67uwC6UM3nYY3d2M9+/NVBiNeIgH3hl3MIGP/Wq0VkCg1xmrjdfsrRp3b/lzkMSAENRcR+FkTf/LAzx2coBDGshmgzfG8VwQAO9suaLqzPV5tQ8sLaJbXMsN7Ympfu4FIE1PvycoEIKxn0VnuSoibw5fH7mE7rIP/w8/5a6QxfWNEXJ/17AgX+1lGIDuYRxPw7dNpnDFvSX3DOH9cl38qcZWfgE2m0W2L38hKqfVXh4AoB4qht/uakbIPcJNaBiDnkVkzXlI5AKBujGM2KVRlUAzloFwF3L0A257Qr7RBbeylFuu5KLFt9WppqboHF3Wm64sL2wQ9S7LqNgJxphkfjgmn+bWaCU/zibsJD2SH4BhwjlU8PTU2EHzL2fCgJRFhBUUuCPyjrROhSyMEtMh73Z4UZxdhkolsAXiCexFT4dIwy8MwBtTX8FTsGA2f4g6mwOHMR2PQxn9P3VKaa+ZFGgtsa88eRYW085I/JwFwTFJqE2z/VV7Lf/M5x7ubii2D/QMqgnXfNqmyRHvgAD57RmRNbv91PJe5LE6SEq2FAxSPDP6almKmsG3dCJHh4N+OoHZLGUQIAlmGmSbc0kytj7zOTDj+SEWqohVGOQexfXti7GHZhMeLFhLYW7d2eDrwOeZGl9KGoRh77UVfeW8jzRq7hlq9cT8c2WcbzNpQmxOE8ltW66pGl4t8L1YnijexdhmrbJlZI+w6YMC1GO4AJZV+mSZajKM8Bz5dqjfOUJENSF4NYGHdUkTKtJSfWORf54CRkGWZRk6nQklOsPV8JqspoZL1UwGbQMfgLG4y2fy8BR1gSW6J8Iv+9nyHv+TXLtTSqUISIDJMbsyrnmvrcrZPA1WJ7JgS8GqLPDIFfftwmzx/a5kmOd9seAz6oTbdebSO0kVV4aZLNmdY5sT4IgRe7mjzJcsJcKhnX/dP2P7AaI2i4ydDMRSTqPtwlFGXZrIV8q1c+xdMEYcP7YKrb3wSDB03ZzmJAX9X+xOwJuB+WXZf69qiWdlk3Ubf50ob8lgTVAZLb58r/y3HMErab7j2m2TZ9v0/7nSy/p1OnAnbqbu4wSjN+mZuuzLj5n+dlsIQLigb29x2i8sYhII7VNkcTViqWZ6aUEbvSm96wNAzygpYWAtGi6I7nXherpL19Tum8TU3azg+uRYNmh0o2FrUb4mwXrr6ejV4PNkMnOzTuPRgs5heC9q5NlJ9PtXCLPjOk021F/vjgDDuzUrx7Zgvy/9O8bt1Qx6MXJ+uu9jBOJykjrObtZap5Ih+DfsZE+fz9KGrWQG1s7dQ/1eEFeoBKOxsI1mCsd3LfmfJBCY3Dc23jqVBj/ZfuMUlBkv5F9iSelJfP5yXtSYkIB4r4CzxvnTq5NZOfJDdTmh1tslMMwxtaihV143mquVSRaONycZSv96t5pQqZucJyUt6etEOpumj+fhcjo6Xvl6j8+r8ohQDYwX7c6S7iX40MlJxbFhQzaI+oZL2r/Rd5VA6E6LM2yeGgR/+j2kWxmajwJQjVpT/vd5/5hyvunhuszbV46+qv9gebpKrk7RDOio58CCXz/vgFZGGL3PpO1zYeeJv0fzRTJp+K2UYmOkMthr+XbRdOYhHHxsKw5uvF+YCO13qzlPrEJlZXzfzGJw34hUWzNYP+i2SDRAdRQ3ZsT53Kh6oJOseiyt/wowsKfdtllkUqvKk/NVJbd1EoMrZXPoGeyalwugD+QpmVQFZQtk9BPgfXiUcEdsUEbK0UyIQquhKcOgxn5hwIyzIS2Z/se7sH+SEhfE46lrttPmqZjBaTx8p741YJ6F/3Zkz0sWA1cVifpgU8E2HfpLCSHqSrlmmCYA+YGt3W6Lr6T1pRwoGJgO7LGpcEAiQcY+4TnqPUajkXYKpDieIX9nHXCl2lBDWha9Og5Dge8v6MyegStohl01BY17H5H1gnwQA7Bwe6PTwPKaamQ9qGTqJay+/RDxvAQLE0JmAlcoPuf8YESmQXvVAi0h7tHpKDy8yabWJ0puOkMULOiU7yV9CS9wzXZOINXnR9zbgh7tGmbjQG2QCBjVYRhttzBbzUjSsEl4FN7gJz5dI3mDjV3cHzNpyJsXQjRnS7D0wSItypLjDRX+M0nNCj1DoqaDckPqKRrRWCA85XC/5siHvdtQ9oNNvV3HbRqiULqRooQZmSf5HR+8VkIgLBU0cnC+NrWwMp780ysEm4WdUeV6FV0KVGi7D4UdYIb+BzZWh1OoPCVVduYkAfFCmh3TOUJ1qcke5N4IsQ/YWsVaWH58L1L2q+EZIStnXb8Cy5Rxm/3e7RW0EkFyYEXmTU1QjyKumGziN7Csy/+7kaE7pCmAEo6UkGO4YYDyARHgb06mypZN5hxkwW0CjjVcen6zxrbNyGekGfOcXIqrWDRNingmhD9UFYYrNIbK2fgzzJJ5wRXu6z4y8EAvEsNdEgKpnZTEteRRsOuSw1OM0Pbw3u2vEhHBgfTp8EplCuLef3Ds/jD9J/Pe9UwRJ5IlX9kYDLKJc+j07IZx4xsCVSgQgbKURlLhxP8wBeS9woTBF1UPo7k0h9LjaeFn01B8BR85PJ2ccxKfARik+WUXlus+QMrlfca53p/wZ3nSbGeJ7UU62/R0PqTq2s6zspbGXZ82QQL5qQ1wpvG4xdTahmMxGSpw/EPtyWW5Tb+AvEkJc3Sax/e0NXYUShr557me4Z8CeOB/DT38LdRVriWjCdKd+H87sKiE9KsQoO+HBeMuD8QeH5Q4xMCbH3mHE9oG1oRHYZIbSHhAr1rrLjqh/sxeUH91Ge90VrIWA+b/utsDHfbYqe/29SijlFxRRa2bPd1S8xeJIsiYIpRS+eAVyKjniuoaI4Maw43Yk2ngZIQNw5VDBQcY7h+712Waj2NWHh9l+QvQKR1wx3VrOI5C83QcJ7eNLitocyKochPJ3VWIMW25AWCfItP5knJLRiMZmrFtVA3hxl9ficUm3kFF0l6UsvSz1g3zBUyjuHuwnkzBZVvaVHK+tJ6W6bcJPmuAs9ZAneHiSo8YALnpuPUuzmop0qIjEhsPc85CyrxkaGdT3eFudwlXM+ycywJ2YTXlvhxszw/q9qPPfHMxRUinuXlGx7JFSwXAAwhlqE9hXq92d1UbNuxJNyIn+TrtCfkBVTnBIsiZ+nl9RyCHSzCahOzxEFP/bMNAtytuIL6QTvczHf6oxs9xEDA3ZKHApfxIlYy7XocZAJtafCu0jBfyicQU18x3bq4TWKItZnJBZFU8bxDzndw+Z5NwHrmr9DlKRepiT95PR7zGfEeuFvGX7Uj0dcn1GD7AdX2GUWHkAw5XTzz20dTEvwNz2SGg5YZmSGA1pPxqiN0vubP6Z4Hr+QMmkmrYGjqJ6cVZ/1UXEP/8ehcKtQ0L8EWpENdZLBt19Mu8EBnTqZn/dQknMDQjX+aKUuO+KupoNfi8+UoC1cyiFUOanVHlNAoGbgbJ8v5fKeGdEOb+H49D/+JIGfbuNjFxdZ4IYF+1hCCxYdPg2sppccFMABqxCb9LdPwdlD5mTymnwCfaJe7E6E68il4rVgSxxxz1JM98btXPDraGrT4EDqXhgZT/b8prE4eOCrYb+kBJ8Z9Kj/BhmO/UN7x9j7vZSVO37IIYf5uDE5ucYI5dAbeqCo9jRvlF8t5m4gEnXEVu2s0yYUozLq3nnEoX2VVnsEzhPZEqVo3TD4/nk/OlS4u37aW1HHlbDTa3W7JEn4bLwv+mkPIm5WZf93JusCw56vih09ZP4Fqj2xjLh16odEPXrTZbia3mXM6yPIxemm8zovINkPdsxKErfGMEMqVG8YGG7VTrUdK0JZPYPZr/kLGlrP6hyz9tMYQ5H7eYzEqQsRqEnVY8BP5/sSsHgaTkeiGBA+3AXJ0iBMv5SInlRSfE+GppjCguqmCMbxfLrDWWYxUtaZ3Q+NkHfcnfWNZYV/GE4plgSeVDk6/fhjxFM9UItbuXJIfh4qw4B5g/h6RvIY4t3Nw8qn6tQXM0pefb1HAa9HlEooIfjuqcAYLyUUBEVmivDOjsB/mn5zEx+Ze2Z/tk/BirTRxT1v8xFpVutAs+Ew6yX6KmfbIVSn+M7Bnald4sDTDzbnDW8jKUVQBHHID5NbTd04heGEbJCIwU1S8mpYaCLcHfeFmbN+u5mO3ZVUMzk7coAybsmq+PjvuKKFyS3KkTuadQPusNVZEF4RFK7aH5wXoNS6wsUUYrDg07siPJB+PF5mY/Iug8VwLqgD/uJrxge0l6GvxKbiKGsRUz95/tH84HNOQGQKdAOvhbgnPTESrKG5YFlxO1gCjZEBmDzDSW1DPl6umoJSmmnHjIoMC9tnbUjEQJ52Lh2amPCiG1t19YZBhYUy8D8WY90bSyTWJlbJ6IM3twgzcsz5FHZqOIAJ2GRKynZ0dW7GL6p75bbieb+Vbc1UfIwvHt+gfEC4d36bUOEE7ZViwHnG9ziQ8795EEOdg8nPeDAOa5IA/dI9xYooUT17yMNvMoQqcoltle+Q/hGWAJV7TAa2nyMVnY0OWmy0d2uoAQVD1r9ztr6MNf9kwEqpy/s5hkfKZm5QYG8g2AgXB3LiGyNPdTXyorfYEUm/ltrqs4W65SnDrytsRV5I/pG4OdgCQg1mbNCSkpntS8VW6+gUPe8bGafnlXDayRyuzwwm68reaBZAkuW8HX4DxipyBjvAdtueh6elIA/fCKBbzIC+0xaO/lv2Rx/HVXxR3uYSultnerb7oUBuBL9ZqbxQjVo1Z3GG3MSvczw5G8QMri7P4RkSfvUf+Oyf3UjeVT7ToYxveDWWBanvLlbVRTYCwI70ohD5EjiacgAbc/vcoPfRPfiyGQIwG4x9Z8FInyzz0gj1K/AS+07zLMUJ1kehzPcFu4mjxSCp1uUAqLO58nxk8Wnb/D8aR93h8R9JGG2XeTp5twKVgNvthSy/67MGwflPr/Wy8JFvDKaCz8ok9A2uj6wfAD2Ev4wTmWFFn0VvQUH313CI4X4ayHGipOb5JnzWXwD2IMmdaWKQ9sl4vX/j9lCiB9l3W/HtR/rlCKASSeH8qOy6zhKEcXsV/PizbpuHJuvNi+DCjg8F9JTG7StJYUimYGVW789BaFRayFmBGt2S9UCtuYwdtJF0yBVhwYXwmOnmJGvueDmlOj1Lc7DNSQK6F++4Wq7IRBBhQlRtw1cuOaVj+WrsJRPk0M/7kkEhjDzc5MFqaq+W58tcoSqhl+nU5Tlrc0bVFG9qH8fOQ1hlc0rhUa80TcDE3s3/1csAtUJEIn10MardOFGAllilefHQzRnBSaglD6wZDGxwdExreH0FO1xMIKXM1jy2pOVyJkkbenVxVdSUi1WWYisRGQG71rABR+UPR053ul/eQK+RBiMAGPe1exX7r4w5k6/SDyd1Vz8JBYheRSK7azHYoKHrEuuOO+ddTWvmcfhUDtnXeXVlh2e2Hlc5xl9uwXwCDEuuWohW4iwmv/6GZQpuGif0lhBoyIS5em9EmEMGR4aYXcYoFOqnNRDItp8kDaXZr3iPM4iGO+iD8OsmRe5hc5Vhv/qjbr/7EJ7DLB1m2OvBaqh2LUzQKappuxsNF2aniCbOQs4AvS8CYKikfZ5ffOHg30+KcKEwQfehEA6scTGAa1KVWKR8phewd7esN9YSioarZ0eY9EDfdFGBz5dkkDebpDOS6PI2zXAz4/gg1Lc7zPYPd84IC5j7LsWLjvWORb3Vq1L+QfL2xI305P5IVj6yF7Xt55GTiFrEJd8OGqVY4HeZImzWMEJdLOonWriQfkWOEl2tHhFlNmEKUUPDM9evD38T/hQP2feEbr4rbgcam2aWtZMK4sLtZNDK88nOuSmmT8TkkHP8EzQS8OO/RLkQ7Y+YMB06KhfxC+jaWKVNHoHP7TjoALoA8aO5+2jAL+Vv5QNODsbuWIZZHc9zmjqN/9gTHiNRef7FBmHzICYBvkx4w6OgTGcVdgyDK9D98A6I4S0+2VAzS3O5vPV6Koa22vRnkbwn19uSId6Tqk4ELPW/h3icb+vujMGJqYZ4CbFiv/eqWTC4ZilPBPc3dJMZmAXIuQNtwJzsKUos5CDYlzksqqUi5GJGuAugyN2st30UFCXu6zcdR0SP1+Cwa2/ywlyzdRjfYWQdY4XDenVpLDIZxWuaRSgwyhOl9wm3zT8EBqWXDrvzMLIDHNQnEB27YLbDFRmxOgaqbpt0aOpcZiNe43qz2ivNsXkr1mNmt4MnCkW3nbU+WkobnVsk5ZwF2dStUHWqCNINLhFzXALnfzArjzhN8rDKsXmxHlyWYxu9bIdTFuF8ASI1m2MB9m3v5vmYgK73xipQyfkhvVGBVhw9T9PKrR4ZuvXmlM0vs+9YzoLH6Pz7HnTb+vezRwdYhZIGB5T2CR2Ca0fxypvalcpofp6Gc5eP3HnG6E3kc2RWPQPMGQqQlE+6dwRwkaNovWuscZs6qdQnemM3AC8r1oDZkYG+ww1iyWKiqhtSFCrfLUkuvw7H7l0CJFRV5XCsYd+ikHMcLSEcHDylL2BdPQSCrr/B1HpK0ay4CQ5cyYWaDnWn9HvLrb2qVcSidILiSWV+cJqCUE7ZK6bA/1TMwutuY53taE5EUoRWHUDextJbuO/cEnLMTsBaHVUHnxxeBRTNo1714lCRuB5lTOyUk4sDIa+DTECoR1T5JixtNceiSjQStBbJZ0MhUpZR86ReNmmIdgXo1LTZpGOgeLypvujzfer/kux/trTKOBusbHZaJlI7HNVALxq/6K9vscRECJxTJYfhXG/tp4F2Iea7VFt4NT0J3ATca7jMKcN1lC6TKTqRfG5r6AJa8lPPPPAQtOO6Og18uqg6PifMapwtDNR9+F2LDEiXp2PNQzwNNWephOhi6Biok3aF52r6T2LjfG4izWNuqVq26e4raNu0oW7SxfgW3EsO0OwTxp4+Dw9hahjSHTpDXhfM4pAsSScpoyR6FYw534IBtKV2+IAC17rNtayoI9FbtNH9kbnlHuruYqTNkP3Z69gr0CXZv82C/LbymdsJILWUsowlFQxlqcHMB1urbgSpvSt4VtDoD6kIoea/xdj7R6wKgW5Do9GlDguWF+GW0Z+4+6Cx9segiNGYNgRn8aLR7SQuRxsmVDV9NE6NREV6t2gRyPQ81s6f+moBT8nFY3bfN/or3s9NRcCpFtUIkEzvIKILvTxg1wydZb4MUzzaZLmXW2MPYQgwIqXm0PQTOI+tuItKrA11cu+Y62XiYfqlzKuqssEAogn8ieTuYAO0+tahStjPL10Yz59zbrcet7AuhQXuNoFHEAFZ5yA7FmB1nJG896HWLCJb6ZeEHmSzR55kdm7xe8uD2TV2B5RltKyiJ0v5zY3bT6Nkml+aOzBPiOtRqMFP26UqblljfOzGo6Qq4+Saq6iZcxRhSVwMstQhivf28Gc5/tDHPeH9ciqlgVeApaCrGtUlcj9jvwi0Il7l7OEnVR9n9ryD/iy9QAAyWGGsoNCNwGNAfvrewJf6IdbeIS/B/zb/Bj6bxw/BK27DGQtqN5ZmkG/ji2v3kudRhs5GMUg/TPotZN+75Guv4YSkhupzgK3WsG88bOEkQ9wtwwA5vFkQSVE0vXb4xw8o/e0qwJn1Eh1T7keJ+UIUKWRmWXE/w/epDppUGTQVWdAf6uqGMQ8Q8+rA7M5wLx9VLH1TockNGGEJMVwiXy6wb3Dh+QWT0ozZbuGv3PuXWxZ3bwHKXP0VepwOKoNtGpqpMtOLDSuiN/uBr8+ozPpUb8HjNA7TObzQeldSBs95sNc1JoMsxy2gsbRVn41ujcX5JCPJCtdccxpHi6HG4US2Q7zQ+CkSeQlPGHXnwBzrfEivJieH4ClYemWaA0QCOj6r/9wUrEXkzXhc+GAUkvEjUpelIuA9iVzo1DCxQMQz8P428k3/4JWq++rizDdy9yjWwfFSa9JItSXMwdbaPS09H5IRHbvlxanCB/xWxhfq8jP8p9Fm53KlnORHl4PSHNr4YKPO1TgI/VzFfcQrXsLS/yxHXj9PaGNgsnUyX2RakCMyRK4lPPqeI0nVG2JfkG+ZnO9YvrzSArgtIoxHm/JJBFo+2fJt7NC+xILlOil0+kjEKlVPWVZt+iDfLYLv2EXcvxKrnoPT6A1vyXHuN9zvdQirU7LxmNh8qXJWAqK/SzjIB8DWluYS4nIzxmBxNRzJl9AJRfCAXIETq3p7NZDHh7SIuX6UXhPMIysnaNs7yEUSVLV5MVBNzfhTHgz/3QEgTxTS/eDKsW/fXR1QwWFVtHQ3lWqhWSHdd/ZQBagHavSGd6XNZHQEmpBxzBKFwyl3PM//ILuZAavX/iVx7KmGeShDcxv5nslX4Uf1OH71+g6bHGb3BykNDMeML/dzMaNUbYJYNpU4OIYG/zULz3ex6zYqP4oTKWTb6wPMvxixEELxhfdCNQ6w19NKBxL2yYuokt8GB/Kq/23xoNjNCiUtpl4Kz8+tzo/bqxqqwQyvJ3LZyzfM6fcsxeu9OU/R/A6UraLco0KAL6ZOyGaYZGC9R+GKZuTyxJgb/RpnM3rgoupdR2xAdHowyA2BhlgwhBZUz8JDVmcAEoYSCVHgm+nP4lV9Z2HcbvXx48uPua/7dRkETQR/S9F7hHicVVoOgFCl2FXKTsZ4hilDhLNoxxZZx/jZY66whEbd5aMiZZDiIb8e2SPM0/ILTPWo58Albmfcs7ncStmhP1P77/AHCAo8V3OmHfPj9OhMhDhJXLZWu17zIwa6kYJ+91maTF3UCOR1Z7lJ9Mb5OhjmjMsnaQibu6sRWnJmpAzDTCV2fJpr+OnEWPrEUnW9BuoOzUmf1Fl2EuB7jkWMBgT0bFyVMMNMk3vFTmlttcfrAP++dxjBXfJHBflU+RFbgkZCPFXaumiq6z6jYVw6HQoCQfvbeuKMtpQutQA9x3UafeREOtf/ouNyDSooFfJOSuaiH3mtuDi5Hne0rSnLvKZ/doz7lgg5F0UrXKy+oLSnSjzrVAL6wCpJG7PLAZGIV2LtjQllPaFbGFSMvfFlmpRqE+gsq2im14h0hIFOlmwPHrtVs4AjMUCt2cH8OwghJ1yrjb7C4Z5gIhWqIWGXBlqEJlauhi+TQosFsOUgJM3nzUL0X1aXollc+h+3FehJh3BWaAe+NOuCJm1umv/XrESdn9CKpXhm+oDV/1EGPlxH1HFoooQJYD6eZ0zCX79eZhfBr2FPzHbJBSyPfAtY4Yeyy2Q6QOSfUjgk7TLCcnTcn6ciJ/tpLh1RQC6SToIXkEGJlf5jjZoOSLBeVCf8GbkXP8uo/Bwkit1Mj+CDx4MuERsCQVicf9yGI3+THy2FQv11j4NVgOdEfD2tthXiZMvvvHd2Z0fWdQOPwH5qjBFL5mMGJI4MbYf1QEK23nebe+7y0aatWl6ftZ3sy9DKDz0CtCzV9VqQc8QICQ6a2tAgaryIQAAcp14bI2/g5PyubHOM3a5ozMOIGfV1DIlf3A5QsdRXWEmbLbr8W1/7CoCSzG8C414iW1qNDTQd0C9cZ+Md2vh6pHRs9iAaP+gvgcY37Edd1Le/CVYzq2YI9sFQ2m+ngMMBcHlrkGEwU4Y5joUPfaogQ6uKIKYGSDWBORl8OrDz9jPPH4Aj05oJQJbMxj62EXufiNMVhWMsiugF86lhVnbKYveslEc6sC3RRTx2zTMoIjqWQ81IbnxADDWQ6/y6IvE6lRBTsL0vl2D+Rz+uJBpCKyg4xdxSKo9/BmQ7FV+rSZtEs0FZ7Ecsjhydxw3n+6erteW34u2NHZr/Mjl4bGLnAyMTkRuBxPocoq3aC3ntX6qZU3qHUVf4DoizP0dkjw/CWQ8T4JyIlUa6zkR4PLBN6PNf23xA+8H0misaIuLKy6xWJJYqw4kDl3Hv7gth4Xnvr4x7FqYAisa/7TFE4esY7zkf5VSNBng57BRvzxESYutU/PRle4RbmWd5jtus7j6N2te7aDyMsifpQKEerlKIiDz1Pf0yWt5vFf4F8FjYmbUR2gx0Tdz0898NkCyFH/iPcLBTO7q2XGcTVV2Wem0DSGmwysNLhRqNFGymqhUC8Q0ieExUfTAiW/XdJ0upCNAgfwtpKHRz3kXe/kOJbzqgN6Xdr0TcCA0uKqa4ho9rTUcpNkkVZCrV1UUJy4Edm6zlx1dFKfN5Qy5gPlHhxuTDrmR1SweEVQKR721OBwAp8Ox/5dEG0Uqb87V42UwUvszDoHZe9+bgK7DiG8a+ia7ZOhAEFOufYJniAls+oDWRZBWAUKJ4EKZWU07fKnjXhY5ln1ORoh+bbMErIH4Jrb2AQ4yYdL7qX5Vopq0KNMYWYEiCTPf6QMQmg9kXE4TS8WzPiwC3hNxTMbgRWYZEZA0c9KzaXekI74Qp7KbLzR+jIjVH/yJOYOFV4wr7lMewM0RWuJez6ZFw93qMgZtaYsNylvmsf67/YecovoVnYTOie5YFCLHHSPmzHA7g1yzjhF9xKjkCbfD216baX9yAu+NL+1Fa4YOdoAj1fAoSFEuJamB2M8XjSMHyB4L+1/GUN74e8J9x2bNjOecLg+qt4H3hw2RbSSJVroDvSVWNcTKctb6x+LzRhkgV3znXWdg2ufGU8CUMdM7IVjHLgEFzQJAnfuMIfVAiqmTQGq+fu9lLKd9qy2GGeTxs8FZQwBZYLZC9i3mRzZRX4+0uDw0p/TUvmhFk7o8/FE0J905TsBhfQELsCLWdJz7ZXqAwiEKm1L9Y5gqhDSmZgAv45n2NrdW5ZiCEa6F+6xXxAwpQGbjggCLcSuJ1RCT/WbF//VXy7vbir9tfDxeyhQiPxFT+3L5/X3I5JON7UcXfP0WJTLOhMCvQvjKl1JTA+Li66dh9Uut6zhSad8WvUJWOD2HlWVd6/307sQ67XFcI9zp5zxP9TN1b4VFOCZ+yS8gvyuhHBVEvdWGWs00hjFy0iBVOB9ILY7DnktFbknDkKzg1eMt3N9E08F3I9fW8vRPtb9Pl8yzo+NPUd/gJDjrFnlaCpLGoYrE/yW6qtOPlqGPLaxvelHYPnJgVBj2u6Uiz4f/plj5ELtWdoyl1Fb7u336X2spd1j+fZh2dd+g4xD/kCaihC4V3taXRde6NfeTVFHgQcQfvKC6pQRY7LDK0jeYe/D9kx8hFXlPeVfo0OOz4YoLs22ha8IQmMhqaxt38UNa/tmCNux5e9/jAPX+5K11sg0Qi+4/AkLjxS3OAqwBVO1aQxIG6Z3KuDRCGzXRuIaAhr2YrOSSlxObkMrDmNcjZGhMtfnWtZ1mRCu6IYibGMLCQvTB682IS08Q49FvswOrajOy36bbPQzcmKCjUg4lFzk7teE2Owh9dd8GgjBGM07FI9nqC6aU/1M/AwQqmz+8g9JpTWiD3tbNMp+PBe7zkwPbHvLPVbCLHRb6126gBoB7mocVTgBL9PUkpDtQZ4AOE86bZF8NUSCTIuBBGr0fkgMe5m4gmucvTHZJO/1beCp+XRV1un54XgnDZCH6iyYMs0NmBeN/eqcSFx9RMXQk9ArfmuVGyHwhzmKHqFbJ7g4Z0nnkk8N8hTgGn407BuH2RvCfWn07h2r1hmochGR4yGJkygCE9WeO6+fgEQuVUUs6uxkwNlzkdgzQ9jzMgDtrC/tDQFhEleq0cCBq6Cojv5g902mO+D5sF+D/ftb+aV4ZPlM7B6dSX6oRjmQqHOzEgdyq3glOm5WluUf1YJ4GJtb+rpIG3VHzPrCc6yfrYjlQbBy8bUidl0KI8MrT/QIulE1pVUjHVRRrvKkvSVmM+TTvZ/YGPK/5YWdYGVdvCgTv4Yde7GISuccUtPUUCvo9NELhR7q4ZvBIeiXL4eSoGT2yllDUu9yXmv9qosk15dmO1gsNSHHMEpFiMnikQ4DHngbMuS0GObH5eMYarJH+F+/GgYQ10wegpK6/g/yDUvNbPWCo2UygN9K9UeBmq8GP99l0UGqTJZBYU4EZCPEd7kjZD41xRcoGUiDymJekzX7Y+pHs5NwXNae87PkP9n2xYVD3onPXxe8vuH3rMfp1yXkEAERMtZ1xkAU4iwMFAp9KlDDSX3Fkon7BBFhASme+OicF7mjeHKN0an/Lm/OZJ79S9735Y053qQMvnMhPowWe84n5EdZsCnsremumgQnEnGWXXlJ5+y8gEGWIx65RXQTcTiRsLCLhjTH9LC3EZ+0Ul4ucqAJhgFLrSRpP4PP+TwE8J1P4qzxEAMHqyzed2Ip5D+ZyWbgpH7GDr8TIEWxfwjzJ56xVE1ykTW/osKn1IdglTNFG8kA0n6xo2NIsvAF7zyS4ic6pAYjISVJe3qFCm0i9noOdFIXaZIeMLkfoTnzvhOqy1HxQDdU+EbPFV4qi+JfDI3X/yMWjblAD5ewCNWztNEtATLXYzsyaCMaANYzpnmCo+M2dlwDY0/tZzZX5pVlTrAObCrL3dE1r2ktuDAhwu91rZhlfpUa22hZfXD5M1XAu/woUmFIP6YTUWfpngz02Amuo5JSQxT0lT+/HDvnNNe2f07nbNR7IcZ9zNfN8MngjSMGq8PyhQMEsoL7tfN1duNgA8Xf/R4CrObvSqKJKARdTC751DAU+yo7YlO4OryTZ5+jkBYC4WwjWy6jhNI+A4Lh2UjDnBwoZ+v0zl2Jd/KxoXoXo8zXMatfOlQcRZBsLT7dRYMlm6UfcxF7OBSWblt+LRbHl4DiZEO8VRvO/5oSwMiJk8lWuMvFzCmWYxWoMeoqVBURQCqv2QNjMjmIX8LpRR1u+M63+xR3LVOZyGIoAhuG9dTzwmOHDd2dyGfaOm2ZBbGdN+T1ILn3A2Hc8HpygXtzhlIK+wgqonLPMvqs/24NKFVathfblk729cx9FgabPvphRtml0NqaTuRWxTC/QnYnQwa74eed5eEK2RVwcVmyviX91V+A8Cn/9fPoa9Q0eDlfksfRD93HMA6a5RT1cvs8KqjpCWFd0j8CfkeU/47QGgyGSx4f1YhVM8xm+M2gl9qMW1V8EwBJciar2Gqud6ZRTr1pN6atj3ZU1UJY60UGLKeeJanVPTbGAliNH1byvktU6ksW2GXCXH1wJFLUZzvaXDwZvaVPtvCLwHjWz2nD7ZbpN8+DXrAi6KeolMI4yINvWP+aX+d+u4Bk0NhIVjtGAZeoGB6cCUu5eGYMcSmV4Cy0RGm4PUWhyBm65OjX56SqxV0ZWmeVYJUQOKsuCKvoBIS2M6kGaoS/l7blK6vP2hLSNkHG91lGYroQNP7Q/kCZ3IQFpLUnC98LimKvL6WmgJPig573pD1VDZm3l65Sqr18C89cLf6e4A1OVc51ycBcpmnhju0tenWLNq0vQB3Kwg6nFxAZa85a2N9wE+5VbBgZLNax7rpzZplIfQ7Vjs6ue9PxsnV9JlFPREtRYkAVxfpT17o1zI1hD+l+9fuDuWtVoGPZkM819ahRrlOhhO77U14QUEMBQ1QHgegGMjaNKXmmxf8drUGuptv6QcoVAB0CtKVVhbvcJkCMdClGYLQa6FncLFpFL3/ovvDN0EKH4ihz6kxd7uiyMZssC4Rrx2dgF3DDJ/lSTs2lWCLd3D8EBr0c18Va3azo9cY2i9+JOblOLG2Qwa9681j5V5083Nid4nW546Nz73fTR3DC+zQPOYGQ+JwyTjHqHh332W0BQ3X+eiQ6jclb9oGXXT0lNpbNvoVjxoc47ipuEdia1mAM2QFefFGz0bLwJcnlPdySB9g+6jotL6bUBdUXA2fdLLg+IJPFJf/8mPfY4Qed+bRDD5QcDlPRh++vUOi8/OxxeB54PmNXfBrPrRau8l8EWLR1z1qA6/mBR0LFNrNKZ49Vr90U/W+KzmLf0Uii4HIOhZsmFLH5JT7s/VPGhYhhsevVhtE2ZHfHcS5UfXWEOmCYbsdjmu9uqqQGhC8NcMlum6aevhU9KVCv/Ph7rr1Ibh09TV75YWUnf962XJZ6QgYEyxPXS0r61B8NJPdNh7/CCyC5CQP0NbzeDdjdm6H/5fgyun23WRjvO4mi5TPUsK/17FuuMZATzxpGiWcskm5iNTB7x4ldE8oqMn9HQ6oUcWx5Wgdee8eiaHVctHiMU0iWtrNkLa4S9P7KjERjg3kWc4kBG5UwTvgEMjyv6lx7Gi3gOBHJ+JoyhnnAG7BbcpSIzzV2OpyAa40K6MXYpMYUUBPqNnjcM3yJTuUYrQcri/rTURL/uPL4mOGsG1Qc252MPESCJqa3MLSdhNlnKs+GGTb8x/SX3s+ir5QRcVxu/lDmyX2hZiO/Z+5c+DwlwtZ/TnJoHP0sdpmRRPK53alDUHYhhqryRkd312UTNKZcT35b3BX+KCqH/7A2/G7CxpOpHMwPsRjCsEYBZantXFTmY+unyQHuTZ/26vyatkewYT6kHIDZvrRuzVPh51BU1nyESAZEocihTmkz2MHinuOlDtCLasCuYzDkJqY3atqnjvAdiyZPwihY8IBAuhEnqSyulnsQM2fWxH7+BnDxA1wFKbkznXKrgkhVgA+hEVmevqbuU58UVWL+rDcdKxLJVStEypmqDgs8RM1vVXMLir6MbzgWHfXfZ3hnAfct46JlRCzNOiyv9Y1Wl0896sE/IyZSO5k4ObaSP9E/XSz/AF6NSs3vZaig15iQajyHCvg2vnCdbw3SU+HqIM/YHBRgAtAytSItfAL4FcF5mhX7NdEIV7YwYF/KSYa0OFoSOvrzhEwc3mYeyUk3VJockZBYhK9UyheGdJJyeSbQZiDdOIUvAS87AGaXyqDvVXOr526GVz0HUJ/2BwBuCBlXOhiU0+vhKe2Eq32hNZod6kZ6iHy8nX7CN9jTBsh5OH/2fNhk+px1prMT/M9MfnA7sv3H7xVJ973S1E6dpeWLiUonmDfN82roRjEag6yL2yew/y2e0jiVEGL2aYVzf+x+yt2Znt4+8PkSpCtpzjZU1Ze3KqPeTsOJ5wcFTKLaigOLHofehLOf58aHFvGbKU4V0E36H/CZHDtHb8wZ/zBFBcduJzrW+C7nTKkWdJAzo+XeskjejlPPzQrDS06krQLxlYhCLxdzgwQW20JRC3dGWsADXo/2likZ6hKfmquV4IDsknGWFYnF3Lsdo1fzuG4ivj0T2eEX4ql0TtH48+0xMiZHUKB7nNB4oo9+ZtZ+O4FjWg+VR797hX3Ty2M2E28EXPDK8V85nrjU1vwCZIr8Tuxq7dTx8z2z28sLsFimmImJNESFD0WjP+oiW0X1z0/fCkdKOxIvBVZ8MzDH53npDVXtetdaPAd9LfSxqA/Xxs0RF450rx3kxCVeeDUMhvsz4ib90Jh5Cq9SHXqgQ9+YtUejRliblWGD2QpYDGeWTJnGtPErPSsbhi+LE8jRComPVKHcrbsRUKOylIr4Ym/kk4RcZbolrMxQOobZZCKpa2e0t2sLiWN841kqLr+Qfkqgkdgn20WRPeKnflRvz+o4VV6FgYLUOg31ZeEbWXz0NYJRs982EjluFrnJxsv3RwLPUHXQYi5bUIHjxlhLQZHlAU96YOTGmVgiMZTKXfsDS6I8NtrekKRCU9vfNPje7MzyElUWn7lNH6WU82uP9Qj/4wxlC/lOBHiBEVHdWl6JdxtUfz+gszXPCVuLZMqaptsqEL+tfPSMrkWBJy5aWXf7/GO56wtWoQH0lsOY00pBIXH7HlewU4ZUOFfVTAwbHyjDxgpoiINbdtLwdmntqJJQg57+3yORh4U4ink5K1SXsLxYaL8w/23WnZ1Qhi3vlD/yJXEjXHBSXraGcDM33OSMexgV72HdNe246H4RmQDxtCbga1397sUEcdd96OLZM3hdkFll1Y6rSVH+l1u/jhmeVbABCXRAO5/JD5BnFtd1SfD//1o0ivtDEq6U3ZCzyCUHYD1IP1e01mmq4QoFTKHleNgPKG7PoIqrE1WjPhOe+ednCj3X679lEHRsTGh+d9BB5SLYfmfPXQvQ1MMYJGhw+4zIo+frdrZol9faxXfCsSN/nojKO0LgVRvmBOVKrekFlH+PLiXAYIPourhCRFSTrZLlJ0MNtErvM9czskrVl61eHXT8JhrJXuGqSG2QXWYmclwhC9/OKH+LC8rDGbQCrOmBD62X0IkdQae4uPYuH8o0+l/Se06v90uGG0o+p+KvUNL/UWMopnacEO1jeTyuy06FNzFNmHUoztrb10hlYip+EM6XNHDirppM+tp32JgFeW5zwmlqZw8yVD/am9wGkIbR3oGEyVsrFdtwL0anioidwuRRmEnuOicFbztoCfZiQYth1x6NGeXmwL+tAvkymrIH1AqzLOFZI/U4nyeUGZzhBg278k/1ps8cz4BAo8Q+T7teUnuPhRi+jwAD0tkXmuV8hKQlRCFB9YUUKGhDuuX96LZgbyqT1V10bWBww9FVC7vqK/tTrEz3KbijKaj+AWozl3Gna9wv+y8BL+OGzT5+8nLTXLTkMCi0xwymmhuqKfu6WCtiEaHhcUAAZf1LPuTHHvH8ryB2EilS0gd24NLkHAxNrspQj84GrvTvi9zL0qTSpDuz2q+DKQ4QzNhL64XhoA6o+oUaWpNVx+ItlPejepJ0h4lbISJQ8vS+P2clVGJHdBzMjx0a8Smf3bJCVjuaBZHZf1vqxZ93khnMMIbweexDfxZDMGm/BQsjJJNxdnK844sy9Wf9vHCp/oNncDGtotPXULwVZbHKR4tTUIfD15L5Hp7LAGmzxIujUnpXs0tnjRFEK4UkIJtWsBbwe1CN8dvpbCmYXuT0QdZTdwT7Y4Tl10oLi0m+e7JTWaEkiardVHtNKnd3jWIrj3Jj9cSIZyfEXn/AMOglO6vyQVWRNL23EDk8Pi6qQD8FBJx3AqvXl8QSIFesa3U3RXK+rmqufcRXMwtQBa0/oZArO/tf5KSp2k637ee0MpbF4XHtIo8OSwl62ZP9ODWdZZrGWUxwuutBpkJ60B/3mBrY7Ef+/k451S5i/nV97k1Ad3chm0p/54oP14KGh9i4iFn77J7QU57CdfvfiN7dxkpkVuXky6413009C5NI3yPvSmHBIiyPe9lvF7OkTOG8ae8Pu7rZsAHvzYp3hAOnhnzxE7v6t+OARPyDHqFDhWxpc951Wtd+0zgLYnMPTJ/Szc5OrAiTSt+J2STq1SOOw2AHrgp4GWvHDEv8h4qGKK49/kyXLM22BWB0aS+kTiUQw3aYXdihPzlADYi1LUvgKx1OXtWpoPT1aPlhyjsQ3WS44AB/BghVTfDbA0ZAZNqXg/GwaZzWRUY9TwTyxdOvnq2lxEIdBynKzuG2ne82PiGvhWOeKNgnC+5Ndrtjo23yApQR0x1uGd70DZiP6kdNrvbqf48t4H7RM13zhz1GP5Ewpfd7lskyYTRO9PWFFlh87WZZXjJaiQQrmELYJyREbJoLqApHgFCbynpQtYwt1W2M47YLoghYSBeejRfCYaJgbEjpFH85AAwP+NTbp8JIvUnXdjDkNw+zx0BY3KmO0TF7o+GXiOWw2LUCtI4QQrKmvZh0I5naPd05gqvwC4JZ1ShWC1aolo8q9CNU75Dw2TFmectl+DVkn4gKL7PV7xop7krMf68KEGUTF12XG+M4o+soDwB7zXesSXe0hHEWNTsMvRZTdYgsZF8oTkiaEZhFwK114nL5Hm9VZ2vUZKhze/aOdApd/tsi8ebhrRVYF9PMZGcnhTiXLceuQN1paIGLrddNKLeywDxfn93WbscpN8B7UzuHCONoaRO7UALC6/hsnjTfdQYpZRZ1ZB/dmROSzEa5sfHgblW+O/sMba87FDSgVsq55ZHcYabHbN9kk6pPpmkQy0sB1A8CrSTv5re6hyA0H5OzYYu2CSX4mN7zgWuMzOozfdYiTTH/kZNJPL1BIw4IGNUIVOAS61QwUdviOVoGLfbnqpmRLCde5IuUW1xHra9cxtOqdbpNF/dihFPdLSRJMKu/bXolDs44dgri/7oojfRMioxWeoVtTtx320qIs+aKfzvN8zZW3xePsetBf0rTevY6lBY5PS5JyBDDa3oPIT7psOJmXn5RtPIxgZFdcqN6IZ1s8T/LIlp+fxV0GDo+bF/UBdtqgmRHw3hIAujG5d3w4jVf4HWcppPjUixp2tqSFLMM2AyzAUJNEDgZHXinIJs0laTUGIsVl9ZAeMFImigZTz8J7rxlH025NGItn8YQxcwrmQ3EHTBsHax86B/mCx+2NIT0hVMAFS2fhmS7uBQz9MhN1GF51uuST9WplwheMG2To3u6u6Nrv3PWK+KK8z32OCdc+pD0Neqv1awiCzDOEUN+BIYIRcc2rIGLdvLnQ3UGG8Sui/5llYOygbN982nozRVSQtegzx/yCaommbL2hSS3ovD1bhDtRK/YTGTpjX6P+x/S+NmGi6XTu28R+VSkJAbQpfAG6ZBWFHsJ2lrGCdubI8vlP0tZn39CleR7L4x13n2979JZYdHHPbDhBNWc7Mv1B+xIAPJ5yl+Ch+7e8kCA8WsKkfbmV5n87G/8kGDm2F23JORkLwsYbPPgUvzSpQd/JLW+77rEIxj2bjs1awl3P0Im5YTqDFg/CEwFTZH2BjvGeBX7wKdo0tye19l/sI5SsX7k4RXT+g+Mv8Gqnq8sB9HzSOHAgyuLOZ4SiUWRozhLy+AQ8ng8iL+FK3taTF+XoIiAv+yj59bz7La7TLR4JuCJTycF6M+Og6+3WyCdL3TOVBudrSgzk6CSohPW3Dh0iOs8hTojJLjNq6IxNXroNmDl5y5cu3UpLH0fZiEw39k4xe/lkVdLMPnDCsB6P25xdIes5dmkvQ4Wp4T9waIY79RkZH0EWholq3MgPk10YbG97MHYhzQjHKdJS3zWMvAM/hcRfWKq05KL3e2dwUVL3NjHMw9GCIJCtrkeRwgVStMeCfbxrYJYcu/S9fvhTTSywDXTZR3VEzM4fYQQLHW5KEaYLudZ0Pr2fo+yKgOTXI6+h2wnpqo+7wzloE//yB7JX7yCjwRJRHAbxsNo66+pnPPSx1WmCs2cR7HYpzqMCl7xtz8ahtt3d4ej9UvvikXgGcd2LvvHFcd3Z34BJO6nO38IdFMTeG5kkiYuF972ejzH2msfcWyQH0u1y6BdjNlZEY395Oz2BYzmOwQNhqz2BgKBiEdELXrFHyTkMuA4ABsS8crzVH5BRZwj1DZfNoPaD6heXZZza7h74zBRxaP34DHw5w5BPFQaMWbisBiQmAPAnQk2sosMIYOdhXMVoZqMtYut5zSkPzirVSGMA8ix+byP7Ijl3R0rVMQK2Bv/AMV5S1STh7BsjmBoiwaXlInxGuONVAsXSQhAMUJrD7QH3PkvHu3tUefXN8/goXg3nC9uD+tQbI8WbowX7IYgl8/fHZXxHjm8xu4QmY12Ffn/CX8HUHRkzATUjw1JHQo0CHWXMlZpjafXP8hZwz+No6Cb3E0BPidBKODsuumElUHVrx/XujDc+VAKjjQDz/1BQtBFRe8I/GL2bR3BU30Qq/jr3vpdkLPliLxAsDlzau54suLXjWNwzZ68mwAmL8M+X2AlnloB2ZR7DCx5p0Frg0q05jzKiNBNupxhePhbntG9fXvQHO3SAV9DHnoRNBau4Am7V3xhLq7AMdcVCvr3G1xTpbh09yYaye7mbHBDPkULxKYZbmMWX+mKZj0M4auUXQ6mSiqvBb8PtmlC6gCY/cAhu9MdPXs+MUArysQM+Zp2gXwJiYqXjvorhwBAChmILWJQXNBvgL6DQO7BmI6m1gYL+M9Mlq+M7PbmGwRGOpSs4ZErmN8fODxh8IE5Qm5QvetPgHpdiGvdl+5h8avJaZ5AVV4lzfa55cF8yBWrdxQmMaomshnZFhkFtVa6VVkw8lvKerP6Wfue/qiiFrXn6+2dQKd7Fdd+9ODnQcZNC/w1+nYFCRWyQrPeYFQQ/1Hoj5G5KNMvvCFvIytevi12Xb7ttZRtsQp74fTnZ+PCmdhN1UjANijcgTBplvbkanjzAmL04vdJB+Jr2ebvFclU5uFfM7xxTt5IsBcc//Il78L+BpgjAn/0LwG1i9G/u9Z0PoBchePyPTEbDT1GRqhDrTnz+sJkA1dYCD8AQmFmc5v8NdofWt2Cyf8uj7ircxvrzpzLnmlswP5nnC75+byJJTs7ZTQ4t3+zocOu0hUHM+KYbCnPGctNWWz2TX4j3737Ha1GzRA6WIg/7b4cB1/Hs1siDMCoZPQLfKtKt1JI5ixaCDRcjTPpPDEmcxXWUs5miosdk8T8gYBdZp1CTeyJ6JFzSDinXjuJoX8F6V0T9zoTSW3VWk08yn6Ry1tkUeGLB+faLwxWUkhrhuohWN/2qCBkBnW2FArJzjb4ob7A8mKylx7spMSJ1eM2qAVIRbrs23Hc/G3jzbPllVp1fvoEnqvTRe8gFUXUmE6ezfuo02lIqcfvEGcaofOuhBSDWexZgmVyGa4R27eMiW4kaOczUnQlktmaXJjNwAuLJvpVEllyqEeVgUsELwr8Kc6Byw60fAwSyw9iNj19PEunDN2ssEEXgyrddDSpaG6xtCr1t/7D3Jl54ZhrIf2eM7z+oRYOsM6sw6Ce0fuOpMYQ95QhG3t/OF8gVxgZNgFC4ky66M4B0w+IaAYmeUlsLZxKGmge3yOXnjDtMifGZy6AWCsHo9owsWDz5R/1a16FUX0YtNUYNjJWtH782QEUVhCNL/b+g3zTr+pwUhSjVtJL6nxNJ14kFVvcRIG/Hjoj8MvmCAW/N9Xse4vb9Go8B+5OLIcnZmzDx7OiGSLyD1TS7I/85IgzNErg3E5DpVxXedumhobQlZn4y403WYayLc+7f5KU7DlJNHxGZb7asYSS7XV/s101dBtIJqhvTk7cTToxVJ1+P9o9NdpLKYBfZ+xzUFL51RJrNxd/94HLa+DymlihCN62Nsc2YsVZFlQweWX2N+FdwXzI4A6Yu4+2amtObACMI4CFMlx+4N6co9UYnRyKjkcvN42TZ7Pt6wi8dstV+bd4wogG4eCc3aY4/lVOmxsoL4frRGnp6NlzEjtqugLz1h4IORbZR9r4DrIOCqYoB7LvQp5WP0LKe4Nb3PYBQ/favdlrpJSkE+XANrOSCL0CxGAL7J7cQMKZfcGneDrw6zCviIBwhU8APNtpQjUN2tWlNBan5i6ECZsayT44+ovgj9JTVHCeEsPon0morJyPaE45bJh/Mxb22FuZ1YIT3tximC0fUNaWIb8N6XIt3+3LEEUEhFZwLWCuBSfxV21VuKcv2aLUuCQr8m3LbqvHubLxe01SBmL/5FHia53RarxIDacbRshcIzQ9NvQJyepMzHxBakW6y4wu+cDw/qaxfk4n30t+IxjN2dEbNzFpzNWm7ClBGnhNE82GHVWUKJEXN5tM8j3ORcmADCcHkT+JgT96DoX+6+Q6L4+Ze1PbP9daYUMUBNFRbIE7NtPhS0lkcw5B2kmjwDsIa2HJvJNt+DDKfbv+r+VaB1WlW6If/k9HO+yZK11OIh4oVyRtU7TsVuv+CadBX0WvFkic5gRCpiSEQCSD6fWcbzbtPp/bYvI1w5FL6nYe+R54nVKazTDljVtDSN95iSgK9envPZ7rqFlxNbxIAk/FPUIo5noyKUzkdbXyiSopsMlEbhk4tcNACcVkczfmA3pjSG4s5diJ4TdNGTTii1MDVq7tdJIlghMizWs4HL9b3sW8N4UPmt/NxT+d0oDR9sw4KCDKdgwIMWwSCoqcv79W7nqYODl+2gmPS6mNWMDmuBqvmnaxGhfmBvMDIcPAvhQ9QshtGFRNQA+dCsJF7KKQmv5cGUxJR0lwJxq309rFEK59LoxSvXIr1IGWr4YibzqsXLx7RYtoD4DrtrZ8J7KoMPgIcQVU7s6NwDcu5XbE/xcPd4WKKnKQVVqEsWgkyn6ZrcxCIS3eXBMcYT9tAwRcJucY4qBnfYXsFBfDtQjyS/jukDoTVEhQ9ooNlKeDSSNOAHGykmOSVxVRv3yX9ofg/fXcZatKhwkg5ulK9o8+KXp48rWrZhIorQhiz2fxAmmbI8rPb5jwvq6P8dVU9vUSCZwgSNelKS2QzCjmMDJSPIM/y2thVMfA3rl+/s4iSLlRMsL/W+sZzxkMELav8DIJF0CvzNlLAduP2NHogQR+j4SDfcfkZIy480h9c/EXk6bqXoU28L0YdJQLUJ7kIJanAdlb40IuM0DV9uBDJOLCv0yIqZ7XNLkvicz5O4JD3RI0QBUXnoTpFUHktQyB6gt56HuzAWl51msJqQM7+nluP5T2RkJShhW6wfsZ1fQky30tZljMufReQ23+xA+eCrqL0F8aNSVAjQWUW4VL+quz8DjOTLHPF615VtIQMInSbTGvhTejX/lFAaCv5qeeUCq1d4+pZUXqQYXdz5NF17GAdsmwypHItR3qcYIxL9bj9ERhQCRc99Ug0dkin2sHagelHi4aZvcoHfHFpoVK/pNhGS+9n6tWISJ1foV6wo8gzq0nR24kLz5UPLsHgG6I6Ih9hlgTz9z4PQEk1N03uH3ZVLmNchd5eXXniIXU/rQ88uz65ePU85wOSHKeTuTynGH/dgJZMiLUYHe6USXYAh2E/tQXQOW87KbGzTO/LGfr9UApDHR3wEQfqMM9wkfC0HEGsbJj6p8lVn0HPux7UUnRvS2U3H4tDHj3VG+cysvxi6TPOv2hs6JOVchBm1K8I1tAnIw0l5IzBa7D1j0aGaonlTafN8UMMy3aAASUG14/7QU/0KllT1/0YOv64QB0wHL7oQ84HNH5ab0Jp1a+iU/hbLTBUN37E7TUwgZBLCHCMbPTxw45hcw8cpGYRLS/x9VBTUlTNgnkSzg/NzNbmIUXcD2cWjMIxdY5FRAbij/Ccguo4oFclmJn+wK5HO5CLklZ/lqXclVlKZiMTXyoA2MSzYemRiignS3QAp3Q+KVUxHlC22fZvaAOV+ottZYuaRQ6z8YZOLy7oeFnnLqK4UYe1p2LsX7QZ8u3LSlmyZV6WtCKP3M0JlO5fzDbdsQwWhrvRJrgf4KjdBXT1ZiTL0il6BXBztTCstDZhDGUpEreZnFA8OgFXcnOG5KUcd6F+tdJS/HYLkiyVOwibBh1qv44VIKLt6+/Tx8fsdmI2BtgfA8CCZfOBVT4GAvD7McgANn4A6paYeei0oZDZxcLD/Vgw+gJCpjirqHzSgLWKrUKqQe7HTibrxdeamm4dKN/D2Nw/SWYBVqfXIie1zgYDkf3rtiZdWcZHpZ1i94PmnLUpiIvds7fpa4Bwl75MG4ZL+aXjQcdRDIlclSDdfil5goukCmWhUTq7b2O/2F+G8x7ZTHBymjF2nXfHgR2MuZDQtNZCMCvTVf0EBcNlXfLkrKABT0b4/B4hq32ubLdXmDL5S8ZU9n1o/sXFarUUgLifHvtW7sTt97zj+SH2iefY9tOGM2kX6fcY+lg/WRQFwuFE4BrK+gu6jVWL6fJGeNUyQOv5dNQkw1bUExQFnjYzta+1KR3IaK3FKJrqeetzB6NyuXGF38tcLQDC8J5HLRR5hNyYB7aWm72Ay/FwJDJXE5hUctGrsQJujrkFNm3wcPEKNLAgmZtzYSsBOLiR8BWBeqKSdoVurTMcuLtx10l+QjnlabBGMNw6YYKlL0B1GexAeWclwA+UYclG0tNhlztK4zbxNgq+WCrPJ2WOj/+wkukXDWqhJgE7lMIfQz8iYWFSKqm4otpJ2WlNsBuJgFX15RgbeHgTyQvHmd6c6kmJ3PF+9NVkn6Z0+J/0Qi7JI8gYZ3wCdCOuEIBTzEejEvn6FO4UjwEKjILMBiHhEIckNoTpQGpCb7kllKlRHc1x0RNNpm6qnf774L+fJgt7Hhp7f1gWfo9fDoRBTN1tPTrT5lSJNEHzCXRtvDlQbqWG5RCHB8KnRSomAAIJbL3yv2QySqUAnCvfu003mFNcQjA/fmG5j4J+Zz3W+aiQc2TUH9n1cBK/aeEDh+YXUQX+SOFvdyXXenny3QcMPxq77CdMLJnhCFEo9iIBHwXa+NS+sEdsQLpf8fJMCTPz0g9XExQ3yoIHE4zQ4GAWI+b8N4z2DTXeUAC2QRxx4gOibfd/nMYsf2m267nO9PdATCpDKER42RoSvYS5wv9vA1tFlpVXhaHqeCwLyeXe6pKjg8pFoulritREK4B2V5T5pFO4SI7jSahgJqwd20Fntz3lXGLC8zEz2tbaQGvhf8OGeIRmseaqEEKKn8WjNFHkMKvEit6rz6as+rR4VA+OZaoriD8gN/JmyOQdlnCw1sNscVm9KfkBN9MlR1qvvfeMdKs1x7JaWKgb3wz8STrsdszrTsUXJmBGza1nJgyJKyOm3stW7XnUX0rPuf3EYQcS8NRYKTpXc3kp6EGmnMeRBoCT//2ucsqDwxgn7c3DeVofCfognlKLq1OJhb2NANm6k4jm7r6DqKgM2B7GDe8CarltZDmnlQ2Sd40m6rkcV3jn3SdwzvZEFhDt6qp5D/I1qe+Nc4hC7fzBcGVTyz9l9NDY8Lr7fuln7TzgPMsPnWSLTGJWwyN32nWzJflgi00L3akX0o5OvRT8BLWo1jArbM5jGj0xsHhVWk46zfgR+y5aJkIeip+q9ZMEsHAVYGPdj683kKI8AoNtYldlaNbcS9DJzf343BNjcQNjLM9Vhfi8chLP8Pc9Wzx3LPOOdTsKrxw6/GG9FBPJWgIFlr1/SJnejG1yc2axhiYlrQDDXB5iF7qP/JLyBqiFn6FwHMZlHw7XDRbXyN6pxYD8GzRZcT8XwHIr4ac+D7Qv7UZzeeyP2GQHyTwwU80OaVLkfaJRLVIB8Xy5moLxXCDRevi/0/FmfA/qk/uyqa2Fh8qidLu1ZXBSGOadTe1wOKkmrpM6ZNcpyh7BwpKmwQc7FrQwWtY8W/oE8kiHlQSWsNZt06sVvUBZVkYZ9v+xV85QjB31IqGMMUGrgzOnCqVaYINCevfG6AU9UZjUHfTzhKf1mA0zqEcM5z9NUX51EvmmP1N1imAYgNRoW8E6QN4qMwdhNAg4G8C8Ily8XuvtHZ5DVOBTgQplMslxUlyEdeZpd+rJ3QO0PRC/1GBy0znqySgAYFe5v1WM7FuXG2p51q0ISgrK+WyfWAn/xdlR3mSoeBF/uHV073Ayf7/KcKXgIvSI+OKA8wiAHMA/gsuGHy+gGou1WSrP6z9TkFrOX4xDpITJbkC3iUd776ZeHBIpFAVL4S778rPPVau0WRmHZJSHEQU1UIcFQ0cECOE3zlRnPe5PaLw1PatzAQA++zQ/FoBYDuje4wtz1S9AFDeZZVzgCFSomZmsZPlT0/wsE4amU/lSCzKyFc8YAZ0+i7l+ApiMJMApI/phtu9G/Ww7iw/MpR+uQNpBHTqXxngcydxHSjQm526cN2AYtJ5V5JPpBTbh2IGhGXprSKa75ExLYEi5/whmXuzLNw6xT0rOVbKztAoxfMyo7PN0KEP/Yyiuih4VOwQpPjBo3ZJQqANQ4w0PWfA1UfRg8fyyG10QxVzO54i0fCpi8IQ26FoLap2UaJR4+Ipg+wx9WVmvmqYtBJwbLfsGWotvQDsP5l03oGhH6Wdgvoo6BaawkVUcEWjtUOsLQkliE7d2lnoP5AhLJivmfxssh/mRuSPUKZtQirOS5w5jbQH74JYKq88ZLG353KC1O+oCpSwq6FaEOVqiGyMU5KFg8ez0QJl1nuFDPGQTfGHnk4RosAc+Hmrbl8ugZsE2I4Y4SgYbFl+R5LMchv4SEPVf8SV8+tG4IqJUyIF6xHPT4OE50Ue+4xRxYg+JpOtsQJgqsBpEO3QTOvKxcwdE5AVhDql1mzz9KLyn/x9YFjACeOvMm+Z3/Mj1Bhw/x0l4FW8yKiUmLrrvp4rIWjjSKqSGvLNJZiOs0fNTn0VsmqZD2PRGIVogM2Vhb1QhNmeH8XzI9jIbkMUbqP4WkRN1vpZJHKiLk9F242Wasj7ihuUA8TrUiqjPihFYW4yscCP18V0qXmym6U0SLh+CjCHjsiTLs2+xqDAtN8MRyh5zMm+ZmwPKWeBvw+IuR7cYOUF+ESdfAflha0WWFxpwrS9hPVyArveEbcq8ockRsww2wG/3jMjESlHiDUxFgf4veOJguOJTtbqiCL1XX9bAcUg7x0esRa2PtoDQvax0Wf2QX7RVh741dB5Kek964jmdJBuruHejbUfzLJAl8FRVb/fuvzTX8yMp6xsfANCeyp2I0yhHgHhvp/a3wkQXCgKCjJsOTQhh9o9i+02Dd4JXcOz3fSkZAd0+03gvfxIaE3X7Vb4u2LvMmksbFCBWltI+y2KZrSx5krvBCPffTLIs1+2uwfHifk9yyNXA+ZR0YqgvETM8RxumOZzHwjJa8+LINWZs3jG2W5Rh+faCPxEyrMkgZJlfIqfgIVSSHdwjpCd8ovVWnswy3L5iJbXDrk2e85lnYXzBCJR2wF6fCLF/SsbLqRAcDe7GU0CROzj2z4KyAbVoz/dLkuNjAiIBW7qUOqUg0/x9hqEn0UyhgesdL9Pix8julYGRrEj3bi237fq4yCS3nU6wjQxKH/ctlcwO1gZIcly8E2NMae74yYssIsYUIJFV7pxWcrc62rCKvt8xntEoIPiOKytZIyYWUfW3wXOxoG0epDAapgXhjNfuSnRzbj5suVDSTmsIt0p6+fMZW/egTpe49jKnEbcwl1yR+HsZae/Kd3D2masItrxWdG0yfm9dGyL5uCpwHBIwm8foHxJDHGSoFVLd0xS3jr9jG/uVjHhtI5p3WDND+/yUuFgpqoSYJzf5jgKLt0qUTAA8sRTCs6g3fJAeRtYTcX8JzLymIydM3BJxa4fXpsaTIlj+D8ETa0vf9RmcdpcaoKVtW7SnoIKBVUXBd9WDn9FZAZXQvQprzz+7IUkPJYUu/bK2Q/Y8TEkJTcr9gKkN2A/J42pd+fwpJDmpyHfwfFy/K6yZSSall9FHYy1mN0X1RuoJTPI4X9sgeYDnwVxF86TNawA8kFwrGPzTBUMMxhEV+usdamBGGmVc3kIIH6qEcz01BhpYZ+DaKtnMeYOEfTNXPrKChJzYAJFgulCF0T/Is7OyElI3QUEN0jrDIb2qtlQHe0Drqwo+aQb+eqCeMkYSoDMJTI2gfY7GJBenLtL/To4DtYsKaJeU9OLnJ1lIeY6gRBpEs+EVJrtzVkRnjgqE/MlzsR1HLQ0aok4Im/7vpGw6UF+IbWorvMeJmMDuHhaVtPUXSLPWwt8VGxUCyI4LMYMj3JdyLolP5WJWKgOfpevUNsgXBhLRxY4NwZn+jvYfWsa1sXSE44nXTtc8L9VXsaZAPdO8VHXclrGROsfMNg9VWhKVsT+6hoFL2Pswac6o3xOl78Nxe56lDgsEsF7o5OmyXYkHteajlO79B6SUsF6rm0GLpNFsGmLUfmJsGJddKl4iTzXv57aRFxEOgEWIN/eTySojFwBmF9xlvtIgsnGvA4sniYk4VPkcLAY3BUh2TEnvwVp2m+yz7RtNZuLefFyIlHrz2655Ms51Pn+MOOoF8ac9Zqxicfk3FxFqwXe/7Ev/BSCapG0XAckmVF3NkrU4WKlnUGHWW6iUK0rukl1IHdNAmz/GhhH6mBIqoSFNGtV09Q0qdvWgAb0qoXJyavELMwwAvT1tN7nbTLvzwvczuMZjzGcHIB3ShRF5pTEeljWWx5C60ZBvliTuvlN7i4063uyThav45Z7/MKDew/OocJpm3V0pW2g5dYni2KkjrYUui2xw+MqDcuONn1WDFcRjzqvVr6hyjF3ciWdgx/PA6Q5a8F9iJ5UxiqRxD1wCphGYQtTOgvzZwBndXymLoUfG9wIlA9V9D1oA+QW5u1NWseYJRjVM+jCfxrygtugUo5W1uHQei1JV3waDqIUuThWSzIBCRcrTf6IhuVWl1Q+/rjHZdALc8kuqZRi1Km12YhMtMak/jF6dPYId2W2g3IPRT1eqZEcXNPmXLijQXjzlAk0nxlrj1KW4ZUmDylHo5NEVDPTz8MG+inHhw0BBN/A/tj6oqH5Z0s9WYtmmbpUY1hBUW54fS7OzjLizFXd59Eq8Na9Pbs4X62hJwkJcugsDPVdlHJtPC7nPGRbNOYLot/DKeWJ+Rz26KvPYLE+qAhSRoqLgUGGz3wJDpiWlNyKm6tfxo3vu0wxeU6Lck9WCbDXzL8lmp2GOGffVVfytyxuT5vNN3qYaWZuGJJUHRr/DBfHblvpQavJQTVY/hrXKXNmCIdP7ZZXSSeSqjmJIxDUx0CkbOaDPqDSkestysWHS3FvP8/V9KKsSb/100b0APcJTfS0aPYA+zxLtvC+PsS3u3C3DdswkqDAzcJOotw8Ji+Nxo5EQn56YM/h8pNI10Hm7xAsjPT8Ssr4RZreMObnWqmMUGOv1x1jAUiFgw+Dki0Uqwpzla7tVlAvFmDpEp+mm+H/tEYUGglDhguciXlnddzIO8KCDZsj5cXEafnPM6OaPqCXpABiIhfvIIO0TqX8+kTAALjNwQXDCq6Y/vhrv31dIlYdNP6CJRIlxhfGzBp88VuTF/V9UV0MJn8p8cp/bdx94a7BRMd2UPhzZLY9Bmbeztj2kuo2YDm9CmdSSLnHhsDqFaM7eT0UFwYYB0D3k5m6TIO8zHi+T4jkf6cmjR0/FHGExbixuo+0klesqKQt2C6c2siZvFHoRMPFid9cDu4PNLVTC7mQg2cKZlHJnQTKnOTxxxckjOanyLIb/jhCsY07mR4iPBRQ6bNeY65UiDrLYFdqgu5uw5MUxT2w0DGnbHejQxoWQmSVMwgChJoLczTHn+wVNY3/GHjl94xiBZAda0rl4oa+xA3X3ItLZQsVYGYTgJey7MwUcKJfDWiUafCQVPBIHleQbudrXH7OBwpjfTZJ31N+mJjYa71MMdYNCOyDULZ0zxuT8Z6sDipuLRlw9nrgtbUDRJYYS1blq7g7hb013cwvLl3N1U+D8R5h6x2OHBaXaC3mK4dNluZ0oymqEBtNrrGI/l2jEF/AhFyIk5I8gq0sV+aiYmPwN4DdXuQkozQg4zNXrGX8PonBzbydhJ2b9w16A6yNjnwGxuKnsRyhNiKLoHbz/AD0XsVPIosEZK3becxEA91LLZK8USm/YGS82REcfUeK37dPImUdhYGIbGb2Cd49ZGWAPxEIP8w3R11SUhtwZkPKiADk+ZsDvl3FcmRcn00Tn/AGF1inrr6ktVdR4dKD0bcQQUeN6LYQsMY+6lsZq3erEYDzJIYidgixtWd9RIPjzb5hpDbNxelBQDBpbz03PYp33tkvHj2Sxcl8RRocFt6A3ksJtu3P0gB2E4Z1I1jVkJIs4ltRp/kqRuEWLiDAcbOlkHgEtducU6b8ieuMeoQewGKvM441VIRazS0C8EFG2F6CYiUTKcEdKotSJQZ921fncnyYLEIa+yRmGagcAbwTEOtnRerG+TDPqDa17GLNGOk9JHBj+/3z/lbgfyyLQa+F8jQOnNkhGApcR+GaV8im0jFHCQ3ScPCHrAyeQzeCUc9TDFYo2vSlHRloRGBJKi+J87kySi5bJxwcR3v4JnJC0gTA5QwzzYAJbkeNFvGuNU3w1VH/ixTHlXMdQ8/oGcXXh+5TTvPkvk8N1ZOKYCH4T83JbF/Rgh9adG+fJzJzB9Lu+qjE68lTB53NHDX59vp4Vm3XCcAxOod4N0bj2pAb462LSLkOUMC2G7DZmurRS1NNZ1lT2xDedMGhoIdrMKIwo3HW7A6d76VLgsHjXqNCmfm0PVF6RjJcvQ6MY22z60EFw7S79swa+0Aie+k4p2YIl7HD7xZgRJs9QbMi+x8cABujcbul7hrEQCFfUAiTaS2BU2Z23hBINId1ZkRJK4p0wc0LTLoyLVnEr3mkWKdjYBOuqCtgECCBCYkPiPcqb0/AtYdsfpm44z3mcjQqhJ5lH5MGTcdNhDMzoNlWiAo/SH0UTkds8Ez42CKXEmi1I8RKlgaReFLtSYmef1rzaLjpQP5VavnTFIqjYhY9iQf+l+Gp3pvOg+gyF2h/2kQb2f10x3xldGPG+i9giCzgfpeVzBKqAW9KsNdAQP5nn0bZ3QVpvIudyxtc5LWQtbgVOMJzw52LwvZpWWi0ycEpsIFAn4xmnOZfIhYAlBw+94kK2PhGats8aljqmSuPy/y7jGI2ON86gAxpwTtCUoS+AwgtT84QUAM32gulXNP6FFH/O2wk882uDJgFVrxmGY08UR/nxOqh/myZgryvv09p8Ptma9jisxWEFFTwtmS4Eq93TZ4QVJM8W0EhcEYp+J31z3s8l4KZ0Vz8xYn/A9AU8IhzC8EUukiiEs9wzsRtrrWS9BVaCrchsRQxcmybNWLyfBEEuJGbGCdAKUGAfNxXiw6Zk1I0WgRH1/N85MLDu/aAEDOM+t6cbu9lg7vntLBKELaL5k/KZXmk/X0k1Jz9PHNhCjYAuQfX2NJFjfdv35KARWHrbmmuSH0xGhkfcWl8sDsAI0co9r9slh2s+ipwyJT0cbc0vix4vZjN9QDv1lwzHHSao0nQIymQqOScD8XJAU27CpJ0MT06jt7i9YaRhDCmlYQBjnWYutsHNOk2t3UWT/pRokTfDbvEEoRXxr4Vc8G+/gIHgwg2OlknUcHWUjUgBc5qqu5xbhaZ53BiML5wxZUG0cdxXzh4L6ZxoX2+K7cw5/wFAdLVD+tzHbbnSkmCZu9zuWrwStH/IK8D6hn1qxQpbDuFAZaie+Hzh7iVUpM3dE2QaQqHEuEx+ihXlA2kU4I7Z+FX90CSHdo6HX/mA4WT/72IXOjuT00kWkkLLjdHZYmxGgVFqzoH01iR/nNcGfxjjkZeq+8q//uxC7lFpiJnarW+FEtRBHlEWcqloTkiMyT1+ORdsoWlaa77/0XWs+r1fV/1vWCXNeVMcGIqU4LG3qWAA5rjxo08QIP2XDtSsPcNvhJpTDMnMjyCqzIF6QnLMwVJObWHpc61EQJKkNTLo5hCaD6qpCR3O7ulAhr0+E4+ojrgxi+WnuGqyWwFvH4Nw7x4Qk0Pk5edGP8V8UIGHQ+kyYxOjkuUwFhc9F3w+rJZJ8VOr+kcFhzBUvUDnEV2P7WpSFrXtg+12kG0kVyU29JFva5KonHNz2my/co47s/U0dx9Sr4HX/tt7RsBdZToBDG0WRU1Tcd7dG1uYmKfWSelSutJlllgikM9ufwwb+OrkZNA56EmQd9ZRdIYg24s8SKVRU9qE1EMHQjpJMwaMEtDRYs22f2huJl7R/TvFfD7b5gUFamMNyKKESsOiMuahzKLC/8L7r1NAAhxSUVLM0GuWPJRgbWm3zJdzVFk7RaMm5HS+zOjd+kdPCj5X6S6K8JVsXhnjy39TZRkyUybM+zD9evucgSpwgfMFq+igJQefZ9h/VcbY7OHEswIw9lnKO2PHiXa4vymiUlMDk3AOfR2yaw+1fV12lYZpYy2K38WixAw+Zp4iu4UVCUYfEfz3RWtf9OlKkW7llq5SHgEQ0dfdAeMiY17S8JHZYz59rg41q54VP7sELQpZ8cgPWHYfdE2z7Tv8SCminGgnHvoyhCIFTtiLWmcDVSJZ9IalwMLKNSzFecmk8DYo2z2Np/G6rssrKwt9tA2J+lZDIMdBvhmqvHWx4h1WEykYe4zsjVkNXIQHapCZbB0zgxhhWCLiLW3orpaqWJVP3emmupQk7TqZwdKRdSlwehC01AtbNYQj/gIz1RKZDJVCNLxv729NpfYnpSkJTinY+nNNJ2VEjG2YWGtFkzm1ZwFby9iiXdk+xurxn+7klQyQwxz/emiGZtyuL0Qw5hQNIKdLZ9qU7iF7Zb23XJ0QGxnZ0WBkI/n6ajxmanim7SOlhQuCRd2GC8dOFYghOHutJBlmie9LiNgPMxonBW47AFa7bFjCDjie80JeWilPGiWyHOaJ71Wv5ChR2vDK5BFQuR4jbNTzFlnkw6NLInfRFx3O0bZ4xONE+AYKKUcoMikX4jZAhUga8D9Cc2VhrbSL7U0Qo3TD9A4ItTd/BNGw7047LlH86AVwb0A5JenDkO+GMBBoXV4bXItLIrrtN0OZeWLhrH3eqXB28tbn+4Sj4mZ2ZSvMm8+uk9NsSGZ1sQGR5E5WsAq0922gVK0CtWnOO8nYh7RESRLiTtQM0Unf4E6DkKBifxlNn5RLBYkIEWnTl+P1FLCvRDkL0tELIc7vvsMhN2jqlg9FV5jN5bVa1lLmoT9NZwFXtewoFeyQ6a/a8ensV9sw5j1khUUm0usDceriLa6qmXpTSDp1OSBzXwNCO7HXFlVYeX8MRV2fj91UAbTHUsThC2++TagaGC+YA3svSYzkTOmsJ+Ugzjl+7HYs3D/vyOnpqI3qM/W38tV0W5/izxykP9fq+KEGxFvmNJkCPdOVn6cIKWkqlYBbnQ2Lsx0z+Tcpx7LadO7xtb+h9E5RShhz2Lbx/y6Fnhy/BKhGnzCvWzNhX0qwpMipAsZbqveJbUddWsJUogquikLUlPqWZbT95Qw1MKLJBDqrW4rEzrUsLJke/i+T8BgOEbFbawDw25KywfnW0zSsm56o+JAgQrrD20w0ywIc2nU63Pt2ggijKAJJDmZSnSXDPPQQZZlFDtOUwiK2EP0tLGbs9eFcoOgTl0g3MZ+yFtS6e5cPVzUMmhQ8QScLDQH32ely/J4sIHlH747v29sxCQCN6V3Nm7x+wtMih7ZRh3AfYUNrvL2Zf+OiH/1nQMwhVehYJKubeFZ69O2/2f2cPphcscBhOyArtzBrCxbnoUXoz9rk0BznynSoEseKOhnJsJhhhsZOmUV8Gtd9MNe74s+/x8hGFKp8aN4f0svIKHEfHhySlaFkmT8gq3YY+Iu6bY7DxUuRMFxjSr9vJC6Ttm2i1B5K68b8ANp67Aj2FocTJcSV+eRE6Fj111qj+9sAbRRyN2rQVwTEj5ZEM5IVxiFe3mwdNir6peVqBe8JwMBHt4h9zZnekdF/pcapdVUI0arTqGjyD9DOursaAqfrJjY0qeCIHfYkwKJNDcSi/55hQcqV6+q2AR2T5+r84xjd777PSCFQ8k0BKDOJRy59fxu6eqVIkADBWCXepk9SL0UJP7AKdqA0vFKiTPE2gr8+PrdLKaUcbZ+QefLjfhdHURo4xBxwap+9Mjbm+xFMqTlesSkazSJ9xm0C2c4e6t8+rzHCgN0QmJfqzuwpgJ6TWnnFo5Pu6EPj3NfV5a2BopEvnpTzVYGap4nMTNWAvgsyDzSXQIs+DdwqdD+trVY8PKe8g3xaDLF5SA+tcDXzOWP89l0Fg7CLHBY0o+1FPJpWSriHLfRgWtgqeyB7Mp4v9fdORl6zH75CzZDcQa5Bod8gvmZb63FJXMEhvJp+OP2onNONW3ilkr56WYzgmHaT4tsIqWpVgs/Pl0GjlcZ/LrlTkRrCc2/NposZOsMTR7yxT3W055BOc0IKfUbBiIOpOzjOyQBEN/IMaQX+z1LImTfQlAsZe7o3ibH9Z7NxVFVjCzOC83TIG3ZPVZcJConxxKSvvJvT6DNVN7lj2WnJx9tHGJn+76FjPDBWUyinmNpNZM5mtM2DzqRq3uq0X1xJhTFFxCFkP9VLbMYIh1NUj5S9tLAmpNKUHp/R+FQj1lgqkQUmj/C8BPZ1Ie4zjrKp2StzudAeGqgecISb/UtXNrlvim2/7is3a3yve+I7V9pHCVvwaVgBVaaj7+kR/s+GZKOfKSYuBn80qQDhKBw0MXSaD/WFXiYJOVJhBrFgNKOT/pDz3Es23LqWKOrEfyqA38yzlZk/RDk8MrVPS8idtswbAa/mjrMEV/e8AmU2uTbDhjquTOxNBHEJ8jYlhvh7xcOzuY8gpWSEK/hg+1QS2GQiye0yZQrG9t09vhRASeceebs3b/UldVYbAtsIG0LQKamaJVJP/rZMWRNxFKdGjEwNBen7J/xCOHjwOsFksf/KLHo1ruECf0rRGA80/ik1l1w5VTFrp6862zfgDNtvroSAY061cFhRN5AhMStFbmF/xuC0x5Qx02YDUnRz2fzmhOwwb70cdiXo1XSyALplQ7p73CJqzvR2+nv+GhPU3JT/CjREKnEl0SIyK1T/z9b5MwqFTCrbvxFCEHywbXBmBHedpUq6jABshPysbvOn0vAdgugjE/mvvJwwewbAuwe/wZzcUxEuRuGiEYwgmsIMA+2RW6vb00UJRnu4NRHw9oYutF4oFgpFfG6ZlR4zMLTVoTUa7X7MJu/GlFk7N5LqJeKZ4u+Y0J0laUwceV0f3QUAvpA4ojsyr/LXwUI3qDV71UGf8oiPOVK6Nv7oom0XhQfHVFx6I6zivKXc4heu4K4ks8WbD+Wpvd+FJQS8NvaaNp2QSmUT9wy4AX3ZKo0wTJpk4kokdiv8Sitl0whnM6SNXNdEXJ2Wk5cCKUD5DKLHLXAVlMsArpS2RtIvgG20xq+cc34PQy74J3u+LhLS7sJhfpyGRxTnxH8j3cJYs9uc/Fwqo8+f7eur6a7qWt4iJYGI3FTIVDHeF/W2M7f914gP/g3YjoHE+1cQu45adgjQI8m/yC1zTOKADj5yCAR52jrRGMMbnamTD9OFQ1aGYfStFHaUF8Yi24+WPLODVRS1uqPlAZHCG00H9BfTFqADBZ14zxCJEjOj9mEgL/5D6jEqVEejPZJ2cGSkuNg2N6YY+KIaq9Y5Mac9yQEzEy+vBK6GokpVslA1USoTpZasZ7DdUzJ9BjERL0AgbyQ+IiWVbvmDUCSXUWJz4rnHvNbdRY2oIYldC+xu3Pe6pNyGBsHeTAUQVEbX9ve5ivyO15rCOFrhDzZHq8Xwm4/jkz/UYVcMrNDyQ3GVkAadjUkH2643mtJperT5IDgBfb0SHu4Yk9Mp1xICa/eNw0mXjZkutM1Mswjhl8aFCscvjR9aVAAtR9XWs0NZMwRZjxF2GcNZmAE4d7Gn7c8v8lmBjWCPs3cyImi7+AmUkmMhLYFuRjxjG9/1K86cNxo7uuN34oIkY+A4zkKg8ZmsOZF43IgrcyO9/R75z2YAfvk7oxmo5bQVHy7MfxpKq6jMZpvukOSoDGECKBKp8tiGM5DyV2NsQYi+qUq99WC3ceYRyuJFzbz3z3IqbKs6lBvnm1Cdxqkc4srjvyckrop2V/Pf0qtdnpOe+4zZ0H9iB7UrEFvDjj7pNZXh+JH0f6MOVkXxZdMyvcb6ZO47rYNJKDyDGMv8GvLaGsKGT+ruOb1rW9A+yVbl+D8K+3zE44yHIX+w5oyl05X30sCQjdC58jvh+98sMPJvTLEpSwlt9MzZxXJuwJ6rpngka06jO3g5lmFimnbyC7ZgrQup6Cb5V9porc0/cYzVeicFAEYmoh6+UJMQDbG4Orzvzup56pIis9qojhHR+jOhnRjZcqkVD4ctOvS5fnDBTyMkD4ntte4bi07fXoixGDdqH2PctHKkutvX7cVMPs1olJgXrAcqmc13EhLh9JvH81GKYkLLdX8VLRiaWXyrQ9dtNyHyZOzA8fWqcpGltCnPzOjNQVTGvreN3bbgj2UToHrIvd582EAaCaE36t1K014+sfZDmq8rpwpr4KRbVZRUOwIjsCHFbmSZGKkmJisaBc9FI3m1k3R6LrkUz+7hkwcjnepm1EtdsJy1A7Lway5uVbgOimk4/cRx1VI49dwBIbvHYmsvm1uhzU/ymC5e+orSnvyBpZNv3KWZnHT0uN3z9qiG4DIUQQgL2IhIHauHYsgTTSsnquQZhBawobXgzpTktVvq9OKzKIWYhR4q2czZVJ8FXQRlVD3C9HUeQKLgDOvucVfAR2xoOHRgvpqdBfYcVbvSFJD/lkzXC0+Um5gq+Yh0YBW/QkRV2zuZUx08I2DVkjLJtU0nGI6rNAbeIKZBahkOkj6GcmD2WXw34/P+SfVqwuW6UbM24i5UpNvqMzGjZn6vdbdCNjdN85Au6feG3ca1bYxXUG1NPI7LcRBESKLlQj+yh1riMaOYcOoTHFgwlEDaOMHrtJULl+219ah8kSuk4pir7Tgd8sVxNFj9OZFRMgVHnRvyNClAyww4TxV3Aqkdy2baiiigAEunugTd3exLSlx8lq5ZF7a+FyHiSKl9d96vpQmMtuFaVexyB4+47m2n9l5G+p6ZsXjv4Xhl4BgKG1uJamipF0NYM5Z0JzYpIT0OINnPoFp61V+z3e+zCmD4X8b9v71EQyQYrpG0zJd4AwwaG+NKAI2nm0cd1Zo3pdHQbSuRaGgsUErnLAoXgGLPHN8rTq0qaTToTEhTCbNZF3RNR/pEbOGDBr+rdManMriIAPg1d/uTZkYF1StwSgfqDIAWNYqYarGrLdIdJ1QhttApzzoUPiPpLib5kHsmAGOupoi3RD1VG4An24FfEEVl5UjaQGKVNGEb5JbLZDyIk3OpOjgi07/dTN0/6sYuVGe2At4lCslPJCLsNrufbQGFMoZL6wuc/tYbsaRN4EVfZNB9tvMGa/XkufmxmL606SYvhMhg18RNMnZIAthqB55yx10k3hXLmRaNqQ7jcnOJ6JOlwbLnb5PBVnUnq5AUpXqEK4P2rnEWI68JI14//ecufzA2mY3fkW2awGyJgOlH1OCVyiUVwsqWQdDDtoNvcv0RTiTdwvAVrSgDOWkruI7HDoa79cuLVrWfojMbEzbKM18rHjINaO2V1jx01g4A8c5jhX8kToC9UT9Fvrc37dpwAeA+MxTx5gMLwlT1iIh/kS/IishN7hotRC7o7wi+U6LI4EAaHJABWU5kRnDJOGteqnMstRxfoKgTh6gb++wKu+lc3Yhihhg00whKFqNdk0ZkS415EU7iVVJd2WB8lcHWD6dIW10hy+zWFkxzrBZzjN6Am1IYkxjdhc5q8rGeLXkzKen1yvN9OMlvZnsQWn23XCBirVJZeYftocnWvHYXL2oDoxIYIlcvc7a6JwcwhN+kGNnGgcdT/SwNQ7xbblcFEY29BqT1fw/fpabZ5DulYZMOoqzbrcMD11ctviVQI2WIirKQlba4TIF9j+4k4JjfxI0FI6powEVf0y6IfT+xpkiPdczkYIM73CtxefWsZ1ssSbEwKlxWT/wqVR2203VV7zCo6u1iOBmraLd7JN4SC4TLEnMYynzTnj+8DsyWHNazw+b9bbZPmJFy+9rj7WXV8A4r7XE/7LXG9f76/gvq06ZPKESPIPylxZRAwj3Ls1jqKNEtUGj8k7nVZ+nT2zF1miOFNS9Cmu4Fp8GpnuajCNlXIoGkRJfn+/zTJTUAzJHJ9HW25E00zCkteE+pe6wlkfUg6RPPbW10+zP8Moo34qau738495cs9VY5zMq6MfK2/qEbH0GlFox4x4q4kYarEzwWXm0mLDquhZjDAURk4v8U/q5MSw7jOxkHavmKkEvg3GyNZ9YoPuEUZ/y0gNty92wDP6c+jyl4bz1wbpFcAAzXreM3Z1DuMx3Oofv5tY3eo0RSfch23JeYEz8mZ0PZHntn/wJH8+NSpd6cUhNtO/n+1Y+uDq9SfruGsYqdXFrWLvh4M/GlHw+1jC3IsQF3TFEibSwzetrl+piegNE97QWHXHL3jSNt5+2VkBjT1X9SbizUybMzhQ+VsQfaBhaH06PGuei1SANQnFauiWA7M1gFya7OLXfOz+VFEGXfSFURC3E2Ud/ZBjlAUQytqVYfFVTlDirlxmeZXc0D8Q6T2PBVa5G24KNoeP9naouHw+LROhEmhouUGt184m3OfSscbWA6g7YDRwF8ixAlkaVjQH1/nZp9kLjfS6L9H83sB02WModt6vWr322RWAu7vRCn+dmC7g4FkmALpI5DtsE/H6eVJR1lsT6WDTN4GlgJIta1MoRjnVtfOzVKgBL9SlYe7pGB51Tgmf/k+JXZqiUUQM7HJ1hbnihmDxgbOoIyT/8Y0JgcKBp8FbFG3XQIjJN/Vh4bIGOIbmtZsaDfkBcE1psm39o+HR07NbPnHHvuVHACMlrz8TNJpdOx20IIGWoTMV2j1nCftufJ/ztFO1mXNVOu6CAGNUzVGlDHvu0Hwop+rzMN5BlETgvq9AQ9g7RlW83s3lvvgjxlXb2PP1BVMnsPOBIKMdN6Sr9HS91Aouh+wuA9gCwmqIOI5FZjvW9LGSIjo+R0Vqk34QVHWqZGLtEVPjGNpOORs9f5Devt+Nm0SFY/TxjHO5AclPjfJoFSwHNqo5eazBMcLzhVWWb8nTRhgCu0RV/Kh21fe+h6zz3A6WtKlyiRg10+dSFIMup+DXkreA4kr9fZJ5+DPQNKQLCL60Zqw62s1UXDGSy27KB0VnbLIxW4D6VNihT4UnG6XAeiOjyfu4ENh3qJ3Z69XjiEi8BjyJHyyzHWHbH7F4cnHVHmkUYI77R8zNiXCyRimxQNlc8ehSIzgJcnk8n2kjn2L5t+GL6E/RGsAfk05vYXL/884/Id4TFjZoOeL+mcnpNvU077eUF/92xspxSj+8Ck/9AHGHiNFxPGtlJrkySq/fZcoY5oa5/+Bbr22A0DDUJGmCtLW/L4D7HT4BkiP28t/aaXOXc05bT601Ry9+dGdNNo8YkGMfffU8qbrkJRN8Qrt4+j+QA8jHNJd3xxGd0puQlFbOyr6/b5zdVTDFFF2ChFQVsOzqR2rovJBJNcKw2DT87vSE23Tc7MtZEOM2uWfrSqha90lNE1KcQ1eAu9mlpcPvPOt9Am8No82qO6CUr5OmqnRWdyG9eG8aP4d0g81nTrJg9L+XI1jnUOE5WBhxpIEh1j+N5+CcXmgDN/XNsvu9gYrtLoYbV7Gokdknpgd5PYb3jeROMPgPmwTkvepKsEnXfRmqDudDqq53eyBHL6eUYZKp5P8DIXB8XyhdcFcNKqNR33RogMiI1k2B6D9zX6c/cigtQgwHth0vIEaE2Bg+LEpk9S7L9uFew8WhkH0iei9zq7hZ4OlNmtY/L1qNktQnyDTcZ0gloxSqkl2NFUjs1MzjpeeglF/98fkO96+kc9sjS2AqXGQQwpbAyTt0VnFG6VEm3mLwqKDngROkZv23kdHO5VYUkRuLO7NwqqwW9lxa1Msl+LoxymFV6HUQM2NTBKCYch98IKSu4uZLUISmLq31eQBEvSxzyU/6IJacvrZo+trgrrt3OJmC+aYhJ81d2LSzIXO6axQTBr8R7jej93kThwRCmPaDwF1h8Dp2rwCw1Ey6fWdm7GkVm3t6Hqkh27Pudbq1HHZpMXqmCMTUqw/nck41LX7nb7nkJBB4wMJRySG8EQ5sX9FgH5goUcyPNIsRGKcdJf4ML5cXMB4t8eiMxz47s/ywNvwjmfiFSn6PLS5BJHmu02qC6aYQNMl1PLLdMtWhbsSgEI8ZbA5Gicy94fqMQSlj3BhbYwy38+uaDAKvttmECDhH0AZ2b/z9oLLqiztffgW234egqLEwkMq/gk4wf9JAVNrJRSl8MlgdB33beKkam421yiiiiwNUUuRYtWTsTvWiIVElm4V43qBHq3RVai63soZtnTzqvn+/2c7Xb3xgBB1ZJI6boEOzAQEZA1rRqYHgZzbhJogqJxf1wdp9P+GdHyWiUF5Kc4wIY4n1QxxGo4MhxyER1/G9GJqXoAKVmw+FlBBwAyogo0ryjCamBN4nsWz6msiHvpven8uYB1seKOfsbWdeiPHa2hvS8z8ILvwSL/2lwAwJ6i8NPUtNHmdAzEQCIIJvz8aUiMZd+GuD4kUg0449O1sxHO6shnow6U/yJk7SfQ4U96RUpgeObMoUJqhvVpMqNGyNqtL1DqOChzv2Oj/+ZpRcOys3xnxprZI7DA2tzKdoPqG0VYCaBgiYKacpHk80+N+tVNN1q31H1YHKLUD4fxn7WC0DYbW7ExODcFn/ItLmv74dr1Bv3uwXLUt0rPq+N+Tr/r7o31rvr5mFjfDje3uZQGSmixUgWjhZhD50lwrlN7UUt8ZZzJ0nLfcabu4mB7OVAwoolq0dj/CRsJ5G7911sQcCEyZbuxLduMuBw42z2wfVk7XLLg9mxMjmSzMukMuZf0L6if9VNHQ5eSCV6gC8HDP1OXiqCmEj8f2+p1zzHFGsnNxBMxvYFoXlgrU1oPhNXu5uGL+Md4kqYDzuvfv0wqTZIyHNEBOfZR7IYQ9lG6Rz0Kgx40+2A0bv67FbtmLuEsVcNA8Ur9uWVkiaIsNadO5KuyRHLAe8kwKD5AwW54DKzaj3HqViTNga+uw0mK5tD4+mJcESgcFMivPPyDeHxEiEIHkY3c42WH6oIvF8DPOYi5BKpVqD2YPWj+1dthYolyv6bcWyVI9VfzqW7yKV/364T9L461aCh3DtVqLA5Y58oCsy1Hyd7h8MgowGnHKATtJjbp1t0fZKENyrDarnnfjyfMwLmSbdyJIYbRkfPuI2L8VUofaA++/lBB7AIW0FFcpBcBDiwNeodSXBr/6F5teEhZqXCh6hsaSHW7ZULUknhmkoio03sNIhpgv8pg7KQUZik69ywPVPbtdFU/3iAjQZX5zdBF0CPbpW3AMggx46rNGo0ZS5Q2gAb5TRnhAnlR0yaaWfLP/5+HrDByKgSvDdW/f/wjU6C+xddBpyW5HN9quzBAV+ojpv250o1Y0Vr9g8+jXa97JIx/SQynUmSucGkmg62JNT4Zq4p+rVTFWZu7dhIQ8KyTJiQi21ticSDDU0OCnT76UoHa15MeJNjm1qfPYtlTwo6R84SyzGCGz9l48tbMvjekpFTeNYkwm6RFhMC6wrScb9M+0r/xZuWOna+9Hyd2gDjVW/D4t1Gc5DAYZIEIWxrFFIjUGfHn6f3X9ZIF5zbwf0ZImJP91qapCOhrHpWOI4ra5IHCrKM8TMufVpnFVDcq+lxMC5vJmsAafuyT/YdKNE4G8+nkWrS+kYFDebulKftH6e3yVASsBazrvaGRzm+/8Vy40DLi43b6W2VGqtZgx6bpk9t2mGCtj0liyKF1UIoPBiEWaZ8tKWnZpi6I6jckDPITj1UlV+VqhqfmIo7kH5FNK9FDcw8a8jYHzHiqa37zRTIRge8mLdVr+sGWsDZciDe1u5cXlF0bRivziZrrF+ZJh2HeMkjFgDob4NaJ6CMqfNCd6O/fE1EyVlMdejyRT5YieZL2jBK0QNQRYzuhuMfjw0D+i3ksyhMkgqxJhVtLhjbVjlLM4KNiVvrBQzw147m12cRiiCxahFuPF+bJ3hI3gTAbIA//EhRHHOtrhJ0YFM5MhZfgaScKD9ErTnie+uhT0OQ640F6y6cADx4WWgWIszP/jOz0shtCX3CeCrCsHaRnLqO1/jJE4Ft970JOUMLMo6Edgr0fGWMWjxR1zeVXIanNXbPlaRDcuVE+rA/vBCFRsSU60TULEGDabdufg0RK9IUbMHTK6yg/GL0E7C6Z4Adt8ZET/bhoVEvL2FLi98HBraem6kCvf1KhyFt3vNPz5IAhNGrTQqcSEfX2K2H7E0APMv2wX4dDT+aLAnjEPcJFz5fvBeVfwZgWU0N/ZyOLjWibBeolDAhkADDRiEC3gRb7VDZ/4dkLWPOZmpyjWq0tor4IoGN4g1Og5gCFX70C2N4tdUoHKyhK7ftcBBU5269v5/BR9HYkB77xxDFy02u4A2TbJvdECNszGMNm04CKQS/OkWhbAHAUP38itd+6Xxv7AgZaUJ+ClaF5auBS/XxLtfv9LWgV22AC+CM73NYLLS4nCpI51/J1Bnw+2bPdqrkNUTdoq+egVNrmlQN0+nodDOlGBuZpIEviGYUnFAVq09eQSFS4ZceObeoElIoa99ssPEo3qx81G+xU4KN1jZy2dbE2fIito+dYamYkbISO7Eu6EUioO/hwd8Oa+0BF5sMl/tcYV9BNZcUnuj4wyQ+9hPsCbBMeb4jR8wdfwrHKxmuhcs31d+Fg4hMbndVcvJENKCKkwkg39YuYLwrwt1dg24ocFdHHV9MQ6SnRWEkPjHkY9XpVlACU2Oi3DtcPWajTBTQuH8mVvMRqexnKrCO7hu6/bgunPxNnVc465MHveEfnx1tXiRAfulDsaus5vCeS420v/NwtciD5nCoxGiwFu10MA3BzV8Ipv/JLMlWMBuusyEhzdXhXg2HfpaO1Hmn2Mu7+nVlumjGCxY59booADrTnEpJguzW05Ev4wNtfLeCRlynLE7gSrdGC/TMo2CMmQyrFHR6h2VZzahdzMDYdvaLJICy4MOMgP6NdQ+VumVu2e0dNQTcckvWHwbFLzUpztDs9cxMNtacJRl0hWzxj5EaOTVDKJ19oTWsYmM6awYalGd+N3Spbfvgl62ZEkk91ErUOib5eA1nKVg+Z1bDf+VuNza9c8SHYYIUtE0vCUxHel4a6O7iwI4YWSv9mXmwBIpw2s2trdQraBSrH8qTJKIVd0wNXDcUX3sOUQa7qAsa7sClyTIkiGqTuV7ck1u2ZR+FTJVz7NOnhuHFT3WF/h/hPNDaaZ+few9XUAdaXTjsUUvSpRMeSW3VnJhJqQwYY4i9yppMxXYvRe36Iw2sTCBmhTeNhbL+Sves9azU7McDt4iKgx3Gl2RR12X0zH4K8VparVfL0+zwwXr3QawkJ6OBMWUdLyK2m2KjRZpBcUZ79hlMfgkLQCvihn/k12eQBY2veCQUKlKiuLxTQstjzcAYjfIWVE1tTX78dgXGgf6yQetrKD5t7Ne5ia3UO9qcbmI5CYy46uq4yYvIVdgHciTdMrrRKzpU71tuQJbDaVoywreQFA6ie1AFT7NFhDWlaVrR5JqNZbNDAw+WKbE2/TiC90En8EbtM5kX1IMy22LAQryBMIfkWVJUMyhxNfr6c4kbAM8t5sPyT/FQ0b7PtCS8SqD4211G1ywIa1CMvjXelGiF/8h/JldS4cAIv7SD9K8KwggO1Q0xAGBnocBWOXF3t+PbKdPuH7Ri3MhgD71lm16v8Ghgu9QZzm0hx7dGScQEPNoLhD1ftRJg8Ai6Mr4lbk+eHvfynlheyaLBuSpGeiu9aHEaUDogtiLp/2p+3nx2CR3/tJRjjlpnP3hKDqPrb5ZEuX8iQC2I+0xwpLuGWXYn7H4a/2WiloSNx0xeMXZbzn32wUMfrzAOIsZkxmp4DoQG7von7yopwCWyo7uaEb69iCgZ3qV6M0OfwRRwmLyl4q9RSjTZ7rIKt0tTBkhTaa7zBs0zSyWAb8dO4DLAz3nGjSLuXmLLYFHzxMycGYwwsC71P2SVf/YFRQgjCxTLvhrkCQfSdPY2hoeA1S5WcCYxQ2OqFUWFINFvwI2JAlVdNRNw9/sDqXR8HSlrHI2PR2OsvmlrFq3KouIM1W1o6YfAxFxG91D5vfMyCDHXt4ga/bRhXRgQyAK+VxL0aAKKWEm1+MzoKOCjVgz5vqe66YKPhNbQAGWg/6aJw8Dh7ktdDwgix9hiIvHOyKdnw/DlFtyh1gxVhWuCBRF90SpmGI/NNdpDq5oBTBT0dbNsUrV1ObsAgUx4HzUtwi72g4UkVCb0wp6tNpn56YuOUNw8RiXkRF5m8OrKQ83cN0p+3RjDn5PFAKlNjJsyDpgtbUYT7cEZdcJM9ht9CBwO8ITfGoxK46P8rQGXgIgzJWq4pNnONmzLXeyHm6uRytJC8ya6YnjuwuCl5D71qEy1pHsFwJlQPzoc0RV0TqzRjuv3qtGz54Yay1CIAygVNpkfoK1k+7PAWFL4YXdQt4fI59ylW7/Jp1bnTGHU1e0Cm4YiClxuBnNGlYAqsuVm+QnNn28N7+o74Nh0r2D1A/0dS4tfdmDA2ei13lCaS206EIIewiRxFASbM25NthiYMDSmJzf9OErBPesIktWtNsfA0EoSgwdqHCR7KRAfQAFMt9mOYyslMu4TebQ3hhptlckXz8NgkBN/lwFEbzWem95vPxSUbblHx/QGb204thjoF3DLZzDMmNJyONEJaRwapU/XWLkPLUOE4Mo4RY7//Otntp7aa3uvp1Tlnuje/tDPnuxm51fEakno6JkFfm2UC9l6yErZkew/GwWs2nXhHcijmKiI0xgly8KiBny5Y/wux1sXcdHvRN96heP7y9+NdSwxFO/011ededU+8nsYVeqKpIpa9H5zHvrp/8k9gLkVgVYcRPApBZi/qBzvutiUqoG3sxl+kfLEuxPlGJGsEwXdiMDKbqERTNqVqW07VicBp7aFXMoT8JUPwKPN32Arp83l6cU3uPPXIKSk5ncv2zbVKnrcMi/BKbbC5iiaS/OGe4v9uFgTdy3LJ1jR/a+wYeE2CvZYoRCrSbhdP7bhAKDa3Sn+ghPzCeLfQW5a8l0j/7SQCpaGJOD9X5BK7hP7MeakxzEnTvc1lIwUcTSkZehB69YF5e/Xl8UT3rmCvtmiTBXVg67rGRMcQ5MfJJq0VERDynkdlb2HVxgjeFCoULKn7xTsf26EEzbVJVaGex+aVrbgm9x1qIwW6PtgT4yCnIRzzKVValemnbfD2iAYdvtqnkjioerfH2OHPSx0fh8qztv3SpFeZZf58tJ+pYqZuxIdNmWu9TSYIdEydIT3GSBUIZPozW8aSpszH1o5juejNKwI99DuKMOhMKOcerqwHPNvP6UrLn2enfyDgz2tqxyLepvK/yxtXJcSsT5RdbrgLlThUHVOFKVEdCcEOkuv0lac8MXiiYrM8z6QForyVQHrLsrzm9QRJlzz4dOoMNkrYLRqjx7Q+Ko1uF9i7mV/RcfOuySYE8/CEAsnG1zyWmELhn0ZdfosI9eaUa59NoNGLH2/nV5rUpkcFgqJ/mycH5V08VDMN3XhKrfV6stAQWBnfyv9zr2DXA9vhrRSyQ07WicAjW+MgZ64PJTpA7r0AHi77kvs05JMTxp5+GseeRM07x9VWM6RzZkZ7tFdYAz2llZzZ3AQRRwmMtCQOmst6RIjGHZCN0ac2mkixky4qOExEwc+JCbWdZETujwUH8K6sYJ3pH49D0TwRazegQH6R7pCsbtMTN4V8WA87/Uz93WQCcYM1b5vC57kc/9C+OZUUmBB1jXicWyfhWa9ZcZ2QSMRcbqRvkxrlGB52rJlwmVlPPWF5R7APgs28HRh09Qb7fZBJ16yDUdeqXCMAOPOZiuDnMAdLkb4ZIHVEbaUbWmxLYmfur26iGLTXxWabu0GwKUK0Q+Js0PcsBcV8Mh0d/LR1LB9p7I+6IUWWEDWdsPpFjinC3QqjTKj7Mp2jHMH3GsMQ8WmrJntMH0f0SDNwnH0JwtxJhLXr6dbQ1kxjoeOZCeGhAjHh8IXm9YGt7c3+HwHfE5mwgh6vrgDQEtPTvzJrOO2tE9lPQ2SVvHBmiD89N6/Hh6tk7RKn8cQucZ2E/vDfzzs+zoywN/o6FrgHdbojjHKHPZm7Fo7i8lPFeSWc2cRWRgpQt7dc7MvnlVkZymyFC2LctrhPU2xt+RxxFD7yim5S8Tz63LevCbJlgucBRatOKimZULDb+H2Ef4sUh8Nny160jt4ifppyZr0O3kqNDuUr7GG8FNoacCv6yI50NbhZ07w+qwhI6YhhetIkButrZznLlzRNQ3kcsYda/9FikW+5jqIrj+dpaGv0wAPxd/1tZ5ihd5pRqwI8hYQOrYVGFrvswtOdpKNBjTA51ZaPfVwy7PyMm//rlL1PyJk5oi4CgaRWSQQcmGYOn1pmdG+m39jRa1SGVzaBTZje4t3j8ila0rXKaC+7ZtPqcUNktVJCdg/izUYU93wGwXP3NjqPmqgNEVGpjA7VuMkaMv+78ElTzTS/5KnQzHtV2pZ8YI6aQkuFrZQZdbJUygQieI54HPrs3vShmhMd388U5aGb4wiDsj5sw12b5RTp3vtTu5GYlsf0HUIj0LJRlzy37oYLoB3qLcgYfSnShjE5z8loznGpUr9UeX5r5AA6YLhc+JeJ5NUoVzH964tPejP43Vf8Ri+yOeJCybu6xQiBm2dmXcqTrtmJA86VXoW3EJxJ5+C/EslpvIj8p8X0jnLMYWPc3ShXY1aX0791tX4G8cCxNKjQ8/0HE3MVaV0rpstz7pYrEf+wr5QCnZb/Nj1aRHWSXEn0tdMJEAI04m6+Oo2Yuaq2OjPBCL8Fyk+0tOkH6cEaaOMqvgo/rDzsw34BG+aOrjE3vQ3rgGm/2krsIRRfv20l1ueaZqXGQOV8/BrNZ6sODpFQ67SXrrvbc1BdJjLDLWjCoKlZIg/rIq2LdUMRgjk22y+1EtIqJNnwdOPwkENPNayiVfygEJAI5sa5Ml7Im3tqD4wr4HpSznN3z1HvCOC49pIDzoa3lnI2xe68QLhd/2OnlLb9C3SSidOS5ifN5J5avWgCNpwmBeflASYHZWD0DCBUX6zr6w1c/Zkx7M37mMqb7/pYZT0JNWoyxZtMQiiqlLOpJ/z60huw/RyHK2ly6+XM8twi+XBu31kIlWieEyzODX2Pkh1BCnxISy5V5kl9fbAuUtcWSKohbfXFfSiYbh/ypv06IktxuZDHl/o3USBgMkvCBupLlyUbMuN60VnD6mT2ZtXu3blL+4qIoKccUpCOetwpW5FRJetjJWXk1Ap1LpfVy1DlpVlE8GZwY+Lo+34qUEeYgQg5TANTjECC43lTXUmxLpK9N5ENQv0P9xdKtLbmK0p1PU/n5ifecMv19AQX2nmWZtnkvcOeFHhOYvSVwozSkzXw/3seDSidkKPon37lKeRm2Zj+3TrHjdWmxeEo3MmpYUSJt/Gn82c1ud2fvt8MHcYlSiJ7reXyJ5vuDq8hI5FRbY+eiBStM8VLMeg09+fZkmEg9T4G5HWPFthnHiQRTHaA1GF5xOxkei7NZlYmyuHg6rITM+uVYmCqL2+kAc8RXOFvvMjuo+bFVN0cYhYC1iZIbV0dGBxhpyVchTsJjAKP5HCchfbO6CyDeo6K/Vj00h3cFfQA1UB0zrUuDlnK4b6skXWfR9uq3nRsMLsjSSu7gHWwy/bGT/vE1JjOHJ4IoAwsWiLDpmit6us6hWLrLeBeRp1FiM4oJYCN0SdB8m2rYrzl0qCRpZk9Fet48Imh9mNJ8Fhv6Zvi7I98afGgShGA3mqyCIym0GGqGa6pZTBo9LGOo51A+1h7qedbiel0a4M6Xdb6UEhV42Lyvr2Ce6rWhE6AHkgtPUUp6ojWI9Vqx1dYWnDgXVhZlBPZ1fj+t9NtCH1gVmQp/JHQzXsVIgkHNPWecE4md2VWI7Ri1XFGunTkuG6zv3ub3DgMd/8LFAZV9dYsU5xBKfaej+aH5iY4MFcgp8YwmJcJrKeZkOSMnd8RbmHFxqReoRZyVS4PtW/Poj31Eu6sPhqCwaGDJe02tbGVrRj0MReZXYMjDN+jPVFc2FpokQCuC/wJ/s8mmbFMMUfsHIr5w1nPZDOlp1vrui0X3jZWt2c3gjrxXYuxmJPGp3mvSJAtRqHQmZ+5YeklMPK+pydv++qFXnnqy+AZNr81CQ4PO2AUuJECjojYdTjIAQ25RE8KHQvU/TXbW9HprMmTMn0iQOMM17ZE52wzh+eq7ePzab9030L3g2v+buSYb66mZkixNeu/E7fYzSTXaYTaxSrJtqsjd5WMfmqhnwaL18mEbGiZz+sW/LJ/+B/Cy3m1CAhWkaI514YKsGo/y4VjdUoTpFggQPObjIIWfSfZDRe8PrFky9MThKTbO95WLyZypywOIE0rKjV64z6gLQvsWRGw18IWJy9TyWH9M9icP6gDIhNQqEg1NMXIA3RxI6E01ODi2jebu/V0b17Wz7BUeMiV24orDzKkTY0U/OwM/c2jmenIKkHC84npq517Zb5PUaYjtBC8r3MiZVfjT675bQsAGCxynbkfjR21jcjkLbRzGiMg0gXwc3YwYak3awZsFGUBVe+vk/v/0Lg/B7TXEqCaaFP+ia/zghkH/N5TC+dF9u/Gc2jIS/l35ms+ym4VzRJnL5eURBjj3nPOb3TItEbDl4S41IqIu+QyDmADVoaEntEIFjc+dBm1787ZSw32qp7/c24HX8IH/KrWSEwy98PObtbIFDHwu/a/7MY4xuCHlpxKto8/OaH4AJwpT3HxXyRfIwsuW5NQrGJ/EUDejwHQ9ROjHKbSr7BQ/Rh59KofpQS3OMakYVrP9t2tq2vkrGtc9qc0p8o9fuJgplPqzhUuCbOZmHaeucEPM8QJanTm+lzwjWyq9ch2o3QsfgTYcvojC+y1vd6gw3MhQoKLJs1EREULnGq1mWitWijmj0D1JEWzevSTb9JHzilDcLOQ4Nku+LmAz9u8MsS+B/SGXb+FwRU7kxnBS3O7w6oaB9YMXRiyttY7Dy7dKjwQZwNv0Ag0BilKOzR7v9ZHQYqFNLaZ3Rvmcila9PDRQnSEGWat32mfjhhfBTU0VVRJ7f2Z4utCum7nduOCJR8PJO3p36uwSa24JFlz6sTosI+hwHku11iuse7RK5S/2746gDM61ESiOdkYb+XJ/zYssh23dcG6SLaK8oPIlCu5AJGQOwhovRDcpLnyKvfAhUWmQHGpG1q9Z+KiSCgwsUbzHvdTftK3L5kD9aq+lzZozWmBpZyBO8BIeJHZhrcKd4pObUpdPJ63V8QRBBft8tyK9XqnIF4BL/TaBKOX/20X91ui1Yis2VKjv0tba0+lPhVx8gPghlIxKwqFjngRmBayzITee84MPgZdwEltDE5ZCo040OxjksJu4qnkj+WiBcZjD3IBozsRj98ZGH8LhY9BzEqTJt17XPiMvWMz4pc5di186PCP9iW3W03uln2Y+xnla6ig36snqdK4BM0omp4K+dhWU/Fp8q/RKzKULddbgS64SGAQkaz+EXYFWWAuRiJ40KjsDcBAVFxVPzBo2DIaUmXUmvo5lS/ZZMXI74SNyW+cCI/jnluzWoRNjBAQNUyp3ll2wY5MEnEKXqwN8KiB+4g0kKUP++apqO4DJAjxFH7pVVkIImOOFyOx7Xipy1laUkv2/oirBJY2jdaztyb6uNshQS+QcM3FPK25RU9dwTk+Xgo8oHLhyAe5elIXbrPzt4gMHbt+dIzwdeFCI0C16e0Fshz8H2suRI4+74lXbPKCMShNVZRpVvzMiJgIYxjkcpsUL8M/f8js5vrYWlA6VHz+5zmridGip+zrvv2+qh3PEDlKorFJ78RwY+XqcrlAJqVGZlvZCKGJXa3XADXuXDclsXMjG4WjyX6wfnWg7zFlR1bSTcxtW6AY3QCbAvpQisYGfbEQ02buME4fbnu8Cu9eWV/Y0uXwyKmiVUeB7Xngpm5spRtSvu8+bdzOQi9Qh/Zje+8XRDMY9EDj2+xX3nxmuMZFchCIKKBwNqDfHOLtovwssgWM7kyEVWxhvXte03F8ztU3vkzkss6hQnPR9mYkTJ65jiGA/a1SmXpK93xeoQeXtGNeuA+GZzg53saTmTWUXz8pBiSifbwffM9IjHJI2p06liu8ZLrU2mU2ZMrAKDIkMeZzurDb6Yc29pnUc0TAfZfs+ZK44HVl6tT/mNpsEaw4OMeDj/QM4k38DF6EBUiLEqZfJWVbW3kcAaglvY3TbVwAGc9NZ8nofBchrb6toi1zFr69gRkRHBdnpYPp1I85m8kne+mikc3dBG38XyZxQQONztolCnQLMMo0NIJlfzfwvmuzYdxptm52jDiuhU9Mxk5m2VAg8dI1gGBFgAlxoVm17Yi050G+DU6OtwwbRUxi9UvEDyAW2NOE3HgWvTHMXQ5IQJd1H/dpuNDd38cwD6CV7OBdNRMaU5Lsze1OeXgBwTS0/iyvDXERjwwkK9OCKn8Y+6CkbyZqm7Xbkqt0qBtpHLYwOvGeSb/jvZIj4aCxi5XE627guY52p0yOjetoEZb6LhrB6Nc1Wl/1LRTAfzjHADxgVcDyF15YE6fQSAQ2TUDkVscwZkgpY5qV4CDxO84UHB0kODCv/PU/Nvw38gLh0ffebDQOx+J3XKgrvZLG70zZOUJ9Tuqtx4SkHi5nF3fEov6ENa6TFl+oR1Sdjlrk4ZoFJKSir4iB2nG22DbihBbO5C8ieBThVk3EGpy43Hv9ZxiT3X1A4uD+wzVPWcaP7Db8VCeulREZPPw6GeYbGjHGrE6pinS1oxT2yiQdifEVsw9gmm89VUgDMbYEMykxJyPCIUcI8wU7zclm8claHb+mmUs1sb7iAoUxe9LN028/P5Eh0QGGEejqAubWkGkvBa6VIaR4veeo+2SXykQsoxJ50ZLWz2ZvRrsOnS9I0gfY57R7lUO1UBWkC2DJEG0JoJtGjE+dUBxWK29TlcrI/0h/odB1cNN576stlUZGjvcK8uziXoay/1MeDWhbHxq+3YmetzPKd9Va+oI94lTSjwE2+Z5XpJCPv51ZNVvyUpJf5GpROoVBkhfEogc1tjSpBjLieEKiiZ5Hox0F3JYwXV98FVfPNES4LoTFXQujJr+p+AO+YLxnd84ck4CfwXXTMB7D2aNcprpPbap4f3GsBuAioy1DBBNv3oCPeU79Ju2eu0yAJKWANNi8uOn+1JCCMp0PJyjc+5dFsaZAfyxS8kyNvVT1Rt0DICoeU8GvnmS8KwBnoceEU/BBYieVIjmJ0pa7BmdRHqIypGhKjYE3ebSH+TNRBEtqsXbEJkbuD2gDTznENqa+Djo2XNgGEcityQJ2IWnwkly2wARCy9RCGR9blM9bfw8fIfHnK12C7Ux5NCEKjpT+ZW4tFE5M0C32pFnLpc6UO1wOuFgQuaJFGeFc7NXlnW87UowIdUIsRVKaw3zhsRXxpshyVT7DdMzisCB5ENCvPB5vdTAChl6v03Pc+YklvkRBuzC8cZnZGBrOa3g6ela8pmzsPYyTJob2Ga79ruGxPMjRz+lFYlbeNWfiF1IVjOMz4EGXE3nVaj0DuGILTl0jZl31k8ntm5fT+D5C451pDKd+a/kltY1wVTDqB7ucYjCNkLTjSRi3dY1bzsoqR/xSDYXE3ZRuqv4msmRIIeJ7H/l/+jS2UoGY+2D05H7XO01lU5EgWhTsdmNm7/eTBuPG/vMUqKpNWD7BKmXSC6oFGvYiOX2SgxH+ql0POmvvdA4u9ctEHSHGf6vvSQUsxrnX8WlUkHaTgyZuQ05BFysrAoyeI8p+7XVee9mAAV7++nWDTD5ZzHxTxj9ctSWuNjTg+n5sXHABcDNJZyh5FT1wTxS059IQR2B0fjMC80XnuOrBJWfDVaNveC+5pO3R8gQpJliPIMFl6I4XXag5MXVGIJnwWC898ck1MeLJgyEKsxY4hRCgWQuWEySLH2ZDQufyf9lGAZFdnrM9CiP03AptAhkmV2S30pYIu88uaiMEH86dCjfRH2S6pbvNsEB3RhY67eeuMl+1XyZNXM9xv/i8EJH+dK4tgTCF3SdTjjrZutDxui9u5ViBZT+YL4FygN11dPl/QZn/CaSHFY8PyY/WeTB+vhI967Wl4aO3qaWY0Vid0N50yvE95YLm4QP8Owz5M1iXQCIPW2F23PgDEwbReEWnDSVOogCVCydWXg7OwkmwUvHrGSCAI16Bf8ew9Lhj7C0VCPLAkBYps98lHbONZvGyOovIPCwatSLKYsDk9TREk8k9NUx3m4haJIQ1S3xmCUjwlFJymLXQYxwMSolwSxALy3vf6IRTTeRb1h9nrpn205MIgec0zr/HCGeu07nUrSuJLoJ44SG5/i5fG3aNQwj56bySOhMXBJKKPwswt0qPtOZR25GffP+Non/NT7AeKNEfCiY3JYYoXHdWrL9ZPkwVBawgtxf3bjDDkc6E+Zmgu/oXgjQZPHyqOQwCwvwogO3wSYv6KzZHv2vrKZjh1tH8TaKmk73iaW3RgWKaMUXD1e5gt6WVyYwiBHTUkc6OvPbO0CxqbOTRd4Z5cjX+soPuNOIzqJukUBgS88XE64MdNX33aHrcvnYmUDP6Nk/R3gqxXr+myxgrCmRGlKN0HwIdX1U4Iurrm2nq7v9ISmDDXqKTp9XeraSUYvALFcUysrn7bIMK2xD/P6L4F6Pk2n1FJtVZA2KJMaM/A04N67vVLyy1dASgNVCrDR+ZbDhbrzRaxy7GB2bsvlUZEK7rHAtaiw28A8ztgAE7gUo565HHYsXY5sHPmMwlmUYk78a9fsVqTxGIKPaEfyBtQ7Q/Z6lHX49kmDdM/smZSmSplaoFv5wC5IdAv7dcHNc9KQLVrG5tSQ4ECZcrZr9GjLMPGGA2Kou+30KLIH+BDmxV7OMKcf6W6FhDxeIl47nMrCic07AGmKZ9eDHVg0WeJYq8Euozav6wan0CIHfKHZ+Hb6rVHu5b61VKhO/XG2i4IpTypV9D7zBRBspB4D7eSYg7FuTA5xamzK3aHbpdvOzuFoUVd6M0yXAWI86lrPhOpsBy5erj5oOdRyP7wNYiWfHmu0L5e48FmDaXtMSZ9j7PPPNiVsI8nSuWGmi9QCJMdMNOYnbGlhQyL0mmowCim+Uk8oEf9TJCKTTkZuhbdu4Ao8QHxslTR/9EZ/yRVE0W4cIQuF/j2k8XCbJxz3ixmN8dJydloc2cIeIoW73bZ6NtztHtx0slDwzz2B8Ai+z4R3EGo2ac43AtTDKDDFpBdmFnlqIQsGqFAu5UcBYeaaxb2rHx4p29iNcy49xh4lAohHOrmxBP6SgFqhIzviVNP5zQz4qkrDn+zHGyX3vrB4IzrYGNDOa9c/7nIWL9YD2IPk2ILkibZs3Y73lKeGUUixB6k9HSnMfBplM=]], sha="8fd9780caae8a3a072c43de4891c5ca70e73173509a68bfbacc388696d09a013", tag="9eae3dfcefcb7f82803126cdf7ec92e291ca9c35bbf6ee50e992246dbf086c3f", blockOn="never", keyMode="auto", wraps={{n="pRz/ZpueCUuCh4IK",w="q9PsyGT89d8tH/0hlWsW4rkFLLhL6YbOBEpVpzVNz00="},{n="9FkUqnspx5vZpxKP",w="43NqPJiRVWv6jvMud5WLK4kJPy9TPqkYfTNuDRAKI10="},{n="4pVavGPL5knclzPE",w="DM7Wyinmra8SCSp+QmN4Zp9oAy5L50P1S1mCl6zHRW0="},{n="ac1i081lViuqYBrw",w="DFs2+57/ugQPP+D0z6NVKw76Z7Uja4r9vG5h0k5BvkY="}}}
local BUILDTAG = "v261008-telemetry"
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
-- คีย์แต่ละตัว unwrap ได้ payload key (PK) เดียวกัน → ถอด body; คีย์ผิด = tag ไม่ตรง
local function unwrap(key)
	if type(key) ~= "string" or key == "" then return nil end -- ความยาวคีย์ไม่จำกัด (wrap ด้วย hmac อยู่แล้ว)
	local wk = C.hmac(key, "hzv-wrap")
	for _, e in ipairs(PACK.wraps) do
		local pk = C.crypt(wk, C.b64decode(e.n), C.b64decode(e.w))
		if #pk == 32 and C.ctEqual(C.hmac(pk, saltBin .. ctBin), tagBin) then
			return pk
		end
	end
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
