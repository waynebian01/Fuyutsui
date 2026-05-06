local addon, ns = ...
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")


local function CharCfg()
    return Fuyutsui.db and Fuyutsui.db.char
end

local function GetClassColorStr()
    local fn = Fuyutsui.state and Fuyutsui.state.classFilename
    local raid = fn and RAID_CLASS_COLORS[fn]
    return raid and raid.colorStr or "ffffffff"
end

--- 窗口底部状态栏（AceGUI Frame 的 status 区域，在标签页与关闭按钮之外）
local function GetFooterStatusText()
    local st = Fuyutsui.state
    local cls = (st and st.className) or "?"
    local spec = (st and st.specName) or "?"
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

--- 合并 blocks.state、blocks.auras、blocks.spells；再写入 Fuyutsui.guiIndexToBlockKey（全集，同索引仍拼接）。
--- 分表：Fuyutsui.guiIndexToBlockKeyCore、Fuyutsui.guiIndexToBlockKeySpell（供界面分区显示）。
function Fuyutsui:RebuildGuiIndexBlockMap()
    local core = {}
    local spell = {}
    local bl = Fuyutsui.blocks
    if bl and bl.state then
        for name, idx in pairs(bl.state) do
            if type(idx) == "number" then
                addToMap(core, idx, name)
            end
        end
    end
    if bl and bl.auras then
        for slotIndex, info in pairs(bl.auras) do
            if type(info) == "table" and type(slotIndex) == "number" then
                local label = type(info.name) == "string" and info.name ~= "" and info.name or tostring(slotIndex)
                addToMap(core, slotIndex, label)
            end
        end
    end
    if bl and bl.spells then
        for _, info in pairs(bl.spells) do
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

    Fuyutsui.guiIndexToBlockKeyCore = Fuyutsui.guiIndexToBlockKeyCore or {}
    Fuyutsui.guiIndexToBlockKeySpell = Fuyutsui.guiIndexToBlockKeySpell or {}
    wipe(Fuyutsui.guiIndexToBlockKeyCore)
    wipe(Fuyutsui.guiIndexToBlockKeySpell)
    for idx, name in pairs(core) do
        Fuyutsui.guiIndexToBlockKeyCore[idx] = name
    end
    for idx, name in pairs(spell) do
        Fuyutsui.guiIndexToBlockKeySpell[idx] = name
    end

    Fuyutsui.guiIndexToBlockKey = Fuyutsui.guiIndexToBlockKey or {}
    wipe(Fuyutsui.guiIndexToBlockKey)
    for idx, name in pairs(core) do
        Fuyutsui.guiIndexToBlockKey[idx] = name
    end
    for idx, name in pairs(spell) do
        local prev = Fuyutsui.guiIndexToBlockKey[idx]
        if prev then
            Fuyutsui.guiIndexToBlockKey[idx] = prev .. " | " .. name
        else
            Fuyutsui.guiIndexToBlockKey[idx] = name
        end
    end
    return Fuyutsui.guiIndexToBlockKey
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

--- blocks.countBars 仅用于展示，不并入 guiIndexToBlockKey；每行「键: name」。
local function formatCountBarsLines()
    local cb = Fuyutsui.blocks and Fuyutsui.blocks.countBars
    if not cb or not next(cb) then
        return {}
    end
    local keys = {}
    for k in pairs(cb) do
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
        local v = cb[k]
        local nm = (type(v) == "table" and type(v.name) == "string") and v.name or tostring(v)
        tinsert(lines, ("%s: %s"):format(tostring(k), nm))
    end
    return lines
end

--- 核心区、「法术冷却」、可选「施法计数」；索引区一行一条，施法计数为键与 name。
local function BuildBlocksSummary()
    Fuyutsui:RebuildGuiIndexBlockMap()
    local core = Fuyutsui.guiIndexToBlockKeyCore
    local spl = Fuyutsui.guiIndexToBlockKeySpell
    local countLines = formatCountBarsLines()
    local hasCore = core and next(core)
    local hasSpell = spl and next(spl)
    local hasCount = #countLines > 0
    if not hasCore and not hasSpell and not hasCount then
        return "暂无数据：Fuyutsui.blocks.state / .auras / .spells 尚无索引映射，且未配置 blocks.countBars。"
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
function Fuyutsui:SyncBlockFromDB()
    local c = CharCfg()
    local st = Fuyutsui.blocks and Fuyutsui.blocks.state
    if not c or not st then return end
    if st["爆发开关"] then
        self:CreatTexture(st["爆发开关"], c.cooldowns / 255 or 0)
    end
    if st["AOE开关"] then
        self:CreatTexture(st["AOE开关"], c.aoeMode / 255 or 0)
    end
    if st["输出模式"] then
        self:CreatTexture(st["输出模式"], c.dpsMode / 255 or 0)
    end
    if self.RefreshQuickToggleAppearance then
        self:RefreshQuickToggleAppearance()
    end
end

local function GetVersion()
    return C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addon, "Version")
        or GetAddOnMetadata(addon, "Version")
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

]]):format(addon)
                    end,
                },
            },
        },
        -- ========== 标签 2：Fuyutsui.blocks 映射 ==========
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
                    "以下项保存在 |cffffffffFuyutsuiADB|r 的 |cffffffffdb.char|r（按角色），与 |cffffffff/fu cd|r、|cffffffff/fu aoemode|r、|cffffffff/fu dpsmode|r 一致。",
                },
                cooldowns = {
                    type = "toggle",
                    order = 10,
                    name = "爆发",
                    desc = "开启时允许按逻辑使用爆发；关闭时对应像素会反映为关。",
                    width = "full",
                    get = function()
                        local c = CharCfg()
                        return c and ((c.cooldowns or 0) == 1) or false
                    end,
                    set = function(_, val)
                        local c = CharCfg()
                        if not c then return end
                        c.cooldowns = val and 1 or 0
                        if Fuyutsui and Fuyutsui.SwitchCooldown then
                            Fuyutsui:SwitchCooldown()
                        else
                            Fuyutsui:SyncBlockFromDB()
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
                        local c = CharCfg()
                        return (c and c.aoeMode) or 0
                    end,
                    set = function(_, val)
                        local c = CharCfg()
                        if not c then return end
                        c.aoeMode = val
                        if Fuyutsui and Fuyutsui.SwitchAoeMode then
                            Fuyutsui:SwitchAoeMode()
                        else
                            Fuyutsui:SyncBlockFromDB()
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
                        local c = CharCfg()
                        return (c and c.dpsMode) or 0
                    end,
                    set = function(_, val)
                        local c = CharCfg()
                        if not c then return end
                        c.dpsMode = val
                        if Fuyutsui and Fuyutsui.SwitchDpsMode then
                            Fuyutsui:SwitchDpsMode()
                        else
                            Fuyutsui:SyncBlockFromDB()
                        end
                    end,
                },
            },
        },
    },
}

AC:RegisterOptionsTable("Fuyutsui_Options", Fuyutsui.options, nil)

function Fuyutsui:OpenInfoGUI()
    ACD:SetDefaultSize("Fuyutsui_Options", 520, 480)
    ACD:Open("Fuyutsui_Options")
    local root = ACD.OpenFrames["Fuyutsui_Options"]
    if root and root.SetStatusText then
        root:SetStatusText(GetFooterStatusText())
    end
end
