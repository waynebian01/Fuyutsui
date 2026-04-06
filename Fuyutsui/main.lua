local _, fu = ...
local rc = LibStub("LibRangeCheck-3.0")
local creat = fu.updateOrCreatTextureByIndex
local state, group, target, nameplate, group_list = {}, {}, {}, {}, {}
local group_blocks, blocks = nil, nil
local failedSpellTimer, updateIndex = nil, 1
local updateSpecInfo, createClassMacro
local roleMap, enumPowerType = fu.roleMap, fu.EnumPowerType

-- 创建颜色曲线
local dispelCurve = fu.dispelCurve
local curve140 = fu.creatColorCurve(1, 140)
local curve120 = fu.creatColorCurve(1, 120)
local curve115 = fu.creatColorCurve(1, 115)
local curve100 = fu.creatColorCurve(1, 100)
local curve80 = fu.creatColorCurve(1, 80)
local curve255 = fu.creatColorCurve(255, 255)
local curve10 = fu.creatColorCurve(10, 100)

-- 单体读条治疗法术
-- 施法目标的生命值倍率,防止对同一个目标重复施法,导致过量治疗
local helpfulSpells = {
    [2061] = curve115,    -- 快速治疗
    [1262763] = curve115, -- 祈福
    [82326] = curve140,   -- 圣光术
    [19750] = curve115,   -- 圣光闪现
}
-- ================================================================
--                          玩家信息
-- ================================================================

-- 获取玩家固定信息, 函数, 变量
local function getPlayerInfo()
    local name = UnitName("player")
    local GUID = UnitGUID("player")
    local specIndex = C_SpecializationInfo.GetSpecialization()
    local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex)
    -- 更新玩家信息
    state.name, state.GUID = name, GUID
    state.className, state.classFilename, state.classId = fu.className, fu.classFilename, fu.classId
    state.specIndex, state.specID = specIndex, specID
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
    print(fu.classId)
    -- 创建固定色块
    creat(fu.fixed_blocks.anchor, 0)
    creat(fu.fixed_blocks.class, fu.classId / 255)
    creat(fu.fixed_blocks.specIndex, specIndex / 255)
end

local function updateSpellKnown()
    if fu.blocks and fu.blocks.spell_cd then
        for spellID, info in pairs(fu.blocks.spell_cd) do
            info.isSpellKnown = C_SpellBook.IsSpellKnown(spellID)
        end
    end
    if fu.blocks and fu.blocks.hero_talent and fu.heroSpell then
        local hero_talent = 0
        for spellID, info in pairs(fu.heroSpell) do
            if C_SpellBook.IsSpellKnown(spellID) then
                hero_talent = info
            end
        end
        creat(fu.blocks.hero_talent, hero_talent / 255)
    end
end

local function updatePlayerSpecInfo()
    fu.clearAllTextures()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex)
    if type(updateSpecInfo) == "function" then updateSpecInfo() end -- 更新专精信息
    -- 更新变量
    state.specIndex, state.specID = specIndex, specID
    state.powerType = fu.powerType or nil -- 更新能量类型
    group_blocks = fu.group_blocks        -- 更新队伍块
    blocks = fu.blocks                    -- 更新色块
    -- 更新专精色块
    creat(fu.fixed_blocks.specIndex, specIndex / 255)
end

-- 更新玩家有效性
local function updatePlayerValid()
    state.valid = not state.isDead and not state.mounted and not state.isChatOpen
    creat(fu.fixed_blocks.valid, state.valid and 1 / 255 or 0)
end

local function updatePlayerMounted()
    state.mounted = IsMounted() or state.shapeshiftFormID == 27 or state.shapeshiftFormID == 3 or
        state.shapeshiftFormID == 29
    updatePlayerValid()
end

-- 更新玩家战斗状态
local function updatePlayerCombat()
    state.combat = UnitAffectingCombat("player")
    creat(fu.fixed_blocks.combat, state.combat and 1 / 255 or 0)
end

-- 更新玩家移动状态
local function updatePlayerMoving(boolean)
    state.moving = boolean
    creat(fu.fixed_blocks.moving, state.moving and 1 / 255 or 0)
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
            local castingDurationColor = cast:EvaluateRemainingDuration(curve10)
            local _, _, b = castingDurationColor:GetRGB()
            creat(fu.fixed_blocks.casting, b)
        end
    else
        creat(fu.fixed_blocks.casting, 0)
    end
end

