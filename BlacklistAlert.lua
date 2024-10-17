local blacklist = {}

local frame = CreateFrame("Frame", "BlacklistFrame", UIParent, "BackdropTemplate")
frame:SetSize(400, 400)
frame:SetPoint("CENTER")

frame:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frame:SetBackdropColor(0, 0, 0, 1)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", frame, "TOP", 0, -10)
title:SetText("Blacklist Alert")

local inputBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
inputBox:SetSize(200, 30)
inputBox:SetPoint("TOP", title, "BOTTOM", 0, -20)
inputBox:SetAutoFocus(false)

local inputLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
inputLabel:SetPoint("TOP", inputBox, "BOTTOM", 0, -5)
inputLabel:SetText("Name of player")

local addButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
addButton:SetSize(140, 30)
addButton:SetPoint("TOP", inputLabel, "BOTTOM", -75, -10)
addButton:SetText("Add to Blacklist")

local removeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
removeButton:SetSize(140, 30)
removeButton:SetPoint("LEFT", addButton, "RIGHT", 10, 0)
removeButton:SetText("Remove from Blacklist")

local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(250, 150)
scrollFrame:SetPoint("TOP", addButton, "BOTTOM", 0, -20)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(250, 150)
scrollFrame:SetScrollChild(scrollChild)

local blacklistText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
blacklistText:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -10)
blacklistText:SetJustifyH("LEFT")
blacklistText:SetWidth(230)

local function UpdateBlacklistDisplay()
    local list = ""
    for playerName in pairs(blacklist) do
        list = list .. playerName .. "\n"
    end
    blacklistText:SetText(list)
end

-- Botón de cierre
local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

local function AddToBlacklist(playerName)
    if playerName ~= "" and not blacklist[playerName] then
        blacklist[playerName] = true
        print(playerName .. " added to blacklist.")
        UpdateBlacklistDisplay()
    else
        print("PLayer aready blacklisted or empty name.")
    end
end

local function RemoveFromBlacklist(playerName)
    if blacklist[playerName] then
        blacklist[playerName] = nil
        print(playerName .. " removed from blacklist.")
        UpdateBlacklistDisplay()
    else
        print("Player is not on blacklist.")
    end
end

addButton:SetScript("OnClick", function()
    local playerName = inputBox:GetText()
    AddToBlacklist(playerName)
    inputBox:SetText("")
end)

removeButton:SetScript("OnClick", function()
    local playerName = inputBox:GetText()
    RemoveFromBlacklist(playerName)
    inputBox:SetText("")
end)

local function ShowAlert(playerName)
    RaidNotice_AddMessage(RaidWarningFrame, "|cffff0000BE CAREFUL: " .. playerName .. " its on your group!|r", ChatTypeInfo["RAID_WARNING"])
    
    PlaySoundFile("Sound\\interface\\RaidWarning.ogg")
end

local function CheckPartyForBlacklist()
    local numGroupMembers = GetNumGroupMembers()
    for i = 1, numGroupMembers do
        local name
        if IsInRaid() then
            name = GetRaidRosterInfo(i)
        else
            if i == 1 then
                name = GetUnitName("player")
            else
                name = GetUnitName("party" .. (i-1))
            end
        end
        
        if name and blacklist[name] then
            ShowAlert(name)
        end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:SetScript("OnEvent", CheckPartyForBlacklist)


local function SaveBlacklist()
    BlacklistAlertDB = blacklist  
end

local function LoadBlacklist()
    if BlacklistAlertDB then
        blacklist = BlacklistAlertDB  
    else
        blacklist = {}  
    end
    UpdateBlacklistDisplay()  
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT") 
eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "BlacklistAlert" then
        LoadBlacklist()  
    elseif event == "GROUP_ROSTER_UPDATE" then
        CheckPartyForBlacklist()  
    elseif event == "PLAYER_LOGOUT" then
        SaveBlacklist()  
    end
end)

local function ToggleBlacklistWindow()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

SLASH_BLACKLIST1 = "/blacklist"
SlashCmdList["BLACKLIST"] = function(msg)
    ToggleBlacklistWindow()
end

frame:Hide()