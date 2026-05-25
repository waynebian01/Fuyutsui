local addon, ns = ...
local isSec = issecretvalue
local GetSpellCooldownDuration = C_Spell.GetSpellCooldownDuration
local GetSpellChargeDuration = C_Spell.GetSpellChargeDuration
local GetSpellCooldown = C_Spell.GetSpellCooldown
local GetSpellName = C_Spell.GetSpellName
local IsSpellKnown = C_SpellBook.IsSpellKnown
local IsSpellInSpellBook = C_SpellBook.IsSpellInSpellBook
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local rc = LibStub("LibRangeCheck-3.0")

local state = Fuyutsui.state
local blocks = Fuyutsui.blocks
local target = Fuyutsui.target
local nameplate = Fuyutsui.nameplate
local group = Fuyutsui.group
local groupList = Fuyutsui.groupList
local spells = {}
local failedSpell, failedSpellId, failedSpellTimer, updateIndex = nil, nil, nil, 1
local roleMap, spellsList, EnumPowerType = Fuyutsui.roleMap, Fuyutsui.spellsList, Fuyutsui.EnumPowerType
local fallbackColor, falseValueBlack, falseValueWhite = CreateColor(0, 0, 1, 1), CreateColor(0, 0, 0, 1),
    CreateColor(0, 0, 1, 1)

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
local curve255 = Fuyutsui:creatColorCurve(255, 255)
local castCurve = Fuyutsui:creatColorCurve(2.55, 255)

local powerCurve = {}
function Fuyutsui:CreatPowerCurve(powerType)
    if powerCurve[powerType] then return end
    local powerMax = UnitPowerMax("player", EnumPowerType[powerType])
    if powerMax >= 250 then
        powerCurve[powerType] = self:creatColorCurve(1, 100)
    else
        powerCurve[powerType] = self:creatColorCurve(1, powerMax)
    end
end

-- 单体读条治疗法术
-- 施法目标的生命值增加值,防止对同一个目标重复施法,导致过量治疗
local helpfulSpells = {
    [2061] = 15,    -- 快速治疗
    [1262763] = 15, -- 祈福
    [82326] = 40,   -- 圣光术
    [19750] = 15,   -- 圣光闪现
    [8936] = 15,    -- 愈合
    [186263] = 50,  -- 暗影愈合
    [77472] = 15,   -- 治疗波
}

local dispelCurve = C_CurveUtil.CreateColorCurve()
target.enemyCurve = C_CurveUtil.CreateColorCurve()
target.friendCurve = C_CurveUtil.CreateColorCurve()

dispelCurve:SetType(Enum.LuaCurveType.Step)
target.enemyCurve:SetType(Enum.LuaCurveType.Step)
target.friendCurve:SetType(Enum.LuaCurveType.Step)

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
    if succSpells[spellID] or Fuyutsui.spellsList[spellID] then return end
    succSpells[spellID] = true
    print("[" .. spellID .. "]" .. " = { index = " .. succIndex .. ", }, -- " .. GetSpellName(spellID))
    succIndex = succIndex + 1
end

local function getSpellChargesInfo()
    local charges = C_Spell.GetSpellCharges(1247378)
    for k, v in pairs(charges) do
        print(k, v, issecretvalue(v))
    end
end

function Fuyutsui:SPELL_UPDATE_CHARGES(_)
    -- getSpellChargesInfo()
end

-- 驱散能力映射
local dispelAbilities = {
    [1] = { 527, 360823, 4987, 115450, 88423, 77130 },              -- 魔法驱散
    [2] = { 383016, 51886, 392378, 2782, 475 },                     -- 诅咒驱散
    [3] = { 390632, 213634, 393024, 213644, 388874, 218164 },       -- 疾病驱散
    [4] = { 392378, 2782, 393024, 213644, 388874, 218164, 365585 }, -- 中毒驱散
    [11] = {}                                                       -- 流血驱散
}

-- 进攻驱散能力映射
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
    spells = {}
    if not blocks.spells then return end
    C_Timer.After(1, function()
        for spellID, info in pairs(blocks.spells) do
            local isKnown = IsSpellKnown(spellID)
            if info.inSpellBook then
                isKnown = IsSpellInSpellBook(spellID)
            end
            local index = info.index
            if isKnown or info.forcedKnown then
                spells[spellID] = info
            else
                Fuyutsui:CreatTexture(index, 1)
            end
        end
    end)
end

-- 更新法术已知状态
function Fuyutsui:updateSpellKnown()
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

-- ================================================================
--                          玩家信息
-- ================================================================

function Fuyutsui:updatePlayerBlocks()
    self.Initialize = false
    self.state.isDead = UnitIsDeadOrGhost("player") -- 4.有效性(死亡)
    self.state.isChatOpen = false                   -- 4.有效性(聊天框)
    self.state.drinkStatus = false                  -- 4.有效性(喝水)
    self:updatePlayerMounted()                      -- 4.有效性(坐骑, 变形)
    self:updatePlayerCombat()                       -- 5.战斗
    self:updatePlayerMoving(IsPlayerMoving())       -- 6.移动
    self:updatePlayerCastingInfo()                  -- 7.施法
    self:updatePlayerChannelingInfo()               -- 8.引导
    self:updatePlayerEmpowerInfo()                  -- 9.蓄力  10.蓄力层数
    self:updatePlayerHealth()                       -- 11.生命值
    self:updatePlayerPowerType()                    -- 12.能量值
    self:updatePlayerAssistant()                    -- 13.一键辅助
    -- 14. 法术失败
    self:updateTargetValid()                        -- 15.目标类型
    self:updateGroupType()                          -- 16.队伍类型
    self:updateGroupCount()                         -- 17.队伍人数
    -- 18. 19. 更新boss战ID和难度
    self:updateHeroTalent()                         -- 20.英雄天赋

    self:updatePlayerBarInfo()                      -- 创建玩家bar信息
    self:updateShapeshiftForm()                     -- 姿态
    self:updatePlayerStagger()                      -- 酒池
    self:updateRune()                               -- 符文
    self:updateTargetRangeBlock()                   -- 目标距离
    self:updateTargetHealth()                       -- 目标生命值
    self:updateEnemyCount()                         -- 敌人数量
    self:updateGroup()                              -- 更新队伍
    self:GetItemCount()                             -- 获取物品数量
    C_Timer.After(1, function()
        self:updatePlayerConfig()
        self.Initialize = true
    end)
end

