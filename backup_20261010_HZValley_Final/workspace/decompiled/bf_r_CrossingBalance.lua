-- https://sitetest1.lua.expert

local CrossingBalance = require(script.Parent.MovementConfig).CrossingBalance
local v1 = {}

function v1.calculate(v2, v3) -- line 4 | captures: CrossingBalance
    local v4 = math.floor(v2)
    local v5 = math.max(0, v4)
    local v6 = math.floor(v3)
    local v7 = math.max(0, v6)
    local v8 = v5 + v7
    local v9
    if CrossingBalance.Enabled and v5 > 0 and v7 > 0 and v8 > 2 then
        local v10 = (v5 - 1) / (v8 - 2)
        v9 = math.clamp(v10, 0, 1) ^ CrossingBalance.PressureExponent
    else
        v9 = 0
    end
    return {
        catchers = v5,
        runners = v7,
        pressure = v9,
        runnerScale = 1 + CrossingBalance.RunnerMaxBonus * v9,
        catcherScale = 1 - CrossingBalance.CatcherMaxReduction * v9
    }
end

return table.freeze(v1)
