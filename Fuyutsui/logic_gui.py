# -*- coding: utf-8 -*-
"""
通用 GUI：根据职业/专精自动适配显示。
使用 CustomTkinter，背景半透明，文字保持清晰。
"""
import threading
import time
import ctypes
import customtkinter as ctk

import importlib

from utils import *
from GetPixels import get_info

title = "冬月"

def _load_logic_module(module_name: str):
    """Load a class-specific logic module from the `class/` package."""
    m = importlib.import_module(f"class.{module_name}")
    # Expected API: run_<class>_logic
    return getattr(m, f"run_{module_name.replace('_logic', '')}_logic")

run_priest_logic = _load_logic_module("priest_logic")
run_druid_logic = _load_logic_module("druid_logic")
run_paladin_logic = _load_logic_module("paladin_logic")
run_deathknight_logic = _load_logic_module("deathknight_logic")
run_warrior_logic = _load_logic_module("warrior_logic")
run_hunter_logic = _load_logic_module("hunter_logic")
run_rogue_logic = _load_logic_module("rogue_logic")
run_shaman_logic = _load_logic_module("shaman_logic")
run_mage_logic = _load_logic_module("mage_logic")
run_warlock_logic = _load_logic_module("warlock_logic")
run_monk_logic = _load_logic_module("monk_logic")
run_demonhunter_logic = _load_logic_module("demonhunter_logic")
run_evoker_logic = _load_logic_module("evoker_logic")

TOGGLE_INTERVAL = 0.05
LOGIC_INTERVAL = 0.1
GUI_UPDATE_MS = 100

LOGIC_FUNCS_BY_CLASS = {
    1: run_warrior_logic,
    2: run_paladin_logic,
    3: run_hunter_logic,
    4: run_rogue_logic,
    5: run_priest_logic,
    6: run_deathknight_logic,
    7: run_shaman_logic,
    8: run_mage_logic,
    9: run_warlock_logic,
    10: run_monk_logic,
    11: run_druid_logic,
    12: run_demonhunter_logic,
    13: run_evoker_logic,
}

def _default_logic(state_dict, spec_name):
    return None, "无逻辑定义", {}


_toggle_lock = threading.Lock()
_toggle_key_str = "XBUTTON2"
_toggle_vk = get_vk(_toggle_key_str)
_binding_key_mode = False

# 发送按键模式：switch=开关(持续) / click=单击(一次) / hold=按住(按住持续)
_send_mode = "switch"
_click_pending = False

_state_lock = threading.Lock()
_logic_enabled = False
_state_dict = {}
_class_name = None
_class_id = None
_spec_name = None
_spec_id = None
_current_step = ""  # 当前步骤，每次逻辑循环都会更新
_unit_info = {}  # 单位信息，供 GUI 显示

_CONFIG_CACHE = None
_DEFAULT_STATUS_KEYS = ["生命值", "能量值", "有效性", "战斗", "移动", "施法", "引导"]

# 不在「实时状态」中展示的键（锚点/职业/专精在 YAML 中与 state 分列，仍不显示）
_GUI_SKIP_STATE_KEYS = frozenset({"锚点", "职业", "专精"})


def _get_global_state_display_keys():
    """
    从 config 顶层 state 生成固定展示列名：按 step 升序，排除 group/spells 及 _GUI_SKIP_STATE_KEYS。
    若未配置 state，则退回 _DEFAULT_STATUS_KEYS。
    """
    config = _get_config_cached()
    raw = config.get("state")
    if not isinstance(raw, dict):
        return list(_DEFAULT_STATUS_KEYS)
    items = []
    for k, v in raw.items():
        if k in ("group", "spells") or k in _GUI_SKIP_STATE_KEYS:
            continue
        if not isinstance(v, dict) or "step" not in v:
            continue
        try:
            step = int(v["step"])
        except (TypeError, ValueError):
            step = 0
        items.append((step, k))
    if not items:
        return list(_DEFAULT_STATUS_KEYS)
    items.sort(key=lambda x: x[0])
    return [k for _, k in items]


def _get_config_cached():
    """config.yml 缓存：避免 GUI 每帧都重复解析 YAML。"""
    global _CONFIG_CACHE
    if _CONFIG_CACHE is None:
        _CONFIG_CACHE = load_config()
    return _CONFIG_CACHE


