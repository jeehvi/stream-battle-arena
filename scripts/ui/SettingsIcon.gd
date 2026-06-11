extends Control

signal pressed

const ICON_SIZE := 32.0
const MARGIN := 16.0
const LINE_WIDTH := 2.0
const LINE_GAP := 5.0
const LINE_LENGTH := 18.0
const COLOR_IDLE := Color("#9A9A9A")
const COLOR_HOVER := Color("#D4AF37")

var _hovered := false


func _init():
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)


func _ready():
	anchor_left = 1.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 0.0
	offset_left = -(ICON_SIZE + MARGIN)
	offset_right = -MARGIN
	offset_top = MARGIN
	offset_bottom = MARGIN + ICON_SIZE
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _draw():
	var color = COLOR_HOVER if _hovered else COLOR_IDLE
	var cx = ICON_SIZE * 0.5
	var cy = ICON_SIZE * 0.5
	var y0 = cy - LINE_GAP
	var y1 = cy
	var y2 = cy + LINE_GAP
	var x0 = cx - LINE_LENGTH * 0.5
	var x1 = cx + LINE_LENGTH * 0.5
	draw_line(Vector2(x0, y0), Vector2(x1, y0), color, LINE_WIDTH)
	draw_line(Vector2(x0, y1), Vector2(x1, y1), color, LINE_WIDTH)
	draw_line(Vector2(x0, y2), Vector2(x1, y2), color, LINE_WIDTH)


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()
		accept_event()


func _on_mouse_entered():
	_hovered = true
	queue_redraw()


func _on_mouse_exited():
	_hovered = false
	queue_redraw()
