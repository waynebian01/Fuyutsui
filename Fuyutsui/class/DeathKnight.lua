local _, fu = ...
if fu.classId ~= 6 then return end
local creat = fu.updateOrCreatTextureByIndex
fu.HarmfulSpellId = 47528

fu.heroSpell = {
    [439843] = 1, -- 死亡使者
    [433901] = 2, -- 萨莱因
    [444005] = 3, -- 天启骑士
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then
        fu.blocks = {
            runes = 11,
            assistant = 12,
            target_valid = 13,
            target_health = 14,
            enemy_count = 15,
            hero_talent = 16,
            spell_cd = {
                [46585] = { index = 17, name = "亡者复生" },
                [55233] = { index = 18, name = "吸血鬼之血" },
                [48792] = { index = 19, name = "冰封之韧" },
                [49039] = { index = 20, name = "巫妖之躯" },
            }
        }
        fu.assistant_spells = {
            [206930] = 1, -- 心脏打击
            [43265] = 2,  -- 枯萎凋零
            [195292] = 3, -- 死神的抚摸
            [49998] = 4,  -- 灵界打击
            [49028] = 5,  -- 符文刃舞
            [195182] = 6, -- 精髓分裂
            [50842] = 7,  -- 血液沸腾
            [433895] = 8, -- 吸血鬼打击
        }
    elseif specIndex == 3 then
        fu.blocks = {
            runes = 11,
            assistant = 12,
            target_valid = 13,
            target_health = 14,
            enemy_count = 15,
            hero_talent = 16,
            auras = {
                ["脓疮毒镰"] = {
                    index = 21,
                    auraRef = fu.auras["脓疮毒镰"],
                    showKey = "remaining",
                },
                ["次级食尸鬼"] = {
                    index = 22,
                    auraRef = fu.auras["次级食尸鬼"],
                    showKey = "remaining",
                },
                ["食尸鬼层数"] = {
                    index = 23,
                    auraRef = fu.auras["次级食尸鬼"],
                    showKey = "count",
                },
                ["末日突降"] = {
                    index = 24,
                    auraRef = fu.auras["末日突降"],
                    showKey = "remaining",
                },
                ["末日突降层数"] = {
                    index = 25,
                    auraRef = fu.auras["末日突降"],
                    showKey = "count",
                },
                ["黑暗援助"] = {
                    index = 26,
                    auraRef = fu.auras["黑暗援助"],
                    showKey = "remaining",
                },
                ["禁断知识"] = {
                    index = 27,
                    auraRef = fu.auras["禁断知识"],
                    showKey = "remaining",
                },
            },
            spell_cd = {
                [46584] = { index = 31, name = "亡者复生", isSpellKnown = false },
                [42650] = { index = 32, name = "亡者大军", isSpellKnown = false },
                [1247378] = { index = 33, name = "腐化", isSpellKnown = false },
                [1233448] = { index = 34, name = "黑暗突变", isSpellKnown = false },
                [343294] = { index = 35, name = "灵魂收割", isSpellKnown = false },
            },
            spell_charge = {
                [1247378] = { index = 36, name = "腐化", isSpellKnown = false },
            },
        }
        fu.assistant_spells = {
            [46584] = 9,    -- 亡者复生
            [42650] = 10,   -- 亡者大军
            [47541] = 11,   -- 凋零缠绕
            [55090] = 12,   -- 天灾打击
            [207317] = 13,  -- 扩散
            [77575] = 14,   -- 爆发
            [85948] = 15,   -- 脓疮打击
            [1247378] = 16, -- 腐化
            [1233448] = 17, -- 黑暗突变
            [343294] = 18,  -- 灵魂收割
        }
    end
end

function fu.CreateClassMacro()
    local dynamicSpells = {}
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
        [12] = "心脏打击",
        [13] = "[@player]枯萎凋零",
        [14] = "死神的抚摸",
        [15] = "符文刃舞",
        [16] = "精髓分裂",
        [17] = "血液沸腾",
        [18] = "吸血鬼之血",
        [19] = "冰封之韧",
        [20] = "巫妖之躯",
    }
    fu.CreateMacro(dynamicSpells, staticSpells, _)
end
