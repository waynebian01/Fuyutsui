import os   # 用于配置路径
import yaml # 加载 config.yml / keymap.yml
import ctypes

# 配置路径（与 main.py 同目录）
_BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(_BASE_DIR, "config.yml")
KEYMAP_PATH = os.path.join(_BASE_DIR, "keymap.yml")

_keymap_cache = None
_unit_spell_to_hotkey_cache = None
_current_keymap_class = None


def select_keymap_for_class(class_id):
    """
    根据 config.yml 中职业配置的 keymap 字段切换使用的 keymap 文件。
    - class_id: 职业 id，如 5、11；若为空则回退到默认 keymap.yml。
    调用后会清空 keymap 缓存和热键缓存，后续 load_keymap/get_hotkey 会使用新的 keymap。
    """
    global KEYMAP_PATH, _keymap_cache, _unit_spell_to_hotkey_cache, _current_keymap_class

    if class_id == _current_keymap_class and _keymap_cache is not None:
        return

    keymap_path = os.path.join(_BASE_DIR, "keymap.yml")
    if class_id is not None:
        config = load_config()
        class_dict = config.get(class_id) or config.get(str(class_id))
        if isinstance(class_dict, dict):
            km = class_dict.get("keymap")
            if isinstance(km, str) and km:
                keymap_path = os.path.join(_BASE_DIR, "keymap", km) if not os.path.isabs(km) else km

    KEYMAP_PATH = keymap_path
    _current_keymap_class = class_id
    _keymap_cache = None
    _unit_spell_to_hotkey_cache = None



def load_keymap():
    """加载当前选择的 keymap 文件（可由 select_keymap_for_class 动态切换）。"""
    global _keymap_cache
    if _keymap_cache is None:
        with open(KEYMAP_PATH, "r", encoding="utf-8") as f:
            _keymap_cache = yaml.safe_load(f)
    return _keymap_cache

def get_hotkey(unit, spell):
    """
    根据 unit 和 spell 返回热键。
    若 unit 为空（None 或 ""），则按 unit=0 查找。
    返回热键字符串，未找到则返回 None。
    """
    global _unit_spell_to_hotkey_cache
    if _unit_spell_to_hotkey_cache is None:
        keymap = load_keymap()
        _unit_spell_to_hotkey_cache = {}
        for id_val, entry in (keymap or {}).items():
            if not isinstance(entry, dict):
                continue
            u = entry.get("unit")
            # 兼容旧字段 spell/hotkey 以及中文字段 技能/热键
            s = entry.get("spell") or entry.get("技能")
            h = entry.get("hotkey") or entry.get("热键")
            if s is not None and h is not None:
                u = int(u) if u is not None else 0
                _unit_spell_to_hotkey_cache[(u, s)] = h
    u = 0 if unit in (None, "") else (int(unit) if isinstance(unit, str) else unit)
    return _unit_spell_to_hotkey_cache.get((u, spell))

def load_config():
    """加载 config.yml"""
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


# 职业 ID -> 名称；专精 (class_id, spec_id) -> 名称
_CLASS_NAMES = { 1: "战士", 2: "圣骑士", 3: "猎人", 4: "盗贼", 5: "牧师", 6: "死亡骑士",
                7: "萨满", 8: "法师", 9: "术士", 10: "武僧", 11: "德鲁伊", 12: "恶魔猎手", 13: "唤魔师"}
_SPEC_NAMES = {
    (1, 1): "武器", (1, 2): "狂怒", (1, 3): "防护",
    (2, 1): "神圣", (2, 2): "防护", (2, 3): "惩戒",
    (3, 1): "兽王", (3, 2): "射击", (3, 3): "生存",
    (4, 1): "刺杀", (4, 2): "狂徒", (4, 3): "敏锐",
    (5, 1): "戒律", (5, 2): "神牧", (5, 3): "暗影",
    (6, 1): "鲜血", (6, 2): "冰霜", (6, 3): "邪恶",
    (7, 1): "元素", (7, 2): "增强", (7, 3): "奶萨",
    (8, 1): "奥术", (8, 2): "火焰", (8, 3): "冰霜",
    (9, 1): "痛苦", (9, 2): "恶魔", (9, 3): "毁灭",
    (10, 1): "酒仙", (10, 2): "织雾", (10, 3): "踏风",
    (11, 1): "平衡", (11, 2): "野性", (11, 3): "守护", (11, 4): "奶德",
    (12, 1): "浩劫", (12, 2): "复仇", (12, 3): "噬灭",
    (13, 1): "湮灭", (13, 2): "恩护", (13, 3): "增辉",
}

