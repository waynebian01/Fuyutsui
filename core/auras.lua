local addon, ns = ...
local classFilename, classId = UnitClassBase("player")
local e = Fuyutsui.e
local addAuras, updateAuras, removeAuras = {}, {}, {} -- 添加、更新、移除光环

--[[
    auras.lua — 逻辑光环状态机（按职业）
    如何在本文件里新增一条光环
    1. 在 `auras[职业ID]` 下增加键名（中文名），与职业 Lua 里 `Fuyutsui.blocks.auras` 引用的名称一致。
    2. 常用字段：
       - remaining / duration / expirationTime：倒计时；有 duration 时事件会刷新 expirationTime。
       - count, countMin, countMax：层数；配合映射表里的 step（正加负减）在「法术冷却」或「施法成功」等路径更新。
       - addAuras / updateAuras / removeAuras：三张「法术 ID -> { event = e["…"], … }」表；

       event 必须是`e` 的键之一:
       「法术冷却」
       「施法成功」
       「图标改变」
       「法术覆盖」
       「屏幕提示显示/隐藏」
       「图标发光隐藏」
       - 可选：step、castBar（施法成功时是否要求有读条）、overrideSpellID、单条上的 duration 覆盖、isIcon 等；
         若多条逻辑共用显示名可用 name + spellId 指向另一条（见文件中武僧等示例）。

]]

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
        ["斩杀高亮"] = {
            remaining = 0,
            duration = 15, -- 持续时间给长一点，触发后只要系统没发取消发光的事件，这15秒内终端都会读取到高亮状态
            expirationTime = nil,
            addAuras = nil,
            updateAuras = nil,
            removeAuras = {
                [5308]   = { event = e["图标发光隐藏"] }, -- 斩杀（基础/防战）
                [163201] = { event = e["图标发光隐藏"] }, -- 斩杀（武器）
                [281000] = { event = e["图标发光隐藏"] }, -- 斩杀（狂暴）
                [280735] = { event = e["图标发光隐藏"] }, -- 斩杀（屠杀天赋）
            },
        },
        ["英勇打击高亮"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = nil,
            updateAuras = nil,
            removeAuras = {
                [1269383] = { event = e["图标发光隐藏"] }, -- 英勇打击
            },
        },
        ["顺劈斩高亮"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = nil,
            updateAuras = nil,
            removeAuras = {
                [845] = { event = e["图标发光隐藏"] }, -- 顺劈斩(845)发光结束时取消
            },
        },
        ["致死高亮"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = nil,
            updateAuras = nil,
            removeAuras = {
                [12294] = { event = e["图标发光隐藏"] }, -- 致死打击发光结束时取消
            },
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
            duration = 24,
            expirationTime = nil,
            addAuras = {
                [31884] = { event = e["法术冷却"] },
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
            removeAuras = {
                [427453] = { event = e["施法成功"] }, -- 施放圣光之锤后清除buff
            },
        },
        ["神圣军备"] = {
            remaining = 0,
            duration = 0,
            expirationTime = nil,
            isIcon = 0,
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
        ["美德道标"] = {
            remaining = 0,
            duration = 9,
            expirationTime = nil,
            addAuras = {
                [200025] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
    },
    -- 猎人
    [3] = {
        ["自然之友"] = {
            remaining = 0,
            duration = 8,
            expirationTime = nil,
            addAuras = {
                [1276720] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [34026] = { event = e["施法成功"] }
            },
        },
        ["狂野怒火"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [19574] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
            },
        },
        ["猎人印记"] = {
            remaining = 0,
            duration = 255,
            expirationTime = nil,
            addAuras = {
                [257284] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
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
        ["祸福相依"] = {
            remaining = 0,
            duration = 20,
            count = 0,
            countMin = 0,
            countMax = 10,
            expirationTime = nil,
            addAuras = {
                [390787] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = nil,
            removeAuras = {
                [17] = { event = e["施法成功"] },
                [1253593] = { event = e["施法成功"] }
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

                [1242174] = { event = e["施法成功"], step = -1 }, -- 凋零缠绕
                [383269] = { event = e["施法成功"], step = -1 }, -- 扩散
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
                [444505] = { event = e["法术冷却"], duration = 14 }, -- 莫格莱尼的力量
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["亡者指挥官"] = {
            remaining = 0,
            duration = 30,
            expirationTime = nil,
            addAuras = {
                [390260] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["寒冰锁链"] = {
            remaining = 0,
            duration = 8,
            expirationTime = nil,
            addAuras = {
                [444826] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [55090] = { event = e["施法成功"] },
            },
        },
        ["暗影之爪"] = {
            remaining = 0,
            duration = 12,
            count = 0,
            countMin = 0,
            countMax = 4,
            expirationTime = nil,
            addAuras = {
                [1241569] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["凋萎"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [1271199] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [55090] = { event = e["施法成功"] },
            },
        },
        ["杀戮机器"] = {
            remaining = 0,
            duration = 10,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [51124] = { event = e["法术冷却"], step = 1 },
            },
            updateAuras = nil,
            removeAuras = {
                [207230] = { event = e["施法成功"] }, -- 冰霜之镰
                [49020] = { event = e["施法成功"] }, -- 湮灭
            },
        },
        ["白霜"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [59052] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [49184] = { event = e["施法成功"] }, -- 凛风冲击
            },
        },
        ["冰霜灾祸"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [1229310] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [1228433] = { event = e["施法成功"] }, -- 冰霜灾祸
            },
        },
        ["锋锐之霜"] = {
            remaining = 0,
            duration = 30,
            count = 0,
            countMin = 0,
            countMax = 5,
            expirationTime = nil,
            addAuras = {
                [50401] = { event = e["法术冷却"], step = 1 },
                [49143] = { event = e["施法成功"], step = 1 }, -- 冰霜打击
            },
            updateAuras = nil,
            removeAuras = {
                [49143] = { event = e["施法成功"], step = -1 }, -- 冰霜打击
            },
        },
        ["冰霜之柱"] = {
            remaining = 0,
            duration = 12,
            expirationTime = nil,
            addAuras = {
                [51271] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["霜巢之眷-冰霜巨龙之怒"] = {
            remaining = 0,
            duration = 45,
            expirationTime = nil,
            addAuras = {
                [1265639] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [1265384] = { event = e["施法成功"] },
            },
        },
        ["霜巢之眷"] = {
            remaining = 0,
            duration = 12,
            expirationTime = nil,
            addAuras = {
                [1265630] = { event = e["法术冷却"] },
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
        ["飞旋之水"] = {
            name = "飞旋之水",
            spellId = 453407,
            remaining = 0,
            duration = 25,
            expirationTime = nil,
            addAuras = {
                [453407] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [77472] = { event = e["施法成功"] },
            },
        },
        ["治疗之雨"] = {
            name = "治疗之雨",
            spellId = 73920,
            remaining = 0,
            duration = 18,
            expirationTime = nil,
            addAuras = {
                [73920] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["治疗之雨-涌动"] = {
            name = "治疗之雨-涌动",
            spellId = 456366,
            remaining = 0,
            duration = 18,
            expirationTime = nil,
            addAuras = {
                [456366] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
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
        ["风暴涌流图腾-持续时间"] = {
            remaining = 0,
            duration = 18,
            expirationTime = nil,
            addAuras = {
                [1267068] = { event = e["施法成功"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["治疗之泉图腾-持续时间"] = {
            remaining = 0,
            duration = 18,
            expirationTime = nil,
            addAuras = {
                [5394] = { event = e["施法成功"] },
            },
            updateAuras = nil,
            removeAuras = nil,
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
        ["升腾 - 增强"] = {
            name = "升腾",
            spellId = 114051,
            remaining = 0,
            duration = 6,
            expirationTime = nil,
            addAuras = {
                [114052] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["倾盆大雨"] = {
            name = "倾盆大雨",
            spellId = 462488,
            remaining = 0,
            duration = 24,
            count = 0,
            countMin = 0,
            countMax = 2,
            expirationTime = nil,
            addAuras = {
                [462488] = { event = e["法术冷却"], step = 2 },
            },
            updateAuras = {
                [462603] = { event = e["施法成功"], step = -1 }, -- 激流
            },
            removeAuras = nil,
        },
        ["毁灭闪电"] = {
            remaining = 0,
            duration = 10,
            expirationTime = nil,
            addAuras = {
                [1252415] = { event = e["法术冷却"] },
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
            duration = 60,
            expirationTime = nil,
            addAuras = {
                [199786] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [199786] = { event = e["施法成功"] }, -- 冰枪术
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
                [399491] = { event = e["施法成功"] }, -- 神龙之赐
                [116670] = { event = e["施法成功"] }, -- 活血术
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
        ["星河守护者"] = {
            remaining = 0,
            duration = 15,
            expirationTime = nil,
            addAuras = {
                [213708] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [8921] = { event = e["施法成功"] },
            },
        },
        ["淤血"] = {
            remaining = 0,
            duration = 10,
            expirationTime = nil,
            addAuras = {
                [93622] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = {
                [33917] = { event = e["施法成功"] },
            },
        },
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
        ["烈火烙印"] = {
            remaining = 0,
            duration = 12,
            expirationTime = nil,
            addAuras = {
                [207771] = { event = e["法术冷却"] },
            },
            updateAuras = nil,
            removeAuras = nil,
        },
        ["无羁邪怒"] = {
            remaining = 0,
            duration = 12,
            expirationTime = nil,
            addAuras = {
                [187827] = { event = e["图标发光显示"] },
            },
            updateAuras = nil,
            removeAuras = {
                [187827] = { event = e["图标发光隐藏"] },
            },
        }
    },
    -- 唤魔师
    [13] = {

    },
}

Fuyutsui.Auras = {}
do
    Fuyutsui.Auras = auras[classId] or {}
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

    for name, data in pairs(Fuyutsui.Auras) do
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
        local aura = Fuyutsui.Auras[auraName]
        if aura and ((not info.castBar) or castBarID) then
            if info.duration then
                aura.expirationTime = now + info.duration
            elseif aura.duration then
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
        local aura = Fuyutsui.Auras[auraName]
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
        local aura = Fuyutsui.Auras[auraName]
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
function Fuyutsui:updateAuraBySpellCooldown(spellID)
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
function Fuyutsui:updateAuraBySuccess(spellID, castBarID)
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
        local aura = Fuyutsui.Auras[auraName]
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
function Fuyutsui:updateAuraByIcon(spellID)
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

-- 首次登录遍历所有Icon光环
function Fuyutsui:updateAuraIconByEnteringWorld()
    local ev = e["图标改变"]
    local addBySpell = addAuras[ev]
    local updateBySpell = updateAuras[ev]
    local removeBySpell = removeAuras[ev]
    if addBySpell then
        for spellId, info in pairs(addBySpell) do
            updateAuraByIconMap(addBySpell[spellId], spellId)
        end
    end
    if updateBySpell then
        for spellId, info in pairs(updateBySpell) do
            updateAuraByIconMap(updateBySpell[spellId], spellId)
        end
    end
    if removeBySpell then
        for spellId, info in pairs(removeBySpell) do
            updateAuraByIconMap(removeBySpell[spellId], spellId)
        end
    end
end

local function updateAuraByOverrideMap(map, overrideSpellID)
    if not map then
        return
    end

    for auraName, info in pairs(map) do
        local aura = Fuyutsui.Auras[auraName]
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
function Fuyutsui:updateAuraBySpellOverride(baseSpellID, overrideSpellID)
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
function Fuyutsui:updateAuraByActivationOverlayShow(spellId)
    local addBySpell = addAuras[e["屏幕提示显示"]]
    local updateBySpell = updateAuras[e["屏幕提示显示"]]
    applyAuraMapForSpellEvent(addBySpell and addBySpell[spellId], nil)
    updateAuraMapForSpellEvent(updateBySpell and updateBySpell[spellId], nil)
end

---@param spellId number 光环ID, 屏幕提示
-- 通过事件"SPELL_ACTIVATION_OVERLAY_HIDE"更新光环, 并更新光环的结束时间
function Fuyutsui:updateAuraByActivationOverlayHide(spellId)
    local removeBySpell = removeAuras[e["屏幕提示隐藏"]]
    clearAurasFromRemoveMap(removeBySpell and removeBySpell[spellId], false)
end

-- SPELL_ACTIVATION_OVERLAY_GLOW_SHOW / HIDE：与 main.lua 一致，按是否仍发光刷新或清除时间
function Fuyutsui:updateAuraByOverlayGlow(spellID)
    local ev = e["图标发光隐藏"]
    local removeBySpell = removeAuras[ev]
    local map = removeBySpell and removeBySpell[spellID]
    if not map then
        return
    end
    local now = GetTime()
    local isSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed(spellID)
    for auraName in pairs(map) do
        local aura = Fuyutsui.Auras[auraName]
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
function Fuyutsui:updateAura()
    local currentTime = GetTime()
    for name, info in pairs(Fuyutsui.Auras) do
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

function Fuyutsui:updateAuraBlocks()
    if not self.blocks or not self.blocks.auras then
        return
    end
    for k, info in pairs(self.blocks.auras) do
        if info.auraName and info.showKey then
            local aura = Fuyutsui.Auras and Fuyutsui.Auras[info.auraName]
            if not aura then
                self:CreatTexture(k, 0)
            else
                local v = aura[info.showKey]
                if v then
                    self:CreatTexture(k, v / 255)
                else
                    self:CreatTexture(k, 0)
                end
            end
        else
            self:CreatTexture(k, 0)
        end
    end
end
