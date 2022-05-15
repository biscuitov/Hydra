local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local fa = require("fAwesome5")
imgui.OnInitialize(function()
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges)
    icon = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 14.0, config, iconRanges)
end)

local COLORS = {
    [0] = {back = {0.26, 0.71, 0.81, 1},    text = {1, 1, 1, 1}, icon = {1, 1, 1, 1}, border = {1, 0, 0, 0}},--{back = imgui.ImVec4(0.1, 0.13, 0.17, 1), text = imgui.ImVec4(1, 1, 1, 1), icon = imgui.ImVec4(1, 0, 0.3, 1), border = imgui.ImVec4(1, 0, 0.3, 1)},
    [1] = {back = {0.26, 0.81, 0.31, 1},    text = {1, 1, 1, 1}, icon = {1, 1, 1, 1}, border = {1, 0, 0, 0}},
    [2] = {back = {1, 0.39, 0.39, 1},       text = {1, 1, 1, 1}, icon = {1, 1, 1, 1}, border = {1, 0, 0, 0}},
    [3] = {back = {0.97, 0.57, 0.28, 1},    text = {1, 1, 1, 1}, icon = {1, 1, 1, 1}, border = {1, 0, 0, 0}},
    [4] = {back = {0, 0, 0, 1},             text = {1, 1, 1, 1}, icon = {1, 1, 1, 1}, border = {1, 0, 0, 0}},
}


local list = {}
EXPORTS = {
    __version = '0.1',
    TYPE = {
        INFO = 0,
        OK = 1,
        ERROR = 2,
        WARN = 3,
        DEBUG = 4
    },
    ICON = {
        [0] = fa.ICON_FA_INFO_CIRCLE,
        [1] = fa.ICON_FA_CHECK,
        [2] = fa.ICON_FA_TIMES,
        [3] = fa.ICON_FA_EXCLAMATION,
        [4] = fa.ICON_FA_WRENCH
    },
    Show = function(text, type, time, colors)
        table.insert(list, {
            text = text,
            type = type or 2,
            time = time or 4,
            start = os.clock(),
            alpha = 0,
            colors = colors or COLORS[type]
        })
    end
}

local newFrame = imgui.OnFrame(
    function() return #list > 0 end,
    function(self)
        self.HideCursor = true
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 300, 300
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin('notf_window', _, 0
            + imgui.WindowFlags.AlwaysAutoResize
            + imgui.WindowFlags.NoTitleBar
            + imgui.WindowFlags.NoResize
            + imgui.WindowFlags.NoMove
            + imgui.WindowFlags.NoBackground
        )

        local winSize = imgui.GetWindowSize()
        imgui.SetWindowPosVec2(imgui.ImVec2(resX - 10 - winSize.x, 50))

        for k, data in ipairs(list) do
            ------------------------------------------------
            local default_data = {
                text = 'text',
                type = 0,
                time = 1500
            }
            for k, v in pairs(default_data) do
                if data[k] == nil then
                    data[k] = v
                end
            end


            local c = imgui.GetCursorPos()
            local p = imgui.GetCursorScreenPos()
            local DL = imgui.GetWindowDrawList()

            local textSize = imgui.CalcTextSize(data.text)
            local iconSize = imgui.CalcTextSize(EXPORTS.ICON[data.type] or fa.ICON_FA_TIMES)
            local size = imgui.ImVec2(5 + iconSize.x + 5 + textSize.x + 5, 5 + textSize.y + 5)


            local winSize = imgui.GetWindowSize()
            if winSize.x > size.x + 20 then
                imgui.SetCursorPosX(winSize.x - size.x - 8)
            end


            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, data.alpha)--bringFloatTo(1, 0, data.start + data.time / 5, data.time / 5) or 1)
            imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 5)
            imgui.PushStyleColor(imgui.Col.ChildBg,     tableToImVec(data.colors.back or COLORS[data.type].back))
            imgui.PushStyleColor(imgui.Col.Border,      tableToImVec(data.colors.border or COLORS[data.type].border))
            imgui.BeginChild('toastNotf:'..tostring(k)..tostring(data.text), size, true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
                imgui.PushStyleColor(imgui.Col.Text,    tableToImVec(data.colors.icon or COLORS[data.type].icon))
                imgui.SetCursorPos(imgui.ImVec2(5, size.y / 2 - iconSize.y / 2))
                imgui.Text(EXPORTS.ICON[data.type] or fa.ICON_FA_TIMES)
                imgui.PopStyleColor()

                imgui.PushStyleColor(imgui.Col.Text,    tableToImVec(data.colors.text or COLORS[data.type].text))
                imgui.SetCursorPos(imgui.ImVec2(5 + iconSize.x + 5, size.y / 2 - textSize.y / 2))
                imgui.Text(data.text)
                imgui.PopStyleColor()
            imgui.EndChild()
            imgui.PopStyleColor()
            imgui.PopStyleVar(2)
            ------------------------------------------------
        end

        imgui.End()
    end
)

function tableToImVec(tbl)
    return imgui.ImVec4(tbl[1], tbl[2], tbl[3], tbl[4])
end

