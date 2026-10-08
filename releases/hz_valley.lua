-- ============================================================
-- HZ HUB secure bootstrap (single-file tester build)
-- สร้างอัตโนมัติโดย tools/release.py — ห้ามแก้มือ
-- build: v261008-reorg
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
local PACK = {id="valley", salt="x1Fy7M7+wOmfiSFlBR+Zgg==", ct=[[
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]], sha="8fd9780caae8a3a072c43de4891c5ca70e73173509a68bfbacc388696d09a013", tag="877bbe3341197c65ab2d35d9a385f9456507e025f04171a910185da94c93ec44", blockOn="never", keyMode="auto", wraps={{n="YMREVAWLTqPhczOZ",w="KsdSjH1Ye50ZOqUAvZC3ysEDhEH+TVoixXlB1Ur2aBw="}}}
local BUILDTAG = "v261008-reorg"
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
