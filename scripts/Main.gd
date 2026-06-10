extends Node2D

const SCREEN_PADDING := 80.0
const PLAYER_SPEED := 60.0

@onready var fps_label: Label = $CanvasLayer/FPSLabel
@onready var alive_label: Label = $CanvasLayer/AliveLabel
@onready var killfeed_container: VBoxContainer = $CanvasLayer/KillfeedContainer
@onready var camera: Camera2D = $Camera2D
@onready var canvas_layer: CanvasLayer = $CanvasLayer

var showdown_overlay: Control
var results_screen: Control
var results_content: VBoxContainer
var timer_label: Label
var _match_duration_label: Label
var _showdown_list: HBoxContainer
var _showdown_col_left: VBoxContainer
var _showdown_col_right: VBoxContainer
var _arena_size: float = 1000.0

var _waiting_overlay: Control
var _waiting_title: Label
var _waiting_countdown: Label
var _waiting_join: Label
var _waiting_players: Label
var _transition_label: Label

const STATE_PLAYING := 0
const STATE_SHOWDOWN_PAUSE := 1
const STATE_GAME_OVER_DELAY := 2

const PHASE_WAITING := 0
const PHASE_TRANSITION := 1
const PHASE_PLAYING := 2

const BULLET_SPEED := 1200.0
const BULLET_RADIUS := 2.0
const BULLET_CHANCE := 0.5

var _phase := PHASE_WAITING
var _target_timer := 0.0
var _game_over := false
var _battle_state := STATE_PLAYING
var _state_timer := 0.0
var _showdown_triggered := false
var _last_winner = null
var _battle_time := 0.0
var _speed_multiplier := 1.0
var _boost_applied := false
var _early_boost_duration := 0.0
var _early_cd_mult := 1.0
var _midgame_boosted := false
var _killfeed_entries: Array = []
var _global_ranking := {}
var _bullets: Array = []

var _waiting_remaining: float
var _waiting_total: int
var _waiting_index := 0
var _waiting_rate: float
var _waiting_accum := 0.0
var _waiting_config: Dictionary
var _session_recorded := false
var _initial_player_count := 0
var _bullet_debug_timer := 0.0


func _ready():
	camera.global_position = Vector2.ZERO
	get_viewport().size_changed.connect(_on_viewport_resized)
	_setup_ui()
	_start_waiting_phase()


