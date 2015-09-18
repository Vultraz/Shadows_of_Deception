--#textdomain wesnoth-Shadows_of_Deception

---
-- Checks inventory of every unit matching the SUF for an certain item.
-- Returns true if a matching item is found.
-- If no SUF is provided, all side 1 hero units will be checked.
--
-- [have_item]
--     ... SUF ...
--     item=id
-- [/have_item]
---
function wml_conditionals.have_item(cfg)
	local units = wesnoth.get_units(cfg)

	if not units then
		units = wesnoth.get_units({ side = 1, role = "hero" })
	end

	for i, u in ipairs(units) do
		if helper.get_child(u.variables.__cfg, "item", cfg.item) then
			return true
		end
	end

	return false
end

---
-- Checks every unit matching the SUF for an AMLA of the specified id.
-- Returns true if a matching advancement is found to be already acquired.
-- Note that this tag does *not* check advancement possibilities a unit has.
--
-- [have_amla]
--     ... SUF ...
--     advancement=id
-- [/have_amla]
---
function wml_conditionals.have_amla(cfg)
	for i, u in ipairs(wesnoth.get_units(cfg)) do
		local mods = helper.get_child(u.__cfg, "modifications")

		local amla_tag = "advance"
		if wesnoth.compare_versions(wesnoth.game_config.version, '>', '1.13.1') then
			amla_tag = "advancement"
		end

		for amla in helper.child_range(mods, amla_tag) do
			if amla.id == cfg.advancement then return true end
		end
	end

	return false
end
