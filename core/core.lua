local _, fu = ...
Fuyutsui = LibStub("AceAddon-3.0"):NewAddon("Fuyutsui", "AceConsole-3.0", "AceEvent-3.0")
local className, classFilename, classId = UnitClass("player")
local specIndex = C_SpecializationInfo.GetSpecialization()
print("职业:", className, "职业文件:", classFilename, "职业ID:", classId, "专精索引:", specIndex)
fu.className, fu.classFilename, fu.classId = className, classFilename, classId
fu.specIndex = specIndex

-- 游戏内宏命令
-- /fu 命令系统
-- /fu cd       — 爆发 开 / 关 切换
-- /fu cd on      — 爆发 开启
-- /fu cd off     — 爆发 关闭

-- /fu aoemode   — 自动 / 单体 切换
-- /fu aoemode auro  — 切换回自动模式
-- /fu aoemode aoe      — 仅开 AOE 模式

-- /fu dpsmode  — DPS 模式 开 / 关 切换
-- /fu dpsmode manual     — 输出模式 切换到 手动编写逻辑
-- /fu dpsmode assistant  — 输出模式 切换到 官方一键辅助

FuyutsuiDB = {
    aoeMode = 0,
    cooldowns = 0,
    dpsMode = 0,
}

local function SaveConfig()
    -- 确保全局变量已初始化
    FuyutsuiDB.aoeMode = FuyutsuiDB.aoeMode or 0
    FuyutsuiDB.cooldowns = FuyutsuiDB.cooldowns or 0
    FuyutsuiDB.dpsMode = FuyutsuiDB.dpsMode or 0
end

local function switchCooldown()
    if FuyutsuiDB.cooldowns == 0 then
        print("|cff00ff00[Fuyutsui]|r 爆发已|cffff0000关闭|r") -- 修改"关闭"为红色
    else
        print("|cff00ff00[Fuyutsui]|r 爆发已|cff00ff00开启|r")
    end
    if fu.blocks and fu.blocks["爆发开关"] then
        fu.updateOrCreatTextureByIndex(fu.blocks["爆发开关"], FuyutsuiDB.cooldowns / 255)
    end
    SaveConfig() -- 保存
end

local function switchAoeMode()
    if FuyutsuiDB.aoeMode == 0 then
        print("|cff00ff00[Fuyutsui]|r 已切换|cff00ff00自动|r模式！")
    elseif FuyutsuiDB.aoeMode == 1 then
        print("|cff00ff00[Fuyutsui]|r 已切换|cff00ff00单体|r模式！")
    end
    if fu.blocks and fu.blocks["AOE开关"] then
        fu.updateOrCreatTextureByIndex(fu.blocks["AOE开关"], FuyutsuiDB.aoeMode / 255)
    end
    SaveConfig() -- 保存
end

local function switchDpsMode()
    if FuyutsuiDB.dpsMode == 0 then
        print("|cff00ff00[Fuyutsui]|r 输出模式已修改为|cff00ff00官方一键辅助|r") -- 修改"关闭"为红色
    else
        print("|cff00ff00[Fuyutsui]|r 输出模式已修改为|cff00ff00手动编写逻辑|r")
    end
    if fu.blocks and fu.blocks["输出模式"] then
        fu.updateOrCreatTextureByIndex(fu.blocks["输出模式"], FuyutsuiDB.dpsMode / 255)
    end
    SaveConfig() -- 保存
end

--- 供 gui.lua 等界面在改 FuyutsuiDB 后调用，与斜杠命令一致（含 print、像素、保存）
fu.switchCooldown = switchCooldown
fu.switchAoeMode = switchAoeMode
fu.switchDpsMode = switchDpsMode

