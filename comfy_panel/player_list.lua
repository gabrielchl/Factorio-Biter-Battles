--[[
Hello there!

This will add a player list with "ranks" to your server.
Oh.. and you can also "poke" a player.
pokemessages = 80% by redlabel

To install, add: require "player_list"
to your scenario control.lua.

---MewMew---

Minor changes by ~~~Gerkiz~~~
--]]
local Event = require('utils.event')
local Where = require('commands.where')
local Session = require('utils.datastore.session_data')
local Jailed = require('utils.datastore.jail_data')
local Tabs = require('comfy_panel.main')
local Global = require('utils.global')

local Public = {}

local this = {
    player_list = {
        last_poke_tick = {},
        pokes = {},
        sorting_method = {},
    },
    show_roles_in_list = false,
}

Global.register(this, function(t)
    this = t
end)

local symbol_asc = '▲'
local symbol_desc = '▼'

local pokemessages = {
    'a stick',
    'a leaf',
    'a moldy carrot',
    'a crispy slice of bacon',
    'a french fry',
    'a realistic toygun',
    'a broomstick',
    'a thirteen inch iron stick',
    'a mechanical keyboard',
    'a fly fishing cane',
    'a selfie stick',
    'an oversized fidget spinner',
    'a thumb extender',
    'a dirty straw',
    'a green bean',
    'a banana',
    'an umbrella',
    "grandpa's walking stick",
    'live firework',
    'a toilet brush',
    'a fake hand',
    'an undercooked hotdog',
    "a slice of yesterday's microwaved pizza",
    'bubblegum',
    'a biter leg',
    "grandma's toothbrush",
    'charred octopus',
    'a dollhouse bathtub',
    'a length of copper wire',
    'a decommissioned nuke',
    'a smelly trout',
    'an unopened can of deodorant',
    'a stone brick',
    'a half full barrel of lube',
    'a half empty barrel of lube',
    'an unexploded cannon shell',
    'a blasting programmable speaker',
    'a not so straight rail',
    'a mismatched pipe to ground',
    'a surplus box of landmines',
    'decommissioned yellow rounds',
    'an oily pumpjack shaft',
    'a melted plastic bar in the shape of the virgin mary',
    'a bottle of watermelon vitamin water',
    'a slice of watermelon',
    'a stegosaurus tibia',
    "a basking musician's clarinet",
    'a twig',
    'an undisclosed pokey item',
    'a childhood trophy everyone else got',
    'a dead starfish',
    'a titanium toothpick',
    'a nail file',
    'a stamp collection',
    'a bucket of lego',
    'a rolled up carpet',
    'a rolled up WELCOME doormat',
    "Bobby's favorite bone",
    'an empty bottle of cheap vodka',
    'a tattooing needle',
    'a peeled cucumber',
    'a stack of cotton candy',
    'a signed baseball bat',
    'that 5 dollar bill grandma sent for christmas',
    'a stack of overdue phone bills',
    "the 'relax' section of the white pages",
    'a bag of gym clothes which never made it to the washing machine',
    'a handful of peanut butter',
    "a pheasant's feather",
    'a rusty pickaxe',
    'a diamond sword',
    'the bill of rights of a banana republic',
    "one of those giant airport Toblerone's",
    'a long handed inserter',
    'a wiimote',
    'an easter chocolate rabbit',
    'a ball of yarn the cat threw up',
    'a slightly expired but perfectly edible cheese sandwich',
    'conclusive proof of lizard people existence',
    'a pen drive full of high res wallpapers',
    'a pet hamster',
    'an oversized goldfish',
    'a one foot extension cord',
    "a CD from Walmart's 1 dollar bucket",
    'a magic wand',
    'a list of disappointed people who believed in you',
    'murder exhibit no. 3',
    "a paperback copy of 'Great Expectations'",
    'a baby biter',
    'a little biter fang',
    'the latest diet fad',
    'a belt that no longer fits you',
    'an abandoned pet rock',
    'a lava lamp',
    'some spirit herbs',
    'a box of fish sticks found at the back of the freezer',
    'a bowl of tofu rice',
    'a bowl of ramen noodles',
    'a live lobster!',
    'a miniature golf cart',
    'dunce cap',
    'a fully furnished x-mas tree',
    'an orphaned power pole',
    'an horphaned power pole',
    'an box of overpriced girl scout cookies',
    'the cheapest item from the yard sale',
    'a Sharpie',
    'a glowstick',
    'a thick unibrow hair',
    'a very detailed map of Kazakhstan',
    'the official Factorio installation DVD',
    'a Liberal Arts degree',
    'a pitcher of Kool-Aid',
    'a 1/4 pound vegan burrito',
    'a bottle of expensive wine',
    'a hamster sized gravestone',
    'a counterfeit Cuban cigar',
    'an old Nokia phone',
    'a huge inferiority complex',
    'a dead real state agent',
    'a deck of tarot cards',
    'unreleased Wikileaks documents',
    'a mean-looking garden dwarf',
    'the actual mythological OBESE cat',
    'a telescope used to spy on the MILF next door',
    'a fancy candelabra',
    'the comic version of the Kama Sutra',
    "an inflatable 'Netflix & chill' doll",
    'whatever it is redlabel gets high on',
    "Obama's birth certificate",
    'a deck of Cards Against Humanity',
    'a copy of META MEME HUMOR for Dummies',
    'an abandoned, not-so-young-anymore puppy',
    'one of those useless items advertised on TV',
    'a genetic blueprint of a Japanese teen idol',
}

