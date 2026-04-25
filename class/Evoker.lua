local _, fu = ...
if fu.classId ~= 13 then return end

fu.heroSpell = {
    [1264269] = 1, -- 塑焰者
    [436335] = 2,  -- 鳞长
    [438587] = 2,  -- 鳞长
    [431442] = 2,  -- 时空守卫
}

fu.spellCooldown = {
    [365585] = { index = 31, name = "净除" },
    [363916] = { index = 32, name = "黑曜鳞片", charge = 33 },
    [358385] = { index = 34, name = "山崩" },
    [360995] = { index = 35, name = "青翠之拥" },
    [357210] = { index = 36, name = "深呼吸" },
    [374227] = { index = 37, name = "微风" },
    [358267] = { index = 38, name = "悬空", charge = 39 },
    [368970] = { index = 40, name = "扫尾", },
    [370553] = { index = 41, name = "扭转天平", },
    [370665] = { index = 42, name = "营救", },
    [374968] = { index = 43, name = "时间螺旋", },
    [406732] = { index = 44, name = "空间悖论", },
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    if specIndex == 1 then
        fu.blocks = {
            ["施法技能"] = 21,
        }
        fu.spellCooldown[359073] = { index = 45, name = "永恒之涌" }
        fu.spellCooldown[351338] = { index = 46, name = "镇压" }
        fu.spellCooldown[375087] = { index = 47, name = "狂龙之怒" }
        fu.spellCooldown[357208] = { index = 48, name = "火焰吐息" }
    elseif specIndex == 2 then
        fu.blocks = {

        }
    elseif specIndex == 3 then
        fu.blocks = {

        }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = { "活化烈焰", "青翠之拥", "回响", "逆转", "净除", "翡翠之花" }
    local specialSpells = {}
    local staticSpells = {
        [1] = "净除",
        [2] = "火焰吐息",
        [3] = "青铜龙的祝福",
        [4] = "灼烧之焰",
        [5] = "黑曜鳞片",
        [6] = "山崩",
        [7] = "悬空",
        [8] = "碧蓝打击",
        [9] = "扫尾",
        [10] = "翡翠之花",
        [11] = "扭转天平",
        [12] = "活化烈焰",
        [13] = "裂解",
        [14] = "深呼吸",
        [15] = "青翠之拥",
        [16] = "永恒之涌",
        [17] = "葬火",
        [18] = "狂龙之怒",
        [19] = "镇压",
        [20] = "梦游",
        [21] = "微风",
        [22] = "时间螺旋",
        [23] = "空间悖论",
        [24] = "营救",
    }

    fu.CreateMacro(dynamicSpells, staticSpells, specialSpells)
end
