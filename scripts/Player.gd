extends Node2D

var username: String = "viewer_001":
	set(value):
		username = value
		if is_inside_tree():
			_username_label.text = value

var player_color: Color:
	set(value):
		player_color = value
		queue_redraw()

const RADIUS := 10.0
const CANNON_LENGTH := 10.0

var _username_label: Label
var normalized_position := Vector2.ZERO
var show_username := true:
	set(value):
		show_username = value
		if _username_label != null:
			_username_label.visible = value


func _ready():
	if player_color == Color.BLACK:
		player_color = Color.from_hsv(randf(), 0.8, 0.9)
	_setup_username_label()
	queue_redraw()


func _setup_username_label():
	if _username_label != null:
		return
	_username_label = Label.new()
	_username_label.text = username
	_username_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_username_label.custom_minimum_size = Vector2(120, 0)
	_username_label.add_theme_font_size_override("font_size", 12)
	_username_label.position = Vector2(-60, RADIUS + 6)
	add_child(_username_label)


func _draw():
	# Player body
	draw_circle(Vector2.ZERO, RADIUS, player_color)

	# Cannon starts at the top edge of circle and points upward
	draw_line(Vector2(0, -RADIUS), Vector2(0, -RADIUS - CANNON_LENGTH), Color.WHITE, 3.0)
