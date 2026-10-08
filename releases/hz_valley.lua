-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-1833
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
local PACK = {id="valley", salt="iROGdOGMIsocqsagJ1KkYw==", ct=[[
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]], sha="35189aa24463787360477044d30421bea0af5826dbd61e9d11e881560cab440c", tag="d871e5ffece5548b8c1ab98f90138b0442f65d3e5c466a67594554e3a7328ed5", blockOn="never", keyMode="auto", wraps={{n="zmgPGtebTUMq7zNI",w="lQ4LyGsNIk1LQJEyCVZ0K69h6RcrGCqFrkITzzftqZo="}}}
local BUILDTAG = "v261008-1833"
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
