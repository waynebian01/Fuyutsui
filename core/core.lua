local addon, ns = ...
local className, classFilename, classId = UnitClass("player")
Fuyutsui = LibStub("AceAddon-3.0"):NewAddon("Fuyutsui", "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0") -- AceConfig-3.0 是 Ace3 库中的一个模块，用于注册和管理配置选项
local ACD = LibStub("AceConfigDialog-3.0")

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
    self:GetCharacterSpecInfo()
    self:updateSpellKnown()
    self:updatePlayerBlocks()
    self:readKeybindings()
    self:hookChatFrameEditBox()

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
    if self.StartFrameUpdates then
        self:StartFrameUpdates()
    end
    if self.InitQuickToggleButton then
        self:InitQuickToggleButton()
    end
    self.Initialize = true
end

local function CharCfg()
    return Fuyutsui.db and Fuyutsui.db.char
end

local fuDelayEndTimer = nil

local function SaveConfig()
    local c = CharCfg()
    if not c then return end
    c.aoeMode = c.aoeMode or 0
    c.cooldowns = c.cooldowns or 0
    c.dpsMode = c.dpsMode or 0
    c.delay = c.delay or 0
end

--- 与斜杠 / 配置界面一致：print、同步顶部像素、规范化 db.char
function Fuyutsui:SwitchCooldown()
    local c = self.db and self.db.char
    if not c then return end
    if c.cooldowns == 0 then
        print("|cff00ff00[Fuyutsui]|r 爆发已|cffff0000关闭|r") -- 修改"关闭"为红色
    else
        print("|cff00ff00[Fuyutsui]|r 爆发已|cff00ff00开启|r")
    end
    local st = self.blocks and self.blocks.state
    if st and st["爆发开关"] then
        self:CreatTexture(st["爆发开关"], c.cooldowns / 255 or 0)
    end
    SaveConfig()
    if self.RefreshQuickToggleAppearance then
        self:RefreshQuickToggleAppearance()
    end
end

function Fuyutsui:SwitchAoeMode()
    local c = self.db and self.db.char
    if not c then return end
    if c.aoeMode == 0 then
        print("|cff00ff00[Fuyutsui]|r 已切换|cff00ff00自动|r模式！")
    else
        print("|cff00ff00[Fuyutsui]|r 已切换|cff00ff00单体|r模式！")
    end
    local st = self.blocks and self.blocks.state
    if st and st["AOE开关"] then
        self:CreatTexture(st["AOE开关"], c.aoeMode / 255 or 0)
    end
    SaveConfig()
    if self.RefreshQuickToggleAppearance then
        self:RefreshQuickToggleAppearance()
    end
end

function Fuyutsui:SwitchDpsMode()
    local c = self.db and self.db.char
    if not c then return end
    if c.dpsMode == 0 then
        print("|cff00ff00[Fuyutsui]|r 输出模式已修改为|cff00ff00官方一键辅助|r") -- 修改"关闭"为红色
    else
        print("|cff00ff00[Fuyutsui]|r 输出模式已修改为|cff00ff00手动编写逻辑|r")
    end
    local st = self.blocks and self.blocks.state
    if st and st["输出模式"] then
        self:CreatTexture(st["输出模式"], c.dpsMode / 255 or 0)
    end
    SaveConfig()
    if self.RefreshQuickToggleAppearance then
        self:RefreshQuickToggleAppearance()
    end
end

function Fuyutsui:SwitchDelay()
    local c = self.db and self.db.char
    if not c then return end
    if c.delay == 0 then
        print("|cff00ff00[Fuyutsui]|r 延迟已关闭")
    else
        print("|cff00ff00[Fuyutsui]|r 延迟已开启")
    end
    local st = self.blocks and self.blocks.state
    if st and st["延迟"] then
        self:CreatTexture(st["延迟"], c.delay / 255 or 0)
    end
    SaveConfig()
