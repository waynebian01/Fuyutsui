import ctypes            # 用于调用 Windows 底层的 C 函数库（操作窗口、处理缩放）
from ctypes import wintypes # 定义了 Windows 专用的数据类型（如 POINT, RECT）
import mss              # 一个极速的屏幕截图库，比 PIL 快很多
import os               # 用于配置路径
import sys              # 用于添加父目录到导入路径
import time             # 用于统计扫描耗时
import yaml             # 加载 config.yml

# 添加当前目录到路径，用于导入 utils
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if _SCRIPT_DIR not in sys.path:
    sys.path.insert(0, _SCRIPT_DIR)

# 解决 Windows 屏幕缩放问题（高 DPI 适配）
try:
    ctypes.windll.user32.SetProcessDPIAware()
except Exception:
    pass

# config.yml 与 GetPixels.py 同目录
CONFIG_PATH = os.path.join(_SCRIPT_DIR, "config.yml")

PIXELS_PER_ROW = 255  # 扫描 255 个数据点

def load_config():
    """加载 config.yml"""
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def get_game_top_left(window_title):
    """获取游戏客户区（不含标题栏和边框）左上角坐标及宽度"""
    hwnd = ctypes.windll.user32.FindWindowW(None, window_title)
    if not hwnd:
        return None

    point = wintypes.POINT(0, 0)
    ctypes.windll.user32.ClientToScreen(hwnd, ctypes.byref(point))

    rect = wintypes.RECT()
    ctypes.windll.user32.GetClientRect(hwnd, ctypes.byref(rect))
    window_width = rect.right - rect.left

    return point.x, point.y, window_width


def scan_top_bar(window_title="魔兽世界"):
    """
    扫描客户区顶部长条（自适应步长）：
    找 (R=0,G=1,B=0) 为起点，向右逐像素扫描，当 R=0 且 1<=G<=200 时，
    用 G 通道作为索引、B 通道作为数值，填充 row_data。
    返回 row_data: {1: val1, 2: val2, ...} 或 None
    """
    pos = get_game_top_left(window_title)
    if not pos:
        return None

    base_x, base_y, width = pos

    with mss.mss() as sct:
        monitor = {"top": base_y, "left": base_x, "width": width, "height": 1}
        img = sct.grab(monitor)
        raw_data = img.raw
        total_bytes = len(raw_data)

        def pixel_at(x, y):
            offset = (y * width + x) * 4
            if offset + 2 >= total_bytes or x >= width:
                return None, None, None
            # mss 返回 BGRA
            return raw_data[offset], raw_data[offset + 1], raw_data[offset + 2]

        # 1. 找起点 (R=0, G=1, B=0)
        start_x = -1
        for x in range(min(PIXELS_PER_ROW, width)):
            b, g, r = pixel_at(x, 0)
            if r is None:
                break
            if r == 0 and g == 1 and b == 0:
                start_x = x
                break
        if start_x == -1:
            return None

        # 2. 从起点向右逐像素扫描，G 通道为索引 (1~200)，B 通道为数值
        row_data = {}
        current_x = start_x
        while current_x < width:
            b, g, r = pixel_at(current_x, 0)
            if r is None:
                break
            if r == 0 and 1 <= g <= PIXELS_PER_ROW:
                row_data[g] = b
                if g == PIXELS_PER_ROW:
                    break
            current_x += 1

        return row_data if row_data else None


# 可与 state 分开展开在 YAML 顶层的像素元字段（step 与 state 同一套索引）
_META_PIXEL_KEYS = ("锚点", "职业", "专精")


def _get_spec_config(config, class_id, spec_id):
    """合并顶层元字段、state 与职业专精配置。config 结构：锚点/职业/专精、state，以及 5->1 等。"""
    state = config.get("state") or {}
    spec_cfg = {}
    class_dict = config.get(class_id) if class_id is not None else None
    if isinstance(class_dict, dict):
        spec_cfg = class_dict.get(spec_id) or {}
    merged = {}
    for key in _META_PIXEL_KEYS:
        block = config.get(key)
        if isinstance(block, dict) and "step" in block:
            merged[key] = block
    merged.update(state)
    for k, v in (spec_cfg or {}).items():
        merged[k] = v
    return merged


