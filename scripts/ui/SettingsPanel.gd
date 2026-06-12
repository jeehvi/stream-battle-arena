extends Control

const StyledButton = preload("res://scripts/ui/StyledButton.gd")

var _volume_slider: HSlider
var _volume_value_label: Label
var _display_mode: OptionButton
var _save_btn: Button
var _save_feedback: Label


func _init():
	GameSettings.load_settings()
	_setup_ui()
	_load_ui_values()


func _load_ui_values():
	_volume_slider.value = GameSettings.master_volume
	_volume_value_label.text = "%d%%" % clampi(roundi(GameSettings.master_volume), 0, 100)
	_display_mode.selected = GameSettings.display_mode


func _setup_ui():
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0

	var bg = ColorRect.new()
	bg.name = "BlackBackground"
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color("#000000")
	add_child(bg)

	var center = VBoxContainer.new()
	center.name = "Center"
	center.anchor_left = 0.5
	center.anchor_top = 0.5
	center.anchor_right = 0.5
	center.anchor_bottom = 0.5
	center.offset_left = -220.0
	center.offset_top = -200.0
	center.offset_right = 220.0
	center.offset_bottom = 200.0
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 0)
	add_child(center)

	var title = Label.new()
	title.text = "SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	center.add_child(title)

	center.add_child(_spacer(32))

	var audio_title = Label.new()
	audio_title.text = "AUDIO"
	audio_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	audio_title.add_theme_font_size_override("font_size", 24)
	audio_title.add_theme_color_override("font_color", Color("#CCCCCC"))
	center.add_child(audio_title)

	center.add_child(_spacer(12))
	center.add_child(_build_volume_row())
	center.add_child(_spacer(24))

	var display_title = Label.new()
	display_title.text = "DISPLAY"
	display_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	display_title.add_theme_font_size_override("font_size", 24)
	display_title.add_theme_color_override("font_color", Color("#CCCCCC"))
	center.add_child(display_title)

	center.add_child(_spacer(12))
	center.add_child(_build_display_row())
	center.add_child(_spacer(24))

	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	center.add_child(btn_row)

	_save_btn = StyledButton.new()
	_save_btn.text = "SAVE"
	_save_btn.pressed.connect(_on_save_pressed)
	btn_row.add_child(_save_btn)

	var back_btn = StyledButton.new()
	back_btn.text = "BACK"
	back_btn.pressed.connect(_on_back_pressed)
	btn_row.add_child(back_btn)

	_save_feedback = Label.new()
	_save_feedback.text = ""
	_save_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_save_feedback.add_theme_color_override("font_color", Color("#4CAF50"))
	_save_feedback.add_theme_font_size_override("font_size", 20)
	_save_feedback.custom_minimum_size = Vector2(0, 28)
	center.add_child(_save_feedback)


func _build_volume_row() -> HBoxContainer:
	var row = HBoxContainer.new()
	row.name = "VolumeRow"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)

	var label = Label.new()
	label.text = "Master Volume"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(130, 30)
	row.add_child(label)

	_volume_slider = HSlider.new()
	_volume_slider.name = "VolumeSlider"
	_volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_volume_slider.custom_minimum_size = Vector2(120, 30)
	_volume_slider.min_value = 0.0
	_volume_slider.max_value = 100.0
	_volume_slider.step = 1.0
	_style_slider(_volume_slider)
	_volume_slider.value_changed.connect(_on_volume_changed)
	row.add_child(_volume_slider)

	_volume_value_label = Label.new()
	_volume_value_label.name = "VolumeValue"
	_volume_value_label.text = "80%"
	_volume_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_volume_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_volume_value_label.custom_minimum_size = Vector2(40, 30)
	_volume_value_label.add_theme_color_override("font_color", Color("#D4AF37"))
	row.add_child(_volume_value_label)

	return row


