# -*- coding: utf-8 -*-
"""
Fuyutsui 统一入口：支持 GUI 模式和无界面模式。
GUI 模式: python logic_gui.py
无界面模式: python logic_gui.py --headless [--window-title "魔兽世界"] [--interval 0.05] [--debug]
"""

import argparse
import importlib
import json
import re
import sys
import threading
import time
import ctypes
from pathlib import Path

from GetPixels import get_info
from utils import (
    get_class_and_spec_name,
    load_config,
    select_keymap_for_class,
    send_key_to_wow,
)

# =============================================================================
# 公共配置和辅助函数
# =============================================================================

title = "冬月"

# GUI 相关常量
DEFAULT_MAIN_GEOMETRY = "400x110"
DEFAULT_TEAM_GEOMETRY = "550x600"
DEFAULT_LIVE_INFO_GEOMETRY = "420x540"

# 加载逻辑模块
def _load_logic_module(module_name: str):
    """Load a class-specific logic module from the `class/` package."""
    m = importlib.import_module(f"class.{module_name}")
    return getattr(m, f"run_{module_name.replace('_logic', '')}_logic")

LOGIC_FUNCS_BY_CLASS = {
    1: _load_logic_module("warrior_logic"),
    2: _load_logic_module("paladin_logic"),
    3: _load_logic_module("hunter_logic"),
    4: _load_logic_module("rogue_logic"),
    5: _load_logic_module("priest_logic"),
    6: _load_logic_module("deathknight_logic"),
    7: _load_logic_module("shaman_logic"),
    8: _load_logic_module("mage_logic"),
    9: _load_logic_module("warlock_logic"),
    10: _load_logic_module("monk_logic"),
    11: _load_logic_module("druid_logic"),
    12: _load_logic_module("demonhunter_logic"),
    13: _load_logic_module("evoker_logic"),
}

def _default_logic(state_dict, spec_name):
    return None, "无逻辑定义", {}

# =============================================================================
# Headless 模式相关代码
# =============================================================================

DEFAULT_WINDOW_TITLE = "魔兽世界"
DEFAULT_INTERVAL = 0.05
LOG_PATH = Path(__file__).resolve().parent / "logic_headless.log"

def _log(message: str):
    line = f"{time.strftime('%Y-%m-%d %H:%M:%S')} {message}"
    print(line, flush=True)
    try:
        with LOG_PATH.open("a", encoding="utf-8") as f:
            f.write(line + "\n")
    except OSError:
        pass

_headless_logic_enabled = True  # 默认为 True，由 Lua 端控制

def run_headless(window_title: str, interval: float, debug: bool = False):
    """运行无界面模式主循环。逻辑开关由有效性像素控制（由 Lua 端设置）。"""
    config = load_config()
    last_identity = None
    last_valid = None
    last_status = None

    _log("Fuyutsui headless runtime started.")
    _log("Use /fbg logic on/off in game to control logic.")

    global _headless_logic_enabled
    _headless_logic_enabled = True  # 初始状态

    while True:
        loop_start = time.perf_counter()
        state_dict = get_info()

        if not state_dict:
            status = "等待游戏窗口或像素数据"
            if status != last_status:
                _log(status)
                last_status = status
            _sleep_remaining(loop_start, interval)
            continue

        class_id = state_dict.get("职业")
        spec_id = state_dict.get("专精")
        identity = (class_id, spec_id)
        if identity != last_identity:
            select_keymap_for_class(class_id)
            class_name, spec_name = get_class_and_spec_name(config, class_id, spec_id)
            _log(f"检测到职业: {class_name or '-'} / 专精: {spec_name or '-'}")
            last_identity = identity
        else:
            _, spec_name = get_class_and_spec_name(config, class_id, spec_id)

        valid = bool(state_dict.get("有效性"))
        if valid != last_valid:
            _log("有效性: " + ("开启" if valid else "关闭"))
            last_valid = valid

        if not valid:
            status = "有效性为 0，暂停发键"
            if status != last_status:
                _log(status)
                last_status = status
            _sleep_remaining(loop_start, interval)
            continue

        logic_func = LOGIC_FUNCS_BY_CLASS.get(class_id, _default_logic)
        action_hotkey, current_step, unit_info = logic_func(state_dict, spec_name)

        extra_delay = 0.0
        if action_hotkey:
            send_key_to_wow(action_hotkey, window_title=window_title)
            if isinstance(unit_info, dict):
                extra_delay = float(unit_info.get("_delay", 0.0) or 0.0)
            if debug:
                _log(f"{current_step} -> {action_hotkey}")
        elif debug and current_step != last_status:
            _log(current_step)
            last_status = current_step

        _sleep_remaining(loop_start, interval, extra_delay)

