local _, fu = ...
if fu.classId ~= 5 then return end
local creat = fu.updateOrCreatTextureByIndex
local failedSpellTimer = nil
fu.HarmfulSpellId, fu.HelpfulSpellId = 585, 2061
local dynamicSpells = { "苦修", "快速治疗", "真言术：盾", "愈合祷言", "纯净术", "圣言术：静" }
local staticSpells = {
    [1] = "心灵震爆",
    [2] = "惩击",
    [3] = "暗言术：痛",
    [4] = "真言术：韧",
    [5] = "神圣新星",
    [6] = "苦修",
    [7] = "真言术：耀",
    [8] = "福音",
    [9] = "终极苦修",
    [10] = "绝望祷言",
    [11] = "暗言术：灭",
    [12] = "吸血鬼之触",
    [13] = "[nostance:1]暗影形态",
    [14] = "暗言术：癫",
    [15] = "精神鞭笞",
    [16] = "虚空形态",
    [17] = "虚空洪流",
    [18] = "触须猛击",
    [19] = "虚空冲击",
    [20] = "虚空齐射",
    [21] = "圣言术：罚",
    [22] = "神圣之火",
    [23] = "治疗祷言",
    [24] = "神圣化身",
    [25] = "奥术洪流",
    [26] = "心灵尖啸",
    [27] = "[@cursor]群体驱散",
    [28] = "[@cursor]真言术：障",
    [29] = "神圣赞美诗",
    [30] = "光晕",
}

function fu.CreateClassMacro()
    fu.CreateMacro(dynamicSpells, staticSpells)
end

function fu.updateSpellSuccess(spellID)
    if not fu.blocks.auras then return end
    if spellID == 450215 then -- 虚空冲击
        local spellOverride = C_SpellBook.FindSpellOverrideByID(585)
        if spellOverride == 450215 and fu.blocks.auras.entropicRift.expirationTime and fu.blocks.auras.entropicRift.castCount < 3 then
            fu.blocks.auras.entropicRift.expirationTime = fu.blocks.auras.entropicRift.expirationTime + 1
            fu.blocks.auras.entropicRift.castCount = fu.blocks.auras.entropicRift.castCount + 1
        end
    elseif spellID == 472433 then -- 获取: 福音
        fu.blocks.auras.evangelism.expirationTime = GetTime() + fu.blocks.auras.evangelism.duration
        fu.blocks.auras.evangelism.applications = 2
    elseif spellID == 194509 and fu.blocks.auras.evangelism.expirationTime then -- 真言术：耀
        fu.blocks.auras.evangelism.applications = fu.blocks.auras.evangelism.applications - 1
    elseif spellID == 596 and fu.blocks.auras.lightweaver.expirationTime then
        fu.blocks.auras.lightweaver.applications = math.max(0, fu.blocks.auras.lightweaver.applications - 1)
        creat(fu.blocks.auras.lightweaver.index2, fu.blocks.auras.lightweaver.applications / 255)
    elseif spellID == 232633 and fu.blocks.auras.evangelism.expirationTime then -- 消耗: 福音
        fu.blocks.auras.evangelism.applications = math.max(0, fu.blocks.auras.evangelism.applications - 1)
        creat(fu.blocks.auras.evangelism.index2, fu.blocks.auras.evangelism.applications / 255)
    end
end

-- 更新法术冷却更新
function fu.updateSpellCooldownByEvent(spellId)
    if not fu.blocks or not fu.blocks.auras then return end
    if spellId == 390993 and fu.blocks.auras.lightweaver then -- 获取: 织光者
        fu.blocks.auras.lightweaver.expirationTime = GetTime() + fu.blocks.auras.lightweaver.duration
        fu.blocks.auras.lightweaver.applications = math.min(4, fu.blocks.auras.lightweaver.applications + 1)
        creat(fu.blocks.auras.lightweaver.index2, fu.blocks.auras.lightweaver.applications / 255)
    end
end

function fu.updateSpellOverride(baseSpellID, overrideSpellID)
    if not fu.blocks.auras then return end
    if baseSpellID == 17 then
        if overrideSpellID == 1253593 then
            fu.blocks.auras.voidShield.expirationTime = GetTime() + fu.blocks.auras.voidShield.duration
        elseif overrideSpellID == nil then
            fu.blocks.auras.voidShield.expirationTime = nil
        end
    end
end