def _get_class_spec_cfg(class_id, spec_id):
    """获取 config.yml 里指定 (class_id, spec_id) 的 spec 配置块。"""
    if class_id is None or spec_id is None:
        return {}
    config = _get_config_cached()
    class_dict = config.get(class_id) or config.get(str(class_id)) or {}
    if not isinstance(class_dict, dict):
        return {}
    return class_dict.get(spec_id) or class_dict.get(str(spec_id)) or {}


def get_group_config_for_class_spec(class_id, spec_id):
    """根据 config.yml 生成队伍字段表格配置 (num_units, fields)。"""
    spec_cfg = _get_class_spec_cfg(class_id, spec_id)
    group_cfg = spec_cfg.get("group") if isinstance(spec_cfg, dict) else None
    if not isinstance(group_cfg, dict):
        return (0, [])
    try:
        num_units = int(group_cfg.get("num", 0))
    except (TypeError, ValueError):
        num_units = 0
    fields = [k for k in group_cfg.keys() if k not in ("start", "num")]
    return (num_units, fields)


def get_class_spec_view_data(class_id, spec_id):
    """
    聚合生成 GUI 所需数据，避免同一 spec_cfg 被重复解析三次：
    返回 (status_keys, (num_units, fields), spells_list)
    实时状态列：先固定展示 config 顶层 state（按 step），再追加当前专精独有字段（去重）。
    """
    fixed = _get_global_state_display_keys()
    spec_cfg = _get_class_spec_cfg(class_id, spec_id)
    if not isinstance(spec_cfg, dict) or not spec_cfg:
        return fixed, (0, []), []

    extra_keys = [k for k in spec_cfg.keys() if k not in ("spells", "group", "keymap")]
    status_keys = list(fixed)
    seen = set(fixed)
    for k in extra_keys:
        if k not in seen and k not in _GUI_SKIP_STATE_KEYS:
            status_keys.append(k)
            seen.add(k)

    spells_cfg = spec_cfg.get("spells")
    spells_list = list(spells_cfg.keys()) if isinstance(spells_cfg, dict) else []

    group_cfg = spec_cfg.get("group")
    if not isinstance(group_cfg, dict):
        group_num = 0
        fields = []
    else:
        try:
            group_num = int(group_cfg.get("num", 0))
        except (TypeError, ValueError):
            group_num = 0
        fields = [k for k in group_cfg.keys() if k not in ("start", "num")]

    return status_keys, (group_num, fields), spells_list


