# -*- coding: utf-8 -*-
"""术士职业的基础逻辑（未实现）。"""
from utils import *

action_map = {
    1: ("恐惧", "恐惧"),
    2: ("死亡缠绕", "死亡缠绕"),
    3: ("暗影之怒", "暗影之怒"),
    4: ("内爆", "内爆"),
    5: ("召唤恶魔暴君", "召唤恶魔暴君"),
    6: ("魔典：邪能破坏者", "魔典：邪能破坏者"),
    7: ("召唤末日守卫", "召唤末日守卫"),
    8: ("古尔丹之手", "古尔丹之手"),
    9: ("召唤恐惧猎犬", "召唤恐惧猎犬"),
    10: ("召唤恶魔卫士", "召唤恶魔卫士"),
    11: ("恶魔之箭", "恶魔之箭"),
    12: ("暗影箭", "暗影箭"),
    13: ("召唤地狱猎犬", "召唤地狱猎犬"),
    14: ("召唤小鬼", "召唤小鬼"),
    15: ("虚弱灾厄", "虚弱灾厄"),
    16: ("语言灾厄", "语言灾厄"),
    17: ("陨灭", "陨灭"),
    18: ("狱火箭(暗影箭)", "暗影箭"),
    19: ("灵魂石", "灵魂石"),
    20: ("邪能统御", "邪能统御"),
    21: ("黑暗契约", "黑暗契约"),
    22: ("恶魔之箭", "恶魔之箭"),
    23: ("魔典：小鬼领主", "魔典：小鬼领主"),
    24: ("法术封锁", "法术封锁"),
    25: ("吞噬魔法", "吞噬魔法"),
    26: ("爆燃冲刺", "爆燃冲刺"),
    27: ("放逐术", "放逐术"),
    28: ("疲劳诅咒", "疲劳诅咒"),
    29: ("语言诅咒", "语言诅咒"),
    30: ("恶魔传送门", "恶魔传送门"),
    31: ("灵魂燃烧", "灵魂燃烧"),
    32: ("恐惧嚎叫", "恐惧嚎叫"),
    33: ("恶魔法阵", "恶魔法阵"),
    34: ("恶魔法阵：传送", "恶魔法阵：传送"),
    35: ("制造灵魂之井", "制造灵魂之井"),
    36: ("召唤仪式", "召唤仪式"),
    37: ("腐蚀术", "腐蚀术"),
    38: ("吸取生命", "吸取生命"),
    39: ("召唤黑眼", "召唤黑眼"),
    40: ("痛苦无常", "痛苦无常"),
    41: ("幽冥收割", "幽冥收割"),
    42: ("腐蚀之种", "腐蚀之种"),
    43: ("痛楚", "痛楚"),
    44: ("鬼影缠身", "鬼影缠身"),
    45: ("枯萎", "枯萎"),
    46: ("怨毒", "怨毒"),
    47: ("召唤地狱火", "召唤地狱火"),
    48: ("暗影灼烧", "暗影灼烧"),
    49: ("混乱之箭", "混乱之箭"),
    50: ("火焰之雨", "火焰之雨"),
    51: ("灵魂之火", "灵魂之火"),
    52: ("烧尽", "烧尽"),
    53: ("燃烧", "燃烧"),
    54: ("献祭", "献祭"),
    55: ("引导恶魔之火", "引导恶魔之火"),
    56: ("浩劫", "浩劫"),
    57: ("火焰之雨", "火焰之雨"),
    58: ("大灾变", "大灾变"),
    59: ("吸取灵魂", "吸取灵魂"),
    60: ("召唤虚空行者", "召唤虚空行者"),
    61: ("召唤萨亚德", "召唤萨亚德"),
}

failed_spell_map = {
    1: "死亡缠绕",
    2: "暗影之怒",
    3: "暗影之怒",
    4: "内爆",
    5: "召唤恶魔暴君",
    6: "魔典：邪能破坏者",
}

summon_baby = {9, 10, 13, 14, 60, 61 } # 召唤宝宝的index

# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None

def run_warlock_logic(state_dict, spec_name):
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

    灵魂碎片 = state_dict.get("灵魂碎片", 0)
    施法技能 = state_dict.get("施法技能", 0)

    恐惧 = spells.get("恐惧", -1)
    死亡缠绕 = spells.get("死亡缠绕", -1)
    灵魂石 = spells.get("灵魂石", -1)
    暗影之怒 = spells.get("暗影之怒", -1)
    邪能统御 = spells.get("邪能统御", -1)
    黑暗契约 = spells.get("黑暗契约", -1)
    恶魔传送门 = spells.get("恶魔传送门", -1)
    虚弱灾厄 = spells.get("虚弱灾厄", -1)
    语言灾厄 = spells.get("语言灾厄", -1)
    恶魔法阵 = spells.get("恶魔法阵", -1)
    法阵传送 = spells.get("法阵传送", -1)

    if spec_name == "痛苦":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 一键辅助 in summon_baby and 邪能统御 == 0:
                current_step = "施放 邪能统御"
                action_hotkey = get_hotkey(0, "邪能统御")
            elif tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中 - 无匹配技能"
        else:
            current_step = "无匹配技能"
      
    elif spec_name == "恶魔":
        小鬼数量 = state_dict.get("小鬼数量", 0)
        吞噬魔法 = state_dict.get("吞噬魔法", 0)
        魔典邪能破坏者 = spells.get("魔典：邪能破坏者", -1)
        内爆 = spells.get("内爆", -1)
        古尔丹之手 = spells.get("古尔丹之手", -1)
        暗影箭 = spells.get("暗影箭", -1)
        

        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 魔典邪能破坏者 == 0 and 吞噬魔法 == 1:
                current_step = "施放 魔典：邪能破坏者"
                action_hotkey = get_hotkey(0, "魔典：邪能破坏者")
            elif 小鬼数量 >= 6 and 内爆 == 0:
                current_step = "施放 内爆"
                action_hotkey = get_hotkey(0, "内爆")
            elif 施法技能 == 10 and 灵魂碎片 == 5:
                current_step = "施放 古尔丹之手"
                action_hotkey = get_hotkey(0, "古尔丹之手")
            elif 施法技能 == 10 and 灵魂碎片 < 5:
                current_step = "施放 暗影箭"
                action_hotkey = get_hotkey(0, "暗影箭")
            elif 一键辅助 in summon_baby and 邪能统御 == 0:
                current_step = "施放 邪能统御"
                action_hotkey = get_hotkey(0, "邪能统御")
            elif tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"

    elif spec_name == "毁灭":
        燃烧  = spells.get("燃烧", -1)
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 施法技能 == 54 and 燃烧 == 0:
                current_step = "施放 燃烧"
                action_hotkey = get_hotkey(0, "燃烧")
            elif 一键辅助 in summon_baby and 邪能统御 == 0:
                current_step = "施放 邪能统御"
                action_hotkey = get_hotkey(0, "邪能统御")
            elif tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中 - 无匹配技能"
        else:
            current_step = "无匹配技能"
      
    
    return action_hotkey, current_step, unit_info