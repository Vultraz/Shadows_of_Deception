--#textdomain wesnoth-NX-RPG

local dialogs = nxrequire "gui/dialogs/inv"
local buttons = dialogs.buttons

-- This brings up the custom inventory control window
function wml_actions.inventory_controller(cfg)
	local unit = wesnoth.get_variable "unit"
	local which_category_belongs_to_what_unit = {}
	local adjacent_units = wesnoth.get_variable(
		"units_adjacent_to_unit_using_inventory") or {}
	local selected_recipient = 1
	local page_count = 0
	local var, inv_list_data, button, continue
	local command_list = {}

	-- Prints item list.
	local function print_item_list()
		for i, item in ipairs(inv_list_data) do
			if item.active then
				wesnoth.set_dialog_value(item.image .. "~BLIT(misc/active_item_indicator.png,0,0)", "inventory_list", i, "list_image")
			else
				wesnoth.set_dialog_value(item.image, "inventory_list", i, "list_image")
			end

			wesnoth.set_dialog_value(item.name, "inventory_list", i, "list_name")
			wesnoth.set_dialog_value(item.name, "details_pages", i, "details_name")
			wesnoth.set_dialog_value(item.quantity or 1, "inventory_list", i, "list_quantity")
			wesnoth.set_dialog_value(item.description, "details_pages", i, "details_description")

			page_count = i
		end
	end

	-- Refreshes use button value
	local function refresh_use_button_text(index)
		local item = inv_list_data[index]

		if item.active and item.effect_type == "continuous" then
			wesnoth.set_dialog_value("Unequip Item", "use_button")
		else
			wesnoth.set_dialog_value("Use Item", "use_button")
		end

		wesnoth.set_dialog_active(
			wesnoth.eval_conditional(
				helper.get_child(item, "usable_if") or {}),
			"use_button")
	end

	-- Sets values for the details panel widgets
	local function select_from_inventory()
		local i = wesnoth.get_dialog_value("inventory_list")

		if i > page_count or page_count == 0 then
			wesnoth.fire("wml_message", {
				logger = "error",
				message = "[NX] BUG: invalid inventory_list row number"
			})

			return
		end
		refresh_use_button_text(i)
		wesnoth.set_dialog_value(i, "details_pages")
	end

	local function keepGoing()
		return button == buttons.use or
				button == buttons.give or
				button == buttons.drop or (
					continue and not (
						button == buttons.exit or
						button <= 0
					)
				)
	end

	-- Handles using an item
	local function use_item()
		local i = wesnoth.get_dialog_value("inventory_list")
		local item_var = lp8.get_child(var, "item", i)
		local list_item = inv_list_data[i]

		button = buttons.use
		continue = true

		if not list_item.active then
			if list_item.effect_type == "single" then
				item_var.quantity = (list_item.quantity or 1) - 1

				wesnoth.set_dialog_value(
					list_item.quantity, "inventory_list", i, "list_quantity")

				if list_item.quantity == 0 then
					lp8.remove_subtag(var, "item", i)
				end
			end

			if list_item.effect_type == "continuous" then
				wesnoth.set_dialog_value(
					list_item.image
						.. "~BLIT(misc/active_item_indicator.png,0,0)",
					"inventory_list", i, "list_image")
				item_var.active = true
			end

			table.insert(command_list,(helper.get_child(list_item, "command")))
		else
			wesnoth.set_dialog_value(
				list_item.image, "inventory_list", i, "list_image")

			if list_item.effect_type == "continuous" then
				item_var.active = false
			end

			table.insert(command_list,(helper.get_child(list_item, "removal_command")))
		end

		wesnoth.put_unit(unit)
		refresh_use_button_text(i)
	end
	
	-- Preshow function
	local function inventory_preshow()
		-- List for units
		if units_adjacent_to_unit_using_inventory then
			for i = 1, adjacent_units.length do
				table.insert(which_category_belongs_to_what_unit, { id = adjacent_units[i].id } )
			end
		else
			wesnoth.set_dialog_active(false, "give_button")
		end

		wesnoth.set_dialog_value(wesnoth.get_variable("unit.image") .. "~RC(magenta>red)", "unit_image")

		wesnoth.set_dialog_callback(select_from_inventory, "inventory_list")
		wesnoth.set_dialog_callback(use_item, "use_button")

		-- Sets initial values of stuff
		print_item_list()

		wesnoth.set_dialog_value(1, "inventory_list")
		select_from_inventory()

		-- TODO: remove these after their recpective functions have been coded
		wesnoth.set_dialog_active(false, "give_button")
		wesnoth.set_dialog_active(false, "drop_button")
	end

	repeat
		var = helper.get_child(unit, "variables")
		inv_list_data = lp8.get_children(var, "item")
		button = next(inv_list_data)
			and wesnoth.show_dialog(dialogs.normal, inventory_preshow)
			or wesnoth.show_dialog(dialogs.empty)
	until not keepGoing()
	
	for i = 1, #command_list do
		wml_actions.command(command_list[i])
	end
end
