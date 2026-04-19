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