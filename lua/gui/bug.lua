-- #textdomain wesnoth-Shadows_of_Deception

---
-- Displays an error message on a popup dialog.
--
-- This is intended to be used as an exit mechanism when the WML detects an
-- inconsistency (see the BUG and BUG_ON macros in macros/debug-utils.cfg
--
-- [bug]
--     message= <...>
--     # Optional conditional statement
--     [condition]
--         ...
--     [/condition]
-- [/bug]
---

local dialogs = nxrequire "gui/dialogs/bug"

function wml_actions.bug(cfg)
	local cond = wml.get_child(cfg, "condition")

	if cond and not wesnoth.eval_conditional(cond) then
		return
	end

	local report = cfg.should_report
	local notice = cfg.message
	local log_notice = notice
	local may_ignore = cfg.may_ignore

	if not log_notice or log_notice == "" then
		log_notice = "inconsistency detected"
	end

	if report == nil then
		report = true
	end

	if may_ignore == nil then
		may_ignore = true
	end

	log_message(L_ERR, "BUG: " .. log_notice)

	local function show_details()
		local cap = _ "Details"
		local msg = _ "The following WML condition was unexpectedly reached:"

		-- #textdomain wesnoth
		local _ = wesnoth.textdomain "wesnoth"
		local ok = _ "Close"

		wesnoth.show_dialog(dialogs.dialog, function()
			wesnoth.set_dialog_value(cap, "title")
			wesnoth.set_dialog_value(msg, "message")
			wesnoth.set_dialog_value(wesnoth.debug(cond), "wml")
			wesnoth.set_dialog_value(ok, "ok")
		end)
	end

	local function preshow()
		-- #textdomain wesnoth-Shadows_of_Deception
		local _ = wesnoth.textdomain "wesnoth-Shadows_of_Deception"
		local msg = _ "An inconsistency has been detected, and the scenario might not continue working as originally intended."

		if report then
			msg = msg .. "\n\n" .. _ "Please report this to the campaign maintainer!"
		end

		if notice ~= nil and notice ~= "" then
			msg = msg .. "\n\n" .. _ "Message:"
			msg = msg .. "\n\t" .. cfg.message
		end

		msg = msg .. "\n"

		local cap = _ "Error"
		local det = _ "Details"

		-- #textdomain wesnoth
		local _ = wesnoth.textdomain "wesnoth"
		local ok = _ "Continue"
		local quit = _ "Quit"

		-- #textdomain wesnoth-Shadows_of_Deception
		local _ = wesnoth.textdomain "wesnoth-Shadows_of_Deception"

		wesnoth.set_dialog_value(cap, "title")
		wesnoth.set_dialog_value(msg, "message")
		wesnoth.set_dialog_value(det, "details")
		wesnoth.set_dialog_value(ok , "ok")
		wesnoth.set_dialog_value(quit , "quit")

		if cond then
			wesnoth.set_dialog_callback(show_details, "details")
		else
			wesnoth.set_dialog_active(false, "details")
		end

		if not may_ignore then
			wesnoth.set_dialog_active(false, "ok")
		end
	end

	local result = wesnoth.show_dialog(dialogs.alert, preshow, nil)

	if result == 2 or not may_ignore then
		wesnoth.fire("endlevel", {
			result = "defeat",
			linger_mode = false,
		})
	end
end