end

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

    -- 游戏内功能
    local c = self.db and self.db.char
    if command == "cd" then
        if not c then return end
        c.cooldowns = (c.cooldowns == 0) and 1 or 0
        self:SwitchCooldown()
    elseif command == "cd on" then
        if not c then return end
        c.cooldowns = 1
        self:SwitchCooldown()
    elseif command == "cd off" then
        if not c then return end
        c.cooldowns = 0
        self:SwitchCooldown()
    elseif command == "aoemode" then
        if not c then return end
        c.aoeMode = (c.aoeMode == 0) and 1 or 0
        self:SwitchAoeMode()
    elseif command == "aoemode auto" then
        if not c then return end
        c.aoeMode = 0
        self:SwitchAoeMode()
    elseif command == "aoemode aoe" then
        if not c then return end
        c.aoeMode = 1
        self:SwitchAoeMode()
    elseif command == "dpsmode" then
        if not c then return end
        c.dpsMode = (c.dpsMode == 0) and 1 or 0
        self:SwitchDpsMode()
    elseif command == "dpsmode manual" then
        if not c then return end
        c.dpsMode = 1
        self:SwitchDpsMode()
    elseif command == "dpsmode assistant" then
        if not c then return end
        c.dpsMode = 0
        self:SwitchDpsMode()
    elseif command:match("^delay") then
        if not c then return end
        local secStr = command:match("^delay%s+(.+)$")
        local sec = 1
        if secStr then
            local trimmed = secStr:match("^%s*(.-)%s*$") or ""
            if trimmed ~= "" then
                local parsed = tonumber(trimmed)
                if parsed and parsed > 0 then
                    sec = parsed
                else
                    print("|cff00ff00[Fuyutsui]|r 无效秒数；请输入正数（例如 /fu delay 5），或不写秒数使用默认 1 秒。")
                    return
                end
            end
        end
        if fuDelayEndTimer then
            fuDelayEndTimer:Cancel()
            fuDelayEndTimer = nil
        end
        c.delay = 1
        self:SwitchDelay()
        fuDelayEndTimer = C_Timer.NewTimer(sec, function()
            fuDelayEndTimer = nil
            local cc = Fuyutsui.db and Fuyutsui.db.char
            if cc then
                cc.delay = 0
                print("|cff00ff00[Fuyutsui]|r db.char.delay 已恢复为 0。")
                self:SwitchDelay()
            end
        end)
        print("|cff00ff00[Fuyutsui]|r db.char.delay 已设为 1，" .. sec .. " 秒后恢复为 0。")
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
        print("临时 delay 标志（db.char.delay 置 1 持续 x 秒后归零）: /fu delay [秒]，省略秒数则为 1 秒")
        print("界面设置(Ace): /fu options")
    elseif command == "gui" then
        if self.OpenInfoGUI then
            self:OpenInfoGUI()
        end
    else
        if self.OpenInfoGUI then
            self:OpenInfoGUI()
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
end

-- /script SetTestSecret(0)
SetTestSecret(1)

function Fuyutsui:IterateGroupMembers(reversed, forceParty)
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

function Fuyutsui:creatColorCurve(point, b)
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Linear)
    curve:AddPoint(0, CreateColor(0, 0, 0, 1))
    curve:AddPoint(point, CreateColor(0, 0, b / 255, 1))
    return curve
end

Fuyutsui.state = {
    classId = classId,
    className = className,
    classFilename = classFilename,
}
Fuyutsui.blocks = {}
Fuyutsui.target = {}
Fuyutsui.nameplate = {}
Fuyutsui.group = {}
Fuyutsui.groupList = {}
Fuyutsui.defaults = {
    profile = {
        someInput = "",
    },
    char = {
        level = 0,
        aoeMode = 0,
        cooldowns = 0,
        dpsMode = 0,
        delay = 0,
        quickButtonCX = 180,
        quickButtonCY = -100,
        quickButtonShow = true,
    },
}
Fuyutsui.options = {
    type = "group",
    name = "Fuyutsui",
    args = {
        intro = {
            type = "description",
            name = "与 /fu 子命令配合；游戏内开关仍保存在「角色专用」变量 FuyutsuiADB（db.char）。",
            fontSize = "medium",
            order = 0,
        },
        someInput = {
            type = "input",
            name = "示例文本",
            desc = "/fu message 会打印此项（profile）",
            order = 10,
            width = "full",
            get = function()
                return (Fuyutsui.db and Fuyutsui.db.profile and Fuyutsui.db.profile.someInput) or ""
            end,
            set = function(_, v)
                if Fuyutsui.db and Fuyutsui.db.profile then
                    Fuyutsui.db.profile.someInput = v or ""
                end
            end,
        },
    }
}