def _sleep_remaining(start_time: float, interval: float, extra_delay: float = 0.0):
    if extra_delay > 0:
        time.sleep(extra_delay)
        return
    sleep_time = interval - (time.perf_counter() - start_time)
    if sleep_time > 0:
        time.sleep(sleep_time)

# =============================================================================
# GUI 模式相关代码
# =============================================================================

import customtkinter as ctk

GUI_UPDATE_MS = 200
_TOGGLE_DEBOUNCE_SEC = 0.12

_GUI_GEOMETRY_STATE = Path(__file__).resolve().parent / "gui_window_state.json"
_RE_TK_GEOMETRY = re.compile(r"^\d+x\d+([+-]\d+){2}$|^\d+x\d+$")

def _read_gui_state_dict() -> dict:
    try:
        if _GUI_GEOMETRY_STATE.is_file():
            data = json.loads(_GUI_GEOMETRY_STATE.read_text(encoding="utf-8"))
            if isinstance(data, dict):
                return data
    except Exception:
        pass
    return {}

def _write_gui_state_dict(data: dict) -> None:
    try:
        _GUI_GEOMETRY_STATE.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    except Exception:
        pass

def _load_main_window_geometry() -> str:
    g = _read_gui_state_dict().get("geometry")
    if isinstance(g, str) and _RE_TK_GEOMETRY.match(g.strip()):
        return g.strip()
    return DEFAULT_MAIN_GEOMETRY

def _load_subwindow_geometry(state_key: str, default: str) -> str:
    g = _read_gui_state_dict().get(state_key)
    if isinstance(g, str) and _RE_TK_GEOMETRY.match(g.strip()):
        return g.strip()
    return default

def _save_main_window_geometry(root: ctk.CTk) -> None:
    try:
        root.update_idletasks()
        g = root.geometry()
        if _RE_TK_GEOMETRY.match(g):
            data = _read_gui_state_dict()
            data["geometry"] = g
            _write_gui_state_dict(data)
    except Exception:
        pass

def _save_toplevel_geometry(win, state_key: str) -> None:
    try:
        win.update_idletasks()
        g = win.geometry()
        if _RE_TK_GEOMETRY.match(g):
            data = _read_gui_state_dict()
            data[state_key] = g
            _write_gui_state_dict(data)
    except Exception:
        pass

# GUI 状态
_gui_state_lock = threading.Lock()
_gui_logic_enabled = False
_gui_send_mode = "switch"
_gui_click_pending = False
_gui_state_dict = {}
_gui_class_name = None
_gui_class_id = None
_gui_spec_name = None
_gui_spec_id = None
_gui_current_step = ""
_gui_unit_info = {}
_gui_scan_ms = 0.0

# 鼠标钩子相关
_toggle_key_str = "XBUTTON2"
_toggle_vk = None
_binding_key_mode = False
_MOUSE_XBUTTON_VKS = {0x05, 0x06}
_xbutton_pressed = False
_xbutton_hook = None

WH_MOUSE_LL = 14
WM_XBUTTONDOWN = 0x020B
WM_XBUTTONUP = 0x020C
XBUTTON1_FLAG = 0x0001
XBUTTON2_FLAG = 0x0002
_toggle_lock = threading.Lock()
_mouse_hook_proc_ref = None

def _get_vk_for_gui(key_str):
    """从 utils 导入 get_vk"""
    from utils import get_vk
    return get_vk(key_str)

