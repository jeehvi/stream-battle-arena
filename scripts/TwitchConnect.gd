extends Control

var _connect_btn: Button
var _continue_btn: Button
var _status_label: Label


func _ready():
	_setup_ui()
	_connect_btn.pressed.connect(_on_connect_pressed)
	_continue_btn.pressed.connect(_on_continue_pressed)


func _setup_ui():
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0

	var container = VBoxContainer.new()
	container.name = "Container"
	container.anchor_left = 0.5
	container.anchor_top = 0.5
	container.anchor_right = 0.5
	container.anchor_bottom = 0.5
	container.offset_left = -250.0
	container.offset_top = -180.0
	container.offset_right = 250.0
	container.offset_bottom = 180.0
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(container)

	var title = Label.new()
	title.name = "Title"
	title.text = "STREAM BATTLE ARENA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.custom_minimum_size = Vector2(0, 100)
	container.add_child(title)

	container.add_child(_make_spacer(24))

	var subtitle = Label.new()
	subtitle.name = "Subtitle"
	subtitle.text = "Connect your Twitch account to start"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.custom_minimum_size = Vector2(0, 40)
	container.add_child(subtitle)

	container.add_child(_make_spacer(32))

	_connect_btn = Button.new()
	_connect_btn.name = "ConnectButton"
	_connect_btn.text = "CONNECT TWITCH"
	_connect_btn.custom_minimum_size = Vector2(350, 56)
	_connect_btn.add_theme_font_size_override("font_size", 26)
	container.add_child(_connect_btn)

	container.add_child(_make_spacer(16))

	_status_label = Label.new()
	_status_label.name = "Status"
	_status_label.text = "Not connected"
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 16)
	_status_label.custom_minimum_size = Vector2(0, 30)
	container.add_child(_status_label)

	container.add_child(_make_spacer(16))

	_continue_btn = Button.new()
	_continue_btn.name = "ContinueButton"
	_continue_btn.text = "CONTINUE"
	_continue_btn.custom_minimum_size = Vector2(350, 56)
	_continue_btn.add_theme_font_size_override("font_size", 26)
	_continue_btn.visible = false
	container.add_child(_continue_btn)


func _make_spacer(height: int) -> Control:
	var s = Control.new()
	s.custom_minimum_size = Vector2(0, height)
	return s


func _on_connect_pressed():
	_status_label.text = "Connected as: TestStreamer"
	_connect_btn.visible = false
	_continue_btn.visible = true


func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