function Public.get_formatted_playtime_from_ticks(ticks)
    local math_floor = math.floor
    local seconds = math_floor(ticks / 60)
    local minutes = math_floor(seconds / 60)
    local hours = math_floor(minutes / 60)
    local days = math_floor(hours / 24)

    minutes = minutes % 60
    hours = hours % 24

    if days >= 1 then
        return string.format('%d days %d hours', days, hours)
    elseif hours >= 1 then
        return string.format('%d hours %d minutes', hours, minutes)
    else
        return string.format('%d minutes', minutes)
    end
end

local function get_rank(player)
    local t = 0
    if storage.total_time_online_players[player.name] then
        t = storage.total_time_online_players[player.name]
    end

    local m = t / 3600

    local ranks = {
        'item/burner-mining-drill',
        'item/burner-inserter',
        'item/stone-furnace',
        'item/light-armor',
        'item/steam-engine',
        'item/inserter',
        'item/transport-belt',
        'item/underground-belt',
        'item/splitter',
        'item/assembling-machine-1',
        'item/long-handed-inserter',
        'item/electronic-circuit',
        'item/electric-mining-drill',
        'technology/steel-axe',
        'item/heavy-armor',
        'item/steel-furnace',
        'item/gun-turret',
        'item/fast-transport-belt',
        'item/fast-underground-belt',
        'item/fast-splitter',
        'item/assembling-machine-2',
        'item/fast-inserter',
        'item/radar',
        'item/repair-pack',
        'item/defender-capsule',
        'item/pumpjack',
        'item/chemical-plant',
        'item/solar-panel',
        'item/advanced-circuit',
        'item/modular-armor',
        'item/accumulator',
        'item/construction-robot',
        'item/distractor-capsule',
        'item/bulk-inserter',
        'item/electric-furnace',
        'item/express-transport-belt',
        'item/express-underground-belt',
        'item/express-splitter',
        'item/assembling-machine-3',
        'item/processing-unit',
        'item/power-armor',
        'item/logistic-robot',
        'item/laser-turret',
        'item/personal-laser-defense-equipment',
        'item/destroyer-capsule',
        'item/power-armor-mk2',
        'item/flamethrower-turret',
        'item/beacon',
        'item/steam-turbine',
        'item/centrifuge',
        'item/nuclear-reactor',
        'item/cannon-shell',
        'item/rocket',
        'item/explosive-cannon-shell',
        'item/explosive-rocket',
        'item/uranium-cannon-shell',
        'item/explosive-uranium-cannon-shell',
        'item/atomic-bomb',
        'achievement/so-long-and-thanks-for-all-the-fish',
        'achievement/golem',
    }

    --60? ranks

    local time_needed = 240 -- in minutes between rank upgrades
    m = m / time_needed
    m = math.floor(m)
    m = m + 1

    if m > #ranks then
        m = #ranks
    end

    return ranks[m]
