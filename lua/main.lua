---
-- NX global Lua configuration
---

-- Textdomain
local _ = wesnoth.textdomain 'wesnoth-Shadows_of_Deception'

-- Function aliases
helper      = wesnoth.require 'lua/helper.lua'
items       = wesnoth.require 'lua/wml/items.lua'
on_event    = wesnoth.require 'lua/on_event.lua'
--debug_utils = wesnoth.require '~add-ons/Wesnoth_Lua_Pack/debug_utils.lua'

T          = wml.tag
vars       = wml.variables
vars_proxy = wml.variables_proxy -- TODO: better name
arrays     = wml.array_access

wml_actions      = wesnoth.wml_actions
wml_conditionals = wesnoth.wml_conditionals

---
-- Global utility functions
---

-- Log level aliases
L_ERR  = "error"
L_WARN = "warning"
L_INFO = "info"
L_DBG  = "debug"

-- Prints a wml message in the chat window to the specified logger
function log_message(level, msg)
	wml_actions.wml_message({
		logger = level,
		message = "[SoD] " .. msg
	})
end

---
-- Main file loading logic
---

function nxrequire(script)
	return wesnoth.require(('~add-ons/Shadows_of_Deception/lua/%s.lua'):format(script))
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
