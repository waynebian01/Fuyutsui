# -*- coding: utf-8 -*-
"""
无 GUI 版本：
- 保留与 logic_gui.py 一致的核心逻辑循环
- 不创建窗口，只在控制台输出状态
"""
import ctypes
import ctypes.wintypes
import importlib
import threading
import time

from GetPixels import get_info
from utils import *

TOGGLE_INTERVAL = 0.1
LOGIC_INTERVAL = 0.2
PRINT_INTERVAL = 1.0
TOGGLE_DEBOUNCE_SEC = 0.12


def _load_logic_module(module_name: str):
    m = importlib.import_module(f"class.{module_name}")
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

_MOUSE_XBUTTON_VKS = {0x05, 0x06}
_xbutton_pressed = False
_xbutton_hook = None
_mouse_hook_proc_ref = None

WH_MOUSE_LL = 14
WM_XBUTTONDOWN = 0x020B
WM_XBUTTONUP = 0x020C
XBUTTON2_FLAG = 0x0002

_LowLevelMouseProc = ctypes.WINFUNCTYPE(
    ctypes.c_long, ctypes.c_int, ctypes.c_ulong, ctypes.POINTER(ctypes.c_ulong)
)

_state_lock = threading.Lock()
_logic_enabled = False
_send_mode = "switch"  # switch / click / hold
_click_pending = False
_current_step = ""
_scan_ms = 0.0
_class_name = None
_spec_name = None

_CONFIG_CACHE = None


def _get_config_cached():
    global _CONFIG_CACHE
    if _CONFIG_CACHE is None:
        _CONFIG_CACHE = load_config()
    return _CONFIG_CACHE


def _make_mouse_hook_proc():
    class MSLLHOOKSTRUCT(ctypes.Structure):
        _fields_ = [
            ("pt_x", ctypes.c_long),
            ("pt_y", ctypes.c_long),
            ("mouseData", ctypes.c_ulong),
            ("flags", ctypes.c_ulong),
            ("time", ctypes.c_ulong),
            ("dwExtraInfo", ctypes.POINTER(ctypes.c_ulong)),
        ]

    def _proc(nCode, wParam, lParam):
        global _xbutton_pressed
        if nCode >= 0 and wParam in (WM_XBUTTONDOWN, WM_XBUTTONUP):
            info = ctypes.cast(lParam, ctypes.POINTER(MSLLHOOKSTRUCT))[0]
            hi_word = (info.mouseData >> 16) & 0xFFFF
            vk_now = _toggle_vk
            if vk_now in _MOUSE_XBUTTON_VKS:
                is_xb2 = hi_word == XBUTTON2_FLAG
                want_xb2 = vk_now == 0x06
                if is_xb2 == want_xb2:
                    _xbutton_pressed = wParam == WM_XBUTTONDOWN
        return ctypes.windll.user32.CallNextHookEx(None, nCode, wParam, lParam)

    return _LowLevelMouseProc(_proc)


def _install_mouse_hook():
    global _xbutton_hook, _mouse_hook_proc_ref
    if _xbutton_hook is not None:
        return
    _mouse_hook_proc_ref = _make_mouse_hook_proc()
    _xbutton_hook = ctypes.windll.user32.SetWindowsHookExW(
        WH_MOUSE_LL, _mouse_hook_proc_ref, None, 0
    )


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


def _print_status():
    with _state_lock:
        enabled = _logic_enabled
        mode = _send_mode
        class_name = _class_name
        spec_name = _spec_name
        step = _current_step
        scan_ms = _scan_ms
    status = "开启" if enabled else "关闭"
    print(f"[状态] {status} | 模式:{mode} | 职业:{class_name or '-'} | 专精:{spec_name or '-'} | 步骤:{step or '-'} | 扫描:{scan_ms:.1f}ms")


def run_logic_nogui():
    global _logic_enabled, _click_pending, _current_step, _scan_ms, _class_name, _spec_name
    prev_pressed = False
    prev_vk = _toggle_vk
    last_logic_time = 0.0
    last_toggle_time = 0.0
    last_print_time = 0.0
    state_dict_cache = {}
    class_id_cache = None
    spec_name_cache = None

    _start_mouse_hook_thread()
    print("[启动] 无GUI模式已运行，默认切换键: XBUTTON2，发送模式: switch")

    while True:
        vk_now = _toggle_vk
        if vk_now is None:
            time.sleep(TOGGLE_INTERVAL)
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
        rising = rising_raw and (now - last_toggle_time >= TOGGLE_DEBOUNCE_SEC)
        if rising:
            last_toggle_time = now
        falling = (not current_pressed) and prev_pressed

        mode = _send_mode
        if mode == "switch":
            if rising:
                with _state_lock:
                    _logic_enabled = not _logic_enabled
                    _click_pending = False
                    _current_step = "逻辑 " + ("开启" if _logic_enabled else "关闭")
        elif mode == "click":
            if rising:
                with _state_lock:
                    _logic_enabled = True
                    _click_pending = True
                    _current_step = "单击触发"
        elif mode == "hold":
            with _state_lock:
                _logic_enabled = current_pressed
                _click_pending = False
                if falling:
                    _current_step = "按住结束"

        prev_pressed = current_pressed

        if now - last_logic_time >= LOGIC_INTERVAL:
            last_logic_time = now
            t0 = time.perf_counter()
            state_dict = get_info()
            _scan_ms = (time.perf_counter() - t0) * 1000
            class_name = None
            spec_name = None
            class_id = None
            if state_dict:
                class_id = state_dict.get("职业")
                spec_id = state_dict.get("专精")
                config = _get_config_cached()
                class_name, spec_name = get_class_and_spec_name(config, class_id, spec_id)
                select_keymap_for_class(class_id)
            with _state_lock:
                _class_name = class_name
                _spec_name = spec_name
            state_dict_cache = state_dict or {}
            class_id_cache = class_id
            spec_name_cache = spec_name

        if now - last_print_time >= PRINT_INTERVAL:
            last_print_time = now
            _print_status()

        if not _logic_enabled:
            time.sleep(TOGGLE_INTERVAL)
            continue

        if not state_dict_cache or not state_dict_cache.get("有效性"):
            with _state_lock:
                _current_step = "等待游戏状态"
            time.sleep(TOGGLE_INTERVAL)
            continue

        logic_func = LOGIC_FUNCS_BY_CLASS.get(class_id_cache, _default_logic)
        action_hotkey, step, unit_info_update = logic_func(state_dict_cache, spec_name_cache)
        with _state_lock:
            _current_step = step or "无操作"

        delay_after_send = 0.0
        if mode == "click":
            with _state_lock:
                pending = _click_pending
            if pending:
                if action_hotkey:
                    send_key_to_wow(action_hotkey)
                    delay_after_send = unit_info_update.get("_delay", 0.0) if unit_info_update else 0.0
                with _state_lock:
                    _logic_enabled = False
                    _click_pending = False
        else:
            if action_hotkey:
                send_key_to_wow(action_hotkey)
                delay_after_send = unit_info_update.get("_delay", 0.0) if unit_info_update else 0.0

        if delay_after_send > 0:
            time.sleep(delay_after_send)
        else:
            time.sleep(TOGGLE_INTERVAL)


if __name__ == "__main__":
    run_logic_nogui()