-- 载入玩家blocks配置
function Fuyutsui:loadPlayerBlocks(specIndex)
    if not specIndex or not self.ClassBlocks then
        return
    end
    local t = self.ClassBlocks[specIndex]
    if not t then return end
    blocks = {
        state = {},
        auras = {},
        spells = {},
        countBars = {},
    }
    for k, v in pairs(t) do
        if k == "countBars" then
            for key, value in pairs(v) do
                blocks.countBars[key] = value
            end
        end

        if type(v) ~= "table" or not v.type then
            -- 跳过 powerType 等非条目字段
        elseif v.type == "block" then
            if not v.name then
                self:Print(("loadPlayerBlocks: 索引 %s 的 block 缺少 name，已跳过"):format(tostring(k)))
            else
                blocks.state[v.name] = k
            end
        elseif v.type == "aura" then
            blocks.auras[k] = v
        elseif v.type == "spell" then
            if not v.spellId then
                self:Print(("loadPlayerBlocks: 索引 %s 的 spell 缺少 spellId，已跳过"):format(tostring(k)))
            else
                if not blocks.spells[v.spellId] then
                    blocks.spells[v.spellId] = {}
                end
                if v.charge then
                    blocks.spells[v.spellId].charge = k
                else
                    blocks.spells[v.spellId].index = k
                end
                if v.forcedKnown then
                    blocks.spells[v.spellId].forcedKnown = v.forcedKnown
                end
                if v.inSpellBook then
                    blocks.spells[v.spellId].inSpellBook = v.inSpellBook
                end
            end
        elseif v.type == "group" then
            blocks.groups = {}
            blocks.groups.start = k
            blocks.groups.num = v.num
            blocks.groups.healthPercent = v.healthPercent
            blocks.groups.role = v.role
            blocks.groups.dispel = v.dispel
            blocks.groups.auras = v.auras
            if v.rejuv then
                blocks.groups.rejuv = v.rejuv
            end
        end
    end
    self.blocks = blocks
end

-- 载入玩家宏
function Fuyutsui:loadPlayerMacros()
    if not self.MacrosList then
        return
    end
    local m = self.MacrosList
    self:CreateMacro(m.dynamicSpells, m.staticSpells, m.specialSpells)
end

-- 1. 首次登录获取角色信息
function Fuyutsui:GetCharacterInfo()
    self.db.char.level = UnitLevel("player")
    self.state.name = UnitName("player")
    self.state.GUID = UnitGUID("player")
    self.state.classColor = RAID_CLASS_COLORS[self.state.classFilename].colorStr
end

-- 2. 首次登录获取玩家专精信息
function Fuyutsui:GetCharacterSpecInfo()
    self.state.specIndex = C_SpecializationInfo.GetSpecialization()
    local specID, specName, _, _, role = C_SpecializationInfo.GetSpecializationInfo(self.state.specIndex)
    self.state.specID = specID
    self.state.specName = specName
    self.state.specRole = role
    self.state.specRange = self.rangeSpecID[specID]
    self.state.isDead = UnitIsDeadOrGhost("player")
    self.state.isChatOpen = false
    self.state.casting = false
    self.state.channeling = false
    self:loadPlayerBlocks(self.state.specIndex)
    self:updateSpellKnown()
    self:updatePlayerMounted()
    self:updateGroup()
    self:loadPlayerMacros() -- 载入玩家宏
    self:updateAuraIconByEnteringWorld()
    self:GetItemCount()     -- 获取物品数量
    self:CreatTexture(blocks.state["职业"], self.state.classId / 255)
    self:CreatTexture(blocks.state["专精"], self.state.specIndex / 255)
end

-- 2. 更新玩家专精信息
function Fuyutsui:updatePlayerSpecInfo()
    self:clearAllTextures()
    self.state.specIndex = C_SpecializationInfo.GetSpecialization()
    local specID, specName, _, _, role = C_SpecializationInfo.GetSpecializationInfo(self.state.specIndex)
    self.state.specID = specID
    self.state.specName = specName
    self.state.specRole = role
    self.state.specRange = self.rangeSpecID[specID]
    self:loadPlayerBlocks(self.state.specIndex) -- 载入玩家blocks配置

    self:updateSpellKnown()                     -- 更新法术已知状态
    self:updatePlayerBlocks()                   -- 更新玩家blocks信息
    self:CreatTexture(blocks.state["职业"], self.state.classId / 255)
    self:CreatTexture(blocks.state["专精"], self.state.specIndex / 255)
end

-- 4. 更新玩家有效性
function Fuyutsui:updatePlayerValid()
    local valid = not state.isDead and not state.mounted and not state.isChatOpen and not state.drinkStatus
    state.valid = valid and 1 / 255 or 0
    self:CreatTexture(blocks.state["有效性"], state.valid)
end

-- 5. 更新玩家战斗状态
function Fuyutsui:updatePlayerCombat()
    local combat = UnitAffectingCombat("player")
    state.combat = combat and 1 / 255 or 0
    self:CreatTexture(blocks.state["战斗"], state.combat)
end

-- 6. 更新玩家移动状态
function Fuyutsui:updatePlayerMoving(boolean)
    state.drinkStatus = false
    self:updatePlayerValid()
    state.moving = boolean and 1 / 255 or 0
    self:CreatTexture(blocks.state["移动"], state.moving)
end

-- 7. 更新玩家施法状态
function Fuyutsui:updatePlayerCastingInfo()
    if state.casting then
        local cast = UnitCastingDuration("player")
        if cast then
            local castingDurationColor = cast:EvaluateElapsedDuration(castCurve)
            ---@diagnostic disable-next-line: param-type-mismatch
            local _, _, b = castingDurationColor:GetRGB()
            state.castingDuration = b
            self:CreatTexture(blocks.state["施法"], state.castingDuration)
        else
            state.castingDuration = 0
            self:CreatTexture(blocks.state["施法"], 0)
        end
    else
        state.castingDuration = 0
        self:CreatTexture(blocks.state["施法"], 0)
    end
end

-- 8. 更新玩家引导状态
function Fuyutsui:updatePlayerChannelingInfo()
    if state.channeling then
        local channel = UnitChannelDuration("player")
        if channel then
            local channelDurationColor = channel:EvaluateRemainingDuration(castCurve)
            ---@diagnostic disable-next-line: param-type-mismatch
            local _, _, b = channelDurationColor:GetRGB()
            state.channelingDuration = b
            self:CreatTexture(blocks.state["引导"], b)
        else
            state.channelingDuration = 0
            self:CreatTexture(blocks.state["引导"], 0)
        end
    else
        state.channelingDuration = 0
        self:CreatTexture(blocks.state["引导"], 0)
    end
end

-- 9. 10. 更新玩家蓄力状态
function Fuyutsui:updatePlayerEmpowerInfo()
    if state.empowering then
        local empowerStages = UnitEmpoweredStageDurations("player")
        local empowerDuration = UnitEmpoweredChannelDuration("player")
        if empowerDuration then
            local empowerDurationColor = empowerDuration:EvaluateRemainingDuration(castCurve)
            ---@diagnostic disable-next-line: param-type-mismatch
            local _, _, b = empowerDurationColor:GetRGB()
            state.empowerDuration = b
            self:CreatTexture(blocks.state["蓄力"], state.empowerDuration)
        end
        if empowerStages then
            for k, v in pairs(empowerStages) do
                local empower = v:EvaluateRemainingDuration(castCurve)
                ---@diagnostic disable-next-line: param-type-mismatch
                local _, _, b = empower:GetRGB()
                state.empowerStage = (k - 1) / 255
                self:CreatTexture(blocks.state["蓄力层数"], state.empowerStage)
                if b > 0 then
                    break
                end
            end
        end
    else
        state.empowerDuration = 0
        state.empowerStage = 0
        self:CreatTexture(blocks.state["蓄力"], 0)
        self:CreatTexture(blocks.state["蓄力层数"], 0)
    end