func _setup_ui():
	results_screen = Control.new()
	results_screen.name = "ResultsScreen"
	results_screen.visible = false
	results_screen.anchor_left = 0.0
	results_screen.anchor_top = 0.0
	results_screen.anchor_right = 1.0
	results_screen.anchor_bottom = 1.0
	canvas_layer.add_child(results_screen)

	var bg = ColorRect.new()
	bg.name = "Background"
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0, 0, 0, 0.85)
	results_screen.add_child(bg)

	var content = VBoxContainer.new()
	content.name = "Content"
	content.anchor_left = 0.0
	content.anchor_top = 0.0
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.offset_left = 60.0
	content.offset_right = -60.0
	content.offset_top = 40.0
	content.offset_bottom = -40.0
	results_screen.add_child(content)
	results_content = content

	_match_duration_label = Label.new()
	_match_duration_label.name = "MatchDurationLabel"
	_match_duration_label.anchor_left = 1.0
	_match_duration_label.anchor_top = 0.0
	_match_duration_label.anchor_right = 1.0
	_match_duration_label.anchor_bottom = 0.0
	_match_duration_label.offset_left = -220.0
	_match_duration_label.offset_right = -50.0
	_match_duration_label.offset_top = 35.0
	_match_duration_label.offset_bottom = 65.0
	_match_duration_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_match_duration_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_match_duration_label.add_theme_font_size_override("font_size", 18)
	results_screen.add_child(_match_duration_label)

	var button_row = HBoxContainer.new()
	button_row.name = "ActionButtons"
	button_row.anchor_left = 0.5
	button_row.anchor_top = 1.0
	button_row.anchor_right = 0.5
	button_row.anchor_bottom = 1.0
	button_row.offset_left = -210.0
	button_row.offset_top = -94.0
	button_row.offset_right = 210.0
	button_row.offset_bottom = -50.0
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 24)
	results_screen.add_child(button_row)

	var play_again = Button.new()
	play_again.name = "PlayAgain"
	play_again.text = "PLAY AGAIN"
	play_again.custom_minimum_size = Vector2(190, 44)
	play_again.add_theme_font_size_override("font_size", 20)
	play_again.pressed.connect(_on_play_again)
	button_row.add_child(play_again)

	var back_menu = Button.new()
	back_menu.name = "BackToMenu"
	back_menu.text = "BACK TO MENU"
	back_menu.custom_minimum_size = Vector2(190, 44)
	back_menu.add_theme_font_size_override("font_size", 20)
	back_menu.pressed.connect(_on_back_to_menu)
	button_row.add_child(back_menu)

	showdown_overlay = Control.new()
	showdown_overlay.name = "ShowdownOverlay"
	showdown_overlay.visible = false
	showdown_overlay.anchor_left = 0.0
	showdown_overlay.anchor_top = 0.0
	showdown_overlay.anchor_right = 1.0
	showdown_overlay.anchor_bottom = 1.0
	canvas_layer.add_child(showdown_overlay)

	var sd_bg = ColorRect.new()
	sd_bg.name = "Background"
	sd_bg.anchor_left = 0.0
	sd_bg.anchor_top = 0.0
	sd_bg.anchor_right = 1.0
	sd_bg.anchor_bottom = 1.0
	sd_bg.color = Color(0, 0, 0, 0.65)
	showdown_overlay.add_child(sd_bg)

	var sd_content = VBoxContainer.new()
	sd_content.name = "Content"
	sd_content.anchor_left = 0.5
	sd_content.anchor_top = 0.5
	sd_content.anchor_right = 0.5
	sd_content.anchor_bottom = 0.5
	sd_content.offset_left = -300.0
	sd_content.offset_top = -220.0
	sd_content.offset_right = 300.0
	sd_content.offset_bottom = 220.0
	sd_content.alignment = BoxContainer.ALIGNMENT_CENTER
	showdown_overlay.add_child(sd_content)

	var sd_title = Label.new()
	sd_title.name = "Title"
	sd_title.text = "FINAL SHOWDOWN"
	sd_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sd_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sd_title.add_theme_font_size_override("font_size", 56)
	sd_content.add_child(sd_title)

	_showdown_list = HBoxContainer.new()
	_showdown_list.name = "PlayerList"
	_showdown_list.alignment = BoxContainer.ALIGNMENT_CENTER
	_showdown_list.add_theme_constant_override("separation", 40)
	sd_content.add_child(_showdown_list)

	_showdown_col_left = VBoxContainer.new()
	_showdown_col_left.name = "LeftColumn"
	_showdown_col_left.add_theme_constant_override("separation", 4)
	_showdown_list.add_child(_showdown_col_left)

	_showdown_col_right = VBoxContainer.new()
	_showdown_col_right.name = "RightColumn"
	_showdown_col_right.add_theme_constant_override("separation", 4)
	_showdown_list.add_child(_showdown_col_right)

	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.anchor_left = 0.5
	timer_label.anchor_top = 0.0
	timer_label.anchor_right = 0.5
	timer_label.anchor_bottom = 0.0
	timer_label.offset_left = -100.0
	timer_label.offset_right = 100.0
	timer_label.offset_top = 8.0
	timer_label.offset_bottom = 48.0
	timer_label.text = "00:00"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	timer_label.add_theme_font_size_override("font_size", 36)
	canvas_layer.add_child(timer_label)

	timer_label.visible = false

	_waiting_overlay = Control.new()
	_waiting_overlay.name = "WaitingOverlay"
	_waiting_overlay.anchor_left = 0.0
	_waiting_overlay.anchor_top = 0.0
	_waiting_overlay.anchor_right = 1.0
	_waiting_overlay.anchor_bottom = 1.0
	canvas_layer.add_child(_waiting_overlay)

	var wt_bg = ColorRect.new()
	wt_bg.name = "Background"
	wt_bg.anchor_left = 0.0
	wt_bg.anchor_top = 0.0
	wt_bg.anchor_right = 1.0
	wt_bg.anchor_bottom = 1.0
	wt_bg.color = Color(0, 0, 0, 0.45)
	_waiting_overlay.add_child(wt_bg)

	_waiting_title = Label.new()
	_waiting_title.name = "TitleLabel"
	_waiting_title.anchor_left = 0.5
	_waiting_title.anchor_top = 0.0
	_waiting_title.anchor_right = 0.5
	_waiting_title.anchor_bottom = 0.0
	_waiting_title.offset_left = -250.0
	_waiting_title.offset_top = 50.0
	_waiting_title.offset_right = 250.0
	_waiting_title.offset_bottom = 120.0
	_waiting_title.text = "GET READY"
	_waiting_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_waiting_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_waiting_title.add_theme_font_size_override("font_size", 60)
	_waiting_overlay.add_child(_waiting_title)

	_waiting_countdown = Label.new()
	_waiting_countdown.name = "CountdownLabel"
	_waiting_countdown.anchor_left = 0.5
	_waiting_countdown.anchor_top = 0.0
	_waiting_countdown.anchor_right = 0.5
	_waiting_countdown.anchor_bottom = 0.0
	_waiting_countdown.offset_left = -250.0
	_waiting_countdown.offset_top = 140.0
	_waiting_countdown.offset_right = 250.0
	_waiting_countdown.offset_bottom = 200.0
	_waiting_countdown.text = "Battle starts in %d" % GameSettings.waiting_duration
	_waiting_countdown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_waiting_countdown.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_waiting_countdown.add_theme_font_size_override("font_size", 40)
	_waiting_overlay.add_child(_waiting_countdown)

	_waiting_join = Label.new()
	_waiting_join.name = "JoinLabel"
	_waiting_join.anchor_left = 0.5
	_waiting_join.anchor_top = 0.0
	_waiting_join.anchor_right = 0.5
	_waiting_join.anchor_bottom = 0.0
	_waiting_join.offset_left = -250.0
	_waiting_join.offset_top = 220.0
	_waiting_join.offset_right = 250.0
	_waiting_join.offset_bottom = 270.0
	_waiting_join.text = "Type %s to join" % GameSettings.join_command
	_waiting_join.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_waiting_join.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_waiting_join.add_theme_font_size_override("font_size", 28)
	_waiting_overlay.add_child(_waiting_join)

	_waiting_players = Label.new()
	_waiting_players.name = "PlayerCountLabel"
	_waiting_players.anchor_left = 0.5
	_waiting_players.anchor_top = 1.0
	_waiting_players.anchor_right = 0.5
	_waiting_players.anchor_bottom = 1.0
	_waiting_players.offset_left = -250.0
	_waiting_players.offset_top = -60.0
	_waiting_players.offset_right = 250.0
	_waiting_players.offset_bottom = -10.0
	_waiting_players.text = "0 joined"
	_waiting_players.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_waiting_players.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_waiting_players.add_theme_font_size_override("font_size", 28)
	_waiting_overlay.add_child(_waiting_players)

	_transition_label = Label.new()
	_transition_label.name = "TransitionLabel"
	_transition_label.visible = false
	_transition_label.anchor_left = 0.5
	_transition_label.anchor_top = 0.5
	_transition_label.anchor_right = 0.5
	_transition_label.anchor_bottom = 0.5
	_transition_label.offset_left = -250.0
	_transition_label.offset_top = -40.0
	_transition_label.offset_right = 250.0
	_transition_label.offset_bottom = 40.0
	_transition_label.text = "BATTLE STARTING"
	_transition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_transition_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_transition_label.add_theme_font_size_override("font_size", 56)
	canvas_layer.add_child(_transition_label)


