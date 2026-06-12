extends Control

const StyledButton = preload("res://scripts/ui/StyledButton.gd")
const UISafeArea = preload("res://scripts/ui/UISafeArea.gd")
const SettingsIcon = preload("res://scripts/ui/SettingsIcon.gd")
const SettingsPanel = preload("res://scripts/ui/SettingsPanel.gd")
const ConfirmDialog = preload("res://scripts/ui/ConfirmDialog.gd")
const BattleArenaBannerScene = preload("res://scenes/ui/BattleArenaBanner.tscn")
const DarkArenaCardScene = preload("res://scenes/ui/DarkArenaCard.tscn")

var _player_count: SpinBox
var _selected_waiting_idx := 0
var _waiting_buttons: Array[Button]

var _canvas_root: Control
var _ui_safe_area: MarginContainer
var _full_area: Control
var _top_spacer: Control
var _banner_section
var _banner_to_content: Control
var _card_area: CenterContainer
var _filler_spacer: Control
var _footer_section: Control
var _streamer_info: HBoxContainer
var _join_helper: Label


func _ready():
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0

	_build_canvas()
	_build_background()
	_build_main_menu_content()
	_build_streamer_info()
	_build_join_helper()
	_add_settings_icon()

	get_viewport().size_changed.connect(_update_layout)
	_update_layout()
	call_deferred("_debug_centering")


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

	_ui_safe_area = UISafeArea.new()
	_ui_safe_area.name = "UISafeArea"
	_ui_safe_area.anchor_left = 0.0
	_ui_safe_area.anchor_top = 0.0
	_ui_safe_area.anchor_right = 1.0
	_ui_safe_area.anchor_bottom = 1.0
	_canvas_root.add_child(_ui_safe_area)

	_full_area = Control.new()
	_full_area.name = "FullArea"
	_full_area.anchor_left = 0.0
	_full_area.anchor_top = 0.0
	_full_area.anchor_right = 1.0
	_full_area.anchor_bottom = 1.0
	_full_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_full_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_ui_safe_area.add_child(_full_area)

	var main_layout = VBoxContainer.new()
	main_layout.name = "MainLayout"
	main_layout.anchor_left = 0.0
	main_layout.anchor_top = 0.0
	main_layout.anchor_right = 1.0
	main_layout.anchor_bottom = 1.0
	_full_area.add_child(main_layout)

	_top_spacer = Control.new()
	_top_spacer.name = "TopSpacer"
	_top_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_layout.add_child(_top_spacer)

	_banner_section = BattleArenaBannerScene.instantiate()
	_banner_section.name = "BannerSection"
	main_layout.add_child(_banner_section)

	_banner_to_content = Control.new()
	_banner_to_content.name = "BannerToCardSpacer"
	_banner_to_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_layout.add_child(_banner_to_content)

	_card_area = CenterContainer.new()
	_card_area.name = "CardArea"
	_card_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_layout.add_child(_card_area)

	_filler_spacer = Control.new()
	_filler_spacer.name = "FillerSpacer"
	_filler_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_filler_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_filler_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_layout.add_child(_filler_spacer)

	_footer_section = Control.new()
	_footer_section.name = "FooterSection"
	_footer_section.custom_minimum_size = Vector2(0, 56)
	main_layout.add_child(_footer_section)


func _build_main_menu_content():
	var cinzel = load("res://assets/fonts/Cinzel-Bold.otf")

	var card: Variant = DarkArenaCardScene.instantiate()
	card.name = "MainMenuCard"
	_card_area.add_child(card)
	card.set_title("GAME OPTIONS")

	var vbox = card.get_content()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# --- Waiting time section ---
	var waiting_title = Label.new()
	waiting_title.text = "Waiting time for players to join"
	waiting_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	waiting_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	waiting_title.add_theme_font_override("font", cinzel)
	waiting_title.add_theme_font_size_override("font_size", 18)
	waiting_title.add_theme_color_override("font_color", Color("#CCCCCC"))
	vbox.add_child(waiting_title)

	vbox.add_child(_make_spacer(3))

	_waiting_buttons = []
	var duration_labels = ["30 SEC", "60 SEC", "90 SEC"]
	var waiting_row = HBoxContainer.new()
	waiting_row.name = "WaitingRow"
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
	var waiting_center = CenterContainer.new()
	waiting_center.name = "WaitingCenter"
	waiting_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	waiting_center.add_child(waiting_row)
	vbox.add_child(waiting_center)

	vbox.add_child(_make_spacer(8))

	# --- Test Players (dev-only) ---
	var test_row = HBoxContainer.new()
	test_row.name = "TestRow"
	test_row.alignment = BoxContainer.ALIGNMENT_CENTER
	test_row.add_theme_constant_override("separation", 6)

	var test_label = Label.new()
	test_label.text = "TEST PLAYERS"
	test_label.add_theme_font_override("font", cinzel)
	test_label.add_theme_font_size_override("font_size", 14)
	test_label.add_theme_color_override("font_color", Color("#9A9A9A"))
	test_row.add_child(test_label)

	_player_count = SpinBox.new()
	_player_count.min_value = 1
	_player_count.max_value = 2000
	_player_count.value = 300
	_player_count.step = 1
	_player_count.custom_minimum_size = Vector2(60, 22)
	test_row.add_child(_player_count)

	var test_center = CenterContainer.new()
	test_center.name = "TestCenter"
	test_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	test_center.add_child(test_row)
	vbox.add_child(test_center)

	vbox.add_child(_make_spacer(12))

	# --- Buttons ---
	var start_btn = StyledButton.new()
	start_btn.name = "StartButton"
	start_btn.text = "START BATTLE"
	start_btn.pressed.connect(_on_start_pressed)
	var start_center = CenterContainer.new()
	start_center.name = "StartCenter"
	start_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_center.add_child(start_btn)
	vbox.add_child(start_center)

	vbox.add_child(_make_spacer(6))

	var exit_btn = StyledButton.new()
	exit_btn.name = "ExitButton"
	exit_btn.text = "EXIT GAME"
	exit_btn.pressed.connect(_on_exit_pressed)
	var exit_center = CenterContainer.new()
	exit_center.name = "ExitCenter"
	exit_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exit_center.add_child(exit_btn)
	vbox.add_child(exit_center)


