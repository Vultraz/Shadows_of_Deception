
_ = wesnoth.textdomain 'wesnoth-NX-RPG'
wml_actions = wesnoth.wml_actions
helper = wesnoth.require 'lua/helper.lua'
items = wesnoth.require 'lua/wml/items.lua'
T = helper.set_wml_tag_metatable {}
--debug_utils = wesnoth.require '~add-ons/Wesnoth_Lua_Pack/debug_utils.lua'

if lp8 ~= nil then
	if type(lp8) ~= 'table' or lp8 ~= namespace_of_8680s_Lua_Pack then
		local function dbgstr(x)
			return ('%s(%s)'):format(type(x), tostring(x))
		end
		error(("lp8 is %s; namespace_of_8680s_Lua_Pack is %s"):
			format(dbgstr(lp8),
				dbgstr(namespace_of_8680s_Lua_Pack)))
	end

	for _, module in ipairs {
		'wml';
		'modifications';
		'table';
	} do
		lp8.import(module)
	end
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
