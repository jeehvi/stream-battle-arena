extends MarginContainer

const MARGIN_LEFT := 0.04
const MARGIN_RIGHT := 0.04
const MARGIN_TOP := 0.06
const MARGIN_BOTTOM := 0.06


func _ready():
	get_viewport().size_changed.connect(_update_margins)
	_update_margins()


func _update_margins():
	var parent_size = get_parent().size
	if parent_size.x <= 0 or parent_size.y <= 0:
		return
	add_theme_constant_override("margin_left", parent_size.x * MARGIN_LEFT)
	add_theme_constant_override("margin_right", parent_size.x * MARGIN_RIGHT)
	add_theme_constant_override("margin_top", parent_size.y * MARGIN_TOP)
	add_theme_constant_override("margin_bottom", parent_size.y * MARGIN_BOTTOM)
