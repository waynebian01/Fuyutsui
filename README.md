# Fuyutsui（“冬月修补匠3型”）
Fuyutsui Tinkerer是由日本大众消费电子巨头 冬月电子（Fuyutsuki Electronics） 研发的一块网络接入仓（Cyberdeck），能显著提升你玩《魔兽世界》的快感。
---
## 它支持谁?
- **版本**: 听说它只支持_Relic_
   ### 职业与专精支持
   #### 天赋
   脚本使用的天赋均来自于[WOWHEAD](https://www.wowhead.com/guides/classes)推荐的天赋
   #### 图标含义:

   ✅: 手写逻辑

   🔄: 官方一键辅助

   ❌: 不支持

   | 职业 | 专精 |专精  |专精  |专精  |
   | --- | --- | --- | --- | --- |
   | 战士 | 武器 🔄 | 狂怒 🔄 | 防护 ✅🔄 |  |
   | 圣骑士 | 神圣 ✅ | 防护✅🔄 | 惩戒 🔄 |  | : 
   | 猎人 | 野兽 🔄 | 射击 🔄 | 生存 🔄 |  |
   | 盗贼 | 奇袭 ❌ | 狂徒 ❌ | 敏锐 ❌ |  |
   | 牧师 | 戒律 ✅ | 神圣 ✅ | 暗影 ✅🔄 |  |
   | 死亡骑士 | 鲜血 🔄 | 冰霜 🔄 | 邪恶 🔄✅ |  |
   | 萨满 | 元素 🔄 | 增强 🔄 | 恢复 ✅ |  |
   | 法师 | 奥术 ❌ | 火焰 ❌ | 冰霜 ✅🔄 |  |
   | 术士 | 痛苦 ❌ | 恶魔 ✅🔄 | 毁灭 ❌ |  |
   | 武僧 | 酒仙 ✅🔄 | 织雾 ✅ | 踏风 ✅🔄 |  |
   | 德鲁伊 | 平衡 ❌ | 野性 ❌ | 守护 ✅🔄 | 恢复 ✅ |
   | 恶魔猎手 | 浩劫 🔄 | 复仇 🔄 | 噬灭 🔄 |  |
   | 唤魔师 | 湮灭 ❌ | 恩护 ❌ | 增辉 ❌ |  |


- **感觉支持的职业非常少**

## 它到底做了什么？

- **Lua（游戏内）**：在屏幕顶部生成一条“色块/色条”数据。
- **Python（桌面端）**：扫描这条色条，从每个像素值获取队伍成员、光环、技能冷却等。
- **策略决策（职业逻辑）**：根据当前职业专精加载对应的逻辑模块里判断“下一步该干谁”。

结果就是：它不是一个顶尖科技,研发初衷是“易用性低”与“稳定性差”。这让它看起来不像军用设备那样充满杀气，反而更像是一台经过久经风霜的废土工作站。

---

## 如何启动
下面按“游戏内 Lua 插件 + 桌面端 Python”两部分说明。该项目面向 Windows（会调用屏幕截图与 Windows API）。

### 1. 文件放在哪里
**Lua 插件（WoW AddOn）**：把仓库里的 `Fuyutsui` 这个文件夹整体复制到魔兽世界安装目录的 `Interface/AddOns/` 下面。

### 2. 安装 VS Code
1. 安装 VS Code（任意版本即可）。
2. 打开 VS Code 后：`文件 -> 打开文件夹`，选择项目根目录, 也就是`Interface/AddOns/Fuyutsui`。

### 3. 安装 Python（Windows）

桌面端脚本依赖 **Python 3**，且会调用 Windows API，请在 **Windows** 上安装。

#### 3.1 从哪里装

1. 打开 [Python 官方下载页](https://www.python.org/downloads/windows/)，下载 **Windows installer (64-bit)**。
2. 版本建议 **3.10 或更高**（与 `customtkinter`、类型提示等兼容性更好；3.9 多数情况也能用，若遇库不兼容再升级）。

#### 3.2 安装向导里务必勾选的选项

- **Add python.exe to PATH**（或 “将 Python 添加到 PATH”）：不勾的话，终端里经常提示找不到 `python` / `pip`。
- 若出现 **Install launcher for all users**，可保留默认；装好后可用 `py -3` 启动指定版本。

#### 3.3 装好后自检

在 **PowerShell** 或 **命令提示符**（或 VS Code 终端）中执行：

```text
python --version
```

若提示找不到命令，可再试：

```text
py -3 --version
```

能打印出 `Python 3.x.x` 即表示安装成功。建议顺便升级 pip（减少装包失败）：

```text
python -m pip install --upgrade pip
```

> **说明**：`python -m pip` 比单独敲 `pip` 更稳——永远对应当前这个 Python，避免“装了包却给另一个 Python 装”的混乱。

#### 3.4 （可选）用虚拟环境隔离依赖

若你本机还有别的 Python 项目，建议在插件的 Python 子目录里建虚拟环境：

```text
cd "你的路径\Interface\AddOns\Fuyutsui\Fuyutsui"
python -m venv .venv
.\.venv\Scripts\activate
```

激活后提示符前会出现 `(.venv)`，此时再执行下面的 `pip install` 只会装到这个环境里。  
VS Code 里可在命令面板选择 **Python: Select Interpreter**，选带 `.venv` 的那一项。

### 4. 安装 Python 依赖

依赖列表在 **`Fuyutsui/Fuyutsui/requirements.txt`**（含 `customtkinter`、`PyYAML`、`mss` 等）。**必须在包含 `logic_gui.py` 的目录下安装并运行**，否则相对路径下的 `config.yml` 等会找不到。

1. 打开终端，进入 Python 工程目录：

   ```text
   cd "你的路径\Interface\AddOns\Fuyutsui\Fuyutsui"
   ```

2. 若使用了虚拟环境，先执行 `.\.venv\Scripts\activate`。

3. 一键安装依赖：

   ```text
   python -m pip install -r requirements.txt
   ```

4. 验证关键包是否就绪（可选）：

   ```text
   python -c "import customtkinter, yaml, mss; print('ok')"
   ```

若报错，把**完整终端输出**复制给 AI 或查阅报错中的包名，通常是网络、代理或 Python 版本过旧导致。

### 5. 运行与日常使用

#### 5.1 与游戏配合

1. 启动魔兽世界，在角色选择界面或游戏中于插件列表启用 **`Fuyutsui`**。
2. 桌面端通过窗口标题查找游戏窗口，默认标题为 **`魔兽世界`**（与国服客户端一致；若你使用其他语言客户端，需改 `GetPixels.py` / `utils.py` 里传入的 `window_title` 或相关默认值，否则截不到正确区域）。

#### 5.2 启动桌面 GUI

在 **`Interface/AddOns/Fuyutsui/Fuyutsui`** 目录下执行（与第 4 步 `cd` 目录相同）：

```text
python logic_gui.py
```

不要从仓库根目录 `.../AddOns/Fuyutsui` 直接运行，除非你自己改好了工作目录与配置文件路径。

#### 5.3 GUI 与热键

- 按 **`XBUTTON2`**（鼠标侧键 2，具体以鼠标驱动为准）可切换 **逻辑开启 / 关闭**。
- 其他行为以 GUI 内说明与 `config.yml`、`keymap.yml` 为准。

#### 5.4 常见问题速查

| 现象 | 可能原因与处理 |
| --- | --- |
| `'python' 不是内部或外部命令` | 未加入 PATH 或需用 `py -3`；或重装 Python 并勾选 Add to PATH。 |
| `No module named 'xxx'` | 在 `Fuyutsui\Fuyutsui` 下重新执行 `python -m pip install -r requirements.txt`；确认 VS Code 选中的解释器与终端一致。 |
| 找不到游戏窗口 / 截图为空 | 检查窗口标题是否为 `魔兽世界`；游戏需在前台或未被最小化到仅任务栏（以实际 Windows 行为为准）。 |
| 权限或杀毒拦截 | 将项目目录或 Python 加入白名单，或以管理员身份仅作最后手段测试（一般不需要）。 |

## 免责声明

本项目偏“个人工具/实验性质”，通过读取游戏画面像素并触发热键来实现辅助决策。
请你自行判断是否符合你的需求，别让它被荒坂发现。

[icon]: https://wow.zamimg.com/images/wow/icons/large/ui_spellbook_onebutton.jpg
