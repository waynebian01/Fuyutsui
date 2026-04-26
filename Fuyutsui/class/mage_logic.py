# -*- coding: utf-8 -*-
"""法师职业的基础逻辑（未实现）。"""

from utils import *

action_map = {
    6: ("奥术智慧", "奥术智慧"),
    7: ("寒冰箭", "寒冰箭"),
    8: ("冰川尖刺", "寒冰箭"),
    9: ("冰枪术", "冰枪术"),
    10: ("冰霜射线", "冰霜射线"),
    11: ("冰风暴", "冰风暴"),
    12: ("寒冰宝珠", "寒冰宝珠"),
    4: ("暴风雪", "暴风雪"),
    5: ("暴风雪", "暴风雪"),
    13: ("霜火之箭", "寒冰箭"),
    14: ("彗星风暴", "冰霜射线"),
}

failed_spell_map = {
    1: "强化隐形术",
    2: "冰霜新星",
    3: "龙息术",
}

# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None

def run_mage_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}

    战斗 = state_dict.get("战斗", False)
    移动 = state_dict.get("移动", False)
    施法 = state_dict.get("施法", 0)
    引导 = state_dict.get("引导", 0)
    蓄力 = state_dict.get("蓄力", 0)
    蓄力层数 = state_dict.get("蓄力层数", 0)
    生命值 = state_dict.get("生命值", 0)
    能量值 = state_dict.get("能量值", 0)
    一键辅助 = state_dict.get("一键辅助", 0)
    法术失败 = state_dict.get("法术失败", 0)
    目标类型 = state_dict.get("目标类型", 0)
    队伍类型 = state_dict.get("队伍类型", 0)
    队伍人数 = state_dict.get("队伍人数", 0)
    首领战 = state_dict.get("首领战", 0)
    难度 = state_dict.get("难度", 0)
    英雄天赋 = state_dict.get("英雄天赋", 0)

    失败法术 = _get_failed_spell(state_dict)
    tup = action_map.get(一键辅助)
    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    if 法术失败 != 0 and 失败法术 is not None:
        current_step = f"施放 {失败法术}"
        action_hotkey = get_hotkey(0, 失败法术)
    elif spec_name == "奥术":
        current_step = "奥术专精,不执行任何操作"
        return None, current_step, unit_info
    elif spec_name == "火焰":
        current_step = "火焰专精,不执行任何操作"
        return None, current_step, unit_info
    elif spec_name == "冰霜":
        真能真空 = state_dict.get("真能真空", 0)
        冰川尖刺 = state_dict.get("冰川尖刺", 0)
        冰冷智慧 = state_dict.get("冰冷智慧", 0)
        冰冻之雨 = state_dict.get("冰冻之雨", 0)
        寒冰指 = state_dict.get("寒冰指", 0)
        寒冰指层数 = state_dict.get("寒冰指层数", 0)
        敌人人数 = state_dict.get("敌人人数", 0)

        解除诅咒cd = spells.get("解除诅咒", -1)
        强化隐形术cd = spells.get("强化隐形术", -1)
        冰霜新星cd = spells.get("冰霜新星", -1)
        法术反制cd = spells.get("法术反制", -1)
        寒冰宝珠cd = spells.get("寒冰宝珠", -1)
        冰霜射线cd = spells.get("冰霜射线", -1)
        寒冰护体cd = spells.get("寒冰护体", -1)
        冰风暴cd = spells.get("冰风暴", -1)
        冰风暴充能cd = spells.get("冰风暴充能", -1)
        暴风雪Tcd = spells.get("暴风雪T", -1)
        暴风雪Ccd = spells.get("暴风雪C", -1)
        # 施放冰川尖刺时, 冰川尖刺层数清零,防止重复施法
        if 施法技能 == 8: 
           冰川尖刺 = 1
        
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 敌人人数 > 3 and 冰冻之雨 > 0 and (暴风雪Tcd == 0 or 暴风雪Ccd == 0):
                current_step = "施放 暴风雪"
                action_hotkey = get_hotkey(0, "暴风雪")
            elif 冰冷智慧 > 0 and 真能真空 == 0 and 冰风暴cd == 0:
                current_step = "施放 冰风暴"
                action_hotkey = get_hotkey(0, "冰风暴")
            elif 寒冰指层数 == 2:
                current_step = "施放 冰枪术"
                action_hotkey = get_hotkey(0, "冰枪术")
            elif 冰川尖刺 >= 2:
                current_step = "施放 寒冰箭"
                action_hotkey = get_hotkey(0, "寒冰箭")
            elif tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"

    return action_hotkey, current_step, unit_info