-- https://sitetest1.lua.expert

local v1 = require(game:GetService("ReplicatedFirst"):WaitForChild("FFlags"))
local v2 = {
    Enabled = true,
    SalesEnabled = true,
    MaxInventory = 1000000,
    PackSize = 3,
    Order = {
        "BananaPeel",
        "RescueKit",
        "Adrenaline",
        "InflatableDecoy",
        "EmergencyAirhorn",
        "PocketDoor",
        "RufusLeash",
        "BowlingBall",
        "RocketShoes",
        "BigDagger",
        "Cloak",
        "OneHitShield",
        "BearTrap"
    }
}

v2.Items = {
    BigDagger = {
        IconImage = "rbxassetid://111671278699403",
        Kind = "Ability",
        Cooldown = 25,
        Name = "BIG DAGGER",
        Tag = "A LITTLE EXTRA REACH",
        Description = "Double your melee reach for your next hit. Expires after 5 seconds.",
        Role = "CHASER",
        UseRole = "Catcher",
        RoleItem = true,
        Gems = 1125,
        Coins = 0,
        ProductId = 3715925637,
        Preview = "BigDagger",
        Accent = Color3.fromRGB(255, 180, 98)
    },
    Cloak = {
        IconImage = "rbxassetid://134839019713281",
        Kind = "Ability",
        Cooldown = 35,
        Name = "CLOAK",
        Tag = "BLINK AND I'M GONE",
        Description = "Disappear for 3 seconds. You can still be hit. Using an item ends the cloak. Players near you can see you a little.",
        Role = "RUNNER",
        UseRole = "Runner",
        RoleItem = true,
        Gems = 1625,
        Coins = 0,
        ProductId = 3715925800,
        Preview = "Cloak",
        Accent = Color3.fromRGB(170, 150, 245)
    },
    OneHitShield = {
        IconImage = "rbxassetid://88625045611008",
        Free = true,
        Kind = "Ability",
        Cooldown = 45,
        Name = "ONE HIT SHIELD",
        Tag = "NICE TRY",
        Description = "Raise a shield for 0.75 seconds. It blocks the next hit, then breaks.",
        Role = "RUNNER",
        UseRole = "Runner",
        RoleItem = true,
        Gems = 0,
        Coins = 0,
        Preview = "OneHitShield",
        Accent = Color3.fromRGB(110, 205, 255)
    },
    BearTrap = {
        IconImage = "rbxassetid://132668377495458",
        Free = true,
        ThrowRange = 10,
        TriggerRadius = 2,
        TrapDuration = 12,
        StunDuration = 0.5,
        Kind = "Ability",
        Cooldown = 35,
        Name = "BEAR TRAP",
        Tag = "WATCH YOUR STEP",
        Description = "Toss a trap 10 studs ahead. The first runner to step in it is stuck in place for half a second. Lasts 12 seconds.",
        Role = "CHASER",
        UseRole = "Catcher",
        RoleItem = true,
        Gems = 0,
        Coins = 0,
        Preview = "BearTrap",
        Accent = Color3.fromRGB(222, 112, 96)
    },
    InflatableDecoy = {
        IconImage = "rbxassetid://129293392144023",
        Kind = "Ability",
        Cooldown = 30,
        Name = "INFLATABLE DECOY",
        Tag = "DOUBLE TROUBLE",
        Description = "Send an inflatable copy running straight ahead for 7 seconds. It pops when caught.",
        Role = "RUNNER",
        UseRole = "Runner",
        RoleItem = true,
        Coins = 840,
        Gems = 1200,
        ProductId = 3715705958,
        Preview = "InflatableDecoy",
        Accent = Color3.fromRGB(118, 212, 242)
    },
    EmergencyAirhorn = {
        IconImage = "rbxassetid://116268308218108",
        Kind = "Ability",
        Cooldown = 18,
        Name = "EMERGENCY AIRHORN",
        Tag = "SMALL HORN. BIG PANIC.",
        Description = "Blast nearby chasers backward in every direction.",
        Role = "RUNNER",
        UseRole = "Runner",
        RoleItem = true,
        Coins = 630,
        Gems = 1450,
        ProductId = 3715705962,
        Preview = "EmergencyAirhorn",
        Accent = Color3.fromRGB(255, 190, 92)
    },
    PocketDoor = {
        IconImage = "rbxassetid://91558112029977",
        Kind = "Ability",
        Cooldown = 25,
        Name = "POCKET DOOR",
        Tag = "NOT TODAY",
        Description = "Slam a temporary door in front of you. Chasers smash through or go around. Lasts 6 seconds.",
        Role = "RUNNER",
        UseRole = "Runner",
        RoleItem = true,
        Coins = 840,
        Gems = 875,
        ProductId = 3715705964,
        Preview = "PocketDoor",
        Accent = Color3.fromRGB(177, 152, 245)
    },
    RufusLeash = {
        HitRadius = 2.8,
        ThrowRange = 15,
        IconImage = "rbxassetid://123560947340742",
        Kind = "Ability",
        Cooldown = 20,
        Name = "RUFUS\226\128\153S LEASH",
        Tag = "COME BACK HERE",
        Description = "Throw a leash up to 15 studs ahead. A hit pulls a runner up to 6 studs toward you.",
        Role = "CHASER",
        UseRole = "Catcher",
        RoleItem = true,
        Coins = 840,
        Gems = 1625,
        ProductId = 3715705971,
        Preview = "RufusLeash",
        Accent = Color3.fromRGB(240, 168, 114)
    },
    BowlingBall = {
        IconImage = "rbxassetid://95438074463345",
        Kind = "Ability",
        Cooldown = 20,
        Name = "BOWLING BALL",
        Tag = "STRIKE!",
        Description = "Roll a ball along the ground. A direct hit briefly trips a runner.",
        Role = "CHASER",
        UseRole = "Catcher",
        RoleItem = true,
        Coins = 630,
        Gems = 600,
        ProductId = 3715705976,
        Preview = "BowlingBall",
        Accent = Color3.fromRGB(168, 142, 240)
    },
    RocketShoes = {
        IconImage = "rbxassetid://81361668939419",
        CarrySeconds = 0.6,
        Kind = "Ability",
        Cooldown = 18,
        Name = "ROCKET SHOES",
        Tag = "BRAKES SOLD SEPARATELY",
        Description = "Dash in your movement direction, or camera-forward while standing still.",
        Role = "CHASER",
        UseRole = "Catcher",
        RoleItem = true,
        Coins = 420,
        Gems = 1300,
        ProductId = 3715705981,
        Preview = "RocketShoes",
        Accent = Color3.fromRGB(255, 136, 103)
    },
    BananaPeel = {
        Kind = "Item",
        Cooldown = 12,
        Name = "BANANA PEEL",
        Tag = "A LITTLE SLIP-UP",
        Description = "Throw a peel that lasts 15 seconds. The first opponent slips, falls, then quickly gets back up.",
        Role = "RUNNER / CATCHER",
        Coins = 135,
        Gems = 60,
        ProductId = 3715698235,
        Preview = "BananaPeel",
        Accent = Color3.fromRGB(242, 207, 105)
    },
    RescueKit = {
        Kind = "Item",
        Cooldown = 22,
        Name = "RESCUE KIT",
        Tag = "BACK ON YOUR FEET",
        Description = "Revive yourself when downed during a crossing. Use while rescue is available.",
        Role = "RUNNER",
        UseRole = "Runner",
        Coins = 203,
        Gems = 90,
        ProductId = 3715698237,
        Preview = "RescueKit",
        Accent = Color3.fromRGB(128, 218, 180)
    },
    Adrenaline = {
        Kind = "Item",
        Cooldown = 12,
        Name = "ADRENALINE",
        Tag = "FIND YOUR SECOND WIND",
        Description = "Accelerate 60% faster and retain more speed through turns for 5 seconds.",
        Role = "RUNNER / CATCHER",
        Coins = 135,
        Gems = 60,
        ProductId = 3715698239,
        Preview = "Adrenaline",
        Accent = Color3.fromRGB(137, 192, 246)
    }
}
v2.ProductGrants = {
    [3715925637] = {
        UniverseId = 10764627709,
        Item = "BigDagger",
        Amount = 1
    },
    [3715925800] = {
        UniverseId = 10764627709,
        Item = "Cloak",
        Amount = 1
    },
    [3715705958] = {
        UniverseId = 10764627709,
        Item = "InflatableDecoy",
        Amount = 1
    },
    [3715705962] = {
        UniverseId = 10764627709,
        Item = "EmergencyAirhorn",
        Amount = 1
    },
    [3715705964] = {
        UniverseId = 10764627709,
        Item = "PocketDoor",
        Amount = 1
    },
    [3715705971] = {
        UniverseId = 10764627709,
        Item = "RufusLeash",
        Amount = 1
    },
    [3715705976] = {
        UniverseId = 10764627709,
        Item = "BowlingBall",
        Amount = 1
    },
    [3715705981] = {
        UniverseId = 10764627709,
        Item = "RocketShoes",
        Amount = 1
    },
    [3715702794] = {
        UniverseId = 10764627709,
        Item = "InflatableDecoy",
        Amount = 3
    },
    [3715702796] = {
        UniverseId = 10764627709,
        Item = "EmergencyAirhorn",
        Amount = 3
    },
    [3715702799] = {
        UniverseId = 10764627709,
        Item = "PocketDoor",
        Amount = 3
    },
    [3715702801] = {
        UniverseId = 10764627709,
        Item = "RufusLeash",
        Amount = 3
    },
    [3715702805] = {
        UniverseId = 10764627709,
        Item = "BowlingBall",
        Amount = 3
    },
    [3715702806] = {
        UniverseId = 10764627709,
        Item = "RocketShoes",
        Amount = 3
    },
    [3715698235] = {
        UniverseId = 10764627709,
        Item = "BananaPeel",
        Amount = 3
    },
    [3715698237] = {
        UniverseId = 10764627709,
        Item = "RescueKit",
        Amount = 3
    },
    [3715698239] = {
        UniverseId = 10764627709,
        Item = "Adrenaline",
        Amount = 3
    }
}
v2.Disabled = {}

