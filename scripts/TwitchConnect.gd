extends Control

const StyledButton = preload("res://scripts/ui/StyledButton.gd")
const SettingsIcon = preload("res://scripts/ui/SettingsIcon.gd")
const SettingsPanel = preload("res://scripts/ui/SettingsPanel.gd")
const BattleArenaBannerScene = preload("res://scenes/ui/BattleArenaBanner.tscn")
const DevConfig = preload("res://scripts/DevConfig.gd")

var _connect_btn: Button
var _continue_btn: Button
var _status_label: Label
var _description_label: Label

@onready var _card_panel: Variant = %AuthCard
@onready var _ui_safe_area: MarginContainer = %SafeArea
var _banner_section
@onready var _auth_section: Control = %AuthSection
@onready var _top_spacer: Control = %TopSpacer
@onready var _banner_to_card_spacer: Control = %BannerToCardSpacer
@onready var _main_layout: VBoxContainer = %MainLayout
@onready var _card_center: CenterContainer = %CardCenter
@onready var _canvas_root: Control = %CanvasRoot
@onready var _full_area: Control = %FullArea

var _twitch_texture: Texture2D
var _bangers_font: Font


func _ready():
	var win = get_window()
	win.min_size = Vector2i(1280, 720)
	GameSettings.load_settings()
	GameSettings.apply_display_mode(GameSettings.display_mode)

	_build_card_content()
	_load_assets()
	_apply_styles()
	_card_panel.set_title("AUTHENTICATION")
	_card_panel.set_padding(40, 34, 40, 34)
	_card_panel.set_content_separation(12)
	_instantiate_banner()
	if _connect_btn:
		_connect_btn.pressed.connect(_on_connect_pressed)
	if _continue_btn:
		_continue_btn.pressed.connect(_on_continue_pressed)
	get_viewport().size_changed.connect(_update_layout)
	_update_layout()
	_add_settings_icon()


func _build_card_content():
	var content = _card_panel.get_content()

	_description_label = Label.new()
	_description_label.name = "DescriptionLabel"
	_description_label.text = "Sign in with your Twitch account to enter the arena."
	_description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_description_label)

	var btn_center = CenterContainer.new()
	btn_center.name = "ButtonCenter"
	btn_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(btn_center)

	_connect_btn = StyledButton.new()
	_connect_btn.name = "ConnectButton"
	_connect_btn.text = "CONNECT TWITCH"
	btn_center.add_child(_connect_btn)

	_status_label = Label.new()
	_status_label.name = "StatusLabel"
	_status_label.text = "Not connected to Twitch"
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_status_label)

	_continue_btn = StyledButton.new()
	_continue_btn.name = "ContinueButton"
	_continue_btn.text = "CONTINUE"
	_continue_btn.custom_minimum_size = Vector2(200, 0)
	_continue_btn.visible = false
	_continue_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_continue_btn)


func _add_settings_icon():
	var icon = SettingsIcon.new()
	icon.name = "SettingsIcon"
	icon.pressed.connect(
		func():
			var panel = SettingsPanel.new()
			add_child(panel)
	)
	_full_area.add_child(icon)


func _instantiate_banner():
	_banner_section = BattleArenaBannerScene.instantiate()
	_banner_section.name = "BannerSection"
	_main_layout.add_child(_banner_section)
	_main_layout.move_child(_banner_section, 1)


func _load_assets():
	var twitch_tex = load("res://assets/ui/icons/twitch.svg")
	var twitch_img = twitch_tex.get_image()
	if twitch_img:
		twitch_img.resize(24, 24, Image.INTERPOLATE_LANCZOS)
		_twitch_texture = ImageTexture.create_from_image(twitch_img)
	else:
		_twitch_texture = twitch_tex
	_bangers_font = load("res://assets/fonts/Bangers-Regular.ttf")


func _apply_styles():
	if _connect_btn:
		_connect_btn.icon = _twitch_texture

	if _description_label:
		_description_label.add_theme_color_override("font_color", Color("#9A9A9A"))
		_description_label.add_theme_font_size_override("font_size", 16)

	if _status_label:
		_status_label.add_theme_color_override("font_color", Color("#9A9A9A"))
		_status_label.add_theme_font_size_override("font_size", 14)
		_status_label.custom_minimum_size = Vector2(0, 24)


func _update_layout():
	var vp = get_window().size
	var factor = vp.x / 1920.0

	_canvas_root.scale = Vector2(factor, factor)
	_canvas_root.position = Vector2.ZERO

	if _banner_section != null and _banner_section.has_method("update_spacer_sizes"):
		_banner_section.update_spacer_sizes()
	else:
		push_warning("BattleArenaBanner: missing update_spacer_sizes")

	const CARD_PAD = 68.0
	const AUTH_SIZE = 18.0
	const DESC_SIZE = 16.0
	const BTN_H = 40.0
	const STATUS_SIZE = 14.0
	const SEPARATION = 12.0
	var continue_h = 50.0 if _continue_btn and _continue_btn.visible else 0.0
	var card_items_h = AUTH_SIZE + DESC_SIZE + BTN_H + STATUS_SIZE + continue_h
	var card_gaps = (4.0 if continue_h > 0 else 3.0) * SEPARATION
	var card_h = CARD_PAD + card_items_h + card_gaps

	const GAP = 50.0
	const TOP_SPACER_H = 75.6
	const CARD_WIDTH = 600.0
	const BUTTON_WIDTH = 440.0

	_top_spacer.custom_minimum_size = Vector2(0, TOP_SPACER_H)
	_banner_to_card_spacer.custom_minimum_size = Vector2(0, GAP)
	_card_panel.custom_minimum_size = Vector2(CARD_WIDTH, 0)
	if _connect_btn:
		_connect_btn.custom_minimum_size = Vector2(BUTTON_WIDTH, 0)
	_auth_section.custom_minimum_size = Vector2(0, card_h)


func _on_connect_pressed():
	if not _status_label or not _connect_btn or not _continue_btn:
		return
	_status_label.text = "Connected as: TestStreamer"
	_connect_btn.visible = false
	_continue_btn.visible = true
	_update_layout()


func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _print_centering_diagnostics():
	if not DevConfig.DEBUG_LAYOUT:
		return

	await get_tree().process_frame
	await get_tree().process_frame

	var vp = get_window().size
	var vp_cx = vp.x * 0.5

	var entries = [
		{ "name": "UISafeArea",    "node": _ui_safe_area },
		{ "name": "MainLayout",    "node": _main_layout },
		{ "name": "BannerSection", "node": _banner_section },
		{ "name": "AuthSection",   "node": _auth_section },
		{ "name": "CardCenter",    "node": _card_center },
		{ "name": "AuthCard",      "node": _card_panel },
		{ "name": "ConnectButton", "node": _connect_btn },
	]

	print("\n=== CENTERING DIAGNOSTIC (global rects) ===")
	print("Viewport: ", vp, "  Center X: ", vp_cx)
	print("")

	for e in entries:
		var n = e["node"] as Control
		if not n:
			print(e["name"], ": INVALID")
			continue
		var rect = n.get_global_rect()
		var cx = rect.position.x + rect.size.x * 0.5
		var delta = cx - vp_cx
		print(e["name"], "  global_rect: pos=", rect.position, " size=", rect.size, "  cx=", cx, "  delta=", delta)

	print("==========================================\n")
