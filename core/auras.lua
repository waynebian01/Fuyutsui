local addon, fu = ...
local Fuyutsui =_G[addon]
local classId = fu.classId
local addAuras, updateAuras, removeAuras = {}, {}, {} -- 添加、更新、移除光环
Fuyutsui.Auras = {}
local e = {
    ["法术冷却"] = "SPELL_UPDATE_COOLDOWN", -- 冷却事件
    ["施法成功"] = "UNIT_SPELLCAST_SUCCEEDED", -- 成功事件
    ["图标改变"] = "SPELL_UPDATE_ICON", -- ICON事件
    ["法术覆盖"] = "COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED", -- 法术临时覆盖事件
    ["图标发光显示"] = "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW", -- 图标发光显示
    ["图标发光隐藏"] = "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE", -- 图标发光隐藏
    ["屏幕提示显示"] = "SPELL_ACTIVATION_OVERLAY_SHOW", -- 屏幕提示显示
    ["屏幕提示隐藏"] = "SPELL_ACTIVATION_OVERLAY_HIDE", -- 屏幕提示隐藏
}

-- 光环列表
local auras = {
    -- 战士
    [1] = {
        ["盾牌格挡"] = {
            remaining = 0,
            duration = 8,
            expirationTime = nil,
            addAuras = {
                [132404] = { event = e["冷却事件"] },
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
                [223819] = { event = e["冷却事件"] },
                [408458] = { event = e["冷却事件"] },
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
                [54149] = { event = e["冷却事件"], step = 2 },
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
                [414273] = { event = e["冷却事件"], step = 2 },
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
                [432496] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["圣洁武器"] = {
            remaining = 0,
            duration = 20,
            expirationTime = nil,
            addAuras = {
                [432502] = { event = e["冷却事件"] },
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
                [327510] = { event = e["冷却事件"], step = 1 },
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
                [188370] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["复仇之怒"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [188370] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["处决宣判"] = {
            remaining = 0,
            duration = 10,
            expirationTime = nil,
            addAuras = {
                [343527] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["圣光之锤"] = {
            remaining = 0,
            duration = 20,
            expirationTime = nil,
            addAuras = {
                [1246643] = { event = e["冷却事件"] },
                [427441] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
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
                [1253591] = { event = e["冷却事件"] },
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
                [114255] = { event = e["冷却事件"], step = 1 },
            },
            updateAuras = {
                [2061] = { event = e["施法成功"], step = -1 }, -- 快速治疗
                [596] = { event = e["施法成功"], step = -1 }, -- 治疗祷言
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
            removeAuras = { {
                [585] = {
                    event = e["图标改变"],
                    overrideSpellID = 450215
                },
            }, },
        },
        ["暗影愈合"] = {
            remaining = 0,
            duration = 15,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [1252217] = { event = e["冷却事件"], step = 1 },
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
                [472433] = { { event = e["冷却事件"], step = 2 } },
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
                [390993] = { event = e["冷却事件"], step = 1 },
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
                [1262766] = { event = e["冷却事件"] },
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
                [458123] = { event = e["冷却事件"] }
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
                [1241077] = { event = e["冷却事件"] },
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
                [1242654] = { event = e["冷却事件"] },
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
                [1254252] = { event = e["冷却事件"] },
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
                [81340] = { event = e["冷却事件"], step = 1 },
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
                [101568] = { event = e["冷却事件"] },
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
                [1242223] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["枯萎凋零"] = {
            remaining = 0,
            duration = 10,
            expirationTime = nil,
            addAuras = {
                [188290] = { event = e["冷却事件"] },
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
                [453406] = { event = e["冷却事件"] },
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
                [53390] = { event = e["冷却事件"], step = 1 },
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
                [1267089] = { event = e["冷却事件"], step = 1 },
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
                [73685] = { event = e["冷却事件"], step = 2 },
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
                [114052] = { event = e["冷却事件"] },
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
                [1247730] = { event = e["冷却事件"] },
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
                [190446] = { event = e["冷却事件"] },
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
                [270232] = { event = e["冷却事件"] },
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
                [44544] = { event = e["冷却事件"], step = 1 },
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
            addAuras = {
                [116] = { -- 寒冰箭
                    event = e["图标改变"],
                    overrideSpellID = 199786,
                    isIcon = 1,
                },
            },
            updateAuras = nil,
            removeAuras = {
                [116] = { -- 寒冰箭
                    event = e["图标改变"],
                    overrideSpellID = 199786,
                    isIcon = 1,
                },
            },
        },
    },
    -- 术士
    [9] = {
        ["魔典：邪能破坏者"] = {
            remaining = 0,
            duration = 120,
            expirationTime = nil,
            addAuras = {
                [132409] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["吞噬魔法"] = {
            remaining = 0,
            duration = 120,
            expirationTime = nil,
            addAuras = {
                [1276610] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
    },
    -- 武僧
    [10] = {
        ["疗伤珠"] = {
            remaining = 0,
            duration = 30,
            expirationTime = nil,
            addAuras = {
                [224863] = { event = e["冷却事件"] },
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
                [392883] = { event = e["冷却事件"] },
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
                [1262768] = { event = e["冷却事件"] },
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
                [197919] = { event = e["冷却事件"] },
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
                [197916] = { event = e["冷却事件"] },
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
                [399496] = { event = e["冷却事件"], step = 1 },
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
                [1260565] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["玄牛之力"] = {
            remaining = 0,
            duration = 30,
            expirationTime = nil,
            addAuras = {
                [443112] = { event = e["冷却事件"] },
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
                [443421] = { event = e["冷却事件"], duration = 4, },
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
                [372152] = { event = e["冷却事件"], step = 1 },
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
                [192081] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["狂暴回复"] = {
            remaining = 0,
            duration = 4,
            expirationTime = nil,
            addAuras = {
                [22842] = { event = e["冷却事件"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["节能施法"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [16870] = { event = e["冷却事件"] },
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
                [114108] = { event = e["冷却事件"] },
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

do
    Fuyutsui.Auras = auras[classId]
    for _, v in pairs(Fuyutsui.Auras) do
        if v.addAuras then
            for spellId, data in pairs(v.addAuras) do
                if not addAuras[data.event] then
                    addAuras[data.event] = {}
                end
                addAuras[data.event][spellId] = data
            end
        end
        if v.updateAuras then
            for spellId, data in pairs(v.updateAuras) do
                if not updateAuras[data.event] then
                    updateAuras[data.event] = {}
                end
                updateAuras[data.event][spellId] = data
            end
        end
        if v.removeAuras then
            for spellId, data in pairs(v.removeAuras) do
                if not removeAuras[data.event] then
                    removeAuras[data.event] = {}
                end
                removeAuras[data.event][spellId] = data
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

for _, v in pairs(e) do
    frame:RegisterEvent(v)
end

