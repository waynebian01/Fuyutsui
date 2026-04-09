local _, fu = ...
if fu.classId ~= 10 then return end

fu.HarmfulSpellId, fu.HelpfulSpellId = 100780, 116670

fu.heroSpell = {
    [450508] = 1, -- 祥和宗师
    [450615] = 2, -- 影踪派
    [443028] = 3, -- 天神御师
    [123904] = 3, -- 天神御师
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then
        fu.HarmfulSpellId = 121253
        fu.blocks = {
            ["酒池"] = 21,
            ["目标生命值"] = 22,
            ["敌人人数"] = 23,
            auras = {
                ["疗伤珠"] = {
                    index = 25,
                    auraRef = fu.auras["疗伤珠"],
                    showKey = "count",
                },
                ["活力苏醒"] = {
                    index = 26,
                    auraRef = fu.auras["活力苏醒"],
                    showKey = "remaining",
                },
                ["清空地窖"] = {
                    index = 27,
                    auraRef = fu.auras["清空地窖"],
                    showKey = "remaining",
                },
            },
            spell_cd = {
                [121253] = { index = 31, name = "醉酿投", charge = 32 },
                [119582] = { index = 33, name = "活血酒", charge = 34 },
                [322507] = { index = 35, name = "天神酒", charge = 36 },
                [1241059] = { index = 37, name = "天神灌注", charge = 38 },
                [322109] = { index = 39, name = "轮回之触" },
                [119381] = { index = 40, name = "扫堂腿" },
                [322101] = { index = 41, name = "移花接木" },
                [101643] = { index = 42, name = "魂体双分" },
                [119996] = { index = 43, name = "魂体双分：转移" },
                [116705] = { index = 44, name = "切喉手" },
                [115181] = { index = 45, name = "火焰之息" },
                [123986] = { index = 46, name = "真气爆裂" },
                [325153] = { index = 47, name = "爆炸酒桶" },
                [198898] = { index = 48, name = "赤精之歌" },
                [115399] = { index = 49, name = "玄牛酒" },
                [116844] = { index = 50, name = "平心之环" },
                [115078] = { index = 51, name = "分筋错骨" },
                [132578] = { index = 52, name = "玄牛下凡" },
            },
        }
    elseif specIndex == 2 then
        fu.HarmfulSpellId, fu.HelpfulSpellId = 100780, 115151
        fu.blocks = {
            ["敌人人数"] = 21,
            ["施法技能"] = 22,
            ["施法目标"] = 23,
            auras = {
                ["法力茶层数"] = {
                    index = 24,
                    auraRef = fu.auras["法力茶"],
                    showKey = "count",
                },
                ["生生不息1"] = {
                    index = 25,
                    auraRef = fu.auras["生生不息1"],
                    showKey = "remaining",
                },
                ["生生不息2"] = {
                    index = 26,
                    auraRef = fu.auras["生生不息2"],
                    showKey = "remaining",
                },
                ["神龙之赐层数"] = {
                    index = 27,
                    auraRef = fu.auras["神龙之赐"],
                    showKey = "count",
                },
                ["灵泉"] = {
                    index = 28,
                    auraRef = fu.auras["灵泉"],
                    showKey = "remaining",
                },
                ["玄牛之力"] = {
                    index = 29,
                    auraRef = fu.auras["玄牛之力"],
                    showKey = "remaining",
                },
                ["青龙之心"] = {
                    index = 30,
                    auraRef = fu.auras["青龙之心"],
                    showKey = "remaining",
                },
            },
            spell_cd = {
                [116680] = { index = 31, name = "雷光聚神茶", charge = 32 },
                [115151] = { index = 33, name = "复苏之雾", charge = 34 },
                [115310] = { index = 35, name = "还魂术" },
                [116849] = { index = 36, name = "作茧缚命" },
                [115450] = { index = 37, name = "清创生血" },
                [443028] = { index = 38, name = "天神御身" },
                [322109] = { index = 39, name = "轮回之触" },
                [119381] = { index = 40, name = "扫堂腿" },
                [1270621] = { index = 41, name = "宁神茶" },
                [101643] = { index = 42, name = "魂体双分" },
                [119996] = { index = 43, name = "魂体双分：转移" },
                [107428] = { index = 44, name = "旭日东升踢" },
                [100784] = { index = 45, name = "幻灭踢" },
                [116844] = { index = 46, name = "平心之环" },
                [115078] = { index = 47, name = "分筋错骨" },
            },
        }
        fu.group_blocks = {
            unit_start = 70,
            block_num = 5,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = {
                [4] = { 119611 }, -- 复苏之雾
                [5] = { 124682 }, -- 氤氲之雾
            },
        }
    elseif specIndex == 3 then
        fu.HarmfulSpellId = 392983
        fu.blocks = {
            ["目标生命值"] = 21,
            ["敌人人数"] = 22,
            auras = {

            },
            spell_cd = {
                [322109] = { index = 31, name = "轮回之触" },
                [119381] = { index = 32, name = "扫堂腿" },
                [322101] = { index = 33, name = "移花接木" },
                [101643] = { index = 34, name = "魂体双分" },
                [119996] = { index = 35, name = "魂体双分：转移" },
                [116705] = { index = 36, name = "切喉手" },
                [198898] = { index = 37, name = "赤精之歌" },
                [116844] = { index = 38, name = "平心之环" },
                [115078] = { index = 39, name = "分筋错骨" },
            },
        }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = { "氤氲之雾", "活血术", "清创生血", "抚慰之雾", "复苏之雾" }
    local staticSpells = {
        [1] = "扫堂腿",
        [2] = "神鹤引项踢",
        [3] = "壮胆酒",
        [4] = "[known:116844,@cursor]平心之环;[known:198898]赤精之歌",
        [5] = "猛虎掌",
        [6] = "轮回之触",
        [7] = "幻灭踢",
        [8] = "碎玉闪电",
        [9] = "切喉手",
        [10] = "天神灌注",
        [11] = "火焰之息",
        [12] = "活血酒",
        [13] = "[@player]爆炸酒桶",
        [14] = "玄牛下凡",
        [15] = "醉酿投",
        [16] = "真气爆裂",
        [17] = "天神酒",
        [18] = "移花接木",
        [19] = "魂体双分",
        [20] = "魂体双分：转移",
        [21] = "雷光聚神茶",
        [22] = "法力茶",
        [23] = "旭日东升踢",
        [24] = "天神御身",
        [25] = "分筋错骨",
        [26] = "风领主之击",
        [27] = "怒雷破",
        [28] = "升龙霸",
    }
    fu.CreateMacro(dynamicSpells, staticSpells, _)
end
