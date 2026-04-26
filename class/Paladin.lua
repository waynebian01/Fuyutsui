local _, fu = ...
if fu.classId ~= 2 then return end
fu.heroSpell = {
    [432359] = 1, -- 铸光者
    [431377] = 2, -- 烈日先驱
}

fu.spellCooldown = {
    [115750] = { index = 31, name = "盲目之光" },
    [853] = { index = 32, name = "制裁之锤" },
    [642] = { index = 33, name = "圣盾术" },
    [6940] = { index = 34, name = "牺牲祝福" },
    [1044] = { index = 35, name = "自由祝福" },
    [1022] = { index = 36, name = "保护祝福" },
    [633] = { index = 37, name = "圣疗术" }
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
            ["神圣能量"] = 21,
            ["施法技能"] = 22,
            ["施法目标"] = 23,
            ["目标距离"] = 24,
            auras = {
                ["神圣意志"] = {
                    index = 25,
                    auraRef = fu.auras["神圣意志"],
                    showKey = "remaining",
                },
                ["圣光灌注"] = {
                    index = 26,
                    auraRef = fu.auras["圣光灌注"],
                    showKey = "remaining",
                },
                ["灌注层数"] = {
                    index = 27,
                    auraRef = fu.auras["灌注层数"],
                    showKey = "count",
                },
                ["神性层数"] = {
                    index = 28,
                    auraRef = fu.auras["神性之手"],
                    showKey = "count",
                },
            },
        }

        fu.spellCooldown[20473] = { index = 38, name = "神圣震击", charge = 39 }
        fu.spellCooldown[4987] = { index = 40, name = "清洁术" }
        fu.spellCooldown[275773] = { index = 41, name = "审判" }
        fu.spellCooldown[375576] = { index = 42, name = "圣洁鸣钟" }
        fu.spellCooldown[114165] = { index = 43, name = "神圣棱镜" }
        fu.spellCooldown[31821] = { index = 44, name = "光环掌握" }
        fu.spellCooldown[200025] = { index = 45, name = "美德道标" }

        fu.group_blocks = {
            unit_start = 70,
            block_num = 6,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = {
                [4] = { 156322 },        -- 永恒之火, 156322
                [5] = { 1244893 },       -- 救世道标, 1244893
                [6] = { 53563, 156910 }, -- 圣光道标, 信仰道标, 53563, 156910
            },
        }
    elseif specIndex == 2 then
        fu.HarmfulSpellId = 275779
        fu.powerType = "MANA"
        fu.blocks = {
            ["神圣能量"] = 21,
            auras = {
                ["神圣意志"] = {
                    index = 22,
                    auraRef = fu.auras["神圣意志"],
                    showKey = "remaining",
                },
                ["神圣壁垒"] = {
                    index = 23,
                    auraRef = fu.auras["神圣壁垒"],
                    showKey = "remaining",
                },
                ["圣洁武器"] = {
                    index = 24,
                    auraRef = fu.auras["圣洁武器"],
                    showKey = "remaining",
                },
                ["闪耀之光"] = {
                    index = 25,
                    auraRef = fu.auras["闪耀之光"],
                    showKey = "remaining",
                },
                ["闪光层数"] = {
                    index = 26,
                    auraRef = fu.auras["闪耀之光"],
                    showKey = "count",
                },
                ["神圣军备"] = {
                    index = 27,
                    auraRef = fu.updateAuras.byIcon[432459],
                    showKey = "isIcon",
                },
                ["奉献"] = {
                    index = 28,
                    auraRef = fu.auras["奉献"],
                    showKey = "remaining",
                },
                ["复仇之怒"] = {
                    index = 29,
                    auraRef = fu.auras["复仇之怒"],
                    showKey = "remaining",
                },
                ["圣光之锤"] = {
                    index = 30,
                    auraRef = fu.auras["圣光之锤"],
                    showKey = "remaining",
                },
            },
        }

        fu.spellCooldown[432459] = { index = 38, name = "神圣壁垒", charge = 39 }
        fu.spellCooldown[213644] = { index = 40, name = "清毒术" }
        fu.spellCooldown[275779] = { index = 41, name = "审判" }
        fu.spellCooldown[375576] = { index = 42, name = "圣洁鸣钟" }
        fu.spellCooldown[31935] = { index = 43, name = "复仇者之盾" }
        fu.spellCooldown[26573] = { index = 44, name = "奉献" }
        fu.spellCooldown[53600] = { index = 45, name = "正义盾击" }
        fu.spellCooldown[204019] = { index = 46, name = "祝福之锤" }

        fu.group_blocks = {
            unit_start = 70,
            block_num = 3,
            healthPercent = 1,
            role = 2,
            dispel = 3,
        }
    elseif specIndex == 3 then
        fu.HarmfulSpellId = 20271
        fu.powerType = "MANA"
        fu.auras["复仇之怒"].duration = 24
        fu.blocks = {
            ["神圣能量"] = 21,
            ["爆发开关"] = 26,
            ["AOE开关"] = 27,
            ["输出模式"] = 28,
            ["敌人人数"] = 29,
            auras = {
                ["神圣意志"] = {
                    index = 22,
                    auraRef = fu.auras["神圣意志"],
                    showKey = "remaining",
                },
                ["复仇之怒"] = {
                    index = 23,
                    auraRef = fu.auras["复仇之怒"],
                    showKey = "remaining",
                },
                ["处决宣判"] = {
                    index = 24,
                    auraRef = fu.auras["处决宣判"],
                    showKey = "remaining",
                },
                -- 427441
                ["圣光之锤"] = {
                    index = 25,
                    auraRef = fu.auras["圣光之锤"],
                    showKey = "remaining",
                },
            },
        }
        fu.spellCooldown[213644] = { index = 38, name = "清毒术" }
        fu.spellCooldown[20271] = { index = 39, name = "审判", charge = 40 }
        fu.spellCooldown[375576] = { index = 41, name = "圣洁鸣钟" }
        fu.spellCooldown[184575] = { index = 42, name = "公正之剑" }
        fu.spellCooldown[343527] = { index = 43, name = "处决宣判" }
        fu.spellCooldown[255937] = { index = 44, name = "灰烬觉醒" }

        fu.group_blocks = {
            unit_start = 70,
            block_num = 3,
            healthPercent = 1,
            role = 2,
            dispel = 3,
        }
    end
