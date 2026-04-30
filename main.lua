local _, fu = ...
local isSec = issecretvalue
local GetSpellCooldownDuration = C_Spell.GetSpellCooldownDuration
local GetSpellChargeDuration = C_Spell.GetSpellChargeDuration
local GetSpellCooldown = C_Spell.GetSpellCooldown
local GetOverrideSpell = C_Spell.GetOverrideSpell
local IsSpellInRange = C_Spell.IsSpellInRange
local GetSpellName = C_Spell.GetSpellName
local IsSpellKnown = C_SpellBook.IsSpellKnown
local IsSpellInSpellBook = C_SpellBook.IsSpellInSpellBook
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex
local rc = LibStub("LibRangeCheck-3.0")
local creat = fu.updateOrCreatTextureByIndex

local state, spells, group, group_list, target, nameplate = {}, {}, {}, {}, {}, {}
local fixed, group_blocks, blocks = {}, nil, nil
local failedSpell, failedSpellId, failedSpellTimer, updateIndex = nil, nil, nil, 1
local updateSpecInfo, createClassMacro
local roleMap, enumPowerType, spellsList = fu.roleMap, fu.EnumPowerType, fu.spellsList
local fallbackColor = CreateColor(0, 0, 1)
local specRange = 40

fixed["锚点"] = 1
fixed["职业"] = 2
fixed["专精"] = 3
fixed["有效性"] = 4
fixed["战斗"] = 5
fixed["移动"] = 6
fixed["施法"] = 7
fixed["引导"] = 8
fixed["蓄力"] = 9
fixed["蓄力层数"] = 10
fixed["生命值"] = 11
fixed["能量值"] = 12
fixed["一键辅助"] = 13
fixed["法术失败"] = 14
fixed["目标类型"] = 15
fixed["队伍类型"] = 16
fixed["队伍人数"] = 17
fixed["首领战"] = 18
fixed["难度"] = 19
fixed["英雄天赋"] = 20


-- ================================================================
--                          创建颜色曲线
-- ================================================================
local curveCache = {}


local function creatColorCurveScaling(b)
    if curveCache[b] then
        return curveCache[b]
    end
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Linear)
    if b > 100 then
        curve:AddPoint(0, CreateColor(0, 0, (b - 100) / 255, 1))
        curve:AddPoint(1, CreateColor(0, 0, b / 255, 1))
    else
        local z = (100 - b) / 100
        curve:AddPoint(0, CreateColor(0, 0, 0, 1))
        curve:AddPoint(z, CreateColor(0, 0, 1 / 255, 1))
        curve:AddPoint(1, CreateColor(0, 0, b / 255, 1))
    end
    curveCache[b] = curve
    return curve
end

local curve100 = creatColorCurveScaling(100)
local curve255 = fu.creatColorCurve(255, 255)
local curve10 = fu.creatColorCurve(10, 100)

-- 单体读条治疗法术
-- 施法目标的生命值增加值,防止对同一个目标重复施法,导致过量治疗
local helpfulSpells = {
    [2061] = 15,    -- 快速治疗
    [1262763] = 15, -- 祈福
    [82326] = 40,   -- 圣光术
    [19750] = 15,   -- 圣光闪现
    [8936] = 15,    -- 愈合
    [186263] = 40,  -- 暗影愈合
    [77472] = 15,   -- 治疗波
}

local dispelCurve = C_CurveUtil.CreateColorCurve()
target.enemyCurve = C_CurveUtil.CreateColorCurve()
target.friendCurve = C_CurveUtil.CreateColorCurve()

dispelCurve:SetType(Enum.LuaCurveType.Step)
target.enemyCurve:SetType(Enum.LuaCurveType.Step)
target.friendCurve:SetType(Enum.LuaCurveType.Step)

-- test
local testColorCurve = C_CurveUtil.CreateColorCurve()
testColorCurve:SetType(Enum.LuaCurveType.Step)
for i = 0, 11 do
    testColorCurve:AddPoint(i, CreateColor(0, 1, i / 255, 1))
end

local function testcurve()
    local unit = "target"
    if not UnitExists(unit) then return end
    local auraInstanceIDs = C_UnitAuras.GetUnitAuraInstanceIDs(unit, "HELPFUL", 1, 4)
    if auraInstanceIDs and #auraInstanceIDs > 0 then
        local color = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceIDs[1], testColorCurve)
        -- print(color.b)
    end
end


-- ================================================================
--                          通用函数
-- ================================================================

-- 更新单位距离
local function updateUnitRange(unit)
    local minRange, maxRange = rc:GetRange(unit)
    return minRange, maxRange
end

-- 打印成功施放的技能id和名称, 不重复打印已经施放的技能
-- 打印格式为  [spellID] = { index = i, }, -- 技能名称
local succSpells = {}
local succIndex = 1
local function printSuccSpell(spellID)
    if succSpells[spellID] or fu.spellsList[spellID] then return end
    succSpells[spellID] = true
    print("[" .. spellID .. "]" .. " = { index = " .. succIndex .. ", }, -- " .. GetSpellName(spellID))
    succIndex = succIndex + 1
end

-- ================================================================
--                          玩家信息
-- ================================================================
-- https://github.com/waynebian01/Fuyutsui

-- 获取玩家固定信息, 函数, 变量
local function getPlayerInfo()
    local name = UnitName("player")
    local GUID = UnitGUID("player")
    local specIndex = C_SpecializationInfo.GetSpecialization()
    local specID, _, _, _, role = C_SpecializationInfo.GetSpecializationInfo(specIndex)

    -- 更新玩家信息
    state.name, state.GUID = name, GUID
    state.className, state.classFilename, state.classId = fu.className, fu.classFilename, fu.classId
    state.specIndex, state.specID, state.specRole = specIndex, specID, role
    specRange = fu.rangeSpecID[state.specID]
    -- 载入函数
    updateSpecInfo = fu.updateSpecInfo                                  -- 更新专精信息
    createClassMacro = fu.CreateClassMacro                              -- 创建类宏
    -- 更新函数
    if type(updateSpecInfo) == "function" then updateSpecInfo() end     -- 更新专精信息
    if type(createClassMacro) == "function" then createClassMacro() end -- 创建类宏

    -- 更新变量
    state.powerType = fu.powerType or nil -- 更新能量类型
    group_blocks = fu.group_blocks        -- 更新队伍块
    blocks = fu.blocks                    -- 更新色块
    -- 创建固定色块
    creat(fixed["锚点"], 0)
    creat(fixed["职业"], fu.classId / 255)
    creat(fixed["专精"], specIndex / 255)
end

-- 各法术的驱散能力映射
local dispelAbilities = {
    [1] = { 527, 360823, 4987, 115450, 88423, 77130 },              -- 魔法驱散
    [2] = { 383016, 51886, 392378, 2782, 475, 77130 },              -- 诅咒驱散
    [3] = { 390632, 213634, 393024, 213644, 388874, 218164 },       -- 疾病驱散
    [4] = { 392378, 2782, 393024, 213644, 388874, 218164, 365585 }, -- 中毒驱散
    [11] = {}                                                       -- 流血驱散
}

