extends Control

const StyledButton = preload("res://scripts/ui/StyledButton.gd")
const SettingsIcon = preload("res://scripts/ui/SettingsIcon.gd")
const SettingsPanel = preload("res://scripts/ui/SettingsPanel.gd")
const BattleArenaBannerScene = preload("res://scenes/ui/BattleArenaBanner.tscn")

@onready var _connect_btn: Button = %ConnectButton
@onready var _continue_btn: Button = %ContinueButton
@onready var _status_label: Label = %StatusLabel
@onready var _card_panel: Panel = %AuthCard
@onready var _safe_area: MarginContainer = %SafeArea
var _banner_section
@onready var _auth_section: Control = %AuthSection
@onready var _top_spacer: Control = %TopSpacer
@onready var _banner_to_card_spacer: Control = %BannerToCardSpacer
@onready var _twitch_icon: TextureRect = %TwitchIcon

@onready var _twitch_title: Label = %TwitchTitle
@onready var _auth_title: Label = %AuthTitle
@onready var _description_label: Label = %DescriptionLabel
@onready var _main_layout: VBoxContainer = %MainLayout
@onready var _card_center: CenterContainer = %CardCenter
@onready var _canvas_root: Control = %CanvasRoot

var _twitch_texture: Texture2D
var _bangers_font: Font


func _ready():
	var win = get_window()
	win.min_size = Vector2i(1280, 720)
	GameSettings.load_settings()
	GameSettings.apply_display_mode(GameSettings.display_mode)

	_load_assets()
	_apply_styles()
	_instantiate_banner()
	_connect_btn.pressed.connect(_on_connect_pressed)
	_continue_btn.pressed.connect(_on_continue_pressed)
	get_viewport().size_changed.connect(_update_layout)
	_update_layout()
	_add_settings_icon()


func _add_settings_icon():
	var icon = SettingsIcon.new()
	icon.name = "SettingsIcon"
	icon.pressed.connect(
		func():
			var panel = SettingsPanel.new()
			add_child(panel)
	)
	add_child(icon)


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
	_twitch_icon.texture = _twitch_texture

	_bangers_font = load("res://assets/fonts/Bangers-Regular.ttf")


func _apply_styles():
	_connect_btn.icon = _twitch_texture

	var auth_ls = LabelSettings.new()
	auth_ls.font = _bangers_font
	auth_ls.font_color = Color("#D4AF37")
	auth_ls.font_size = 18
	_auth_title.label_settings = auth_ls

	_twitch_title.add_theme_color_override("font_color", Color("#FFFFFF"))
	_twitch_title.add_theme_font_size_override("font_size", 22)

	_description_label.add_theme_color_override("font_color", Color("#D0D0D0"))
	_description_label.add_theme_font_size_override("font_size", 20)

	_status_label.add_theme_color_override("font_color", Color("#C0C0C0"))
	_status_label.add_theme_font_size_override("font_size", 18)

	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#171717")
	card_style.border_color = Color("#8A6A1F")
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.corner_radius_top_left = 8
	card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8
	card_style.corner_radius_bottom_right = 8
	card_style.content_margin_left = 32
	card_style.content_margin_right = 32
	card_style.content_margin_top = 32
	card_style.content_margin_bottom = 32
	card_style.shadow_color = Color(0, 0, 0, 0.35)
	card_style.shadow_size = 6
	_card_panel.add_theme_stylebox_override("panel", card_style)

	_add_card_corner_marks(_card_panel)


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

	if _banner_section != null and _banner_section.has_method("update_spacer_sizes"):
		_banner_section.update_spacer_sizes()
	else:
		push_warning("BattleArenaBanner: missing update_spacer_sizes")

	const CARD_PAD = 40.0
	const CARD_SEP = 60.0
	const AUTH_SIZE = 18.0
	const TWITCH_ROW_H = 28.0
	const DESC_SIZE = 22.0
	const BTN_H = 40.0
	const STATUS_SIZE = 20.0
	var continue_h = 0.0 if not _continue_btn.visible else 50.0
	var card_items_h = AUTH_SIZE + 1.0 + TWITCH_ROW_H + DESC_SIZE + BTN_H + STATUS_SIZE + continue_h
	var card_h = CARD_PAD + CARD_SEP + card_items_h

	const GAP = 50.0
	const TOP_SPACER_H = 75.6
	const CARD_WIDTH = 560.0
	const BUTTON_WIDTH = 420.0

	_top_spacer.custom_minimum_size = Vector2(0, TOP_SPACER_H)
	_banner_to_card_spacer.custom_minimum_size = Vector2(0, GAP)
	_card_panel.custom_minimum_size = Vector2(CARD_WIDTH, 0)
	_connect_btn.custom_minimum_size = Vector2(BUTTON_WIDTH, 0)
	_auth_section.custom_minimum_size = Vector2(0, card_h)


func _on_connect_pressed():
	_status_label.text = "Connected as: TestStreamer"
	_connect_btn.visible = false
	_continue_btn.visible = true
	_update_layout()


func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _print_centering_diagnostics():
	await get_tree().process_frame
	await get_tree().process_frame

	var vp = get_window().size
	var vp_cx = vp.x * 0.5

	var entries = [
		{ "name": "SafeArea",      "node": _safe_area },
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
