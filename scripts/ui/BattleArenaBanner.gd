extends VBoxContainer

const SWORD_H := 64.0
const TITLE_SIZE := 85.0
const SUBTITLE_SIZE := 34.0
const DIVIDER_H := 16.0
const TAGLINE_H := 26.0
const SP_SWORD_TITLE := 12.0
const SP_TITLE_SUB := 4.0
const SP_SUB_DIV := 4.0
const SP_DIV_TAG := 4.0

var banner_h: float:
	get:
		return SWORD_H + SP_SWORD_TITLE + TITLE_SIZE + SP_TITLE_SUB + SUBTITLE_SIZE + SP_SUB_DIV + DIVIDER_H + SP_DIV_TAG + TAGLINE_H

var _spacers: Array[Control]

@onready var _sword_icon: TextureRect = %SwordIcon
@onready var _title_label: Label = %TitleLabel
@onready var _arena_label: Label = %ArenaLabel
@onready var _tagline_label: Label = %TaglineLabel
@onready var _gold_divider: Control = %GoldDivider


func _ready():
	_load_assets()
	_apply_styles()
	_gold_divider.draw.connect(_on_divider_draw)
	_spacers = [%SpST, %SpTA, %SpAD, %SpDT]
	custom_minimum_size = Vector2(0, banner_h)


func _load_assets():
	_sword_icon.texture = load("res://assets/ui/icons/sword.svg")
	_sword_icon.rotation = deg_to_rad(180.0)


func _apply_styles():
	var cinzel = load("res://assets/fonts/Cinzel-Bold.otf")

	var title_ls := LabelSettings.new()
	title_ls.font = cinzel
	title_ls.font_color = Color("#D4AF37")
	title_ls.font_size = 85
	title_ls.shadow_color = Color(0, 0, 0, 0.45)
	title_ls.shadow_offset = Vector2(1, 2)
	title_ls.shadow_size = 4
	_title_label.label_settings = title_ls

	var sub_ls := LabelSettings.new()
	sub_ls.font = cinzel
	sub_ls.font_color = Color("#B86A1A")
	sub_ls.font_size = 34
	sub_ls.shadow_color = Color(0, 0, 0, 0.45)
	sub_ls.shadow_offset = Vector2(1, 2)
	sub_ls.shadow_size = 4
	_arena_label.label_settings = sub_ls

	var tagline_ls := LabelSettings.new()
	tagline_ls.font = cinzel
	tagline_ls.font_color = Color("#CCCCCC")
	tagline_ls.font_size = 22
	tagline_ls.shadow_color = Color(0, 0, 0, 0.35)
	tagline_ls.shadow_offset = Vector2(0, 1)
	tagline_ls.shadow_size = 2
	_tagline_label.label_settings = tagline_ls


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
	var pts := PackedVector2Array([
		Vector2(w * 0.5, cy - ds),
		Vector2(w * 0.5 + ds, cy),
		Vector2(w * 0.5, cy + ds),
		Vector2(w * 0.5 - ds, cy)
	])
	_gold_divider.draw_polygon(pts, PackedColorArray([gold]))


func update_spacer_sizes():
	if _spacers.size() >= 4:
		_spacers[0].custom_minimum_size = Vector2(0, SP_SWORD_TITLE)
		_spacers[1].custom_minimum_size = Vector2(0, SP_TITLE_SUB)
		_spacers[2].custom_minimum_size = Vector2(0, SP_SUB_DIV)
		_spacers[3].custom_minimum_size = Vector2(0, SP_DIV_TAG)
