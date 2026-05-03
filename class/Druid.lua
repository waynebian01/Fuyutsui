local _, fu = ...
if fu.classId ~= 11 then return end

local creat = fu.updateOrCreatTextureByIndex

fu.HelpfulSpellId = 774
fu.HarmfulSpellId = 5176

fu.heroSpell = {
    [424058] = 1, -- 艾露恩钦选者
    [433901] = 2, -- 丛林守护者
    [441583] = 3, -- 利爪德鲁伊
    [439528] = 4, -- 荒野追猎者
}

fu.spellCooldown = {
    [22812] = { index = 31, name = "树皮术" },
    [132469] = { index = 32, name = "台风" },
    [99] = { index = 33, name = "夺魂咆哮" },
    [29166] = { index = 34, name = "激活" },
    [102793] = { index = 35, name = "乌索尔旋风" },
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.countBars = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then
        fu.blocks = {
            ["目标生命值"] = 21,
            ["敌人人数"] = 22,
            ["姿态"] = 23,
            auras = {

            },
        }
        fu.spellCooldown[78675] = { index = 36, name = "日光术" }
    elseif specIndex == 2 then
        fu.blocks = {
            ["目标生命值"] = 21,
            ["敌人人数"] = 22,
            ["姿态"] = 23,
            auras = {

            },
        }
    elseif specIndex == 3 then
        fu.powerType = "RAGE"
        fu.blocks = {
            ["目标生命值"] = 21,
            ["敌人人数"] = 22,
            ["姿态"] = 23,
            auras = {
                ["塞纳留斯的梦境"] = {
                    index = 24,
                    auraRef = fu.Auras["塞纳留斯的梦境"],
                    showKey = "remaining",
                },
                ["塞纳留斯的梦境层数"] = {
                    index = 25,
                    auraRef = fu.Auras["塞纳留斯的梦境"],
                    showKey = "count",
                },
                ["铁鬃"] = {
                    index = 26,
                    auraRef = fu.Auras["铁鬃"],
                    showKey = "remaining",
                },
                ["狂暴回复"] = {
                    index = 27,
                    auraRef = fu.Auras["狂暴回复"],
                    showKey = "remaining",
                },
            },
        }
        fu.spellCooldown[22842] = { index = 36, name = "狂暴回复", charge = 37 }
        fu.spellCooldown[61336] = { index = 38, name = "生存本能" }
        fu.spellCooldown[102558] = { index = 39, name = "化身：乌索克的守护者" }
        fu.spellCooldown[1261867] = { index = 40, name = "野性之心" }
    elseif specIndex == 4 then
        fu.powerType = "MANA"
        fu.blocks = {
            ["姿态"] = 21,
            ["目标距离"] = 22,
            ["连击点"] = 23,
            ["施法技能"] = 24,
            auras = {
                ["节能施法"] = {
                    index = 29,
                    auraRef = fu.Auras["节能施法"],
                    showKey = "remaining",
                },
                ["丛林之魂"] = {
                    index = 30,
                    auraRef = fu.Auras["丛林之魂"],
                    showKey = "remaining",
                },
            },

        }

        fu.spellCooldown[18562] = { index = 36, name = "迅捷治愈", charge = 37 }
        fu.spellCooldown[48438] = { index = 38, name = "野性成长" }
        fu.spellCooldown[391528] = { index = 39, name = "万灵之召" }
        fu.spellCooldown[88423] = { index = 40, name = "自然之愈" }
        fu.spellCooldown[102342] = { index = 41, name = "铁木树皮" }
        fu.spellCooldown[132158] = { index = 42, name = "自然迅捷" }
        fu.spellCooldown[1261867] = { index = 43, name = "野性之心" }

        fu.group_blocks = {
            unit_start = 45,
            block_num = 7,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = {
                [4] = { 33763 },                    -- 生命绽放
                [5] = { 48438, 8936, 774, 155777 }, -- 迅捷治愈(回春术, 萌芽, 愈合, 野性生长)
                [6] = { 8936 },                     -- 愈合
            },
            rejuv = 7,                              -- 回春术数量
        }
    end
end

-- 创建德鲁伊宏
function fu.CreateClassMacro()
    local dynamicSpells = { "回春术", "愈合", "生命绽放", "迅捷治愈", "自然之愈" }
    local specialSpells = { [17] = "/cancelaura [spec:4]猎豹形态\n/cast 万灵之召", }
    local staticSpells = {
        [1]  = "[nostance:2]猎豹形态(变形)",
        [2]  = "[nostance:1]熊形态(变形)",
        [3]  = "[nostance:4]枭兽形态",
        [4]  = "月火术",
        [5]  = "树皮术",
        [6]  = "横扫",
        [7]  = "潜行",
        [8]  = "凶猛撕咬",
        [9]  = "愤怒",
        [10] = "割裂",
        [11] = "撕碎",
        [12] = "斜掠",
        [13] = "痛击",
        [14] = "野性印记",
        [15] = "裂伤",
        [16] = "野性成长",
        [18] = "自然迅捷",
        [19] = "[@player]激活",
        [20] = "野性之心",
        [21] = "野性冲锋",
        [22] = "铁鬃",
        [23] = "摧折",
        [24] = "明月普照",
        [25] = "狂暴回复",
        [26] = "台风",
        [27] = "夺魂咆哮",
        [28] = "[@cursor]乌索尔旋风",
        [29] = "日光术",
        [30] = "星涌术",
        [31] = "星火术",
        [32] = "星辰坠落",
        [33] = "自然之力",
        [34] = "日蚀",
        [35] = "超凡之盟",
        [36] = "化身：艾露恩之眷",
        [37] = "艾露恩之怒",
        [38] = "野性蘑菇",
        [39] = "新月",
        [40] = "阳炎术",
        [41] = "月蚀",
        [42] = "化身：阿莎曼之灵",
        [43] = "原始之怒",
        [44] = "迎头痛击",
        [45] = "怒意狂乱",
        [46] = "猛虎之怒",
        [47] = "生存本能",
        [48] = "野性冲锋",
        [49] = "群体缠绕",
        [50] = "狂暴",
        [51] = "啃噬",
        [52] = "野性狂乱",
    }
    fu.CreateMacro(dynamicSpells, staticSpells, specialSpells)
end
