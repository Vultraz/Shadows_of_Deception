--#textdomain wesnoth-Shadows_of_Deception

---
-- Removes the terrain overlay from every hex matching a given SLF.
--
-- [remove_terrain_overlays]
--     <SLF>
-- [/remove_terrain_overlays]
---
function wml_actions.remove_terrain_overlays(cfg)
	local locs = wesnoth.get_locations(cfg)

	for i, loc in ipairs(locs) do
		local locstr = wesnoth.get_terrain(loc[1], loc[2])
		wesnoth.set_terrain(loc[1], loc[2], string.gsub(locstr, "%^.*$", ""))
	end
end

---
-- Installs mechanical, unlocked "Gate" units on *^Ng\ and *^Ng/ hexes using the given
-- owner side.
--
-- [setup_gates]
--     side=3
-- [/setup_gates]
---
function wml_actions.setup_gates(cfg)
	local locs = wesnoth.get_locations {
		-- include_borders is only valid on 1.13 or later
		include_borders = false,
		terrain = "*^Pr\\",
		{ "or", { terrain = "*^Pr/" } },
		{ "not", { { "filter", {} } } },
	}

	for k, loc in ipairs(locs) do
		wesnoth.put_unit({
			type = "Gate",
			side = cfg.side,
			id = string.format("__gate_X%dY%d", loc[1], loc[2]),
		}, loc[1], loc[2])
	end
end

---
-- Removes an event barrier consisting of adjacent hexes matching
-- a terrain type filter (usually *^Ngl\,*^Ngl/) on the specified location
--
-- If highlight is true, the affected locations will also be highlighted
-- for the player
--
-- Additionally, if var_write is true, those locations will also be written
-- as WML variables.
--
-- [unlock_gates]
--     x,y=<coordinates>
--     var_wirte=<bool, def false>
--     highlight=<bool, def false>
-- [/unlock_gates]
---
function wml_actions.unlock_gates(cfg)
	local gatex, gatey = serialize_loc_string({
		x = cfg.x,
		y = cfg.y,
		radius = 6,
		T.filter_radius {
			terrain = "*^Ngl\\,*^Ngl/"
		}
	})

	wml_actions.remove_terrain_overlays({
		x = gatex,
		y = gatey
	})

	wml_actions.remove_shroud({
		side = 1,
		x = gatex,
		y = gatey
	})

	wml_actions.redraw({
		side = 1
	})

	local highlight = cfg.highlight or false

	if highlight then
		wesnoth.scroll_to_tile(cfg.x, cfg.y)

		wml_actions.highlight_goal({
			x = gatex,
			y = gatey
		})

		wesnoth.scroll_to_tile(wesnoth.current.event_context.x1, wesnoth.current.event_context.y1)

		wml_actions.redraw {}
	end

	-- This is similar to the functionality of [simplify_location_filter]
	-- TODO: consider whether I actually need this
	local var_write = cfg.write or false

	if var_write then
		vars_proxy.temp_gate_locs.x = gatex
		vars_proxy.temp_gate_locs.y = gatey
	end
end

---
-- Displays text mid-screen for a specified time, then fades it out
-- [interim_text]
--     title:         Title displayed
--     text:          Text displayed
--     duration:      Duration of the text after fade-in and before fade-out animations, in milliseconds
-- [/interim_text]
---
function alpha_print(text, size, alpha)
	local c = helper.round(255 * alpha)

	--wesnoth.message(string.format("alpha %0.1f, step %d", alpha ,c))

	wml_actions.print({
		text = text,
		size = size,
		red = c, green = c, blue = c,
		duration = 1000
	})

	wesnoth.delay(20)

	wml_actions.redraw({})
end

function wml_actions.interim_text(cfg)
	local title = cfg.title
	local text = cfg.text
	local duration = cfg.duration
	--local fade_duration = cfg.fade_duration

	if not text then
		text = ""
	end

	if title then
		text = "<span size='larger' weight='bold'>" .. title .. "</span>\n\n" .. text;
	end

	if not duration then
		duration = 5000
	end

	for alpha = 0.0, 1.0, 0.1 do
		alpha_print(text, 20, alpha)
	end

	wesnoth.delay(duration)

	for alpha = 1.0, 0.0, -0.1 do
		alpha_print(text, 20, alpha)
	end

	wesnoth.delay(750)
end

---
-- Hack to immediately remove any [print] text from screen,
-- regardless of the previous message's duration
---
function wml_actions.clear_print()
	wml_actions.print({
		text = "",
		duration = 1
	})

	wesnoth.delay(20)

	wml_actions.redraw({})
end