-- 各法术的进攻驱散能力映射
local offensiveDispelAbilities = {
    [1] = { 528 },  -- 魔法
    [9] = { 2908 }, -- 激怒
}

-- 检查玩家是否学习了多个法术中的任意一个
local function hasLearnedAnySpell(spellIDs)
    for _, spellID in ipairs(spellIDs) do
        if IsSpellKnown(spellID) then
            return true
        end
    end
    return false
end

local function updateCooldownSpellKnown()
    local count = 1
    spells = {}
    if fu.spellCooldown then
        for spellID, info in pairs(fu.spellCooldown) do
            local isKnown = IsSpellKnown(spellID)
            local isInBook = IsSpellInSpellBook(spellID)
            local index = info.index
            if isKnown or isInBook or info.forcedKnown then
                -- print("加入法术:", info.name, index)
                spells[spellID] = info
            else
                -- print("未加入法术:", count, info.name, index)
                count = count + 1
                creat(index, 1)
            end
        end
    end
end

-- 更新法术已知状态
local function updateSpellKnown()
    updateCooldownSpellKnown()

    -- 动态生成防御驱散能力
    local dispelCapabilities = {
        [1] = false,  -- 魔法驱散
        [2] = false,  -- 疾病驱散
        [3] = false,  -- 诅咒驱散
        [4] = false,  -- 中毒驱散
        [11] = false, -- 流血
    }
    -- 动态生成进攻驱散能力
    local offensiveDispelCapabilities = {
        [1] = false, -- 魔法
        [9] = false, -- 激怒
    }

    if fu.heroSpell then
        local index = 0
        for spellID, info in pairs(fu.heroSpell) do
            if IsSpellKnown(spellID) or IsSpellInSpellBook(spellID) then
                index = info
            end
        end
        creat(fixed["英雄天赋"], index / 255)
    end

    for debuffType, spellIDs in pairs(dispelAbilities) do
        dispelCapabilities[debuffType] = hasLearnedAnySpell(spellIDs)
    end

    for debuffType, spellIDs in pairs(offensiveDispelAbilities) do
        offensiveDispelCapabilities[debuffType] = hasLearnedAnySpell(spellIDs)
    end

    dispelCurve:ClearPoints()
    target.enemyCurve:ClearPoints()
    target.friendCurve:ClearPoints()

    for i, v in pairs(dispelCapabilities) do
        if v then
            dispelCurve:AddPoint(i, CreateColor(0, 1, i / 255, 1))
            target.friendCurve:AddPoint(i, CreateColor(0, 1, (i + 11) / 255, 1))
        else
            dispelCurve:AddPoint(i, CreateColor(0, 0, 0, 1))
            target.friendCurve:AddPoint(i, CreateColor(0, 0, 11 / 255, 1))
        end
    end

    for i, v in pairs(offensiveDispelCapabilities) do
        if v then
            if i == 9 then
                target.enemyCurve:AddPoint(9, CreateColor(0, 1, 3 / 255, 1))
            else
                target.enemyCurve:AddPoint(i, CreateColor(0, 1, (i + 1) / 255, 1))
            end
        else
            target.enemyCurve:AddPoint(i, CreateColor(0, 0, 1 / 255, 1))
        end
    end
end

local function updatePlayerSpecInfo()
    fu.clearAllTextures()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex)
    -- 更新专精信息
    if type(updateSpecInfo) == "function" then
        updateSpecInfo()
    end
    -- 更新变量
    state.specIndex, state.specID = specIndex, specID
    state.powerType = fu.powerType or nil -- 更新能量类型
    group_blocks = fu.group_blocks        -- 更新队伍块
    blocks = fu.blocks                    -- 更新色块
    updateSpellKnown()
    -- 更新专精色块
    creat(fixed["专精"], specIndex / 255)
end

-- 更新玩家有效性
local function updatePlayerValid()
    state.valid = not state.isDead and not state.mounted and not state.isChatOpen
    creat(fixed["有效性"], state.valid and 1 / 255 or 0)
end

local function updatePlayerMounted()
    state.mounted = IsMounted() or state.shapeshiftFormID == 27 or state.shapeshiftFormID == 3 or
        state.shapeshiftFormID == 29
    updatePlayerValid()
end

-- 更新玩家战斗状态
local function updatePlayerCombat()
    state.combat = UnitAffectingCombat("player")
    creat(fixed["战斗"], state.combat and 1 / 255 or 0)
end

-- 更新玩家移动状态
local function updatePlayerMoving(boolean)
    state.moving = boolean
    creat(fixed["移动"], state.moving and 1 / 255 or 0)
end

local function updatePlayerState()
    state.isDead = UnitIsDeadOrGhost("player")
    state.moving = IsPlayerMoving()
    state.isChatOpen = false
    state.casting = false
    state.channeling = false
    updatePlayerMounted()
    updatePlayerMoving(IsPlayerMoving())
end

-- 更新玩家施法状态
local function updatePlayerCastingInfo()
    if state.casting then
        local cast = UnitCastingDuration("player")
        if cast then
            local castingDurationColor = cast:EvaluateElapsedDuration(curve10)
            ---@diagnostic disable-next-line: param-type-mismatch
            local _, _, b = castingDurationColor:GetRGB()
            creat(fixed["施法"], b)
        end
    else
        creat(fixed["施法"], 0)
    end
end

-- 更新玩家引导状态
local function updatePlayerChannelingInfo()
    if state.channeling then
        local channel = UnitChannelDuration("player")
        if channel then
            local channelDurationColor = channel:EvaluateRemainingDuration(curve10)
            ---@diagnostic disable-next-line: param-type-mismatch
            local _, _, b = channelDurationColor:GetRGB()
            creat(fixed["引导"], b)
        end
    else
        creat(fixed["引导"], 0)
    end
end

-- 更新玩家蓄力状态
local function updatePlayerEmpowerInfo()
    if state.empowering then
        local empowerStages = UnitEmpoweredStageDurations("player")
        local empowerDuration = UnitEmpoweredChannelDuration("player")
        if empowerDuration then
            local empowerDurationColor = empowerDuration:EvaluateRemainingDuration(curve10)
            ---@diagnostic disable-next-line: param-type-mismatch
            local _, _, b = empowerDurationColor:GetRGB()
            creat(fixed["蓄力"], b)
        end
        if empowerStages then
            for k, v in pairs(empowerStages) do
                local empower = v:EvaluateRemainingDuration(curve10)
                ---@diagnostic disable-next-line: param-type-mismatch
                local _, _, b = empower:GetRGB()
                creat(fixed["蓄力层数"], (k - 1) / 255)
                if b > 0 then
                    break
                end
            end
        end
    else
        creat(fixed["蓄力"], 0)
        creat(fixed["蓄力层数"], 0)
    end
end

