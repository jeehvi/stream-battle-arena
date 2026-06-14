extends Control

const UISafeArea = preload("res://scripts/ui/UISafeArea.gd")
const BattleArenaBannerScene = preload("res://scenes/ui/BattleArenaBanner.tscn")
const BACKGROUND = preload("res://assets/ui/connect-twitch-bg-1920x1080.png")

const CANVAS_SIZE := Vector2(1920, 1080)
const TOP_SPACER_H := 75.6
const BANNER_TO_CONTENT_GAP := 50.0
const FOOTER_H := 56.0

var _canvas_root: Control
var _background_image: TextureRect
var _ui_safe_area: MarginContainer
var _full_area: Control
var _main_layout: VBoxContainer
var _top_spacer: Control
var _banner_section
var _banner_to_content: Control
var _content_area: CenterContainer
var _filler_spacer: Control
var _footer_section: Control


func _init():
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_structure()


func _ready():
	get_viewport().size_changed.connect(update_layout)
	update_layout()


func _build_structure():
	_canvas_root = Control.new()
	_canvas_root.name = "CanvasRoot"
	_canvas_root.anchor_left = 0.0
	_canvas_root.anchor_top = 0.0
	_canvas_root.anchor_right = 0.0
	_canvas_root.anchor_bottom = 0.0
	_canvas_root.custom_minimum_size = CANVAS_SIZE
	_canvas_root.size = CANVAS_SIZE
	_canvas_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_canvas_root)

	_background_image = TextureRect.new()
	_background_image.name = "BackgroundImage"
	_background_image.texture = BACKGROUND
	_background_image.anchor_left = 0.0
	_background_image.anchor_top = 0.0
	_background_image.anchor_right = 1.0
	_background_image.anchor_bottom = 1.0
	_background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background_image.stretch_mode = TextureRect.STRETCH_SCALE
	_background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas_root.add_child(_background_image)

	_ui_safe_area = UISafeArea.new()
	_ui_safe_area.name = "UISafeArea"
	_ui_safe_area.anchor_left = 0.0
	_ui_safe_area.anchor_top = 0.0
	_ui_safe_area.anchor_right = 1.0
	_ui_safe_area.anchor_bottom = 1.0
	_canvas_root.add_child(_ui_safe_area)

	_full_area = Control.new()
	_full_area.name = "FullArea"
	_full_area.anchor_left = 0.0
	_full_area.anchor_top = 0.0
	_full_area.anchor_right = 1.0
	_full_area.anchor_bottom = 1.0
	_full_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_full_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_ui_safe_area.add_child(_full_area)

	_main_layout = VBoxContainer.new()
	_main_layout.name = "MainLayout"
	_main_layout.anchor_left = 0.0
	_main_layout.anchor_top = 0.0
	_main_layout.anchor_right = 1.0
	_main_layout.anchor_bottom = 1.0
	_full_area.add_child(_main_layout)

	_top_spacer = Control.new()
	_top_spacer.name = "TopSpacer"
	_top_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_layout.add_child(_top_spacer)

	_banner_section = BattleArenaBannerScene.instantiate()
	_banner_section.name = "BannerSection"
	_main_layout.add_child(_banner_section)

	_banner_to_content = Control.new()
	_banner_to_content.name = "BannerToCardSpacer"
	_banner_to_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_layout.add_child(_banner_to_content)

	_content_area = CenterContainer.new()
	_content_area.name = "ContentArea"
	_content_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_main_layout.add_child(_content_area)

	_filler_spacer = Control.new()
	_filler_spacer.name = "FillerSpacer"
	_filler_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_filler_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_filler_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_layout.add_child(_filler_spacer)

	_footer_section = Control.new()
	_footer_section.name = "FooterSection"
	_footer_section.custom_minimum_size = Vector2(0, FOOTER_H)
	_main_layout.add_child(_footer_section)


func update_layout():
	var vp = get_window().size
	if vp.x <= 0:
		return

	var factor = vp.x / CANVAS_SIZE.x
	_canvas_root.scale = Vector2(factor, factor)
	_canvas_root.position = Vector2.ZERO

	if _banner_section and _banner_section.has_method("update_spacer_sizes"):
		_banner_section.update_spacer_sizes()

	_top_spacer.custom_minimum_size = Vector2(0, TOP_SPACER_H)
	_banner_to_content.custom_minimum_size = Vector2(0, BANNER_TO_CONTENT_GAP)


func set_banner_enabled(enabled: bool):
	_banner_section.visible = enabled
	_banner_to_content.visible = enabled


func get_canvas_root() -> Control:
	return _canvas_root


func get_safe_area() -> MarginContainer:
	return _ui_safe_area


func get_full_area() -> Control:
	return _full_area


func get_content_area() -> CenterContainer:
	return _content_area


func get_footer_section() -> Control:
	return _footer_section


func get_banner() -> Control:
	return _banner_section as Control
