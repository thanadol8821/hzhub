-- https://sitetest1.lua.expert

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Session = script.Parent.Parent:WaitForChild("Game"):WaitForChild("Session")
local v1 = {}

function v1.movementReason(v2) -- line 7 | captures: Session
    if Session:GetAttribute("GlobalPaused") == true then
        return "GlobalPause"
    end
    if Session:GetAttribute("MapChanging") == true then
        return "MapChange"
    end
    if v2:GetAttribute("Spectating") == true then
        return "Spectating"
    end
    return nil
end

function v1.reason(v3) -- line 19 | captures: UserInputService, GuiService, Session
    if v3:GetAttribute("EventHostPanelOpen") == true then
        return "EventHostPanel"
    end
    if v3:GetAttribute("CrateOpen") == true then
        return "Crates"
    end
    if v3:GetAttribute("StarterPackOpen") == true then
        return "StarterPack"
    end
    if v3:GetAttribute("LikeRewardOpen") == true and v3:GetAttribute("InMatch") ~= true then
        return "LikeReward"
    end
    if v3:GetAttribute("CreatorPanelOpen") == true then
        return "CreatorPanel"
    end
    if not Session:GetAttribute("GlobalPaused") and not v3:GetAttribute("GlobalWheelOpen") and not v3:GetAttribute("GiveawayPickerOpen") then
        if v3:GetAttribute("MapVoteOpen") == true then
            return "MapVote"
        end
        if Session:GetAttribute("MapChanging") == true then
            return "MapChange"
        end
        if v3:GetAttribute("EmoteWheelOpen") == true then
            return "Emotes"
        end
        if v3:GetAttribute("AnnouncementComposerOpen") == true then
            return "AnnouncementComposer"
        end
        if v3:GetAttribute("SettingsOpen") == true then
            return "Settings"
        end
        if v3:GetAttribute("UpdateLogOpen") == true then
            return "UpdateLog"
        end
        if v3:GetAttribute("Spectating") == true then
            return "Spectating"
        end
        if v3:GetAttribute("FairPlayNoticeOpen") == true then
            return "FairPlayNotice"
        end
        if v3:GetAttribute("ConnectionQualityOpen") ~= true or v3:GetAttribute("InMatch") == true then
            if v3:GetAttribute("JourneyOpen") == true then
                return "Journey"
            end
            if v3:GetAttribute("BalloonOfferOpen") ~= true or v3:GetAttribute("InMatch") == true then
                if v3:GetAttribute("ArmoryOpen") == true then
                    return "Armory"
                end
                if v3:GetAttribute("ServerBrowserOpen") ~= true or v3:GetAttribute("InMatch") == true then
                    if v3:GetAttribute("AdminRefreshActive") == true then
                        return "AdminRefresh"
                    end
                    if v3:GetAttribute("AdminConsoleActive") == true then
                        return "AdminConsole"
                    end
                    if GuiService.MenuIsOpen then
                        return "RobloxMenu"
                    end
                    if UserInputService:GetFocusedTextBox() then
                        return "TextInput"
                    end
                    if v3:GetAttribute("ScreenPresentationActive") == true then
                        return "ScreenTransition"
                    end
                    if v3:GetAttribute("InMatch") ~= true then
                        return nil
                    end
                    local Phase = Session:GetAttribute("Phase")
                    local v4
                    if not (Phase == "SelectHero" and Session:GetAttribute("LeadUserId") == v3.UserId) then
                        if Phase == "HeroChoice" then
                            v4 = Session:GetAttribute("SelectedUserId") == v3.UserId
                        else
                            v4 = false
                        end
                    else
                        v4 = true
                    end
                    if v4 and v3:GetAttribute("ReleaseCameraForUI") == true then
                        return "Choice"
                    end
                    if v3:GetAttribute("ChoiceSpotlightActive") ~= true then
                        return nil
                    end
                    if Phase == "SelectHero" then
                        return "ChoiceCamera"
                    end
                    if Phase == "HeroChoice" then
                        return "ChoiceCamera"
                    end
                    if Phase == "ChoiceReveal" then
                        return "ChoiceCamera"
                    end
                    return nil
                end
                return "ServerBrowser"
            end
            return "BalloonOffer"
        end
        return "ConnectionQuality"
    end
    return "GlobalWheel"
end

local v5 = require(game:GetService("ReplicatedFirst"):WaitForChild("FFlags"))
local v6 = {}
local v7

local function watchGui(v8) -- line 119 | captures: v7, v6
    if v7 == v8 then
        return
    end
    v7 = v8
    table.clear(v6)

    local function track(v9) -- line 125 | captures: v6
        if v9:IsA("GuiButton") then
            v6[v9] = true
        end
    end

    for v10, v11 in v8:GetDescendants() do
        if v11:IsA("GuiButton") then
            v6[v11] = true
        end
    end
    v8.DescendantAdded:Connect(track)
    v8.DescendantRemoving:Connect(function(v12) -- line 134 | captures: v6
        v6[v12] = nil
    end)
end

function v1.cursorReason(v13) -- line 138 | captures: v1, v5, v6, watchGui
    local v14 = v1.reason(v13)
    if v14 then
        return v14
    end
    if v13:GetAttribute("ReleaseCursorForControls") == true then
        return "CursorControls"
    end
    local v15 = v5.peekUIVersion()
    if v15 ~= nil and v15 ~= "NewGui" then
        local PlayerGui = v13:FindFirstChildOfClass("PlayerGui")
        if PlayerGui then
            watchGui(PlayerGui)
            for v16 in v6 do
                if v16.Modal then
                    local v17 = v16
                    local v18
                    while true do
                        if v17 then
                            if v17 == PlayerGui then
                                v18 = true
                                break
                            end
                            if v17:IsA("GuiObject") then
                                if v17.Visible then
                                    if v17:IsA("LayerCollector") then
                                        if v17.Enabled then
                                            v17 = v17.Parent
                                            continue
                                        end
                                        v18 = false
                                        break
                                    end
                                    v17 = v17.Parent
                                    continue
                                end
                                v18 = false
                                break
                            end
                            if v17:IsA("LayerCollector") then
                                if v17.Enabled then
                                    v17 = v17.Parent
                                    continue
                                end
                                v18 = false
                                break
                            end
                            v17 = v17.Parent
                            continue
                        end
                        v18 = true
                        break
                    end
                    if v18 and v17 == PlayerGui then
                        return "InteractiveMenu"
                    end
                end
            end
        end
    end
    return nil
end

return v1