func _build_streamer_info():
	var cinzel = load("res://assets/fonts/Cinzel-Bold.otf")
	var hbox = HBoxContainer.new()
	hbox.name = "StreamerInfo"
	hbox.anchor_left = 0.0
	hbox.anchor_top = 0.0
	hbox.offset_left = 12
	hbox.offset_top = 8
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 8)

	var icon = TextureRect.new()
	icon.texture = preload("res://assets/ui/icons/twitch.svg")
	icon.custom_minimum_size = Vector2(28, 28)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	hbox.add_child(icon)

	var label = Label.new()
	var streamer = GameSettings.streamer_name
	label.text = streamer.to_upper() if streamer else "TESTSTREAMER"
	label.add_theme_font_override("font", cinzel)
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color("#D4AF37"))
	hbox.add_child(label)

	_full_area.add_child(hbox)
	_streamer_info = hbox


func _build_join_helper():
	var cinzel = load("res://assets/fonts/Cinzel-Bold.otf")

	var label = Label.new()
	label.name = "JoinHelper"
	label.text = "Viewers will need to type !battle to join the battle."
	label.anchor_left = 0.0
	label.anchor_right = 1.0
	label.anchor_top = 0.0
	label.anchor_bottom = 1.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", cinzel)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color("#9A9A9A"))
	_footer_section.add_child(label)
	_join_helper = label


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


func _debug_centering():
	await get_tree().process_frame
	await get_tree().process_frame

	var vp = get_window().size
	var vp_cx = vp.x * 0.5

	print("=== Main Menu Centering Debug ===")
	print("Viewport center_x: ", vp_cx)
	print("Viewport size: ", vp)

	var areas = [
		["UISafeArea", _ui_safe_area],
		["MainLayout", find_child("MainLayout", true, false)],
		["CardArea", find_child("CardArea", true, false)],
		["FooterSection", find_child("FooterSection", true, false)],
	]
	for pair in areas:
		var node = pair[1] as Control
		if node:
			var r = node.get_global_rect()
			var cx = r.position.x + r.size.x * 0.5
			print(pair[0], "  global_rect: pos=", r.position, " size=", r.size, "  center_x: ", cx, "  delta_viewport: ", cx - vp_cx)

	var banner = _banner_section
	if banner and banner is Control:
		var br = banner.get_global_rect()
		var bcx = br.position.x + br.size.x * 0.5
		print("BannerSection  global_rect: pos=", br.position, " size=", br.size, "  center_x: ", bcx, "  delta_viewport: ", bcx - vp_cx)

	var items = [
		["SwordIcon", "SwordIcon"],
		["STREAM BATTLE", "TitleLabel"],
		["A R E N A", "ArenaLabel"],
		["StreamerInfo", "StreamerInfo"],
		["WaitingRow", "WaitingRow"],
		["TestRow", "TestRow"],
		["StartButton", "StartButton"],
		["ExitButton", "ExitButton"],
		["JoinHelper", "JoinHelper"],
	]
	var ref_x = vp_cx
	for pair in items:
		var node = find_child(pair[1], true, false)
		if node and node is Control:
			var r = node.get_global_rect()
			var cx = r.position.x + r.size.x * 0.5
			var delta = cx - ref_x
			print(pair[0], " center_x: ", cx, "  delta: ", delta)
		else:
			print(pair[0], ": NOT FOUND")
	print("================================")


func _update_layout():
	var vp = get_window().size
	var factor = vp.x / 1920.0

	_canvas_root.scale = Vector2(factor, factor)
	_canvas_root.position = Vector2.ZERO

	if _banner_section and _banner_section.has_method("update_spacer_sizes"):
		_banner_section.update_spacer_sizes()

	const TOP_SPACER_H = 75.6
	const GAP = 50.0
	const CARD_WIDTH = 560.0

	_top_spacer.custom_minimum_size = Vector2(0, TOP_SPACER_H)
	_banner_to_content.custom_minimum_size = Vector2(0, GAP)

	var card = find_child("MainMenuCard", true, false)
	if card:
		card.custom_minimum_size = Vector2(CARD_WIDTH, 0)


func _add_settings_icon():
	var icon = SettingsIcon.new()
	icon.name = "SettingsIcon"
	icon.pressed.connect(
		func():
			var panel = SettingsPanel.new()
			add_child(panel)
	)
	_full_area.add_child(icon)


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
