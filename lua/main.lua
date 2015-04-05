-- NX global configuration for Lua.

_ = wesnoth.textdomain 'wesnoth-Shadows_of_Deception'
wml_actions = wesnoth.wml_actions
helper = wesnoth.require 'lua/helper.lua'
items = wesnoth.require 'lua/wml/items.lua'
T = helper.set_wml_tag_metatable {}
--debug_utils = wesnoth.require '~add-ons/Wesnoth_Lua_Pack/debug_utils.lua'

function nxrequire(script)
	if wesnoth.have_file( "~add-ons/Shadows_of_Deception/_main.cfg" ) then
		return wesnoth.require('~add-ons/Shadows_of_Deception/lua/' .. script .. '.lua')
	else
		return wesnoth.require('~add-ons/NX-RPG/lua/' .. script .. '.lua')
	end
end

for _, script in ipairs {
	'debug';
	'theme';
	'hex';
	'spawner';
	'wml_tags';
	'gui/bug';
	'gui/help';
	'gui/inventory';
	'gui/item_pickup';
	'gui/spellcasting';
	'gui/transient_message';
	'failsafe';
} do
	nxrequire(script)
end
