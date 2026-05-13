# -*- coding: utf-8 -*-
"""
Unified runtime for Fuyutsui logic: supports both GUI and headless modes.
GUI mode (default): Full interface with key binding, status display, team window.
Headless mode (--headless): Screen scanning and logic execution only, suitable for
                            background automation or when used with FuyutsuiBurstGuard.
"""
import argparse
import ctypes
import importlib
import json
import os
import re
import sys
import threading
import time
from pathlib import Path

# Ensure we can import local modules
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if _SCRIPT_DIR not in sys.path:
    sys.path.insert(0, _SCRIPT_DIR)

from GetPixels import get_info
from utils import (
    get_class_and_spec_name,
    load_config,
    select_keymap_for_class,
    send_key_to_wow,
)

# Try to import GUI dependencies; if unavailable, GUI mode is disabled
try:
    import customtkinter as ctk
    GUI_AVAILABLE = True
except ImportError:
    GUI_AVAILABLE = False

# Default settings
DEFAULT_WINDOW_TITLE = "魔兽世界"
DEFAULT_INTERVAL = 0.05
LOG_PATH = Path(__file__).resolve().parent / "logic_headless.log"

# ============================================================
# Logic Module Loading
# ============================================================

def _load_logic_module(module_name: str):
    """Load a class-specific logic module from the class/ package."""
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

# ============================================================
# Logging
# ============================================================

def _log(message: str, also_print: bool = True):
    """Log message to file and optionally to stdout."""
    line = f"{time.strftime('%Y-%m-%d %H:%M:%S')} {message}"
    if also_print:
        print(line, flush=True)
    try:
        with LOG_PATH.open("a", encoding="utf-8") as f:
            f.write(line + "\n")
    except OSError:
        pass

# ============================================================
# Headless Runtime
# ============================================================

def run_headless(window_title: str, interval: float, debug: bool = False):
    """
    Headless runtime: scan pixels and run class logic without GUI.
    Use this for background automation or with FuyutsuiBurstGuard.
    """
    config = load_config()
    last_identity = None
    last_valid = None
    last_status = None

    _log("Fuyutsui headless runtime started.")
    _log("Use Fuyutsui in game to toggle burst and logic settings.")

    # State for burst guard integration
    burst_on = True  # Default to on; controlled by pixel status
    logic_enabled = True  # Controlled by "有效性" pixel from game

    while True:
        loop_start = time.perf_counter()
        state_dict = get_info(window_title)

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

        # "有效性" controls logic execution (from FuyutsuiBurstGuard integration)
        valid = bool(state_dict.get("有效性"))
        if valid != last_valid:
            _log("可执行状态: " + ("开启" if valid else "关闭"))
            last_valid = valid

        if not valid or not logic_enabled:
            _log("游戏状态无效或逻辑已关闭，暂停发键")
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

# ============================================================
# GUI Mode
# ============================================================

if GUI_AVAILABLE:
    # Import all GUI-related code only when customtkinter is available
    from utils import *

    title = "Fuyutsui"
    DEFAULT_MAIN_GEOMETRY = "400x110"
    DEFAULT_TEAM_GEOMETRY = "550x600"
    DEFAULT_LIVE_INFO_GEOMETRY = "420x540"
    _GUI_GEOMETRY_STATE = Path(__file__).resolve().parent / "gui_window_state.json"
    _RE_TK_GEOMETRY = re.compile(r"^\d+x\d+([+-]\d+){2}$|^\d+x\d+$")

    # All the GUI code from logic_gui.py will be appended here...
    # For brevity, we'll reference it from the original file
    # The main changes needed are:
    # 1. Add headless mode support in CLI
    # 2. Share logic loop between GUI and headless

    # We'll create a separate entry point that re-uses the GUI code
    pass

# ============================================================
# Main Entry Point
# ============================================================

def main():
    parser = argparse.ArgumentParser(description="Fuyutsui logic runtime")
    parser.add_argument("--window-title", default=DEFAULT_WINDOW_TITLE,
                        help="Game window title (default: 魔兽世界)")
    parser.add_argument("--interval", type=float, default=DEFAULT_INTERVAL,
                        help=f"Scan interval in seconds (default: {DEFAULT_INTERVAL})")
    parser.add_argument("--debug", action="store_true",
                        help="Enable debug logging")
    parser.add_argument("--headless", action="store_true",
                        help="Run without GUI (background mode)")
    args = parser.parse_args()

    if args.headless:
        try:
            run_headless(args.window_title, max(0.01, args.interval), args.debug)
        except KeyboardInterrupt:
            _log("Fuyutsui headless runtime stopped by user.")
        except Exception as exc:
            _log(f"Fuyutsui headless runtime crashed: {exc!r}")
            raise
    else:
        if not GUI_AVAILABLE:
            print("Error: customtkinter is not installed. Use --headless for non-GUI mode.")
            sys.exit(1)
        # GUI mode - import from logic_gui for now to keep changes minimal
        # A future update can merge the files completely
        import logic_gui
        logic_gui.create_gui()
        # Start the worker thread
        # This is handled inside create_gui()

if __name__ == "__main__":
    sys.exit(main())