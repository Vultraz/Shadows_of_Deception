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
	local selected_row = 1
	local page_count = 0
	local var, inv_list_data, button, continue
	local command_list = {}
	local valid_attacks = {axe = 1, ["battle axe"] = 1, bow = 1, broadsword = 1, dagger = 1, crossbow = 1, hammer = 1, javelin = 1, lance = 1, spear = 1, staff = 1}; 

	-- Syncs weapon data with the table and sorts it
	local function sync_and_sort_items()
		for i, attack in pairs(lp8.get_children(unit, 'attack')) do
			if valid_attacks[attack.name] and not helper.get_child(var, "item", attack.name) then
				local descrip = string.format("%s - %s %s", attack.damage, attack.number, attack.type)

				-- [attack] doesn't have dedicated id keys, and the description is more like a name anyway
				table.insert(inv_list_data, { id = attack.name, name = attack.description, image = attack.icon, description = descrip, effect_type = "continuous", active = true,
					{ "command", { "object", { silent = true, duration = "forever",
						{ "effect", { apply_to = "new_attack",
							{ "attack", attack } }
						} } }
					},
					{ "removal_command", { "object", { silent = true, duration = "forever",
						{ "effect", { apply_to = "remove_attack", range = attack.range, name = attack.name } } } }
					}
				})
			end
		end

		-- Sorts the table alphabetacally by the name keys' value
		table.sort(inv_list_data, function(a,b) return a.name < b.name end)
	end

	-- Prints item list
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
			wesnoth.set_dialog_value(_"Unequip Item", "use_button")
		elseif not item.active and item.effect_type == "continuous" then
			wesnoth.set_dialog_value(_"Equip Item", "use_button")
		else
			wesnoth.set_dialog_value(_"Use Item", "use_button")
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

		selected_row = i
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

		-- If item is not active...
		if not list_item.active then
			-- ... and if it's single-use, decrease quantity by 1
			if list_item.effect_type == "single" then
				item_var.quantity = (list_item.quantity or 1) - 1

				wesnoth.set_dialog_value(
					list_item.quantity, "inventory_list", i, "list_quantity")

				-- Delete item if you now have none of it
				if list_item.quantity == 0 then
					lp8.remove_subtag(var, "item", i)
				end
			end

			-- ... and if it's continuous-use, activate it
			if list_item.effect_type == "continuous" then
				wesnoth.set_dialog_value(
					list_item.image
						.. "~BLIT(misc/active_item_indicator.png,0,0)",
					"inventory_list", i, "list_image")
				item_var.active = true
			end

			table.insert(command_list,(helper.get_child(list_item, "command")))

		-- But if it was already active, therefor it was a continuous-use item
		-- So just deactivate it
		else
			wesnoth.set_dialog_value(
				list_item.image, "inventory_list", i, "list_image")

			item_var.active = false

			table.insert(command_list,(helper.get_child(list_item, "removal_command")))
		end

		refresh_use_button_text(i)
	end

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

		wesnoth.set_dialog_value(selected_row, "inventory_list")
		select_from_inventory()

		-- TODO: remove these after their recpective functions have been coded
		wesnoth.set_dialog_active(false, "give_button")
		wesnoth.set_dialog_active(false, "drop_button")
	end

	repeat
		-- Keep all tables and main variables up to date
		var = helper.get_child(unit, "variables")
		inv_list_data = lp8.get_children(var, "item")
		sync_and_sort_items() -- Adds weapons to inv_list_data and sorts it alphabetacally
		button = next(inv_list_data)
			and wesnoth.show_dialog(dialogs.normal, inventory_preshow)
			or wesnoth.show_dialog(dialogs.empty)
	until not keepGoing()

	-- Resyncs the local lua tables with the actual unit
	wesnoth.put_unit(unit)

	for i = 1, #command_list do
		wml_actions.command(command_list[i])
	end
end
