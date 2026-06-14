extends Node

var streamer_name := "TestStreamer"
var waiting_duration := 30
var join_command := "!battle"
var test_player_count := 300
var global_ranking := {}

var master_volume := 80.0
var music_volume := 80.0
var ui_volume := 80.0
var battle_volume := 80.0
var display_mode := 0
var selected_theme := 0

const SETTINGS_PATH := "user://settings.cfg"
const AUDIO_BUSES := {
	"Master": "master_volume",
	"Music": "music_volume",
	"UI": "ui_volume",
	"Battle": "battle_volume",
}


func _ready():
	load_settings()
	call_deferred("_deferred_apply")


func _deferred_apply():
	await get_tree().process_frame
	apply_audio_settings()
	apply_display_mode(display_mode)


func save_settings():
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master_volume", master_volume)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "ui_volume", ui_volume)
	cfg.set_value("audio", "battle_volume", battle_volume)
	cfg.set_value("display", "display_mode", display_mode)
	cfg.set_value("theme", "selected_theme", selected_theme)
	cfg.save(SETTINGS_PATH)


func load_settings():
	var cfg := ConfigFile.new()
	var err := cfg.load(SETTINGS_PATH)
	if err != OK:
		return
	if cfg.has_section_key("audio", "master_volume"):
		master_volume = cfg.get_value("audio", "master_volume", 80.0)
	if cfg.has_section_key("audio", "music_volume"):
		music_volume = cfg.get_value("audio", "music_volume", 80.0)
	if cfg.has_section_key("audio", "ui_volume"):
		ui_volume = cfg.get_value("audio", "ui_volume", 80.0)
	if cfg.has_section_key("audio", "battle_volume"):
		battle_volume = cfg.get_value("audio", "battle_volume", 80.0)
	if cfg.has_section_key("display", "display_mode"):
		display_mode = cfg.get_value("display", "display_mode", 0)
	if cfg.has_section_key("theme", "selected_theme"):
		selected_theme = cfg.get_value("theme", "selected_theme", 0)


func apply_audio_settings():
	_ensure_audio_buses()
	for bus_name in AUDIO_BUSES.keys():
		var idx := AudioServer.get_bus_index(bus_name)
		if idx < 0:
			continue
		var pct = clampf(float(get(AUDIO_BUSES[bus_name])), 0.0, 100.0)
		AudioServer.set_bus_volume_db(idx, _percent_to_db(pct))


func _ensure_audio_buses():
	for bus_name in ["Music", "UI", "Battle"]:
		if AudioServer.get_bus_index(bus_name) >= 0:
			continue
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, bus_name)


func _percent_to_db(value: float) -> float:
	var linear = clampf(value / 100.0, 0.0, 1.0)
	if linear <= 0.0:
		return -80.0
	return linear_to_db(linear)


func apply_display_mode(mode: int):
	var screen_count := DisplayServer.get_screen_count()
	if screen_count <= 0:
		push_warning("No screens detected yet. Skipping display mode apply.")
		return

	var win := get_window()
	if not win:
		return
	var screen := win.current_screen
	if screen < 0 or screen >= screen_count:
		screen = 0 if screen_count > 0 else 0

	match mode:
		0:
			var screen_pos := DisplayServer.screen_get_position(screen)
			var screen_size := DisplayServer.screen_get_size(screen)
			win.borderless = true
			win.mode = Window.MODE_WINDOWED
			win.position = screen_pos
			win.size = screen_size
		1:
			win.borderless = false
			win.mode = Window.MODE_WINDOWED
			win.size = Vector2i(1280, 720)
			_center_window(screen)
		2:
			win.borderless = false
			win.mode = Window.MODE_WINDOWED
			win.size = Vector2i(1600, 900)
			_center_window(screen)


func _center_window(screen: int):
	var screen_count := DisplayServer.get_screen_count()
	if screen_count <= 0:
		return
	var win := get_window()
	if not win:
		return
	if screen < 0 or screen >= screen_count:
		screen = 0 if screen_count > 0 else 0
	if screen < 0 or screen >= screen_count:
		return
	var usable: Rect2i
	if DisplayServer.has_method(&"screen_get_usable_rect"):
		usable = DisplayServer.screen_get_usable_rect(screen)
	else:
		usable = Rect2i(
			DisplayServer.screen_get_position(screen),
			DisplayServer.screen_get_size(screen)
		)
	win.position = Vector2i(
		usable.position.x + (usable.size.x - win.size.x) / 2,
		usable.position.y + (usable.size.y - win.size.y) / 2
	)
