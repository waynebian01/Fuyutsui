local _, fu = ...
if fu.classId ~= 1 then return end
fu.HarmfulSpellId = 355

fu.heroSpell = {
    [436358] = 1, -- 巨神兵
    [444767] = 2, -- 屠戮者
    [434969] = 3, -- 山丘领主
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    if specIndex == 1 then
        fu.blocks = {
            ["目标生命值"] = 21,
            ["敌人人数"] = 22,
            auras = {

            },
        }
        fu.spellCooldown = {
            [202168] = { index = 31, name = "胜利在望" },
            [376079] = { index = 32, name = "勇士之矛" },
            [6544] = { index = 33, name = "英勇飞跃" },
            [97462] = { index = 34, name = "集结呐喊" },
            [46968] = { index = 35, name = "震荡波" },
            [107570] = { index = 36, name = "风暴之锤" },
            [384110] = { index = 37, name = "破裂投掷" },
            [64382] = { index = 38, name = "碎裂投掷" },
            [5246] = { index = 39, name = "破胆怒吼" },
        }
    elseif specIndex == 2 then
        fu.blocks = {
            ["敌人人数"] = 21,
            auras = {

            }
        }
        fu.spellCooldown = {
            [202168] = { index = 31, name = "胜利在望" },
            [376079] = { index = 32, name = "勇士之矛" },
            [6544] = { index = 33, name = "英勇飞跃" },
            [97462] = { index = 34, name = "集结呐喊" },
            [46968] = { index = 35, name = "震荡波" },
            [107570] = { index = 36, name = "风暴之锤" },
            [384110] = { index = 37, name = "破裂投掷" },
            [64382] = { index = 38, name = "碎裂投掷" },
            [5246] = { index = 39, name = "破胆怒吼" },
            [1719] = { index = 40, name = "鲁莽" },
        }
    elseif specIndex == 3 then
        fu.blocks = {
            ["目标生命值"] = 21,
            ["敌人人数"] = 22,
            auras = {
                ["盾牌格挡"] = {
                    index = 25,
                    auraRef = fu.auras["盾牌格挡"],
                    showKey = "remaining",
                },
            },
        }
        fu.spellCooldown = {
            [202168] = { index = 31, name = "胜利在望" },
            [376079] = { index = 32, name = "勇士之矛" },
            [6544] = { index = 33, name = "英勇飞跃" },
            [97462] = { index = 34, name = "集结呐喊" },
            [46968] = { index = 35, name = "震荡波" },
            [107570] = { index = 36, name = "风暴之锤" },
            [384110] = { index = 37, name = "破裂投掷" },
            [64382] = { index = 38, name = "碎裂投掷" },
            [5246] = { index = 39, name = "破胆怒吼" },
            [2565] = { index = 40, name = "盾牌格挡", charge = 41 },
            [385952] = { index = 42, name = "盾牌冲锋" },
            [107574] = { index = 43, name = "天神下凡" },
            [1160] = { index = 44, name = "挫志怒吼" },
        }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = {}
    local staticSpells = {
        [1] = "英勇投掷",
        [2] = "战斗怒吼",
        [3] = "猛击",
        [4] = "撕裂",
        [5] = "斩杀",
        [6] = "剑刃风暴",
        [7] = "崩摧",
        [8] = "致死打击",
        [9] = "巨人打击",
        [10] = "顺劈斩",
        [11] = "压制",
        [12] = "横扫攻击",
        [13] = "天神下凡",
        [14] = "旋风斩",
        [15] = "斩杀",
        [16] = "嗜血",
        [17] = "暴怒",
        [18] = "奥丁之怒",
        [19] = "怒击",
        [20] = "雷霆一击",
        [21] = "复仇",
        [22] = "胜利在望",
        [23] = "勇士之矛",
        [24] = "英勇飞跃",
        [25] = "集结呐喊",
        [26] = "震荡波",
        [27] = "风暴之锤",
        [28] = "盾牌猛击",
        [29] = "破裂投掷",
        [30] = "碎裂投掷",
        [31] = "破胆怒吼",
        [32] = "鲁莽",
        [33] = "盾牌格挡",
        [34] = "盾牌冲锋",
        [35] = "挫志怒吼",
        [36] = "无视苦痛",
    }
    fu.CreateMacro(dynamicSpells, staticSpells, _)
end
