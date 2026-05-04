local _, fu = ...
if fu.classId ~= 2 then return end

Fuyutsui.ClassBlocks = {
    [1] = {
        powerType = "MANA",

        [1] = { type = "block", name = "神圣能量" },
        [2] = { type = "block", name = "施法技能" },
        [3] = { type = "block", name = "施法目标" },
        [4] = { type = "block", name = "目标距离" },

        [5] = { type = "aura", name = "神圣意志", auraRef = fu.Auras["神圣意志"], showKey = "remaining" },
        [6] = { type = "aura", name = "圣光灌注", auraRef = fu.Auras["圣光灌注"], showKey = "remaining" },
        [7] = { type = "aura", name = "灌注层数", auraRef = fu.Auras["灌注层数"], showKey = "count" },
        [8] = { type = "aura", name = "神性层数", auraRef = fu.Auras["神性之手"], showKey = "count" },

        [11] = { type = "spell", spellId = 115750, name = "盲目之光" },
        [12] = { type = "spell", spellId = 853, name = "制裁之锤" },
        [13] = { type = "spell", spellId = 642, name = "圣盾术" },
        [14] = { type = "spell", spellId = 6940, name = "牺牲祝福" },
        [15] = { type = "spell", spellId = 1044, name = "自由祝福" },
        [16] = { type = "spell", spellId = 1022, name = "保护祝福" },
        [17] = { type = "spell", spellId = 633, name = "圣疗术" },
        [18] = { type = "spell", spellId = 20473, name = "神圣震击" },
        [19] = { type = "spell", spellId = 20473, name = "神圣震击", charge = true, },
        [20] = { type = "spell", spellId = 4987, name = "清洁术" },
        [21] = { type = "spell", spellId = 275773, name = "审判" },
        [22] = { type = "spell", spellId = 375576, name = "圣洁鸣钟" },
        [23] = { type = "spell", spellId = 114165, name = "神圣棱镜" },
        [24] = { type = "spell", spellId = 31821, name = "光环掌握" },
        [25] = { type = "spell", spellId = 200025, name = "美德道标" },
        [50] = {
            type = "group_blocks",
            block_num = 6,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = {
                [4] = { 156322 },        -- 永恒之火, 156322
                [5] = { 1244893 },       -- 救世道标, 1244893
                [6] = { 53563, 156910 }, -- 圣光道标, 信仰道标, 53563, 156910
            },
        },
    },
    [2] = {
        powerType = "MANA",
        [1] = { type = "block", name = "神圣能量" },

        [2] = { type = "block", aura = "神圣意志", auraRef = fu.Auras["神圣意志"], showKey = "remaining" },
        [3] = { type = "block", aura = "神圣壁垒", auraRef = fu.Auras["神圣壁垒"], showKey = "remaining" },
        [4] = { type = "block", aura = "圣洁武器", auraRef = fu.Auras["圣洁武器"], showKey = "remaining" },
        [5] = { type = "block", aura = "闪耀之光", auraRef = fu.Auras["闪耀之光"], showKey = "remaining" },
        [6] = { type = "block", aura = "闪光层数", auraRef = fu.Auras["闪耀之光"], showKey = "count" },
        [7] = { type = "block", aura = "神圣军备", auraRef = fu.Auras["神圣军备"], showKey = "isIcon" },
        [8] = { type = "block", aura = "奉献", auraRef = fu.Auras["奉献"], showKey = "remaining" },
        [9] = { type = "block", aura = "复仇之怒", auraRef = fu.Auras["复仇之怒"], showKey = "remaining" },
        [10] = { type = "block", aura = "圣光之锤", auraRef = fu.Auras["圣光之锤"], showKey = "remaining" },

        [11] = { type = "spell", spellId = 115750, name = "盲目之光" },
        [12] = { type = "spell", spellId = 853, name = "制裁之锤" },
        [13] = { type = "spell", spellId = 642, name = "圣盾术" },
        [14] = { type = "spell", spellId = 6940, name = "牺牲祝福" },
        [15] = { type = "spell", spellId = 1044, name = "自由祝福" },
        [16] = { type = "spell", spellId = 1022, name = "保护祝福" },
        [17] = { type = "spell", spellId = 633, name = "圣疗术" },
        [18] = { type = "spell", spellId = 432459, name = "神圣壁垒" },
        [19] = { type = "spell", spellId = 432459, name = "神圣壁垒", charge = true, },
        [20] = { type = "spell", spellId = 213644, name = "清毒术" },
        [21] = { type = "spell", spellId = 275779, name = "审判" },
        [22] = { type = "spell", spellId = 375576, name = "圣洁鸣钟" },
        [23] = { type = "spell", spellId = 31935, name = "复仇者之盾" },
        [24] = { type = "spell", spellId = 26573, name = "奉献" },
        [25] = { type = "spell", spellId = 53600, name = "正义盾击" },
        [26] = { type = "spell", spellId = 204019, name = "祝福之锤" },

        [50] = {
            type = "group_blocks",
            block_num = 3,
            healthPercent = 1,
            role = 2,
            dispel = 3,
        },
    },

    [3] = {
        powerType = "MANA",

        [1] = { type = "block", name = "神圣能量" },
        [2] = { type = "block", name = "爆发开关" },
        [3] = { type = "block", name = "AOE开关" },
        [4] = { type = "block", name = "输出模式" },
        [5] = { type = "aura", name = "神圣意志", auraRef = fu.Auras["神圣意志"], showKey = "remaining" },
        [6] = { type = "aura", name = "复仇之怒", auraRef = fu.Auras["复仇之怒"], showKey = "remaining" },
        [7] = { type = "aura", name = "处决宣判", auraRef = fu.Auras["处决宣判"], showKey = "remaining" },
        [8] = { type = "aura", name = "圣光之锤", auraRef = fu.Auras["圣光之锤"], showKey = "remaining" },

        [11] = { type = "spell", spellId = 115750, name = "盲目之光" },
        [12] = { type = "spell", spellId = 853, name = "制裁之锤" },
        [13] = { type = "spell", spellId = 642, name = "圣盾术" },
        [14] = { type = "spell", spellId = 6940, name = "牺牲祝福" },
        [15] = { type = "spell", spellId = 1044, name = "自由祝福" },
        [16] = { type = "spell", spellId = 1022, name = "保护祝福" },
        [17] = { type = "spell", spellId = 633, name = "圣疗术" },

        [18] = { type = "spell", spellId = 213644, name = "清毒术" },
        [19] = { type = "spell", spellId = 20271, name = "审判" },
        [20] = { type = "spell", spellId = 20271, name = "审判", charge = true, },
        [21] = { type = "spell", spellId = 375576, name = "圣洁鸣钟" },
        [22] = { type = "spell", spellId = 184575, name = "公正之剑" },
        [23] = { type = "spell", spellId = 343527, name = "处决宣判" },
        [24] = { type = "spell", spellId = 255937, name = "灰烬觉醒" },

        [50] = {
            type = "group_blocks",
            block_num = 3,
            healthPercent = 1,
            role = 2,
            dispel = 3,
        },

    },
}

