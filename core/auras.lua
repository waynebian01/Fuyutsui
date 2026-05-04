local addon, fu = ...
local classId, e = fu.classId, fu.e
local addAuras, updateAuras, removeAuras = {}, {}, {} -- 添加、更新、移除光环
local creat = fu.updateOrCreatTextureByIndex

-- 光环列表
local auras = {
    -- 战士
    [1] = {
        ["盾牌格挡"] = {
            remaining = 0,
            duration = 8,
            expirationTime = nil,
            addAuras = {
                [132404] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
    },
    -- 圣骑士
    [2] = {
        ["神圣意志"] = {
            remaining = 0,
            duration = 12,
            expirationTime = nil,
            addAuras = {
                [223819] = { event = e["法术冷却"] },
                [408458] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [223819] = { event = e["屏幕提示隐藏"] },
                [408458] = { event = e["屏幕提示隐藏"] },
            },
        },
        ["圣光灌注"] = {
            remaining = 0,
            duration = 15,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [54149] = { event = e["法术冷却"], step = 2 },
            },
            updateAuras = {
                [19750] = { event = e["施法成功"], step = -1 }, -- 圣光闪现
                [275773] = { event = e["施法成功"], step = -1 }, -- 审判
            },
            removeAuras = {
                [54149] = { event = e["屏幕提示隐藏"] },
            },
        },
        ["神性之手"] = {
            remaining = 0,
            duration = 15,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [414273] = { event = e["法术冷却"], step = 2 },
            },
            updateAuras = {
                [82326] = { event = e["施法成功"], step = -1 }, -- 圣光术
            },
            removeAuras = nil,
        },
        ["神圣壁垒"] = {
            remaining = 0,
            duration = 20,
            expirationTime = nil,
            addAuras = {
                [432496] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["圣洁武器"] = {
            remaining = 0,
            duration = 20,
            expirationTime = nil,
            addAuras = {
                [432502] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["闪耀之光"] = {
            remaining = 0,
            duration = 30,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [327510] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = {
                [85673] = { event = e["施法成功"], step = -1 }, -- 荣耀圣令
            },
            removeAuras = nil,
        },
        ["奉献"] = {
            remaining = 0,
            duration = 12,
            expirationTime = nil,
            addAuras = {
                [188370] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["复仇之怒"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [188370] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["处决宣判"] = {
            remaining = 0,
            duration = 10,
            expirationTime = nil,
            addAuras = {
                [343527] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["圣光之锤"] = {
            remaining = 0,
            duration = 20,
            expirationTime = nil,
            addAuras = {
                [1246643] = { event = e["法术冷却"] },
                [427441] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["神圣军备"] = {
            remaining = 0,
            duration = 0,
            expirationTime = nil,
            isIcon = 1,
            addAuras = {
                [432459] = {
                    event = e["图标改变"],
                    overrideSpellID = 432472,
                },
            },
            updateAuras = nil,
            removeAuras = {
                [432459] = {
                    event = e["图标改变"],
                    overrideSpellID = 432472,
                },
            },
        },
    },
    -- 猎人
    [3] = {

    },
    -- 盗贼
    [4] = {

    },
    -- 牧师
    [5] = {
        ["虚空之盾"] = {
            remaining = 0,
            duration = 60,
            expirationTime = nil,
            addAuras = {
                [1253591] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [1253593] = { event = e["施法成功"] }
            },
        },
        ["圣光涌动"] = {
            remaining = 0,
            duration = 20,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [114255] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = {
                [2061] = { event = e["施法成功"], step = -1 }, -- 快速治疗
                [596] = { event = e["施法成功"], step = -1 }, -- 治疗祷言
                [186263] = { event = e["施法成功"], step = -1 }, -- 暗影愈合
            },
            removeAuras = nil,
        },
        ["熵能裂隙"] = {
            remaining = 0,
            duration = 12,
            expirationTime = nil,
            addAuras = {
                [585] = {
                    event = e["图标改变"],
                    overrideSpellID = 450215
                },
            },
            updateAuras = nil,
            removeAuras = {
                [585] = {
                    event = e["图标改变"],
                    overrideSpellID = 450215
                },
            },
        },
        ["暗影愈合"] = {
            remaining = 0,
            duration = 15,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [1252217] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = {
                [186263] = { event = e["施法成功"], step = -1 },
            },
            removeAuras = nil,
        },
        ["福音"] = {
            remaining = 0,
            duration = 120,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [472433] = { event = e["法术冷却"], step = 2 },
            },
            updateAuras = {
                [194509] = { event = e["施法成功"], step = -1 }, -- 真言术：耀
            },
            removeAuras = nil,
        },
        ["织光者"] = {
            remaining = 0,
            duration = 20,
            count = 0,
            countMin = 0,
            countMax = 4,
            expirationTime = nil,
            addAuras = {
                [390993] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = {
                [596] = { event = e["施法成功"], step = -1 }
            },
            removeAuras = nil,
        },
        ["祈福"] = {
            remaining = 0,
            duration = 32,
            expirationTime = nil,
            addAuras = {
                [1262766] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [2061] = {
                    event = e["图标改变"],
                    overrideSpellID = 1262763
                },
            },
        },
    },
    -- 死亡骑士
    [6] = {
        ["脓疮毒镰"] = {
            name = "脓疮毒镰",
            spellId = 458123,
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [458123] = { event = e["法术冷却"] }
            },
            updateAuras = nil,
            removeAuras = {
                [458128] = { event = e["施法成功"] },
            },
        },
        ["脓疮毒镰2"] = {
            name = "脓疮毒镰",
            spellId = 1241077,
            remaining = 0,
            duration = 25,
            expirationTime = nil,
            addAuras = {
                [1241077] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["割魂索命"] = {
            name = "割魂索命",
            spellId = 1242654,
            remaining = 0,
            duration = 30,
            expirationTime = nil,
            addAuras = {
                [1242654] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [343294] = { event = e["施法成功"] },
            },
        },
        ["次级食尸鬼"] = {
            remaining = 0,
            duration = 30,
            expirationTime = nil,
            addAuras = {
                [1254252] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["末日突降"] = {
            remaining = 0,
            duration = 10,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [81340] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = {
                [47541] = { event = e["施法成功"], step = -1 }, -- 凋零缠绕
                [207317] = { event = e["施法成功"], step = -1 }, -- 扩散
            },
            removeAuras = nil,
        },
        ["黑暗援助"] = {
            remaining = 0,
            duration = 20,
            expirationTime = nil,
            addAuras = {
                [101568] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [49998] = { event = e["施法成功"] }, -- 灵界打击
            },
        },
        ["禁断知识"] = {
            remaining = 0,
            duration = 30,
            expirationTime = nil,
            addAuras = {
                [1242223] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["枯萎凋零"] = {
            remaining = 0,
            duration = 10,
            expirationTime = nil,
            addAuras = {
                [43265] = { event = e["施法成功"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
    },
    -- 萨满祭司
    [7] = {
        ["飞旋之土"] = {
            name = "飞旋之土",
            spellId = 453406,
            remaining = 0,
            duration = 25,
            expirationTime = nil,
            addAuras = {
                [453406] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [1064] = { event = e["施法成功"] },
            },
        },
        ["潮汐奔涌"] = {
            remaining = 0,
            duration = 15,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [53390] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = nil,
            removeAuras = {
                [77472] = { event = e["施法成功"], step = -1, castBar = true },
            },
        },
        ["风暴涌流图腾"] = {
            remaining = 0,
            duration = 60,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [1267089] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = {
                [1267068] = { event = e["施法成功"], step = -1 },
            },
            removeAuras = {
                [5394] = {
                    event = e["图标改变"],
                    overrideSpellID = 1267068
                },
            },
        },
        ["生命释放"] = {
            name = "生命释放",
            spellId = 73685,
            remaining = 0,
            duration = 10,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [73685] = { event = e["法术冷却"], step = 2 },
            },
            updateAuras = {
                [61295] = { event = e["施法成功"], step = -1 }, -- 激流
                [77472] = { event = e["施法成功"], step = -1 }, -- 治疗波
                [1064] = { event = e["施法成功"], step = -1 }, -- 治疗链
            },
            removeAuras = nil,
        },
        ["升腾"] = {
            name = "升腾",
            spellId = 114052,
            remaining = 0,
            duration = 6,
            expirationTime = nil,
            addAuras = {
                [114052] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
    },
    -- 法师
    [8] = {
        ["热能真空"] = {
            remaining = 0,
            duration = 12,
            expirationTime = nil,
            addAuras = {
                [1247730] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [30455] = { event = e["施法成功"] },
            },
        },
        ["冰冷智慧"] = {
            remaining = 0,
            duration = 20,
            expirationTime = nil,
            addAuras = {
                [190446] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [44614] = { event = e["施法成功"] }, -- 冰风暴
            },
        },
        ["冰冻之雨"] = {
            remaining = 0,
            duration = 12,
            expirationTime = nil,
            addAuras = {
                [270232] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["寒冰指"] = {
            remaining = 0,
            duration = 30,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [44544] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = {
                [30455] = { event = e["施法成功"], step = -1 }, -- 冰枪术
            },
            removeAuras = nil,
        },
        ["冰川尖刺！"] = {
            remaining = 0,
            duration = 0,
            expirationTime = nil,
            isIcon = 1,
            addAuras = {
                [116] = { -- 寒冰箭
                    event = e["图标改变"],
                    overrideSpellID = 199786,
                },
            },
            updateAuras = nil,
            removeAuras = {
                [116] = { -- 寒冰箭
                    event = e["图标改变"],
                    overrideSpellID = 199786,
                },
            },
        },
    },
    -- 术士
    [9] = {
        ["魔典：邪能破坏者"] = {
            remaining = 0,
            duration = 0,
            expirationTime = nil,
            isIcon = 1,
            addAuras = {
                [1276467] = {
                    event = e["图标改变"],
                    overrideSpellID = 388215,
                },
            },
            updateAuras = nil,
            removeAuras = {
                [1276467] = {
                    event = e["图标改变"],
                    overrideSpellID = 388215,
                },
            },
        },
    },
    -- 武僧
    [10] = {
        ["疗伤珠"] = {
            remaining = 0,
            duration = 30,
            expirationTime = nil,
            addAuras = {
                [224863] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [322101] = { event = e["施法成功"] },
            },
        },
        ["活力苏醒"] = {
            remaining = 0,
            duration = 20,
            expirationTime = nil,
            addAuras = {
                [392883] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [116670] = { event = e["施法成功"] },
            },
        },
        ["清空地窖"] = {
            remaining = 0,
            duration = 20,
            expirationTime = nil,
            addAuras = {
                [1262768] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [1263438] = { event = e["施法成功"] },
            },
        },
        ["生生不息1"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [197919] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [124682] = { event = e["施法成功"] }, -- 氤氲之雾
                [107428] = { event = e["施法成功"] }, -- 旭日东升踢
            },
        },
        ["生生不息2"] = {
            name = "生生不息",
            spellId = 197916,
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [197916] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [399491] = { event = e["施法成功"] }, -- 神龙之赐
                [116670] = { event = e["施法成功"] }, -- 活血术
            },
        },
        ["神龙之赐"] = {
            remaining = 0,
            duration = 60,
            count = 0,
            countMin = 0,
            countMax = 10,
            expirationTime = nil,
            addAuras = {
                [399496] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = nil,
            removeAuras = {
                [399491] = { event = e["施法成功"], },
            },
        },
        ["灵泉"] = {
            remaining = 0,
            duration = 30,
            expirationTime = nil,
            addAuras = {
                [1260565] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["玄牛之力"] = {
            remaining = 0,
            duration = 30,
            expirationTime = nil,
            addAuras = {
                [443112] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [124682] = { event = e["施法成功"] }, -- 氤氲之雾
            },
        },
        ["青龙之心"] = {
            remaining = 0,
            duration = 4,
            expirationTime = nil,
            addAuras = {
                [443421] = { event = e["法术冷却"], duration = 4, },
                [116680] = { event = e["施法成功"], duration = 8 }, -- 氤氲之雾
            },
            updateAuras = nil,
            removeAuras = nil,
        },
    },
    -- 德鲁伊
    [11] = {
        ["塞纳留斯的梦境"] = {
            remaining = 0,
            duration = 10,
            count = 0,
            countMin = 0,
            countMax = 4,
            expirationTime = nil,
            addAuras = {
                [372152] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = {
                [8936] = { event = e["施法成功"], step = -1 }, -- 愈合
                [22842] = { event = e["施法成功"], step = -1 }, -- 狂暴回复
            },
            removeAuras = {
                [8936] = { event = e["图标发光隐藏"] }, -- 愈合
            },
        },
        ["铁鬃"] = {
            remaining = 0,
            duration = 7,
            expirationTime = nil,
            addAuras = {
                [192081] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["狂暴回复"] = {
            remaining = 0,
            duration = 4,
            expirationTime = nil,
            addAuras = {
                [22842] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["节能施法"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [16870] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [8936] = { event = e["施法成功"] }, -- 愈合
            },
        },
        ["丛林之魂"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [114108] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [8936] = { event = e["施法成功"] }, -- 愈合
                [774] = { event = e["施法成功"] }, -- 回春术
            },
        },
    },
    -- 恶魔猎手
    [12] = {

    },
    -- 唤魔师
    [13] = {

    },
}

fu.Auras = {}
do
    fu.Auras = auras[classId] or {}
    local function indexAura(target, auraName, auraData)
        for spellId, info in pairs(auraData) do
            local ev = info.event
            local byEvent = target[ev]
            if not byEvent then
                byEvent = {}
                target[ev] = byEvent
            end
            local bySpell = byEvent[spellId]
            if not bySpell then
                bySpell = {}
                byEvent[spellId] = bySpell
            end
            bySpell[auraName] = info
        end
    end

    for name, data in pairs(fu.Auras) do
        if data.addAuras then
            indexAura(addAuras, name, data.addAuras)
        end
        if data.updateAuras then
            indexAura(updateAuras, name, data.updateAuras)
        end
        if data.removeAuras then
            indexAura(removeAuras, name, data.removeAuras)
        end
    end
end

---@param auraMap table<string, table>|nil 光环名 -> info
---@param castBarID any|nil 施法成功时传入读条 ID；冷却类调用传 nil，不按读条过滤
local function applyAuraMapForSpellEvent(auraMap, castBarID)
    if not auraMap then
        return
    end
    local now = GetTime()
    for auraName, info in pairs(auraMap) do
        local aura = fu.Auras[auraName]
        if aura and ((not info.castBar) or castBarID) then
            if aura.duration then
                aura.expirationTime = now + aura.duration
            end
            if aura.count and info.step then
                if info.step > 0 then
                    aura.expirationTime = now + aura.duration
                    aura.count = math.min(aura.countMax, aura.count + info.step)
                else
                    aura.count = math.max(aura.countMin, aura.count + info.step)
                end
            end
        end
    end
end

---@param auraMap table<string, table>|nil 光环名 -> info
---@param castBarID any|nil 施法成功时传入读条 ID；冷却类调用传 nil，不按读条过滤
local function updateAuraMapForSpellEvent(auraMap, castBarID)
    if not auraMap then
        return
    end
    local now = GetTime()
    for auraName, info in pairs(auraMap) do
        local aura = fu.Auras[auraName]
        if aura and ((not info.castBar) or castBarID) then
            if aura.count and info.step then
                if info.step > 0 then
                    aura.expirationTime = now + aura.duration
                    aura.count = math.min(aura.countMax, aura.count + info.step)
                else
                    aura.count = math.max(aura.countMin, aura.count + info.step)
                end
            elseif aura.duration then
                aura.expirationTime = now + aura.duration
            end
        end
    end
end

---@param removeMap table<string, table>|nil 光环名 -> info
---@param resetCount boolean|nil 为 true 时重置层数（冷却/施法成功移除）；屏幕提示类仅清时间传 false
local function clearAurasFromRemoveMap(removeMap, resetCount)
    if not removeMap then
        return
    end
    for auraName in pairs(removeMap) do
        local aura = fu.Auras[auraName]
        if aura then
            if resetCount and aura.count then
                aura.count = aura.countMin
            end
            aura.expirationTime = nil
        end
    end
end

---@param spellID number 法术 ID（冷却事件键）
-- 通过 SPELL_UPDATE_COOLDOWN 同步光环结束时间与层数
local function updateAuraBySpellCooldown(spellID)
    local ev = e["法术冷却"]
    local addBySpell = addAuras[ev]
    local updateBySpell = updateAuras[ev]
    local removeBySpell = removeAuras[ev]
    applyAuraMapForSpellEvent(addBySpell and addBySpell[spellID], nil)
    updateAuraMapForSpellEvent(updateBySpell and updateBySpell[spellID], nil)
    clearAurasFromRemoveMap(removeBySpell and removeBySpell[spellID], true)
end

---@param spellID number 法术ID
---@param castBarID number 施法条ID
-- 通过事件"UNIT_SPELLCAST_SUCCEEDED"更新光环, 并更新光环的层数
local function updateAuraBySuccess(spellID, castBarID)
    local ev = e["施法成功"]
    local addBySpell = addAuras[ev]
    local updateBySpell = updateAuras[ev]
    local removeBySpell = removeAuras[ev]
    applyAuraMapForSpellEvent(addBySpell and addBySpell[spellID], castBarID)
    updateAuraMapForSpellEvent(updateBySpell and updateBySpell[spellID], castBarID)
    clearAurasFromRemoveMap(removeBySpell and removeBySpell[spellID], true)
end

local function updateAuraByIconMap(map, spellID)
    if not map then
        return
    end
    local hasOverride = false
    local overrideSpellID = C_Spell.GetOverrideSpell(spellID)
    for auraName, info in pairs(map) do
        local aura = fu.Auras[auraName]
        if overrideSpellID and info.overrideSpellID and overrideSpellID == info.overrideSpellID then
            hasOverride = true
        end
        if aura.isIcon then
            if hasOverride then
                aura.isIcon = 2
            else
                aura.isIcon = 1
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
end

---@param spellID number 法术ID
-- 通过事件"SPELL_UPDATE_ICON"更新光环, 并更新光环的层数
local function updateAuraByIcon(spellID)
    local ev = e["图标改变"]
    local addBySpell = addAuras[ev]
    local updateBySpell = updateAuras[ev]
    local removeBySpell = removeAuras[ev]
    if addBySpell and addBySpell[spellID] then
        updateAuraByIconMap(addBySpell[spellID], spellID)
    end
    if updateBySpell and updateBySpell[spellID] then
        updateAuraByIconMap(updateBySpell[spellID], spellID)
    end
    if removeBySpell and removeBySpell[spellID] then
        updateAuraByIconMap(removeBySpell[spellID], spellID)
    end
end

local function updateAuraByOverrideMap(map, overrideSpellID)
    if not map then
        return
    end

    for auraName, info in pairs(map) do
        local aura = fu.Auras[auraName]
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

---@param baseSpellID number 基本法术ID
---@param overrideSpellID number 覆盖法术ID
-- 通过事件"COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED"更新光环, 并更新光环的结束时间
local function updateAuraBySpellOverride(baseSpellID, overrideSpellID)
    local ev = e["法术覆盖"]
    local addBySpell = addAuras[ev]
    local updateBySpell = updateAuras[ev]
    local removeBySpell = removeAuras[ev]
    if addBySpell and addBySpell[baseSpellID] then
        updateAuraByOverrideMap(addBySpell[baseSpellID], overrideSpellID)
    end
    if updateBySpell and updateBySpell[baseSpellID] then
        updateAuraByOverrideMap(updateBySpell[baseSpellID], overrideSpellID)
    end
    if removeBySpell and removeBySpell[baseSpellID] then
        updateAuraByOverrideMap(removeBySpell[baseSpellID], overrideSpellID)
    end
end

---@param spellId number 光环ID, 屏幕提示
-- 通过事件"SPELL_ACTIVATION_OVERLAY_HIDE"更新光环, 并更新光环的结束时间
local function updateAuraByActivationOverlayShow(spellId)
    local addBySpell = addAuras[e["屏幕提示显示"]]
    local updateBySpell = updateAuras[e["屏幕提示显示"]]
    applyAuraMapForSpellEvent(addBySpell and addBySpell[spellId], nil)
    updateAuraMapForSpellEvent(updateBySpell and updateBySpell[spellId], nil)
end

---@param spellId number 光环ID, 屏幕提示
-- 通过事件"SPELL_ACTIVATION_OVERLAY_HIDE"更新光环, 并更新光环的结束时间
local function updateAuraByActivationOverlayHide(spellId)
    local removeBySpell = removeAuras[e["屏幕提示隐藏"]]
    clearAurasFromRemoveMap(removeBySpell and removeBySpell[spellId], false)
end

-- SPELL_ACTIVATION_OVERLAY_GLOW_SHOW / HIDE：与 main.lua 一致，按是否仍发光刷新或清除时间
local function updateAuraByOverlayGlow(spellID)
    local ev = e["图标发光隐藏"]
    local removeBySpell = removeAuras[ev]
    local map = removeBySpell and removeBySpell[spellID]
    if not map then
        return
    end
    local now = GetTime()
    local isSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed(spellID)
    for auraName in pairs(map) do
        local aura = fu.Auras[auraName]
        if aura then
            if isSpellOverlayed and aura.duration then
                aura.expirationTime = now + aura.duration
            else
                aura.expirationTime = nil
            end
        end
    end
end

-- 通过每帧更新光环
local function updateAura()
    local currentTime = GetTime()
    for name, info in pairs(fu.Auras) do
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

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

for _, v in pairs(e) do
    frame:RegisterEvent(v)
end

function frame:SPELL_UPDATE_COOLDOWN(spellID)
    -- print(spellID, C_Spell.GetSpellName(spellID))
    updateAuraBySpellCooldown(spellID)
end

function frame:UNIT_SPELLCAST_SUCCEEDED(unit, castGUID, spellID, castBarID)
    updateAuraBySuccess(spellID, castBarID)
end

function frame:SPELL_UPDATE_ICON(spellId)
    updateAuraByIcon(spellId)
end

function frame:COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED(baseSpellID, overrideSpellID)
    updateAuraBySpellOverride(baseSpellID, overrideSpellID)
end

function frame:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(spellId)
    updateAuraByOverlayGlow(spellId)
end

function frame:SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(spellId)
    updateAuraByOverlayGlow(spellId)
end

function frame:SPELL_ACTIVATION_OVERLAY_SHOW(spellId)
    updateAuraByActivationOverlayShow(spellId)
end

function frame:SPELL_ACTIVATION_OVERLAY_HIDE(spellId)
    updateAuraByActivationOverlayHide(spellId)
end

local timeElapsed = 0
frame:SetScript("OnUpdate", function(_, elapsed)
    timeElapsed = timeElapsed + elapsed
    if timeElapsed > 0.2 then
        updateAura()
        updateAuraBlocks()
        timeElapsed = 0
    end
end)