def _make_mouse_hook_proc():
    global _toggle_vk
    class MSLLHOOKSTRUCT(ctypes.Structure):
        _fields_ = [
            ("pt_x", ctypes.c_long), ("pt_y", ctypes.c_long), ("mouseData", ctypes.c_ulong),
            ("flags", ctypes.c_ulong), ("time", ctypes.c_ulong), ("dwExtraInfo", ctypes.POINTER(ctypes.c_ulong)),
        ]
    def _proc(nCode, wParam, lParam):
        global _xbutton_pressed
        if nCode >= 0 and wParam in (WM_XBUTTONDOWN, WM_XBUTTONUP):
            info = ctypes.cast(lParam, ctypes.POINTER(MSLLHOOKSTRUCT))[0]
            hi_word = (info.mouseData >> 16) & 0xFFFF
            vk_now = _toggle_vk
            if vk_now in _MOUSE_XBUTTON_VKS:
                want_xb2 = (vk_now == 0x06)
                is_xb2 = (hi_word == XBUTTON2_FLAG)
                if want_xb2 == is_xb2:
                    _xbutton_pressed = (wParam == WM_XBUTTONDOWN)
        return ctypes.windll.user32.CallNextHookEx(None, nCode, wParam, lParam)
    return ctypes.WINFUNCTYPE(ctypes.c_long, ctypes.c_int, ctypes.c_ulong, ctypes.POINTER(ctypes.c_ulong))(_proc)

def _install_mouse_hook():
    global _xbutton_hook, _mouse_hook_proc_ref
    if _xbutton_hook is not None:
        return
    _mouse_hook_proc_ref = _make_mouse_hook_proc()
    _xbutton_hook = ctypes.windll.user32.SetWindowsHookExW(WH_MOUSE_LL, _mouse_hook_proc_ref, None, 0)

def _start_mouse_hook_thread():
    def _hook_thread():
        _install_mouse_hook()
        msg = ctypes.wintypes.MSG()
        while True:
            ret = ctypes.windll.user32.GetMessageW(ctypes.byref(msg), None, 0, 0)
            if ret == 0 or ret == -1:
                break
            ctypes.windll.user32.TranslateMessage(ctypes.byref(msg))
            ctypes.windll.user32.DispatchMessageW(ctypes.byref(msg))
    t = threading.Thread(target=_hook_thread, daemon=True)
    t.start()

BG_DARK = "#1e1e1e"
BG_FRAME = "#2d2d2d"
FG_LIGHT = "#eaeaea"
GREEN = "#00d9a5"
RED = "#ff6b6b"
FG_DIM = "#94a3b8"
WINDOW_ALPHA = 1.0

CLASS_NAME_COLORS = {
    "战士": "#C79C6E", "圣骑士": "#F58CBA", "猎人": "#ABD473", "盗贼": "#FFF569",
    "潜行者": "#FFF569", "牧师": "#FFFFFF", "萨满": "#0070DE", "法师": "#69CCF0",
    "术士": "#9482C9", "武僧": "#00FF96", "德鲁伊": "#FF7D0A", "死亡骑士": "#C41F3B",
    "恶魔猎手": "#A330C9", "唤魔师": "#33937F",
}

def _disable_ime_for_hwnd(hwnd: int):
    try:
        imm32 = ctypes.windll.imm32
        hIMC = imm32.ImmGetContext(hwnd)
        if hIMC:
            imm32.ImmSetOpenStatus(hIMC, 0)
            imm32.ImmReleaseContext(hwnd, hIMC)
            return True
    except Exception:
        pass
    try:
        ctypes.windll.imm32.ImmDisableIME(0)
        return True
    except Exception:
        return False

