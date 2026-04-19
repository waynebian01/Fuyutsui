local _, fu = ...
if fu.classId ~= 12 then return end
local creat = fu.updateOrCreatTextureByIndex

fu.heroSpell = {
    [442290] = 1,  -- 奥达奇收割者
    [452402] = 2,  -- 邪痕枭雄
    [1253304] = 3, -- 歼灭者
}

fu.spellCooldown = {
    [196718] = { index = 40, name = "黑暗" },
    [198793] = { index = 41, name = "复仇回避" },
    [185123] = { index = 42, name = "投掷利刃", charge = 43 },
    [207684] = { index = 44, name = "悲苦咒符" },
    [217832] = { index = 45, name = "禁锢" },
    [258920] = { index = 46, name = "献祭光环" },
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then
        fu.blocks = {
            ["敌人人数"] = 21,
        }
        fu.spellCooldown[179057] = { index = 47, name = "混乱新星" }
        fu.spellCooldown[191427] = { index = 48, name = "恶魔变形" }
        fu.spellCooldown[232893] = { index = 49, name = "邪能之刃" }
        fu.spellCooldown[188499] = { index = 50, name = "刃舞" }
        fu.spellCooldown[162794] = { index = 51, name = "混乱打击" }
        fu.spellCooldown[198589] = { index = 52, name = "疾影" }
        fu.spellCooldown[370965] = { index = 53, name = "恶魔追击" }
        fu.spellCooldown[198013] = { index = 54, name = "眼棱" }
        fu.spellCooldown[195072] = { index = 55, name = "邪能冲撞" }
        fu.spellCooldown[258860] = { index = 56, name = "精华破碎" }
    elseif specIndex == 2 then
        fu.blocks = {
            ["敌人人数"] = 21,
        }
        fu.spellCooldown[179057] = { index = 47, name = "混乱新星" }
        fu.spellCooldown[187827] = { index = 48, name = "恶魔变形" }
        fu.spellCooldown[232893] = { index = 49, name = "邪能之刃" }
        fu.spellCooldown[189110] = { index = 50, name = "地狱火撞击", charge = 51 }
        fu.spellCooldown[203720] = { index = 52, name = "恶魔尖刺" }
        fu.spellCooldown[204021] = { index = 53, name = "烈火烙印", charge = 54 }
        fu.spellCooldown[247454] = { index = 55, name = "幽魂炸弹" }
        fu.spellCooldown[207407] = { index = 56, name = "灵魂切削" }
        fu.spellCooldown[204596] = { index = 57, name = "烈焰咒符" }
        fu.spellCooldown[390163] = { index = 58, name = "怨念咒符" }
        fu.spellCooldown[228447] = { index = 59, name = "灵魂裂劈" }
        fu.spellCooldown[263642] = { index = 60, name = "破裂", charge = 61 }
        fu.spellCooldown[212084] = { index = 62, name = "邪能毁灭" }
        fu.spellCooldown[202137] = { index = 63, name = "沉默咒符" }
    elseif specIndex == 3 then
        fu.blocks = {
            ["敌人人数"] = 21,
        }
        fu.spellCooldown[1234195] = { index = 47, name = "虚空新星" }
        fu.spellCooldown[1217605] = { index = 48, name = "虚空变形" }
        fu.spellCooldown[1245412] = { index = 49, name = "虚空之刃" }
        fu.spellCooldown[1234796] = { index = 50, name = "变换", charge = 51 }
        fu.spellCooldown[1226019] = { index = 52, name = "收割" }
        fu.spellCooldown[473662] = { index = 53, name = "吞噬" }
        fu.spellCooldown[198589] = { index = 54, name = "疾影" }
        fu.spellCooldown[473728] = { index = 55, name = "虚空射线" }
        fu.spellCooldown[1246167] = { index = 56, name = "恶魔追击" }
        fu.spellCooldown[1239123] = { index = 57, name = "饥渴斩击" }
        fu.spellCooldown[1245453] = { index = 58, name = "剔除" }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = {}
    local specialSpells = { [19] = "/castsequence reset=3 烈火烙印,0", }
    local staticSpells = {
        [1] = "复仇回避",
        [2] = "投掷利刃",
        [3] = "[@cursor]悲苦咒符",
        [4] = "禁锢",
        [5] = "献祭光环",
        [6] = "混乱新星",
        [7] = "恶魔变形",
        [8] = "邪能之刃",
        [9] = "刃舞",
        [10] = "混乱打击",
        [11] = "疾影",
        [12] = "恶魔追击",
        [13] = "眼棱",
        [14] = "邪能冲撞",
        [15] = "精华破碎",
        [16] = "恶魔变形",
        [17] = "地狱火撞击",
        [18] = "恶魔尖刺",
        -- [19] = "烈火烙印",
        [20] = "幽魂炸弹",
        [21] = "灵魂切削",
        [22] = "[@player]烈焰咒符",
        [23] = "[@player]怨念咒符",
        [24] = "灵魂裂劈",
        [25] = "破裂",
        [26] = "邪能毁灭",
        [27] = "[@cursor]沉默咒符",
        [28] = "虚空新星",
        [29] = "虚空变形",
        [30] = "虚空之刃",
        [31] = "变换",
        [32] = "收割",
        [33] = "吞噬",
        [34] = "虚空射线",
        [35] = "恶魔追击",
        [36] = "饥渴斩击",
        [37] = "黑暗",
    }
    fu.CreateMacro(dynamicSpells, staticSpells, specialSpells)
end
