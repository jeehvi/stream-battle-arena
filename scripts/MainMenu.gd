extends Control

const StyledButton = preload("res://scripts/ui/StyledButton.gd")
const SettingsIcon = preload("res://scripts/ui/SettingsIcon.gd")
const SettingsPanel = preload("res://scripts/ui/SettingsPanel.gd")
const ConfirmDialog = preload("res://scripts/ui/ConfirmDialog.gd")
const DarkArenaCardScene = preload("res://scenes/ui/DarkArenaCard.tscn")
const DevConfig = preload("res://scripts/DevConfig.gd")
const ScreenFrame = preload("res://scripts/ui/ScreenFrame.gd")

const THEMES := [
	{ "name": "Default", "status": "Owned", "price": "", "owned": true, "description": "The classic Dark Arena look currently used by Stream Battle Arena." },
	{ "name": "Tanks", "status": "2.99€", "price": "2.99€", "owned": false, "description": "A future armored battlefield theme with tank-inspired UI and arena details." },
	{ "name": "Space", "status": "2.99€", "price": "2.99€", "owned": false, "description": "A future cosmic arena theme with deep-space styling and sci-fi accents." },
	{ "name": "Pirates", "status": "2.99€", "price": "2.99€", "owned": false, "description": "A future high-seas theme with pirate-styled panels and battle flair." },
	{ "name": "Roman Empire", "status": "2.99€", "price": "2.99€", "owned": false, "description": "A future coliseum theme inspired by banners, bronze, marble, and empire." },
]

const THEME_CARD_SIZE := Vector2(500, 88)
const THEME_CARD_PADDING := 13.0
const THEME_CARD_GAP := THEME_CARD_PADDING
const THEME_BUTTON_SIZE := Vector2(94, 30)
const THEME_SLANT_RATIO := 0.4
const THEME_PREVIEW_SIZE := Vector2(178, 62)
const THEME_LABEL_HEIGHT := 16.0
const THEME_LABEL_TO_CARD_GAP := 1.0
const THEME_CARD_OUTLINE := Color("#5A5A5A")
const THEME_PREVIEW_OUTLINE := Color("#555555")
const THEME_BUTTON_OUTLINE := Color("#777777")

var _player_count: SpinBox
var _selected_waiting_idx := 0
var _waiting_buttons: Array[Button]

var _screen_frame
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
var _theme_selected_value: Label
var _theme_preview_panel: Control
var _theme_options_list: VBoxContainer


func _ready():
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0

	_ensure_owned_theme_selected()
	_build_canvas()
	_build_main_menu_content()
	_build_theme_preview_panel()
	_build_streamer_info()
	_build_join_helper()
	_add_settings_icon()

	get_viewport().size_changed.connect(_update_layout)
	_update_layout()
	if DevConfig.DEBUG_LAYOUT:
		call_deferred("_debug_centering")


func _build_canvas():
	_screen_frame = ScreenFrame.new()
	_screen_frame.name = "ScreenFrame"
	add_child(_screen_frame)

	_canvas_root = _screen_frame.get_canvas_root()
	_ui_safe_area = _screen_frame.get_safe_area()
	_full_area = _screen_frame.get_full_area()
	_top_spacer = find_child("TopSpacer", true, false) as Control
	_banner_section = _screen_frame.get_banner()
	_banner_to_content = find_child("BannerToCardSpacer", true, false) as Control
	_card_area = _screen_frame.get_content_area()
	_card_area.name = "CardArea"
	_filler_spacer = find_child("FillerSpacer", true, false) as Control
	_footer_section = _screen_frame.get_footer_section()


func _build_main_menu_content():
	var cinzel = load("res://assets/fonts/Cinzel-Bold.otf")

	var card: Variant = DarkArenaCardScene.instantiate()
	card.name = "MainMenuCard"
	_card_area.add_child(card)
	card.set_title("GAME OPTIONS")
	card.set_padding(40, 34, 40, 34)
	card.set_content_separation(0)

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

	vbox.add_child(_make_spacer(8))

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

	vbox.add_child(_make_spacer(14))

	if DevConfig.DEV_MODE:
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
		_player_count.value = GameSettings.test_player_count
		_player_count.step = 1
		_player_count.custom_minimum_size = Vector2(60, 22)
		test_row.add_child(_player_count)

		var test_center = CenterContainer.new()
		test_center.name = "TestCenter"
		test_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		test_center.add_child(test_row)
		vbox.add_child(test_center)

		vbox.add_child(_make_spacer(18))

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

	vbox.add_child(_make_spacer(10))

	var exit_btn = StyledButton.new()
	exit_btn.name = "ExitButton"
	exit_btn.text = "EXIT GAME"
	exit_btn.pressed.connect(_on_exit_pressed)
	var exit_center = CenterContainer.new()
	exit_center.name = "ExitCenter"
	exit_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exit_center.add_child(exit_btn)
	vbox.add_child(exit_center)


