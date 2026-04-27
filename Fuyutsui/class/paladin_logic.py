# -*- coding: utf-8 -*-
"""圣骑士职业的逻辑决策（神圣/防护/惩戒）。"""
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

def run_paladin_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}

    # ==================== 基础状态变量 ====================
    战斗 = state_dict.get("战斗", 0)
    移动 = state_dict.get("移动", 0)
    施法 = state_dict.get("施法", 0)
    引导 = state_dict.get("引导", 0)
    生命值 = state_dict.get("生命值")
    能量值 = state_dict.get("能量值")
    一键辅助 = state_dict.get("一键辅助")
    法术失败 = state_dict.get("法术失败", 0)
    目标类型 = state_dict.get("目标类型", 0)
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

    # ==================== 公共变量（多专精共享） ====================
    # --- BUFF ---
    神圣意志BUFF = state_dict.get("神圣意志", 0)
    复仇之怒BUFF = state_dict.get("复仇之怒", 0)
    # --- CD ---
    审判CD = spells.get("审判", -1)
    圣洁鸣钟CD = spells.get("圣洁鸣钟", -1)
    复仇之怒CD = spells.get("复仇之怒", -1)

    # ==================== 神圣专精变量 ====================
    # --- BUFF ---
    圣光灌注BUFF = state_dict.get("圣光灌注", 0)
    神性层数BUFF = state_dict.get("神性层数", 0)
    # --- CD ---
    神圣震击CD = spells.get("神圣震击", -1)
    震击充能CD = spells.get("震击充能", -1)
    清洁术CD = spells.get("清洁术", -1)
    盲目之光CD = spells.get("盲目之光", -1)
    神圣棱镜CD = spells.get("神圣棱镜", -1)
    光环掌握CD = spells.get("光环掌握", -1)
    牺牲祝福CD = spells.get("牺牲祝福", -1)
    自由祝福CD = spells.get("自由祝福", -1)
    制裁之锤CD = spells.get("制裁之锤", -1)
    保护祝福CD = spells.get("保护祝福", -1)
    圣疗术CD = spells.get("圣疗术", -1)
    美德道标CD = spells.get("美德道标", -1)

    # ==================== 防护专精变量 ====================
    # --- BUFF ---
    军备类型BUFF = state_dict.get("军备类型", 0)
    闪耀之光BUFF = state_dict.get("闪耀之光", 0)
    神圣壁垒BUFF = state_dict.get("神圣壁垒", 0)
    圣洁武器BUFF = state_dict.get("圣洁武器", 0)
    壁垒充能BUFF = state_dict.get("壁垒充能", 0)
    奉献BUFF = state_dict.get("奉献", 0)
    圣光之锤BUFF = state_dict.get("圣光之锤", 0)
    # --- CD ---
    神圣壁垒CD = spells.get("神圣壁垒", -1)
    奉献CD = spells.get("奉献", -1)
    祝福之锤CD = spells.get("祝福之锤", -1)
    正义之锤CD = spells.get("正义之锤", -1)
    复仇者之盾CD = spells.get("复仇者之盾", -1)


    # ==================== 惩戒专精变量 ====================
    # --- BUFF ---
    处决宣判BUFF = state_dict.get("处决宣判", 0)
    # --- CD ---
    清毒术CD = spells.get("清毒术", -1)
    处决宣判CD = spells.get("处决宣判", -1)
    灰烬觉醒CD = spells.get("灰烬觉醒", -1)
    公正之剑CD = spells.get("公正之剑", -1)

    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    if spec_name == "神圣":
        dispel_unit_magic, _ = get_unit_with_dispel_type(state_dict, 1)
        dispel_unit_disease, _ = get_unit_with_dispel_type(state_dict, 3)
        dispel_unit_poison, _ = get_unit_with_dispel_type(state_dict, 4)
        最低单位, 最低生命值 = get_lowest_health_unit(state_dict, 100)
        无火最低, 无火最低血量 = get_lowest_health_unit_without_aura(state_dict, "永恒之火", health_threshold=101)
        count90 = count_units_below_health(state_dict, 90)
        count80 = count_units_below_health(state_dict, 80)
        count75 = count_units_below_health(state_dict, 75)

        unit_info = {
            "最低单位": 最低单位,
            "最低生命值": 最低生命值,
            "无火最低": 无火最低,
            "无火最低血量": 无火最低血量,
            "count90": count90,
            "count80": count80,
            "count75": count75,
        }

        # 驱散优先级：魔法 > 疾病 > 毒素
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

        # ---- 优先级 0: 引导中 ----
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"

        # ---- 优先级 1: 法术失败重试 ----
        elif 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放: {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)

        # ---- 优先级 2: 驱散 ----
        elif 清洁术CD == 0 and 驱散单位 is not None:
            current_step = f"施放: 清毒术 on {驱散单位}"
            action_hotkey = get_hotkey(int(驱散单位), "清毒术")
        elif 清洁术CD == 0 and 目标类型 == 12:
            current_step = "施放: 清毒术 on 目标"
            action_hotkey = get_hotkey(0, "清毒术")
        
        # ---- 自救 ----
        elif 圣疗术CD == 0 and 生命值 < 20:
            current_step = "施放: 圣疗术"
            action_hotkey = get_hotkey(1, "圣疗术")
        # ---- AOE群抬 ----
        # 美德道标
        elif 美德道标CD == 0 and count75 >= 3:
            current_step = "施放: 美德道标"
            action_hotkey = get_hotkey(0, "美德道标")
        # 圣洁鸣钟:
        elif 美德道标CD >= 6 and 圣洁鸣钟CD == 0 and 神圣能量 <= 2 and count80 >= 3:
            current_step = "群奶: 圣洁鸣钟"
            action_hotkey = get_hotkey(1, "圣洁鸣钟")
        # ---- 5豆消耗 ----
        elif 神圣能量 == 5:
            # 永恒之火
            if 无火最低 is not None and 无火最低血量 is not None and 无火最低血量 <= 80:
                current_step = f"5豆: 永恒之火 on {无火最低}"
                action_hotkey = get_hotkey(int(无火最低), "荣耀圣令")
            # 荣耀圣令
            elif 最低单位 is not None and 最低生命值 is not None and 最低生命值 <= 75:
                current_step = f"5豆: 荣耀圣令 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "荣耀圣令")
            # 群抬: 黎明之光
            elif count90 >= 3:
                current_step = "5豆: 黎明之光"
                action_hotkey = get_hotkey(0, "黎明之光")
            # 进攻: 正义盾击
            elif 战斗 and 1 <= 目标类型 <= 3 and 目标距离 is not None and 目标距离 <= 5:
                current_step = "5豆: 正义盾击"
                action_hotkey = get_hotkey(0, "正义盾击")
        # ---- 3豆/意志消耗 ----
        elif 神圣能量 >= 3 or 神圣意志BUFF > 0:
            # 永恒之火
            if 无火最低 is not None and 无火最低血量 is not None and 无火最低血量 <= 80:
                current_step = f"3豆: 永恒之火 on {无火最低}"
                action_hotkey = get_hotkey(int(无火最低), "荣耀圣令")
            # 荣耀圣令
            elif 最低单位 is not None and 最低生命值 is not None and 最低生命值 <= 75:
                current_step = f"3豆: 荣耀圣令 on {最低单位}"
                action_hotkey = get_hotkey(int(最低单位), "荣耀圣令")
            # 群抬: 黎明之光
            elif count90 >= 3:
                current_step = "3豆: 黎明之光"
                action_hotkey = get_hotkey(0, "黎明之光")
        # ---- 神性层免费圣光术 ----
        elif 最低单位 is not None and 最低生命值 is not None and not 施法 and 神性层数BUFF > 0 and 最低生命值 < 60:
            current_step = f"神性: 圣光术 on {最低单位}"
            action_hotkey = get_hotkey(int(最低单位), "圣光术")
        # ---- 灌注圣光闪现 ----
        elif 最低单位 is not None and 最低生命值 is not None and not 施法 and 圣光灌注BUFF > 0 and 最低生命值 <= 85 and 神圣能量 <= 3:
            current_step = f"灌注: 圣光闪现 on {最低单位}"
            action_hotkey = get_hotkey(int(最低单位), "圣光闪现")
        # ---- 神圣震击 ----
        elif 最低单位 is not None and 最低生命值 is not None and 神圣震击CD == 0 and not 施法 and 圣光灌注BUFF == 0 and 最低生命值 < 90 and 神圣能量 <= 4:
            current_step = f"施放: 神圣震击 on {最低单位}"
            action_hotkey = get_hotkey(int(最低单位), "神圣震击")
        # ---- 圣光术站桩 ----
        elif 最低单位 is not None and 最低生命值 is not None and not 施法 and not 移动 and 最低生命值 < 50 and 能量值 >= 50:
            current_step = f"站桩: 圣光术 on {最低单位}"
            action_hotkey = get_hotkey(int(最低单位), "圣光术")
        # ---- 审判补能量 ----
        elif 战斗 and 1 <= 目标类型 <= 3 and 神圣能量 == 2 and 审判CD == 0:
            current_step = "能量: 审判"
            action_hotkey = get_hotkey(0, "审判")
        # ---- 平刷兜底 ----
        elif 最低单位 is not None and 最低生命值 is not None and not 施法 and not 移动 and 最低生命值 <= 90 and 圣光灌注BUFF == 0:
            current_step = f"平刷: 圣光闪现 on {最低单位}"
            action_hotkey = get_hotkey(int(最低单位), "圣光闪现")
        else:
            current_step = "无匹配技能"
        # ---- 进攻攒豆（独立判断，不受 elif 链限制） ----
        if current_step == "无匹配技能" and 战斗 and 1 <= 目标类型 <= 3:
            # 审判优先
            if 神圣能量 <= 4 and 审判CD == 0:
                current_step = "进攻: 审判"
                action_hotkey = get_hotkey(0, "审判")
            # 震击兜底
            elif not 施法 and 神圣能量 <= 4 and 神圣震击CD == 0:
                current_step = "进攻: 神圣震击"
                action_hotkey = get_hotkey(0, "神圣震击")

    elif spec_name == "防护":
        最低单位, 最低生命值 = get_lowest_health_unit(state_dict, 100)
        unit_info = {
            "最低单位": 最低单位,
            "最低生命值": 最低生命值,
        }

        # ---- 优先级 1: 法术失败重试 ----
        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)

        # ---- 优先级 2: 防御技能 ----
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 军备类型BUFF == 1 and 神圣壁垒CD == 0 and 壁垒充能BUFF == 0:  # 军备模式1: 壁垒
                current_step = "施放 神圣壁垒"
                action_hotkey = get_hotkey(0, "神圣壁垒")
            elif 军备类型BUFF == 2 and 神圣壁垒CD == 0 and 圣洁武器BUFF == 0:  # 军备模式2: 壁垒
                current_step = "施放 神圣壁垒"
                action_hotkey = get_hotkey(0, "神圣壁垒")
            elif 闪耀之光BUFF > 0 and 生命值 < 80:  # 荣耀圣令
                current_step = "施放 荣耀圣令"
                action_hotkey = get_hotkey(0, "荣耀圣令")
            elif not 移动 and 奉献BUFF == 0 and 奉献CD == 0:   # 奉献
                current_step = "施放 奉献"
                action_hotkey = get_hotkey(0, "奉献")

            # ---- 输出循环 ----
            elif 圣光之锤BUFF > 0 and 神圣能量 >= 3:    # 圣光之锤消耗
                current_step = "施放 圣光之锤"
                action_hotkey = get_hotkey(0, "圣洁鸣钟")
            elif 复仇之怒BUFF > 0 and 圣洁鸣钟CD == 0:  # 圣洁鸣钟（增伤）
                current_step = "施放 圣洁鸣钟"
                action_hotkey = get_hotkey(0, "圣洁鸣钟")
            elif ((神圣能量 >= 3 and 圣光之锤BUFF == 0) or 神圣意志BUFF > 0) and 目标距离 is not None and 目标距离 <= 5:    # 正义盾击
                current_step = "施放 正义盾击"
                action_hotkey = get_hotkey(0, "正义盾击")
            elif 复仇者之盾CD == 0: # 复仇者之盾
                current_step = "施放 复仇者之盾"
                action_hotkey = get_hotkey(0, "复仇者之盾")
            elif 审判CD == 0:   # 审判
                current_step = "施放 审判"
                action_hotkey = get_hotkey(0, "审判")
            elif (祝福之锤CD == 0 or 正义之锤CD == 0):  # 填充
                current_step = "施放 祝福之锤"
                action_hotkey = get_hotkey(0, "祝福之锤")
            elif 奉献CD == 0:   # 奉献
                current_step = "施放 奉献"
                action_hotkey = get_hotkey(0, "奉献")
            else:
                current_step = "战斗中-无匹配技能"

    elif spec_name == "惩戒":
        最低单位, 最低生命值 = get_lowest_health_unit(state_dict, 100)
        玩家数据 = (state_dict.get("group") or {}).get("1") or {}
        玩家驱散 = 玩家数据.get("驱散")
        玩家有驱散 = 玩家驱散 is not None and int(玩家驱散) in (3, 4)

        # ---- 优先级 1: 法术失败重试 ----
        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)

        # ---- 优先级 2: 生存 / 自保 ----
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 圣疗术CD == 0 and 生命值 < 20:   # 圣疗术自救
                current_step = "施放 圣疗术"
                action_hotkey = get_hotkey(1, "圣疗术")
            elif 清毒术CD == 0 and 玩家有驱散:  # 驱散
                current_step = "施放 清毒术"
                action_hotkey = get_hotkey(1, "清毒术")
            elif 生命值 < 30 and (神圣能量 >= 3 or 神圣意志BUFF > 0):  # 荣耀圣令自救
                current_step = "施放 荣耀圣令"
                action_hotkey = get_hotkey(0, "荣耀圣令")

            # ---- 输出循环 ----
            elif 复仇之怒BUFF > 0 and 处决宣判CD == 0:  # 处决宣判（增伤）
                current_step = "施放 处决宣判"
                action_hotkey = get_hotkey(0, "处决宣判")
            elif 灰烬觉醒CD == 0 and 处决宣判BUFF > 0 and 神圣能量 < 3:  # 灰烬觉醒攒能
                current_step = "施放 灰烬觉醒"
                action_hotkey = get_hotkey(0, "灰烬觉醒")
            elif 处决宣判BUFF > 0 and 圣光之锤BUFF > 0 and (神圣能量 == 5 or 神圣意志BUFF > 0):  # 圣光之锤消耗
                current_step = "施放 圣光之锤"
                action_hotkey = get_hotkey(0, "灰烬觉醒")
            elif 神圣能量 < 3 and 圣洁鸣钟CD == 0 and 灰烬觉醒CD >= 25:
                current_step = "施放 圣洁鸣钟"  # 圣洁鸣钟攒能
                action_hotkey = get_hotkey(0, "圣洁鸣钟")
            elif 圣光之锤BUFF > 0 and (神圣能量 >= 3 or 神圣意志BUFF > 0):  # 圣光之锤消耗
                current_step = "施放 圣光之锤"
                action_hotkey = get_hotkey(0, "灰烬觉醒")
            elif (神圣能量 >= 3 or 神圣意志BUFF > 0) and 敌人人数 >= 2 and 目标距离 <= 6:  # AOE: 神圣风暴
                current_step = "施放 神圣风暴"
                action_hotkey = get_hotkey(0, "神圣风暴")
            elif (神圣能量 >= 3 or 神圣意志BUFF > 0) and 敌人人数 < 2 and 目标距离 < 10:  # 单体: 最终审判
                current_step = "施放 最终审判"
                action_hotkey = get_hotkey(0, "最终审判")

            # ---- 常规 ----
            elif 神圣能量 <= 3 and 公正之剑CD == 0:
                current_step = "施放 公正之剑"
                action_hotkey = get_hotkey(0, "公正之剑")
            elif 神圣能量 <= 4 and 审判CD == 0:
                current_step = "施放 审判"
                action_hotkey = get_hotkey(0, "审判")
            elif 神圣能量 <= 4 and 公正之剑CD == 0:
                current_step = "施放 公正之剑"
                action_hotkey = get_hotkey(0, "公正之剑")
            else:
                current_step = "战斗中-无匹配技能"

    return action_hotkey, current_step, unit_info