local oldBlocks = {
    [1] = {
        powerType = "MANA",
        blocks = {
            ["神圣能量"] = 21,
            ["施法技能"] = 22,
            ["施法目标"] = 23,
            ["目标距离"] = 24,
        },
        auras = {
            ["神圣意志"] = {
                index = 25,
                auraRef = fu.Auras["神圣意志"],
                showKey = "remaining",
            },
            ["圣光灌注"] = {
                index = 26,
                auraRef = fu.Auras["圣光灌注"],
                showKey = "remaining",
            },
            ["灌注层数"] = {
                index = 27,
                auraRef = fu.Auras["灌注层数"],
                showKey = "count",
            },
            ["神性层数"] = {
                index = 28,
                auraRef = fu.Auras["神性之手"],
                showKey = "count",
            },
        },
        spellCooldown = {
            [115750] = { index = 31, name = "盲目之光" },
            [853] = { index = 32, name = "制裁之锤" },
            [642] = { index = 33, name = "圣盾术" },
            [6940] = { index = 34, name = "牺牲祝福" },
            [1044] = { index = 35, name = "自由祝福" },
            [1022] = { index = 36, name = "保护祝福" },
            [633] = { index = 37, name = "圣疗术" },
            [20473] = { index = 38, name = "神圣震击", charge = 39 },
            [4987] = { index = 40, name = "清洁术" },
            [275773] = { index = 41, name = "审判" },
            [375576] = { index = 42, name = "圣洁鸣钟" },
            [114165] = { index = 43, name = "神圣棱镜" },
            [31821] = { index = 44, name = "光环掌握" },
            [200025] = { index = 45, name = "美德道标" },
        },

        group_blocks = {
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
        },
    },
    [2] = {

        powerType = "MANA",
        blocks = {
            ["神圣能量"] = 21,
            auras = {
                ["神圣意志"] = {
                    index = 22,
                    auraRef = fu.Auras["神圣意志"],
                    showKey = "remaining",
                },
                ["神圣壁垒"] = {
                    index = 23,
                    auraRef = fu.Auras["神圣壁垒"],
                    showKey = "remaining",
                },
                ["圣洁武器"] = {
                    index = 24,
                    auraRef = fu.Auras["圣洁武器"],
                    showKey = "remaining",
                },
                ["闪耀之光"] = {
                    index = 25,
                    auraRef = fu.Auras["闪耀之光"],
                    showKey = "remaining",
                },
                ["闪光层数"] = {
                    index = 26,
                    auraRef = fu.Auras["闪耀之光"],
                    showKey = "count",
                },
                ["神圣军备"] = {
                    index = 27,
                    auraRef = fu.Auras["神圣军备"],
                    showKey = "isIcon",
                },
                ["奉献"] = {
                    index = 28,
                    auraRef = fu.Auras["奉献"],
                    showKey = "remaining",
                },
                ["复仇之怒"] = {
                    index = 29,
                    auraRef = fu.Auras["复仇之怒"],
                    showKey = "remaining",
                },
                ["圣光之锤"] = {
                    index = 30,
                    auraRef = fu.Auras["圣光之锤"],
                    showKey = "remaining",
                },
            },
        },

        spellCooldown = {
            [115750] = { index = 31, name = "盲目之光" },
            [853] = { index = 32, name = "制裁之锤" },
            [642] = { index = 33, name = "圣盾术" },
            [6940] = { index = 34, name = "牺牲祝福" },
            [1044] = { index = 35, name = "自由祝福" },
            [1022] = { index = 36, name = "保护祝福" },
            [633] = { index = 37, name = "圣疗术" },
            [432459] = { index = 38, name = "神圣壁垒", charge = 39 },
            [213644] = { index = 40, name = "清毒术" },
            [275779] = { index = 41, name = "审判" },
            [375576] = { index = 42, name = "圣洁鸣钟" },
            [31935] = { index = 43, name = "复仇者之盾" },
            [26573] = { index = 44, name = "奉献" },
            [53600] = { index = 45, name = "正义盾击" },
            [204019] = { index = 46, name = "祝福之锤" },
        },

        group_blocks = {
            unit_start = 70,
            block_num = 3,
            healthPercent = 1,
            role = 2,
            dispel = 3,
        },
    },

    [3] = {
        powerType = "MANA",
        blocks = {
            ["神圣能量"] = 21,
            ["爆发开关"] = 26,
            ["AOE开关"] = 27,
            ["输出模式"] = 28,
            auras = {
                ["神圣意志"] = {
                    index = 22,
                    auraRef = fu.Auras["神圣意志"],
                    showKey = "remaining",
                },
                ["复仇之怒"] = {
                    index = 23,
                    auraRef = fu.Auras["复仇之怒"],
                    showKey = "remaining",
                },
                ["处决宣判"] = {
                    index = 24,
                    auraRef = fu.Auras["处决宣判"],
                    showKey = "remaining",
                },
                ["圣光之锤"] = {
                    index = 25,
                    auraRef = fu.Auras["圣光之锤"],
                    showKey = "remaining",
                },
            },
        },
        spellCooldown = {
            [115750] = { index = 31, name = "盲目之光" },
            [853] = { index = 32, name = "制裁之锤" },
            [642] = { index = 33, name = "圣盾术" },
            [6940] = { index = 34, name = "牺牲祝福" },
            [1044] = { index = 35, name = "自由祝福" },
            [1022] = { index = 36, name = "保护祝福" },
            [633] = { index = 37, name = "圣疗术" },
            [213644] = { index = 38, name = "清毒术" },
            [20271] = { index = 39, name = "审判", charge = 40 },
            [375576] = { index = 41, name = "圣洁鸣钟" },
            [184575] = { index = 42, name = "公正之剑" },
            [343527] = { index = 43, name = "处决宣判" },
            [255937] = { index = 44, name = "灰烬觉醒" },
        },

        group_blocks = {
            unit_start = 70,
            block_num = 3,
            healthPercent = 1,
            role = 2,
            dispel = 3,
        },

    },
}
-- 创建圣骑士宏{
Fuyutsui.MacrosList = {
    dynamicSpells = { "神圣震击", "圣光闪现", "圣光术", "荣耀圣令", "清毒术", "圣疗术" },
    specialSpells = {},
    staticSpells = {
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
        [24] = "十字军打击",
        [25] = "炽热防御者",
        [26] = "[@mouseover]破咒祝福",
        [27] = "神圣风暴",
        [28] = "奉献",
        [29] = "神圣壁垒",
        [30] = "[@player]荣耀圣令",
        [31] = "圣光道标",
    },
}