end

local comparators = {
    ['pokes_asc'] = function(a, b)
        return a.pokes > b.pokes
    end,
    ['pokes_desc'] = function(a, b)
        return a.pokes < b.pokes
    end,
    ['total_time_played_asc'] = function(a, b)
        return a.total_played_ticks < b.total_played_ticks
    end,
    ['total_time_played_desc'] = function(a, b)
        return a.total_played_ticks > b.total_played_ticks
    end,
    ['time_played_asc'] = function(a, b)
        return a.played_ticks < b.played_ticks
    end,
    ['time_played_desc'] = function(a, b)
        return a.played_ticks > b.played_ticks
    end,
    ['name_asc'] = function(a, b)
        return a.name:lower() < b.name:lower()
    end,
    ['name_desc'] = function(a, b)
        return a.name:lower() > b.name:lower()
    end,
}

local function get_comparator(sort_by)
    return comparators[sort_by]
end

local function get_sorted_list(sort_by)
    local play_table = Session.get_session_table()
    local player_list = {}
    for i, player in pairs(game.connected_players) do
        player_list[i] = {}
        player_list[i].rank = get_rank(player)
        player_list[i].name = player.name

        local t = 0
        if storage.total_time_online_players[player.name] then
            t = storage.total_time_online_players[player.name]
        end

        player_list[i].total_played_time = Public.get_formatted_playtime_from_ticks(t)
        player_list[i].total_played_ticks = t

        player_list[i].played_time = Public.get_formatted_playtime_from_ticks(player.online_time)
        player_list[i].played_ticks = player.online_time

        player_list[i].pokes = this.player_list.pokes[player.index]
        player_list[i].player_index = player.index
    end

    local comparator = get_comparator(sort_by)
    table.sort(player_list, comparator)

    return player_list
end

