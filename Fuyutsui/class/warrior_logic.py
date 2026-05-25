# -*- coding: utf-8 -*-
"""战士职业的基础逻辑。"""

from utils import *

action_map = {
    11: ("英勇投掷", "英勇投掷"),
    12: ("战斗怒吼", "战斗怒吼"),
    13: ("猛击", "猛击"),
    14: ("撕裂", "撕裂"),
    15: ("斩杀", "斩杀"),
    16: ("剑刃风暴", "剑刃风暴"),
    17: ("崩摧", "崩摧"),
    18: ("致死打击", "致死打击"),
    19: ("巨人打击", "巨人打击"),
    20: ("顺劈斩", "顺劈斩"),
    21: ("压制", "压制"),
    22: ("横扫攻击", "横扫攻击"),
    23: ("天神下凡", "天神下凡"),
    24: ("旋风斩", "旋风斩"),
    25: ("斩杀", "斩杀"),
    26: ("嗜血", "嗜血"),
    27: ("暴怒", "暴怒"),
    28: ("奥丁之怒", "奥丁之怒"),
    29: ("怒击", "怒击"),
    30: ("雷霆一击", "雷霆一击"),
    31: ("雷霆轰击", "雷霆一击"),
    32: ("复仇", "复仇"),
    33: ("盾牌猛击", "盾牌猛击"),
    34: ("斩杀", "斩杀"),
    35: ("英勇打击", "猛击"),
    36: ("浴血奋战", "嗜血"),
    37: ("碎甲猛击", "怒击"),
    38: ("破坏者", "破坏者"),
    39: ("斩杀", "斩杀")
}

failed_spell_map = {
    1: "胜利在望",
    2: "勇士之矛",
    3: "英勇飞跃",
    4: "集结呐喊",
    5: "震荡波",
    6: "风暴之锤",
    7: "破裂投掷",
    8: "碎裂投掷",
    9: "破胆怒吼",
    10: "盾牌冲锋",
}

# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None


def run_warrior_logic(state_dict, spec_name):
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
    敌人人数 = state_dict.get("敌人人数", 0)
    目标生命值 = state_dict.get("目标生命值", 0)
    失败法术 = _get_failed_spell(state_dict)
    tup = action_map.get(一键辅助)
    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    if 法术失败 != 0 and 失败法术 is not None:
        current_step = f"施放 {失败法术}"
        action_hotkey = get_hotkey(0, 失败法术)
    elif 一键辅助 == 12:
        current_step = "施放 战斗怒吼"
        action_hotkey = get_hotkey(0, "战斗怒吼")
    elif spec_name == "武器": 
        英勇打击高亮 = state_dict.get("英勇打击高亮", 0)
        斩杀高亮 = state_dict.get("斩杀高亮", 0)
        顺劈斩高亮 = state_dict.get("顺劈斩高亮", 0)
        致死高亮 = state_dict.get("致死高亮", 0)
        致死打击 = spells.get("致死打击", -1)
        巨人打击 = spells.get("巨人打击", -1)
        崩摧 = spells.get("崩摧", -1)
        顺劈斩= spells.get("顺劈斩", -1)
        斩杀 = spells.get("斩杀", -1)
        压制 = spells.get("压制", -1)
        压制充能 = spells.get("压制充能", -1)
        if 英雄天赋 == 1:
            if 战斗 and 1 <= 目标类型 <= 3:
                if 生命值 < 70 and spells.get("胜利在望") == 0:
                    current_step = "施放 胜利在望"
                    action_hotkey = get_hotkey(0, "胜利在望")
                elif 一键辅助 == 14:
                    current_step = "施放 撕裂"
                    action_hotkey = get_hotkey(0, "撕裂")
                elif 巨人打击 == 0:
                    current_step = "施放 巨人打击"
                    action_hotkey = get_hotkey(0, "巨人打击")
                elif 崩摧 == 0:
                    current_step = "施放 崩摧"
                    action_hotkey = get_hotkey(0, "崩摧")
                elif 一键辅助 == 22:
                    current_step = "施放 横扫攻击"
                    action_hotkey = get_hotkey(0, "横扫攻击")
                elif 敌人人数>=3 and 顺劈斩 == 0 and 能量值 >= 20:
                    current_step = "施放 顺劈斩"
                    action_hotkey = get_hotkey(0, "顺劈斩")
                elif 敌人人数<=2 and 英勇打击高亮 > 0 and 能量值 >= 20:
                    current_step = "施放 英勇打击"
                    action_hotkey = get_hotkey(0, "猛击")
                elif 敌人人数<=2 and 顺劈斩 == 0 and 顺劈斩高亮 > 0 and 能量值 >= 20:
                    current_step = "施放 顺劈斩"
                    action_hotkey = get_hotkey(0, "顺劈斩")
                elif 致死打击 == 0 and 致死高亮 > 0 and 能量值 >= 15:
                    current_step = "施放 致死打击"
                    action_hotkey = get_hotkey(0, "致死打击")
                elif 致死打击 == 0 and 能量值 >= 30:
                    current_step = "施放 致死打击"
                    action_hotkey = get_hotkey(0, "致死打击")
                elif 压制 == 0:
                    current_step = "施放 压制"
                    action_hotkey = get_hotkey(0, "压制")
                elif 斩杀高亮>0 and 斩杀 == 0:
                    current_step = "施放 斩杀"
                    action_hotkey = get_hotkey(0, "斩杀")
                elif 能量值 >= 50:
                    current_step = "施放 猛击"
                    action_hotkey = get_hotkey(0, "猛击")
            else:
                current_step = "无匹配技能"     
        elif 英雄天赋 == 2 and tup:
            current_step = f"一键辅助-施放 {tup[0]}"
            action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "无匹配技能"            
    elif spec_name == "狂怒":
        if 战斗 and 1 <= 目标类型 <= 3:
            if 生命值 < 70 and spells.get("胜利在望") == 0:
                current_step = "施放 胜利在望"
                action_hotkey = get_hotkey(0, "胜利在望")
            elif tup:
                current_step = f"一键辅助-施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "无匹配技能"
    elif spec_name == "防护":
        盾牌格挡 = state_dict.get("盾牌格挡", 0)

        if 战斗 and 1 <= 目标类型 <= 3:
            if 盾牌格挡 == 0 and spells.get("盾牌格挡") == 0 and 能量值 >= 25:
                current_step = "施放 盾牌格挡"
                action_hotkey = get_hotkey(0, "盾牌格挡")
            elif 生命值 < 70 and spells.get("胜利在望") == 0:
                current_step = "施放 胜利在望"
                action_hotkey = get_hotkey(0, "胜利在望")
            elif 能量值 >= 60:
                current_step = "施放 无视苦痛"
                action_hotkey = get_hotkey(0, "无视苦痛")
            elif tup:
                current_step = f"一键辅助-施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "无匹配技能"

    return action_hotkey, current_step, unit_info
