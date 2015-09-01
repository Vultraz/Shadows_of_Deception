---
-- NX global Lua configuration
---

-- Textdomain
_ = wesnoth.textdomain 'wesnoth-Shadows_of_Deception'

-- Function aliases
helper      = wesnoth.require 'lua/helper.lua'
items       = wesnoth.require 'lua/wml/items.lua'
--debug_utils = wesnoth.require '~add-ons/Wesnoth_Lua_Pack/debug_utils.lua'

T = helper.set_wml_tag_metatable {}

wml_actions      = wesnoth.wml_actions
wml_conditionals = wesnoth.wml_conditionals or {} -- Table fallback for use in 1.12

---
-- Main file loading logic
---

function nxrequire(script)
	if wesnoth.have_file( "~add-ons/Shadows_of_Deception/_main.cfg" ) then
		return wesnoth.require('~add-ons/Shadows_of_Deception/lua/' .. script .. '.lua')
	else
		return wesnoth.require('~add-ons/NX-RPG/lua/' .. script .. '.lua')
	end
end

for _, script in ipairs {
	'hex';
	'spawner';
	'wml_tags';
	'conditional_tags';
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