func _build_theme_preview_panel():
	var panel = Control.new()
	panel.name = "ThemePreviewPanel"
	panel.anchor_left = 1.0
	panel.anchor_top = 0.5
	panel.anchor_right = 1.0
	panel.anchor_bottom = 0.5
	panel.offset_left = -530.0
	panel.offset_top = -190.0
	panel.offset_right = -30.0
	panel.offset_bottom = -70.0
	_full_area.add_child(panel)
	_theme_preview_panel = panel

	_theme_selected_value = Label.new()
	_theme_selected_value.name = "ThemeSelectedValue"
	_theme_selected_value.text = _get_theme_name(GameSettings.selected_theme)
	_theme_selected_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_theme_selected_value.position = Vector2(0, 0)
	_theme_selected_value.size = Vector2(THEME_CARD_SIZE.x, THEME_LABEL_HEIGHT)
	_theme_selected_value.custom_minimum_size = Vector2(THEME_CARD_SIZE.x, THEME_LABEL_HEIGHT)
	_theme_selected_value.add_theme_font_size_override("font_size", 14)
	_theme_selected_value.add_theme_color_override("font_color", Color("#D4AF37"))
	panel.add_child(_theme_selected_value)

	var selected_btn = Button.new()
	selected_btn.text = "SELECTED"
	selected_btn.disabled = true
	selected_btn.custom_minimum_size = THEME_BUTTON_SIZE
	_style_compact_button(selected_btn)

	var row = _make_theme_box(selected_btn)
	row.position = Vector2(0, THEME_LABEL_HEIGHT + THEME_LABEL_TO_CARD_GAP)
	row.gui_input.connect(
		func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_toggle_theme_options()
				get_viewport().set_input_as_handled()
	)
	panel.add_child(row)

	_build_theme_options_list()


func _build_theme_options_list():
	_theme_options_list = VBoxContainer.new()
	_theme_options_list.name = "ThemeOptionsList"
	_theme_options_list.visible = false
	_theme_options_list.anchor_left = 1.0
	_theme_options_list.anchor_top = 0.5
	_theme_options_list.anchor_right = 1.0
	_theme_options_list.anchor_bottom = 0.5
	_theme_options_list.offset_left = -530.0
	_theme_options_list.offset_top = -50.0
	_theme_options_list.offset_right = -30.0
	_theme_options_list.offset_bottom = 430.0
	_theme_options_list.add_theme_constant_override("separation", 18)
	_full_area.add_child(_theme_options_list)
	_rebuild_theme_options()


func _toggle_theme_options():
	if not _theme_options_list:
		return
	if not _theme_options_list.visible:
		_rebuild_theme_options()
	_theme_options_list.visible = not _theme_options_list.visible


func _rebuild_theme_options():
	if not _theme_options_list:
		return
	for child in _theme_options_list.get_children():
		child.queue_free()
	for i in range(THEMES.size()):
		if i == GameSettings.selected_theme:
			continue
		_theme_options_list.add_child(_make_theme_option_row(i))


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
	if not DevConfig.DEBUG_LAYOUT:
		return

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
		["CardArea", _card_area],
		["FooterSection", _footer_section],
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
		["ThemeSelectedValue", "ThemeSelectedValue"],
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


func _make_theme_preview_box(label_text: String) -> Panel:
	var box = Panel.new()
	box.name = label_text.replace(" ", "") + "Preview"
	box.custom_minimum_size = THEME_PREVIEW_SIZE
	box.size = THEME_PREVIEW_SIZE
	box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_theme_stylebox_override("panel", _make_theme_row_style(false))
	_add_slanted_shape(box, THEME_PREVIEW_SIZE, Color("#202020"), THEME_PREVIEW_OUTLINE)

	var label = Label.new()
	label.text = label_text
	label.anchor_left = 0.0
	label.anchor_top = 0.0
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color("#9A9A9A"))
	box.add_child(label)
	return box


