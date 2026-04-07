# -*- coding: utf-8 -*-
"""术士职业的基础逻辑（未实现）。"""
from utils import *

def run_warlock_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}
    health = state_dict.get("生命值")
    power = state_dict.get("能量值")
    assistant = state_dict.get("一键辅助")
    target_valid = state_dict.get("目标有效")
    combat = state_dict.get("战斗")
    casting = state_dict.get("施法")
    moving = state_dict.get("移动")
    group_type = state_dict.get("队伍类型", 0)
    failedSpell = state_dict.get("法术失败", 0)

    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    if spec_name == "痛苦":
        return action_hotkey, current_step, unit_info

    elif spec_name == "恶魔":
        if spells.get("死亡缠绕", 0) < 1 and failedSpell == 32:
            current_step = "施放 死亡缠绕"
            action_hotkey = get_hotkey(0, "死亡缠绕")
        elif spells.get("暗影之怒", 0) < 1 and failedSpell == 34:
            current_step = "施放 暗影之怒"
            action_hotkey = get_hotkey(0, "暗影之怒")
        elif spells.get("召唤末日守卫", 0) < 1 and failedSpell == 41:
            current_step = "施放 召唤末日守卫"
            action_hotkey = get_hotkey(0, "召唤末日守卫")
        #elif spells.get("内爆", 0) < 1 and failedSpell == 37:
        #    current_step = "施放 内爆"
        #    action_hotkey = get_hotkey(0, "内爆")
        elif combat and target_valid:
            if spells.get("魔典：邪能破坏者") == 0 and state_dict.get("法术封锁", -1) == 1 and state_dict.get("灵魂碎片", -1) >= 1:
                current_step = "施放 逻辑-魔典：邪能破坏者"
                action_hotkey = get_hotkey(0, "魔典：邪能破坏者")
            elif state_dict.get("小鬼数量", 0) >= 6 and spells.get("内爆") == 0:
                current_step = "施放 逻辑-内爆"
                action_hotkey = get_hotkey(0, "内爆")
            elif state_dict.get("施法技能", -1) == 18 and state_dict.get("灵魂碎片", -1) == 5:
                current_step = "施放 逻辑-古尔丹之手"
                action_hotkey = get_hotkey(0, "古尔丹之手")
            elif state_dict.get("施法技能", -1) == 18 and state_dict.get("灵魂碎片", -1) < 5:
                current_step = "施放 逻辑-暗影箭"
                action_hotkey = get_hotkey(0, "暗影箭")
            elif assistant == 3 and spells.get("邪能统御") == 0:
                current_step = "施放 邪能统御"
                action_hotkey = get_hotkey(0, "邪能统御")
            else:
                action_map = {
                    1: ("古尔丹之手", "古尔丹之手"),
                    2: ("召唤恐惧猎犬", "召唤恐惧猎犬"),
                    3: ("召唤恶魔卫士", "召唤恶魔卫士"),
                    4: ("恶魔之箭", "恶魔之箭"),
                    5: ("暗影箭", "暗影箭"),
                    10: ("陨灭", "古尔丹之手"),
                    11: ("狱火箭", "暗影箭"),
                }
                tup = action_map.get(assistant)
                if tup:
                    current_step = f"施放 {tup[0]}"
                    action_hotkey = get_hotkey(0, tup[1])
                else:
                    current_step = "战斗中-无匹配技能"

    elif spec_name == "毁灭":
        return action_hotkey, current_step, unit_info
    
    
    return action_hotkey, current_step, unit_info