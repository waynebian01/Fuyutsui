local addonName, fu = ...
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

Fuyutsui.defaults = {
    profile = {
        someInput = "",
    },
    char = {
        level = 0,
    },
}

local function GetClassColorStr()
    local raid = fu.classFilename and RAID_CLASS_COLORS[fu.classFilename]
    return raid and raid.colorStr or "ffffffff"
end

--- 窗口底部状态栏（AceGUI Frame 的 status 区域，在标签页与关闭按钮之外）
local function GetFooterStatusText()
    local cls = fu.className or "?"
    local spec = fu.specName or "?"
    return ("职业：|c%s%s|r  专精：|c%s%s|r"):format(GetClassColorStr(), cls, GetClassColorStr(), spec)
end

local tinsert, sort, wipe = table.insert, table.sort, wipe

local function addToMap(map, idx, name)
    if type(idx) ~= "number" then return end
    local prev = map[idx]
    if prev then
        map[idx] = prev .. " | " .. tostring(name)
    else
        map[idx] = tostring(name)
    end
end

--- 分别合并 fixed+blocks+auras、spellCooldown；再写入 fu.guiIndexToBlockKey（全集，同索引仍拼接）。
--- 分表：fu.guiIndexToBlockKeyCore、fu.guiIndexToBlockKeySpell（供界面分区显示）。
function fu.RebuildGuiIndexBlockMap()
    local core = {}
    local spell = {}
    if fu.fixedBlocks then
        for k, v in pairs(fu.fixedBlocks) do
            if type(v) == "number" then
                addToMap(core, v, k)
            end
        end
    end
    if fu.blocks then
        for k, v in pairs(fu.blocks) do
            if k ~= "auras" and type(v) == "number" then
                addToMap(core, v, k)
            end
        end
        if fu.blocks.auras then
            for auraName, info in pairs(fu.blocks.auras) do
                if type(info) == "table" and type(info.index) == "number" then
                    addToMap(core, info.index, auraName)
                end
            end
        end
    end
    if fu.spellCooldown then
        for _, info in pairs(fu.spellCooldown) do
            if type(info) == "table" then
                local nm = info.name
                if type(nm) == "string" and nm ~= "" then
                    if type(info.index) == "number" then
                        addToMap(spell, info.index, nm)
                    end
                    if type(info.charge) == "number" then
                        addToMap(spell, info.charge, nm .. "·充能")
                    end
                end
            end
        end
    end

    fu.guiIndexToBlockKeyCore = fu.guiIndexToBlockKeyCore or {}
    fu.guiIndexToBlockKeySpell = fu.guiIndexToBlockKeySpell or {}
    wipe(fu.guiIndexToBlockKeyCore)
    wipe(fu.guiIndexToBlockKeySpell)
    for idx, name in pairs(core) do
        fu.guiIndexToBlockKeyCore[idx] = name
    end
    for idx, name in pairs(spell) do
        fu.guiIndexToBlockKeySpell[idx] = name
    end

    fu.guiIndexToBlockKey = fu.guiIndexToBlockKey or {}
    wipe(fu.guiIndexToBlockKey)
    for idx, name in pairs(core) do
        fu.guiIndexToBlockKey[idx] = name
    end
    for idx, name in pairs(spell) do
        local prev = fu.guiIndexToBlockKey[idx]
        if prev then
            fu.guiIndexToBlockKey[idx] = prev .. " | " .. name
        else
            fu.guiIndexToBlockKey[idx] = name
        end
    end
    return fu.guiIndexToBlockKey
end

--- 同一映射表内按索引排序，每行一条「索引: 名称」。
local function formatMapRowsOnePerLine(map)
    if not map or not next(map) then
        return {}
    end
    local indices = {}
    for idx in pairs(map) do
        tinsert(indices, idx)
    end
    sort(indices)
    local lines = {}
    for _, idx in ipairs(indices) do
        tinsert(lines, ("%d: %s"):format(idx, map[idx]))
    end
    return lines
end

--- fu.countBars 仅用于展示，不并入 guiIndexToBlockKey；每行「键: name」。
local function formatCountBarsLines()
    if not fu.countBars or not next(fu.countBars) then
        return {}
    end
    local keys = {}
    for k in pairs(fu.countBars) do
        tinsert(keys, k)
    end
    sort(keys, function(a, b)
        local na, nb = tonumber(a), tonumber(b)
        if na and nb then return na < nb end
        if na then return true end
        if nb then return false end
        return tostring(a) < tostring(b)
    end)
    local lines = {}
    for _, k in ipairs(keys) do
        local v = fu.countBars[k]
        local nm = (type(v) == "table" and type(v.name) == "string") and v.name or tostring(v)
        tinsert(lines, ("%s: %s"):format(tostring(k), nm))
    end
    return lines
