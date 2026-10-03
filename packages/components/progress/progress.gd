extends Control
## 进度条：圆角轨道（白 6% 底）
## + 琥珀填充条 + 右端百分比小字。纯展示，使用方经 set_value 驱动。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var value := 0.0 # 0-100
var bar_height := 8.0
var show_percent := true

var _font: SystemFont

const TRACK_COLOR := Color(1.0, 1.0, 1.0, 0.06)


func _init() -> void:
	custom_minimum_size = Vector2(160.0, 16.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = UITheme.system_font()


func set_value(v: float) -> void:
	value = clampf(v, 0.0, 100.0)
	queue_redraw()


func get_value() -> float:
	return value


func _draw() -> void:
	var bar_size := Vector2(size.x, bar_height) if not show_percent else Vector2(size.x - 44.0, bar_height)
	var track := Rect2(Vector2.ZERO, bar_size)
	var radius := bar_height * 0.5
	draw_rect(track, TRACK_COLOR, true)
	if value > 0.0:
		var fill_width := maxf(bar_size.x * value / 100.0, radius)
		draw_rect(Rect2(Vector2.ZERO, Vector2(fill_width, bar_height)), UITheme.ACCENT, true)
	if show_percent:
		draw_string(_font, Vector2(bar_size.x + 8.0, size.y * 0.5 + 5.0), "%d%%" % roundi(value), HORIZONTAL_ALIGNMENT_LEFT, 40.0, 12, UITheme.TEXT_FAINT)
