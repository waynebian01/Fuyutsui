# -*- coding: utf-8 -*-
"""牧师职业的逻辑决策（戒律 / 神牧 / 暗影）。"""

from utils import *

# 将需要驱散的首领 ID
need_dispel_bosses = {4, 5}
# 不需要驱散的首领 ID
no_dispel_bosses = {64}
# 法术失败列表
failed_spell_map = {
    1: "心灵尖啸",
    2: "群体驱散",
    3: "真言术：障",
    4: "终极苦修",
    5: "神圣化身",
    6: "光晕",
    7: "神圣赞美诗",
    8: "虚空形态",
    9: "吸血鬼的拥抱",
}
action_map = {
    19: ("吸血鬼之触", "吸血鬼之触"),
    11: ("心灵震爆", "心灵震爆"),
    13: ("暗言术：灭", "暗言术：灭"),
    14: ("暗言术：痛", "暗言术：痛"),
    21: ("暗言术：癫", "暗言术：癫"),
    22: ("精神鞭笞", "精神鞭笞"),
    8: ("虚空形态", "虚空形态"),
    23: ("虚空洪流", "虚空洪流"),
    24: ("触须猛击", "触须猛击"),
    25: ("虚空冲击", "虚空冲击"),
    26: ("虚空齐射", "虚空齐射"),
    27: ("精神鞭笞：狂", "精神鞭笞"),
    28: ("光晕", "光晕"),
}
# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None