end

-- 11. 更新玩家血量信息
function Fuyutsui:updatePlayerHealth()
    local healthPercent = UnitHealthPercent("player", false, curve100)
    ---@diagnostic disable-next-line: param-type-mismatch
    local _, _, b = healthPercent:GetRGB()
    state.healthPercent = b
    self:CreatTexture(blocks.state["生命值"], state.healthPercent)
end

local specialPowerMap = {
    ["COMBO_POINTS"] = "连击点",
    ["HOLY_POWER"] = "神圣能量",
    ["ESSENCE"] = "精华能量",
    ["SOUL_SHARDS"] = "灵魂碎片",
    ["CHI"] = "真气",
}
-- 12. 更新玩家能量值
function Fuyutsui:updatePlayerPower(powerType)
    if blocks then
        local power = UnitPower("player", EnumPowerType[powerType])
        local specialPower = specialPowerMap[powerType]
        if isSec(power) then
            if not powerCurve[powerType] then self:CreatPowerCurve(powerType) end
            local powerPercent = UnitPowerPercent("player", EnumPowerType[powerType], nil, powerCurve[powerType])
            ---@diagnostic disable-next-line: param-type-mismatch
            local _, _, b = powerPercent:GetRGB()
            state.powerPercent = b
            self:CreatTexture(blocks.state["能量值"], state.powerPercent)
        elseif specialPower then
            local blockIndex = blocks.state[specialPower]
            if blockIndex then
                self:CreatTexture(blockIndex, power / 255 or 0)
            end
        end
    end
end

function Fuyutsui:updatePlayerPowerType()
    local powerType = UnitPowerType("player")
    self:CreatPowerCurve(powerType)
    self:updatePlayerPower(powerType)
end

-- 13. 更新玩家[一键辅助]
function Fuyutsui:updatePlayerAssistant()
    local spellId = C_AssistedCombat.GetNextCastSpell()
    local spellIndex = spellsList[spellId] and spellsList[spellId].index or 0
    state.assistantSpell = spellIndex / 255 or 0
    self:CreatTexture(blocks.state["一键辅助"], state.assistantSpell)
end

-- 14. 更新玩家法术失败
function Fuyutsui:updateSpellFailed(spellID)
    local isUsable = C_Spell.IsSpellUsable(spellID)

    if spellsList[spellID] and spellsList[spellID].failed then
        failedSpell = spellsList[spellID].index
        state.failedSpell = failedSpell / 255 or 0
    else
        failedSpell = nil
        state.failedSpell = 0
    end

    if not isUsable or not failedSpell then return end

    failedSpellId = spellID

    if failedSpellTimer then
        failedSpellTimer:Cancel()
        failedSpellTimer = nil
    end

    failedSpellTimer = C_Timer.NewTimer(1.5, function()
        self:CreatTexture(blocks.state["法术失败"], 0)
        failedSpellTimer = nil
        failedSpell = nil
        failedSpellId = nil
    end)
    self:CreatTexture(blocks.state["法术失败"], state.failedSpell)
end

-- 14. 通过施法成功更新玩家法术失败
function Fuyutsui:updateFailedSpellBySuccess(spellID)
    if spellID ~= failedSpellId then return end
    failedSpell = nil
    failedSpellId = nil
    print("|cff00ff00插入技能: |r", GetSpellName(spellID))
    self:CreatTexture(blocks.state["法术失败"], 0)
end

-- 15. 更新目标类型
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

function Fuyutsui:updateTargetValid()
    local targetType = 0

    if target.inRange and not target.isDead then
        targetType = getTargetDispelType()
    end
    target.type = targetType
    self:CreatTexture(blocks.state["目标类型"], target.type)
end

-- 16. 更新玩家队伍类型
function Fuyutsui:updateGroupType()
    local index = 0
    if UnitInRaid("player") then
        index = UnitInRaid("player") or 0
    elseif UnitInParty("player") then
        index = 46
    end
    state.groupType = index / 255 or 0
    self:CreatTexture(blocks.state["队伍类型"], state.groupType)
end

-- 17. 更新玩家队伍人数
function Fuyutsui:updateGroupCount()
    local count = GetNumGroupMembers()
    state.groupCount = count / 255 or 0
    self:CreatTexture(blocks.state["队伍人数"], state.groupCount)
end

-- 18. 19. 更新boss战ID和难度
function Fuyutsui:updateEncounterID(encounterID, difficultyID)
    state.encounterID = encounterID
    --[[更新难度ID
            1 = "5人本普通", -- Normal (Dungeon)
            2 = "5人本英雄", -- Heroic (Dungeon)
            14 = "团本普通", -- Normal (Raid)
            15 = "团本英雄", -- Heroic (Raid)
            16 = "团本史诗", -- Mythic (Raid)
            17 = "团本随机", -- Looking (Raid)
            23 = "5人本史诗", -- Mythic (Dungeon)
        ]]
    local id = self.bossID and self.bossID[encounterID] or 0
    if id then
        state.bossID = id / 255 or 0
        self:CreatTexture(blocks.state["首领战"], state.bossID)
    else
        state.bossID = 0
        self:CreatTexture(blocks.state["首领战"], state.bossID)
    end
    state.difficultyID = difficultyID
    self:CreatTexture(blocks.state["难度"], state.difficultyID / 255 or 0)
end

-- 20. 更新玩家英雄天赋
function Fuyutsui:updateHeroTalent()
    if self.heroTalents and blocks.state["英雄天赋"] then
        C_Timer.After(1, function()
            self.state.heroTalent = 0
            for spellID, index in pairs(self.heroTalents) do
                if IsSpellKnown(spellID) or IsSpellInSpellBook(spellID) then
                    self.state.heroTalent = index
                    break
                end
            end
            self:CreatTexture(blocks.state["英雄天赋"], self.state.heroTalent / 255)
        end)
    end
end

-- 创建玩家bar信息
function Fuyutsui:updatePlayerBarInfo()
    if blocks.countBars then
        for k, v in pairs(blocks.countBars) do
            self:CreateAutoLayoutBar(v.valueType, v.minValue, v.maxValue, v.spellId)
        end
    end
end

function Fuyutsui:updatePlayerMounted()
    state.mounted = IsMounted() or state.shapeshiftFormID == 27 or state.shapeshiftFormID == 3 or
        state.shapeshiftFormID == 29
    self:updatePlayerValid()
end

function Fuyutsui:updatePlayerCasting(spellId)
    if not blocks then return end
    if blocks.state["施法目标"] then
        if state.castTargetIndex then
            self:CreatTexture(blocks.state["施法目标"], state.castTargetIndex)
        else
            self:CreatTexture(blocks.state["施法目标"], 0)
        end
    end
    if blocks.state["施法技能"] then
        local castingSpell = spellsList[spellId] and spellsList[spellId].index or 0
        state.castingSpell = castingSpell / 255 or 0
        if castingSpell then
            self:CreatTexture(blocks.state["施法技能"], state.castingSpell)
        else
            self:CreatTexture(blocks.state["施法技能"], 0)
        end
    end
