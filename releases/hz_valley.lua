-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-syssep
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
local PACK = {id="valley", salt="0SJvLbQ+MUoJNTfLJ1H0dQ==", ct=[[
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]], sha="8fd9780caae8a3a072c43de4891c5ca70e73173509a68bfbacc388696d09a013", tag="2ddd6c95483183970544a077cdf790118ac87dc0164470aa173a82ba4d5bcf48", blockOn="never", keyMode="auto", wraps={{n="DfSZWcD8Nj1v/qD9",w="0jLkaUfaxqISbBljAPRqKWryUHGDVt09PBBL1AGgxZM="}}}
local BUILDTAG = "v261008-syssep"
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
			Headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" },
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
		Headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" },
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
