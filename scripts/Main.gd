extends Node2D

const PLAYER_COUNT := 10

@onready var fps_label: Label = $CanvasLayer/FPSLabel


func _ready():
	var screen_size = get_viewport_rect().size

	for i in PLAYER_COUNT:
		var player = preload("res://scenes/Player.tscn").instantiate()
		player.position = Vector2(
			randf_range(60, screen_size.x - 60),
			randf_range(60, screen_size.y - 60)
		)
		player.username = "viewer_%03d" % (i + 1)
		add_child(player)


func _process(_delta):
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
