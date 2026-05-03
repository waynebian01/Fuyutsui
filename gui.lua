local addonName, fu = ...
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local tinsert, sort = table.insert, table.sort

--- 将 fu.blocks 格式化为只读文本（用于「色块映射」页）
local function BuildBlocksSummary()
    if not fu.blocks then
        return "当前没有 fu.blocks。\n通常在载入对应职业与专精模块后才会有映射表。"
    end
    local keys = {}
    for k in pairs(fu.blocks) do
        if k ~= "auras" then
            tinsert(keys, k)
        end
    end
    sort(keys)
    local lines = {}
    for _, k in ipairs(keys) do
        local v = fu.blocks[k]
        if type(v) == "number" then
            tinsert(lines, ("[%s]  →  顶部色条索引 %d"):format(k, v))
        else
            tinsert(lines, ("[%s]  →  %s"):format(k, tostring(v)))
        end
    end
    if fu.blocks.auras and next(fu.blocks.auras) then
        tinsert(lines, "")
        tinsert(lines, "—— auras ——")
        local an = {}
        for n in pairs(fu.blocks.auras) do
            tinsert(an, n)
        end
        sort(an)
        for _, n in ipairs(an) do
            local a = fu.blocks.auras[n]
            if type(a) == "table" then
                tinsert(lines, ("  %s  index=%s  showKey=%s"):format(
                    n, tostring(a.index), tostring(a.showKey)))
            else
                tinsert(lines, ("  %s  →  %s"):format(n, tostring(a)))
            end
        end
    end
    if fu.group_blocks and next(fu.group_blocks) then
        tinsert(lines, "")
        tinsert(lines, "—— fu.group_blocks（简要）——")
        for k, v in pairs(fu.group_blocks) do
            tinsert(lines, ("  %s  →  %s"):format(k, type(v) == "table" and "表" or tostring(v)))
        end
    end
    if #lines == 0 then
        return "fu.blocks 存在但无可用字段。"
    end
    return table.concat(lines, "\n")
end

--- 与 core.lua 中 slash 逻辑一致：改 SavedVariables 后同步顶部像素
local function SyncBlockFromDB()
    if not fu.blocks then return end
    if fu.blocks["爆发开关"] then
        fu.updateOrCreatTextureByIndex(fu.blocks["爆发开关"], FuyutsuiDB.cooldowns / 255)
    end
    if fu.blocks["AOE开关"] then
        fu.updateOrCreatTextureByIndex(fu.blocks["AOE开关"], FuyutsuiDB.aoeMode / 255)
    end
    if fu.blocks["输出模式"] then
        fu.updateOrCreatTextureByIndex(fu.blocks["输出模式"], FuyutsuiDB.dpsMode / 255)
    end
end

local function GetVersion()
    return C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version")
        or GetAddOnMetadata(addonName, "Version")
        or "?"
end

--- AceConfig options 表：根节点 childGroups = "tab" 时，子 group 显示为标签页
local options = {
    type = "group",
    name = "Fuyutsui",
    childGroups = "tab",
    args = {
        -- ========== 标签 1：关于 ==========
        about = {
            type = "group",
            name = "关于",
            order = 1,
            args = {
                intro = {
                    type = "description",
                    order = 1,
                    fontSize = "medium",
                    name = function()
                        local ver = GetVersion()
                        local cls = fu.className or "?"
                        local cid = fu.classId and tostring(fu.classId) or "?"
                        local spec = fu.specIndex and tostring(fu.specIndex) or "?"
                        return ([[
|cff00ccff%s|r

版本：|cffffffff%s|r
作者：|cffffffff%s|r

当前职业：|cffffffff%s|r（ID %s）
专精索引：|cffffffff%s|r（与游戏专精槽位一致）

将战斗与状态信息编码为屏幕顶部色条显示。详细命令见 |cffffffff/fu help|r。
]]):format(addonName, ver,
                            C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Author")
                            or GetAddOnMetadata(addonName, "Author") or "Wayne Bian",
                            cls, cid, spec)
                    end,
                },
            },
        },
        -- ========== 标签 2：fu.blocks 信息 ==========
        blocks = {
            type = "group",
            name = "fu.blocks",
            order = 2,
            args = {
                hint = {
                    type = "description",
                    order = 0,
                    name = "以下为当前专精下 |cfffffffffu.blocks|r 的键与顶部色条索引对应关系（只读）。切换专精后请重新打开本页刷新。",
                },
                dump = {
                    type = "input",
                    order = 1,
                    name = "映射表",
                    width = "full",
                    multiline = 25,
                    get = function()
                        return BuildBlocksSummary()
                    end,
                    set = function() end,
                },
            },
        },
        -- ========== 标签 3：配置 ==========
        settings = {
            type = "group",
            name = "配置",
            order = 3,
            args = {
                note = {
                    type = "description",
                    order = 0,
                    name = "以下选项保存在 |cffffffffFuyutsuiDB|r（角色存档），与 |cffffffff/fu cd|r、|cffffffff/fu aoemode|r、|cffffffff/fu dpsmode|r 一致。",
                },
                cooldowns = {
                    type = "toggle",
                    order = 10,
                    name = "爆发（大技能）",
                    desc = "开启时允许按逻辑使用爆发；关闭时对应像素会反映为关。",
                    width = "full",
                    get = function()
                        FuyutsuiDB = FuyutsuiDB or {}
                        return (FuyutsuiDB.cooldowns or 0) == 1
                    end,
                    set = function(_, val)
                        FuyutsuiDB = FuyutsuiDB or {}
                        FuyutsuiDB.cooldowns = val and 1 or 0
                        SyncBlockFromDB()
                    end,
                },
                aoeMode = {
                    type = "select",
                    order = 20,
                    name = "AOE / 单体",
                    values = { [0] = "自动", [1] = "单体" },
                    sorting = { 0, 1 },
                    get = function()
                        FuyutsuiDB = FuyutsuiDB or {}
                        return FuyutsuiDB.aoeMode or 0
                    end,
                    set = function(_, val)
                        FuyutsuiDB = FuyutsuiDB or {}
                        FuyutsuiDB.aoeMode = val
                        SyncBlockFromDB()
                    end,
                },
                dpsMode = {
                    type = "select",
                    order = 30,
                    name = "输出模式",
                    values = { [0] = "官方一键辅助", [1] = "手动编写逻辑" },
                    sorting = { 0, 1 },
                    get = function()
                        FuyutsuiDB = FuyutsuiDB or {}
                        return FuyutsuiDB.dpsMode or 0
                    end,
                    set = function(_, val)
                        FuyutsuiDB = FuyutsuiDB or {}
                        FuyutsuiDB.dpsMode = val
                        SyncBlockFromDB()
                    end,
                },
            },
        },
    },
}

AceConfig:RegisterOptionsTable(addonName .. "Info", options, nil)

function fu.OpenInfoGUI()
    AceConfigDialog:SetDefaultSize(addonName .. "Info", 520, 480)
    AceConfigDialog:Open(addonName .. "Info")
end