-- 更新玩家引导状态
local function updatePlayerChannelingInfo()
    if state.channeling then
        local channel = UnitChannelDuration("player")
        if channel then
            local channelDurationColor = channel:EvaluateRemainingDuration(curve10)
            local _, _, b = channelDurationColor:GetRGB()
            creat(fu.fixed_blocks.channel, b)
        end
    else
        creat(fu.fixed_blocks.channel, 0)
    end
end

local function updatePlayerCasting(spellId)
    if blocks then
        if blocks.castingUnit then
            if state.castTargetIndex then
                creat(blocks.castingUnit, state.castTargetIndex / 255)
            else
                creat(blocks.castingUnit, 0)
            end
        end
        if blocks.castingSpell then
            if fu.castingSpellList[spellId] then
                creat(blocks.castingSpell, fu.castingSpellList[spellId] / 255)
            else
                creat(blocks.castingSpell, 0)
            end
        end
    end
end

-- 更新玩家血量信息
local function updatePlayerHealth()
    state.healthPercent = UnitHealthPercent("player", false, curve100)
    local _, _, b = state.healthPercent:GetRGB()
    creat(fu.fixed_blocks.HealthPercent, b)
end

-- 更新玩家能量信息
local function updatePlayerPower(powerType)
    if (state.powerType and powerType == state.powerType) or state.powerType == nil or powerType == nil then
        state.powerPercent = UnitPowerPercent("player", enumPowerType[state.powerType], nil, curve100)
        local _, _, b = state.powerPercent:GetRGB()
        creat(fu.fixed_blocks.PowerPercent, b)
    end
    if powerType == "COMBO_POINTS" and blocks and blocks.comboPoints then
        local power = UnitPower("player", 4)
        creat(blocks.comboPoints, power / 255)
    end
    if powerType == "HOLY_POWER" and blocks and blocks.holyPower then
        local power = UnitPower("player", 9)
        creat(blocks.holyPower, power / 255)
    end
    if powerType == "SOUL_SHARDS" and blocks and blocks.soulShards then
        local power = UnitPower("player", 7)
        creat(blocks.soulShards, power / 255)
    end
end

-- 更新玩家酒池百分比
local function updatePlayerStagger()
    if blocks and blocks.stagger then
        local unit = "player"
        local damage = UnitStagger(unit)
        local maxHealth = UnitHealthMax(unit)
        local staggerPercent = damage / maxHealth * 100
        creat(blocks.stagger, staggerPercent / 255)
    end
end



---@param spellID number 光环ID,
-- 通过事件 "SPELL_UPDATE_COOLDOWN"获取光环,
-- 更新光环的结束时间, 并更新光环的层数
local function updateAuraBySpellCooldown(spellID)
    local updateAura = fu.updateAuras.bySpellCooldown[spellID]
    if not updateAura then return end
    if type(updateAura) == "table" then
        for _, info in pairs(updateAura) do
            local aura = fu.auras[info.name]
            if not aura then return end
            if aura.duration then
                aura.expirationTime = GetTime() + aura.duration
            end
            if aura.count and info.step then
                if info.step > 0 then
                    aura.count = math.min(aura.countMax, aura.count + info.step)
                else
                    aura.count = math.max(aura.countMin, aura.count + info.step)
                end
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
-- 通过事件"UNIT_SPELLCAST_SUCCEEDED"更新光环, 并更新光环的层数
local function updateAuraBySuccess(spellID)
    local spellInfo = fu.updateAuras.bySuccess[spellID]
    if not spellInfo then return end
    for _, info in pairs(spellInfo) do
        local aura = fu.auras[info.name]
        if aura then
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
    local overrideSpellID = C_Spell.GetOverrideSpell(spellID)
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
    if blocks and blocks.runes then
        local total = 0
        for i = 1, 6 do
            total = total + GetRuneCount(i)
        end
        creat(blocks.runes, total / 255)
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
    if blocks then
        if blocks.encounterID then
            local id = fu.bossID and fu.bossID[encounterID] or 0
            if id then
                creat(blocks.encounterID, id / 255)
            end
        end
        if blocks.difficultyID then
            creat(blocks.difficultyID, difficultyID / 255)
        end
    end
end


-- 更新玩家[一键辅助]
local function updatePlayerAssistant()
    local spellId = C_AssistedCombat.GetNextCastSpell()
    if blocks and blocks.assistant and spellId then
        if fu.assistant[spellId] then
            creat(blocks.assistant, fu.assistant[spellId] / 255)
        else
            creat(blocks.assistant, 0)
        end
    end
