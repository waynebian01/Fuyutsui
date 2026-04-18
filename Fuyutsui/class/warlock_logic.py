# -*- coding: utf-8 -*-
"""术士职业的基础逻辑（未实现）。"""
from utils import *
action_map = {
    8: ("古尔丹之手", "古尔丹之手"),
    9: ("召唤恐惧猎犬", "召唤恐惧猎犬"),
    10: ("召唤恶魔卫士", "召唤恶魔卫士"),
    11: ("恶魔之箭", "恶魔之箭"),
    12: ("暗影箭", "暗影箭"),
    17: ("陨灭", "古尔丹之手"),
    18: ("狱火箭", "暗影箭"),
}

failed_spell_map = {
    1: "死亡缠绕",
    2: "暗影之怒",
    3: "暗影之怒",
    4: "内爆",
    5: "召唤恶魔暴君",
    6: "魔典：邪能破坏者",
}

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
    tup = action_map.get(一键辅助)

    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    if spec_name == "痛苦":
        return action_hotkey, current_step, unit_info

    elif spec_name == "恶魔":
        小鬼数量 = state_dict.get("小鬼数量", 0)
        灵魂碎片 = state_dict.get("灵魂碎片", 0)
        施法技能 = state_dict.get("施法技能", 0)
        法术封锁 = state_dict.get("法术封锁", 0)

        魔典邪能破坏者 = spells.get("魔典：邪能破坏者", -1)
        内爆 = spells.get("内爆", -1)
        古尔丹之手 = spells.get("古尔丹之手", -1)
        暗影箭 = spells.get("暗影箭", -1)
        邪能统御 = spells.get("邪能统御", -1)

        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 魔典邪能破坏者 == 0 and 法术封锁 == 1:
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
            elif 一键辅助 == 10 and 邪能统御 == 0:
                current_step = "施放 邪能统御"
                action_hotkey = get_hotkey(0, "邪能统御")
            elif tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"

    elif spec_name == "毁灭":
        return action_hotkey, current_step, unit_info
    
    
    return action_hotkey, current_step, unit_info