extends Control
## 图标按钮：圆形底盘 + 程序化图标，锚定屏幕角落；桌面鼠标与触屏统一命中，
## 命中就地消费、未命中透传给场景其他层。子类可定义标准行为（最大化切换 /
## 返回场景），或直接连接 pressed 自行接线。

signal pressed

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")
const ICON_TOOTH := 5.0 # 命中外扩（与齿轮齿顶一致，命中区合计 radius + tooth + slack）

var icon := "gear" # gear 齿轮 / list 列表 / back 返回箭头 / maximize 最大化（状态感知，见 ElementWindowButton）
var corner := "top-right" # top-right / top-left
var margin := 40.0 # 图标中心距角落横向点距
var radius := 16.0
var hit_slack := 6.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func icon_center() -> Vector2:
	var size := get_viewport_rect().size
	if corner == "top-left":
		return Vector2(margin, margin)
	return Vector2(size.x - margin, margin)


func is_hit(point: Vector2) -> bool:
	return point.distance_to(icon_center()) <= radius + ICON_TOOTH + hit_slack


func _unhandled_input(event: InputEvent) -> void:
	var hit := false
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and not touch.canceled:
			hit = is_hit(touch.position)
			if hit:
				_on_pressed()
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			hit = is_hit(mouse.position)
			if hit:
				_on_pressed()
	if hit:
		get_viewport().set_input_as_handled()
		queue_redraw()


## 按下处理：默认只发 pressed；子类覆盖以附加标准行为（在 emit 前执行）
func _on_pressed() -> void:
	pressed.emit()


func _draw() -> void:
	var center := icon_center()
	_draw_under(center)
	draw_circle(center, radius, UITheme.CHASSIS_FILL, true, -1.0, true)
	draw_arc(center, radius, 0.0, TAU, 48, UITheme.BORDER_STRONG, 1.0, true)
	_draw_glyph(center)


## 底盘之下图层钩子（齿轮齿顶先画，被半透底盘压暗，与既有实现一致）
func _draw_under(_center: Vector2) -> void:
	if icon == "gear":
		for i in 8:
			var dir := Vector2(cos(TAU * float(i) / 8.0), sin(TAU * float(i) / 8.0))
			draw_line(_center + dir * (radius - 2.0), _center + dir * (radius + ICON_TOOTH), UITheme.TEXT_MAIN, 3.0, true)


## 底盘之上图标钩子
func _draw_glyph(_center: Vector2) -> void:
	match icon:
		"gear":
			# 齿轮内环 + 轴孔（齿顶已在底盘之下画出）
			draw_arc(_center, radius - 6.0, 0.0, TAU, 32, UITheme.TEXT_MAIN, 1.5, true)
			draw_circle(_center, 2.5, UITheme.TEXT_MAIN, true, -1.0, true)
		"list":
			_draw_list_glyph(_center)
		"back":
			_draw_back_glyph(_center)


func _draw_list_glyph(center: Vector2) -> void:
	# 列表图标：三横线，首行带圆点
	var half := 6.0
	for i in 3:
		var y := center.y - half + float(i) * 6.0
		if i == 0:
			draw_circle(Vector2(center.x - half, y), 1.6, UITheme.TEXT_MAIN)
		draw_line(Vector2(center.x - half + (5.0 if i == 0 else 0.0), y), Vector2(center.x + half, y), UITheme.TEXT_MAIN, 2.0, true)


func _draw_back_glyph(center: Vector2) -> void:
	# 左向箭头
	var y := center.y
	draw_line(Vector2(center.x + 6.0, y), Vector2(center.x - 6.0, y), UITheme.TEXT_MAIN, 2.0, true)
	draw_polyline(PackedVector2Array([Vector2(center.x - 1.0, y - 5.0), Vector2(center.x - 6.0, y), Vector2(center.x - 1.0, y + 5.0)]), UITheme.TEXT_MAIN, 2.0, true)