end

-- 更新玩家配置
function Fuyutsui:updatePlayerConfig()
    local c = self.db and self.db.char
    if not c or not blocks then return end
    if blocks.state["爆发开关"] then
        self:CreatTexture(blocks.state["爆发开关"], c.cooldowns / 255 or 0)
    end
    if blocks.state["AOE开关"] then
        self:CreatTexture(blocks.state["AOE开关"], c.aoeMode / 255 or 0)
    end
    if blocks.state["输出模式"] then
        self:CreatTexture(blocks.state["输出模式"], c.dpsMode / 255 or 0)
    end
    if blocks.state["爆发药水开关"] then
        self:CreatTexture(blocks.state["爆发药水开关"], c.potion / 255 or 0)
    end
end

-- 更新玩家酒池百分比
function Fuyutsui:updatePlayerStagger()
    if blocks and blocks.state["酒池"] then
        local unit = "player"
        local damage = UnitStagger(unit)
        local maxHealth = UnitHealthMax(unit)
        local staggerPercent = damage / maxHealth * 100
        state.staggerPercent = staggerPercent / 255 or 0
        self:CreatTexture(blocks.state["酒池"], state.staggerPercent)
    end
end

-- 更新玩家符文
function Fuyutsui:updateRune()
    if blocks and blocks.state["符文"] then
        local total = 0
        for i = 1, 6 do
            local runeCount = GetRuneCount(i)
            if runeCount then
                total = total + runeCount
            end
        end
        state.runeCount = total / 255 or 0
        self:CreatTexture(blocks.state["符文"], state.runeCount)
    end
end

-- 获取玩家形态
function Fuyutsui:updateShapeshiftForm()
    local shapeshiftFormID = GetShapeshiftFormID() or 0
    state.shapeshiftFormID = shapeshiftFormID / 255
    if blocks and blocks.state["姿态"] then
        self:CreatTexture(blocks.state["姿态"], state.shapeshiftFormID)
    end
end

local diseaseJudgeTimer = nil
function Fuyutsui:updateDiseaseJudge()
    if blocks and blocks.state["疾病判断"] then
        state.diseaseJudge = 1 / 255 or 0
        self:CreatTexture(blocks.state["疾病判断"], state.diseaseJudge)
        if diseaseJudgeTimer then
            diseaseJudgeTimer:Cancel()
            diseaseJudgeTimer = nil
        end
        diseaseJudgeTimer = C_Timer.NewTimer(1, function()
            state.diseaseJudge = 0
            self:CreatTexture(blocks.state["疾病判断"], state.diseaseJudge)
            diseaseJudgeTimer = nil
        end)
    end
end

-- 更新防御光环
function Fuyutsui:GetDefensiveAuraInstanceID(unit, info)
    if unit ~= "player" then return end
    if info.addedAuras then
        for i = 1, 2 do
            local aura = C_UnitAuras.GetBuffDataByIndex(unit, i, "HELPFUL|BIG_DEFENSIVE")
            if not issecretvalue(aura) and aura then
                state.DefensiveAuraInstanceID = aura.auraInstanceID
            end
        end
    end
    if info.removedAuraInstanceIDs then
        for _, v in pairs(info.removedAuraInstanceIDs) do
            if v == state.DefensiveAuraInstanceID then
                state.DefensiveAuraInstanceID = nil
            end
        end
    end
end

function Fuyutsui:GetDefensiveAuraDuration()
    if blocks and blocks.state["防御光环"] then
        if state.DefensiveAuraInstanceID then
            local duration = C_UnitAuras.GetAuraDuration("player", state.DefensiveAuraInstanceID)
            if duration then
                local auraduration = duration:EvaluateRemainingDuration(curve255)
                ---@diagnostic disable-next-line: param-type-mismatch
                local _, _, b = auraduration:GetRGB()
                self:CreatTexture(blocks.state["防御光环"], b)
            else
                self:CreatTexture(blocks.state["防御光环"], 0)
            end
        else
            self:CreatTexture(blocks.state["防御光环"], 0)
        end
    end
end

-- 更新法术冷却信息
function Fuyutsui:updateSpellCooldown()
    if not spells then return end
    for spellID, info in pairs(spells) do
        local index = info.index
        local cdDurationObj = GetSpellCooldownDuration(spellID)
        local cdInfo = GetSpellCooldown(spellID)
        if cdDurationObj and cdInfo then
            local result = cdDurationObj:EvaluateRemainingDuration(curve255, 1)
            fallbackColor:SetRGBA(0, index, 254 / 255)
            ---@diagnostic disable-next-line: param-type-mismatch
            local value = EvaluateColorFromBoolean(cdInfo.isEnabled, result, fallbackColor)
            local _, _, b = value:GetRGB()
            if cdInfo.isOnGCD then b = 0 end
            self:CreatTexture(index, b)
        else
            self:CreatTexture(index, 1)
        end
        local chargeIndex = info.charge
        if chargeIndex then
            local chDurationObj = GetSpellChargeDuration(spellID)
            if chDurationObj then
                local result = chDurationObj:EvaluateRemainingDuration(curve255)
                ---@diagnostic disable-next-line: param-type-mismatch
                local _, _, b = result:GetRGB()
                self:CreatTexture(chargeIndex, b)
            else
                self:CreatTexture(chargeIndex, 1)
            end
        end
    end
end

function Fuyutsui:GetItemCount()
    self.state.HealthPotionCount = C_Item.GetItemCount(241304) + C_Item.GetItemCount(241305)    -- 银月城生命药水
    self.state.ManaPotionCount = C_Item.GetItemCount(241301) + C_Item.GetItemCount(241300)      -- 光注法力药水
    self.state.HealthstoneCount = C_Item.GetItemCount(5512) + C_Item.GetItemCount(224464)       -- 治疗石
    self.state.RecklessnessCount = C_Item.GetItemCount(241288) + C_Item.GetItemCount(241289)    -- 鲁莽药水
    self.state.LightsPotentialCount = C_Item.GetItemCount(241308) + C_Item.GetItemCount(241309) -- 圣光潜力
end

function Fuyutsui:GetItemRemainingTime(itemID)
    local startTimeSeconds, durationSeconds, enableCooldownTimer = C_Item.GetItemCooldown(itemID)
    if not enableCooldownTimer then return 255 end
    if startTimeSeconds > 0 then
        return durationSeconds - (GetTime() - startTimeSeconds)
    else
        return 0
    end
end