if v1.LiveFlagsApply and not v1.StarterAbilitiesEnabled then
    for v3, v4 in v2.Items do
        if v4.Kind == "Ability" and v4.Free == true then
            v2.Disabled[v3] = true
        end
    end
    local v5 = #v2.Order
    for v6 = v5, 1, -1 do
        if v2.Disabled[v2.Order[v6]] then
            table.remove(v2.Order, v6)
        end
    end
end

function v2.get(v7) -- line 271 | captures: v2
    local v8, v9
    if type(v7) == "string" then
        if v2.Disabled[v7] then
            v9 = false
        else
            local v10 = v2.Items[v7]
            if v10 then
                v8 = v10
                v9 = true
            else
                v9 = false
            end
        end
    else
        v9 = false
    end
    if not v9 then
        v8 = nil
    end
    return v8
end

function v2.equippedForRole(v11, v12) -- line 275 | captures: v2
    if v11 then
        local equippedAbilities = v11.equippedAbilities
        if type(equippedAbilities) == "table" then
            return v11.equippedAbilities[v12] or ""
        end
        local v13 = v2.get(v11.equippedAbility)
        local v14, v15
        if v13 and v13.UseRole == v12 then
            local equippedAbility = v11.equippedAbility
            if equippedAbility then
                v14 = equippedAbility
                v15 = true
            else
                v15 = false
            end
        else
            v15 = false
        end
        if not v15 then
            v14 = ""
        end
        return v14
    end
    return ""
end

return v2