local function updatePlayerCasting(spellId)
    if not blocks then return end
    if blocks["施法目标"] then
        if state.castTargetIndex then
            creat(blocks["施法目标"], state.castTargetIndex / 255)
        else
            creat(blocks["施法目标"], 0)
        end
    end
    if blocks["施法技能"] then
        local castingSpell = spellsList[spellId] and spellsList[spellId].index
        if castingSpell then
            creat(blocks["施法技能"], castingSpell / 255)
        else
            creat(blocks["施法技能"], 0)
        end
    end
end

-- 更新玩家血量信息
local function updatePlayerHealth()
    state.healthPercent = UnitHealthPercent("player", false, curve100)
    ---@diagnostic disable-next-line: param-type-mismatch
    local _, _, b = state.healthPercent:GetRGB()
    creat(fixed["生命值"], b)
end

-- 更新玩家能量信息
local function updatePlayerPower(powerType)
    if (state.powerType and powerType == state.powerType) or state.powerType == nil or powerType == nil then
        state.powerPercent = UnitPowerPercent("player", enumPowerType[state.powerType], nil, curve100)
        ---@diagnostic disable-next-line: param-type-mismatch
        local _, _, b = state.powerPercent:GetRGB()
        creat(fixed["能量值"], b)
    end
    if powerType == "COMBO_POINTS" and blocks and blocks["连击点"] then
        local power = UnitPower("player", 4)
        creat(blocks["连击点"], power / 255)
    end
    if powerType == "HOLY_POWER" and blocks and blocks["神圣能量"] then
        local power = UnitPower("player", 9)
        creat(blocks["神圣能量"], power / 255)
    end
    if powerType == "SOUL_SHARDS" and blocks and blocks["灵魂碎片"] then
        local power = UnitPower("player", 7)
        creat(blocks["灵魂碎片"], power / 255)
    end
end
-- 更新玩家配置
local function updatePlayerConfig()
    C_Timer.After(3, function()
        if blocks and FuyutsuiDB then
            print("重新描绘配置像素")
            if fu.blocks["爆发开关"] then
                creat(fu.blocks["爆发开关"], (FuyutsuiDB.cooldowns or 0) / 255)
            end
            if fu.blocks["AOE开关"] then
                creat(fu.blocks["AOE开关"], (FuyutsuiDB.aoeMode or 0) / 255)
            end
            if fu.blocks["输出模式"] then
                creat(fu.blocks["输出模式"], (FuyutsuiDB.dpsMode or 0) / 255)
            end
        end
    end)
end
-- 更新玩家酒池百分比
local function updatePlayerStagger()
    if blocks and blocks["酒池"] then
        local unit = "player"
        local damage = UnitStagger(unit)
        local maxHealth = UnitHealthMax(unit)
        local staggerPercent = damage / maxHealth * 100
        creat(blocks["酒池"], staggerPercent / 255)
    end
end

---@param spellID number 光环ID,
-- 通过事件 "SPELL_UPDATE_COOLDOWN"获取光环,
-- 更新光环的结束时间, 并更新光环的层数
local function updateAuraBySpellCooldown(spellID)
    local updateAura = fu.updateAuras.bySpellCooldown[spellID]
    if not updateAura then return end
    for _, info in pairs(updateAura) do
        local aura = fu.auras[info.name]
        if not aura then return end
        if aura.duration then
            aura.expirationTime = GetTime() + aura.duration
        end
        if aura.count and info.step then
            if info.step > 0 then
                aura.expirationTime = GetTime() + aura.duration
                aura.count = math.min(aura.countMax, aura.count + info.step)
            else
                aura.count = math.max(aura.countMin, aura.count + info.step)
            end
        end
    end
end

---@param baseSpellID number 基本法术ID
---@param overrideSpellID number 覆盖法术ID
-- 通过事件"COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED"更新光环, 并更新光环的结束时间
local function updateAuraBySpellOverride(baseSpellID, overrideSpellID)
    local spellInfo = fu.updateAuras.bySpellOverride[baseSpellID]
    if not spellInfo then return end
    for _, info in pairs(spellInfo) do
        local aura = fu.auras[info.name]
        if aura then
            if overrideSpellID and aura.duration and overrideSpellID == info.overrideSpellID then
                if aura.duration then
                    aura.expirationTime = GetTime() + aura.duration
                end
            else
                aura.expirationTime = nil
            end
        end
    end
end



---@param spellId number 光环ID, 屏幕提示
-- 通过事件"SPELL_ACTIVATION_OVERLAY_SHOW"更新光环, 并更新光环的结束时间
local function updateAuraByActivationOverlayShow(spellId)

end

---@param spellId number 光环ID, 屏幕提示
-- 通过事件"SPELL_ACTIVATION_OVERLAY_HIDE"更新光环, 并更新光环的结束时间
local function updateAuraByActivationOverlayHide(spellId)
    local updateAura = fu.updateAuras.byActivationOverlay[spellId]
    if not updateAura then return end
    local aura = fu.auras[updateAura.name]
    if not aura then return end
    aura.expirationTime = nil
end

---@param spellID number 法术ID, 法术发光ID
-- SPELL_ACTIVATION_OVERLAY_GLOW_SHOW
-- SPELL_ACTIVATION_OVERLAY_GLOW_HIDE
-- 更新法术发光, 并更新光环的结束时间
local function updateAuraByOverlayGlow(spellID)
    local updateAura = fu.updateAuras.byOverlayGlow[spellID]
    if not updateAura then return end
    local aura = fu.auras[updateAura.name]
    if not aura then return end
    local isSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed(spellID)
    if isSpellOverlayed and aura.duration then
        aura.expirationTime = GetTime() + aura.duration
    else
        aura.expirationTime = nil
    end
end

---@param spellID number 法术ID
---@param castBarID number 施法条ID
-- 通过事件"UNIT_SPELLCAST_SUCCEEDED"更新光环, 并更新光环的层数
local function updateAuraBySuccess(spellID, castBarID)
    local spellInfo = fu.updateAuras.bySuccess[spellID]
    if not spellInfo then return end
    for _, info in pairs(spellInfo) do
        local aura = fu.auras[info.name]
        local isCastBarValid = (not info.castBar) or (info.castBar and castBarID)

        if aura and isCastBarValid then
            if aura.count then
                if info.step then
                    if info.step > 0 then
                        aura.count = math.min(aura.countMax, aura.count + info.step)
                    else
                        aura.count = math.max(aura.countMin, aura.count + info.step)
                    end
                else
                    if aura.count ~= aura.countMin then
                        aura.count = aura.countMin
                    end
                end
            else
                aura.expirationTime = nil
            end
        end
    end
end

---@param spellID number 法术ID
-- 通过事件"SPELL_UPDATE_ICON"更新光环, 并更新光环的层数
local function updateAuraByIcon(spellID)
    local spellInfo = fu.updateAuras.byIcon[spellID]
    if not spellInfo then return end
    local hasOverride = false
    local overrideSpellID = GetOverrideSpell(spellID)
    local aura = fu.auras[spellInfo.name]
    if overrideSpellID == spellInfo.overrideSpellID then
        hasOverride = true
    end
    if spellInfo.isIcon then
        if hasOverride then
            spellInfo.isIcon = 2
        else
            spellInfo.isIcon = 1
        end
    end
    if aura then
        if hasOverride and aura.duration then
            aura.expirationTime = GetTime() + aura.duration
        else
            aura.expirationTime = nil
        end
    end
