extends Control
## 离散步长滑块：− 圆钮 + 刻度轨道 + 拇指 + ＋ 圆钮，整体衬深色半透胶囊底
## 。点击轨道或拖动定级（四舍五入取最近级），
## ＋/− 按步长进退；触屏与鼠标统一命中，命中就地消费、未命中透传。程序化
## set_value 不发事件；用户操作（点击/拖动/步进，含同级别操作）发 value_changed，
## 供使用方打断命令动画。
## 定位：默认底部（bottom_margin / origin_x）；top_y ≥ 0 时轨道中线取该视口
## y 值（顶部按钮排）；right_align ≥ 0 时右缘按该距离对齐视口右边（随窗口
## 宽度自适应，需使用方逐帧或窗口变化时刷新）。

signal value_changed(level: int)

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")
const HIT_SLACK := 4.0 # 轨道命中放宽：端点级（级 1 / 级 10）点击可命中
const PILL_PADDING := 10.0 # 胶囊底内边距

var min_value := 1
var max_value := 10
var step := 1
var value := 1
var show_ticks := true
var track_width := 170.0
var button_size := 26.0
var bottom_margin := 24.0
var origin_x := 20.0
var top_y := -1.0 # ≥0：轨道中线视口 y；-1：底部模式
var right_align := -1.0 # ≥0：滑块右缘距视口右边（覆盖 origin_x）

var _dragging := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


## 程序化赋值（不发 value_changed，超出范围钳制）
func set_value(v: int) -> void:
	value = clampi(v, min_value, max_value)
	queue_redraw()


func get_value() -> int:
	return value


## 滑块整体胶囊矩形（含衬底边距）
func _pill_rect() -> Rect2:
	var track := _track_rect()
	var left := _minus_rect().position.x - PILL_PADDING
	var top := track.position.y - button_size * 0.5 - PILL_PADDING
	var height := button_size + PILL_PADDING * 2.0
	var right := _plus_rect().end.x + PILL_PADDING
	return Rect2(Vector2(left, top), Vector2(right - left, height))


func _unhandled_input(event: InputEvent) -> void:
	var consumed := false
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and not touch.canceled:
			consumed = _press(touch.position)
		elif _dragging and touch.index == 0:
			_dragging = false
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			if mouse.pressed:
				consumed = _press(mouse.position)
			elif _dragging:
				_dragging = false
				consumed = true
	elif event is InputEventMouseMotion and _dragging:
		_set_from_track((event as InputEventMouseMotion).position)
		consumed = true
	if consumed:
		get_viewport().set_input_as_handled()
		queue_redraw()


func _press(point: Vector2) -> bool:
	# ＋/− 圆钮步进，轨道点击/拖动定级
	if _minus_rect().has_point(point):
		_emit_value(value - step)
		return true
	if _plus_rect().has_point(point):
		_emit_value(value + step)
		return true
	if _track_hit(point):
		_dragging = true
		_set_from_track(point)
		return true
	return false


func _set_from_track(point: Vector2) -> void:
	var track := _track_rect()
	var raw := min_value + (point.x - track.position.x) / track.size.x * float(max_value - min_value)
	var level := int(roundf((raw - min_value) / float(step))) * step + min_value
	_emit_value(level)


func _emit_value(level: int) -> void:
	value = clampi(level, min_value, max_value)
	value_changed.emit(value)


func _centerline_y() -> float:
	var size := get_viewport_rect().size
	if top_y >= 0.0:
		return top_y
	return size.y - bottom_margin - button_size * 0.5


func _origin_left() -> float:
	if right_align >= 0.0:
		var size := get_viewport_rect().size
		return size.x - right_align - (button_size + 12.0 + track_width + 12.0 + button_size)
	return origin_x


func _track_rect() -> Rect2:
	var y := _centerline_y()
	return Rect2(Vector2(_origin_left() + button_size + 12.0, y), Vector2(track_width, 1.0))


func _track_hit(point: Vector2) -> bool:
	var track := _track_rect()
	# 横向放宽 2 点 + 纵向放宽（指尖精度）：轨道端点级点击可命中
	return Rect2(track.position + Vector2(-2.0, -14.0), Vector2(track.size.x + 4.0, 28.0)).has_point(point)


func _minus_rect() -> Rect2:
	var y := _centerline_y()
	return Rect2(Vector2(_origin_left(), y - button_size * 0.5), Vector2(button_size, button_size))


func _plus_rect() -> Rect2:
	var y := _centerline_y()
	return Rect2(Vector2(_track_rect().end.x + 12.0, y - button_size * 0.5), Vector2(button_size, button_size))


func track_right() -> float:
	return _track_rect().end.x


func _draw() -> void:
	# 胶囊衬底：浅色背景上保证整组控件可读
	draw_rect(_pill_rect(), UITheme.CHASSIS_FILL, true)
	draw_rect(_pill_rect(), UITheme.BORDER_STRONG, false, 1.0, true)
	# 轨道（刻度：经过级别琥珀点亮——设计稿定稿，拇指遮挡也能数出级别）
	var track := _track_rect()
	var track_y := track.position.y
	draw_line(Vector2(track.position.x, track_y), Vector2(track.end.x, track_y), UITheme.TEXT_DIM, 2.0, true)
	if show_ticks:
		var levels := (max_value - min_value) / step + 1
		for i in levels:
			var x := track.position.x + track.size.x * float(i) / float(levels - 1)
			var passed := i <= int((value - min_value) / step)
			draw_line(Vector2(x, track_y - 6.0), Vector2(x, track_y + 6.0), UITheme.ACCENT if passed else UITheme.TEXT_FAINT, 1.5, true)
	# ＋/− 圆钮
	for btn in [[_minus_rect(), "-"], [_plus_rect(), "+"]]:
		var rect: Rect2 = btn[0]
		var center := rect.get_center()
		draw_circle(center, button_size / 2.0, UITheme.ROW_IDLE, true, -1.0, true)
		draw_arc(center, button_size / 2.0, 0.0, TAU, 32, UITheme.BORDER_ACTIVE, 1.0, true)
		draw_line(center + Vector2(-6.0, 0.0), center + Vector2(6.0, 0.0), UITheme.TEXT_MAIN, 2.0, true)
		if btn[1] == "+":
			draw_line(center + Vector2(0.0, -6.0), center + Vector2(0.0, 6.0), UITheme.TEXT_MAIN, 2.0, true)
	# 拇指（琥珀 12px + 柔光环，与设计稿一致）
	var t := float(value - min_value) / float(max_value - min_value)
	var thumb := Vector2(track.position.x + track.size.x * t, track_y)
	draw_circle(thumb, 6.0, UITheme.ACCENT, true, -1.0, true)
	draw_arc(thumb, 7.5, 0.0, TAU, 32, Color(UITheme.ACCENT.r, UITheme.ACCENT.g, UITheme.ACCENT.b, 0.25), 3.0, true)
