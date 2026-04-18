# -*- coding: utf-8 -*-

from utils import *

# 将需要驱散的首领 ID
need_dispel_bosses = {4, 5}
# 不需要驱散的首领 ID
no_dispel_bosses = {64}

action_map = {
    1: ("轮回之触", "轮回之触"),
    10: ("猛虎掌", "猛虎掌"),
    11: ("神鹤引项踢", "神鹤引项踢"),
    12: ("幻灭踢", "幻灭踢"),
    13: ("爆炸酒桶", "爆炸酒桶"),
    14: ("真气爆裂", "真气爆裂"),
    15: ("醉酿投", "醉酿投"),
    16: ("火焰之息", "火焰之息"),
    17: ("碧玉疾风", "碧玉疾风"),
    20: ("幻灭踢", "幻灭踢"),
    21: ("怒雷破", "怒雷破"),
    22: ("旭日东升踢", "旭日东升踢"),
    18: ("碎玉闪电", "碎玉闪电"),
    19: ("神鹤引项踢", "神鹤引项踢"),
    23: ("风领主之击", "风领主之击"),
    24: ("疾风呼啸踢", "旭日东升踢"),
    25: ("升龙霸", "升龙霸"),
}

failed_spell_map = {
    1: "轮回之触",
    2: "扫堂腿",
    3: "魂体双分",
    4: "魂体双分：转移",
    5: "作茧缚命",
    6: "还魂术",
    7: "平心之环",
    8: "分筋错骨",
    9: "玄牛下凡",
}

# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None