end

local function updateTeaCount(spellID)
    if spellID ~= 115294 then return end
    local aura = fu.auras["法力茶"]
    if aura and aura.count then
        if state.channeling then
            aura.count = math.max(0, aura.count - 1)
        end
    end
end

--[[local function updateTeaCount2(spellID)
    if spellID ~= 115294 then return end
    local aura = fu.auras["法力茶"]
    if aura and aura.count then
        aura.count = math.max(0, aura.count - 1)
    end
end]]

-- 通过每帧更新光环
local function updateAura()
    local currentTime = GetTime()
    for name, info in pairs(fu.auras) do
        local expTime = info.expirationTime
        if expTime then
            if info.count and info.count <= 0 then
                expTime = nil
            end
            if expTime then
                local remaining = expTime - currentTime
                if remaining > 0 then
                    info.remaining = remaining
                else
                    info.expirationTime = nil
                    info.remaining = 0
                    if info.count then info.count = 0 end
                end
            else
                info.expirationTime = nil
                info.remaining = 0
                if info.count then info.count = 0 end
            end
        else
            if info.remaining ~= 0 then info.remaining = 0 end
            if info.count and info.count ~= info.countMin then info.count = info.countMin end
        end
    end
end

local function updateAuraBlocks()
    if not fu.blocks or not fu.blocks.auras then return end
    for name, info in pairs(fu.blocks.auras) do
        local v = info.show
        if info.auraRef and info.showKey then
            v = info.auraRef[info.showKey]
        end
        if v then
            creat(info.index, v / 255)
        else
            creat(info.index, 0)
        end
    end
end

local function updateRune()
    if blocks and blocks["符文"] then
        local total = 0
        for i = 1, 6 do
            local runeCount = GetRuneCount(i)
            if runeCount then
                total = total + runeCount
            end
        end
        creat(blocks["符文"], total / 255)
    end
end

-- 更新boss战ID
--[[更新难度ID
1 = "5人本普通", -- Normal (Dungeon)
2 = "5人本英雄", -- Heroic (Dungeon)
14 = "团本普通", -- Normal (Raid)
15 = "团本英雄", -- Heroic (Raid)
16 = "团本史诗", -- Mythic (Raid)
17 = "团本随机", -- Looking (Raid)
23 = "5人本史诗", -- Mythic (Dungeon)]]
local function updateEncounterID(encounterID, difficultyID)
    local id = fu.bossID and fu.bossID[encounterID] or 0
    if id then
        creat(fixed["首领战"], id / 255)
    end
    creat(fixed["难度"], difficultyID / 255)
end

-- 更新玩家[一键辅助]
local function updatePlayerAssistant()
    local spellId = C_AssistedCombat.GetNextCastSpell()
    local spellIndex = spellsList[spellId] and spellsList[spellId].index or nil
    if spellIndex then
        creat(fixed["一键辅助"], spellIndex / 255)
    else
        creat(fixed["一键辅助"], 0)
    end
end

-- 更新法术冷却信息
local function updateSpellCooldown()
    if not spells then return end
    for spellID, info in pairs(spells) do
        local index = info.index
        local cdDurationObj = GetSpellCooldownDuration(spellID)
        local cdInfo = GetSpellCooldown(spellID)
        if cdDurationObj and cdInfo then
            local result = cdDurationObj:EvaluateRemainingDuration(curve255, 1)
            fallbackColor:SetRGBA(0, index, 1)
            ---@diagnostic disable-next-line: param-type-mismatch
            local value = EvaluateColorFromBoolean(cdInfo.isEnabled, result, fallbackColor)
            local _, _, b = value:GetRGB()
            ---@diagnostic disable-next-line: undefined-field
            if cdInfo.isOnGCD then b = 0 end
            creat(index, b)
        else
            creat(index, 1)
        end
        local chargeIndex = info.charge
        if chargeIndex then
            local chDurationObj = GetSpellChargeDuration(spellID)
            if chDurationObj then
                local result = chDurationObj:EvaluateRemainingDuration(curve255)
                ---@diagnostic disable-next-line: param-type-mismatch
                local _, _, b = result:GetRGB()
                creat(chargeIndex, b)
            else
                creat(chargeIndex, 1)
            end
        end
    end
end

-- 获取玩家形态
local function updateShapeshiftForm()
    state.shapeshiftFormID = GetShapeshiftFormID()
    if blocks and blocks["姿态"] then
        creat(blocks["姿态"], state.shapeshiftFormID and state.shapeshiftFormID / 255 or 0)
    end
end

-- 更新法术失败
local function updateTeaCountFailed(spellID)
    if spellID ~= 115294 then return end
    local isUsable = C_Spell.IsSpellUsable(spellID)
    if not isUsable then
        local aura = fu.auras["法力茶"]
        if aura and aura.count then
            aura.count = 0
        end
    end
end

local function updateSpellFailed(spellID)
    local isUsable = C_Spell.IsSpellUsable(spellID)

    if spellsList[spellID] and spellsList[spellID].failed then
        failedSpell = spellsList[spellID].index
    else
        failedSpell = nil
    end

    if not isUsable or not failedSpell then return end

    failedSpellId = spellID

    if failedSpellTimer then
        failedSpellTimer:Cancel()
        failedSpellTimer = nil
    end

    failedSpellTimer = C_Timer.NewTimer(1.5, function()
        creat(fixed["法术失败"], 0)
        failedSpellTimer = nil
        failedSpell = nil
        failedSpellId = nil
    end)
    creat(fixed["法术失败"], failedSpell / 255)
end

local function updateFailedSpellBySuccess(spellID)
    if spellID ~= failedSpellId then return end
    failedSpell = nil
    failedSpellId = nil
    print("|cff00ff00插入技能: |r", GetSpellName(spellID))
    creat(fixed["法术失败"], 0)
end

local diseaseJudgeTimer = nil
local function updateDiseaseJudge()
    if blocks and blocks["疾病判断"] then
        creat(blocks["疾病判断"], 1 / 255)
        if diseaseJudgeTimer then
            diseaseJudgeTimer:Cancel()
            diseaseJudgeTimer = nil
        end
        diseaseJudgeTimer = C_Timer.NewTimer(1, function()
            creat(blocks["疾病判断"], 0)
            diseaseJudgeTimer = nil
        end)
    end
end

-- ================================================================
--                          目标信息
-- ================================================================
--[[
    0 = "没有目标"

    1 = "敌方",
    2 = "敌方 有魔法 增益 "
    3 = "敌方 有激怒 增益",

    11 = "友方"
    12 = "友方 有魔法 减益"
    13 = "友方 有疾病 减益"
    14 = "友方 有诅咒 减益"
    15 = "友方 有中毒 减益"

]]

