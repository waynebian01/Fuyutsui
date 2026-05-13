local addonName, ns = ...

local DB

local defaults = {
    logicEnabled = true,
}

local function ApplyDefaults()
    FuyutsuiBurstGuardDB = FuyutsuiBurstGuardDB or {}
    DB = FuyutsuiBurstGuardDB
    for key, value in pairs(defaults) do
        if DB[key] == nil then
            DB[key] = value
        end
    end
end

local function IsLogicOn()
    return DB and DB.logicEnabled == true
end

local function ForceValidOff()
    if not Fuyutsui or not Fuyutsui.blocks or not Fuyutsui.blocks.state then
        return false
    end
    local validIndex = Fuyutsui.blocks.state["有效性"]
    if not validIndex or type(Fuyutsui.CreatTexture) ~= "function" then
        return false
    end
    Fuyutsui.state = Fuyutsui.state or {}
    Fuyutsui.state.valid = 0
    Fuyutsui:CreatTexture(validIndex, 0)
    return true
end

local function RefreshFuyutsuiValid()
    if IsLogicOn() then
        if Fuyutsui and type(Fuyutsui.updatePlayerValid) == "function" then
            Fuyutsui:updatePlayerValid()
        end
    else
        ForceValidOff()
    end
end

local function InstallLogicHook()
    if not Fuyutsui or type(Fuyutsui.updatePlayerValid) ~= "function" then
        return false
    end
    hooksecurefunc(Fuyutsui, "updatePlayerValid", function()
        if not IsLogicOn() then
            ForceValidOff()
        end
    end)
    RefreshFuyutsuiValid()
    return true
end

local function ToggleLogic()
    if not DB then
        ApplyDefaults()
    end
    DB.logicEnabled = not DB.logicEnabled
    RefreshFuyutsuiValid()
    print("|cff00ff00[Fuyutsui]|r 逻辑已" .. (DB.logicEnabled and "|cff00ff00开启|r" or "|cffffd100关闭|r"))
end

function Fuyutsui_ToggleLogic()
    ToggleLogic()
end

SLASH_FUYUTSUIBURSTGUARD1 = "/fbg"
SlashCmdList.FUYUTSUIBURSTGUARD = function(msg)
    local cmd = tostring(msg or ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
    if cmd == "logic" or cmd == "logic on" or cmd == "logic off" then
        if cmd == "logic on" then
            if not DB then ApplyDefaults() end
            DB.logicEnabled = true
            RefreshFuyutsuiValid()
            print("|cff00ff00[Fuyutsui]|r 逻辑已|cff00ff00开启|r")
        elseif cmd == "logic off" then
            if not DB then ApplyDefaults() end
            DB.logicEnabled = false
            RefreshFuyutsuiValid()
            print("|cff00ff00[Fuyutsui]|r 逻辑已|cffffd100关闭|r")
        else
            ToggleLogic()
        end
    else
        print("|cff00ff00[Fuyutsui]|r /fbg logic - 控制逻辑运行")
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "ADDON_LOADED" then
        ApplyDefaults()
    elseif event == "PLAYER_LOGIN" then
        C_Timer.After(1, function()
            InstallLogicHook()
            RefreshFuyutsuiValid()
        end)
    end
end)