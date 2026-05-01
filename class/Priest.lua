local _, fu = ...
if fu.classId ~= 5 then return end

fu.HarmfulSpellId, fu.HelpfulSpellId = 585, 2061

fu.heroSpell = {
    [1248423] = 1, -- 神谕者
    [263165] = 2,  -- 虚空编织者
    [447444] = 2,  -- 虚空编织者
    [120517] = 3,  -- 执政官
    [102644] = 3,  -- 执政官
}

fu.spellCooldown = {
    [8122] = { index = 31, name = "心灵尖啸" },
    [32375] = { index = 32, name = "群体驱散" },
    [527] = { index = 33, name = "纯净术" },
    [19236] = { index = 34, name = "绝望祷言" },
    [232633] = { index = 35, name = "奥术洪流" },
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
            ["施法技能"] = 22,
            ["施法目标"] = 23,
            ["目标生命值"] = 46,
            auras = {
                ["虚空之盾"] = {
                    index = 24,
                    auraRef = fu.auras["虚空之盾"],
                    showKey = "remaining",
                },
                ["圣光涌动"] = {
                    index = 25,
                    auraRef = fu.auras["圣光涌动"],
                    showKey = "remaining",
                },
                ["涌动层数"] = {
                    index = 26,
                    auraRef = fu.auras["圣光涌动"],
                    showKey = "count",
                },
                ["熵能裂隙"] = {
                    index = 27,
                    auraRef = fu.auras["熵能裂隙"],
                    showKey = "remaining",
                },
                ["暗影愈合"] = {
                    index = 28,
                    auraRef = fu.auras["暗影愈合"],
                    showKey = "remaining",
                },
                ["暗影层数"] = {
                    index = 29,
                    auraRef = fu.auras["暗影愈合"],
                    showKey = "count",
                },
                ["福音层数"] = {
                    index = 30,
                    auraRef = fu.auras["福音"],
                    showKey = "count",
                },
            },
        }

        fu.spellCooldown[47540] = { index = 36, name = "苦修", charge = 37 }
        fu.spellCooldown[194509] = { index = 38, name = "真言术：耀", charge = 39 }
        fu.spellCooldown[17] = { index = 40, name = "真言术：盾" }
        fu.spellCooldown[62618] = { index = 41, name = "真言术：障" }
        fu.spellCooldown[421453] = { index = 42, name = "终极苦修" }
        fu.spellCooldown[472433] = { index = 43, name = "福音" }
        fu.spellCooldown[8092] = { index = 44, name = "心灵震爆" }
        fu.spellCooldown[32379] = { index = 45, name = "暗言术：灭" }

        fu.group_blocks = {
            unit_start = 70,
            block_num = 5,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = {
                [4] = { 194384 },      -- 救赎, 194384
                [5] = { 17, 1253593 }, -- 真言术：盾, 虚空护盾, 17, 1253593
            },
        }
    elseif specIndex == 2 then
        fu.powerType = "MANA"
        fu.blocks = {
            ["施法技能"] = 22,
            ["施法目标"] = 23,
            auras = {
                ["织光者"] = {
                    index = 25,
                    auraRef = fu.auras["织光者"],
                    showKey = "remaining",
                },
                ["织光者层数"] = {
                    index = 26,
                    auraRef = fu.auras["织光者"],
                    showKey = "count",
                },
                ["圣光涌动"] = {
                    index = 27,
                    auraRef = fu.auras["圣光涌动"],
                    showKey = "remaining",
                },
                ["祈福"] = {
                    index = 28,
                    auraRef = fu.auras["祈福"],
                    showKey = "remaining",
                },
            },
        }

        fu.spellCooldown[33076] = { index = 36, name = "愈合祷言", charge = 37 }
        fu.spellCooldown[2050] = { index = 38, name = "圣言术：静", charge = 39 }
        fu.spellCooldown[88625] = { index = 40, name = "圣言术：罚" }
        fu.spellCooldown[200183] = { index = 41, name = "神圣化身" }
        fu.spellCooldown[14914] = { index = 42, name = "神圣之火" }
        fu.spellCooldown[120517] = { index = 43, name = "光晕" }
        fu.spellCooldown[64843] = { index = 44, name = "神圣赞美诗" }

        fu.group_blocks = {
            unit_start = 70,
            block_num = 5,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = {
                [4] = { 41635 }, -- 愈合祷言, 41635
                [5] = { 139 },   -- 恢复, 139
            },
        }
    elseif specIndex == 3 then
        fu.powerType = "INSANITY"
        fu.blocks = {
            ["目标生命值"] = 46,
            auras = {
                ["虚空形态buff"] = {
                    index = 47,
                    auraRef = fu.auras["虚空形态"],
                    showKey = "remaining",
                    playerAuraSpellId = 194249,
                },
            },
        }
        fu.spellCooldown[8092] = { index = 36, name = "心灵震爆" }
        fu.spellCooldown[32379] = { index = 37, name = "暗言术：灭" }
        fu.spellCooldown[263165] = { index = 38, name = "虚空洪流" }
        fu.spellCooldown[228260] = { index = 39, name = "虚空形态" }
        fu.spellCooldown[1227280] = { index = 40, name = "触须猛击" }
        fu.spellCooldown[15286] = { index = 41, name = "吸血鬼的拥抱" }
        fu.spellCooldown[120644] = { index = 42, name = "光晕" }
        fu.spellCooldown[1242173] = { index = 43, name = "虚空齐射", forcedKnown = true }
        fu.spellCooldown[335467] = { index = 44, name = "暗言术：癫" }
        fu.spellCooldown[15407] = { index = 45, name = "精神鞭笞" }

        -- 虚空形态光环监控修复
        local vfAura = fu.auras["虚空形态"]
        if vfAura then
            vfAura.duration = 20  -- 设置基础时长
        end
        -- 注册触发事件 (bySpellCooldown: 按钮转圈时触发; bySuccess: 释放成功时触发)
        fu.updateAuras.bySpellCooldown[228260] = { { name = "虚空形态" } } -- 虚空爆发
        fu.updateAuras.bySpellCooldown[391109] = { { name = "虚空形态" } } -- 黑暗升华
        fu.updateAuras.bySuccess[228260] = { { name = "虚空形态" } }
        fu.updateAuras.bySuccess[391109] = { { name = "虚空形态" } }
    end