local function getTargetDispelType()
    local unit = "target"
    if not UnitExists(unit) then return 0 end
    local filter, curve, b = nil, nil, 0

    if target.canAttack then
        b = 1 / 255
        curve = target.enemyCurve
        filter = "HELPFUL|RAID_PLAYER_DISPELLABLE"
    elseif target.canAssist then
        b = 11 / 255
        curve = target.friendCurve
        filter = "HARMFUL|RAID_PLAYER_DISPELLABLE"
    else
        return 0
    end

    local auraInstanceIDs = C_UnitAuras.GetUnitAuraInstanceIDs(unit, filter, 1, 4)

    if auraInstanceIDs and #auraInstanceIDs > 0 then
        local color = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceIDs[1], curve)
        return color.b
    end
    return b
end

-- 更新目标类型
local function updateTargetValid()
    local targetType = 0

    if target.inRange and not target.isDead then
        targetType = getTargetDispelType()
    end

    creat(fixed["目标类型"], targetType)
end

-- 更新目标是否可以攻击
local function updateTargetType()
    target.canAttack = UnitCanAttack("player", "target")
    target.canAssist = UnitCanAssist("player", "target")
    updateTargetValid()
end

local function updateTargetRangeBlock()
    local minRange, maxRange = updateUnitRange("target")
    target.maxRange = maxRange
    if target.maxRange and specRange then
        target.inRange = target.maxRange <= specRange
        updateTargetValid()
    end
    if blocks and blocks["目标距离"] then
        if target.maxRange then
            creat(blocks["目标距离"], target.maxRange / 255)
        else
            creat(blocks["目标距离"], 1)
        end
    end
end

-- 更新目标是否死亡
local function updateTargetDeath()
    target.isDead = UnitIsDeadOrGhost("target")
    updateTargetValid()
end

-- 更新目标生命值
local function updateTargetHealth()
    target.healthPercent = UnitHealthPercent("target", false, curve100)
    ---@diagnostic disable-next-line: param-type-mismatch
    local _, _, b = target.healthPercent:GetRGB()
    if blocks and blocks["目标生命值"] then
        creat(blocks["目标生命值"], b)
    end
end

-- 更新目标完整信息
local function updateTargetFullInfo()
    updateTargetType()
    updateTargetDeath()
    updateTargetHealth()
    getTargetDispelType()
end

-- ================================================================
--                          姓名版信息
-- ================================================================

local function addNameplate(unit)
    local minRange, maxRange = updateUnitRange(unit)
    nameplate[unit] = {
        name = GetUnitName(unit, true),
        GUID = UnitGUID(unit),
        canAttack = UnitCanAttack("player", unit),
        canAssist = UnitCanAssist("player", unit),
        minRange = minRange,
        maxRange = maxRange,
        affectingCombat = UnitAffectingCombat(unit),
    }
end

-- 更新范围内敌方姓名版数量
local function updateEnemyCount()
    local count = 0
    local inTestMap = state.mapID and state.mapID == 2393
    for unit, data in pairs(nameplate) do
        local minRange, maxRange = updateUnitRange(unit)
        data.minRange = minRange
        data.maxRange = maxRange
        data.affectingCombat = UnitAffectingCombat(unit)
        if data.canAttack and data.maxRange and data.maxRange <= specRange and (data.affectingCombat or inTestMap) then
            count = count + 1
        end
    end
    if blocks and blocks["敌人人数"] then
        creat(blocks["敌人人数"], count / 255)
    end
end

-- ================================================================
--                          队伍信息
-- ================================================================

local function updateUnitHealthInfo(unit)
    local obj = group[unit]
    if not group_blocks or not obj then return end
    local index = group_blocks.unit_start + (obj.index - 1) * group_blocks.block_num + group_blocks.healthPercent
    obj.curve = creatColorCurveScaling(100 + obj.inComingHeals - obj.healAbsorb)
    local healthPercent = UnitHealthPercent(unit, false, obj.curve)
    ---@diagnostic disable-next-line: param-type-mismatch
    local _, _, b = healthPercent:GetRGB()
    obj.healthPercent = b
    creat(index, obj.healthPercent)
    -- print("更新生命值", GetTime(), unit, obj.inComingHeals, obj.healAbsorb)
end

local function updateUnitValid(unit)
    local obj = group[unit]
    if not obj then return end
    obj.valid = not obj.isDead and obj.canAssist and obj.inSight
end

local falseValue = CreateColor(0, 0, 0, 1)
local function updateGroupInRange()
    if not group_blocks then return end
    local numUnits = #group_list
    if numUnits >= 1 then
        local unit = group_list[updateIndex]
        local obj = group[unit]
        if not obj then return end
        local index = group_blocks.unit_start + (obj.index - 1) * group_blocks.block_num + group_blocks.role
        obj.isDead = UnitIsDeadOrGhost(unit)
        obj.canAssist = UnitCanAssist("player", unit)
        obj.valid = not obj.isDead and obj.canAssist and obj.inSight
        if obj.valid then
            local inRange = UnitIsUnit(unit, "player") and true or UnitInRange(unit)
            local roleValue = roleMap[obj.role] and roleMap[obj.role] / 255 or 5 / 255
            local trueValue = CreateColor(0, 0, roleValue, 1)
            local booleanValue = EvaluateColorFromBoolean(inRange, trueValue, falseValue)
            local _, _, b = booleanValue:GetRGB()
            creat(index, b)
        else
            creat(index, 0)
        end
        updateIndex = updateIndex + 1
        if updateIndex > numUnits then
            updateIndex = 1
        end
    end
end

local function updateUnitDeath(unitGUID)
    for unit, data in pairs(group) do
        if data.GUID == unitGUID then
            data.isDead = true
            -- print(unit, data.GUID, data.name)
            updateUnitValid(unit)
        end
    end
end

local function updateUnitDeathByHealthInfo(unit)
    local obj = group[unit]
    if not obj then return end
    obj.isDead = UnitIsDeadOrGhost(unit)
    updateUnitValid(unit)
end

local function updateUnitInSight(unit)
    local obj = group[unit]
    if not obj then return end
    obj.inSight = false
    -- print("目标不在视野中", obj.name)
    if obj.inSightTimer then
        obj.inSightTimer:Cancel()
        obj.inSightTimer = nil
    end
    obj.inSightTimer = C_Timer.NewTimer(1.5, function()
        obj.inSight = true
        obj.inSightTimer = nil
        -- print("目标在视野中", obj.name)
        updateUnitValid(unit)
    end)
    updateUnitValid(unit)
end

local function updateUnitHealAbsorbCurve(unit)
    local obj = group[unit]
    if not obj then return end
    obj.healAbsorb = 15
    if obj.curveTimer then
        obj.curveTimer:Cancel()
    end
    obj.curveTimer = C_Timer.NewTimer(0.7, function()
        if group[unit] and group[unit] == obj then
            obj.healAbsorb = 0
            obj.curveTimer = nil
        end
        updateUnitHealthInfo(unit)
    end)
    updateUnitHealthInfo(unit)
end

