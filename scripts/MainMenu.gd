extends Control

const StyledButton = preload("res://scripts/ui/StyledButton.gd")
const SafeArea = preload("res://scripts/ui/SafeArea.gd")
const SettingsIcon = preload("res://scripts/ui/SettingsIcon.gd")
const SettingsPanel = preload("res://scripts/ui/SettingsPanel.gd")
const ConfirmDialog = preload("res://scripts/ui/ConfirmDialog.gd")
const BattleArenaBannerScene = preload("res://scenes/ui/BattleArenaBanner.tscn")

var _player_count: SpinBox
var _selected_waiting_idx := 0
var _waiting_buttons: Array[Button]

var _canvas_root: Control
var _safe_area: MarginContainer
var _top_spacer: Control
var _banner_section
var _settings_section: Control
var _banner_to_content: Control


func _ready():
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0

	_build_canvas()
	_build_background()
	_build_settings_section()
	_add_settings_icon()

	get_viewport().size_changed.connect(_update_layout)
	_update_layout()


func _build_background():
	var tex = TextureRect.new()
	tex.name = "BackgroundImage"
	tex.texture = preload("res://assets/ui/connect-twitch-bg-1920x1080.png")
	tex.anchor_left = 0.0
	tex.anchor_top = 0.0
	tex.anchor_right = 1.0
	tex.anchor_bottom = 1.0
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	_canvas_root.add_child(tex)
	_canvas_root.move_child(tex, 0)


func _build_canvas():
	_canvas_root = Control.new()
	_canvas_root.name = "CanvasRoot"
	_canvas_root.anchor_left = 0.0
	_canvas_root.anchor_top = 0.0
	_canvas_root.anchor_right = 0.0
	_canvas_root.anchor_bottom = 0.0
	_canvas_root.custom_minimum_size = Vector2(1920, 1080)
	_canvas_root.size = Vector2(1920, 1080)
	_canvas_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_canvas_root)

	_safe_area = SafeArea.new()
	_safe_area.name = "SafeArea"
	_safe_area.anchor_left = 0.0
	_safe_area.anchor_top = 0.0
	_safe_area.anchor_right = 1.0
	_safe_area.anchor_bottom = 1.0
	_canvas_root.add_child(_safe_area)

	var main_layout = VBoxContainer.new()
	main_layout.name = "MainLayout"
	main_layout.anchor_left = 0.0
	main_layout.anchor_top = 0.0
	main_layout.anchor_right = 0.0
	main_layout.anchor_bottom = 0.0
	_safe_area.add_child(main_layout)

	_top_spacer = Control.new()
	_top_spacer.name = "TopSpacer"
	main_layout.add_child(_top_spacer)

	_banner_section = BattleArenaBannerScene.instantiate()
	_banner_section.name = "BannerSection"
	main_layout.add_child(_banner_section)

	_banner_to_content = Control.new()
	_banner_to_content.name = "BannerToCardSpacer"
	main_layout.add_child(_banner_to_content)

	_settings_section = Control.new()
	_settings_section.name = "SettingsSection"
	_settings_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_settings_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_layout.add_child(_settings_section)


