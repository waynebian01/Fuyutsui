local _, fu = ...
if fu.classId ~= 8 then return end
local creat = fu.updateOrCreatTextureByIndex

fu.HarmfulSpellId = 116 -- 寒冰箭

fu.heroSpell = {
    [443739] = 1, -- 疾咒师
    [448601] = 2, -- 日怒
    [431044] = 3, -- 霜火
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then

    elseif specIndex == 2 then

    elseif specIndex == 3 then
        fu.powerType = "MANA"
        fu.blocks = {
            ["施法技能"] = 22,
            ["敌人人数"] = 23,
            auras = {
                ["热能真空"] = {
                    index = 31,
                    auraRef = fu.auras["热能真空"],
                    showKey = "remaining",
                },
                ["冰川尖刺！"] = {
                    index = 32,
                    auraRef = fu.updateAuras.byIcon[116],
                    showKey = "isIcon",
                    name = "冰川尖刺！",
                },
                ["冰冷智慧"] = {
                    index = 33,
                    auraRef = fu.auras["冰冷智慧"],
                    showKey = "remaining",
                },
                ["冰冻之雨"] = {
                    index = 34,
                    auraRef = fu.auras["冰冻之雨"],
                    showKey = "remaining",
                },
                ["寒冰指"] = {
                    index = 35,
                    auraRef = fu.auras["寒冰指"],
                    showKey = "remaining",
                },
                ["寒冰指层数"] = {
                    index = 36,
                    auraRef = fu.auras["寒冰指"],
                    showKey = "count",
                },
            },
        }
        fu.spellCooldown = {
            [475] = { index = 41, name = "解除诅咒" },
            [110959] = { index = 42, name = "强化隐形术" },
            [122] = { index = 43, name = "冰霜新星" },
            [2139] = { index = 44, name = "法术反制" },
            [31661] = { index = 45, name = "龙息术" },
            [1248829] = { index = 46, name = "暴风雪" },
            [190356] = { index = 47, name = "暴风雪" },
            [84714] = { index = 48, name = "寒冰宝珠" },
            [205021] = { index = 49, name = "冰霜射线" },
            [11426] = { index = 50, name = "寒冰护体" },
            [44614] = { index = 51, name = "冰风暴", charge = 52 },
        }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = { "解除诅咒" }
    local specialSpells = {}
    local staticSpells = {
        [1] = "寒冰箭",
        [2] = "强化隐形术",
        [3] = "冰霜新星",
        [4] = "法术反制",
        [5] = "变形术",
        [6] = "奥术智慧",
        [7] = "法术吸取",
        [8] = "冰枪术",
        [9] = "寒冰宝珠",
        [10] = "冰霜射线",
        [11] = "冰风暴",
        [12] = "寒冰护体",
        [13] = "暴风雪",
        [14] = "龙息术",
    }
    fu.CreateMacro(dynamicSpells, staticSpells, specialSpells)
end
