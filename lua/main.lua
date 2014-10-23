-- NX global configuration for Lua.

_ = wesnoth.textdomain 'wesnoth-Shadows_of_Deception'
wml_actions = wesnoth.wml_actions
helper = wesnoth.require 'lua/helper.lua'
items = wesnoth.require 'lua/wml/items.lua'
T = helper.set_wml_tag_metatable {}
--debug_utils = wesnoth.require '~add-ons/Wesnoth_Lua_Pack/debug_utils.lua'

nxconfig = lp8.new_table()

-- nxconfig.name = '{NX_NAME}'

-- #ifdef NX_IS_GIT
-- nxconfig.git = lp8.new_table()
-- nxconfig.git.head = '{NX_GIT_HEAD}'
-- nxconfig.git.branch = nxconfig.git.head:match '^ref: refs/heads/(.+)'
-- #endif

function nxrequire(script)
	return wesnoth.require('~add-ons/Shadows_of_Deception/lua/' .. script .. '.lua')
end

for _, script in ipairs {
	'debug';
	'theme';
	'wml_tags';
	'gui/main';
} do
	nxrequire(script)
end
