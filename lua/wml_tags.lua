--#textdomain wesnoth-NX-RPG

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
-- Checks every unit matching the SUF's inventory for an certain item.
-- Returns true if a matching item is found.
-- If no [filter] is found, the filter will be all side 1 hero units
--
-- [have_item]
--     [filter][/filter]
--     item=id
-- [/have_item]
---
function wml_actions.have_item(cfg)
	local filter = helper.get_child(cfg, "filter") or { side = 1, role = "hero" }

	for i, u in ipairs(wesnoth.get_units(filter)) do
		if helper.get_child(u.variables.__cfg, "item", cfg.item) then
			return true
		end
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
		terrain = "*^Ng\\",
		{ "or", { terrain = "*^Ng/" } },
		{ "not", { { "filter", {} } } },
	}

	for k, loc in ipairs(locs) do
		wesnoth.put_unit(loc[1], loc[2], {
			type = "Gate",
			side = cfg.side,
			id = string.format("__gate_X%dY%d", loc[1], loc[2]),
		})
	end
end

---
-- Installs mechanical "Gate" units on the given x,y coords using the given owner side.
-- If none are found, they will be placed on all *^Ngl\ and *^Ngl/ hexes instead.
--
-- [unlock_gates]
--     side=3
--     x,y=33,9
-- [/unlock_gates]
---
function wml_actions.unlock_gates(cfg)
	local locs = {}
	if cfg.x or cfg.y then
		locs = wesnoth.get_locations {
			x = cfg.x,
			y = cfg.y,
			{ "not", { { "filter", {} } } },
		}
	else
		locs = wesnoth.get_locations {
			terrain = "*^Ngl\\",
			{ "or", { terrain = "*^Ngl/" } },
			{ "not", { { "filter", {} } } },
		}
	end

	for k, loc in ipairs(locs) do
		wesnoth.put_unit(loc[1], loc[2], {
			type = "Gate",
			side = cfg.side,
			id = string.format("__locked_gate_X%dY%d", loc[1], loc[2]),
		})
		wesnoth.scroll_to_tile(loc[1], loc[2])
		wesnoth.float_label(loc[1], loc[2], "<span color='#e1e119'>Gate unlocked</span>")
	end
end

---
-- Displays text mid-screen for a specified time, then fades it out
-- [intro_text]
--     title:         Title displayed  
--     body:          Text displayed
--     duration:      Duration of the text after fade-in and before fade-out animations, in milliseconds
-- [/intro_text]
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
	local text = cfg.body
	local duration = cfg.duration
	--local fade_duration = cfg.fade_duration

	if text == nil then
		text = ""
	end

	if title ~= nil then
		text = "<span size='larger' weight='bold'>" .. title .. "</span>\n\n" .. text;
	end

	if duration == nil then
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
-- Hack to immedualely remove any [print] text from screen,
-- regardless of the previous message's duration
---
function wml_actions.clear_print()
	wml_actions.print({
		text = " ",
		duration = 1
	})
	
	wesnoth.delay(20)

	wml_actions.redraw({})
end

---
-- Fades out the currently playing music and replaces
-- it with silence afterwards.
--
-- NOTE: A possible timing issue in the sound code causes
-- Wesnoth to emit some short (< 100 ms) noise at the end
-- of the sequence when replacing the music playlist. This
-- also normally occurs when quitting a scenario that uses
-- silence.ogg to return to the titlescreen. It's advised
-- to have some ambient noise playing at the same time
-- [fade_out_music] is used. Furthermore, it's not possible
-- to determine at this time whether music is enabled in
-- the first place, so the fade out delay will always occur
-- regardless of the user's preferences.
--
-- [fade_out_music]
--     duration= (optional int, defaults to 1000 ms)
-- [/fade_out_music]
---
function wml_actions.fade_out_music(cfg)
	local duration = cfg.duration

	if duration == nil then
		duration = 1000
	end

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

	set_music_volume(100)
end

---
-- Override lp8 [remove_object].
-- Default [filter]x,y=$x1,$y1.
---
do
	local old, f, c = wml_actions.remove_object, {'filter',{}}
	function wml_actions.remove_object(cfg)
		if not helper.get_child(cfg, 'filter') then
			c = wesnoth.current.event_context
			f[2].x, f[2].y = c.x1, c.y1
			cfg = helper.literal(cfg)
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

	wesnoth.set_variable(variable, {})

	for t, side_number in helper.get_sides(cfg) do
		-- wesnoth.message("WML", string.format("store side %u", side_number))
		local side_store = string.format("%s[%u]", variable, array_index)

		wesnoth.set_variable(side_store, {})

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

	local data_set = helper.get_variable_array(variable)

	for index, side_data in ipairs(data_set) do
		wesnoth.wml_actions.modify_side {
			side = side_data.side, gold = side_data.gold, village_gold = side_data.village_gold,
			income = side_data.income, controller = side_data.controller, hidden = side_data.hidden
		}

		local units = helper.get_variable_array(variable .. string.format("[%u].units", index - 1))

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
function wml_actions.simplify_location_filter(cfg)
	local var = cfg.variable or "location"
	local locs = wesnoth.get_locations(cfg)
	local xstr, ystr = "", ""

	wesnoth.set_variable(var)

	for i, loc in ipairs(locs) do
		if i > 1 then
			xstr = xstr .. string.format(",%d", loc[1])
			ystr = ystr .. string.format(",%d", loc[2])
		else
			xstr = string.format("%d", loc[1])
			ystr = string.format("%d", loc[2])
		end
	end

	wesnoth.set_variable(var .. ".x", xstr)
	wesnoth.set_variable(var .. ".y", ystr)
end

---
-- Inserts the data for a spell into the unit's variable.spell table
--
function wml_actions.learn_spell(cfg)
	local unit = wesnoth.get_units({id = cfg.unit})[1].__cfg
	local var = helper.get_child(unit, "variables")

	table.insert(var, {"spell", helper.literal(cfg)})

	wesnoth.put_unit(unit)
end