# 戒律
def _priest_discipline_logic(state_dict):
    action_hotkey = None
    current_step = "无匹配技能"
    
    spells = state_dict.get("spells") or {}
    战斗 = state_dict.get("战斗")
    移动 = state_dict.get("移动")
    施法 = state_dict.get("施法")
    引导 = state_dict.get("引导")
    生命值 = state_dict.get("生命值")
    能量值 = state_dict.get("能量值")
    一键辅助 = state_dict.get("一键辅助")
    法术失败 = state_dict.get("法术失败", 0)
    目标类型 = state_dict.get("目标类型", 0)
    队伍类型 = int(state_dict.get("队伍类型", 0) or 0)
    队伍人数 = int(state_dict.get("队伍人数", 0) or 0)
    首领战 = int(state_dict.get("首领战", 0) or 0)
    难度 = int(state_dict.get("难度", 0) or 0)
    英雄天赋 = int(state_dict.get("英雄天赋", 0) or 0)

    施法技能 = state_dict.get("施法技能", 0)
    施法目标 = state_dict.get("施法目标", 0)

    虚空之盾 = state_dict.get("虚空之盾", 0)
    圣光涌动 = state_dict.get("圣光涌动", 0)
    涌动层数 = state_dict.get("涌动层数", 0)
    熵能裂隙 = state_dict.get("熵能裂隙", 0)    
    福音层数 = state_dict.get("福音层数", 0)
    暗影愈合 = state_dict.get("暗影愈合", 0)
    暗影层数 = state_dict.get("暗影层数", 0)

    心灵尖啸 = spells.get("心灵尖啸", -1)
    群体驱散 = spells.get("群体驱散", -1)
    纯净术 = spells.get("纯净术", -1)
    绝望祷言 = spells.get("绝望祷言", -1)
    奥术洪流 = spells.get("奥术洪流", -1)
    苦修 = spells.get("苦修", -1)
    苦修充能 = spells.get("苦修充能", -1)
    耀 = spells.get("真言术：耀", -1)
    耀充能 = spells.get("耀充能", -1)
    盾 = spells.get("真言术：盾", -1)
    障 = spells.get("真言术：障", -1)
    福音 = spells.get("福音", -1)
    心灵震爆 = spells.get("心灵震爆", -1)
    灭 = spells.get("暗言术：灭", -1)
    
    失败法术 = _get_failed_spell(state_dict)

    治疗限值 = int(60 + (能量值 * 0.3)) # 90-60
    暗影愈合阈值 = int(70 - (暗影愈合 * 2) + (暗影层数 * 15)) # 55 - 100
    涌动阈值 = int(80 - 圣光涌动 + (涌动层数 * 10)) # 70 - 80

    dispel_unit_magic, _ = get_unit_with_dispel_type(state_dict, 1)
    dispel_unit_disease, _ = get_unit_with_dispel_type(state_dict, 3)
    最低单位, 最低生命值 = get_lowest_health_unit(state_dict, 100)
    无救赎最低, 无救赎生命值 = get_lowest_health_unit_without_aura(state_dict, "救赎", 100)
    无盾最低, 无盾生命值 = get_lowest_health_unit_without_aura(state_dict, "真言术：盾", 101)
    无盾坦克, 无盾坦克生命值 = get_unit_with_role_and_without_aura_name(state_dict, 1, "真言术：盾")
    无救赎90数量 = count_units_without_aura_below_health(state_dict, "救赎", 90)
    有救赎数量 = count_units_with_aura(state_dict, "救赎")

    驱散单位 = None
    if dispel_unit_magic is not None:
        if 队伍类型 == 46 and 首领战 not in no_dispel_bosses:
            驱散单位 = dispel_unit_magic
        elif 队伍类型 <= 40 and 首领战 in need_dispel_bosses:
            驱散单位 = dispel_unit_magic
    if 驱散单位 is None:
        驱散单位 = dispel_unit_disease

    unit_info = {
        "暗影愈合阈值": 暗影愈合阈值,
        "驱散单位": 驱散单位,
        "最低单位": 最低单位,
        "最低生命值": 最低生命值,
        "无救赎最低": 无救赎最低,
        "无救赎生命值": 无救赎生命值,
        "无盾最低": 无盾最低,    
        "无盾生命值": 无盾生命值,
        "无盾坦克": 无盾坦克,
        "无盾坦克生命值": 无盾坦克生命值,    
    }

    if 引导 > 0:
        current_step = "引导,不执行任何操作"
    elif 绝望祷言 == 0 and 生命值 < 50:
        current_step = "施放 绝望祷言"
        action_hotkey = get_hotkey(0, "绝望祷言")
    elif 奥术洪流 == 0 and 能量值 <= 90:
        current_step = "施放 奥术洪流"
        action_hotkey = get_hotkey(0, "奥术洪流")
    elif 一键辅助 == 10:
        current_step = "施放 真言术：韧"
        action_hotkey = get_hotkey(0, "真言术：韧")
    elif 法术失败 != 0 and 失败法术 is not None:
        current_step = f"施放 {失败法术}"
        action_hotkey = get_hotkey(0, 失败法术)
    elif 英雄天赋 == 1:
        if 队伍类型 <= 40:
            if 纯净术 == 0 and 驱散单位 is not None:
                current_step = f"施放 纯净术 on {驱散单位}"
                action_hotkey = get_hotkey(int(驱散单位), "纯净术")
            elif 1 <= 目标类型 <= 3 and 战斗 and 一键辅助 == 14:
                current_step = "施放 暗言术：痛"
                action_hotkey = get_hotkey(0, "暗言术：痛")
            elif 无救赎90数量 >= 5 and 耀 == 0 and 福音层数 > 0:
                current_step = "施放 真言术：耀"
                action_hotkey = get_hotkey(0, "真言术：耀")
            elif 无救赎90数量 >= 5 and 福音 == 0:
                current_step = "施放 福音"
                action_hotkey = get_hotkey(0, "福音")
            elif 圣光涌动 > 0 and 无救赎最低 is not None and 无救赎生命值 is not None and 无救赎生命值 < 90:
                current_step = f"施放 快速治疗 on {无救赎最低}, 无救赎生命低于90%的单位"
                action_hotkey = get_hotkey(int(无救赎最低), "快速治疗")
            elif 圣光涌动 > 0 and 最低单位 is not None and 最低生命值 is not None and 最低生命值 < 70:
                current_step = f"施放 快速治疗 on {最低单位}, 生命最低的单位"
                action_hotkey = get_hotkey(int(最低单位), "快速治疗")
            elif 暗影愈合 > 0 and 暗影层数 > 0 and 施法技能 != 34 and 最低单位 is not None and 最低生命值 is not None and 最低生命值 < 暗影愈合阈值:
                current_step = f"施放 暗影愈合 on {最低单位}, 暗影愈合"
                action_hotkey = get_hotkey(int(最低单位), "快速治疗")
            elif 盾 == 0 and 无救赎最低 and 无救赎生命值 is not None and (无救赎生命值 < 治疗限值 or 虚空之盾 > 0):
                current_step = f"施放 真言术：盾 on {无救赎最低}, 无救赎单位"
                action_hotkey = get_hotkey(int(无救赎最低), "真言术：盾")
            elif 盾 == 0 and 无盾最低 and 无盾生命值 is not None and (无盾生命值 < 治疗限值 or 虚空之盾 > 0):
                current_step = f"施放 真言术：盾 on {无盾最低}, 无盾生命最低的单位"
                action_hotkey = get_hotkey(int(无盾最低), "真言术：盾")
            elif 盾 == 0 and 无盾坦克 is not None:
                current_step = f"施放 真言术：盾 on {无盾坦克}, 无盾单位"
                action_hotkey = get_hotkey(int(无盾坦克), "真言术：盾")
            elif 无救赎90数量 >= 5 and 耀 == 0 and 施法技能 != 30:
                current_step = "施放 真言术：耀"
                action_hotkey = get_hotkey(0, "真言术：耀")
            elif 苦修 == 0 and 最低单位 is not None and 最低生命值 is not None and 最低生命值 < 75:
                current_step = f"施放 苦修 on {最低单位}, 生命最低的单位"
                action_hotkey = get_hotkey(int(最低单位), "苦修")
            elif 1 <= 目标类型 <= 3 and 战斗:
                if 灭 == 0 and 有救赎数量 > 0:
                    current_step = "施放 暗言术：灭"
                    action_hotkey = get_hotkey(0, "暗言术：灭")
                elif not 移动 and 心灵震爆 == 0 and 有救赎数量 > 0:
                    current_step = "施放 心灵震爆"
                    action_hotkey = get_hotkey(0, "心灵震爆")
                elif 苦修 == 0 and 有救赎数量 > 0:
                    current_step = "施放 苦修"
                    action_hotkey = get_hotkey(0, "苦修")
                elif not 移动:
                    current_step = "施放 惩击"
                    action_hotkey = get_hotkey(0, "惩击")
                else:
                    current_step = "战斗中-无匹配技能"
        elif 队伍类型 == 46:
            if 纯净术 == 0 and 驱散单位 is not None:
                current_step = f"施放 纯净术 on {驱散单位}"
                action_hotkey = get_hotkey(int(驱散单位), "纯净术")
            elif 1 <= 目标类型 <= 3 and 战斗 and 一键辅助 == 14:
                current_step = "施放 暗言术：痛"
                action_hotkey = get_hotkey(0, "暗言术：痛")
            elif 无救赎90数量 >= 2 and 耀 == 0 and 福音层数 > 0:
                current_step = "施放 真言术：耀"
                action_hotkey = get_hotkey(0, "真言术：耀")
            elif 无救赎90数量 >= 2 and 福音 == 0:
                current_step = "施放 福音"
                action_hotkey = get_hotkey(0, "福音")
            elif 圣光涌动 > 0 and 涌动层数 > 0 and 无救赎最低 is not None and 无救赎生命值 is not None and 无救赎生命值 < 90:
                current_step = f"施放 快速治疗 on {无救赎最低}, 无救赎生命低于90%的单位"
                action_hotkey = get_hotkey(int(无救赎最低), "快速治疗")
            elif 圣光涌动 > 0 and 涌动层数 > 0 and 最低单位 is not None and 最低生命值 is not None and 最低生命值 < 涌动阈值:
                current_step = f"施放 快速治疗 on {最低单位}, 生命最低的单位"
                action_hotkey = get_hotkey(int(最低单位), "快速治疗")
            elif 暗影愈合 > 0 and 暗影层数 > 0 and 施法技能 != 34 and 最低单位 is not None and 最低生命值 is not None and 最低生命值 < 暗影愈合阈值:
                current_step = f"施放 暗影愈合 on {最低单位}, 暗影愈合"
                action_hotkey = get_hotkey(int(最低单位), "快速治疗")
            elif 盾 == 0 and 无救赎最低 and 无救赎生命值 is not None and (无救赎生命值 < 90 or 虚空之盾 > 0):
                current_step = f"施放 真言术：盾 on {无救赎最低}, 无救赎单位"
                action_hotkey = get_hotkey(int(无救赎最低), "真言术：盾")
            elif 盾 == 0 and 无盾最低 and 无盾生命值 is not None and (无盾生命值 < 90 or 虚空之盾 > 0):
                current_step = f"施放 真言术：盾 on {无盾最低}, 无盾生命最低的单位"
                action_hotkey = get_hotkey(int(无盾最低), "真言术：盾")
            elif 盾 == 0 and 无盾坦克 is not None:
                current_step = f"施放 真言术：盾 on {无盾坦克}, 无盾单位"
                action_hotkey = get_hotkey(int(无盾坦克), "真言术：盾")
            elif 无救赎90数量 >= 3 and 耀 == 0 and 施法技能 != 30:
                current_step = "施放 真言术：耀"
                action_hotkey = get_hotkey(0, "真言术：耀")
            elif 苦修 == 0 and 最低单位 is not None and 最低生命值 is not None and 最低生命值 < 75:
                current_step = f"施放 苦修 on {最低单位}, 生命最低的单位"
                action_hotkey = get_hotkey(int(最低单位), "苦修")
            elif 1 <= 目标类型 <= 3 and 战斗:
                if 灭 == 0 and 有救赎数量 > 0:
                    current_step = "施放 暗言术：灭"
                    action_hotkey = get_hotkey(0, "暗言术：灭")
                elif not 移动 and 心灵震爆 == 0 and 有救赎数量 > 0:
                    current_step = "施放 心灵震爆"
                    action_hotkey = get_hotkey(0, "心灵震爆")
                elif 苦修 == 0 and 有救赎数量 > 0:
                    current_step = "施放 苦修"
                    action_hotkey = get_hotkey(0, "苦修")
                elif not 移动:
                    current_step = "施放 惩击"
                    action_hotkey = get_hotkey(0, "惩击")
                else:
                    current_step = "战斗中-无匹配技能"

    elif 英雄天赋 == 2:
        if 战斗:
            if 目标类型 and 一键辅助 == 14:
                current_step = "施放 暗言术：痛"
                action_hotkey = get_hotkey(0, "暗言术：痛")
            elif 1 <= 目标类型 <= 3 and 熵能裂隙 > 0 and 苦修 == 0:
                current_step = "施放 苦修"
                action_hotkey = get_hotkey(0, "苦修")
            elif 盾 == 0  and 无救赎最低 is not None and 无救赎生命值 < 99:
                current_step = f"施放 真言术：盾 on {无救赎最低}, 无救赎生命最低的单位, 有虚空之盾"
                action_hotkey = get_hotkey(int(无救赎最低), "真言术：盾")
            elif 圣光涌动 > 0 and 无救赎最低 is not None and 无救赎生命值 < 90:
                current_step = f"施放 快速治疗 on {无救赎最低}, 无救赎生命低于90%的单位"
                action_hotkey = get_hotkey(int(无救赎最低), "快速治疗")
            elif 福音 == 0 and (无救赎90数量 >= 4 or (队伍类型 == 46 and 无救赎90数量 >= 1)):
                current_step = "施放 福音"
                action_hotkey = get_hotkey(0, "福音")
            elif 耀 == 0 and 施法 == 0 and (无救赎90数量 >= 4 or (队伍类型 == 46 and 无救赎90数量 >= 1)):
                current_step = "施放 真言术：耀"
                action_hotkey = get_hotkey(0, "真言术：耀")
            elif 灭 == 0:
                current_step = "施放 暗言术：灭"
                action_hotkey = get_hotkey(0, "暗言术：灭")
            elif not 移动 and 心灵震爆 == 0:
                current_step = "施放 心灵震爆"
                action_hotkey = get_hotkey(0, "心灵震爆")
            elif not 移动 and 1 <= 目标类型 <= 3 and 熵能裂隙 > 0:
                current_step = "施放 惩击"
                action_hotkey = get_hotkey(0, "惩击")
            elif 盾 == 0 and 无救赎最低 is not None and 无救赎生命值 < 90:
                current_step = f"施放 真言术：盾 on {无救赎最低}, 无救赎生命最低的单位"
                action_hotkey = get_hotkey(int(无救赎最低), "真言术：盾")   
            elif 1 <= 目标类型 <= 3 and 苦修 == 0 and 虚空之盾 == 0:
                current_step = "施放 苦修"
                action_hotkey = get_hotkey(0, "苦修")
            elif 1 <= 目标类型 <= 3:
                current_step = "施放 惩击"
                action_hotkey = get_hotkey(0, "惩击")

    return action_hotkey, current_step, unit_info