---
-- Fades out the currently playing music and replaces
-- it with silence afterwards.
--
-- It's not possible to determine at this time whether music
-- is enabled in the first place, so the fade out delay will
-- always occur regardless of the user's preferences.
--
-- [fade_out_music]
--     duration= (optional int, defaults to 1000 ms)
-- [/fade_out_music]
---
function wml_actions.fade_out_music(cfg)
	local duration = cfg.duration

	if not duration then
		duration = 1000
	end

	-- HACK: reserve last 10 milliseconds for the music switch workaround.
	duration = duration - 10

	local function set_music_volume(percentage)
		wesnoth.fire("volume", { music = percentage })
	end

	local delay_granularity = 10

	duration = math.max(delay_granularity, duration)
	local rem = duration % delay_granularity

	if rem ~= 0 then
		duration = duration - rem
	end

	local steps = duration / delay_granularity
	--wesnoth.message(string.format("%d steps", steps))

	for k = 1, steps do
		local v = helper.round(100 - (100*k / steps))
		--wesnoth.message(string.format("step %d, volume %d", k, v))
		set_music_volume(v)
		wesnoth.delay(delay_granularity)
	end

	wesnoth.set_music({
		name = "silence.ogg",
		immediate = true,
		append = false
	})

	-- HACK: give the new track a chance to start playing silently before
	--       resetting to full volume.
	wesnoth.delay(10)

	set_music_volume(100)
end

