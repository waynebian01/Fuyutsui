local _, fu = ...
local className, classFilename, classId = UnitClass("player")
local specIndex = C_SpecializationInfo.GetSpecialization()
local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex)
print("职业:", className, "职业文件:", classFilename, "职业ID:", classId, "专精索引:", specIndex)
fu.className, fu.classFilename, fu.classId = className, classFilename, classId
fu.specIndex = specIndex
fu.spellsList = {
    [384255]  = { index = 151, },              -- 切换天赋
    -- 种族
    [232633]  = { index = 101, },              -- 奥术洪流(法力)
    [129597]  = { index = 102, },              -- 奥术洪流(能量)
    -- 术士
    [5782]    = { index = 1, failed = true },  -- 恐惧
    [6789]    = { index = 2, failed = true },  -- 死亡缠绕
    [30283]   = { index = 3, failed = true },  -- 暗影之怒
    [196277]  = { index = 4, failed = true },  -- 内爆
    [265187]  = { index = 5, failed = true },  -- 召唤恶魔暴君
    [1276467] = { index = 6, failed = true },  -- 魔典：邪能破坏者
    [1276672] = { index = 7, },                -- 召唤末日守卫
    [105174]  = { index = 8, },                -- 古尔丹之手
    [104316]  = { index = 9, },                -- 召唤恐惧猎犬
    [30146]   = { index = 10, },               -- 召唤恶魔卫士
    [264178]  = { index = 11, },               -- 恶魔之箭
    [686]     = { index = 12, },               -- 暗影箭
    [691]     = { index = 13, },               -- 召唤地狱猎犬
    [688]     = { index = 14, },               -- 召唤小鬼
    [1271748] = { index = 15, },               -- 虚弱灾厄
    [1271802] = { index = 16, },               -- 语言灾厄
    [434635]  = { index = 17, },               -- 陨灭(古尔丹之手)
    [434506]  = { index = 18, },               -- 狱火箭(暗影箭)
    [20707]   = { index = 19, },               -- 灵魂石
    [333889]  = { index = 20, },               -- 邪能统御
    [108416]  = { index = 21, },               -- 黑暗契约
    [264187]  = { index = 22, },               -- 恶魔之箭
    [1276452] = { index = 23, },               -- 魔典：小鬼领主
    [132409]  = { index = 24, },               -- 法术封锁
    -- 牧师
    [8122]    = { index = 1, failed = true },  -- 心灵尖啸
    [32375]   = { index = 2, failed = true },  -- 群体驱散
    [62618]   = { index = 3, failed = true },  -- 真言术：障
    [421453]  = { index = 4, failed = true },  -- 终极苦修
    [200183]  = { index = 5, failed = true },  -- 神圣化身
    [120517]  = { index = 6, failed = true },  -- 光晕
    [64843]   = { index = 7, failed = true },  -- 神圣赞美诗
    [228260]  = { index = 8, failed = true },  -- 虚空形态
    [15286]   = { index = 9, failed = true },  -- 吸血鬼的拥抱
    [21562]   = { index = 10, },               -- 真言术：韧
    [8092]    = { index = 11, },               -- 心灵震爆
    [585]     = { index = 12, },               -- 惩击
    [32379]   = { index = 13, },               -- 暗言术：灭
    [589]     = { index = 14, },               -- 暗言术：痛
    [47540]   = { index = 15, },               -- 苦修
    [88625]   = { index = 16, },               -- 圣言术：罚
    [14914]   = { index = 17, },               -- 神圣之火
    [132157]  = { index = 18, },               -- 神圣新星
    [34914]   = { index = 19, },               -- 吸血鬼之触
    [232698]  = { index = 20, },               -- 暗影形态
    [335467]  = { index = 21, },               -- 暗言术：癫
    [15407]   = { index = 22, },               -- 精神鞭笞
    [263165]  = { index = 23, },               -- 虚空洪流
    [1227280] = { index = 24, },               -- 触须猛击
    [450983]  = { index = 25, },               -- 虚空冲击
    [1242173] = { index = 26, },               -- 虚空齐射
    [391403]  = { index = 27, },               -- 精神鞭笞：狂
    [120644]  = { index = 28, },               -- 光晕
    [2061]    = { index = 29, },               -- 快速治疗
    [194509]  = { index = 30, },               -- 真言术：耀
    [64863]   = { index = 31, },               -- 神圣赞美诗
    [596]     = { index = 32, },               -- 治疗祷言
    [1262763] = { index = 33, },               -- 祈福
    [186263]  = { index = 34, },               -- 暗影愈合
    -- 德鲁伊
    [132469]  = { index = 1, failed = true },  -- 台风
    [99]      = { index = 2, failed = true },  -- 夺魂咆哮
    [102793]  = { index = 3, failed = true },  -- 乌索尔旋风
    [132158]  = { index = 4 },                 -- 自然迅捷
    [8921]    = { index = 5, },                -- 月火术
    [1126]    = { index = 6, },                -- 野性印记
    [400254]  = { index = 7, },                -- 摧折
    [204066]  = { index = 8, },                -- 明月普照
    [213771]  = { index = 9, },                -- 横扫
    [5487]    = { index = 10, },               -- 熊形态
    [77758]   = { index = 11, },               -- 痛击
    [33917]   = { index = 12, },               -- 裂伤
    [1252871] = { index = 13, },               -- 赤红之月
    [441605]  = { index = 14, },               -- 毁灭
    [22568]   = { index = 15, },               -- 凶猛撕咬
    [1079]    = { index = 16, },               -- 割裂
    [5221]    = { index = 17, },               -- 撕碎
    [1822]    = { index = 18, },               -- 斜掠
    [5176]    = { index = 19, },               -- 愤怒
    [8936]    = { index = 20, },               -- 愈合
    [48438]   = { index = 21, },               -- 野性生长
    [740]     = { index = 22, },               -- 宁静
    -- 法师
    [110959]  = { index = 1, failed = true },  -- 强化隐形术
    [122]     = { index = 2, failed = true },  -- 冰霜新星
    [31661]   = { index = 3, failed = true },  -- 龙息术
    [1248829] = { index = 4, },                -- 暴风雪
    [190356]  = { index = 5, },                -- 暴风雪
    [1459]    = { index = 6, },                -- 奥术智慧
    [116]     = { index = 7, },                -- 寒冰箭
    [199786]  = { index = 8, },                -- 冰川尖刺
    [30455]   = { index = 9, },                -- 冰枪术
    [205021]  = { index = 10, },               -- 冰霜射线
    [44614]   = { index = 11, },               -- 冰风暴
    [84714]   = { index = 12, },               -- 寒冰宝珠
    [431044]  = { index = 13, },               -- 霜火之箭
    [153595]  = { index = 14, },               -- 彗星风暴
    -- 圣骑士
    [115750]  = { index = 1, failed = true },  -- 盲目之光
    [31821]   = { index = 2, failed = true },  -- 光环掌握
    [1044]    = { index = 3, failed = true },  -- 自由祝福
    [853]     = { index = 4, failed = true },  -- 制裁之锤
    [1022]    = { index = 5, failed = true },  -- 保护祝福
    [642]     = { index = 6, failed = true },  -- 圣盾术
    [375576]  = { index = 7, },                -- 圣洁鸣钟
    [31935]   = { index = 8, },                -- 复仇者之盾
    [26573]   = { index = 9, },                -- 奉献
    [275779]  = { index = 10, },               -- 审判
    [53600]   = { index = 11, },               -- 正义盾击
    [204019]  = { index = 12, },               -- 祝福之锤
    [184575]  = { index = 13, },               -- 公正之剑
    [20271]   = { index = 14, },               -- 审判
    [383328]  = { index = 15, },               -- 最终审判
    [255937]  = { index = 16, },               -- 灰烬觉醒
    [53385]   = { index = 17, },               -- 神圣风暴
    [427453]  = { index = 18, },               -- 圣光之锤(灰烬觉醒, 圣洁鸣钟)
    [24275]   = { index = 19, },               -- 愤怒之锤(审判)
    [343527]  = { index = 20, },               -- 处决宣判
    [1241413] = { index = 21, },               -- 愤怒之锤(审判)
    [82326]   = { index = 22, },               -- 圣光术
    [19750]   = { index = 23, },               -- 圣光闪现
    [200025]  = { index = 24, failed = true }, -- 美德道标
    [114165]  = { index = 25, },               -- 神圣棱镜
    -- 武僧
    [322109]  = { index = 1, failed = true },  -- 轮回之触
    [119381]  = { index = 2, failed = true },  -- 扫堂腿
    [101643]  = { index = 3, failed = true },  -- 魂体双分
    [119996]  = { index = 4, failed = true },  -- 转移
    [116849]  = { index = 5, failed = true },  -- 作茧缚命
    [115310]  = { index = 6, failed = true },  -- 还魂术
    [116844]  = { index = 7, failed = true },  -- 平心之环
    [115078]  = { index = 8, failed = true },  -- 分筋错骨
    [132578]  = { index = 9, failed = true },  -- 玄牛下凡
    [100780]  = { index = 10, },               -- 猛虎掌
    [322729]  = { index = 11, },               -- 神鹤引项踢
    [205523]  = { index = 12, },               -- 幻灭踢
    [325153]  = { index = 13, },               -- 爆炸酒桶
    [123986]  = { index = 14, },               -- 真气爆裂
    [121253]  = { index = 15, },               -- 醉酿投
    [115181]  = { index = 16, },               -- 火焰之息
    [116847]  = { index = 17, },               -- 碧玉疾风
    [117952]  = { index = 18, },               -- 碎玉闪电
    [101546]  = { index = 19, },               -- 神鹤引项踢
    [100784]  = { index = 20, },               -- 幻灭踢
    [113656]  = { index = 21, },               -- 怒雷破
    [107428]  = { index = 22, },               -- 旭日东升踢
    [392983]  = { index = 23, },               -- 风领主之击
    [467307]  = { index = 24, },               -- 疾风呼啸踢
    [152175]  = { index = 25, },               -- 升龙霸
    [399491]  = { index = 26, },               -- 神龙之赐
    [116670]  = { index = 27, },               -- 活血术
    [115175]  = { index = 28, },               -- 抚慰之雾
    [443028]  = { index = 29, },               -- 天神御身
    [124682]  = { index = 30, },               -- 氤氲之雾
    [115294]  = { index = 31, },               -- 法力茶
    -- 战士
    [202168]  = { index = 1, failed = true },  -- 胜利在望
    [376079]  = { index = 2, failed = true },  -- 勇士之矛
    [6544]    = { index = 3, failed = true },  -- 英勇飞跃
    [97462]   = { index = 4, failed = true },  -- 集结呐喊
    [46968]   = { index = 5, failed = true },  -- 震荡波
    [107570]  = { index = 6, failed = true },  -- 风暴之锤
    [384110]  = { index = 7, failed = true },  -- 破裂投掷
    [64382]   = { index = 8, failed = true },  -- 碎裂投掷
    [5246]    = { index = 9, failed = true },  -- 破胆怒吼
    [385952]  = { index = 10, failed = true }, -- 盾牌冲锋
    [57755]   = { index = 11, },               -- 英勇投掷
    [6673]    = { index = 12, },               -- 战斗怒吼
    [1464]    = { index = 13, },               -- 猛击
    [772]     = { index = 14, },               -- 撕裂
    [281000]  = { index = 15, },               -- 斩杀
    [227847]  = { index = 16, },               -- 剑刃风暴
    [436358]  = { index = 17, },               -- 崩摧
    [12294]   = { index = 18, },               -- 致死打击
    [167105]  = { index = 19, },               -- 巨人打击
    [845]     = { index = 20, },               -- 顺劈斩
    [7384]    = { index = 21, },               -- 压制
    [260708]  = { index = 22, },               -- 横扫攻击
    [107574]  = { index = 23, },               -- 天神下凡
    [190411]  = { index = 24, },               -- 旋风斩
    [5308]    = { index = 25, },               -- 斩杀
    [23881]   = { index = 26, },               -- 嗜血
    [184367]  = { index = 27, },               -- 暴怒
    [385059]  = { index = 28, },               -- 奥丁之怒
    [85288]   = { index = 29, },               -- 怒击
    [6343]    = { index = 30, },               -- 雷霆一击
    [435222]  = { index = 31, },               -- 雷霆轰击
    [6572]    = { index = 32, },               -- 复仇
    [23922]   = { index = 33, },               -- 盾牌猛击
    [163201]  = { index = 34, },               -- 斩杀
    [1269383] = { index = 35, },               -- 英勇打击
    -- 死亡骑士
    [51052]   = { index = 1, failed = true },  -- 反魔法领域
    [221562]  = { index = 2, failed = true },  -- 窒息
    [207167]  = { index = 3, failed = true },  -- 致盲冰雨
    [42650]   = { index = 4, failed = true },  -- 亡者大军
    [206930]  = { index = 5, },                -- 心脏打击
    [43265]   = { index = 6, },                -- 枯萎凋零
    [195292]  = { index = 7, },                -- 死神的抚摸
    [49998]   = { index = 8, },                -- 灵界打击
    [49028]   = { index = 9, },                -- 符文刃舞
    [195182]  = { index = 10, },               -- 精髓分裂
    [50842]   = { index = 11, },               -- 血液沸腾
    [433895]  = { index = 12, },               -- 吸血鬼打击
    [46584]   = { index = 13, },               -- 亡者复生
    [47541]   = { index = 14, },               -- 凋零缠绕
    [55090]   = { index = 15, },               -- 天灾打击
    [207317]  = { index = 16, },               -- 扩散
    [77575]   = { index = 17, },               -- 爆发
    [85948]   = { index = 18, },               -- 脓疮打击
    [1247378] = { index = 19, },               -- 腐化
    [1233448] = { index = 20, },               -- 黑暗突变
    [343294]  = { index = 21, },               -- 灵魂收割
    [458128]  = { index = 22, },               -- 脓疮毒镰
    [108199]  = { index = 23, failed = true }, -- 血魔之握
    [1263569] = { index = 24, failed = true }, -- 憎恶附肢
    [439843]  = { index = 25, },               -- 死神印记
    [194913]  = { index = 26, },               -- 冰川突进
    [279302]  = { index = 27, },               -- 冰霜巨龙之怒
    [196770]  = { index = 28, },               -- 冷酷严冬
    [51271]   = { index = 29, },               -- 冰霜之柱
    [49143]   = { index = 30, },               -- 冰霜打击
    [49184]   = { index = 31, },               -- 凛风冲击
    [207230]  = { index = 32, },               -- 冰霜之镰
    [1249685] = { index = 33, },               -- 冰龙吐息
    [49020]   = { index = 34, },               -- 湮灭
    [47568]   = { index = 35, },               -- 符文武器增效
    [316239]  = { index = 36, },               -- 符文打击
    [1265384] = { index = 37, },               -- 冰霜巨龙之怒
    [1228433] = { index = 38, },               -- 冰霜灾祸
    -- 猎人
    [217200]  = { index = 1, },                -- 倒刺射击
    [34026]   = { index = 2, },                -- 杀戮命令
    [193455]  = { index = 3, },                -- 眼镜蛇射击
    [19574]   = { index = 4, },                -- 狂野怒火
    [201430]  = { index = 5, },                -- 荒野呼唤
    [131894]  = { index = 6, },                -- 夺命黑鸦
    [120360]  = { index = 7, },                -- 弹幕射击
    [321530]  = { index = 8, },                -- 血溅十方
    [19434]   = { index = 9, },                -- 瞄准射击
    [257044]  = { index = 10, },               -- 急速射击
    [56641]   = { index = 11, },               -- 稳固射击
    [2643]    = { index = 12, },               -- 多重射击
    [288613]  = { index = 13, },               -- 百发百中
    [53351]   = { index = 14, },               -- 夺命射击
    [212431]  = { index = 15, },               -- 爆炸射击
    [389831]  = { index = 16, },               -- 哀恸箭
    [257284]  = { index = 17, },               -- 猎人印记
    [185358]  = { index = 18, },               -- 奥术射击
    [342049]  = { index = 19, },               -- 奇美拉射击
    [883]     = { index = 20, },               -- 召唤宠物1
    [1264359] = { index = 21, },               -- 狂野鞭笞
    [109304]  = { index = 22, failed = true }, -- 意气风发
    [186265]  = { index = 23, },               -- 灵龟守护
    [147362]  = { index = 24, },               -- 反制射击
    [392060]  = { index = 25, },               -- 哀恸箭
    [466930]  = { index = 26, },               -- 黑蚀箭
    [19577]   = { index = 27, },               -- 胁迫
    [260243]  = { index = 28, },               -- 乱射
    [257620]  = { index = 29, },               -- 多重射击
    [259489]  = { index = 30, },               -- 杀戮命令
    [193265]  = { index = 31, },               -- 投掷手斧
    [1251592] = { index = 32, },               -- 燎焰沥青
    [1261193] = { index = 33, },               -- 爆裂火铳
    [1250646] = { index = 34, },               -- 狩魂一击
    [190925]  = { index = 35, },               -- 鱼叉猛刺
    [186270]  = { index = 36, },               -- 猛禽一击
    [259495]  = { index = 37, },               -- 野火炸弹
    [53480]   = { index = 38, },               -- 牺牲咆哮
    -- 恶魔猎手
    [198793]  = { index = 1, },                -- 复仇回避
    [185123]  = { index = 2, },                -- 投掷利刃
    [207684]  = { index = 3, failed = true },  -- 悲苦咒符
    [217832]  = { index = 4, failed = true },  -- 禁锢
    [258920]  = { index = 5, },                -- 献祭光环
    [179057]  = { index = 6, failed = true },  -- 混乱新星
    [191427]  = { index = 7, },                -- 恶魔变形
    [232893]  = { index = 8, },                -- 邪能之刃
    [188499]  = { index = 9, },                -- 刃舞
    [162794]  = { index = 10, },               -- 混乱打击
    [198589]  = { index = 11, },               -- 疾影
    [370965]  = { index = 12, },               -- 恶魔追击
    [198013]  = { index = 13, },               -- 眼棱
    [195072]  = { index = 14, },               -- 邪能冲撞
    [258860]  = { index = 15, },               -- 精华破碎
    [187827]  = { index = 16, failed = true }, -- 恶魔变形
    [189110]  = { index = 17, },               -- 地狱火撞击
    [203720]  = { index = 18, },               -- 恶魔尖刺
    [204021]  = { index = 19, failed = true }, -- 烈火烙印
    [247454]  = { index = 20, },               -- 幽魂炸弹
    [207407]  = { index = 21, },               -- 灵魂切削
    [204596]  = { index = 22, },               -- 烈焰咒符
    [390163]  = { index = 23, },               -- 怨念咒符
    [228477]  = { index = 24, },               -- 灵魂裂劈
    [263642]  = { index = 25, },               -- 破裂
    [212084]  = { index = 26, failed = true }, -- 邪能毁灭
    [202137]  = { index = 27, failed = true }, -- 沉默咒符
    [1234195] = { index = 28, failed = true }, -- 虚空新星
    [1217605] = { index = 29, },               -- 虚空变形
    [1245412] = { index = 30, },               -- 虚空之刃
    [1234796] = { index = 31, },               -- 变换
    [1226019] = { index = 32, },               -- 收割
    [473662]  = { index = 33, },               -- 吞噬
    [473728]  = { index = 34, },               -- 虚空射线
    [1246167] = { index = 35, },               -- 恶魔追击
    [1239123] = { index = 36, },               -- 饥渴斩击
    [1245453] = { index = 37, },               -- 剔除
    [201427]  = { index = 38, },               -- 毁灭(混乱打击)
    [210152]  = { index = 39, },               -- 死亡横扫(刃舞)
    [452487]  = { index = 46, },               -- 吞噬之焰(献祭光环)
    [427917]  = { index = 41, },               -- 献祭光环
    [204157]  = { index = 42, },               -- 投掷利刃
    [196718]  = { index = 43, failed = true }, -- 黑暗

    -- 萨满
    [457481]  = { index = 1, },                -- 唤潮者的护卫
    [382021]  = { index = 2, },                -- 大地生命武器
    [462854]  = { index = 3, },                -- 天怒
    [52127]   = { index = 4, },                -- 水之护盾
    [470411]  = { index = 5, },                -- 烈焰震击
    [51505]   = { index = 6, },                -- 熔岩爆裂
    [188196]  = { index = 7, },                -- 闪电箭
    [188443]  = { index = 8, },                -- 闪电链
    [5394]    = { index = 9, },                -- 治疗之泉图腾
    [57994]   = { index = 10, },               -- 风剪
    [443454]  = { index = 11, },               -- 先祖迅捷
    [378081]  = { index = 12, },               -- 自然迅捷
    [444995]  = { index = 13, failed = true }, -- 涌动图腾
    [192058]  = { index = 14, failed = true }, -- 电能图腾
    [192063]  = { index = 15, failed = true }, -- 阵风
    [98008]   = { index = 16, failed = true }, -- 灵魂链接图腾
    [198103]  = { index = 17, failed = true }, -- 土元素
    [8143]    = { index = 18, failed = true }, -- 战栗图腾
    [383013]  = { index = 19, failed = true }, -- 清毒图腾
    [108287]  = { index = 20, failed = true }, -- 图腾投射
    [114052]  = { index = 21, failed = true }, -- 升腾
    [108280]  = { index = 22, failed = true }, -- 治疗之潮图腾
    [187874]  = { index = 23, },               -- 毁灭闪电
    [470057]  = { index = 24, },               -- 流电炽焰
    [318038]  = { index = 25, },               -- 火舌武器
    [60103]   = { index = 26, },               -- 熔岩猛击
    [197214]  = { index = 27, },               -- 裂地术
    [1218090] = { index = 28, },               -- 始源风暴
    [115356]  = { index = 29, },               -- 风切
    [33757]   = { index = 30, },               -- 风怒武器
    [17364]   = { index = 31, },               -- 风暴打击
    [452201]  = { index = 32, },               -- 狂风怒号
    [117014]  = { index = 33, },               -- 元素冲击
    [462620]  = { index = 34, },               -- 地震术
    [8042]    = { index = 35, },               -- 大地震击
    [191634]  = { index = 36, },               -- 风暴守护者
    [192106]  = { index = 37, },               -- 闪电之盾
    [77472]   = { index = 38, },               -- 治疗波
    [1064]    = { index = 39, },               -- 治疗链
    [61295]   = { index = 40, },               -- 激流
    [974]     = { index = 41, },               -- 大地之盾
    [77130]   = { index = 42, },               -- 净化灵魂
    [73685]   = { index = 43, },               -- 生命释放
}
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
    ["冰川尖刺！"] = {
        name = "冰川尖刺！",
        spellId = 1222865,
        remaining = 0,
        duration = 120,
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
        duration = 30,
        expirationTime = nil,
    },
    ["玄牛之力"] = {
        name = "玄牛之力",
        spellId = 443112,
        remaining = 0,
        duration = 30,
        expirationTime = nil,
    },
    ["青龙之心"] = {
        name = "青龙之心",
        spellId = 443421,
        remaining = 0,
        duration = 4,
        expirationTime = nil,
    },
    -- 战士
    ["盾牌格挡"] = {
        name = "盾牌格挡",
        spellId = 132404,
        remaining = 0,
        duration = 8,
        expirationTime = nil,
    },
    -- 萨满祭司
    ["潮汐奔涌"] = {
        name = "潮汐奔涌",
        spellId = 53390,
        remaining = 0,
        duration = 15,
        count = 0,
        countMin = 0,
        countMax = 2,
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
        [1222865] = { { name = "冰川尖刺！" } },
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
        [443112] = { { name = "玄牛之力" } },
        [443421] = { { name = "青龙之心" } },
        -- 战士
        [132404] = { { name = "盾牌格挡" } },
        -- 萨满祭司
        [53390] = { { name = "潮汐奔涌", step = 1 } },
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

    },
    -- SPELL_ACTIVATION_OVERLAY_HIDE
    -- 屏幕提示事件, 检测参数: 法术ID
    byActivationOverlay = {
        [223819] = { name = "神圣意志", auraID = 223819 },
        [114255] = { name = "圣光涌动", auraID = 114255 },
        [54149] = { name = "圣光灌注", auraID = 54149 },
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
        [458128] = { -- 脓疮毒镰
            { name = "次级食尸鬼", auraID = 1254252, step = 1.5 },
            { name = "脓疮毒镰", auraID = 458123 }
        },
        [55090] = { { name = "次级食尸鬼", auraID = 1254252, step = -1, } }, -- 天灾打击
        [433895] = { { name = "次级食尸鬼", auraID = 1254252, step = -1, } }, -- 吸血鬼打击
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
        [199786] = { { name = "冰川尖刺！", auraID = 1222865 } },
        -- 冰风暴
        [44614] = { { name = "冰冷智慧", auraID = 190446 } },
        -- 圣光术
        [82326] = { { name = "神性之手", auraID = 414273, step = -1 } },
        -- 圣光闪现
        [19750] = { { name = "圣光灌注", auraID = 54149, step = -1 } },
        -- 审判
        [275773] = { { name = "圣光灌注", auraID = 54149, step = -1 } },
        -- 荣耀圣令
        [85673] = { { name = "闪耀之光", auraID = 327510, step = -1 } },
        -- 真言术：耀
        [194509] = { { name = "福音", auraID = 472433, step = -1 } },
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
        -- 氤氲之雾
        [124682] = {
            { name = "生生不息1", auraID = 197919 },
            { name = "玄牛之力", auraID = 443112 },
        },
        -- 神龙之赐
        [399491] = {
            { name = "神龙之赐", auraID = 399496 },
            { name = "生生不息2", auraID = 197919 } },
        -- 旭日东升踢
        [107428] = { { name = "生生不息1", auraID = 197919 } },
        -- 治疗波
        [77472] = { { name = "潮汐奔涌", auraID = 53390, step = -1 } },
        -- 治疗链
        [1064] = { { name = "潮汐奔涌", auraID = 53390, step = -1, castBar = true } },
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
        [2061] = {
            name = "祈福",
            auraID = 1262766,
            spellId = 2061,
            overrideSpellID = 1262763
        },
    }
}
-- 英雄天赋
fu.heroTalent = {
    -- 术士
    [445486] = 1, -- 地狱召唤者
    [449614] = 2, -- 灵魂收割者
    [428514] = 3, -- 恶魔使徒
    -- 武僧
    [450508] = 1, -- 祥和宗师
    [450615] = 2, -- 影踪派
    [443028] = 3, -- 天神御师
    [123904] = 3, -- 天神御师
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
-- 专精范围
fu.rangeSpecID = {
    -- Death Knight
    [250] = 15,  -- 鲜血
    [251] = 15,  -- 冰霜
    [252] = 15,  -- 邪恶
    [1455] = 15, -- Initial
    -- Demon Hunter
    [577] = 15,  -- 浩劫
    [581] = 15,  -- 复仇
    [1480] = 25, -- 噬灭
    [1456] = 15, -- Initial
    -- Druid
    [102] = 46,  -- 平衡
    [103] = 15,  -- 野性
    [104] = 15,  -- 守护
    [105] = 46,  -- 恢复
    [1447] = 15, -- Initial
    -- Evoker
    [1467] = 30, -- 湮灭
    [1468] = 30, -- 恩护
    [1473] = 30, -- 增辉
    [1465] = 15, -- Initial
    -- Hunter
    [253] = 46,  -- 兽王
    [254] = 46,  -- 射击
    [255] = 15,  -- 生存
    [1448] = 15, -- Initial
    -- Mage
    [62] = 46,   -- 奥术
    [63] = 46,   -- 火焰
    [64] = 46,   -- 冰霜
    [1449] = 15, -- Initial
    -- Monk
    [268] = 10,  -- 酒仙
    [270] = 10,  -- 织雾
    [269] = 10,  -- 踏风
    [1450] = 10, -- Initial
    -- Paladin
    [65] = 30,   -- 神圣
    [66] = 15,   -- 防护
    [70] = 25,   -- 惩戒
    [1451] = 25, -- Initial
    -- Priest
    [256] = 46,  -- 戒律
    [257] = 46,  -- 神圣
    [258] = 46,  -- 暗影
    [1452] = 46, -- Initial
    -- Rogue
    [259] = 15,  -- 刺杀
    [260] = 15,  -- 狂徒
    [261] = 15,  -- 敏锐
    [1453] = 15, -- Initial
    -- Shaman
    [262] = 46,  -- 元素
    [263] = 15,  -- 增强
    [264] = 46,  -- 恢复
    [1444] = 46, -- Initial
    -- Warlock
    [265] = 46,  -- 痛苦
    [266] = 46,  -- 恶魔
    [267] = 46,  -- 毁灭
    [1454] = 46, -- Initial
    -- Warrior
    [71] = 15,   -- 武器
    [72] = 15,   -- 狂怒
    [73] = 15,   -- 防护
    [1446] = 15, -- Initial
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
