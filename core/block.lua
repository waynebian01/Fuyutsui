local addon, ns = ...
local screenWidth = GetScreenWidth()

local BLOCK_FIX_COUNT = 510
local BLOCK_FIRST_SCHEME_MAX = 255
local BLOCK_FIX_CONFIG = {
    blockCount = BLOCK_FIX_COUNT,               -- 总色块数量
    blockWidth = screenWidth / BLOCK_FIX_COUNT, -- 色块宽度
    blockHeight = 1,                            -- 色块高度
    blockSpacing = 0,                           -- 色块间距
}

local BAR_CONFIG = {
    count = 255,
    heightOffset = -BLOCK_FIX_CONFIG.blockHeight,
    width = screenWidth / 255,
    height = 1,
    point = "TOPLEFT",
}

-- 计算 X 偏移
local function GetXOffset(index, Width, spacing)
    return index * (Width + spacing)
end

-- 创建"色条"的容器
local colorBars = CreateFrame("Frame", "FuyutsuiColorBars", UIParent)
colorBars:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
colorBars:SetSize(screenWidth, BLOCK_FIX_CONFIG.blockHeight)
colorBars:SetFrameStrata("TOOLTIP") -- 确保在最上层
colorBars:SetFrameLevel(10000)
-- colorBars:Raise()   -- Increases the frame's frame level above all other frames in its strata

-- 存储纹理的数组 (1 到 510)
local pixelTextures = {}

-- 获取特定索引的纹理（如果不存在则创建）
local function creatTextureByIndex(i)
    if i <= 0 or i > BLOCK_FIX_CONFIG.blockCount then return nil end
    if pixelTextures[i] == nil then
        local tex = colorBars:CreateTexture(nil, "OVERLAY")
        tex:SetSize(BLOCK_FIX_CONFIG.blockWidth, BLOCK_FIX_CONFIG.blockHeight)
        tex:SetPoint("TOPLEFT", colorBars, "TOPLEFT",
            GetXOffset(i - 1, BLOCK_FIX_CONFIG.blockWidth, BLOCK_FIX_CONFIG.blockSpacing), 0)
        pixelTextures[i] = tex
    end
    return pixelTextures[i]
end

-- 更新或创建静态色块 (按索引)
-- 索引 1..255: (0, i/255, b, 1)；索引 256..510: (1/255, i/256, b, 1)
function Fuyutsui:CreatTexture(i, b)
    local tex = creatTextureByIndex(i)
    if tex then
        if i > BLOCK_FIRST_SCHEME_MAX then
            tex:SetColorTexture(1 / 255, (i - BLOCK_FIRST_SCHEME_MAX) / 255, b, 1)
        else
            tex:SetColorTexture(0, i / 255, b, 1)
        end
    end
end

function Fuyutsui:clearAllTextures()
    for i = 1, BLOCK_FIX_CONFIG.blockCount do
        self:CreatTexture(i, 0)
    end
end

for i = 1, BLOCK_FIX_CONFIG.blockCount do
    Fuyutsui:CreatTexture(i, 0)
end

-- 创建"色条"的容器
local countBars = CreateFrame("Frame", "FuyutsuiCountBars", UIParent)
countBars:SetSize(screenWidth, 20)
countBars:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, BAR_CONFIG.heightOffset)
countBars:SetFrameStrata("TOOLTIP") -- 确保在最上层
countBars:SetFrameLevel(1)
local createdBars = {}
local spellIdToBar = {} -- 新增：用于根据 spellId 查找已存在的条
local nextAvailableIndex = 2
-- 多条 bar 共用一个终点色块，始终画在当前序列里最后创建的那条末尾
local countBarEndTexture = nil

