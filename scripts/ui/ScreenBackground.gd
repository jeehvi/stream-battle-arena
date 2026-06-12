extends Control

const BG_CENTER := Color("#1B1B1B")
const BG_EDGE := Color("#121212")
const VIGNETTE_STRENGTH := 0.35
const TEXTURE_SIZE := 256

var _gradient_tex: Texture2D
var _vignette_tex: Texture2D


func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	_generate_textures()
	_add_gradient()
	_add_vignette()


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
