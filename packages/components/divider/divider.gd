extends Control
## 分割线：水平 1px 分割线；
## 带文案时线在文案两侧断开，文案 12px 弱化色。纯展示。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var text := ""
var line_color := Color(1.0, 1.0, 1.0, 0.14)

var _font: SystemFont


func _init() -> void:
	custom_minimum_size = Vector2(0.0, 12.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = UITheme.system_font()


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, 20.0 if text != "" else 12.0)
	queue_redraw()


func _draw() -> void:
	var y := size.y * 0.5
	if text == "":
		draw_line(Vector2(0.0, y), Vector2(size.x, y), line_color, 1.0, true)
		return
	var text_width := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	var gap := text_width * 0.5 + 12.0
	var center := size.x * 0.5
	draw_line(Vector2(0.0, y), Vector2(center - gap, y), line_color, 1.0, true)
	draw_line(Vector2(center + gap, y), Vector2(size.x, y), line_color, 1.0, true)
	draw_string(_font, Vector2(center - text_width * 0.5, y + 5.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, UITheme.TEXT_FAINT)
