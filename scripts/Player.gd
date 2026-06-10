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
var direction := Vector2.RIGHT
var max_health := 100
var health := 100
var damage := 10
var attack_cooldown := 1.0
var kills := 0
var is_alive := true
var current_target = null
var target_direction := Vector2.RIGHT
var _change_timer := 0.0
var _attack_timer := 0.0
var _muzzle_flash_timer := 0.0
var _hit_flash_timer := 0.0
var show_username := true:
	set(value):
		show_username = value
		if _username_label != null:
			_username_label.visible = value


func _ready():
	if player_color == Color.BLACK:
		player_color = Color.from_hsv(randf(), 0.8, 0.9)
	_change_timer = randf_range(2.0, 5.0)
	_attack_timer = randf_range(0.0, attack_cooldown)
	target_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
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


func setup_combat(config: Dictionary):
	max_health = config["max_health"]
	health = max_health
	damage = config["damage"]
	attack_cooldown = config["attack_cooldown"]


func fire():
	_muzzle_flash_timer = 0.1


func take_damage(amount: int, attacker):
	if not is_alive:
		return
	_hit_flash_timer = 0.22
	health -= amount
	if health <= 0:
		die(attacker)


func die(_killer):
	if _killer != null:
		_killer.kills += 1
	is_alive = false
	visible = false
	direction = Vector2.ZERO
	queue_redraw()


func update_direction(delta: float):
	if not is_alive:
		return
	_change_timer -= delta
	if _change_timer <= 0.0:
		_change_timer = randf_range(2.0, 5.0)
		target_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

	if _muzzle_flash_timer > 0.0:
		_muzzle_flash_timer -= delta
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta

	var old_dir = direction
	direction = direction.lerp(target_direction, 2.0 * delta).normalized()
	if direction != old_dir or _muzzle_flash_timer > 0.0 or _hit_flash_timer > 0.0:
		queue_redraw()


func _draw():
	if not is_alive:
		return

	# Body with hit flash
	var t = _hit_flash_timer / 0.22
	var flash_amount = clamp(t * 0.35, 0.0, 0.35)
	var body_color = player_color.lerp(Color.RED, flash_amount)
	draw_circle(Vector2.ZERO, RADIUS, body_color)

	# Cannon direction
	var cannon_dir: Vector2
	if current_target != null:
		cannon_dir = (current_target.position - position).normalized()
	else:
		cannon_dir = direction.normalized()

	draw_line(cannon_dir * RADIUS, cannon_dir * (RADIUS + CANNON_LENGTH), Color.WHITE, 3.0)

	# Muzzle flash at cannon tip
	if _muzzle_flash_timer > 0.0:
		var tip = cannon_dir * (RADIUS + CANNON_LENGTH)
		draw_circle(tip, 6.0, Color(1.0, 0.85, 0.15))