func _rounded_slanted_points(draw_size: Vector2) -> PackedVector2Array:
	var slant = _theme_slant(draw_size)
	var corners = [
		Vector2(slant, 0.0),
		Vector2(draw_size.x, 0.0),
		Vector2(draw_size.x - slant, draw_size.y),
		Vector2(0.0, draw_size.y),
	]
	var rounded := PackedVector2Array()
	var radius = min(7.0, draw_size.y * 0.22, draw_size.x * 0.08)
	for i in range(corners.size()):
		var prev = corners[(i - 1 + corners.size()) % corners.size()]
		var corner = corners[i]
		var next = corners[(i + 1) % corners.size()]
		var from_prev = (prev - corner).normalized()
		var to_next = (next - corner).normalized()
		var start = corner + from_prev * radius
		var end = corner + to_next * radius
		for step in range(5):
			var t = float(step) / 4.0
			var a = start.lerp(corner, t)
			var b = corner.lerp(end, t)
			rounded.append(a.lerp(b, t))
	rounded.append(rounded[0])
	return rounded


func _theme_slant(draw_size: Vector2) -> float:
	return draw_size.y * THEME_SLANT_RATIO


func _add_slanted_shape(target: Control, draw_size: Vector2, fill_color: Color, outline_color: Color):
	var fill = Polygon2D.new()
	fill.name = "SlantedFill"
	fill.color = fill_color
	fill.polygon = _rounded_slanted_points(draw_size)
	target.add_child(fill)

	var outline = Line2D.new()
	outline.name = "SlantedOutline"
	outline.width = 1.6
	outline.default_color = outline_color
	outline.points = _rounded_slanted_points(draw_size)
	target.add_child(outline)


func _wrap_theme_action(button: Button) -> CenterContainer:
	var outer = CenterContainer.new()
	outer.custom_minimum_size = Vector2(THEME_BUTTON_SIZE.x, THEME_CARD_SIZE.y)
	outer.size = Vector2(THEME_BUTTON_SIZE.x, THEME_CARD_SIZE.y)

	var panel = Panel.new()
	panel.custom_minimum_size = THEME_BUTTON_SIZE
	panel.size = THEME_BUTTON_SIZE
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", _make_theme_row_style(false))
	_add_slanted_shape(panel, THEME_BUTTON_SIZE, Color("#262626"), THEME_BUTTON_OUTLINE)
	outer.add_child(panel)

	button.anchor_left = 0.0
	button.anchor_top = 0.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = 0.0
	button.offset_top = 0.0
	button.offset_right = 0.0
	button.offset_bottom = 0.0
	button.custom_minimum_size = THEME_BUTTON_SIZE
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.clip_text = true
	panel.add_child(button)
	return outer


func _make_theme_name_label(theme_name: String) -> Label:
	var label = Label.new()
	label.text = theme_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.position = Vector2(0, 0)
	label.size = Vector2(THEME_CARD_SIZE.x, THEME_LABEL_HEIGHT)
	label.custom_minimum_size = Vector2(THEME_CARD_SIZE.x, THEME_LABEL_HEIGHT)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color("#D4AF37"))
	return label


func _make_theme_box(action_btn: Button) -> Panel:
	var row = Panel.new()
	row.custom_minimum_size = Vector2(0, THEME_CARD_SIZE.y)
	row.size = THEME_CARD_SIZE
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.add_theme_stylebox_override("panel", _make_theme_row_style(false))
	_add_slanted_shape(row, THEME_CARD_SIZE, Color("#1B1B1B"), THEME_CARD_OUTLINE)

	var preview_y = (THEME_CARD_SIZE.y - THEME_PREVIEW_SIZE.y) * 0.5
	var card_slant = _theme_slant(THEME_CARD_SIZE)
	var preview_slant = _theme_slant(THEME_PREVIEW_SIZE)
	var button_slant = _theme_slant(THEME_BUTTON_SIZE)
	var button_x = THEME_CARD_SIZE.x - THEME_BUTTON_SIZE.x - THEME_CARD_PADDING - card_slant + button_slant
	var first_x = THEME_CARD_PADDING + card_slant - preview_slant
	var second_x = first_x + THEME_PREVIEW_SIZE.x + THEME_CARD_GAP - preview_slant

	var img1 = _make_theme_preview_box("IMG 1")
	img1.position = Vector2(first_x, preview_y)
	row.add_child(img1)

	var img2 = _make_theme_preview_box("IMG 2")
	img2.position = Vector2(second_x, preview_y)
	row.add_child(img2)

	var action = _wrap_theme_action(action_btn)
	action.position = Vector2(button_x, 0.0)
	row.add_child(action)
	return row