func _build_display_row() -> HBoxContainer:
	var row = HBoxContainer.new()
	row.name = "DisplayRow"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)

	var label = Label.new()
	label.text = "Display Mode"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(130, 30)
	row.add_child(label)

	_display_mode = OptionButton.new()
	_display_mode.name = "DisplayMode"
	_display_mode.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_display_mode.custom_minimum_size = Vector2(120, 30)
	_display_mode.add_item("Borderless Fullscreen", 0)
	_display_mode.add_item("Windowed 1280x720", 1)
	_display_mode.add_item("Windowed 1600x900", 2)
	_display_mode.selected = 0
	_style_option_button(_display_mode)
	row.add_child(_display_mode)

	return row


func _style_slider(slider: HSlider):
	var slide = StyleBoxFlat.new()
	slide.bg_color = Color("#333333")
	slide.corner_radius_top_left = 4
	slide.corner_radius_top_right = 4
	slide.corner_radius_bottom_left = 4
	slide.corner_radius_bottom_right = 4
	slider.add_theme_stylebox_override("slide", slide)

	var fill = StyleBoxFlat.new()
	fill.bg_color = Color("#D4AF37")
	fill.corner_radius_top_left = 4
	fill.corner_radius_top_right = 4
	fill.corner_radius_bottom_left = 4
	fill.corner_radius_bottom_right = 4
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)

	var grabber = StyleBoxFlat.new()
	grabber.bg_color = Color("#FFD54F")
	grabber.corner_radius_top_left = 6
	grabber.corner_radius_top_right = 6
	grabber.corner_radius_bottom_left = 6
	grabber.corner_radius_bottom_right = 6
	grabber.content_margin_left = 8
	grabber.content_margin_right = 8
	grabber.content_margin_top = 8
	grabber.content_margin_bottom = 8
	slider.add_theme_stylebox_override("grabber", grabber)


func _style_option_button(btn: OptionButton):
	btn.add_theme_color_override("font_color", Color("#FFFFFF"))
	btn.add_theme_color_override("font_hover_color", Color("#D4AF37"))
	btn.add_theme_color_override("font_pressed_color", Color("#D4AF37"))
	btn.add_theme_color_override("font_focus_color", Color("#FFFFFF"))

	var normal = StyleBoxFlat.new()
	normal.bg_color = Color("#1B1B1B")
	normal.border_color = Color("#8A6A1F")
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 4
	normal.corner_radius_top_right = 4
	normal.corner_radius_bottom_left = 4
	normal.corner_radius_bottom_right = 4
	normal.content_margin_left = 8
	normal.content_margin_right = 8
	btn.add_theme_stylebox_override("normal", normal)

	var hover = normal.duplicate()
	hover.border_color = Color("#D4AF37")
	btn.add_theme_stylebox_override("hover", hover)

	var focus = normal.duplicate()
	focus.border_color = Color("#D4AF37")
	btn.add_theme_stylebox_override("focus", focus)

	btn.get_popup().add_theme_color_override("font_color", Color("#FFFFFF"))
	btn.get_popup().add_theme_color_override("font_hover_color", Color("#D4AF37"))
	var popup_bg = StyleBoxFlat.new()
	popup_bg.bg_color = Color("#1B1B1B")
	popup_bg.border_color = Color("#8A6A1F")
	popup_bg.border_width_left = 1
	popup_bg.border_width_right = 1
	popup_bg.border_width_top = 1
	popup_bg.border_width_bottom = 1
	btn.get_popup().add_theme_stylebox_override("panel", popup_bg)


func _on_volume_changed(value: float):
	var pct = clampi(roundi(value), 0, 100)
	_volume_value_label.text = "%d%%" % pct


func _on_save_pressed():
	GameSettings.master_volume = _volume_slider.value
	GameSettings.display_mode = _display_mode.selected
	GameSettings.save_settings()
	GameSettings.apply_display_mode(GameSettings.display_mode)
	_save_feedback.text = "Settings saved"
	_save_btn.disabled = true
	await get_tree().create_timer(1.5).timeout
	_save_btn.disabled = false
	_save_feedback.text = ""


func _spacer(height: int) -> Control:
	var s = Control.new()
	s.custom_minimum_size = Vector2(0, height)
	return s


func _on_back_pressed():
	queue_free()


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		accept_event()
		queue_free()
