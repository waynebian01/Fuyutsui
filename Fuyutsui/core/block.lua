local _, fu = ...
local screenWidth = GetScreenWidth()

local BLOCK_FIX_CONFIG = {
    blockCount = 255,               -- 总色块数量
    blockWidth = screenWidth / 255, -- 色块宽度
    blockHeight = 1,                -- 色块高度
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

local c = 200
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

local nextAvailableIndex = 2

---@param minValue number 最小值
---@param maxValue number 最大值
---@param valueAPI function 获取当前值的API
---@param events table 事件表
function fu.CreateAutoLayoutBar(minValue, maxValue, valueAPI, events)
    local startIndex = nextAvailableIndex
    local barWidth = maxValue * BAR_CONFIG.width

    -- 计算总占用长度：左侧(1) + 进度条(maxValue) + 右侧(1)
    -- 下一个起始点需要再加 1 个空白间隔色块
    nextAvailableIndex = startIndex + maxValue + 2

    if nextAvailableIndex > BAR_CONFIG.count then
        print("警告: FuyutsuiCountBars 空间不足!")
        return nil
    end

    -- 1. 创建进度条主体
    local bar = CreateFrame("StatusBar", nil, countBars)
    bar:SetSize(barWidth, BAR_CONFIG.height)
    bar:SetPoint("TOPLEFT", countBars, "TOPLEFT", (startIndex - 1) * BAR_CONFIG.width + 1, 0)
    bar:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
    bar:GetStatusBarTexture():SetDrawLayer("ARTWORK")
    bar:SetStatusBarColor(1, 1, 1, 1) -- 纯白填充
    bar:SetFrameLevel(10000)

    -- 2. 创建背景色块 (左右各多出一个，共 maxValue + 2 个)
    -- 颜色从 i = -1 开始计算，这样左侧多出的色块 G 通道固定为 0
    for i = -1, maxValue do
        local currentRelativeIndex = i + 1 -- 将范围 [-1, maxValue] 映射到 [0, maxValue + 1]
        local absolutePos = startIndex + i -- 实际在屏幕上的位置

        local tex = countBars:CreateTexture(nil, "BACKGROUND")
        tex:SetSize(BAR_CONFIG.width, BAR_CONFIG.height)
        tex:SetPoint("TOPLEFT", countBars, "TOPLEFT", (absolutePos - 1) * BAR_CONFIG.width, 0)

        -- 核心逻辑：颜色根据相对于当前条的偏移量计算
        -- 每一个进度条的第一个色块（左侧多出的）颜色均为 (1/255, 0, 0)
        tex:SetColorTexture(1 / 255, currentRelativeIndex / 255, 0, 1)
    end

    -- 3. 刷新逻辑
    local function Refresh()
        local val = valueAPI()
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
    return bar
end
