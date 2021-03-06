--#textdomain wesnoth-Shadows_of_Deception

---
-- This brings up a dialog when a unit moves to pick up an item.
-- There are 3 choices:
-- * USE:   Apply the item's effect, and add to inventory if effect_type = equip
-- * TAKE:  Add item to inventory. No effect is applied
-- * LEAVE: Do nothing
---

-- The syntax for defining an item pikcup is as follows:

--[[
[take_item]
    id:             Unique ID of the item
    name:           Translatable string that will be displayed in the inventory
    image:          Icon for the item
    description:    Translatable string describing the item
    quantity:       The number of copies of this item the unit will have
    effect_type:    One of "single", "equip", "message", or "static"
    event:          Name of the event to fire once you USE or TAKE the item
                    Defaults to "id .. '_taken'"
    remove_event:   Name of the event to remove once the item is picked up
                    Defaults to "id .. '_pickup'"
    must_take:      Bool (default no). If yes, the option to leave the item will be disabled
    silent:         Bool (default no). If yes, the item vars will be written directly
                    to the unit, with no dialog prompt
    unit:           If specified, the item will be given to the unit with this ID,
                    else, it is given to the unit at $x1, $y1
    remove_image:   Bool (default yes). Whether to remove the item image from the map once
                    it is acquired or not

    [usable_by]
        ... SUF: The item will only be able to be used or taken if the primary
            unit matches this filter
    [/usable_by]

    [usable_if]
        ... The item will only be usable if this condition is matched ...
    [/usable_if]

    [on_use]
        ... Code to execute when item is used
    [/on_use]

    [on_remove]
        ... Code to be executed if item is being unequipped.
            Only applies if effect_type = equip
    [/on_remove]
[/take_item]
--]]


local dialog = nxrequire "gui/dialogs/item_pickup"
local buttons = dialog.buttons
dialog = dialog.dialog

function wml_actions.take_item(cfg)
	-- Parse the toplevel to substitute variables, then write the rest
	-- of the config object as literal to preserve variables for later
	-- access in the inventory
	cfg = wml.shallow_parsed(cfg)
	for subtag in lp8.subtags(cfg) do
		subtag[2] = wml.literal(subtag[2])
	end

	local unit

	if cfg.unit then
		unit = wesnoth.get_units({id = cfg.unit})[1]
	else
		unit = wesnoth.get_units({x = wesnoth.current.event_context.x1, y = wesnoth.current.event_context.y1})[1]
	end

	local must_take = cfg.must_take
	local effect_type = cfg.effect_type or helper.wml_error("[take_item] missing mandatory effect_type key")

	local function item_preshow()
		-- Set all widget starting values
		wesnoth.set_dialog_value(cfg.name, "item_name")
		wesnoth.set_dialog_value(cfg.image or "", "image_name")
		wesnoth.set_dialog_value(cfg.description, "item_description")

		if effect_type == "equip" then
			wesnoth.set_dialog_value(_"Equip", "use_button")
		elseif effect_type == "message" then
			wesnoth.set_dialog_value(_"Examine", "use_button")
		end

		-- For this case, the Use button doesn't get a different value,
		-- and is disabled instead, since this item type has no effect
		if effect_type == "static" then
			wesnoth.set_dialog_active(false, "use_button")
		end

		-- Disable various buttons if the wrong person is attempting to pick up
		-- the item, or if certain conditions have not been met
		local usable_if = wml.get_child(cfg, "usable_if") or {}
		local usable_by = wml.get_child(cfg, "usable_by") or {}

		if must_take then
			wesnoth.set_dialog_active(false, "leave_button")
		end

		if not wesnoth.eval_conditional(usable_if) then
			wesnoth.set_dialog_active(false, "use_button")
		end

		if not wml_conditionals.have_unit(lp8.copyTable(usable_by, { x = "$x1", y = "$y1" })) then
			local cannot_use_message = tostring(usable_by.cannot_use_message or "This unit cannot use this item.")

			wesnoth.set_dialog_value(cannot_use_message, "cannot_use_warning")

			wesnoth.set_dialog_active(false, "use_button")
			wesnoth.set_dialog_active(false, "take_button")

			-- Allow this to override must_take. Not doing so for an item examined by the
			-- wrong person and must_take true would result in all three buttons disabled
			wesnoth.set_dialog_active(true, "leave_button")
		end
	end

	local function set_item_vars(activate)
		local items = arrays.get("item", unit.variables)

		if not cfg.quantity then
			cfg.quantity = 1
		end

		-- If we already have an item with the given ID, bump its qualitity
		for i, item in ipairs(items) do
			if item.id == cfg.id then
				item.quantity = item.quantity + cfg.quantity

				-- We only need to write this one item's config back
				unit.variables[string.format("item[%d]", i - 1)] = item
				return
			end
		end

		-- We didn't have the item. Add it
		if activate then
			cfg.active = true
		end

		-- Write the new item directly to unit.variables since we don't need it locally
		unit.variables[string.format("item[%d]", #items)] = cfg
	end

	local function clean_up_item()
		local event = cfg.event or cfg.id .. "_taken"
		local event_to_remove = cfg.remove_event or cfg.id .. "_pickup"

		local loc_x = wesnoth.current.event_context.x1
		local loc_y = wesnoth.current.event_context.y1

		-- Remove the parent event for the item
		wml_actions.event({ id = event_to_remove, remove = true })

		wesnoth.fire_event(event, loc_x, loc_y)

		local remove_image = cfg.remove_image

		if remove_image == nil then
			remove_image = true
		end

		if remove_image then
			items.remove(loc_x, loc_y)
		end
	end

	if cfg.silent then
		set_item_vars()

		return
	end

	local button

	-- Hack to disable Esc key escaping from the dialog if must_take is true
	-- -2 is the value returned by a GUI2 dialog when exited with Esc
	if must_take then
		repeat button = wesnoth.show_dialog(dialog, item_preshow) until button ~= -2
	else
		button = wesnoth.show_dialog(dialog, item_preshow)
	end

	if button == buttons.use or button == -1 then
		if effect_type == "equip" then
			set_item_vars('and activate item')
		end

		wml_actions.command(wml.get_child(cfg, "on_use") or {})

		if effect_type ~= "message" then
			clean_up_item()
		end
	end

	if button == buttons.take then
		set_item_vars()
		clean_up_item()
	end
end