local events = { "SPELL_UPDATE_USES", "PLAYER_ENTERING_WORLD", "SPELL_UPDATE_CHARGES" }
---@param minValue number 最小值
---@param maxValue number 最大值
---@param spellId number 法术ID
function Fuyutsui:CreateAutoLayoutBar(valueType, minValue, maxValue, spellId)
    maxValue = maxValue or 0
    minValue = minValue or 0
    -- 重复性检查
    if spellIdToBar[spellId] then
        return spellIdToBar[spellId]
    end

    local startIndex = nextAvailableIndex
    local barWidth = maxValue * BAR_CONFIG.width
    -- +1 为末尾灰色终点色块，再 +2 为与下一条 bar 的间隔（与原逻辑一致）
    nextAvailableIndex = startIndex + maxValue + 3

    if nextAvailableIndex > BAR_CONFIG.count then
        print("警告: Fuyutsui_CountBars 空间不足!")
        return nil
    end

    -- 1. 创建进度条主体
    local bar = CreateFrame("StatusBar", nil, countBars)
    bar:SetSize(barWidth + 1, BAR_CONFIG.height) -- +1 确保满格时能完全覆盖
    bar:SetPoint("TOPLEFT", countBars, "TOPLEFT", (startIndex - 1) * BAR_CONFIG.width, 0)
    bar:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
    bar:GetStatusBarTexture():SetDrawLayer("ARTWORK")
    bar:SetStatusBarColor(1, 1, 1, 1)
    bar:SetFrameLevel(5000)

    -- 2. 创建背景色块 (左右各多出一个)
    for i = -1, maxValue do
        local currentRelativeIndex = i + 1
        local absolutePos = startIndex + i

        local tex = countBars:CreateTexture(nil, "BACKGROUND")
        tex:SetSize(BAR_CONFIG.width, BAR_CONFIG.height)
        tex:SetPoint("TOPLEFT", countBars, "TOPLEFT", (absolutePos - 1) * BAR_CONFIG.width, 0)
        tex:SetColorTexture(1 / 255, currentRelativeIndex / 255, 0, 1)
    end

    -- 2b. 末尾终点色块 (200, 200, 200)：仅显示在最后一次创建的 bar 上（复用同一纹理并改锚点）
    local endPos = startIndex + maxValue + 1
    if not countBarEndTexture then
        countBarEndTexture = countBars:CreateTexture(nil, "BACKGROUND")
        countBarEndTexture:SetSize(BAR_CONFIG.width, BAR_CONFIG.height)
    end
    countBarEndTexture:ClearAllPoints()
    countBarEndTexture:SetPoint("TOPLEFT", countBars, "TOPLEFT", (endPos - 1) * BAR_CONFIG.width, 0)
    countBarEndTexture:SetColorTexture(200 / 255, 200 / 255, 200 / 255, 1)
    countBarEndTexture:Show()

    -- 3. 刷新逻辑
    local function Refresh()
        local val = 0
        if valueType == "castCount" then
            val = C_Spell.GetSpellCastCount(spellId) or 0
        elseif valueType == "charge" then
            local charges = C_Spell.GetSpellCharges(spellId)
            if not charges then return end
            val = charges.currentCharges or 0
        end
        bar:SetMinMaxValues(minValue, maxValue)
        bar:SetValue(val)
    end

    for _, event in ipairs(events) do
        bar:RegisterEvent(event)
    end
    bar:SetScript("OnEvent", Refresh)

    Refresh()

    tinsert(createdBars, bar)
    spellIdToBar[spellId] = bar -- 记录此 spellId 已被创建

    return bar
end

--- 清除所有已创建的进度条和背景
function Fuyutsui:ClearAllFuyutsuiBars()
    -- 1. 释放框架
    for _, bar in ipairs(createdBars) do
        bar:UnregisterAllEvents()
        bar:SetScript("OnEvent", nil)
        bar:Hide()
        bar:SetParent(nil)
    end

    -- 2. 清除纹理
    local regions = { countBars:GetRegions() }
    for _, region in ipairs(regions) do
        if region:IsObjectType("Texture") then
            ---@diagnostic disable-next-line: undefined-field
            region:SetColorTexture(0, 0, 0, 0)
            region:Hide()
        end
    end

    -- 3. 重置所有状态表
    wipe(createdBars)
    wipe(spellIdToBar) -- 必须清空映射表，否则下次无法重新创建
    nextAvailableIndex = 2

    -- print("|cff00ff00FuyutsuiBars 清除成功: 计数器与法术映射已重置。|r")