end

-- 创建圣骑士宏
function fu.CreateClassMacro()
    local dynamicSpells = { "神圣震击", "圣光闪现", "圣光术", "荣耀圣令", "清毒术", "圣疗术" }
    local specialSpells = {}
    local staticSpells = {
        [1] = "牺牲祝福",
        [2] = "代祷",
        [3] = "圣盾术",
        [4] = "盲目之光",
        [5] = "[@mouseover]保护祝福",
        [6] = "审判",
        [7] = "制裁之锤",
        [8] = "光环掌握",
        [9] = "圣洁鸣钟",
        [10] = "正义盾击",
        [11] = "黎明之光",
        [12] = "[@mouseover]自由祝福",
        [13] = "神圣棱镜",
        [14] = "神圣震击",
        [15] = "公正之剑",
        [16] = "",
        [17] = "处决宣判",
        [18] = "最终审判",
        [19] = "复仇之怒",
        [20] = "[spec:2]圣洁鸣钟;[spec:3]灰烬觉醒",
        [21] = "复仇者之盾",
        [22] = "责难",
        [23] = "远古列王守卫",
        [24] = "祝福之锤",
        [25] = "炽热防御者",
        [26] = "[@mouseover]破咒祝福",
        [27] = "神圣风暴",
        [28] = "奉献",
        [29] = "神圣壁垒",
        [30] = "[@player]荣耀圣令",
    }
    fu.CreateMacro(dynamicSpells, staticSpells, specialSpells)
end