# 神圣
def _priest_holy_logic(state_dict):
    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    spells = state_dict.get("spells") or {}
    战斗 = state_dict.get("战斗")
    移动 = state_dict.get("移动")
    施法 = state_dict.get("施法")
    引导 = state_dict.get("引导")
    生命值 = state_dict.get("生命值")
    能量值 = state_dict.get("能量值")
    一键辅助 = state_dict.get("一键辅助")
    法术失败 = state_dict.get("法术失败", 0)
    目标类型 = state_dict.get("目标类型")
    队伍类型 = int(state_dict.get("队伍类型", 0) or 0)
    队伍人数 = int(state_dict.get("队伍人数", 0) or 0)
    首领战 = int(state_dict.get("首领战", 0) or 0)
    难度 = int(state_dict.get("难度", 0) or 0)
    英雄天赋 = int(state_dict.get("英雄天赋", 0) or 0)

    施法技能 = state_dict.get("施法技能", 0)
    施法目标 = state_dict.get("施法目标", 0)

    织光者 = state_dict.get("织光者", 0)
    织光层数 = state_dict.get("织光层数", 0)
    圣光涌动 = state_dict.get("圣光涌动", 0)
    祈福 = state_dict.get("祈福", 0)
    
    愈合祷言_cd = spells.get("愈合祷言", -1)
    静_cd = spells.get("圣言术：静", -1)
    静_charge = spells.get("静充能", -1)
    罚_cd = spells.get("圣言术：罚", -1)
    纯净术 = spells.get("纯净术", -1)
    绝望祷言_cd = spells.get("绝望祷言", -1)
    神圣化身_cd = spells.get("神圣化身", -1)
    光晕_cd = spells.get("光晕", -1)
    神圣赞美诗_cd = spells.get("神圣赞美诗", -1)
    神圣之火_cd = spells.get("神圣之火", -1)
    心灵尖啸_cd = spells.get("心灵尖啸", -1)
    群体驱散_cd = spells.get("群体驱散", -1)
    奥术洪流_cd = spells.get("奥术洪流", -1)

    dispel_magic_unit, _ = get_unit_with_dispel_type(state_dict, 1)
    dispel_unit_disease, _ = get_unit_with_dispel_type(state_dict, 3)
    lowest_u, lowest_p = get_lowest_health_unit(state_dict, 100)
    no_mend_u, no_mend_p = get_lowest_health_unit_without_aura(state_dict, "愈合祷言", 101)
    no_mend_tank, no_mend_tank_pct = get_unit_with_role_and_without_aura_name(state_dict, 1, "愈合祷言")
    count90 = get_count_units_below_health(state_dict, 90)
    count80 = get_count_units_below_health(state_dict, 80)
    count60 = get_count_units_below_health(state_dict, 60)
    
    if 施法技能 == 32 and 织光层数 > 0:
        织光层数 -= 1
    if 施法技能 == 29 or 施法技能 == 33:
        织光层数 += 1

    
    治疗限值 = int(60 + (能量值 * 0.3)) # 90-60
    群疗限值数量 = get_count_units_below_health(state_dict, 治疗限值)
    群疗限值2数量 = get_count_units_below_health(state_dict, 治疗限值 - 10)
    失败法术 = _get_failed_spell(state_dict)
    
    # 战斗逻辑
    def _combat_filler():
        nonlocal current_step, action_hotkey
        if not 移动 and 神圣之火_cd == 0:
            current_step = "施放 神圣之火"
            action_hotkey = get_hotkey(0, "神圣之火")
        elif not 移动:
            current_step = "施放 惩击"
            action_hotkey = get_hotkey(0, "惩击")
        else:
            current_step = "战斗中-无匹配技能"

    # 愈合祷言逻辑
    def _mending_filler():
        nonlocal current_step, action_hotkey
        if 愈合祷言_cd == 0 and no_mend_u is not None and no_mend_p is not None and no_mend_p < 95:
            current_step = f"施放 愈合祷言 on {no_mend_u}, 无愈合祷言生命低于95%的单位"
            action_hotkey = get_hotkey(int(no_mend_u), "愈合祷言")
        elif 愈合祷言_cd == 0 and no_mend_tank is not None:
            current_step = f"施放 愈合祷言 on {no_mend_tank}, 无愈合祷言坦克"
            action_hotkey = get_hotkey(int(no_mend_tank), "愈合祷言")
        elif 愈合祷言_cd == 0 and no_mend_u is not None:
            current_step = f"施放 愈合祷言 on {no_mend_u}, 无愈合祷言的单位"
            action_hotkey = get_hotkey(int(no_mend_u), "愈合祷言")
        else:
            current_step = f"施放 愈合祷言 on 玩家"
            action_hotkey = get_hotkey(1, "愈合祷言")

    驱散单位 = None
    if dispel_magic_unit is not None:
        if 队伍类型 == 46 and 首领战 not in no_dispel_bosses:
            驱散单位 = dispel_magic_unit
        elif 队伍类型 <= 40 and 首领战 in need_dispel_bosses:
            驱散单位 = dispel_magic_unit
    if 驱散单位 is None:
        驱散单位 = dispel_unit_disease

    if 引导 > 0:
        current_step = "引导,不执行任何操作"
    elif 绝望祷言_cd == 0 and 生命值 < 50:
        current_step = "施放 绝望祷言"
        action_hotkey = get_hotkey(0, "绝望祷言")
    elif 奥术洪流_cd == 0 and 能量值 <= 90:
        current_step = "施放 奥术洪流"
        action_hotkey = get_hotkey(0, "奥术洪流")
    elif 一键辅助 == 10:
        current_step = "施放 真言术：韧"
        action_hotkey = get_hotkey(0, "真言术：韧")
    elif 法术失败 != 0 and 失败法术 is not None:
        current_step = f"施放 {失败法术}"
        action_hotkey = get_hotkey(0, 失败法术)
    elif 英雄天赋 == 3:
        if 队伍类型 <= 40:
            # 驱散
            if 纯净术 == 0 and 驱散单位 is not None:
                current_step = f"施放 纯净术 on {驱散单位}"
                action_hotkey = get_hotkey(int(驱散单位), "纯净术")
            elif 目标类型 == 12:
                current_step = f"施放 纯净术 on 目标"
                action_hotkey = get_hotkey(0, "纯净术")
            # 愈合祷言
            elif 愈合祷言_cd == 0:
                _mending_filler()
             # 光晕
            elif 施法技能 != 17 and count90 >= 2 and 光晕_cd == 0:
                current_step = "施放 光晕"
                action_hotkey = get_hotkey(0, "光晕")
            elif lowest_u is not None and lowest_p is not None and lowest_p < 治疗限值:
                # 圣言术：静
                if 静_charge <= 3 and lowest_p < 治疗限值 - 10:
                    current_step = f"施放 圣言术：静 on {lowest_u}, 生命低于80%的单位"
                    action_hotkey = get_hotkey(int(lowest_u), "圣言术：静")
                elif 静_cd == 0 and lowest_p < 治疗限值 - 20:
                    current_step = f"施放 圣言术：静 on {lowest_u}, 生命低于60%的单位"
                    action_hotkey = get_hotkey(int(lowest_u), "圣言术：静")
                # 神圣化身
                elif 神圣化身_cd == 0 and 群疗限值数量 >= 3 and 静_cd > 5:
                    current_step = "施放 神圣化身"
                    action_hotkey = get_hotkey(0, "神圣化身")
                # 治疗祷言
                elif 织光层数 > 0 and 圣光涌动 > 0 and 群疗限值数量 >= 3:
                    current_step = "施放 治疗祷言"
                    action_hotkey = get_hotkey(0, "治疗祷言")
                elif 织光层数 > 0 and not 移动 and 施法技能 != 32 and 群疗限值数量 >= 3:
                    current_step = "施放 治疗祷言"
                    action_hotkey = get_hotkey(0, "治疗祷言")
                elif 织光层数 > 0 and not 移动 and 施法技能 == 32 and (群疗限值2数量 > 3 or 群疗限值数量 >= 7):
                    current_step = "施放 治疗祷言"
                    action_hotkey = get_hotkey(0, "治疗祷言")
                # 快速治疗
                elif 织光层数 < 4:
                    current_step = f"施放 快速治疗 on {lowest_u}, 生命最低的单位"
                    action_hotkey = get_hotkey(int(lowest_u), "快速治疗")
                else:
                    if 目标类型 and 战斗:
                        _combat_filler()
            elif 1 <= 目标类型 <= 3 and 战斗:
                _combat_filler()

        elif 队伍类型 == 46: 
            # 纯净术
            if 纯净术 == 0 and 驱散单位 is not None:
                current_step = f"施放 纯净术 on {驱散单位}"
                action_hotkey = get_hotkey(int(驱散单位), "纯净术")
            elif 目标类型 == 12:
                current_step = f"施放 纯净术 on 目标"
                action_hotkey = get_hotkey(0, "纯净术")
            # 愈合祷言
            elif 愈合祷言_cd == 0:
                _mending_filler()
            # 治疗逻辑
            elif lowest_u is not None and lowest_p is not None and lowest_p < 90:
                # 圣言术：静
                if 静_charge <= 1 and lowest_p < 80:
                    current_step = f"施放 圣言术：静 on {lowest_u}, 生命低于80%的单位"
                    action_hotkey = get_hotkey(int(lowest_u), "圣言术：静")
                elif 静_cd == 0 and lowest_p < 60:
                    current_step = f"施放 圣言术：静 on {lowest_u}, 生命低于60%的单位"
                    action_hotkey = get_hotkey(int(lowest_u), "圣言术：静")
                # 神圣化身
                elif 战斗 and 神圣化身_cd == 0 and count80 >= 3 and 静_cd > 2:
                    current_step = "施放 神圣化身"
                    action_hotkey = get_hotkey(0, "神圣化身")
                # 光晕
                elif 战斗 and count90 >= 3 and 施法技能 != 6 and 光晕_cd == 0:
                    current_step = "施放 光晕"
                    action_hotkey = get_hotkey(0, "光晕")
                # 快速治疗, 仅在一个单位生命低于60%时使用
                elif 静_cd > 6 and count60 == 1 and lowest_p < 60:
                    current_step = f"施放 快速治疗 on {lowest_u}, 生命最低的单位"
                    action_hotkey = get_hotkey(int(lowest_u), "快速治疗")
                # 治疗祷言
                elif 施法技能 != 32 and 织光层数 > 0 and (圣光涌动 > 0 or 织光层数 == 4) and count90 >= 2:
                    current_step = "施放 治疗祷言"
                    action_hotkey = get_hotkey(0, "治疗祷言")
                elif 施法技能 == 32 and 织光层数 > 0 and (圣光涌动 > 0 or 织光层数 == 4) and count80 >= 2:
                    current_step = "施放 治疗祷言"
                    action_hotkey = get_hotkey(0, "治疗祷言")
                # 织光者, 织光层数为0时
                elif 织光层数 == 0:
                    current_step = f"施放 快速治疗 on {lowest_u}, 生命最低的单位"
                    action_hotkey = get_hotkey(int(lowest_u), "快速治疗")
                # 快速治疗
                else:
                    current_step = f"施放 快速治疗 on {lowest_u}, 生命最低的单位"
                    action_hotkey = get_hotkey(int(lowest_u), "快速治疗")
                
            elif 1 <= 目标类型 <= 3 and 战斗:
                _combat_filler()

    return action_hotkey, current_step, unit_info