end

-- ================================================================
--                     玩家光环图标
-- ================================================================
local AURA_LAYER_PADDING = 4                                                    -- 尺寸递增
local AURA_ICON_SIZE = 22                                                       -- 图标尺寸
local AURA_WHITE_BLOCK_SIZE = AURA_ICON_SIZE + 3                                -- 白底尺寸
local AURA_COOLDOWN_BLOCK_SIZE = AURA_WHITE_BLOCK_SIZE + 4                      -- 冷却尺寸
local AURA_MARKER_WIDTH = 2                                                     -- 标记宽度
local AURA_ICON_SPACING = 0                                                     -- 图标间距
local AURA_APP_BAR_MAX = 20                                                     -- 光环层数条 最大值 (0-20)
local AURA_APP_BAR_BG_COUNT = AURA_APP_BAR_MAX + 1                              -- 背景色块数量 (0-20 共 21 格)
local AURA_APP_BAR_HEIGHT = 2                                                   -- 光环层数条 高度
local AURA_APP_BAR_WIDTH = 20                                                   -- StatusBar 宽度 (固定 20px)
local AURA_APP_BAR_BG_WIDTH = 21                                                -- 背景宽度 (固定 21px)
local AURA_SLOT_SIZE = AURA_COOLDOWN_BLOCK_SIZE                                 -- 槽位尺寸
local AURA_SLOT_PITCH = AURA_SLOT_SIZE + AURA_ICON_SPACING                      -- 槽位间距
local AURA_APP_BAR_BG_SEG_WIDTH = AURA_APP_BAR_BG_WIDTH / AURA_APP_BAR_BG_COUNT -- 光环层数条 背景段宽度
local AURA_ROW_HEIGHT = AURA_SLOT_SIZE + AURA_APP_BAR_HEIGHT                    -- 行高
local AURA_ROW_SPACING = 4                                                      -- 两行之间的额外间距
local auraDurationCurve = Fuyutsui:creatColorCurve(255, 255)                    -- 光环持续时间曲线

local auraIconBars = CreateFrame("Frame", "FuyutsuiAuraIcons", UIParent)        -- 光环图标容器
auraIconBars:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, BAR_CONFIG.heightOffset - 4)
auraIconBars:SetSize(screenWidth, AURA_ROW_HEIGHT * 2 + AURA_ROW_SPACING)
auraIconBars:SetFrameStrata("TOOLTIP")
auraIconBars:SetFrameLevel(1)
auraIconBars:SetMovable(true)
auraIconBars:SetClampedToScreen(true)

local function saveAuraIconBarsPosition()
    local c = Fuyutsui.db and Fuyutsui.db.char
    if not c then return end
    local p, _, rp, x, y = auraIconBars:GetPoint(1)
    if p and x and y then
        c.auraIconPoint = p
        c.auraIconRelPoint = rp or p
        c.auraIconX = x
        c.auraIconY = y
    end
end

local function restoreAuraIconBarsPosition()
    local c = Fuyutsui.db and Fuyutsui.db.char
    if c and c.auraIconPoint and c.auraIconX and c.auraIconY then
        auraIconBars:ClearAllPoints()
        auraIconBars:SetPoint(c.auraIconPoint, UIParent, c.auraIconRelPoint or c.auraIconPoint, c.auraIconX, c.auraIconY)
    end
end

restoreAuraIconBarsPosition()

