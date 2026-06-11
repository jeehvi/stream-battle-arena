extends Control

signal confirmed
signal cancelled

const StyledButton = preload("res://scripts/ui/StyledButton.gd")


func _init():
	_setup_ui()


func setup(title_text: String, message_text: String):
	var title = find_child("TitleLabel", true, false) as Label
	var msg = find_child("MessageLabel", true, false) as Label
	if title:
		title.text = title_text
	if msg:
		msg.text = message_text


func _setup_ui():
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0

	mouse_filter = MOUSE_FILTER_STOP

	var bg = ColorRect.new()
	bg.name = "Background"
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0, 0, 0, 0.7)
	add_child(bg)

	var card = Panel.new()
	card.name = "Card"
	card.anchor_left = 0.5
	card.anchor_top = 0.5
	card.anchor_right = 0.5
	card.anchor_bottom = 0.5
	card.offset_left = -220.0
	card.offset_top = -100.0
	card.offset_right = 220.0
	card.offset_bottom = 100.0

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
	card.add_theme_stylebox_override("panel", card_style)
	add_child(card)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.anchor_left = 0.0
	vbox.anchor_top = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 0)
	card.add_child(vbox)

	var title = Label.new()
	title.name = "TitleLabel"
	title.text = "TITLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color("#D4AF37"))
	vbox.add_child(title)

	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer1)

	var msg = Label.new()
	msg.name = "MessageLabel"
	msg.text = "MESSAGE"
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 22)
	msg.add_theme_color_override("font_color", Color("#BDBDBD"))
	msg.custom_minimum_size = Vector2(0, 50)
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(msg)

	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(spacer2)

	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_row)

	var yes_btn = StyledButton.new()
	yes_btn.text = "YES"
	yes_btn.pressed.connect(_on_yes)
	btn_row.add_child(yes_btn)

	var no_btn = StyledButton.new()
	no_btn.text = "NO"
	no_btn.pressed.connect(_on_no)
	btn_row.add_child(no_btn)


func _on_yes():
	confirmed.emit()
	queue_free()


func _on_no():
	cancelled.emit()
	queue_free()


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		accept_event()
		_on_no()
