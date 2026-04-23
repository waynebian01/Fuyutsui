local _, fu = ...
if fu.classId ~= 6 then return end
local creat = fu.updateOrCreatTextureByIndex
fu.HarmfulSpellId = 47528

fu.heroSpell = {
    [439843] = 1, -- 死亡使者
    [433901] = 2, -- 萨莱因
    [444005] = 3, -- 天启骑士
}

fu.spellCooldown = {
    [49576]  = { index = 40, name = "死亡之握" },
    [51052]  = { index = 41, name = "反魔法领域" },
    [221562] = { index = 42, name = "窒息" },
    [207167] = { index = 43, name = "致盲冰雨" },
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then
        fu.blocks = {
            ["符文"] = 21,
            ["目标生命值"] = 22,
            ["敌人人数"] = 23,
        }
        fu.spellCooldown[46585] = { index = 44, name = "亡者复生" }
        fu.spellCooldown[55233] = { index = 45, name = "吸血鬼之血" }
        fu.spellCooldown[48792] = { index = 46, name = "冰封之韧" }
        fu.spellCooldown[49039] = { index = 47, name = "巫妖之躯" }
        fu.spellCooldown[108199] = { index = 48, name = "血魔之握" }
        fu.spellCooldown[1263569] = { index = 49, name = "憎恶附肢" }
    elseif specIndex == 2 then
        fu.blocks = {
            ["符文"] = 21,
            ["目标生命值"] = 22,
            ["敌人人数"] = 23,
            auras = {
                ["黑暗援助"] = {
                    index = 24,
                    auraRef = fu.auras["黑暗援助"],
                    showKey = "remaining",
                },
            }
        }
    elseif specIndex == 3 then
        local eventTable = { "SPELL_UPDATE_USES", "PLAYER_ENTERING_WORLD" }
        fu.CreateAutoLayoutBar(0, 20, 55090, eventTable) -- 天灾打击

        fu.blocks = {
            ["符文"] = 21,
            ["目标生命值"] = 22,
            ["敌人人数"] = 23,
            auras = {
                ["次级食尸鬼"] = {
                    index = 25,
                    auraRef = fu.auras["次级食尸鬼"],
                    showKey = "remaining",
                },
                ["食尸鬼层数"] = {
                    index = 26,
                    auraRef = fu.auras["次级食尸鬼"],
                    showKey = "count",
                },
                ["末日突降"] = {
                    index = 27,
                    auraRef = fu.auras["末日突降"],
                    showKey = "remaining",
                },
                ["末日突降层数"] = {
                    index = 28,
                    auraRef = fu.auras["末日突降"],
                    showKey = "count",
                },
                ["黑暗援助"] = {
                    index = 29,
                    auraRef = fu.auras["黑暗援助"],
                    showKey = "remaining",
                },
                ["禁断知识"] = {
                    index = 30,
                    auraRef = fu.auras["禁断知识"],
                    showKey = "remaining",
                },
                ["脓疮毒镰"] = {
                    index = 31,
                    auraRef = fu.auras["脓疮毒镰"],
                    showKey = "remaining",
                },
            }
        }
        fu.spellCooldown[46584] = { index = 44, name = "亡者复生" }
        fu.spellCooldown[42650] = { index = 45, name = "亡者大军" }
        fu.spellCooldown[1247378] = { index = 46, name = "腐化", charge = 47 }
        fu.spellCooldown[1233448] = { index = 48, name = "黑暗突变" }
        fu.spellCooldown[343294] = { index = 49, name = "灵魂收割" }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = {}
    local specialSpells = { [38] = "/castsequence reset=3 死亡之握,0", }
    local staticSpells = {
        [1] = "亡者复生",
        [2] = "亡者大军",
        [3] = "凋零缠绕",
        [4] = "天灾打击",
        [5] = "扩散",
        [6] = "爆发",
        [7] = "脓疮打击",
        [8] = "腐化",
        [9] = "黑暗突变",
        [10] = "灵魂收割",
        [11] = "灵界打击",
        [12] = "[spec:2]心脏打击;[spec:3]天灾打击",
        [13] = "[@player]枯萎凋零",
        [14] = "死神的抚摸",
        [15] = "符文刃舞",
        [16] = "精髓分裂",
        [17] = "血液沸腾",
        [18] = "吸血鬼之血",
        [19] = "冰封之韧",
        [20] = "巫妖之躯",
        [21] = "[@cursor]反魔法领域",
        [22] = "窒息",
        [23] = "致盲冰雨",
        [24] = "血魔之握",
        [25] = "憎恶附肢",
        [26] = "死神印记",
        [27] = "冰川突进",
        [28] = "冰霜巨龙之怒",
        [29] = "冷酷严冬",
        [30] = "冰霜之柱",
        [31] = "冰霜打击",
        [32] = "凛风冲击",
        [33] = "冰霜之镰",
        [34] = "冰龙吐息",
        [35] = "湮灭",
        [36] = "符文武器增效",
        [37] = "符文打击",
    }
    fu.CreateMacro(dynamicSpells, staticSpells, specialSpells)
end