local function updateUnitIncomingHealsCurve(spellID)
    local unit = state.castTargetUnit
    if not unit then return end
    local obj = group[unit]
    if not obj then return end
    local isHelpfulSpell = helpfulSpells[spellID]
    if isHelpfulSpell then
        obj.inComingHeals = isHelpfulSpell
    end
    updateUnitHealthInfo(unit)
end

local function updateUnitIncomingHealsCurve2()
    --[[local unit = state.castTargetUnit
    if not unit then
        print("治疗预估没有恢复,没有目标")
        return
    end
    local obj = group[unit]
    if not obj then
        print("治疗预估没有恢复,目标对象不在队伍里,目标:", unit)
        return
    end

    obj.inComingHeals = 0

    updateUnitHealthInfo(unit)
]]
    for unit, data in pairs(group) do
        data.inComingHeals = 0
        updateUnitHealthInfo(unit)
    end
end

local function updateUnitFullAura(unit)
    local obj = group[unit]
    if not obj then return end
    for i = 1, 5 do
        local buff = C_UnitAuras.GetBuffDataByIndex(unit, i, "PLAYER|HELPFUL|RAID_IN_COMBAT")
        if buff then
            obj.aura[buff.auraInstanceID] = buff
        end
    end
end

local function getMaxAuraByTable(unit, spellIds)
    local obj = group[unit]
    if not obj or not obj.aura then return end
    local maxAura = nil
    for i, spellId in pairs(spellIds) do
        for auraInstanceID, aura in pairs(obj.aura) do
            if isSec(aura.spellId) then
                obj.aura[auraInstanceID] = nil
            else
                if aura.spellId == spellId and aura.expirationTime and (not maxAura or aura.expirationTime > maxAura.expirationTime) then
                    maxAura = aura
                end
            end
        end
    end
    return maxAura
end

local function getRejuvCount(unit)
    local obj = group[unit]
    if not obj or not obj.aura then return end
    local rejuvCount = 0
    for auraInstanceID, aura in pairs(obj.aura) do
        if aura.spellId == 774 or aura.spellId == 155777 then
            rejuvCount = rejuvCount + 1
        end
    end
    return rejuvCount
end

local function OnUpdateUnitAura()
    if not group_blocks or not group_blocks.aura then return end
    for unit, data in pairs(group) do
        for i, spellIds in pairs(group_blocks.aura) do
            local index = group_blocks.unit_start + (data.index - 1) * group_blocks.block_num + i
            local maxAura = getMaxAuraByTable(unit, spellIds)
            if maxAura and maxAura.auraInstanceID then
                local duration = C_UnitAuras.GetAuraDuration(unit, maxAura.auraInstanceID)
                if maxAura.expirationTime == 0 then
                    creat(index, 1)
                elseif duration then
                    local auraduration = duration:EvaluateRemainingDuration(curve255)
                    ---@diagnostic disable-next-line: param-type-mismatch
                    local _, _, b = auraduration:GetRGB()
                    creat(index, b)
                end
            else
                creat(index, 0)
            end
        end
        if group_blocks.rejuv then
            local index = group_blocks.unit_start + (data.index - 1) * group_blocks.block_num +
                group_blocks.rejuv
            local rejuvCount = getRejuvCount(unit)
            creat(index, rejuvCount / 255)
        end
    end
end

--[[local function OnUpdateUnitAura()
    if not group_blocks or not group_blocks.aura then return end
    for unit, data in pairs(group) do
        for i, spellIds in pairs(group_blocks.aura) do
            local index = group_blocks.unit_start + (data.index - 1) * group_blocks.block_num + i
            local hasAura = false
            for j, spellId in ipairs(spellIds) do
                local aura = C_UnitAuras.GetUnitAuraBySpellID(unit, spellId)
                if aura and aura.sourceUnit == "player" then
                    hasAura = true
                    if aura.expirationTime == 0 then
                        creat(index, 1)
                    else
                        local duration = C_UnitAuras.GetAuraDuration(unit, aura.auraInstanceID)
                        local auraduration = duration:EvaluateRemainingDuration(curve255)
                        local _, _, b = auraduration:GetRGB()
                        creat(index, b)
                    end
                end
            end
            if not hasAura then
                creat(index, 0)
            end
        end
    end
    if group_blocks.rejuv then
        for unit, data in pairs(fu.group) do
            local has_rejuv_count = 0
            local index = group_blocks.unit_start + (data.index - 1) * group_blocks.block_num +
                group_blocks.rejuv
            local rejuv_aura = C_UnitAuras.GetUnitAuraBySpellID(unit, 774)
            local rejuv2_aura = C_UnitAuras.GetUnitAuraBySpellID(unit, 155777)
            if rejuv_aura and rejuv_aura.sourceUnit == "player" then
                has_rejuv_count = has_rejuv_count + 1
            end
            if rejuv2_aura and rejuv2_aura.sourceUnit == "player" then
                has_rejuv_count = has_rejuv_count + 1
            end
            creat(index, has_rejuv_count / 255)
        end
    end
end]]

local function getAuraDispelTypeColor(unit)
    local obj = group[unit]
    if not group_blocks or not obj then return end
    local index = group_blocks.unit_start + (obj.index - 1) * group_blocks.block_num + group_blocks.dispel
    local auraInstanceIDs = C_UnitAuras.GetUnitAuraInstanceIDs(unit, "HARMFUL|RAID_PLAYER_DISPELLABLE", 1, 4)
    if auraInstanceIDs and #auraInstanceIDs > 0 then
        local color = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceIDs[1], dispelCurve)
        if color then
            creat(index, color.b)
        end
    else
        creat(index, 0)
    end
end

local function clearGroupBlocks()
    if group_blocks then
        local startIndex = group_blocks.unit_start
        for i = startIndex, 255 do
            creat(i, 0)
        end
    end
end

local function updateGroupCount()
    local count = GetNumGroupMembers()
    creat(fixed["队伍人数"], count / 255)
end

local function updateGroupType()
    local index = 0
    if UnitInRaid("player") then
        index = UnitInRaid("player") or 0
    elseif UnitInParty("player") then
        index = 46
    end
    creat(fixed["队伍类型"], index / 255)
end

local function updateGroup()
    table.wipe(group)
    table.wipe(group_list)

    local i = 1
    for unit in fu.IterateGroupMembers() do
        table.insert(group_list, unit)
        local role = UnitGroupRolesAssigned(unit)
        if unit == "player" then
            role = state.specRole
        end
        group[unit] = {
            index = i,
            name = GetUnitName(unit, true),
            GUID = UnitGUID(unit),
            role = role,
            isDead = UnitIsDeadOrGhost(unit),
            inRange = UnitInRange(unit),
            canAttack = UnitCanAttack("player", unit),
            canAssist = UnitCanAssist("player", unit),
            inSight = true,
            inSightTimer = nil,
            curve = curve100,
            healAbsorb = 0,
            inComingHeals = 0,
            curveTimer = nil,
            aura = {}
        }
        updateUnitValid(unit)
        updateUnitHealthInfo(unit)
        updateUnitFullAura(unit)
        i = i + 1
    end

    fu.group = group
end

-- ================================================================
--                          注册事件
-- ================================================================
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

