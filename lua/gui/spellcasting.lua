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

		if i > page_count or page_count == 0 then
			wesnoth.fire("wml_message", {
				logger = "error",
				message = "[NX] BUG: invalid spell_list row number"
			})

			return
		end

		selected_row = i
		wesnoth.set_dialog_value(i, "details_pages")
	end

	-- Show details and potential targets for the spell's effect
	local function show_spell_options()
	end

	-- Preshow function
	local function spellcast_preshow()
		-- Prints list of spells
		print_spell_list()
		
		wesnoth.set_dialog_callback(select_spell, "spell_list")
	end

	if spell_list_data == nil then
		wesnoth.show_dialog(dialogs.empty)
	else
		wesnoth.show_dialog(dialogs.normal, spellcast_preshow)
	end 
end
