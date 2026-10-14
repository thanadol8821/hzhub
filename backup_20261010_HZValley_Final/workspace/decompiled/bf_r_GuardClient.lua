-- https://sitetest1.lua.expert

local LocalPlayer = game.Players.LocalPlayer
local ChickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local v1 = require(game:GetService("ReplicatedStorage"):WaitForChild("ChickenOrHero"):WaitForChild("OldUIReskin"):WaitForChild("Skin"))
local Panels = v1.Panels
local MovementGuardEvent = ChickenOrHero.Presentation:WaitForChild("MovementGuardEvent")
local v2 = Panels.screen(LocalPlayer, "ValleyFairPlay", 85)
local v3, v4, v5 = Panels.panel(v2, "Warning", 620, 360)
Panels.text(v4, "Eyebrow", "HUSS VALLEY  /  FAIR PLAY", 28, 24, 505, 24, 12, Panels.Gold)
local v6 = Panels.text(v4, "Title", "FAIR PLAY WARNING", 28, 65, 555, 52, 27, Panels.Gold)

v6.Font = Enum.Font.GothamBold

local v7 = Panels.text(v4, "Message", "", 28, 127, 560, 145, 17)

v7.TextYAlignment = Enum.TextYAlignment.Top

local v8 = Panels.button(v4, "Acknowledge", "I UNDERSTAND", 28, 297, 564, 40, Color3.fromRGB(87, 57, 43))

v8.Modal = true
v1.button(v8, "primary")
v5.Visible = false
v8.Activated:Connect(function() -- line 15 | captures: LocalPlayer, v3
    v3.Visible = false
    LocalPlayer:SetAttribute("FairPlayNoticeOpen", nil)
end)
local v9 = Panels.make("Frame", v2, "StaffAlert", {
    BorderSizePixel = 0,
    Visible = false,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -18, 0, 100),
    Size = UDim2.fromOffset(350, 156),
    BackgroundColor3 = Panels.Ink
})
Panels.corner(v9, 12)
Panels.stroke(v9, Panels.Gold, 0.3)
v1.panel(v9)
Panels.text(v9, "Label", "MODERATION \194\183 REVIEW REQUEST", 14, 10, 290, 20, 11, Panels.Gold)
local v10 = Panels.text(v9, "Message", "", 14, 37, 320, 65, 13)

v10.TextYAlignment = Enum.TextYAlignment.Top

local v11 = Panels.button(v9, "Dismiss", "DISMISS", 14, 115, 100, 28)
local v12 = Panels.button(v9, "Watch", "SPECTATE", 124, 115, 211, 28, Color3.fromRGB(43, 80, 93))
v1.button(v11, "secondary")
v1.button(v12, "primary")
local userId, v13
local v14 = false

local function showToast(v15) -- line 27 | captures: v14, LocalPlayer, v9
    v14 = v15
    v9.Visible = v15 and LocalPlayer:GetAttribute("TestUIHidden") == false
end

local v16 = LocalPlayer:GetAttributeChangedSignal("TestUIHidden"):Connect(function() -- line 28 | captures: v14, LocalPlayer, v9
    local v17 = v14
    v14 = v17
    v9.Visible = v17 and LocalPlayer:GetAttribute("TestUIHidden") == false
end)
v11.Activated:Connect(function() -- line 29 | captures: v14, v9
    v14 = false
    v9.Visible = false
end)
v12.Activated:Connect(function() -- line 30 | captures: userId, v14, LocalPlayer, ChickenOrHero, v9, v10
    if LocalPlayer:GetAttribute("InMatch") == true then
        v10.Text = "Return to the lobby to spectate. Use ;anticheat <player> for evidence."
    else
        ChickenOrHero.Presentation.SpectateEvent:FireServer("Start", userId)
        v14 = false
        v9.Visible = false
    end
end)
MovementGuardEvent.OnClientEvent:Connect(function(v18, v19) -- line 34 | captures: userId, v13, v14, LocalPlayer, v3, v6, v7, v9, v10
    if type(v19) == "table" then
        if v18 == "Warning" then
            v6.Text = v19.title
            v7.Text = v19.message
            v3.Visible = true
            LocalPlayer:SetAttribute("FairPlayNoticeOpen", true)
        elseif v18 == "Staff" then
            userId = v19.userId
            v10.Text = v19.message
            v14 = true
            local v20 = LocalPlayer:GetAttribute("TestUIHidden") == false
            v9.Visible = v20
            v13 = os.clock()
            local v21 = v13
            task.delay(18, function() -- line 37 | captures: v21, v13, v14, v9
                if v13 == v21 then
                    v14 = false
                    v9.Visible = false
                end
            end)
        end
    end
end)
script.Destroying:Connect(function() -- line 39 | captures: LocalPlayer, v2, v16
    v16:Disconnect()
    LocalPlayer:SetAttribute("FairPlayNoticeOpen", nil)
    v2:Destroy()
end)