def get_class_and_spec_name(config, class_id, spec_id):
    """
    根据 class_id、spec_id 返回 (class_name, spec_name)。
    若 config 中有 names 配置则优先使用，否则使用内置映射。
    """
    class_name = _CLASS_NAMES.get(class_id, f"职业{class_id}" if class_id else None)
    spec_name = _SPEC_NAMES.get((class_id, spec_id))
    if spec_name is None and class_id is not None and spec_id is not None:
        class_dict = config.get(class_id) or config.get(str(class_id))
        if isinstance(class_dict, dict) and spec_id in class_dict:
            spec_name = f"专精{spec_id}"
        else:
            spec_name = f"专精{spec_id}" if spec_id else None
    return (class_name, spec_name)


def _role_not_zero(data):
    """检查单位职责是否不等于 0，职责为 0 则返回 False（应跳过）。"""
    role = data.get("职责")
    if role is None:
        return True
    try:
        return int(role) != 0
    except (TypeError, ValueError):
        return True


def get_lowest_health_unit(state_dict, health_threshold=100):
    """
    在 group 中生命值最低的单位, 生命值 0 视为死亡不选, health_threshold 以上的视为不选。
    仅考虑职责不等于 0 的单位。
    返回 (lowest_unit, lowest_pct) 或 (None, None), lowest_unit 为 "1"~"30"。
    """
    group = state_dict.get("group") or {}
    lowest_unit, lowest_pct = None, health_threshold
    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue
        pct = data.get("生命值")
        if pct is None:
            continue
        try:
            pct = int(pct)
        except (TypeError, ValueError):
            continue
        if 0 < pct < health_threshold and pct < lowest_pct:
            lowest_unit, lowest_pct = key, pct
    slot = str(lowest_unit) if lowest_unit is not None else None
    return (slot, lowest_pct) if lowest_unit is not None else (None, None)

def get_count_units_below_health(state_dict, health_threshold=100):
    """
    在 group 中生命值低于 health_threshold 的单位数量。
    仅考虑职责不等于 0 的单位。
    返回一个整数 count。
    """
    group = state_dict.get("group") or {}
    count = 0
    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue
        pct = data.get("生命值")
        if pct is None:
            continue
        try:
            pct = int(pct)
        except (TypeError, ValueError):
            continue
        if 0 < pct < health_threshold:
            count += 1
    return count


def get_unit_with_role(state_dict, role, reverse=False):
    """
    获取职责等于 role 的单位。根据 reverse 返回正序第一个或逆序第一个。

    参数:
        state_dict: 状态字典
        role: 职责值（如 1=坦克, 2=治疗, 3=输出）
        reverse: False=返回第一个匹配单位, True=返回逆序最后一个匹配单位

    返回 单位 key（如 "1"）或 None
    """
    group = state_dict.get("group") or {}
    try:
        target_role = int(role)
    except (TypeError, ValueError):
        return None
    matches = []
    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        r = data.get("职责")
        if r is None:
            continue
        try:
            if int(r) == target_role:
                matches.append(str(key))
        except (TypeError, ValueError):
            continue
    if not matches:
        return None
    return matches[-1] if reverse else matches[0]


def get_unit_with_role_and_without_aura_name(state_dict, role, aura_name, reverse=False):
    """
    获取职责等于 role 且没有指定光环的单位。根据 reverse 返回正序第一个或逆序第一个。

    参数:
        state_dict: 状态字典
        role: 职责值（如 1=坦克, 2=治疗, 3=输出）
        aura_name: 光环名称，如 "回春术"、"愈合"、"救赎"
        reverse: False=返回第一个匹配单位, True=返回逆序最后一个匹配单位

    返回 (unit, health_pct)，unit 为单位 key（如 "1"），无匹配时返回 (None, None)
    """
    group = state_dict.get("group") or {}
    try:
        target_role = int(role)
    except (TypeError, ValueError):
        return (None, None)

    matches = []
    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        r = data.get("职责")
        if r is None:
            continue
        try:
            if int(r) != target_role:
                continue
        except (TypeError, ValueError):
            continue
        if _has_aura(data, aura_name):
            continue
        pct = data.get("生命值")
        try:
            pct = int(pct) if pct is not None else None
        except (TypeError, ValueError):
            pct = None
        matches.append((str(key), pct))

    if not matches:
        return (None, None)

    unit, pct = matches[-1] if reverse else matches[0]
    return unit, pct


