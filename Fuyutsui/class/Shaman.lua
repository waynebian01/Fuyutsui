local _, fu = ...
if fu.classId ~= 7 then return end

fu.HelpfulSpellId = 77472
fu.HarmfulSpellId = 188196



fu.spellCooldown = {
    [462854] = { index = 31, name = "天怒" },
    [192106] = { index = 32, name = "闪电之盾"},
    [188196] = { index = 33, name = "闪电箭" },
    [188443] = { index = 34, name = "闪电链" },
    [1064] = { index = 35, name = "治疗链" },
    [974] = { index = 36, name = "大地之盾" },
    [57994] = { index = 37, name = "风剪" },
    [198103] = { index = 38, name = "土元素" },
    [192058] = { index = 39, name = "电能图腾" },

}


function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
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
        fu.spellCooldown[443454] = { index = 40, name = "先祖迅捷" }
        fu.spellCooldown[117014] = { index = 41, name = "元素冲击" }
        fu.spellCooldown[462620] = { index = 42, name = "地震术" }
        fu.spellCooldown[8042] = { index = 43, name = "大地震击" }
        fu.spellCooldown[470057] = { index = 44, name = "流电炽焰" }
        fu.spellCooldown[318038] = { index = 45, name = "火舌武器" }
        fu.spellCooldown[51505] = { index = 46, name = "熔岩爆裂" }
        fu.spellCooldown[191634] = { index = 47, name = "风暴守护者" }
        fu.spellCooldown[452201] = { index = 48, name = "狂风怒号" }
        fu.spellCooldown[114050] = { index = 49, name = "升腾" }

    end
    if specIndex == 2 then 
        fu.powerType = "MANA"
        fu.blocks = {
            ["目标生命值"] = 21,
            ["敌人人数"] = 22,
            auras = {

            },
        }
        fu.spellCooldown[187874] = { index = 40, name = "毁灭闪电" }
        fu.spellCooldown[470057] = { index = 41, name = "流电炽焰" }
        fu.spellCooldown[444995] = { index = 42, name = "涌动图腾" }
        fu.spellCooldown[318038] = { index = 43, name = "火舌武器" }
        fu.spellCooldown[60103] = { index = 44, name = "熔岩猛击" }
        fu.spellCooldown[197214] = { index = 45, name = "裂地术" }
        fu.spellCooldown[1218090] = { index = 46, name = "始源风暴" }
        fu.spellCooldown[33757] = { index = 47, name = "风怒武器" }
        fu.spellCooldown[17364] = { index = 48, name = "风暴打击" }
        fu.spellCooldown[452201] = { index = 49, name = "狂风怒号" }
        fu.spellCooldown[115356] = { index = 50, name = "风切" }
        fu.spellCooldown[114051] = { index = 51, name = "升腾" }

        
    end    
    if specIndex == 3 then
        fu.powerType = "MANA"
        fu.blocks = {
            ["施法技能"] = 22,
            ["施法目标"] = 23,
            auras = {
                ["飞旋之土"] = {
                    index = 24,
                    auraRef = fu.auras["飞旋之土"],
                    showKey = "remaining",
                },
                ["潮汐奔涌"] = {
                    index = 25,
                    auraRef = fu.auras["潮汐奔涌"],
                    showKey = "count",
                },
                ["风暴涌流图腾层数"] = {
                    index = 26,
                    auraRef = fu.auras["风暴涌流图腾层数"],
                    showKey = "count",
                },
                ["大地生命武器"] = {
                    index = 27,
                    auraRef = fu.auras["大地生命武器"],
                    showKey = "remaining",
                },
                ["生命释放"] = {
                    index = 28,
                    auraRef = fu.auras["生命释放"],
                    showKey = "remaining",
                },
            },
        }

        
            fu.spellCooldown[457481] = { index = 40, name = "唤潮者的护卫" }
            fu.spellCooldown[382021] = { index = 41, name = "大地生命武器" }
            fu.spellCooldown[52127] = { index = 42, name = "水之护盾" }
            fu.spellCooldown[470411] = { index = 43, name = "烈焰震击" }
            fu.spellCooldown[51505] = { index = 44, name = "熔岩爆裂" }
            fu.spellCooldown[77472] = { index = 45, name = "治疗波" }
            fu.spellCooldown[61295] = { index = 46, name = "激流", charge = 61 }
            fu.spellCooldown[77130] = { index = 47, name = "净化灵魂" }
            fu.spellCooldown[5394] = { index = 48, name = "治疗之泉图腾", charge = 62 }
            fu.spellCooldown[73685] = { index = 49, name = "生命释放" }
            fu.spellCooldown[443454] = { index = 50, name = "先祖迅捷" }
            fu.spellCooldown[378081] = { index = 51, name = "自然迅捷" }
            fu.spellCooldown[444995] = { index = 52, name = "涌动图腾" }
            fu.spellCooldown[192063] = { index = 53, name = "阵风" }
            fu.spellCooldown[98008] = { index = 54, name = "灵魂链接图腾" }
            fu.spellCooldown[8143] = { index = 56, name = "战栗图腾" }
            fu.spellCooldown[383013] = { index = 57, name = "清毒图腾" }
            fu.spellCooldown[108287] = { index = 58, name = "图腾投射" }
            fu.spellCooldown[114052] = { index = 59, name = "升腾" }
            fu.spellCooldown[108280] = { index = 60, name = "治疗之潮图腾" }
        




        fu.group_blocks = {
            unit_start = 70,
            block_num = 6,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = {
                [4] = { 61295 },
                [5] = { 974, 383648 },
                [6] = { 382024 }
            },
        }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = {
        "治疗波",
        "治疗链",
        "激流",
        "大地之盾",
        "净化灵魂",
        "生命释放",
    }
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