func _populate_showdown_list():
	for child in _showdown_col_left.get_children():
		child.queue_free()
	for child in _showdown_col_right.get_children():
		child.queue_free()

	var players: Array = []
	for child in get_children():
		if child is CanvasLayer or child is Camera2D:
			continue
		if child.is_alive:
			players.append(child)

	players.sort_custom(func(a, b): return a.kills > b.kills)

	var count = mini(10, players.size())
	var half = ceili(count / 2.0)

	for i in range(mini(half, players.size())):
		var p = players[i]
		var label = Label.new()
		label.text = "%d. %s - %d kills" % [i + 1, p.username, p.kills]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.add_theme_font_size_override("font_size", 20)
		_showdown_col_left.add_child(label)

	for i in range(half, count):
		var p = players[i]
		var label = Label.new()
		label.text = "%d. %s - %d kills" % [i + 1, p.username, p.kills]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.add_theme_font_size_override("font_size", 20)
		_showdown_col_right.add_child(label)


func _start_waiting_phase():
	_phase = PHASE_WAITING
	_waiting_total = GameSettings.test_player_count
	_waiting_remaining = float(GameSettings.waiting_duration)
	_waiting_index = 0
	_waiting_rate = _waiting_remaining / float(_waiting_total)
	_waiting_accum = 0.0
	_waiting_config = BattleConfig.get_config(_waiting_total)
	_global_ranking = GameSettings.global_ranking

	_arena_size = _get_arena_size_for_count(_waiting_total)
	var viewport = get_window().size
	var zoom = maxf(viewport.x / _arena_size, viewport.y / _arena_size)
	camera.zoom = Vector2(zoom, zoom)

	_waiting_overlay.visible = true
	alive_label.visible = false
	_waiting_players.text = "0 joined"
	_waiting_countdown.text = "Battle starts in %d" % GameSettings.waiting_duration
	queue_redraw()


