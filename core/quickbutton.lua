local addon, ns = ...

local DRAG_THRESHOLD = 10

local function CharCfg()
    return Fuyutsui.db and Fuyutsui.db.char
end

function Fuyutsui:RefreshQuickToggleAppearance()
    local f = self.quickToggleFrame
    if not f or not f:IsShown() then return end
    local c = CharCfg()
    if not c then return end
    local cdOn = (c.cooldowns or 0) == 1
    local aoe = c.aoeMode or 0
    local dpsAssistant = (c.dpsMode or 0) == 0
    if f.bg then
        if cdOn then
            f.bg:SetColorTexture(0.15, 0.45, 0.2, 0.92)
        else
            f.bg:SetColorTexture(0.35, 0.12, 0.12, 0.92)
        end
    end
    if f.textAll then
        local burst = cdOn and "|cff00ff00开|r" or "|cffff4444关|r"
        local aoeStr = (aoe == 0) and "|cff00ff00自|r" or "|cffffaa00单|r"
        local dpsStr = dpsAssistant and "|cff88ccff官|r" or "|cffcccc33手|r"
        f.textAll:SetText(("爆%s\n群%s\n模%s"):format(burst, aoeStr, dpsStr))
    end
end

local function SaveQuickButtonPosition(self)
    local c = CharCfg()
    if not c then return end
    local p, _, rp, x, y = self:GetPoint(1)
    if p and x and y then
        c.quickButtonPoint = p
        c.quickButtonRelPoint = rp or p
        c.quickButtonX = x
        c.quickButtonY = y
    end
end

function Fuyutsui:InitQuickToggleButton()
    if self.quickToggleFrame then
        self:RefreshQuickToggleAppearance()
        return
    end

    local c = CharCfg()
    local f = CreateFrame("Button", "FuyutsuiQuickToggle", UIParent, "BackdropTemplate")
    f:SetSize(50, 50)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
    f:SetMovable(true)

    local p = c and c.quickButtonPoint
    if p and c.quickButtonX and c.quickButtonY then
        f:SetPoint(p, UIParent, c.quickButtonRelPoint or p, c.quickButtonX, c.quickButtonY)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", c and c.quickButtonCX or 180, c and c.quickButtonCY or -100)
    end

    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints()
    f.bg:SetColorTexture(0.2, 0.2, 0.2, 0.9)

    local fs = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("CENTER", f, "CENTER", 0, 0)
    fs:SetWidth(46)
    fs:SetJustifyH("CENTER")
    fs:SetJustifyV("MIDDLE")
    local fontFile, fontSize = fs:GetFont()
    fs:SetFont(fontFile or "Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    f.textAll = fs

    f:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    f:SetBackdropBorderColor(0.4, 0.4, 0.55, 1)

    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Fuyutsui", 0, 1, 0.6)
        GameTooltip:AddLine("左键：切换爆发开/关", 1, 1, 1, true)
        GameTooltip:AddLine("右键：切换 AOE（自动 / 单体）", 1, 1, 1, true)
        GameTooltip:AddLine("中键：切换输出模式（官方辅助 / 手动逻辑）", 1, 1, 1, true)
        GameTooltip:AddLine("按住左键拖动：移动按钮", 0.85, 0.85, 0.85, true)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", GameTooltip_Hide)

    local function finishLeftDrag(s)
        if not s._dragActive then return end
        s:StopMovingOrSizing()
        s._dragActive = false
        SaveQuickButtonPosition(s)
    end

    f:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        self._dragStartX, self._dragStartY = GetCursorPosition()
        self._didDrag = false
        self._dragActive = false
        self:SetScript("OnUpdate", function(s)
            if not s._dragStartX then return end
            if s._dragActive then
                if not IsMouseButtonDown("LeftButton") then
                    finishLeftDrag(s)
                    s._dragStartX, s._dragStartY = nil, nil
                    s:SetScript("OnUpdate", nil)
                end
                return
            end
            local x, y = GetCursorPosition()
            local dx = math.abs(x - s._dragStartX)
            local dy = math.abs(y - s._dragStartY)
            if dx > DRAG_THRESHOLD or dy > DRAG_THRESHOLD then
                s._dragActive = true
                s._didDrag = true
                s:StartMoving()
            end
        end)
    end)

    f:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:SetScript("OnUpdate", nil)
            if self._dragActive then
                finishLeftDrag(self)
            elseif not self._didDrag then
                local ch = CharCfg()
                if ch and Fuyutsui.SwitchCooldown then
                    ch.cooldowns = (ch.cooldowns == 0) and 1 or 0
                    Fuyutsui:SwitchCooldown()
                end
            end
            self._dragStartX, self._dragStartY = nil, nil
            self._didDrag = false
            self._dragActive = false
        end
    end)

    f:SetScript("OnClick", function(self, button)
        local ch = CharCfg()
        if button == "RightButton" then
            if ch and Fuyutsui.SwitchAoeMode then
                ch.aoeMode = (ch.aoeMode == 0) and 1 or 0
                Fuyutsui:SwitchAoeMode()
            end
        elseif button == "MiddleButton" then
            if ch and Fuyutsui.SwitchDpsMode then
                ch.dpsMode = (ch.dpsMode == 0) and 1 or 0
                Fuyutsui:SwitchDpsMode()
            end
        end
    end)

    self.quickToggleFrame = f
    self:RefreshQuickToggleAppearance()
end
