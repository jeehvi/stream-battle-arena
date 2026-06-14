extends Control

const SettingsPanel = preload("res://scripts/ui/SettingsPanel.gd")

@onready var _results_content: VBoxContainer = %ResultsCard.get_content()
@onready var _canvas_root: Control = $CanvasRoot
@onready var _background_image: TextureRect = $CanvasRoot/BackgroundImage
@onready var _top_spacer: Control = $CanvasRoot/UISafeArea/MainLayout/TopSpacer
@onready var _results_card = %ResultsCard

const BANGERS = preload("res://assets/fonts/Bangers-Regular.ttf")
const BACKGROUND = preload("res://assets/ui/connect-twitch-bg-1920x1080.png")
const TROPHY = preload("res://assets/ui/icons/trophy.svg")
const HOURGLASS = preload("res://assets/ui/icons/hourglass.svg")
const CROWN = preload("res://assets/ui/icons/crown.svg")
const SWORD = preload("res://assets/ui/icons/sword.svg")

const CANVAS_SIZE := Vector2(1920, 1080)
const TOP_SPACER_H := 28.0
const CARD_WIDTH := 1080.0
const TITLE_ICON_SIZE := 32.0
const STAT_ICON_SIZE := 24.0


func _ready():
	_canvas_root.custom_minimum_size = CANVAS_SIZE
	_canvas_root.size = CANVAS_SIZE
	_background_image.texture = BACKGROUND
	_background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background_image.stretch_mode = TextureRect.STRETCH_SCALE
	%ResultsCard.set_title("MATCH RESULTS")
	%ResultsCard.set_title_font_size(26)
	%ResultsCard.set_padding(44, 34, 44, 34)
	%ResultsCard.set_content_separation(0)
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
	_canvas_root.scale = Vector2(factor, factor)
	_canvas_root.position = Vector2.ZERO

	_top_spacer.custom_minimum_size = Vector2(0, TOP_SPACER_H)
	_results_card.custom_minimum_size = Vector2(CARD_WIDTH, 0)


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

	winner_row.add_child(_make_icon(TROPHY, TITLE_ICON_SIZE, "TrophyLeft"))

	var w_title = _make_label("WINNER", 36, Color(1, 0.8, 0), false)
	w_title.add_theme_font_override("font", BANGERS)
	winner_row.add_child(w_title)

	winner_row.add_child(_make_icon(TROPHY, TITLE_ICON_SIZE, "TrophyRight"))

	var winner_name = _make_label(winner.username, 30, Color("#D4AF37"))
	winner_name.add_theme_font_override("font", BANGERS)
	_results_content.add_child(winner_name)
	_results_content.add_child(_make_label("", 6))

	var dur_min = int(battle_time) / 60
	var dur_sec = int(battle_time) % 60
	_results_content.add_child(_make_stat_row(
		HOURGLASS,
		"Match Duration: %02d:%02d" % [dur_min, dur_sec],
		16,
		Color(0.7, 0.7, 0.7),
		STAT_ICON_SIZE
	))
	_results_content.add_child(_make_label("", 10))

	var vp = winner.kills + 10
	_results_content.add_child(_make_stat_row(SWORD, "Kills this battle: %d" % winner.kills, 20, Color.WHITE, STAT_ICON_SIZE))
	_results_content.add_child(_make_stat_row(CROWN, "Points earned: %d" % vp, 20, Color.WHITE, STAT_ICON_SIZE))

	_results_content.add_child(_make_label("", 18))

	var columns = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 42)
	_results_content.add_child(columns)

	var col_left = VBoxContainer.new()
	col_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_left.add_theme_constant_override("separation", 4)
	columns.add_child(col_left)

	var col_right = VBoxContainer.new()
	col_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_right.add_theme_constant_override("separation", 4)
	columns.add_child(col_right)

	var bs_title = _make_label("BATTLE STATS", 20, Color(0.6, 0.6, 0.6))
	bs_title.add_theme_font_override("font", BANGERS)
	col_left.add_child(bs_title)
	col_left.add_child(_make_label("", 8))

	col_left.add_child(_make_stat_row(CROWN, "BATTLE MVP", 18, Color(1.0, 0.75, 0.2), STAT_ICON_SIZE))
	col_left.add_child(_make_label("%s - %d kills" % [mvp.username, mvp.kills], 16))
	col_left.add_child(_make_label("", 12))

	col_left.add_child(_make_stat_row(SWORD, "TOP KILLS THIS BATTLE", 18, Color(0.7, 0.7, 0.7), STAT_ICON_SIZE))
	for i in range(mini(5, all_players.size())):
		var p = all_players[i]
		col_left.add_child(_make_label("%d. %s - %d kills" % [i + 1, p.username, p.kills], 15))
	col_left.add_child(_make_label("", 12))

	col_left.add_child(_make_stat_row(SWORD, "KILL KINGS", 18, Color(0.75, 0.4, 0.15), STAT_ICON_SIZE))
	if top_kills.size() > 0:
		for i in range(top_kills.size()):
			var p = top_kills[i]
			col_left.add_child(_make_label("%d. %s - %d kills" % [i + 1, p.username, p.entry.session_kills], 15))

	var ss_title = _make_label("SESSION STATS", 20, Color(0.6, 0.6, 0.6))
	ss_title.add_theme_font_override("font", BANGERS)
	col_right.add_child(ss_title)
	col_right.add_child(_make_label("", 8))

	col_right.add_child(_make_label("SESSION LEADERBOARD", 18, Color(0.7, 0.7, 0.7)))
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
				15
			))

	col_right.add_child(_make_label("", 12))

	col_right.add_child(_make_stat_row(CROWN, "SESSION WINNERS", 18, Color(0.7, 0.7, 0.7), STAT_ICON_SIZE))
	if session_winners.size() > 0:
		var sw_scroll = ScrollContainer.new()
		sw_scroll.custom_minimum_size = Vector2(0, min(260, session_winners.size() * 22))
		col_right.add_child(sw_scroll)
		var sw_list = VBoxContainer.new()
		sw_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sw_list.add_theme_constant_override("separation", 2)
		sw_scroll.add_child(sw_list)
		for w in session_winners:
			sw_list.add_child(_make_label("Battle %d: %s" % [w.battle_number, w.username], 15))

	visible = true


func _make_icon(texture: Texture2D, size_px: float, node_name: String = "ResultIcon") -> TextureRect:
	var icon = TextureRect.new()
	icon.name = node_name
	icon.texture = texture
	icon.custom_minimum_size = Vector2(size_px, size_px)
	icon.size = Vector2(size_px, size_px)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _make_stat_row(texture: Texture2D, text: String, font_size: int, color: Color = Color.WHITE, icon_size: float = STAT_ICON_SIZE) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_make_icon(texture, icon_size))
	row.add_child(_make_label(text, font_size, color, false))
	return row


func _make_label(text: String, font_size: int, color: Color = Color.WHITE, expand: bool = true) -> Label:
	var l = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL if expand else Control.SIZE_SHRINK_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l


func _on_play_again():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_back_to_menu():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
