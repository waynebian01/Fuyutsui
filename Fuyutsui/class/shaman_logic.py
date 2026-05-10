# -*- coding: utf-8 -*-
"""萨满职业逻辑（）。"""

''' 奶萨天赋
    涌动图腾手动释放
    大秘天赋 CgQARUG2fGwHkLP0T7/MoTNl/AAAAgBAAAAjZMLbmZmZmxMjxMGWgFYGLasNgMDshZGMbzMmpZbZmZzMmNWMmZMYWGAAMAzMDmZAYmBD
    团本天赋 CgQARUG2fGwHkLP0T7/MoTNl/AAAAgBAAAAzMzMLLbDzMGzMzMzYGLwGMjFN2GQmB2MDDmtxYmmttZGmxswiZmZMYWGAAAYmZwMDAMYA

'''

from utils import *

# 将需要驱散的首领 ID
need_dispel_bosses = {4, 5}
# 不需要驱散的首领 ID
no_dispel_bosses = {64}

# 失败法术映射
failed_spell_map = {
    13: "涌动图腾",
    14: "电能图腾",
    15: "阵风",
    17: "土元素",
    18: "战栗图腾",
    19: "清毒图腾",
    20: "图腾投射",
    21: "升腾",
}
action_map = {
    1: ("唤潮者的护卫", "唤潮者的护卫"),
    2: ("大地生命武器", "大地生命武器"),
    3: ("天怒", "天怒"),
    4: ("水之护盾", "水之护盾"),
    5: ("烈焰震击", "烈焰震击"),
    6: ("熔岩爆裂", "熔岩爆裂"),
    7: ("闪电箭", "闪电箭"),
    8: ("闪电链", "闪电链"),
    11: ("先祖迅捷", "先祖迅捷"),
    13: ("涌动图腾", "涌动图腾"),
    23: ("毁灭闪电", "毁灭闪电"),
    24: ("流电炽焰", "流电炽焰"),
    25: ("火舌武器", "火舌武器"),
    26: ("熔岩猛击", "熔岩猛击"),
    27: ("裂地术", "裂地术"),
    28: ("始源风暴", "始源风暴"),
    29: ("风切", "风切"),
    30: ("风怒武器", "风怒武器"),
    31: ("风暴打击", "风暴打击"),
    32: ("狂风怒号", "闪电箭"),
    33: ("元素冲击", "元素冲击"),
    34: ("地震术", "地震术"),
    35: ("大地震击", "大地震击"),
    36: ("风暴守护者", "风暴守护者"),
    37: ("闪电之盾", "闪电之盾"),

}

def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None

def _as_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return default

def _ready(value):
    return value == 0

def _active(value):
    return _as_int(value) > 0

def _unit_hotkey(unit, spell):
    if unit is None:
        return None
    return get_hotkey(int(unit), spell)

def _pick_shaman_dispel_unit(state_dict, 队伍类型, 首领战):
    dispel_unit_magic, _ = get_unit_with_dispel_type(state_dict, 1)
    dispel_unit_curse, _ = get_unit_with_dispel_type(state_dict, 2)

    if dispel_unit_magic is not None:
        if 队伍类型 == 46 and 首领战 not in no_dispel_bosses:
            return dispel_unit_magic
        if 队伍类型 <= 40 and 首领战 in need_dispel_bosses:
            return dispel_unit_magic
    return dispel_unit_curse

