# -*- coding: utf-8 -*-
"""死亡骑士职业的逻辑决策（鲜血 / 邪恶）。"""

from utils import *


def run_deathknight_logic(state_dict, spec_name):
    spells = state_dict.get("spells") or {}
    生命值 = state_dict.get("生命值")
    能量值 = state_dict.get("能量值")
    一键辅助 = state_dict.get("一键辅助")
    目标有效 = state_dict.get("目标有效")
    战斗 = state_dict.get("战斗")
    引导 = state_dict.get("引导")
    符文 = state_dict.get("符文")

    action_hotkey = None
    current_step = "无匹配技能"
    unit_info = {}

    if spec_name == "鲜血":
        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
            return None, current_step, unit_info

        if 战斗 and 目标有效:
            action_map = {
                1: ("心脏打击", "心脏打击"),
                2: ("枯萎凋零", "枯萎凋零"),
                3: ("死神的抚摸", "死神的抚摸"),
                4: ("灵界打击", "灵界打击"),
                5: ("符文刃舞", "符文刃舞"),
                6: ("精髓分裂", "精髓分裂"),
                7: ("血液沸腾", "血液沸腾"),
                8: ("吸血鬼打击", "心脏打击"),
            }
            tup = action_map.get(一键辅助)
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
            else:
                current_step = "战斗中-无匹配技能"
        else:
            current_step = "非战斗状态,不执行任何操作"

    elif spec_name == "冰霜":
        current_step = "冰霜专精,不执行任何操作"
        return None, current_step, unit_info

    elif spec_name == "邪恶":
        敌人人数 = state_dict.get("敌人人数", 0)
        英雄天赋 = state_dict.get("英雄天赋", 0)
        脓疮毒镰 = state_dict.get("脓疮毒镰", 0)
        次级食尸鬼 = state_dict.get("次级食尸鬼", 0)
        食尸鬼层数 = state_dict.get("食尸鬼层数", 0)
        末日突降 = state_dict.get("末日突降", 0)
        末日突降层数 = state_dict.get("末日突降层数", 0)
        黑暗援助 = state_dict.get("黑暗援助", 0)
        禁断知识 = state_dict.get("禁断知识", 0)
        
        亡者复生cd = spells.get("亡者复生")
        亡者大军cd = spells.get("亡者大军")
        腐化cd = spells.get("腐化")
        腐化charge = spells.get("腐化充能")
        黑暗突变cd = spells.get("黑暗突变")
        灵魂收割cd = spells.get("灵魂收割")

        if 引导 > 0:
            current_step = "在引导,不执行任何操作"
            return None, current_step, unit_info
        if not 战斗:
            current_step = "非战斗状态,不执行任何操作"
            return None, current_step, unit_info
        if not 目标有效:
            current_step = "目标无效,不执行任何操作"
            return None, current_step, unit_info
        if 一键辅助 == 1:
            current_step = "施放 亡者复生-一键"
            action_hotkey = get_hotkey(0, "亡者复生")
        elif 黑暗援助 > 0 and 生命值 <= 80:
            current_step = "施放 灵界打击"
            action_hotkey = get_hotkey(0, "灵界打击")
        elif 生命值 <= 30 and 能量值 >= 40:
            current_step = "施放 灵界打击"
            action_hotkey = get_hotkey(0, "灵界打击")
        elif 一键辅助 == 6:
            current_step = "施放 爆发-一键"
            action_hotkey = get_hotkey(0, "爆发")
        elif 黑暗突变cd == 0:
            current_step = "施放 黑暗突变-cd好了"
            action_hotkey = get_hotkey(0, "黑暗突变")
        elif 灵魂收割cd == 0 and state_dict.get("目标生命值") < 20:
            current_step = "施放 灵魂收割"
            action_hotkey = get_hotkey(0, "灵魂收割")
        elif 一键辅助 == 16:
            current_step = "施放 腐化 一键辅助"
            action_hotkey = get_hotkey(0, "腐化")
        elif  腐化cd < 1:
            current_step = "施放 腐化-快好了"
            action_hotkey = get_hotkey(0, "腐化")
        elif 脓疮毒镰 < 1.5:
            current_step = "施放 脓疮毒镰-快没了"
            action_hotkey = get_hotkey(0, "脓疮打击")
        elif 食尸鬼层数 >= 8 and 符文 > 0:
            current_step = "施放 天灾打击-8层"
            action_hotkey = get_hotkey(0, "天灾打击")
        elif 能量值 >= 80 and 敌人人数 >= 4:
            current_step = "施放 扩散-80能量"
            action_hotkey = get_hotkey(0, "扩散")
        elif 末日突降 >= 1 and 能量值 >= 15 and 敌人人数 < 4:
            current_step = "施放 凋零缠绕-末日突降-15能量"
            action_hotkey = get_hotkey(0, "凋零缠绕")
        elif 能量值 >= 80 and 敌人人数 < 4:
            current_step = "施放 凋零缠绕-80能量"
            action_hotkey = get_hotkey(0, "凋零缠绕")
        elif 禁断知识 > 0 and 能量值 >= 30 and 敌人人数 < 4:
            current_step = "施放 凋零缠绕-爆发期"
            action_hotkey = get_hotkey(0, "凋零缠绕")
        elif 禁断知识 > 0 and 能量值 >= 30 and 敌人人数 >= 4:
            current_step = "施放 扩散-爆发期"
            action_hotkey = get_hotkey(0, "扩散")
        elif 食尸鬼层数 == 0 and 符文 >= 2:
            current_step = "施放 脓疮打击-没层数了"
            action_hotkey = get_hotkey(0, "脓疮打击")
        elif 食尸鬼层数 >= 1 and 符文 > 0:
            current_step = "施放 天灾打击-大于1层"
            action_hotkey = get_hotkey(0, "天灾打击")
        elif 能量值 >= 30:
            current_step = "施放 凋零缠绕-后备技能"
            action_hotkey = get_hotkey(0, "凋零缠绕")
        else:
            current_step = "战斗中-无匹配技能"

    return action_hotkey, current_step, unit_info

