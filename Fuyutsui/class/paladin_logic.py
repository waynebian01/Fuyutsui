# -*- coding: utf-8 -*-
"""圣骑士职业的逻辑决策（神圣）。"""

from utils import *

need_dispel_bosses = {4, 5} # 需要驱散的首领 ID
no_dispel_bosses = {64} # 不需要驱散的首领 ID

# 技能映射
action_map = {
    7: ("圣洁鸣钟", "圣洁鸣钟"),
    8: ("复仇者之盾", "复仇者之盾"),
    9: ("奉献", "奉献"),
    10: ("审判", "审判"),
    11: ("正义盾击", "正义盾击"),
    12: ("祝福之锤", "祝福之锤"),
    19: ("愤怒之锤", "审判"),
    21: ("愤怒之锤", "审判"),
    13: ("公正之剑", "公正之剑"),
    14: ("审判", "审判"),
    15: ("最终审判", "最终审判"),
    16: ("灰烬觉醒", "灰烬觉醒"),
    17: ("神圣风暴", "神圣风暴"),
    18: ("圣光之锤", "灰烬觉醒"),
    20: ("处决宣判", "处决宣判"),
}

# 法术失败映射
failed_spell_map = {
    1: "盲目之光",
    2: "光环掌握",
    3: "自由祝福",
    4: "制裁之锤",
    5: "保护祝福",
    6: "圣盾术",
    24: "美德道标",
}

# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None

