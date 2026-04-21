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
    16: "灰烬觉醒",
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

def get_action_hotkey(skill_name, unit=0):
    """获取技能按键，特殊技能直接返回固定按键"""
    if skill_name in direct_key_map:
        return direct_key_map[skill_name]
    return get_hotkey(unit, skill_name)

def run_paladin_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}

    # 基础状态变量
    战斗 = state_dict.get("战斗", False)
    移动 = state_dict.get("移动", False)
    施法 = state_dict.get("施法")
    引导 = state_dict.get("引导")
    生命值 = state_dict.get("生命值")
    能量值 = state_dict.get("能量值")
    一键辅助 = state_dict.get("一键辅助")
    法术失败 = state_dict.get("法术失败", 0)
    目标类型 = state_dict.get("目标类型", False)
    目标距离 = state_dict.get("目标距离")
    目标生命值 = state_dict.get("目标生命值", 0)
    敌人人数 = state_dict.get("敌人人数", 0)
    队伍类型 = int(state_dict.get("队伍类型", 0) or 0)
    队伍人数 = int(state_dict.get("队伍人数", 0) or 0)
    首领战 = int(state_dict.get("首领战", 0) or 0)
    难度 = int(state_dict.get("难度", 0) or 0)
    英雄天赋 = int(state_dict.get("英雄天赋", 0) or 0)
    神圣能量 = state_dict.get("神圣能量", 0)
    施法技能 = state_dict.get("施法技能", 0)
    施法目标 = state_dict.get("施法目标", 0)
    失败法术 = _get_failed_spell(state_dict)
    
    # 神圣专精变量（BUFF）
    神圣意志BUFF = state_dict.get("神圣意志", 0)
    圣光灌注BUFF = state_dict.get("圣光灌注", 0)
    神性层数BUFF = state_dict.get("神性层数", 0)
    # 神圣专精变量（CD）
    神圣震击CD = spells.get("神圣震击", -1)
    震击充能CD = spells.get("震击充能", -1)
    清洁术CD = spells.get("清洁术", -1)
    盲目之光CD = spells.get("盲目之光", -1)
    审判CD = spells.get("审判", -1)
    圣洁鸣钟CD = spells.get("圣洁鸣钟", -1)
    神圣棱镜CD = spells.get("神圣棱镜", -1)
    光环掌握CD = spells.get("光环掌握", -1)
    牺牲祝福CD = spells.get("牺牲祝福", -1)
    自由祝福CD = spells.get("自由祝福", -1)
    制裁之锤CD = spells.get("制裁之锤", -1)
    保护祝福CD = spells.get("保护祝福", -1)
    圣疗术CD = spells.get("圣疗术", -1)
    美德道标CD = spells.get("美德道标", -1)
    
    # 防护专精变量（BUFF）
    军备类型BUFF = state_dict.get("军备类型", 0)
    闪耀之光BUFF = state_dict.get("闪耀之光", 0)
    神圣壁垒BUFF = state_dict.get("神圣壁垒", 0)
    圣洁武器BUFF = state_dict.get("圣洁武器", 0)
    壁垒充能BUFF = state_dict.get("壁垒充能", 0)
    奉献BUFF = state_dict.get("奉献", 0)
    复仇之怒BUFF = state_dict.get("复仇之怒", 0)
    圣光之锤BUFF = state_dict.get("圣光之锤", 0)
    神圣意志BUFF = state_dict.get("神圣意志", 0)

    # 防护专精变量（CD）
    神圣壁垒CD = spells.get("神圣壁垒", -1)
    奉献CD = spells.get("奉献", -1)
    审判CD = spells.get("审判", -1)
    祝福之锤CD = spells.get("祝福之锤", -1)
    正义之锤CD = spells.get("正义之锤", -1)
    复仇者之盾CD = spells.get("复仇者之盾", -1)
    圣洁鸣钟CD = spells.get("圣洁鸣钟", -1)

    # 惩戒专精变量
    处决宣判CD = spells.get("处决宣判", -1)
    灰烬觉醒CD = spells.get("灰烬觉醒", -1)
    审判CD = spells.get("审判", -1)
    公正之剑CD = spells.get("公正之剑", -1)
    处决宣判BUFF = state_dict.get("处决宣判", 0)
    复仇之怒CD = spells.get("复仇之怒", -1)
    复仇之怒BUFF = state_dict.get("复仇之怒", 0)

    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    if spec_name == "神圣":

        dispel_unit_magic, _ = get_unit_with_dispel_type(state_dict, 1)
        dispel_unit_disease, _ = get_unit_with_dispel_type(state_dict, 3)
        dispel_unit_poison, _ = get_unit_with_dispel_type(state_dict, 4)
        最低单位, 最低生命值 = get_lowest_health_unit(state_dict, 100)
        count90 = count_units_below_health(state_dict, 90)
        count80 = count_units_below_health(state_dict, 80)
        count75 = count_units_below_health(state_dict, 75)

        圣光限值 = int(40 + (能量值 * 0.3)) # 40-70

        unit_info = {
            "最低单位": 最低单位,
            "最低生命值": 最低生命值,
            "count90": count90,
            "count80": count80,
            "count75": count75,
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

        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_action_hotkey(失败法术)
        elif 清洁术CD == 0 and 驱散单位 is not None:
            current_step = f"施放 清毒术 on {驱散单位}"
            action_hotkey = get_hotkey(int(驱散单位), "清毒术")
        elif 最低单位 is not None and 最低生命值 is not None and 最低生命值 < 90:
            if 圣疗术CD == 0 and 生命值 < 20:
                current_step = "施放 圣疗术"
                action_hotkey = get_hotkey(1, "圣疗术")
            elif 圣疗术CD == 0 and 神圣能量 < 3 and 最低生命值 < 15:
                current_step = f"施放 圣疗术 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣疗术")
            elif 美德道标CD == 0 and count75 >= 3:
                current_step = "施放 美德道标"
                action_hotkey = get_hotkey(0, "美德道标")
            elif 圣洁鸣钟CD == 0 and 神圣能量 <= 2 and count75 >= 3:
                current_step = "施放 圣洁鸣钟"
                action_hotkey = get_hotkey(1, "圣洁鸣钟")
            elif 施法 == 0 and 最低生命值 < 70 and 神性层数BUFF > 0:
                current_step = f"施放 圣光术 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣光术")
            elif (神圣能量 >= 3 or 神圣意志BUFF > 0) and 最低生命值 <= 80:
                current_step = f"施放 荣耀圣令 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "荣耀圣令")
            elif 施法 == 0 and 移动 == 0 and 最低生命值 < 50 and 能量值 >= 50:
                current_step = f"施放 圣光术 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣光术")
            elif 施法 == 0 and 圣光灌注BUFF > 0 and 最低生命值 <= 85 and 神圣能量 <= 3:
                current_step = f"施放 圣光闪现 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣光闪现")
            elif 神圣震击CD == 0 and 施法 == 0 and 圣光灌注BUFF == 0 and 最低生命值 < 90:
                current_step = f"施放 神圣震击 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "神圣震击")
            elif 战斗 and 1 <= 目标类型 <= 3 and 神圣能量 == 2 and 审判CD <= 1:
                current_step = "施放 审判"
                action_hotkey = get_hotkey(0, "审判")
            elif 施法 == 0 and 移动 == 0 and 圣光灌注BUFF == 0 and 最低生命值 < 90 and 神圣能量 <= 4:
                current_step = f"施放 圣光闪现 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "圣光闪现")
            else:
                current_step = "无匹配技能"
        elif 战斗 and 1 <= 目标类型 <= 3:
            if (神圣能量 == 5 or (神圣意志BUFF > 0 and 神圣能量 >= 5)) and 目标距离 is not None and 目标距离 <= 5:
                current_step = "施放 正义盾击"
                action_hotkey = get_hotkey(0, "正义盾击")
            elif 神圣能量 <= 4 and 审判CD == 0:
                current_step = "施放 审判"
                action_hotkey = get_hotkey(0, "审判")
            elif 神圣能量 <= 4 and 神圣震击CD == 0:
                current_step = "施放 神圣震击"
                action_hotkey = get_hotkey(0, "神圣震击")
                current_step = "施放 神圣震击"
                action_hotkey = get_hotkey(0, "神圣震击")
            else:
                current_step = "无匹配技能"
        
        # 将最低生命值单位信息添加到 unit_info
        unit_info["最低单位"] = 最低单位
        unit_info["最低生命值"] = 最低生命值

    elif spec_name == "防护":
        最低单位, 最低生命值 = get_lowest_health_unit(state_dict, 100)
        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_action_hotkey(失败法术)
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 军备类型BUFF == 1 and 神圣壁垒CD == 0 and 壁垒充能BUFF == 0:
                current_step = "施放 神圣壁垒"
                action_hotkey = get_hotkey(0, "神圣壁垒")
            elif 军备类型BUFF == 2 and 神圣壁垒CD == 0 and 圣洁武器BUFF == 0:
                current_step = "施放 神圣壁垒"
                action_hotkey = get_hotkey(0, "神圣壁垒")
            elif 闪耀之光BUFF > 0 and 生命值 < 80:
                current_step = "施放 荣耀圣令"
                action_hotkey = get_hotkey(0, "荣耀圣令")
            elif 移动 == 0 and 奉献BUFF == 0 and 奉献CD == 0:
                current_step = "施放 奉献"
                action_hotkey = get_hotkey(0, "奉献")
            elif 圣光之锤BUFF > 0 and 神圣能量 >= 3:
                current_step = "施放 圣光之锤"
                action_hotkey = get_hotkey(1, "圣洁鸣钟")
            elif 复仇之怒BUFF > 0 and 圣洁鸣钟CD == 0:
                current_step = "施放 圣洁鸣钟"
                action_hotkey = get_hotkey(1, "圣洁鸣钟")
            elif ((神圣能量 >= 3 and 圣光之锤BUFF == 0) or 神圣意志BUFF > 0) and 目标距离 is not None and 目标距离 <= 5:
                current_step = "施放 正义盾击"
                action_hotkey = get_hotkey(0, "正义盾击")
            elif 复仇者之盾CD == 0:
                current_step = "施放 复仇者之盾"
                action_hotkey = get_hotkey(0, "复仇者之盾") 
            elif 审判CD == 0:
                current_step = "施放 审判"
                action_hotkey = get_hotkey(0, "审判")
            elif (祝福之锤CD == 0 or 正义之锤CD == 0):
                current_step = "施放 祝福之锤"
                action_hotkey = get_hotkey(0, "祝福之锤")
            else:
                current_step = "战斗中-无匹配技能"

        # 将最低生命值单位信息添加到 unit_info
        unit_info["最低单位"] = 最低单位
        unit_info["最低生命值"] = 最低生命值

    elif spec_name == "惩戒":
        最低单位, 最低生命值 = get_lowest_health_unit(state_dict, 100)
        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_action_hotkey(失败法术)
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 圣疗术CD == 0 and 生命值 < 20:
                current_step = "施放 圣疗术"
                action_hotkey = get_hotkey(1, "圣疗术")
            elif 生命值 < 30 and 神圣能量 >= 3:
                current_step = "施放 荣耀圣令"
                action_hotkey = get_hotkey(0, "荣耀圣令")
            elif 复仇之怒BUFF > 0 and 处决宣判CD == 0:
                current_step = "施放 处决宣判"
                action_hotkey = get_hotkey(0, "处决宣判")
            elif 灰烬觉醒CD == 0 and 处决宣判BUFF > 0:
                current_step = "施放 灰烬觉醒"
                action_hotkey = get_hotkey(0, "灰烬觉醒")
            elif 处决宣判BUFF > 0 and 圣光之锤BUFF > 0 and 神圣能量 == 5:
                current_step = "施放 圣光之锤"
                action_hotkey = get_hotkey(0, "灰烬觉醒")
            elif 神圣能量 < 3 and 圣洁鸣钟CD == 0 and 灰烬觉醒CD >=25:
                current_step = "施放 圣洁鸣钟"
                action_hotkey = get_hotkey(0, "圣洁鸣钟")
            elif 圣光之锤BUFF > 0 and 神圣能量 >=3:
                current_step = "施放 圣光之锤"
                action_hotkey = get_hotkey(0, "灰烬觉醒")
            elif 神圣能量 >=3 and 敌人人数 >= 2:
                current_step = "施放 神圣风暴"
                action_hotkey = get_hotkey(0, "神圣风暴")
            elif 神圣能量 >=3 and 敌人人数 < 2:
                current_step = "施放 最终审判"
                action_hotkey = get_hotkey(0, "最终审判")
            elif 神圣能量 <=3 and 公正之剑CD ==0:
                current_step = "施放 公正之剑"
                action_hotkey = get_hotkey(0, "公正之剑")
            elif 神圣能量 <=4 and 审判CD == 0:
                current_step = "施放 审判"
                action_hotkey = get_hotkey(0, "审判")
            
        

            
            
            else:
                current_step = "战斗中-无匹配技能"

    return action_hotkey, current_step, unit_info