func _build_settings_section():
	var cinzel = load("res://assets/fonts/Cinzel-Bold.otf")

	var outer = VBoxContainer.new()
	outer.name = "CardContainer"
	outer.anchor_left = 0.0
	outer.anchor_top = 0.0
	outer.anchor_right = 1.0
	outer.anchor_bottom = 1.0
	_settings_section.add_child(outer)

	var card = Panel.new()
	card.name = "MenuCard"
	card.custom_minimum_size = Vector2(560, 0)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var s = StyleBoxFlat.new()
	s.bg_color = Color("#171717")
	s.border_color = Color("#8A6A1F")
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.corner_radius_top_left = 8
	s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 8
	s.corner_radius_bottom_right = 8
	s.content_margin_left = 32
	s.content_margin_right = 32
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 6
	card.add_theme_stylebox_override("panel", s)
	outer.add_child(card)

	_add_card_corner_marks(card)

	var vbox = VBoxContainer.new()
	vbox.name = "CardContent"
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)

	# --- Streamer row ---
	var streamer_row = HBoxContainer.new()
	streamer_row.alignment = BoxContainer.ALIGNMENT_CENTER
	streamer_row.add_theme_constant_override("separation", 8)

	var twitch_icon = TextureRect.new()
	twitch_icon.texture = preload("res://assets/ui/icons/twitch.svg")
	twitch_icon.custom_minimum_size = Vector2(24, 24)
	twitch_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	twitch_icon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	streamer_row.add_child(twitch_icon)

	var name_label = Label.new()
	var streamer = GameSettings.streamer_name
	name_label.text = streamer.to_upper() if streamer else "TESTSTREAMER"
	name_label.add_theme_font_override("font", cinzel)
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color("#D4AF37"))
	streamer_row.add_child(name_label)

	vbox.add_child(streamer_row)

	vbox.add_child(_make_spacer(2))

	# --- Waiting time section ---
	var waiting_title = Label.new()
	waiting_title.text = "Waiting time for players to join"
	waiting_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	waiting_title.add_theme_font_override("font", cinzel)
	waiting_title.add_theme_font_size_override("font_size", 18)
	waiting_title.add_theme_color_override("font_color", Color("#CCCCCC"))
	vbox.add_child(waiting_title)

	vbox.add_child(_make_spacer(2))

	_waiting_buttons = []
	var duration_labels = ["30 SEC", "60 SEC", "90 SEC"]
	var waiting_row = HBoxContainer.new()
	waiting_row.alignment = BoxContainer.ALIGNMENT_CENTER
	waiting_row.add_theme_constant_override("separation", 6)

	for i in duration_labels.size():
		var btn = Button.new()
		btn.text = duration_labels[i]
		btn.custom_minimum_size = Vector2(80, 24)
		btn.pressed.connect(_on_waiting_option_pressed.bind(i))
		_waiting_buttons.append(btn)
		waiting_row.add_child(btn)

	_update_waiting_button_styles()
	vbox.add_child(waiting_row)

	vbox.add_child(_make_spacer(2))

	# --- Join command notice ---
	var join_info = Label.new()
	join_info.text = "Viewers will need to type !battle to join the battle."
	join_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	join_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	join_info.add_theme_font_override("font", cinzel)
	join_info.add_theme_font_size_override("font_size", 18)
	join_info.add_theme_color_override("font_color", Color("#BDBDBD"))
	vbox.add_child(join_info)

	vbox.add_child(_make_spacer(2))

	# --- Test Players (dev-only) ---
	var test_row = HBoxContainer.new()
	test_row.alignment = BoxContainer.ALIGNMENT_CENTER
	test_row.add_theme_constant_override("separation", 6)

	var test_label = Label.new()
	test_label.text = "TEST PLAYERS"
	test_label.add_theme_font_override("font", cinzel)
	test_label.add_theme_font_size_override("font_size", 16)
	test_label.add_theme_color_override("font_color", Color("#BDBDBD"))
	test_row.add_child(test_label)

	_player_count = SpinBox.new()
	_player_count.min_value = 1
	_player_count.max_value = 2000
	_player_count.value = 300
	_player_count.step = 1
	_player_count.custom_minimum_size = Vector2(60, 22)
	test_row.add_child(_player_count)

	vbox.add_child(test_row)

	vbox.add_child(_make_spacer(2))

	# --- Buttons ---
	var start_btn = StyledButton.new()
	start_btn.name = "StartButton"
	start_btn.text = "START BATTLE"
	start_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_btn.pressed.connect(_on_start_pressed)
	vbox.add_child(start_btn)

	vbox.add_child(_make_spacer(2))

	var settings_btn = StyledButton.new()
	settings_btn.name = "SettingsButton"
	settings_btn.text = "SETTINGS"
	settings_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	settings_btn.pressed.connect(
		func():
			var panel = SettingsPanel.new()
			add_child(panel)
	)
	vbox.add_child(settings_btn)

	vbox.add_child(_make_spacer(2))

	var exit_btn = StyledButton.new()
	exit_btn.name = "ExitButton"
	exit_btn.text = "EXIT GAME"
	exit_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	exit_btn.pressed.connect(_on_exit_pressed)
	vbox.add_child(exit_btn)


