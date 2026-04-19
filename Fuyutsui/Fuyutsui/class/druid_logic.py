# -*- coding: utf-8 -*-
"""德鲁伊职业的逻辑决策（奶德 / 守护）。"""

from utils import *
spell_map ={
    1: "台风",
    2: "夺魂咆哮",
    3: "乌索尔旋风",
    4: "自然迅捷",
    5: "月火术",
    6: "野性印记",
    7: "摧折",
    8: "明月普照",
    9: "横扫",
    10: "熊形态",
    11: "痛击",
    12: "裂伤",
    13: "赤红之月",
    14: "毁灭",
    15: "凶猛撕咬",
    16: "割裂",
    17: "撕碎",
    18: "斜掠",
    19: "愤怒",
    20: "愈合",
    21: "野性生长",
    22: "宁静",
}

# 将需要驱散的首领 ID
need_dispel_bosses = {4, 5}
# 不需要驱散的首领 ID
no_dispel_bosses = {64}
# 法术失败列表
failed_spell_map = {
    1: "台风",
    2: "夺魂咆哮",
    3: "乌索尔旋风",
    4: "自然迅捷",
}

action_map = {
    7: ("摧折", "摧折"),
    8: ("明月普照", "明月普照"),
    5: ("月火术", "月火术"),
    9: ("横扫", "横扫"),
    10: ("熊形态", "熊形态"),
    11: ("痛击", "痛击"),
    12: ("裂伤", "裂伤"),
    6: ("野性印记", "野性印记"),
    13: ("赤红之月", "月火术"),
    14: ("毁灭", "摧折"),
    15: ("凶猛撕咬", "凶猛撕咬"),
    16: ("割裂", "割裂"),
    17: ("撕碎", "撕碎"),
    18: ("斜掠", "斜掠"),
}

# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None

