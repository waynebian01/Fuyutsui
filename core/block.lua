local _, fu = ...
local screenWidth = GetScreenWidth()

local BLOCK_FIX_CONFIG = {
    blockCount = 255,               -- 总色块数量
    blockWidth = screenWidth / 255, -- 色块宽度
    blockHeight = 2,                -- 色块高度
    blockSpacing = 0,               -- 色块间距
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
-- mainAnchor:Raise()   -- Increases the frame's frame level above all other frames in its strata
fu.MainAnchor = colorBars

-- 存储纹理的数组 (1 到 255)
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
function fu.updateOrCreatTextureByIndex(i, b)
    local tex = creatTextureByIndex(i)
    if tex then
        tex:SetColorTexture(0, i / 255, b, 1)
    end
end

function fu.clearAllTextures()
    for i = 20, BLOCK_FIX_CONFIG.blockCount do
        fu.updateOrCreatTextureByIndex(i, 0)
        -- print("清除色块:", i)
    end
end

for i = 1, BLOCK_FIX_CONFIG.blockCount do
    fu.updateOrCreatTextureByIndex(i, 0)
end

local c = 255
local BAR_CONFIG = {
    count = c,
    width = screenWidth / c,
    height = 2,
    point = "TOPLEFT",
}


-- 创建"色条"的容器
local countBars = CreateFrame("Frame", "FuyutsuiCountBars", UIParent)
countBars:SetSize(screenWidth, 20)
countBars:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -2)
countBars:SetFrameStrata("TOOLTIP") -- 确保在最上层
countBars:SetFrameLevel(1)
local createdBars = {}
local spellIdToBar = {} -- 新增：用于根据 spellId 查找已存在的条
local nextAvailableIndex = 2

---@param minValue number 最小值
---@param maxValue number 最大值
---@param spellId number 法术ID
---@param events table 事件表
function fu.CreateAutoLayoutBar(minValue, maxValue, spellId, events)
    -- --- 新增：重复性检查 ---
    if spellIdToBar[spellId] then
        -- 如果已经存在该 spellId 的条，直接返回，不执行任何操作
        return spellIdToBar[spellId]
    end

    local startIndex = nextAvailableIndex
    local barWidth = maxValue * BAR_CONFIG.width
    nextAvailableIndex = startIndex + maxValue + 2

    if nextAvailableIndex > BAR_CONFIG.count then
        print("警告: FuyutsuiCountBars 空间不足!")
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

    -- 3. 刷新逻辑
    local function Refresh()
        local val = C_Spell.GetSpellCastCount(spellId) or 0
        bar:SetMinMaxValues(minValue, maxValue)
        bar:SetValue(val)
    end

    if events and type(events) == "table" then
        for _, event in ipairs(events) do
            bar:RegisterEvent(event)
        end
        bar:SetScript("OnEvent", Refresh)
    end

    Refresh()

    -- --- 记录数据 ---
    tinsert(createdBars, bar)
    spellIdToBar[spellId] = bar -- 记录此 spellId 已被创建

    return bar
end

--- 清除所有已创建的进度条和背景
function fu.ClearAllFuyutsuiBars()
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
