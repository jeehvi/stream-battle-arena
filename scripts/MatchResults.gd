extends Control

const SettingsPanel = preload("res://scripts/ui/SettingsPanel.gd")

@onready var _results_content: VBoxContainer = %ResultsCard.get_content()

const BANGERS = preload("res://assets/fonts/Bangers-Regular.ttf")
const TROPHY = preload("res://assets/ui/icons/trophy.svg")


func _ready():
	$CanvasRoot/BackgroundImage.texture = load("res://assets/ui/connect-twitch-bg-1920x1080.png")
	%ResultsCard.set_title("MATCH RESULTS")
	%PlayAgain.pressed.connect(_on_play_again)
	%BackToMenu.pressed.connect(_on_back_to_menu)
	%ResultsSettingsIcon.pressed.connect(
		func():
			var panel = SettingsPanel.new()
			get_parent().add_child(panel)
	)
	get_viewport().size_changed.connect(_update_layout)
	_update_layout()


func _update_layout():
	var vp = get_window().size
	if vp.x <= 0:
		return
	var factor = vp.x / 1920.0
	$CanvasRoot.scale = Vector2(factor, factor)
	$CanvasRoot.position = Vector2.ZERO


func show_results(data: Dictionary) -> void:
	for child in _results_content.get_children():
		child.queue_free()

	var winner: Node = data.winner
	var battle_time: float = data.battle_time
	var mvp: Node = data.mvp
	var all_players: Array = data.all_players
	var top_kills: Array = data.top_kills
	var top_pts: Array = data.top_pts
	var session_winners: Array = data.session_winners

	var winner_row = HBoxContainer.new()
	winner_row.name = "WinnerRow"
	winner_row.alignment = BoxContainer.ALIGNMENT_CENTER
	winner_row.add_theme_constant_override("separation", 12)
	_results_content.add_child(winner_row)

	var trophy_left = TextureRect.new()
	trophy_left.name = "TrophyLeft"
	trophy_left.texture = TROPHY
	trophy_left.custom_minimum_size = Vector2(24, 24)
	trophy_left.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	winner_row.add_child(trophy_left)

	var w_title = _make_label("WINNER", 30, Color(1, 0.8, 0))
	w_title.add_theme_font_override("font", BANGERS)
	winner_row.add_child(w_title)

	var trophy_right = TextureRect.new()
	trophy_right.name = "TrophyRight"
	trophy_right.texture = TROPHY
	trophy_right.custom_minimum_size = Vector2(24, 24)
	trophy_right.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	winner_row.add_child(trophy_right)

	_results_content.add_child(_make_label(winner.username, 22))

	var dur_min = int(battle_time) / 60
	var dur_sec = int(battle_time) % 60
	_results_content.add_child(_make_label("Match Duration: %02d:%02d" % [dur_min, dur_sec], 16, Color(0.7, 0.7, 0.7)))
	_results_content.add_child(_make_label("", 8))

	var vp = winner.kills + 10
	_results_content.add_child(_make_label("Kills this battle: %d" % winner.kills, 20))
	_results_content.add_child(_make_label("Points earned: %d" % vp, 20))

	_results_content.add_child(_make_label("", 16))

	var columns = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	_results_content.add_child(columns)

	var col_left = VBoxContainer.new()
	col_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(col_left)

	var col_right = VBoxContainer.new()
	col_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(col_right)

	var bs_title = _make_label("BATTLE STATS", 18, Color(0.6, 0.6, 0.6))
	bs_title.add_theme_font_override("font", BANGERS)
	col_left.add_child(bs_title)
	col_left.add_child(_make_label("", 8))

	col_left.add_child(_make_label("BATTLE MVP", 17, Color(1.0, 0.75, 0.2)))
	col_left.add_child(_make_label("%s - %d kills" % [mvp.username, mvp.kills], 15))
	col_left.add_child(_make_label("", 12))

	col_left.add_child(_make_label("TOP KILLS THIS BATTLE", 17, Color(0.7, 0.7, 0.7)))
	for i in range(mini(5, all_players.size())):
		var p = all_players[i]
		col_left.add_child(_make_label("%d. %s - %d kills" % [i + 1, p.username, p.kills], 14))
	col_left.add_child(_make_label("", 12))

	col_left.add_child(_make_label("KILL KINGS", 17, Color(0.75, 0.4, 0.15)))
	if top_kills.size() > 0:
		for i in range(top_kills.size()):
			var p = top_kills[i]
			col_left.add_child(_make_label("%d. %s - %d kills" % [i + 1, p.username, p.entry.session_kills], 14))

	var ss_title = _make_label("SESSION STATS", 18, Color(0.6, 0.6, 0.6))
	ss_title.add_theme_font_override("font", BANGERS)
	col_right.add_child(ss_title)
	col_right.add_child(_make_label("", 8))

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

	visible = true


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