def _run_gui_background_loop():
    """GUI 模式下的后台逻辑循环"""
    global _gui_logic_enabled, _gui_state_dict, _gui_class_name, _gui_class_id
    global _gui_spec_name, _gui_spec_id, _gui_current_step, _gui_unit_info, _gui_send_mode, _gui_click_pending, _gui_scan_ms

    from utils import get_vk
    prev_pressed = False
    prev_vk = _get_vk_for_gui(_toggle_key_str)
    last_logic_time = 0.0
    last_toggle_time = 0.0
    global _toggle_vk
    _toggle_vk = prev_vk

    while True:
        if _binding_key_mode:
            time.sleep(0.1)
            continue

        vk_now = _toggle_vk
        if vk_now is None:
            time.sleep(0.1)
            continue

        if vk_now != prev_vk:
            prev_pressed = False
            prev_vk = vk_now

        if vk_now in _MOUSE_XBUTTON_VKS:
            current_pressed = _xbutton_pressed
            rising_raw = current_pressed and not prev_pressed
        else:
            key_state = ctypes.windll.user32.GetAsyncKeyState(vk_now)
            current_pressed = (key_state & 0x8000) != 0
            rising_raw = (current_pressed and not prev_pressed) or ((key_state & 0x0001) != 0)
        now = time.time()
        rising = rising_raw and (now - last_toggle_time >= _TOGGLE_DEBOUNCE_SEC)
        if rising:
            last_toggle_time = now
        falling = (not current_pressed) and prev_pressed

        mode = _gui_send_mode
        if mode == "switch":
            if rising:
                with _gui_state_lock:
                    _gui_logic_enabled = not _gui_logic_enabled
                    _gui_click_pending = False
                _gui_current_step = "逻辑 " + ("开启" if _gui_logic_enabled else "关闭")
        elif mode == "click":
            if rising:
                with _gui_state_lock:
                    _gui_logic_enabled = True
                    _gui_click_pending = True
                _gui_current_step = "单击触发"
        elif mode == "hold":
            with _gui_state_lock:
                _gui_logic_enabled = current_pressed
                _gui_click_pending = False
            if falling:
                _gui_current_step = "按住结束"

        prev_pressed = current_pressed

        if now - last_logic_time >= 0.2:
            last_logic_time = now
            _t0 = time.perf_counter()
            state_dict = get_info()
            _gui_scan_ms = (time.perf_counter() - _t0) * 1000
            if state_dict:
                class_id = state_dict.get("职业")
                spec_id = state_dict.get("专精")
                config = load_config()
                class_name, spec_name = get_class_and_spec_name(config, class_id, spec_id)
                select_keymap_for_class(class_id)
                with _gui_state_lock:
                    _gui_state_dict = state_dict
                    _gui_class_name = class_name
                    _gui_class_id = class_id
                    _gui_spec_name = spec_name
                    _gui_spec_id = spec_id

        if not _gui_logic_enabled:
            time.sleep(0.1)
            continue

        sd = _gui_state_dict
        if not sd or not sd.get("有效性"):
            _gui_current_step = "等待游戏状态"
            time.sleep(0.1)
            continue

        class_id = _gui_class_id
        spec_name = _gui_spec_name
        action_hotkey = None
        _gui_current_step = "无操作"

        logic_func = LOGIC_FUNCS_BY_CLASS.get(class_id, _default_logic)
        action_hotkey, _gui_current_step, unit_info_update = logic_func(sd, spec_name)
        if unit_info_update:
            with _gui_state_lock:
                _gui_unit_info = unit_info_update

        delay_after_send = 0.0
        if mode == "click":
            with _gui_state_lock:
                pending = _gui_click_pending
            if pending:
                if action_hotkey:
                    send_key_to_wow(action_hotkey)
                    delay_after_send = unit_info_update.get("_delay", 0.0) if unit_info_update else 0.0
                with _gui_state_lock:
                    _gui_logic_enabled = False
                    _gui_click_pending = False
        else:
            if action_hotkey:
                send_key_to_wow(action_hotkey)
                delay_after_send = unit_info_update.get("_delay", 0.0) if unit_info_update else 0.0

        if delay_after_send > 0:
            time.sleep(delay_after_send)
        else:
            time.sleep(0.1)

