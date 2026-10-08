-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-keysys
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
local PACK = {id="valley", salt="XYI5nCqp03Qm7eh3r4js5Q==", ct=[[
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]], sha="8fd9780caae8a3a072c43de4891c5ca70e73173509a68bfbacc388696d09a013", tag="592b6cf8734c9614a6a3f58acd828ca9d5a2b41c0c1fc374e9c99f681d9a60d8", blockOn="never", keyMode="auto", wraps={{n="bHGQe+PHH5OzFr00",w="a5Zs3nkH7seoUbqQrZBRy0mKbqlD8UGHJg21MV3YK+k="},{n="rSTTIIl45WpUumjI",w="YI5Bm28VgponRZXsSOPzAgdvdA3rnBM/M1RPop/TTwA="},{n="0W8nnYjTr7H0t329",w="tBef1F3yfy7wfy7wRBuIj0iLEsv+tM2RR7wCCLmnXP4="},{n="8JW61CejmJ0Sp+Uo",w="rvTe8h75D7vDkG/5HXEu0Xk11Sgvajc4QJ9L0zJi2fI="}}}
local BUILDTAG = "v261008-keysys"
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
