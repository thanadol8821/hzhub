-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v2.6-test
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
local PACK = {id="hzvalley", salt="UQtMgl6TQoOx0p8HpurwBg==", ct=[[
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]], sha="8fd9780caae8a3a072c43de4891c5ca70e73173509a68bfbacc388696d09a013", tag="819e6de35db583de35e731e596d6c0235c773cbf752665b6d0137f4fbfe6343e", blockOn="never", keyMode="auto", wraps={{n="BOkzLt3HkCgCZYzX",w="mzF9hboWsk3ehP18sArKsQE4I0v7V3hHUdUTxi9t3gI="},{n="w1Crj1HM+yKldSrb",w="0BmgEi4exFI5Gjsu4Gv9tmbrH6lwV0qL7XU3BcHNLw0="},{n="PaCkjl7oVd7kRKTT",w="0F89ToZgb1Sj2hR08fNDfz6bYYX+j0gzE/DKk4ATeAk="},{n="JQKf4erWo8+JioBF",w="eRi865n0zanQZSmKRCjS530SLdSbPhi1VESE2hcNQ7w="}}}
local BUILDTAG = "v2.6-test"
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