def _run_priest_loop():
    """后台运行的全职业主循环（根据职业/专精自动适配）"""
    global _logic_enabled, _state_dict, _class_name, _class_id, _spec_name, _spec_id, _current_step, _unit_info, _send_mode, _click_pending
    prev_pressed = False
    prev_vk = _toggle_vk
    last_logic_time = 0.0

    while True:
        if _binding_key_mode:
            time.sleep(TOGGLE_INTERVAL)
            continue

        vk_now = _toggle_vk
        if vk_now is None:
            time.sleep(TOGGLE_INTERVAL)
            continue

        # 如果用户在运行中修改了“开启逻辑”的按键，重置边沿状态，避免误触发
        if vk_now != prev_vk:
            prev_pressed = False
            prev_vk = vk_now

        current_pressed = (ctypes.windll.user32.GetAsyncKeyState(vk_now) & 0x8000) != 0
        rising = current_pressed and not prev_pressed
        falling = (not current_pressed) and prev_pressed

        # 根据“发送模式”决定何时启用逻辑与何时只发送一次
        mode = _send_mode
        if mode == "switch":
            if rising:
                with _state_lock:
                    _logic_enabled = not _logic_enabled
                    _click_pending = False
                _current_step = "逻辑 " + ("开启" if _logic_enabled else "关闭")
        elif mode == "click":
            # 单击：按一次发送一次
            if rising:
                with _state_lock:
                    _logic_enabled = True
                    _click_pending = True
                _current_step = "单击触发"
            # 松开不改变状态，由 pending 的“一次”发送逻辑决定何时关闭
        elif mode == "hold":
            # 按住：持续发送，松开停止
            with _state_lock:
                _logic_enabled = current_pressed
                _click_pending = False
            if falling:
                _current_step = "按住结束"
        else:
            # 兜底：不支持的模式按开关逻辑处理
            if rising:
                with _state_lock:
                    _logic_enabled = not _logic_enabled
                    _click_pending = False
                _current_step = "逻辑 " + ("开启" if _logic_enabled else "关闭")

        prev_pressed = current_pressed

        now = time.time()
        if now - last_logic_time >= LOGIC_INTERVAL:
            last_logic_time = now
            state_dict = get_info()
            class_name, spec_name = None, None
            class_id, spec_id = None, None
            if state_dict:
                class_id = state_dict.get("职业")
                spec_id = state_dict.get("专精")
                config = load_config()
                class_name, spec_name = get_class_and_spec_name(config, class_id, spec_id)
                select_keymap_for_class(class_id)

            with _state_lock:
                _state_dict = state_dict or {}
                _class_name = class_name
                _class_id = class_id
                _spec_name = spec_name
                _spec_id = spec_id

        if not _logic_enabled:
            time.sleep(TOGGLE_INTERVAL)
            continue

        sd = _state_dict
        if not sd or not sd.get("有效性"):
            _current_step = "等待游戏状态"
            time.sleep(TOGGLE_INTERVAL)
            continue

        state_dict = sd
        class_id = _class_id
        spec_name = _spec_name
        action_hotkey = None
        _current_step = "无操作"  # 每轮重置，确保显示本轮决策

        logic_func = LOGIC_FUNCS_BY_CLASS.get(class_id, _default_logic)
        action_hotkey, _current_step, unit_info_update = logic_func(state_dict, spec_name)
        if unit_info_update:
            with _state_lock:
                _unit_info = unit_info_update

        # 根据发送模式处理发送逻辑
        if mode == "click":
            with _state_lock:
                pending = _click_pending
            if pending:
                # 只发送一次：无论是否命中 action_hotkey，都结束本次单击
                if action_hotkey:
                    send_key_to_wow(action_hotkey)
                with _state_lock:
                    _logic_enabled = False
                    _click_pending = False
        else:
            if action_hotkey:
                send_key_to_wow(action_hotkey)
        time.sleep(TOGGLE_INTERVAL)

# CustomTkinter 配色：深灰主题，文字高对比度
BG_DARK = "#1e1e1e"
BG_FRAME = "#2d2d2d"
FG_LIGHT = "#eaeaea"
GREEN = "#00d9a5"
RED = "#ff6b6b"
FG_DIM = "#94a3b8"
WINDOW_ALPHA = 1.0   # 1.0=文字不透明；若需背景半透明可调低（整窗同透明度）

# 职业名称颜色（用于 GUI 顶部“职业”显示）
CLASS_NAME_COLORS = {
    "战士": "#C79C6E",
    "圣骑士": "#F58CBA",
    "猎人": "#ABD473",
    "盗贼": "#FFF569",
    "潜行者": "#FFF569",
    "牧师": "#FFFFFF",
    "萨满": "#0070DE",
    "法师": "#69CCF0",
    "术士": "#9482C9",
    "武僧": "#00FF96",
    "德鲁伊": "#FF7D0A",
    "死亡骑士": "#C41F3B",
    "恶魔猎手": "#A330C9",
    "唤魔师": "#33937F",
}

def _disable_ime_for_hwnd(hwnd: int):
    """
    尽量关闭指定窗口的 IME，避免窗口获取焦点后弹出输入法候选/输入窗口。
    Windows IME 相关接口有兼容性差异，所以做了多种 best-effort。
    """
    try:
        imm32 = ctypes.windll.imm32
        hIMC = imm32.ImmGetContext(hwnd)
        if hIMC:
            # 0=关闭 IME 打开状态
            imm32.ImmSetOpenStatus(hIMC, 0)
            imm32.ImmReleaseContext(hwnd, hIMC)
            return True
    except Exception:
        pass

    # 兜底：不同系统/签名可能导致 ImmDisableIME 行为不一致
    try:
        ctypes.windll.imm32.ImmDisableIME(0)
        return True
    except Exception:
        return False


