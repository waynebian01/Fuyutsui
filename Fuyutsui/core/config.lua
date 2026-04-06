local _, fu = ...
local className, classFilename, classId = UnitClass("player")
local specIndex = C_SpecializationInfo.GetSpecialization()
print(className, classFilename, classId, specIndex)
fu.className, fu.classFilename, fu.classId = className, classFilename, classId
fu.specIndex = specIndex

-- 光环列表
fu.auras = {
    -- 死亡骑士
    ["脓疮毒镰"] = {
        name = "脓疮毒镰",
        spellId = 458123,
        remaining = 0,
        duration = 15,
        expirationTime = nil,
    },
    ["次级食尸鬼"] = {
        name = "次级食尸鬼",
        spellId = 1254252,
        remaining = 0,
        duration = 30,
        count = 0,
        countMin = 0,
        countMax = 8,
        expirationTime = nil,
    },
    ["末日突降"] = {
        name = "末日突降",
        spellId = 81340,
        remaining = 0,
        duration = 10,
        count = 0,
        countMin = 0,
        countMax = 2,
        expirationTime = nil,
    },
    ["黑暗援助"] = {
        name = "黑暗援助",
        spellId = 101568,
        remaining = 0,
        duration = 20,
        expirationTime = nil,
    },
    ["禁断知识"] = {
        name = "禁断知识",
        spellId = 1242223,
        remaining = 0,
        duration = 30,
        expirationTime = nil,
    },
    -- 德鲁伊
    ["塞纳留斯的梦境"] = {
        name = "塞纳留斯的梦境",
        spellId = 372152,
        remaining = 0,
        duration = 10,
        count = 0,
        countMin = 0,
        countMax = 4,
        expirationTime = nil,
    },
    ["铁鬃"] = {
        name = "铁鬃",
        spellId = 192081,
        remaining = 0,
        duration = 7,
        expirationTime = nil,
    },
    ["狂暴回复"] = {
        name = "狂暴回复",
        spellId = 22842,
        remaining = 0,
        duration = 4,
        expirationTime = nil,
    },
    ["节能施法"] = {
        name = "节能施法",
        spellId = 16870,
        remaining = 0,
        duration = 15,
        expirationTime = nil,
    },
    ["丛林之魂"] = {
        name = "丛林之魂",
        spellId = 114108,
        remaining = 0,
        duration = 15,
        expirationTime = nil,
    },
    -- 法师
    ["热能真空"] = {
        name = "热能真空",
        spellId = 1247730,
        remaining = 0,
        duration = 12,
        expirationTime = nil,
    },
    ["冰冷智慧"] = {
        name = "冰冷智慧",
        spellId = 190446,
        remaining = 0,
        duration = 20,
        expirationTime = nil,
    },
    ["冰冻之雨"] = {
        name = "冰冻之雨",
        spellId = 270232,
        remaining = 0,
        duration = 12,
        expirationTime = nil,
    },
    ["寒冰指"] = {
        name = "寒冰指",
        spellId = 44544,
        remaining = 0,
        duration = 30,
        count = 0,
        countMin = 0,
        countMax = 2,
        expirationTime = nil,
    },
    -- 圣骑士
    ["神圣意志"] = {
        name = "神圣意志",
        spellId = 223819,
        remaining = 0,
        duration = 12,
        expirationTime = nil,
    },
    ["圣光灌注"] = {
        name = "圣光灌注",
        spellId = 54149,
        remaining = 0,
        duration = 15,
        count = 0,
        countMin = 0,
        countMax = 2,
        expirationTime = nil,
    },
    ["神性之手"] = {
        name = "神性之手",
        spellId = 414273,
        remaining = 0,
        duration = 15,
        count = 0,
        countMin = 0,
        countMax = 2,
        expirationTime = nil,
    },
    ["神圣壁垒"] = {
        name = "神圣壁垒",
        spellId = 432496,
        remaining = 0,
        duration = 20,
        expirationTime = nil,
    },
    ["圣洁武器"] = {
        name = "圣洁武器",
        spellId = 432502,
        remaining = 0,
        duration = 20,
        expirationTime = nil,
    },
    ["闪耀之光"] = {
        name = "闪耀之光",
        spellId = 327510,
        remaining = 0,
        duration = 30,
        count = 0,
        countMin = 0,
        countMax = 2,
        expirationTime = nil,
    },
    -- 牧师
    ["虚空之盾"] = {
        name = "虚空之盾",
        spellId = 1253591,
        remaining = 0,
        duration = 60,
        expirationTime = nil,
    },
    ["圣光涌动"] = {
        name = "圣光涌动",
        spellId = 114255,
        remaining = 0,
        duration = 20,
        count = 0,
        countMin = 0,
        countMax = 2,
        expirationTime = nil,
    },
    ["熵能裂隙"] = {
        name = "熵能裂隙",
        spellId = 450193,
        remaining = 0,
        duration = 12,
        expirationTime = nil,
    },
    ["暗影愈合"] = {
        name = "暗影愈合",
        spellId = 1252217,
        remaining = 0,
        duration = 15,
        count = 0,
        countMin = 0,
        countMax = 2,
        expirationTime = nil,
    },
    ["福音"] = {
        name = "福音",
        spellId = 472433,
        remaining = 0,
        duration = 120,
        count = 0,
        countMin = 0,
        countMax = 2,
        expirationTime = nil,
    },
    ["织光者"] = {
        name = "织光者",
        spellId = 390993,
        remaining = 0,
        duration = 20,
        count = 0,
        countMin = 0,
        countMax = 4,
        expirationTime = nil,
    },
    ["祈福"] = {
        name = "祈福",
        spellId = 1262766,
        remaining = 0,
        duration = 32,
        expirationTime = nil,
    },
    -- 术士
    ["魔典：邪能破坏者"] = {
        name = "魔典：邪能破坏者",
        spellId = 132409,
        remaining = 0,
        duration = 120,
        expirationTime = nil,
    },
    -- 武僧
    ["疗伤珠"] = {
        name = "疗伤珠",
        spellId = 224863,
        remaining = 0,
        duration = 30,
        count = 0,
        countMin = 0,
        countMax = 5,
        expirationTime = nil,
    },
    ["活力苏醒"] = {
        name = "活力苏醒",
        spellId = 392883,
        remaining = 0,
        duration = 20,
        expirationTime = nil,
    },
    ["清空地窖"] = {
        name = "清空地窖",
        spellId = 1262768,
        remaining = 0,
        duration = 20,
        expirationTime = nil,
    },
    ["法力茶"] = {
        name = "法力茶",
        spellId = 115867,
        remaining = 0,
        duration = 120,
        count = 0,
        countMin = 0,
        countMax = 20,
        expirationTime = nil,
    },
    ["生生不息1"] = {
        name = "生生不息",
        spellId = 197919,
        remaining = 0,
        duration = 15,
        expirationTime = nil,
    },
    ["生生不息2"] = {
        name = "生生不息",
        spellId = 197916,
        remaining = 0,
        duration = 15,
        expirationTime = nil,
    },
    ["神龙之赐"] = {
        name = "神龙之赐",
        spellId = 399496,
        remaining = 0,
        duration = 60,
        count = 0,
        countMin = 0,
        countMax = 10,
        expirationTime = nil,
    },
    ["灵泉"] = {
        name = "灵泉",
        spellId = 1260565,
        remaining = 0,
        duration = 8,
        expirationTime = nil,
    },
}
-- 更新光环
fu.updateAuras = {
    -- SPELL_UPDATE_COOLDOWN, 获取光环的事件, 检测参数: 光环ID
    bySpellCooldown = {
        -- 死亡骑士
        [458123] = { { name = "脓疮毒镰" } },
        [1254252] = { { name = "次级食尸鬼", step = 1 } },
        [81340] = { { name = "末日突降", step = 1 } },
        [101568] = { { name = "黑暗援助" } },
        [1242223] = { { name = "禁断知识" } },
        -- 德鲁伊
        [372152] = { { name = "塞纳留斯的梦境", step = 1 } },
        [192081] = { { name = "铁鬃" } },
        [22842] = { { name = "狂暴回复" } },
        [16870] = { { name = "节能施法" } },
        [114108] = { { name = "丛林之魂" } },
        -- 法师
        [1247730] = { { name = "热能真空" } },
        [190446] = { { name = "冰冷智慧" } },
        [270232] = { { name = "冰冻之雨" } },
        [44544] = { { name = "寒冰指", step = 1 } },
        -- 圣骑士
        [223819] = { { name = "神圣意志" } },
        [54149] = { { name = "圣光灌注", step = 2 } },
        [414273] = { { name = "神性之手", step = 2 } },
        [432496] = { { name = "神圣壁垒" } },
        [432502] = { { name = "圣洁武器" } },
        [327510] = { { name = "闪耀之光", step = 1 } },
        -- 牧师
        [1253591] = { { name = "虚空之盾" } },
        [114255] = { { name = "圣光涌动", step = 1 } },
        ["熵能裂隙"] = { { name = "熵能裂隙" } },
        [1252217] = { { name = "暗影愈合", step = 1 } },
        [472433] = { { name = "福音", step = 2 } },
        [390993] = { { name = "织光者", step = 1 } },
        [1262766] = { { name = "祈福" } },
        -- 术士
        [132409] = { { name = "魔典：邪能破坏者" } },
        -- 武僧
        [224863] = { { name = "疗伤珠", step = 1 } },
        [1241109] = { { name = "疗伤珠", step = -1 } }, -- 砮皂的决心
        [392883] = { { name = "活力苏醒" } },
        [1262768] = { { name = "清空地窖" } },
        [115867] = { { name = "法力茶", step = 1 } },
        [197919] = { { name = "生生不息1" }, { name = "法力茶", step = 1 } }, -- 生生不息(氤氲之雾,旭日东升踢), 默认会用掉加一层法力茶
        [197916] = { { name = "生生不息2" }, { name = "法力茶", step = 1 } }, -- 生生不息(活血术,神龙之赐), 默认会用掉加一层法力茶
        [399496] = { { name = "神龙之赐", step = 1 } },
        [1260565] = { { name = "灵泉" } },
    },
    -- COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED
    -- 法术覆盖事件, 检测参数: 基本法术ID, 覆盖法术ID
    -- 注意: 每个基本法术ID可以对应多个覆盖法术ID, 所以需要放入一个table中
    bySpellOverride = {
        [17] = {
            {
                name = "虚空之盾",
                auraID = 1253591,
                spellId = 17,
                overrideSpellID = 1253593
            }
        },
        [2061] = {
            {
                name = "祈福",
                auraID = 1262766,
                spellId = 2061,
                overrideSpellID = 1262763
            }
        },
    },
    -- SPELL_ACTIVATION_OVERLAY_HIDE
    -- 屏幕提示事件, 检测参数: 法术ID
    byActivationOverlay = {
        [223819] = { name = "神圣意志", auraID = 223819 },
        [114255] = { name = "圣光涌动", auraID = 114255 },
    },
    -- SPELL_ACTIVATION_OVERLAY_GLOW_SHOW
    -- SPELL_ACTIVATION_OVERLAY_GLOW_HIDE
    -- 法术图标发光事件, 检测参数: 法术ID
    byOverlayGlow = {
        [8936] = { auraID = 372152, name = "塞纳留斯的梦境", },
        [49998] = { auraID = 101568, name = "黑暗援助", },
    },
    -- UNIT_SPELLCAST_SUCCEEDED
    -- 法术成功事件, 键: 法术ID, 值: name: 光环名称, auraID: 光环ID, step: 光环层数步长
    -- 注意: 每个法术ID可以对应多个光环, 所以需要放入一个table中
    bySuccess = {
        -- 死亡骑士
        [85948] = { { name = "次级食尸鬼", auraID = 1254252, step = 1.5, } }, -- 脓疮打击
        [458128] = { { name = "次级食尸鬼", auraID = 1254252, step = 1.5, } }, -- 脓疮毒镰
        [55090] = { { name = "次级食尸鬼", auraID = 1254252, step = -1, } }, -- 天灾打击
        [47541] = { { name = "末日突降", auraID = 81340, step = -1, } }, -- 凋零缠绕
        [207317] = { { name = "末日突降", auraID = 81340, step = -1, } }, -- 扩散
        -- 愈合
        [8936] = {
            { name = "塞纳留斯的梦境", auraID = 372152, step = -1, },
            { name = "丛林之魂", auraID = 114108 },
            { name = "节能施法", auraID = 16870 },
        },
        -- 回春术
        [774] = { { name = "丛林之魂", auraID = 114108 } },
        [22842] = { { name = "塞纳留斯的梦境", auraID = 372152, step = -1, } },
        -- 冰枪术
        [30455] = {
            { name = "寒冰指", auraID = 44544, step = -1 },
            { name = "热能真空", auraID = 1247730 },
        },
        -- 冰风暴
        [44614] = { { name = "冰冷智慧", auraID = 190446 } },
        -- 圣光术
        [82326] = { { name = "神性之手", auraID = 414273, step = -1 } },
        -- 圣光闪现
        [19750] = { { name = "圣光灌注", auraID = 54149, step = -1 } },
        -- 荣耀圣令
        [85673] = { { name = "闪耀之光", auraID = 327510, step = -1 } },
        -- 真言术：耀
        [194509] = { { name = "真言术：耀", auraName = "福音", auraID = 472433, step = -1 } },
        -- 快速治疗
        [2061] = { { name = "圣光涌动", auraID = 114255, step = -1 } },
        -- 暗影愈合
        [186263] = { { name = "暗影愈合", auraID = 1252217, step = -1 } },
        -- 治疗祷言
        [596] = {
            { name = "织光者", auraID = 390993, step = -1 },
            { name = "圣光涌动", auraID = 114255, step = -1 } },
        -- 移花接木
        [322101] = { { name = "疗伤珠", auraID = 224863 } },
        -- 活血术
        [116670] = {
            { name = "活力苏醒", auraID = 392883 },
            { name = "生生不息2", auraID = 197919 } },
        -- 清空地窖
        [1263438] = { { name = "清空地窖", auraID = 1262768 } },
        -- 法力茶
        [115294] = { { name = "法力茶", auraID = 115867 } },
        -- 氤氲之雾
        [124682] = { { name = "生生不息1", auraID = 197919 } },
        -- 神龙之赐
        [399491] = {
            { name = "神龙之赐", auraID = 399496 },
            { name = "生生不息2", auraID = 197919 } },
        -- 旭日东升踢
        [107428] = { { name = "生生不息1", auraID = 197919 } },
    },
    -- 法术图标事件"SPELL_UPDATE_ICON",
    -- 检测参数: 基础法术ID
    byIcon = {
        [116] = { -- 寒冰箭
            name = "冰川尖刺！",
            auraID = nil,
            spellId = 116,
            overrideSpellID = 199786,
            isIcon = 1,
        },
        [432459] = {
            name = "神圣军备",
            auraID = nil,
            spellId = 432459,
            overrideSpellID = 432472,
            isIcon = 1,
        },
        [1253591] = {
            name = "虚空之盾",
            auraID = 1253591,
            spellId = 17,
            overrideSpellID = 1253593,
        },
        [1276467] = {
            name = "魔典：邪能破坏者",
            auraID = nil,
            spellId = 1276467,
            overrideSpellID = 132409,
            isIcon = 1,
        },
        [585] = {
            name = "惩击",
            auraID = "熵能裂隙",
            spellId = 585,
            overrideSpellID = 450215
        },
    }
}
-- 失败法术
fu.failedSpells = {
    -- 种族
    [232633] = 101, -- 奥术洪流(法力)
    [129597] = 102, -- 奥术洪流(能量)
    -- 术士
    [5782] = 1,     -- 恐惧
    [6789] = 2,     -- 死亡缠绕
    [30283] = 3,    -- 暗影之怒
    [196277] = 7,   -- 内爆
    [265187] = 8,   -- 召唤恶魔暴君
    [1276467] = 9,  -- 魔典：邪能破坏者
    [1276672] = 11, -- 召唤末日守卫
    [264187] = 13,  -- 恶魔之箭

    -- 牧师
    [8122] = 1,   -- 心灵尖啸
    [32375] = 2,  -- 群体驱散
    [62618] = 3,  -- 真言术：障
    [421453] = 4, -- 终极苦修
    [200183] = 5, -- 神圣化身
    [120517] = 6, -- 光晕
    [64843] = 7,  -- 神圣赞美诗
    [228260] = 8, -- 虚空形态
    [15286] = 9,  -- 吸血鬼的拥抱

    -- 德鲁伊
    [132469] = 1, -- 台风
    [99] = 2,     -- 夺魂咆哮
    [102793] = 3, -- 乌索克旋风
    [132158] = 4, -- 自然迅捷

    -- 法师
    [110959] = 1,  -- 强化隐形术
    [122] = 2,     -- 冰霜新星
    [31661] = 3,   -- 龙息术
    [1248829] = 4, -- 暴风雪
    [190356] = 4,  -- 暴风雪

    -- 圣骑士
    [115750] = 1, -- 盲目之光
    [31821] = 2,  -- 光环掌握
    [1044] = 3,   -- 自由祝福
    [853] = 4,    -- 制裁之锤
    [1022] = 5,   -- 保护祝福

}
-- 一键辅助法术
fu.assistant = {
    -- 死亡骑士
    [206930]  = 1,  -- 心脏打击
    [43265]   = 2,  -- 枯萎凋零
    [195292]  = 3,  -- 死神的抚摸
    [49998]   = 4,  -- 灵界打击
    [49028]   = 5,  -- 符文刃舞
    [195182]  = 6,  -- 精髓分裂
    [50842]   = 7,  -- 血液沸腾
    [433895]  = 8,  -- 吸血鬼打击
    [46584]   = 9,  -- 亡者复生
    [42650]   = 10, -- 亡者大军
    [47541]   = 11, -- 凋零缠绕
    [55090]   = 12, -- 天灾打击
    [207317]  = 13, -- 扩散
    [77575]   = 14, -- 爆发
    [85948]   = 15, -- 脓疮打击
    [1247378] = 16, -- 腐化
    [1233448] = 17, -- 黑暗突变
    [343294]  = 18, -- 灵魂收割
    -- 德鲁伊
    [8921]    = 1,  -- 月火术
    [1126]    = 2,  -- 野性印记
    [400254]  = 3,  -- 摧折
    [204066]  = 4,  -- 明月普照
    [213771]  = 5,  -- 横扫
    [5487]    = 6,  -- 熊形态
    [77758]   = 7,  -- 痛击
    [33917]   = 8,  -- 裂伤
    [1252871] = 9,  -- 赤红之月
    [441605]  = 10, -- 毁灭
    [22568]   = 11, -- 凶猛撕咬
    [1079]    = 12, -- 割裂
    [5221]    = 13, -- 撕碎
    [1822]    = 14, -- 斜掠
    [5176]    = 15, -- 愤怒
    -- 法师
    [1459]    = 1,  -- 奥术智慧
    [116]     = 2,  -- 寒冰箭
    [199786]  = 3,  -- 冰川尖刺
    [30455]   = 4,  -- 冰枪术
    [205021]  = 5,  -- 冰霜射线
    [44614]   = 6,  -- 冰风暴
    [84714]   = 7,  -- 寒冰宝珠
    -- 圣骑士
    [375576]  = 1,  -- 圣洁鸣钟
    [31935]   = 2,  -- 复仇者之盾
    [26573]   = 3,  -- 奉献
    [275779]  = 4,  -- 审判
    [53600]   = 5,  -- 正义盾击
    [204019]  = 6,  -- 祝福之锤
    [184575]  = 7,  -- 公正之剑
    [20271]   = 8,  -- 审判
    [383328]  = 9,  -- 最终审判
    [255937]  = 10, -- 灰烬觉醒
    [53385]   = 11, -- 神圣风暴
    [427453]  = 12, -- 圣光之锤(灰烬觉醒)
    [24275]   = 13, -- 愤怒之锤(审判)
    [343527]  = 14, -- 处决宣判
    [1241413]  = 15, -- 愤怒之锤(审判)
    -- 牧师
    [21562]   = 1,  -- 真言术：韧
    [8092]    = 2,  -- 心灵震爆
    [585]     = 3,  -- 惩击
    [32379]   = 4,  -- 暗言术：灭
    [589]     = 5,  -- 暗言术：痛
    [47540]   = 6,  -- 苦修
    [88625]   = 7,  -- 圣言术：罚
    [14914]   = 8,  -- 神圣之火
    [132157]  = 9,  -- 神圣新星
    [34914]   = 10, -- 吸血鬼之触
    [232698]  = 11, -- 暗影形态
    [335467]  = 12, -- 暗言术：癫
    [15407]   = 13, -- 精神鞭笞
    [228260]  = 14, -- 虚空形态
    [263165]  = 15, -- 虚空洪流
    [1227280] = 16, -- 触须猛击
    [450983]  = 17, -- 虚空冲击
    [1242173] = 18, -- 虚空齐射
    [391403]  = 19, -- 精神鞭笞：狂
    [120644]  = 20, -- 光晕
    -- 术士
    [105174]  = 1,  -- 古尔丹之手
    [104316]  = 2,  -- 召唤恐惧猎犬
    [30146]   = 3,  -- 召唤恶魔卫士
    [264178]  = 4,  -- 恶魔之箭
    [686]     = 5,  -- 暗影箭
    [691]     = 6,  -- 召唤地狱猎犬
    [688]     = 7,  -- 召唤小鬼
    [1271748] = 8,  -- 虚弱灾厄
    [1271802] = 9,  -- 语言灾厄
    [434635]  = 10, -- 陨灭(古尔丹之手)
    [434506]  = 11, -- 狱火箭(暗影箭)
    -- 武僧
    [322109]  = 1,  -- 轮回之触
    [100780]  = 2,  -- 猛虎掌
    [322729]  = 3,  -- 神鹤引项踢
    [205523]  = 4,  -- 幻灭踢
    [325153]  = 5,  -- 爆炸酒桶
    [123986]  = 6,  -- 真气爆裂
    [121253]  = 7,  -- 醉酿投
    [115181]  = 8,  -- 火焰之息
    [116847]  = 9,  -- 碧玉疾风
    -- 猎人
    [217200]  = 1,  -- 倒刺射击
    [34026]   = 2,  -- 杀戮命令
    [193455]  = 3,  -- 眼镜蛇射击
    [19574]   = 4,  -- 狂野怒火
    [201430]  = 5,  -- 荒野呼唤
    [131894]  = 6,  -- 夺命黑鸦
    [120360]  = 7,  -- 弹幕射击
    [321530]  = 8,  -- 血溅十方
    [19434]   = 9,  -- 瞄准射击
    [257044]  = 10, -- 急速射击
    [56641]   = 11, -- 稳固射击
    [2643]    = 12, -- 多重射击
    [288613]  = 13, -- 百发百中
    [53351]   = 14, -- 夺命射击
    [212431]  = 15, -- 爆炸射击
    [389831]  = 16, -- 哀恸箭
    [257284]  = 17, -- 猎人印记
    [185358]  = 18, -- 奥术射击
    [342049]  = 19, -- 奇美拉射击
    [883]     = 20, -- 召唤宠物1
    [1264359] = 21, -- 狂野鞭笞
}
-- 难度文本
fu.difficutlyToText = {
    [1] = "5人本普通", -- Normal (Dungeon)
    [2] = "5人本英雄", -- Heroic (Dungeon)
    [14] = "团本普通", -- Normal (Raid)
    [15] = "团本英雄", -- Heroic (Raid)
    [16] = "团本史诗", -- Mythic (Raid)
    [17] = "团本随机", -- Looking (Raid)
    [23] = "5人本史诗", -- Mythic (Dungeon)
}
-- 首领ID
fu.bossID = {
    [0] = 0,     -- 未战斗
    -- 团本
    [3176] = 1,  -- 元首阿福扎恩
    [3177] = 2,  -- 弗拉希乌斯
    [3179] = 3,  -- 陨落之王萨哈达尔
    [3178] = 4,  -- 威厄高尔和艾佐拉克
    [3180] = 5,  -- 光盲先锋军
    [3181] = 6,  -- 宇宙之冕
    [3306] = 7,  -- 奇美鲁斯，未梦之神
    [3182] = 8,  -- 贝洛朗，奥的子嗣
    [3183] = 9,  -- 至暗之夜降临
    [3454] = 10, -- 鲁阿夏尔
    [3459] = 11, -- 索姆贝兰
    [3431] = 12, -- 普雷达萨斯
    [3436] = 13, -- 克拉格平
    -- 大米
    -- 节点希纳斯
    [3328] = 51, -- 核技工程长卡斯雷瑟
    [3332] = 52, -- 核心守卫奈萨拉
    [3333] = 53, -- 洛萨克森
    -- 迈萨拉洞窟
    [3212] = 54, -- 姆罗金和内克拉克斯
    [3213] = 55, -- 沃达扎
    [3214] = 56, -- 拉克图尔，聚魂之器
    -- 风行者之塔
    [3056] = 57, -- 烬晓
    [3057] = 58, -- 被遗弃的二人组
    [3058] = 59, -- 指挥官克罗鲁科
    [3059] = 60, -- 无眠之心
    -- 魔导师平台
    [3071] = 61, -- 奥能金刚库斯托斯
    [3072] = 62, -- 瑟拉奈尔·日鞭
    [3073] = 63, -- 吉美尔鲁斯
    [3074] = 64, -- 迪詹崔乌斯
    -- 执政团之座
    [2065] = 65, -- 晋升者祖拉尔
    [2066] = 66, -- 萨普瑞什
    [2067] = 67, -- 总督奈扎尔
    [2068] = 68, -- 鲁拉
    -- 艾杰斯亚学院
    [2562] = 69, -- 维克萨姆斯
    [2563] = 70, -- 茂林古树
    [2564] = 71, -- 克罗兹
    [2565] = 72, -- 多拉苟萨的回响
    -- 萨隆矿坑
    [1999] = 73, -- 熔炉之主加弗斯特
    [2001] = 74, -- 伊克和科瑞克
    [2000] = 75, -- 天灾领主泰兰努斯
    -- 通天峰
    [1698] = 76, -- 兰吉特
    [1699] = 77, -- 阿拉卡纳斯
    [1700] = 78, -- 鲁克兰
    [1701] = 79, -- 高阶贤者维里克斯
}
-- 施法技能列表
fu.castingSpellList = {
    [384255] = 101, -- 切换天赋
    -- 牧师
    [585] = 2,      -- 惩击
    [32375] = 3,    -- 群体驱散
    [2061] = 4,     -- 快速治疗
    [8092] = 5,     -- 心灵震爆
    [194509] = 6,   -- 真言术：耀
    [421453] = 7,   -- 终极苦修
    [212036] = 8,   -- 群体复活
    [47540] = 9,    -- 苦修
    [64863] = 10,   -- 神圣赞美诗
    [596] = 11,     -- 治疗祷言
    [14914] = 12,   -- 神圣之火
    [34914] = 13,   -- 心灵尖啸
    [15407] = 14,   -- 精神鞭笞
    [228260] = 15,  -- 虚空形态
    [120644] = 16,  -- 光晕(暗影)
    [120517] = 17,  -- 光晕
    [391403] = 18,  -- 精神鞭笞：狂
    [1262763] = 19, -- 祈福
    -- 术士
    [5782] = 1,     -- 恐惧
    [6789] = 2,     -- 死亡缠绕
    [20707] = 3,    -- 灵魂石
    [30283] = 4,    -- 暗影之怒
    [333889] = 5,   -- 邪能统御
    [108416] = 6,   -- 黑暗契约
    [196277] = 7,   -- 内爆
    [265187] = 8,   -- 召唤恶魔暴君
    [1276467] = 9,  -- 魔典：邪能破坏者
    [105174] = 10,  -- 古尔丹之手
    [1276672] = 11, -- 召唤末日守卫
    [104316] = 12,  -- 召唤恐惧猎犬
    [264187] = 13,  -- 恶魔之箭
    [1276452] = 14, -- 魔典：小鬼领主
    [1271748] = 15, -- 虚弱灾厄
    [1271802] = 16, -- 语言灾厄
    [132409] = 17,  -- 法术封锁
    [30146] = 18,   -- 召唤恶魔卫士
    [686] = 19,     -- 暗影箭
    -- 法师
    [116] = 1,      -- 寒冰箭
    [199786] = 2,   -- 冰川尖刺
    [205021] = 3,   -- 冰霜射线
    [1248829] = 4,  -- 暴风雪
    [190356] = 5,   -- 暴风雪
}
-- 能量类型
fu.EnumPowerType = {
    ["MANA"] = 0,
    ["RAGE"] = 1,
    ["FOCUS"] = 2,
    ["ENERGY"] = 3,
    ["COMBO_POINTS"] = 4,
    ["RUNES"] = 5,
    ["RUNIC_POWER"] = 6,
    ["SOUL_SHARDS"] = 7,
    ["LUNAR_POWER"] = 8,
    ["HOLY_POWER"] = 9,
    ["MAELSTROM"] = 11,
    ["CHI"] = 12,
    ["INSANITY"] = 13,
    ["BURNING_EMBERS"] = 14,
    ["DEMONIC_FURY"] = 15,
    ["ARCANE_CHARGES"] = 16,
    ["FURY"] = 17,
    ["PAIN"] = 18,
    ["ESSENCE"] = 19,
    ["SHADOW_ORBS"] = 28,
}
-- 固定区块
fu.fixed_blocks = {
    anchor = 1,        -- 锚点
    class = 2,         -- 职业
    specIndex = 3,     -- 专精
    valid = 4,         -- 有效性
    combat = 5,        -- 战斗状态
    moving = 6,        -- 移动状态
    casting = 7,       -- 施法状态
    channel = 8,       -- 引导状态
    HealthPercent = 9, -- 血量百分比
    PowerPercent = 10, -- 能量百分比
}
-- 无秘密值光环
fu.noSecretAuras = {
    -- 恩护 唤魔师
    [355941] = true,  -- Dream Breath
    [363502] = true,  -- Dream Flight
    [364343] = true,  -- Echo
    [366155] = true,  -- Reversion
    [367364] = true,  -- Echo Reversion
    [373267] = true,  -- Lifebind
    [376788] = true,  -- Echo Dream Breath
    -- 增辉 唤魔师
    [360827] = true,  -- Blistering Scales
    [395152] = true,  -- Ebon Might
    [410089] = true,  -- Prescience
    [410263] = true,  -- Inferno's Blessing
    [410686] = true,  -- Symbiotic Bloom
    [413984] = true,  -- Shifting Sands
    -- 恢复 德鲁伊
    [774] = true,     -- Rejuv, 回春
    [8936] = true,    -- Regrowth, 愈合
    [33763] = true,   -- Lifebloom, 生命绽放
    [48438] = true,   -- Wild Growth, 野性生长
    [155777] = true,  -- Germination, 萌芽
    -- 戒律 牧师
    [17] = true,      -- 真言术：盾
    [194384] = true,  -- 救赎
    [1253593] = true, -- 虚空护盾
    -- 神圣 牧师
    [139] = true,     -- 恢复
    [41635] = true,   -- 愈合祷言
    [77489] = true,   -- 圣光回响
    -- 织雾 武僧
    [115175] = true,  -- Soothing Mist 抚慰之雾
    [119611] = true,  -- Renewing Mist 复苏之雾
    [124682] = true,  -- Enveloping Mist 氤氲之雾
    [450769] = true,  -- Aspect of Harmony 和谐化身
    -- 恢复 萨满
    [974] = true,
    [383648] = true,  -- Earth Shield
    [61295] = true,   -- Riptide
    -- 神圣 圣骑士
    [53563] = true,   -- Beacon of Light, 圣光道标
    [156322] = true,  -- Eternal Flame, 永恒之火
    [156910] = true,  -- Beacon of Faith, 信仰道标
    [1244893] = true, -- Beacon of the Savior, 救世道标
}
-- 动作条
fu.actionBars = {
    { startSlot = 1,   endSlot = 12,  bindingPrefix = "ACTIONBUTTON" },
    { startSlot = 13,  endSlot = 24,  bindingPrefix = "ACTIONBUTTON" },
    { startSlot = 25,  endSlot = 36,  bindingPrefix = "MULTIACTIONBAR3BUTTON" },
    { startSlot = 37,  endSlot = 48,  bindingPrefix = "MULTIACTIONBAR4BUTTON" },
    { startSlot = 49,  endSlot = 60,  bindingPrefix = "MULTIACTIONBAR2BUTTON" },
    { startSlot = 61,  endSlot = 72,  bindingPrefix = "MULTIACTIONBAR1BUTTON" },
    { startSlot = 73,  endSlot = 84,  bindingPrefix = "ACTIONBUTTON" }, -- 战斗姿态, 猫形态, 潜行, 暗影
    { startSlot = 85,  endSlot = 96,  bindingPrefix = "ACTIONBUTTON" }, -- 防御姿态,
    { startSlot = 97,  endSlot = 108, bindingPrefix = "ACTIONBUTTON" }, -- 狂暴姿态, 熊形态
    { startSlot = 109, endSlot = 120, bindingPrefix = "ACTIONBUTTON" }, -- 枭兽形态
    { startSlot = 121, endSlot = 143, bindingPrefix = "ACTIONBUTTON" },
    { startSlot = 145, endSlot = 156, bindingPrefix = "MULTIACTIONBAR5BUTTON" },
    { startSlot = 157, endSlot = 168, bindingPrefix = "MULTIACTIONBAR6BUTTON" },
    { startSlot = 169, endSlot = 180, bindingPrefix = "MULTIACTIONBAR7BUTTON" }
}
-- 按键映射
fu.keymap = {
    ["1"] = 49,
    ["2"] = 50,
    ["3"] = 51,
    ["4"] = 52,
    ["5"] = 53,
    ["6"] = 54,
    ["7"] = 55,
    ["8"] = 56,
    ["9"] = 57,
    ["0"] = 48,

    ["F1"] = 112,
    ["F2"] = 113,
    ["F3"] = 114,
    ["F4"] = 115,
    ["F5"] = 116,
    ["F6"] = 117,
    ["F7"] = 118,
    ["F8"] = 119,
    ["F9"] = 120,
    ["F10"] = 121,
    ["F11"] = 122,
    ["F12"] = 123,

    ["Q"] = 81,
    ["W"] = 87,
    ["E"] = 69,
    ["R"] = 82,
    ["T"] = 84,
    ["Y"] = 89,
    ["U"] = 85,
    ["I"] = 73,
    ["O"] = 79,
    ["P"] = 80,
    ["A"] = 65,
    ["S"] = 83,
    ["D"] = 68,
    ["F"] = 70,
    ["G"] = 71,
    ["H"] = 72,
    ["J"] = 74,
    ["K"] = 75,
    ["L"] = 76,
    ["Z"] = 90,
    ["X"] = 88,
    ["C"] = 67,
    ["V"] = 86,
    ["B"] = 66,
    ["N"] = 78,
    ["M"] = 77,

    ["NUMPAD0"] = 96,
    ["NUMPAD1"] = 97,
    ["NUMPAD2"] = 98,
    ["NUMPAD3"] = 99,
    ["NUMPAD4"] = 100,
    ["NUMPAD5"] = 101,
    ["NUMPAD6"] = 102,
    ["NUMPAD7"] = 103,
    ["NUMPAD8"] = 104,
    ["NUMPAD9"] = 105,
    ["NUMPADMULTIPLY"] = 106,
    ["NUMPADPLUS"] = 107,
    ["NUMPADMINUS"] = 109,
    ["NUMPADDECIMAL"] = 110,
    ["NUMPADDIVIDE"] = 111,

    ["N0"] = 96,  -- 0x60
    ["N1"] = 97,  -- 0x61
    ["N2"] = 98,  -- 0x62
    ["N3"] = 99,  -- 0x63
    ["N4"] = 100, -- 0x64
    ["N5"] = 101, -- 0x65
    ["N6"] = 102, -- 0x66
    ["N7"] = 103, -- 0x67
    ["N8"] = 104, -- 0x68
    ["N9"] = 105, -- 0x69
    ["N*"] = 106, -- 0x6A
    ["N+"] = 107, -- 0x6B
    ["N-"] = 109, -- 0x6D
    ["N."] = 110, -- 0x6E
    ["N/"] = 111, -- 0x6F

    ["SPACE"] = 32,
    ["="] = 187,
    ["EQUALS"] = 187, -- WoW可能返回EQUALS而不是=
    ["-"] = 189,
    ["MINUS"] = 189,  -- WoW可能返回MINUS而不是-
    ["["] = 219,
    ["]"] = 221,
    ["\\"] = 220,
    [";"] = 186,
    ["SEMICOLON"] = 186, -- WoW可能返回SEMICOLON而不是;
    ["'"] = 222,
    [","] = 188,
    ["COMMA"] = 188,  -- WoW可能返回COMMA而不是,
    ["."] = 190,
    ["PERIOD"] = 190, -- WoW可能返回PERIOD而不是.
    ["/"] = 191,
}
-- 角色类型映射
fu.roleMap = {
    ["TANK"] = 1,
    ["HEALER"] = 2,
    ["DAMAGER"] = 3,
    ["NONE"] = 0,
}