end
-- 更新法术冷却信息
local function updateSpellCooldown()
    if blocks and blocks.spell_cd then
        for k, v in pairs(blocks.spell_cd) do
            if v.isSpellKnown then
                local durationObj = C_Spell.GetSpellCooldownDuration(k)
                local cooldown = C_Spell.GetSpellCooldown(k)
                if durationObj and cooldown then
                    local result = durationObj:EvaluateRemainingDuration(curve255)
                    local value = C_CurveUtil.EvaluateColorFromBoolean(cooldown.isEnabled, result,
                        CreateColor(0, v.index, 1))
                    local _, _, b = value:GetRGB()
                    ---@diagnostic disable-next-line: undefined-field
                    if cooldown.isOnGCD then b = 0 end
                    creat(v.index, b)
                else
                    creat(v.index, 1)
                end
            else
                creat(v.index, 1)
            end
        end
    end
end

-- 更新法术充能冷却信息
local function updateSpellChargeCooldown()
    if blocks and blocks.spell_charge then
        for k, v in pairs(blocks.spell_charge) do
            local isSpellKnown = C_SpellBook.IsSpellKnown(k)
            if isSpellKnown then
                local durationObj = C_Spell.GetSpellChargeDuration(k)
                local result = durationObj:EvaluateRemainingDuration(curve255)
                if durationObj then
                    local _, _, b = result:GetRGB()
                    creat(v.index, b)
                else
                    creat(v.index, 1)
                end
            else
                creat(v.index, 1)
            end
        end
    end
end

-- 获取玩家形态
local function updateShapeshiftForm()
    state.shapeshiftFormID = GetShapeshiftFormID()
    if blocks and blocks.stance then
        creat(blocks.stance, state.shapeshiftFormID and state.shapeshiftFormID / 255 or 0)
    end
end

-- 更新法术失败
local function updateSpellFailed(spellID)
    if not blocks or not blocks.failedSpell then return end
    if fu.failedSpells[spellID] then
        creat(blocks.failedSpell, fu.failedSpells[spellID] / 255)
        if failedSpellTimer then
            failedSpellTimer:Cancel()
            failedSpellTimer = nil
        end
        failedSpellTimer = C_Timer.NewTimer(1, function()
            creat(blocks.failedSpell, 0)
            failedSpellTimer = nil
        end)
    end
end

-- ================================================================
--                          目标信息
-- ================================================================
-- 更新目标是否有效
local function updateTargetValid()
    target.valid = target.canAttack and target.inRange and not target.isDead
    if blocks and blocks.target_valid then
        creat(blocks.target_valid, target.valid and 1 / 255 or 0)
    end
end

-- 更新目标是否可以攻击
local function updateTargetCanAttack()
    target.canAttack = UnitCanAttack("player", "target")
    updateTargetValid()
end

-- 更新目标距离, 0:不在范围内, 1:近战范围, 2:远程范围
local function updateTargetDistance()
    local minRange, maxRange = rc:GetRange("target")
    return minRange, maxRange
end

local function updateTargetDistanceBlock()
    local minRange, maxRange = updateTargetDistance()
    target.maxRange = maxRange
    if blocks and blocks.target_maxRange then
        if target.maxRange then
            creat(blocks.target_maxRange, target.maxRange / 255)
        else
            creat(blocks.target_maxRange, 1)
        end
    end
end

-- 更新目标是否在范围内
local function updateTargetInRange()
    target.inRange = fu.HarmfulSpellId and C_Spell.IsSpellInRange(fu.HarmfulSpellId, "target")
    updateTargetDistanceBlock()
    updateTargetValid()
end

-- 更新目标是否死亡
local function updateTargetDeath()
    target.isDead = UnitIsDeadOrGhost("target")
    updateTargetValid()
end

-- 更新目标生命值
local function updateTargetHealth()
    target.healthPercent = UnitHealthPercent("target", false, curve100)
    local _, _, b = target.healthPercent:GetRGB()
    if blocks and blocks.target_health then
        creat(blocks.target_health, b)
    end
end

-- 更新目标完整信息
local function updateTargetFullInfo()
    updateTargetCanAttack()
    updateTargetInRange()
    updateTargetDeath()
    updateTargetHealth()
end

-- ================================================================
--                          姓名版信息
-- ================================================================

-- 更新范围内敌方姓名版数量
local function updateNameplateCount()
    if blocks and blocks.enemy_count and fu.HarmfulSpellId then
        nameplate.count = 0
        for i = 1, 8 do
            local unit = "nameplate" .. i
            if UnitExists(unit) and UnitCanAttack("player", unit) and C_Spell.IsSpellInRange(fu.HarmfulSpellId, unit) then
                nameplate.count = nameplate.count + 1
            end
        end
        creat(blocks.enemy_count, nameplate.count / 255)
    end
