extends Node2D

const SettingsIcon = preload("res://scripts/ui/SettingsIcon.gd")
const SettingsPanel = preload("res://scripts/ui/SettingsPanel.gd")

@onready var camera: Camera2D = $Camera2D
@onready var canvas: CanvasLayer = $CanvasLayer

var _remaining_time: float
var _total_players: int
var _next_player_index := 0
var _players_per_second: float
var _reveal_accumulator := 0.0
var _config: Dictionary

var _countdown_label: Label
var _player_count_label: Label


func _ready():
	_setup_ui()

	_total_players = GameSettings.test_player_count
	_remaining_time = float(GameSettings.waiting_duration)
	_players_per_second = float(_total_players) / max(_remaining_time, 1.0)
	_config = BattleConfig.get_config(_total_players)

	var arena_size = _get_arena_size(_total_players)
	var viewport = get_window().size
	var zoom = maxf(viewport.x / arena_size, viewport.y / arena_size)
	camera.zoom = Vector2(zoom, zoom)

	_player_count_label.text = "Players joined: 0 / %d" % _total_players
	_update_countdown_display()


func _setup_ui():
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0, 0, 0, 0.45)
	canvas.add_child(bg)

	var title = Label.new()
	title.name = "TitleLabel"
	title.anchor_left = 0.5
	title.anchor_top = 0.0
	title.anchor_right = 0.5
	title.anchor_bottom = 0.0
	title.offset_left = -250.0
	title.offset_top = 50.0
	title.offset_right = 250.0
	title.offset_bottom = 120.0
	title.text = "GET READY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 60)
	canvas.add_child(title)

	_countdown_label = Label.new()
	_countdown_label.name = "CountdownLabel"
	_countdown_label.anchor_left = 0.5
	_countdown_label.anchor_top = 0.0
	_countdown_label.anchor_right = 0.5
	_countdown_label.anchor_bottom = 0.0
	_countdown_label.offset_left = -250.0
	_countdown_label.offset_top = 140.0
	_countdown_label.offset_right = 250.0
	_countdown_label.offset_bottom = 200.0
	_countdown_label.text = "Battle starts in %d" % GameSettings.waiting_duration
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_countdown_label.add_theme_font_size_override("font_size", 40)
	canvas.add_child(_countdown_label)

	var join_label = Label.new()
	join_label.name = "JoinLabel"
	join_label.anchor_left = 0.5
	join_label.anchor_top = 0.0
	join_label.anchor_right = 0.5
	join_label.anchor_bottom = 0.0
	join_label.offset_left = -250.0
	join_label.offset_top = 220.0
	join_label.offset_right = 250.0
	join_label.offset_bottom = 270.0
	join_label.text = "Type %s to join" % GameSettings.join_command
	join_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	join_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	join_label.add_theme_font_size_override("font_size", 28)
	canvas.add_child(join_label)

	_player_count_label = Label.new()
	_player_count_label.name = "PlayerCountLabel"
	_player_count_label.anchor_left = 0.5
	_player_count_label.anchor_top = 0.0
	_player_count_label.anchor_right = 0.5
	_player_count_label.anchor_bottom = 0.0
	_player_count_label.offset_left = -250.0
	_player_count_label.offset_top = 290.0
	_player_count_label.offset_right = 250.0
	_player_count_label.offset_bottom = 340.0
	_player_count_label.text = "Players joined: 0 / %d" % GameSettings.test_player_count
	_player_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_player_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_player_count_label.add_theme_font_size_override("font_size", 28)
	canvas.add_child(_player_count_label)

	_add_settings_icon()


func _add_settings_icon():
	var icon = SettingsIcon.new()
	icon.name = "SettingsIcon"
	icon.pressed.connect(
		func():
			var panel = SettingsPanel.new()
			canvas.add_child(panel)
	)
	canvas.add_child(icon)


func _process(delta):
	if _remaining_time <= 0.0:
		return

	_remaining_time -= delta
	_update_countdown_display()

	_reveal_accumulator += _players_per_second * delta
	while _reveal_accumulator >= 1.0 and _next_player_index < _total_players:
		_reveal_accumulator -= 1.0
		_spawn_fake_player()

	_player_count_label.text = "Players joined: %d / %d" % [min(_next_player_index, _total_players), _total_players]

	if _remaining_time <= 0.0:
		_finish_waiting()


func _spawn_fake_player():
	var player = preload("res://scenes/Player.tscn").instantiate()
	player.normalized_position = Vector2(randf(), randf())
	player.direction = Vector2.ZERO
	player.target_direction = Vector2.ZERO
	player.username = "viewer_%03d" % (_next_player_index + 1)
	player.show_username = true
	player.setup_combat(_config)
	player.is_alive = true
	player.visible = true
	add_child(player)
	_apply_player_position(player)
	_next_player_index += 1


func _apply_player_position(player):
	var arena_size = _get_arena_size(_total_players)
	var half = arena_size * 0.5
	var margin = 80.0 / camera.zoom.x
	player.position = Vector2(
		lerpf(-half + margin, half - margin, player.normalized_position.x),
		lerpf(-half + margin, half - margin, player.normalized_position.y)
	)


func _update_countdown_display():
	var seconds = int(ceil(_remaining_time))
	_countdown_label.text = "Battle starts in %d" % seconds


func _finish_waiting():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _get_arena_size(count: int) -> float:
	if count <= 10:
		return 1000.0
	elif count <= 50:
		return 1600.0
	elif count <= 100:
		return 2200.0
	elif count <= 300:
		return 3200.0
	elif count <= 1000:
		return 5000.0
	else:
		return 8000.0
