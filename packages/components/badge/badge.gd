extends Control
## 徽章：右上角小圆点或数字胶囊
## （琥珀底 + 深色文字），作为独立小控件叠加在宿主控件角落（经 position 放置）。
## count 大于 0 显示数字，等于 0 显示小圆点。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var count := 0
var show := true

var _font: SystemFont

const DOT_RADIUS := 4.0
const PILL_HEIGHT := 14.0


func _init() -> void:
	custom_minimum_size = Vector2(DOT_RADIUS * 2.0, DOT_RADIUS * 2.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = UITheme.system_font()


func set_count(v: int) -> void:
	count = maxi(v, 0)
	queue_redraw()


func set_show(v: bool) -> void:
	show = v
	queue_redraw()


func _draw() -> void:
	if not show:
		return
	if count > 0:
		var text := str(count)
		var text_width := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		var pill_width := maxf(text_width + 10.0, PILL_HEIGHT)
		var pill := Rect2(Vector2.ZERO, Vector2(pill_width, PILL_HEIGHT))
		custom_minimum_size = Vector2(pill_width, PILL_HEIGHT)
		draw_rect(pill, UITheme.ACCENT, true)
		draw_string(_font, Vector2((pill_width - text_width) * 0.5, PILL_HEIGHT * 0.72), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.16, 0.15, 0.10))
	else:
		custom_minimum_size = Vector2(DOT_RADIUS * 2.0, DOT_RADIUS * 2.0)
		draw_circle(Vector2(DOT_RADIUS, DOT_RADIUS), DOT_RADIUS, UITheme.ACCENT, true, -1.0, true)