def run_druid_logic(state_dict, spec_name):
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
    失败法术 = _get_failed_spell(state_dict)

    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    if spec_name == "守护":
        狂暴充能 = spells.get("狂暴充能")
        狂暴回复 = spells.get("狂暴回复")
        铁鬃 = state_dict.get("铁鬃")
        梦境层数 = state_dict.get("梦境层数")
        姿态 = state_dict.get("姿态", 0)
        目标距离 = state_dict.get("目标距离", 0)
        队伍人数 = state_dict.get("队伍人数")
        tup = action_map.get(一键辅助)

        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 姿态 != 5:
                current_step = "施放 熊形态"
                action_hotkey = get_hotkey(0, "熊形态")
            elif 生命值 < 85 and 能量值 > 10 and 狂暴充能 < 3 and 狂暴回复 == 0:
                current_step = "施放 狂暴充能"
                action_hotkey = get_hotkey(0, "狂暴回复")
            elif 生命值 < 60 and 能量值 > 10 and 狂暴回复 < 1:
                current_step = "施放 狂暴回复"
                action_hotkey = get_hotkey(0, "狂暴回复")
            elif ((铁鬃 < 2 and 能量值 > 40) or 能量值 > 80):
                current_step = "施放 铁鬃"
                action_hotkey = get_hotkey(0, "铁鬃")
            elif 梦境层数 > 0 and 狂暴回复 > 15:
                current_step = "施放 愈合"
                action_hotkey = get_hotkey(1, "愈合")
            elif tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"
        else:
            current_step = "不执行任何操作"

    elif spec_name == "平衡":
        current_step = "平衡专精,不执行任何操作"
        return None, current_step, unit_info

    elif spec_name == "野性":
        current_step = "野性专精,不执行任何操作"
        return None, current_step, unit_info

    elif spec_name == "奶德":
        姿态 = state_dict.get("姿态", 0)
        目标距离 = state_dict.get("目标距离", 0)
        连击点 = state_dict.get("连击点", 0)
        施法技能 = state_dict.get("施法技能", 0)
        节能施法 = state_dict.get("节能施法", 0)
        丛林之魂 = state_dict.get("丛林之魂", 0)

        树皮术 = spells.get("树皮术", -1)
        野性成长 = spells.get("野性成长", -1)
        万灵之召 = spells.get("万灵之召", -1)
        迅捷治愈 = spells.get("迅捷治愈", -1)
        迅捷充能 = spells.get("迅捷充能", -1)
        自然之愈 = spells.get("自然之愈", -1)
        铁木树皮 = spells.get("铁木树皮", -1)
        自然迅捷 = spells.get("自然迅捷", -1)
        激活 = spells.get("激活", -1)
        野性之心 = spells.get("野性之心", -1)
        台风 = spells.get("台风", -1)
        夺魂咆哮 = spells.get("夺魂咆哮", -1)
        乌索尔旋风 = spells.get("乌索尔旋风", -1)

        dispel_unit_magic, _ = get_unit_with_dispel_type(state_dict, 1)
        dispel_unit_curse, _ = get_unit_with_dispel_type(state_dict, 2)
        dispel_unit_poison, _ = get_unit_with_dispel_type(state_dict, 4)

        治疗限值 = int(60 + (能量值 * 0.3)) # 90-60
        群疗限值数量 = get_count_units_below_health(state_dict, 治疗限值)
        群疗限值2数量 = get_count_units_below_health(state_dict, 治疗限值 - 10)

        最低, 血量最低 = get_lowest_health_unit(state_dict, 100)
        可迅捷最低, 可迅捷最低血量 = get_lowest_health_unit_with_aura(state_dict, "迅捷治愈", health_threshold=101)
        无愈合最低, 无愈合最低血量 = get_lowest_health_unit_without_aura(state_dict, "愈合", health_threshold=101)
        无回春最低, 无回春最低血量 = get_lowest_health_unit_with_aura_count(state_dict, "回春术", 0, health_threshold=101)
        单回春最低, 单回春血量最低 = get_lowest_health_unit_with_aura_count(state_dict, "回春术", 1, health_threshold=101)
        无绽放坦克, _ = get_unit_with_role_and_without_aura_name(state_dict, 1, "生命绽放", reverse=False)
        有绽放单位, 绽放时间 = get_unit_with_aura(state_dict, "生命绽放")
        count90 = count_units_below_health(state_dict, 90)
        count70 = count_units_below_health(state_dict, 70)
        tup = action_map.get(一键辅助)

        驱散单位 = None
        if dispel_unit_magic is not None:
            if 队伍类型 == 46 and 首领战 not in no_dispel_bosses:
                驱散单位 = dispel_unit_magic
            elif 队伍类型 <= 40 and 首领战 in need_dispel_bosses:
                驱散单位 = dispel_unit_magic
        if 驱散单位 is None:
            驱散单位 = dispel_unit_curse
        if 驱散单位 is None:
            驱散单位 = dispel_unit_poison

        unit_info = {
            "有魔法单位": dispel_unit_magic,
            "有诅咒单位": dispel_unit_curse,
            "有中毒单位": dispel_unit_poison,
            "最低单位": 最低,
            "最低血量": 血量最低,
            "可迅捷最低": 可迅捷最低,
            "可迅捷最低血量": 可迅捷最低血量,
            "无愈合最低": 无愈合最低,
            "无愈合最低血量": 无愈合最低血量,
            "无回春最低": 无回春最低,
            "无回春最低血量": 无回春最低血量,
            "单回春最低": 单回春最低,
            "单回春血量最低": 单回春血量最低,
            "无绽放坦克": 无绽放坦克,
            "有绽放单位": 有绽放单位,
            "绽放时间": 绽放时间,
            "count90": count90,
            "count70": count70,
        }

        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)
        elif 自然之愈 == 0 and 驱散单位 is not None:
            current_step = f"施放 自然之愈 on {驱散单位}"
            action_hotkey = get_hotkey(int(驱散单位), "自然之愈")            
        elif 有绽放单位 is not None and 绽放时间 is not None and 绽放时间 < 3:
            current_step = f"补 生命绽放 on {有绽放单位}"
            action_hotkey = get_hotkey(int(有绽放单位), "生命绽放")
        elif 有绽放单位 is None and 无绽放坦克 is not None:
            current_step = f"施放 生命绽放 on {无绽放坦克}"
            action_hotkey = get_hotkey(int(无绽放坦克), "生命绽放")
        elif 施法技能 != 20 and 0 < 节能施法 < 5 and 无愈合最低 is not None and 无愈合最低血量 is not None and 无愈合最低血量 < 治疗限值:
            current_step = f"施放 愈合 on {无愈合最低}"
            action_hotkey = get_hotkey(int(无愈合最低), "愈合")
        elif 激活 == 0 and 战斗 and 姿态 == 0 and 能量值 < 80 and count70 >= 2:
            current_step = "施放 激活"
            action_hotkey = get_hotkey(0, "激活")
        elif 丛林之魂 > 0 and 无回春最低 is not None and 无回春最低血量 is not None:
            current_step = f"施放 回春术 on {无回春最低}"
            action_hotkey = get_hotkey(int(无回春最低), "回春术")
        elif 迅捷治愈 == 0 and 可迅捷最低 is not None and 可迅捷最低血量 is not None and 可迅捷最低血量 < 治疗限值:
            current_step = f"施放 迅捷治愈 on {可迅捷最低}"
            action_hotkey = get_hotkey(int(可迅捷最低), "迅捷治愈")
        elif 施法技能 != 21 and 野性成长 == 0 and count90 >= 2:
            current_step = "施放 野性成长"
            action_hotkey = get_hotkey(0, "野性成长")
        elif 万灵之召 == 0 and count70 >= 2:
            current_step = "施放 万灵之召"
            action_hotkey = get_hotkey(0, "万灵之召")
        elif 施法技能 != 20 and 4 < 节能施法 < 15 and 无愈合最低 is not None and 无愈合最低血量 is not None and 无愈合最低血量 < 治疗限值 - 10:
            current_step = f"施放 愈合 on {无愈合最低}"
            action_hotkey = get_hotkey(int(无愈合最低), "愈合")
        elif 自然迅捷 == 255 and 无愈合最低 is not None and 无愈合最低血量 is not None and 无愈合最低血量 < 治疗限值 - 20:
            current_step = f"施放 自然迅捷 on {无愈合最低}"
            action_hotkey = get_hotkey(int(无愈合最低), "愈合")
        elif 自然迅捷 == 0 and 无愈合最低 is not None and 无愈合最低血量 is not None and 无愈合最低血量 < 治疗限值 - 20:
            current_step = "施放 自然迅捷"
            action_hotkey = get_hotkey(0, "自然迅捷")
        elif 单回春最低 is not None and 单回春血量最低 is not None and 单回春血量最低 < 治疗限值 - 10 and 队伍类型 == 46:
            current_step = f"施放 回春术 on {单回春最低}"
            action_hotkey = get_hotkey(int(单回春最低), "回春术")
        elif 无回春最低 is not None and 无回春最低血量 is not None and 无回春最低血量 < 治疗限值:
            current_step = f"施放 回春术 on {无回春最低}"
            action_hotkey = get_hotkey(int(无回春最低), "回春术")
        elif 施法技能 != 20 and 无愈合最低 is not None and 无愈合最低血量 is not None and 无愈合最低血量 < 70:
            current_step = f"施放 愈合 on {无愈合最低}"
            action_hotkey = get_hotkey(int(无愈合最低), "愈合")
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 一键辅助 == 18:
                current_step = "施放 斜掠"
                action_hotkey = get_hotkey(0, "斜掠")
            elif 目标距离 <= 4:
                if 姿态 != 1:
                    current_step = "施放 猎豹形态"
                    action_hotkey = get_hotkey(0, "猎豹形态")
                elif 姿态 == 1:
                    if 连击点 <= 1 and 野性之心 == 0:
                        current_step = "施放 野性之心"
                        action_hotkey = get_hotkey(0, "野性之心")
                    elif tup:
                            current_step = f"施放 {tup[0]}"
                            action_hotkey = get_hotkey(0, tup[1])
                    else:
                        current_step = "战斗中-无匹配技能"
            elif 目标距离 > 8:
                if 一键辅助 == 5:
                    current_step = "施放 月火术"
                    action_hotkey = get_hotkey(0, "月火术")
                elif 一键辅助 == 19:
                    current_step = "施放 愤怒"
                    action_hotkey = get_hotkey(0, "愤怒")
        elif 一键辅助 == 6:
            current_step = "施放 野性印记"
            action_hotkey = get_hotkey(0, "野性印记")
        else:
            current_step = "无匹配技能"

    return action_hotkey, current_step, unit_info