def _run_totemic_party_logic(state_dict, spells, tup):
    战斗 = state_dict.get("战斗", 0)
    目标类型 = _as_int(state_dict.get("目标类型", 0))
    队伍类型 = _as_int(state_dict.get("队伍类型", 0))
    首领战 = _as_int(state_dict.get("首领战", 0))
    能量值 = _as_int(state_dict.get("能量值", 0))

    潮汐奔涌 = _as_int(state_dict.get("潮汐奔涌", 0))
    涌流层数 = _as_int(state_dict.get("涌流层数", 0))
    生命释放buff = _as_int(state_dict.get("生命释放", 0))
    升腾buff = _as_int(state_dict.get("升腾", 0))

    自然迅捷 = spells.get("自然迅捷", -1)
    激流 = spells.get("激流", -1)
    治疗之泉 = spells.get("治疗之泉图腾", -1)
    净化灵魂 = spells.get("净化灵魂", -1)
    生命释放 = spells.get("生命释放", -1)
    涌动图腾 = spells.get("涌动图腾", -1)
    升腾 = spells.get("升腾", -1)

    lowest_u, lowest_p = get_lowest_health_unit(state_dict, 100)
    无激流最低, 无激流最低血量 = get_lowest_health_unit_without_aura(state_dict, "激流", 101)
    驱散单位 = _pick_shaman_dispel_unit(state_dict, 队伍类型, 首领战)

    count95 = get_count_units_below_health(state_dict, 95)
    count90 = get_count_units_below_health(state_dict, 90)
    count85 = get_count_units_below_health(state_dict, 85)
    count80 = get_count_units_below_health(state_dict, 80)
    count70 = get_count_units_below_health(state_dict, 70)
    count60 = get_count_units_below_health(state_dict, 60)
    count45 = get_count_units_below_health(state_dict, 45)

    unit_info = {
        "最低单位": lowest_u,
        "最低血量": lowest_p,
        "无激流最低": 无激流最低,
        "无激流最低血量": 无激流最低血量,
        "驱散单位": 驱散单位,
        "count95": count95,
        "count90": count90,
        "count85": count85,
        "count80": count80,
        "count70": count70,
        "count60": count60,
        "涌流层数": 涌流层数,
        "潮汐奔涌": 潮汐奔涌,
        "生命释放buff": 生命释放buff,
        "升腾buff": 升腾buff,
        "蓝量": 能量值,
    }

    if _ready(涌动图腾):
        return get_hotkey(0, "涌动图腾"), "图腾-最高优先级: 涌动图腾", unit_info

    # 驱散只处理可确认的队友目标；目标净化没有 unit=0 热键时不挡治疗链路。
    if _ready(净化灵魂) and 驱散单位 is not None:
        return _unit_hotkey(驱散单位, "净化灵魂"), f"图腾-驱散: 净化灵魂 on {驱散单位}", unit_info
    if _ready(净化灵魂) and 目标类型 == 12 and get_hotkey(0, "净化灵魂"):
        return get_hotkey(0, "净化灵魂"), "图腾-目标驱散: 净化灵魂 on 目标", unit_info

    has_lowest = lowest_u is not None and lowest_p is not None
    storm_proc = 涌流层数 > 0
    has_tidal_waves = _active(潮汐奔涌)
    healing_buff = _active(生命释放buff) or has_tidal_waves or _active(升腾buff)
    riptide_target = 无激流最低 if 无激流最低 is not None else lowest_u
    riptide_ready = _ready(激流) and riptide_target is not None
    natural_swiftness_active = _as_int(自然迅捷) == 255
    high_aoe = count60 >= 2 or count70 >= 3 or count85 >= 4
    medium_aoe = count70 >= 2 or count80 >= 3 or count90 >= 4
    pressure_aoe = high_aoe or medium_aoe
    emergency_single = has_lowest and lowest_p <= 60 and not pressure_aoe
    needs_single_heal = has_lowest and lowest_p <= 85

    # 非紧急期尽量卡 CD 铺激流；已有潮汐奔涌且需要单刷时，先把读条治疗打出去。
    if riptide_ready and not emergency_single and not pressure_aoe and (not has_tidal_waves or not needs_single_heal):
        return _unit_hotkey(riptide_target, "激流"), f"图腾-卡CD激流: 激流 on {riptide_target}", unit_info

    def _riptide_before_hard_cast(reason):
        if riptide_ready and not has_tidal_waves:
            return _unit_hotkey(riptide_target, "激流"), f"图腾-{reason}前置潮汐奔涌: 激流 on {riptide_target}", unit_info
        return None

    # 救命线：先保命，再接治疗波。自然迅捷按下后下一轮会进入治疗波。
    if emergency_single:
        if natural_swiftness_active:
            return _unit_hotkey(lowest_u, "治疗波"), f"图腾-自然迅捷治疗波: 治疗波 on {lowest_u}", unit_info
        if _ready(自然迅捷):
            return get_hotkey(0, "自然迅捷"), f"图腾-濒死单点: 自然迅捷 -> 治疗波 on {lowest_u}", unit_info
        if _ready(生命释放):
            return _unit_hotkey(lowest_u, "生命释放"), f"图腾-濒死单点: 生命释放 on {lowest_u}", unit_info
        tide_setup = _riptide_before_hard_cast("濒死治疗波")
        if tide_setup:
            return tide_setup
        return _unit_hotkey(lowest_u, "治疗波"), f"图腾-濒死单点: 治疗波 on {lowest_u}", unit_info

    # 高额 AOE：涌动图腾前置，后续用风暴涌流、治疗泉和治疗链兜住。
    if high_aoe:
        if storm_proc and _ready(治疗之泉):
            return get_hotkey(0, "治疗之泉图腾"), "图腾-高压AOE: 风暴涌流图腾", unit_info
        if _ready(治疗之泉):
            return get_hotkey(0, "治疗之泉图腾"), "图腾-高压AOE: 治疗之泉图腾", unit_info
        if has_lowest and _ready(生命释放):
            return _unit_hotkey(lowest_u, "生命释放"), f"图腾-高压AOE: 生命释放 on {lowest_u}", unit_info
        if has_lowest:
            tide_setup = _riptide_before_hard_cast("高压治疗链")
            if tide_setup:
                return tide_setup
            return _unit_hotkey(lowest_u, "治疗链"), f"图腾-高压AOE: 治疗链 on {lowest_u}", unit_info

    # 双目标/中等 AOE：先吃风暴涌流和治疗泉，再用生命释放+治疗链。
    if medium_aoe:
        if storm_proc and _ready(治疗之泉):
            return get_hotkey(0, "治疗之泉图腾"), "图腾-中压AOE: 风暴涌流图腾", unit_info
        if _ready(治疗之泉):
            return get_hotkey(0, "治疗之泉图腾"), "图腾-中压AOE: 治疗之泉图腾", unit_info
        if has_lowest and _ready(生命释放):
            return _unit_hotkey(lowest_u, "生命释放"), f"图腾-中压AOE: 生命释放 on {lowest_u}", unit_info
        if has_lowest and healing_buff:
            tide_setup = _riptide_before_hard_cast("中压治疗链")
            if tide_setup:
                return tide_setup
            return _unit_hotkey(lowest_u, "治疗链"), f"图腾-中压AOE: 治疗链 on {lowest_u}", unit_info
        if has_lowest:
            tide_setup = _riptide_before_hard_cast("中压治疗链")
            if tide_setup:
                return tide_setup
            return _unit_hotkey(lowest_u, "治疗链"), f"图腾-中压AOE兜底: 治疗链 on {lowest_u}", unit_info

    # 单点/点名：激流前面已尽量卡 CD，这里接治疗波吃潮汐奔涌/升腾收益。
    if needs_single_heal:
        if _ready(激流) and 无激流最低 is not None and 无激流最低血量 is not None and 无激流最低血量 <= 95:
            return _unit_hotkey(无激流最低, "激流"), f"图腾-平刷铺激流: 激流 on {无激流最低}", unit_info
        if healing_buff:
            tide_setup = _riptide_before_hard_cast("平刷治疗波")
            if tide_setup:
                return tide_setup
            return _unit_hotkey(lowest_u, "治疗波"), f"图腾-平刷吃buff: 治疗波 on {lowest_u}", unit_info
        if _ready(治疗之泉) and count90 >= 2:
            return get_hotkey(0, "治疗之泉图腾"), "图腾-平刷小队: 治疗之泉图腾", unit_info
        tide_setup = _riptide_before_hard_cast("平刷治疗波")
        if tide_setup:
            return tide_setup
        return _unit_hotkey(lowest_u, "治疗波"), f"图腾-平刷: 治疗波 on {lowest_u}", unit_info

    # 稳定期：维护激流，再交给一键辅助做输出填充。
    if riptide_ready:
        return _unit_hotkey(riptide_target, "激流"), f"图腾-稳定铺激流: 激流 on {riptide_target}", unit_info
    if 战斗 and 1 <= 目标类型 <= 3 and tup:
        return get_hotkey(0, tup[1]), f"图腾-输出填充: {tup[0]}", unit_info
    return None, "图腾-无匹配技能", unit_info

