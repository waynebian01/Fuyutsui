local IsSpellKnown = C_SpellBook.IsSpellKnown
-- 创建颜色曲线
local dispelCurve = C_CurveUtil.CreateColorCurve()
dispelCurve:SetType(Enum.LuaCurveType.Step)

-- 各法术的驱散能力映射
local dispelAbilities = {
    [1] = { 527, 360823, 4987, 115450, 88423 },                        -- 魔法驱散
    [2] = { 390632, 213634, 393024, 213644, 388874, 218164 },          -- 疾病驱散
    [3] = { 383016, 51886, 392378, 2782, 475 },                        -- 诅咒驱散
    [4] = { 392378, 2782, 393024, 213644, 388874, 218164, 365585 }     -- 中毒驱散
}

local function updateDispelCapabilities()
    -- 动态生成驱散能力
    local dispelCapabilities = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
    }
    for debuffType, spellIDs in pairs(dispelAbilities) do
        for _, spellID in ipairs(spellIDs) do
            if IsSpellKnown(spellID) then
                dispelCapabilities[debuffType] = true
                break
            end
        end
    end

    for i = 1, 4 do
        if dispelCapabilities[i] then
            dispelCurve:AddPoint(i, CreateColor(0, 1, i / 255, 1))
        else
            dispelCurve:AddPoint(i, CreateColor(0, 0, 0, 1))
        end
    end
end

updateDispelCapabilities()
