-- https://sitetest1.lua.expert

local v1 = require(script.Parent:WaitForChild("ControlGate"))
local v2 = {}
local v3, v4

function v2.request(v5) -- line 5 | captures: v3, v4
    v3 = os.clock()
    v4 = v5 == true
end

function v2.clear() -- line 9 | captures: v3, v4
    v3 = nil
    v4 = nil
end

function v2.consume() -- line 13 | captures: v3, v4, v2
    local v6 = v3
    local v7 = v4
    v2.clear()
    local v8 = if v6 == nil then false else os.clock() - v6 <= 0.15
    return v8, v7 == true
end

function v2.available(v9) -- line 18 | captures: v1
    local Character = v9.Character
    local v10, v11
    if Character then
        v10 = Character:FindFirstChildOfClass("Humanoid")
        v11 = Character:FindFirstChild("HumanoidRootPart")
    else
        v10 = Character
        v11 = Character
    end
    if v9:GetAttribute("GameRole") ~= "Catcher" and v10 ~= nil then
        if v10.Health > 0 then
            if v11 == nil then
                return false
            end
            return not v11.Anchored and not v10.Sit and not v10.PlatformStand and not Character:GetAttribute("MovementLocked") and not Character:GetAttribute("TackleActive") and v1.movementReason(v9) == nil
        end
    end
    return false
end

local function control() -- line 34
    local PreferredInput = game.UserInputService.PreferredInput
    if PreferredInput == Enum.PreferredInput.Touch then
        return "Tap DASH"
    end
    if PreferredInput == Enum.PreferredInput.Gamepad then
        return "RT / R2"
    end
    return "Space"
end

v2.control = control
return v2