function fu.updateSpellIcon(spellId)
    if not fu.blocks.auras then return end
    local overrideSpellID = C_Spell.GetOverrideSpell(spellId)
    if spellId == 585 and fu.blocks.auras.entropicRift then
        if overrideSpellID == 450215 then
            fu.blocks.auras.entropicRift.expirationTime = GetTime() + fu.blocks.auras.entropicRift.duration
        elseif overrideSpellID == 585 then
            fu.blocks.auras.entropicRift.expirationTime = nil
        end
    elseif spellId == 2061 then
        if fu.blocks.auras.shadowMend then
            if overrideSpellID == 186263 then
                fu.blocks.auras.shadowMend.expirationTime = GetTime() + fu.blocks.auras.shadowMend.duration
            elseif overrideSpellID == 2061 then
                fu.blocks.auras.shadowMend.expirationTime = nil
            end
        end
        if fu.blocks.auras.benediction then -- 获取: 祈福
            if overrideSpellID == 1262763 then
                fu.blocks.auras.benediction.expirationTime = GetTime() + fu.blocks.auras.benediction.duration
            elseif overrideSpellID == 2061 then
                fu.blocks.auras.benediction.expirationTime = nil
            end
        end
    end
end

-- 更新法术发光效果
function fu.updateSpellOverlay(spellId)
    if not fu.blocks or not fu.blocks.auras then return end
    --[[if spellId == 2061 then
        local isSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed(spellId)
        if isSpellOverlayed then
            fu.blocks.auras.lightBurst.expirationTime = GetTime() + fu.blocks.auras.lightBurst.duration
        else
            fu.blocks.auras.lightBurst.expirationTime = nil
        end
    end]]
end

-- 更新法术警报, SPELL_ACTIVATION_OVERLAY_SHOW
function fu.spellActivationOverlayShow(spellID)
    if not fu.blocks.auras then return end
    if spellID == 114255 then
        fu.blocks.auras.lightBurst.expirationTime = GetTime() + fu.blocks.auras.lightBurst.duration
    end
end

-- 更新法术警报, SPELL_ACTIVATION_OVERLAY_HIDE
function fu.spellActivationOverlayHide(spellID)
    if not fu.blocks.auras then return end
    if spellID == 114255 then
        fu.blocks.auras.lightBurst.expirationTime = nil
    end
