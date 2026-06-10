extends Node2D

const SCREEN_PADDING := 80.0

@onready var fps_label: Label = $CanvasLayer/FPSLabel
@onready var camera: Camera2D = $Camera2D

var _initialized := false


func _ready():
	camera.global_position = Vector2.ZERO
	get_viewport().size_changed.connect(_on_viewport_resized)


func _process(_delta):
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

	if not _initialized:
		_initialized = true
		_spawn_players()
		_update_responsive_layout()


func _on_viewport_resized():
	_update_responsive_layout()


func _update_responsive_layout():
	var arena_size = _get_arena_size()
	var viewport = get_window().size
	var zoom = maxf(viewport.x / arena_size, viewport.y / arena_size)
	camera.zoom = Vector2(zoom, zoom)

	_apply_layout()
	queue_redraw()


func _apply_layout():
	var viewport = get_window().size
	var zoom = camera.zoom.x
	var half_w = viewport.x / zoom * 0.5
	var half_h = viewport.y / zoom * 0.5
	var margin = SCREEN_PADDING / zoom

	for child in get_children():
		if child is CanvasLayer or child is Camera2D:
			continue
		child.position = Vector2(
			lerpf(-half_w + margin, half_w - margin, child.normalized_position.x),
			lerpf(-half_h + margin, half_h - margin, child.normalized_position.y)
		)


func _get_player_count() -> int:
	var count := 0
	for child in get_children():
		if child is CanvasLayer or child is Camera2D:
			continue
		count += 1
	return count


func _get_arena_size() -> float:
	var count = _get_player_count()
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


func _spawn_players():
	for i in 300:
		var player = preload("res://scenes/Player.tscn").instantiate()
		player.normalized_position = Vector2(randf(), randf())
		player.username = "viewer_%03d" % (i + 1)
		add_child(player)

	_update_username_visibility()


func _update_username_visibility():
	var show = _get_player_count() <= 300
	for child in get_children():
		if child is CanvasLayer or child is Camera2D:
			continue
		child.show_username = show


func _draw():
	var arena_size = _get_arena_size()
	var half = arena_size * 0.5
	draw_rect(Rect2(-half, -half, arena_size, arena_size), Color(0.12, 0.12, 0.15))
