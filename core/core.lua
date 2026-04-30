local _, fu = ...

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
        print("|cff00ff00[Fuyutsui|r 输出模式已修改为|cff00ff00手动编写逻辑|r")
    end
    if fu.blocks and fu.blocks["输出模式"] then
        fu.updateOrCreatTextureByIndex(fu.blocks["输出模式"], FuyutsuiDB.dpsMode / 255)
    end
    SaveConfig() -- 保存
end

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
    else
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
-- ==================== 屏幕内控制面板 ====================

local switchButtonRegistry = {}

local function updateSwitchButtons()
    for _, v in pairs(switchButtonRegistry) do
        local btn, opt = v.btn, v.opt
        local onText, offText = opt.onText or "ON", opt.offText or "OFF"
        local curState = opt.getter()
        if curState then
            btn:SetText(onText)
            if btn.Left then btn.Left:SetDesaturated(false) end
            if btn.Middle then btn.Middle:SetDesaturated(false) end
            if btn.Right then btn.Right:SetDesaturated(false) end
        else
            btn:SetText(offText)
            if btn.Left then btn.Left:SetDesaturated(true) end
            if btn.Middle then btn.Middle:SetDesaturated(true) end
            if btn.Right then btn.Right:SetDesaturated(true) end
        end
    end
end

local panelFrame = CreateFrame("Frame", "FuyutsuiPanel", UIParent, BackdropTemplateMixin and "BackdropTemplate")
panelFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
panelFrame:SetSize(130, 52)
panelFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
panelFrame:SetBackdropColor(0, 0, 0, 0.5)
panelFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
panelFrame:SetMovable(true)
panelFrame:SetClampedToScreen(true)
panelFrame:SetFrameStrata("LOW")

panelFrame:SetScript("OnMouseDown", function() panelFrame:StartMoving() end)
panelFrame:SetScript("OnMouseUp", function() panelFrame:StopMovingOrSizing() end)

-- 显示/隐藏按钮
local controlButton = CreateFrame("Button", "FuyutsuiControlButton", UIParent, "UIPanelButtonTemplate")
controlButton:SetSize(30, 18)
controlButton:SetPoint("TOP", panelFrame, "BOTTOM", 0, 0)
controlButton:SetFrameStrata("LOW")
controlButton:SetText("隐")
controlButton:SetNormalFontObject("GameFontNormalSmall")
controlButton:SetHighlightFontObject("GameFontHighlightSmall")
controlButton:SetScript("OnClick", function()
    if panelFrame:IsShown() then
        panelFrame:Hide()
        controlButton:SetText("显")
    else
        panelFrame:Show()
        controlButton:SetText("隐")
    end
end)

panelFrame:Show()

-- 快捷键绑定模式 (使用 OverrideBinding, 不会覆盖动作条键位, 重载后失效)
local pendingBindButton = nil
local bindBtnRegistry = {} -- name -> bindBtn frame
local boundKeys = {} -- name -> key (仅当前session)

local bindEditBox = CreateFrame("EditBox", "FuyutsuiBindEditBox", UIParent)
bindEditBox:Hide()
bindEditBox:SetAutoFocus(false)
bindEditBox:SetWidth(0)
bindEditBox:SetHeight(0)
bindEditBox:SetScript("OnKeyDown", function(self, key)
    if not pendingBindButton then
        self:ClearFocus()
        self:Hide()
        return
    end
    -- 忽略修饰键及组合键
    if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL"
        or key == "LALT" or key == "RALT" then
        print("|cFFFFD700Fuyutsui|r: 不支持修饰键，请只按普通键")
        return
    end
    if IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown() then
        print("|cFFFFD700Fuyutsui|r: 不支持修饰键组合，请只按普通键")
        return
    end
    local btnName = pendingBindButton
    pendingBindButton = nil
    self:ClearFocus()
    self:Hide()
    local bindBtn = bindBtnRegistry[btnName]
    -- ESC 取消绑定
    if key == "ESCAPE" then
        if bindBtn then
            ClearOverrideBindings(bindBtn)
        end
        boundKeys[btnName] = nil
        print("|cFFFFD700Fuyutsui|r: 快捷键已清除")
        return
    end
    if not bindBtn then return end
    ClearOverrideBindings(bindBtn)
    SetOverrideBindingClick(bindBtn, false, key, btnName .. "Bind", "LeftButton")
    boundKeys[btnName] = key
    print("|cFFFFD700Fuyutsui|r: " .. key .. " 已绑定")
end)
bindEditBox:SetScript("OnEscapePressed", function(self)
    if pendingBindButton then
        local btnName = pendingBindButton
        pendingBindButton = nil
        self:ClearFocus()
        self:Hide()
        local bindBtn = bindBtnRegistry[btnName]
        if bindBtn then
            ClearOverrideBindings(bindBtn)
        end
        boundKeys[btnName] = nil
        print("|cFFFFD700Fuyutsui|r: 快捷键已清除")
    end
end)