function bringFloatTo(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return from + (count * (to - from) / 100), true
    end
    return (timer > duration) and to or from, false
end

local DEBUG = false

function main()
    if DEBUG then
        for k, v in pairs(EXPORTS.TYPE) do
            EXPORTS.Show('Toast Notification\nType: '..k..' ('..tostring(v)..')', v, 5000)
        end
    end
    while true do
        wait(0)
        for k, data in ipairs(list) do
            --==[ UPDATE ALPHA ]==--
            if data.alpha == nil then list[k].alpha = 0 end
            if os.clock() - data.start < 0.5 then
                list[k].alpha = bringFloatTo(0, 1, data.start, 0.5)
            elseif data.time - 0.5 < os.clock() - data.start then
                list[k].alpha = bringFloatTo(1, 0, data.start + data.time - 0.5, 0.5)
            end

            --==[ REMOVE ]==--
            if os.clock() - data.start > data.time then
                table.remove(list, k)
            end
        end
    end
end


function imgui.MaterialSlider(id, width, max_value, value, color, bg_color)
    local function bringFloatTo(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return from + (count * (to - from) / 100), true
        end
        return (timer > duration) and to or from, false
    end
    if UI_MATERIALSLIDER == nil then UI_MATERIALSLIDER = {} end
    if not UI_MATERIALSLIDER[id] then UI_MATERIALSLIDER[id] = {height = width / 12, curr_width = 0, clicked = nil, c_pos_y = nil, c_pos_y_old = nil, c_pos_x = imgui.GetCursorPos().x + imgui.GetWindowPos().x, text = nil, hovered = {nil, nil}} end
    local pool = UI_MATERIALSLIDER[id]
    if max_value ~= nil and value ~= nil and pool["clicked"] == nil then
        pool["curr_width"] = width * (value / (max_value + 1))
        pool["text"] = tostring(value)
    end
    if pool["c_pos_y"] == nil then pool["c_pos_y"] = imgui.GetCursorPos().y + (pool["height"] / 2) end
    if pool["c_pos_y_old"] == nil then pool["c_pos_y_old"] = pool["c_pos_y"] end
    imgui.SetCursorPosY(pool["c_pos_y"])
    imgui.PushStyleVar(imgui.StyleVar.ChildWindowRounding, pool["height"])
    imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0, 0, 0, 0))
    local draw_list = imgui.GetWindowDrawList()
    draw_list:AddRectFilled(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x, imgui.GetCursorPos().y + imgui.GetWindowPos().y - imgui.GetScrollY()), imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + width, imgui.GetCursorPos().y + imgui.GetWindowPos().y + pool["height"] - imgui.GetScrollY()), imgui.GetColorU32(bg_color or imgui.GetStyle().Colors[imgui.Col.TextDisabled]), pool["height"] / 2)
    imgui.BeginChild("##" .. id, imgui.ImVec2(width, pool["height"]))
    if pool["curr_width"] < pool["height"] / 2 then
        draw_list:PathArcTo(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + (pool["height"] / 2), imgui.GetCursorPos().y + imgui.GetWindowPos().y + (pool["height"] / 2) - imgui.GetScrollY()), pool["height"] / 2, math.acos(-(((pool["height"] / 2) - pool["curr_width"]) / (pool["height"] / 2))), math.acos(((pool["height"] / 2) - pool["curr_width"]) / (pool["height"] / 2)) + 3.141)
        draw_list:PathFillConvex(imgui.GetColorU32(color or imgui.GetStyle().Colors[imgui.Col.ButtonActive]))
        draw_list:PathClear()
    else
        draw_list:AddRectFilled(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x, imgui.GetCursorPos().y + imgui.GetWindowPos().y - imgui.GetScrollY()), imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + pool["curr_width"], imgui.GetCursorPos().y + imgui.GetWindowPos().y + pool["height"] - imgui.GetScrollY()), imgui.GetColorU32(color or imgui.GetStyle().Colors[imgui.Col.ButtonActive]), pool["height"] / 2)
    end
    imgui.EndChild()
    imgui.PopStyleColor()
    imgui.PopStyleVar()
    if imgui.IsItemClicked() then pool["clicked"] = true end
    if imgui.IsItemHovered() then
        if pool["hovered"][1] == nil then pool["hovered"][1] = os.clock() end
        pool["hovered"][2] = nil
    else
        if pool["hovered"][2] == nil then pool["hovered"][2] = os.clock() end
        pool["hovered"][1] = nil
    end
    if pool["hovered"][1] ~= nil then
        pool["height"] = bringFloatTo(pool["height"], width / 8, pool["hovered"][1], 0.3)
        pool["c_pos_y"] = bringFloatTo(pool["c_pos_y"], pool["c_pos_y_old"] - ((((width/8) - (width/16)) / 2) * 0.5), pool["hovered"][1], 0.3)
    elseif pool["hovered"][2] ~= nil then
        pool["height"] = bringFloatTo(pool["height"], width / 12, pool["hovered"][2], 0.3)
        pool["c_pos_y"] = bringFloatTo(pool["c_pos_y"], pool["c_pos_y_old"], pool["hovered"][2], 0.3)
    end
    if imgui.IsMouseDown(0) and pool["clicked"] then
        if imgui.GetMousePos().x - pool["c_pos_x"] > width then pool["curr_width"] = width
        elseif imgui.GetMousePos().x - pool["c_pos_x"] < 0 then pool["curr_width"] = 0
        else pool["curr_width"] = imgui.GetMousePos().x - pool["c_pos_x"] end
        if max_value ~= nil and max_value > 1 then
            local nearest = nil
            local min_dist = nil
            for i = 0, max_value do
                if nearest == nil then nearest = i end
                if min_dist == nil then min_dist = math.abs((i * (width / max_value)) - pool["curr_width"]) end
                if math.abs((i * (width / max_value)) - pool["curr_width"]) < min_dist then
                    min_dist = math.abs((i * (width / max_value)) - pool["curr_width"])
                    nearest = i
                end
            end
            pool["curr_width"] = nearest * (width / max_value)
            pool["text"] = tostring(nearest)
        end
    elseif not imgui.IsMouseDown(0) and pool["clicked"] then pool["clicked"] = false end
    return pool["text"] or pool["curr_width"]
end
