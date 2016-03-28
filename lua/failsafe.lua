-- Catches potentially game-breaking conditions and ends the game
-- before it begins.

local maintainer_mode =
	wesnoth.have_file("~add-ons/Shadows_of_Deception/maint-mode.cfg") or
	wesnoth.have_file("~add-ons/NX-RPG/maint-mode.cfg")

local function do_bug(msg, may_ignore)
	wesnoth.wml_actions.bug { message = msg, should_report = false, may_ignore = (maintainer_mode or may_ignore) }
end


if not lp8 then
	do_bug( _ "8680’s Lua Pack (lp8) is missing or not installed, and is required for this campaign to run. Please install 8680’s Lua Pack from the add-ons server, or refer to the included readme.md file for additional options.", false)
end

local ver = wesnoth.game_config.version
local v = wesnoth.compare_versions

if v(ver, '<', '1.12.0') then
	do_bug( _ "Shadows of Deception requires Wesnoth 1.12.0 or later. Please update your Wesnoth installation.", false)
end

if v(ver, '>=', '1.13.0') then
	do_bug( _ "Shadows of Deception is untested on Wesnoth 1.13 and may not function as expected! Please use version 1.12.0 or later.", false)
end
