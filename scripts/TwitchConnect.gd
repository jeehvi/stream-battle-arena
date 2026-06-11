extends Control

const StyledButton = preload("res://scripts/ui/StyledButton.gd")

@onready var _connect_btn: Button = %ConnectButton
@onready var _continue_btn: Button = %ContinueButton
@onready var _status_label: Label = %StatusLabel
@onready var _title_label: Label = %TitleLabel
@onready var _arena_label: Label = %ArenaLabel
@onready var _tagline_label: Label = %TaglineLabel
@onready var _card_panel: Panel = %AuthCard
@onready var _safe_area: MarginContainer = %SafeArea
@onready var _banner_section: VBoxContainer = %BannerSection
@onready var _auth_section: Control = %AuthSection
@onready var _top_spacer: Control = %TopSpacer
@onready var _banner_to_card_spacer: Control = %BannerToCardSpacer
@onready var _sword_icon: TextureRect = %SwordIcon
@onready var _twitch_icon: TextureRect = %TwitchIcon
@onready var _gold_glow: TextureRect = %GoldGlow
@onready var _gold_divider: Control = %GoldDivider
@onready var _twitch_title: Label = %TwitchTitle
@onready var _auth_title: Label = %AuthTitle
@onready var _description_label: Label = %DescriptionLabel
@onready var _main_layout: VBoxContainer = %MainLayout
@onready var _card_center: CenterContainer = %CardCenter

var _banner_spacers: Array[Control]
var _twitch_texture: Texture2D
var _bangers_font: Font
var _cinzel_font: Font


func _ready():
	_load_assets()
	_apply_styles()
	_banner_spacers = [%SpST, %SpTA, %SpAD, %SpDT]
	_connect_btn.pressed.connect(_on_connect_pressed)
	_continue_btn.pressed.connect(_on_continue_pressed)
	_gold_divider.draw.connect(_on_divider_draw)
	get_viewport().size_changed.connect(_update_layout)
	_update_layout()


func _load_assets():
	_sword_icon.texture = load("res://assets/ui/icons/sword.svg")
	_sword_icon.rotation = deg_to_rad(180.0)

	var twitch_tex = load("res://assets/ui/icons/twitch.svg")
	var twitch_img = twitch_tex.get_image()
	if twitch_img:
		twitch_img.resize(24, 24, Image.INTERPOLATE_LANCZOS)
		_twitch_texture = ImageTexture.create_from_image(twitch_img)
	else:
		_twitch_texture = twitch_tex
	_twitch_icon.texture = _twitch_texture

	_bangers_font = load("res://assets/fonts/Bangers-Regular.ttf")
	_cinzel_font = load("res://assets/fonts/Cinzel-Bold.otf")


func _apply_styles():
	_connect_btn.icon = _twitch_texture

	var title_ls = LabelSettings.new()
	title_ls.font = _cinzel_font
	title_ls.font_color = Color("#D4AF37")
	title_ls.shadow_color = Color(0, 0, 0, 0.45)
	title_ls.shadow_offset = Vector2(1, 2)
	title_ls.shadow_size = 4
	_title_label.label_settings = title_ls

	var sub_ls = LabelSettings.new()
	sub_ls.font = _cinzel_font
	sub_ls.font_color = Color("#B86A1A")
	sub_ls.shadow_color = Color(0, 0, 0, 0.45)
	sub_ls.shadow_offset = Vector2(1, 2)
	sub_ls.shadow_size = 4
	_arena_label.label_settings = sub_ls

	_tagline_label.add_theme_color_override("font_color", Color("#9A9A9A"))
	_tagline_label.add_theme_font_size_override("font_size", 12)

	var auth_ls = LabelSettings.new()
	auth_ls.font = _bangers_font
	auth_ls.font_color = Color("#D4AF37")
	auth_ls.font_size = 14
	_auth_title.label_settings = auth_ls

	_twitch_title.add_theme_color_override("font_color", Color("#FFFFFF"))
	_twitch_title.add_theme_font_size_override("font_size", 18)

	_description_label.add_theme_color_override("font_color", Color("#BDBDBD"))
	_description_label.add_theme_font_size_override("font_size", 14)

	_status_label.add_theme_color_override("font_color", Color("#9A9A9A"))
	_status_label.add_theme_font_size_override("font_size", 12)

	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#1E3A5F")
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

	_create_gold_glow()
	_add_card_corner_marks(_card_panel)


func _create_gold_glow():
	var gs = 320
	var gimg = Image.create(gs, gs, false, Image.FORMAT_RGBA8)
	var gcx = gs * 0.5
	var gcy = gs * 0.3
	var gmr = gs * 0.5
	for y in range(gs):
		for x in range(gs):
			var dx = x - gcx
			var dy = y - gcy
			var d = sqrt(dx * dx + dy * dy) / gmr
			d = clampf(d, 0.0, 1.0)
			var a = (1.0 - d) * (1.0 - d) * 0.12
			gimg.set_pixel(x, y, Color(1.0, 0.83, 0.22, a))
	_gold_glow.texture = ImageTexture.create_from_image(gimg)


