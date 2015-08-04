--#textdomain wesnoth-Shadows_of_Deception

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
function wml_conditionals.have_item(cfg)
	local filter = helper.get_child(cfg, "filter") or { side = 1, role = "hero" }

	for i, u in ipairs(wesnoth.get_units(filter)) do
		if helper.get_child(u.variables.__cfg, "item", cfg.item) then
			return true
		end
	end
end