def _has_aura(data, aura_name):
    """检查单位是否有指定光环。直接从 data 中取 aura_name。"""
    val = data.get(aura_name)
    if val is None:
        return False
    try:
        return int(val) != 0
    except (TypeError, ValueError):
        return False


def _has_any_aura(data, aura_names):
    """检查单位是否拥有 aura_names 中任意一个光环。"""
    for name in aura_names:
        if _has_aura(data, name):
            return True
    return False


def get_lowest_health_unit_with_any_aura(state_dict, *aura_names, health_threshold=100):
    """
    获取拥有 aura_names 中任意一个光环、且生命值低于 health_threshold 的单位中，生命值最低者。
    生命值 0 视为死亡不选。仅考虑职责不等于 0 的单位。

    参数:
        state_dict: 状态字典
        *aura_names: 光环名称，如 "回春术"、"愈合"、"生命绽放"
        health_threshold: 只考虑生命值低于此阈值的单位（默认 100）

    返回 (lowest_unit, lowest_pct) 或 (None, None), lowest_unit 为 "1"~"30"。

    使用示范:
        # 奶德：找有回春/愈合/生命绽放且血最低的单位（可施放迅捷治愈消耗 HoT 治疗）
        unit, pct = get_lowest_health_unit_with_any_aura(
            state_dict, "回春术", "愈合", "生命绽放", health_threshold=90
        )
        if unit and spells.get("迅捷治愈") == 0:
            action_hotkey = get_hotkey(int(unit), "迅捷治愈")
    """
    if not aura_names:
        return (None, None)
    group = state_dict.get("group") or {}
    lowest_unit, lowest_pct = None, health_threshold
    try:
        threshold = int(health_threshold)
    except (TypeError, ValueError):
        return (None, None)
    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue
        if not _has_any_aura(data, aura_names):
            continue
        pct = data.get("生命值")
        if pct is None:
            continue
        try:
            pct = int(pct)
        except (TypeError, ValueError):
            continue
        if 0 < pct < threshold and pct < lowest_pct:
            lowest_unit, lowest_pct = key, pct
    slot = str(lowest_unit) if lowest_unit is not None else None
    return (slot, lowest_pct) if lowest_unit is not None else (None, None)


def get_lowest_health_unit_without_aura(state_dict, aura_name, health_threshold=100):
    """
    获取没有指定光环名称、且生命值最低的单位。生命值 0 视为死亡不选。
    仅考虑职责不等于 0 的单位。
    aura_name 为 group 中的键名（如 "救赎"、"真言术：盾"），或对应 aura[spellId]。
    health_threshold: 只考虑生命值低于此阈值的单位（默认 100，即排除满血）。
    返回 (lowest_unit, lowest_pct) 或 (None, None), lowest_unit 为 "1"~"30"。
    """
    group = state_dict.get("group") or {}
    lowest_unit, lowest_pct = None, health_threshold
    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue
        if _has_aura(data, aura_name):
            continue
        pct = data.get("生命值")
        if pct is None:
            continue
        try:
            pct = int(pct)
        except (TypeError, ValueError):
            continue
        if 0 < pct < health_threshold and pct < lowest_pct:
            lowest_unit, lowest_pct = key, pct
    slot = str(lowest_unit) if lowest_unit is not None else None
    return (slot, lowest_pct) if lowest_unit is not None else (None, None)

