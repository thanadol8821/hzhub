-- https://sitetest1.lua.expert

local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local v1 = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("TouchActionButton"))
local LocalPlayer = game.Players.LocalPlayer
local v2 = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero").Movement:WaitForChild("BoostInput"))
local BoostButton = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("BoostButton")

local function request(v3) -- line 10 | captures: LocalPlayer, v2
    if v2.available(LocalPlayer) then
        v2.request(v3)
        return true
    end
    return false
end

ContextActionService:BindAction("CoHBoost", function(v4, v5) -- line 17 | captures: LocalPlayer, v2
    if v2.available(LocalPlayer) then
        if v5 == Enum.UserInputState.Begin and v2.available(LocalPlayer) then
            v2.request(nil)
        end
        return Enum.ContextActionResult.Sink
    end
    return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonR2)
local v6 = v1.bind(BoostButton, request)
local v7 = 0
local v8 = RunService.RenderStepped:Connect(function(v9) -- line 28 | captures: v7, v1, LocalPlayer, v2, BoostButton
    v7 += v9
    if v7 < 0.08 then
        return
    end
    v7 = 0
    local v10 = v2.available(LocalPlayer)
    local Character = LocalPlayer.Character
    local v11 = (Character and Character:GetAttribute("DashCooldownUntil") or 0) - os.clock()
    local v12 = math.max(0, v11)
    v1.update(BoostButton, v10, v12, "DASH")
end)
script.Destroying:Connect(function() -- line 39 | captures: ContextActionService, v2, BoostButton, v6, v8
    v2.clear()
    ContextActionService:UnbindAction("CoHBoost")
    v6:Disconnect()
    v8:Disconnect()
    BoostButton.Visible = false
end)
