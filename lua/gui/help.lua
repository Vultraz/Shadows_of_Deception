--#textdomain wesnoth-Shadows_of_Deception

local dialog, data, page_count =
	nxrequire 'gui/dialogs/help', nxrequire 'data/help'

local prev_page = 1 

local function select_topic()
	local i = wesnoth.get_dialog_value("topic_list")

	if i > page_count then
		wesnoth.fire("wml_message", {
			logger = "error",
			message = "[SoD] BUG: invalid topic_list row number"
		})

		return
	end

	wesnoth.set_dialog_value("icons/menu-book.png",      "topic_list", prev_page,  "topic_list_image")
	wesnoth.set_dialog_value("icons/menu-book-open.png", "topic_list", i,          "topic_list_image")

	wesnoth.set_dialog_value(i, "help_text_pages")

	-- Keeps a copy of the current page
	prev_page = i
end

local function preshow()
	page_count = #data

	for i, h in ipairs(data) do
		wesnoth.set_dialog_value(h.name, "topic_list", i, "topic_list_name")
		wesnoth.set_dialog_markup(true,  "topic_list", i, "topic_list_name")

		wesnoth.set_dialog_value(h.text, "help_text_pages", i, "topic_text")
		wesnoth.set_dialog_markup(true,  "help_text_pages", i, "topic_text")
	end

	wesnoth.set_dialog_callback(select_topic, "topic_list")

	select_topic()
end

function wml_actions.show_campaign_help()
	wesnoth.show_dialog(dialog, preshow)
end