def get_lowest_health_unit_with_aura(state_dict, aura_name, health_threshold=100):
    """
    获取拥有指定光环名称、且生命值最低的单位。生命值 0 视为死亡不选。
    仅考虑职责不等于 0 的单位。
    aura_name 为 group 中的键名（如 "救赎"、"真言术：盾"），或对应 aura[spellId]。
    health_threshold: 只考虑生命值低于此阈值的单位（默认 100，即排除满血）。
    返回 (lowest_unit, lowest_pct) 或 (None, None), lowest_unit 为 "1"~"30"。
    """
    group = state_dict.get("group") or {}
    lowest_unit, lowest_pct = None, health_threshold
    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue
        if not _has_aura(data, aura_name):
            continue
        pct = data.get("生命值")
        if pct is None:
            continue
        try:
            pct = int(pct)
        except (TypeError, ValueError):
            continue
        if 0 < pct < health_threshold and pct < lowest_pct:
            lowest_unit, lowest_pct = key, pct
    slot = str(lowest_unit) if lowest_unit is not None else None
    return (slot, lowest_pct) if lowest_unit is not None else (None, None)


def get_lowest_health_unit_with_aura_count(state_dict, aura_name, aura_count, health_threshold=100):
    """
    获取 aura_name 等于 aura_count，且生命值最低的单位。
    生命值 0 视为死亡不选。仅考虑职责不等于 0 的单位。

    参数:
        state_dict: 状态字典
        aura_name: group 中的键名（如 "腐化2"、"救赎"）
        aura_count: 目标光环层数/数量，只选该值完全相等的单位
        health_threshold: 只考虑生命值低于此阈值的单位（默认 100）

    返回 (lowest_unit, lowest_pct) 或 (None, None)
    """
    group = state_dict.get("group") or {}
    lowest_unit, lowest_pct = None, health_threshold
    try:
        target_count = int(aura_count)
        threshold = int(health_threshold)
    except (TypeError, ValueError):
        return (None, None)
    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue
        val = data.get(aura_name)
        if val is None:
            continue
        try:
            if int(val) != target_count:
                continue
        except (TypeError, ValueError):
            continue
        pct = data.get("生命值")
        if pct is None:
            continue
        try:
            pct = int(pct)
        except (TypeError, ValueError):
            continue
        if 0 < pct < threshold and pct < lowest_pct:
            lowest_unit, lowest_pct = key, pct
    slot = str(lowest_unit) if lowest_unit is not None else None
    return (slot, lowest_pct) if lowest_unit is not None else (None, None)

def get_unit_with_aura(state_dict, aura_name):
    """
    获取拥有 aura_name 的单位。
    生命值 0 视为死亡不选。仅考虑职责不等于 0 的单位。

    参数:
        state_dict: 状态字典
        aura_name: group 中的键名（如 "腐化2"、"救赎"）
       
    返回 (unit, aura_duration) 或 (None, None)
    """
    group = state_dict.get("group") or {}
    best_unit, best_duration = None, None

    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue

        # aura 数值为 0 视为没有该光环
        val = data.get(aura_name)
        if val is None:
            continue
        try:
            duration = int(val)
        except (TypeError, ValueError):
            continue
        if duration <= 0:
            continue

        if best_duration is None or duration > best_duration:
            best_unit, best_duration = str(key), duration

    return (best_unit, best_duration) if best_unit is not None else (None, None)



def count_units_without_aura_below_health(state_dict, aura_name, health_threshold):
    """
    统计没有指定光环、且生命值低于给定阈值的单位数量。
    仅考虑职责不等于 0 的单位。
    - aura_name: group 中的键名（如 "救赎"、"真言术：盾"），或对应 aura[spellId]。
    - health_threshold: 血量阈值（百分比整数），统计 0 < 生命值 < health_threshold 的单位。
    返回一个整数 count。
    """
    group = state_dict.get("group") or {}
    count = 0
    try:
        threshold = int(health_threshold)
    except (TypeError, ValueError):
        return 0

    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue

        if _has_aura(data, aura_name):
            continue

        pct = data.get("生命值")
        if pct is None:
            continue
        try:
            pct = int(pct)
        except (TypeError, ValueError):
            continue

        if 0 < pct < threshold:
            count += 1

    return count