function SetTestSecret(set)
    SetCVar("secretChallengeModeRestrictionsForced", set)
    SetCVar("secretCombatRestrictionsForced", set)
    SetCVar("secretEncounterRestrictionsForced", set)
    SetCVar("secretMapRestrictionsForced", set)
    SetCVar("secretPvPMatchRestrictionsForced", set)
    SetCVar("secretAuraDataRestrictionsForced", set)
    SetCVar("scriptErrors", set);
    SetCVar("doNotFlashLowHealthWarning", set);
end

-- /script SetTestSecret(0)
SetTestSecret(1)

-- 遍历队伍成员, 来自WeakAuras的代码
---@param reversed boolean 是否逆序
---@param forceParty boolean 是否强制使用队伍
---@return function 迭代器
function fu.IterateGroupMembers(reversed, forceParty)
    local unit = (not forceParty and IsInRaid()) and 'raid' or 'party'
    local numGroupMembers = unit == 'party' and GetNumSubgroupMembers() or GetNumGroupMembers()
    local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
    return function()
        local ret
        if i == 0 and unit == 'party' then
            ret = 'player'
        elseif i <= numGroupMembers and i > 0 then
            ret = unit .. i
        end
        i = i + (reversed and -1 or 1)
        return ret
    end
end

function fu.creatColorCurve(point, b)
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Linear)
    curve:AddPoint(0, CreateColor(0, 0, 0, 1))
    curve:AddPoint(point, CreateColor(0, 0, b / 255, 1))
    return curve
end

-- 创建颜色曲线
fu.dispelCurve = C_CurveUtil.CreateColorCurve()
fu.dispelCurve:SetType(Enum.LuaCurveType.Step)
fu.dispelCurve:AddPoint(0, CreateColor(0, 0, 0, 1))         -- 无
fu.dispelCurve:AddPoint(1, CreateColor(0, 1, 1 / 255, 1))   -- 魔法
fu.dispelCurve:AddPoint(2, CreateColor(0, 1, 2 / 255, 1))   -- 诅咒
fu.dispelCurve:AddPoint(3, CreateColor(0, 1, 3 / 255, 1))   -- 疾病
fu.dispelCurve:AddPoint(4, CreateColor(0, 1, 4 / 255, 1))   -- 中毒
fu.dispelCurve:AddPoint(11, CreateColor(0, 1, 11 / 255, 1)) -- 流血
