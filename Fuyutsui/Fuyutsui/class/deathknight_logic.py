# -*- coding: utf-8 -*-
"""死亡骑士职业的逻辑决策（鲜血 / 邪恶）。"""

from utils import *

action_map = {
    5: ("心脏打击", "心脏打击"),
    6: ("枯萎凋零", "枯萎凋零"),
    7: ("死神的抚摸", "死神的抚摸"),
    8: ("灵界打击", "灵界打击"),
    9: ("符文刃舞", "符文刃舞"),
    10: ("精髓分裂", "精髓分裂"),
    11: ("血液沸腾", "血液沸腾"),
    12: ("吸血鬼打击", "心脏打击"),
    13: ("亡者复生", "亡者复生"),
    4: ("亡者大军", "亡者大军"),
    14: ("凋零缠绕", "凋零缠绕"),
    15: ("天灾打击", "天灾打击"),
    16: ("扩散", "扩散"),
    17: ("爆发", "爆发"),
    18: ("脓疮打击", "脓疮打击"),
    19: ("腐化", "腐化"),
    20: ("黑暗突变", "黑暗突变"),
    21: ("灵魂收割", "灵魂收割"),
    22: ("脓疮毒镰", "脓疮打击"),
    25: ("死神印记", "死神印记"),
    26: ("冰川突进", "冰川突进"),
    27: ("冰霜巨龙之怒", "冰霜巨龙之怒"),
    28: ("冷酷严冬", "冷酷严冬"),
    29: ("冰霜之柱", "冰霜之柱"),
    30: ("冰霜打击", "冰霜打击"),
    31: ("凛风冲击", "凛风冲击"),
    32: ("冰霜之镰", "冰霜之镰"),
    33: ("冰龙吐息", "冰龙吐息"),
    34: ("湮灭", "湮灭"),
    35: ("符文武器增效", "符文武器增效"),
    36: ("符文打击", "符文打击"),
    37: ("冰霜巨龙之怒", "冰霜巨龙之怒"),
    38: ("冰霜灾祸", "冰霜打击"),
}

failed_spell_map = {
    1: "反魔法领域",
    2: "窒息",
    3: "致盲冰雨",
    4: "亡者大军",
    23: "血魔之握",
    24: "憎恶附肢",
}

# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None