---
-- Override lp8 [remove_object].
-- Default [filter]x,y=$x1,$y1.
---
do
	local old, f, c = wml_actions.remove_object, {'filter',{}}
	function wml_actions.remove_object(cfg)
		if not wml.get_child(cfg, 'filter') then
			c = wesnoth.current.event_context
			f[2].x, f[2].y = c.x1, c.y1
			cfg = wml.literal(cfg)
			cfg[#cfg+1] = f
		end
		old(cfg)
	end
end

---
-- Deactivates specified sides
-- This removes the sides from the map and side list and stores them
-- in a variable
---
function wml_actions.deactivate_and_serialize_sides(cfg)
	local variable = cfg.variable or "sides"
	local array_index = 0

	vars[variable] = {}

	for t, side_number in helper.get_sides(cfg) do
		-- wesnoth.message("WML", string.format("store side %u", side_number))
		local side_store = string.format("%s[%u]", variable, array_index)

		vars[side_store] = {}

		wesnoth.wml_actions.store_side {
			variable = side_store, side = side_number
		}
		wesnoth.wml_actions.store_unit {
			kill = true,
			variable = side_store .. ".units", { "filter", { side = side_number } }
		}
		wesnoth.wml_actions.modify_side {
			controller = "null", income = -2, gold = 0, village_gold = 0,
			hidden = true, side = side_number
		}

		array_index = array_index + 1
	end
end

---
-- Reactivates sides
-- Re-initializes sides from specified variable
---
function wml_actions.unserialize_and_activate_sides(cfg)
	local variable = cfg.variable or helper.wml_error("[unserialize_and_activate_sides]: Missing variable!")

	local data_set = arrays.get(variable)

	for index, side_data in ipairs(data_set) do
		wesnoth.wml_actions.modify_side {
			side = side_data.side, gold = side_data.gold, village_gold = side_data.village_gold,
			income = side_data.income, controller = side_data.controller, hidden = side_data.hidden
		}

		local units = arrays.get(variable .. string.format("[%u].units", index - 1))

		for uindex, container in ipairs(units) do
			wesnoth.wml_actions.unstore_unit {
				variable = string.format("%s[%u].units[%u]", variable, index - 1, uindex - 1),
				find_vacant = true
			}
		end
	end
end

---
-- Matches a standard location filter and stores the resultant coordinates
-- list in a container with two attributes that are comma-separated lists, .x and .y.
--
-- [simplify_location_filter]
--     ... SLF ...
--     variable="location"
-- [/simplify_location_filter]
---
function serialize_loc_string(slf)
	local locs = wesnoth.get_locations(slf)
	local xstr, ystr = "", ""

	for i, loc in ipairs(locs) do
		if i > 1 then
			xstr = xstr .. string.format(",%d", loc[1])
			ystr = ystr .. string.format(",%d", loc[2])
		else
			xstr = string.format("%d", loc[1])
			ystr = string.format("%d", loc[2])
		end
	end

	return xstr, ystr
end

function wml_actions.simplify_location_filter(cfg)
	local var = cfg.variable or "location"

	vars[var] = nil

	local xstr, ystr = serialize_loc_string(cfg)

	vars[var .. ".x"] = xstr
	vars[var .. ".y"] = ystr
end

---
-- Inserts the data for a spell into the unit's variable.spell table
--
function wml_actions.learn_spell(cfg)
	cfg = wml.literal(cfg)

	local unit = wesnoth.get_units({id = cfg.unit})[1]
	local spells = arrays.get("spell", unit.variables)

	for i, item in ipairs(spells) do
		if item.id == cfg.id then
			log_message(L_ERR, ("spell '%s' already learned by %s"):format(cfg.id, unit.name))
			return
		end
	end

	cfg.cooldown_remaining = 0

	unit.variables[string.format("spell[%d]", #spells)] = cfg

	if not cfg.silent then
		wesnoth.play_sound(cfg.sound or "magic-1.ogg")
	end
end

---
-- Creates a unit that's initially hidden from view as if [hide_unit]
-- was used on it.
--
-- This is necessary since [unit] followed by [hide_unit] allows the unit
-- to be displayed for an instant.
--
-- The syntax is identical to [unit].
---
function wml_actions.hidden_unit(cfg)
	local u = wesnoth.create_unit(cfg)
	-- Don't clobber existing units. We don't check for passability
	-- because we occasionally use this with units that have infinite
	-- movement costs on all terrains, and there's no need to make
	-- this smarter than [unit].
	u.x, u.y = wesnoth.find_vacant_tile(u.x, u.y)
	u.hidden = true
	wesnoth.put_unit(u)
end

---
-- Counts the number of matching units.
--
-- [count_units]
--     ... SUF ...
--     variable=unit_count
-- [/count_units]
---

function wml_actions.count_units(cfg)
	local units = wesnoth.get_units(cfg)
	local varname = cfg.variable or "unit_count"

	if not units then
		vars[varname] = 0
	else
		vars[varname] = #units
	end
end

---
-- Gets the relative direction of a source hex to a target hex.
-- Useful to determine in which direction a unit should be facing
-- (from the source) to look at another unit (at the target).
--
-- NOTE: This initial implementation only handles southwest and
-- southeast. The C++ code handling these calculations isn't exposed
-- to Lua yet, but direction.lua provides an attempt at translating
-- it.
--
-- [store_direction]
--     from_x,from_y= ...
--     to_x,to_y= ...
--     variable="direction"
-- [/store_direction]
--
-- Or:
--
-- [store_direction]
--     [from]
--         ... SLF ...
--     [/from]
--     [to]
--         ... SLF ...
--     [/to]
--     variable="direction"
-- [/store_direction]
---
function wml_actions.store_direction(cfg)
	local from_slf = wml.get_child(cfg, "from")
	local to_slf = wml.get_child(cfg, "to")

	local a = { x = cfg.from_x, y = cfg.from_y }
	local b = { x = cfg.to_x  , y = cfg.to_y   }

	if from_slf then
		a.x = wesnoth.get_locations(from_slf)[1][1]
		a.y = wesnoth.get_locations(from_slf)[1][2]
	end
	if to_slf then
		b.x = wesnoth.get_locations(to_slf)[1][1]
		b.y = wesnoth.get_locations(to_slf)[1][2]
	end

	if not a.x or not a.y or not b.x or not b.y then
		helper.wml_error "[store_direction] missing coordinate!"
	end

	local variable = cfg.variable or "direction"

	-- local facing = loc_relative_direction(b, a) or "sw"
	-- vars[variable] = facing

	if a.x < b.x then
		vars[variable] = "se"
	else
		vars[variable] = "sw"
	end
end

---
-- Changes one or more units' facing to follow the specified location, unit,
-- or direction.
--
-- [set_facing]
--     [filter]
--         ... SUF ...
--     [/filter]
--     [filter_location]
--         ... SLF ...
--     [/filter_location]
-- [/set_facing]
--
-- Or:
--
-- [set_facing]
--     [filter]
--         ... SUF ...
--     [/filter]
--     [filter_second]
--         ... SUF ...
--     [/filter_second]
-- [/set_facing]
--
-- Or:
--
-- [set_facing]
--     [filter]
--         ... SUF ...
--     [/filter]
--     facing= ... direction ...
-- [/set_facing]
---
function wml_actions.set_facing(cfg)
	local suf = wml.get_child(cfg, "filter") or
		helper.wml_error("[set_facing] Missing unit filter")

	local facing = cfg.facing
	local target_suf = wml.get_child(cfg, "filter_second")
	local target_slf = wml.get_child(cfg, "filter_location")

	local target_loc, target_u

	if not facing then
		if target_suf then
			target_u = wesnoth.get_units(target_suf)[1] or
				helper.wml_error("[set_facing] Could not match the specified [filter_second] unit")
		elseif target_slf then
			target_loc = wesnoth.get_locations(target_slf)[1] or
				helper.wml_error("[set_facing] Could not match the specified [filter_location] location")
		end
	end

	local units = wesnoth.get_units(suf) or
		helper.wml_error("[set_facing] Could not match any on-map units with [filter]")

	for i, u in ipairs(units) do
		local new_facing

		if facing then
			new_facing = facing
		elseif target_u then
			new_facing = hex_facing(
				{ x = u.x, y = u.y },
				{ x = target_u.x, y = target_u.y }
			)
		elseif target_loc then
			new_facing = hex_facing(
				{ x = u.x, y = u.y },
				{ x = target_loc[1], y = target_loc[2] }
			)
		else
			helper.wml_error("[set_facing] Missing facing or [filter_second] or [filter_location]")
		end

		if new_facing ~= u.facing then
			u.facing = new_facing

			-- HACK:
			-- Force Wesnoth to re-read the unit's current facing and update the game
			-- display accordingly. Against what one would normally expect, calling
			-- [redraw] does *not* work as an alternative.

			wesnoth.extract_unit(u)
			wesnoth.put_unit(u)
		end
	end
end

---
-- Highlights a given set of target locations at once as a hint for the
-- player.
--
-- [highlight_goal]
--     ... SLF ...
--     image=(optional path to the goal overlay)
-- [/highlight_goal]
---
function wml_actions.highlight_goal(cfg)
	cfg = wml.literal(cfg)

	if not cfg.image then
		cfg.image = "misc/goal-highlight.png"
	end

	for i = 1, 3 do
		wesnoth.wml_actions.item(cfg)
		wesnoth.delay(300)
		wesnoth.wml_actions.remove_item(cfg)
		wesnoth.wml_actions.redraw {}
		wesnoth.delay(300)
	end
end

---
-- Check if a character is present that was created in a previous scenario
--
-- [check_for_character]
--   ... Unit stats ...
-- [/check_for_character]
---
function wml_actions.check_for_character(cfg)
	if not wml_conditionals.have_unit { side = 1, id = cfg.id, search_recall_list = true } then
		wesnoth.put_recall_unit(cfg.__parsed, 1)
	end
end

---
-- Applies a given list of AMLAs to a unit matching the given SUF.
--
-- [apply_amlas]
--     ... SUF ...
--     [advance]
--         ... contents of the [advancement] tag ...
--     [/advance]
--     [advance]
--         ... another AMLA ...
--     [/advance]
--     ...
-- [/apply_amlas]
---
function wml_actions.apply_amlas(cfg)
	local u = wesnoth.get_units(cfg)[1] or helper.wml_error("[apply_amlas]: Could not match any units!")

	for amla_cfg in wml.child_range(cfg, "advancement") do
		wesnoth.add_modification(u, amla_tag, amla_cfg)
	end
end

---
-- Removes an item from the specified character's inventory.
-- If no SUF is provided, the item will be removed from all inventories -
-- ie, all side 1 hero units
--
-- If remove_all is set to true, the item will be removed even if its quantity
-- is greater than 1. If false (default), the quantity will be decreased by 1
-- instead.
--
-- [remove_inventory_item]
--     [filter]
--         ... SUF ...
--     [/filter]
--     item=item id to remove
--     remove_all=(bool, default false)
-- [/remove_inventoru_item]
---
function wml_actions.remove_inventory_item(cfg)
	local filter = wml.get_child(cfg, "filter") or { side = 1, role = "hero" }
	local remove_all = cfg.remove_all or false

	for i, u in ipairs(wesnoth.get_units(filter)) do
		local items = arrays.get("item", u.variables)

		for i, item in ipairs(items) do
			if item.id == cfg.item then
				if item.quantity > 1 and not remove_all then
					item.quantity = item.quantity - 1
				else -- Remove all of this item
					table.remove(vars, i)
				end
			end
		end

		arrays.set(items, "item", u.variables)
	end
end

---
-- Creates an array of the existing advancements a unit has
--
-- [store_amlas]
--     ... SUF ...
--     variable=optional WML array name
-- [/store_amlas]
---
function wml_actions.store_amlas(cfg)
	local unit = wesnoth.get_units(cfg)[1].__cfg
	local mods = wml.get_child(unit, "modifications")

	local var = cfg.variable or "advancements"

	local advancement_table = {}
	for amla in wml.child_range(mods, "advancement") do
		table.insert(advancement_table, amla)
	end

	arrays.set(var, advancement_table)
end