func _spawn_waiting_player():
	var player_count = _get_player_count()
	if player_count >= _waiting_total:
		return

	var p = preload("res://scenes/Player.tscn").instantiate()
	p.name = "Player%d" % (_waiting_index + 1)
	p.username = "viewer_%03d" % (_waiting_index + 1)
	p.kills = 0

	var config = _waiting_config
	p.max_health = config.max_health
	p.health = config.max_health
	p.damage = config.damage
	p.attack_cooldown = config.attack_cooldown

	p.normalized_position = Vector2(randf_range(0.05, 0.95), randf_range(0.05, 0.95))
	p.direction = Vector2.ZERO

	var viewport = get_window().size
	var zoom = camera.zoom.x
	var half_w = viewport.x / zoom * 0.5
	var half_h = viewport.y / zoom * 0.5
	var margin = SCREEN_PADDING / zoom
	p.position = Vector2(
		lerpf(-half_w + margin, half_w - margin, p.normalized_position.x),
		lerpf(-half_h + margin, half_h - margin, p.normalized_position.y)
	)

	add_child(p)
	_waiting_index += 1
	_waiting_players.text = "%d joined" % [player_count + 1]


func _process(delta):
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

	match _phase:
		PHASE_WAITING:
			_waiting_remaining -= delta
			_waiting_accum += delta
			var sec = int(ceili(_waiting_remaining))
			_waiting_countdown.text = "Battle starts in %d" % maxi(0, sec)

			while _waiting_accum >= _waiting_rate and _waiting_index < _waiting_total:
				_waiting_accum -= _waiting_rate
				_spawn_waiting_player()

			if _waiting_remaining <= 0.0:
				_phase = PHASE_TRANSITION
				_waiting_overlay.visible = false
				_transition_label.visible = true
				_state_timer = 2.0
				_update_responsive_layout()
				_update_username_visibility()

		PHASE_TRANSITION:
			_state_timer -= delta
			if _state_timer <= 0.0:
				_transition_label.visible = false
				timer_label.visible = true
				_phase = PHASE_PLAYING
				_battle_time = 0.0
				_initial_player_count = _get_player_count()
				alive_label.visible = true
				_grant_early_boost()
				for child in get_children():
					if not (child is CanvasLayer or child is Camera2D):
						child.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

		PHASE_PLAYING:
			if not _game_over:
				_move_players(delta)

			if not _game_over and _battle_state == STATE_PLAYING:
				_battle_time += delta
			var minutes = int(_battle_time) / 60
			var seconds = int(_battle_time) % 60
			timer_label.text = "%02d:%02d" % [minutes, seconds]

			if _boost_applied and _battle_time >= _early_boost_duration:
				_revert_early_boost()

			_update_state_timers(delta)
			_update_bullets(delta)
			_update_alive_count()
			_update_killfeed(delta)


