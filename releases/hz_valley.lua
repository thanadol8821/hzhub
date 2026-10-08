-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-v22
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
local PACK = {id="valley", salt="IttXuDWku8xEoqwJ6WP7OQ==", ct=[[
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]], sha="35189aa24463787360477044d30421bea0af5826dbd61e9d11e881560cab440c", tag="51c32e36bd8a4b4b3123cb08793916aaae32e6e64ec8eeb6fd272c3984c81971", blockOn="never", keyMode="auto", wraps={{n="im0L1hK9PlmWQRQO",w="wnU/tAGv5iVEEgSiAFXdY15xOXbjjx7D1YBMZ9TyG+U="}}}
local BUILDTAG = "v261008-v22"
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
