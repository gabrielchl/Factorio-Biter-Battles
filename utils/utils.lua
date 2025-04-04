local Module = {}

Module.distance = function(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    return math.sqrt(dx * dx + dy * dy)
end

-- rounds number (num) to certain number of decimal places (idp)
math.round = function(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function math.clamp(num, min, max)
    if num < min then
        return min
    elseif num > max then
        return max
    else
        return num
    end
end

Module.print_except = function(msg, player)
    for _, p in pairs(game.players) do
        if p.connected and p ~= player then
            p.print(msg)
        end
    end
end

Module.print_admins = function(msg)
    for _, p in pairs(game.players) do
        if p.connected and p.admin then
            p.print(msg)
        end
    end
end

Module.get_actor = function()
    if game.player then
        return game.player.name
    end
    return '<server>'
end

Module.cast_bool = function(var)
    if var then
        return true
    else
        return false
    end
end

Module.find_entities_by_last_user = function(player, surface, filters)
    if type(player) == 'string' or not player then
        error(
            "bad argument #1 to '"
                .. debug.getinfo(1, 'n').name
                .. "' (number or LuaPlayer expected, got "
                .. type(player)
                .. ')',
            1
        )
        return
    end
    if type(surface) ~= 'table' and type(surface) ~= 'number' then
        error(
            "bad argument #2 to '"
                .. debug.getinfo(1, 'n').name
                .. "' (number or LuaSurface expected, got "
                .. type(surface)
                .. ')',
            1
        )
        return
    end
    local entities = {}
    local surface = surface
    local player = player
    local filters = filters or {}
    if type(surface) == 'number' then
        surface = game.surfaces[surface]
    end
    if type(player) == 'number' then
        player = game.get_player(player)
    end
    filters.force = player.force.name
    for _, e in pairs(surface.find_entities_filtered(filters)) do
        if e.last_user == player then
            table.insert(entities, e)
        end
    end
    return entities
end

Module.ternary = function(c, t, f)
    if c then
        return t
    else
        return f
    end
end

function Module.safe_wrap_with_player_print(player, func, ...)
    local function error_handler(err)
        local print_target = player or game
        log('Error caught: ' .. err)
        print_target.print('Error caught: ' .. err)
        -- Print the full stack trace to the log
        log(debug.traceback())
    end
    local call_succeeded, result = xpcall(func, error_handler, ...)
    return result
end

function Module.safe_wrap_cmd(cmd, func, ...)
    local print_fn = game.print
    if cmd.player_index then
        local player = game.get_player(cmd.player_index)
        if player then
            print_fn = player.print
        end
    end
    local function error_handler(err)
        log('Error caught: ' .. err)
        print_fn('Error caught: ' .. err)
        -- Print the full stack trace to the log
        log(debug.traceback())
    end
    local call_succeeded, result = xpcall(func, error_handler, ...)
    return result
end

local minutes_to_ticks = 60 * 60
local hours_to_ticks = 60 * 60 * 60
local ticks_to_minutes = 1 / minutes_to_ticks
local ticks_to_hours = 1 / hours_to_ticks
Module.format_time = function(ticks)
    local result = {}

    local hours = math.floor(ticks * ticks_to_hours)
    if hours > 0 then
        ticks = ticks - hours * hours_to_ticks
        table.insert(result, hours)
        if hours == 1 then
            table.insert(result, 'hour')
        else
            table.insert(result, 'hours')
        end
    end

    local minutes = math.floor(ticks * ticks_to_minutes)
    table.insert(result, minutes)
    if minutes == 1 then
        table.insert(result, 'minute')
    else
        table.insert(result, 'minutes')
    end

    return table.concat(result, ' ')
end

Module.gui_style = function(element, attributes)
    for attribute, value in pairs(attributes) do
        element.style[attribute] = value
    end
end

Module.GUI_VARIANTS = {
    Dark = 1,
    Light = 2,
}
local VARIANTS = Module.GUI_VARIANTS

Module.GUI_THEMES = {
    { type = 'frame_button', name = 'Dark squared', variant = VARIANTS.Dark },
    { type = 'slot_button', name = 'Dark rounded', variant = VARIANTS.Dark },
    { type = 'mod_gui_button', name = 'Light squared', variant = VARIANTS.Light },
    { type = 'rounded_button', name = 'Light rounded', variant = VARIANTS.Light },
}

---@param player LuaPlayer
---Get currently selected theme variant by player or default value.
Module.selected_theme_variant = function(player)
    local theme = storage.gui_theme[player.name]
    if not theme then
        theme = Module.GUI_THEMES[1]
    end

    return theme.variant
end

Module.top_button_style = function()
    return {
        font_color = { 165, 165, 165 },
        font = 'default-semibold',
        minimal_height = 36,
        maximal_height = 36,
        minimal_width = 40,
        padding = -2,
    }
end

Module.left_frame_style = function()
    return {
        padding = 2,
        font_color = { 165, 165, 165 },
        font = 'default-semibold',
        use_header_filler = false,
    }
end

return Module
