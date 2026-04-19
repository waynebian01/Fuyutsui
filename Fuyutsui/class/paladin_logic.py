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

def _get_ret_helper_finisher(one_key_value, finisher_mode=0):
    """
    返回惩戒终结技对应的 (显示名, 实际按键技能名)。
    终结技规则：
    群体模式:
    - 推荐最终审判 -> 打最终审判
    - 推荐神圣风暴 -> 打神圣风暴
    - 推荐圣光之锤 -> 打神圣风暴
    - 推荐处决宣判 -> 打神圣风暴
    单体模式:
    - 推荐最终审判 -> 打最终审判
    - 推荐神圣风暴 -> 打最终审判
    - 推荐圣光之锤 -> 打最终审判
    - 推荐处决宣判 -> 打最终审判
    """
    if one_key_value == 15:
        return ("最终审判", "最终审判")
    if one_key_value == 17:
        if finisher_mode == 1:
            return ("神圣风暴", "最终审判")
        return ("神圣风暴", "神圣风暴")
    if one_key_value == 18:
        if finisher_mode == 1:
            return ("圣光之锤", "最终审判")
        return ("圣光之锤", "神圣风暴")
    if one_key_value == 20:
        if finisher_mode == 1:
            return ("处决宣判", "最终审判")
        return ("处决宣判", "神圣风暴")
    return None


def _resolve_ret_3hp_action(公正之剑, 审判, 一键辅助, helper_finisher=None, finisher_mode=0):
    """
    3豆时：
    1. 公正之剑可用 -> 先打公正之剑
    2. 否则审判可用 -> 先打审判（开翅膀时这个键位实际就是愤怒之锤）
    3. 两个都不可用 -> 跟一键辅助终结技
    """
    if helper_finisher is None:
        helper_finisher = _get_ret_helper_finisher(一键辅助, finisher_mode)

    if 公正之剑 <= 1:
        return get_hotkey(0, "公正之剑"), "3豆先补豆: 公正之剑"

    if 审判 <= 1:
        shown_name = "愤怒之锤" if 一键辅助 in (19, 21) else "审判"
        return get_hotkey(0, "审判"), f"3豆先补豆: {shown_name}"

    if helper_finisher:
        shown_name, cast_name = helper_finisher
        return get_hotkey(0, cast_name), f"3豆无补豆技能，终结技: {shown_name}"

    return None, "3豆无可用技能"

def run_paladin_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}

    战斗 = state_dict.get("战斗", False)
    有效性 = state_dict.get("有效性", False)
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
        生命值 = int(state_dict.get("生命值", 100) or 100)
        神圣能量 = int(state_dict.get("神圣能量", 0) or 0)
        惩戒终结模式 = int(state_dict.get("惩戒终结模式", 0) or 0)

        公正之剑 = spells.get("公正之剑", 99)
        审判 = spells.get("审判", 99)
        荣耀圣令 = spells.get("荣耀圣令", 99)

        helper_finisher = _get_ret_helper_finisher(一键辅助, 惩戒终结模式)

        unit_info["神圣能量"] = 神圣能量
        unit_info["一键辅助"] = 一键辅助
        unit_info["惩戒终结模式"] = 惩戒终结模式

        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)
        elif not 战斗:
            current_step = "脱战待机"
        elif not 有效性:
            current_step = "无有效目标"
        elif 施法 or 引导:
            current_step = "正在施法/引导"
        elif 生命值 < 50 and 神圣能量 >= 3 and 荣耀圣令 <= 1:
            current_step = "保命: 对自己施放 荣耀圣令"
            action_hotkey = get_hotkey(1, "荣耀圣令")
        elif 神圣能量 == 5 and helper_finisher:
            shown_name, cast_name = helper_finisher
            current_step = f"5豆终结技: {shown_name}"
            action_hotkey = get_hotkey(0, cast_name)
        elif 神圣能量 == 4 and helper_finisher:
            shown_name, cast_name = helper_finisher
            current_step = f"4豆终结技: {shown_name}"
            action_hotkey = get_hotkey(0, cast_name)
        elif 神圣能量 == 3 and (公正之剑 <= 1 or 审判 <= 1 or helper_finisher):
            action_hotkey, current_step = _resolve_ret_3hp_action(
                公正之剑, 审判, 一键辅助, helper_finisher, 惩戒终结模式
            )
        elif 公正之剑 <= 1:
            current_step = "常规: 公正之剑"
            action_hotkey = get_hotkey(0, "公正之剑")
        elif 审判 <= 1:
            shown_name = "愤怒之锤" if 一键辅助 in (19, 21) else "审判"
            current_step = f"常规: {shown_name}"
            action_hotkey = get_hotkey(0, "审判")
        else:
            current_step = "战斗中-无匹配技能"

    return action_hotkey, current_step, unit_info