-- 定义主处理函数
local function Fuyutsui_SlashHandler(msg)
    -- 将输入转换为小写并拆分参数
    local command = string.lower(msg:trim())
    -- 爆发
    if command == "cd" then
        FuyutsuiDB.cooldowns = (FuyutsuiDB.cooldowns == 0) and 1 or 0
        switchCooldown()
    elseif command == "cd on" then
        FuyutsuiDB.cooldowns = 1
        switchCooldown()
    elseif command == "cd off" then
        FuyutsuiDB.cooldowns = 0
        switchCooldown()
        -- AOE模式
    elseif command == "aoemode" then
        FuyutsuiDB.aoeMode = (FuyutsuiDB.aoeMode == 0) and 1 or 0
        switchAoeMode()
    elseif command == "aoemode auto" then
        FuyutsuiDB.aoeMode = 0
        switchAoeMode()
    elseif command == "aoemode aoe" then
        FuyutsuiDB.aoeMode = 1
        switchAoeMode()
        -- 输出模式
    elseif command == "dpsmode" then
        FuyutsuiDB.dpsMode = (FuyutsuiDB.dpsMode == 0) and 1 or 0
        switchDpsMode()
    elseif command == "dpsmode manual" then
        FuyutsuiDB.dpsMode = 1
        switchDpsMode()
    elseif command == "dpsmode assistant" then
        FuyutsuiDB.dpsMode = 0
        switchDpsMode()
    elseif command == "help" then
        -- 默认显示的帮助信息
        print("|cff00ff00Fuyutsui|r 命令列表:")
        print("爆发开关: /fu cd")
        print("|cff00ff00开启|r爆发: /fu cd on")
        print("|cffff0000关闭|r爆发: /fu cd off")
        print("切换AOE模式: /fu aoemode              ")
        print("切换AOE为|cff00ff00自动|r: /fu aoemode auto")
        print("切换AOE为|cff00ff00单体|r: /fu aoemode single")
        print("切换输出模式: /fu dpsmode")
        print("切换输出模式为|cff00ff00手写逻辑|r: /fu dpsmode manual")
        print("切换输出模式为|cff00ff00一键辅助|r: /fu dpsmode assistant")
    elseif command == "gui" then
        if fu.OpenInfoGUI then
            fu.OpenInfoGUI()
        end
    else
        if fu.OpenInfoGUI then
            fu.OpenInfoGUI()
        end
    end
end

-- 绑定命令（使用你定义的变量名）
SLASH_FUYUTSUI1 = "/fu"
SLASH_FUYUTSUI2 = "/fuyutsui"
SlashCmdList["FUYUTSUI"] = Fuyutsui_SlashHandler

function SetTestSecret(set)
    SetCVar("secretChallengeModeRestrictionsForced", set)
    SetCVar("secretCombatRestrictionsForced", set)
    SetCVar("secretEncounterRestrictionsForced", set)
    SetCVar("secretMapRestrictionsForced", set)
    SetCVar("secretPvPMatchRestrictionsForced", set)
    SetCVar("secretAuraDataRestrictionsForced", set)
    SetCVar("scriptErrors", set);
    SetCVar("doNotFlashLowHealthWarning", set);
    print("|cff00ff00[Fuyutsui]|r 已设置测试模式: " .. (set == 1 and "|cff00ff00开启|r" or "|cffff0000关闭|r"))
end

-- /script SetTestSecret(0)
SetTestSecret(1)

function FuGetAuraDate(unit)
    for i = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, i)
        if aura then
            for key, value in pairs(aura) do
                if key == "name" then
                    print(value, issecretvalue(key), issecretvalue(value))
                end
            end
        end
    end
end

-- /script FuGetAuraDate("player", id)

---@param reversed boolean 是否逆序
---@param forceParty boolean 是否强制使用队伍
---@return function 迭代器
function fu.IterateGroupMembers(reversed, forceParty)
    local unit = (not forceParty and IsInRaid()) and 'raid' or 'party'
    local numGroupMembers = unit == 'party' and GetNumSubgroupMembers() or GetNumGroupMembers()
    local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
    return function()
        local ret
        if i == 0 and unit == 'party' then
            ret = 'player'
        elseif i <= numGroupMembers and i > 0 then
            ret = unit .. i
        end
        i = i + (reversed and -1 or 1)
        return ret
    end
end

function fu.creatColorCurve(point, b)
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Linear)
    curve:AddPoint(0, CreateColor(0, 0, 0, 1))
    curve:AddPoint(point, CreateColor(0, 0, b / 255, 1))
    return curve
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "Fuyutsui" then
        -- 如果配置不存在，则初始化
        if not FuyutsuiDB then
            FuyutsuiDB = {
                aoeMode = 0,
                cooldowns = 0,
                dpsMode = 0
            }
        end

        -- 将保存的数据读回本地变量
        FuyutsuiDB.aoeMode = FuyutsuiDB.aoeMode
        FuyutsuiDB.cooldowns = FuyutsuiDB.cooldowns
        FuyutsuiDB.dpsMode = FuyutsuiDB.dpsMode

        -- 根据读取到的数据初始化界面/状态
        -- 调用一次以同步你代码中的 fu.blocks 逻辑
        C_Timer.After(5, function()
            if switchCooldown then switchCooldown() end
            if switchAoeMode then switchAoeMode() end
            if switchDpsMode then switchDpsMode() end
        end)
    end
end)