end

function fu.CreateClassMacro()
    local dynamicSpells = { "苦修", "快速治疗", "真言术：盾", "愈合祷言", "纯净术", "圣言术：静" }
    local staticSpells = {
        [1] = "心灵震爆",
        [2] = "惩击",
        [3] = "暗言术：痛",
        [4] = "真言术：韧",
        [5] = "神圣新星",
        [6] = "苦修",
        [7] = "真言术：耀",
        [8] = "福音",
        [9] = "终极苦修",
        [10] = "绝望祷言",
        [11] = "暗言术：灭",
        [12] = "吸血鬼之触",
        [13] = "[nostance:1]暗影形态",
        [14] = "暗言术：癫",
        [15] = "精神鞭笞",
        [16] = "虚空形态",
        [17] = "虚空洪流",
        [18] = "触须猛击",
        [19] = "虚空冲击",
        [20] = "虚空齐射",
        [21] = "圣言术：罚",
        [22] = "神圣之火",
        [23] = "治疗祷言",
        [24] = "神圣化身",
        [25] = "奥术洪流",
        [26] = "心灵尖啸",
        [27] = "[@cursor]群体驱散",
        [28] = "[@cursor]真言术：障",
        [29] = "神圣赞美诗",
        [30] = "光晕",
        [31] = "纯净术",
        [32] = "快速治疗",
        [33] = "真言术：盾",
        [34] = "愈合祷言",
        [35] = "圣言术：静",
    }

    fu.CreateMacro(dynamicSpells, staticSpells)
end