local function enableAuraIconDrag(dragFrame)
    dragFrame:EnableMouse(true)
    dragFrame:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then return end
        auraIconBars:StartMoving()
        auraIconBars:SetScript("OnUpdate", function(frame)
            if not IsMouseButtonDown("LeftButton") then
                frame:StopMovingOrSizing()
                frame:SetScript("OnUpdate", nil)
                saveAuraIconBarsPosition()
            end
        end)
    end)
end

local buffIconSlots = {}
local debuffIconSlots = {}

local function createRowMarker(r, g, b)
    local tex = auraIconBars:CreateTexture(nil, "OVERLAY")
    tex:SetSize(AURA_MARKER_WIDTH, AURA_ROW_HEIGHT)
    tex:SetColorTexture(r, g, b, 1)
    return tex
end

local buffRowStartMarker = createRowMarker(0, 1, 0)
local buffRowEndMarker = createRowMarker(0, 1, 0)
local debuffRowStartMarker = createRowMarker(1, 0, 0)
local debuffRowEndMarker = createRowMarker(1, 0, 0)

local function updateRowMarkers(startMarker, endMarker, count, rowOffset)
    startMarker:ClearAllPoints()
    startMarker:SetPoint("TOPLEFT", auraIconBars, "TOPLEFT", 0, rowOffset)
    startMarker:Show()

    endMarker:ClearAllPoints()
    endMarker:SetPoint("TOPLEFT", auraIconBars, "TOPLEFT",
        AURA_MARKER_WIDTH + count * AURA_SLOT_SIZE + math.max(0, count - 1) * AURA_ICON_SPACING, rowOffset)
    endMarker:Show()
end

local function getAuraRemainingB(unit, auraInstanceID)
    local duration = C_UnitAuras.GetAuraDuration(unit, auraInstanceID)
    if duration then
        local auraduration = duration:EvaluateRemainingDuration(auraDurationCurve)
        ---@diagnostic disable-next-line: param-type-mismatch
        local _, _, b = auraduration:GetRGB()
        return b
    else
        return 0
    end
end

local function createAuraIconSlot(parent)
    local slot = CreateFrame("Frame", nil, parent)
    slot:SetSize(AURA_SLOT_SIZE, AURA_SLOT_SIZE)

    slot.cooldownBlock = slot:CreateTexture(nil, "BACKGROUND")
    slot.cooldownBlock:SetSize(AURA_COOLDOWN_BLOCK_SIZE, AURA_COOLDOWN_BLOCK_SIZE)
    slot.cooldownBlock:SetPoint("CENTER", slot, "CENTER", 0, 0)

    slot.whiteBlock = slot:CreateTexture(nil, "BORDER")
    slot.whiteBlock:SetSize(AURA_WHITE_BLOCK_SIZE, AURA_WHITE_BLOCK_SIZE)
    slot.whiteBlock:SetPoint("CENTER", slot, "CENTER", 0, 0)
    slot.whiteBlock:SetColorTexture(1, 1, 1, 1)

    slot.icon = slot:CreateTexture(nil, "ARTWORK")
    slot.icon:SetSize(AURA_ICON_SIZE, AURA_ICON_SIZE)
    slot.icon:SetPoint("CENTER", slot, "CENTER", 0, 0)

    slot.dragHit = CreateFrame("Frame", nil, slot)
    slot.dragHit:SetSize(AURA_ICON_SIZE, AURA_ICON_SIZE)
    slot.dragHit:SetPoint("CENTER", slot.icon, "CENTER", 0, 0)
    slot.dragHit:SetFrameLevel(30)
    enableAuraIconDrag(slot.dragHit)

    slot.appBarFrame = CreateFrame("Frame", nil, slot)
    slot.appBarFrame:SetSize(AURA_APP_BAR_BG_WIDTH, AURA_APP_BAR_HEIGHT)
    slot.appBarFrame:SetPoint("TOP", slot, "BOTTOM", 0, 0)
    slot.appBarFrame:SetFrameLevel(20)

    slot.appBarBg = {}
    for segIndex = 0, AURA_APP_BAR_MAX do
        local tex = slot.appBarFrame:CreateTexture(nil, "OVERLAY")
        tex:SetSize(AURA_APP_BAR_BG_SEG_WIDTH, AURA_APP_BAR_HEIGHT)
        tex:SetPoint("TOPLEFT", slot.appBarFrame, "TOPLEFT", segIndex * AURA_APP_BAR_BG_SEG_WIDTH, 0)
        slot.appBarBg[segIndex] = tex
    end

    slot.appBar = CreateFrame("StatusBar", nil, slot.appBarFrame)
    slot.appBar:SetSize(AURA_APP_BAR_WIDTH, AURA_APP_BAR_HEIGHT)
    slot.appBar:SetPoint("TOPLEFT", slot.appBarFrame, "TOPLEFT", 0, 0)
    slot.appBar:SetFrameLevel(21)
    slot.appBar:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
    slot.appBar:GetStatusBarTexture():SetDrawLayer("OVERLAY")
    slot.appBar:SetStatusBarColor(1, 1, 1, 1)
    slot.appBar:SetMinMaxValues(0, AURA_APP_BAR_MAX)
    slot.appBar:SetValue(0)

    return slot
