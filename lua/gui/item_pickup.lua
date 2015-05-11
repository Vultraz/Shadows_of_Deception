--#textdomain wesnoth-Shadows_of_Deception

---
-- This brings up a dialog when a unit moves to pick up an item.
-- There are 3 choices:
-- * USE:   Apply the item's effect, and add to inventory if effect_type = equip
-- * TAKE:  Add item to inventory. No effect is applied
-- * LEAVE: Do nothing
--
-- [take_item]
--     id=must be unique
--     name= _ "string"
--     image=path/to/image.png
--     description= _ "translatable string"
--     effect_type=use either "single" or "equip"
--     event=the name of the event to fire if you USE or TAKE the item
--     must_take=yes/no
--     [usable_by]
--         ... SUF: The item will only be able to be used or taken if the primary
--             unit matches this filter
--     [/usable_by]
--     [usable_if]
--         ... The item will only be usable if this condition is matched ...
--     [/usable_if]
--     [command]
--         ... Code to execute when item is used
--     [/command]
--     [removal_command]
--         ... Code to be executed if item is being unequipped.
--             Only applies if effect_type = equip
--     [/removal_command]
-- [/take_item]
---

local dialog = nxrequire "gui/dialogs/item_pickup"
local buttons = dialog.buttons
dialog = dialog.dialog

function wml_actions.take_item(cfg)
	-- Parse the toplevel to substitute variables, then write the rest
	-- of the config object as literal to preserve variables for later
	-- access in the inventory
	cfg = helper.shallow_parsed(cfg)
	for subtag in lp8.subtags(cfg) do
		subtag[2] = helper.literal(subtag[2])
	end

	local unit = wesnoth.get_units({x = wesnoth.current.event_context.x1, y = wesnoth.current.event_context.y1})[1].__cfg
	local vars = helper.get_child(unit, "variables")

	local function item_preshow()
		-- Set all widget starting values
		wesnoth.set_dialog_value ( cfg.name, "item_name" )
		wesnoth.set_dialog_value ( cfg.image or "", "image_name" )
		wesnoth.set_dialog_value ( cfg.description, "item_description" )

		if cfg.effect_type == "equip" then
			wesnoth.set_dialog_value(_"Equip", "use_button")
		elseif cfg.effect_type == "message" then
			wesnoth.set_dialog_value(_"Examine", "use_button")
		end

		-- Disable various buttons if the wrong person is attempting to pick up
		-- the item, or if certain conditions have not been met
		local usable_if = helper.get_child(cfg, "usable_if") or {}
		local usable_by = helper.get_child(cfg, "usable_by")

		if not wesnoth.eval_conditional(usable_if) then
			wesnoth.set_dialog_active(false, "use_button")
		end

		if not wesnoth.eval_conditional { { "have_unit", lp8.copyTable(usable_by, { x,y = "$x1,$y1" }) } } then
			wesnoth.set_dialog_value(tostring(usable_by.cannot_use_message), "cannot_use_warning")

			wesnoth.set_dialog_active(false, "use_button")
			wesnoth.set_dialog_active(false, "take_button")
		end

		if cfg.must_take then
			wesnoth.set_dialog_active(false, "leave_button")
		end
	end

	local function set_item_vars(activate)
		local item = helper.get_child(vars, "item", cfg.id)

		if item then
			item.quantity = (item.quantity or 0) + 1
		else
			if activate then
				cfg.active = true
			end
			table.insert(vars, {"item", cfg})
		end

		wesnoth.put_unit(unit)
	end

	local function clean_up_item()
		local event = cfg.event or cfg.id .. "_taken"
		local loc_x = wesnoth.current.event_context.x1
		local loc_y = wesnoth.current.event_context.y1

		-- Remove the parent event for the item
		wml_actions.event({ id = cfg.id .. "_pickup", remove = true })

		wesnoth.fire_event(event, loc_x, loc_y)

		items.remove(loc_x, loc_y)
	end

	if cfg.silent then
		set_item_vars()

		return
	end

	local button = wesnoth.show_dialog(dialog, item_preshow)

	if button == buttons.use or button == -1 then
		if cfg.effect_type == "equip" then
			set_item_vars('and activate item')
		end

		wml_actions.command(helper.get_child(cfg, "command"))

		if cfg.effect_type ~= "message" then
			clean_up_item()
		end
	end

	if button == buttons.take then
		set_item_vars()
		clean_up_item()
	end
end