def count_units_with_aura(state_dict, aura_name):
    """
    统计拥有指定光环的单位数量。
    仅考虑职责不等于 0 的单位。
    - aura_name: group 中的键名（如 "救赎"、"真言术：盾"），或对应 aura[spellId]。
    返回一个整数 count。
    """
    group = state_dict.get("group") or {}
    count = 0

    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue

        if _has_aura(data, aura_name):
            count += 1

    return count

def count_units_below_health(state_dict, health_threshold):
    """
    统计生命值低于给定阈值的单位数量。
    仅考虑职责不等于 0 的单位。
    - health_threshold: 血量阈值（百分比整数），统计 0 < 生命值 < health_threshold 的单位。
    返回一个整数 count。
    """
    group = state_dict.get("group") or {}
    count = 0
    try:
        threshold = int(health_threshold)
    except (TypeError, ValueError):
        return 0

    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue

        pct = data.get("生命值")
        if pct is None:
            continue
        try:
            pct = int(pct)
        except (TypeError, ValueError):
            continue

        if 0 < pct < threshold:
            count += 1

    return count

def get_unit_with_dispel_type(state_dict, dispel_type):
    """
    查找拥有指定驱散类型的第一个单位。
    仅考虑职责不等于 0 的单位。
    - dispel_type: 驱散类型整数 。
    - group 中 驱散 字段为 type: int。
    返回 (slot_key, unit_data) 或 (None, None)，slot_key 为 "1"～"30"。
    """
    group = state_dict.get("group") or {}
    for key, data in group.items():
        if not isinstance(data, dict):
            continue
        if not _role_not_zero(data):
            continue
        val = data.get("驱散")      
        if val is not None:
            try:
                if int(val) == dispel_type:
                    return key, data
            except (TypeError, ValueError):
                pass
    return None, None


# --- 后台按键发送（Windows PostMessage）---
WM_KEYDOWN = 0x0100
WM_KEYUP   = 0x0101

# 修饰键与常用键的虚拟键码（与 keymap 中的名称一致）
_VK = {
    "SHIFT": 0x10,
    "CONTROL": 0x11,
    "CTRL": 0x11,
    "MENU": 0x12,
    "ALT": 0x12,
    # 鼠标侧键（XButton1 / XButton2）
    "XBUTTON1": 0x05,
    "X1": 0x05,
    "MOUSE4": 0x05,
    "XBUTTON2": 0x06,
    "X2": 0x06,
    "MOUSE5": 0x06,
    "F1": 0x70, "F2": 0x71, "F3": 0x72, "F4": 0x73, "F5": 0x74,
    "F6": 0x75, "F7": 0x76, "F8": 0x77, "F9": 0x78, "F10": 0x79,
    "F11": 0x7A, "F12": 0x7B,
    "NUMPAD0": 0x60, "NUMPAD1": 0x61, "NUMPAD2": 0x62, "NUMPAD3": 0x63,
    "NUMPAD4": 0x64, "NUMPAD5": 0x65, "NUMPAD6": 0x66, "NUMPAD7": 0x67,
    "NUMPAD8": 0x68, "NUMPAD9": 0x69,
    "NUMPADDECIMAL": 0x6E,
    "NUMPADPLUS": 0x6B,
    "NUMPADMINUS": 0x6D,
    "NUMPADMULTIPLY": 0x6A,
    "NUMPADDIVIDE": 0x6F,
}

# 单字符到 VK 的常用映射（与 keymap 中 CTRL-, 等一致）
_CHAR_VK = {
    ",": 0xBC, ".": 0xBE, "/": 0xBF, ";": 0xBA, "'": 0xDE,
    "[": 0xDB, "]": 0xDD, "=": 0xBB, "-": 0xBD, "`": 0xC0,
}


def _parse_hotkey(hotkey_str):
    """
    解析热键字符串，如 "CTRL-ALT-NUMPAD1" -> (['CTRL','ALT'], 'NUMPAD1')。
    单字符键如 "CTRL-," -> (['CTRL'], ',')。
    """
    if not hotkey_str or not isinstance(hotkey_str, str):
        return [], None
    parts = hotkey_str.strip().upper().split("-")
    if not parts:
        return [], None
    # 最后一段是主键，前面都是修饰键
    main_key = parts[-1]
    mods = []
    for p in parts[:-1]:
        if p in ("CTRL", "CONTROL", "ALT", "MENU", "SHIFT"):
            if p == "CONTROL":
                p = "CTRL"
            if p == "MENU":
                p = "ALT"
            if p not in mods:
                mods.append(p)
    # 主键保持原样以便匹配 NUMPAD1 或单字符
    if len(parts[-1]) == 1:
        main_key = hotkey_str.strip().split("-")[-1]  # 保留原始大小写/字符
    else:
        main_key = parts[-1]
    return mods, main_key