def build_state_dict(config, row_data, state_config, class_id=None, spec_id=None):
    """
    根据 state_config 和 row_data 构建完整字典。
    键 = 配置的 key（如 职业、专精、生命值），值 = 按 type 转换后的整数/布尔/字符串；
    spells 和 group 为子字典；
    group 从 start 开始，每隔 num 个 step 为一个子字典（每个队友/小队成员）。
    """
    result = {}
    if class_id is None and 2 in row_data:
        class_id = row_data[2]
    if spec_id is None and 3 in row_data:
        spec_id = row_data[3]

    # 解析 state 中的普通字段（非 spells、group）
    for key, field in (state_config or {}).items():
        if key in ("group", "spells"):
            continue
        if not isinstance(field, dict) or "step" not in field:
            continue
        step = field["step"]
        name = key
        type_ = field.get("type", "int")
        raw = row_data.get(step)

        if type_ == "int":
            result[name] = int(raw) if raw is not None else 0
        elif type_ == "bool":
            result[name] = bool(int(raw)) if raw is not None else False
        else:
            result[name] = raw

    # spells 子字典
    spells_config = (state_config or {}).get("spells")
    if spells_config and isinstance(spells_config, dict):
        spells_sub = {}
        for spell_key, spell_field in spells_config.items():
            if not isinstance(spell_field, dict) or "step" not in spell_field:
                continue
            step = spell_field["step"]
            type_ = spell_field.get("type", "int")
            raw = row_data.get(step)
            if type_ == "int":
                spells_sub[spell_key] = int(raw) if raw is not None else 0
            elif type_ == "bool":
                spells_sub[spell_key] = bool(int(raw)) if raw is not None else False
            else:
                spells_sub[spell_key] = int(raw) if raw is not None else 0
        result["spells"] = spells_sub

    # group 子字典：从 start 开始，每隔 num 个 step 为一个成员
    # Lua: index = unit_start + obj.index * unit_num + field_offset (1~5)
    # Python: base_step=start+(i-1)*num, row_key=base_step+(rel_step-1) 对应 Lua 的 index
    group_config = (state_config or {}).get("group")
    if group_config and isinstance(group_config, dict):
        start = group_config.get("start", 26)
        num_params = group_config.get("num", 5)
        NUM_GROUPS = 30
        result["group"] = {}
        for i in range(1, NUM_GROUPS + 1):
            base_step = start + (i - 1) * num_params
            sub = {}
            for field_key, field in group_config.items():
                if field_key in ("start", "num") or not isinstance(field, dict) or "step" not in field:
                    continue
                rel_step = field.get("step")
                type_ = field.get("type", "int")
                row_key = base_step + rel_step
                raw = row_data.get(row_key)
                if type_ == "int":
                    sub[field_key] = int(raw) if raw is not None else 0
                elif type_ == "bool":
                    sub[field_key] = bool(int(raw)) if raw is not None else False
                else:
                    sub[field_key] = int(raw) if raw is not None else 0
            result["group"][str(i)] = sub

    return result


def get_info(window_title="魔兽世界"):
    """
    主入口：扫描顶部长条，加载配置，根据职业专精扩展字典，返回完整状态字典。
    """
    row_data = scan_top_bar(window_title)
    if not row_data:
        return None

    config = load_config()
    class_id = row_data.get(2)
    spec_id = row_data.get(3)

    state_config = _get_spec_config(config, class_id, spec_id)
    return build_state_dict(config, row_data, state_config, class_id, spec_id)


if __name__ == "__main__":
    start_time = time.perf_counter()
    info = get_info()
    elapsed_ms = (time.perf_counter() - start_time) * 1000

    print(f"扫描耗时: {elapsed_ms:.2f} ms")
    if info:
        import json
        # 简单打印（json 对中文友好）
        print(json.dumps(info, ensure_ascii=False, indent=2))
    else:
        print("未找到游戏窗口或扫描失败")