end

-- ================================================================
--                          队伍信息
-- ================================================================

local function updateUnitHealthInfo(unit)
    local obj = group[unit]
    if not group_blocks or not obj then return end
    local index = group_blocks.unit_start + (obj.index - 1) * group_blocks.block_num + group_blocks.healthPercent
    local healthPercent = UnitHealthPercent(unit, false, obj.curve)
    local _, _, b = healthPercent:GetRGB()
    obj.healthPercent = b
    creat(index, obj.healthPercent)
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
    if numUnits > 1 then
        local unit = group_list[updateIndex]
        local obj = group[unit]
        if not obj then return end
        local index = group_blocks.unit_start + (obj.index - 1) * group_blocks.block_num + group_blocks.role
        obj.isDead = UnitIsDeadOrGhost(unit)
        updateUnitValid(unit)
        if obj.valid then
            local inRange = UnitInRange(unit)
            local roleValue = roleMap[obj.role] and roleMap[obj.role] / 255 or 5
            local trueValue = CreateColor(0, 0, roleValue, 1)
            local booleanValue = C_CurveUtil.EvaluateColorFromBoolean(inRange, trueValue, falseValue)
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

local function updateUnitCurve(unit)
    local obj = group[unit]
    if not obj then return end
    obj.curve = curve80
    if obj.curveTimer then
        obj.curveTimer:Cancel()
    end
    obj.curveTimer = C_Timer.NewTimer(1, function()
        if group[unit] and group[unit] == obj then
            obj.curve = curve100
            obj.curveTimer = nil
        end
        updateUnitHealthInfo(unit)
    end)
end



local function updateCastUnitCurve(spellID, boolean)
    local unit = state.castTargetUnit
    if not unit then return end
    local obj = group[unit]
    if not obj then return end
    local isHelpfulSpell = helpfulSpells[spellID]
    if boolean and isHelpfulSpell then
        obj.curve = isHelpfulSpell
    else
        obj.curve = curve100
    end
    updateUnitHealthInfo(unit)
end

local function updateUnitFullAura(unit)
    local obj = group[unit]
    if not obj then return end
end

local function OnUpdateUnitAura()
    if not group_blocks then return end
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
    if fu.group_blocks.rejuv then
        for unit, data in pairs(fu.group) do
            local has_rejuv_count = 0
            local index = fu.group_blocks.unit_start + (data.index - 1) * fu.group_blocks.block_num + fu.group_blocks.rejuv
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
end

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
    for i = 40, 200 do
        creat(i, 0)
    end
end

local function updateGroupCount()
    if blocks and blocks.members_count then
        local count = GetNumGroupMembers()
        creat(blocks.members_count, count / 255)
    end
end

local function updateGroupType()
    if blocks and blocks.group_type then
        local index = 0
        if UnitInRaid("player") then
            index = UnitInRaid("player")
        elseif UnitInParty("player") then
            index = 46
        end
        creat(blocks.group_type, index / 255)
    end
end
local function updateGroup()
    table.wipe(group)
    table.wipe(group_list)
    clearGroupBlocks()
    local i = 1
    for unit in fu.IterateGroupMembers() do
        table.insert(group_list, unit)
        group[unit] = {
            index = i,
            name = GetUnitName(unit, true),
            GUID = UnitGUID(unit),
            role = UnitGroupRolesAssigned(unit),
            isDead = UnitIsDeadOrGhost(unit),
            inRange = UnitInRange(unit),
            canAttack = UnitCanAttack("player", unit),
            canAssist = UnitCanAssist("player", unit),
            inSight = true,
            inSightTimer = nil,
            curve = curve100,
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


frame:RegisterEvent("PLAYER_LOGIN")
function frame:PLAYER_LOGIN()
    SetCVar("ActionButtonUseKeyDown", 1)
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

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
function frame:PLAYER_ENTERING_WORLD()
    updatePlayerState()
    updateSpellKnown()
    updateGroup()
end

frame:RegisterEvent("ZONE_CHANGED")
function frame:ZONE_CHANGED()
    local mapID = C_Map.GetBestMapForUnit("player")
    local mapInfo = C_Map.GetMapInfo(mapID)
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
    updateSpellKnown()
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
    updateTargetCanAttack()
    updatePlayerCombat()
end

function frame:PLAYER_REGEN_ENABLED()
    updateTargetCanAttack()
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
    if not issecretvalue(targetName) then
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
    updatePlayerCasting(spellID)
    updateCastUnitCurve(spellID, true)
end

function frame:UNIT_SPELLCAST_STOP(unitTarget, castGUID, spellID, castBarID)
    updateCastUnitCurve(spellID, false)
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
    updatePlayerCasting(spellID)
end

function frame:UNIT_SPELLCAST_CHANNEL_STOP(unitTarget, castGUID, spellID, castBarID)
    state.channeling = false
    state.castTargetUnit = nil
    state.castTargetName = nil
    state.castTargetIndex = nil
    updatePlayerCasting(0)
end

frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
function frame:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellID, castBarID)
    if not issecretvalue(spellID) then
        updateAuraBySuccess(spellID)
        if spellID == 384255 then
            C_Timer.After(1, function() updateSpellKnown() end)
        end
    end
