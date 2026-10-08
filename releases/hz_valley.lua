-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-1104
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
local PACK = {id="valley", salt="VBwnlb8HUV4GhnSGTY2+Zw==", ct=[[
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]], sha="8fd9780caae8a3a072c43de4891c5ca70e73173509a68bfbacc388696d09a013", tag="a89cd94566b3f2ca9cbe4429c8adca4a383e7fb3a4f72c5dc0f8d9e63b02d7d3", blockOn="never", keyMode="auto", wraps={{n="EEZn7UNvIqoJKBJb",w="RxlvKWgWz3/KqFrEDTecyDVP+cyQR4vW+lRjJx3cT+I="},{n="OXwYFPvhwSzeCooH",w="hnWJrFzt6Oekhbr77UzLnjE0/WMX4M91dLnWaWPvpm0="},{n="BJgRZX/dw3CPz3Sb",w="elOo7Mnl0xOUY8gaudG2uupL3GQWeI75QKaAfhSL9vU="},{n="NztcALgdZdISb4Sx",w="f4hQA2At4ekzA/2aTqcTipWTIUEL1ExBQpQhmihbH+k="}}}
local BUILDTAG = "v261008-1104"
local DISCORD = nil

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

-- ที่เก็บคีย์เข้ารหัสผูกเครื่อง (HWID) — เหมือน Guard.keyStore: ก๊อปไฟล์ไปเครื่องอื่นเปิดไม่ได้
local function hwid()
	local ok, h = pcall(gethwid)
	if ok and type(h) == "string" and h ~= "" then return h end
	return "uid:" .. tostring(game:GetService("Players").LocalPlayer.UserId)
end
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