local function updateAllFunction()
    getPlayerInfo()
    updatePlayerState()
    updatePlayerCombat()
    updatePlayerHealth()
    updatePlayerPower()
    updateGroup()
    updateShapeshiftForm()
    updateGroupCount()
    updateGroupType()
    fu.readKeybindings()
end

frame:RegisterEvent("PLAYER_LOGIN")
function frame:PLAYER_LOGIN()
    updateAllFunction()
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
function frame:PLAYER_ENTERING_WORLD()
    state.mapID = C_Map.GetBestMapForUnit("player") or 0
    fu.ClearAllFuyutsuiBars()
    C_Timer.After(1, function()
        updatePlayerSpecInfo()
        updateGroup()
    end)
    updatePlayerState()
    updateSpellKnown()
    updatePlayerConfig()
end

frame:RegisterEvent("ZONE_CHANGED")
function frame:ZONE_CHANGED()
    state.mapID = C_Map.GetBestMapForUnit("player") or 0
    state.mapInfo = C_Map.GetMapInfo(state.mapID)
end

frame:RegisterEvent("PLAYER_TALENT_UPDATE")
function frame:PLAYER_TALENT_UPDATE()
    updatePlayerSpecInfo()
    updatePlayerMoving(IsPlayerMoving())
    updatePlayerValid()
    updatePlayerCombat()
    updatePlayerHealth()
    updatePlayerPower()
    updatePlayerAssistant()
    updateGroup()
    updateTargetFullInfo()
    updateShapeshiftForm()
    fu.readKeybindings()
end

frame:RegisterEvent("PLAYER_DEAD")
function frame:PLAYER_DEAD()
    state.isDead = UnitIsDeadOrGhost("player")
    updatePlayerValid()
end

frame:RegisterEvent("PLAYER_ALIVE")
function frame:PLAYER_ALIVE()
    state.isDead = UnitIsDeadOrGhost("player")
    updatePlayerValid()
end

frame:RegisterEvent("PLAYER_UNGHOST")
function frame:PLAYER_UNGHOST()
    state.isDead = UnitIsDeadOrGhost("player")
    updatePlayerValid()
end

frame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
function frame:PLAYER_MOUNT_DISPLAY_CHANGED()
    updatePlayerMounted()
end

-- 战斗状态更新
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- 进入战斗
frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- 离开战斗
function frame:PLAYER_REGEN_DISABLED()
    updateTargetType()
    updatePlayerCombat()
end

function frame:PLAYER_REGEN_ENABLED()
    updateTargetType()
    updatePlayerCombat()
end

-- 移动状态更新
frame:RegisterEvent("PLAYER_STARTED_MOVING")
frame:RegisterEvent("PLAYER_STOPPED_MOVING")
function frame:PLAYER_STARTED_MOVING()
    updatePlayerMoving(true)
end

function frame:PLAYER_STOPPED_MOVING()
    updatePlayerMoving(false)
end

frame:RegisterEvent("UNIT_SPELLCAST_SENT")
function frame:UNIT_SPELLCAST_SENT(player, targetName, castGUID, spellID)
    if not isSec(targetName) then
        for unit, data in pairs(group) do
            if data.name == targetName then
                state.castTargetUnit = unit
                state.castTargetName = targetName
                state.castTargetIndex = data.index
                break
            end
        end
        -- print(state.castTargetUnit, state.castTargetName, state.castTargetIndex)
    end
end

-- 施法状态
frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
function frame:UNIT_SPELLCAST_START(unitTarget, castGUID, spellID, castBarID)
    state.casting = true
    updateUnitIncomingHealsCurve(spellID)
    updatePlayerCasting(spellID)
end

function frame:UNIT_SPELLCAST_STOP(unitTarget, castGUID, spellID, castBarID)
    -- print("结束施法时间:", GetTime())
    updateUnitIncomingHealsCurve2()
    state.casting = false
    state.castTargetUnit = nil
    state.castTargetName = nil
    state.castTargetIndex = nil
    updatePlayerCasting(0)
end

-- 引导状态
frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
function frame:UNIT_SPELLCAST_CHANNEL_START(unitTarget, castGUID, spellID, castBarID)
    state.channeling = true
    state.channelingSpellID = spellID
    updatePlayerCasting(spellID)
end

function frame:UNIT_SPELLCAST_CHANNEL_STOP(unitTarget, castGUID, spellID, castBarID)
    state.channeling = false
    state.castTargetUnit = nil
    state.castTargetName = nil
    state.castTargetIndex = nil
    updatePlayerCasting(0)
    -- updateTeaCount2(spellID)
end

-- 蓄力状态
frame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "player")
frame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "player")
function frame:UNIT_SPELLCAST_EMPOWER_START(unitTarget, castGUID, spellID, castBarID)
    state.empowering = true
    state.empoweringSpellID = spellID
    updatePlayerCasting(spellID)
end

function frame:UNIT_SPELLCAST_EMPOWER_STOP(unitTarget, castGUID, spellID, complete, interruptedBy, castBarID)
    state.empowering = false
    state.castTargetUnit = nil
    state.castTargetName = nil
    state.castTargetIndex = nil
    updatePlayerCasting(0)
end

local updateLesserGhoul = false
frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
function frame:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellID, castBarID)
    if not isSec(spellID) then
        updateAuraBySuccess(spellID, castBarID)
        updateFailedSpellBySuccess(spellID)
        -- printSuccSpell(spellID)
        -- print(spellID)
        if spellID == 384255 then
            fu.ClearAllFuyutsuiBars()
            print("切换天赋")
            C_Timer.After(1, function()
                updateAllFunction()
            end)
        elseif spellID == 200749 then
            fu.ClearAllFuyutsuiBars()
            print("切换专精")
            C_Timer.After(1, function()
                updateAllFunction()
            end)
        end
    end
end

frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
function frame:UNIT_SPELLCAST_FAILED(unitTarget, castGUID, spellID, castBarID)
    if not isSec(spellID) then
        updateTeaCountFailed(spellID)
        updateSpellFailed(spellID)
    end
end

frame:RegisterEvent("UNIT_HEALTH")
function frame:UNIT_HEALTH(unit)
    if unit == "player" then
        updatePlayerHealth()
        updatePlayerStagger()
    end
    if unit == "target" then
        updateTargetHealth()
    end
    if group[unit] then
        updateUnitHealthInfo(unit)
        updateUnitDeathByHealthInfo(unit)
    end
end

frame:RegisterEvent("UNIT_MAXHEALTH")
function frame:UNIT_MAXHEALTH(unit)
    if unit == "player" then
        updatePlayerHealth()
    end
    if group[unit] then
        updateUnitHealthInfo(unit)
        updateUnitDeathByHealthInfo(unit)
    end
end

frame:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
function frame:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(unit)
    if unit == "player" then
        updatePlayerHealth()
    end
    if group[unit] then
        updateUnitHealAbsorbCurve(unit)
        updateUnitHealthInfo(unit)
        updateUnitDeathByHealthInfo(unit)
    end
end

