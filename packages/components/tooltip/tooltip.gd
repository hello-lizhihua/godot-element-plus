extends Control
## 悬停提示气泡：锚定宿主控件，鼠标悬停显示、
## 移出隐藏；本层为全屏 IGNORE 覆盖层，气泡（深色半透 + 白描边 + 小箭头）绘制
## 在宿主上方（placement="top"）或下方居中，不拦截任何输入；也经 show_tip /
## hide_tip 编程控制（触屏长按等场景由使用方接线）。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var text := ""
var placement := "top" # top / bottom

var _target: Control = null
var _visible_tip := false
var _font: SystemFont

const BUBBLE_PADDING_X := 10.0
const BUBBLE_PADDING_Y := 5.0
const ARROW := 5.0
const GAP := 6.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = UITheme.system_font()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	queue_redraw()


## 绑定宿主控件：悬停显隐自动接线（重复绑定先解绑旧宿主）
func attach_to(target: Control, tip_text: String) -> void:
	if _target != null and _target.mouse_entered.is_connected(show_tip):
		_target.mouse_entered.disconnect(show_tip)
		_target.mouse_exited.disconnect(hide_tip)
	_target = target
	text = tip_text
	target.mouse_entered.connect(show_tip)
	target.mouse_exited.connect(hide_tip)


func show_tip() -> void:
	_visible_tip = true
	visible = true
	queue_redraw()


func hide_tip() -> void:
	_visible_tip = false
	visible = false


func _bubble_rect() -> Rect2:
	if _target == null or not _target.is_inside_tree():
		return Rect2()
	var target_rect := Rect2(_target.get_global_position(), _target.size)
	var text_size := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
	var bubble_size := text_size + Vector2(BUBBLE_PADDING_X * 2.0, BUBBLE_PADDING_Y * 2.0)
	var center_x := target_rect.get_center().x - bubble_size.x * 0.5
	var y := target_rect.position.y - bubble_size.y - GAP - ARROW
	if placement == "bottom":
		y = target_rect.end.y + GAP + ARROW
	return Rect2(Vector2(center_x, y), bubble_size)


func _draw() -> void:
	if not _visible_tip:
		return
	var bubble := _bubble_rect()
	draw_rect(bubble, UITheme.POPOUT_FILL, true)
	draw_rect(bubble, UITheme.BORDER_STRONG, false, 1.0, true)
	# 小箭头指向宿主
	var tip_x := bubble.get_center().x
	var tip_y := bubble.position.y - ARROW if placement == "top" else bubble.end.y + ARROW
	var base_y := bubble.position.y if placement == "top" else bubble.end.y
	draw_colored_polygon(PackedVector2Array([
		Vector2(tip_x - ARROW, base_y),
		Vector2(tip_x + ARROW, base_y),
		Vector2(tip_x, tip_y),
	]), UITheme.POPOUT_FILL)
	draw_string(_font, bubble.position + Vector2(BUBBLE_PADDING_X, bubble.size.y * 0.5 + 4.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, UITheme.TEXT_MAIN)
