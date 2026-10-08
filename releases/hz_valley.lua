-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-1716
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
local PACK = {id="valley", salt="c03zl5k/WwyNZtbKKv32VQ==", ct=[[
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]], sha="35189aa24463787360477044d30421bea0af5826dbd61e9d11e881560cab440c", tag="15ab645ef361c7e0d1a1bc10397f13b4a1b8737163f25280a05fd4a84ac79907", blockOn="never", keyMode="auto", wraps={{n="NXuIi1gqOZgBJhfg",w="scJ6pGW2nWbdoEx1T4E4AV7AdWscZdDHTxQA1b97H4M="}}}
local BUILDTAG = "v261008-1716"
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