# 暗影
def _priest_shadow_logic(state_dict):
    spells = state_dict.get("spells") or {}
    战斗 = state_dict.get("战斗")
    移动 = state_dict.get("移动")
    施法 = state_dict.get("施法")
    引导 = state_dict.get("引导")
    生命值 = state_dict.get("生命值")
    能量值 = state_dict.get("能量值")
    一键辅助 = state_dict.get("一键辅助")
    法术失败 = state_dict.get("法术失败", 0)
    目标类型 = state_dict.get("目标类型")
    队伍类型 = int(state_dict.get("队伍类型", 0) or 0)
    队伍人数 = int(state_dict.get("队伍人数", 0) or 0)
    首领战 = int(state_dict.get("首领战", 0) or 0)
    难度 = int(state_dict.get("难度", 0) or 0)
    英雄天赋 = int(state_dict.get("英雄天赋", 0) or 0)

    绝望祷言 = spells.get("绝望祷言", -1)
    心灵震爆 = spells.get("心灵震爆", -1)
    灭 = spells.get("暗言术：灭", -1)
    虚空洪流 = spells.get("虚空洪流", -1)
    虚空形态 = spells.get("虚空形态", -1)
    触须猛击 = spells.get("触须猛击", -1)
    吸血鬼的拥抱 = spells.get("吸血鬼的拥抱", -1)
    光晕 = spells.get("光晕", -1)
    虚空齐射 = spells.get("虚空齐射", -1)
    
    失败法术 = _get_failed_spell(state_dict)

    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}
    if 引导 > 0:
        if 战斗 and 1 <= 目标类型 <= 3 and 一键辅助 !=22:
            tup = action_map.get(一键辅助)
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"
    elif 绝望祷言 == 0 and 生命值 < 50:
        current_step = "施放 绝望祷言"
        action_hotkey = get_hotkey(0, "绝望祷言")
    elif 一键辅助 == 10:
        current_step = "施放 真言术：韧"
        action_hotkey = get_hotkey(0, "真言术：韧")
    elif 一键辅助 == 20:
        current_step = "施放 暗影形态"
        action_hotkey = get_hotkey(0, "暗影形态")
    elif 1 <= 目标类型 <= 3 and  虚空形态 == 0 and 法术失败 == 8:
        current_step = "施放 虚空形态"
        action_hotkey = get_hotkey(0, "虚空形态")
    elif 法术失败 != 0 and 失败法术 is not None:
        current_step = f"施放 {失败法术}"
        action_hotkey = get_hotkey(0, 失败法术)
    elif 战斗 and 1 <= 目标类型 <= 3:
        tup = action_map.get(一键辅助)
        if tup:
            current_step = f"施放 {tup[0]}"
            action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "战斗中-无匹配技能"
    return action_hotkey, current_step, unit_info

def run_priest_logic(state_dict, spec_name):
    if spec_name == "戒律":
        return _priest_discipline_logic(state_dict)
    elif spec_name == "神牧":
        return _priest_holy_logic(state_dict)
    elif spec_name == "暗影":
        return _priest_shadow_logic(state_dict)
    return None, "无匹配技能", {}