function Fuyutsui:updateItemCoolDown()
    if blocks then
        if blocks.state["大红冷却"] then
            if not self.state.HealthPotionCount then
                self:GetItemCount()
            end
            local remainingTime = self:GetItemRemainingTime(241304)
            if remainingTime and self.state.HealthPotionCount > 0 then
                self:CreatTexture(blocks.state["大红冷却"], math.min(1, remainingTime / 255))
            else
                self:CreatTexture(blocks.state["大红冷却"], 1)
            end
        end
        if blocks.state["大蓝冷却"] then
            if not self.state.ManaPotionCount then
                self:GetItemCount()
            end
            local remainingTime = self:GetItemRemainingTime(241301)
            if remainingTime and self.state.ManaPotionCount > 0 then
                self:CreatTexture(blocks.state["大蓝冷却"], math.min(1, remainingTime / 255))
            else
                self:CreatTexture(blocks.state["大蓝冷却"], 1)
            end
        end
        if blocks.state["治疗石冷却"] then
            if not self.state.HealthstoneCount then
                self:GetItemCount()
            end
            local remainingTime = self:GetItemRemainingTime(5512)
            if remainingTime and self.state.HealthstoneCount > 0 then
                self:CreatTexture(blocks.state["治疗石冷却"], math.min(1, remainingTime / 255))
            else
                self:CreatTexture(blocks.state["治疗石冷却"], 1)
            end
        end
        if blocks.state["鲁莽药水冷却"] then
            if not self.state.RecklessnessCount then
                self:GetItemCount()
            end
            local remainingTime = self:GetItemRemainingTime(241288)
            if remainingTime and self.state.RecklessnessCount > 0 then
                self:CreatTexture(blocks.state["鲁莽药水冷却"], math.min(1, remainingTime / 255))
            else
                self:CreatTexture(blocks.state["鲁莽药水冷却"], 1)
            end
        end
        if blocks.state["圣光潜力冷却"] then
            if not self.state.LightsPotentialCount then
                self:GetItemCount()
            end
            local remainingTime = self:GetItemRemainingTime(241308)
            if remainingTime and self.state.LightsPotentialCount > 0 then
                self:CreatTexture(blocks.state["圣光潜力冷却"], math.min(1, remainingTime / 255))
            else
                self:CreatTexture(blocks.state["圣光潜力冷却"], 1)
            end
        end
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

-- 更新目标是否可以攻击
function Fuyutsui:updateTargetType()
    target.canAttack = UnitCanAttack("player", "target")
    target.canAssist = UnitCanAssist("player", "target")
    self:updateTargetValid()
end

function Fuyutsui:updateTargetRangeBlock()
    local minRange, maxRange = updateUnitRange("target")
    target.minRange = minRange
    target.maxRange = maxRange
    if target.canAttack then
        if target.maxRange and self.state.specRange then
            target.inRange = target.maxRange <= self.state.specRange
            self:updateTargetValid()
        end
    elseif target.canAssist then
        if target.maxRange then
            target.inRange = target.maxRange <= 40
            self:updateTargetValid()
        end
    end
    if blocks and blocks.state["目标距离"] and target.maxRange then
        local maxRangeValue = target.maxRange and target.maxRange / 255 or 1
        self:CreatTexture(blocks.state["目标距离"], maxRangeValue)
    end
end

function Fuyutsui:updateTargetCastingInfo()
    if not UnitExists("target") then return end
    local cast = UnitCastingDuration("target")
    if cast then
        local _, _, _, _, _, _, _, notInterruptible = UnitCastingInfo("target")
        local castingDurationColor = cast:EvaluateRemainingDuration(castCurve)
        local booleanValue = EvaluateColorFromBoolean(notInterruptible, falseValueWhite, castingDurationColor)
        ---@diagnostic disable-next-line: param-type-mismatch
        local _, _, b = booleanValue:GetRGB()
        target.castingDuration = b
        if blocks and blocks.state["目标施法"] then
            self:CreatTexture(blocks.state["目标施法"], b)
        end
    else
        target.castingDuration = 0
        if blocks and blocks.state["目标施法"] then
            self:CreatTexture(blocks.state["目标施法"], 0)
        end
    end
end

function Fuyutsui:updateTargetChannelInfo()
    if not UnitExists("target") then return end
    local channel = UnitChannelDuration("target")
    if channel then
        local _, _, _, _, _, _, notInterruptible = UnitChannelInfo("target")
        local channelDurationColor = channel:EvaluateRemainingDuration(castCurve)
        local booleanValue = EvaluateColorFromBoolean(notInterruptible, falseValueWhite, channelDurationColor)
        ---@diagnostic disable-next-line: param-type-mismatch
        local _, _, b = booleanValue:GetRGB()
        target.channelingDuration = b
        if blocks and blocks.state["目标引导"] then
            self:CreatTexture(blocks.state["目标引导"], b)
        end
    else
        target.channelingDuration = 0
        if blocks and blocks.state["目标引导"] then
            self:CreatTexture(blocks.state["目标引导"], 0)
        end
    end
end

-- 更新目标是否死亡
function Fuyutsui:updateTargetDeath()
    target.isDead = UnitIsDeadOrGhost("target")
    self:updateTargetValid()
end

-- 更新目标生命值
function Fuyutsui:updateTargetHealth()
    local healthPercent = UnitHealthPercent("target", false, curve100)
    ---@diagnostic disable-next-line: param-type-mismatch
    local _, _, b = healthPercent:GetRGB()
    target.healthPercent = b or 0
    if blocks and blocks.state["目标生命值"] then
        self:CreatTexture(blocks.state["目标生命值"], b)
    end
end

-- 更新目标完整信息
function Fuyutsui:updateTargetFullInfo()
    self:updateTargetType()
    self:updateTargetDeath()
    self:updateTargetHealth()
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
local testMap = {
    [2393] = true, -- 银月城
}
local testEncounter = {
    [2563] = true, -- 茂林古树
}
-- 更新范围内敌方姓名版数量
function Fuyutsui:updateEnemyCount()
    local count = 0
    local inTestMap = state.mapID and testMap[state.mapID]
    local inTestEncounter = state.encounterID and testEncounter[state.encounterID]
    for unit, data in pairs(nameplate) do
        local minRange, maxRange = updateUnitRange(unit)
        data.minRange = minRange
        data.maxRange = maxRange
        data.affectingCombat = UnitAffectingCombat(unit)
        if data.canAttack and data.maxRange and data.maxRange <= self.state.specRange
            and (data.affectingCombat or inTestMap or inTestEncounter) then
            count = count + 1
        end
    end
    state.enemyCount = count / 255 or 0
    if blocks and blocks.state["敌人人数"] then
        self:CreatTexture(blocks.state["敌人人数"], state.enemyCount)
    end
end

-- 通过施放成功获取喝水状态
local drinkStatusTimer = nil
function Fuyutsui:updateDrinkStatus(spellID)
    local name = C_Spell.GetSpellName(spellID)
    if name == "饮水" or name == "进食饮水" then
        state.drinkStatus = true
        self:updatePlayerValid()
        if drinkStatusTimer then
            drinkStatusTimer:Cancel()
            drinkStatusTimer = nil
        end
        drinkStatusTimer = C_Timer.NewTimer(20, function()
            state.drinkStatus = false
            self:updatePlayerValid()
            drinkStatusTimer = nil
        end)
    else
        if drinkStatusTimer then
            drinkStatusTimer:Cancel()
            drinkStatusTimer = nil
        end
        state.drinkStatus = false
        self:updatePlayerValid()
    end
end

-- ================================================================
--                          队伍信息
-- ================================================================

