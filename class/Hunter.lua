local _, fu = ...
if fu.classId ~= 3 then return end

fu.heroSpell = {
    [466930] = 1,  -- 黑暗游侠
    [466932] = 1,  -- 黑暗游侠
    [471876] = 2,  -- 猎群领袖
    [1253599] = 3, -- 哨兵
}

fu.spellCooldown = {
    [53480]  = { index = 30, name = "牺牲咆哮" },
    [109304] = { index = 31, name = "意气风发" },
    [19577]  = { index = 32, name = "胁迫" },
    [5116]   = { index = 33, name = "震荡射击" },
    [19801]  = { index = 34, name = "宁神射击" },
    [187698] = { index = 35, name = "焦油陷进" },
    [1513]   = { index = 36, name = "恐吓野兽" },
    [109248] = { index = 37, name = "束缚射击" },
    [195645] = { index = 38, name = "摔绊" },
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
        fu.spellCooldown[34026] = { index = 39, name = "杀戮命令", charge = 40 }
        fu.spellCooldown[217200] = { index = 41, name = "倒刺射击", charge = 42 }
        fu.spellCooldown[147362] = { index = 43, name = "反制射击" }
        fu.spellCooldown[19574] = { index = 44, name = "狂野怒火" }
        fu.spellCooldown[1264359] = { index = 45, name = "狂野鞭笞" }
    elseif specIndex == 2 then
        fu.blocks = {

        }

        fu.spellCooldown[147362] = { index = 39, name = "反制射击" }
        fu.spellCooldown[19434] = { index = 40, name = "瞄准射击", charge = 41 }
        fu.spellCooldown[257044] = { index = 42, name = "急速射击" }
        fu.spellCooldown[288613] = { index = 43, name = "百发百中" }
    elseif specIndex == 3 then
        fu.blocks = {

        }
        fu.spellCooldown[1261193] = { index = 39, name = "爆裂火铳" }
        fu.spellCooldown[1250646] = { index = 40, name = "狩魂一击" }
        fu.spellCooldown[190925] = { index = 41, name = "鱼叉猛刺" }
        fu.spellCooldown[186270] = { index = 42, name = "猛禽一击" }
        fu.spellCooldown[259495] = { index = 43, name = "野火炸弹" }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = {}
    local specialSpells = {}
    local staticSpells = {
        [1] = "意气风发",
        [2] = "灵龟守护",
        [3] = "反制射击",
        [4] = "多重射击",
        [5] = "狂野怒火",
        [6] = "夺命射击",
        [7] = "百发百中",
        [8] = "爆炸射击",
        [9] = "荒野呼唤",
        [10] = "血溅十方",
        [11] = "治疗宠物",
        [12] = "倒刺射击",
        [13] = "杀戮命令",
        [14] = "眼镜蛇射击",
        [15] = "瞄准射击",
        [16] = "急速射击",
        [17] = "稳固射击",
        [18] = "哀恸箭",
        [19] = "猎人印记",
        [20] = "奥术射击",
        [21] = "奇美拉射击",
        [22] = "夺命黑鸦",
        [23] = "弹幕射击",
        [24] = "召唤宠物 1",
        [25] = "召唤宠物 2",
        [26] = "召唤宠物 3",
        [27] = "召唤宠物 4",
        [28] = "召唤宠物 5",
        [29] = "狂野鞭笞",
        [30] = "黑蚀箭",
        [31] = "[@cursor]乱射",
        [32] = "投掷手斧",
        [33] = "燎焰沥青",
        [34] = "爆裂火铳",
        [35] = "狩魂一击",
        [36] = "鱼叉猛刺",
        [37] = "猛禽一击",
        [38] = "野火炸弹",
        [39] = "牺牲咆哮",
    }

    fu.CreateMacro(dynamicSpells, staticSpells, specialSpells)
end
