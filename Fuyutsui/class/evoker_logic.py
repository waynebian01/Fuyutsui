# -*- coding: utf-8 -*-

from utils import *
action_map = {
    2: ("火焰吐息", "火焰吐息"),
    3: ("青铜龙的祝福", "青铜龙的祝福"),
    8: ("碧蓝打击", "碧蓝打击"),
    12: ("活化烈焰", "活化烈焰"),
    13: ("裂解", "裂解"),
    16: ("永恒之涌", "永恒之涌"),
    17: ("葬火", "葬火"),
    25: ("碧蓝横扫", "碧蓝打击"),
    26: ("火焰吐息", "火焰吐息"),
    27: ("永恒之涌", "永恒之涌"),
    
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

def run_evoker_logic(state_dict, spec_name):
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

    if spec_name == "湮灭":

        施法技能 = state_dict.get("施法技能", 0)

        火焰吐息CD = spells.get("火焰吐息", -1)
        永恒之涌CD = spells.get("永恒之涌", -1)

        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        if 蓄力 > 0:
            if 蓄力层数 == 1 and 施法技能 == 26:
                current_step = "施放 火焰吐息"
                action_hotkey = get_hotkey(0, "火焰吐息")
            elif 蓄力层数 == 1 and 施法技能 == 27:
                current_step = "施放 永恒之涌"
                action_hotkey = get_hotkey(0, "永恒之涌")
            else:
                current_step = "蓄力中-无匹配技能"
        elif 一键辅助 == 3:
            current_step = "施放 青铜龙的祝福"
            action_hotkey = get_hotkey(0, "青铜龙的祝福")
        elif 战斗 and 1 <= 目标类型 <= 3 and tup:
            current_step = f"施放 {tup[0]}"
            action_hotkey = get_hotkey(0, tup[1])
            unit_info["_delay"] = 0.5  # 添加延迟
        else:
            current_step = "无匹配技能"
        
    elif spec_name == "恩护":
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
    elif spec_name == "增辉":
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