function Fuyutsui:updateUnitHealthInfo(unit)
    local obj = group[unit]
    if not blocks or not blocks.groups or not obj then return end
    local index = blocks.groups.start + (obj.index - 1) * blocks.groups.num + blocks.groups.healthPercent
    obj.curve = creatColorCurveScaling(100 + obj.inComingHeals - obj.healAbsorb)
    local healthPercent = UnitHealthPercent(unit, false, obj.curve)
    ---@diagnostic disable-next-line: param-type-mismatch
    local _, _, b = healthPercent:GetRGB()
    obj.healthPercent = b
    self:CreatTexture(index, obj.healthPercent)
end

function Fuyutsui:updateUnitValid(unit)
    local obj = group[unit]
    if not obj then return end
    obj.valid = not obj.isDead and obj.canAssist and obj.inSight
end

function Fuyutsui:updateGroupInRangeAndHealth()
    if not blocks or not blocks.groups then return end
    local numUnits = #groupList
    if numUnits >= 1 then
        local unit = groupList[updateIndex]
        local obj = group[unit]
        if not obj then return end
        self:updateUnitHealthInfo(unit)
        local index = blocks.groups.start + (obj.index - 1) * blocks.groups.num + blocks.groups.role
        obj.isDead = UnitIsDeadOrGhost(unit)
        obj.canAssist = UnitCanAssist("player", unit)
        obj.valid = not obj.isDead and obj.canAssist and obj.inSight
        if obj.valid then
            local inRange = UnitIsUnit(unit, "player") and true or UnitInRange(unit)
            local roleValue = roleMap[obj.role] and roleMap[obj.role] / 255 or 5 / 255
            local trueValue = CreateColor(0, 0, roleValue, 1)
            local booleanValue = EvaluateColorFromBoolean(inRange, trueValue, falseValueBlack)
            local _, _, b = booleanValue:GetRGB()
            self:CreatTexture(index, b)
        else
            self:CreatTexture(index, 0)
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
            Fuyutsui:updateUnitValid(unit)
        end
    end
end

local function updateUnitDeathByHealthInfo(unit)
    local obj = group[unit]
    if not obj then return end
    obj.isDead = UnitIsDeadOrGhost(unit)
    Fuyutsui:updateUnitValid(unit)
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
        Fuyutsui:updateUnitValid(unit)
    end)
    Fuyutsui:updateUnitValid(unit)
end

local function updateUnitHealAbsorbCurve(unit)
    local obj = group[unit]
    if not obj then return end
    obj.healAbsorb = 15
    if obj.curveTimer then
        obj.curveTimer:Cancel()
    end
    obj.curveTimer = C_Timer.NewTimer(1, function()
        if group[unit] and group[unit] == obj then
            obj.healAbsorb = 0
            obj.curveTimer = nil
        end
    end)
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
end

local function updateUnitIncomingHealsCurve2()
    for unit, data in pairs(group) do
        data.inComingHeals = 0
    end
end

function Fuyutsui:updateUnitFullAura(unit)
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

function Fuyutsui:OnUpdateUnitAura()
    if not blocks or not blocks.groups or not blocks.groups.auras then return end
    for unit, data in pairs(group) do
        for i, spellIds in pairs(blocks.groups.auras) do
            local index = blocks.groups.start + (data.index - 1) * blocks.groups.num + i
            local maxAura = getMaxAuraByTable(unit, spellIds)
            if maxAura and maxAura.auraInstanceID then
                local duration = C_UnitAuras.GetAuraDuration(unit, maxAura.auraInstanceID)
                if maxAura.expirationTime == 0 then
                    self:CreatTexture(index, 1)
                elseif duration then
                    local auraduration = duration:EvaluateRemainingDuration(curve255)
                    ---@diagnostic disable-next-line: param-type-mismatch
                    local _, _, b = auraduration:GetRGB()
                    self:CreatTexture(index, b)
                else
                    self:CreatTexture(index, 0)
                end
            else
                self:CreatTexture(index, 0)
            end
        end
        if blocks.groups.rejuv then
            local index = blocks.groups.start + (data.index - 1) * blocks.groups.num + blocks.groups.rejuv
            local rejuvCount = getRejuvCount(unit)
            self:CreatTexture(index, rejuvCount / 255)
        end
    end
end

local function getAuraDispelTypeColor(unit)
    local obj = group[unit]
    if not blocks.groups or not obj then return end
    local index = blocks.groups.start + (obj.index - 1) * blocks.groups.num + blocks.groups.dispel
    local auraInstanceIDs = C_UnitAuras.GetUnitAuraInstanceIDs(unit, "HARMFUL|RAID_PLAYER_DISPELLABLE", 1, 4)
    if auraInstanceIDs and #auraInstanceIDs > 0 then
        local color = C_UnitAuras.GetAuraDispelTypeColor(unit, auraInstanceIDs[1], dispelCurve)
        if color then
            Fuyutsui:CreatTexture(index, color.b)
        end
    else
        Fuyutsui:CreatTexture(index, 0)
    end
end

function Fuyutsui:clearGroupBlocks()
    if blocks.groups and blocks.groups.start then
        local startIndex = blocks.groups.start
        for index = startIndex, 255 do
            self:CreatTexture(index, 0)
        end
    end
end

function Fuyutsui:updateGroup()
    self.group = {}
    self.groupList = {}
    local i = 1
    for unit in self:IterateGroupMembers() do
        table.insert(groupList, unit)
        local role = UnitGroupRolesAssigned(unit)
        if unit == "player" then
            role = self.state.specRole
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
        self:updateUnitValid(unit)
        self:updateUnitHealthInfo(unit)
        self:updateUnitFullAura(unit)
        i = i + 1
    end
end

-- ================================================================
--                          事件
-- ================================================================

function Fuyutsui:ZONE_CHANGED()
    state.mapID = C_Map.GetBestMapForUnit("player") or 0
    state.mapInfo = C_Map.GetMapInfo(state.mapID)
    state.subzone = GetSubZoneText()
    -- print("ZONE_CHANGED", state.mapID, state.mapInfo, state.subzone)
    if GetBindLocation() == state.subzone then
        self:Print("欢迎回家!")
    end
end

function Fuyutsui:ZONE_CHANGED_INDOORS()
    state.mapID = C_Map.GetBestMapForUnit("player") or 0
    state.mapInfo = C_Map.GetMapInfo(state.mapID)
    state.subzone = GetSubZoneText()
    -- print("ZONE_CHANGED_INDOORS", state.mapID, state.mapInfo, state.subzone)
    if GetBindLocation() == state.subzone then
        self:Print("欢迎回家!")
    end
end

function Fuyutsui:PLAYER_ENTERING_WORLD()
    state.mapID = C_Map.GetBestMapForUnit("player") or 0
    self:updateHeroTalent()
end

function Fuyutsui:PLAYER_TALENT_UPDATE()
    self:updatePlayerSpecInfo()
    self:updateGroup()
end

function Fuyutsui:PLAYER_DEAD()
    self.state.isDead = UnitIsDeadOrGhost("player")
    self:updatePlayerValid()
end

function Fuyutsui:PLAYER_ALIVE()
    state.isDead = UnitIsDeadOrGhost("player")
    self:updatePlayerValid()
end

