local _, fu = ...
if fu.classId ~= 9 then return end

fu.heroSpell = {
    [445486] = 1, -- 地狱召唤者
    [449614] = 2, -- 灵魂收割者
    [428514] = 3, -- 恶魔使徒
}

fu.spellCooldown = {
    [5782]    = { index = 31, name = "恐惧" },
    [6789]    = { index = 32, name = "死亡缠绕" },
    [20707]   = { index = 33, name = "灵魂石" },
    [30283]   = { index = 34, name = "暗影之怒" },
    [333889]  = { index = 35, name = "邪能统御" },
    [108416]  = { index = 36, name = "黑暗契约" },
    [111771]  = { index = 37, name = "恶魔传送门" },
    [1271748] = { index = 38, name = "虚弱灾厄" },
    [1271802] = { index = 39, name = "语言灾厄" },
    [48018]   = { index = 40, name = "恶魔法阵" },
    [48020]   = { index = 41, name = "恶魔法阵：传送" },
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
            ["灵魂碎片"] = 23,
            ["施法技能"] = 24,
            auras = {

            },
        }
        fu.spellCooldown[205180] = { index = 42, name = "召唤黑眼" }
        fu.spellCooldown[48181] = { index = 43, name = "鬼影缠身" }
        fu.spellCooldown[1257052] = { index = 44, name = "幽冥收割" }
        fu.spellCooldown[442726] = { index = 45, name = "怨毒" }
    elseif specIndex == 2 then
        fu.powerType = "MANA"
        local eventTable = { "SPELL_UPDATE_USES", "PLAYER_ENTERING_WORLD" }
        fu.countBars = {
            [1] = { name = "内爆", minValue = 0, maxValue = 20, spellId = 196277, events = eventTable },
        }
        fu.blocks = {
            ["灵魂碎片"] = 23,
            ["施法技能"] = 24,
            auras = {
                ["魔典：邪能破坏者"] = {
                    index = 25,
                    auraRef = fu.updateAuras.byIcon[1276467],
                    showKey = "isIcon",
                },
            },
        }
        fu.spellCooldown[196277] = { index = 42, name = "内爆" }
        fu.spellCooldown[265187] = { index = 43, name = "召唤恶魔暴君" }
        fu.spellCooldown[1276467] = { index = 44, name = "魔典：邪能破坏者" }
        fu.spellCooldown[105174] = { index = 45, name = "古尔丹之手" }
        fu.spellCooldown[1276672] = { index = 46, name = "召唤末日守卫" }
        fu.spellCooldown[104316] = { index = 47, name = "召唤恐惧猎犬" }
        fu.spellCooldown[264187] = { index = 48, name = "恶魔之箭" }
        fu.spellCooldown[1276452] = { index = 49, name = "魔典：小鬼领主" }
        fu.spellCooldown[388215] = { index = 50, name = "吞噬魔法" }
        fu.spellCooldown[30146] = { index = 51, name = "召唤恶魔卫士" }
    elseif specIndex == 3 then
        fu.blocks = {
            ["灵魂碎片"] = 23,
            ["施法技能"] = 24,
            auras = {

            },
        }
        fu.spellCooldown[1122] = { index = 42, name = "召唤地狱火" }
        fu.spellCooldown[6353] = { index = 43, name = "灵魂之火" }
        fu.spellCooldown[17962] = { index = 44, name = "燃烧", charge = 45 }
    end
end

local staticSpells = {
    [1] = "恐惧",
    [2] = "死亡缠绕",
    [3] = "[@cursor]暗影之怒",
    [4] = "内爆",
    [5] = "召唤恶魔暴君",
    [6] = "魔典：邪能破坏者",
    [7] = "召唤末日守卫",
    [8] = "古尔丹之手",
    [9] = "召唤恐惧猎犬",
    [10] = "召唤恶魔卫士",
    [11] = "恶魔之箭",
    [12] = "暗影箭",
    [13] = "召唤地狱猎犬",
    [14] = "召唤小鬼",
    [15] = "虚弱灾厄",
    [16] = "语言灾厄",
    [17] = "陨灭",
    [18] = "狱火箭",
    [19] = "灵魂石",
    [20] = "邪能统御",
    [21] = "黑暗契约",
    [22] = "恶魔之箭",
    [23] = "魔典：小鬼领主",
    [24] = "法术封锁",
    [25] = "吞噬魔法",
    [26] = "爆燃冲刺",
    [27] = "放逐术",
    [28] = "疲劳诅咒",
    [29] = "语言诅咒",
    [30] = "恶魔传送门",
    [31] = "灵魂燃烧",
    [32] = "恐惧嚎叫",
    [33] = "恶魔法阵",
    [34] = "恶魔法阵：传送",
    [35] = "制造灵魂之井",
    [36] = "召唤仪式",
    [37] = "腐蚀术",
    [38] = "吸取生命",
    [39] = "召唤黑眼",
    [40] = "痛苦无常",
    [41] = "幽冥收割",
    [42] = "腐蚀之种",
    [43] = "痛楚",
    [44] = "鬼影缠身",
    [45] = "枯萎",
    [46] = "怨毒",
    [47] = "召唤地狱火",
    [48] = "暗影灼烧",
    [49] = "混乱之箭",
    [50] = "火焰之雨",
    [51] = "灵魂之火",
    [52] = "烧尽",
    [53] = "燃烧",
    [54] = "献祭",
    [55] = "引导恶魔之火",
    [56] = "浩劫",
    [57] = "火焰之雨",
    [58] = "大灾变",
    [59] = "吸取灵魂",
    [60] = "召唤虚空行者",
    [61] = "召唤萨亚德",
}

function fu.CreateClassMacro()
    fu.CreateMacro({}, staticSpells)
end
