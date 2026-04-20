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
    16: "灵魂链接图腾",
    17: "土元素",
    18: "战栗图腾",
    19: "清毒图腾",
    20: "图腾投射",
    21: "升腾",
    22: "治疗之潮图腾",
}

def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None

def run_shaman_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}


    




    战斗 = state_dict.get("战斗")
    移动 = state_dict.get("移动")
    施法 = state_dict.get("施法")
    引导 = state_dict.get("引导")
    生命值 = state_dict.get("生命值")
    能量值 = state_dict.get("能量值")
    一键辅助 = state_dict.get("一键辅助")
    法术失败 = state_dict.get("法术失败", 0)
    失败法术 = _get_failed_spell(state_dict)

    目标类型 = state_dict.get("目标类型")
    队伍类型 = int(state_dict.get("队伍类型", 0) or 0)
    首领战 = int(state_dict.get("首领战", 0) or 0)


    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}
    if spec_name == "元素":
        action_map = {
            11: ("先祖迅捷", "先祖迅捷"),
            33: ("元素冲击", "元素冲击"),
            34: ("地震术", "地震术"),
            35: ("大地震击", "大地震击"),
            3: ("天怒", "天怒"),
            24: ("流电炽焰", "流电炽焰"),
            25: ("火舌武器", "火舌武器"),
            6: ("熔岩爆裂", "熔岩爆裂"),
            37: ("闪电之盾", "闪电之盾"),
            7: ("闪电箭", "闪电箭"),
            32: ("狂风怒号", "闪电箭"),
            8: ("闪电链", "闪电链"),
            36: ("风暴守护者", "风暴守护者"),
            5: ("烈焰震击", "烈焰震击"),
        }

        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)

        elif 战斗 and  1 <= 目标类型 <= 3:
            tup = action_map.get(一键辅助)
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"
                
    elif spec_name == "增强":
        action_map = {
            3: ("天怒", "天怒"),
            23: ("毁灭闪电", "毁灭闪电"),
            24: ("流电炽焰", "流电炽焰"),
            13: ("涌动图腾", "涌动图腾"),
            25: ("火舌武器", "火舌武器"),
            26: ("熔岩猛击", "熔岩猛击"),
            27: ("裂地术", "裂地术"),
            28: ("始源风暴", "始源风暴"),
            37: ("闪电之盾", "闪电之盾"),
            7: ("闪电箭", "闪电箭"),
            32: ("狂风怒号", "闪电箭"),
            8: ("闪电链", "闪电链"),
            30: ("风怒武器", "风怒武器"),
            31: ("风暴打击", "风暴打击"),
            29: ("风切", "风切"),
        }

        if 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)

        elif 战斗 and 1 <= 目标类型 <= 3:
            tup = action_map.get(一键辅助)
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"
    elif spec_name == "奶萨":
        action_map = {
            1: ("唤潮者的护卫", "唤潮者的护卫"),
            2: ("大地生命武器", "大地生命武器"),
            3: ("天怒", "天怒"),
            4: ("水之护盾", "水之护盾"),
            5: ("烈焰震击", "烈焰震击"),
            6: ("熔岩爆裂", "熔岩爆裂"),
            7: ("闪电箭", "闪电箭"),
            8: ("闪电链", "闪电链"),
        }


        风暴涌流图腾层数 = state_dict.get("风暴涌流图腾层数", 0)
        飞旋之土 = state_dict.get("飞旋之土", 0)
        潮汐奔涌 = state_dict.get("潮汐奔涌", 0)
        生命释放buff = state_dict.get("生命释放", 0)

        激流 = spells.get("激流", -1)
        激流充能 = spells.get("激流充能", -1)
        治疗波 = spells.get("治疗波", -1)
        治疗链 =  spells.get("治疗链", -1)
        大地之盾 = spells.get("大地之盾", -1)
        治疗之泉图腾 = spells.get("治疗之泉图腾", -1)
        治疗之泉图腾充能 = spells.get("治疗之泉图腾充能", -1)
        生命释放 = spells.get("生命释放", -1)
        净化灵魂 = spells.get("净化灵魂", -1)
        自然迅捷 = spells.get("自然迅捷", -1)
        治疗之潮图腾 = spells.get("治疗之潮图腾", -1)

        dispel_unit_magic, _ = get_unit_with_dispel_type(state_dict, 1) # 获取可以驱散魔法类型的单位
        dispel_unit_curse, _ = get_unit_with_dispel_type(state_dict, 2) # 获取可以驱散诅咒类型的单位

        无盾坦克,_ = get_unit_with_role_and_without_aura_name(state_dict, 1, "大地之盾" , reverse=False) # 没有大地之盾的坦克单位
        无盾治疗,_ = get_unit_with_role_and_without_aura_name(state_dict, 2, "大地之盾") # 没有大地之盾的治疗单位
        lowest_u, lowest_p = get_lowest_health_unit(state_dict, 100)
        count92 = get_count_units_below_health(state_dict, 92)   # 血量低于92%的单位数量
        count88 = get_count_units_below_health(state_dict, 88)   # 血量低于88%的单位数量
        count70 = get_count_units_below_health(state_dict, 70)   # 血量低于70%的单位数量
        count60 = get_count_units_below_health(state_dict, 60)   # 血量低于60%的单位数量
        count80 = get_count_units_below_health(state_dict, 80)   # 血量低于80%的单位数量
        治疗限值 = int(70 + (能量值 * 0.2)) # 70-90 
        群疗限值数量 = get_count_units_below_health(state_dict, 治疗限值 + 2)
        无激流最低, 无激流最低血量= get_lowest_health_unit_without_aura(state_dict, "激流", 100) # 没有激流且需要补血的最低血量单位


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
            # 驱散
            if 净化灵魂 == 0 and 驱散单位 is not None:
                current_step = f"施放 净化灵魂 on {驱散单位}"
                action_hotkey = get_hotkey(int(驱散单位), "净化灵魂")
            elif 目标类型 == 12:
                current_step = f"施放 净化灵魂 on 目标"
                action_hotkey = get_hotkey(0, "净化灵魂")
            elif (count60 >= 2 or count70 >= 3) and (风暴涌流图腾层数 > 0 or 治疗之泉图腾 == 0):
                current_step = f"施放治疗图腾 on {lowest_u}"
                action_hotkey = get_hotkey(0, "治疗之泉图腾")
            elif count70 >=3 and (生命释放buff > 0 or 自然迅捷 == 255):
                current_step = f"施放 治疗链 on {lowest_u}, 释放治疗链"
                action_hotkey = get_hotkey(int(lowest_u), "治疗链")
            elif lowest_u is not None and lowest_p is not None and lowest_p <= 60:
                if 生命释放 == 0:
                    current_step = f"施放 生命释放 on {lowest_u}, 释放生命释放"
                    action_hotkey = get_hotkey(int(lowest_u), "生命释放")
                elif 自然迅捷 == 0:
                    current_step = f"施放 自然迅捷 on {lowest_u}, 释放自然迅捷"
                    action_hotkey = get_hotkey(0, "自然迅捷")
                elif 自然迅捷 == 255:
                    current_step = f"施放 治疗波 on {lowest_u}, 释放治疗波"
                    action_hotkey = get_hotkey(int(lowest_u), "治疗波")
                elif 风暴涌流图腾层数 > 0 and lowest_p <= 35:
                    current_step = f"施放 风暴涌流图腾 on {lowest_u}, 释放风暴涌流图腾"
                    action_hotkey = get_hotkey(int(lowest_u), "治疗之泉图腾")
                elif 治疗波 == 0:
                    current_step = f"施放 治疗波 on {lowest_u}, 释放治疗波"
                    action_hotkey = get_hotkey(int(lowest_u), "治疗波")
            elif 激流 == 0 and 无激流最低 is not None and 无激流最低血量 is not None:
                current_step = f"施放 激流 on {无激流最低}, 释放激流"
                action_hotkey = get_hotkey(int(无激流最低), "激流")
            elif count80 >= 3 and 治疗之泉图腾 == 0 and 治疗之泉图腾充能 == 0 :
                current_step = f"施放 治疗之泉图腾 on {lowest_u}, 释放治疗之泉图腾"
                action_hotkey = get_hotkey(0, "治疗之泉图腾")
            elif count80 >= 3 and 治疗链 == 0 :
                current_step = f"施放 治疗链 on {lowest_u}, 释放治疗链"
                action_hotkey = get_hotkey(int(lowest_u), "治疗链")
            elif 激流 == 0  and lowest_u is not None and lowest_p is not None and lowest_p <= 90:
                current_step = f"施放 激流 on {lowest_u}, 释放激流"
                action_hotkey = get_hotkey(int(lowest_u), "激流")
            elif lowest_u is not None and lowest_p is not None and lowest_p <= 90:
                current_step = f"施放 治疗波 on {lowest_u}, 释放治疗波"
                action_hotkey = get_hotkey(int(lowest_u), "治疗波")
            #大地之盾 
            elif 大地之盾 == 0 and 无盾坦克 is not None:
                current_step = f"施放 大地之盾 on {无盾坦克}, 无盾坦克单位"
                action_hotkey = get_hotkey(int(无盾坦克), "大地之盾")
            elif 大地之盾 == 0 and 无盾治疗 is not None:
                current_step = f"施放 大地之盾 on {无盾治疗}, 无盾治疗单位"
                action_hotkey = get_hotkey(int(无盾治疗), "大地之盾")
        elif 队伍类型 <= 40:
            # 驱散
            if 净化灵魂 == 0 and 驱散单位 is not None:
                current_step = f"施放 净化灵魂 on {驱散单位}"
                action_hotkey = get_hotkey(int(驱散单位), "净化灵魂")
            elif 目标类型 == 12:
                current_step = f"施放 净化灵魂 on 目标"
                action_hotkey = get_hotkey(0, "净化灵魂")
            elif 生命释放buff > 0 and 群疗限值数量 >= 3:
                current_step = f"施放 治疗链 on {lowest_u}, 释放治疗链"
                action_hotkey = get_hotkey(int(lowest_u), "治疗链")
            elif 自然迅捷 == 255 and 群疗限值数量 >= 3:
                current_step = f"施放 治疗链 on {lowest_u}, 释放治疗链"
                action_hotkey = get_hotkey(int(lowest_u), "治疗链")
            #没有激流的最低生命值玩家存在 释放激流给没有激流的最低生命值玩家
            elif 激流 == 0 and 无激流最低 is not None and 无激流最低血量 is not None:
                current_step = f"施放 激流 on {无激流最低}, 释放激流"
                action_hotkey = get_hotkey(int(无激流最低), "激流")
            #4人生命值小于80 且风暴涌流图腾cd == 0 释放风暴涌流图腾
            elif count80 >= 3 and 风暴涌流图腾层数 > 0 :
                current_step = f"施放 风暴涌流图腾 on {lowest_u}, 释放风暴涌流图腾"
                action_hotkey = get_hotkey(0, "治疗之泉图腾")
            #生命释放卡cd释放
            elif 生命释放 == 0 and lowest_u is not None and lowest_p is not None and lowest_p < 90:
                current_step = f"施放 生命释放 on {lowest_u}, 释放生命释放"
                action_hotkey = get_hotkey(int(lowest_u), "生命释放")
            # 3人生命值小于88
            elif count88 >= 3 and 治疗之泉图腾 == 0 :
                current_step = f"施放 治疗之泉图腾 on {lowest_u}, 释放治疗之泉图腾"
                action_hotkey = get_hotkey(0, "治疗之泉图腾")
            #有迅捷且3人生命低于80 huo 释放迅捷
            elif count80 >= 3  and 自然迅捷 == 0 :
                current_step = f"施放 自然迅捷 on {lowest_u}, 释放自然迅捷"
                action_hotkey = get_hotkey(0, "自然迅捷")
            # 群疗限值数量 >= 4 释放治疗链
            elif 群疗限值数量 >= 4 and 治疗链 == 0 :
                current_step = f"施放 治疗链 on {lowest_u}, 释放治疗链"
                action_hotkey = get_hotkey(int(lowest_u), "治疗链")
            # 群疗限值数量 <= 2 and 单人生命小于治疗限值   释放治疗波
            elif lowest_u is not None and lowest_p is not None and lowest_p  < 治疗限值 - 15 and 群疗限值数量 <= 2:
                current_step = f"施放 治疗波 on {lowest_u}, 释放治疗波"
                action_hotkey = get_hotkey(int(lowest_u), "治疗波")
      
        if  法术失败 == 0 and action_hotkey is None and 战斗 and 1 <= 目标类型 <= 3:
            tup = action_map.get(一键辅助)
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"

    return action_hotkey, current_step, unit_info
