extends Control
## 开关：全宽圆角轨道 + 白色滑动
## 圆钮——关 = 白 14% 底、圆钮居左；开 = 琥珀底、圆钮居右。控件矩形内鼠标与
## 触屏点击切换；程序化 set_checked 不发事件，用户切换发 toggled。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

signal toggled(checked: bool)

var checked := false
var track_width := 40.0
var track_height := 22.0

var _font: SystemFont


func _init() -> void:
	custom_minimum_size = Vector2(track_width, track_height)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = UITheme.system_font()


func _ready() -> void:
	custom_minimum_size = Vector2(track_width, track_height)
	queue_redraw()


func set_checked(v: bool) -> void:
	checked = v
	queue_redraw()


func is_checked() -> bool:
	return checked


func _gui_input(event: InputEvent) -> void:
	var hit := false
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		hit = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		hit = touch.pressed and not touch.canceled
	if hit:
		checked = not checked
		queue_redraw()
		toggled.emit(checked)
		accept_event()


func _draw() -> void:
	# 胶囊轨道（两端半圆）：关 = 白 14% 底 + 描边、开 = 琥珀底
	var track := Rect2(Vector2.ZERO, Vector2(track_width, track_height))
	var r := track_height * 0.5
	var center_y := track.get_center().y
	var fill := UITheme.ACCENT if checked else UITheme.ROW_HOVER
	draw_rect(Rect2(track.position.x + r, track.position.y, track.size.x - track_height, track_height), fill, true)
	draw_circle(Vector2(track.position.x + r, center_y), r, fill, true, -1.0, true)
	draw_circle(Vector2(track.end.x - r, center_y), r, fill, true, -1.0, true)
	if not checked:
		# 关态轨道在浅底上需要描边保持可见（沿胶囊轮廓）
		draw_arc(Vector2(track.position.x + r, center_y), r, PI * 0.5, PI * 1.5, 24, UITheme.BORDER_STRONG, 1.0, true)
		draw_arc(Vector2(track.end.x - r, center_y), r, -PI * 0.5, PI * 0.5, 24, UITheme.BORDER_STRONG, 1.0, true)
		draw_line(Vector2(track.position.x + r, track.position.y), Vector2(track.end.x - r, track.position.y), UITheme.BORDER_STRONG, 1.0, true)
		draw_line(Vector2(track.position.x + r, track.end.y), Vector2(track.end.x - r, track.end.y), UITheme.BORDER_STRONG, 1.0, true)
	var knob_radius := track_height * 0.5 - 3.0
	var knob_x := track_width - track_height * 0.5 - 1.0 if checked else track_height * 0.5 + 1.0
	draw_circle(Vector2(knob_x, track_height * 0.5), knob_radius, UITheme.TEXT_MAIN, true, -1.0, true)
