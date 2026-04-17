local _, fu = ...
if fu.classId ~= 3 then return end

fu.heroSpell = {
    [466930] = 1,  -- 黑暗游侠
    [466932] = 1,  -- 黑暗游侠
    [471876] = 2,  -- 猎群领袖
    [1253599] = 3, -- 哨兵
}

fu.spellCooldown = {
    [109304] = { index = 41, name = "意气风发" },
    [19577]  = { index = 42, name = "胁迫" },
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil

    -- 專精 1：野獸控制 (Beast Mastery)
    if specIndex == 1 then
        fu.HarmfulSpellId        = 193455 -- 眼鏡蛇射擊
        fu.blocks                = {

        }
        fu.spellCooldown[34026]  = { index = 43, name = "杀戮命令", charge = 32 }
        fu.spellCooldown[217200] = { index = 44, name = "倒刺射击", charge = 34 }
        fu.spellCooldown[147362] = { index = 45, name = "反制射击" }
        fu.spellCooldown[19574]  = { index = 46, name = "狂野怒火" }
    elseif specIndex == 2 then
        fu.HarmfulSpellId        = 19434 -- 瞄準射擊
        fu.blocks                = {

        }

        fu.spellCooldown[147362] = { index = 43, name = "反制射击" }
        fu.spellCooldown[19434]  = { index = 44, name = "瞄准射击", charge = 30 }
        fu.spellCooldown[257044] = { index = 45, name = "急速射击" }
        fu.spellCooldown[288613] = { index = 46, name = "百发百中" }
    elseif specIndex == 3 then
        fu.HarmfulSpellId        = 1261193 -- 爆裂火铳
        fu.blocks                = {

        }
        fu.spellCooldown[1261193] = { index = 43, name = "爆裂火铳" }
        fu.spellCooldown[1250646] = { index = 44, name = "狩魂一击" }
        fu.spellCooldown[190925] = { index = 45, name = "鱼叉猛刺" }
        fu.spellCooldown[186270] = { index = 46, name = "猛禽一击" }
        fu.spellCooldown[259495] = { index = 47, name = "野火炸弹" }
        fu.spellCooldown[53480] = { index = 48, name = "牺牲咆哮" }
    end
end

-- 創建獵人巨集
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