func _update_alive_count():
	var alive := 0
	var winner = null
	for child in get_children():
		if child is CanvasLayer or child is Camera2D:
			continue
		if child.is_alive:
			alive += 1
			winner = child

	alive_label.text = "Alive: %d / %d" % [alive, _initial_player_count]

	if not _showdown_triggered and alive <= 10 and _battle_state == STATE_PLAYING:
		_showdown_triggered = true
		_battle_state = STATE_SHOWDOWN_PAUSE
		_state_timer = 5.0
		_populate_showdown_list()
		showdown_overlay.visible = true

	if not _midgame_boosted and alive <= 100 and _battle_state == STATE_PLAYING:
		_midgame_boosted = true
		_speed_multiplier *= 1.10
		for child in get_children():
			if not (child is CanvasLayer or child is Camera2D):
				child.attack_cooldown *= 0.90

	if alive <= 1 and _battle_state == STATE_PLAYING:
		_battle_state = STATE_GAME_OVER_DELAY
		_state_timer = 3.0
		_game_over = true
		_last_winner = winner


func _move_players(delta):
	if _battle_state != STATE_PLAYING:
		return

	var viewport = get_window().size
	var zoom = camera.zoom.x
	var margin = SCREEN_PADDING / zoom
	var left = -viewport.x / zoom * 0.5 + margin
	var right = viewport.x / zoom * 0.5 - margin
	var top = -viewport.y / zoom * 0.5 + margin
	var bottom = viewport.y / zoom * 0.5 - margin

	_target_timer -= delta
	if _target_timer <= 0.0:
		_target_timer = 0.5
		_update_targets()

	for child in get_children():
		if child is CanvasLayer or child is Camera2D:
			continue

		child.update_direction(delta)

		if _boost_applied and child.current_target != null and is_instance_valid(child.current_target) and child.current_target.is_alive:
			var target_dir = (child.current_target.position - child.position).normalized()
			child.direction = (child.direction * 0.7 + target_dir * 0.3).normalized()

		child.position += child.direction * PLAYER_SPEED * _speed_multiplier * delta

		if child.position.x < left:
			child.position.x = left
			child.direction.x = abs(child.direction.x)
			child.target_direction.x = abs(child.target_direction.x)
		elif child.position.x > right:
			child.position.x = right
			child.direction.x = -abs(child.direction.x)
			child.target_direction.x = -abs(child.target_direction.x)

		if child.position.y < top:
			child.position.y = top
			child.direction.y = abs(child.direction.y)
			child.target_direction.y = abs(child.target_direction.y)
		elif child.position.y > bottom:
			child.position.y = bottom
			child.direction.y = -abs(child.direction.y)
			child.target_direction.y = -abs(child.target_direction.y)

		if child.is_alive:
			child._attack_timer -= delta
			if child._attack_timer <= 0.0 and child.current_target != null and is_instance_valid(child.current_target):
				child._attack_timer = child.attack_cooldown
				var victim = child.current_target
				if victim.is_alive and randf() < BULLET_CHANCE:
					var dir = (victim.position - child.position).normalized()
					var tip = child.position + dir * 20.0
					var dist = victim.position.distance_to(child.position)
					var dur = clampf(dist / BULLET_SPEED, 0.08, 0.25)
					_bullets.append({
						start_position = tip,
						target_player = victim,
						attacker = child,
						damage = child.damage,
						elapsed_time = 0.0,
						duration = dur,
						has_applied_damage = false
					})
					print("Bullet Created | shooter=%s target=%s dist=%.1f dur=%.3f" % [child.username, victim.username, dist, dur])
					child.fire()
			child.queue_redraw()


