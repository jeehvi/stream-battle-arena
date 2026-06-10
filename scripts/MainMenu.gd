extends Control

const LABEL_WIDTH := 180
const INPUT_WIDTH := 250
const ROW_HEIGHT := 36

var _streamer_name: LineEdit
var _waiting_duration: OptionButton
var _join_command: LineEdit
var _player_count: SpinBox


func _ready():
	_setup_ui()


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
	container.offset_top = -260.0
	container.offset_right = 250.0
	container.offset_bottom = 260.0
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

	container.add_child(_make_spacer(16))

	container.add_child(_make_setting_row("Streamer Name", _make_streamer_name_input()))
	container.add_child(_make_spacer(8))
	container.add_child(_make_setting_row("Waiting Room Duration", _make_waiting_duration_input()))
	container.add_child(_make_spacer(8))
	container.add_child(_make_setting_row("Join Command", _make_join_command_input()))
	container.add_child(_make_spacer(8))
	container.add_child(_make_setting_row("Test Player Count", _make_player_count_input()))

	container.add_child(_make_spacer(32))

	var start_btn = Button.new()
	start_btn.name = "StartButton"
	start_btn.text = "START BATTLE"
	start_btn.custom_minimum_size = Vector2(350, 56)
	start_btn.add_theme_font_size_override("font_size", 26)
	start_btn.pressed.connect(_on_start_pressed)
	container.add_child(start_btn)


func _make_setting_row(label_text: String, input: Control) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER

	var label = Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(LABEL_WIDTH, ROW_HEIGHT)
	row.add_child(label)

	row.add_child(input)

	return row


func _make_streamer_name_input() -> LineEdit:
	_streamer_name = LineEdit.new()
	_streamer_name.text = "TestStreamer"
	_streamer_name.custom_minimum_size = Vector2(INPUT_WIDTH, ROW_HEIGHT)
	return _streamer_name


func _make_waiting_duration_input() -> OptionButton:
	_waiting_duration = OptionButton.new()
	_waiting_duration.add_item("30 seconds", 0)
	_waiting_duration.add_item("60 seconds", 1)
	_waiting_duration.add_item("90 seconds", 2)
	_waiting_duration.selected = 0
	_waiting_duration.custom_minimum_size = Vector2(INPUT_WIDTH, ROW_HEIGHT)
	return _waiting_duration


func _make_join_command_input() -> LineEdit:
	_join_command = LineEdit.new()
	_join_command.text = "!battle"
	_join_command.custom_minimum_size = Vector2(INPUT_WIDTH, ROW_HEIGHT)
	return _join_command


func _make_player_count_input() -> SpinBox:
	_player_count = SpinBox.new()
	_player_count.min_value = 1
	_player_count.max_value = 2000
	_player_count.value = 300
	_player_count.step = 1
	_player_count.custom_minimum_size = Vector2(INPUT_WIDTH, ROW_HEIGHT)
	return _player_count


func _make_spacer(height: int) -> Control:
	var s = Control.new()
	s.custom_minimum_size = Vector2(0, height)
	return s


func _on_start_pressed():
	var duration_values = [30, 60, 90]
	GameSettings.streamer_name = _streamer_name.text
	GameSettings.waiting_duration = duration_values[_waiting_duration.selected]
	GameSettings.join_command = _join_command.text
	GameSettings.test_player_count = int(_player_count.value)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
