# -*- coding: utf-8 -*-
"""恶魔猎手职业的基础逻辑（未实现）。"""

from utils import *

action_map = {
    1: ("复仇回避", "复仇回避"),
    2: ("投掷利刃", "投掷利刃"),
    3: ("悲苦咒符", "悲苦咒符"),
    4: ("禁锢", "禁锢"),
    5: ("献祭光环", "献祭光环"),
    6: ("混乱新星", "混乱新星"),
    7: ("恶魔变形", "恶魔变形"),
    8: ("邪能之刃", "邪能之刃"),
    9: ("刃舞", "刃舞"),
    10: ("混乱打击", "混乱打击"),
    11: ("疾影", "疾影"),
    12: ("恶魔追击", "恶魔追击"),
    13: ("眼棱", "眼棱"),
    14: ("邪能冲撞", "邪能冲撞"),
    15: ("精华破碎", "精华破碎"),
    16: ("恶魔变形", "恶魔变形"),
    17: ("地狱火撞击", "地狱火撞击"),
    18: ("恶魔尖刺", "恶魔尖刺"),
    19: ("烈火烙印", "烈火烙印"),
    20: ("幽魂炸弹", "幽魂炸弹"),
    21: ("灵魂切削", "灵魂切削"),
    22: ("烈焰咒符", "烈焰咒符"),
    23: ("怨念咒符", "怨念咒符"),
    24: ("灵魂裂劈", "灵魂裂劈"),
    25: ("破裂", "破裂"),
    26: ("邪能毁灭", "邪能毁灭"),
    27: ("沉默咒符", "沉默咒符"),
    28: ("虚空新星", "虚空新星"),
    29: ("虚空变形", "虚空变形"),
    30: ("虚空之刃", "虚空之刃"),
    31: ("变换", "变换"),
    32: ("收割", "收割"),
    33: ("吞噬", "吞噬"),
    34: ("虚空射线", "虚空射线"),
    35: ("恶魔追击", "恶魔追击"),
    36: ("饥渴斩击", "饥渴斩击"),
    37: ("剔除", "收割"),
    38: ("毁灭", "混乱打击"),
    39: ("死亡横扫", "刃舞"),
    40: ("吞噬之焰", "献祭光环"),
    41: ("献祭光环", "献祭光环"),
    42: ("投掷利刃", "投掷利刃"),
    43: ("黑暗", "黑暗"),
    44: ("吞噬", "吞噬"),
    45: ("坍缩之星", "虚空变形"),
    46: ("根除", "收割"),
    47: ("灵魂献祭", "献祭光环"),
    48: ("深渊凝视", "眼棱"),
    49: ("邪能之刃", "邪能之刃"),
    50: ("毁灭", "毁灭"),
    51: ("毁灭", "毁灭"),
    52: ("混乱打击", "混乱打击"),
    53: ("混乱打击", "混乱打击"),
    54: ("恶魔变形", "恶魔变形"),
    55: ("恶魔变形", "恶魔变形"),
    56: ("吞噬之焰", "献祭光环"),
}

failed_spell_map = {
    3: "悲苦咒符",
    4: "禁锢",
    6: "混乱新星",
    16: "恶魔变形",
    26: "邪能毁灭",
    27: "沉默咒符",
    28: "虚空新星",
    29: "虚空变形",
    43: "黑暗",
    45: "虚空变形",
}

# 找到失败法术，必须是法术有冷却时间，并且冷却时间为 0
def _get_failed_spell(state_dict):
    法术失败 = state_dict.get("法术失败", 0)
    spells = state_dict.get("spells") or {}
    spell_name = failed_spell_map.get(法术失败)
    if spell_name and spells.get(spell_name, -1) == 0:
        return spell_name
    return None


def run_demonhunter_logic(state_dict, spec_name):
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

    黑暗_cd = spells.get("黑暗", -1)
    复仇回避_cd = spells.get("复仇回避", -1)
    投掷利刃_cd = spells.get("投掷利刃", -1)
    投掷利刃_charge = spells.get("投掷利刃充能", -1)
    悲苦咒符_cd = spells.get("悲苦咒符", -1)
    禁锢_cd = spells.get("禁锢", -1)
    献祭光环_cd = spells.get("献祭光环", -1)

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
    elif spec_name == "浩劫": 
        if 战斗 and 1 <= 目标类型 <= 3:
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "无匹配技能"
    elif spec_name == "复仇":
        灵魂残片 = state_dict.get("灵魂残片", 0)
        投掷利刃_层数 = state_dict.get("投掷利刃", 0)
        地狱火撞击_层数 = state_dict.get("地狱火撞击", 0)
        烈火烙印_层数 = state_dict.get("烈火烙印", 0)
        破裂_层数 = state_dict.get("破裂", 0)

        敌人人数 = state_dict.get("敌人人数", 0)
        烈火烙印 = state_dict.get("烈火烙印buff", 0)

        混乱新星_cd = spells.get("混乱新星", -1)
        恶魔变形_cd = spells.get("恶魔变形", -1)
        邪能之刃_cd = spells.get("邪能之刃", -1)
        地狱火撞击_cd = spells.get("地狱火撞击", -1)
        地狱火撞击_charge = spells.get("地狱火撞击充能", -1)
        恶魔尖刺_cd = spells.get("恶魔尖刺", -1)
        烈火烙印_cd = spells.get("烈火烙印", -1)
        烈火烙印_charge = spells.get("烈火烙印充能", -1)
        幽魂炸弹_cd = spells.get("幽魂炸弹", -1)
        灵魂切削_cd = spells.get("灵魂切削", -1)
        烈焰咒符_cd = spells.get("烈焰咒符", -1)
        怨念咒符_cd = spells.get("怨念咒符", -1)
        灵魂裂劈_cd = spells.get("灵魂裂劈", -1)
        破裂_cd = spells.get("破裂", -1)
        破裂_charge = spells.get("破裂充能", -1)
        邪能毁灭_cd = spells.get("邪能毁灭", -1)
        沉默咒符_cd = spells.get("沉默咒符", -1)
      
        if 战斗 and 1 <= 目标类型 <= 3:
            if 恶魔尖刺_cd == 0:
                current_step = "施放 恶魔尖刺"
                action_hotkey = get_hotkey(0, "恶魔尖刺")
            elif 烈火烙印 == 0 and 烈火烙印_cd == 0:
                current_step = "施放 烈火烙印"
                action_hotkey = get_hotkey(0, "烈火烙印")
            elif not 移动 and 邪能毁灭_cd == 0 and 能量值 >= 50 and( 生命值 <= 80 or 敌人人数 >= 5):
                current_step = "施放 邪能毁灭"
                action_hotkey = get_hotkey(0, "邪能毁灭")
            elif 邪能之刃_cd == 0 and 能量值 <= 20:
                current_step = "施放 邪能之刃"
                action_hotkey = get_hotkey(0, "邪能之刃")
            elif tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "无匹配技能"
    elif spec_name == "噬灭":

        if 战斗 and 1 <= 目标类型 <= 3:
            if tup:
                current_step = f"施放 {tup[0]}"
                action_hotkey = get_hotkey(0, tup[1])
        else:
            current_step = "无匹配技能"

    return action_hotkey, current_step, unit_info