def _get_vk(key_name):
    """根据键名返回虚拟键码，单字符用 VkKeyScanW 或 _CHAR_VK。"""
    key_upper = key_name.upper() if isinstance(key_name, str) and len(key_name) > 1 else key_name
    if key_upper in _VK:
        return _VK[key_upper]
    if len(key_name) == 1 and key_name in _CHAR_VK:
        return _CHAR_VK[key_name]
    if len(key_name) == 1:
        # 使用 Windows API 获取字符的 VK
        vk = ctypes.windll.user32.VkKeyScanW(ord(key_name))
        if vk != -1:
            return vk & 0xFF
    return None


def get_vk(key_str):
    """
    根据键名字符串返回 Windows 虚拟键码（用于检测按键状态等）。
    支持单字符（如 "G"、"g"）或键名（如 "F1"、"NUMPAD1"）。无法解析时返回 None。
    """
    if not key_str or not isinstance(key_str, str):
        return None
    key_str = key_str.strip()
    if not key_str:
        return None
    return _get_vk(key_str)


def is_modifier_pressed():
    """
    检查是否按下了 Shift、Ctrl 或 Alt 修饰键中的任意一个。
    返回 True 表示有修饰键被按下，应该暂停发送按键。
    """
    # 虚拟键码：Shift=0x10, Ctrl=0x11, Alt=0x12
    VK_SHIFT = 0x10
    VK_CONTROL = 0x11
    VK_MENU = 0x12  # Alt键
    
    # GetAsyncKeyState 返回值如果最高位为1，表示按键被按下
    return (
        (ctypes.windll.user32.GetAsyncKeyState(VK_SHIFT) & 0x8000) != 0 or
        (ctypes.windll.user32.GetAsyncKeyState(VK_CONTROL) & 0x8000) != 0 or
        (ctypes.windll.user32.GetAsyncKeyState(VK_MENU) & 0x8000) != 0
    )


def send_key_to_wow(keys_str, window_title="魔兽世界"):
    """
    向指定窗口后台发送按键（不要求窗口在前台）。
    参数 keys_str: 与 keymap 中 hotkey 格式一致，如 "CTRL-NUMPAD1"、"ALT-F1"、"CTRL-,"。
    参数 window_title: 目标窗口标题，默认 "魔兽世界"。
    找到窗口则发送并返回 True，否则返回 False。
    注意：部分游戏使用 DirectInput/原始输入，可能不响应 PostMessage，此时需另用驱动或前台模拟。
    注意：如果按下了 Shift、Ctrl 或 Alt 修饰键，将暂停发送按键。
    """
    if not keys_str:
        return False
    
    # 检查是否按下了修饰键，如果是则暂停发送
    if is_modifier_pressed():
        return False
    
    mods, main_key = _parse_hotkey(keys_str)
    vk_main = _get_vk(main_key)
    if vk_main is None:
        return False

    hwnd = ctypes.windll.user32.FindWindowW(None, window_title)
    if not hwnd:
        return False

    # 修饰键 VK 列表（按下顺序）
    mod_vks = []
    for m in mods:
        vk = _get_vk(m)
        if vk is not None and vk not in mod_vks:
            mod_vks.append(vk)

    def post(key_code, key_up=False):
        lparam = 0xC0000001 if key_up else 0x00000001
        ctypes.windll.user32.PostMessageW(hwnd, WM_KEYUP if key_up else WM_KEYDOWN, key_code, lparam)

    # 顺序：修饰键按下 -> 主键按下 -> 主键抬起 -> 修饰键抬起
    for vk in mod_vks:
        post(vk, key_up=False)
    post(vk_main, key_up=False)
    post(vk_main, key_up=True)
    for vk in reversed(mod_vks):
        post(vk, key_up=True)

    return True