end

--- 核心区、「法术冷却」、可选「施法计数」；索引区一行一条，施法计数为键与 name。
local function BuildBlocksSummary()
    fu.RebuildGuiIndexBlockMap()
    local core = fu.guiIndexToBlockKeyCore
    local spl = fu.guiIndexToBlockKeySpell
    local countLines = formatCountBarsLines()
    local hasCore = core and next(core)
    local hasSpell = spl and next(spl)
    local hasCount = #countLines > 0
    if not hasCore and not hasSpell and not hasCount then
        return "暂无数据：fu.fixedBlocks / fu.blocks / fu.spellCooldown 尚无索引映射，且未配置 fu.countBars。"
    end
    local parts = {}
    if hasCore then
        for _, line in ipairs(formatMapRowsOnePerLine(core)) do
            tinsert(parts, line)
        end
    end
    if hasSpell then
        if hasCore then
            tinsert(parts, "")
        end
        tinsert(parts, "法术冷却")
        for _, line in ipairs(formatMapRowsOnePerLine(spl)) do
            tinsert(parts, line)
        end
    end
    if hasCount then
        if hasCore or hasSpell then
            tinsert(parts, "")
        end
        tinsert(parts, "施法计数")
        for _, line in ipairs(countLines) do
            tinsert(parts, line)
        end
    end
    return table.concat(parts, "\n")
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
Fuyutsui.options = {
    type = "group",
    name = "Fuyutsui",
    childGroups = "tab",
    args = {
        -- ========== 标签 1：关于 ==========
        about = {
            type = "group",
            name = "关于",
            order = 3,
            args = {
                intro = {
                    type = "description",
                    order = 1,
                    fontSize = "medium",
                    name = function()
                        return ([[
|cff00ccff%s|r
Fuyutsui Tinkerer是由Fuyutsuki Electronics研发的一块|cFF00FF00免费|r网络接入仓，大概能提升你在夜之城的战斗体验。

感谢所有使用和反馈本插件的用户，特别感谢Discord群组中的成员们的宝贵意见与建议，让插件得以不断完善和进步！

]]):format(addonName)
                    end,
                },
            },
        },
        -- ========== 标签 2：fu.blocks 信息 ==========
        blocks = {
            type = "group",
            name = "映射表",
            order = 2,
            args = {
                hint = {
                    type = "description",
                    order = 0,
                    name =
                    "索引, 法术冷却, 施法计数。",
                },
                dump = {
                    type = "description",
                    order = 1,
                    fontSize = "medium",
                    width = "full",
                    name = function()
                        return BuildBlocksSummary()
                    end,
                },
            },
        },
        -- ========== 标签 3：配置 ==========
        settings = {
            type = "group",
            name = "配置",
            order = 1,
            args = {
                note = {
                    type = "description",
                    order = 0,
                    name =
                    "",
                },
                cooldowns = {
                    type = "toggle",
                    order = 10,
                    name = "爆发",
                    desc = "开启时允许按逻辑使用爆发；关闭时对应像素会反映为关。",
                    width = "full",
                    get = function()
                        FuyutsuiDB = FuyutsuiDB or {}
                        return (FuyutsuiDB.cooldowns or 0) == 1
                    end,
                    set = function(_, val)
                        FuyutsuiDB = FuyutsuiDB or {}
                        FuyutsuiDB.cooldowns = val and 1 or 0
                        if fu.switchCooldown then
                            fu.switchCooldown()
                        else
                            SyncBlockFromDB()
                        end
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
                        if fu.switchAoeMode then
                            fu.switchAoeMode()
                        else
                            SyncBlockFromDB()
                        end
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
                        if fu.switchDpsMode then
                            fu.switchDpsMode()
                        else
                            SyncBlockFromDB()
                        end
                    end,
                },
            },
        },
    },
}

AC:RegisterOptionsTable("Fuyutsui_Options", Fuyutsui.options, nil)

function fu.OpenInfoGUI()
    ACD:SetDefaultSize("Fuyutsui_Options", 520, 480)
    ACD:Open("Fuyutsui_Options")
    local root = ACD.OpenFrames["Fuyutsui_Options"]
    if root and root.SetStatusText then
        root:SetStatusText(GetFooterStatusText())
    end
end
