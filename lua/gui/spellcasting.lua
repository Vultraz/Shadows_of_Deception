--#textdomain wesnoth-NX-RPG

local dialogs = nxrequire "gui/dialogs/spellcasting"
local buttons = dialogs.buttons

function wml_actions.spellcasting_controller(cfg)
	local unit = wesnoth.get_variable "unit"
	local var = helper.get_child(unit, "variables")
	local spell_list_data = lp8.get_children(var, "spell")
	local page_count

	-- Prints list of spells the current unit has learned
	local function print_spell_list()
		for i, spell in ipairs(spell_list_data) do
			wesnoth.set_dialog_value(spell.image, "spell_list", i, "spell_image")
			wesnoth.set_dialog_value(spell.name, "spell_list", i, "spell_name")
			wesnoth.set_dialog_value(spell.description, "details_pages", i, "details_description")

			page_count = i
		end
	end

	-- Sets values for the details panel widgets
	local function select_spell()
		local i = wesnoth.get_dialog_value("spell_list")
		local spell = spell_list_data[i]

		if i > page_count or page_count == 0 then
			wesnoth.fire("wml_message", {
				logger = "error",
				message = "[NX] BUG: invalid spell_list row number"
			})

			return
		end

		selected_row = i
		wesnoth.set_dialog_value(i, "details_pages")

		-- Disables the Cast button if the spell is still in cooldown
		wesnoth.set_dialog_active(wesnoth.eval_conditional(spell.cooldown_remaining == 0), "cast_button")
	end

	-- Applies the effect of the spell
	-- Overlays are placed over every location a potential target for the spell
	-- A menu item that shows on all of these hexes. Using it triggers the spell
	local function cast_spell()
		local i = wesnoth.get_dialog_value("spell_list")
		local list_spell = spell_list_data[i]
		local loc_filter = helper.get_child(list_spell, "target_filter")
		local effect = helper.get_child(list_spell, "spell_effect")
		local pre_event = string.format("%s%s", list_spell.id, "_pre_event")
		local post_event = string.format("%s%s", list_spell.id, "_post_event")

		for i, loc in ipairs(wesnoth.get_locations(loc_filter)) do
			items.place_image(loc[1], loc[2], "misc/goal-highlight.png")
		end

		wml_actions.set_menu_item {
			id = "spell_trigger",
			description = _"Cast " .. list_spell.name .. " Spell",
			image = "icons/menu-casting.png",
			{"filter_location", loc_filter},
			{"command", {
				{"clear_menu_item", {id = "spell_trigger"}},
				{"remove_item", {image = "misc/goal-highlight.png"}},
				{"set_variable", {name = "spell_target.x", value = "$x1"}},
				{"set_variable", {name = "spell_target.y", value = "$y1"}},
				{"fire_event", {name = pre_event}},
				{"command", effect},
				{"fire_event", {name = post_event}},
				{"set_variable", {name = string.format("$unit.variables.spells[%i]", i), value = list_spell.cooldown_time or 0}},
				{"clear_variable", {name = "spell_target"}}
			}
		}}
	end

	local function spellcast_preshow()		
		wesnoth.set_dialog_callback(select_spell, "spell_list")
		wesnoth.set_dialog_callback(cast_spell, "cast_button")

		-- Sets initial values
		print_spell_list()

		wesnoth.set_dialog_value(1, "spell_list")
		select_spell()
	end

	if not next(spell_list_data) then
		wesnoth.show_dialog(dialogs.empty)
	else
		wesnoth.show_dialog(dialogs.normal, spellcast_preshow)
	end 
end