func _on_waiting_option_pressed(idx: int):
	_selected_waiting_idx = idx
	_update_waiting_button_styles()


func _update_waiting_button_styles():
	var gold_bg = Color("#B8860B")
	var gold_border = Color("#FFD54F")
	var dark_bg = Color("#2A2A2A")
	var dark_border = Color("#555555")

	for i in _waiting_buttons.size():
		var btn = _waiting_buttons[i]
		var selected = i == _selected_waiting_idx

		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 2
		style.content_margin_bottom = 2

		if selected:
			style.bg_color = gold_bg
			style.border_color = gold_border
			btn.add_theme_color_override("font_color", Color("#000000"))
		else:
			style.bg_color = dark_bg
			style.border_color = dark_border
			btn.add_theme_color_override("font_color", Color("#CCCCCC"))

		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)


func _add_card_corner_marks(card: Panel):
	var marks = Control.new()
	marks.name = "CornerMarks"
	marks.anchor_left = 0.0
	marks.anchor_top = 0.0
	marks.anchor_right = 1.0
	marks.anchor_bottom = 1.0
	marks.mouse_filter = Control.MOUSE_FILTER_PASS
	marks.draw.connect(_on_corner_marks_draw)
	card.add_child(marks)


func _on_corner_marks_draw():
	var marks = find_child("CornerMarks", true, true) as Control
	if not marks:
		return
	var w = marks.size.x
	var h = marks.size.y
	if w <= 0 or h <= 0:
		return
	var gold = Color("#D4AF37")
	var lw = 2.0
	var arm = 14.0
	var off = 6.0
	marks.draw_line(Vector2(off, off), Vector2(off + arm, off), gold, lw)
	marks.draw_line(Vector2(off, off), Vector2(off, off + arm), gold, lw)
	marks.draw_line(Vector2(w - off, off), Vector2(w - off - arm, off), gold, lw)
	marks.draw_line(Vector2(w - off, off), Vector2(w - off, off + arm), gold, lw)
	marks.draw_line(Vector2(off, h - off), Vector2(off + arm, h - off), gold, lw)
	marks.draw_line(Vector2(off, h - off), Vector2(off, h - off - arm), gold, lw)
	marks.draw_line(Vector2(w - off, h - off), Vector2(w - off - arm, h - off), gold, lw)
	marks.draw_line(Vector2(w - off, h - off), Vector2(w - off, h - off - arm), gold, lw)


func _update_layout():
	var vp = get_window().size
	var factor = vp.x / 1920.0

	_canvas_root.scale = Vector2(factor, factor)
	_canvas_root.position = Vector2.ZERO

	_safe_area.add_theme_constant_override("margin_left", 80)
	_safe_area.add_theme_constant_override("margin_right", 80)
	_safe_area.add_theme_constant_override("margin_top", 54)
	_safe_area.add_theme_constant_override("margin_bottom", 54)

	_banner_section.update_spacer_sizes()

	_top_spacer.custom_minimum_size = Vector2(0, 4)
	_banner_to_content.custom_minimum_size = Vector2(0, 40)


func _add_settings_icon():
	var icon = SettingsIcon.new()
	icon.name = "SettingsIcon"
	icon.pressed.connect(
		func():
			var panel = SettingsPanel.new()
			add_child(panel)
	)
	add_child(icon)


func _make_spacer(height: int) -> Control:
	var s = Control.new()
	s.custom_minimum_size = Vector2(0, height)
	return s


func _on_start_pressed():
	var duration_values = [30, 60, 90]
	var streamer = GameSettings.streamer_name
	GameSettings.streamer_name = streamer if streamer else "TESTSTREAMER"
	GameSettings.waiting_duration = duration_values[_selected_waiting_idx]
	GameSettings.join_command = "!battle"
	GameSettings.test_player_count = int(_player_count.value)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_exit_pressed():
	var dialog = ConfirmDialog.new()
	dialog.setup("EXIT GAME", "Are you sure you want to exit?")
	dialog.confirmed.connect(get_tree().quit)
	add_child(dialog)