end

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then
        fu.powerType = "MANA"
        fu.blocks = {
            assistant = 11,
            target_valid = 12,
            group_type = 13,
            members_count = 14,
            hero_talent = 15,
            encounterID = 16,
            difficultyID = 17,
            failedSpell = 18,
            auras = {
                voidShield = {
                    name = "虚空之盾",
                    index = 19,
                    remaining = 0,
                    duration = 60,
                    expirationTime = nil,
                },
                lightBurst = {
                    name = "圣光涌动",
                    index = 20,
                    remaining = 0,
                    duration = 20,
                    expirationTime = nil,
                },
                entropicRift = {
                    name = "熵能裂隙",
                    castCount = 0,
                    index = 21,
                    remaining = 0,
                    duration = 8,
                    expirationTime = nil,
                },
                shadowMend = {
                    name = "暗影愈合",
                    index = 22,
                    remaining = 0,
                    duration = 15,
                    expirationTime = nil,
                },
                evangelism = {
                    name = "福音",
                    index = 37,
                    remaining = 0,
                    duration = 120,
                    applications = 0,
                    expirationTime = nil,
                },
            },
            spell_cd = {
                [17] = { index = 23, spellId = 17, name = "真言术：盾" },
                [47540] = { index = 24, spellId = 47540, name = "苦修" },
                [194509] = { index = 25, spellId = 194509, name = "真言术：耀" },
                [527] = { index = 26, spellId = 527, name = "纯净术" },
                [19236] = { index = 27, spellId = 19236, name = "绝望祷言" },
                [8092] = { index = 28, spellId = 8092, name = "心灵震爆" },
                [472433] = { index = 29, spellId = 472433, name = "福音" },
                [32379] = { index = 30, spellId = 32379, name = "暗言术：灭" },
                [232633] = { index = 31, spellId = 232633, name = "奥术洪流" },
                [8122] = { index = 32, spellId = 8122, name = "心灵尖啸", failed = true },
                [32375] = { index = 33, spellId = 32375, name = "群体驱散", failed = true },
                [62618] = { index = 34, spellId = 62618, name = "真言术：障", failed = true },
                [421453] = { index = 35, spellId = 421453, name = "终极苦修", failed = true },
            },
            spell_charge = {
                [47540] = { index = 36, spellId = 47540, name = "苦修" }
            },
        }
        fu.group_blocks = {
            unit_start = 40,
            block_num = 5,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = { [4] = { 194384 }, [5] = { 17, 1253593 }, },
        }
        fu.assistant_spells = {
            [8092] = 1,  -- 心灵震爆
            [585] = 2,   -- 惩击
            [32379] = 3, -- 暗言术：灭
            [589] = 4,   -- 暗言术：痛
            [21562] = 5, -- 真言术：韧
            [47540] = 6, -- 苦修
        }
    elseif specIndex == 2 then
        fu.powerType = "MANA"
        fu.blocks = {
            assistant = 11,
            target_valid = 12,
            group_type = 13,
            members_count = 14,
            hero_talent = 15,
            encounterID = 16,
            difficultyID = 17,
            failedSpell = 18,
            castingSpell = 36,
            auras = {
                lightweaver = {
                    name = "织光者",
                    index = 19,
                    index2 = 20,
                    remaining = 0,
                    duration = 20,
                    applications = 0,
                    expirationTime = nil,
                },
                lightBurst = {
                    name = "圣光涌动",
                    index = 21,
                    remaining = 0,
                    duration = 20,
                    expirationTime = nil,
                },
                benediction = {
                    name = "祈福",
                    index = 22,
                    remaining = 0,
                    duration = 52,
                    expirationTime = nil,
                },
            },
            spell_cd = {
                [33076] = { index = 23, name = "愈合祷言" },
                [2050] = { index = 24, name = "圣言术：静" },
                [88625] = { index = 26, name = "圣言术：罚" },
                [527] = { index = 27, name = "纯净术" },
                [19236] = { index = 28, name = "绝望祷言" },
                [200183] = { index = 29, name = "神圣化身", failed = true },
                [120517] = { index = 30, name = "光晕", failed = true },
                [64843] = { index = 31, name = "神圣赞美诗", failed = true },
                [14914] = { index = 32, name = "神圣之火" },
                [8122] = { index = 33, name = "心灵尖啸", failed = true },
                [32375] = { index = 34, name = "群体驱散", failed = true },
                [232633] = { index = 35, name = "奥术洪流" },
            },
            spell_charge = {
                [2050] = { index = 25, name = "圣言术：静" }
            },
        }
        fu.group_blocks = {
            unit_start = 40,
            block_num = 5,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = { [4] = { 41635 }, [5] = { 139 }, },
        }
        fu.assistant_spells = {
            [88625] = 1,  -- 圣言术：罚
            [585] = 2,    -- 惩击
            [14914] = 3,  -- 神圣之火
            [132157] = 4, -- 神圣新星
            [21562] = 5,  -- 真言术：韧
        }
    elseif specIndex == 3 then
        fu.powerType = "INSANITY"
        fu.blocks = {
            assistant = 11,
            target_valid = 12,
            failedSpell = 13,
            hero_talent = 14,
            encounterID = 15,
            difficultyID = 16,
            spell_cd = {
                [8092] = { index = 31, name = "心灵震爆" },
                [32379] = { index = 32, name = "暗言术：灭" },
                [263165] = { index = 33, name = "虚空洪流" },
                [228260] = { index = 34, name = "虚空形态", failed = true },
                [1227280] = { index = 35, name = "触须猛击" },
                [19236] = { index = 36, name = "绝望祷言" },
                [8122] = { index = 37, name = "心灵尖啸", failed = true },
                [32375] = { index = 38, name = "群体驱散", failed = true },
                [15286] = { index = 39, name = "吸血鬼的拥抱", failed = true },
                [120644] = { index = 40, name = "光晕" },
            },
        }
        fu.assistant_spells = {
            [34914] = 1,    -- 吸血鬼之触
            [8092] = 2,     -- 心灵震爆
            [232698] = 3,   -- 暗影形态
            [32379] = 4,    -- 暗言术：灭
            [589] = 5,      -- 暗言术：痛
            [335467] = 6,   -- 暗言术：癫
            [21562] = 7,    -- 真言术：韧
            [15407] = 8,    -- 精神鞭笞
            [228260] = 9,   -- 虚空形态
            [263165] = 10,  -- 虚空洪流
            [1227280] = 11, -- 触须猛击
            [450983] = 12,  -- 虚空冲击
            [1242173] = 13, -- 虚空齐射
            [391403] = 14,  -- 精神鞭笞：狂
            [120644] = 15,  -- 光晕
        }
    end
end

function fu.updateHeroTalent()
    if fu.blocks.hero_talent then
        local hero_talent = 0
        if C_SpellBook.IsSpellKnown(1248423) then
            hero_talent = 1
        elseif C_SpellBook.IsSpellKnown(447444) then
            hero_talent = 2
        elseif C_SpellBook.IsSpellKnown(120517) then
            hero_talent = 3
        end
        creat(fu.blocks.hero_talent, hero_talent / 255)
    end
end

function fu.updateOnUpdate()
    if not fu.blocks or not fu.blocks.auras then return end
    for _, aura in pairs(fu.blocks.auras) do
        if aura.expirationTime then
            aura.remaining = math.floor(aura.expirationTime - GetTime() + 0.5)
            if aura.remaining > 0 then
                creat(aura.index, aura.remaining / 255)
            else
                aura.expirationTime = nil
                creat(aura.index, 0)
            end
        else
            aura.remaining = 0
            if aura.applications then aura.applications = 0 end
            if aura.index2 then creat(aura.index2, 0) end
            creat(aura.index, 0)
        end
        if aura.applications and aura.applications <= 0 then
            aura.expirationTime = nil
            creat(aura.index, 0)
        end
    end
end

fu.updateSpecInfo()
