-- Catches potentially game-breaking conditions and ends the game
-- before it begins.

local function do_bug(msg, may_ignore)
	wesnoth.wml_actions.bug { message = msg, should_report = false, may_ignore = may_ignore }
end


if not lp8 then
	do_bug( _ "8680’s Lua Pack (lp8) is missing or not installled, and is required for this campaign to run. Please install 8680’s Lua Pack from the add-ons server, or refer to the included readme.md file for additional options.", false)
end

local ver = wesnoth.game_config.version
local v = wesnoth.compare_versions

if v(ver, '<', '1.11.11') then
	do_bug( _ "Shadows of Deception requires Wesnoth 1.11.11 or later.", false)
end
