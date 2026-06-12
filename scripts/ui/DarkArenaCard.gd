extends Panel
class_name DarkArenaCard

var _title_section: VBoxContainer
var _title_label: Label
var _content: VBoxContainer
var _padding: MarginContainer

const BANGERS = preload("res://assets/fonts/Bangers-Regular.ttf")


func _get_minimum_size() -> Vector2:
	var s = custom_minimum_size
	if _padding:
		var ps = _padding.get_combined_minimum_size()
		s.x = max(s.x, ps.x)
		s.y = max(s.y, ps.y)
	return s


func _ready():
	_build_structure()
	_apply_style()
	var m = find_child("CornerMarks", true, false) as Control
	if m:
		m.queue_redraw()
	var d = find_child("CardDivider", true, false) as Control
	if d:
		d.queue_redraw()


func _build_structure():
	var bg = ColorRect.new()
	bg.name = "CardBgFill"
	bg.color = Color("#171717")
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var marks = Control.new()
	marks.name = "CornerMarks"
	marks.anchor_left = 0.0
	marks.anchor_top = 0.0
	marks.anchor_right = 1.0
	marks.anchor_bottom = 1.0
	marks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marks.draw.connect(_on_corner_marks_draw)
	add_child(marks)

	_padding = MarginContainer.new()
	_padding.name = "CardPadding"
	_padding.anchor_left = 0.0
	_padding.anchor_top = 0.0
	_padding.anchor_right = 1.0
	_padding.anchor_bottom = 1.0
	add_child(_padding)

	var layout = VBoxContainer.new()
	layout.name = "CardLayout"
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_padding.add_child(layout)

	_title_section = VBoxContainer.new()
	_title_section.name = "TitleSection"
	_title_section.visible = false
	layout.add_child(_title_section)

	_title_label = Label.new()
	_title_label.name = "TitleLabel"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_section.add_child(_title_label)

	var title_spacer = Control.new()
	title_spacer.custom_minimum_size = Vector2(0, 8)
	_title_section.add_child(title_spacer)

	var divider = Control.new()
	divider.name = "CardDivider"
	divider.custom_minimum_size = Vector2(0, 16)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	divider.draw.connect(_on_card_divider_draw)
	_title_section.add_child(divider)

	var content_spacer = Control.new()
	content_spacer.custom_minimum_size = Vector2(0, 12)
	layout.add_child(content_spacer)

	_content = VBoxContainer.new()
	_content.name = "CardContent"
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(_content)


func _apply_style():
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
	s.content_margin_left = 0
	s.content_margin_right = 0
	s.content_margin_top = 0
	s.content_margin_bottom = 0
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 6
	add_theme_stylebox_override("panel", s)

	_padding.add_theme_constant_override("margin_left", 32)
	_padding.add_theme_constant_override("margin_right", 32)
	_padding.add_theme_constant_override("margin_top", 28)
	_padding.add_theme_constant_override("margin_bottom", 28)

	var title_ls = LabelSettings.new()
	title_ls.font = BANGERS
	title_ls.font_color = Color("#D4AF37")
	title_ls.font_size = 18
	_title_label.label_settings = title_ls


func _on_card_divider_draw():
	var d = find_child("CardDivider", true, false) as Control
	if not d:
		return
	var w = d.size.x
	var h = d.size.y
	if w <= 0 or h <= 0:
		return
	var cy = h * 0.5
	var gold = Color("#D4AF37")
	var lw = 1.0
	var gap = 14.0
	var ds = 5.0
	var ll = w * 0.5 - gap
	if ll > 0:
		d.draw_line(Vector2(0, cy), Vector2(ll, cy), gold, lw)
		d.draw_line(Vector2(w - ll, cy), Vector2(w, cy), gold, lw)
	var pts := PackedVector2Array([
		Vector2(w * 0.5, cy - ds),
		Vector2(w * 0.5 + ds, cy),
		Vector2(w * 0.5, cy + ds),
		Vector2(w * 0.5 - ds, cy)
	])
	d.draw_polygon(pts, PackedColorArray([gold]))


func _on_corner_marks_draw():
	var marks = find_child("CornerMarks", true, false) as Control
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


func set_title(text: String):
	if _title_label == null:
		push_error("NULL TEXT TARGET in DarkArenaCard.set_title: _title_label")
		return
	_title_label.text = text
	_title_section.visible = text.length() > 0


func get_content() -> VBoxContainer:
	return _content


func set_content_separation(px: int):
	_content.add_theme_constant_override("separation", px)
