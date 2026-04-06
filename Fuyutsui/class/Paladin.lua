local _, fu = ...
if fu.classId ~= 2 then return end

fu.HelpfulSpellId = 19750
fu.HarmfulSpellId = 275773

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then
        fu.powerType = "MANA"
        fu.blocks = {
            holyPower = 11,
            target_valid = 12,
            group_type = 13,
            members_count = 14,
            encounterID = 15,
            difficultyID = 16,
            failedSpell = 17,
            auras = {
                ["神圣意志"] = {
                    index = 18,
                    auraRef = fu.auras["神圣意志"],
                    showKey = "remaining",
                },
                ["圣光灌注"] = {
                    index = 19,
                    auraRef = fu.auras["圣光灌注"],
                    showKey = "remaining",
                },
                ["神性之手"] = {
                    index = 20,
                    auraRef = fu.auras["神性之手"],
                    showKey = "remaining",
                },
            },
            spell_cd = {
                [20473] = { index = 21, spellId = 20473, name = "神圣震击" },
                [4987] = { index = 22, spellId = 4987, name = "清洁术" },
                [115750] = { index = 23, spellId = 115750, name = "盲目之光" },
                [275773] = { index = 24, spellId = 275773, name = "审判" },
                [375576] = { index = 25, spellId = 375576, name = "圣洁鸣钟" },
                [114165] = { index = 26, spellId = 114165, name = "神圣棱镜" },
                [31821] = { index = 27, spellId = 31821, name = "光环掌握" },
                [6940] = { index = 28, spellId = 6940, name = "牺牲祝福" },
                [1044] = { index = 29, spellId = 1044, name = "自由祝福" },
                [853] = { index = 30, spellId = 853, name = "制裁之锤" },
                [1022] = { index = 31, spellId = 1022, name = "保护祝福" },
                [633] = { index = 32, spellId = 633, name = "圣疗术" },
            },
            spell_charge = {
                [20473] = { index = 32, spellId = 20473, name = "神圣震击" },
            },
        }
        fu.group_blocks = {
            unit_start = 40,
            block_num = 6,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = {
                [4] = { 156322 },        -- 永恒之火
                [5] = { 1244893 },       -- 救世道标
                [6] = { 53563, 156910 }, -- 圣光道标, 信仰道标
            },
        }
    elseif specIndex == 2 then
        fu.HarmfulSpellId = 275779
        fu.powerType = "MANA"
        fu.blocks = {
            holyPower = 11,
            target_valid = 12,
            assistant = 13,
            failedSpell = 14,
            auras = {
                ["神圣军备"] = {
                    index = 40,
                    auraRef = fu.updateAuras.byIcon[432459],
                    showKey = "isIcon",
                },
                ["神圣意志"] = {
                    index = 16,
                    auraRef = fu.auras["神圣意志"],
                    showKey = "remaining",
                },
                ["神圣壁垒"] = {
                    index = 17,
                    auraRef = fu.auras["神圣壁垒"],
                    showKey = "remaining",
                },
                ["圣洁武器"] = {
                    index = 18,
                    auraRef = fu.auras["圣洁武器"],
                    showKey = "remaining",
                },
                ["闪耀之光"] = {
                    index = 19,
                    auraRef = fu.auras["闪耀之光"],
                    showKey = "remaining",
                },
            },
            spell_cd = {
                [213644] = { index = 21, spellId = 213644, name = "清毒术" },
                [115750] = { index = 22, spellId = 115750, name = "盲目之光" },
                [275779] = { index = 23, spellId = 275779, name = "审判" },
                [375576] = { index = 24, spellId = 375576, name = "圣洁鸣钟" },
                [6940] = { index = 25, spellId = 6940, name = "牺牲祝福" },
                [1044] = { index = 26, spellId = 1044, name = "自由祝福" },
                [853] = { index = 27, spellId = 853, name = "制裁之锤" },
                [1022] = { index = 28, spellId = 1022, name = "保护祝福" },
                [432459] = { index = 29, spellId = 432459, name = "神圣壁垒" },
                [31935] = { index = 31, spellId = 31935, name = "复仇者之盾" },
                [26573] = { index = 32, spellId = 26573, name = "奉献" },
                [53600] = { index = 33, spellId = 53600, name = "正义盾击" },
                [204019] = { index = 34, spellId = 204019, name = "祝福之锤" },
            },
            spell_charge = {
                [432459] = { index = 30, spellId = 432459, name = "神圣壁垒" },
            },
        }
    elseif specIndex == 3 then
        fu.HarmfulSpellId = 20271
        fu.powerType = "MANA"
        fu.blocks = {
            holyPower = 11,
            target_valid = 12,
            assistant = 13,
            failedSpell = 14,
            auras = {
                ["神圣意志"] = {
                    index = 16,
                    auraRef = fu.auras["神圣意志"],
                    showKey = "remaining",
                },
            },
            spell_cd = {
                [213644] = { index = 31, spellId = 213644, name = "清毒术" },
                [115750] = { index = 32, spellId = 115750, name = "盲目之光" },
                [20271] = { index = 33, spellId = 20271, name = "审判" },
                [375576] = { index = 34, spellId = 375576, name = "圣洁鸣钟" },
                [6940] = { index = 35, spellId = 6940, name = "牺牲祝福" },
                [1044] = { index = 36, spellId = 1044, name = "自由祝福" },
                [853] = { index = 37, spellId = 853, name = "制裁之锤" },
                [1022] = { index = 38, spellId = 1022, name = "保护祝福" },
                [184575] = { index = 39, spellId = 184575, name = "公正之剑" },
                [343527] = { index = 40, spellId = 343527, name = "处决宣判" },
                [255937] = { index = 41, spellId = 255937, name = "灰烬觉醒" },
            },
            spell_charge = {
                [20271] = { index = 42, spellId = 20271, name = "审判充能" },
            },
        }
    end
end

-- 创建圣骑士宏
function fu.CreateClassMacro()
    local dynamicSpells = { "神圣震击", "圣光闪现", "圣光术", "荣耀圣令", "清洁术", "圣疗术" }
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
        [16] = "圣洁鸣钟",
        [17] = "处决宣判",
        [18] = "最终审判",
        [19] = "复仇之怒",
        [20] = "灰烬觉醒",
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
