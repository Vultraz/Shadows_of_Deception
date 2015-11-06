--#textdomain wesnoth-Shadows_of_Deception

local dialogs = nxrequire "gui/dialogs/spellcasting"
local buttons = dialogs.buttons

function wml_actions.show_spell_list(cfg)
	local unit = wesnoth.get_units(cfg)[1].__cfg
	local var = helper.get_child(unit, "variables")
	local spell_list_data = lp8.get_children(var, "spell")
	local page_count

	-- Prints list of spells the current unit has learned
	local function print_spell_list()
		for i, spell in ipairs(spell_list_data) do
			wesnoth.set_dialog_value(spell.image, "spell_list", i, "spell_image")
			wesnoth.set_dialog_value(spell.name, "spell_list", i, "spell_name")
			wesnoth.set_dialog_value(spell.description, "details_pages", i, "details_description")

			-- Sets notice if there are no valid targets
			if not wesnoth.eval_conditional { {'have_location', helper.get_child(spell, 'target_filter')} } then
				wesnoth.set_dialog_value(_"<span color='#ff0000'>No valid targets for this spell.</span>",
					"details_pages", i, "details_notice_validity")
				wesnoth.set_dialog_markup(true,
					"details_pages", i, "details_notice_validity")
			end

			-- Sets notice if the spell is still cooling
			if spell.cooldown_remaining > 0 then
				local turnstext = _"turns remaining"

				if spell.cooldown_remaining == 1 then 
					turnstext = _"turn remaining"
				end

				wesnoth.set_dialog_value(string.format("<span color='#ff0000'>%s\n(<small>%i %s</small>)</span>", _"This spell is cooling down.", spell.cooldown_remaining, turnstext),
					"details_pages", i, "details_notice_cooling")
				wesnoth.set_dialog_markup(true,
					"details_pages", i, "details_notice_cooling")
			end

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
				message = "[SoD] BUG: invalid spell_list row number"
			})

			return
		end

		selected_row = i
		wesnoth.set_dialog_value(i, "details_pages")

		-- Disables the Cast button if the spell is still in cooldown or there are no valid targets
		if spell.cooldown_remaining > 0 or not wesnoth.eval_conditional { {'have_location', helper.get_child(spell, 'target_filter')} } then
			wesnoth.set_dialog_active(false, "cast_button")
		else
			wesnoth.set_dialog_active(true, "cast_button")
		end
	end

	-- Applies the effect of the spell
	-- * Overlays are placed over every location that is a potential target for the spell
	-- * A menu item will show on all of these hexes. Using it triggers the spell
	local function cast_spell()
		local i = wesnoth.get_dialog_value("spell_list")
		local spell = spell_list_data[i]
		local spell_slf = helper.get_child(spell, "target_filter")
		local spell_effect = helper.get_child(spell, "spell_effect")

		-- Catch any case where spell_target is an existing variable
		-- This usually shouldn't happen, but do it anyway to be safe
		if wesnoth.get_variable("spell_target") then
			wesnoth.fire("wml_message", {
				logger = "warning",
				message = "[SoD] variable spell_target already exists"
			})
		end

		spell.cooldown_remaining = spell.cooldown_time or 0

		-- Substitute vars in the target filter. This is relevant so that auto-stored vars
		-- such as $x1 and $y1 will have the values relative to the caster - ie, the unit 
		-- for whom the spellcasting menu item was invoked. Otherwise, they evaluate to values
		-- relative to the target - ie, the unit for whom the 'Cast Spell' menu was invoked
		spell_slf = wesnoth.tovconfig(spell_slf)

		for i, loc in pairs(wesnoth.get_locations(spell_slf)) do
			items.place_image(loc[1], loc[2], "misc/goal-highlight.png")
		end

		-- Don't allow turn end mid-cast
		wml_actions.disallow_end_turn {}

		wml_actions.set_menu_item {
			id = "spell_trigger",
			description = _"Cast Spell: " .. spell.name,
			image = "icons/menu-casting_active.png",
			{"filter_location", spell_slf},
			{"command", {
				{"clear_menu_item", {id = "spell_trigger"}},
				{"remove_item", {image = "misc/goal-highlight.png"}},
				{"set_variable", {name = "spell_target.x", value = "$x1"}},
				{"set_variable", {name = "spell_target.y", value = "$y1"}},
				{"fire_event", {name = spell.id .. "_pre_event"}},
				{"command", spell_effect},
				{"fire_event", {name = spell.id .. "_post_event"}},
				{"clear_variable", {name = "spell_target"}},
				{"allow_end_turn", {}}
			}}
		}

		wesnoth.put_unit(unit)
	end

	local function spellcast_preshow()
		wesnoth.set_dialog_value("Spellcasting — " .. unit.name, "title")
		wesnoth.set_dialog_callback(select_spell, "spell_list")
		wesnoth.set_dialog_callback(cast_spell, "cast_button")

		print_spell_list()

		-- Sets initial values
		wesnoth.set_dialog_value(1, "spell_list")
		select_spell()
	end

	if not next(spell_list_data) then
		wesnoth.show_dialog(dialogs.empty)
	else
		wesnoth.show_dialog(dialogs.normal, spellcast_preshow)
	end 
end

-- Decreases the cooldown time for each spell every turn
function decrease_cooldown_time()
	for unit in lp8.values(wesnoth.get_units {id = 'Niryone, Elynia'}) do
		unit = unit.__cfg

		for spell in lp8.children(helper.get_child(unit, 'variables'), 'spell') do
			if spell.cooldown_remaining > 0 then
				spell.cooldown_remaining = spell.cooldown_remaining - 1
			end
		end

		wesnoth.put_unit(unit)
	end
end

wml_actions.event({
	name = "side 1 turn",
	first_time_only = false,
	{'lua', {code='decrease_cooldown_time()'}}
})