func _make_theme_option_row(theme_idx: int) -> Control:
	var theme = THEMES[theme_idx]
	var item = Control.new()
	item.name = "%sThemeItem" % str(theme["name"]).replace(" ", "")
	item.custom_minimum_size = Vector2(THEME_CARD_SIZE.x, THEME_LABEL_HEIGHT + THEME_LABEL_TO_CARD_GAP + THEME_CARD_SIZE.y)
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.add_child(_make_theme_name_label(str(theme["name"])))

	var action_btn = Button.new()
	action_btn.custom_minimum_size = THEME_BUTTON_SIZE
	_style_compact_button(action_btn)
	if theme_idx == GameSettings.selected_theme:
		action_btn.text = "SELECTED"
		action_btn.disabled = true
	elif theme["owned"]:
		action_btn.text = "SELECT"
		action_btn.pressed.connect(_select_theme.bind(theme_idx))
	else:
		action_btn.text = "PREVIEW"
		action_btn.pressed.connect(_open_theme_preview.bind(theme_idx))

	var row = _make_theme_box(action_btn)
	row.name = "%sThemeRow" % str(theme["name"]).replace(" ", "")
	row.position = Vector2(0, THEME_LABEL_HEIGHT + THEME_LABEL_TO_CARD_GAP)
	row.gui_input.connect(
		func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				if theme["owned"]:
					_select_theme(theme_idx)
				else:
					_open_theme_preview(theme_idx)
				get_viewport().set_input_as_handled()
	)
	item.add_child(row)

	return item


func _open_theme_preview(theme_idx: int):
	var theme = THEMES[theme_idx]
	var overlay = _make_modal_overlay("ThemePreviewModal")
	var center = CenterContainer.new()
	center.anchor_left = 0.0
	center.anchor_top = 0.0
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	overlay.add_child(center)

	var card = DarkArenaCardScene.instantiate()
	card.name = "ThemePreviewCard"
	card.custom_minimum_size = Vector2(1040, 0)
	center.add_child(card)
	card.set_title(theme["name"])
	card.set_title_font_size(32)
	card.set_padding(44, 36, 44, 36)
	card.set_content_separation(10)

	var content = card.get_content()
	content.alignment = BoxContainer.ALIGNMENT_CENTER

	overlay.set_meta("slide_idx", 0)

	var gallery = HBoxContainer.new()
	gallery.name = "PreviewGallery"
	gallery.alignment = BoxContainer.ALIGNMENT_CENTER
	gallery.add_theme_constant_override("separation", 16)
	content.add_child(gallery)

	var left_btn = Button.new()
	left_btn.text = "<"
	left_btn.custom_minimum_size = Vector2(42, 42)
	_style_compact_button(left_btn)
	gallery.add_child(left_btn)

	var preview = Panel.new()
	preview.name = "PreviewPlaceholder"
	preview.custom_minimum_size = Vector2(720, 260)
	preview.add_theme_stylebox_override("panel", _make_theme_row_style(true))
	gallery.add_child(preview)

	var preview_label = Label.new()
	preview_label.anchor_left = 0.0
	preview_label.anchor_top = 0.0
	preview_label.anchor_right = 1.0
	preview_label.anchor_bottom = 1.0
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview_label.add_theme_font_size_override("font_size", 24)
	preview_label.add_theme_color_override("font_color", Color("#9A9A9A"))
	preview.add_child(preview_label)

	var right_btn = Button.new()
	right_btn.text = ">"
	right_btn.custom_minimum_size = Vector2(42, 42)
	_style_compact_button(right_btn)
	gallery.add_child(right_btn)

	var dots_label = Label.new()
	dots_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dots_label.add_theme_font_size_override("font_size", 18)
	dots_label.add_theme_color_override("font_color", Color("#CCCCCC"))
	content.add_child(dots_label)

	_update_preview_slide(overlay, preview_label, dots_label, str(theme["name"]))
	left_btn.pressed.connect(func(): _step_preview_slide(overlay, preview_label, dots_label, str(theme["name"]), -1))
	right_btn.pressed.connect(func(): _step_preview_slide(overlay, preview_label, dots_label, str(theme["name"]), 1))

	var desc = Label.new()
	desc.text = theme["description"]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(760, 48)
	desc.add_theme_font_size_override("font_size", 17)
	desc.add_theme_color_override("font_color", Color("#CCCCCC"))
	content.add_child(desc)

	var price = Label.new()
	price.text = "Price: %s" % theme["price"]
	price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price.add_theme_font_size_override("font_size", 22)
	price.add_theme_color_override("font_color", Color("#D4AF37"))
	content.add_child(price)

	var feedback = Label.new()
	feedback.text = ""
	feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback.custom_minimum_size = Vector2(0, 26)
	feedback.add_theme_font_size_override("font_size", 18)
	feedback.add_theme_color_override("font_color", Color("#CCCCCC"))
	content.add_child(feedback)

	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 18)
	content.add_child(btn_row)

	var buy_btn = StyledButton.new()
	buy_btn.text = "BUY"
	buy_btn.pressed.connect(func(): feedback.text = "Coming Soon")
	btn_row.add_child(buy_btn)

	var back_btn = StyledButton.new()
	back_btn.text = "BACK"
	back_btn.pressed.connect(overlay.queue_free)
	btn_row.add_child(back_btn)

	add_child(overlay)


