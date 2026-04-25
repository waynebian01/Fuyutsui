# -*- coding: utf-8 -*-
"""盗贼职业的基础逻辑（未实现）。"""
from utils import *

action_map = {
    1: ("毒刃", "毒刃"),
    2: ("致盲", "致盲"),
    3: ("暗影斗篷", "暗影斗篷"),
    4: ("凿击", "凿击"),
    5: ("嫁祸诀窍", "嫁祸诀窍"),
    6: ("闪避", "闪避"),
    7: ("迟钝药膏", "迟钝药膏"),
    8: ("萎缩药膏", "萎缩药膏"),
    9: ("菊花茶", "菊花茶"),
    10: ("肾击", "肾击"),
    11: ("佯攻", "佯攻"),
    12: ("偷袭", "偷袭"),
    13: ("消失", "消失"),
    14: ("切割", "切割"),
    15: ("潜伏帷幕", "潜伏帷幕"),
    16: ("扰乱", "扰乱"),
    17: ("猩红之瓶", "猩红之瓶"),
    18: ("疾跑", "疾跑"),
    19: ("闷棍", "闷棍"),
    20: ("速效药膏", "速效药膏"),
    21: ("致伤药膏", "致伤药膏"),
    22: ("夺命药膏", "夺命药膏"),
    23: ("增效药膏", "增效药膏"),
    24: ("减速药膏", "减速药膏"),
    25: ("刀扇", "刀扇"),
    26: ("死亡印记", "死亡印记"),
    27: ("死亡印记", "死亡印记"),
    28: ("锁喉", "锁喉"),
    29: ("剧毒之刃", "剧毒之刃"),
    30: ("割裂", "割裂"),
    31: ("毁伤", "毁伤"),
    32: ("君王之灾", "君王之灾"),
    33: ("毒伤", "毒伤"),
    34: ("暗影步", "暗影步"),
    35: ("猩红风暴", "猩红风暴"),
    36: ("伏击", "伏击"),
    37: ("脚踢", "脚踢"),
    38: ("冲动", "冲动"),
    39: ("影舞步", "影舞步"),
    40: ("正中眉心", "正中眉心"),
    41: ("刀锋冲刺", "刀锋冲刺"),
    42: ("手枪射击", "手枪射击"),
    43: ("剑刃乱舞", "剑刃乱舞"),
    44: ("抓钩", "抓钩"),
    45: ("命运骨骰", "命运骨骰"),
    46: ("斩击", "斩击"),
    47: ("时运继延", "时运继延"),
    48: ("伺机待发", "伺机待发"),
    49: ("黑火药", "黑火药"),
    50: ("影分身", "影分身"),
    51: ("暗影之刃", "暗影之刃"),
    52: ("背刺", "背刺"),
    53: ("暗影之舞", "暗影之舞"),
    54: ("袖剑风暴", "袖剑风暴"),
    55: ("暗影打击", "暗影打击"),
    56: ("飞镖投掷", "飞镖投掷"),
    57: ("幽暗之刃", "背刺"),
    58: ("赤喉之咬", "赤喉之咬"),
    59: ("影袭", "影袭"),
    60: ("致命一击", "斩击"),
}

failed_spell_map = {
  
}
# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None


def run_rogue_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}

    战斗 = state_dict.get("战斗", 0)
    移动 = state_dict.get("移动", 0)
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
    
    if spec_name == "刺杀":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 战斗 and 1 <= 目标类型 <= 3 and tup:
            current_step = f"施放 {tup[0]}"
            action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "战斗中-无匹配技能"
      
    elif spec_name == "狂徒":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 战斗 and 1 <= 目标类型 <= 3 and tup:
            current_step = f"施放 {tup[0]}"
            action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "战斗中-无匹配技能"
    elif spec_name == "敏锐":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 战斗 and 1 <= 目标类型 <= 3 and tup:
            current_step = f"施放 {tup[0]}"
            action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "战斗中-无匹配技能"

    return action_hotkey, current_step, unit_info

