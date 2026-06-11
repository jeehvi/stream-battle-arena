extends Node

var streamer_name := "TestStreamer"
var waiting_duration := 30
var join_command := "!battle"
var test_player_count := 300
var global_ranking := {}

var master_volume := 80.0
var display_mode := 0

const SETTINGS_PATH := "user://settings.cfg"


func _ready():
	load_settings()
	call_deferred("_deferred_apply")


func _deferred_apply():
	await get_tree().process_frame
	apply_display_mode(display_mode)


func save_settings():
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master_volume", master_volume)
	cfg.set_value("display", "display_mode", display_mode)
	cfg.save(SETTINGS_PATH)


func load_settings():
	var cfg := ConfigFile.new()
	var err := cfg.load(SETTINGS_PATH)
	if err != OK:
		return
	if cfg.has_section_key("audio", "master_volume"):
		master_volume = cfg.get_value("audio", "master_volume", 80.0)
	if cfg.has_section_key("display", "display_mode"):
		display_mode = cfg.get_value("display", "display_mode", 0)


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
