extends Node2D

var username: String = "viewer_001"
var player_color: Color:
	set(value):
		player_color = value
		queue_redraw()

const RADIUS := 6.0
const CANNON_LENGTH := 14.0


func _ready():
	if player_color == Color.BLACK:
		player_color = Color.from_hsv(randf(), 0.8, 0.9)
	queue_redraw()


func _draw():
	# Player body
	draw_circle(Vector2.ZERO, RADIUS, player_color)

	# Cannon pointing right by default
	draw_line(Vector2.ZERO, Vector2.RIGHT * CANNON_LENGTH, Color.WHITE, 2.0)

	# Username below
	draw_string(
		ThemeDB.fallback_font,
		Vector2(-18, RADIUS + 14),
		username,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		10,
		Color.WHITE
	)