func _update_targets():
	var players: Array = []
	for child in get_children():
		if child is CanvasLayer or child is Camera2D:
			continue
		players.append(child)

	for p in players:
		if not p.is_alive:
			p.current_target = null
			continue

		var nearest = null
		var nearest_dist = INF

		for other in players:
			if other == p or not other.is_alive:
				continue
			var d = p.position.distance_squared_to(other.position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = other

		p.current_target = nearest


func _add_killfeed(killer_name: String, victim_name: String):
	var label = Label.new()
	label.text = "%s eliminated %s" % [killer_name, victim_name]
	label.add_theme_font_size_override("font_size", 12)
	killfeed_container.add_child(label)
	_killfeed_entries.append({ label = label, time = 5.0 })

	# Keep at most 5 entries
	while _killfeed_entries.size() > 5:
		var old = _killfeed_entries.pop_front()
		old.label.queue_free()


func _update_killfeed(delta):
	for i in range(_killfeed_entries.size() - 1, -1, -1):
		_killfeed_entries[i].time -= delta
		if _killfeed_entries[i].time <= 0.0:
			_killfeed_entries[i].label.queue_free()
			_killfeed_entries.remove_at(i)


func _update_state_timers(delta):
	if _battle_state == STATE_SHOWDOWN_PAUSE:
		_state_timer -= delta
		if _state_timer <= 0.0:
			_battle_state = STATE_PLAYING
			showdown_overlay.visible = false
			for child in _showdown_col_left.get_children():
				child.queue_free()
			for child in _showdown_col_right.get_children():
				child.queue_free()

	if _battle_state == STATE_GAME_OVER_DELAY:
		_state_timer -= delta
		if _state_timer <= 0.0 and _last_winner != null:
			_battle_state = STATE_GAME_OVER_DELAY + 1
			_show_results(_last_winner)


func _update_bullets(delta):
	_bullet_debug_timer += delta
	if _bullet_debug_timer >= 5.0:
		_bullet_debug_timer = 0.0
		print("Active bullets count: %d" % _bullets.size())

	var modified := false

	if _battle_state != STATE_PLAYING:
		if _bullets.size() > 0:
			print("Bullet Cleanup | reason=battle_end/showdown count=%d" % _bullets.size())
			_bullets.clear()
			modified = true
		if modified:
			queue_redraw()
		return

	for i in range(_bullets.size() - 1, -1, -1):
		var b = _bullets[i]

		if not is_instance_valid(b.target_player):
			print("Bullet Removed | reason=invalid_target target=invalid")
			_bullets.remove_at(i)
			modified = true
			continue

		if not b.target_player.is_alive:
			print("Bullet Removed | reason=target_dead target=%s" % b.target_player.username)
			_bullets.remove_at(i)
			modified = true
			continue

		b.elapsed_time += delta
		var progress = clampf(b.elapsed_time / b.duration, 0.0, 1.0)
		var bullet_pos = b.start_position.lerp(b.target_player.position, progress)

		if progress >= 1.0:
			if not b.has_applied_damage:
				b.has_applied_damage = true
				print("Bullet Impact | target=%s elapsed=%.3f" % [b.target_player.username, b.elapsed_time])
				b.target_player.take_damage(b.damage, b.attacker)
				if not b.target_player.is_alive:
					_add_killfeed(b.attacker.username, b.target_player.username)
			_bullets.remove_at(i)
			modified = true
		else:
			b.position = bullet_pos

	if modified or _bullets.size() > 0:
		queue_redraw()


func _show_results(winner):
	alive_label.visible = false
	timer_label.visible = false

	if not _session_recorded:
		_session_recorded = true
		var all_players: Array = []
		for child in get_children():
			if child is CanvasLayer or child is Camera2D:
				continue
			all_players.append(child)
		SessionStats.record_battle(all_players, winner)

	_update_global_ranking(winner)

	for child in results_content.get_children():
		child.queue_free()

	# Winner section
	var w_title = _make_label("WINNER", 30)
	w_title.add_theme_color_override("font_color", Color(1, 0.8, 0))
	results_content.add_child(w_title)

	results_content.add_child(_make_label(winner.username, 22))

	var dur_min = int(_battle_time) / 60
	var dur_sec = int(_battle_time) % 60
	_match_duration_label.text = "Match Duration: %02d:%02d" % [dur_min, dur_sec]

	var vp = winner.kills + 10
	results_content.add_child(_make_label("Kills this battle: %d" % winner.kills, 20))
	results_content.add_child(_make_label("Points earned: %d" % vp, 20))

	results_content.add_child(_make_label("", 16))

	# Collect players and find MVP
	var all_players: Array = []
	for child in get_children():
		if child is CanvasLayer or child is Camera2D:
			continue
		all_players.append(child)

	var mvp = null
	for p in all_players:
		if mvp == null or p.kills > mvp.kills:
			mvp = p

	all_players.sort_custom(func(a, b): return a.kills > b.kills)

	# Top session data
	var top_pts = SessionStats.get_top_points(10)
	var top_kills = SessionStats.get_top_kills(5)
	var session_winners = SessionStats.get_session_winners()

	# 2-column layout
	var columns = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	results_content.add_child(columns)

	var col_left = VBoxContainer.new()
	col_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(col_left)

	var col_right = VBoxContainer.new()
	col_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(col_right)

	# ---- LEFT COLUMN: BATTLE STATS ----
	col_left.add_child(_make_label("BATTLE STATS", 18, Color(0.6, 0.6, 0.6)))
	col_left.add_child(_make_label("", 8))

	# BATTLE MVP
	col_left.add_child(_make_label("BATTLE MVP", 17, Color(1.0, 0.75, 0.2)))
	col_left.add_child(_make_label("%s - %d kills" % [mvp.username, mvp.kills], 15))
	col_left.add_child(_make_label("", 12))

	# TOP KILLS THIS BATTLE
	col_left.add_child(_make_label("TOP KILLS THIS BATTLE", 17, Color(0.7, 0.7, 0.7)))
	for i in range(mini(5, all_players.size())):
		var p = all_players[i]
		col_left.add_child(_make_label("%d. %s - %d kills" % [i + 1, p.username, p.kills], 14))
	col_left.add_child(_make_label("", 12))

	# KILL KINGS
	col_left.add_child(_make_label("KILL KINGS", 17, Color(0.75, 0.4, 0.15)))
	if top_kills.size() > 0:
		for i in range(top_kills.size()):
			var p = top_kills[i]
			col_left.add_child(_make_label("%d. %s - %d kills" % [i + 1, p.username, p.entry.session_kills], 14))

	# ---- RIGHT COLUMN: SESSION STATS ----
	col_right.add_child(_make_label("SESSION STATS", 18, Color(0.6, 0.6, 0.6)))
	col_right.add_child(_make_label("", 8))

	# SESSION LEADERBOARD
	col_right.add_child(_make_label("SESSION LEADERBOARD", 17, Color(0.7, 0.7, 0.7)))
	if top_pts.size() > 0:
		var sl_scroll = ScrollContainer.new()
		sl_scroll.custom_minimum_size = Vector2(0, min(220, top_pts.size() * 22))
		col_right.add_child(sl_scroll)
		var sl_list = VBoxContainer.new()
		sl_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sl_list.add_theme_constant_override("separation", 2)
		sl_scroll.add_child(sl_list)
		for i in range(top_pts.size()):
			var p = top_pts[i]
			var e = p.entry
			sl_list.add_child(_make_label(
				"%d. %s - %d pts | %d wins | %d kills" % [i + 1, p.username, e.session_points, e.session_wins, e.session_kills],
				14
			))

	col_right.add_child(_make_label("", 12))

	# SESSION WINNERS
	col_right.add_child(_make_label("SESSION WINNERS", 17, Color(0.7, 0.7, 0.7)))
	if session_winners.size() > 0:
		var sw_scroll = ScrollContainer.new()
		sw_scroll.custom_minimum_size = Vector2(0, min(260, session_winners.size() * 22))
		col_right.add_child(sw_scroll)
		var sw_list = VBoxContainer.new()
		sw_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sw_list.add_theme_constant_override("separation", 2)
		sw_scroll.add_child(sw_list)
		for w in session_winners:
			sw_list.add_child(_make_label("Battle %d: %s" % [w.battle_number, w.username], 14))

	results_screen.visible = true
	GameSettings.global_ranking = _global_ranking


func _make_label(text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	var l = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l


func _on_play_again():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_back_to_menu():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _update_global_ranking(winner):
	for child in get_children():
		if child is CanvasLayer or child is Camera2D:
			continue

		if not _global_ranking.has(child.username):
			_global_ranking[child.username] = {
				total_points = 0,
				total_kills = 0,
				wins = 0,
				games_played = 0,
			}

		var entry = _global_ranking[child.username]
		entry.total_kills += child.kills
		entry.total_points += child.kills
		entry.games_played += 1

		if child == winner:
			entry.total_points += 10
			entry.wins += 1


func _on_viewport_resized():
	_update_responsive_layout()


func _update_responsive_layout():
	var viewport = get_window().size
	var zoom = maxf(viewport.x / _arena_size, viewport.y / _arena_size)
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
	return _get_arena_size_for_count(_get_player_count())


func _get_arena_size_for_count(count: int) -> float:
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


func _grant_early_boost():
	var count = _waiting_total
	var cd_mult: float
	var speed_mult: float

	if count >= 300:
		_early_boost_duration = 30.0
		cd_mult = 0.55
		speed_mult = 1.25
	elif count >= 151:
		_early_boost_duration = 40.0
		cd_mult = 0.50
		speed_mult = 1.30
	elif count >= 51:
		_early_boost_duration = 45.0
		cd_mult = 0.45
		speed_mult = 1.35
	elif count >= 20:
		_early_boost_duration = 45.0
		cd_mult = 0.45
		speed_mult = 1.40
	else:
		return

	_early_cd_mult = cd_mult
	_speed_multiplier = speed_mult
	for child in get_children():
		if not (child is CanvasLayer or child is Camera2D):
			child.attack_cooldown *= cd_mult
	_boost_applied = true


func _revert_early_boost():
	_speed_multiplier = 1.0
	for child in get_children():
		if not (child is CanvasLayer or child is Camera2D):
			child.attack_cooldown /= _early_cd_mult
	_boost_applied = false
	_early_boost_duration = 0.0
	_early_cd_mult = 1.0


func _update_username_visibility():
	var should_show = _get_player_count() <= 300
	for child in get_children():
		if child is CanvasLayer or child is Camera2D:
			continue
		if "show_username" in child:
			child.show_username = should_show


func _draw():
	var half = _arena_size * 0.5
	draw_rect(Rect2(-half, -half, _arena_size, _arena_size), Color(0.12, 0.12, 0.15))

	# Visual-only bullets
	for b in _bullets:
		draw_circle(b.position, BULLET_RADIUS, Color(1.0, 0.7, 0.0))