def create_gui():
    ctk.set_appearance_mode("dark")
    ctk.set_default_color_theme("dark-blue")

    root = ctk.CTk()
    try:
        hwnd = root.winfo_id()
        _disable_ime_for_hwnd(hwnd)
        # 再延迟一次，避免窗口刚创建/获得焦点后 IME 状态又被系统恢复
        root.after(200, lambda: _disable_ime_for_hwnd(root.winfo_id()))
    except Exception:
        pass
    root.title(title)
    root.geometry("400x680")
    root.resizable(True, True)
    root.attributes("-topmost", True)
    root.configure(fg_color=BG_DARK)
    # 背景半透明，文字使用高对比度颜色保持清晰
    root.attributes("-alpha", WINDOW_ALPHA)

    main_frame = ctk.CTkFrame(root, fg_color="transparent")
    main_frame.pack(fill="both", expand=True, padx=12, pady=12)

    # ---- 1. 职业/专精 + 开关 ----
    top_frame = ctk.CTkFrame(main_frame, fg_color=BG_FRAME, corner_radius=8)
    top_frame.pack(fill="x", pady=(0, 6))

    inner_top = ctk.CTkFrame(top_frame, fg_color="transparent")
    inner_top.pack(fill="x", padx=12, pady=(10, 4))

    class_prefix_label = ctk.CTkLabel(inner_top, text="职业:", font=("Microsoft YaHei", 14, "bold"), text_color=FG_LIGHT)
    class_prefix_label.pack(side="left", padx=(12, 0))
    class_name_label = ctk.CTkLabel(inner_top, text="-", font=("Microsoft YaHei", 14, "bold"), text_color=FG_LIGHT)
    class_name_label.pack(side="left", padx=(6, 0))
    spec_label = ctk.CTkLabel(inner_top, text="专精: -", font=("Microsoft YaHei", 14, "bold"), text_color=FG_LIGHT)
    spec_label.pack(side="left", padx=(12, 0))

    toggle_row = ctk.CTkFrame(top_frame, fg_color="transparent")
    toggle_row.pack(fill="x", padx=12, pady=(0, 10))

    binding_in_progress = False

    def _display_key_str(key_str: str) -> str:
        # 让空格等字符更友好显示
        if key_str == " ":
            return "SPACE"
        return str(key_str)

    def _stop_binding():
        nonlocal binding_in_progress
        binding_in_progress = False
        global _binding_key_mode
        _binding_key_mode = False
        bind_btn.configure(state="normal")
        try:
            root.unbind("<KeyPress>")
            root.unbind("<ButtonPress>")
        except Exception:
            pass

    def _set_bound_key(key_str: str):
        global _toggle_key_str, _toggle_vk
        vk = get_vk(key_str)
        if vk is None:
            return False
        with _toggle_lock:
            _toggle_key_str = key_str
            _toggle_vk = vk
        return True

    def on_key_press(event):
        nonlocal binding_in_progress
        if not binding_in_progress:
            return
        # 防止某些输入法在检测 KeyPress 前后重新打开
        try:
            _disable_ime_for_hwnd(root.winfo_id())
        except Exception:
            pass

        # Tk 的 event.char 在输入字符时更可靠；功能键通常 event.keysym 可用
        candidate = None
        ch = getattr(event, "char", "")
        if ch and isinstance(ch, str) and len(ch) == 1:
            candidate = ch.upper()
        else:
            keysym = getattr(event, "keysym", None) or ""
            keysym = str(keysym)
            if keysym.lower() == "space":
                candidate = " "
            else:
                candidate = keysym.upper() if len(keysym) > 1 else keysym

        if not candidate:
            return

        if not _set_bound_key(candidate):
            bound_key_label.configure(text=f"已绑定:（不支持 {candidate}，请重试）")
            return

        bound_key_label.configure(text=f"已绑定: {_display_key_str(candidate)}")
        _stop_binding()

    def on_button_press(event):
        nonlocal binding_in_progress
        if not binding_in_progress:
            return
        try:
            _disable_ime_for_hwnd(root.winfo_id())
        except Exception:
            pass

        # Tk 通常把额外鼠标键映射为 ButtonPress-4 / ButtonPress-5
        num = getattr(event, "num", None)
        candidate = None
        if num == 4:
            candidate = "XBUTTON1"
        elif num == 5:
            candidate = "XBUTTON2"

        if not candidate:
            bound_key_label.configure(text="已绑定:（不支持该鼠标键，请重试）")
            return

        if not _set_bound_key(candidate):
            bound_key_label.configure(text=f"已绑定:（不支持 {candidate}，请重试）")
            return

        bound_key_label.configure(text=f"已绑定: {_display_key_str(candidate)}")
        _stop_binding()

    def start_binding_key():
        nonlocal binding_in_progress
        if binding_in_progress:
            return

        binding_in_progress = True
        global _binding_key_mode
        _binding_key_mode = True
        bind_btn.configure(state="disabled")
        bound_key_label.configure(text="已绑定:（请按下按键）")

        # 让当前窗口获得焦点，尽量保证 KeyPress 能进来
        try:
            root.focus_force()
            # focus 后立即再关一次 IME，避免候选/输入窗口被重新弹出
            _disable_ime_for_hwnd(root.winfo_id())
            root.after(100, lambda: _disable_ime_for_hwnd(root.winfo_id()))
        except Exception:
            pass

        root.bind("<KeyPress>", on_key_press)
        root.bind("<ButtonPress>", on_button_press)

    bind_btn = ctk.CTkButton(
        toggle_row,
        text="绑定按键",
        command=start_binding_key,
        font=("Microsoft YaHei", 12),
        fg_color=BG_DARK,
        text_color=FG_LIGHT,
        hover_color="#3d3d3d",
        corner_radius=8,
        width=90,
    )
    bind_btn.pack(side="left", padx=(0, 8))

    bound_key_label = ctk.CTkLabel(
        toggle_row,
        text=f"已绑定: {_display_key_str(_toggle_key_str)}",
        font=("Microsoft YaHei", 12),
        text_color=FG_DIM,
    )
    bound_key_label.pack(side="left")

    status_label = ctk.CTkLabel(
        toggle_row,
        text="状态: 关闭",
        font=("Microsoft YaHei", 12),
        text_color=RED,
    )
    status_label.pack(side="right")

    # ---- 额外：发送模式（开关/单击/按住）----
    mode_row = ctk.CTkFrame(top_frame, fg_color="transparent")
    mode_row.pack(fill="x", padx=12, pady=(0, 10))

    mode_label = ctk.CTkLabel(mode_row, text="发送模式:", font=("Microsoft YaHei", 12), text_color=FG_LIGHT)
    mode_label.pack(side="left")

    # 使用 GUI 按钮控制全局发送模式，并在切换时立即停止当前发送
    def set_send_mode(mode: str):
        global _send_mode, _logic_enabled, _click_pending
        with _state_lock:
            _send_mode = mode
            _click_pending = False
            _logic_enabled = False
        update_mode_buttons()

    def update_mode_buttons():
        # 当前模式按钮绿色，其余白色
        active = _send_mode
        switch_btn.configure(text_color=GREEN if active == "switch" else FG_LIGHT)
        click_btn.configure(text_color=GREEN if active == "click" else FG_LIGHT)
        hold_btn.configure(text_color=GREEN if active == "hold" else FG_LIGHT)

    switch_btn = ctk.CTkButton(
        mode_row,
        text="开关",
        command=lambda: set_send_mode("switch"),
        font=("Microsoft YaHei", 12),
        width=80,
        fg_color=BG_DARK,
        text_color=GREEN if _send_mode == "switch" else FG_LIGHT,
        hover_color="#3d3d3d",
        corner_radius=8,
    )
    switch_btn.pack(side="left", padx=(12, 6))

    click_btn = ctk.CTkButton(
        mode_row,
        text="单击",
        command=lambda: set_send_mode("click"),
        font=("Microsoft YaHei", 12),
        width=80,
        fg_color=BG_DARK,
        text_color=GREEN if _send_mode == "click" else FG_LIGHT,
        hover_color="#3d3d3d",
        corner_radius=8,
    )
    click_btn.pack(side="left", padx=(6, 6))

    hold_btn = ctk.CTkButton(
        mode_row,
        text="按住",
        command=lambda: set_send_mode("hold"),
        font=("Microsoft YaHei", 12),
        width=80,
        fg_color=BG_DARK,
        text_color=GREEN if _send_mode == "hold" else FG_LIGHT,
        hover_color="#3d3d3d",
        corner_radius=8,
    )
    hold_btn.pack(side="left", padx=(6, 6))

    # ---- 3. 显示队伍（弹窗）----
    def open_team_window():
        with _state_lock:
            spec_snapshot = _spec_name
            class_snapshot = _class_name
            spec_id_snapshot = _spec_id
            class_id_snapshot = _class_id

        # 专精未知时不显示弹窗内容（也不弹窗）
        if spec_snapshot is None:
            return

        team_window = ctk.CTkToplevel(root)
        team_window.title("队伍信息")
        team_window.geometry("550x600")
        team_window.resizable(True, True)
        team_window.attributes("-topmost", True)
        try:
            team_window.attributes("-alpha", WINDOW_ALPHA)
        except Exception:
            pass

        header_frame = ctk.CTkFrame(team_window, fg_color=BG_FRAME, corner_radius=8)
        header_frame.pack(fill="x", padx=12, pady=(12, 8))
        header_label = ctk.CTkLabel(
            header_frame,
            text=f"队伍信息（职业: {class_snapshot or '-'} / 专精: {spec_snapshot or '-'})",
            font=("Microsoft YaHei", 12, "bold"),
            text_color=FG_LIGHT,
            anchor="w",
        )
        header_label.pack(fill="x", padx=12, pady=10)

        body_frame = ctk.CTkFrame(team_window, fg_color="transparent")
        body_frame.pack(fill="both", expand=True, padx=12, pady=(0, 12))

        team_text = ctk.CTkTextbox(
            body_frame,
            wrap="none",
            font=("Consolas", 11),
            corner_radius=8,
        )
        team_text.pack(fill="both", expand=True)
        team_text.configure(state="disabled")

        def format_value(v):
            if v is None:
                return "-"
            if isinstance(v, bool):
                return "是" if v else "否"
            return str(v)

        def build_team_text(sd, spec_name, class_id, spec_id, unit_info):
            if spec_name is None:
                return ""

            group = sd.get("group") or {}
            if not group:
                return "未检测到队伍数据（请确认游戏窗口存在且扫描成功）。\n"

            # group keys 理论上是 "1".."30"
            unit_keys = sorted(
                group.keys(),
                key=lambda x: int(x) if str(x).isdigit() else 10**9,
            )

            # 字段排序：优先使用当前专精在主界面显示的字段顺序，其余字段按字母排序补齐
            ordered_fields = []
            if spec_name and class_id is not None and spec_id is not None:
                try:
                    _, fields_for_spec = get_group_config_for_class_spec(class_id, spec_id)
                    ordered_fields.extend([f for f in fields_for_spec if f not in ordered_fields])
                except Exception:
                    pass

            rest_fields = set()
            for uk in unit_keys:
                unit_data = group.get(uk) or {}
                for f in unit_data.keys():
                    if f not in ordered_fields:
                        rest_fields.add(f)

            ordered_fields.extend(sorted(rest_fields))

            lines = []
            lines.append(f"单位总数: {len(unit_keys)}")
            lines.append(f"字段数: {len(ordered_fields)}")
            lines.append("")

            for uk in unit_keys:
                unit_data = group.get(uk) or {}
                # 每个单位严格一行：字段之间用分隔符拼接，避免多行导致滚动成本过高
                field_parts = []
                for f in ordered_fields:
                    field_parts.append(f"{f}={format_value(unit_data.get(f))}")
                lines.append(f"Unit {uk}: " + " | ".join(field_parts))

            if unit_info:
                lines.append("")
                lines.append("逻辑推荐/目标单位（unit_info）")
                for k in sorted(unit_info.keys()):
                    lines.append(f"  {k}: {format_value(unit_info.get(k))}")

            return "\n".join(lines) + "\n"

        # 自动刷新：让弹窗能跟随实时状态变化
        def refresh():
            if not team_window.winfo_exists():
                return

            with _state_lock:
                sd_now = dict(_state_dict)
                spec_now = _spec_name
                class_now = _class_name
                spec_id_now = _spec_id
                class_id_now = _class_id
                unit_info_now = dict(_unit_info)

            # 更新顶部标题（职业/专精可能在首次打开后发生变化）
            if spec_now is None:
                header_label.configure(
                    text=f"队伍信息（职业: {class_now or '-'} / 专精: -）"
                )
                team_text.configure(state="normal")
                team_text.delete("1.0", "end")
                team_text.configure(state="disabled")
            else:
                header_label.configure(
                    text=f"队伍信息（职业: {class_now or '-'} / 专精: {spec_now or '-'})"
                )

                team_text.configure(state="normal")
                team_text.delete("1.0", "end")
                team_text.insert("end", build_team_text(sd_now, spec_now, class_id_now, spec_id_now, unit_info_now))
                team_text.configure(state="disabled")

            TEAM_WINDOW_REFRESH_MS = 500
            team_window.after(TEAM_WINDOW_REFRESH_MS, refresh)

        refresh()

    # 顶部新增按钮：点击弹窗展示所有单位信息
    normal_geometry = "400x680"
    small_geometry = "400x110"
    is_small = False

    resize_btn = None

    def toggle_window_size():
        nonlocal is_small, resize_btn
        is_small = not is_small
        root.geometry(small_geometry if is_small else normal_geometry)
        # 同步按钮图标：当前为缩小状态时显示“▲”表示可恢复
        if resize_btn is not None:
            resize_btn.configure(text=("▲" if is_small else "▼"))

    resize_btn = ctk.CTkButton(
        inner_top,
        text="▼",
        command=toggle_window_size,
        font=("Microsoft YaHei", 12),
        width=28,
        fg_color=BG_DARK,
        text_color=FG_LIGHT,
        hover_color="#3d3d3d",
        corner_radius=8,
    )
    resize_btn.pack(side="right", padx=(0, 8))

    ctk.CTkButton(
        inner_top,
        text="显示队伍",
        command=open_team_window,
        font=("Microsoft YaHei", 12),
        width=100,
        fg_color=BG_DARK,
        text_color=FG_LIGHT,
        hover_color="#3d3d3d",
        corner_radius=8,
    ).pack(side="right", padx=(8, 0))

    # ---- 2. 状态区域（未检测到职业时不显示）----
    content_frame = ctk.CTkFrame(main_frame, fg_color="transparent")
    # 不 pack content_frame，等检测到职业后再显示

    status_frame = ctk.CTkFrame(content_frame, fg_color=BG_FRAME, corner_radius=8)

    status_frame.pack(fill="both", expand=True, pady=(0, 6))

    status_header = ctk.CTkFrame(status_frame, fg_color="transparent")
    status_header.pack(fill="x", padx=12, pady=(10, 2))
    ctk.CTkLabel(status_header, text="实时状态", font=("Microsoft YaHei", 13, "bold"), text_color=FG_LIGHT).pack(side="left")

    status_grid = ctk.CTkFrame(status_frame, fg_color="transparent")
    status_grid.pack(fill="x", padx=12, pady=4)

    status_vars = {}

    def update_status_display(keys):
        for w in status_grid.winfo_children():
            w.destroy()
        status_vars.clear()
        for i, k in enumerate(keys):
            row, col = i // 3, (i % 3) * 2
            ctk.CTkLabel(status_grid, text=k + ":", font=("Microsoft YaHei", 12), text_color=FG_DIM).grid(
                row=row, column=col, sticky="w", padx=(0, 4), pady=1)
            lbl = ctk.CTkLabel(status_grid, text="-", font=("Microsoft YaHei", 12), text_color=FG_LIGHT)
            lbl.grid(row=row, column=col + 1, sticky="w", padx=(0, 16), pady=1)
            status_vars[k] = lbl

    action_label = ctk.CTkLabel(status_frame, text="当前步骤: -", font=("Microsoft YaHei", 12), text_color=FG_LIGHT)
    action_label.pack(anchor="w", padx=12, pady=(8, 10))

    # ---- 技能冷却 ----
    cooldown_frame = ctk.CTkFrame(content_frame, fg_color=BG_FRAME, corner_radius=8)
    cooldown_frame.pack(fill="x", pady=(0, 6))
    cooldown_header = ctk.CTkFrame(cooldown_frame, fg_color="transparent")
    cooldown_header.pack(fill="x", padx=12, pady=(10, 2))
    ctk.CTkLabel(cooldown_header, text="技能冷却", font=("Microsoft YaHei", 13, "bold"), text_color=FG_LIGHT).pack(side="left")
    cooldown_grid = ctk.CTkFrame(cooldown_frame, fg_color="transparent")
    cooldown_grid.pack(fill="x", padx=12, pady=(4, 10))
    cooldown_vars = {}

    COOLDOWN_PER_ROW = 3

    def update_cooldown_display(spell_list):
        """根据专精技能列表重建冷却显示，每行 3 个技能"""
        for w in cooldown_grid.winfo_children():
            w.destroy()
        cooldown_vars.clear()
        if not spell_list:
            return
        for i, name in enumerate(spell_list):
            row = i // COOLDOWN_PER_ROW
            col = (i % COOLDOWN_PER_ROW) * 2
            ctk.CTkLabel(cooldown_grid, text=name + ":", font=("Microsoft YaHei", 11), text_color=FG_DIM).grid(
                row=row, column=col, sticky="w", padx=(0, 4), pady=1)
            lbl = ctk.CTkLabel(cooldown_grid, text="-", font=("Microsoft YaHei", 11), text_color=FG_LIGHT)
            lbl.grid(row=row, column=col + 1, sticky="w", padx=(0, 16), pady=1)
            cooldown_vars[name] = lbl

    last_cooldown_spells = [None]

    last_status_keys = [None]

    def update_display():
        with _state_lock:
            sd = dict(_state_dict)
            enabled = _logic_enabled
            mode = _send_mode
            class_name = _class_name
            spec = _spec_name
            class_id = _class_id
            spec_id = _spec_id

        class_name_label.configure(
            text=class_name or "-",
            text_color=CLASS_NAME_COLORS.get(class_name, FG_LIGHT),
        )
        spec_label.configure(text=f"专精: {spec or '-'}")
        if spec is None:
            if content_frame.winfo_ismapped():
                content_frame.pack_forget()
            root.after(GUI_UPDATE_MS, update_display)
            return
        if not content_frame.winfo_ismapped():
            content_frame.pack(fill="both", expand=True, pady=(0, 6))

        # 发送模式显示：单击模式固定显示“状态: 单击”并高亮
        if mode == "click":
            status_label.configure(text="状态: 单击", text_color=GREEN)
        else:
            status_label.configure(
                text=f"状态: {'开启' if enabled else '关闭'}",
                text_color=GREEN if enabled else RED,
            )

        current_status_keys, _, current_cooldown_spells = get_class_spec_view_data(class_id, spec_id)
        if last_status_keys[0] != current_status_keys:
            last_status_keys[0] = current_status_keys
            update_status_display(current_status_keys)

        if last_cooldown_spells[0] != current_cooldown_spells:
            last_cooldown_spells[0] = current_cooldown_spells
            update_cooldown_display(current_cooldown_spells)

        spells_data = sd.get("spells") or {}
        for name, lbl in cooldown_vars.items():
            val = spells_data.get(name)
            if val is None:
                lbl.configure(text="-", text_color=FG_DIM)
            else:
                lbl.configure(text=str(int(val)), text_color=FG_LIGHT)

        for k in status_vars:
            v = sd.get(k)
            txt = str(v) if v is not None else "-"
            status_vars[k].configure(text=txt, text_color=GREEN if v is True else (RED if v is False else FG_LIGHT))

        action_label.configure(text=f"当前步骤: {_current_step}")

        root.after(GUI_UPDATE_MS, update_display)

    default_keys, _, _ = get_class_spec_view_data(None, None)
    update_status_display(default_keys)
    last_status_keys[0] = default_keys
    root.after(0, update_display)

    def start_worker():
        try:
            _run_priest_loop()
        except Exception as e:
            print("Worker error:", e)

    worker = threading.Thread(target=start_worker, daemon=True)
    worker.start()

    root.mainloop()


if __name__ == "__main__":
    create_gui()
