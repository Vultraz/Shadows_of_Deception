
_ = wesnoth.textdomain 'wesnoth-NX-RPG'
wml_actions = wesnoth.wml_actions
helper = wesnoth.require 'lua/helper.lua'
items = wesnoth.require 'lua/wml/items.lua'
T = helper.set_wml_tag_metatable {}
--debug_utils = wesnoth.require '~add-ons/Wesnoth_Lua_Pack/debug_utils.lua'

for _, module in ipairs {
	'wml';
	'modifications';
} do
	lp8.import(module)
end

function nxrequire(script)
	return wesnoth.require('~add-ons/NX-RPG/lua/' .. script .. '.lua')
end

for _, script in ipairs {
	'debug';
	'theme';
	'wml_tags';
	'gui/main';
} do
	nxrequire(script)
end