function Fuyutsui:PLAYER_UNGHOST()
    state.isDead = UnitIsDeadOrGhost("player")
    self:updatePlayerValid()
end

function Fuyutsui:PLAYER_MOUNT_DISPLAY_CHANGED()
    self:updatePlayerMounted()
end

-- 战斗状态更新
function Fuyutsui:PLAYER_REGEN_DISABLED()
    self:updateTargetType()
    self:updatePlayerCombat()
end

function Fuyutsui:PLAYER_REGEN_ENABLED()
    self:updateTargetType()
    self:updatePlayerCombat()
end

-- 移动状态更新
function Fuyutsui:PLAYER_STARTED_MOVING()
    self:updatePlayerMoving(true)
end

function Fuyutsui:PLAYER_STOPPED_MOVING()
    self:updatePlayerMoving(false)
end

function Fuyutsui:UNIT_SPELLCAST_SENT(_, unitTarget, targetName, castGUID, spellID)
    if unitTarget ~= "player" then return end
    if not isSec(targetName) then
        for unit, data in pairs(group) do
            if data.name == targetName then
                state.castTargetUnit = unit
                state.castTargetName = targetName
                state.castTargetIndex = data.index / 255
                break
            end
        end
        -- print(state.castTargetUnit, state.castTargetName, state.castTargetIndex)
    end
end

-- 施法状态
function Fuyutsui:UNIT_SPELLCAST_START(_, unitTarget, castGUID, spellID, castBarID)
    if unitTarget == "player" then
        state.casting = true
        updateUnitIncomingHealsCurve(spellID)
        self:updatePlayerCasting(spellID)
    end
    if unitTarget == "target" then
        target.casting = true
    end
end

function Fuyutsui:UNIT_SPELLCAST_STOP(_, unitTarget, castGUID, spellID, castBarID)
    if unitTarget == "player" then
        -- print("结束施法时间:", GetTime())
        updateUnitIncomingHealsCurve2()
        state.casting = false
        state.castTargetUnit = nil
        state.castTargetName = nil
        state.castTargetIndex = 0
        self:updatePlayerCasting(0)
    elseif unitTarget == "target" then
        target.casting = false
    end
end

-- 引导状态
function Fuyutsui:UNIT_SPELLCAST_CHANNEL_START(_, unitTarget, castGUID, spellID, castBarID)
    if unitTarget == "player" then
        state.channeling = true
        state.channelingSpellID = spellID
        self:updatePlayerCasting(spellID)
    elseif unitTarget == "target" then
        target.channeling = true
    end
end

function Fuyutsui:UNIT_SPELLCAST_CHANNEL_STOP(_, unitTarget, castGUID, spellID, castBarID)
    if unitTarget == "player" then
        state.channeling = false
        state.castTargetUnit = nil
        state.castTargetName = nil
        state.castTargetIndex = 0
        self:updatePlayerCasting(0)
    elseif unitTarget == "target" then
        target.channeling = false
    end
end

-- 蓄力状态
function Fuyutsui:UNIT_SPELLCAST_EMPOWER_START(_, unitTarget, castGUID, spellID, castBarID)
    if unitTarget == "player" then
        state.empowering = true
        state.empoweringSpellID = spellID
        self:updatePlayerCasting(spellID)
    elseif unitTarget == "target" then
        target.empowering = true
    end
end

function Fuyutsui:UNIT_SPELLCAST_EMPOWER_STOP(_, unitTarget, castGUID, spellID, complete, interruptedBy, castBarID)
    if unitTarget ~= "player" then
        state.empowering = false
        state.castTargetUnit = nil
        state.castTargetName = nil
        state.castTargetIndex = 0
        self:updatePlayerCasting(0)
    elseif unitTarget == "target" then
        target.empowering = false
    end
end

function Fuyutsui:UNIT_SPELLCAST_SUCCEEDED(_, unitTarget, castGUID, spellID, castBarID)
    if unitTarget ~= "player" or isSec(spellID) then return end
    self:updateDrinkStatus(spellID)
    -- printSuccSpell(spellID)
    self:updateFailedSpellBySuccess(spellID)
    self:updateAuraBySuccess(spellID, castBarID)
    if spellID == 384255 then
        self:ClearAllFuyutsuiBars()
        print("切换天赋")
        C_Timer.After(1, function()
            self:updatePlayerSpecInfo()
        end)
    elseif spellID == 200749 then
        self:ClearAllFuyutsuiBars()
        print("切换专精")
        C_Timer.After(1, function()
            self:updatePlayerSpecInfo()
        end)
    end
end

function Fuyutsui:UNIT_SPELLCAST_FAILED(_, unitTarget, castGUID, spellID, castBarID)
    if unitTarget ~= "player" then return end
    if not isSec(spellID) then
        self:updateSpellFailed(spellID)
    end
end

function Fuyutsui:SPELL_UPDATE_COOLDOWN(_, spellID)
    -- self:Print(spellID, C_Spell.GetSpellName(spellID))
    if issecretvalue(spellID) then return end
    self:updateAuraBySpellCooldown(spellID)
end

function Fuyutsui:SPELL_UPDATE_ICON(_, spellID)
    if issecretvalue(spellID) then return end
    self:updateAuraByIcon(spellID)
end

function Fuyutsui:COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED(_, baseSpellID, overrideSpellID)
    self:updateAuraBySpellOverride(baseSpellID, overrideSpellID)
end

function Fuyutsui:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(_, spellId)
    self:updateAuraByOverlayGlow(spellId)
end

function Fuyutsui:SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(_, spellId)
    self:updateAuraByOverlayGlow(spellId)
end

function Fuyutsui:SPELL_ACTIVATION_OVERLAY_SHOW(_, spellId)
    self:updateAuraByActivationOverlayShow(spellId)
end

function Fuyutsui:SPELL_ACTIVATION_OVERLAY_HIDE(_, spellId)
    self:updateAuraByActivationOverlayHide(spellId)
end

local potions = {
    [241304] = "银月城生命药水",
    [241305] = "银月城生命药水",
    [241301] = "光注法力药水",
    [241300] = "光注法力药水",
    [5512] = "治疗石",
    [224464] = "恶魔治疗石",
    [241288] = "鲁莽药水",
    [241289] = "鲁莽药水",
    [241308] = "圣光潜力",
    [241309] = "圣光潜力",
}

function Fuyutsui:ITEM_COUNT_CHANGED(_, itemID)
    if potions[itemID] then
        self:GetItemCount()
    end
end

function Fuyutsui:UNIT_HEALTH(_, unit)
    if unit == "player" then
        self:updatePlayerHealth()
        self:updatePlayerStagger()
    end
    if unit == "target" then
        self:updateTargetHealth()
    end
    if group[unit] then
        updateUnitDeathByHealthInfo(unit)
    end
end

function Fuyutsui:UNIT_MAXHEALTH(_, unit)
    if unit == "player" then
        self:updatePlayerHealth()
    end
    if group[unit] then
        updateUnitDeathByHealthInfo(unit)
    end
end

function Fuyutsui:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(_, unit)
    if unit == "player" then
        self:updatePlayerHealth()
    end
    if group[unit] then
        updateUnitHealAbsorbCurve(unit)
        updateUnitDeathByHealthInfo(unit)
    end