def run_monk_logic(state_dict, spec_name):
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
    
    if 引导 > 0:
        current_step = "在引导,不执行任何操作"
    elif 法术失败 != 0 and 失败法术 is not None:
        current_step = f"施放 {失败法术}"
        action_hotkey = get_hotkey(0, 失败法术)
    elif spec_name == "酒仙":
        酒池 = state_dict.get("酒池", 0)
        目标生命值 = state_dict.get("目标生命值", 0)
        敌人人数 = state_dict.get("敌人人数", 0)
        活力苏醒 = state_dict.get("活力苏醒", 0)
        疗伤珠 = state_dict.get("疗伤珠", 0)
        清空地窖 = state_dict.get("清空地窖", 0)

        醉酿投 = spells.get("醉酿投", 0)
        醉酿充能 = spells.get("醉酿充能", 0)
        活血酒 = spells.get("活血酒", 0)
        活血充能 = spells.get("活血充能", 0)
        天神酒 = spells.get("天神酒", 0)
        天神充能 = spells.get("天神充能", 0)
        天神灌注 = spells.get("天神灌注", 0)
        灌注充能 = spells.get("灌注充能", 0)
        轮回之触 = spells.get("轮回之触", 0)
        扫堂腿 = spells.get("扫堂腿", 0)
        移花接木 = spells.get("移花接木", 0)
        魂体双分 = spells.get("魂体双分", 0)
        转移 = spells.get("魂体双分：转移", 0)
        切喉手 = spells.get("切喉手", 0)
        火焰之息 = spells.get("火焰之息", 0)
        真气爆裂 = spells.get("真气爆裂", 0)
        爆炸酒桶 = spells.get("爆炸酒桶", 0)
        赤精之歌 = spells.get("赤精之歌", 0)

        def _combat_logic():
            current_step = None
            action_hotkey = None
            if 酒池 > 10 and 天神酒 == 0 and 天神充能 == 0:
                current_step = "施放 天神酒"
                action_hotkey = get_hotkey(0, "天神酒")
            elif 酒池 > 10 and 天神灌注 == 0 and 灌注充能 == 0:
                current_step = "施放 天神灌注"
                action_hotkey = get_hotkey(0, "天神灌注")
            elif 酒池 > 30 and 活血酒 == 0 and 活血充能 == 0:
                current_step = "施放 活血酒"
                action_hotkey = get_hotkey(0, "活血酒")
            elif 酒池 > 60 and 活血酒 < 1:
                current_step = "施放 活血酒"
                action_hotkey = get_hotkey(0, "活血酒")
            elif 移花接木 == 0 and 疗伤珠 >= 3 and 生命值 < 80:
                current_step = "施放 移花接木"
                action_hotkey = get_hotkey(0, "移花接木")
            elif 活力苏醒 > 0 and 生命值 < 80:
                current_step = "施放 [@player]活血术"
                action_hotkey = get_hotkey(1, "活血术")
            elif 醉酿投 > 3 and 爆炸酒桶 == 0:
                current_step = "施放 爆炸酒桶"
                action_hotkey = get_hotkey(0, "爆炸酒桶")
            elif 清空地窖 > 0:
                current_step = "施放 爆炸酒桶"
                action_hotkey = get_hotkey(0, "爆炸酒桶")
            elif 醉酿投 < 1:
                current_step = "施放 醉酿投"
                action_hotkey = get_hotkey(0, "醉酿投")
            elif tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"

            return current_step, action_hotkey

        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 战斗 and 1 <= 目标类型 <= 3:
            current_step, action_hotkey = _combat_logic()
        else:
            current_step = "非战斗状态,不执行任何操作"

    elif spec_name == "织雾":
        敌人人数 = state_dict.get("敌人人数", 0)
        施法技能 = state_dict.get("施法技能", 0)
        施法目标 = state_dict.get("施法目标", 0)

        法力茶层数 = state_dict.get("法力茶层数", 0)
        生生不息1 = state_dict.get("生生不息1", 0)
        生生不息2 = state_dict.get("生生不息2", 0)
        神龙层数 = state_dict.get("神龙层数", 0)
        灵泉 = state_dict.get("灵泉", 0)
        玄牛之力 = state_dict.get("玄牛之力", 0)
        青龙之心 = state_dict.get("青龙之心", 0)

        雷光茶 = spells.get("雷光茶", -1)
        雷光充能 = spells.get("雷光充能", -1)
        复苏之雾 = spells.get("复苏之雾", -1)
        复苏充能 = spells.get("复苏充能", -1)
        还魂术 = spells.get("还魂术", -1)
        作茧缚命 = spells.get("作茧缚命", -1)
        清创生血 = spells.get("清创生血", -1)
        天神御身 = spells.get("天神御身", -1)
        轮回之触 = spells.get("轮回之触", -1)
        扫堂腿 = spells.get("扫堂腿", -1)
        宁神茶 = spells.get("宁神茶", -1)
        魂体双分 = spells.get("魂体双分", -1)
        转移 = spells.get("魂体双分：转移", -1)
        旭日东升踢 = spells.get("旭日东升踢", -1)
        幻灭踢 = spells.get("幻灭踢", -1)

        生命值最低单位, 最低生命值 = get_lowest_health_unit(state_dict, 100)
        无复苏单位, 无复苏生命值 = get_lowest_health_unit_without_aura(state_dict, "复苏之雾", 101)
        无氤氲单位, 无氤氲生命值 = get_lowest_health_unit_without_aura(state_dict, "氤氲之雾", 101)
        count90 = get_count_units_below_health(state_dict, 90)
        count80 = get_count_units_below_health(state_dict, 80)

        魔法单位, _ = get_unit_with_dispel_type(state_dict, 1)
        疾病单位, _ = get_unit_with_dispel_type(state_dict, 3)
        中毒单位, _ = get_unit_with_dispel_type(state_dict, 4)

        # 将需要驱散的首领 ID
        need_dispel_bosses = {4, 5}
        # 不需要驱散的首领 ID
        no_dispel_bosses = {64}

        if 施法技能 == 30:  # 氤氲之雾
            玄牛之力 = 0
            生生不息1 = 0
        if 施法技能 == 26:  # 神龙之赐
            神龙层数 = 0
            生生不息2 = 0
        if 施法技能 == 27:  # 活血术
            生生不息2 = 0

        驱散单位 = None
        if 魔法单位 is not None:
            if 队伍类型 == 46 and 首领战 not in no_dispel_bosses:
                驱散单位 = 魔法单位
            elif 队伍类型 <= 40 and 首领战 in need_dispel_bosses:
                驱散单位 = 魔法单位
        if 驱散单位 is None:
            驱散单位 = 疾病单位
        if 驱散单位 is None:
            驱散单位 = 中毒单位

        unit_info = {
            "驱散单位": 驱散单位,
            "无复苏单位": 无复苏单位,
            "无复苏生命值": 无复苏生命值,
            "无氤氲单位": 无氤氲单位,
            "无氤氲生命值": 无氤氲生命值,
            "生命值最低单位": 生命值最低单位,
            "最低生命值": 最低生命值,
            "无复苏单位": 无复苏单位,
            "无复苏生命值": 无复苏生命值,
        }

        if 引导 > 0:
            if 施法技能 == 31 and 能量值 >= 95: # 法力茶
                current_step = "施放 复苏之雾"
                action_hotkey = get_hotkey(1, "复苏之雾")
            elif 施法技能 == 31 and 战斗 and count80 >= 3 and 神龙层数 >= 8: # 法力茶
                current_step = f"施放 活血术 on {生命值最低单位}"
                action_hotkey = get_hotkey(int(生命值最低单位), "活血术")
            else:
                current_step = "在引导,不执行任何操作"
        elif 清创生血 == 0 and 驱散单位 is not None:
            current_step = f"施放 清创生血 on {驱散单位}"
            action_hotkey = get_hotkey(int(驱散单位), "清创生血")
        elif 神龙层数 >= 8 and 生命值最低单位 is not None and count80 >= 2 :
            current_step = f"施放 活血术 on {生命值最低单位}"
            action_hotkey = get_hotkey(int(生命值最低单位), "活血术")
        elif 神龙层数 >= 8 and 生命值最低单位 is not None and 最低生命值 < 50:
            current_step = f"施放 活血术 on {生命值最低单位}"
            action_hotkey = get_hotkey(int(生命值最低单位), "活血术")
        elif 生生不息2 >= 1 and 生命值最低单位 is not None and 最低生命值 < 90:
            current_step = f"施放 活血术 on {生命值最低单位}"
            action_hotkey = get_hotkey(int(生命值最低单位), "活血术")
        elif not 战斗:
            if 复苏之雾 == 0 and 无复苏单位 is not None:
                current_step = f"施放 复苏之雾 on {无复苏单位}"
                action_hotkey = get_hotkey(int(无复苏单位), "复苏之雾")
            elif 生生不息1 >= 1 and 无氤氲单位 is not None and 无氤氲生命值 < 90:
                current_step = f"施放 活血术 on {无氤氲单位}"
                action_hotkey = get_hotkey(int(无氤氲单位), "活血术")
            elif 法力茶层数 >= 15 and 能量值 <= 60:
                current_step = "施放 法力茶"
                action_hotkey = get_hotkey(0, "法力茶")
        elif 战斗:
            # 复苏之雾
            if 复苏之雾 == 0 and 复苏充能 <= 1 and 无复苏单位 is not None:
                current_step = f"施放 复苏之雾 on {无复苏单位}"
                action_hotkey = get_hotkey(int(无复苏单位), "复苏之雾")
            # 法力茶
            elif 法力茶层数 >= 15 and 能量值 <= 20:
                current_step = "施放 法力茶"
                action_hotkey = get_hotkey(0, "法力茶")
            elif 宁神茶 == 0 and 神龙层数 < 10 and 法力茶层数 + 神龙层数 >= 10:
                current_step = "施放 法力茶"
                action_hotkey = get_hotkey(0, "法力茶")
            # 雷光聚神茶
            elif 1 <= 目标类型 <= 3 and 旭日东升踢 == 0 and 雷光茶 == 0:
                current_step = "施放 雷光聚神茶"
                action_hotkey = get_hotkey(0, "雷光聚神茶")
            # 旭日东升踢
            elif 1 <= 目标类型 <= 3 and 旭日东升踢 == 0:
                current_step = "施放 旭日东升踢"
                action_hotkey = get_hotkey(0, "旭日东升踢")
            # 天神御身
            elif 1 <= 目标类型 <= 3 and count80 >= 3 and 天神御身 == 0:
                current_step = "施放 天神御身"
                action_hotkey = get_hotkey(0, "天神御身")
            # 复苏之雾
            elif 复苏之雾 == 0 and 无复苏单位 is not None:
                current_step = f"施放 复苏之雾 on {无复苏单位}"
                action_hotkey = get_hotkey(int(无复苏单位), "复苏之雾")
            # 氤氲之雾
            elif 玄牛之力 > 0 and 施法技能 != 30 and 无氤氲单位 is not None:
                current_step = f"施放 氤氲之雾 on {无氤氲单位}"
                action_hotkey = get_hotkey(int(无氤氲单位), "氤氲之雾")
            # 神鹤引项踢
            elif 1 <= 目标类型 <= 3 and 敌人人数 >= 5:
                current_step = "施放 神鹤引项踢"
                action_hotkey = get_hotkey(0, "神鹤引项踢")
            # 幻灭踢
            elif 1 <= 目标类型 <= 3 and 幻灭踢 == 0:
                current_step = "施放 幻灭踢"
                action_hotkey = get_hotkey(0, "幻灭踢")
            # 猛虎掌
            elif 1 <= 目标类型 <= 3:
                current_step = "施放 猛虎掌"
                action_hotkey = get_hotkey(0, "猛虎掌")
            else:
                current_step = "不执行任何操作"
                return None, current_step, unit_info

    elif spec_name == "踏风":
        目标生命值 = state_dict.get("目标生命值", 0)
        敌人人数 = state_dict.get("敌人人数", 0)

        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 战斗 and 1 <= 目标类型 <= 3 and tup:
            current_step = f"施放 {tup[0]}"
            action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "战斗中-无匹配技能"

    return action_hotkey, current_step, unit_info