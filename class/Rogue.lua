local _, fu = ...
if fu.classId ~= 4 then return end

fu.heroSpell = {
    [457052] = 1, -- 死亡猎手
    [452536] = 2, -- 命缚者
    [441146] = 3, -- 欺诈者
}

fu.spellCooldown = {
    [5938]   = { index = 31, name = "毒刃" },
    [2094]   = { index = 32, name = "致盲" },
    [1966]   = { index = 33, name = "佯攻" },
    [1856]   = { index = 34, name = "消失" },
    [1833]   = { index = 35, name = "偷袭" },
    [114018] = { index = 36, name = "潜伏帷幕" },
    [381623] = { index = 37, name = "菊花茶" },
    [5277]   = { index = 38, name = "闪避" },
    [185311] = { index = 39, name = "猩红之瓶" },
    [1725]   = { index = 40, name = "扰乱" },
    [2983]   = { index = 41, name = "疾跑" },
    [1776]   = { index = 42, name = "凿击" },
    [408]    = { index = 43, name = "肾击" },
    [31224]  = { index = 44, name = "暗影斗篷" },
    [1766]   = { index = 45, name = "脚踢" },
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.countBars = nil
    fu.group_blocks = nil
    if specIndex == 1 then
        fu.blocks = {

        }

        fu.spellCooldown[360194] = { index = 46, name = "死亡印记" }
        fu.spellCooldown[1293340] = { index = 47, name = "死亡印记" }
        fu.spellCooldown[703] = { index = 48, name = "锁喉" }
        fu.spellCooldown[385627] = { index = 49, name = "君王之灾" }
        fu.spellCooldown[36554] = { index = 50, name = "暗影步" }
    elseif specIndex == 2 then
        fu.blocks = {

        }

        fu.spellCooldown[13750] = { index = 46, name = "冲动" }
        fu.spellCooldown[51690] = { index = 47, name = "影舞步" }
        fu.spellCooldown[271877] = { index = 48, name = "刀锋冲刺" }
        fu.spellCooldown[315341] = { index = 49, name = "正中眉心" }
        fu.spellCooldown[13877] = { index = 50, name = "剑刃乱舞" }
        fu.spellCooldown[195475] = { index = 51, name = "抓钩", charge = 52 }
        fu.spellCooldown[1214909] = { index = 53, name = "命运骨骰" }
    elseif specIndex == 3 then
        fu.blocks = {

        }
        fu.spellCooldown[36554] = { index = 46, name = "暗影步" }
        fu.spellCooldown[280719] = { index = 47, name = "影分身" }
        fu.spellCooldown[121471] = { index = 48, name = "暗影之刃" }
        fu.spellCooldown[185313] = { index = 49, name = "暗影之舞", charge = 50 }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = {}
    local specialSpells = {}
    local staticSpells = {
        [1] = "毒刃",
        [2] = "致盲",
        [3] = "暗影斗篷",
        [4] = "凿击",
        [5] = "嫁祸诀窍",
        [6] = "闪避",
        [7] = "迟钝药膏",
        [8] = "萎缩药膏",
        [9] = "菊花茶",
        [10] = "肾击",
        [11] = "佯攻",
        [12] = "偷袭",
        [13] = "消失",
        [14] = "切割",
        [15] = "潜伏帷幕",
        [16] = "扰乱",
        [17] = "猩红之瓶",
        [18] = "疾跑",
        [19] = "闷棍",
        [20] = "速效药膏",
        [21] = "致伤药膏",
        [22] = "夺命药膏",
        [23] = "增效药膏",
        [24] = "减速药膏",
        [25] = "刀扇",
        [26] = "死亡印记",
        [27] = "死亡印记",
        [28] = "锁喉",
        [29] = "剧毒之刃",
        [30] = "割裂",
        [31] = "毁伤",
        [32] = "君王之灾",
        [33] = "毒伤",
        [34] = "暗影步",
        [35] = "猩红风暴",
        [36] = "伏击",
        [37] = "脚踢",
        [38] = "冲动",
        [39] = "影舞步",
        [40] = "正中眉心",
        [41] = "刀锋冲刺",
        [42] = "手枪射击",
        [43] = "剑刃乱舞",
        [44] = "抓钩",
        [45] = "命运骨骰",
        [46] = "斩击",
        [47] = "时运继延",
        [48] = "伺机待发",
        [49] = "黑火药",
        [50] = "影分身",
        [51] = "暗影之刃",
        [52] = "背刺",
        [53] = "暗影之舞",
        [54] = "袖剑风暴",
        [55] = "暗影打击",
        [56] = "飞镖投掷",
        [57] = "赤喉之咬",
        [58] = "影袭",
    }

    fu.CreateMacro(dynamicSpells, staticSpells, specialSpells)
end
