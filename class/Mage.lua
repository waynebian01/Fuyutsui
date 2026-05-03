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
    fu.countBars = nil
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
                    auraRef = fu.Auras["热能真空"],
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
                    auraRef = fu.Auras["冰冷智慧"],
                    showKey = "remaining",
                },
                ["冰冻之雨"] = {
                    index = 34,
                    auraRef = fu.Auras["冰冻之雨"],
                    showKey = "remaining",
                },
                ["寒冰指"] = {
                    index = 35,
                    auraRef = fu.Auras["寒冰指"],
                    showKey = "remaining",
                },
                ["寒冰指层数"] = {
                    index = 36,
                    auraRef = fu.Auras["寒冰指"],
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
        [1] = "寒冰屏障",
        [2] = "解除诅咒",
        [3] = "强化隐形术",
        [4] = "超级新星",
        [5] = "冰锥术",
        [6] = "操控时间",
        [7] = "回归",
        [8] = "时间扭曲",
        [9] = "镜像",
        [10] = "法术反制",
        [11] = "闪现术",
        [12] = "缓落术",
        [13] = "魔爆术",
        [14] = "寒冰新星",
        [15] = "闪光术",
        [16] = "传送距离",
        [17] = "闪回",
        [18] = "强化隐形术",
        [19] = "冰霜新星",
        [20] = "龙息术",
        [21] = "群体隐形",
        [22] = "法术吸取",
        [23] = "[@cursor]暴风雪",

        [25] = "奥术智慧",
        [26] = "寒冰箭",
        [27] = "冰川尖刺",
        [28] = "冰枪术",
        [29] = "冰霜射线",
        [30] = "冰风暴",
        [31] = "寒冰宝珠",
        [32] = "霜火之箭",
        [33] = "彗星风暴",
        [34] = "急速冷却",
        [35] = "棱光护体",
        [36] = "奥术脉冲",
        [37] = "奥术弹幕",
        [38] = "大法师之触",
        [39] = "奥术飞弹",
        [40] = "奥术冲击",
        [41] = "奥术宝珠",
        [42] = "奥术涌动",
        [43] = "烈焰护体",
        [44] = "深寒凝冰",
        [45] = "燃烧",
        [46] = "[@cursor]流星",
        [47] = "火球术",
        [48] = "火焰冲击",
        [49] = "炎爆术",
        [50] = "[@cursor]烈焰风暴",
        [51] = "变形术",
        [52] = "霜火之箭",

        [54] = "灼烧",
        [55] = "造餐术",
    }
    fu.CreateMacro(dynamicSpells, staticSpells, specialSpells)
end