end

frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
function frame:UNIT_SPELLCAST_FAILED(unitTarget, castGUID, spellID, castBarID)
    if not issecretvalue(spellID) then
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
    updateUnitCurve(unit)
    if unit == "player" then
        updatePlayerHealth()
    end
    if group[unit] then
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
    fu.updateUsesSpell = spellID
    fu.updateUsesBaseSpell = baseSpellID
    C_Timer.After(0.3, function()
        fu.updateUsesSpell = nil
        fu.updateUsesBaseSpell = nil
    end)
end

frame:RegisterEvent("SPELL_UPDATE_COOLDOWN") -- 法术冷却更新
function frame:SPELL_UPDATE_COOLDOWN(spellID)
    print(spellID, C_Spell.GetSpellName(spellID))

    updateAuraBySpellCooldown(spellID)
end

frame:RegisterEvent("GROUP_ROSTER_UPDATE")
function frame:GROUP_ROSTER_UPDATE()
    state.castTargetName, state.castTargetUnit = nil, nil
    updateGroup()
    updateGroupCount()
    updateGroupType()
end

frame:RegisterEvent("UNIT_DIED")
function frame:UNIT_DIED(unitGUID)
    if not issecretvalue(unitGUID) then
        updateUnitDeath(unitGUID)
    end
end

--[[frame:RegisterEvent("UNIT_IN_RANGE_UPDATE")
function frame:UNIT_IN_RANGE_UPDATE(unit, inRange)
end]]

frame:RegisterEvent("SPELL_RANGE_CHECK_UPDATE")
function frame:SPELL_RANGE_CHECK_UPDATE()
    updateTargetInRange()
    updateNameplateCount()
end

frame:RegisterEvent("ACTION_RANGE_CHECK_UPDATE")
function frame:ACTION_RANGE_CHECK_UPDATE(slot, isInRange, checksRange)
    updateTargetInRange()
    updateNameplateCount()
end

frame:RegisterEvent("UI_ERROR_MESSAGE")
function frame:UI_ERROR_MESSAGE(errorType, message)
    if message == "目标不在视野中" then
        updateUnitInSight(state.castTargetUnit)
    end
end

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
function frame:PLAYER_TARGET_CHANGED()
    updateTargetFullInfo()
end

frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
function frame:NAME_PLATE_UNIT_ADDED(unit)
    updateNameplateCount()
    updateTargetCanAttack()
end

frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
function frame:NAME_PLATE_UNIT_REMOVED(unit)
    updateNameplateCount()
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
    elseif info.addedAuras then
        for k, v in pairs(info.addedAuras) do
            if not issecretvalue(v.spellId) then
                obj.aura[v.auraInstanceID] = v
            end
        end
    elseif info.updatedAuraInstanceIDs then
        for _, v in pairs(info.updatedAuraInstanceIDs) do
            local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, v)
            if aura and not issecretvalue(aura.spellId) then
                obj.aura[aura.auraInstanceID] = aura
            end
        end
    elseif info.removedAuraInstanceIDs then
        for _, v in pairs(info.removedAuraInstanceIDs) do
            obj.aura[v] = nil
        end
    end
end

local timer02, timer10 = 0, 0
frame:SetScript("OnUpdate", function(_, update)
    timer02 = timer02 + update
    timer10 = timer10 + update
    updatePlayerCastingInfo()
    updatePlayerChannelingInfo()
    updateGroupInRange()
    if timer02 > 0.2 then
        updateSpellCooldown()
        updateSpellChargeCooldown()
        OnUpdateUnitAura()
        updatePlayerAssistant()
        updateRune()
        updateAura()
        updateAuraBlocks()
        timer02 = 0
    end
    if timer10 >= 1 then
        updateTargetDistanceBlock()
        timer10 = 0
    end
end)
