local _, fu = ...
Fuyutsui = LibStub("AceAddon-3.0"):NewAddon("Fuyutsui", "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0") -- AceConfig-3.0 是 Ace3 库中的一个模块，用于注册和管理配置选项
local ACD = LibStub("AceConfigDialog-3.0")
local className, classFilename, classId = UnitClass("player")
local specIndex = C_SpecializationInfo.GetSpecialization()
print("职业:", className, "职业文件:", classFilename, "职业ID:", classId, "专精索引:", specIndex)
fu.className, fu.classFilename, fu.classId = className, classFilename, classId
fu.specIndex = specIndex

function Fuyutsui:OnInitialize()
    -- 使用“默认”配置文件，而非特定角色的配置文件。
    -- https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
    self.db = LibStub("AceDB-3.0"):New("FuyutsuiADB", self.defaults, true)
    -- 注册一个选项表，并将其添加到暴雪选项窗口中。
    -- https://www.wowace.com/projects/ace3/pages/api/ace-config-3-0
    AC:RegisterOptionsTable("Fuyutsui_Options", self.options)
    self.optionsFrame = ACD:AddToBlizOptions("Fuyutsui_Options", "Fuyutsui")
    -- 添加一个子选项表 —— 即我们的配置文件面板。
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    AC:RegisterOptionsTable("Fuyutsui_Profiles", profiles)
    ACD:AddToBlizOptions("Fuyutsui_Profiles", "Profiles", "Fuyutsui")
    -- 注册斜杠命令
    self:RegisterChatCommand("fu", "SlashCommand")
    self:RegisterChatCommand("Fuyutsui", "SlashCommand")

    self:GetCharacterInfo()
end

function Fuyutsui:OnEnable()
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:RegisterEvent("PLAYER_DEAD")
    self:RegisterEvent("PLAYER_ALIVE")
    self:RegisterEvent("PLAYER_UNGHOST")
    self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_STARTED_MOVING")
    self:RegisterEvent("PLAYER_STOPPED_MOVING")
    self:RegisterEvent("UNIT_SPELLCAST_SENT")
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UNIT_SPELLCAST_STOP")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("UNIT_SPELLCAST_FAILED")
    self:RegisterEvent("UNIT_POWER_UPDATE")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
    self:RegisterEvent("UNIT_HEAL_PREDICTION")
    self:RegisterEvent("SPELL_UPDATE_USES")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("UNIT_DIED")
    self:RegisterEvent("SPELL_RANGE_CHECK_UPDATE")
    self:RegisterEvent("ACTION_RANGE_CHECK_UPDATE")
    self:RegisterEvent("UI_ERROR_MESSAGE")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self:RegisterEvent("SPELL_UPDATE_ICON")
    self:RegisterEvent("COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED")
    self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
    self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
    self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_SHOW")
    self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_HIDE")

    self:RegisterEvent("UPDATE_BINDINGS")
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("ACTIONBAR_HIDEGRID")
    self:RegisterEvent("ACTIONBAR_SHOWGRID")

    self:PLAYER_LOGIN()
    if self.StartFrameUpdates then
        self:StartFrameUpdates()
    end
end

function Fuyutsui:GetCharacterInfo()
    self.db.char.level = UnitLevel("player")
end

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

--- AceConsole：由 RegisterChatCommand("fu"|"fuyutsui", "SlashCommand") 分发，勿再手写 SlashCmdList
function Fuyutsui:SlashCommand(input, editbox)
    input = (input or ""):trim()
    local command = string.lower(input)

    -- Ace 调试 / 选项（子命令优先于游戏逻辑同名）
    if command == "enable" then
        self:Enable()
        self:Print("Enabled.")
        return
    elseif command == "disable" then
        self:Disable()
        self:Print("Disabled.")
        return
    elseif command == "message" then
        print("this is our saved message:", self.db and self.db.profile and self.db.profile.someInput)
        return
    elseif command == "options" or command == "config" then
        if self.optionsFrame and self.optionsFrame.name then
            Settings.OpenToCategory(self.optionsFrame.name)
        else
            self:Print("选项界面未就绪。")
        end
        return
    end

    -- 游戏内功能（原 Fuyutsui_SlashHandler）
    if command == "cd" then
        FuyutsuiDB.cooldowns = (FuyutsuiDB.cooldowns == 0) and 1 or 0
        switchCooldown()
    elseif command == "cd on" then
        FuyutsuiDB.cooldowns = 1
        switchCooldown()
    elseif command == "cd off" then
        FuyutsuiDB.cooldowns = 0
        switchCooldown()
    elseif command == "aoemode" then
        FuyutsuiDB.aoeMode = (FuyutsuiDB.aoeMode == 0) and 1 or 0
        switchAoeMode()
    elseif command == "aoemode auto" then
        FuyutsuiDB.aoeMode = 0
        switchAoeMode()
    elseif command == "aoemode aoe" then
        FuyutsuiDB.aoeMode = 1
        switchAoeMode()
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
        print("|cff00ff00Fuyutsui|r 命令列表:")
        print("爆发开关: /fu cd")
        print("|cff00ff00开启|r爆发: /fu cd on")
        print("|cffff0000关闭|r爆发: /fu cd off")
        print("切换AOE模式: /fu aoemode")
        print("切换AOE为|cff00ff00自动|r: /fu aoemode auto")
        print("切换AOE为|cff00ff00单体|r: /fu aoemode aoe")
        print("切换输出模式: /fu dpsmode")
        print("切换输出模式为|cff00ff00手写逻辑|r: /fu dpsmode manual")
        print("切换输出模式为|cff00ff00一键辅助|r: /fu dpsmode assistant")
        print("界面设置(Ace): /fu options")
    elseif command == "gui" then
        if fu.OpenInfoGUI then
            fu.OpenInfoGUI()
        end
    else
        if fu.OpenInfoGUI then
            fu.OpenInfoGUI()
        elseif self.optionsFrame and self.optionsFrame.name then
            Settings.OpenToCategory(self.optionsFrame.name)
        else
            self:Print("输入 /fu help 查看命令。")
        end
    end
end

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
