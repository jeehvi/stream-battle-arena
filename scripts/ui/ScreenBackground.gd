extends Control

const BG_CENTER := Color("#1B1B1B")
const BG_EDGE := Color("#121212")
const VIGNETTE_STRENGTH := 0.35
const SWORD_OPACITY := 0.06
const SWORD_ANGLE := 35.0
const SWORD_MAX_SIZE := 350.0
const TEXTURE_SIZE := 256

var _gradient_tex: Texture2D
var _vignette_tex: Texture2D
var _sword_tex: Texture2D


func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	_generate_textures()
	_add_gradient()
	_add_vignette()
	_add_watermark()


func _generate_textures():
	var half = TEXTURE_SIZE * 0.5
	var cx = half
	var cy = half

	var img = Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	for y in range(TEXTURE_SIZE):
		var dy = y - cy
		for x in range(TEXTURE_SIZE):
			var dx = x - cx
			var d = sqrt(dx * dx + dy * dy) / half
			d = clampf(d, 0.0, 1.0)
			img.set_pixel(x, y, BG_EDGE.lerp(BG_CENTER, 1.0 - d))
	_gradient_tex = ImageTexture.create_from_image(img)

	var vimg = Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	for y in range(TEXTURE_SIZE):
		var dy = y - cy
		for x in range(TEXTURE_SIZE):
			var dx = x - cx
			var d = sqrt(dx * dx + dy * dy) / half
			d = clampf(d, 0.0, 1.0)
			var a = d * d * VIGNETTE_STRENGTH
			vimg.set_pixel(x, y, Color(0, 0, 0, a))
	_vignette_tex = ImageTexture.create_from_image(vimg)

	_sword_tex = load("res://assets/ui/icons/sword.svg")


func _add_gradient():
	var tex = TextureRect.new()
	tex.name = "Gradient"
	tex.anchor_left = 0.0
	tex.anchor_top = 0.0
	tex.anchor_right = 1.0
	tex.anchor_bottom = 1.0
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	tex.texture = _gradient_tex
	add_child(tex)


func _add_vignette():
	var tex = TextureRect.new()
	tex.name = "Vignette"
	tex.anchor_left = 0.0
	tex.anchor_top = 0.0
	tex.anchor_right = 1.0
	tex.anchor_bottom = 1.0
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	tex.texture = _vignette_tex
	add_child(tex)


func _add_watermark():
	var vs = get_viewport().size
	var sword_size = floor(minf(vs.x, vs.y) * 0.4)
	sword_size = minf(sword_size, SWORD_MAX_SIZE)

	var holder = Control.new()
	holder.name = "Watermark"
	holder.anchor_left = 0.0
	holder.anchor_top = 0.0
	holder.anchor_right = 1.0
	holder.anchor_bottom = 1.0
	holder.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(holder)

	for rot in [-SWORD_ANGLE, SWORD_ANGLE]:
		var s = TextureRect.new()
		s.texture = _sword_tex
		s.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		s.self_modulate = Color(1, 1, 1, SWORD_OPACITY)
		s.rotation = deg_to_rad(rot)
		s.mouse_filter = Control.MOUSE_FILTER_PASS
		s.anchor_left = 0.5
		s.anchor_top = 0.5
		s.anchor_right = 0.5
		s.anchor_bottom = 0.5
		s.offset_left = -sword_size * 0.5
		s.offset_top = -sword_size * 0.5
		s.offset_right = sword_size * 0.5
		s.offset_bottom = sword_size * 0.5
		holder.add_child(s)
