
local buttons = {
	cast = 2;
	exit = 1;
}

local spell_list = T.listbox {
	id = "spell_list",
	vertical_scrollbar_mode = "auto",
	T.list_definition {
		T.row {
			T.column {
				grow_factor = 1,
				horizontal_grow = true,
				vertical_grow = true,
				T.toggle_panel {
					T.grid {
						T.row {
							grow_factor = 1,
							T.column {
								border = "all",
								border_size = 5,
								horizontal_alignment = "left",
								T.image {
									id = "spell_image",
									linked_group = "image"
								}
							},
							T.column {
								border = "all",
								border_size = 5,
								horizontal_alignment = "left",
								T.label {
									id = "spell_name",
									linked_group = "name"
								}
							}
						}
					}
				}
			}
		}
	}
}

local spell_details_pages = T.multi_page {
	id = "details_pages",
	T.page_definition {
		T.row {
			grow_factor = 1,
			T.column {
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				vertical_alignment = "top",
				T.scroll_label {
					id = "details_description",
					wrap = true
				}
			}
		},
		T.row {
			grow_factor = 1,
			T.column {
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				vertical_alignment = "top",
				T.scroll_label {
					id = "spell_details",
					wrap = true
				}
			}
		}
	}
}

local main_window = {
	maximum_height = 700,
	maximum_width = 850,

	T.helptip { id = "tooltip_large" }, -- mandatory field
	T.tooltip { id = "tooltip_large" }, -- mandatory field

	T.linked_group { id = "image", fixed_width = true },
	T.linked_group { id = "name", fixed_width = true },

	T.grid {
		T.row {
			grow_factor = 1,
			T.column {
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				T.label {
					definition = "title",
					label = _"Spellcasting"
				}
			}
		},
		T.row {
			grow_factor = 1,
			T.column {
				T.grid {
					T.row {
						T.column {
							border = "all",
							border_size = 5,
							horizontal_grow = "true",
							spell_list
						},
						T.column {
							border = "all",
							border_size = 5,
							horizontal_grow = "true",
							spell_details_pages
						}
					}
				}
			}
		},
		T.row {
			grow_factor = 1,
			T.column {
				T.grid {
					T.row {
						T.column {
							border = "all",
							border_size = 5,
							horizontal_grow = "true",
							T.button {
								id = "cast_button",
								return_value = buttons.cast,
								label = _"Cast Spell"
							}
						},
						T.column {
							border = "all",
							border_size = 5,
							horizontal_grow = "true",
							T.button {
								id = "ok_button",
								return_value = buttons.exit,
								label = _"Exit"
							}
						}
					}
				}
			}
		}
	}
}

local empty_spell_window = {
	maximum_height = 100,
	maximum_width = 800,

	click_dismiss = true,

	T.helptip { id = "tooltip_large" }, -- mandatory field
	T.tooltip { id = "tooltip_large" }, -- mandatory field

	T.grid {
		T.row {
			grow_factor = 1,
			T.column {
				border = "all",
				border_size = 5,
				T.image {
					label = "icons/casting_icon.png"
				}
			},
			T.column {
				border = "all",
				border_size = 5,
				vertical_alignment = "center",
				horizontal_alignment = "center",
				T.label {
					label = _"You do not have any spells learned."
				}
			}
		}
	}
}

return {
	buttons = buttons;
	normal = main_window;
	empty = empty_spell_window;
}