def create_gui():
    """创建并运行 GUI 窗口"""
    global _toggle_vk
    _toggle_vk = _get_vk_for_gui(_toggle_key_str)

    _start_mouse_hook_thread()
    ctk.set_appearance_mode("dark")
    ctk.set_default_color_theme("dark-blue")

    root = ctk.CTk()
    try:
        hwnd = root.winfo_id()
        _disable_ime_for_hwnd(hwnd)
        root.after(200, lambda: _disable_ime_for_hwnd(root.winfo_id()))
    except Exception:
        pass
    root.title(title)
    root.geometry(_load_main_window_geometry())
    root.resizable(True, True)
    root.attributes("-topmost", True)
    root.configure(fg_color=BG_DARK)
    root.attributes("-alpha", WINDOW_ALPHA)

    main_frame = ctk.CTkFrame(root, fg_color="transparent")
    main_frame.pack(fill="both", expand=True, padx=12, pady=12)

    TOP_BAR_PADX = 14
    TOP_BAR_RIGHT_BTN_PADX = (0, 8)
    TOP_BAR_LEFT_INDENT = 14
    TOP_BAR_SIZE = 13

    top_frame = ctk.CTkFrame(main_frame, fg_color=BG_FRAME, corner_radius=8)
    top_frame.pack(fill="x", pady=(0, 6))

    inner_top = ctk.CTkFrame(top_frame, fg_color="transparent")
    inner_top.pack(fill="x", padx=TOP_BAR_PADX, pady=(10, 4))

    class_prefix_label = ctk.CTkLabel(inner_top, text="职业:", font=("Microsoft YaHei", TOP_BAR_SIZE, "bold"), text_color=FG_LIGHT)
    class_prefix_label.pack(side="left", padx=(TOP_BAR_LEFT_INDENT, 0))
    class_name_label = ctk.CTkLabel(inner_top, text="-", font=("Microsoft YaHei", TOP_BAR_SIZE, "bold"), text_color=FG_LIGHT)
    class_name_label.pack(side="left", padx=(6, 0))
    spec_label = ctk.CTkLabel(inner_top, text="专精: -", font=("Microsoft YaHei", TOP_BAR_SIZE, "bold"), text_color=FG_LIGHT)
    spec_label.pack(side="left", padx=(12, 0))

    status_label = ctk.CTkLabel(inner_top, text="状态: 关闭", font=("Microsoft YaHei", TOP_BAR_SIZE, "bold"), text_color=RED)
    status_label.pack(side="left", padx=(12, 0))

    toggle_row = ctk.CTkFrame(top_frame, fg_color="transparent")
    toggle_row.pack(fill="x", padx=TOP_BAR_PADX, pady=(0, 10))

    mode_btn_frame = ctk.CTkFrame(toggle_row, fg_color="transparent", border_width=0)
    mode_btn_frame.pack(side="right", padx=TOP_BAR_RIGHT_BTN_PADX)

    binding_in_progress = [False]

    def _display_key_str(key_str: str) -> str:
        return "SPACE" if key_str == " " else str(key_str)

    def _stop_binding():
        binding_in_progress[0] = False
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
        vk = _get_vk_for_gui(key_str)
        if vk is None:
            return False
        with _toggle_lock:
            _toggle_key_str = key_str
            _toggle_vk = vk
        return True

    def on_key_press(event):
        if not binding_in_progress[0]:
            return
        try:
            _disable_ime_for_hwnd(root.winfo_id())
        except Exception:
            pass
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
        if not binding_in_progress[0]:
            return
        try:
            _disable_ime_for_hwnd(root.winfo_id())
        except Exception:
            pass
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
        if binding_in_progress[0]:
            return
        binding_in_progress[0] = True
        global _binding_key_mode
        _binding_key_mode = True
        bind_btn.configure(state="disabled")
        bound_key_label.configure(text="已绑定:（请按下按键）")
        try:
            root.focus_force()
            _disable_ime_for_hwnd(root.winfo_id())
            root.after(100, lambda: _disable_ime_for_hwnd(root.winfo_id()))
        except Exception:
            pass
        root.bind("<KeyPress>", on_key_press)
        root.bind("<ButtonPress>", on_button_press)

    def set_send_mode(mode: str):
        global _gui_send_mode, _gui_logic_enabled, _gui_click_pending
        with _gui_state_lock:
            _gui_send_mode = mode
            _gui_click_pending = False
            _gui_logic_enabled = False
        update_mode_buttons()

    def update_mode_buttons():
        active = _gui_send_mode
        switch_btn.configure(text_color=GREEN if active == "switch" else FG_LIGHT)
        click_btn.configure(text_color=GREEN if active == "click" else FG_LIGHT)
        hold_btn.configure(text_color=GREEN if active == "hold" else FG_LIGHT)

    switch_btn = ctk.CTkButton(mode_btn_frame, text="开关", command=lambda: set_send_mode("switch"),
                              font=("Microsoft YaHei", 12), width=50, fg_color=BG_DARK,
                              text_color=GREEN if _gui_send_mode == "switch" else FG_LIGHT, hover_color="#3d3d3d", corner_radius=8)
    switch_btn.pack(side="left", padx=(0, 2))

    click_btn = ctk.CTkButton(mode_btn_frame, text="单击", command=lambda: set_send_mode("click"),
                             font=("Microsoft YaHei", 12), width=50, fg_color=BG_DARK,
                             text_color=GREEN if _gui_send_mode == "click" else FG_LIGHT, hover_color="#3d3d3d", corner_radius=8)
    click_btn.pack(side="left", padx=(2, 2))

    hold_btn = ctk.CTkButton(mode_btn_frame, text="按住", command=lambda: set_send_mode("hold"),
                            font=("Microsoft YaHei", 12), width=50, fg_color=BG_DARK,
                            text_color=GREEN if _gui_send_mode == "hold" else FG_LIGHT, hover_color="#3d3d3d", corner_radius=8)
    hold_btn.pack(side="left", padx=(2, 0))

    bind_btn = ctk.CTkButton(toggle_row, text="按键", command=start_binding_key,
                            font=("Microsoft YaHei", 12), fg_color=BG_DARK,
                            text_color=FG_LIGHT, hover_color="#3d3d3d", corner_radius=8, width=50)
    bind_btn.pack(side="left", padx=(10, 8))

    bound_key_label = ctk.CTkLabel(toggle_row, text=f"已绑定: {_display_key_str(_toggle_key_str)}",
                                  font=("Microsoft YaHei", 12), text_color=FG_DIM)
    bound_key_label.pack(side="left", padx=(0, 8))

    def update_display():
        with _gui_state_lock:
            enabled = _gui_logic_enabled
            mode = _gui_send_mode
            class_name = _gui_class_name
            spec = _gui_spec_name

        class_name_label.configure(text=class_name or "-", text_color=CLASS_NAME_COLORS.get(class_name, FG_LIGHT))
        spec_label.configure(text=f"专精: {spec or '-'}")

        if mode == "click":
            status_label.configure(text="状态: 单击", text_color=GREEN)
        else:
            status_label.configure(text=f"状态: {'开启' if enabled else '关闭'}", text_color=GREEN if enabled else RED)

        root.after(GUI_UPDATE_MS, update_display)

    root.after(0, update_display)

    worker = threading.Thread(target=_run_gui_background_loop, daemon=True)
    worker.start()

    def on_main_window_close():
        _save_main_window_geometry(root)
        root.destroy()

    root.protocol("WM_DELETE_WINDOW", on_main_window_close)
    root.mainloop()

# =============================================================================
# 主入口
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description="Fuyutsui - Unify GUI and headless runtime")
    parser.add_argument("--headless", action="store_true", help="Run without GUI")
    parser.add_argument("--window-title", default=DEFAULT_WINDOW_TITLE, help="Window title for pixel capture")
    parser.add_argument("--interval", type=float, default=DEFAULT_INTERVAL, help="Scan interval in seconds")
    parser.add_argument("--debug", action="store_true", help="Enable debug logging")
    args = parser.parse_args()

    if args.headless:
        try:
            run_headless(args.window_title, max(0.01, args.interval), args.debug)
        except KeyboardInterrupt:
            _log("Fuyutsui headless runtime stopped.")
        except Exception as exc:
            _log(f"Fuyutsui headless runtime crashed: {exc!r}")
            raise
    else:
        create_gui()

if __name__ == "__main__":
    main()