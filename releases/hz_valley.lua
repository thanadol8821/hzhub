-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-secure
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
local PACK = {id="valley", salt="YSoil+X+GwzfU610KMxq3g==", ct=[[
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]], sha="8fd9780caae8a3a072c43de4891c5ca70e73173509a68bfbacc388696d09a013", tag="c5045b47d9318c6ab4d64b18d30b9748fd378923e24d2b13263b60bdca0e89b9", blockOn="never", keyMode="auto", wraps={{n="K1K3kFBfsVe0Nwf/",w="7mkJO8m95x4x8tfT46jvWNQQMRQ5X84JwFF/+9EkIBs="}}}
local BUILDTAG = "v261008-secure"
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
