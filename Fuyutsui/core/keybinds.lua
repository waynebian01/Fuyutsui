local _, fu = ...

local actionBars = fu.actionBars
local keymap = fu.keymap
local keybindings = {}

local function ProcessActionSlot(slot)
    -- 1. 获取动作信息并进行卫语句检查
    local actionType, spellId = GetActionInfo(slot)
    if actionType ~= "macro" and actionType ~= "spell" then
        return
    end

    -- 2. 获取法术信息并进行卫语句检查
    local spellinfo = C_Spell.GetSpellInfo(spellId)
    if not spellinfo then
        return
    end

    -- 3. 遍历动作条
    for _, bar in ipairs(actionBars) do
        -- 4. 检查槽位是否在当前动作条范围内
        if slot >= bar.startSlot and slot <= bar.endSlot then
            local slotInBar = slot - bar.startSlot + 1
            local command = bar.bindingPrefix .. slotInBar -- 构造绑定命令
            local key = GetBindingKey(command)             -- 获取绑定的按键
            -- 5. 检查是否有按键绑定
            if key then
                keybindings[spellId] = {
                    key = key,
                    slot = slot,
                    keycode = keymap[key],
                    icon = spellinfo.iconID,
                    name = spellinfo.name,
                }
                -- 如果一个动作（如法术）只需要被记录一次，
                -- 找到绑定后就可以跳出动作条循环 (break)
                -- break
            end
        end
    end
end

-- 扫描按键
local function readKeybindings()
    -- 清理并重新扫描
    table.wipe(keybindings)
    C_Timer.After(0.5, function()
        for slot = 1, 180 do
            ProcessActionSlot(slot)
        end
    end)
    fu.keybindings = keybindings
end

fu.readKeybindings = readKeybindings

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

frame:RegisterEvent("UPDATE_BINDINGS")
function frame:UPDATE_BINDINGS()
    readKeybindings()
end

frame:RegisterEvent("SPELLS_CHANGED")
function frame:SPELLS_CHANGED()
    readKeybindings()
end

frame:RegisterEvent("ACTIONBAR_SHOWGRID")
function frame:ACTIONBAR_SHOWGRID()
    readKeybindings()
end

frame:RegisterEvent("ACTIONBAR_HIDEGRID")
function frame:ACTIONBAR_HIDEGRID()
    readKeybindings()
end