func _step_preview_slide(overlay: Control, preview_label: Label, dots_label: Label, theme_name: String, dir: int):
	var idx = int(overlay.get_meta("slide_idx", 0))
	idx = (idx + dir + 3) % 3
	overlay.set_meta("slide_idx", idx)
	_update_preview_slide(overlay, preview_label, dots_label, theme_name)


func _update_preview_slide(overlay: Control, preview_label: Label, dots_label: Label, theme_name: String):
	var idx = int(overlay.get_meta("slide_idx", 0))
	preview_label.text = "%s preview slide %d" % [theme_name, idx + 1]
	var dots_text := ""
	for i in range(3):
		if i > 0:
			dots_text += " "
		dots_text += "*" if i == idx else "o"
	dots_label.text = dots_text


func _select_theme(theme_idx: int):
	if theme_idx < 0 or theme_idx >= THEMES.size():
		return
	if not THEMES[theme_idx]["owned"]:
		return
	GameSettings.selected_theme = theme_idx
	GameSettings.save_settings()
	if _theme_selected_value:
		_theme_selected_value.text = _get_theme_name(GameSettings.selected_theme)
	_rebuild_theme_options()


func _ensure_owned_theme_selected():
	var theme_idx = GameSettings.selected_theme
	if theme_idx >= 0 and theme_idx < THEMES.size() and THEMES[theme_idx]["owned"]:
		return
	GameSettings.selected_theme = 0
	GameSettings.save_settings()


func _make_modal_overlay(node_name: String) -> Control:
	var overlay = Control.new()
	overlay.name = node_name
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var dim = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0, 0, 0, 0.72)
	dim.anchor_left = 0.0
	dim.anchor_top = 0.0
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	overlay.add_child(dim)
	return overlay


func _make_theme_row_style(is_preview: bool) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color(0, 0, 0, 0)
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_top = 0
	style.border_width_bottom = 0
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _style_compact_button(btn: Button):
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0, 0, 0, 0)
	normal.border_color = Color(0, 0, 0, 0)
	normal.border_width_left = 0
	normal.border_width_right = 0
	normal.border_width_top = 0
	normal.border_width_bottom = 0
	normal.content_margin_left = 0
	normal.content_margin_right = 0
	normal.content_margin_top = 0
	normal.content_margin_bottom = 0

	var hover = normal.duplicate()

	var disabled = normal.duplicate()

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_font_size_override("font_size", 10)
	btn.add_theme_color_override("font_color", Color("#CCCCCC"))
	btn.add_theme_color_override("font_hover_color", Color("#D4AF37"))
	btn.add_theme_color_override("font_disabled_color", Color("#D4AF37"))


func _get_theme_name(theme_idx: int) -> String:
	if theme_idx < 0 or theme_idx >= THEMES.size():
		return str(THEMES[0]["name"])
	return str(THEMES[theme_idx]["name"])


func _update_layout():
	const CARD_WIDTH = 600.0

	if _screen_frame and _screen_frame.has_method("update_layout"):
		_screen_frame.update_layout()

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
	if DevConfig.DEV_MODE and _player_count:
		GameSettings.test_player_count = int(_player_count.value)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_exit_pressed():
	var dialog = ConfirmDialog.new()
	dialog.setup("EXIT GAME", "Are you sure you want to exit?")
	dialog.confirmed.connect(get_tree().quit)
	add_child(dialog)