local function player_list_show(player, frame, sort_by)
    -- Frame management
    frame.clear()
    frame.style.padding = 8
    local play_table = Session.get_trusted_table()
    local jailed = Jailed.get_jailed_table()

    -- Header management
    local t = frame.add({ type = 'table', name = 'player_list_panel_header_table', column_count = 5 })
    local column_widths = { tonumber(40), tonumber(218), tonumber(220), tonumber(222), tonumber(50) }
    local header_column_widths = { tonumber(40), tonumber(210), tonumber(220), tonumber(226), tonumber(50) }
    for _, w in ipairs(header_column_widths) do
        local label = t.add({ type = 'label', caption = '' })
        label.style.minimal_width = w
        label.style.maximal_width = w
    end

    local headers = {
        [1] = '[color=0.1,0.7,0.1]' -- green
            .. tostring(#game.connected_players)
            .. '[/color]',
        [2] = 'Online'
            .. ' / '
            .. '[color=0.7,0.1,0.1]' -- red
            .. tostring(#game.players - #game.connected_players)
            .. '[/color]'
            .. ' Offline',
        [3] = 'Total Time',
        [4] = 'Current Time',
        [5] = 'Poke',
    }
    local header_modifier = {
        ['name_asc'] = function(h)
            h[2] = symbol_asc .. h[2]
        end,
        ['name_desc'] = function(h)
            h[2] = symbol_desc .. h[2]
        end,
        ['total_time_played_asc'] = function(h)
            h[3] = symbol_asc .. h[3]
        end,
        ['total_time_played_desc'] = function(h)
            h[3] = symbol_desc .. h[3]
        end,
        ['time_played_asc'] = function(h)
            h[4] = symbol_asc .. h[4]
        end,
        ['time_played_desc'] = function(h)
            h[4] = symbol_desc .. h[4]
        end,
        ['pokes_asc'] = function(h)
            h[5] = symbol_asc .. h[5]
        end,
        ['pokes_desc'] = function(h)
            h[5] = symbol_desc .. h[5]
        end,
    }

    if sort_by then
        this.player_list.sorting_method[player.index] = sort_by
    else
        sort_by = this.player_list.sorting_method[player.index]
    end

    header_modifier[sort_by](headers)

    for k, v in ipairs(headers) do
        local header_label = t.add({
            type = 'label',
            name = 'player_list_panel_header_' .. k,
            caption = v,
        })
        header_label.style.font = 'default-bold'
        header_label.style.font_color = { r = 0.98, g = 0.66, b = 0.22 }
    end

    -- special style on first header
    local label = t['player_list_panel_header_1']
    label.style.minimal_width = 36
    label.style.maximal_width = 36
    label.style.horizontal_align = 'right'

    -- List management
    local player_list_panel_table = frame.add({
        type = 'scroll-pane',
        name = 'scroll_pane',
        direction = 'vertical',
        horizontal_scroll_policy = 'never',
        vertical_scroll_policy = 'auto',
    })
    player_list_panel_table.style.maximal_height = 530

    player_list_panel_table =
        player_list_panel_table.add({ type = 'table', name = 'player_list_panel_table', column_count = 5 })

    local player_list = get_sorted_list(sort_by)
    for i = 1, #player_list, 1 do
        -- Icon
        local sprite = player_list_panel_table.add({
            type = 'sprite',
            name = 'player_rank_sprite_' .. i,
            sprite = player_list[i].rank,
        })
        sprite.style.height = 32
        sprite.style.width = 32
        sprite.style.stretch_image_to_widget_size = true

        local trusted
        local tooltip

        local player = game.get_player(player_list[i].name)
        if player.admin then
            trusted = '[color=red][A][/color]'
            tooltip = 'This player is an admin of this server.\nLeft-click to show this person on map!'
        elseif jailed[player_list[i].name] then
            trusted = '[color=orange][J][/color]'
            tooltip = 'This player is currently jailed.\nLeft-click to show this person on map!'
        elseif play_table[player_list[i].name] then
            trusted = '[color=green][T][/color]'
            tooltip = 'This player is trusted.\nLeft-click to show this person on map!'
        else
            trusted = '[color=yellow][U][/color]'
            tooltip = 'This player is not trusted.\nLeft-click to show this person on map!'
        end

        local caption
        if this.show_roles_in_list or player.admin then
            caption = player_list[i].name .. ' ' .. trusted
        else
            caption = player_list[i].name
        end

        local name_label = player_list_panel_table.add({
            type = 'label',
            name = 'where_player_' .. player.index,
            caption = caption,
            tooltip = tooltip,
        })

        name_label.style.font = 'default'
        name_label.style.font_color = {
            r = 0.4 + player.color.r * 0.6,
            g = 0.4 + player.color.g * 0.6,
            b = 0.4 + player.color.b * 0.6,
        }
        name_label.style.minimal_width = column_widths[2]
        name_label.style.maximal_width = column_widths[2]

        -- Total time
        local total_label = player_list_panel_table.add({
            type = 'label',
            name = 'player_list_panel_player_total_time_played_' .. i,
            caption = player_list[i].total_played_time,
        })
        total_label.style.minimal_width = column_widths[3]
        total_label.style.maximal_width = column_widths[3]

        -- Current time
        local current_label = player_list_panel_table.add({
            type = 'label',
            name = 'player_list_panel_player_time_played_' .. i,
            caption = player_list[i].played_time,
        })
        current_label.style.minimal_width = column_widths[4]
        current_label.style.maximal_width = column_widths[4]

        -- Poke
        local flow =
            player_list_panel_table.add({ type = 'flow', name = 'button_flow_' .. i, direction = 'horizontal' })
        flow.add({ type = 'label', name = 'button_spacer_' .. i, caption = '' })
        local button =
            flow.add({ type = 'button', name = 'poke_player_' .. player_list[i].name, caption = player_list[i].pokes })
        button.style.font = 'default'
        button.tooltip = 'Poke ' .. player_list[i].name .. ' with a random message!'
        label.style.font_color = { r = 0.83, g = 0.83, b = 0.83 }
        button.style.minimal_height = 30
        button.style.minimal_width = 30
        button.style.maximal_height = 30
        button.style.maximal_width = 30
        button.style.top_padding = 0
        button.style.left_padding = 0
        button.style.right_padding = 0
        button.style.bottom_padding = 0
    end
end

local function on_gui_click(event)
    if not event then
        return
    end
    if not event.element then
        return
    end
    if not event.element.valid then
        return
    end
    if not event.element.name then
        return
    end
    local player = game.get_player(event.element.player_index)

    local frame = Tabs.comfy_panel_get_active_frame(player)
    if not frame then
        return
    end
    if frame.name ~= 'Players' then
        return
    end

    local name = event.element.name
    local actions = {
        ['player_list_panel_header_2'] = function()
            if string.find(event.element.caption, symbol_desc) then
                player_list_show(player, frame, 'name_asc')
            else
                player_list_show(player, frame, 'name_desc')
            end
        end,
        ['player_list_panel_header_3'] = function()
            if string.find(event.element.caption, symbol_desc) then
                player_list_show(player, frame, 'total_time_played_asc')
            else
                player_list_show(player, frame, 'total_time_played_desc')
            end
        end,
        ['player_list_panel_header_4'] = function()
            if string.find(event.element.caption, symbol_desc) then
                player_list_show(player, frame, 'time_played_asc')
            else
                player_list_show(player, frame, 'time_played_desc')
            end
        end,
        ['player_list_panel_header_5'] = function()
            if string.find(event.element.caption, symbol_desc) then
                player_list_show(player, frame, 'pokes_asc')
            else
                player_list_show(player, frame, 'pokes_desc')
            end
        end,
    }

    if actions[name] then
        actions[name]()
        return
    end

    if not event.element.valid then
        return
    end

    --Locate other players
    if string.sub(name, 1, 13) == 'where_player_' then
        local index = tonumber(string.sub(name, 14, string.len(name)))
        if index and game.get_player(index) and index == game.get_player(index).index then
            local target = game.get_player(index)
            if not target or not target.valid then
                return
            end
            Where.create_mini_camera_gui(player, target.name, target.physical_position, target.physical_surface_index)
        end
    --Poke other players
    elseif string.sub(event.element.name, 1, 11) == 'poke_player' then
        local poked_player = string.sub(event.element.name, 13, string.len(event.element.name))
        if player.name == poked_player then
            return
        end
        if this.player_list.last_poke_tick[event.element.player_index] + 300 < game.tick then
            local str = '>> '
            str = str .. player.name
            str = str .. ' has poked '
            str = str .. poked_player
            str = str .. ' with '
            local z = math.random(1, #pokemessages)
            str = str .. pokemessages[z]
            str = str .. ' <<'
            game.print(str)
            this.player_list.last_poke_tick[event.element.player_index] = game.tick
            local p = game.get_player(poked_player)
            this.player_list.pokes[p.index] = this.player_list.pokes[p.index] + 1
        end
    end
end

local function refresh()
    for _, player in pairs(game.connected_players) do
        local frame = Tabs.comfy_panel_get_active_frame(player)
        if frame then
            if frame.name ~= 'Players' then
                return
            end
            player_list_show(player, frame, this.player_list.sorting_method[player.index])
        end
    end
end

local function on_player_joined_game(event)
    if not this.player_list.last_poke_tick[event.player_index] then
        this.player_list.pokes[event.player_index] = 0
        this.player_list.last_poke_tick[event.player_index] = 0
        this.player_list.sorting_method[event.player_index] = 'total_time_played_desc'
    end
    refresh()
end

local function on_player_left_game()
    refresh()
end

--- If the different roles should be shown in the player_list.
---@param value string
function Public.show_roles_in_list(value)
    if value then
        this.show_roles_in_list = value
    end

    return this.show_roles_in_list
end

comfy_panel_tabs['Players'] = { gui = player_list_show, admin = false }

Event.add(defines.events.on_player_joined_game, on_player_joined_game)
Event.add(defines.events.on_player_left_game, on_player_left_game)
Event.add(defines.events.on_gui_click, on_gui_click)

return Public