def run_deathknight_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}
    战斗 = state_dict.get("战斗")
    移动 = state_dict.get("移动")
    施法 = state_dict.get("施法")
    引导 = state_dict.get("引导")
    生命值 = state_dict.get("生命值")
    能量值 = state_dict.get("能量值")
    一键辅助 = state_dict.get("一键辅助")
    法术失败 = state_dict.get("法术失败", 0)
    目标类型 = int(state_dict.get("目标类型", 0) or 0)
    队伍类型 = int(state_dict.get("队伍类型", 0) or 0)
    队伍人数 = int(state_dict.get("队伍人数", 0) or 0)
    首领战 = int(state_dict.get("首领战", 0) or 0)
    难度 = int(state_dict.get("难度", 0) or 0)
    英雄天赋 = int(state_dict.get("英雄天赋", 0) or 0)

    符文 = state_dict.get("符文", 0)
    目标生命值 = state_dict.get("目标生命值", 0)
    敌人人数 = state_dict.get("敌人人数", 0)

    失败法术 = _get_failed_spell(state_dict)

    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}
    
    if 法术失败 != 0 and 失败法术 is not None:
        current_step = f"施放 {失败法术}"
        action_hotkey = get_hotkey(0, 失败法术)
    elif spec_name == "鲜血":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 战斗 and 1 <= 目标类型 <= 3:
            tup = action_map.get(一键辅助)
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"
        else:
            current_step = "非战斗状态,不执行任何操作"

    elif spec_name == "冰霜":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 战斗 and 1 <= 目标类型 <= 3:
            
            tup = action_map.get(一键辅助)
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"
        else:
            current_step = "非战斗状态,不执行任何操作"

    elif spec_name == "邪恶":
        目标生命值 = state_dict.get("目标生命值", 0)
        次级食尸鬼 = state_dict.get("次级食尸鬼", 0)
        食尸鬼层数 = state_dict.get("食尸鬼层数", 0)
        末日突降 = state_dict.get("末日突降", 0)
        末日突降层数 = state_dict.get("末日突降层数", 0)
        黑暗援助 = state_dict.get("黑暗援助", 0)
        禁断知识 = state_dict.get("禁断知识", 0)
        脓疮毒镰 = state_dict.get("脓疮毒镰", 0)

        亡者复生 = spells.get("亡者复生", -1)
        亡者大军 = spells.get("亡者大军", -1)
        腐化 = spells.get("腐化", -1)
        腐化充能 = spells.get("腐化充能", -1)
        黑暗突变 = spells.get("黑暗突变", -1)
        灵魂收割 = spells.get("灵魂收割", -1)
        tup = action_map.get(一键辅助)

        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
        elif 一键辅助 == 13:
                current_step = "施放 亡者复生"
                action_hotkey = get_hotkey(0, "亡者复生")
        elif 战斗 and 1 <= 目标类型 <= 3:
            if 亡者大军 > 0 and tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            elif 黑暗援助 > 0 and 生命值 <= 80:
                current_step = "施放 灵界打击"
                action_hotkey = get_hotkey(0, "灵界打击")
            elif 生命值 <= 30 and 能量值 >= 40:
                current_step = "施放 灵界打击"
                action_hotkey = get_hotkey(0, "灵界打击")
            elif 一键辅助 == 6:
                current_step = "施放 爆发"
                action_hotkey = get_hotkey(0, "爆发")
            elif 黑暗突变 == 0:
                current_step = "施放 黑暗突变"
                action_hotkey = get_hotkey(0, "黑暗突变")
            elif 腐化 == 0 and 腐化充能 < 2 and (灵魂收割 == 255 or 目标生命值 > 35):
                current_step = "施放 腐化"
                action_hotkey = get_hotkey(0, "腐化")
            elif 灵魂收割 == 0 and 目标生命值 < 35 :
                current_step = "施放 灵魂收割"
                action_hotkey = get_hotkey(0, "灵魂收割")
            elif 腐化 == 0 and 黑暗突变 > 15 and (灵魂收割 == 255 or 目标生命值 > 35):
                current_step = "施放 腐化充能"
                action_hotkey = get_hotkey(0, "腐化")
            elif 脓疮毒镰 > 0 and 食尸鬼层数 <= 5:
                current_step = "施放 脓疮毒镰"
                action_hotkey = get_hotkey(0, "脓疮打击")
            elif ((末日突降 == 1 and 能量值 >= 15) or 能量值 >= 80) and 敌人人数 >= 3:
                current_step = "施放 扩散"
                action_hotkey = get_hotkey(0, "扩散")
            elif ((末日突降 == 1 and 能量值 >= 15) or 能量值 >= 80) and 敌人人数 < 3:
                current_step = "施放 凋零缠绕"
                action_hotkey = get_hotkey(0, "凋零缠绕")
            elif 禁断知识 > 0 and 能量值 >= 30 and 敌人人数 < 3:
                current_step = "施放 凋零缠绕"
                action_hotkey = get_hotkey(0, "凋零缠绕")
            elif 禁断知识 > 0 and 能量值 >= 30 and 敌人人数 >= 3:
                current_step = "施放 扩散"
                action_hotkey = get_hotkey(0, "扩散")
            elif 食尸鬼层数 <= 1 and 符文 >= 2:
                current_step = "施放 脓疮打击"
                action_hotkey = get_hotkey(0, "脓疮打击")
            elif 食尸鬼层数 > 0 and 符文 > 0:
                current_step = "施放 天灾打击"
                action_hotkey = get_hotkey(0, "天灾打击")
            elif 能量值 >= 30:
                current_step = "施放 凋零缠绕"
                action_hotkey = get_hotkey(0, "凋零缠绕")
            else:
                current_step = "战斗中-无匹配技能"

    return action_hotkey, current_step, unit_info
