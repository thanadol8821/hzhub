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
local PACK = {id="valley", salt="Xm0X/7vHyY8BevvfWKUu7w==", ct=[[
mwnWiARf7QoxSVECRure54jEuYk60blU979n1KXsiwwbDeG5bMYqm8KrR7EW5D9NgC0K0GFZN3Zy4wSLjYslTWOlEp08heJpKlx5D2PLnN+FdOMVYBJp3TmnonxeO6N9D2x2NI+dOeTPKIO9QqQGW4LUOc5D5BGJ7I0zLKf/okIuYkkGW9LxdDTL7YL2Cl2UWgZjOGnIPYxCn++y1d4h2X1xGVcAlilFb/poFUq1On8xT7aeVMiLHkUM6H6nzxDdVOWrx6l+r5bSRUrSFuBXr/alH56WcXgS5fwGJS38SdmstHs1OZCex8ns4dKUtbvCiWveJ3u+tK56qTKaZgql7vd8OkeNq4u2t4n7be3qvdzs6uFhOmgibpCELIpyS2fbz3dqIAJ9G/TaZYW9rIwDy9rCIK4HO8zgabAC5QpNEtt/gLyJ6pxw75Reh3Lm5wCTekPtGoGK3IUmhZDmb1WcFR+arTAFEAVeLohbyqQ12Auqa3F8pyPteud6sGysGKtIKc8vkLmMIXTb4wj2ZBvVp8vS7HQyuRBJpXveLm3UqadyFQ+QwSmvZWfv8HxdV9/E5A8Ysq4O1O8T/M1gCYgiW/xufeUjZgFv77jp9+aN5gmJQ7XFmLqXmPdfwdyVEk4GyUJBTa8uPbEWRsLZ5XSDuqklL3smKLcI3wlIW709dX5bhXG6L6vW5JQDANfClp/Tv3FkdNJJ+P7yTHRxpf5mu8VgdSDiuf+jzECOW+4tM6VYbPA6so1f2R4jJVUzlKZSiBEiHtfgSPBH7TGCRSI1y/1+EoqpKV+ZxrPhKLhRS9G+8OJFMgEdp+ckkTmjHnxIvxDEjzMkuXwF4GUn/DSCZHrklQPBXH1WDeAO3xMbNfvD7CbFHg4i5D3WiJwjX3HJ6ANvcAvxmTmdqJU6bP8CswlnGdt7V/iLxJ6teXub8CemGagUjW8kE63xx85Ar0vh1PNnyCeYHzsDYyUwGWCkfYY520RV29RxSWtlGw5eTf1b8RI/Lt89vG3vBL0fc7fvwRSbI9nPYyJ4VAMvFmJTyX38MKHQWlUSNCJVCQ/NVWtqAjDh0fXRy+PkvArcwSn6XYgKaNODov8VG+MQXp7hsjVHCDKcHlP9Oz70W/1ZFKqhgOCGGUJLSs+N+JVl001RjX0pgzK78CufQ/pkgKC0QOeKIasSbnKQcue++LyvMyTefNPhD9N4jONUrM+0/Y1iDS1fRieEqEecEmlpB8hjLCtD5k2JNyipCHkPGFDtpoBBq8yjFZ6gnywbsKQbERek2wXEgARq1YkyFRQBMWHaHX0qW9UhHuRAVnMgClQe9TcRo3qe3vEmHjiEff3WyenJQXZ4FvEn3jJQP9ZmhYk35gXMW16D0nEy37I+/YXSMVQwhNAS1rpHKQtxHtYPO156ewWX3fxhN2zdUZYcmwEOvdnbZ3icRaS6AbAemNmrN/jE5326xQbjM5OavemDZul2Ftb8lc5AjTzX8cuHUqEmWlm6XXAPBlrY8nUfaHvBUo3Ca/J0Ji+LgTXV1ScPWTGOT9wBYOtDVdfEqC98fi1VSnJwNPvAU+1SfkJcgzQQwuatVPGl7uyPHfqedGZfsUZxOUbL5nkmJFLFJ/jshEw8umqsvnWYbIfaz46gzaTfH9wtD4H44W8inIx0WcUX9ibkYQ3rQLkd22qDuoBy2ImvBz0ZbBkGojIvnkI8q/KK2bkgdLKh5YEgiBHbdri6MqG0QbZMWSArWKGAUtPfIn7JceJTWutluw9cK+pP1XKLK8Ue5Nt84cEya8hCwTmW3wYTZ0Gwfzq2kQ1DfF1iNoLwV4bJgwIGE1fCi0XxweDqZuGI52xdWk6oX8/nrpBZSFXV+ZPN5+DSf5QZp0CqAhKBWDMhVHaMl2vtW+K/To6sAVge9cV3RIwBoVVhYEPFPD5baASD4qs6WpbvNYj13dlSGPGgoSAet435QOHPqDBUQZGSdMKvwnIC29HULa4aa/90HmAElk5U5gHxCCbH0VWpW5dgvsOSjUeaTwhxk4XWS9Pe9Ljd1jfXNeqE1+viyjXaOFm3MZ+Kcu0fe4A6juhzUtQUrP4VQIzN8+kLZ1bIIs6/lSZ7BzX1DG8oOv48Qaz34QAD2aEHygagsxzmAkfHM68ViqTCI7g2NUNSRj1DzcRbb8UzAWY0Cdfo3YfFOaxPjxVEKqVGse1FNr5lx2/R++BXkwyVH0V7VvLLx4YZnLuMDU4tm4mxaxv9ARZTU56P117EmtitYxwCOmj2SDxGwZSMd/Rq0ms+YICGK4GEdLG851+9lLiW0qQnWKnhqpyFZ55zI0YHAUA35OhYu5xFID+4Lf4bnaDzbrefc8Stb50WUtHakw4M65hZg3ZuVmFbuw5T64/B/jwIyXPKNexdnWDOP8WKakZuy+Yj9jilahp2YHT3X1/mjwBK2bo8PjOyo4qQ+i6FWVcck++i6ttajPsld9ZrHunsftRdhtIkFTNRSeEOVAuNHtGbtdwsINjLzY8GSyEkBzY+KfY8q5RDWvdtaPIOiwiULebYYX9mHZp8xXqRuqtI3fAp2Xzg0mB9BES8L5qDjulqJteg6DjRCu1YAX5wFqRANcgB0Z93CPyixD9n1CoUPhSHfRwB4+0PQH9VNyS070oEopK4gVGCFBBM1maiA1Ndu1nNmbR9kpCSWCMCyT4oECbXwhA3BhDA1v5C555hx47VCVyLAjaViANNgQk1tcZl+Y4MY6uR5cTC8i8i7CdccDwvRzTlzaHOtOlXrclDu5NeRGUYj069blh2CTG7PG/WTqxzJq+aXYqSzf47h9A1lrqrN9i9UXL8xiQw0aC0Trg+kKV8FpdUpzTWaBaiwMY7S+RcE2KmJJXZ4SYi6kKoLceapCrmIYM5gwMF/pZqxcN3YmfCosyvkOxPX4GftX6S/seUt/sLI/4gCwUe1EbEvNjpQ0p+qPerWKuKlEbExVLfbZFbo1yvXoxsGH77v4ikuA1nxyasyx+9B7mjLQCG9QAKfOMEOsXU98gpiN8UwH7Yd3PAMMpCgyUp9GahhC3qyuChT4ccLWYjpl8UWxKOnMrnSnsDWBKANRtp2JiW+RLNT9GGd4OhUufvfYuwfiMgngiC390g3VOo1PWHEd1V4qJKAMoTFoq92EtzUZT5URJicmDi3XSotrzEuYx45lHQwWf4yQ5h6LsInSFj67Q4IbDYJqfZkWFugvgR2/VgoKIfreCfEdvMEKHsfrDmly1NAJOUaQfRpFPW1PbfQ2GeY4psgYnGzQ+3wiatwvqWgI4NUF8OfT44lgOVSexV/F0m7bbDtPxPfKZIaEOzBmsk/bc4sLvnIiRvcm7t2B6pXuYVk3NaTnpsK9VQFEfl+uhDggYeJ9WaNAmkfywIWrEMEs/YawviQLAIV1CFBa1y+7Z9wVooeHlJvtpz1v2NioNpwDJwTGj9t58CwISEuq1uchfQRwtraKdONzSKSBBB25mHoL5kI3mM5UxQqVPywNJmyqm27QQojIWG55hXwy0qVWhpF2pX70zFcyw5VJY8wmnzCQVxXF1myI6pGBwTZfJ6aiI1SEd6LgyDbpK+vG5yEwsMNItmh+vel8nW42emIbg4wSROuZPIlcsxzht41S+wbisM5rs/wfnDRTYKtkgrISWkiOKdOqcknteETP+QCN92Iya/YkWtm0KBsWFQVeCh2TPzG9gRrzJX8hTnWhSHaPm3dUHkApERDMTZg7yXDt7B+YK0fOuCBMLROOJ6k/i+rBMOzgfLe9DwKHwe8tPIw2+3xoDwfwgWcskw91R78/X7GNA61DCYJ5wNcjTzKTImLcL8uzYt8mUU3t7U4YsPOicyJ6dpfhx8FgLT5LPaFEiDD1IQ9hNAttRdegpxzkHBcB7r9+p1+bumCmIaiGMorCwpxqJtgNYIQXiVtfRdoJX2GmhwMINLKwIlsiHQ4FlpRq2JbIF30s/v8Jje9M9F9MviDKXGLrtoFKJ0EZp6pkIeEwGb/sADqQqe5CVBfecpv0vBha6P8eojJBTJ1IQ0Jz3MPfvgzAlkJmetuYhEiTgD1MHKxb0XCAhz9sjvNkHiP5Ega0KOjmR03t7nxd6EGZeZdNKILZUWZoECjfxu4xJbu9UCCu41fvEmt0uWxo69UoBOB9gUUrdfw7twM+Pg5dA3pmdIeBsVIVTdP3HqL+nie+633ED5qZRiJc0DQZRDW++zM76xDbIeGRK1ZWhPqTamVHjbfwomReVpjWsRG+pOUdZrYIvJnwukOCjretS4fTHZzBehcPYBG0Wjwd+wn0HxdUR6xOqbXW8NH89UT2LL20vZGz1DCZZs73XnHmvVe+4EllM39jq7z1KUz7fgCKvvsE1AZkTo1SvzeKi9ijuLrH/8y4FucelQmakupk0wF2fPgIRib5vgrp3kMvLqbdn7PRWnrd5PdLVi3QZXAzOtslP68BzqFUjdGRj7BiQtToKer03ZZ1q0jHw0Sg2XOZRqzKVUlqjnSXY1zV0db6sSSvWzuXFMaw8VbY7wHSY7xhQXo4U+emeoi6olgtpHSf1XUtfY8O0JMa9RLI7fbReKTMpcRQLUnWI7FAY3s1mdb1Er0fRRQe1My3npjjC1rpQBz866b44Tew9vWTA9qugbdMnDCuVkNawI1K8s1X0dxSQStDUG/EattuhBEstar1wl9ezHqEXkMmXG+F0lTlt85oDdpmZG3dLeuji8kStHp03uskS5SN8wzIgvejGlR187YKToyLbMDI0uUAy7Gu3+hK0UQb49azcQxw0cwzai1wkfqHAukoVp+StTRZ2euMCWQ0Qpzt5FB9I0/YoJnejJAolNF8dGsjUFrjzWsR/43JccblvIsiMgLjjSsA7ARMXBNetFcWXsF+fsRs3rAy49l+FGfurvuFRsq9/F4k/QJmBFkx/X9aaWHm7s2g2j1EOFgEl2/jj/WBgATqgL9JqhgVakcwtwKfh57Qh1a2TVTr4x6w9F4QYlRf52E1XD0vfphXKFpCYrANW/aemPLasdVXH22TGy1QzcSkwOTgPHeo2xJ7sAxOrRR5eUqcmDB130yyYzo3XrrYQ6yenQxZ5Q4JB2U0pYUdkyqzvnCf+Fo6Oystc2Bts7YGulAatN8LMTiIn9nwEBSAgaYBQPEd/rdECkcSFuzxRF2coD1RT6/J043Cw4ICFV5dFag21C5gyMFSPOS31NY1xBfwhmFWsjGcClzugIsSUOY3W2jdYbMgHpS2CF1Z+/SpH4ac+GwidNeMkxPSBRerwuUtE0cxX0lzHGwaJeuFpb1ro4USldl0O0+e0uNYxWlweGsLzRSgcb0kySteshFhwRxeZcSqjrVW2/xiZLYvPSSOu7qixo/UAuCnz6Y9NWuKb1kTzMTPWVFMLQd0xKs5w0oa6sKpirajqW69JkShjXNWoI+3ssqsv0sQv3iT7wM9jTCn1rFsQ2nBS6M1mDtGY00YrXC+ZGragMsygZj11bNvcK+g5RQNUzHYw+dVEfVO1rG/xOJiqt67K2uVO+74jag1nPqtL/kDSMeCAeF4VQJtExvUdwGO5wSoaApUjbWN90ZHCuQqvD5ZfBAVTbvwXL0X0nSUaO2reaPyLiDZyppnafJKRCcONTVjrXvC+TBZ1zPsA1W3dhIM666fwaEvMuqlajaVZ2Jlr2bgiTXGDDZOwsjU0XGK8roscCB46XSYvbz01Hbay5oBrJSRfygi4oVnYdxy2UPVSoVqXRdbx1i7piyr3LFz/uiV3fWIbCfMMCOi5Xsl8jTNV5X2k88nr19+rJ7aGdyfmjDNBCLtcfUmGIn7Yz9MtXwxdD0AEE8cSJ6NGMuP24vitdw++IEgGS7bUYzAbtD23q2ZtDryoFyuSkMDQK4X+r3cORi0p4aePmDBn6iCU21BaQJFrQgGC4dgbMbB2sCEZ45kWIT7cV+LXud/iW1mZkGRfaO4M1+4C8p3PPV+MGK7qSX1pqkHxYKWfeDhcltV6aj2Xq5M0eSbzZ9gMs5QBMN7S6/orRI0lRKVQvIQA4aPRy8sWn2RfdpYNTiqfS7XINhvd8+LvxzS5y7KeKUCNTWMxAGmRbsI4e6UDb4qvHA4Ztbv6UVQRtk4B44s9bzwgIsAcJcFNeGFSGFrVOwcDBwI5Anyoe8QXMNS2vlGX79NZ7YMLtr80WopNCxCVV+ovQC4P2dZ1QeLGU1GNVTBAdEbz4LHzhYzin0lem8DBcPxA5Id8qtrxT3YxjVO1ywu6bHfDd//9gQZg791VrYXMYwBbbgBcqP6GwRsihqAig3S7GO4kpEVm5AnnYTtA8rwmOa9UupKUCnu915v1RxWtIM4AubI1PehdL7Fqm0ZL0TrYq4zZWU0qbUvJ+LR2c4DiXAv/G5QOdUgCqOjwDPtGjADcxwjhoBQEawsilJX9BjIDCIk9lV6k1DdOEFftHfkkosOHStlrmWDRxixZK5VufacnkdkMDj2SHu3iLHt4cbUqxY7Oa91crlrb34Q3RUtf3hxn9zDoJ/Rvv0peQ5hev7vOI2J0c41C/1hFzvE4ubaBKbhtTGceSVbwglJnqZfJdSwXGS3in3jkYa/aZywuNYB7BLDXcEzWiHnumlWYH7YHdU/9wBVMeMykI5BFDv7ut4bvURuZSZc4jfSJ1U02pgSXnrS7M43oLHNT0XrSXOE5eA0q00XATxsC2Z91zRZr/wX0BttL25mu+F7f+kV+oKL1ObIeAxgOsdfoo1/hUuC0Le1U4T6sEu/O+thl7nR2YM7GfbpIfRCgRRtbBht0yTMga2GMUTrRUZ/axpE02GJ41TphjNpdhGinBYZWqvvLP55xteh7utOS9hkVmtPabFY9b7d9URxSu56GvZcLJp8ur39USPztmeq94Z83eLnlXu1+Cmw+ghxMEc7jojE9mdDsVmG4Fx6VL/hiVh1hiGRsQmY1RNnw/PNepVEaA0VF4kpUF1RUaM56pkwsvahPVhS5hhvfeiYzhoQARcod/XYeK+3UpLv6gbScKrhxIEDSGv1U1v3ThOTnG51KSGGrfyb9oVUHNAyliYHFQ6qecwh7A/GFvES2EhrOXf8gyRQEEvCx2RKRsZbh3okhanCpNIHad6rCbDzL4xqGYyGSHTDsiJ79onnBomTjT0V8ZbSK1OdMyH6sxQm+XyzL4QRcmxNpNJHhqD66Z1uPfBaMTRdv2/DQyAu9HH3cV2nvkLgztnSQtpvnDrGLZvC3n6zbGOLpSz3Tv57jf0QaJIynurcLC94PUtC04FriE1DYM9sfuI3oIlnEvwzqj5wN1kIsV74sB4QACSGnUjH47oAoKGcb9s+nXJ+9ggnyDE18C+wq2zJujSYVifJmgMlbfXoOu8TGH+eX5xOYIsI75odQnDUibZkzS2psYWsHIOVM3T/6xxO8+5xy8A487z4NVzammIa5ZB4RYc483CyWlCpDKkSPLrs2h0qpurUM2veTD31+sl1JoRKxNloGNVgBt30sChA8OQA7cQC5A1qgkLoBCGZa91LKp/FKGsb3i21GU4SYEoeEBhPnWLHfoUYTO77D6WoW300kQixGSl2yJJQTDfYNDI1T9bYoyRwO574FWCSbCCHhrrKfdtEZMZllEWZouY58dLHbaZ5p7054mJJf+jA3C2zcct157g8BFFsCPaQO6kZRmkYwieqH+18UUp5iYI6gvaesrZ/HCC6yuGDVSpV06PcZdU/YtXm8FS5+FSvFX1Vt8yUIGSt0AMCO8y/pi8C0LpaqlHCHYyLHjamP10DEb82F1/FUrhc5Z26bJtjMvLhcfxiOvxYAaQgBqp4OjoqmgCqOTRYXOrqydNaBPe/bpu2r/MmbqqtIympXks2pFKLA0RgzshsMINW48irEfxtGKlCYvHGgvwkqGLVl0P26UiMVOjjDAowhEhhIWE6tGaM19kxNIwI2iwLQTFdW4Aov67VhsQ6ht7SJTnX5jZhOpW2IGGiHvfp18piZMtWObdfSI6Xv14KCgmDMZ92UjP/potFVJPFcBOZQr5FjGKvILXYgDz2quU/6l7EbjDISdBAmc6SuqruSSeL4wVJpIpoez8UILi6FGLQm0/Hh2aXoSRnpoEFjEd0Ur5Sf60z/czuiGMCcGZ9ZvIgwQs1PZ8vXftQkIqUtFjJDt1KsB5tkeQIi6NoGQBZGMd6NSh5ZR9it0G1+1ak54V0N/JLaw5TpMV47ew6pCj78078h5lQRPPSeA4zRvg09d89S+I935Ww/cbVvUgNpd+jhuyBLEptj+vcAZF7XWZAaVLz3VWY7orsYminhScgPT7jz4vvm2CmwEPlI3h8oOTRv4AXsosnR6PQW86G65wTIYfr6JTj/ljj9/8eMzc/kfA9Cz6Ock16mbEjpF7C6Ws01psxr5snYYF3s38XvcxjhHWYA7ko8Yh+EjxShCCqCO8iyV/rykTFjJpkMaXwhxsYroQHGBWHpQ2GFn5xmOSfNh2swETB2KIKr8DegCeV5QsR39kUgMFv3SeGFOLS132SD1BgsHAPZo755uGWUj+OVCNBqCKZbnWpxwguy+PJyFjJH8SrKgfpwwoRakf9lI4AMEpS8g8mhQ0q9k5vZ+dNdG6+Hj93xQugLY35lhrrEpt3h5GffIXtCjhLL6taI54pvZO/IF0NpcRGStvdcX7r6neCzHpk0QZqFi3zsG4pbUjVKRcwBMnGrukNhNdo32w4L0wyDX3LyAnYjsKaTcRulczInMuiUPGutlOMkGJRHJF0k272AL3oBUpUIfaOrbvF+tmSlB5muqVrsn8a1Qfk5zXKWz0AVxrgLuQEZyjZGAundj9PawiVjLu4DgleKt2kfsDqrXjjEGXioX09O4Rg45wPnq4J0ycWpC4Wtw2CKz6p+npT820oxEQG9e4Bj/vVX90S2v01zd1ut3c+LTGSL2IdchdbPGreBJ2/QWy2qzy0h1VcGDGu9u8ZdmUH6cWd8bpUajq4mUdRFvvlzkBLGwOTiTCsoUx+w3wJ81mveiI6yYsoki49iZ1efy5Ac2FPgH8wpHwXhjMoDtWKgSmEBHY0wh8V8jUjqoCqJtEfaemRH3rnvftA4ZsG5Jic8ymJ6DDMK1FFnIbk5T68XSXgZMim0d98tedfv1sWtBi2lq0pngtqNET/doiUvWqMxWFjbV6PavOuOoWrNXluaB2k9Ju+h+LBnOVcXjcLZpBPr1U+ng0Nr8Qs7Bpbs4u4mI70/r5xz5z6XDQLByGgHz3wUtVZTkCjlhz2L3HgXcxA45Qw7xhF+IeGZBdvaCx7Zg264bmd6TUeJbM6lC2qe9K0JHcgml1ddbDFZ5PWGeyhmGGD/iWaTgDRxswUk07ojQ02JSULKOxiIJkkkRghMMWDBad3jcfVr1fLl2X1dz1Kjq+CepbfLuDU+uNKX8AlyEkicqLhqIMJsNSGbzHZOmplQDCDuYM5SKqKORSbHqoeQYoKpIgc64OxyB1UYghjljXuf4RUEFLb3KGqRFCRGrzQmKDaV2frtqs7DPeEa7anW1w1oxfn/KwNmHKRZKEcTG8XUzAGDH/KFBirohoSGaAdvEfkD2YwN8cEGwu6g88Ao0a7D4PLk0giBpTHQkDLWCVAyUpSBzvZ3YCd59gh3oy6f5kC35szE3t/qqSCgm+AVL823iD78nYvmdrWtrYiAibbkjABEBXXqbprbjNLjNosBE1kSIt9ImPneIMsVYEsAeWCd6AArj8OndmfcgQqQOshLttRZwq02j01l6iIjlmq/n+aonVbaAOmzXS/Q91UC0c/NPVk5IAAsMRFaLldQRE3+2cyY6QEDJONw7IBedfiPeXWx7qNEdfGSWw7uuvsqu98aBZgdBeDyy0VyiHDJ8jgVp2HJVGxeZ2ICtImwougO5JhWnYO8knjuut/uJ1BwJ8d7mS8rpGcLflhePhIWhAdbCn7UTBtwZnhHI2/40gaLoAa2axbG2q7MLqRFQRBikEMFWVI7uT31umD0Zu0gSfzzELCJnXIkgCJM7b0Dyhw9wP06xwu59NJv0RmkZdth43lmIKk5get/sWJHKdTLVjtgfU0wmqDTXF6VnowTH5piBL4SnKhWW8Uo6wbVeOP9xLpYLgGokVOacQtx2erAH8QeRgRzjsLGO7enNrnXD5l6J3kfORpkRNvZAH2LjY+9SiDviTnDqziwlys9x2tiehJxc5MJxlUd4dDqPIlxK03XDxUsGTYvibEbmf5dqatcU0tyCkEXo6rg518kcL8wEpz3soOXuxzGAC9T/PCo/E+j7jcUtq7E0bYfMz1BdwaI2BI8Hrh8t2ugMkHAkMZZWlmbzsNJhSDhEIY4xn717TvQiSYiTHu1pyx3Ul3oZHb0EIKI12nK0K2CxhGnsvEtscwSWEAS+5sT1TBASFM/vpXl/zlFLrUUOOXqnkTc+Yw+SXFrNROU4NINDO5gqYRFAjI7J61T7eFkXjp0qJqKlOwynqNKwIsjzbN1rlZsSfVlS6n6h2VSZsGLFT3yLO5o3iy891vxcvZwwHklwsOTfCG8fy41AJUzgPbB5UvVipUwsmoIdB8ZWIxiyXz8M+/A2w8Cs1cRxAfmDBfV2GxuAlx1lMXusNfQnblJtX2/Cy0bqNlMWYd+7xmcQbwfD3xJfOOt5Tjf91ESxMfPdlmHR55tGRMOPQSEoUcjOTGQ48etWpCBB2lycFs4cqOo20Jgv4kxEX1GPAp41l871oKnJD2FaFsxnt6PBSbbIjZIkIfkSXetVpJ16HyTQPbQkEhiAlmVaYDHU2MHQUILb1RFmGlenv5rUHiINB+lmvemtXKZYZzl9R5oNatYbjztvLR4gPTcptXZWiUmDHxE04qlU7xvs9om1PnMTejkuktftOTzuzjA6Kyi/APqVbRoXxsxlXn3SKL9xnBGyValKes3zYsSJ/l/uVwendwJtoFM/joGSdtmF028srZo8QzU8wRfrZD7DmcFOHAFQX5AuGe+vp/DZtGJf32Tnv1O+cOh4I4XhlGADvn/tE8mnHbLK7MDyCMCHXh9ZaH0oRAAveWcoMFryNMhlae6TdQy1mXD615NywH4+0P26HYt6JSfPEbHQAhRLDAPOQIMP/RCjurXX6tupDGYKrXhO99BwiNucXutT6CIEPb5fM7HQdwzCMr4eySQb5P1reU06/XLaLHzKYC67aC40cR+E0U20dww/bL6UUVMp2qE2g3LKC8Qid5Xbjo8USa15HvtUHEZG/jGKTr+BPBTOPIdPHVzCCS4AlQFBTq9ct82GyR0IqRkOBoROL8H8lyC7E5sPt1GNFHmKJMwLSWMP9i+TyulSWXypVw4Bn1yEgI4X09Gg0qGTMJXOq7KhhWQOo89zZzxkG/QFx9aWsf1OZ50j4pDZiV2F5m2MhYAf5d7Owy4xXm9CI7WZ/WhTlm3Sp7RY4Dsr++8ORiotI9uANz1Nf+rc52b46kUikm4KdTedl+xK+suOiAt+viatndE90YYJUDokHsR6TnSL3kv9DuD4f/7tcrpAkJq/HxsWNyxob613CPzZ6enaAylLz9RrA4KLa1ZUr7TT17MmzrGL9LrMD06A/FpebixW/d30UdhqG5RuAcH2RjNuaXE/CoLJYAytBPiHcVEu/b3EnyZiJwjRzcwiKVVrQYRnsI4lse4zx8syQ6Egu6IWHX1LfWrLGQYXlWXnoOuTmoUvC07dNhFjpfLjYhzUYQiWEkFx3J2NelayckKK2cmeNjqRwxnYwS/yRaWgtEDcxXXTgSMTWBUIP+kNSbjytfXNPbUpEtrKX69L5vBUz5zGJfN3ysP6iu4UlmxZyq2voJpjocXKaNvq/EfJC4fWwbWWdIChClN9z9Da2sY9rFI70tmytJwBBiC/TeBnGgcagMcA8rDSxL+lH699ZP2Q7zblRXONSo/MFoh9J827RVVe4aP43INsRVr99iTq8llRLEKvCU2TDquL/TZMaas3gpiZsyGmbzQYgWhRF60Ehvm2qmNAzy3ubp9xCw01PSBEHoKP5D1kd2+Cy6fkF4JFoTCu+7EJ7v+ax0g28ZsassIOy0VT5h+4CzhGC96kj+odTXGs5aYNaLs0rhz1pq/YfAySMt4ESLdwOREqjcgFZDIxixtL9LJWjqVPjYre4Xyy09z1hdgrkkra/hRSoau0ZLI5Z7raevCKI1hV8E7bL/0Y54uq3malV7hPplI58t4iL998n7lZvTmTcrPz6XdBxmEGbLK3dnx/Wm5TzluhgvHBn+RSNX106duXiXYDEAcvlGzywI/0eQtOazML6Jwa1tJYMU+DFG1O2Je4sDKe3FKKL0uqxLRlGJbA1CxGxWe2thElJ+AdCMk0FLOG7aUJQmvmbFng+w+T9PM56NXAKirEdO/ZV/KVZZpkHQdiyP1VaoJBNYNfQT6MhjCDKi86BaA59Gh6kiS14TUyfwuQQCbZPoDB0/mfkiHfW+aSplfLsD16tGJOTsmhnynby3qFO0pKwHUXMxrYQ8iOmudTEmav7MCyyjDMZCsRWANdmy7DmPNhLTwEIkH7B6Eq+8yMoyAND92C5bQInMtRmql45Tz7ZngsQ+SK1/gMzm+bqKGYr3mm+3Jl8gqYuWCev376H+mZmbBISp4YdSHVlhNPU5tzHjXhBWT/emcJaBh99pYPDCyoqkZ5If+Nmt2WLT6SG9GTWCh4aKmvZiPNtB/7jSi9LlbudkdoHsc7kCb42gYRZuw7rCxx34IdMNmFPn58Po0fia5SXct0saUFoODUyLWMRH0gJE5Wm+cAUYOPqXKXaKksxy+wkIhQJ0tcR9BjG4UxW4CM9dxYoedN5yevKXY1jAxDtsnkdHXK66ZS/tbPHPVe7/htAryWatodpYExD//mRsqGAeKVtLCWkpU0TCqEpeSJpAmHuIxUMleG0+HM2M5Gw8jlo2n1G4wfRkENYGSoq5YqlDNpGY4m2QDq3Ey7te6NifK1ikXvURcZFIjdZ9soYWj2DcIln7V29h16uEGA7mxUWyUjnOc5NzoWY6v2iidaLB3hVKq3j/haDQcjTqpdXofUT53HDLrUJkHrKGLfmQKKB9+w0L+hDXj8ut2kVBATChSqeByKHBy0W0NorAe6cYL8Ep/NuJaFt8uA46pQ7Hs/HygqkuFgUWZSlRwvM5RkIwCIPww50/KrrTwvUjftemwNyFda/UY/tM61H8KP3/leEPHs7/d+r+/08Ba25uiP+MP29NUCIz0qqyv2kjK3nMbDsgyBOyzhyOXJQXd+OqKLDfcY6p16OPAbazJAKi1wLAJm7mC3kJ30ePsTIcs44JmH3ddy1sp4AGcwNJAoAd4e67W1RCAJ2qOIr1TypKAvTTfHwajkMY0VusmUtwpBMP25CrIWFNgs8R6N7iLEz6qvYCsxkFNYtMDe0qjm7G/3IJcvuWAH1XCXOUtCkoQTOJs+h6sdmRRRTJzmvrMWZ2HPBwfZKQgaDKaNHKqBwPQRpMnO1s8q4E21KhDrK+BUqEvgpaIz30GEUA+Wfhi1mwiRjlh64bceK4KWj7FVUWvqvjjJfe5RJu2kfmD5h3ciRh1tKzKtbXOb3hzKtbLhyX5CoJ6ZUvrjsgPSP9H1xW6B014OK9iOdB+i+V3jEV4ASHyWh0qOR7+KEaXyfme1dKQrCCfJxbkaoJOAHTFjK8o8xkGLk5gp9Le0GHjLmSzQYP6s5LWfn+l0c3JU5Et+nx9H92oEx6wspBMbpKai3HGZP9UboFc4DmsrID9pfpmOKYCP3IipOVaGW4dxdDjwT6/E76aQuYvReiAewYtB3FCt+lAKeNpuaElPEiKo+NhpLdMDGPqMZ/pSEcbnQrMPtKPLiqLTLaS8zIHCQOOjYq91UTolfAfVaLaWPu6tpcGhLgusux5eemH4weW0fo8Pqoyac8R51RXd7S5oIqb4PdtEOB1lqQOk3+sMeypkRMjV6h8G2vIODVLSDTukkhbyscBpbFAteoaelzu+8U+3L+34BuBQNyk1E/SrKURnFLYadFKltTRRXFhH5EbgN0Mt1R1ngUvrDGDYUCGMm/AeZyPXXP4BMXJHnqHDExj6IGAFlENM96KPPTr06WDla6Ok55tm2BhgaD2EeiIMWyVhF0+GTF5cdy+gKaqFzg/GsUeZCRDDiQXHHeZcBJQ6o1ytvKnD9uHN6Fv4RSyPrJSwBDBELB02HSaFkOt8cDDP8rFodN5ClG4gSPL5m496SAUfP26FYz8OTPlwag5Fk3TlYWnM1byDGwSbTC9uJTvQ2rjKIvCcmS34HYOcNda9i8XUqVvA3Ta1WqWeqI+we0HLonKRb07u1YcpmiH2LTqOGcg7HBLZtkqPUKy5FRK0h5WizB4O4XI0qhbWitQf907SDKsBLAWJnliiBk31bg1S58uT58UItFJg0Xlh4XuktuHJOaIaansa3FAfmKetFKa7BvQhj/NQPmAJuQdBULmukJJtWhpjlXd3QxnUT/fSkH5iRfAA212E+vVwyleSyG7ydIVzu4JDg3zYu7NCSKUEmOmU4qT4F7AjOEOZcEErS0oG5QTYQP/kUt/dv0ZzfUnIzwKTPV8l6eixor1M7nRvn9BprE87+Cay+Q8ftWkUsju/bvwxhVTcYGRUv4oDkNqu25qW1UoSwNrgdxdQJJccDWup0aF6hFn7C2+DbQAvozbWupyS37Cz4FVl63iDEJnkzeDM55H0+B/Z/V2bWL2vkuFWz8FOad3la4SCccOlpKEhx85u9qTsQVPeYdwHxDAhtOLN3v738P7JvYOIOw/twD0V+4WfahXCYrWYG0LXq1RwC+r8KrSd3z4LEK/OEAov7o61eXJXYsozwTGT/vDxvUprLAWBc0kiHC7A/A4WqIECFjoGXdersEPxMianE4qOYDrsCh7em+u7MWIvuPLwNFREXAZY5nYCDMdx6yxngK87w10dNk/tMaqTqKYKkqwjCrCHggSdiEEkj+6vvHyr/YSjEpAZ2Xy6YZp/ofnOhipuOKuX3ZZAT9x0zLvCSMSGEDq4zC9F7EcUp3RhwLpzTFY5tr+aRtFO7S+mog96HAidEeUmOK7E7K9M6ygadSgoZ/A2466QzLxWBN4ZELFDXHEK0kSH9EJoblT3CP5nFYIAbJgimJg3ojvjEDPX6iIjyxmkJHVXrLwdECXSjK84btHLym8EkLerKUKXLoBTUeS7CzXRWfuhKnQEtwDdbiX8emvEQdPRfPfdFIlEOvWqyVFsRhkkW/tDmQUXK4Janu6c7PzNDiR3Fp3GfsZwfIluA59yAcI3ADwu2nfZIoYpqn0essuKwgzJMO07LbZIq16vi1erRAcjZ9+HumrZWCJKLTQLr5o30kgYC8EHyQIweAFH0PVpt/p9GwCsKP0BcpIXAnBr1QDBGRKNji/QH4rDjWK6I0FlbgJF7A1M7OCY48Nz2nqE0prmeVQ2U5Ybo54+8UnpaVgJxfZZah7fH63zp/ZGxrroii092Rm5kpm2nlliPwlpPius015OY7ri1tAJmHquMJyhIDEvDbU7hFCSASTvMlXYlIz68KLTHlFzAxDjWmyZWFRnnOgUG05O2AsTnmfW77u/U7ukU2DGVMH1xAEwQRtvYkGSKYHs6y07C3v8MoMHxwMENW/o8V7gpTR38TGs9wbLNj0ph5TCZxJvZ5wcldQoL4DTs1pzujODH/XurE5Qg+14vIqGcFyp//F7spfSdA6TkxsTMkgE17IZb0ets/myB/okWZ+VgdEhhwZpSvSfYe/y3CbQuPCAk/T/Mdoic/fL47LBteCJkFVeFzrBNoxIds4wiaPnvR8RmTiIgDW63yQNph8en1a1lznLMkVFb4ogL4XQYgVcoFFeBLobngtrNTAxShFNkRA/Y/WppZT0e/UBc/lCqnBBLFnVS4SLqtY9bFIv6jK8bf73mwo2QrP14kD8kD8BMuRJbu/BiH4L2mPjwQscbNNgBVnz5w4vHMYK5PGaTS7AMazp4sWv1eecL7BER051xrmyDqCm1RufCroMsc/UrpuXz2cTljC+JDQ7tiMJNKKdLjn2yt2yVasN1ssWhs6OPOOsfUG9+TsMlfrqVE80E15gRoESBfzW64z1BWnLVSynoB2I1QEyAoHTkJko+JQZNmRk0IqMu1qI0PEc0+pT2azT19qW7LlTjvNFV4tihHqrjuWZwfSFslpvd8uJcmI2cN353Lmvz2kW/cAH9L1aF722oqX7OstTdZLhrmDsx5Pbjbb/0ZkBP9bP0WMyqjKgCKLOvIVwM4ywckUYW4TUVD/dQAIYu6wJX2nX3mE6fuGKiW0SCh6kNtnMQHSbd+TqNdWDzNlPbnNeI/jjsDnJwCN8JGDpvQuzYTYpr/ZPxeX5r2pisAhiFixNSUavMERJE2tn0I2Te9MJbmBDzWOYjdQb/ESGxXuHdGxOVM8ruZrJoqVR6A15oDp0ZkUkyB7EaAfmJmjhQ3od4jzMbHqXnCJVJv3Bv8ioQeTvJI1LvuILSLLymLYqfVMigp9jFxfmyj01L59Rq/wfQb8/kadQnR8ARc2AeuLUV+s6SAUbmlPpgfqc4VovXK3gbL26Cw+qpwIH3CEPXtBRnp9PU535zBic5pTxURvP66nYkGmp0bD4jK2N2VtEOFZ9uMhWs1ONMxs7SjINnH1RTXAScmrAY4b918Ex/5+i7JBW6Y6CkUfSxburz+aGwaRDJm5QyHs0P+VJ5kkooZuDMH6ejDJV55ziZUm7r/2YiITgyEjaMWoIo7hqvB64ks66DnLx/g5RTyBD4pdfHXSNVV4z3juQUJCINUsVPWhHz0Mu/2ezKHm/RrwLDC/PekCC79QYtQyhcesyhNrxiI/U8xoyhjYwJLLwn0VYkdSWszwyEef0PfkGuKXp2f9Nry67FTmkhmM6/9+ZfUyDXLTHANAPIpNUWPxPoSU0M520k0UdSFw24vCApcx6LTTS6Nr9tMpdRNJvKJmvPpPexZXz9QeQC9AtmPQAq9RNHmFfVUUIwpfCw+c9NRsREM8ecMxrc+Csa+Pm8A2aXNc+Sw1tAclzWOiJQC5Uv0o7uH/Z7RcK1gs1frPgSk6YlFDtYWATg+xUtxQjahGA2/Kh1P8kIi+oMznJg4lYU+WPsADwt7jr3uEIr7CpjvFtleN8xWbAOmIIxpGj1XREqOoidHtdfUJN5zRi1nh+Nur2oR1kwb9VNp5Gnraw1eYQ2QC2tyhFfKcXTBZcgCuWL7bi2v1+qG0ytF8Jf77Q1HZiCXsH0w6+cdvh9YYhuE+qoamjSwdxaNSijrIJkfBXWsUvuQHOsOoYsBo1KWe7eN4PtC5kIjpjGEJChpIw5yRfzgX7tqN/KMv2leGuITg8M4hraZuPU00nwZKO4i8yLNlTGET64BVxBSHKfARe5o3unqdK6Tl+nYzgTq3sn8sAeYzxebLqd/d94MC3ENAs1RG9hqkDQUABqbNjLg97ZcKGMoiHGczHDbnDQwSnZHMMIVRwP4pD0HuAPvB5gfVe9sX9PJEsmIL1I8wTVm0foZtntyENmSEUei7Wy9Q1FsOie44jjtpsylrNmsTXeh+dPi5neENNNhImY9s7cyTKBLR5/jU7JVl991qKXlzpUpy7YkzvUYNBKt2m1CaYDXWBxfKD8MoiSo4n7sDxUOVh5X9jiHCbyj5LM7yUqksT633xZ1z9Jxz1BX+obG6Vr0swgEDgltglFA4G356PxeghwTi5+alkGwUsR69esbR5iRJWLfU1/oGkJTB8DulAkzkqS9NsGRZZWmnCLKJkLBemJv/UlNGSJhKjPiRN0u2Jq3U6y8jIHXbeCTxXwJUc/4CECWALP3CS+AbIMXvqyetqmqgUl5GAf9TkcB0X42/2tL4R1144DlE/sALzo4RlLekM3hvPKHkwlKocVOhMDRwbKD10L6SpWkrr2gxFlDIDgL40k7DZ5RKyVsO2YNgILQubUIfGO6b4roaRnRi/ZEMtEz5nqRgJL6BZKgQQRs00i4GQGdbQKxZIc7eOu+ZEMwNwYCfFne4GSeBmugz0x+Z/DIymP35u6/DTupDgVtNalrth/2/QBrW3gjYGGSTrVGqAOHNGWSLjvla7Je9FzSkAeVmV4JnFGMnU2VcJ1s/GGDnTJWY3hCUyVgB6rcPplHi5JhMZ318JHHwlHJJUSFWjKn8dmM2swS8Pk6oFOPyjHR6ucD230wBAaDMqd39axlFJqqbGPnj2IbNQ9xyIXpF+4TaZZn6sUpdA85wgX+LSNbRx/kSnNuguBXJOZMgCJsw/9M3ky6gJqEC/vmk2/lqULCkDYf849w/LIA9Hb0Yzby+lCz2FS0kRUtGgECiSNcpKqwpKrUq6dx1L8lGZay7nDqeqFfujacMAfpNVmp4inF0AKSfxBg0bzvkkW91sx/+H4JIhr+tFWmBsNYwyV/H9DFz/pF5GKrACThI3QOHfIAE3mOryLkkOjNZEcf37XO6BiuIsiiGUKmoOkl0YQo7EitZmrjaNa71d2qapoRF6rOSiGXlKdGyNBkg4y16AJBaRordXVGmcRiGjqAch2woYpGK6/2zwkwcs+8EYVLpf01yfCmaK1ohBVFt0vxSOC9m3OtXSJYDkJjZUE7kdbXyJF7lIqqTs/1ibnw1F1UgAG26O/lyuRqa2qDAoOTfJfCsksf5eXBIUUu2SIL6qL4PHYk2mV+qTiyiaiLAizW4+bSrA2TqvC8EsPN3aQmmFHggvkLhOTudRI/AqgL9xzWxI00wV5zT0GeQcaCZ/v/yzYqP/2XrbbpbDFb2Vg0/PujCJaV2rolKZ+2n+2trsklhTLa86zhGiQor462uxi+FOx8YodMolQ2ehBUHnE3GmdhoE0C6P1nJXxzqKKCKYKIgWmIfFzV4DHBp/f+v/n0TcdqjaPVCC0ce8OEMneodtni5mpaygSODuFXDPaT2Aatod4X2x9fpAMUznlpKqkxud4fFnPgPPpkRvc3xBeWFJ0u8sfOEO2emA3gMQk7BNpWj/ZmlbqDcV85Q8SmMQgZm7fqtvmOB3T7Uxwk9+PKRT2VafmgfG9UWYjYzw4AhYfaC/742TTAzRElbkv4LukI/WVICdt2slZl5PawKXT6StsrsLschXEtsJ9mpqtSdXACgWZpcsH2rqhSEJV5NDRWMu24A5kVcAOUToqK0SLugps1hptG/+b31RlTtP3fXwKH0R7fjYa5QwMT6B+Q+ZzYsYNeajxADIZC1VNKjNbJ6/lCT3AuqhXC6WYaZC3y8/9+J1hSb1lLv8xkC30/HyS+cyS3C6NZZpLZF4LdWInUY/36BNeneubngPciMr5WMS2mxNRtNZODm85xJASVJux+N1/6Zm00F2+LPNrbB7xXnXpWfACsb2iMtk5PQ9dETx5CvPolcuUuLn3Pe6poeEFAoPJsErS4FwZ/bqpjTPK5zkCCEMlXNSVpwP4sOql+syHfwZwOUltuMbdF68q3Rs8y2u5kGL4n2hu6WTI2F4bRMOH/ZCBDxbvZcG/uJy7q63ObF90+kCP91jPBHV4iAQbzpvuBiV8oYy+bEcjwJdz3JNmuUpvCHiJkCEqmCySBIejWAREAPBaxgByOKpEwHakH+xhQ6pLfIvB8uWOUZw7M/fgBpfydwKQ68TpC6ZQ/spAd7YsO18ryM41kTWmmQZK6wRFE2VC06IzHUgkz9uyRiujWcg6G6js6/wkurHFZVvsRZdSBLz2nj+zTLLmK60wsjqP7i1xBlQLwee6MjgzltPpKJpHsVgeIqhfDCGei/bUX9C16EqEXcGdNoF4PDo1GVSWpKgZaupKaW1cauHapcRYIw3AI9oVcYjmYdyNKNXSJITyMIV0qG6Mim1K8eZmqDCfkQdzXGr7OAMhIQrS0qvxA2W/Ps8KP8Jjm2oZgGXJNB3Nc6kmTGWO9eGg63bAd/WPV6n/km4a0nHsORrTMgke5vIYkFNEooUzt7NLA8F9UMKig4AZS6cdF1viX7wdsUuy9yg7ZB8ufeCQXtjPem/DJ87VbVlPqhvTCmp8gji1qxA7EtDJC0/BIMxvzuJeWTx6J4eV/p2sYQEXLW8URzdEs4g0xnqtdCLP+Rmzgt63D3pwemP0nM2mL/DQ1vLOVhl6tjCLu0fVwZsoG4bML21aNfzBUo737kWmksYA+Tx7cvTJdOU2eMwHMLej03iKg/iFSKr00LPucs7lIWNt0P2zyO+DwqFIkzd8WmI/yzlT3bnwikWLVTHz0tsEnmSoqqr8tKQtinGPhAYwiUEyySBB/DkpbxwgydXGCf+uccf+rzg/w+NxVOAVnjQwrbSbEZ52cZFxe5dCC/PvKA4ONOrttVWk8GUYy2pipHA8qQk84XJp9jPbwPH1hKgGOUmn2rXX4pMRZAqO9zOdVvJO2PMY8HMXIPtvFD0Zrtzzf7J0ujNKcvIxlnL58YPBzRUlNm8gsWWyxJQmdzA+QHm61vGc/2LH4mSggQ3fhy0vwrHJl06V1wQW06jpotqEvDtSGOLhc0JLEIce86IsSuIsxL2S12/LE8DO+IicQ7wUDR1Sa1eOaMhb/dnNwjdYXroIks5Y1QPxMkvnQPWryl/5C0FVPJ3R2+8ImR0sE4Fx5U69lq2R0zndNi3Mh37Pn0rCXIt/mrlAuTBckULJn3Q6DlZe4RATIunYDXlMctxqU44oeaD7NoeLPVeZGnQwgNOPvbFKxYF2B9xw2E1H02RrRlghyoTCk2ril0orZidbj/pXhn71btbEmR+OsGA/U/DL+t/5KlYZ0xJ7slozWPGT+pobIReGWNYrX3+XDhT6ygQaqkgZFSaB1vO77TxztTYSlRdLi8hOTwrowF+wQJuigNPzmKb7E4d0Ibd6tytcT7px23jJOVtT4lo5LAvu1FxAFHCjfLdQFZmm+KZa8W+DWBPoU3qWg2VpI4Kz4Uiam124O5L1GlubiUBh2nxipvFFIVS5u9VNjvy/rICka8KFpKckWlidQQjl7ybQ+NFny4aSX8vnf7esF7sVdd1K4FHcy50Rc0Gzdcah8jppSwWdtJYt/DOXHaKkYHz6LqlchnYO3iYwRUk0mcW6jgKm/hMfR50jNozALbUzWNe5BqeSluGnleu0MZN6b/dc3QYa3/sbTW9vSh5oauXLxLqA1qj31gZfpAgto9KtkLMkHQGIl/CXELXvpKZlBWIaAt1XdcxgXZxr0Ek86L903SAznl9McpyHVBpKvNWoRGjwEXnYRHmB7Den8ST890iMO+NpqV4MCcMOnJKoPi7XINZXtBJx5fYdDrK5mw5ve5ezQOd7n9g5hsS/qyG1DHKvxRdsl5bMeO4YS0spiMohnmlzWxGacYBareIbWYW7fKquYazpp19u5fKO5Gv25GpxY8OYeQp9xBy5V0IneudZAntcXWXry0c/Hk67aA5fp8s83acIPjvHBQMNOAV+GqE00CuUzhznPaE8ci14KgAOzUuHcRVZ+7jx3fFxi/9Ydffqf0FUfL7ntbwWLfPq9/6yir7SCLdOPpZa9sfapBcdhv3INlGrCgUvcYKbjWWeY8TiYu1tUJIgpii8IGQzsegyPLVZdcM8WrDvjK7Z/6+mT+PX7WYOcwXtLM+yO7HuIaJkrchZDDLQc8sYqpVHK+S7cnPSQ8pSM9N1COuRaJHGkpA6Xt8IrvJE4L+oI32CEoXLhcnirV0zj07OQroT4rUxOrppvUvOOc9MBqMjmdWzsykRY1F1e2vylkj2Og3z+5sLFH7+K5R/B3XvWKPZ2OAWlLCfVfUsxOw//k50wcr/YEMatUkBrBM4VDNFeCDYZxF9rY3QLA2yiqG8o+H3zXqAaJJ476ywyF0eEm0TXr6XCWOJNRqrTnlvVA3wFkhjyWPBYeuB1ayu87VRMD1GhZZJSX4OLI5xFZ9uxbGnbK3zz9wzc4vaZkM2/SSXUaSf8QsqukuwxecUzsp0n29ujxhefFLPobHVuxeW+b87qsc6m0D3rY3xBfhkIzhEwY/0hVSdQvPTkBjGEMrcWmvyT5Ekz4tVWpKkWm6d9IlPrTh6Hv/c7aZA7VEX+/s8g7AETu/hkWEg2xu0WekqbHST3ItqPUtHgdB+Si3oGnxH1BpuASLlgSq0iXqN4ZYsq/1V7R+UT3RTO6/tuMWpBOh+S/n6E/rqViLr6dvrArZcmmA6VF8J18DrdDdaX88QS0lbzkL1+lThRLn99lKdu2geM2THQecj8ykZHYwMczTY6s0Ai46LFoTRNuvFOpow36lnltkja6eekQ5384gOC/0h0H8TrTn+Za2Z8Km8gQ/WYZpb3YDAAGRnzt/2AUv5Po2Sc8UzI8z5p/NWcRtZYlCE0drCZuNiApm+5NAgIW/5cYnD0FkYTSx3ENIF8iaOX3zNZPt9Z82NEgjlbQBP89Sl4R7pUwZjGeMjAL/avXp8Era2U+1guGwQBYFVVB6XjRGLCSgTTLhAVEuIirrLRFJAkqFDAWHs4u6yvRF9nxcxTaLwxe4ljlxUZh0UfRL8JRyNlNh2WrvWXfuvCPf5Vt5CSo4z5fh3tt2D+1FQGN8ggyDUAp5jBY2/JjqHbwCN8+wzoYrac05aa+M9T1XiFKrRoB/Ob5POkVDzyf6eBPtxf/zA17Vn+egNbiHlkw633LgxlQdI1JvDKuePr87JZdmTVBILYfV1Wgnhb2gHxzHilYBSmzHI5NMGu+1ZMBpk4L6BOWt6kVtD8mBa3azezK7mem/YlMQuJGjLgoPDSyWiHh0vEYnEgyyCtmwunozLe97HU0cBcXdxwlbTi8H0Ypo9P2mpaPt7ySBTnVlAyLGFYZkztxDJES1eTMXHuh3KcZXzaxPGBpmyD5jmFid8hQeb3hHy0dBmT0knJ0uyva/slMsnZgLm6Ss+zvWLmMZqcmLZ3FWNukJCNxSmey7miK68/Pnr7H5h0kyrB+9VDT0PO/svCoGmudYguqp9St3dul1o2DXCNLxmBJUjTEP8cvi8MSWVNMnT6yHxz0Xt27ENCsLF34pbM45yjc+RWWh7FWDzYIyxL+WYuxj+tBOi1uqz63cg0YdKSn0XEpqU4LnAIqJc/KyQVK/s+yDU64xZuXGI3ts2+IPgwlkdJ6Dv8vgFvXz6D1axnNJxr5VHHgSmsEuqV3i/vmSLRQEzG54TvVT91KN61/FexuqmS8hoWL8OOtf4OEdD6LocwWLJ4JlHkpYSwvuhbIl7JlfPZgf79/T5cVBZpzDj/FXVT+f3croaHPlMWDfgYoZR3B+H5GXg2Y0Wogu4qDOdzsyIYWPWekzMXX8ZG2u+nVWwbJykXYas2fDcrWksOHq5R/ox1EnvyWLNNaSgXXsak6JLGfatoYmVvlHhSQDW8/Vdl6Ln2I2tMocUdU3JIYmCLGriQpl+fO9BTWGic7caTaI/5iAtJBjy+bmCQ/jIRXMBk8mQ6VWj09vDk/8KloG+kC96CEJ+SSgcYdUDjh1ZkI0xTd9Ak0Pi8YB9zm1WrpEWOrO8IC+i26Ncb9UHv3nKcnvqLoFzVeGZWkb4WmyB9X0L+uqiY9/qxhm+rKiZmVcua16dDWisE7qZ+Q3hhGspZOzAQRjuj75ijZuz1C6CJvTH2LxMzYseTiAwaxxnWhX54MW+mZyny02oA3xUElm2jsdUoxTfQznOqrvUbjbreVH1XXQrTqjsq3q6Bea6IxLuQYI/3v5PxGc5SF2IwUAGroNGJF5K5h6vp7/WzgZGZBseIjrxaPaOQ/Tdni0aC0dJBm6CP1119R1eL3XVi2RgvL90u8S1j0yomuteTG6rk4ODZX+qQvfDi+OUxYd/k52dgXc8fhSIh70/3H0Ha0wkIO4LT2JCeyfISKV3KEgHJGTsn71q8w0aaHdLMjHrVAXPJf2q3FIGXcHiR7wc4rRdnBN5IyF4cGM5w+kCnX0OfWysOY0RIVq2LBoIW1OA9ycwUtRJX87xiNPSamTxqUCu2tsrR8hizpb3TZ3hIP4uFifIagov/UmBc8SHuGevm/U7I5NFMJb1Gt0fW4VEigyv0s1r0kxw1GCCQYMjS9bFSGQkSMVYABrF9tkkzcD6ZVK7N5SecjCFyvoeTK5DCyMw0iV51KCyPbr+lF065mrJFbzs2AqczYjrfRA9rAGEPm8//TtUCVucWdIB8MU3mO6pNnaDl0YPFdvG1wVj/QdKE+65WcbRjZmKIxIWmhdGTXTsE0CYCD2OHUBmX7TdMvM7kwlImCIomzWbcfPOl+dKLDuFdjATGxPd93xulIfFQHROsmrHrBKrWioIKSNDNXE0Oxm0r+yeiJR5t4ETTh36doKmCgy9rQbhQZEpNoyJn0MVYBRpsC/dqaXE8euyxLvYMKPlMMZvMqNDucksn9HanRwtwKfhBBixQQfHzyyGZwAKUtNfIRme5swQogiW/u1KOMEh+o2KzLTXMSS1cu6dcpyta6yLBxyT7oS94NJJ+1jjnRLs4yF5JZGrgzcYwiWM0aja/5PIcJxKFHC/exOFBQScW9rvNqSfiJojxrbX8EcSgy5eJIRz83tYZ2mKZowc7q5ZobVgrx8ICrQlwVNn4ukMtqOqccCmvpF48EYabg73b4H3bNa9zC2mhJHPIZDuQXboqk2qPikD2Vv5XnCJUXPXb8I+fsBeqQE8NVnjmqbVxtI34/k3Adwul/1GilxK4zrV2EoVb3IjQpnGeKoATHHhVN1vbu+uGCBlqVNBUNoZr06pAN8fMfMJGsJxZQLTGBGOQqw8rA1+WxaHlqOaswwPjfhUKSrSV3N+SHJOHn4Xrs6OXNoaQD3NBIQSW+RRvBEWnwWYKIQjofvFQKKjSWrGKtGU+l9jIt0FtA83WQAzKt8pbadM3ziP6PtHq9pB26yCRDb0unEJ6uj/K1C3wsT9Jt4kcdK6o6AFUqtpq7UDaerOxoVrbKEbCefspVoburT0y46i/vDKtEBFa6fNQP0N47rzN95KuZH+WOk8zKFMwXjDW4QYMNw8zIj1Mo3YH/eaowfy3yi7iZiEveOJCzm4wQcE/QcinwZABmSGDK1wdPpyXW4OjgHMj23UnhbxNtszUwQmkG60jQQh8THx2YBUKPfbXVr8r8rFWsbHQjKi2Tfs3/t3aW7huExzanrDHkJ8+XtnIsTd9a+GSU6I6dLd/k2KY3EAu6K+lhbhPW8LJvKce+pdI3NiKJG7YxtZipcbsFYjrbS+b6Z0uMsMGAnwhJpi5s9YPfKRe/c7A5BHfG/y+vXbJf1mZbeZPUXvSQj/NQW206n1M4XCyAtNqLk1lDsY7OkighG34bracUVqf3V8AixYgj0eTrdwAVblEW/sZLEbJroN1TTpO5pachhMKQt2lmKLUNkt+5YLhRFZvK7hWvvigCcRjl8BRVAQmp7BfxpGV/2rq5st9lVvdjHJ6YM/JCUkrxk7+biMxDJTvBGYXsNb6vonsVTL8NaNkc0LBFblyd9VIQ2CcCl4FGFGSei55WI/escQnXobl+f0uG8AVdHGBynDijYtjMmslYBvcFsBbxJePD1A4v7rBLbC6hhVxMKHFxlZCjwf+zqla7DsxFGEM90JmbzcZNm85sSHBO4pGYZqDNHF2r0nawFo+SZDeO62wNElJwB77EeKTRAYRCCZmXDInpdkgEI1XtDZ59VJJyElgpoCY83dNkyZSIoUKrJ1+eO6tkMh4bgkaFwEVkkIIpbMcWtfRc+F1Se545BXmBnPcOp+lAdJPs+gOWjeyKDMmp0KjYHun723fNQfRqVMP0uHER1Grb4ZGrvlVOv9q4+B402bXwfBj1Btewu1iNauUWBrEhqO9EdX//fJPMWJ3FBejTZUKlE5un1usyp3zdTYBngoUNt7ElMrAxz6O7KCNycyc7W39xUTCvQE1+ixHVPp+/bQD45L/rIdDQCp4RqBBqGu1jfE8AWwPNJQVyezkdl1C76j9FALTyMSCLTg8jqhyHxnA+NWTdRamkVP0025uifGddxhqaUVWPDbGUnnLzhdjW1k2sFrKbrRPzDlCF5SjASSL1XJxXDB6UwX1xak4CeDv8+5qGxq3awkywz/x3N/JShJkfMhjMbz4sj2fvEj9zVaAw9dwH6W8re7NU4mCJ8tf7cxjYdu8RhPPDQsvxdUBxRYBn56WbO/nGIJhy88vuDtoQFU8qRHzn1BiaZhNweVqWS3w0kZvE08pT29IvG/IGowloihxew+AosqpnZ+eaYgT3YtdrRekNMZcSCqpqsdp0g8/mlMGNJwjmdXNn3biy0K8/u21uy0Y8OJ4v465LIeLtwulyqNk7YmXzGawnrcTPWKuzU9ItJfWD7he8LGHC7CgoPQgwScNzz/QRHJQO7uGZ+SM61s/+MU2wmS2M+Qhbjl9H3VTU/JkjJuoXZ9I3R64678Q1Jeb0GQ4YXlbnc38KeBY72vDDOSeyiJ00QtVSqY0DIf9j5oZoKCQR/Y1RMXP4A1DGwGUrqtpbo3GSBjAziCo4ZqJC8FyIj6S2A6orj1k2sabAhrQAk9Iw/U6XmeeNtwc+GPB9115t7ArNhyXOK3B29Y7FKzCbZbTZzr4zM6lnSrYI0sd2kmUudV4RJU1wkpiTUW8wACde8XCqPjZW/e9VK/8bTr3a0YhZj17QkJNQVzqGXRF9+EjpvoCj7jxw/rqhF/00XE0tKWNihHkHaoI23fp7UqKBQNW/d0Q+gY9vlCH/Ei0f7dVspSP+hwWQhaXIgXIW9WfV1xLDPd5FFMLmYv1LYVJp3ER5MWeSkG8HzKcOkANI47VQVcKIcOg3DUtTUT2QBI1wltx+ZllNJllszppo/ANjBGTlqJ4u8MLyBUp6VavlOULUwAWiRmXy28BpFX4uBfNC5gQGt7zAIsQOISOpIQNYpEl7lvrnJKm8DoAYcB7Gd+qraiLnuT1xVKtWqvhi8R1mJZ3D1sOHsrPvj6AjGYcwjjsE/L+I3KFOfgYb08jKaBCNbGrcBjgbSZ2TfJH1xBSEfQkfhWgFhinVXZWcavkEW3pPqdUikJPBCuMzV0jt3qN6tYN2YJcxFa4CmPf1xCpcGY6Ocyx2V01p5COcrt9CYDMgosqcFi4lf8ab1epDjn4uOn2kSj3kOetsXDiX94FSpvjvkx6W+7jTmUMB9Wbj6HntQGlIdITxSSLUcXT3aeQQlSQMAFEh9CrjOsugeg4pikHxercBHLyFFAhhEwUamXGjoSl0BuwFN4s4ZxZsnb2txjrmVz+uNrev8cjk+aTYCt812A5AALYYGABV0/vbmkyEn2MZxjCu8uMYBJCrjapzw54uZ6LLsxbD58w2lDmKFPSvNplza98+utIFZO3XhRTnJd0XlNPkW1rx6MGkRlGXfz2dkba7HLEif3YLzoEclyZFwJ2BxnGbV10rYQ+Og9oRjTMoJbVfng7Ojd6o7PZT6YwpZw1H2wYkmUYWT6krS0dAvHTMOEF8rPsQ0PX1k2/gMD8Y3oUvDG+pQKuYJ4gdTZ26Yp9VqnpTj54nyUXptS8YfJi6LJksvNqN0bQ0PxWr4EQI8/7XvlWtTV6Ikz2tNuP2XENyOmaUxL5ktciDuTeYZu8QD/B8J+XPmB9mxGmJngA5uDWChuEBbYSUVkXi9ASlvt33UE4qrB5n9XIVGORa5KVYwL+M31wU12Pznxm9gT/RmltPHnqlmWsSlVCwLcsSY0c1ugTN4TVdRYiuxLkUHM3Q6kUm3Nlgj0SNHyM92/Obihsh/4GcvcAUHN04It4yUzWN+ZuMH+s7Q+DPGv7VHD4JXFwYpuOnUkPuJmq+criD9yf9CUPEzt24/u5ouZi15aUbjERcBqYXGZH2oZ+KgtndlPivyfKuDxkhYGnpT9xZXiE8QU6RFF66fximB+egXKRlSiAdY0yqu3WUYglN5wBxd2yuh126hkLz9gi7H8F3YKmymAGuuuk5c6HLEwCvW6NiZt4EBmmEFAz9couL2mWv+vgRIjnAZ+rtwa7tE/leLKfUZvraaDoZwsAmCEQD8H20+ib5Ij3KeRbzfkc3WGvlgndtSUMvgI5CdC5U+piiWpLyfFAX+djSKhltZd/JHx+hkU7n3oI32zVluX2MhxqaAcOrF3XtLhIZ5OSXqjdNFduoTlE/K3Xsbz/yeYOcqU95JaEqt8iVlNRtqbREtujhdorBzxKmkZNrSRQcNfDxs/SICE2MT+7tlOHQ4bFS4+7Uw4MuzTjWtFB3aUOcQvgsFZghpV8cSb1+xdq9n3fzC4oHbYH/YaFLcNQhmpiZzZe3hSHeBpPAEr4S8KZNS4cK14TlFOKkE184E1qFZ4VFKsSYpYoynLalKkSq8dNN4BXuq4C+D4ALsjN8Ps/v2JTQj966Y8OLHWWVmZGv/lbDCfvTDWZFnUizbayMEHdwe6Fatm9UJYADMBnGqwqQhOb5+Dw/GtKgukMIm8MV7XYJ0FJ2p1xD5YcW3xo35kzoJN3PAMzgmHcJyNyHTtC4T+ucMM2SPCL6WOcTuv43tv9wpRXGk+wXQSb1D4YuoXoCe5Kj/TrTX8wu54YARvYu6vcn/wu41dfkKzgrkeJqk4txtuUUtSXyK9N9ZEc2frsu568fbMexGGlt080jnEM3Ev96K42oD9kbFaVhekl6pRO3ReVQMRdDY5was4wG6WPZbpTFgcS7h1cwdAPC6hfuz4sh4UuwJuPXZkf3/hw3dXorFSaZvmSljRUUW2CnJdLq8/HTI6fu7eRVPbTgdoLR7A/iCN1N3Yj8gRaEKsO4Mwd/2wT1al5QiQcCsBOP4kqhudnTIpLbI2bhWzUJ/vWf3J7UbfDwGjSs0BPnCUZYETCwj8q0zQV/SrfTYjKS0Dmruy4JB9FCe5PyZQeqEN2yA0t1qpWha6EzDBhVJNH244c8HU5ESUh9H0xib0RhZ/Rc5THBB42H0+YBam0K/XaHZcl/WCWFVOyPKg4emDBlwA+keu5iCCSg5RCK4ZxhPxzt+KQ6SRvxb3R5dMaGQLkqZhF40kDi61Ioh3lCUdBMt+z2THVctOZNkQrqKTiilWgGN2f9o5yBqIMAHBxpqF7qsz4Jyja/+T9+kQcYg8n1mrE5CSEW8d11Ie5TmdIzN+Eexw6Prq+2J/5GteetW17Xslc3RAbJYN/EJhEyuf9sFtsX4GQTemYOW+UYAaHcOaa36EticoQzbUq22qYR0AkolDAFWCegyMUTmJm8cVIYOa0Dfn7ed85zh9irXr/bSpXi/LBGF9/f8CKORhmX3LoUpNv8vEYkCHwklaZjbPHOqTvwdTsoor2TGvcIw1CVCtn0d6IJagBTk5+yBmm7vn/hrFLkQGRecR0o38NcFQ6NpvXtW2WABat+sKvPWFATjRoAg3iiJ0HhM9Kez7sL+Nw57upMS3t7IOAZpfxDeJn/i3kkMkoULyIONQHH3AIkllvhk/8d5g3oY/epgNvw9ohjDjBH3KfC9lxILb9hN/pQm1WMcwoKDenHYHKkKWoStE+R+Wp+OxZ9cpHCQcFgtHlyP2JcYoAdfVs1nRSM/wXar5jrBC269iuea1Kmp+b41+6OPz7v95emQcj36SuZAhUQlOheGgEkDKS2zM5WuhQJt86IBeZC0rw+nKUCv21N378TvpHBT4naDArwwTxuUWAgkQL/GP2eQdP1EGPo9HX0Iw6FNbXI4DMjh676zRkocwe0HgTOMCuHwan4PlijkBVE6iIeVu8hvQC6Gn86nkx0p7X+sn+PqOisdNzYA4IG81aAE7iAuuVX29QLCDRFQg6WmvfvL1CMa9JGeXF4XSjuPPk2juq2deMHz9Mps+sAYgLUNinJMI0uLJuRHSpbvbBIxz1IfbDD6XNdDSilmQXMPCUUWx+V9+TGDm8jz1fBKmoPIByOz56ZnSpXI8yruoPe1D4Eboc0uYxBJOMdkRMdG45rZXbzuFJJ2IWb8FLRQ7nVnF3rvsmrqgHs1DKlLsqph6KTacpIS5wFq8GyflA0TWVo1O9dRq3yobj/xbP/gagypKfDoiSyoU7PMyZMUYk2UfsnO8azUUDzsvGofcYcQyW7wSsDHTH5t2ANOIZ2Nlswe/K0Kbz8JuPFgh6bJOnNKBnTFOCkNSsyzhvBsa8VCl9Jmj7KEYxQ0mMw+yt99GM8zgSRYqb4RlV2Y8g68b7AbdWvvL5D2U8g4ydHZyaQoEwYYhX7cMfpmY5nNQy26qEQx+OyQneyi/yGxceyMjJIxet931K4y5CGlY4PXUuOy/3lmMu4IZMmyxvHmExKvLKFtbGUzBmLWGAhEm492iGl7AqnqL9vtgsLilQn2ykC0y4EniUUiclflOJ5SMG8aiCIfREkN6VH7h9E8VSZAqA4j5aq9X8pqeSrBAx2Lfmj9Yp1VzGp2zssloLiz3/OJ1SeURPILIP+s3kEZ9CYQfzSyw6IC7MqvuK7RbsPF1jKPTUdLh0n3yxWXLamjFervbmUrtKTb36OnFM3ApfjTTdxMhAx2845DJ82snIe9ZldKEAtq8nWbSn8guNkSjuBId0kmZg1YODj11oiLZemXkIdfIsnC4ngSD/5hPTn0RW6SiqeHlQooR2OGPY9E5PKpjCpf7+QIFciGCPayuu6aetf0w3pZrbKMiJBlg7yLqSsYrwQrxe1RxdnaqX2iY3s2UGfLL2umleIAT95l8sPy5tnaUOLGIzWJGlPMfyNk/zaApyRE5L6E4d0/9aie0EN4+4iWsSRBYBwaxtk1vEXeo5e+BRPDzqn2Fat3mw9azUFvg9IvkVBukXrx1paK3/au4RyW/ywcXRIG9+bpWjthlWI9pTNC7EaromgY+Q1lLaWrUrxdPPU0NgjPCRw28GxjqQqROE2V70y8S4U5aadwNrIk/+zyDBnR8++UVXANy/G5YZ2V/U/TbEr+y0Bw8iia61q0cNeez91Kp1NRQKi4JY4rBNy0kbiOqc+IU4pOD3yXE85XGqQHqUXT5jdbsYL5SSWHnYxWAmP52TA+oOpOJ0wg+EfJL8fTwwIwgLR+3om4TlFbAf4MaKLOlaPb5EZlYF91CGN7bMD7t8Y6uFxJZs5vYHmCmoeTi2o+4bFFFljJmJj1WQHCEnMHDBZT5lCItg6H3ESHrI5KZnuQ7JVcOoWzVg8ajxeykK+qbX8qCza/pi0X0wiT+DY7r+jDqd/mkxVqEwu4/zVyLrM85J9BvTu5mqHvH0LPdPA3ySNI0STzNNbDANFhwgIGyAdanU5AfLdFigSWNLbuXBctMP0GHhqWtArFqRsv37IoMExDjG0LLUQV4mq3ea518TwbwbdyjEWN+qx16Nk3kNa91OO6PgOpgkBOXPviw/diAfK8l36z75qZ5XW2pJJIAcohyVtIcKG2cB3aWmGHovzKpUvaWQNe4PiqxAorEWPHc12i0A3Pkeq0OuWf5bq1rgWgZ3Sg8vRv8So7pFSFLeEd7EMsFIQKWhDz8Deda16DYSbPK+9jw5Rq0uQ2USamC9uTXqTyO399LUPHSDbH9VGn71bocUBRuEfb2K6Eycyc6m4DFJSr1yXRZdA2woWfV2JuakSVugv9FazbEe3S1i/tVHBcDdW12TuQaIzZ7Z07T9nYPbfC8xe1z1K3czVPOoVgu1n+Rgt8QSbXRYAyAEy+GAJr+si5ifJMS83QYCHZzOViBp8xcYNgGHYCGva8Cs9ehtPAVv3u2Ff1Jf0bYk6IWJ7tWfqopPT4MCqcSPXw4zn/MbaAQtEqHS+KmBh0B177BE5goHcesBo93AtZZU8g2Iippyga/2tyFLGmLKyPHqRT4JSgV9vDo9Y6XZd35g+kisQk1pR37UlkaFauOBboaeryVgZnAervw9TqExhqIhs/8QKgrtQ8Ih6cZJvoQAo3jtmbczTXUCNXCArs+i2MvHrMd57cNhrdnaHFRr+uEjT6GF4uBLnwU6WwEqNYrHf4Jf5JJOGquyiSmn9JGpmezzsuYlNDpCD0pK9Ig7lza+8rLWdFp/fFFxKdXcKd85d/d/jBms4xKJvuoRsXguQdVhti9rPZR3yncqVyfhR/aCtZ91ArKb80+/nM4/LNt/jTrO8NSSOfa7gwBKXrnNE2324nPaNo0p+vIsOr1O+e5yYwogyraWrI2JNOHRNLoe9SA2PqMKoGaCaMdg3ILx3N4nAkgmuTJmoDcd0rGF1xj98eDZM/QmEv8z0Hl0jwm9Kl7G2Gg6aUznKfVT83k1L8J7AJTWcveBHWogykRS/E8ntbaPIRsa8uqfms1jUvUBCcKmP+faXFha0zHUIRaluCduszlKdr59tDOqNc18mBs5zrMYnnuNMOMYo49jMtgSYkEh57GWN+2D4qltFu6Qf2mL5M3+Y+V/Sw9BDYDrJkI/WnFcPKZK112GJjbVbrnsVzvgjKTPG7/9F4rrWBuOj1NR47ak56tsNrJpKZWrqGbwf6+1+0lcXS+jiAleSmnJeEg2VoAGkbQJCipZKYit3O2Q1nmgI9DNYSiwpVpmUOQGZJRHJonMVRoKzb2sCnhCAAGSi51YXraZI4jJJjh/dKy8lMcadgny5bVdEwnMZfwVszsGGPhRXvnJOFezJFC2L+AFJ6A4WkoVMb4Koqo1QpBNdw/owQUXky+xR3m/w61lnwivJMUoEqLvTRft23j4JrkVraLDXGZ8tigxk8YmUJ7Q2rTkQPhqPH4IbeUgDFAJlULB5gSpd99JEHV2ofIiVGYU8XRn2LA9aLHAd95GPFIJAGIYEuTaDsf8dH64vCm98I8oJOsC/rpfejSmdnTD2L/n13ERc9mBhxIRgn6h7fj9/okQhla1IgWPY3gTjTsKUXOzKGEVpVWScmEIyr7rjRfXosX2/97krEmKgfX4j540aSnENBGsp3+SWcmiUi8IUEOHxeex38stUK9y9/jYe7byrWAw5uS700tXpOZ52RRVn0mKM+NHWoTlwVuCnJBoml9PxmnctsceKgoyIq82qHG4USwBG/ld6nSFD8YvReW9Mi2rWUTNLSXc4X3i8M/omF05b+rrfzC+4Ec9HmawOHaWPz3L9801Pl8fIHzyu0+mBeu4nr+d963cpJa/Q3kww7wSoLfMlohXVuLQalIi8KqLet9nAo7+f/H6KpGKo8ktx4paYO3v2nMzOME9qvma8fPiKWf4dTfyDeWIGu6sF/Ka0pd9L0CexLqepS0Z/QhhOi/R/RTU8gvHlw5g3qnndYQRn8YKDvQXdkm/HeDN4X4wCbco7ebd/MdktnACjb5Tl9FUMTkLePgzGk+1Pa4legSMsoI9VM1hbEddiyutr63Imb3bce754St7uBLYNw5PIrvKwTkvMhTv4k1kDu9wDCX6c3TRaSSAW5J275XyM+V/C6lj6gqzTQbIEs4DOTkHvdHAVMFICFIpziFIJ/uvC6jD3D2JDhX4nzgXdE3aRlh8Dc3OaRNW4q8Jvi8v3qTHNd7cSg7R3TkD9S9OlfSPFg7p6HDqWQhrytxnhmMwD9AYlon8P6jG/tquvV3XyYL/GEUvsKv9ulHaaNpnAsmP6QyDFoodO3zotEzCI+zQKUebl9VAdVEcO2X4mG0ukOJtOxqpzDAsNauRDvx0jLr+K+5LS235jRD5dk4HDRbhEnkWL1PKRj/TxOm+e6C+/HVJqWb9bYTHxoGmtA9uRHF+7mbKvkOJvz3jgk7VZkQjIlx8k1+++OYax6nD6kf2297omiaxPK8uXayxcr+YzAkUMkQSAiKl3zqs3/b/O0r5NEwjwsF5A+89Bc620Z4jhisBS1rjEKjMb38TFjWgDHj3ZWoPc09l+JbfvMmnC6pTw1IZGWBT7cn6ylXHcqbEWFpRKc9Z168ICExLX21vOG40M34sRXSqd5ukFRcKiqbJaRMHagq0O3vus5YE+1m/al0GB7QCyVSQo68QU/cujS9bLjRoxu/4I3GAON0RpJWhVmyw4Oe33UNeYE+lHcoCUIz58Ocl9C20XghYN5QPdOR8NRD9sdvsOLSMNAOjkuYdkXB66UwX6mwbDJ8VUjoFlkWlqVLbJjVc73PngtfjryH3AU9lj8Znn4IlffAu6FgyltG1CvHYX6rGxTHp3wHhJKUxKz4eqmJgqf6yPhPSKfjOzK90g9HLZ2ewpgZ4bMUOGmnBMa3ldaBZTxNkj029HuKj89tp6Ow9XR96Lp2V9/EBfHY9QOszPY7KUjQ9BcnVT9PXe1ZcEdWsIy5VgD/6i5cU2mCqegnaIs62VhrM9RmX/yy6F+pbHRaZ1VKxbcSeR4gqf+yjBcfPDgnLkHzI5VsUXfakuFeAD5iKWlBJkzS1w+hzKradsRUPnfGE7KQLhWY4Suun7/E4d5P+rG1r4ohCVoyrc55MhckeNFnYYvpstjiUNG+FWXP/uNLLodCqUYgS64zIC8msE7WFcBNbsjHhRpxg/VaQFbPUKMQ8QDgN+W1EDRxU7nbiqpp15/f7ZwDcJaWluQqqmAbnnXzBoxKr7DRJaYy+OHxJfvHQjyDd+lTHJmGHxaOw/5+xqlrw59w2GpL1A76AWFBtzcEVDkRTtE/TfveponKts8mnxgwgYOW89CvyTqtwfXuLSFbwZk6j8LEFhWTeWkPXSOCh10O2jSkjO5z4tYXsM8xxeCfGZ7BmBvSvqmatfN0DD56XXmC3E/959g7AHzNL5mXbCfeCcXyDqSNOdvNlR+2lU+kDBQlo9afKKioybhz3vC+3R1OnTDbihnJl1vS/BMYZUn665NXiD8fkklOrP1Ijizr/Nm/3FiE9ul9cc0MLFXWs6lGoLDB3FdUmBDu5ztQ/i1FFGF4eVjS4tVDtTe8nayVr+M0r7kcJwjZQCYo4WMBfBTVa/23OtGtUpj15j/ugnMyDx8/4+uI/UH2M0yL84Nige+CPeR9Ukq8c9kv51Jn3i2eKplY2nnw4vjuxzb/OG50Li6vacd0MrU4Uski6rdaulqZkj9ssgFOEZc2KB8RPJI1pvYmW1N3fm1du0oDYs44hik2XzfrjCCWYCzVh6N2tmG43PowRYTqFkbvlXaOH8kKfRXKT5nO2wjAZ067Qla9T+san8t7iafsnUTU0H125AcChTJz5QRrZE9TZzVfoObOcfGEmhA9O447vNFzOHlr659trWE8r38ji4JJkLVi84pVrnYKMOskFyU5ucd8fUt+H7cZaV6CEnGX/TuEPPy+UXvbJ5CSq9mumBZeFhrYt+BCWrYzNqeXuC+8h1bP9+uUzOvGxbn2JX97fyY8XgtsiiBWtphlq7j8YshsYu/6DPV9dOwO9MN6ATG8mPP69Grg3OCYQ+ltYsyI2RcKHtoJuIy8wuuB/9DaIXNzjn+XJJGzBG75Iv2+YS7qwA1H2/tcco7ZHC1Trm79j3SzOXNPA3If1A3BE+9hLm5D/tCT5VvUIto5Itfz+3j5zPQu7PCnV91DNQj13+HINXiwiyAefCQ3oV84HrzyXe4wSSiPg5NAer1yUIjkSn0eTKycg8oKGsV86+M9YUYDeb8eRUc63efzqKUE6EmQBr2KjkOcnnppOh4b5NTWMoN8OnK1cRB+XDlkmBhYKWTLJfFY371lYHdhNgT8tiYSZE+o6JsDh02Xz8E+VUAWPV+AkyETH7wedgZqFGnJFV6UD9YdhX2X3BeFDMUYAW82wHkZErGUElrzWE6FbJCxNMUowysdA1pOQLYovOZOS1zDUEX9C3OTpmWGyWzpl2wZUxBnWtp9Hgtgx+Szxq+ty1z0e+Y+5ftMdI31LhE7B7zNy9m6mXHmHmEKQ4aGXIeb6u6KvbcYxXqPxukpVHiffrhCn0JthsFBXfunMJ5m7DlYTP4H6ctvNRjlkirJNbrhHXb+5YSzjV0QgV/5Serj3FKkXC3WQ63v7JRmJ1zWgFtiUtPG0xFkCSR1ERA7/MkouhTa2fFUYpiirxiEm99J8qZuCnK3yau0Tn6YJCgym0Ptm+jN1Mh3kTVS4F3V/1OcNLmorUHDWd5C8zXoIePnhrJpOPAQPDrHs/X/fXlMD8om5jQSTf8JrW3k1hWNEkbLynHPDZYOH7mylSYHdQCxkdnV+cexTgGFtSkt3gJsT3WPskANbp6GVhxdKgzBOZgCqNxkpTk62NkVAk4JuTmBcL0TIqP1zT6xnTzcb2XmSCZKVFmNuD2Aqx6zFeONYw83EiijnsJL+Ez6RPcX5uKbBvlRrxpEAMvRtUg/PWJkid2+Axl7CxhxU8ivMp4ijjYwW6+7dFf3VEedTAOVNvUwvWcIwACk99TKGqludhh7oEd48tNGVItPIs8BZajseJ3Uds3UEfncu2/SvRPGV7vO47cWW4bKRXquAyL3kUn0Gio+/bWgD/AWO6Ww1zG75UgL0Chh/eoodZWesjFxqqaIV8DShSduFVDSPsJvAI16EBpLlJnDf5Wvk8zZ0pBY2M5GvegWtwmBrmtjAGBRq3O6P5jhO8+6gCqMn448FGehz+ftiEhW7v0mKM8ViQ7K2Lyo1LJ8XvqcMBjmftAtLYZ72bzuSe8Gb2WB4/GX/SzzIBxQMfbaJDymnbhSScvWPI8WhS1Or+b5wxGlDEcN30z6RCz3JQ8AdzpngSb90SgSG2gock9ymUCAY7SHRChJwebgpZ2XeKY0mF0hWPlTrK8HKfYtMVSkVhgQLEjpQuoRBx5mA0aEyvhuIm3ERtfXtV9D8BLMKi2N6Ty0Zn4sRyPOr9Q8UN/Ut6Tvfdlk65kvdb2wyKcknQOYVNBRn5MMs2Xhv+q+uVASXwQNrWijUgptUZ5dl5nB2M9/aeABspW/L1gUvVxomEPjViOzoYET4nDMutmoHy3yBz3pB/TjRIWie2zB4F9lGc79NC4QddPjFhD45F37lAtG0fAScdCKpeEOjHjxccs4gHzeGNktR55u8ePi17I74JYDmpIq5Y/sRCvktfz+/iR/m8qQFdo7fXhhzc984j/sZhXQtEctY0DewOFhUU+x+508IPz2Sv/L01JUS1Z4dBf8Jb+SNI3v+za/tFLj8ZzBjA8aTW/8nlrDpFecqbu0ub6dlpSg12OsQ17cY4n0tY0hquXSEpW+Br8ndSLnPRFaW7Tf5eTxz95sGbP+7HDSyJ0xlhwh1ZGpX/Ghbd71fNwW0YCOQBspWTHwSd8Qb/F/k7BE1/p6YLiDV5CxoafakiNR/LutNrXTAOkWjCZFzgOxmwR4yXf9hRFU2KQGv+rsLK7gQZ1050sM8VZmSmCOCk1VhfMxPv4tXEqdl8lQGwKlsfisquJ1rXI12WpWYXg9HSPat9edQtN46Sc1XDl2hPbZ1bwHxac+m50fXWmyuvbFDoAoQAw9XRnOHoGzF7XCNBc0NXmaNpdslvEYj9BQemTW4yumjj5T+g7jz2kRRJyrM+WYb4WztFFvvqricaia+kzqeAqWTK3dL6GLgFTwTpo3vQEZt958lgKuBfJO714r+UZiO+Dq3s8xwKAzHdb3OSDqa2MWrtCiwZtMKsLbB1Qxkmq9+EwxJE7aXn0oS3LfAIrb7E+ntz3blKoPLLtTTgQmJfnfu8Mqt4WYC4sMo0idXZBfQexTUbBniERpXLU/IFsmMYThiQYGRSUFpD648PaM5BjleIsyyeztn0CRA5LsxYXCu3qohqllEYmbwzoBc/dQuJKP+/Dgzh4btGOKGsBx4b9dfyrODMwCUpOu9Hy3ZwUYwKQO0EYXKAAbg9pPCyP+q+eNZyI0PxNrppDvyMoBQFFepw3S3weQnpmKOWAP4/e4wHgVlRwGTOXgh3XWFUPK4uTwqLzeekna0/dQBA76z4bZHblJ22T0ctxSn42u5Fx9OMCKZBVgDmNOb8oopHRcWGFI+gz/zqJijNNohp5YjnhRiEG1Aaj+C6AzjIvTYVLp8HOkmaf1uImJvqV+JLZ2aykSFLsv/mCTUmMAf81Y0LmYrBnr6nCmWQtYYH4OyudicGeCpxBRjj9YNxX2k+ME2pSRJuJy7wJ1YzjADuICFg0yRT5eUMc9/7mOPAl1aUI8q6abmsXc9szQYn72amWcJTMI6i5S/+UA8gaFrYuAYM9nXdfkhdy0E1vIXcnKA0cpLoJ0qbFDT4HmYnhaIWNscAIhp8jsHnWweZfS6mwX+iN3mIG/zKEluamyKLuq1d6/vVJ2ukn7cHnKotQ8c/YGxPJJOGuY2hdAdNff+/ad/Cp+K1l8kvepENKV2api7mD0xFcSmAAYhfMKoGq54fsDJbFguJ4bGZkc+PM8EzwBKsfQ5GJwRetMPeJpeQ0rppcuqY0fC/9ofQJlVdCb7BVh3n1NYfcy1BFwI5mAeDMJh0lGixXRz6lq91o0nsuQENm/Ttc/ydWPzeZBWgUAHKxONDk4EsZcmECt0SLRapPJ5vUGX+mZv2y7NrV6cBK87Zy4j62to2kARF6eXGh2WG8jAUQm4Xi1QAU0awqIVcQITADURpLe+AvQWRZ1CWhPinAl/sfTFd7LLxjl+kWYB5FEXE/rL9JBPyEVMI3fRllfeyycHFydZqoBPKcCtAkHM2gLaP7piCrl112qllklsw9gxBsOWnV29XnzDd9vRggBe9nbuSxi7fpbcefQVWKiHOiT7bVe6+DzeLi8c3qz9kCvNYsBAtgzN+Z89TO68TMQ7i1joxQ6LeiFJ7NEmFSRQBSbUsm0eg29G+yCCQwc/Pc1V343t3tOwduJSinBZGs+ePqYR2OSQtRZbg7hp2Yvjbd7z5m/L1cI9OIccqveTzqDNzWWMLSSVF03Zlk3OWZyQoBEgzL76mhAZCPUsS/we+xIZKNJ47LPJhGdHCwob6OiJcv2xXo6oATEvIuHGovIhqfFIOpjd+iKPJdJzj3e8eHDPRBSYlHMoSA1GraM1RZcjXkJ9Foa4YgvZIz1WOVjLtTWKclcg6rn8irn9rPOw8bjrNgthu5eo2HkXc47V6UBzXoZkDmJRI8tadodhF3rl7pF/ohZY5nl8UcfaGFO6BnxKY8mv0Msglo6pqGrimZCPYTlcdCagDdx05rjlpd++dY7NXKZG7F8MaKLyiIhd0md9Uf8utaAk4TW5ocQ6G/OuqRGjq5pfzYYu5H7yPEsw6dDO5+0oUTEAH53VSWYcoEdB2ujd88j9iXbbzki0qywhwhRQSPRjixMWdcBdpa2hRxS7fXC1xDjuNz2bJiilieTZP+1Q68SAUOB1nXWaB/OrXTCxuudm+8jINAmDj8tJtm90P0MMGluyE10Ljk96PkEzkDBHXodR8yzj0OCJ6TfJd/EP3WFonInJcrdlUsn9thNnB5U1j0NtejooMbHp8tpM2z1O369n9SpUJwbLodJLsbalgIySvkwV+xGiNbCCeJfeErsSdUTAfUofMAB131ojv6S6+3nc3wPGZIGDZJDt1KLGqK5WDIL2lUzFSl1SzDxRrEXoAv+XQNVtwQ2a3Py9Jszcoo4gJ5u2hgU5+xmgByAgH5pqKXYEwMwoGc5EqpzQqszio7mmszOOgAk4cuhgzpthfD2uJP0oWABFkEV5PYPe79+YXRZAzl0qQI0Amt6RFTZVVVFj+E0aLdRxYIb/BdwRm/URbf37MHQBsCwml69f31k806hEnxsmpV0h9dJhRqcn7NsEmBfN6aEuH9uSoZ68EpE0xIWmbLMRWxBzUa25bikUZ2hmdIw0jGxPH8hj6/fzT0gldYTmZDJykWnmKiMeSRYVNrmXGxn3ENXvJf3cSw/zg1JQpsWJQbtKWehmXNUKTISRk4TbwyH++MGvIX7shp1Zw+Fiod35f+7kRmcRzlPfYcZZdEhG7DhUaPPmyTfPqg96mjX5C+4y+Sfz0ygBhK6dsHBARcyc3Pa+/kvtKVy5mA2t2HcZ3IRJaJwRj+313zSbQhWWHexfQJahJsJIDSf0+/W/yQhi1kSn2pddwRp6RbKU+Uelrg/mV5TdYGxAFDp+8EC8kwKeTg9VqHW9+EhA+q+AJI9g1KziddINYUXUTlVoop0Zo0k0AX4uTMVAr0lmsXcRdtEWbPwKH3FMwoOJUzh+nj1J5F4aHM2nohqaj8BO1cDF/osHG/GziaZSqW6b66XXY8Kd1TVv15wQbC3q397sH6LnxTypsnNSlSm781JJkZ6kqOwzRXT6YoS6AQql9aq2247QvGcMjq03edK0giKLg5iQ+o/6shP5q8FmSyDzlOz5/rSWcbLRwU/yC2RNgU7HW1bP9wSTIv5blVGq/nSyU1VVrWynanGhOhn98gyKuCgj8hm5Xio33HH7hKzLnmD2O6riPIdfwxTqsP85DUfTm92lF2BIjsxyLJcRAxIAvwZvx6WgJEEtB9jczCK1L0WOt+xyHZtfpZEak1KE0oIQkE4wVrCf7VPbWyK5FNYAjSyqgEiFG1MXMISQGr6CIMuGR8NXLEPD73X7WlH1PKD8RlXpuxl7xcTnY2e6E+B3YsVTMCEuhuYZiHA7LFe4i/17WGMkuCB5BRu/jD9Xyk0m+HQc7aMxJcDmilNfVDnje6j05/6cKj1uhQ6Gf+bzKX1zjB8LLujPKrHFQaUfP41Vbh/+mc7HZjjspvwrKeKCLljFb/KHqQAsgsOzwI1V2+KINyw+TkX9UUDuNoOTsALJH3DWyEAErWogTKUT3LAF1YCmlQOzGQDj1gFiSg4ZSH6WmTSNbMUid9ZLJ0Q6UonSWc9KZV4Adj7stqKfFxDEAkqhYFlJ+wlzR+3G9UlMSUtvA3oEan470fOFnSbQDNLn3hJU5tJAM/Yp0en0n9htPvbMiS4kpa155nEIg5Se5YaAIFIPJaTXG8ZtrTHZqlD4K7xOVn+tosemCtJmLt7i5FPrTMIHe8tjomb1t686pgbBwcBdd0UR7FM63ctG7roob4vwGllY8j/owngWMVdJnOgx2mbPHbKkqdI1yv8Xo8zkE4hKM3FvRyBfgDL5lEN4Cjw3E3RWWc0NJBIN0MDZ6xZ8pzdm82l6MqM2oR5dgZY3n1ey7T/usNiWAFj43dMNb+L5k/e53aP7AeqAaS7lYriOUkgiD6HqWHvPTtzqUONOm3Gs0LPlYGE2L0KsvHk+B0nogiCF18yxZbLd8vp3GZ9Gt6N6H2VQeZ8B9xoxNFNwaxCLpA1/YIr5Q6T9B73kII9QoSDhf97hXP8G7PSN6fzEJZYvqHK8cm5ONoSJxORUxhXHP1nsaBBVsuazO2RaM6owyyZMVEwrhF8Ms0To7CYqRJD28rmZM797g1gSnn0vL7kZLiiwxbWMFuJaAQ1SuHPJUhnylSwFYJJTXAAKe54C0iDNj9kBKqfFeGNb7Zfog56UJgAcS//FPqrnbiWBDXcoHxX1GEtvXsdiXTwhGCpZrUfOb8zwEvXvnrjZ3skQ8Fxb/fyxKosUz0zgkxLda4kpf+xcHB+EpcfqZy7qIj08GwhFmQ+ULn78Ojgy5Rv7LVlaTAdE6CCipYlNc5CqO22fAsK7N6iSWF1U+rb3lwBxQye3hOer7eSKD4CksFzFyFBZMTBeijqT5EUC6UVGxL8Zr1ye8tNsp8rkR7qnwgEM9S3thbL2ptetciNc++IAEdyPJ9EvIqV4APEWZ2hkuyM0Q2lxVx0Ih2qyeSWfdYSNU3FYUIlH9dPylY2cXF2BS40ol6ec+FuptlNnzkUpjQ9oF1DaK5e8UEmT0iqVMndYWrRwdP5zpIIR1gLGnxZhiCihtTPr7Awe9W/PKTxmXae9PRlSe9SCGTp0rfjoVu8vgYIgt8OeYrAEW2tvxaE3CXebDFRmSVTilowkj4h+rd5rO4IOqLnN2P8TF7Dqw4raco+VyvyYVlyDFOVXq9xhT1SNZtMw765pFO4bbYkfWcyoqh6Kw8u7phPLsIsJYKP2xRro9Qbghqh3VvsQgzJq5Ii343xB0+1gTthTyuGRGmhvciXVuBhT75UxXEShL31kBEqTpU445nJ9GwuvcoHTjtVaCENMJ0/Oha6NUkISBSe/kQghVzcEMIbT/SZ0ra8lTbRMin6MJ7TlqHNsEWknRwNmbTXQE5T+BVS5HSM//02pDvVKsHHjIkaMJ2/QPXeChmPV24b4V24WB7Z8kgjB2ofq2iDrdxTzKmRtGrn9KbusHPxlxUQKSYjvnJAKdHTjgPLeBsecz9V76OxfvJcxEcI90x/mKG6f1E4CpdOasy1tJS3v1icI6CtmFRBnF203LWmtn/BDbqPEJ88h2pEeYMoBMBfGWHNMKR/x4WMA2swvOUrVt+PMm3Q/PzkOybMbY6z5TSKCgkA0lqU+WDeT6/Bxp92SGwYoPMehaPC3ZePzkkILNXdE11BMsnSLTwzGKPT9v5X8dNHlH2qRkIYDF3F82L4DxSjJ8wNqJ3r+hiyrWM8v8ccKinWReWpQIBzSS4MO7JVz7iiuAjCx+7ApuK5MZXX4kzwKQNjr8IXCvfoC2hQp8pSBuCL4L6rdRzzvigka/gFkdngqIrnacdRC8A2mk1RfSbhG9DVv8noLLqsJPOJLgXpawt35FmmMCSNrDuzSBg081/nmpwbLOLLfMbLYc+vED8gM94D7/yo1mUHUpCUZV/ZNvJJFozcwqwngEH1Y9UM8SAlFxmAZl3RMvNKA2QXNkV+M+8JlmRF4akwbFyCn4eMLz5EbcLUk675Ko+5u9Q1wsHzRqvvxCcfHUpStEb039BY4zzp/kH4TAo2qstIF0Q/UpiD5nLqI2cT0qZCOlwJMj9g5P2JuEDm/rYTxdk3AUqBhaEWgUDhGl9KGHZTqKpiZ6y7QgRe7yaNK3lHM8nYQ+6NkQrXi+ym3+oHz14H5XhxpVam39zaITXR08VutjAi0SJBvu499DJ6AvYUy4ni34KuX/2ri4ZspMbx549qARhtaqTFxnfSONuPUApnYh2df5CDNWQm6XV+ce0Gm62tPGRJRl/r9qJl99KSoAXi3S/poRQsKOTOl2fGzrptZnO5WaCkxZ1olgVMr/J0O5lcPaOLdFscePmnfIe4UfTimZdhBehFjqz+by2NJrlzNyKaBaGAXdBcFg3QeLJcvqpAIKyZXFTCDalxKGWaU1JDPt6bRYzkxZVX9oD2pZzQJfCfsyJq9QAFizbTs7qgDGydcwHh4Gn+qLDULNjqtdZf0USYv093k1R9jJ+WGsRoLlwlkTPWgtwcrmbN3Z/hF1RrpPlnZr/X6JpVzckdiZuz1bdgcUe7GHrRMoVXxpudwwV//XQZu4uUbFYAnvPK2xrMIxmhU2N5iWNno7GFvbWRQ/BpYwX0g8d/mJWtMV08133ehP4dynW+X3xBgf3KtzvHLTH+VKUR9Smvozb1xI1ehKDQ4ER7z1cTdxnqKHLZy+2644TJp8+aOq5QGr1t8VVp7s7ToqTWDcc4BAyD60FEIFCVPDagBuMBDdg1A6PEMNkB0ORmox6MGIYVQqw8w21B6BlVltYLc8K6B8p/PbW00mSuAuNCXs260vy9cNkv1DjG5wLzOupgWg/i6EdgoxEa0Aw9C7EX9x9SF1p1e0+t12DAy0QItYjw8G8f2eHfO19HTEKoerpUW3h3D1+sntJa9MaurpTxDgLxspP3BeupCEjfJu3gNhP/GEwjz5p8kn8H6UYLxgPUj2QRas7QMDmiWmYHRImmhKu3u4sy5b6TuP0EglW2F0cejLKifzuH4uQ4efEOA/A158baL7dZn66xRXl5dMmmRXgxAfMNtZiaBEUtNgkLovGqBkrJu4G2d/fAInSyjWcMVkj9gwaAkGfdajtrOl7QLrjxl3q0ZGPzbZRy86ClB/2eBb1kdrlEDHG+Dxrgx14JmJOFP88TGePYruCSEMnCjpgeSVco0KxBXSvy69k5pMAO/X3fr+yhTngeDpQ8ksAqRynVqPdIsjacWbNpzt7Wkg0ha8PbAuGArlF4kJEm3zxmxKlakqxmmrgTI2muVdH/OS+U0V9XxGOBJotwF1kTlxhvTONkIX3gKuaHbEwV70tleF27GV8UBQ97g7934EKkz62W3mL0rdTrjVOH6VEX8BZR3gJsgR0yep6iK/AK127IXJxZc8lXCxSsX+QznWmeQhUXhkUqA8l++nTnRBO2DqxUnyrJ1hhQfMPYUCTZHxe1b/SGogHBQ4h2zjbfqnffuWba+mzAko8+vIzWG9ca2Nt8ceG92nvSnLnBoq6+rXiIgJXelP3OcAVSj9MeAX7kPFlAJ+4GWgXyU9Mh8mW2u85ihBiCHyCofY4zlgbi4QGAEYPKp/cVcGC7XzyNiG8f6IJoqtqFzohm27R7gGFMeZwn2IeaTEFkIiag0ScDiNv+P1VCJ28R3f3IC3FCrpLgWziarTylNnwKttYBtVlH6U4QeCCrPLug9b9NezAjjeyibe1zuzNn5kLPeQixE/BVHo7Jw45w4c+Yy0SY6aObK5zpzAqASSIC0pwADh6zmumA2j0a7v6HxUA4WolySonv06rZsNpTJd6pe/zAGq9XY97MnRMDDLc5tRRNeI471h9smpnaLi51aWNS9Jd+2h06CuXtnpI5nYbwDKbrS1RxXbTKzQAEgnkWSiubKQXCxT+jFX4HbIzo1eINJT+UGWjMYaZXFRFJss3fpbORBvm5R8uvgnE2w08hSe0sxw4N9mqx1bCfhIAZiLRvoy6iJGIxVZZR/4ZlzYzIMGLNMCsTb4Qns+vftC/s028nq9Oh1TgmkXq9aMeEPWHLGKHXoGj/dEEAdUSUoo/AaN7d2wkdYPKUUBkddIB1UjtffTiN669NsVWL3ycfK8XloKO/XB2ZCPYL6RYM9EDd+3bDmTbUMyBiL7Vicni8Ry0y/QM1T8GMViS3kdm9xuVuLSNzLZiNxJlkkgqKyiFKnWSyl8gki+ou/3tikqwdDyuylxIuXfHtcOQxNyJhMKD1yGEiJdpm5B8F6SXpPH/NlXO45eWpFvC2d5LdUIZZT0iJwYjvnC1bxzQ2Xqk6fTEyKM5+OwreDUW1o+UQqyMUAIr8znBilJAVBXwdnDG3U9Innp751dZthgAP4iNlK01XW8nW/ijkwSHVpAifPqwjb/odjwlRNiBzDV+ShtCzrBMeH1YRKPnsehg+2lhlijMbotG43jDknWZgUq9flvr8mJVjgk1goin9D6OJDUsPVStpmenpxQ4f5fpUhPigsD5LTHM8O5fUqNG7BqEM5jJJdX1+HkjrQ5Ky05mScJWwbJHoJbBGSWAUX3d8PLDlIRIVNdIoPbm4C3iXdpSuV6fuzAxzRhGEwW9so196SM8RZHcDkjzrx9/8oabtoxBGmK2i0CTBprcvZ6+asdt5phhMOOPnrr2xWGXvNf4JxPTnD3+i7nZU8NFFaLCiZIliCZKSj6COB/QKIPklHkfCB2IZhlZDGm6Sishx7qTNqUiHAADyj8tvvbdVivFWfngxNMDBeX78ZMmpJN5sSUmDveBk7UFx6VtiWce62E55bWti8JlVfPuP/4dA6Swoa53AklIFy+mqUspzDr/Lu4iUoJcrmSV3ShvylcLyigbBXOXDR2uWtVtxBQnlm5+psG4G4m7haRLW0WSG76lB2WeVV41BDaN9qNVhvk3ymEYWe4memlmRWf5PbeWBGO2dXDu1Z0TC/d0Jl3JzQRlwFBcRPsxIL/R/DeKceuG9VbhvPnErGWgVqoDaZGTFCpkO+YacLdN5fxOgexzAZz8B2lVvC0SGn7C6ozxxfHKgbOiVbBVHfpwm126Tf7ocQtEsOoGuSKl8I65S8IBe3N9OGjFtaOTQ1Ze0XbzNscCaqYmmDJcEHRg6+yvkh0sSlxrfjaGuNZ3JpDJQUEOpFHCzf+YQnzRI0f2PQZqF7xRim68wlLviXn0NnlJiFkrS7gVqLxw3s/eC+Z8uyn4lnAi+oGZoIFQ5ComjYGlgSbUG/3ATzCG8qgcUR5eqSjJ450/NSzAI55IErCTMrz48879Nf2CDNUQT2BkQz5iZKl5h1RJlaELE4hwhQ07xWbC5GU2wiMk2Fe8nHc6CCtm3fmoPNpxNkm522EErrxYwWlF/2F5kq8mChdaWSF1kGB3DfeykYbdRWku13kYv2Yh7g/8HLZuV4/JyBx28SqFhXAswT+/XeW0YdWumQfHoveCRlD1s0hAfoT/9CvISvIbtDSsudjeRmmuVHzYrYeRDZSBwO4ST/zOMiyOAKv3Mde8mpQESdRBPEEZRKqj3jPOukLzUmttCRgCBw0UZRhzYlt/gK5yPb3GY+Ld19gW36z4D9G9JKXvw9Iw2l8j47UJOkLua60V5X0fxRI1G1l0slXvw0nIEoyE17byR9bZiR/Q9sl8LFrunyB5sqjHkLzklUn9c33LNLPXDhkM98U0efHbohIbZWaRFlKsDABIhJOasIhhPE5magvyGStRCOaYhU7Tt6blHxubQq2jyzeDVCo3Oy1+WWK1Jd6FH/jz2MZghtXSX6szwhi1GcRk8YgHBghmW3r5iH5jQ4EcVZnu4JWlhTrAe8elCnRhLO73/htJ6heT7pOyt0CeHQgAiDR1S+HyJUR4ItJMEDHS8zvLRafUws4romxCpRPmtv36DEpY8yFvJH02XOcEeZMcdQ/BaaogMaEGo2LQ2Kmz9nz+cH3ULDTdcHa+BsqpsMyPaCPYuhXuhsH1cEGK58OnxOcKGDZ0HCD+BUKjnXkS2MBGsz2BYIrTHE0JLcJMeAyz7W0YhgH2gRkL5kOcygP+Cz9yTvWeIzwDxwURXn8xii9J0CO6xsf9Wy1BDWFDYMjTeb+IrUkhOefUhmOeCzw65CFYLenFtolDoY1hOBy1HqLIsdSE+TMb/ZWW7iKEv58z21OEgvX1w/CAU6pkcgyz+H/aoM5bT/xnqV9PL3/2TR20P5ps+l55f1hfSLscy68/RzUav57LBwmuMi49IcEjDbclZov2Q4gg3yaPOgOUKBlJpMkJ05sW1w7uSKNuDb23ZKtxMdDsmkkke55OQSKDgZU8+EONwZEcDWbkGctZ/FOfE3lQd7EcW6OTSR2bSWd88zFqQJJDfnh0NFMCkDzSYkBHr2Fa50VQYw6qKIExiuwHRPVvQHLGoqsfWSVhI08xzNWBK0oqXrP7GzlqfPCw0NunWPJDpvZUq95jGqTBeBjh6cB6dl5ui1AzlUerQXBfFLIwNKHnS4AsLYZZqYWDvpHbr5aINGn4lu3GiNGo9wPzVwPnwLqEWocqwPxHPihhMQGx/fIOfbdpltFHC0WdgW2iGcqD/0Obr6IypTYISdh+LVPs1UFp7KpMlmb+jdTKl27R3WGLC1eMiVSIazXFM25JQQ6mpQM5URTPxFff38AudSBr4Xy0wPxyldw+XbUKDQ6X5vdSiWezVAVMtwBOIV0NE/A4MbKgDWqY8idgfoheKntDfuRGF3UkSOlz0CVJgMBATvo9T2Jbu1abb3JYpDpTRvj28Qo1ARg6wmZpdfWMYSCIx+HUOUHeEIXbktVgP/PQwEBIwvP1hYqY59F06TXIy1l4w/xG/SinjrTbqoBTre88voao6NEMZXUVzgJ2hcAYKbAGz6oVGx7CUdg9Jf44twunBHF+HNsluQq87NeqSx+pxy1NcUUBhKTiLilRxORjtAzNQ2RAD5s6VM/QRtYC2zBUWP8YWUl7qXgDs6867oT62+ausrYwJwy1uD8RaiK9DoGs6qToHpmZri9ylURDSY1x7g4F8dVGiZ3rgazeXXVQ/SZHBpNr8oQBF2ykXUu9Nw2BJ+5eTFQNbgcONMofUB1gqh491vul32HpWGru5+eJttpoVJFfT2YZlkfKufMlZOc9P+0aILdCg1hnNqR1JGk7zfYoqKyyrvZMNiZJu/WJOwN7K9xkeCY7MDpal8HBDNc2mUaTDSVCumDe9jA10uAIkjVacLBYfsQyUXsAXmKmzCvq5X1hxZE6t5AOAOBCbUbz0S5wTZR0zMkztLNp2wtROSbf/YUEBwHYMFzXparBaulr0Y8HgCGnL9ExRQPcXwuo7UpJFjiGydpT2p0lpcSfkJxQnerbwS3a1VDJ/gNUdAakkMGsDj0Rbd/4vvh0NMFIuOPKBvVnHG43XEkyEllBji/HTNfOq/jeUg904fmWvm+xEuDqnlY5YPv7O+lUWZp+j05q7U+zivAsHPHz9tdqQV599hNs+PtlCG+M8uUXGMVe/eIz7AJdDFuCxe9oE9cVqm3SoDAMq08MHKTX4LMCGSkK5pNbN3s2Bc6ImHRoQ9uEuDrN9HlL+LyhR4E4nUEpjI2NIKP4ObYMq4GxPJblysAUBAEqQJrzggUOdpQRkO7BDUIIkQDEKqAYS3/sLGwLQsOX0hf1Gf8GSwlTDEhkn1I7ebcxeJERWifwrxLtv7P6gIAka4UnfRLlbiOL0s1c5I9/Kig0HOl1KEnMWMME7alWmQxQ/l6ZamQl+3qjY/s3HGdmJZKp88jPJUZtop6NTCwlIiLaU6AeaMVG8xzoXRe6VwHakEsGv8zLBBmbLi/MU/vSRBUQqiOy+E/4EbflPHKzq4udM3qQpxCMsSsF/wGMSAjo6gRFQP+VxaK12+DFMRrbc5MvPtl2WB6GX4zBTdfZm9OZTd9KDxnGg1Xm5zrRMkJMVgVrfx3E53oMDQD2z4UpNN6dF+pj8LuU7ovrXqvtPi8XkyGpkP4yhnFKtM8KLDuYyymBjRJKvkAGEHGm/kfDtyGi6jx/R1ETUNfZnb0Sd7703/bHGu0QiY7GvPKDBjdksVDkaA7p08/ZLhHS6IFwZvoeyNvjCzSD9tA2Ox3Y9JyZgfV6UdO6ym2QwUWw4gjqvPgHY16r1esT2VyqnV1e0pTRxDHREpfmCzKhlWphkVAR+loydwsK61Nem5PdNmXMtGQUqYn1fqm4DmXi0EvISJxXWKMVmCsmyGjINxQeq2iIBLXuwM4azNxLmE8zUs+pf2y+3xOmskxLlfM78lZDRNErbVx7KgTSLpzbAjAS3WKRSP70xl6S69RVztpd5ROpbhph7BgVgkEJ0N3+qnrxFrTtriI3HG010kLIEM1SW9eGWaxujNIMFClREbJzibvMGI9I3bBsK4syZK5a/5VCRR1ZiOOWPdmGzbhagytP02rJDmzgnDjWWPWvZtftXkbFU7+kNZbGVdZa7uxYn/YUmxTENjhibDbghsho5KJl6ApkS2UVH52KM9mG6aAIvciLJG8nJFQWoT47ngwt+KNEDLV/VaDyajPtzaL2+BA0QE02X/Ei2hdVSrESTX+N07qnGG5tS6OZzWtMeqnvmBIn7jDL4f8dEDYpX8UENJS+d/YywiTqeE0FkvyiLR0vJweWLE1afxrzlegdgR/XdLKn015J7AcywNkAfSvRpmuXdoW/GMIUlRD8y+18kdww8wzJsuqoYeklIQSsQWbmlU8WYNtgn5sxWgQe8JQ73N4HBAgbCIxssFvNUqdjonU+mtsKwEp/V6+W9hnJzAYsg/mMenVLDM4mFw3KvpqijdRtSHhujTAjemTFySS9Bz/D5Ld5kBgCfM1mtZrstSDqR7/Nj1FwHrMLWlq9842xLGD5J1vUEM1P/TimqiyPBXrwrw2DWQLF0gagNzu7TwdN95gPoKGrJlTCyKb5j/ss/vP2VOxKaqymMtxoebOzRFRH1jyTxuby1bsMScHHP/XPJeha/sZniNn9WPyrBQtjjesBtZtxMj/eUxD1O143lnHoxsu2nrVBC+CtVeKU/DKvIHJNwYwZXtAulRZITFsyusBA0aOdUhuVe4R3GVuo/p09J3MrDQIno8bxEfsAJV6+/1aPShgsPew36VmF/r1ZtsyIHikk7ZHjHWjHQUnB/B/p1gMra44BE/N2pCGdVGadGgO4iT4rWYoByh3MUOWlzlUbCC/YiWghO7EXKnBLBiWcs5P91GgKqVql/EIa0KX7iFea90QRlKt1D5wnwpPxOYi3mhCp2nmO+6/tJU8XHSqW+UQNxDL2MxHD1ZO2sVhnCcV+BIKtcBjL5dmHoSOYE3u2FeGpvPEmRTzaaaCOVRDf0OOxXItWL/V6Ncx3sSXvWKs4orXMk3PZuVL/+ndAqb2eWsQlRMZA44rplVm8mY+5HgbwEu4h6960wscQU5VT6BcKmOiatLDg3OUGvvWxuVg4NXqsQF9PXlwQeL7mfQS/3WshoHiV1eZHJ2/RVWSLvX37TMKYAlEyXQflc49n3GXKUMdh8BNm/S3WXiNJHlY9diUBABV0cK5Cbv1raMWs0zVVxdNUdwk5+jM00yRoM5VbrOg5rF7+EmuuwB8yW165Wzyyh5Vw4+sL+vQ6jlSvvbvwRX8g1dYI8XPFnNhjlMH15gmYZxCXbPZ4xbba2IwQwtOIOWbU/ga90vBzskoFKfyPOdCe/5WqI0MFsWTgOKaH5TMkg9O0O8cd2rpnavQcXg2vTW6QkSI8tPd/n+ZM7egmJthckkwFOt39zpU5IKh+pdIxqHhncVWA5tbmvaLFyQMVY/uUC2r8liW9QSyTFrRO6nBLRdJqRbe/OPFsHT8CpIImrJZX1ZCZ1RbNvDIbYBqJ7cwAuyRPfoK0BdAXVFYh0Ych7ZLkPWtqjavX2OZeRwElecpyLFXkPe4tTgPD1JxRopWitoWuOoKQnokCXQMWgpJ4vgFcW9KhO8ehDVD10lVMNyltgGjrYMWuJvQl1zvV532+UPKhPndpl93SIJs1RqC1ABwqvvnnxTcyzdjPGg79iLoLEsDuQK8O7PiDGGFBliRnrHIhhLnK4F9RaJgnWBGhFGzvcGgquEN4PDwsSgCWZ1IcYQTGP+GM+CzuVB+metwCpQ4eDlnlU+jd+NzTxyvd9XV7KsKCi+JE7al54TADfVTDDx5+zJwbLga4D9pi/QirKmxCkT7+T/5K0n6afGPzxSUvC7Jsjls/Ca+XQA51sN+gCOnHBMldbRv2QFt2s8aU2Br8MFLy1oN73r6tOg46LbUEpzDwgcJ9KNu5bvBrEJBTmfPBtoMqrUcha5d2xTUtywGrYyaOK1y8k1OPbuyaMdaDOb6058uNBd1b+5V+GQzS7JSIS/sbgp7cv65Z0TtaLamI7vUvnQ2Q+ntnTiKQD9VQnmvNdZ8qaS0D/vgfNs+V1g0FnRT5FETKxyLSER2kc1gTHErHxJ0K4/KV9+F1gVeSJexleuqpCIs1HL52U8Yg+V4m742HYw9KdeZHSVSwaDuoHJwLLBG/b5KVEY84IkYcWJF8SPk1VkWERnGXXhuCSrypFENP0uAQa9caQZ63X23BCHpewqWz60yUe6xe7WBNZkpk0JReNGsoeHzQhqyyanYhcKh8dKHtchR+ceGzOqwYxlb2ylECUsw0K2iAUhNuW4ObodIGaI50Hhu/X0XP0G34ADMrHSi2CwldVRwNn0CzWkJgyJtC4fzv8+v7A7AjTSUm2/TsmLWIucQkAgRHZVWrrozbKqc0j9aCSE+fpZtvoT2iUsk4iAAoHb7peOUQHFUY0hidLSTPwFQPJKF00y1fHvw2EYUF9gWUPmze7Z2JEsrpUIMJkbcEqDgyPHU50eWA1qnfLl5gEnSJWIJtaofYcmCp0fiCno+YzMxN8h4FNYYtEocl2YL+SPNdin2wY3kvxp9wTgb0U4iDHZnhoQLJw9X/Bbooh5jWQuPFDNtx1S/o4zhD2kP/XI+dgJbfHQ1Ofh8fQOkv8IXZiFHTzel8HdaqXBvCl9VeRlTAVj541CxJJQclI57OfjeezgOffvit6hz53jusmmC89UZoxSFVN50ZgN7fCEjyoBdoKLhFs4369KfVgnXDdav3z622xXi/IXU7YdEc0QSlxkqU7IU5r2LkQaMG2qHW+1Kj3+JPg+X2157TJdX3MfPSjIK0lQADt6+Dgd0akL06krL9YYbkjwlvlYbNAXWxCwUFOc2ZBr8rpoZB2Pwgp8v5yyIYFwrhFJPvFrirr69s4kNZuy7nFQZc9RS7AoL/2e4jqvFL2v5jkKx6IFDW7YL7wfr0bsns1vJi5JWe4tpK+vE0IPAUpKPp18v3FWp58yvn0J3wzjqHOUIFDt3fRA9s4n59UIXVqneS4IwzJjGpgBz+4VwFqGsAjh/wN10aXcS9BJ7oYWsLGbm0CRb+1Z1a0PGqiN4zwwnjaW+tH31eNpya0Rz+U9rW+nK2k8JoKElLDkYPTUPcRZa5sdD3b4JmhLn7tDGapmhlIyuhLh0zmeLAUvqqMWQve1vAqU6/8+n5xaaxoch3rmWGMaPTwlyXLXwbgzlwQ/LVTjUc7WCRiFDNmHKaCO3r+kIgupywi5Y8KOokaZ+FYgRW4seBTStn+ZEBJDZE8xZyFUH+B4+vEDmjLUfk4jTv/m/s8ciPqmVjLU2Kd7biONX/AqTgBwPiRoiBEQZgx7sJU8lfhGrEaCgz3rMx2FGx33OMm0HgRDXt3FWp4K7HxZfsasUezpctPCHWkB6Sz4x+Ntpe3JK23l+YPZWaEre/3/N8cUagMVkGph/Fogx3gQs0skn8sXAfrV26021OPiujSnVyewEf6In7qkw8eh6LQq1+4kMd0SiR2L7VIFiIDqQ4Z2lhD4V0r1Em0WT097qXuqGb1fWHU1XoIQCJeyL3zYorzp5H6MOFyExNg1EplwI3UWMgbwhZ1xgHz0eMVTn6cQ4C0kb5sx3rPfwNozjxKV5E8BPsDbbU9cxCjmsCiPIpfd7H3vlWSMnT+NdFLBgMQ8J1+5UvSbMO8P/3thp1iAUyjvNxQCEfY7KcjgdA0W4qlW9Rn3JqrZp21GWqe/CzAtOt9eXM5PXqeUTJmwop5d4a+CrZnn7wTt4/UiJ6O7qW49M/BoCJ2WPRw9BIadrePXdftWMg/uBsOh8bljy5+9CwCib7rtxekwE5Q3z71rUsRR8LwLPyx4Te5Fl+iR3rpATw0Nv1eXNOIYf3F6N+meGAhCPnnmhglPiv0x+nywbUAFIHZCqBJiG1FUZrBb00eb/IoGAbtBxd7e5MOlGTyNHCqjwS5CQRMnsvID1R/njjV9jiUCyoSdITgEI7mR5RrB9hOH1w2hYZoCdNXGMmCJDuCZoYxLXLN0t0TDrMIy0bMPVk2qK6QM0DQwqAAsuJDeNeTU9XbtXL4wrEqZ5TeGLw7qI2uMoDe6OfCZ70GyZOuDmQUysDr+QiFLQKZh9HjWq0OYdk7hxpJs+icyFEpgnDioi9rvKTpVKDEvhrGPfKWuiCFghYvNDWAlulxZ7wKs6S8PufWWqmeeQUOThzJq4FiRuZHY0tszXs1ruBANL2R0tJyTNAxT0CqBXhmUA09GJxLfFhAYoWk2f+9DeIVz++sKXr4o1U+OOwyLoqPzLisyo3ZN36jiVxl3zUi55DHVP+6SncjnjGG4EFKB9AdoIomr1CIoYhi+M8IZ3ku4AkaDnzuBuYT+Pl4mUzRyis6W2qxUXTN9E7ksmRXknu3/bJdBxEbT8QzjvG0ThPF+mJazjOscnbcMD1Mo5rzWT+jhH5A+BKMTcPXL2iyKg8FMYLYD55V7M/8BYRpE2k0gCKAzrUvynlRYbhrGwMVyK8STJROFx6AypO46IEs6AcxXSYR7GhejNTH4K6PCYNwClS5HvwlGRN3NxoSTjwBxAG8kaHpiD4jEErlBEAYZ1EjWFxwzSLywMz2KFLWZfDUe/Ba4qLDcuyxH2tJk5W4xNqjE2/wFpF0rLWaW3/ao7gqte07t9s3jrWdoDAXnuNSMoSE5JLV/dN9kRrWDBSotizAbXf+P8EvA1r0MMg9DtQ3tp73tkUNU8zfYsp6cyDKkaMglhLWG8G7WYqA5aJ8dLUDuIeWPTZX0K0lcEBKYY6daFnIYGZC3EViYLzDe1hZ/2ycieSiL4Ft8mgqFM17oDFkxxRadKDzocyiYQvGUcS2HwOkE5C/DOzYMDs87I8pcRwOzSbcppS5xC7Xi9wnsF8KrwfHBWPWY5GaqPdxMJObucfrYoWrY5Zg32UHqEl6czBjA/ASTViL9EvzQt1ClNaetZpJZYWPVwGOLM13ak/9umajXtLBNivuP1KZfQ3GJiLAdoxOzCzHZ0yuEgvcEqZ9iQ+dqyE+66599mAbMdk2bq4tz9anjBth8w0bu4q2epmEUoC0pKuF5tJ/SthmDW2XxkCRjf/BLbIVj4QIHwUfSnlnC+4IrEMctSx6abGDpyEd044OsB59lQNuCCul2+U7HYoYFrVDYkjb3TVUO5TBqXCOJaM08vQvNtn687JBVTUqFlIGWNIfPbzJNqSmhNBZwBnWqVbTIMT2nfKr2Qzm7Dm129pKkuzcEFowphVxlkFILPjDdlHNKOa6g9nkGoqvB8p27SzZpwLuOaJKO5+YmlrO6NnMd61tgyvz95I1tGlrWHjbTxhDjDqFNbhculzlhVG3E3mweKO9FpAqfTzRAXr7gysGXAdOOKKx2zDMRJB+3bCq6aL5bXjuK4w4DOSpn5VV8KH+X1sLa9VSnUoRJq/QDzWnbQJmpT7kLCRawCsMAudyKAISSTC2eDMRRqzp2FZm0HjSEDWcneYtPm3LgKmbux3oZ/HooC41NrbA5Qgpy65dK2UKHPrAIZgcqkIKdYiYQnAjbbJkhNMyYIxel4lR+bG8pGofLz8sqwn9URMqKA6m19G1RPNZhYgnw1b2SUUqrJCNI364XBC6g/WQiZ+rgFNjo2Ni088pmiw1cY64yValGqYnDF0bKnMxeXw8plnWNEhyivKaSvp1e1o7hTR/dRcnFLXIoDVny/X0Is/n9Asd8UNPCP1N2bmYHXGdf3fjEEPf6K3lMTqagHJjZNp3tZ2XPLibf1mEgnvEUfTKulZV7rXAVbhqOazCcAO+s+OAo3Uhi2jUan9P+5Kh+cSyH+koMRXcm3LbWEHxHrAjQgD7tBx/71RVM4TfoQM49MyeQdAXpYVqGZgCmHwWjmv6rXOvYNdMrvg6q0mY6YFiHuR3DOq1PiXtt6XsL7srVugGPtMi971n7z7cN6ppjuNpP7lGkM/Hiq6do8GWmBHAcCUt26vdaAUqnIV2aEZ5j5LZyDH+nYnrUULm2HesmdW9y8UyBXMlzFyQ/SfxymQgGebtW8cfxjG9GTJhO26Z0LuGJ4wK0u6SVoIHbX0zN/WRJJUN/58bvxVpuDy1CJQ4PESntylciu6QBZX8Vh7Dzo656Xgft+/vrihEHFt0eL3mMKjuVtO2+3A/zlLSQZZzMW/1zr7t/5iSIbQYr6orSGdwjFqlNQqnq2/7FbDeqWrQY8taap4ij35R2f/VpxAGQv8GJiOttmRit7see1xiWp5xV8KikH0WeaeRfEPaE8CcAf2tdM7ZdhV3nxCZqE4qjhnqaqmCBHhgnwUGKhXP/QVr5uKnQOpSWYPsm+G9qcovojyYcC28Fdhpq9vuGXfDDS9MZa5PyV+sWltJgLmX+CdQcCxKcrHGI0u/rq8HpMlWafoSLCsqwQOEFv6D5VSMELj8nA+qWX+JS012GBlC5SZp+/qkK7wpLt8nzaTFA5IhbeF0YC1YvTBVJeLmP5uocyS2ytmFEVcLtUguZocdNQ46OKgC/W4kMKqbWn3ibLa0EWzXCX/0aFbpToQbwuCzxatzhCfLIMvCOjS/C76d9vtseTZmbE5T0XLanle8/x4YYy1/XDwWCmxqi/QzT2R5WT92t3c3l2Dhni1sAq8fUwSkjYzczI30G7FanAdDllXYu8+/qAuNUUHfZWkWGyGeuSqBCOPuosz8wl+M5UOcBt1DaIpHnZQGph6m15uBGMHkWsmL7cj7F8F4Qf1D/jb/kMGMaMDS1rgH55d5EtTRolODGiqMwuNi76Bu6A1eJw1PKfsGndgehN//pp6Y0NUmHfxaxXuDij529U15CMAWzw9QP3JYECZbvLRuWwoxgQv2KZScwMfry3kNHi0HgmuzZUZwzbcgXQNAeLnOxjKRNKJnmVhgLSdoCMfw0nk/FoXkovhxHML8EvfJwPa3g4Lhb8izgGGdF0qWLX+3Wstzf8ddS7AJskZz10oHzRgBA+h2vsNmsI7RC2wQFkXl8ESMY3iSMtqUwQcYZYJVJ+X9xmMbgx25f6/Upp/A+QYtO3T3H4Tq8igmJ2U3gPiMm9pmLg8KpjzILSsXPoSzYA4igPgHTeLVuk9Q7DpYJwmQuhp4ZPvzjqzwCmwzrZmMcaFysh7jS7IJ5O3yKSuQSZckjlXbedXiaCZw60IcDQKKROwB3smBMXLIzhh2y3LPwHvFH13Ze5cxunhWrfuM5UtCuSBME5srDc5QkvaKLqyhDPI59ekEYe8ARfiVW7plK05oWYPwTFlsVZWZ5uHR3WR6W5UGBrotq4UJmgksLnFv37cVhKfh5pVl2H9O4KqJlYLSzkmYr/lVX2/MxfXXujH15sviTEpIlveYFLYisRloantbheFqspW5BTnTYI/TuvtFBpwLv83EVeMisc5QUSE1rCgmg9L/UovjQBwgrQNb2vbhsvKiDHFpED9s/9k3mPy8h85q5IqnT1J+tQGMSlcjZMyltBGP+/pZY/SIme79YRIF88aEWjPd6Z3zrndoVIV+JLB2jNaif6tJPPMQppb7rJxppc6pD9977Ubq/OJAw12np9AToasubG3LVH5JLkX8ofNqqwxSpilA2N1367MsEsAxbxJrcIo9K38WVpcm2kgVrhMMCfcXqdPBW93BhPYKnKakjvuWScLSBgeAM0LJQfQdfqJUeKRJgTucJV8VnpXAGUjKmnXp9uPtQVtPHhmhqvqAPM7FwRmxxKYOSfhRqSNYUBciVeXo+vM/UsEvogLQPZr5+WN9pMZgBptR4EuSLDJ0mNVNijkWzDefuofmM2ur/C6mObACPC7MzoTsrd0c5dOqR+PQJrFIj6nI6/8cydwVsd+rsoCA/vBI3O6R77XkmIIMtlVeR1qr+pIUbdlY534otU1/SpTk97WRJgKy5E/vFe53GYUD428GF/f0+7Pg2GLcMjnk1rrkr0K0Pq+C6M29IgzrmYo+J/IjxDGd9dAI33tRRjNBvznlxfvy0NQOeMw84luJkXay2f7H6baysAwm5Rx4jR02g2B4dQXXYvzltQ4oknaCvdHFXj//MzunAxi5EGEanspfg/AWcVZp0Wjfy8u4ZsUlHDLPpIQ78yMLwovU8hzs0CdF+obwAOGto/W6z4Wdd9W9Pr2wzL8smXATFVtUz6SqTuUTZYaypo103SXWaizSHnR2d6xhECI5tj0qwZTbISHCU3X/0+xUn12fI6X3xKRye54c+3PVSjI4wE52BkG9j8EojfWKvRynxuDQeSIQbsFeXYk6xXAW4eF1SgGMWsJb/Tmmj9WZJyRMkcV550316k/JY4qN/cSFIFnbYVkR1hOAL2tafWr7z5BNVP75i7/aZg5ZSBT8YL/Hg77KSWrGKJa3oLyuoyKHpO3HRUcTNeB1+0wleyaO1xIR7qBU5t+OTy3Oh2+Ux7waTmKlel8VcE3xUYpbq6gz9AdaOCsfxPO9hX0Q/Pe9Y2PX0hpid4MSU1u4Wk3W82/8Si6ODbH6hwlDB9YgJsQfg8PAOjR5rmyfu3SV8NNlsNP36kSs6fDXdFAihX21lfwDIfB3mKG/0XltTZO5hEDnnS/J3FRJBpmRTJ6HN6CnwJ3GaK2N/D50t5n5FdFZihP+sHNX0DhBtR0r3ValZlqfFFQHKjyOaiKLbiD/gQls/itMwc/QRAxMXWcyJiqbYn2zR6Kcj+3s9c1hzFh1K3bdsKGtXtxOPquBhHi89UZhnhdF/iScVZB8Cin+IpYhNPVhihQbe9/CSfcgo2NbK3uLPOHf38N0tj/EjdQ50Wo4PRFa0iGYjEHhHM7jkoR+hW5OzkLWApNZ84uCGpebxj++jLJ1YXaazCE7Amb66h5V4z5npwE321YomxfEZhKmld7gh/ewsZmUD4jsFUg6pfg7TnDPmDLANtfg7zwl3r25Aca0gmETvcNqynwIFxO/NuUJEq7o2rJl/4taUOqi1WcqeNPkGdXtnJ5Y39iAvAMs9dHEh2fzVxwniEL20omapK4JBHDxKJ8Io3N913xmaQinNXOwULEmdMBudbxAV/hv1g0nmPhHatf+clOX/9FsHJF2sWRcyTscs4oVOJq8QovVzoM50uqYW12Tyolrady9PWfizaFsKjpEXxeugGpKW4KdOc+7znWlgjlgD03DrxEb71MGFV7PNAeGl1UNgmrKNPAysxCmt+xauLAh2I82AqSqqXBtJXln269FXp88nDhKiNcvU4epBsc1fYo+1ULqOQosgJQ3VTEHVNNGPVzjMIMLkXaLiGgyg20XP6zinKnGuPQXWAkPt1zellIM+5G7E/F8bBe3jOxymgVU+EVt/xA84BqaAgmtnUqzL8iJCgbNk2KxBVEG74Osqi/NyOsL3PzfYDiGO/rl7KxLRFvCoX6VoD8f5wPd9j2Bl+qAjhW+UtQAwZ5bs7XuLWmUIbqFuY6qo+wn3nvOk52GB0rdpsY7Tq7PwCfJ5D31QjE8MpbYpK5nA8kbS8BI6xZsyTa0qYAbOeWT6V3b657XgJFalIYhDlMjkf/FDs6LTMv12na2w4FCP6uoB/F0ddqvdGGS48XtfYDqBx9ere1uu0UTyiI1Smldvh1W9EY+H29MMdPd6357emP7TWF6wY3tUsZxApOF7Rt7aMaKhQZt7x/hgT3THJLAvMfvbPABISTpH1NU9/g6+0sivIUkzdj1mg/StRyOCqBEN8P93MGFk9PsRgUzdlmZycN/oFelKNGdurrZtvuZBDrurf8P+VXn7AtOQFqC2FY1+qzTdRQORWUEJGWOctCWWw+fYD+JhDC07oRhGEQpvdlsfeEE4uvWDV3iq4s9cQt+NtwfHLnuuMzEJpH0e25M597avhz+yqQ6TUummgN9MexCiLfX7qVwcK92BFEoXzkJcbeWTicvttLrzq0DVjveP/IaD6IpkQ+PaP5jyamdfIM788KldVmMsW/VFdnZaum6dsf4z2hwQ+xeyTy6ZSdqbTThl4SAe+1jbJZzLvYb9dxjbWBfcEgjLyB1TwGcNPZ2YSuCXB0CIKwBm7KjU7nNFqQNDhtqfKM/tbTkieumLwP/lwVrP4zl8RDOoJV+0m7+LWOT+f0oSVITfz67Mfa82S9nSt1PLUpoN74EbAI8VWS2I/i5dARrnlb+0xzcYovucpwzk8FKaCJ3UJcsxCgd4iHZEemTrlMHXVgA1Y/scaCIL4o+7Q1PWR+x/Wzm41tPtDsXm1KOj8r+OMj4ypS7WdI3LkbIypglvR2KVO8kWZcxtfPP+sgxi7CblkLDHkFah4CdLuKyfczdpagPd0ccpkxqL4a3aAuvU8X7WdVn4yFfeWuz8we4QAALAN7HWjvexE2RPgKTk0W2KF4Ma1JFEXVQAllCb2d4TWFJ3AMq+RfGBJrkl6hdSOThc9cT19/7n3f8C693bjh5F8jhOkMn3BAcpq3ZY3Ct2Go1Am/1ynGC0Fuo4iDPODati0xAJ/KL/mrIIKiNtZ9sLOQ5DDONviwD8TRIAGW6sVfq1cZsNylHFj7IKP44V261egp1jBdcbQioUKW1QyWMwvM9JZjK061o9+90jLWIdKDTFZYP87qPj6VW7gpxEloXYQDSh/zAmUumunCuM9Tzw9hQArUkhS+mKOwR96OXINHohwlx0Y3rNIO0jNj2vcX+WHcXrVq3txri3q4h+YUZOhPshhCDQrRE+kgIzkKvp4vImXT4csR02W9QMSyc8Uu/gNza5KcOFl1mJk3IioDwqo3gBq48zGPR8HrpWcLGF55hAlsH94V+kCRtRrUaDS6rj9J4Asj6RH4lzAMA9kN2hD7KGHsRD3F6rbpvys58MYyj6fkxeikAUURyN0Vc+xPpF6xIRsuFcPsNpy8ZJ3LN58wqpgOHZcgXhZuuwDIRwTcA4d367OH5oVzkEeYZGewea43AocmXRPDMDkFrrDVdNkdDOGoWeXTHTcpY0hQgUzGetSMjfEx++WjzHd08/tKkqwqEOqmB6HXbgpLJw27+VP4Nz4XZ1IsD/C5oGy1crBkZBV3EyFEIVRnNL+/NjnPyg3XyiK6F+wIKfq9HgFFG1xJPboiBrsxm54+Qmw+v3QaYzSU0NNemKRBv7+MVyEQcl9adgMEXm6ICeqRCEYlvPiEgBlh3Blweo7WEnKrLgndX8wd0HQGFfYBLbSFAmJZ8BR9Q+5MWuzsDGwzyVIfzLaY07DZAz1YLIUrTT/gAWEc+5qQUabrH4EJ1Tvvc3FqMTrBnQtf3z+6XBECRh0laApWb2PCW/A/aq/cnujDu0972NPEDIZVxNhmbKxeldZoUGJ8OdiQtpfgV3Nac8su1GmMFdSguvxKIEPdLRglFF/1kBg/8lvhzt6LiiuoHMWhgwOJsCuyWmidDpxX5XpeP1YFd9jOI//LyhNi4JCYxwJ9SrUTZ+tXm0qWvYdFOA5Dn9BL72+FDv01T1fXkd572iGewf/CEqJdRGtbb/1nqehy3fSiCHJdEDTadgCcrwHw9La8BKaPB24w6jUcgL68n5u4/jSwBUz/o8LR1kwvQN9I4zsENLXAjLz9lv/AYfevzZJwCDnGXmG428EMxwO/nq0tFIa1JpXwSnxONi67x872VYqdukODr4b5//zoH9DCdF8btr7ugcwJAMFrzrKTeWB1Z9wcwxwsjMV14cp1Ow2mFFdZcXHV1o20MC7+/+B0kwHFDi/vt0PeVlhwXjyTifTg6upWlYtYJ/AFe1RNHeyYvrGxTIMq6zGlxpL7YaoN5CDJftoNkpiND4kYro2yNFpgiHWz6XUf38iNULaYehNIHFogcDmeSGBV5Z59XGX4Vd47MZpRURAV4D3IbUoF9GLwg+LSuEknbf2A9QkeUzYRAxzpWmz31VEUBJi5+DhB7PoN8TMdQx4wYBnEtmaoDFhPROeKlDfRZVRQ+HR6GP2aCCcNH3FA+BQdkgvE2aqp7OjqcTtvWOe/NPvnRzhzvt4brJQLJEl8RdpSPQsfvvmj2xBKFD77YuRJP0Rbe6C9CnXyT2HL94SqSP3etrGpPRDMk6bVXvQ2SacJodU1CWV6DoTAH12/yLE6PWzWBtzlakKhCrQRjeNI8Sk9MsRjV2kj41VDHTssBkOxlK0mRSGzf2sY6CJaAcBiGz9dtuORv9mxY8QPSaL8VYMlUksB6sx2k0D5nJE8iXc1jmQ3Q2XfhqLWV6Lcuz0xDOhO/iR4V2asqI2dBoJssRNSoF8Ve6KIhxkglVhmdz+ODEaMmudoJPFQK+JhudEho9IG6hz/cW8NoiewiHk/1Z9CfrpiU8NxG51A4sH04UmZVgkqwFpsX3/EGRN8Aoqu8sD0pPaePmeh0bEzsk/8rttI/6vXp2hziptsN1ddZlOo6tOelc8B9v19F4PdmT/b2hiSVb+LL1FiDFM0iVmT6F8vn+YbeOawPZ4GY0koy8Y0ZdxEU/TtWAvz/eeLv9NqtMEquEkrobNCzTe+/OcW+o7tz+YbHAqN7c0V35wZjnfJ+H8N2X+iH9seB0dcGrvFWmjenwLSGZf1uksOZ7vuRQGjlJEKOJztQV2PQf8IJlC4gHSWucydFNPRaMGB/6+Sp9lws6H1c58FUke/6Df3mQ0fXxYecrlcl3euZewN5IJwxFuVU8wC2DBlw6S4izcA/gXzilW4W+UfcClqHzKS037ggSeVCcV2xXB+fN/VO3x+5sfJtHSwzy8iTECH8KlOUuV2iS89BUYglu55ks39hvKcJjszPH4g9MeybqcbLhpt2nB31FCJhSp+x5Jh471JbzA9Ij5zxsQs18pAkkvAjpHfyBRWhOtosqK9ERFs5Nkv+LjQAYcdJtLi1Zp/DI2FhYH9WVO+IvpKa39gMRbSvy6BzJI785Btr8yQ9bSi8ENY8XohpWVa0tMutVI4U9lB0NEpV4amrlDFb11AHwDSK3CmibnQymRyVSJRbdblIWVuDoNCRwSkXApQczBL7mtGMtIjTEQrnuN+/NlrDuLzqXKOIEC1p3Kd4nIBkliARL8gyLmpK9kRoA3YT2xK1F6M1j3WSPvpc2EANqSUEtLJk2NSWepPVIYwfDjzVYEs1TtOP7pDwd+6821tPPb0pG9F49ZiulXJuRG1JZHcOLnrS9e4tFKKFODeGAX+t6m5v+imC72TZC8J9ImQCc6YIHJ/8UsfK0LX0kLvgRkOvVCIu6PmYhCprshToXxotbUCJqFyY4AYkT/vrqCvgBm87mL7f55amy75AHgJGnj7pbvVqaNr7mFM0s3klPQVK2IXycvh+0HU7utpz3MOqZjzbH6wUn8r7zBiSn5PBxqSeMy40TIsK+5PQseTEDaQHxps0TCKwG9G+yQBm4bjZDDbCY0sMuJ+Uh+0mXbaUtMHeiIj9kMg/gAULpB9QkP3S6kVl7C9LhkXn0Fzxf5s/n4oEQvTkTnWW6AgSw1poUNXIDydeuNTBFiQ+cVxQiuQbpX86AUG4OsmgCNJqxxzQ7Ey1VGzhUDSNDrkEtRr/re0Asxcw/nzHS8it8Kjd4Jdp2niWDspJoL01octtoOxitICtRButlK1mIi6IbAAUIaiWR4VZPvLL3eU5lQPa9wxwr8Vpq6Uq/sDVbOs3jV1YVD6PuEXqNeEKcFgXyg5SCoSEk/0ntU42WKhObl1HDYO72Cut+NowVx8WYIXmr8Z+UkU0+EK0tILSd0j0AyhTE1Sm/ICJBVkQXdSfKwG7uVzvbgie6y1vrbHOMsq1y63wYBR8ipT7KYLebn0Np5yg4HhCdZSDM6N/TP9mjHeJClJGVtaptpMRRVJn589irawJ1SD6JHWmBHUef8I8t/VhLh/2zjqtwqWlnQUwd+RbVDz0CFLHB5S54suO9pyraZoVT9OUcfcNNDnym1dpF1WIRm/u8dYKTjbo4rA9hG4pbvVuOLqHHStd+0g7qPcTvJ5SLN/jodbSqdB8/Z+aXB/g4QCbJm1+5VtEoGnQcOg8QrG60suSZGD/vwtGt/9OHhIP8zJFy4guqdEBaQZOo/70IyLGK+UpmI3/2q/4Hd5lWWCZk7HMwuxMq9W4n6xNIsAMvy4RwlmreBd0ZEfZPyVUyS2yrvGSgxqtmmB6DI1hIkCgaDWg0NsziW+X2Dk4s8OEccTBfCG9srZk2okT0rVQ0+yfF0Lg8MrIHVLxJEkvJxqp3QvaWsRGSTxglEi5cvr36mgMYHYQH/w7GWGtqWuhK3X+60MEH3/Ff/vr9aDS1jCbndDOcauoneexLEQ2S0HgOGDa3lgCOqffA74mvvhGAeyhqmXCyuWyBBWneqH2cnBgoazc5XXosJpTyUaTw0OEDqtpxd3Rd6oMV/XAYvu0PSTxllz5zayE7SABi3tcF9sOn+Vs5AG0lFq+3uay4B7E7dRJH1C+T0bYvhYOv18viv3GR9E6qXy4+/GJHvtP+xffGbSlVVjq5+AdHDVnCBOyiwqhcrJEmAAYyKbyzJXHhWjdcFOhxmjbziJ2f6X+4JXTJw3fP/ZtvIVNdXdDL+I5Ak9Uvdeq1WlDJ4hPs4fZW/85Jrr6d4gwYgUw/qJwFnlh89cHtHN+hzrhG0X7PnCzt6+di/WMGpV68VfMsY0P+kOZKAFEdVp0BhLnnndEumHTR7/0o2fYdzT7tSYrmQcH++0EpgxDxp2K/n3g0MFFEdEULtT4JC31rGzPoCYukCr0Y52yZZo2A6ybMFsSJeW1Qii9BnoZhF1xQF4GI/hFkrLwOse0v0YXkqU2oDPIkzEGeAV3J/5HXmTMkqFyF23lH3GMltzKlTv8a70gZ4yUGQpLVFvdo4Um+P01ejBQ6cQs01qcH+mTJvFNACEtCVg+J62iqq/qF/CxSpuWCh0y/odCe9T5ZvYlKZ2BVmhmWP3uuM+/75EFpr1ISgiXoQcse79vnT2b6MYQ4vgEYsRe/oJiHJ9L3bGozLSrQN/LTC/k2wmf+4nNokzUptQxtoxRKI4CR0o2N6d866SDmV3MA0rw0jKO0PQ9KC+YSoxq18VozSWNgRztqH3WM/DDyhyMfYabzX/E7/hBQ4MSL/VXi5IKm4geThBiq0GCBD8QjaTzfwGOLe9hBj+7NxK7/wS8JE4turmTrx320/XwF0nmI6pZlG+yUU8XniQ2MCgIubdCvX2DYuulVPWuGdK27RrPNQvbpF4hkLN0IGV1NPA1joEQTuGvrXKpMc2iA4uueMOGmMjf8f9Gk+vTh/MW82CdzORqgIW2Lu47/UlmcneI5t7sNij/I82QuB551ftAz3STP+cSadMMA0eKM9nsvkAyfRIBAGQRM3TKKiILIE2B78kO932xvVSDk/hEvOFwF0+gENKsRBxmR2lnV6ozLOf43qSTTsZagaP49xkLW9gX7sT6XeTEyUq3DjqupxJtmwF8ZAAtstWgJ0INrr57kZxBGPGBYiazh47Ta75lga/CavcteUlH6zU1RaRFBPm6KzyOxPjYcRfQ/sT8YmqAVscBN+3uJkOiA60NEliGZ5Rh8zjUfAJjMYGr9e4USx6G/3viiiShNVyRJr0Rjce0k7Ewsdm/u9O1vKJtD7ln3UblAHtq0tiuB8hqyKdb87CmivQgFi7g2TiYjBwB0H0FqIbLWBcdxfiupN43yjS7xdGDz6WoV+rKRmVkzld/GzVk0LYcXgM/8gMn0e6qGyE2pUNVk7XaFDJ3faVNrxvLRzzf8Han3GpVuVR4yxSSsw0RDMdrmePpsyzmE57AUKrkivR/wXOvQo3/POA/9WFazFAtC2sFmS+3z9L0XwQHq0AiIU3YIUA7wtd2lyS8DcxBaUVLrTX/kbrzOJdJ+E1kGx6QT+aevulVk9grFFKtifwksLeQMyKbdFKjoQ9nGpJOv57cENj3InyJQnYXE0BXAOqEnDPpjFVeIf8C+IEy/z03H2xMhjSSbMwLjelv8FP2+zOvqXX2O4Xwu6/o8z4tgajni6XQNyvxtIOOGulDwZrcTMf1E4FaVHcM3prNlxRQawHG6LBd0WMl7EHkhVnfsLIkEPxZLRGd3Hd7foYq29Kz9En0l0qjP7fpm/pdTIf1iHlyPGnxXrk9xoIiV7y/0ke/Xv4iDHT2rYYTgGvCQYd25GAIKEcN5CtQmj/2Ta78PYtVZkB/ISfHDf4AaFD6Xb1/FEPUrWoFbyJxTzded+AlnZI+0OXQOav/SL88jkdjkF/RzU6Wysi+44I9fI9G+A6qxjS0ztHsXxyN9lg+1q2N03yrAfCtV7Fhe/gLGgG39fcD01rc+l02jy0+9Fv5Ja3xn20wPyzbiCeiRsa65qg5GF23WQZqdEJDeZidl9zuqvSD3gx/kfn7m78bJmU+TEtCxliQN2NCltKJv16iOlhnjbi4X8soHFSzNsNjNyv8zKOiRaMIysOIjZeR4JOfhH8CClnHcE0+HTu56TJHo6CR9GzQuLP83N/FT6wUA477y+EgetyZwTtH7BiGiU5yUhwIcHJWgxrHESOwESMqQByFLI5mcB5W2cFhI/tdi5mMb+0a8xKDUsUTeLjxWcCtaDtLWvDF2Go4pXIBs76RKlZvZgHFsE3wgfgYNAQZwXpXwxBInmFci8K8mKjLxQ21W7UzUY0lfQeIMW/GgRdm6jviBdA8NY2bcfPWyuOmU2dxOr+rSs9MXrOdmSv+IzI3PiBx8vPqCIQtzT9KdUi+/Whhyk5JWyIzmQrS6jiONVdNsNDTpRrCd0hjYyevj+/DVE+fy5X0SaVNtfANUojPNlVExTsxkM0thbiM9/OobJkpajouDdZQlQrhOQq1ERt/TMwZVGAqAdkre40a7S9we8cB9hANtqblb75aeXpXsmnyHi7psmmtxea/NU+Ov/omMgTnmKVSdZRbayMNJH6Bj1hqJTsipkhfSLJV3U5T8kyoFnndSsR3JXaqs3UCwkW88GN8hY5qYCnu0FgHCdBUPDLiFo9uch+iQpX5EV+rCDHQEw8Ww21udfi3DYO/9J6+vE725Elhjxlp+RSqGUHVe3PYfaajSiOleRurTdRGh5jYyFSh9HA/ODx6v+02tCEzUfpCiYlInqmhWIly5hZJv9Il4gwiB3nDQ8ey6pBDdCddMqTwT344vzLP8b30ZoDpfqSfawV+3V/2/XsYKZIChjPFmWiqikSL3Y7rOlXhT/ApOcdMB8+9rCbtCupT9rgO6LBZGzL/0+r0sRqmmDBlNWFZC/NNQHz6NWRcN0/0mHkw/I1R5Hpe37kLTi0oRJpRkWQhUARf2s8bl33ockpFkNksDxijwZUeqklHQYTrHD73df/WbHjVctnVCvORkZKMUa0YvLGmWw39PDG1l365j7k13P9y+aDk+GSu+99obQimG87G9iNaLxU7yUYc5wJoItThutQsa/jlumabFNiyvhJ8KxJjyB23J4sd3mLlvTWGzuVq1hRIMnf2kcmvofGIaiNx8RKad3XGdnN0eOV2Dp/D6U7IN/dYT4222+9sy/cursQLouMGsHxOnxyROWKt76royz+Qug/UX+jmCBl50u8VOwU8EgPNOjaAu5pCHuqur5/OJP/4LqjmnBCcBE3KHjn3WaBiix1q3Gssi/u2VbRXpZXfoqlwG9wqN2ol9Z0J7mFvoMBoS24rw3fYdhU1MlWt1Xu/q9K5142QmeM1hHOGTtCdp9ssjOjnl8m27QnX3xOhFuzzHSyAjA4ZFloFfpP6oEkoeXeU2ouoezUnhB1r6ADF0oA2CNvRPr98eY8UFHkO2XhSgnMhYz8byYceawK7haDq53/koZk182HL1IMQZhSi2rOTyVyqwTyu2rT+39aXdgT+NXuo47Qlwu77p8u6lvWnL/kT5nkeZacsc1m9sUaxTFK17oNjXOJo0yzmxO/HJu6p6TsKHpNg3/6HZu3ugv4KpvS0QwW4C0ztOBDBQvGUqLCIErf5+d97DuRVTZx+nVAiNpez6QNcPu2naJvjJByvLG33PISWrGnygqB9EFdEMlVQ0sjdsRnbltE9xVPBxvRt1pttEns1ZLBzJixDTWBIolZ28hgetZY9sD4gcJTD+x3Gb6FlaG34bBv0US2x402vei6KzA7DaQkmWWvvz10hWtVN88VdaXiU3tJWiKn4iQmyMCs5g7JsYXovFkrSj2k3xkPFzTMMcsv8l3oAy1VTMHmSJr0OQ8KRB4rLsoo9cutrFPhkIYLeglhwf2dz96NLrOxThQ8NGmyKEm0sYtZBs3zco1xr7ZK62suzYGHbRrpwoWTSqX7z5S2Y6G5CWE/N4HeUgxklnkXBkmm4lSst56cnNohSuXTeCfwALywn/J2Ozp/jOlECxyqHDYzry9EG5PTeUft6QGbqsViprQ+F4PQ+7bGjcqRIdV6eB+aUWlwNmNZdd5TFRM9hQAeiiNmlVU8JEQmMXfXXPjd/0RwJpROWg65IxP/kg74tnyL/u1JX3dmPt9z0hCFkXiLTP/B41WrIYSrMtEqhTAdqtwZr44Ajm/TE5vvegLFr1oW93cndTMHp+78n33qm4JpHJ0Z9xQk9Mr/4NdRq3DDFjI2wwCZbd5DkRYGxQbsdayoRwC/AkKXQt1Iw2XDgm/yk7a8ICUvxFzXb7XGMSqNRqQo6tNdhv+tXF9OlfUUdJ9If6G/NxqlUGH2LWr4ZKC1e+JLFsOdj59eyP6LYVbbiBL1e8dUmiGfWBHxBtTSAoSETp9ULb9WT7ougQcbAMQQ9r2AZs9Q/HESjvUWuoNK349RrBfLdUvW+2PT2Qt26mljBLMqTPiJUXH8V5xTUoE69T0tPV/cW0maJfx42PBaaQUrZWCuSBOY3AeAJ5/r3VAVWwUbhyAIzk780A3ma74Utyu+R7Ae0hx1+zprBlH8WCZs7zLcfovn07MeObC9bGFfAfQYumoCq9eatBtr07vl4w/tArGuIC86rOALM+EYoSCFeLt63kf+5Lc6uI0dr/TDkVgD5ynAOFLDHa+vW840RDYW5+lVahDsdAvwQ0c8+c9Vdz9Y/9e852+Ff9RgbRaMMkU24bSWd4v8WQYhCDmvnaX8jTx4nVP+84+bgMocIPQCftx57R+lqqgk3GOIdEwDU1+I5+MLmaOyrJo3hDhWUYJrq1BBsxVmwAEaFH4MdhOxF5tdoyaE85VgMJK/UInKGD+bC5YoBB+1zH9RW6kaYJ9aJl7DbP/ycQizwpI0imP2OlNVoVzcwBZfo5rHXGQmyEuUv8rdarnAEqO/3hbFBCSIvJ06ENZUvCMN4k6CaXfjYd6qUQoGo6UDTu9hvABQkFuqVww3oTFPZQtnPZHl+GCNuockmncFvvq048Te5VVYlpl2hkkeE+5nTyroQa34zR3UPe98n+NyjHFbYIp/AMgoDnxGbnZl60KpKgil6cmQE0m2z7YA+MuluNLq4pzSxW4W9TPy36ndeFn5GR2RR6Cq/KcMPIo11mwb6Sx0jXO4Lst+R52vWp0G56t72HpMNZs0xjRWnn3MGYFhBos1138jw5dj4XMSRRDIbA3uMmHAImFw2dXp5Z+7tuknOYXk1In4oG9XvtZ9UV0qbuSkg5KYS/0QxOZhw+VEmqcbN5I2Ri33z0bRieVPAJ2aS7dkUfGLDY7M2oiypluZETp8mTTGYEvlhy+xST3+pVroqMDufAAu/Y3uCuJ5mqIGLRosdasZNfVqrDNWlGvgHfsRsm6d/CWZ9V7PggKN1PLyuB8UXXp6DEqyozj0MrTmZBRm0Fe5WixxEbw6af4ZvRnjA39OH6/l0GYXyRIMWNwhAyv3Yq0JZTKt9/SmSIOW6aHPrTykh8WuJLEPHFr3yVIRcwioH/1WzhFIr+2LJDRiTaG0mWvnJjC6Qylg4SrdiyfgHq0sZo12RwIerPbiAZctTvDpInmYx7BylRqHzdExOyLjOZdJZCFt8l8zjxAUkfi1/tmpl92o89x6hTgBxx6R/XUBShFNv4aOpaksAlxSCTcuWOuB1pMvyqH5GGODyXhQ2SCIcDh+FqH8pMfulDJfAbszx2i9UoMC6U0INzev57k50XCholkvtRt2OZRHrfaPGNbKNPfJCNS2UziFZYkfM/GVLOZh2z6sLW370GWNuXPHUK9clgoTZT3EpFgs3Jk03HnIZjoypLUO++WLT4Ur5+v9Tnj7Ew4H3t10Zpo/Hiib2RwZTQu2xKAheZZqzPIq5SxBrxSWR4o+bKRSmI3mms+Vgi0QM6KIW+wm5Dqq0gmskT5iW98McU0+TrTJg3RfmSHAEGQoz7LLNabNhfSp0rpMnxpGi472LMM9LqH9+GID8c6yxDo7EOkaCVCBBo+nIHKJUG1uCEc6MpKMB+S2pVKlF/VIB0yCDcwssHX3AA01DrMl8oRBD9YMxQqSrnbpWgirHh5B8YahXwqFczVGzYa7I0RWAHzqmKL6sbACuu1N0HUH5YdUsJffxuhBbuU3ma4TxFfumockybeUyyb37uPTNZFU7mfIhMsaejzHunqFv0h/Wx7nQdPabWq/727T7Ow6VP7UNem0CaZ7+j//oDLViNlf98xmPkEzmBTJA5bILu7b0ZJd3qNByiLdWl1pwtO7FNJhpFpF9h67TELYcEM8+t5v3yfvEXevkFLcYH15211bnlt15NWFhO4+0VF6XVLC4f6jY2Jn2zsjAJV/Q+D+RB7wBMFrTQmSqq6MS957z/Tp6mNhPvF0sZYHbQ7uzACmqXm7OYkOXl2I5muSHfgxqnvjOXGO7B6Wd+XATVKfK4l2gbXdfMhIgsFjPYFhQ0pAYKqa78GnbhwUXk/XqgkNCxcys4FdgpXHEev6uxgTvqrSilXFMC4ttaqfQbswqaV8I/wKdKEWQYHzE6elNby3k7IUK5o+sQgf3PRNGp2mJJkzU/QFtrviVnH6a1fBLFdMRL7fnBPdH5bnD7s0tq7+0EZPYSVjnU6/MtepKXN7dFy/5EG4fP0oB5z4isyEHfJyiVAAdOPQwYwu7PqzKk8jeL/vInhC47iWQcbT77aYWi5Kzv0glyVsaBEoCT9+E/oEkEl+oTaUvrVKaJwdcrn1XxdMbFwwBtFxeXxOaHUKNLbalqDR638tlmqLz5Za8C1SReIcvLUIGsmSToNEaYDw9l2DO/yR/EYzQr78R9EFVoWZHHkeKjMD2z7ojrMnuXiVxS3Qu3WQli3p0JCaEevJkmqSQ2l83MVWqDQZKRs4HR9zXKaFkEUQ6jvX04//s6V3Hbd0+4Ci+2NWkKBpwqi2N8irWFV9+sez2gh5fUDjU+ybF45y9sKTBkg8BOG2jq/ccIyXtQih4f3YAyCuhrWz6ngrKGA0LfrbNgXIMC0wdBv9HDAuypQAUQ22pj6qRPu3M/aPuwZ2CAL4Ps0Nb3A0hf27AW4z1/Yvdguh/uDTqg88/SjMsjMKKWwgkR2ZZVPf2hfDgDG/6+M60/Np79GUQDRcAq0VJEkDQZFaX5RCfr6TJJhK7yT6/n6UXqm/TzS2yOCOBZGuY3iFhEItauiDhc0KdPlHUUH7Cf6KyZ3yvLJqnyizk2An+yoJo70t+gnJ1kcKW82iAshz5fW9M62Qu3tyTObmRcyiycXnzFpjjVYzhTBZ/LT7Hga/MB2jsOzTKfPv5WVcPtOxXJ8QI5vLvSzFiDfHUVZQW0MpZ4exxgFUwhtjigDcWA+ResNo0lEAEP6JIMxg+QtueCHRrS5J9C4hOQPatdJmAN3jRK2/1uYvRJB1Z6xbL+4vXIJvwr3wFlT4ovSFEeY1pg6h2K0e6Z4fcAfnNXQt9z/b5jwIvJcOnifMGhckt0eV/+xTqKzZpzZyMMLUoUtS328zMxm+lWO5mcsDRZJuLUH3Mpc5CUu5f7BrLokkmdNXJt2PWGs08MHkxzW8FYKNrXoG/E/FclQzQ4Opv7P61BPqLXksu5E4lupmvG8LIlpwWfZkxZC7Jh6nwaTudFAOW9BC6zryfHtANnvO04mjDNu2A2JuMSfgJXgap9C5Um3tsSh/aOfGnw7u6Ajxv4RN4LHIQHd9ePP+97EBBGG+2/El2C8SPl/5kFdPkHiGGAwS4NSKdL9BL85NVzCTyV1t88EJtfDRcFKnIGNfMTzmHk8yIYSISpx54RD77XF8NkA8LWuhNrBM8b4E9CPyHOfA3aFY1Z5GZ0c1Ks9zT3Iq1BvSPalwDQtUy4nnudh/QwyNcEvW+6lJZk8xDQm0OZnEtFBKxDBhW/YAZm5DnXZOuCRLMr5d0hf3lweom+XG5G3fZiwQTwv/6Y04HQysjrekgQLau6RoA47/A1fD3R15t3cO65tP4knx4cp6e8Wz2XO7Tw3IO3LKmFXw4PUOHPd/ElmejO0MKYtLFDPpeTlnC4TE8o3+hZxT1+bS05OO1JV990l3ADNCYGzLszYh8n/kT91nGr8DkfQeiW4xIqkXdlDwUcnXsS5Tqezj69Kb+vUf65cev6jq/enUnYobTEyozEVsFkyXXkcZkXomiDcMihbwaDM78AM1R9DVL6gT6uEy22LE2gO3G4rM7Bm451QR0MUXF7tMhKYA149PuavtMtzAmkd5AaC7zqe3K7s6/EDQyfmIjUys0duDask/4VPCEx9zGnNgawEJgn9xabFtUEGkX0L+mLiLOEILyTeiDMQPD2uz4c+RomJ02FqT3e3mdH1p25UCLNXdnwOz0SJQf9x8rx+P/nQ4f9OXkHxtZOG/2R3m3WaqEbwTC3QYI046hAizytWoNVmOymYESqF7ZNykW+/+Ny5QVF36OoHBBpRaA8VGOGprtxJQOVt7UjG3AyCrud9o9Yh9JlEr9//UU1Iy+1Mh6pVOu8/o4RKSm+EtZU/Yv5tdKKT9o3qcw+ieIHH0LiysybOohUX3eK0UsfEs4SoLXHxXhJb4ajjCMYCbgfrdAOJnQfx4T9tSlwWv4s8ln/v0f9GCq0iLT8AsFZ0Ii7euxpJh6ewtmh1wYN5PXO5xemkVLpMKqMCejw6pP+ZrJP2aVekrbMC7nIj9q7AeCelXrhqTt4GXSKDEmTLUYn8jTJA1pHwLiOVFfOGFgehQlUzH/4tBexiIpD5S9smPpuOd2ukh5BhN0prGl/3ztdx1MR0JZ8dGAkxbIcnBfiIBvGN/FsnfWdo2cuay38R6fBemx+qFA26V8BiLpW3KZ/TE1Wwzt7AUDk1kc3I84MqecvyDhVEh3tZR10CE1dh9j3vGokWI8TZ34H8pEMkPIJOwnBEliOG93aWZl5JgOml6IsHoOIiA6UA94WcLgXDMFyUc4hCuEZ001aqSQZJYZ+SfH0zAdfC934w2bfjtu87xv9Jmm76hx9QZ26PFsacvuPzdpDnzSwDTeizYimLZUXRmAEr0/P/NAPbN9NBu951x5Y+Zcdws0dfK8i0gcEWY7KJBVpHqdmmEqrHbAe4Q9vaY9tQXibL5Cn7ItpK9uKlKoWHz/lwPrif8fsJzI89jkg62BlTFBi6cO04PN2DgNiEQBfOvgtr9rJGN7VhqcSDGKuL68Y+DJQEtq8QXc/G2Ji2xj58liDeZeozrxi/HF9OFcQvFgMT1Pb/+L+8G33V0hfGIo5/21f4FGvt/AFy2quQppmH6jWbekHvXmrIBp4c9fUddVjJjv74fZxii12d2KxJWLqi00zlcG8sQtf6iWyV/ZVuUK7jIeUAgT5aYZGq8/Id8PkRMsnip9oJruME/sDX3YIi7ikiNBouEZwmDpm2zTSsNWMi1FBuaZT30zRcyKhCqW1Ns3vvwv4+lDAid8k2T8MrI0LbKHDTPWM0L+e1o+85JwG3tyT5lcj5aBQW7bVTPsb7AK3hO5tlngilLhNGAPdGkr/jrZmcFFatrogCJEXP3HHTD8PMvOfYBX+1bZt2LOv8tgeYMg0kKvF+Y6/18E3Uqlqp8fkPdukStC8zRcebLS5JGyWdr4mtOJPUSIjEzi3YZFXiPocHKVElz2EnqPkC0uSybTsFYKU1a+Iq2ikLTOkxqpPT2Zi1z5Dsm8uKhOOSnb9Nhz74SrlBVyhf8P8PJe6p+ekA6aB4LUXP9fRk/cbY8/L6rtlOEs2j90kvKD8jRWRB6lKfjyxX1lHzbx+TiTiymZLAFekp1cisbVszheuRnDq2+Wr7llzDDGxw6mu7vtrhj6myDVQML6Jd+IfENTefA8c/eElVAg6FL6Qn5o7H6lHtEPFdoWR8NS5UsLqPFKEQI4beJzB6DhsW1/NM7SJl2CWxgwI6e+BFNvcr+WGua45jGjz3Tc935X2G4lKSs8uUUGx++pemt+i8yCCb+sZ66KW0774Xzj/SQnJu9zIOFie4DH9eK66lkK41f6iG3HyI2pwyKFUR2DYctOXtgxagOSebKdd4wH0y6BJG97YwYo0wLbWPgdwfCxKXtC7G+ermKPM9kxsRdh4jwWrUWXH0zyYb1xZkzpyUi8EtDx6jb4uW83kE/3Vq8Ra69oDyxdUnnw90At5PgNHlU5xp9YVlM+L4VTobcp9etS8qfNEI6lv/PuAWJb42g6tREOwYmjJBA5RqgCkxcM980QxfhSrOzuFe/oBeytMwh8s/1ZrskzwKNyslxQK5czPzb7sQpUUqsTtTeNqol16AH6RD9eoYnejjlKSsMxOtWyXLr8vWJucGKxMuQZHeP/0ePjivmN+0BUJ4P4ws3VbODC4fs5jb8ZGyz01rt8+5LJOyOXcKqvl/QRr0sj91DC2oEtsPsS5FIPs+fdjmNPccgwCrC2N78O81f4RAkIAjshUwZsbTkAst0bhwULwx7di3bmSJTtoHkwRn9tTzCm3Hm/CzBmKk4vy4n+3EW+6Sp3KVmdUa/cMIPLuHOYlnjC1KsgRA0/jR4Qef7kWx/g4cdPSLePhS+5x/SVk9jtdZoWjoZuBluCO70DVJf4F/sGeB0ad2t97db0074sj+8duWL7Zm2mFk57oUuKU5kW5XU9KZevcn+qH4SKKz964Y7WM+c+qhToMTTpuiNRBsFKn4lbh0nBAr+q8qakPHAqVaMlN1xzkNoPYDLg7917jzp/S2UDLNFgGnkYZFxqcNGxAbzf37r1aZQxK5lcNn14MxzCrjMhIEgwmkqFI5lhh10riyqWYzD3OHJdWI35jSQPdoegmfPShJQ26JMSq8IRqve/MgUskqplHL6ps7hagGv0BltwL2upA4heQO/cI/+N3x6J/TtdGqCiDTZ/qMOSY3kGkeSOaywYkFkoWfQhn9BEl19YBxuDLzowCZsaCmlXsoDyeJk8vZdwQFNVc9ZnbLAd3zM5kBWIN5ICs5EA9dnBW2VGQCM48VsJHtXQV7yVN01ZJPfDnbUvxr2D3gP8GhL60JWCVBvjIh5w0RrvVm8+pgeM1bMl13lhipXNNWIW4JnFJqu3u91nJMjjdJmsKJ5PhLpXvbcJqAMXKgUTSNEhzzh6SJd22zWKUaGMaGBYTIxILwNVo8w3y6mn6qW7wZz22+7ZOxRvbsNKdBtOAELgvt9ik48z4NksqzYP3SbU9RaDTaIkUow+FR2jtAkYEn3+kYbXbR9X15Tw1CP85hQ4bg4QpEqYWN4ha3gACAPjOXTQ0icUZRwYlD8n3sRTOi5vuQ2w4cGKBWWctHaymIVvK6jUfX7v5kq76His+j6WfLAgDDZ4fG96Dd7Cwtq25EcG2JQ5J6XRzCQzJHoT216uEIzbODK0+YOaeeUm9FyTjiZfkk7Btnl+FHTDgDfIyeWzNoL+yDeg4CqIuNPPu5oeMH1tuG4x/6RBLqXOtW390BKbfG4IalXo7pLIBLV0Um2trJODvFZcjquQXPpxVZkV+oIXXOO652xV6FQxYSL6Ri9ITJw7o+AJPQ1kvLT2xZAhxnMlHunuagOCGDbiuu2yTAyk1sltcptVh+BIg1WTA4XnnnSxVU+qDeMubuMgQngR3SCf4DhDFaEMszT97iv62FPtzqWnqFJ1DFadRv6wUJg3gyZRwT2kga2GtYmkgn62vHZ3IVa0euwIbBlPfAn57ldBYQy5OV6VT2h43CYGd3bb5UNcDBlk2dQMEwEFYhjg4e22S1CknOpjTz6Haf+M0rWuDOy8LwrHiE4hdsqtLYsLn+k5pbz1MDhraaAyFQyNXgIVrRtxMR9XKRcMOY6rOQFNyc00B7UnfdbkLzaNFJVJxj4OjSG0sfsfpdWmrnAVgMVoeLHAQfRWYaf5Xf/9AeAD7o67TlqSMYtUxTxeZ+1khgZSox0/J8e9842xAi/asjAIaLQC/i4G9VvRKWMC/VUdPwLhS5piXh9XzZEIqGT4WNfKq/fsp5GccUvoZvFbk/SOmWG9Pt9x/W2DT8erRIttdXdX+CRbIFUL8kL0F8axM0JkAv7u6VU4hE/bRoLfVILy0Moe+1aSWG4mrqqjSks0S1kPdZ5dOWDDDxUo2WEB0RvvceR7zdvolN6Qh6wDtJ95EYInl8E+xGJPyRVwXvTuMYrkgpVE3ndx3BFmD/+4a4QTAfAlLz8zFuD/T4cZ8MK3Pq/ATGLP3LytrPyFgvgodlEsOk5x/zSvsj/aHHo5xqLsneGJlNuFiM7Qpyn0JdOYl4/YbSnbbxHjzyNDk52rjXpve795EfmRcahYSz90pXIEht/HxucmPFKtiGT8iwOOStGmldbxACamHD7TJ5WBM1AUX61sVH5zy+0xmpj0iAJIrlf0Femzk1CEPqiuJybPsuuf/y4vO1dFipKvXMEGdBKPZ4t7pv8Df8r5EoNYCJBVoIUAbax7H1Vn1FtP0aeFZ5OTpal7KIjYUUz4ABwpt+fNdTwshui4qgaa09PQhus3SzWeZbH7/0jvpk7B6iA8vBDR/GNeT6ToFDfaWx9ebyR8HQp10SJ3MtjZi778BisylbLNhAOhnwpsy9ACyCbkoeA+U8ptFQ5HcDveBJuemZJDCS3Ds0D5lndKPTLFPaeiIgqzkPMKa/TPIJAuPh37Sv0rPtCipI7uTTmBFjAVH5eKNWiWtlo38qUzthnwNMldI/7VjFHX/+dr9cE2t9TOiTXThiZFtEHzc1eFaHTpC5FhepSbWv6q2lKxLy9Ba+SjRgrVDq9IdJI9xrAylhgnSOng1JqkHRQn688PAZ3h+PfUvaDgHAz53J1GpDkJQUHkosEoE0x7zT9t4Kb60NmP0IV73vrkvN0fcCBcMMq4YOge2Zbf1hrmpQkpuxhiIdnDlBHhXhGPF7OvZo8ok1PRS+dYgdu224wwhr3REUm92uM4g8NOT5g9lyaXdDSx7iQqGHI1/zxw/vw2dXP6j2YzmFfmXjKE86imSvSCc77nboLdy4F1dQNQ/u6x4O9b+7PZacEEjJmyIj8+FcMUUCNsOCQRQd6cS92EeXtMfjkjwm478vMd1Bkj3i8BJPOOb1NlWNWgAejBOkRTiNG00iDqs83oB5SUeE0y1ABBe6PFvpV3+A5WrxmrvKcKgA2TmjtXv4wetbckg0BL6YaC3xtaOrmrAXqu8bBNCipIYz2EN7Z3jwRjYQRa3fWPtC0dZ1rhqNmWEgwZfniYazfYrBdX/vTMxbftQRuIYgL8zJuvzwLykDCdTn+TGguLTP40wCAJsQBBXM+deLkYRrm5Fb3wtmlyHANTdFPIUL9o/bKclnBXG88tYgtfWVHqDLzvVHRo5K9MNbkS5GooFHH0RRwgY+R9m8Foz5PTYiLLZaNZUyGi2dR5fynaGza77Qzh6xNYlOUtirs6eS2igqKgapg/c1Icft8imxooSV0rGG+4Mpuq5obS9DUFXicWaPpslGR1JgzaWt3z3hSzugsrv+u2WcbK6StQmEZ7GlPYCqab89OmBK/DjwzEQ19kU77RnZdHYAmKBtAK6+b+wVmpYs0ZNdclIcVCfDy80Qc79TriWhHSatA9iCXhcopsGrU9TqIYyCn/11q8ggp9gJ4aYKBBiAaO5mw1RW0G3uIxbA7A9NS9RxBHhtp37xYzLNTexpDf8D2Ewv3e0qq5gMyiHgTGbtUV7qLMwE2n+YPNpBUm3SHS3Vo0BIdYkrNG98RCdWA1VgxZNkEBQsbEPIv8F8gdiUVnjzZp0/HzGtFNZE68mnfQfwvmamTn/iT+vHslU/SXEZEGXJqVc0A871w5sslH8lUxoHnrhOT8cv7BXNsTCfBQEMSiHwlFsonxywkdm/LAFR3g5+ob/cdqdDGD8HcayLR9E5BPnCIysQvf2TWhw5JLSHMhxrMg+00Q/NVOOj8GBa8MhgSvs0+Zznq+zJDQjexoaDqrftjKLmj+35vRHjCfakQu/xSj3JsXtXbtW00m8+ftgWr1JeOiNksOvOCj/EAtUTnSAe6lkXLkEmw7lmYhUI+VuQJ6FjTUZfWHZQ3b+/TNzzXvNPhUMU0+5A6dedUeYlDJ0iBOfxnaZTxtDO9XsZHfAxmEQpH8hPbfYMPVh89Bruwm3oRFMQXXGHJ2qpI6hPWe+As92Cys4BiOt1sPGM4CjuwxTolbMYUFHq8H/Q2LO5lOWB0a5+MySiVk3nXp9jT394/TCrXsoOJalZrMYo2tBGVxak2SSuaWO7yCANA6r5s6njTmTPbB/4IPBczuJfb8ocr502cvcrrKbiaalP0iK0x53OMCDffVeoQi01tBtQrgR3hanoIvU2rS8RMBV3kABsQyArmsvMJDokHS1cUOusaCrcgbEV5AIo4fw+o0tv4uFudwR+EDRfjR7I/47+QLYgYu7i9s98RT0evkFff6Tc2tbAOKeELd6CrCmSHVwJSwsiZ8ZSvyilN6kbBhFDD4Z9dnDBYSdoiGuxQgueTJBXltCKuU/h9c0GpO1EOvYZJy4QCfhtmBnJLcsy8usumOsCQym9IbqU+ooYE9FnoFn7dk/nYaa669MyrTGk9l74QvgvPlWNrvGjgt+Z5d12eH+fl6yvr3ilI5YrYE+shO//+/SwYkPDuFVbV4ASU6mT8Ykh9Zuu+a+IIvZCUH9spzGQRzCnpfFsrlMqhQCCH+axWXs+OfzWsKWFUOyRZPtkXOGYY7eaUR/Q5oYG2wDAvq9C+aPVKTW3e3vNqTRw9X6yRNG1WSchLKyNnEa29mOxJQdT+u7qbf7MTWnGFPpnhbNA2w0VBgT2Lyqjm0pkjz8sNepTm7CuenW6HtcAd83QjrSwJKUTs16E7PTpGZHSr0Cg7VevdG7soDJYA9LQExrt+uFCuvg8b9leFG316a8tY9KV4Oa8FKXdO7BXjRcS2veZYH+TgvwiGTJRv2bSfNwWDIB4DfLEpwueS4RFDapwDrZaL2qotwjtN5sd7DaZgGQgFfpz/QT5H/DyMhhVeWuneKYTr6AqMPKQELYkXTkvN+1LvvKAmVgCRg5rab2Izea0G6E6tTdAbQPE8PEWe8qhB2YJMQdDuVSA1YqyNmwy/S/5PzeO8r61+E2xNNX6XsOTBfFrGXTj+5ZXtRv4SOy/2uG9CVDHsireDzifXjk/h40MfXSXDVyjWa2O2EP/GkwvE2u0v2jTUSG08GCU2HyNxjWc8rqqpndNcsDb+2YpS8v1IBnRzsWtKxwlaGj0jFyNDxP3CaHmy2mB3owh27hjAx5PbfftjBTa5zQr4aJFr6cy8gLh1kNMAy29SW1cNeJfAS9n2TggFkQu6SjrDPMICuYCkAC+0D2nb9H0YZOa4OR9aP5jwz8h4zdyS2WSAq+pz4A4kwzqyWrlNPUFHfDDVPemW6hiFZq+mOEM0mgMY2DVpDiki5yjMcMjQCfGY20oQEQv9IcpLt4g/EB1s1WWCNotuOLgHDSfguqKCgokWP22aeqhwnauXphfdj+b10LmTF6YbZjYbsQuuuDZVpDBo+WLC69QQ9WD5KYYu3nkpnIEV8DjJIamJKQSacjRhWnvNqQriFwG8/GTZ1ITeK+yqs14rHnEILRZVSBA+ojfvaRdBds3aaHiFOIWwZ8GkoP0yGWf9uofxhDsn5DgDpoUDt1APkGEdzxbYsuIGulRVl0shQ83HTWDqWQGu+LASinpsklzOcvuRUrCqgxxhxiWm9xEDDfbbHD7+oJMREZx1kD3DjHw0/PaBjydkNx+hwHUSMpfzcxWjYZtdRfowhSCyPFnLXsDrTs7R4YzFICDFWoniBv99a5fwK7cqp4LUkxkaLtKIlP9oocKam7Z3GyopTYCP2gHdRPKg34wUVD4NRkvW40+fwlteri6hw/i9uhjR4JBAawtmZSMqjAX37a7yI+q1LWf2YWqhC9yNtVVD22LO0QIAsY4xSmfkFaGLs59lPaU+K/732utgAO6E+hFPuSqQHxTP9BnXZXiBhFrIuoMCS/fttm7Jwl1wT2RTo/zXtVyvt3d4BnXAGv4y36rVAmYYYIk5O6onKkRj1ch0v2A+a27zK6J9XL5ySbspgyQrmh0EA9greWfs5AevMsiV4r5XHZCfDum5fS6Bmrxu01boIgCvKmG9K56mKKe3Pe1aVxKwbu0GJ1IhvRuzdNQLmhARmTK4njpmxRd5YpDlr6iFCe7buqVyN+b8LtGpM7cLAZprNEjbBzELeA+zlcCkKAse+kBpv9I/LGtZbAXpRfoBxQGqxncwTizcLIs/I7oj9EM0zjwBqAkqHfwONODLq2u2qqgs+RZTZrfV5Y15aBzBeM14TdYOwUUt4snUOkIJh/UOiITj/Q/L7JkVBrTz2S1FiYJfkiHLGzH7h9ojVvPb/tM0mfLhT4YWQw+467FcJG6KjBn/VW/fW+/91/96aqB7vNAEkXFk1IOcPyI21PAaL6wHVp0AdPqEIv1dfyKZyO+BEXKJPtS4u/EP5mox9XZ6UtVohIEhxlkOdXrZzC8d9r9m+ekW+9XFmbkzfqn+1KJ9SHn8JM0f45Tw7UqwghtZfaMjqxfJuRJiwjxKlnVGxF5WDLzxbJ0cyGOH8HsvBUsnYT+6dsztnXky1qPEJQFcOocJ0xTQlNS6ZrRKrW/8s7nDljMdoKsfwq+8LMZSvYuE6DN0yX+5otSQaFbCuYseLEwn/95g4uR0s5ql2IoveiYeOXXGD9ibZDaO8uwuBhdPld9NZFyjS9oXk5Pm0tKZULQas/n6y5B2ZbOMlqyoz5/lA4J4uOVqdzQiEXT1be61j5uZdGZr19f7icG20XpsLlmXJzVkhanNhH6kvUklhZ/R+W/ncxXdWq3CvyjNjVtKOrqBNuTsy/qIMQmYnjGi6Fr1KQFspDNADNP760WCnxfdDFlU1W46x3yD7sWC+vghudIHoJvSYHf9VAqvUK2QOSLkUuh5i1KbW9ZbFyh+ZXmLRm7OJzMp8qdBLV5Kvemaf2pKTI5seZNAwmWPyP4CwwEYLS524qjCJ85DF9uFJDF5C6+r1WwCoRWqFHc0hucRxyWEPHuCobj8tgLMp+N0Rm3xvIm9k2jwdTyPPvNd7Qf6r+gQ7bAyEDAItzto4rNmQ8cE74bC51V6x+INRfTHQ3JKJGPr7sgJCLUgiYzJqSB+lWJY6ueaJBBfXDpf9SNuGdsspHKwj75eKI0d5tMu3xA/PCu0pBmcfYeDJC/ewKspFYufesftptiy5bAk8HjAIrHvqq0aR7jUvV5af2QbZ8xlnku611cliY1B9APeyBvd6n4SHgbW0bJ2+gACWfLTzmHZKkcvga6UU/Yg8aXcq3kgqDJd8lx+W+CNRUuQegr5jxlXR02NIZ517xwyGs3K4+R+nUqXgpryqAlTQpXmSwkzzb52Os8GhXkCUoSDZhi27IuPa67ZD1js0bub6lRy4RzQSIqyYVl+bQmFKdsSeKHYm3S0GYTvsd5HKp6sriVU9nmbNBT6niABLconSFQ/mX2C7U/gZ8/Dy4nv1B3AHxhGww7UqO/Ie4Hjmiwo9zs3QfYni5tL1oUI32kzRynvie/yYCS6UrQd2uqLKSPfj81EKgSujq9H/iYrLK72CQ0Trfjx7baBlv/Qryk3oG2HLWEwfGf68jQivcW3tnhcfq07behS63pGKa6iWsTv8N8Px1XffkTorwCN63htBFoLogF1hResUgd406m1GzH/bZuGveSZJOuGLMHUZUlGREpSoggqwutjIWR+yzCXZ1xyvBNNcFrXckY4ZVDCg+BtpuLyhXEE0QJPeG3XwsE7j9a32q3B9Qn+GnK3BzbkgR4oPJIZ8MGFjfE0XsK5yuzovjUngLBm7TlPBCBCdLzWk4p3LmYyx0JMJi56bWOxAvjChvyQbpUlk/8342GleiV1ynVv2tslcr9XipvGD8uV5bBdPT33SqqdbRCMe52GYkThLLv4ad/ttbin8aMRDK5n9WLQxkLk05PmdSfSMUxOjogvmazFq/mjrHuh4Unfn3RsaxYU2ehabU0a8MFaqBu3gZg6gzEk8yLMmWEi3UlIDOScf64S6WZq5AZ/vYXMpOz8AFkS7PfVGibrDCMdZmcxx6gK98aHFQ3tMli721UYpO70rmdJ/hPuZYKjjd6KxamNUVqBZDarUPl8K6pC5du+/B3lYdfpribTOkiM+81fTPcKEnKyRw/kgOHh19cjBwFC8+X77tUsG6jJ495ruBXhh/Ue40duguHt9l9NlkX54FtWWK8/hxOJTgsTT72izp/Y0bYu+WLCoqaouhyFJMWotoBwmB7LXKRqq072ATf6PqTSUtczTs39SS+rLWR6pJRox0zABb2m0IgLWlkTL2xVo/ugua40PldysyGS0+HpwfkNN6z0ehEV1cxPCbCyefSkn8XigJxUP4iNw+597uULeYMN3KNB1+ZRc88LrB8D/WcJNn+hskd1prA8Q8qPi+c+/k62UqFMohfT7tHgulmdShXo5vSJpxEWdVFWd0Z/2FhoSICDGl3FmC/CDmfhUChRjb8iZhIZEJChW10sLcDTWf52L2eIRDRg55zfVBB8WITB8mdasXa09aSpw/HYCWczI5413xA513PAVrfQGaLpcgp/k6B/SFWnXwPng7Rnt9zCsva00haEhI/jIcNIR6r/1palTTN1NIilnhyLMdqtBrytSVOvL2sH1s/2HO9El1S63rVi0bt0PLg19CioJ3BZXEa6vZFR7H9AFoYJCYxLpCLeBUloTLW8Y3UC3t/pi47xDkKSf3cOXSPBz3f5xfo1NSw81ssURUMjb9tA4e3D6y9phsKFy1twFirtQ3/gFNcD380sMk6HOrwB6e21BtBC9w9+q2STOMWt0dqcwLrReaZDv8d19q3BdZNIWo0Lk4r+njgne+DsAIW4PcttRBfTXt5PjWFcSxvSWyOWc4cYUa1EpgLThuOxUAWSuUAEzCJW2nYqYYyP+SdY8bATtoxPPFel7/8nB07NWsqDHUwXuNV0dPjmT1sNLju6CVgc4FVI3r+4t7m8/4wiJdsygNWJgxO2/yNS/+wfyHhvZ3fAvAjkTxWwUaht9orqdlZqr6VTTxyf1t/PzuvzekUHBewqKV29kTE1dTC7JrAc0U2J5MKVBrCyNM0tGvSyf5yyDlUubiN9xkMuqz2fOkYNauUZOYVjh8fi1NWFd5C+46xKiSFqENKOLuR4VAhHvcaJV2mGcVSOSx2gp/6Ovqh+6ZMxf8Ynwjd4mJBxEFYEoQKyaHGSpcaf1ptH1C4QxZLZ9VQ1i/FZTpHnEn7taXL7F1ywVe+v+THIjN5QTjqVZaStHENpYUr/SQVHntnFWk6KCT0E1Eq/6HqPoJKEA1jHHru/tghKf8xP5B7tt2Xb6fFYaJLBpSAQOlL2c7fBc3l6O4SJCPVj0pMSGJkR3Xm4HIxojEuSr0IxZ837qkRdmijRgzU4HJnaQtfIIw/6bNZzYlRQaOHL/hXE7tyTSX5bsGbDDFajGNDUBMuErBZCpu9FXKu+ZPyjIiUMZtNCqlbyXURES/U9hygLzWs8C4rLtJcd/hPXAkp/J35UTb7m5b5NGRCDo5a6AbvYeQ2Qjiu9EbCCmIiHbLsy47O1Rrc0BewCSEGWVftr/MbwHoOwBCSRvdeJEwkYC9YHENzvZ/7SAYAhJetu6r95sWXMH8WPnL8ZnF203RXeWfZ0hZrsh7NMhaQEsOFE6/JpO9oM43xsSI5Fk0DwM714G0tDRexNXZE5Lr0zOqf5GJSUL1Joje/+oX9QXiCJb+Rdbcby0btDdZZQbAoRbfGPxXNaMPvNZ8V6Q2TbYAwEPCHaD+WnAr87eIX1KJiJQL8c8Y3AvAM9I6+VtBmZOCjXuZoRFHPn/4yoUcB2ky9qokMZAis6xJ2TBmjVZgVaF3D4UWxCANpdngRPdWuzka7tUhNkAMB8pY8WSFaK80R+Ff7nk3dlUwxirfM6SI8+GF53FEj13hv98B1px8jwhPmK7jtTswrelaruNSejOEhVwWPt+3ONTzNYxfrwajhqPkk9qNMutLYCnlZjXem/xKAdLHnpk3W3Yzhtq0WlP+Hrvid5HLAgpb+DGfQaSQbg70ReYrKLhbCgtpncEpCSSt0Oib1ITa1zjK2kHdZRxzX3io+TJpT3coToPtb6Wd/Cwam+sd775Oi4wzJAncNkauTx+CKyzgbjD5UL1kN/bU9oAQwW6ipjneJ0/t7PX/PuVV9aVWcZin+QOfdyJ1FOpWeieGuJMsj6rxvtKrbQbAPiOK64wPn+3SfG43x6k/FwekgMwAmSK/+e2sMpgaenZWvTxGKBhZQ3nh2EAX33I4B3TKLN4eIjVQqgqqt6OnS6/6WAVqqhFS6ZhSFWs55kIFsNuakp2R+HURaYFWNHqaW9J0p0mQ200eNZlqwYZ8zYGly4bPdWs0RH8LT7uPcqZWbAOCjmXqyIlGBDyBpxG08nZjXjqKqibPGeKLG44HyHHRJb50P8Q3Cn7fuTLTZ0OMAPOtLGFoo61iVwBMZjwOrVNlZuLUEBk7ol1RWl+z5k1ze5/qf6DY8gD7ihRDMY6ekOSYn4K3Q0m/7beRb/g+OI42qIxNWykaRLaAWGrIQ6oVqF2MGIfAxt5TPvRs779pFTykqVv95S4YPjOEuhrhWe9lrtrstDAn7fqBlaiqpU4u/EcmeK8e759CUxBqXHn2Mv6atCaVTYOO9wFWYWB5qt2mgv+zCF9Ipl4Dt+oG+2yocq1dmEzLFkupe/X61wS/uUUcRd9+k45VBIwoEuI9QsvPXjko7VZ7dFO8iYpobWcxxYTDxDsCQ13u0MDBTeBOrlw1xsn66RZrk72l2vH40+rsNdCQPAbtwotkqhPMXPGdv17pD/vEFRjNttXGTjXFK7edKCD4fSSwFR8Py+OHIjb6/hirSRBcBd5aEzXrm7eZ5oIl8ojIDyun9tY8TIMH89ZyKRmN48NK/a4IbX22lQV3kY4ECLxPsBpEAYlQxEvXPVoQ6CFEsivH/TdtT1PImrRweSqwn/G72ZxEzmCQG/hkCRbTKTU1kYkHwRETIbTrdDf57/g2kHQ3iCfyNm9nUCU3LbwDLMINle9/3fviJvF9pSzkK9JybU+yz2I+6JHtGuQv4aR70rsVc7C3qolVZI+hG0LLZPijBL4DsPrPT4y6mPTNIDR0Zh+4w+aggVVVJYRFlZdS/zMWJ95D0Yqn5pPjrFIrCDPvVIaDZ/YiyA/WYCqRfDZBvhpMdmYPpbtM0j2Cj0SsjxaX0WtpC/WYl+uqEl0imzyisUzTFkJpP5wGnNbATEztrb7jj0L4eqXYg3vY3C5USrptwqW98t5TittCxpkhrZ5JNUBPKdUezl0PevWmYzkX2H1uwH/glq8GEic6kiMtLh7u9OwA6D9dkURyirprTTKuwMlD6hrrsvDGzmgqbHYJaKF8618MoUPaXpLrCtfmgau8b1oIbhuZyrpQMJ/DonNI7DtV6EP2/F8bEuqhpMHxkNa3D5xuyRELpmaG48zxmOYm7N2Mi0v2GttZu3EUdXcWrZR0irTFreAtq6ucfcVRoRMK/pt199lD2pVFKSl3qeYXfUzP/gbqKa4z/ia4yj5vCMTMoOXPNFofEw8xUql4PS4O+9NMcnQ0EPY13jYa9pAEcel+itR+4MjFhsbOqjTe5cOGKbEj1CaIqtd42k1bwHYLmiyIJOYG1mklqxFxqU3t5/JQfcSzvc6vVbLfqi2wVBGgOY7wYzSlrAoOvHSX+22tP6+h2tlWJ+fHsxWNzDtSseXHnqFH5WU+PEzsq47bhafGFHiHWp8oLTkyt0Cofv1UGMTbTMEqBRfmzjqvkPvCGyVn00FR6YntSBUXKPtIuO4Znb0Mc0ZFlWdijYBOPrvnQQxTgS6D2CGf+F7O+wuzoJjP6wpZBDEq/eikGfRCRC6dFZj9KIbX253e0CFoQ/1FZ+XcNtdcF+K33r/kIPZZJQMEXV0D/ktuEq1TbgBTUZEn+TugUG0ic7vdGQ5q3dxdscfAUuB+3mi7lEVud8ceDYjahwOg3GrNLnG15OfsM0ZcVhjiQIDqUQQj+xgWd5JrTyTWLU2qYalggA6cgu459rnwAd8lOVFOYX/cIXmfcNwVHn7OufzXIBKhnSJwDszCf8RRZLB89DXj6JZRD4R3YrGH2FNKBEeHKJMgDFTWcRBd1kWy5rAbosMdR+AB4bEl2l+L+tDP1J1YxaoLHE0V9uzSUTppCwHS1btJ6gSqV0I/MU9oW5ORg+rLON1UOhSeu5rB0BiN3AU9nkGg0QrHLlfnzY3ccL61JRV8DfwmWXMC6rGssyPI61ClSN9IH2cyhHBupI/MMSsK4N6Q0JkR+y6WKIRC+cFxG1wDfQ0ZUXrvuJ1KfWfqE+XMblU8kp0aITOR5dkmhQtjM2lpl1FNH5eBQUP08d9PZ6GRAWYwOG9No1h0rYwDIT9QPAVTB4equWOLWFTymB2wnU5ZtK50gYS3gIZDT1V1CgDWtPuldNzrixgHBgmVEfH85JnR3C4bu8Ls2G9X1UQnlPm2pFTKWFHx9ZzRr3Y2GDOpVTLfMNueg5geDo1wn1y1R2kC9yOS8ds4u4w7JgKe8H9CyRWdN1t4Qcc+pqUYxVg0HmP4fdNGw0OEGilkg1HuhvF++4k/Xi+2hTJGBYjGnwDdXdEtebmUqbFIIZ5n+rUdshO9K9GDFzaDyg/apWJSDx+hT0349u2/ekX/45u3cag59kOCrjyQ6MpOYuJK1464j7QqxuMWStegwQasT4JgaUmjwbAecAorR7YUkMYqCmFM3nY8vT6rvfwo9rwL3DE03eS7NTkMdEPcgdlMcKH9eVIIxesq9qN+ivZuB7sBJqGFHHS756xxUnNi1NLJ32YL/z+QaSAPT2C+fL9syQ/rucuMnYmCDu7wFUGVDeZL1m/qNDOTdoRsiTmpPs6cOAxLdydWzZTd3lz3lopSvdGKZYRsoKWWMPzccm/LyxO6wf1i4BKZgoiKfs8PMJpZEjb+WwcuQr4zUBsyLGfF59uvkWcPPSxRB6B1W/orxOv0jSzeg/QhTEtwoSXlxzZdzAdPG9a7XjdPoNVuR2OB87rAn2T5rbBsoQpupn4bEC6uuC1wECmoCD34id1AOLMKikwoJv1LR0xzhn3v0LllqgPKC4JCjZpQnr9A9JnrpWD3KKxEFP17RZoOVOHtGBE7Qfn6QtX1vOnTDQaM639wHB05PQEV3omM6gwMS//zdrp6kIvOpyS3XSFj+4BToEUNRQxIjVWAIbRdlIcD4cMqRfdEurWOmR260Fe+aX4ifPSaDCyojno4aAVSas8cUxR14/X1QqqRaEysObxFXkeJOIMpm27fBcFZRTD6zVPSdkLybElqp4CX5HPC2iO7MMuukWZ590U2p0heYjNZucxO+S0SlkFHRn+aqft88sAuHRwaBvR4sG0G6qIDy+qhK2MEwBkrip9i82+ODJY0NwnNNZ4dUk+8bgZK5Gq3CGYqC5Kkzz+zB7nIsjMyDAAHQ+WzligyqP4EbgPGBaKGdHIK7Vu4EeZupMwe4zYR4YbIoml/6+w8HT58MBiOPuLOHFRMIPc8lj5H4GwhO09XjEqIoKG2yV0J/6pHN9TLCM3Ky2kc6SJWCCaT+pJahznjUw9hbISlFDjChg3gRoNVut7Dl3CEzNSi3NjyErJwtYcD0x7q/SZ/yhYYygdm8ypwGxEuTAfHXXUmKlMCSzcDAdGAW0UyehS2Y8pMSRRjXX63QmZkeaaJK1NaZjwcJ8yRHjb3Fvp2wIvKPZSx/TPVx545/b73qmvCupu+1V31nobhFQTVnphon/0vUufRal+blMXMPNGI9fLP2OY3yDoNQuEy+eLvsPPCF2+BXHe0xNOY6O8WiNu8xmZM9CGNK5bK5tqZo/CC2FyTH01lbsWpPZyBLtMGeCHMid7TxvsSa8l/DY6/cbfiznquSJ9JfYGZg3+aRnANlnx5pCz3Fpb1JKuIPImm34v6Q51d1nlv0E/xNMBDjjkHqFc2ZZVURLrfUv3d628tOCsuZ0FzgzX2fUBUXgxab9zVt6j9g6yIMsqy1ur9SFhckZKNsL+WWK5iPev5wrSyJfsLH5Tn9DL3V/sJIfN435iFC8u44raHml/OZoCPtrB2g5DIuIvpFcuCogX7tOcrvjTi1wnqNPlyUdKz6BN6SphPX5pxD4JsvTWzHwtEbcOkQu0qhsEaXQshwdhKgVCjZ4XkmTHWyhgo3/Y4GpYO0hhp9E8rv9tSTGEOXExnssEm7cDBVi8W0MCy1pJerYRXV8hAQEz4S+Xs1DDgpATptdoPiD4Jo2lEamEI0loHBoLUpZjcTGfwJ2EChf2wWvzGpZhUajDmeyzayKh8IVG+LEcB+du/ekwMUyIf82IvhKxnWsITDo8HsXzOkGgw1ZTj1l3Ea2RyMfS5vYxCjlo2JzZeXpPUJT7uu7B2GK+U4TNoLoxnjTvDD6IA1vcv0d4ohf/ogbTJYfmc0KDxcg7vWzNVY8kmJVX3TDJa+riX9BcTZSK41ub/+djASFkXD56ZEXO25g6y024pmKNWOAEMIlDll1Bh84bJkAHzL3VfcOVPHfVAIHtxL1vF7vsmAYhqo8DNqrYtNPYaxs3K+Xn0xKhHtZlz+RFMjR3USfCOhGSmFKIHRK2sCgGzdgtckQFV4wnuvpeJlu7/voUUgL+Bu2j/8cFWJRmWdzBQRaoGNjBuQp6st4Uf7Cu6LCQntyyNdwGakIsiLRpm3omjYjmmqzhuXeFEkboDhDcUfrFABLOMBPhw6wIj9+nLQ7Z0jcAMhjZQzt7jmUI7mVJuHBgPq7tb9go/gXnc8aNLL5wmaozUl/4o47+jNThJ7vA8Egj3rfCHvx4B2QCjLgc40ADwvM/DiSLYtd9UnzkfPS+wEVnK1uD9rtzmG1DUnu6lCCNa7Bj5k3oThw/x3YIFtTcO3AXQS5nvFNnrcxoR5/xEQGju8dMX2REicIEv+MotwKhdl3GGdEW8ctuRICd9LLqFaMLxOZqgrAFfjNoQCNpjdG52sbCkEyxFNSOmwGK2f/5oMwhFI1qektAVZdr7dYojT0ErJo5J/aRkFhdoExs006Ym1ueHwD6yvD1JxfeFEsZGhvjilfnq42yjWVmtUmb2AfdhvMD8gCMTqTABFAURiuS8dumcP4RB+M7wce3YUFVQcQPfhIjeWqJWS21hea9IbBaOt1jj9YS1GNEAzrOXM85lsIKQuKXrZ9ZPBp7wL4fpVIHFPp1jCdt8itaf50iGMgYoXyCxa8G9GvVWiXsc1tcorB/TqxgDq80zLHWYdcWKIEe8NvWKyiW2otVIrv7mI0ns4Hst0UK/VXXbsnTq3SaTlk3e/z6cMAWMcjIf5zBof6TyUOnXKjIFyvAUXkhGmdZEB8teuZ0SKyeF/Ex/qFZeY2phJdBTVgVtGl3C5+0vqO6HGR89Ckd8g9aBDBUC13D9ntZSyZcB8UySbHc58XHA6zVink98Nul8z0GvwIRJY1yq8R7H7TJ39GmIcNY80AXdx/PIVNi3WFCQFcBn69AH/asv234AHb7q60k4Uifbxb3gvOGn8GoMLgL2xZ5nf04Mb3MckNAwc+W1Nfuj8SV/PA3AMkatR/eiEdT5YLPt2lYT0CPSCHZjJIBY+nLSimLqm8FS62qTwnzD/nvyLLKLqZo+BEDZ62fK/LicR7umrctbwU2xZnOyGjrB/CwiVynKLosG1zE8i6tYbhgFaqj+Bs2VdhGHO1NgdQvo/vjqwHZX9LXSQHqhXudXI/gtlItm6n0IW3LDIL6+TolbinWRl12TCnGb7piAHt7FQfKg0hO5phNl3YD7RvkQOIlifoGXnzDjGjfacPbryNxZAQpuzVmMmyEWFj/kqVvMeeyrMFsNDvYNP82iVSPSPhYy/JM2KHhK2bBJ8xi6Yky1lK2PJvac067D8RUxw/oseurSN5TUAn8OfyMyGxcJP3YwcVeyz5NYDBw15s4beLuv+mu2kUxUdrMAIi9qy85qXKuM8NRnY7JrPvXtzY2RikytH+Oxp8pS6BgtW0iz+RujBgHqLX3vQIASu7yeHZyL0vmEu3HqFMVoLeyUseVx0YYwdeVVknERs5FxGtSAxQaTYn2ssM2OcsKthjgyIxM/i4AE+47pV2jHqYVoNQcVm5AFbMuq3cUBCV6J1kX3bPln9MakIYPZP0T58JvvfVUa9MrsUs1oy/pqy91QsaTRqu2A8UbUo7CL6QaM0NPG85zyTNYcitt6yDWV7Hrfg+W09+UHmTrusZqUk72MLsnZ+JIcl9EAQXV1PWWQ2L5R7W1sWA56zkZHPrX++OU9HtHDs/7y+j15RIcUGWAyIiqVvKLGCKgjFjPsUeA2zmalYlJ0/v+WarOlWRLoRQkd8+lZ3hBI1X8Jg2EYfpwlpgT5sEGuASKIRaTOHxIQjVAz0Lv/ObbDosHlLA859i7szX9IviwxjEGQmkPHJrmOZs+Xwoh45VyYy+KXU93EScAlYVq0vfiUXY1u+WsZhDIfzpXmsgxtsEnPmlMzZkJnSilZrck2hie0/4uTGZbptiv6qNPFJJE8nt5o9KV/8QqZ8u2Z4Z2/1Yo+mCqgRNYQ/jQN/EBHC94oedL6EPh0RolsGCmUN7hCFPRiKlwdzCqYHxLWuNcaV5d+tUa5DuEuVEELqt8U84ab56V/HSu7Pis2r6piPu47rzAq3JBH8kmlamKmGqKuHBb9fOGwubEe/Y9fwVD1EgrQVw7teI2RIqTrZyMtiY9PQ5AluKK3/qMcDQZTdDDsbKdQB2afX1ua6MqJZLZRYyiyBZVSUXn6kQhmc7Aszm6SmteqHuGS47+x5JaKyjqqxWZnN0FasHfk4nAVt3/FknBuJAkCnPMXQw57KoZN94Wu64Oj8RBYSJN0WPQUT0P1I/hKCRBXcc+FFQtZdc8BTKNsMFXUTiVZ7smBGuwKIwiUPko/J/J8ZXCuMhF9ij1OsRZJvpU2/A/xTYEcde1VoBIUBr1ou45p7dwiHU7DFIlsqcaKTCxCsGeWKNuL3gaHUTYnehKjrdkba26yxkU8uUmpd4kDoyGv4O/wwTqeHR0aj8A9EnAkCE8x+YAIlO9rfIGOnREBfjpQ7+Kj20isX3RSan7s2x1BfXjYzMVKmeI/caKXBM3EtWZ+m856nNOctkODyfPu35xQ4y7aBzbKJ0sMXyx2CM9MwgvDsPo8VY3RZyJxs22O0gbRHtb6HQcYR9KQCi6lAjw8bJMnxG/fcyKQK30SWswyfiJFGNW9LUYmwgLjUeGuvT7K0rm8rVgEPQLcDHzN15Wy47vsQQGJv9Hh/tjahzoZUzKg7aekiHdXVerSY10qnPPCdO25HGFxb2LpXjjmw2fqa/xYJ7jEbtDcKmS7D/8Dpe7YZ2iowX8VAYXs3oJfSV9sS56SCvAX8IHMhbAnexa2YTmwFBeNBnSzfUrD8PM7xCASqsmaFmDM5LNzbQavrgSN1dsqa0pDmw7E+MW9t8wJ9AlPzvcCHnUWba/j9NutemhawxcOVt6ppF9XJZengEUvk2jeczzs8/kgzk5auZDYMhwwbo5NJyJEMk498uWHUNwmDlNwkQjAnU3eENH2PI4E1+mf2xZqk1bmxYug3cBtXen7subJfy4lqNDJ6bZgNMke3sv01EgRuJ6IZSSCQSrrqzoKLSwyO3CfcNCdVYtiAiFRWqRa6cDd81MwjaFLoUTGz+Vn+jt5r6XT7QPZyWi5qE61RSwZAM5jgAswKEiWI5voMGt5M959EPiKWwVe7c0+QkKfLTpTL1098IidLxnXIMpwVYjwAFhMM2Xw9GhvCP5qYKAYWJGM3B3q3haKlrMcksBOInHxzAtHIcaUQWVY0hX9aWkAx5kzhLbhwq4vbDejgSNChgKIATSeaFlS3Sjob4s7VSgDjFjsYSB020xk45OmyhCesGAMVoeP7ZOQ77Ba92KJkY4GF/h/dAjz2Bwfs3MAxrOrbsOyRz+BoAGSqCJFZnSASJZCzxZdGr0kkV+kaQnN7YSgM4BkVL3hfFL1BClnQln3YDorGc9wGC4sMeGF4BnCCVPzEvt1XGm8f2Xx8yDUBaAourgXD9piFwQX7z2enr317IcDH3Ka4X4BD5QLWiUD6BAi2Se+dPqeq+WYxLFzhwA2UuA5YInTiJRTvGC0lyasiAzXHQRH4vleFnQjdJPyO+JU1+Ku6EsDwzqQiQRySfwluAaobAK0zqCEPkK39GJlmaH9CojoqX9EPTpV6MH7Xny8KomDFSupX5WzEuVx6q7DW5+LmgqvIl5ffah/wKhT66zwT2uIwTglf4bWels8/VD1tHL5ktxrIZy70GSV9zjuRO4lYIwojeIe4mxcG5nX9pT3qeNaPU6noOLJLt2L1AEAzcIXGPDkpdkTrNCacWon+//MgkPPCpL7nDMsaH5IXv4GH6luI3l4ccP0K46+9B2dlEh/XIirMwbWdKrlitvG/J3j7ELqEkjgvx6MtCYy8NKBrXDMmTvSjw3eMGnhRbEZmdZiWZ9mPiwnwcSpyQGmgOlW+SnkiyJ2x7gd2+nJ+RuZEfBkQ5nL0ZXLQ7m+tT5gJEPnKkT4+eAJEs6bJ8ZEzEKiaXIxTNlFpEYzWlibQAnu3jHGw8schzBNmIM8E6LngS8Zvp6a6AurEXdJ9EnCFtV2W9Kg+hj4xMxeZkY9Aolps/lM/z0OijPH4Pjm2BXIxi4lHk/LmiVs+J7aRkYzi0vvPufY4dM4Cn91XenCNrmZAkjNNl8099fcjFeaKKIFnhvDsBJhFzDdJsV4zVzTpuLrAnQGeX0t3ZpfAwNkK4vLUtiNlIIjZGgIgTImL3TyRWn01EWMWdsguURf/uxF5eNcvKkMj8VTGOPIhtg3sQt9aHKyNHsh4fGQptpvreACseP16QrCqtNehMiJO24t3vmcjOE1l90MmFjBaxFt+Hu+9brja9i1At2QDPJyJcuFQ/X3AX7lStyLozrV9uDLcmvGSYCu2sxnxNX4EWjQflzkTIA1jHDKfK6CwLqlPJL2/ufBVxGB0m5huqieRQd96b9ZOsWcUBI2wclTiO8LlrMnYaZQfFfgPos7dDEh04b/xFY1N6POKPg6oyLAl0WsBhrSJKVY1QMOYbO2VqUcD5WtwWNYdwW9wkdcV1Vu6qgAxatL3Pg64PULZgKXBhNj9TRmtfdOrXcTUi32sQxu7XDAvemd4xLi0uyipxIAhOCfw+JCsVHr/xUAYLECBogUi+rOmRxHknRjryNxA4MKQnGhwAoConIweUXsssx0HeImFa1725F3PiHEN5195F2Ac9edWO7bpmnuSVQ1WyM/79yHGm1hALPop2q/t5lr8uilyJ/iergcdCkXjj2a+pw3b7GCHdeClZIKS8gSkkPWiQU4RjHubr+sDFClspI+iYf9IpAfptT1S2AmaA4XnejAmKssQ/QHC8GMgrGhBb8B6CkAjE8d68HI6vCMUBCs00UzlBrG2PW3SD6sNvpKj+JbkHlltSn83zAvyR6vurkHUASNuX9lF6mBYBI27a2YPa8v3bZjCIo7slHSwWd48n7J7oCaJAsrrfYwJh8KwHdwHzPvPOOoWEDeQQMgh+hOQIJblj3jZ1Ov5VeQlUlimHrAtHojFN5c72o6MjSwx1MhIauMANIoZyaHSEv1FoICNQmJLdOIzaM+l/ootQbNPC3VAUTv9ovo1NWM7EVS5fyqg3aZfSqDNSIxwxZXaVaTR7HYrSJz14o9GqSNJZDOx9ocB9MfePr8P2yypul7S91Ot/VKJrCYNlvhKIHKp9a2gtCiJut1W3Ni0JiklL/zfFO9Zkn984xZaq8QhVbi0U/IONTJbKfcdlgq0psmG2HKRuRCGsLJu6vedv0W1rA8XiGAT+FLAF2bJ9PKW/O01OkVaC5EjivdygIQhOQfeItaZ8KLFWH/rXl7fDY4oUVSZ/8jFybEpYRfDeD2aJd9L2wbwYCPxeRFredKrpPYpgSYFAXt46TLykBTJusD8WUR19rLpqaQjmiXOlvT7MnMhB+eYBMr1nWJQqY3W62vE/Fq5htYj5LrQLEjont+EbDiRbQjTx9DQuWMUZPi2jYr2/iDB7QIRjIS0DodcuBx2Op2irkXaTpz93NJVQlI75mwdhzSwyJPJLZ7yDH+1OgXS4cp67yMIB5JnabwVAZjCYY7401EWqlUB3Y5XlXLs4OdK9lEgXwVlLlyo5AELHdkhmLLs4w/3Qn5mmn1NbEZxEfAaL+rEfbdbAPjpzW/3m8dfPY7iYPu3S3PB2CVl7EfB//8fojQwiPIYzeCjl8oKVZW6zHdibxhvf5OyNxbgmHhH4vAheISkfXIzsQdeQ4+PUo5WP0EwRy4iDOC6f5DwNmrTTwC5Sdj1oVcBMUxh5pz4EgzRf+O341Net18h5uTjlay6PpvGHwbZW23Ucm+rr57Enc25ii1Ylypjh0YXyh65TjEp7NMTB2w1hydNy1317AV+XywX2kV1JL3pmOZQqEX2/yOzX9U6kk8xfYt9Pk9L1B2VxTjQvgcwfT5EAMaE2MKNy+t88IPF8EElCsvg4UqeK5IqaUgQ4k8ibd0xqTVfu5DZwSHp71y4HdTOY96MsJ9c081dl53sl2NpCFFjWPZ2cHOntXB+5UgPxerRTrbOJLCO+Vle6qOwe4+6wy0BLEL5+CzrGS3j+mmd0pbF0FqLnFaJdTleqd4mqmDj1PzNUy9WpJ95LGNs4A33oCQnQyjmV2PwsEORxZoYychcf+7Fi1xKT9pBhcipbG3Hf12C1ml30IA3pLZxpPSIwt7RVKGsPIJ8g396LBrYqgpofA7mGETdfj6Pi/ykyxQ2P0DHr16gVaVTgREfHxI9OqaCfKlosLp79LwyKwdPs4HHpIEbRMeWQmLPFs4wuIzenzigEOzkAAOIIhWKphls4JkR9K0sfco+5UXSnFrY8NoJOd0UdM0ug2cDYnkTyF7M4SnodqVoEUbetEMYR+1+noJHPwJqrTj2/A0DvvB9Wrdm5EL9qYfF17olbJJMi1Lfk38GL79TfqyqFZtbsMP9w7ryklKQM3ZYnyEdzvXf5V9HLaUTYzUUWJRP1/+MiYw75uH7PZxVVsZIxXEMIb3IJUr8tSrOlkC6zF/JFMVvkz0kuL1igvihnBtCFzjZ5NxaKnHAHYmDenGEVLGQZIDc33ezpgQi4DSeeaCO8ZqD3u83aV21Jce9Emvk9eObKlB+0r/Il3vwZzqFK641eoHknwJ5BURTnjER04CQig4cKqaMDx+5Uc9xyROxQI020qdncGUyhv9ZONaEFvV7rm0AWzVSgaf/vkK9epTkS0i7y61Dz4OHgmR9we0BXddpo4xQ7swSw/E0OhuwpNxfirnoWsplU/K+Z3LQCFVGKdORkR1i8kizgibwf2kwNFzpBpBSezsRCf5GZST6ShHmbM68doEXDYiDxzpeVjujwBerKPDN9eTcBk0/Dx4JWpWlffOxkIgyqRIhO1oTmrmtwCMpgeTHpSFjUPybcMQe3DrEyWX3GU2Xwf8FEuNoLn2ZqbdRlCEvFggxqSPxCF/ihgbY+gScY8Y5w3i8n5aqrqcQCTW45Jl9fKzPQQn0KiDuAPMUuEjKI+FQK6FYfHsTL683yo6gXQrhJqMrOfed8blT5OMCis8frq1KkQGNLFC/jrPWfFIgeDO+bTr6ZpjAbYyXR42tQZr05R40qwdI3mVpC9o+GfPcE3I67gC6UbaEjnKq9oLzuakxAa78Maw0V9dh6GRh3uSmQEOtoakNtbdyvD25/1zF5rjsy9ltn7jN7341QR+avFjp+zoitBiAmBgXqWVEyjtjt051lTXxBkPekxy8Ep9zb8rZ5Hz7Ic6L9NMm9NsbQmfqx9NkcWb8waZlypGVbsFeqnXrh0hcLWx0WcMDliCX7VowMOgO3XM49rNYfN26Xd0jA8TiAfHX5His7KK2LZaY51F5zdCCe2VjLL4s06I/SOX6H4NWKWHvHSYyI3pTu2K+4zo5Rk1CSl25VG4PoQst79ZMlZVAw/qv0P+fIhwSNhb0UlyCZ6THQzikZK/aZhwr9a4qB3QuzssMTBZ3v0N+3xqJUB4bSS7LlZqbSbNG00KLjMF/yC8Xp4TcxCRzCM5JlspC5iR1uWeLBif7zRaGVddciD3hFSSoDt9osYZkYCnNA/gKZgTw9yZIvKj9v6OPpspqMmC1Xpz43U4eu3ugn9znnLvvEr3MHpLGfJW4kfHTrb0GbEeCUuKWUMeLKCSPRuxREIg7SCHlV/jrdMQO/YkZ+0luSLiErIPOGZTEpQARaayiyaz9NcsO60/fyB1LiLc1/8mpMXqTniiVe6e5pI2dTCeYh2x9TO9nTNy3dTXHrG+pHOeC1crKN2SLBfzTaZj1SSnfQx6zb8rm7IKCJlChnlESc+bQX7Bm/+8m0HjjccyvaxcCTZ24qx/SBH+dn1HT6/FwdykQUohQD/+Kc/Xl80HtcvSHrYjsw5YfeSEkTdYLyOzolPQpanFXyP6cC4H7vcirAEq4Rk0MHXuuKRMGJgMEooM09lDFABI8jBVcnx64pMqMnKxCBl1/k+6bJukfpWRG22e6c/kZsu1aOTBtT8O9q19rOKdhEI8rb4wNEIgkjfvB5FNC4Kkhs0WPcdTpAfuZneizotOIDnEGLn/Yilo8HwoL2HZCFwSo5ZgPM2m2LfKA17HJWXUZ6KhXPs3P6IsnUL6jDsNfd+6wRnBvk5cDsnZpeEKgzDmcYU5nw7v+fSrzsGeJXhnmv1Vz5hClxiZsebAr8ByqhfEbtMzPHp51W77oXRS+f5qs03j1oVEKNL6a2xVHdPxNqgPwIFlLwx8lz6893NL9D3dOTD1xMNVH+l5Y7tezE+lrz9O3DP0n4zKLXbZzvA6OCAAVEQGTo8SOA5yrWU8SXlDNCFukpuDAflpY0rh0qDabUB9BkExifws5a/M6vOPW1cCkM5wCKfMRfnZK7UXQ4wMfMT4UAJ42MqdJL2RhkMOLo1j5+XoSP0A6oOLfD+SjoSdd24tBRiP9DcFDvZiWckkucWlI0Zg/nwG/5XfvpuP94SRFfSpRL9441OER84Mkle2n1xQMStLzWN6sZiAuZKHc1wEimsIbfZlU2mWdfCGkpL6pvZqbej0ic1yBE7LEfVi6Lsfy9RKqw/RKFK37NcVhpPLml7ucIXtygBDlYjf7BSh+KAJVj3NfesceEAyIJrL+r5PLAeWId/LgzIRfgAqI9CZ+16ga1sKSbOMyW3Oo7gJflfwMyyP59FRD1GXgk1gr1XJnuSdISlwL8+7Ks2pUKYhaDcN0DvFM9MlL0MSF7TRoeOypG3QkYiiJe6GVqfreNu7Ac0bVSgMo+Oz1yjmgN4Y0pOs4OBlwD0VqN0HMRJ0pZm6BNNYdGvA4XzjN8Bk3Q5P3aDIfztWYj9rW4eRUAtGHPoPC43n/TiCT6aUoMIbwMx0wK0i7UA1nuFwrs0yJdVBl4kjrHOoJmhL1KktI5GY0Fu0aY6NrHmwqJOvBcCsipYOLTNKWRpuHErGh2YCG6iL2iUvMQdC66mvSb/3HnmErHWrX3kRPF5wNInpq5oyOoY3idikBH5fcanIOmQ7VKeIzjAz/Nigx7j1maK8aXZt2HfZG5FatPy89OO+TrFv8chfagS1y518uZWVFMwotxyPHM/BMwFoiOLBroughaQz1TNLEAHjtQGXSE1Lwr3Y+HfiUNf2TsfHGQFoa8mUtE2lyRE0yuiCyUPhA4wM5df9FVFjtJoDYloFxiOUzmuYXr+t0PfdylkRAcW6gz13QSC4571QIeGG1NW9EwLpDWlmrBb7BVd4EAjFF2ZI/0aOqZMjYd9EWCSnJFS08PbFGiVnfnn/c0JF2qP9u/9loptcacMh4fGTCmIcq1hx2BoK6Y45ckRlXvp4UhdncQg3oNji747S0FATC6ImaVxTYr7UxCNIrhKSGiYibt62qbHhlG0EGu+zcaOfP4n/6IL/C9OlnO5x5Gh1uFpBgPyhoGyB+n4sQX0L3zHkBONXyMstpWA5vY2otvJ4cXt3v1sIY8k15AM5ithFXb7648rSXNqcW8y8fyFoZ3tiXqT9fLJgru8XTcxGLjJge2d9y1yaaia7tofhJ44+IoVgjMScL3B4x6feLysXGwngxKwcZCiBTLbupZVxqMddU3RiwYdXovwvCU5Ta+XgKlf45hSDK64IDheE3jbioVzoTpchzz1Tv7wGOLo4lVxL7mC1g5VK3za1lbjnrfUICbQFk7t4BZVp9YGYPdyh4N59TBbcfvdM7xkyT+ehl3PcZDVSIBgBVDMJL1+9NzuCPDPfbYXoO9Xw3l1bWWuyR6wiSneRy768P47gw694kLWPEuqA0ngS+DDXjhK22k6zulOBwJb80yU6io2Vzn5xs65pokfeyFHIyKDy0E0l1EhkOVk2J8aRJKqfRY1+U2HkzrlDRaNO3WDB7x3mO7ZMUVyNg3i/xDplRhZsatLMLN7yv9keGkARe7dfqJ/+3eu7NSBMUKvQ86VPduq3WVvYn2GXmlPAz3f3HbDRM8K3OFfqaG0Xs78H2o2DsBZ2Ml0lSYY1l1jC3mFLL0cnLnz09Qc/Wt501wEN707M82QSPVKKIJbu0enNdqlrNhsTukX0x7p8WBWZxOxuDZhrRZQAHoINiDeS94MjLR+e8OV40bUfyqko3e0/TcH4AHceFi/sSJApkdWIopCYdmz9L0gQ32BhdIR9L9nA+BFXq+qCKFyD8ujSpaVpZ+vJFr/SPzzoGGTsIimLH3MFrlgjhS/GHRc0JqGhJuDdSa+Vrm4CrLrLvEd3+8dWOFxZfLPASGgiNOXr4lI6ge9LF4YoyWAfe8DqJ1ftb3+6XtqDO5H2u7MtH9vPptX5mrwKPMThxnl7OS1bSTwJ7qRaRQ1Az+BrJqNkRcPon3NCHr+Fshtto3Lm+Dt6iLLO1L6FvUogvjszl1B/ZGY5lSudWEhhvE2OUkFWcyoplgL4tlSsJdltK5i4qz8boKoNMBJxq9guQD45bW0SNvibsT6KuL8sue0/NYPTTbgu9Fkz3ACEZwoJO3MyMYPIGWz+9kI/OnnwV5/nNhVMfQl/LuccG9mMszmdpVm5WPHb0Rc0Ig7DZPLqbLrqUnMjFYxomJFANVCg0o+37GRVR/90avA1nUZJTSOasFfzXfvJqUFCDQQivx4Kw8Ys5QOLbQMUxct0SwyAYbsXmGCVbbDbp8jNvSfwZyuMqP8n0Kp4q88DcuWhqyrJpWRiDYyji+6s0moEsal6dxD3KgpLf2lIZlngLAGBZFacMG7459pXCJE+sjIcBRBTnUSrWa8MM8B5E5MgrkSxjG6FrKY9FWQSi6aFqLYhJAu3ZxoiiL+Jf9kiF1MpxHWavWJX5q789h4o+zBeC7jByHWFPV1iBX6BoLbGDbB00PNlY4O/VX5VZIe6HyH0UkvtyumwpI4rvPO44z/ksrSM7wPmIIqqx1+Qb7v/BeVH/VkY+eMxlggwr8Ue9foDeupNUNmPV6L2yyf8IzURRUsp49duh47eG9akkrwT7vKZT6xmhbXWeSIHtOV0xYxx9gCVmis5VDXDlGbfYlN1+yKCJC1BKaw9GEoVM1HCXkPxHCRDiDtqQr6b+i824CF34ppLXMoZa39lECMBwvxHffKEqgrOQDeq92w3WcFsEAZTd/cOgCJQEZg5z2unhoCUw+4b+r99awGUMFvmo+cMldL9r9RxlUspG6SdFw/cXRisr3brVdxUDQhSqm4e4gyuQMVqSncuTrImPu2saOy1vEC5JGTfx4RJYfIUeOfVntV1sYf4h0FGSZit64hu/mKbz+LOh3j7b+nhjhAGu3ZRAVnH4tw/o2C3P5MgNYTBvy4hULu+GN0Wj9l7wY9pCCgh0BkUF1tVN611ayymkUO3icH9oUSUtjbsqbNLpTU63RRcK2PTNt9907vMhcmucn0FzCcsaKn1mI2Y7EmrTDfE2TN4qZ8K1V35S2ux1iBtpn/fbZtGToh0o+kp2I3zKh8P50J8antqYdda/znF8oHophbIkfndo4PZqUeMQWAUjTxX0VOoi4bnuSfEGucNHdLU6z5KuGfByyiYmcKkl4ftXAEyBYkeD3hK1t4KzvHZBM9XenwocvZrn1gm4RlxwjE/FqbwO6RrUjD6o5ePuiP2uE3sKT/eL0DDSh1IB79ElrgX3aHs0DIEw54Cm9TCWjDzHeqPHfpqEQ8L4lDnqLkH48+qegvVYhuArUhtoI0qvuOSIVl5IQcA5+ZGciS9OrX1QcqUc6X2M5X0I2cXx5Jdk1nOVIyhgoFAMmxXh6qT7FYw9n2mRUyoyPz4si29cOdhmS8/YyVYGnQAaZ6c87ByThTxfaOfbK/OfA1I5nYX4DfhtFBaUV2iGA9qcZc5wSwg3XPlN2/M2bJXtvUog9xVzkEv5ToTrC13lMslnOnNz07TLooEFQg6N08DyR0FmYJxzOhGBLnoIccC9Yc0MDzQggYCda/Wzmanb50cFacvit2VNuVnyfc0C8Z70QmASaFURasfePMjRb3UZxc2HcBl5p1/hfXd3Ntc3CbPpNrlUbo1FUW3D1+ACm11yJBpHYrZfU3nhs+rjMzYFmWHFnbmBH+UvZRTpSOfYyxu5wzuXDWNyv3m2f6H7PV1iDt+z+bIh/TUJVSuX0QVZLpuhnDHJHqEVhzt6vftSobgfw+jn1WfoeDi85on2b6xxCAPgR5DyqY0IS19Ki/nATDt1xa4bNr6QaNc4qcHdFTBAx1jTH1SPVZ0Pz3nghhCI752c/mMhaU6ql4zsAYeQdJiXaomfjEttIjeLYtHBnwwqFXH+rA7XTHjBdiBDd7wU6qhGk02Q0q8vRvJZpgqX2e+sPRnz94l1gAu1AYuU9AMSdLZu6rQMsUStnO3i2RrpeGd0TAUB1d1wLt6XDxuTA7wco8LymnZw3GyyVkjSM3rbcIlUc6mM+v+VEghkyNC+9/cr8uBAW1cWzMHq1LJbpr+wIvLKLkI5HrleTtWZ25bgHKW9bcwxLxfbv0kfU/Z2k/mIRiaUVqJasu5/gLana2Bk0/ereoYh7rS5zChLKNcfNTAvXAzWMW8rZs1zyI+oGfUoVSlq+fSyid56L+zrVBEf5y9jx8sQSEube4PSLSBJprQsJa1f8LWYTsrU32L34LFyr5AVz5hOf4zOldc8j2jCGhqZp21Lii5DA0w2esCqdJ3NmA/25oyjtqA8UC4mM8X3jPWd+d1CfpXREv+Ffc5+CTzGlwWuYEBuFt0m/K6Wjv6xH9Gl0CmNdMA1LUqApvh0kx2ffmCErwo9/aFaEgnflYg/cqnv3JgWg202HsJ06qVICnh+L5NAD0DWc9dF7mSsz0i8eI+0RupLOZhkeFpmKFH7Qw11FW+FMzPFYlEMk0JWqvh07HrqAMU2IQ+K408lI0+66Vcm0tGZ/bIyDcRfXucBThcJH7+NZ1x1ekP6ZI4mECMxXG+Gquqy7fOcu1y9poB7H7jD+/HXx2LQxrW5IHPOXvhzH3uKjfAsbCx6kG7jIEwD30YIRcVq3UvHLp9Aoa3Kgi2gdzSwsPZY89pFOb7MG27zRYD7ZcBx5M+t7A8iWLaXCehdNm7BuWWh4j2CjI14zltlHmOG7vuVlwFrSsIhliF60l4xxtUCLTAYrcJlvsOFn00Re6qAVV/L+dhyuBgHnSxVnp7fq5V0yywMxQETpLaCxcR9kre2IGtyGszobjYBvaiT7B4sjzzYKSOxRKnvvLp5XraWp/UBgfqWFcyf7HzS6QcUMT53zEi2SkwudkvvY4b+U9nA8k+sY75ac020+5uhWJk6iDrUP8GdTY20WQBHF68fhecW+e5wmZrGvcThOWL8Ge7V9X9+f+9e2SaO7UOZtLXhXpiATKTKJ462fya6+alzY73bRM+AKkcVw2yqKSYISZXrC/CJmUxqBvALmCR67fkMIm0i8Vq+l348FyBTdcnf5epDO2Wqk88LBgkG6TDX73rMCnjzLAOLuOzhiIA/EL8emDc00+6ot9hWuMjFRJVwo9hhLMqBZiVHi+KOHw8bQjP7rnDJalYim4XoQDcnzxDFYL/qM6v/ohchxRL+DrFWiW4eiIniEAzSxJYjx+mAlRhk7J1gA+JnpI4KAsRFJRNIZIuPst3z8Idp39F94vz2b4/Fwhul1AL2Gkcmr7Zbp+buFMfZaq1WRo6vpq+HqV1SbkYE5H2XSwz7hcUP9QAYvUNJIDbLdJQTQ7ywc0KGRLYuWE63+z+OUlUoVBSzIjHTSRaRO21oHx4bcgigQRG7WvfnF88YbGOS1rpZVbaMFLQbEEXznBrskndzCXaf/S8qbMjJV5ODHkF3KfCFMY3pUOaf0MOZljCFoZJa0WuoNS7EuTJSFdahShdkTsSG6+rEv/di0CPzsf/8SFEZvSxT8666Qz94KpnlWjYOy1Y93crLDnwdshUg9UFX6fr1snLiZzNhHN24ZSguiv1UwwnCUrORUHM7AKmiIN818MHkZPHDoE/TOKJbIIJYmHuOogFPAQ+WzX5zm92sP82zzxXmFXMtJBeaCbEysRXnq2uX8rRgntFCgofVAyGQBF9SxTg9/frVUQ2Nre3xjSbnPsYM2ItPNeXbX+avqoDxtziOJt5NU9g3LHcTMLPgbktHFhPBpgDZDsB3T8Lur1RypNwdP0pBNpHe8s3kyvGN3888NY1PQliY7Vc96LgyF2iR/ir964hv8/HSb82pOZqnX+qSdpyLz+rsKLNMhqobswvWr+KKGhLAnnDXAWiumNbbwh3OUbjJt0T4q9GPIXBca2QL8iCeDeuo871r7sKcc4+Wh5R/fpXhyH3RAImwPKSoxhYEnNW8HB+t+BY6/ICiGFQ5jb3sSsQhASfrHmN7taGMaLVeYgVP3E0sLHjle04PBdSqy5rR0FpfFR29Nc3oHm+Jo6A9/QMhc4XXZylt9zCVmvMTOIm+8M6r+d9hvZ1zWyjdqZfa6jlUrBQ2fQscphCVkKWkz8OPwIt29qqAbzn+x6UUJAbvzoyfY8ZpWN44s7le1IvtHhaJUUKE7Q9rdPpDayr9PVyO9KISlRhIsElr4XbqSa6Om8MYXZ938WZy58ivk/hIr+BKj4Z1ua0hSHOodhLHvYpWSObJ19b0D04dh6sWQvuttZ2ortIRIvALTw487A5FcY6+c4OOEOIm59qouzSPYcYL3MiY2Bkako+C49x7siBBHKYUt68cmwqpgTdSuMGK69EaaZ7LuR4t5CbCZjgexyXnvtQgQrMauvSE/+CqHVS8eKGr85kFrbJ3lvdIXFsFY2AM9xTmhQTLq1us05NFYBmErYnPG7algfgivhURTSld30t/+5Fio4FZvK+N+2317qzcY4V8rJ2VaIBXb8OK1oIV7IJoIANXLjdoTfi9KgejNi1jrR9Zr8euCNPYjcanoNyYJVSA6GAxDN0kiKc4wJ5nO7q2mqZrXy/HzxodHP2OnSGlvDYxFgS2BHf7s2u9dtBC20C6ArYTmDRbecmvTPoVO4FruDt4d18SVzC/NH1beg3ktyY12pIkpMRA+jILiedUoygw60NRbMI/SCm++BNBBBTfpnRocQI2KqiiW1W6VTp6Jj0bU3yHqwAcG4QhngpKbfKO77uRfvCaDVVWclTWls/6ZSqkFnisDleZaGOddJS8zpGesYP8GSp7zLWVVgNAKa9Ui6Dar22ob39sCZw7sMSiX/6+QnUyjSnGHYgb7dbt2ZXK7o3b8wvOjWSA+mTF0MofDxDXA6q6i0JNqxhYldy6945Vna6V5SPPfSLbKi1+Xp2QDVEWwtsC7pD++NKK4va8fhlzt7JBuow2Wk8Bzwlq2KCoHkY9e8E9MNY2VbDtTeJZUbQWMGVQxbTk5QnHSyZ3graIbKHVaEPf2cd2845vAG4Xvky4hlxztInGHJ3ZA64fhroHKcPd2PQTLaHz+uFzO0BG4y/QhokofGfYHDXLHXSRcYBxA2Z6oSQ92ua0wEUt9QKqQgDB4Us7Iccl0+cuxQDbmplPEzL+h+rZ0ABqZysE+r+tUaLlH/bLAy6Q2yC+8Sm0QAaFZBnzM3qj3SFgpuSWlkrDLhuUEaHGmD5e9GsV73GrDRDfKXg9uE0/7du10iVheuDhPdTmTqR6k4T3DUFB/tZy8nxuTNcDkB00PLJHQL7ISu7FN6ezoqTY1k6qbQDhaXdSXF1OYeUNtB1YMw0Z2OgAD+Vete0BATSa7YaVjJxQjpVR4r0dJksydIXlByATDe+uHXQJoWcS0w9Mnj29pFO6leYnGSF57FimcsgsKpcvcPItcuBjEvy0/Xjxn+aEd21g/gzF7SwsYQL7KtuFWycEemu10yJL8ad2pfze0SjU/duoKuBOXUHBhtwJZlEUyMjLLS5nMUq2JREPLWFYomtq/0ypxBPct1bn4zdh5kx8PI9+nslaq4Za3AWLrPMXybN+v6SHemd5T8WiG0+ondB505R4ft3Yvjw2S3XNPrRAEqHw0mpGYU7oLGxoh28IE+53s2BLh3uQmTw68+tqa/6d4wLvmw+4BfKJu/Tfz6+u4d9WgDmVKv/MpaVFIx0d0nqa4/u780ThSdyiozU+cOg+NO2LyFyMz2Oa56fUDP/8hVwLVPWwcAnlRW1gLWL5G+rlK8TAN5PPK7II9GKdXK1PTK4h1a+gfuBDmbGQxdzvS7meEDfJa15Ng5X177McaucGg210XZyeERmnTYvGXqLVEXfjcD93S0thp1xFQs+veMAPKQpIWXvS7GPktAyNY8aS9PThLE4hMtlGcAipbL62BUazh6o32HWXwC777hLlEOGBVlTTn+9R33phGIJtwX34O3FZkifpj4buzh790wfmLjo/V52NulhrJ42l4qE/k7zKfcRpUfIUBI3HJQtVPaZTWtrRh7kTj844j2C4gOHy93M+U6GacGes7EHNJOzqxFLcmPHFfoLhCIeez2msSpnHhglJLQsPMuqKIkUsisXGRuchQX1dlkXZh7Q/ZH2vbvcTopiyI8l4OIqqOMt58GhaojKc2rW7jck9gDwrsousNLdH48Ca00HeooZqnUn1mqrVC5jiAxQvJJcyq5xRWZXem8a8aVnWUexbCNts84lEUAMw7DaaHAwMcunr11djMJLgxO4jbP25poUc1LfT56IWZZN3S9tFK4JmDCkU6tWJrbAC9evH+G6Jqqudi/dDagT3iHhwvCwbU6C0TbLR1ZLk8/qH1Kzn4PKEDJAZsIDfaKmZhXQNh7Fyj+UYly3LlU/5nqkoeEAfNppGaIIUD5dcklUtNsUiDSqtxIxSXVs8/c4x7JvFzOlMD6QDxV7trBugXHqV0ZRZqr9JfdSQTeCpcchH0aIi6g1otkRFxd5PjtkY2yw/kMhH4JLFBkTixpk9KR5ynBI+nzqXzmo/oWu71TuPbX4ZenwsKXNxw2z4XSfxcY3PAivMNCIyQDg02VJmphwxC+nL+zbs4CXuGdQsH0lPXVTrdgzEt5QBcPERR3jaVAPzPDf/jxz3EQWlt+kV1Oq13EfrhzFmt7FIAlFic+p+CsypN5gdCV53eN59ngDf/CiIC1eobBpe1ZRc7xGfEwgiNK865g6s42R8coTqosHyaHoqJxxIYFTKdkh2W0ujtAbHaGYsG1wv64X/FYwcI3AL5n9RHUaUnYxgHcIBgrOWXGAaNDDOjOZp8vj6WnEJ6gT1FDslfiD3rfCql/JM9OUWEpgS5hOM8ipt9QlAghY94i60YoqiWveatIjCXKVFVYzStmVTciVFvy9aUjPz+u7vzTooMi/To5tW8mTbuwFRvu9hMqdkYB8fT6Q+1yuNZG17Vm1u9o74RgP2Boa+hfTXUmC1XQy16pGnWAcEBiP3iht2KNDTwxEiPTBVDhqnkw8BY3uZdZP1D99hla92RpQzutQeWlHySeyEiPkeo/iKXkVDJh4kavVci/wvkElnxMTkbf/cniJnXNROE5lcBvvzb/a0+pxjw4EuTTwe9Xt+kfGr5QuFQe31+5bH/ybMvIKUGMuPQ0wHH9xiozdTAVWWawPrBHHbz5hbW87GZdeNGGnYpBysfH2QZz/cZEuE2isJAdBGNcX+bZXbKpNj9Z2/oexCuBwTxsbv5sqOj1HuP/aSPbv5kBO+Ld5jhwFp4ctscN+0sLq/2RLCQ+XZ2OrCQegb3936HBRjlPBBkV18LFfa48UN0DrmSNNvY4/lp41v/guohk7Kn2Lq/CR+OfI9oE5kzDWM8BiEqHFr+Tie3uHvW0S29P5sMRSr5q2jNe5ZMU3mIS4X2+puymD4CQgRRk8fqT2ocrtMLqh67INg4piCr2RlV/DrTz7K3OxHaOVa6UMcaF/TM6qGxis/Ea2D9XzDkqRkLD8AJTA4AuFWHVCIhzuZJmYh0zp9aWNnrxC1sSFxCqCL2NIis0B7UlnOu4NutQ6mC335xbdPidswm882oceI1BknoZvnbEOaRw55wLVadJK/rSUGgp9M220EGekRS57JscKUtbitGgHXL28WlYicxKnn4C4h+8Je8RXG6bO6QmC6opTlkZcD4z8+G9GcTuXMyAb9wWxU2IlGryQY8gDJEdFbhoikddeUEL03SRBscR1uFzeeqm8g6ZRuxNyeytuvQsN9vYva+J9NFHeqU2C9JgTrqCWP3d4JL2QssmmTQopI/d7Ubi+mXs3WS7CBcILoFz4CVn/IhO2s+wS//QYwZXQDJo2bvYEkDM0HosZpN2mVxNfzy9gikbgEwy4nSUypkJu9dO9PaLAMIQqkFoxm3NUP98KVG0v98qqGVmSV6cxzZnQQwI53EJWwaiNb5CRxNoYj+EBbo30Wyaa7ntgPdPXfz11ONCo96pVP3spugyJ1Z7UfFwSEMg81Tn5DtUlOOiGq+CNUK+abVP8nvSNq/NPXZy2OuZ83WJp9rflEryF/IUEdpH7Xwz1qj/SpMycv5nD5Xb2vOjZ2RE66QX4KpqCkaDbx6P+cqA0j3nEqYNGdq5h09xviIo9SqmSuboCD5IiHy+BVjY3FxHDepD+lcsUSF/+kfRVvBKgYLl1M2kL+tRgd3KB90CJabrs3VvD6WM/ANEGz19P5p5EiqKYBS1NivPudTnbpuvKeCCUC11OIHj7F/g1IpdhZMFK9wu5b67JRxQbxoD4picwahIUKgmY0KjU1qGJ3+W13jtVKwRT9panH6c9FnZyBBoVaAbkPipEYqa5kbZtnHFbZBL2jB2zeioWaV+HzfL/7UpKUpI9uWfmytA8Dlu3kXyVPiGdCOoEWlJcaGWtZiR4pFGfzzkjH+o5E+ib/25ILak51uhKvw3Efka30ITIUHEn9hGZPPylREChj7VwfkbpWGT2Q0qY8mEwptRA5bZFXM8c92UU8cvE1JwC0co0pX/Ptzu9r4wYGVsHzfa65Hn395dcwhF6DmKFIOTgbe82kMkAr+Om/f0nZnmJDVcefnAK3/a/N2yQ+twohK60KETGGkphOdYFf2WGBcEMaNRdqkzP9yqdSFXHfhf2VadKylMBOJE3khK0AP3V/xQVhvU22iPfdUwlt1w1rn5WQX3Q/x5rEI6t78//5E7sykD2rdaVW74E6ynG/iQfe385ppr8paDQ1Cx1B0p2NcOzDx6LRr4p4ROeRGYegb0c5AArHXLiOefeEBLfT3IQBFAA10g7Z8X+EZnWyTLrjwljuWtec7sDf+J4JGXnVn+57JCU1kMEjg8HJH1LfFjZuydeoJc8Lpj+EL9bfoM/FAXrLTuLqd2PrHCtYgxQg+WbRiyxsHeiw2/jhiRPN88pJ4o0tQTe+6foVl4jpl4B/yYvTs6PMNKPwPcDTBowbDWgWIPn+2yFQLFwJDOJGnb5jXnGpePjChsj2gMHosVWVP5z9Eteu+KP/AS8WcLFHXf8xtV62PilHmNb3xsc1n6r29KPCrxeel+6JBm+LVNOm5L7VUY1Zu78aOV5VMEyF885Nq8DNcHEsdnx/3U0sf6psHt04VJA4nFUQuE3DKS3wMvrpo3VmKIXJoZgEP7XCjTcMXpIytiBtsVUBqHGYMILw9jedp7VQNBlqRH5oe99PvKOZ0QkGtiQ/sHrCVyLNieKz6s4mq4t8zMJXSZMn0ELAUlUnndGmP2ke3SLkT7+s3tqjA1fZmix+jU7QXMh5R4KVr/tZ4Igg9cwKq5u9RWmugv1+TO63Hv6JWk+C8JOkrHT9vgXRv4UVrQtE/JMmgJ1JivvqRYScZg5UkiTDq+MotLdlucEtZtL++/ZnRtKGDpu5Sj9/VSX4MY0Jn7D2d08BP+aRCBGCli1slV2GkqMq4FzoAoHRwA5gaR29GlcFcR0eX2DyA+F1pVOj7F9tXVYCk5BSlvwLoPAun2ei3ylzBxE9iPmg6+GrDSB/8mVlwOrZpi5gl6h9rcbov3e+O6/+FEmxlXosj78JntuFZMLsdX6jXWbcMHQT0raZt9IkEKBjhHf9z2bNnOnKxalaQPU8p24UIIZwYrC8+tTwvaQzu1yJS8SCNUyM5d1A/LtGM4+CpmLBQ62nxrKx4O7U7IjQWE8fAq5PyTfCq7LgivfhO2mXyjmL8K5vvVRB/ZXDMxNy5h6px4PYfNKdgcTeLakx6nGENBlSXb82FyYdpzH7p5PNU1iODeiAaigkCKJAOgdqrfMX0igZAGT4aVHL9IIA74Artmjk0ljfydXM5FTXmfbP2xVKG1k4Qh8xyNPaMyNLka9FPqS8p3DwGLsM097jsqnQ9D1dJAh2ID2zcDS/sGmd21xHgWxSYJ1ZKDAKugzvtaYU3Rc/KRLC2i9seMU4QcH75thPKpt+dOZk4CHFKHHXj0dxOJRl/9xePywVZjFNAdWuGsS+0lVL7OayxCCqm/LUoqIaBMLQlyVEJCCCNd5BmwGK6Py58enFXxpnpF9pxA/cnbqwHUuZDPyxAX4tZh0Sx9lQoOalWMLGjJNOXzxin4fAD6GQI4YW3jsqFByIleLZJ6Klk/Kj3mjc9i3S4IQD3nnk8EjmK3x3W0yN+i3HeotAW0iJNgs/0zoqUZWtNOS9nts8hUHBiOs308qBTmLZJFKfAcKoNi5x2zok4NPN33sCNCXjjqYsmDNsH48Sw/NzpRuMKX0Z5hkUhuKZA73DNRUJfHh0Lyf+7JAJ5WQAAYmrALZndVfsGKm11oQBq4pEgWvFLfN5inP7bW8a/SfSCLx1X6u+iXfS7GP7AlSOLn84Ijc+SbgevSaHB1xfZJ0KTlatAvwI2ZYfB/FTOoz5/Y2/Mr6SB6jhgP5o4aGG7lctikTtA87HQD8YGsUFHkTof7b/iRuc+ikh+jOnmSWMvLsarhW/SlBPCehQqlq7aygfWu0cCLWWoQwkFAsM1Bf6qw4kSpW160GE+nV+MsQxSfMFKHwA9CeR0kuh/QsaBNH+CRGU/q/o85PqlwjGFmceXoLF3Ide/vRkTtLOn1TjoVM8MLZWYubmaBLN4s0vjM41GCR3q2EEkZ66edUNjAAV0PnGJXHJZH+lpI7BaaQ2VUIzZ0flbaB+lZLauLu1zrJqx2OoOysGr1skH5Mfec1M5T9lSXGuLv5GQ94KJljBvRKNfrHBxtputRLJ02VnaRNc/NMK9QN9b5pe3TWSZSLXuMR78t9n5AJONj7w5+IZxyc3lOniJNDlO5Y3gKN7QorjFO+mIiZKWIm/h0gMu30FxSBp13g4HoFit3Q7yd3tqnDIZ2DdDidVZ8tAhvlCaD/uJbzFQV04xawA4IoMrAjapNjEhL04VFQp4WI/XItVXZ01rl8MTmNTfaXg4KOtlKTFDHsArlcW+8qPDuW2HJZu+uESFm0d5aXSt3DEqBXwJZQhuDprmZHqL1Hkz0zxEb6eNzC4Yd8F8lkWBkB4wgfoiXWFBDionTFEy6CS0LyHfZn6Qr9KU6YeJFZaiTep4okJipkXFNDUXW0iSHeeYulO0GcgJDUvNJLjR11EUjxncUJ30TwrQOf5rmw6/613XghEd3KqqtGZwM7XM+blmE5uc7++fzOjlQ1UxilUyzM4L9dK0aWoUfsPaVKiMzb8fevOZoCK5ztKfsFs0DP0SVOIoaOdkYk5exICeP0E/tDqehYzussPpXFlJD/kg5I4YIlytTlHS/tEx2btdE2ceVCxxKauJSIwVVBh5mPIoJolm9aAawWq8g48FL2yXCHOd6E7gaIweDKW9O5X1o7FsRDNDRN7f9nZQ++YwrF/7zPtlMNhQ5+uw/qAQ01iNryx6ui2hbBBGxrhycw/5MkANUG8oP/HBtzrcKCnCOZhNzYC5azr9wQKBE7tLZrrDWXtxt6f7YrNdDRn6nT7Ljj0iYRgiQJmRpCCvnC56xT1YF4bW2Su8VnI68K3PrA40lEiCsvf9rrUlNaziaykuS5RKgU/stGlw7K5t34bZjGihBeejAqViRsUmFhlcf3zMugtBCoFrw9ua+E9PendbDA9hiNJtsiRTPeDkSmkA6DJdiUuvJtmxYwly9PXN44hC5NWO7/tkIT9G0mGY4ixm/lZ4VVXdPH9HdHEkZ2gxb5/L13TnwnVHVXhf9c0d2m8oyW28d6y1o8pMv/suhzTPYd87CtQGhhJEwbN9UOXB4p1q8JHv7KlPTNZMw8jqI4xuKZyqbErRXMbylukHPBc8HvwItNIY/BgQAYUNqbGNBVvPJK707ZDtt13ikOKh7w6HXkptIbfpNno5DSOxHLWex+Ky/cobpJ0mIrWCDb/pNW6X2XEXagP9W85ZNsQMzK9DLxWcyAfPF2gViN2g4BEkJ3mYFwQU/OV6iRgxOYAwcqzsaRCRkMZF5Bed1fWv5mZokv2A845Wr2A/0NN4z6NWD/mpLgJL2nmY2lBpTSp56/MPz77PTBVzIieXFA4OcYUeCX1P9LNj0QUMuiu9J9mHWGn68QOhb84jXUAP1HgEvTEsvbv5V+uGeFBZt0bpYmPhV0PVTfN/j9LVOrT/cQn5gTZXxjLkmYXzXnF47xcmiMpLLKn4YwoVBASX5ChTXeAJVBLOP3iNmbtP9JbVn6yDJyDd9Aqe/2zQDNmSlSTeYCKrGk4qKuoRzkDjEpTRoD6woMZozDvMmp1yOuuIBON0kJwsF7ira0AUadlldNM+QGQcQxRLP0SbXt7ZkASNgLDqOOpSjf2yrJ1gknbPyO7HF49nG+O3NgfDKhnS1CzxOMtfrnXLeenWFeIFyRNj6wVm0+/fky7Anfe0b5r1/CgDBge8CwB1qQnE7Amo7jMvaa5oJXHiV8j+AzOxyPzz5ivWXxsUQ12lktZtgC7qX6YNTiFT8RK98cFKWhbHyIKDOwiMo+lRsvLe2bbGWkLoHdLBm8vca7n37YosMRzjmATEOq02gl7Fo57bc4wcQnI05l5Qr3n0hWJimPxUhbgKQV1b7jUMIthL8p6sJFEwy16YGjfzBr3BxzFf9+EdU13XR+N7drOpCVzKJxkzYX0C3QIKtUZUOKiqWKCRicPQnxzjGYI2cuLgyE93OArPjY51JepipLwq0BuJWMFsd9lFKKKv6BEvlUs253ZOdO3BrUBRUsxNxQV3PCcwMhfBLUHerPbCM73wuKGuITi8I7fG8D1aHwlkMK/4ZUJuG6wQecxSXc89+swoUi4KELA6joqcmhNRUTlZk0yy/eVYC/jJQZtLf5ink0ZLhCpihfG17DnfpJom1fSixteXz5DO1OWJzhvc7lo4rm7/oPEiSa23SpTR35mcG0fV4PDDSJmsv1gvnmoZrbqX/nHGimx2My3PQ+IKN7g382EU1BRT7Vg/TteRJRHbvhZwMZnRDT32njj6Rt8UC3zNPLH9psDBlA142vGrugMnuxT/ITWHIIAe04y03mZ8Tz9xnxeeOk//k2iKz/xZQIueNQOfeAhpkT92HKVjtwFndBeqmmZeztS+wE2G1yHi8zGYfetmVWW6KWxZdx7BMWu6bo/FVvD/aMhvle8wLjKjhWZo1uygE/918AXKdkDGrSBMQDZEpL3aavLF+EPqHET+EuuYHWIthuGhkuJwLhBP06jsrLE1e6S6QOTj9ky8ZPk18i9Odf3rUredAxaadhbT+WyWRooYex5M4KWutT03c7xQsz/FgqSekNJ6GDxEc/EV3R2XFKFb5dBK68Ow7tx1GEgm73OuTUSkJ+8Iak1BodyIYTxUDNWZ/Q7iLToUYVFPxQqMo3GFjqzxqctLXB2eVBZxP63hjpaYm2xJMI92otdXk7XeqbBzprc2felVbXnwqjHmI8YzBcB+QiCHDi64ttzKAil+1jGfv5EyS/2y1LAYV4hfTVBBXNOzp1sF6xcgcswsHeKfCmWgb4b7ad6+b/FYaCLsixRoTik2kU4ovl1UYx2lKgM7UqlCoHmsnDEpWA/SYXRrP4zzTRfuQO8/S4ay/pt9/35ePIaV/VCRTmvGkLMKh/IUdNKOfj2XlfLPL9N4o/mgwRkfAo3JLlCuolgrpHTTILmm0Hyu+JBrYzG4CXhkbHcGqqcFcPPTnREdgw00mFelRL2N0DMRzQsTpiNhIrKbvHrCXtBGpoGDMsAodxenbPSbfcXGvq9qlQwRaHq1eL8NcrtoQYdbiCNGI17ZO+ifToBKIeApYuS3muqU5KxaSRINl4crpKT+3lcShaUp/lolgagJ+EAKVaI6KQAE8xxcTQKCMeiXYEJj18iGuDYm1zfu8ebeFuoMiws8G+CmPg2Z7hJmD2pqZUQlvchVHjMOHffVy0VdaGF1BPZUF5QYVLKQ8QeYgGBisWK1CuRI0lTEodDF5kxeFJAPCEYTaFxkHPozzG/nM6D/LLx6k3nOJZ0pT6Mk5MM2TVwa+YJOpoMOXEciuHljP8O4FbQVWuluqMk8VvT0VYXuziTc75AjV+FwdjuR7mOm4DTUkM7zP1zoIeBuT0rWysU+4esSxPt8FC4Ua2WeYKlot2UQKPDLYBY=]], sha="8fd9780caae8a3a072c43de4891c5ca70e73173509a68bfbacc388696d09a013", tag="fcd6744b53b6b12ff9e2e476fcfb5c558c800de6ae4189513425966c567d7876", blockOn="never", keyMode="auto", wraps={{n="jLm6hh7XIGvxM33V",w="sFgXUs7bePyHzogQCDaPQBbVO6ItLcDkaiR0/fPp6hs="},{n="Z455RW+r15CLvIB2",w="GAD5RV2fJ8cywOi4js4rXIDYguXFURdqepjbGrFhdRA="},{n="eFFq9yd1PwLHtHfr",w="jXwpJXpzLWL9/OysO0T5h7LQa6FeGtv4yMu1qKdRLIM="},{n="6MfY/dweBp8g9Awi",w="8MRMi7QYBrbYqSEetNRERpq5YVEZnpGEKJNv+/AuSyY="}}}
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
