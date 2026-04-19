local _, fu = ...
if fu.classId ~= 7 then return end

fu.HelpfulSpellId = 77472
fu.HarmfulSpellId = 188196


function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    fu.spellCooldown = nil
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

        fu.spellCooldown = {
            [457481] = { index = 31, name = "唤潮者的护卫" },
            [382021] = { index = 32, name = "大地生命武器" },
            [462854] = { index = 33, name = "天怒" },
            [52127] = { index = 34, name = "水之护盾" },
            [470411] = { index = 35, name = "烈焰震击" },
            [51505] = { index = 36, name = "熔岩爆裂" },
            [188196] = { index = 37, name = "闪电箭" },
            [188443] = { index = 38, name = "闪电链" },
            [77472] = { index = 39, name = "治疗波" },
            [1064] = { index = 40, name = "治疗链" },
            [61295] = { index = 41, name = "激流", charge = 42 },
            [974] = { index = 43, name = "大地之盾" },
            [77130] = { index = 44, name = "净化灵魂" },
            [5394] = { index = 45, name = "治疗之泉图腾", charge = 46 },
            [73685] = { index = 47, name = "生命释放" },
            [57994] = { index = 48, name = "风剪" },
            [443454] = { index = 49, name = "先祖迅捷" },
            [378081] = { index = 50, name = "自然迅捷" },
            [73920] = { index = 51, name = "涌动图腾" },
            [192058] = { index = 52, name = "电能图腾" },
            [192063] = { index = 53, name = "阵风" },
            [98008] = { index = 54, name = "灵魂链接图腾" },
            [198103] = { index = 55, name = "土元素" },
            [8143] = { index = 56, name = "战栗图腾" },
            [383013] = { index = 57, name = "清毒图腾" },
            [108287] = { index = 58, name = "图腾投射" },
            [114052] = { index = 59, name = "升腾" },
            [108280] = { index = 60, name = "治疗之潮图腾" },
        }




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
    local dynamicSpells = { "治疗波", "治疗链", "激流", "大地之盾", "净化灵魂", "生命释放", }
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
    }

    fu.CreateMacro(dynamicSpells, staticSpells)
end