frame:RegisterEvent("UNIT_HEAL_PREDICTION")
function frame:UNIT_HEAL_PREDICTION(unit)
    if unit == "player" then
        updatePlayerHealth()
    end
    if group[unit] then
        updateUnitHealthInfo(unit)
        updateUnitDeathByHealthInfo(unit)
    end
end

-- 能量更新
frame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
function frame:UNIT_POWER_UPDATE(unit, powerType)
    updatePlayerPower(powerType)
end

-- Hook 所有默认聊天框
for i = 1, NUM_CHAT_WINDOWS do
    local editBox = _G["ChatFrame" .. i .. "EditBox"]
    if editBox then
        editBox:HookScript("OnEditFocusGained", function()
            state.isChatOpen = true
            updatePlayerValid()
        end)
        editBox:HookScript("OnEditFocusLost", function()
            state.isChatOpen = false
            updatePlayerValid()
        end)
    end
end

frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW") -- 法术图标发光显示
frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE") -- 法术图标发光隐藏
function frame:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(spellID)
    updateAuraByOverlayGlow(spellID)
end

function frame:SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(spellID)
    updateAuraByOverlayGlow(spellID)
end

frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_SHOW") -- 法术警报显示
frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_HIDE") -- 法术警报隐藏
function frame:SPELL_ACTIVATION_OVERLAY_SHOW(spellId)
    -- updateAuraByActivationOverlayShow(spellId)
end

function frame:SPELL_ACTIVATION_OVERLAY_HIDE(spellId)
    updateAuraByActivationOverlayHide(spellId)
end

frame:RegisterEvent("COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED") -- 法术覆盖更新
function frame:COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED(baseSpellID, overrideSpellID)
    updateAuraBySpellOverride(baseSpellID, overrideSpellID)
end

frame:RegisterEvent("SPELL_UPDATE_ICON") -- 法术图标更新
function frame:SPELL_UPDATE_ICON(spellID)
    updateAuraByIcon(spellID)
end

frame:RegisterEvent("SPELL_UPDATE_USES") -- 法术充能冷却更新
function frame:SPELL_UPDATE_USES(spellID, baseSpellID)
    updateTeaCount(spellID)
    fu.updateUsesSpell = spellID
    fu.updateUsesBaseSpell = baseSpellID
    C_Timer.After(0.3, function()
        fu.updateUsesSpell = nil
        fu.updateUsesBaseSpell = nil
    end)
end

frame:RegisterEvent("SPELL_UPDATE_COOLDOWN") -- 法术冷却更新
function frame:SPELL_UPDATE_COOLDOWN(spellID)
    -- print(spellID, C_Spell.GetSpellName(spellID))
    updateAuraBySpellCooldown(spellID)
end

frame:RegisterEvent("GROUP_ROSTER_UPDATE")
local rosterTimer
function frame:GROUP_ROSTER_UPDATE()
    state.castTargetName, state.castTargetUnit = nil, nil
    if rosterTimer then
        rosterTimer:Cancel()
    end
    rosterTimer = C_Timer.NewTimer(1, function()
        clearGroupBlocks()
        updateGroup()
        updateGroupCount()
        updateGroupType()
        rosterTimer = nil
    end)
end

frame:RegisterEvent("UNIT_DIED")
function frame:UNIT_DIED(unitGUID)
    if not isSec(unitGUID) then
        updateUnitDeath(unitGUID)
    end
end

--[[frame:RegisterEvent("UNIT_IN_RANGE_UPDATE")
function frame:UNIT_IN_RANGE_UPDATE(unit, inRange)
end]]

frame:RegisterEvent("SPELL_RANGE_CHECK_UPDATE")
function frame:SPELL_RANGE_CHECK_UPDATE()
    -- updateNameplateCount()
end

frame:RegisterEvent("ACTION_RANGE_CHECK_UPDATE")
function frame:ACTION_RANGE_CHECK_UPDATE(slot, isInRange, checksRange)
    -- updateNameplateCount()
end

frame:RegisterEvent("UI_ERROR_MESSAGE")
function frame:UI_ERROR_MESSAGE(errorType, message)
    -- print(errorType, message)
    if message == "目标不在视野中" then
        updateUnitInSight(state.castTargetUnit)
    elseif message == "射程范围内无有效目标。" then
        updateDiseaseJudge()
    end
end

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
function frame:PLAYER_TARGET_CHANGED()
    updateTargetFullInfo()
end

frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
function frame:NAME_PLATE_UNIT_ADDED(unit)
    addNameplate(unit)
    updateTargetType()
end

frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
function frame:NAME_PLATE_UNIT_REMOVED(unit)
    nameplate[unit] = nil
    updateTargetType()
end

frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
function frame:UPDATE_SHAPESHIFT_FORM()
    updateShapeshiftForm()
    updatePlayerMounted()
end

frame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
function frame:UPDATE_SHAPESHIFT_FORMS()
    updateShapeshiftForm()
    updatePlayerMounted()
end

frame:RegisterEvent("ENCOUNTER_START")
function frame:ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
    updateEncounterID(encounterID, difficultyID)
end

frame:RegisterEvent("ENCOUNTER_END")
function frame:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
    updateEncounterID(0, 0)
end

frame:RegisterEvent("UNIT_AURA")
function frame:UNIT_AURA(unit, info)
    local obj = group[unit]
    if not obj then return end
    getAuraDispelTypeColor(unit)
    if info.isFullUpdate then
        updateUnitFullAura(unit)
        return
    end
    if info.addedAuras then
        for k, v in pairs(info.addedAuras) do
            if not isSec(v.spellId) and v.sourceUnit == "player" then
                -- print("|cnGREEN_FONT_COLOR:新增光环: |r", v.auraInstanceID, v.spellId, v.name)
                obj.aura[v.auraInstanceID] = v
            end
        end
    end
    if info.updatedAuraInstanceIDs then
        for _, v in pairs(info.updatedAuraInstanceIDs) do
            local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, v)
            if aura and not isSec(aura.spellId) and aura.sourceUnit == "player" then
                -- print("|cnYELLOW_FONT_COLOR:更新光环: |r", aura.auraInstanceID, aura.spellId, aura.name)
                obj.aura[aura.auraInstanceID] = aura
            end
        end
    end
    if info.removedAuraInstanceIDs then
        for _, v in pairs(info.removedAuraInstanceIDs) do
            -- print("|cnRED_FONT_COLOR:移除光环: |r", v)
            obj.aura[v] = nil
        end
    end
end

local timeElapsed = 0
frame:SetScript("OnUpdate", function(_, elapsed)
    timeElapsed = timeElapsed + elapsed
    updatePlayerCastingInfo()
    updatePlayerChannelingInfo()
    updatePlayerEmpowerInfo()
    updateGroupInRange()
    if timeElapsed > 0.2 then
        updateSpellCooldown()
        OnUpdateUnitAura()
        updatePlayerAssistant()
        updateRune()
        updateAura()
        updateAuraBlocks()
        updateTargetRangeBlock()
        updateEnemyCount()
        testcurve()
        timeElapsed = 0
    end
end)
