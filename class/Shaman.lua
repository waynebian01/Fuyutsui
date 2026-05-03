local _, fu = ...
if fu.classId ~= 7 then return end

fu.heroSpell = {
    [443450] = 1, -- 先知
    [454009] = 2, -- 风暴使者
    [444995] = 3, -- 图腾祭祀
}

fu.spellCooldown = {
    [57994] = { index = 31, name = "风剪" },
    [198103] = { index = 32, name = "土元素" },
    [192058] = { index = 33, name = "电能图腾" },
    [378081] = { index = 34, name = "自然迅捷" },
    [108287] = { index = 35, name = "图腾投射" },
    [51514] = { index = 36, name = "妖术" },
    [378773] = { index = 37, name = "强化净化术" },
    [8143] = { index = 38, name = "战栗图腾" },
    [383013] = { index = 39, name = "清毒图腾" },
    [192063] = { index = 40, name = "阵风" },
    [58875] = { index = 41, name = "幽魂步" },
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.countBars = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then
        fu.powerType = "MANA"
        fu.blocks = {
            ["目标生命值"] = 21,
            ["敌人人数"] = 22,
            auras = {

            },
        }
        fu.spellCooldown[462620] = { index = 42, name = "地震术" }
        fu.spellCooldown[8042] = { index = 43, name = "大地震击" }
        fu.spellCooldown[470057] = { index = 44, name = "流电炽焰" }
        fu.spellCooldown[318038] = { index = 45, name = "火舌武器" }
        fu.spellCooldown[51505] = { index = 46, name = "熔岩爆裂" }
        fu.spellCooldown[191634] = { index = 47, name = "风暴守护者" }
        fu.spellCooldown[452201] = { index = 48, name = "狂风怒号" }
        fu.spellCooldown[114050] = { index = 49, name = "升腾" }
        fu.spellCooldown[51886] = { index = 50, name = "净化灵魂" }
        fu.spellCooldown[443454] = { index = 51, name = "先祖迅捷" }
        fu.spellCooldown[117014] = { index = 52, name = "元素冲击" }
    elseif specIndex == 2 then
        fu.powerType = "MANA"
        fu.blocks = {
            ["目标生命值"] = 21,
            ["敌人人数"] = 22,
            auras = {

            },
        }

        fu.spellCooldown[444995] = { index = 42, name = "涌动图腾" }
        fu.spellCooldown[318038] = { index = 43, name = "火舌武器" }
        fu.spellCooldown[60103] = { index = 44, name = "熔岩猛击" }
        fu.spellCooldown[197214] = { index = 45, name = "裂地术" }
        fu.spellCooldown[1218090] = { index = 46, name = "始源风暴" }
        fu.spellCooldown[33757] = { index = 47, name = "风怒武器" }
        fu.spellCooldown[17364] = { index = 48, name = "风暴打击", charge = 49 }
        fu.spellCooldown[452201] = { index = 50, name = "狂风怒号" }
        fu.spellCooldown[115356] = { index = 51, name = "风切" }
        fu.spellCooldown[114051] = { index = 52, name = "升腾" }
        fu.spellCooldown[187874] = { index = 53, name = "毁灭闪电" }
        fu.spellCooldown[470057] = { index = 54, name = "流电炽焰" }
    elseif specIndex == 3 then
        fu.powerType = "MANA"
        fu.blocks = {
            ["施法技能"] = 22,
            ["施法目标"] = 23,
            auras = {
                ["飞旋之土"] = {
                    index = 24,
                    auraRef = fu.Auras["飞旋之土"],
                    showKey = "remaining",
                },
                ["潮汐奔涌"] = {
                    index = 25,
                    auraRef = fu.Auras["潮汐奔涌"],
                    showKey = "count",
                },
                ["风暴涌流图腾"] = {
                    index = 26,
                    auraRef = fu.Auras["风暴涌流图腾"],
                    showKey = "count",
                },
                ["风暴涌流图腾层数"] = {
                    index = 27,
                    auraRef = fu.Auras["风暴涌流图腾"],
                    showKey = "count",
                },
                ["生命释放"] = {
                    index = 28,
                    auraRef = fu.Auras["生命释放"],
                    showKey = "remaining",
                },
                ["升腾"] = {
                    index = 29,
                    auraRef = fu.Auras["升腾"],
                    showKey = "remaining",
                },
            },
        }
        fu.spellCooldown[51505] = { index = 42, name = "熔岩爆裂", charge = 43 }
        fu.spellCooldown[61295] = { index = 44, name = "激流", charge = 45 }
        fu.spellCooldown[5394] = { index = 46, name = "治疗之泉图腾", charge = 47 }
        fu.spellCooldown[470411] = { index = 48, name = "烈焰震击" }
        fu.spellCooldown[77130] = { index = 49, name = "净化灵魂" }
        fu.spellCooldown[73685] = { index = 50, name = "生命释放" }
        fu.spellCooldown[443454] = { index = 51, name = "先祖迅捷" }
        fu.spellCooldown[444995] = { index = 52, name = "涌动图腾" }
        fu.spellCooldown[98008] = { index = 53, name = "灵魂链接图腾" }
        fu.spellCooldown[114052] = { index = 54, name = "升腾" }
        fu.spellCooldown[108280] = { index = 55, name = "治疗之潮图腾" }

        fu.group_blocks = {
            unit_start = 70,
            block_num = 6,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = {
                [4] = { 61295 },       -- 激流
                [5] = { 974, 383648 }, -- 大地之盾
                [6] = { 382024 },      -- 大地生命武器
            },
        }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = { "治疗波", "治疗链", "激流", "大地之盾", "净化灵魂", "生命释放" }
    local staticSpells = {
        [1] = "唤潮者的护卫",
        [2] = "大地生命武器",
        [3] = "天怒",
        [4] = "水之护盾",
        [5] = "烈焰震击",
        [6] = "熔岩爆裂",
        [7] = "闪电箭",
        [8] = "闪电链",
        [9] = "治疗之泉图腾",
        [10] = "风剪",
        [11] = "先祖迅捷",
        [12] = "自然迅捷",
        [13] = "[@cursor]涌动图腾",
        [14] = "[@cursor]电能图腾",
        [15] = "阵风",
        [16] = "[@cursor]灵魂链接图腾",
        [17] = "土元素",
        [18] = "战栗图腾",
        [19] = "清毒图腾",
        [20] = "图腾投射",
        [21] = "升腾",
        [22] = "治疗之潮图腾",
        [23] = "毁灭闪电",
        [24] = "流电炽焰",
        [25] = "火舌武器",
        [26] = "熔岩猛击",
        [27] = "裂地术",
        [28] = "始源风暴",
        [29] = "风切",
        [30] = "风怒武器",
        [31] = "风暴打击",
        [32] = "狂风怒号",
        [33] = "元素冲击",
        [34] = "地震术",
        [35] = "大地震击",
        [36] = "风暴守护者",
        [37] = "闪电之盾",
    }

    fu.CreateMacro(dynamicSpells, staticSpells)
end
