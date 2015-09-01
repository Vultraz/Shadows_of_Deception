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

-- Compatibility with old directory name. Remove once 1.12 support is dropped
local basedir = "Shadows_of_Deception"

if wesnoth.have_file("~add-ons/NX-RPG/_main.cfg") then
	basedir = "NX-RPG"
end

function nxrequire(script)
	return wesnoth.require('~add-ons/' .. basedir .. '/lua/' .. script .. '.lua')
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
