# 安装 Fuyutsui

此文档介绍如何安装 Fuyutsui 项目。

## 先决条件

- Python 3.12.10
- Git
- 定位《魔兽世界》正式服客户端

### Python 3.12.10

- 检测：如果`python -V`提示已安装3.12以上版本，本环节跳过。
- 下载：`https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe`
- 安装：`python-3.12.10-amd64.exe /passive InstallAllUsers=0 PrependPath=1`

### Git

- 检测：如果`git --version`提示已安装任意版本，本环节跳过。
- 下载`https://github.com/git-for-windows/git/releases/download/v2.53.0.windows.2/Git-2.53.0.2-64-bit.exe`
- 安装 `Git-2.53.0.2-64-bit.exe /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"`

### 定位《魔兽世界》正式服客户端

- 检查注册表`HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Blizzard Entertainment\World of Warcraft` KEY为 InstallPath
- 路径应该是 `X:\Path_to_WOW\_retail_\`
- 后文以`{wow_retail_path}`指代`X:\Path_to_WOW\_retail_\`

### 克隆 Fuyutsui repo 到addons目录

- AddOns目录是 `{wow_retail_path}\Interface\AddOns`
- 若`{wow_retail_path}\Interface\AddOns\Fuyutsui`存在则删除。
- 执行`git clone https://github.com/waynebian01/Fuyutsui.git {wow_retail_path}\Interface\AddOns\Fuyutsui`

### 安装Python组件的依赖

- `{wow_retail_path}\Interface\AddOns\Fuyutsui\Fuyutsui`，注意，这相当于repo的`Fuyutsui`子目录
- 执行`py -m pip install -r requirements.txt`安装依赖到系统级python。
- 验证，执行`py -m compileall .\logic_gui.py`、
- 验证，执行`python -c "import customtkinter, yaml, mss; print('ok')"`

## 程序执行

- 再Fuyutsui子目录执行`logic.cmd`，可以执行程序。

## 升级

- 通过git更新Fuyutsui repo