-- 创建开关按钮
local function createSwitchButton(opt)
    local name = opt.name
    local parent = opt.parent
    local onText, offText = opt.onText, opt.offText
    local w, h = opt.width or 60, opt.height or 20
    local anchor = opt.anchor
    local stateGet, stateSet = opt.getter, opt.setter

    local btn = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    btn:SetWidth(w)
    btn:SetHeight(h)
    btn:SetPoint(unpack(anchor))
    btn:SetText(onText)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function(self, mouseBtn)
        if mouseBtn == "RightButton" then
            pendingBindButton = name
            print("|cFFFFD700Fuyutsui|r: 按下要绑定的按键 (ESC取消), 不支持修饰键和组合")
            bindEditBox:Show()
            bindEditBox:SetFocus()
            return
        end
        local curState = stateGet()
        stateSet(not curState)
        updateSwitchButtons()
    end)

    -- 隐藏按钮用于接收快捷键点击
    local bindBtn = CreateFrame("Button", name .. "Bind")
    bindBtn:RegisterForClicks("AnyDown")
    bindBtn:SetScript("OnClick", function()
        local curState = stateGet()
        stateSet(not curState)
        updateSwitchButtons()
    end)
    bindBtnRegistry[name] = bindBtn

    switchButtonRegistry[name] = { btn = btn, opt = opt }

    if opt.tip then
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            local tipText = opt.tip
            local savedKey = boundKeys[name]
            if savedKey then
                tipText = tipText .. "\n|cFFFFD700快捷键: " .. savedKey .. "|r"
            else
                tipText = tipText .. "\n|cFF888888右键点击绑定快捷键|r"
            end
            GameTooltip:AddLine(tipText)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

    return btn
end

-- 爆发按钮
local btnCD = createSwitchButton({
    name = "FuyutsuiCDButton",
    parent = panelFrame,
    onText = "爆发",
    offText = "爆发",
    width = 60,
    height = 20,
    anchor = { "TOPLEFT", panelFrame, "TOPLEFT", 4, -4 },
    tip = "切换爆发开关",
    getter = function() return FuyutsuiDB.cooldowns == 1 end,
    setter = function(v)
        FuyutsuiDB.cooldowns = v and 1 or 0
        switchCooldown()
    end,
})

-- AOE按钮
local btnAOE = createSwitchButton({
    name = "FuyutsuiAOEButton",
    parent = panelFrame,
    onText = "自动",
    offText = "单体",
    width = 60,
    height = 20,
    anchor = { "LEFT", btnCD, "RIGHT", 0, 0 },
    tip = "切换AOE/单体模式",
    getter = function() return FuyutsuiDB.aoeMode == 0 end,
    setter = function(v)
        FuyutsuiDB.aoeMode = v and 0 or 1
        switchAoeMode()
    end,
})

-- 输出模式按钮
local btnDPS = createSwitchButton({
    name = "FuyutsuiDPSButton",
    parent = panelFrame,
    onText = "逻辑",
    offText = "辅助",
    width = 60,
    height = 20,
    anchor = { "TOPLEFT", btnCD, "BOTTOMLEFT", 0, -2 },
    tip = "切换逻辑/辅助输出模式",
    getter = function() return FuyutsuiDB.dpsMode == 1 end,
    setter = function(v)
        FuyutsuiDB.dpsMode = v and 1 or 0
        switchDpsMode()
    end,
})

-- 每 0.5s 刷新按钮状态
local monitorFrame = CreateFrame("Frame")
monitorFrame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 0.5 then
        self.elapsed = 0
        updateSwitchButtons()
    end
end)
    end
end)
