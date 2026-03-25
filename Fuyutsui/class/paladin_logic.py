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
LOGIC_INTERVAL = 0.2
GUI_UPDATE_MS = 150

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


toggle_key_str = "XBUTTON2"
vk_toggle = get_vk(toggle_key_str)

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
    """
    spec_cfg = _get_class_spec_cfg(class_id, spec_id)
    if not isinstance(spec_cfg, dict) or not spec_cfg:
        return list(_DEFAULT_STATUS_KEYS), (0, []), []

    extra_keys = [k for k in spec_cfg.keys() if k not in ("spells", "group", "keymap")]
    status_keys = list(_DEFAULT_STATUS_KEYS) + [k for k in extra_keys if k not in _DEFAULT_STATUS_KEYS]

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
    global _logic_enabled, _state_dict, _class_name, _class_id, _spec_name, _spec_id, _current_step, _unit_info
    prev_pressed = False
    last_logic_time = 0.0

    while True:
        current_pressed = (ctypes.windll.user32.GetAsyncKeyState(vk_toggle) & 0x8000) != 0
        if current_pressed and not prev_pressed:
            with _state_lock:
                _logic_enabled = not _logic_enabled
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


def create_gui():
    ctk.set_appearance_mode("dark")
    ctk.set_default_color_theme("dark-blue")

    root = ctk.CTk()
    root.title("冬月")
    root.geometry("400x600")
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
    inner_top.pack(fill="x", padx=12, pady=10)

    class_label = ctk.CTkLabel(inner_top, text="职业: -", font=("Microsoft YaHei", 14, "bold"), text_color=FG_LIGHT)
    class_label.pack(side="left", padx=(12, 0))
    spec_label = ctk.CTkLabel(inner_top, text="专精: -", font=("Microsoft YaHei", 14, "bold"), text_color=FG_LIGHT)
    spec_label.pack(side="left", padx=(12, 0))

    toggle_var = ctk.BooleanVar(value=False)

    def on_toggle():
        with _state_lock:
            global _logic_enabled
            _logic_enabled = toggle_var.get()
        status_label.configure(text=f"状态: {'开启' if _logic_enabled else '关闭'}",
                              text_color=GREEN if _logic_enabled else RED)

    ctk.CTkCheckBox(
        inner_top,
        text="逻辑开启",
        variable=toggle_var,
        command=on_toggle,
        font=("Microsoft YaHei", 12),
        text_color=FG_LIGHT,
        fg_color=BG_DARK,
    ).pack(side="right")

    def sync_toggle_from_logic():
        with _state_lock:
            v = _logic_enabled
        if toggle_var.get() != v:
            toggle_var.set(v)
            status_label.configure(text=f"状态: {'开启' if v else '关闭'}",
                                  text_color=GREEN if v else RED)

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
    ctk.CTkButton(
        inner_top,
        text="显示队伍",
        command=open_team_window,
        font=("Microsoft YaHei", 12),
        fg_color=BG_FRAME,
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
    status_label = ctk.CTkLabel(status_header, text="状态: 关闭", font=("Microsoft YaHei", 12), text_color=RED)
    status_label.pack(side="right")

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
        sync_toggle_from_logic()
        with _state_lock:
            sd = dict(_state_dict)
            enabled = _logic_enabled
            class_name = _class_name
            spec = _spec_name
            class_id = _class_id
            spec_id = _spec_id

        class_label.configure(text=f"职业: {class_name or '-'}")
        spec_label.configure(text=f"专精: {spec or '-'}")
        if spec is None:
            if content_frame.winfo_ismapped():
                content_frame.pack_forget()
            root.after(GUI_UPDATE_MS, update_display)
            return
        if not content_frame.winfo_ismapped():
            content_frame.pack(fill="both", expand=True, pady=(0, 6))

        status_label.configure(text=f"状态: {'开启' if enabled else '关闭'}",
                              text_color=GREEN if enabled else RED)

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
