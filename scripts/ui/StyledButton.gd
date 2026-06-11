extends Button

const COLOR_NORMAL := Color("#B8860B")
const COLOR_NORMAL_BORDER := Color("#FFD54F")
const COLOR_HOVER := Color("#C69214")
const COLOR_HOVER_BORDER := Color("#FFD54F")
const COLOR_PRESSED := Color("#9E7300")
const COLOR_PRESSED_BORDER := Color("#E6C04D")
const COLOR_DISABLED := Color("#444444")
const COLOR_DISABLED_BORDER := Color("#666666")
const COLOR_DISABLED_TEXT := Color("#BDBDBD")

const CORNER_RADIUS := 12.0
const BORDER_WIDTH := 2
const CONTENT_MARGIN_H := 28
const CONTENT_MARGIN_V := 14
const H_SEPARATION := 8
const FONT_SIZE := 22
const MIN_HEIGHT := 56


func _ready():
	_load_font()
	_apply_style()


func _load_font():
	var f = load("res://assets/fonts/Bangers-Regular.ttf")
	if f:
		add_theme_font_override("font", f)


func _apply_style():
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(maxf(custom_minimum_size.x, 0), MIN_HEIGHT)
	add_theme_font_size_override("font_size", FONT_SIZE)
	add_theme_constant_override("h_separation", H_SEPARATION)

	add_theme_color_override("font_disabled_color", COLOR_DISABLED_TEXT)

	for state_name in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.corner_radius_top_left = CORNER_RADIUS
		style.corner_radius_top_right = CORNER_RADIUS
		style.corner_radius_bottom_left = CORNER_RADIUS
		style.corner_radius_bottom_right = CORNER_RADIUS
		style.content_margin_left = CONTENT_MARGIN_H
		style.content_margin_right = CONTENT_MARGIN_H
		style.content_margin_top = CONTENT_MARGIN_V
		style.content_margin_bottom = CONTENT_MARGIN_V
		style.border_width_left = BORDER_WIDTH
		style.border_width_right = BORDER_WIDTH
		style.border_width_top = BORDER_WIDTH
		style.border_width_bottom = BORDER_WIDTH
		style.shadow_color = Color(0, 0, 0, 0.25)
		style.shadow_size = 4

		match state_name:
			"normal":
				style.bg_color = COLOR_NORMAL
				style.border_color = COLOR_NORMAL_BORDER
			"hover":
				style.bg_color = COLOR_HOVER
				style.border_color = COLOR_HOVER_BORDER
			"pressed":
				style.bg_color = COLOR_PRESSED
				style.border_color = COLOR_PRESSED_BORDER
			"disabled":
				style.bg_color = COLOR_DISABLED
				style.border_color = COLOR_DISABLED_BORDER

		add_theme_stylebox_override(state_name, style)