def run_paladin_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}

    战斗 = state_dict.get("战斗", False)
    移动 = state_dict.get("移动", False)
    施法 = state_dict.get("施法", 0)
    引导 = state_dict.get("引导", 0)
    生命值 = state_dict.get("生命值", 0)
    能量值 = state_dict.get("能量值", 0)
    一键辅助 = state_dict.get("一键辅助", 0)
    法术失败 = state_dict.get("法术失败", 0)
    目标类型 = state_dict.get("目标类型", False)
    队伍类型 = int(state_dict.get("队伍类型", 0) or 0)
    队伍人数 = int(state_dict.get("队伍人数", 0) or 0)
    首领战 = int(state_dict.get("首领战", 0) or 0)
    难度 = int(state_dict.get("难度", 0) or 0)
    英雄天赋 = int(state_dict.get("英雄天赋", 0) or 0)
    
    神圣能量 = state_dict.get("神圣能量", 0)
    失败法术 = _get_failed_spell(state_dict)

    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    if spec_name == "神圣":
        施法技能 = state_dict.get("施法技能", 0)
        施法目标 = state_dict.get("施法目标", 0)
        神圣意志 = state_dict.get("神圣意志", 0)
        圣光灌注 = state_dict.get("圣光灌注", 0)
        灌注层数 = state_dict.get("灌注层数", 0)
        神性层数 = state_dict.get("神性层数", 0)
        目标距离 = state_dict.get("目标距离", 0)

        神圣震击 = spells.get("神圣震击", -1)
        震击充能 = spells.get("震击充能", -1)
        清洁术 = spells.get("清洁术", -1)
        盲目之光 = spells.get("盲目之光", -1)
        审判 = spells.get("审判", -1)
        圣洁鸣钟 = spells.get("圣洁鸣钟", -1)
        神圣棱镜 = spells.get("神圣棱镜", -1)
        光环掌握 = spells.get("光环掌握", -1)
        牺牲祝福 = spells.get("牺牲祝福", -1)
        自由祝福 = spells.get("自由祝福", -1)
        制裁之锤 = spells.get("制裁之锤", -1)
        保护祝福 = spells.get("保护祝福", -1)
        圣疗术 = spells.get("圣疗术", -1)

        dispel_unit_magic, _ = get_unit_with_dispel_type(state_dict, 1)
        dispel_unit_disease, _ = get_unit_with_dispel_type(state_dict, 3)
        dispel_unit_poison, _ = get_unit_with_dispel_type(state_dict, 4)
        最低单位, 最低生命值 = get_lowest_health_unit(state_dict, 100)
        无火最低, 无火最低血量 = get_lowest_health_unit_without_aura(state_dict, "永恒之火", health_threshold=101)
        count90 = count_units_below_health(state_dict, 90)

        圣光限值 = int(40 + (能量值 * 0.3)) # 40-70

        unit_info = {
            "最低单位": 最低单位,
            "最低生命值": 最低生命值,
            "无火最低": 无火最低,
            "无火最低血量": 无火最低血量,
            "count90": count90,
        }

        驱散单位 = None
        if dispel_unit_magic is not None:
            if 队伍类型 == 46 and 首领战 not in no_dispel_bosses:
                驱散单位 = dispel_unit_magic
            elif 队伍类型 <= 40 and 首领战 in need_dispel_bosses:
                驱散单位 = dispel_unit_magic
        if 驱散单位 is None:
            驱散单位 = dispel_unit_disease
        if 驱散单位 is None:
            驱散单位 = dispel_unit_poison

        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)
        elif 清洁术 == 0 and 驱散单位 is not None:
            current_step = f"施放 清毒术 on {驱散单位}"
            action_hotkey = get_hotkey(int(驱散单位), "清毒术")
        elif 神圣能量 == 5:
            if count90 >= 5:
                current_step = "施放 黎明之光"
                action_hotkey = get_hotkey(0, "黎明之光")
            elif 最低单位 is not None and 最低生命值 is not None and 最低生命值 < 70:
                current_step = f"施放 荣耀圣令 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "荣耀圣令")
            elif 无火最低 is not None and 无火最低血量 is not None and 无火最低血量 < 90:
                current_step = f"施放 荣耀圣令 on {无火最低}"
                action_hotkey = get_hotkey(int(无火最低), "荣耀圣令")
            elif 战斗 and 1 <= 目标类型 <= 3 and 0 < 目标距离 <= 5:
                current_step = "施放 正义盾击"
                action_hotkey = get_hotkey(0, "正义盾击")
            elif 最低单位 is not None and 最低生命值 is not None and 最低生命值 < 95:
                current_step = f"施放 荣耀圣令 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "荣耀圣令")
            else:
                current_step = "施放 荣耀圣令 on 玩家"
                action_hotkey = get_hotkey(1, "荣耀圣令")
        elif 最低单位 is not None and 最低生命值 is not None and 最低生命值 <= 95:
            if 圣疗术 == 0 and 最低生命值 <= 25:
                current_step = f"施放 圣疗术 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣疗术")
            elif 震击充能 == 0 and 圣光灌注 == 0:
                current_step = f"施放 神圣震击 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "神圣震击")
            elif 0 < 神圣意志 < 4:
                current_step = f"施放 荣耀圣令 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "荣耀圣令")
            elif 0 < 圣光灌注 < 6:
                current_step = f"施放 圣光闪现 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣光闪现")
            elif 最低生命值 < 圣光限值 + 10 and 神性层数 > 0:
                current_step = f"施放 圣光术 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣光术")
            elif (神圣能量 >= 3 or 神圣意志 > 0) and 最低生命值 <= 60:
                current_step = f"施放 荣耀圣令 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "荣耀圣令")
            elif 神圣能量 >= 3 and 无火最低 is not None and 无火最低血量 is not None and 无火最低血量 <= 90:
                current_step = f"施放 荣耀圣令 on {无火最低}"
                action_hotkey = get_hotkey(int(无火最低), "荣耀圣令")
            elif 圣洁鸣钟 == 0 and 神圣能量 <= 2 and count90 >= 2:
                current_step = "施放 圣洁鸣钟"
                action_hotkey = get_hotkey(0, "圣洁鸣钟")
            elif 圣光灌注 > 0 and 最低生命值 < 80:
                current_step = f"施放 圣光闪现 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣光闪现")
            elif 最低生命值 < 圣光限值:
                current_step = f"施放 圣光术 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣光术")
            elif 神圣震击 == 0 and 圣光灌注 == 0:
                current_step = f"施放 神圣震击 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "神圣震击")
            elif 神圣震击 > 0 and 圣光灌注 == 0:
                current_step = f"施放 圣光闪现 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣光闪现")
            elif 战斗 and 1 <= 目标类型 <= 3:
                if 审判 <= 1:
                    current_step = "施放 审判"
                    action_hotkey = get_hotkey(0, "审判")
                elif 神圣震击 == 0 and 圣光灌注 == 0:
                    current_step = "施放 神圣震击"
                    action_hotkey = get_hotkey(0, "神圣震击")
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 0 < 神圣意志 < 4:
                current_step = "施放 正义盾击"
                action_hotkey = get_hotkey(0, "正义盾击")
            elif 审判 <= 1:
                current_step = "施放 审判"
                action_hotkey = get_hotkey(0, "审判")
            elif 神圣震击 == 0 and 圣光灌注 == 0:
                current_step = "施放 神圣震击"
                action_hotkey = get_hotkey(0, "神圣震击")
        else:
            current_step = "无匹配技能"
 
    elif spec_name == "防护":
        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)
        elif 战斗 and 1 <= 目标类型 <= 3:
            if state_dict.get("军备类型") == 1 and spells.get("神圣壁垒") == 0 and state_dict.get("神圣壁垒") == 0:
                current_step = "施放 神圣壁垒"
                action_hotkey = get_hotkey(0, "神圣壁垒")
            elif state_dict.get("军备类型") == 2 and spells.get("神圣壁垒") == 0 and state_dict.get("圣洁武器") == 0:
                current_step = "施放 神圣壁垒"
                action_hotkey = get_hotkey(0, "神圣壁垒")
            elif state_dict.get("闪耀之光") > 0 and 生命值 < 80:
                current_step = "施放 荣耀圣令"
                action_hotkey = get_hotkey(0, "荣耀圣令")
            else:
                tup = action_map.get(一键辅助)
                if tup and spells.get(tup[0], 0) <= 1:
                    current_step = f"施放 {tup[0]}"
                    action_hotkey = get_hotkey(0, tup[1])
                else:
                    current_step = "战斗中-无匹配技能"

    elif spec_name == "惩戒":
        if 法术失败 != 0 and 失败法术 is not None:
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
