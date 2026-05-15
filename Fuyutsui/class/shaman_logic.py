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
no_dispel_bosses = {64, 58}

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
    45: "治疗之雨",
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
    45: ("治疗之雨", "治疗之雨"),
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
        涌流图腾时间 = state_dict.get("涌流图腾时间", 0)
        倾盆大雨 = state_dict.get("倾盆大雨", 0)
        倾盆大雨层数 = state_dict.get("倾盆大雨层数", 0)
        # 奶萨充能技能层数
        激流层数 = state_dict.get("激流层数", 0)
        治泉层数 = state_dict.get("治疗之泉图腾层数", 0)
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
        灵魂链接 = spells.get("灵魂链接图腾", -1)
        升腾 = spells.get("升腾", -1)
        治疗之潮图腾 = spells.get("治疗之潮图腾", -1)

        需要驱散魔法单位, _ = get_unit_with_dispel_type(state_dict, 1) # 获取可以驱散魔法类型的单位
        需要驱散诅咒单位, _ = get_unit_with_dispel_type(state_dict, 2) # 获取可以驱散诅咒类型的单位
        
        无盾坦克,_ = get_unit_with_role_and_without_aura_name(state_dict, 1, "大地之盾" , reverse=False) # 没有大地之盾的坦克单位
        无盾治疗,_ = get_unit_with_role_and_without_aura_name(state_dict, 2, "大地之盾") # 没有大地之盾的治疗单位
        最低单位, 最低生命值 = get_lowest_health_unit(state_dict, 100)

        count90 = get_count_units_below_health(state_dict, 90)   # 血量低于90%的单位数量
        count70 = get_count_units_below_health(state_dict, 70)   # 血量低于70%的单位数量
        count80 = get_count_units_below_health(state_dict, 80)   # 血量低于80%的单位数量

        治疗限值 = int(70 + (能量值 * 0.2)) # 70-90 
        群疗限值数量 = get_count_units_below_health(state_dict, 治疗限值 + 2)
        无激流最低, 无激流最低血量= get_lowest_health_unit_without_aura(state_dict, "激流", 101) # 没有激流且需要补血的最低血量单位

        驱散单位 = None
        if 需要驱散魔法单位 is not None:
            if 队伍类型 == 46 and 首领战 not in no_dispel_bosses:
                驱散单位 = 需要驱散魔法单位
            elif 队伍类型 <= 40 and 首领战 in need_dispel_bosses:
                驱散单位 = 需要驱散魔法单位
        if 需要驱散诅咒单位 is not None:
            if 队伍类型 == 46 and 首领战 not in no_dispel_bosses:
                驱散单位 = 需要驱散诅咒单位
            elif 队伍类型 <= 40 and 首领战 in need_dispel_bosses:
                驱散单位 = 需要驱散诅咒单位

        激流单位 = None
        if 无激流最低 is not None and 无激流最低血量 is not None:
            if (激流层数 == 1 and 无激流最低血量 <= 90) or 激流层数 == 2:
                激流单位 = 无激流最低
        
        插治疗之泉 = False
        if 战斗 and (0 < 风暴涌流 < 10 or 涌流层数 == 2):
            插治疗之泉 = True
        
        if 风暴涌流 == 0:
            if 治泉层数 == 2 and 0 <= 治泉充能 <= 6 and count90 >= 2:
                插治疗之泉 = True
            elif 治泉层数 == 1 and 治泉充能 > 6 and count80 >= 3:
                插治疗之泉 = True
        elif 风暴涌流 > 0:
            if count90 >= 2 and 涌流图腾时间 == 0:
                插治疗之泉 = True
            elif count80 >= 3:
                插治疗之泉 = True
            elif 战斗 and 风暴涌流 < 10:
                插治疗之泉 = True

        unit_info = { 
            "需要驱散魔法单位": 需要驱散魔法单位,
            "需要驱散诅咒单位": 需要驱散诅咒单位,
            "无激流最低血量": 无激流最低血量,
        }

        if 引导 > 0:
            current_step = "引导,不执行任何操作"
        elif 法术失败 != 0 and 失败法术 is not None:
            current_step = f"施放 {失败法术}"
            action_hotkey = get_hotkey(0, 失败法术)
        elif 法术失败 == 46 and 倾盆大雨层数 >= 1:
            current_step = f"施放 治疗之雨"
            action_hotkey = get_hotkey(0, "治疗之雨")
        elif 一键辅助 in [1, 2, 3, 4] and tup: # 唤潮者的护卫, 大地生命武器, 天怒, 水之护盾
            current_step = f"施放 {tup[0]}"
            action_hotkey = get_hotkey(0, tup[1])
        elif 英雄天赋 == 1:
             """
                wowhead提供的大秘境奶萨逻辑，优先级如下：
                1. Use all your 风暴涌流图腾 procs 
                2. Keep 激流 on cooldown 
                3. Use 先祖迅捷 
                4. Cast 生命释放 
                5. Maintain 治疗之雨 
                6. Keep 治疗之泉图腾 on cooldown 
                7. Cast 治疗链 or 治疗波
             """
             if 队伍类型 == 46:
                # 驱散
                if 目标类型 == 12:
                    current_step = f"施放 净化灵魂 on 目标"
                    action_hotkey = get_hotkey(0, "净化灵魂")
                elif 净化灵魂 == 0 and 驱散单位 is not None:
                    current_step = f"施放 净化灵魂 on {驱散单位}"
                    action_hotkey = get_hotkey(int(驱散单位), "净化灵魂")
                elif 插治疗之泉:
                    current_step = f"施放 治疗之泉图腾"
                    action_hotkey = get_hotkey(0, "治疗之泉图腾")    
                elif 激流单位 is not None:
                    current_step = f"施放 激流 on {激流单位}"
                    action_hotkey = get_hotkey(int(激流单位), "激流")
                elif 最低单位 is not None and 最低生命值 is not None and 最低生命值 <= 85:
                    if 先祖迅捷 == 0:
                        current_step = f"施放 先祖迅捷  "
                        action_hotkey = get_hotkey(0, "先祖迅捷")
                    elif 生命释放 == 0:
                        current_step = f"施放 生命释放 on {最低单位}, 释放生命释放"
                        action_hotkey = get_hotkey(int(最低单位), "生命释放")
                    elif count90 >= 3:
                        current_step = f"施放 治疗链 on {最低单位}, 释放治疗链"
                        action_hotkey = get_hotkey(int(最低单位), "治疗链")
                    else:
                        current_step = f"施放 治疗波 on {最低单位}, 释放治疗波"
                        action_hotkey = get_hotkey(int(最低单位), "治疗波")
                #大地之盾 
                elif 无盾坦克 is not None:
                    current_step = f"施放 大地之盾 on {无盾坦克}, 无盾坦克单位"
                    action_hotkey = get_hotkey(int(无盾坦克), "大地之盾")
                elif 无盾治疗 is not None:
                    current_step = f"施放 大地之盾 on {无盾治疗}, 无盾治疗单位"
                    action_hotkey = get_hotkey(int(无盾治疗), "大地之盾")
                elif 战斗 and  1 <= 目标类型 <= 3 and tup:
                    current_step = f"施放 {tup[0]}"
                    action_hotkey = get_hotkey(0, tup[1])
                else:
                    current_step = "无匹配技能"
        elif 英雄天赋 == 3:
            if 队伍类型 == 46:
                # 驱散
                if 目标类型 == 12:
                    current_step = f"施放 净化灵魂 on 目标"
                    action_hotkey = get_hotkey(0, "净化灵魂")
                elif 净化灵魂 == 0 and 驱散单位 is not None:
                    current_step = f"施放 净化灵魂 on {驱散单位}"
                    action_hotkey = get_hotkey(int(驱散单位), "净化灵魂")
                elif 插治疗之泉:
                    current_step = f"施放 治疗之泉图腾"
                    action_hotkey = get_hotkey(0, "治疗之泉图腾")    
                elif 激流单位 is not None:
                    current_step = f"施放 激流 on {激流单位}"
                    action_hotkey = get_hotkey(int(激流单位), "激流")
                elif 最低单位 is not None and 最低生命值 is not None and 最低生命值 <= 85:
                    if count70 >=3 and (生命释放buff > 0 or 自然迅捷 == 254):
                        current_step = f"施放 治疗链 on {最低单位}, 释放治疗链"
                        action_hotkey = get_hotkey(int(最低单位), "治疗链")
                    elif 生命释放 == 0:
                        current_step = f"施放 生命释放 on {最低单位}, 释放生命释放"
                        action_hotkey = get_hotkey(int(最低单位), "生命释放")
                    elif 最低生命值 <= 60:
                        if 自然迅捷 == 0:
                            current_step = f"施放 自然迅捷 on {最低单位}, 释放自然迅捷"
                            action_hotkey = get_hotkey(0, "自然迅捷")
                        elif 自然迅捷 == 254:
                            current_step = f"施放 治疗波 on {最低单位}, 释放治疗波"
                            action_hotkey = get_hotkey(int(最低单位), "治疗波")
                        else :
                            current_step = f"施放 治疗波 on {最低单位}, 释放治疗波"
                            action_hotkey = get_hotkey(int(最低单位), "治疗波")
                    elif count90 >= 3:
                        current_step = f"施放 治疗链 on {最低单位}, 释放治疗链"
                        action_hotkey = get_hotkey(int(最低单位), "治疗链")
                    else:
                        current_step = f"施放 治疗波 on {最低单位}, 释放治疗波"
                        action_hotkey = get_hotkey(int(最低单位), "治疗波")
                elif 无盾坦克 is not None:
                    current_step = f"施放 大地之盾 on {无盾坦克}, 无盾坦克单位"
                    action_hotkey = get_hotkey(int(无盾坦克), "大地之盾")
                elif 无盾治疗 is not None:
                    current_step = f"施放 大地之盾 on {无盾治疗}, 无盾治疗单位"
                    action_hotkey = get_hotkey(int(无盾治疗), "大地之盾")
                elif 战斗 and  1 <= 目标类型 <= 3 and tup:
                    current_step = f"施放 {tup[0]}"
                    action_hotkey = get_hotkey(0, tup[1])
                else:
                    current_step = "无匹配技能"
            elif 队伍类型 <= 40:  # 团队
                # 驱散
                if 目标类型 == 12:
                    current_step = f"施放 净化灵魂 on 目标"
                    action_hotkey = get_hotkey(0, "净化灵魂")
                elif 净化灵魂 == 0 and 驱散单位 is not None:
                    current_step = f"施放 净化灵魂 on {驱散单位}"
                    action_hotkey = get_hotkey(int(驱散单位), "净化灵魂")
                elif 风暴涌流 > 0:
                    current_step = f"施放 治疗之泉图腾"
                    action_hotkey = get_hotkey(0, "治疗之泉图腾")
                elif 治泉层数 == 2 and 0 <= 治泉充能 <= 6 and count90 >= 2:
                    current_step = f"施放 治疗之泉图腾"
                    action_hotkey = get_hotkey(0, "治疗之泉图腾")
                elif 治泉层数 == 1 and 治泉充能 > 6 and count80 >= 5:
                    current_step = f"施放 治疗之泉图腾"
                    action_hotkey = get_hotkey(0, "治疗之泉图腾")
                elif 激流单位 is not None:
                    current_step = f"施放 激流 on {激流单位}"
                    action_hotkey = get_hotkey(int(激流单位), "激流")
                elif 生命释放 == 0 and 群疗限值数量 >= 3:
                    current_step = f"施放 生命释放 on {最低单位}, 释放生命释放"
                    action_hotkey = get_hotkey(int(最低单位), "生命释放")
                elif (升腾buff > 0 or 升腾 >= 162) and count90 >= 3 :
                    current_step = f"施放 治疗链 on {最低单位}, 释放治疗链"
                    action_hotkey = get_hotkey(int(最低单位), "治疗链")
                elif 最低单位 is not None and 最低生命值 is not None and 最低生命值 <= 治疗限值:
                    if count80 >= 4  and 自然迅捷 == 0 and 生命释放buff == 0:
                        current_step = f"施放 自然迅捷 on {最低单位}, 释放自然迅捷"
                        action_hotkey = get_hotkey(0, "自然迅捷")
                    elif 群疗限值数量 >= 3:
                        current_step = f"施放 治疗链 on {最低单位}, 释放治疗链"
                        action_hotkey = get_hotkey(int(最低单位), "治疗链")
                    elif 群疗限值数量 <= 2:
                        current_step = f"施放 治疗波 on {最低单位}, 释放治疗波"
                        action_hotkey = get_hotkey(int(最低单位), "治疗波")
                    else:
                        current_step = "治疗中-无匹配技能"
                else:
                    current_step = "无匹配技能"
                
    return action_hotkey, current_step, unit_info
