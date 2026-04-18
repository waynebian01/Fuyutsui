# -*- coding: utf-8 -*-

from utils import *
action_map = {
    2: ("杀戮命令", "杀戮命令"),
    1: ("倒刺射击", "倒刺射击"),
    3: ("眼镜蛇射击", "眼镜蛇射击"),
    4: ("狂野怒火", "狂野怒火"),
    5: ("荒野呼唤", "荒野呼唤"),
    6: ("夺命黑鸦", "夺命黑鸦"),
    7: ("弹幕射击", "弹幕射击"),
    8: ("血溅十方", "血溅十方"),
    9: ("瞄准射击", "瞄准射击"),
    10: ("急速射击", "急速射击"),
    11: ("稳固射击", "稳固射击"),
    12: ("多重射击", "多重射击"),
    13: ("百发百中", "百发百中"),
    14: ("夺命射击", "夺命射击"),
    15: ("爆炸射击", "爆炸射击"),
    16: ("哀恸箭", "哀恸箭"),
    17: ("猎人印记", "猎人印记"),
    18: ("奥术射击", "奥术射击"),
    19: ("奇美拉射击", "奇美拉射击"),
    20: ("召唤宠物1", "召唤宠物1"),
    21: ("狂野鞭笞", "狂野鞭笞"),
    22: ("意气风发", "意气风发"),
    23: ("灵龟守护", "灵龟守护"),
    24: ("反制射击", "反制射击"),
    25: ("哀恸箭", "哀恸箭"),
    26: ("黑蚀箭", "黑蚀箭"),
    27: ("胁迫", "胁迫"),
    28: ("乱射", "乱射"),
    29: ("多重射击", "多重射击"),
    30: ("杀戮命令", "杀戮命令"),
    31: ("投掷手斧", "投掷手斧"),
    32: ("燎焰沥青", "燎焰沥青"),
    33: ("爆裂火铳", "爆裂火铳"),
    34: ("狩魂一击", "狩魂一击"),
    35: ("鱼叉猛刺", "鱼叉猛刺"),
    36: ("猛禽一击", "猛禽一击"),
    37: ("野火炸弹", "野火炸弹"),
}

failed_spell_map = {
    1: "意气风发",
    2: "胁迫",
}

# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None

def run_hunter_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}
    生命值 = state_dict.get("生命值")
    能量值 = state_dict.get("能量值")
    一键辅助 = state_dict.get("一键辅助")
    目标类型 = state_dict.get("目标类型")
    战斗 = state_dict.get("战斗")
    施法 = state_dict.get("施法")
    引导 = state_dict.get("引导")
    移动 = state_dict.get("移动")
    英雄天赋 = state_dict.get("英雄天赋", 0)
    法术失败 = state_dict.get("法术失败", 0)
    首领战 = state_dict.get("首领战", 0)
    难度 = state_dict.get("难度", 0)

    tup = action_map.get(一键辅助)

    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    if spec_name == "兽王":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 一键辅助 == 20:
            current_step = "施放 召唤宠物1"
            action_hotkey = get_hotkey(0, "召唤宠物1")
        elif 战斗 and 1 <= 目标类型 <= 3:
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"
        else:
            current_step = "非战斗状态,不执行任何操作"
    elif spec_name == "射击":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 一键辅助 == 20:
            current_step = "施放 召唤宠物1"
            action_hotkey = get_hotkey(0, "召唤宠物1")
        elif 战斗 and 1 <= 目标类型 <= 3:
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"
        else:
            current_step = "非战斗状态,不执行任何操作"
    elif spec_name == "生存":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 一键辅助 == 20:
            current_step = "施放 召唤宠物1"
            action_hotkey = get_hotkey(0, "召唤宠物1")
        elif 战斗 and 1 <= 目标类型 <= 3:
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"
        else:
            current_step = "非战斗状态,不执行任何操作"

    return action_hotkey, current_step, unit_info