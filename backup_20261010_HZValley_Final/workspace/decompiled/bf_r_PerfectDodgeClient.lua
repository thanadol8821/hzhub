-- https://sitetest1.lua.expert

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local BoostRequest = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("BoostRequest")
local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "PerfectDodgeFeedback"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 65
ScreenGui:SetAttribute("UIProportionalExclude", true)
ScreenGui.Parent = PlayerGui

local Sound = Instance.new("Sound")

Sound.Name = "PerfectDodgeSound"
Sound.SoundId = "rbxassetid://132570658772029"
Sound.Volume = 0.35
Sound.Parent = ScreenGui

local Frame = Instance.new("Frame")

Frame.BackgroundTransparency = 1
Frame.AnchorPoint = Vector2.new(0.5, 1)
Frame.Parent = ScreenGui

local TextLabel = Instance.new("TextLabel")

TextLabel.Size = UDim2.fromScale(1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "PERFECT DODGE"
TextLabel.TextColor3 = Color3.fromHex("FFCA3A")
TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
TextLabel.TextStrokeTransparency = 0.3
TextLabel.TextScaled = true
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Visible = false
TextLabel.Parent = Frame

local v1 = 0
local v2

local function place() -- line 39 | captures: PlayerGui, Frame
    local CurrentCamera = workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    local ViewportSize = CurrentCamera.ViewportSize
    local v3 = (1/0)
    local v4 = (-1/0)
    local v5 = (1/0)
    for v6, v7 in { "AbilityControls", "GearControls" } do
        local v8 = PlayerGui:FindFirstChild(v7)
        if v8 and v8.Enabled then
            local v9 = v3
            local v10 = v4
            local v11 = v5
            for v12, v13 in v8:GetChildren() do
                if v13:IsA("GuiButton") and v13.Visible then
                    local AbsolutePosition = v13.AbsolutePosition
                    local AbsoluteSize = v13.AbsoluteSize
                    local X = AbsolutePosition.X
                    v9 = math.min(v9, X)
                    local v14 = AbsolutePosition.X + AbsoluteSize.X
                    v10 = math.max(v10, v14)
                    local Y = AbsolutePosition.Y
                    v11 = math.min(v11, Y)
                end
                v3 = v9
                v4 = v10
                v5 = v11
            end
        end
    end
    local v15 = ViewportSize.X * 0.18
    local v16 = math.clamp(v15, 125, 210)
    local v17 = ViewportSize.Y * 0.025
    local v18 = math.clamp(v17, 16, 24)
    local v19 = v5 < (1/0) and (v3 + v4) * 0.5 or ViewportSize.X * 0.5
    local v20 = v5 < (1/0) and v5 - 8 or ViewportSize.Y * 0.76
    Frame.Size = UDim2.fromOffset(v16, v18)
    local fromOffset = UDim2.fromOffset
    local v21 = v16 / 2 + 4
    local v22 = ViewportSize.X - v16 / 2 - 4
    local v23 = math.clamp(v19, v21, v22)
    local v24 = v18 + 4
    Frame.Position = fromOffset(v23, (math.max(v24, v20)))
end

local v25 = BoostRequest.OnClientEvent:Connect(function(v26) -- line 66 | captures: v1, v2, TweenService, ScreenGui, Sound, TextLabel, place
    if v26 ~= "PerfectDodge" then
        return
    end
    Sound:Stop()
    Sound:Play()
    v1 += 1
    local v27 = v1
    if v2 then
        v2:Cancel()
    end
    place()
    TextLabel.Visible = true
    TextLabel.Position = UDim2.fromScale(0, 0.3)
    TextLabel.TextTransparency = 1
    TextLabel.TextStrokeTransparency = 1
    v2 = TweenService:Create(TextLabel, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0,
        TextStrokeTransparency = 0.3,
        Position = UDim2.fromScale(0, 0)
    })
    v2:Play()
    task.delay(0.85, function() -- line 88 | captures: v27, v1, v2, TweenService, ScreenGui, TextLabel
        if not (v27 == v1 and ScreenGui.Parent) then
            return
        end
        v2 = TweenService:Create(TextLabel, TweenInfo.new(0.22), {
            TextTransparency = 1,
            TextStrokeTransparency = 1
        })
        v2:Play()
        task.delay(0.22, function() -- line 94 | captures: v27, v1, TextLabel
            if v27 == v1 then
                TextLabel.Visible = false
            end
        end)
    end)
end)
local v28 = RunService.RenderStepped:Connect(function() -- line 101 | captures: TextLabel, place
    if TextLabel.Visible then
        place()
    end
end)
script.Destroying:Connect(function() -- line 106 | captures: v1, v2, ScreenGui, v25, v28
    v1 += 1
    v25:Disconnect()
    v28:Disconnect()
    if v2 then
        v2:Cancel()
    end
    ScreenGui:Destroy()
end)