def run_shaman_logic(state_dict, spec_name):
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

    if spec_name == "元素":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)

        elif 战斗 and  1 <= 目标类型 <= 3 and tup:
            current_step = f"施放 {tup[0]}"
            action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "战斗中-无匹配技能"
                
    elif spec_name == "增强":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)
        elif 战斗 and  1 <= 目标类型 <= 3 and tup:
            current_step = f"施放 {tup[0]}"
            action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "战斗中-无匹配技能"

    elif spec_name == "奶萨":
        # 奶萨光环
        飞旋之土 = state_dict.get("飞旋之土", 0)
        潮汐奔涌 = state_dict.get("潮汐奔涌", 0)
        风暴涌流 = state_dict.get("风暴涌流", 0)
        涌流层数 = state_dict.get("涌流层数", 0)
        生命释放buff = state_dict.get("生命释放", 0)
        升腾buff = state_dict.get("升腾", 0)
        
         # 奶萨技能cd
        自然迅捷 = spells.get("自然迅捷", -1)
        熔岩爆裂 = spells.get("熔岩爆裂", -1)
        爆裂充能 = spells.get("爆裂充能", -1)
        激流 = spells.get("激流", -1)
        激流充能 = spells.get("激流充能", -1)
        治疗之泉 = spells.get("治疗之泉图腾", -1)
        治泉充能 = spells.get("治疗之泉图腾充能", -1)
        烈焰震击 = spells.get("烈焰震击", -1)
        净化灵魂 = spells.get("净化灵魂", -1)
        生命释放 = spells.get("生命释放", -1)
        先祖迅捷 = spells.get("先祖迅捷", -1)
        涌动图腾 = spells.get("涌动图腾", -1)
        升腾 = spells.get("升腾", -1)

        dispel_unit_magic, _ = get_unit_with_dispel_type(state_dict, 1) # 获取可以驱散魔法类型的单位
        dispel_unit_curse, _ = get_unit_with_dispel_type(state_dict, 2) # 获取可以驱散诅咒类型的单位

        lowest_u, lowest_p = get_lowest_health_unit(state_dict, 100)

        count90 = get_count_units_below_health(state_dict, 90)   # 血量低于90%的单位数量
        count70 = get_count_units_below_health(state_dict, 70)   # 血量低于70%的单位数量
        count80 = get_count_units_below_health(state_dict, 80)   # 血量低于80%的单位数量

        治疗限值 = int(70 + (能量值 * 0.2)) # 70-90 
        群疗限值数量 = get_count_units_below_health(state_dict, 治疗限值 + 2)
        无激流最低, 无激流最低血量= get_lowest_health_unit_without_aura(state_dict, "激流", 101) # 没有激流且需要补血的最低血量单位

        驱散单位 = None
        if dispel_unit_magic is not None:
            if 队伍类型 == 46 and 首领战 not in no_dispel_bosses:
                驱散单位 = dispel_unit_magic
            elif 队伍类型 <= 40 and 首领战 in need_dispel_bosses:
                驱散单位 = dispel_unit_magic
        if 驱散单位 is None:
            驱散单位 = dispel_unit_curse

        if 引导 > 0:
            current_step = "引导,不执行任何操作"
        elif 法术失败 != 0 and  失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)
        elif 队伍类型 == 46:
            action_hotkey, current_step, unit_info = _run_totemic_party_logic(state_dict, spells, tup)
        elif 英雄天赋 == 1:
             """
                wowhead提供的大秘境奶萨逻辑，优先级如下：
                1. Use all your  风暴涌流图腾 procs 
                2. Keep  激流 on cooldown 
                3. Use  先祖迅捷 
                4. Cast  生命释放 
                5. Maintain  治疗之雨 
                6. Keep  治疗之泉图腾 on cooldown 
                7. Cast  治疗链 or  治疗波
             """
             if 队伍类型 == 46:
                # 驱散
                if 净化灵魂 == 0 and 驱散单位 is not None:
                    current_step = f"施放 净化灵魂 on {驱散单位}"
                    action_hotkey = get_hotkey(int(驱散单位), "净化灵魂")
                elif 目标类型 == 12:
                    current_step = f"施放 净化灵魂 on 目标"
                    action_hotkey = get_hotkey(0, "净化灵魂")
                elif 涌流层数 > 0 and 治疗之泉 == 0:
                    current_step = f"施放治疗图腾"
                    action_hotkey = get_hotkey(0, "治疗之泉图腾")
                elif 激流 == 0 and 激流充能 < 1 and 无激流最低 is not None:
                    current_step = f"施放 激流 on {无激流最低}"
                    action_hotkey = get_hotkey(int(无激流最低), "激流")
                elif 先祖迅捷 == 0:
                    current_step = f"施放 先祖迅捷  "
                    action_hotkey = get_hotkey(0, "先祖迅捷")
                elif 生命释放 == 0 and lowest_u is not None and lowest_p is not None and lowest_p <= 95:
                    current_step = f"施放 生命释放 on {lowest_u}, 释放生命释放"
                    action_hotkey = get_hotkey(int(lowest_u), "生命释放")
                elif 战斗 and  1 <= 目标类型 <= 3 and tup:
                    current_step = f"施放 {tup[0]}"
                    action_hotkey = get_hotkey(0, tup[1])
                else:
                    current_step = "无匹配技能"
        elif 英雄天赋 == 3:
            if 队伍类型 == 46:
                action_hotkey, current_step, unit_info = _run_totemic_party_logic(state_dict, spells, tup)
            elif 队伍类型 <= 40:  # 团队
                if 净化灵魂 == 0 and 驱散单位 is not None:
                    current_step = f"施放 净化灵魂 on {驱散单位}"
                    action_hotkey = get_hotkey(int(驱散单位), "净化灵魂")
                elif 目标类型 == 12:
                    current_step = f"施放 净化灵魂 on 目标"
                    action_hotkey = get_hotkey(0, "净化灵魂")
                elif (生命释放buff > 0 or 自然迅捷 == 255) and 群疗限值数量 >= 3:
                    current_step = f"施放 治疗链 on {lowest_u}, 释放治疗链"
                    action_hotkey = get_hotkey(int(lowest_u), "治疗链")
                elif 涌流层数 > 0 and count80 >= 4 :
                    current_step = f"施放 风暴涌流 on {lowest_u}, 释放风暴涌流"
                    action_hotkey = get_hotkey(0, "治疗之泉图腾")
                elif 生命释放 == 0 and 群疗限值数量 >= 3:
                    current_step = f"施放 生命释放 on {lowest_u}, 释放生命释放"
                    action_hotkey = get_hotkey(int(lowest_u), "生命释放")
                elif (升腾buff > 0 or 升腾 >= 162) and count90 >= 3 :
                    current_step = f"施放 治疗链 on {lowest_u}, 释放治疗链"
                    action_hotkey = get_hotkey(int(lowest_u), "治疗链")
                elif count80 >= 4  and 自然迅捷 == 0 and 生命释放buff == 0:
                    current_step = f"施放 自然迅捷 on {lowest_u}, 释放自然迅捷"
                    action_hotkey = get_hotkey(0, "自然迅捷")
                elif count90 >= 3 and 治疗之泉 == 0 and 涌流层数 == 0 :
                    current_step = f"施放 治疗之泉 on {lowest_u}, 释放治疗之泉"
                    action_hotkey = get_hotkey(0, "治疗之泉图腾")
                elif 激流 == 0 and 无激流最低 is not None and 无激流最低血量 is not None:
                    current_step = f"施放 激流 on {无激流最低}, 释放激流"
                    action_hotkey = get_hotkey(int(无激流最低), "激流")
                elif 群疗限值数量 >= 3 :
                    current_step = f"施放 治疗链 on {lowest_u}, 释放治疗链"
                    action_hotkey = get_hotkey(int(lowest_u), "治疗链")
                elif lowest_u is not None and lowest_p is not None and lowest_p  < 治疗限值 - 15 and 群疗限值数量 <= 2:
                    current_step = f"施放 治疗波 on {lowest_u}, 释放治疗波"
                    action_hotkey = get_hotkey(int(lowest_u), "治疗波")
                else:
                    current_step = "无匹配技能"
                
    return action_hotkey, current_step, unit_info