end

function Fuyutsui:UNIT_HEAL_PREDICTION(_, unit)
    if unit == "player" then
        self:updatePlayerHealth()
    end
    if group[unit] then
        updateUnitDeathByHealthInfo(unit)
    end
end

-- 能量更新
function Fuyutsui:UNIT_POWER_UPDATE(_, unit, powerType)
    if unit ~= "player" then return end
    self:updatePlayerPower(powerType)
end

-- Hook 所有默认聊天框
function Fuyutsui:hookChatFrameEditBox()
    for i = 1, NUM_CHAT_WINDOWS do
        local editBox = _G["ChatFrame" .. i .. "EditBox"]
        if editBox then
            editBox:HookScript("OnEditFocusGained", function()
                state.isChatOpen = true
                self:updatePlayerValid()
            end)
            editBox:HookScript("OnEditFocusLost", function()
                state.isChatOpen = false
                self:updatePlayerValid()
            end)
        end
    end
end

function Fuyutsui:SPELL_UPDATE_USES(_, spellID, baseSpellID)

end

local rosterTimer
function Fuyutsui:GROUP_ROSTER_UPDATE()
    state.castTargetName, state.castTargetUnit = nil, nil
    if rosterTimer then
        rosterTimer:Cancel()
    end
    rosterTimer = C_Timer.NewTimer(1, function()
        self:updateGroup()
        self:updateGroupCount()
        self:updateGroupType()
        rosterTimer = nil
    end)
end

function Fuyutsui:UNIT_DIED(_, unitGUID)
    if not isSec(unitGUID) then
        updateUnitDeath(unitGUID)
    end
end

function Fuyutsui:SPELL_RANGE_CHECK_UPDATE()
    -- updateNameplateCount()
end

function Fuyutsui:ACTION_RANGE_CHECK_UPDATE(_, slot, isInRange, checksRange)
    -- updateNameplateCount()
end

function Fuyutsui:UI_ERROR_MESSAGE(_, errorType, message)
    -- print(errorType, message)
    if message == "目标不在视野中" then
        updateUnitInSight(state.castTargetUnit)
    elseif message == "射程范围内无有效目标。" then
        self:updateDiseaseJudge()
    end
end

function Fuyutsui:UPDATE_BINDINGS()
    self:readKeybindings()
end

function Fuyutsui:SPELLS_CHANGED()
    self:readKeybindings()
end

function Fuyutsui:ACTIONBAR_SHOWGRID()
    self:readKeybindings()
end

function Fuyutsui:ACTIONBAR_HIDEGRID()
    self:readKeybindings()
end

function Fuyutsui:PLAYER_TARGET_CHANGED()
    self:updateTargetFullInfo()
end

function Fuyutsui:NAME_PLATE_UNIT_ADDED(_, unit)
    addNameplate(unit)
    self:updateTargetType()
end

function Fuyutsui:NAME_PLATE_UNIT_REMOVED(_, unit)
    nameplate[unit] = nil
    self:updateTargetType()
end

function Fuyutsui:UPDATE_SHAPESHIFT_FORM()
    self:updateShapeshiftForm()
    self:updatePlayerMounted()
end

function Fuyutsui:UPDATE_SHAPESHIFT_FORMS()
    self:updateShapeshiftForm()
    self:updatePlayerMounted()
end

function Fuyutsui:ENCOUNTER_START(_, encounterID, encounterName, difficultyID, groupSize)
    self:updateEncounterID(encounterID, difficultyID)
end

function Fuyutsui:ENCOUNTER_END(_, encounterID, encounterName, difficultyID, groupSize, success)
    self:updateEncounterID(0, 0)
end

function Fuyutsui:TestFiltered(unit, auraInstanceID)
    local AuraFilters = {
        "HELPFUL",
        "HELPFUL HARMFUL",
        "HELPFUL PLAYER",
        "HELPFUL RAID",
        "HELPFUL CANCELABLE",
        "HELPFUL NOT_CANCELABLE",
        "HELPFUL INCLUDE_NAME_PLATE_ONLY",
        "HELPFUL MAW",
        "HELPFUL EXTERNAL_DEFENSIVE",
        "HELPFUL CROWD_CONTROL",
        "HELPFUL RAID_IN_COMBAT",
        "HELPFUL RAID_PLAYER_DISPELLABLE",
        "HELPFUL BIG_DEFENSIVE",
        "HELPFUL IMPORTANT",
    }
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
    if aura then
        for _, filter in pairs(AuraFilters) do
            local isFiltered = C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, auraInstanceID, filter)
            local boolColored
            if isFiltered then
                boolColored = "|cffff0000" .. tostring(false) .. "|r"
            else
                boolColored = "|cff00ff00" .. tostring(true) .. "|r"
            end
            print(auraInstanceID, aura.name, filter, boolColored)
        end
    end
end

function Fuyutsui:UNIT_AURA(_, unit, info)
    self:GetDefensiveAuraInstanceID(unit, info)
    local obj = group[unit]
    if not obj then return end
    getAuraDispelTypeColor(unit)
    if info.isFullUpdate then
        self:updateUnitFullAura(unit)
        return
    end
    if info.addedAuras then
        for k, v in pairs(info.addedAuras) do
            -- print("|cnGREEN_FONT_COLOR:新增光环: |r", v.auraInstanceID, v.spellId, v.name, v.duration)
            if not isSec(v.spellId) and v.sourceUnit == "player" then
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

function Fuyutsui:ENCOUNTER_TIMELINE_EVENT_ADDED(_, eventInfo)

end

function Fuyutsui:ENCOUNTER_TIMELINE_EVENT_REMOVED(_, eventID)
end

function Fuyutsui:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(_, eventID)
end

function Fuyutsui:StartFrameUpdates()
    if not self.updateFrame then
        self.updateFrame = CreateFrame("Frame")
    end
    local parent = self
    self.updateFrame:SetScript("OnUpdate", function(frame, elapsed)
        parent:OnUpdate(elapsed)
    end)
end

Fuyutsui.timeElapsed = 0
function Fuyutsui:OnUpdate(elapsed)
    -- 1. 高频逻辑（每帧执行）
    -- 这里的函数必须确保能被访问到，如果是成员函数请加 self:
    self:updatePlayerCastingInfo()
    self:updatePlayerChannelingInfo()
    self:updatePlayerEmpowerInfo()
    self:updateTargetCastingInfo()
    self:updateTargetChannelInfo()
    self:updateGroupInRangeAndHealth()
    self:updateAura()

    -- 2. 低频逻辑（每 0.2 秒执行）
    self.timeElapsed = self.timeElapsed + elapsed
    if self.timeElapsed > 0.2 then
        self:GetDefensiveAuraDuration()
        self:updateSpellCooldown()
        self:OnUpdateUnitAura()
        self:updateAuraBlocks()
        self:updatePlayerAssistant()
        self:updateRune()
        self:updateTargetRangeBlock()
        self:updateEnemyCount()
        self:updateItemCoolDown()
        self.timeElapsed = 0
    end
end