end

local function setSlotCooldownColor(slot, r, g, b)
    slot.cooldownBlock:SetColorTexture(r, g, b, 1)
end

local function setSlotAppBarBgColor(slot, r, g)
    for segIndex = 0, AURA_APP_BAR_MAX do
        slot.appBarBg[segIndex]:SetColorTexture(r, g, segIndex / 255, 1)
    end
end

local function collectAurasSorted(auraTable)
    local list = {}
    for _, aura in pairs(auraTable) do
        tinsert(list, aura)
    end
    table.sort(list, function(a, b)
        return a.auraInstanceID < b.auraInstanceID
    end)
    return list
end

local function updateAuraIconRow(slots, auras, rowOffset, borderR, unit)
    local sorted = collectAurasSorted(auras)
    local slotIndex = 0
    for i, aura in ipairs(sorted) do
        slotIndex = slotIndex + 1
        local slot = slots[slotIndex]
        if not slot then
            slot = createAuraIconSlot(auraIconBars)
            slots[slotIndex] = slot
        end
        slot:ClearAllPoints()
        slot:SetPoint("TOPLEFT", auraIconBars, "TOPLEFT", AURA_MARKER_WIDTH + (slotIndex - 1) * AURA_SLOT_PITCH,
            rowOffset)
        slot:Show()

        local b = getAuraRemainingB(unit, aura.auraInstanceID)
        local borderG = i / 255
        setSlotCooldownColor(slot, borderR, borderG, b)
        setSlotAppBarBgColor(slot, borderR, borderG)

        local icon = aura.icon
        if not icon and aura.spellId then
            icon = C_Spell.GetSpellTexture(aura.spellId)
        end
        if icon then
            slot.icon:SetTexture(icon)
            slot.icon:Show()
        else
            slot.icon:Hide()
        end

        local applications = aura.applications or 0
        slot.appBar:SetValue(applications)
    end
    for i = slotIndex + 1, #slots do
        slots[i]:Hide()
    end
    return slotIndex
end

---@param AurasTable table
function Fuyutsui:UpdateAuraIcons(AurasTable, AurasTable2)
    if not AurasTable then return end
    local buffCount = updateAuraIconRow(buffIconSlots, AurasTable or {}, 0, 2 / 255, "player")
    updateRowMarkers(buffRowStartMarker, buffRowEndMarker, buffCount, 0)
    local debuffCount = updateAuraIconRow(debuffIconSlots, AurasTable2 or {}, -AURA_ROW_HEIGHT - AURA_ROW_SPACING,
        3 / 255, "target")
    updateRowMarkers(debuffRowStartMarker, debuffRowEndMarker, debuffCount, -AURA_ROW_HEIGHT - AURA_ROW_SPACING)
end
