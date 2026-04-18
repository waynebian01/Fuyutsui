local _, fu = ...
local format = string.format

local macroList = {}
local macroKind = {}
local modifiers = {
    "CTRL", "ALT", "SHIFT",
    "ALT-CTRL", "ALT-SHIFT", "CTRL-SHIFT",
    "ALT-CTRL-SHIFT"
}

local keys = {
    "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", "NUMPAD5",
    "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPAD0",
    "NUMPADDECIMAL", "NUMPADPLUS", "NUMPADMINUS", "NUMPADMULTIPLY", "NUMPADDIVIDE",
    "F1", "F2", "F3", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
    ",", ".", "/", ";", "'", "[", "]", "="
}

do
    local i = 1
    for _, m in ipairs(modifiers) do
        for _, k in ipairs(keys) do
            macroKind[i] = m .. "-" .. k
            i = i + 1
        end
    end
end


local function createMacro(name, key, macro)
    if InCombatLockdown() then
        -- print("|cFFFF0000错误：战斗中不能创建按钮|r")
        return
    end
    local btn = macroList[name]
    if not btn then
        btn = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
        btn:SetAttribute("type", "macro")
        btn:RegisterForClicks("AnyUp", "AnyDown")
        macroList[name] = btn
        SetOverrideBindingClick(UIParent, false, key, name, "LeftButton")
    end
    btn:SetAttribute("macrotext", macro)
    -- print(name, key, macro)
end

function fu.CreateMacro(dynamicData, staticData, specialData)
    dynamicData = dynamicData or {}
    staticData = staticData or {}
    specialData = specialData or {}

    local dynamicSlots = #dynamicData * 30

    for i = 1, #macroKind do
        local keyBinding = macroKind[i]
        local macroBody
        if i <= dynamicSlots then
            local groupIndex = math.floor((i - 1) / 30) + 1
            local spell = dynamicData[groupIndex]

            if spell then
                local raidIdx = ((i - 1) % 30) + 1
                if raidIdx == 1 then
                    macroBody = format("/cast [group:raid,@raid1]%s;[group:party,@player]%s;[nogroup,@player]%s", spell, spell,
                        spell)
                elseif raidIdx <= 5 then
                    macroBody = format("/cast [group:raid,@raid%d]%s;[group:party,@party%d]%s", raidIdx, spell,
                        raidIdx - 1, spell)
                else
                    macroBody = format("/cast [group:raid,@raid%d]%s", raidIdx, spell)
                end
            end
        else
            local index = i - dynamicSlots
            macroBody = specialData[index]
            if not macroBody then
                local spell = staticData[index]
                if spell then
                    macroBody = "/cast " .. spell
                end
            end
        end
        if macroBody then
            createMacro("s" .. i, keyBinding, macroBody)
        end
    end
end
