extends Control

const StyledButton = preload("res://scripts/ui/StyledButton.gd")
const DarkArenaCardScene = preload("res://scenes/ui/DarkArenaCard.tscn")

var _volume_sliders := {}
var _volume_value_labels := {}
var _display_mode: OptionButton
var _save_btn: Button
var _save_feedback: Label


func _init():
	GameSettings.load_settings()
	_setup_ui()
	_load_ui_values()


func _load_ui_values():
	_set_volume_ui("master", GameSettings.master_volume)
	_set_volume_ui("music", GameSettings.music_volume)
	_set_volume_ui("ui", GameSettings.ui_volume)
	_set_volume_ui("battle", GameSettings.battle_volume)
	_display_mode.selected = clampi(GameSettings.display_mode, 0, 2)


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

	var center = CenterContainer.new()
	center.name = "Center"
	center.anchor_left = 0.0
	center.anchor_top = 0.0
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	add_child(center)

	var card = DarkArenaCardScene.instantiate()
	card.name = "SettingsCard"
	card.custom_minimum_size = Vector2(660, 0)
	center.add_child(card)
	card.set_title("SETTINGS")
	card.set_title_font_size(30)
	card.set_padding(44, 34, 44, 34)
	card.set_content_separation(0)

	var content = card.get_content()
	content.alignment = BoxContainer.ALIGNMENT_CENTER

	var audio_title = Label.new()
	audio_title.text = "AUDIO"
	audio_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	audio_title.add_theme_font_size_override("font_size", 24)
	audio_title.add_theme_color_override("font_color", Color("#CCCCCC"))
	content.add_child(audio_title)

	content.add_child(_spacer(14))
	content.add_child(_build_volume_row("master", "Master Volume"))
	content.add_child(_spacer(8))
	content.add_child(_build_volume_row("music", "Music Volume"))
	content.add_child(_spacer(8))
	content.add_child(_build_volume_row("ui", "UI Volume"))
	content.add_child(_spacer(8))
	content.add_child(_build_volume_row("battle", "Battle Volume"))
	content.add_child(_spacer(24))

	var display_title = Label.new()
	display_title.text = "DISPLAY"
	display_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	display_title.add_theme_font_size_override("font_size", 24)
	display_title.add_theme_color_override("font_color", Color("#CCCCCC"))
	content.add_child(display_title)

	content.add_child(_spacer(14))
	content.add_child(_build_display_row())
	content.add_child(_spacer(24))

	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 18)
	content.add_child(btn_row)

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
	content.add_child(_save_feedback)


func _build_volume_row(id: String, text: String) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.name = "%sVolumeRow" % id.capitalize()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)

	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(150, 34)
	row.add_child(label)

	var slider = HSlider.new()
	slider.name = "%sVolumeSlider" % id.capitalize()
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(220, 34)
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	_style_slider(slider)
	slider.value_changed.connect(_on_volume_changed.bind(id))
	row.add_child(slider)

	var value_label = Label.new()
	value_label.name = "%sVolumeValue" % id.capitalize()
	value_label.text = "80%"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.custom_minimum_size = Vector2(48, 34)
	value_label.add_theme_color_override("font_color", Color("#D4AF37"))
	row.add_child(value_label)

	_volume_sliders[id] = slider
	_volume_value_labels[id] = value_label

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
	label.custom_minimum_size = Vector2(150, 34)
	row.add_child(label)

	_display_mode = OptionButton.new()
	_display_mode.name = "DisplayMode"
	_display_mode.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_display_mode.custom_minimum_size = Vector2(238, 34)
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


func _on_volume_changed(value: float, id: String):
	var pct = clampi(roundi(value), 0, 100)
	if _volume_value_labels.has(id):
		_volume_value_labels[id].text = "%d%%" % pct


func _on_save_pressed():
	GameSettings.master_volume = _get_volume_value("master")
	GameSettings.music_volume = _get_volume_value("music")
	GameSettings.ui_volume = _get_volume_value("ui")
	GameSettings.battle_volume = _get_volume_value("battle")
	GameSettings.display_mode = _display_mode.selected
	GameSettings.save_settings()
	GameSettings.apply_audio_settings()
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


func _set_volume_ui(id: String, value: float):
	if not _volume_sliders.has(id) or not _volume_value_labels.has(id):
		return
	_volume_sliders[id].value = value
	_volume_value_labels[id].text = "%d%%" % clampi(roundi(value), 0, 100)


func _get_volume_value(id: String) -> float:
	if not _volume_sliders.has(id):
		return 80.0
	return _volume_sliders[id].value


func _on_back_pressed():
	queue_free()


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		accept_event()
		queue_free()
