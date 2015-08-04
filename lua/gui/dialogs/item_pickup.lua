--#textdomain wesnoth-Shadows_of_Deception

local buttons = {
	use = 1;
	take = 2;
	leave = 3;
}

local item_dialog = {
	maximum_height = 320,
	maximum_width = 480,
	T.helptip { id="tooltip_large" }, -- mandatory field
	T.tooltip { id="tooltip_large" }, -- mandatory field
	T.grid {
		T.row {
			T.column {
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				T.label {
					definition = "title",
					id = "item_name"
				}
			}
		},
		T.row {
			T.column {
				horizontal_grow = "true",
				T.grid {
					T.row {
						T.column {
							border = "all",
							border_size = 5,
							vertical_alignment = "center",
							horizontal_alignment = "left",
							T.image {
								id = "image_name"
							}
						},
						T.column {
							horizontal_alignment = "left",
							T.grid {
								T.row {
									T.column {
										border = "all",
										border_size = 5,
										horizontal_alignment = "left",
										T.scroll_label {
											id = "item_description",
										}
									}
								},
								T.row {
									T.column {
										border = "all",
										border_size = 5,
										horizontal_alignment = "left",
										T.label {
											id = "cannot_use_warning",
											wrap = true
										}
									}
								}
							}
						}
					}
				}
			}
		},
		T.row {
			T.column {
				horizontal_alignment = "right",
				T.grid {
					T.row {
						T.column {
							border = "all",
							border_size = 5,
							T.button {
								id = "use_button",
								return_value = buttons.use,
								label = _"Use"
							}
						},
						T.column {
							border = "all",
							border_size = 5,
							T.button {
								id = "take_button",
								return_value = buttons.take,
								label = _"Take"
							}
						},
						T.column {
							border = "all",
							border_size = 5,
							T.button {
								id = "leave_button",
								return_value = buttons.leave,
								label = _"Leave"
							}
						}
					}
				}
			}
		}
	}
}

return {
	buttons = buttons;
	dialog = item_dialog;
}
