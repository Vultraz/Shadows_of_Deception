--#textdomain wesnoth-Shadows_of_Deception

local dialogs = nxrequire "gui/dialogs/inv"
local buttons = dialogs.buttons
local invalid_attacks = {ensnare = 1, ["faerie fire"] = 1, fireball = 1, ["magic missile"] = 1, ["mystic fire"] = 1};

-- This brings up the custom inventory control window
function wml_actions.show_inventory(cfg)
	local recipients = vars.adjacent_recipients or nil
	local selected_recipient = 1
	local selected_row = 1
	local page_count = 0
	local unit = wesnoth.get_units(cfg)[1]
	local inv_list_data = {}
	local item_actions, button, continue

	-- Converts first character of a string to uppercase
	local function first_to_upper(str)
		return (tostring(str):gsub("^%l", string.upper))
	end

	-- Checks if we have an item with the given ID
	local function has_item(id)
		for i, item in ipairs(inv_list_data) do
			if item.id == id then return true end
		end

		return false
	end

	-- Syncs weapon data with the table and sorts it
	local function sync_weapons_to_items()
		for attack in wml.child_range(unit.__cfg, 'attack') do
			if not invalid_attacks[attack.name] and not has_item(attack.name) then
				local descrip = string.format("%s - %s %s", attack.damage, attack.number, attack.type)

				table.insert(inv_list_data, {
					id = attack.name,
					name = first_to_upper(attack.description), -- [attack] doesn't have dedicated id keys, and the description is more like a name anyway
					image = attack.icon or string.format("attacks/%s.png", attack.name),
					description = descrip,
					effect_type = "equip",
					active = true,
					quantity = 1,
					T.command {
						T.modify_unit {
							T.filter { x = "$x1", y = "$y1" },
							{ 'effect', lp8.copyTable(attack, { apply_to = 'new_attack' }) }
						}
					},
					T.removal_command {
						T.modify_unit {
							T.filter { x = "$x1", y = "$y1" },
							T.effect { apply_to = "remove_attacks", range = attack.range, name = attack.name }
						}
					}
				})
			end
		end
	end

	local function active_overlay(image)
		return image .. "~BLIT(misc/active_item_indicator.png)"
	end

	-- Prints item list
	local function print_item_list()
		for i, item in ipairs(inv_list_data) do
			if item.active then
				wesnoth.set_dialog_value(active_overlay(item.image), "inventory_list", i, "list_image")
			else
				wesnoth.set_dialog_value(item.image, "inventory_list", i, "list_image")
			end

			wesnoth.set_dialog_value("<big>" .. item.name .. "</big>", "inventory_list", i, "list_name")
			wesnoth.set_dialog_markup(true,                            "inventory_list", i, "list_name")

			wesnoth.set_dialog_value(item.name, "details_pages", i, "details_name")
			wesnoth.set_dialog_value(item.quantity, "inventory_list", i, "list_quantity")
			wesnoth.set_dialog_value(item.description, "details_pages", i, "details_description")

			page_count = i
		end
	end

	-- Refreshes use_button value
	local function refresh_use_button_text(index)
		local item = inv_list_data[index]

		if item.active and item.effect_type == "equip" then
			wesnoth.set_dialog_value(_"Unequip", "use_button")
		elseif not item.active and item.effect_type == "equip" then
			wesnoth.set_dialog_value(_"Equip", "use_button")
		elseif item.effect_type == "message" then
			wesnoth.set_dialog_value(_"Examine", "use_button")
		else
			wesnoth.set_dialog_value(_"Use", "use_button")
		end

		wesnoth.set_dialog_active(
			wesnoth.eval_conditional(
				wml.get_child(item, "usable_if") or {}),
			"use_button")

		-- Override previous active toggle if it's a static
		if item.effect_type == "static" then
			wesnoth.set_dialog_active(false, "use_button")
		end
	end

	-- Sets values for the details panel widgets
	local function select_from_inventory()
		local i = wesnoth.get_dialog_value("inventory_list")

		if i > page_count or page_count == 0 then
			log_message(L_ERR, "BUG: invalid inventory_list row number")

			return
		end

		selected_row = i
		refresh_use_button_text(i)
		wesnoth.set_dialog_value(i, "details_pages")
	end

	local function keep_going()
		return button == buttons.use or
				button == buttons.give or (
					continue and not (
						button == buttons.exit or
						button <= 0
					)
				)
	end

	-- Handles using an item
	local function use_item()
		local i = wesnoth.get_dialog_value("inventory_list")
		local item = inv_list_data[i]

		button = buttons.use
		continue = true

		-- Message effect items don't have any special use commands

		-- If it's single-use, decrease quantity by 1...
		if item.effect_type == "single" then
			item.quantity = (item.quantity or 1) - 1

			wesnoth.set_dialog_value(item.quantity, "inventory_list", i, "list_quantity")

			-- ... and delete it if you now have none
			if item.quantity == 0 then
				table.remove(inv_list_data, i);

				if selected_row == page_count then
					selected_row = selected_row - 1
				end
			end
		end

		-- If it's an equip item...
		if item.effect_type == "equip" then
			-- ... and is not active, activate it
			if not item.active then
				item.active = true

				wesnoth.set_dialog_value(active_overlay(item.image), "inventory_list", i, "list_image")
			else
				item.active = false

				wesnoth.set_dialog_value(item.image, "inventory_list", i, "list_image")

				item_actions = wml.get_child(item, "removal_command")
			end
		end

		-- item_actions can be set previously in a specific effect block
		if item_actions == nil then
			item_actions = wml.get_child(item, "command")
		end

		refresh_use_button_text(i)
	end

	local function give_item()
	end

	local function inventory_preshow()
		wesnoth.set_dialog_value("Inventory — " .. unit.name, "title")
		wesnoth.set_dialog_value(unit.__cfg.image .. "~RC(magenta>red)", "unit_image")

		wesnoth.set_dialog_callback(select_from_inventory, "inventory_list")
		wesnoth.set_dialog_callback(use_item, "use_button")
		wesnoth.set_dialog_callback(give_item, "give_button")

		-- Sets initial values of stuff
		print_item_list()

		wesnoth.set_dialog_value(selected_row, "inventory_list")
		select_from_inventory()

		-- Disable Give button if there are no potential recipients
		if not recipients then
			wesnoth.set_dialog_active(false, "give_button")
		end
	end

	local function inventory_postshow()
		wesnoth.lock_view(true)

		-- Resync the local lua table with the unit variables
		arrays.set("item", inv_list_data, unit.variables)

		-- Execute item effects
		wml_actions.command(item_actions)

		-- We need a delay here to allow for a redraw of the screen and sidebar
		-- I have no idea why a delay allows that to happen
		wesnoth.delay(100)
		wesnoth.lock_view(false)
	end

	repeat
		-- Set variables inside the execution loop to make sure they stay up-to-date each cycle
		inv_list_data = arrays.get("item", unit.variables)
		item_actions = nil

		-- Add valid weapons as [item]s
		sync_weapons_to_items()

		-- Sort items alphabetically
		table.sort(inv_list_data, function(a,b) return tostring(a.name) < tostring(b.name) end)

		if not next(inv_list_data) then
			button = wesnoth.show_dialog(dialogs.empty)
		else
			button = wesnoth.show_dialog(dialogs.normal, inventory_preshow, inventory_postshow)
		end
	until not keep_going()
end