func _on_divider_draw():
	var w = _gold_divider.size.x
	var h = _gold_divider.size.y
	if w <= 0 or h <= 0:
		return
	var cy = h * 0.5
	var gold = Color("#D4AF37")
	var lw = 1.0
	var ll = w * 0.5 - 14.0
	var ds = 5.0
	if ll > 0:
		_gold_divider.draw_line(Vector2(0, cy), Vector2(ll, cy), gold, lw)
		_gold_divider.draw_line(Vector2(w - ll, cy), Vector2(w, cy), gold, lw)
	var pts = PackedVector2Array([
		Vector2(w * 0.5, cy - ds),
		Vector2(w * 0.5 + ds, cy),
		Vector2(w * 0.5, cy + ds),
		Vector2(w * 0.5 - ds, cy)
	])
	_gold_divider.draw_polygon(pts, PackedColorArray([gold]))


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

	var hm = clampf(vp.x * 0.05, 32.0, 80.0)
	var vm = clampf(vp.y * 0.05, 24.0, 60.0)
	_safe_area.add_theme_constant_override("margin_left", hm)
	_safe_area.add_theme_constant_override("margin_right", hm)
	_safe_area.add_theme_constant_override("margin_top", vm)
	_safe_area.add_theme_constant_override("margin_bottom", vm)

	var avail_h = vp.y - vm * 2.0

	var title_size = clampf(vp.x * 0.065, 32.0, 85.0)
	var subtitle_size = clampf(title_size * 0.40, 14.0, 36.0)
	var card_width = minf(vp.x * 0.80, 560.0)
	var button_width = card_width * 0.75

	var sword_h = 64.0
	var divider_h = 16.0
	var tagline_h = 12.0

	var sp_sword_title = 12.0
	var sp_title_sub = 4.0
	var sp_sub_div = 4.0
	var sp_div_tag = 4.0

	var banner_content_h = sword_h + sp_sword_title + title_size + sp_title_sub + subtitle_size + sp_sub_div + divider_h + sp_div_tag + tagline_h

	var card_pad = 64.0
	var card_sep = 60.0
	var auth_size = 14.0
	var twitch_row_h = 24.0
	var desc_size = 14.0
	var btn_h = 40.0
	var status_size = 12.0
	var continue_h = 0.0 if not _continue_btn.visible else 50.0
	var card_items_h = auth_size + 1.0 + twitch_row_h + desc_size + btn_h + status_size + continue_h
	var card_h = card_pad + card_sep + card_items_h

	var top_margin_target = clampf(vp.y * 0.12, 60.0, 140.0)
	var top_spacer_h = maxf(0.0, top_margin_target - vm)
	var gap = 50.0
	var total_h = top_spacer_h + banner_content_h + gap + card_h

	if total_h > avail_h:
		var overshoot = total_h - avail_h
		top_spacer_h = maxf(0.0, top_spacer_h - overshoot * 0.5)
		total_h = top_spacer_h + banner_content_h + gap + card_h

	if total_h > avail_h:
		var shrink = avail_h / total_h
		title_size = maxf(18.0, title_size * shrink)
		subtitle_size = maxf(10.0, subtitle_size * shrink)
		sp_sword_title = maxf(2.0, sp_sword_title * shrink)
		sp_title_sub = maxf(1.0, sp_title_sub * shrink)
		sp_sub_div = maxf(1.0, sp_sub_div * shrink)
		sp_div_tag = maxf(1.0, sp_div_tag * shrink)
		gap = maxf(8.0, gap * shrink)
		card_pad = maxf(16.0, card_pad * shrink)
		card_sep = maxf(4.0, card_sep * shrink)
		auth_size = maxf(10.0, auth_size * shrink)
		twitch_row_h = maxf(16.0, twitch_row_h * shrink)
		desc_size = maxf(10.0, desc_size * shrink)
		btn_h = maxf(28.0, btn_h * shrink)
		status_size = maxf(10.0, status_size * shrink)
		card_items_h = auth_size + 1.0 + twitch_row_h + desc_size + btn_h + status_size + continue_h
		banner_content_h = sword_h + sp_sword_title + title_size + sp_title_sub + subtitle_size + sp_sub_div + divider_h + sp_div_tag + tagline_h
		card_h = card_pad + card_sep + card_items_h
		total_h = top_spacer_h + banner_content_h + gap + card_h

		if total_h > avail_h:
			var force = avail_h / total_h
			banner_content_h = maxf(80.0, banner_content_h * force)
			card_h = maxf(100.0, card_h * force)
			gap = maxf(4.0, gap * force)
			top_spacer_h = maxf(0.0, top_spacer_h * force)
			total_h = top_spacer_h + banner_content_h + gap + card_h

	var title_ls = _title_label.label_settings
	title_ls.font_size = int(title_size)
	_title_label.label_settings = title_ls

	var sub_ls = _arena_label.label_settings
	sub_ls.font_size = int(subtitle_size)
	_arena_label.label_settings = sub_ls

	_banner_section.custom_minimum_size = Vector2(0, banner_content_h)

	if _banner_spacers.size() >= 4:
		_banner_spacers[0].custom_minimum_size = Vector2(0, sp_sword_title)
		_banner_spacers[1].custom_minimum_size = Vector2(0, sp_title_sub)
		_banner_spacers[2].custom_minimum_size = Vector2(0, sp_sub_div)
		_banner_spacers[3].custom_minimum_size = Vector2(0, sp_div_tag)

	_top_spacer.custom_minimum_size = Vector2(0, top_spacer_h)
	_banner_to_card_spacer.custom_minimum_size = Vector2(0, gap)

	_card_panel.custom_minimum_size = Vector2(card_width, 0)
	_connect_btn.custom_minimum_size = Vector2(button_width, 0)
	_auth_section.custom_minimum_size = Vector2(0, card_h)

	_print_centering_diagnostics.call_deferred()


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
		{ "name": "TitleLabel",    "node": _title_label },
		{ "name": "ArenaLabel",    "node": _arena_label },
		{ "name": "GoldDivider",   "node": _gold_divider },
		{ "name": "SwordIcon",     "node": _sword_icon },
		{ "name": "TaglineLabel",  "node": _tagline_label },
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
