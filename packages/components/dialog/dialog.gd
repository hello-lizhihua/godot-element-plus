extends Control
## 对话框：全屏遮罩（黑 40%）
## + 居中深色半透面板（圆角 14、白 32% 描边）+ 标题栏（标题 + 右上角 × 关闭钮）
## + 内容容器。模态：遮罩与面板就地消费点击，点遮罩不关闭（显式调 close_dialog
## 或点 ×）。使用方经 content() 填充内容。

signal opened
signal closed

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var title := ""
var width := 360.0
var visible_modal := true

var _panel_open := false
var _content: VBoxContainer
var _font: SystemFont

const TITLE_HEIGHT := 42.0
const PANEL_MARGIN := 16.0
const MIN_HEIGHT := 120.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = UITheme.system_font()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func open_dialog() -> void:
	_panel_open = true
	visible = true
	opened.emit()
	queue_redraw()


func close_dialog() -> void:
	if _panel_open:
		_panel_open = false
		visible = false
		closed.emit()


func is_open() -> bool:
	return _panel_open


## 内容容器（标题栏之下，高度随内容自适应）
func content() -> VBoxContainer:
	return _content


func _unhandled_input(event: InputEvent) -> void:
	# 模态：就地消费一切点击，防止穿透到场景
	var pressed := false
	if event is InputEventScreenTouch:
		pressed = (event as InputEventScreenTouch).pressed
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		pressed = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	if pressed and _panel_open and get_viewport() != null:
		get_viewport().set_input_as_handled()
		if _close_rect().has_point(_event_point(event)):
			close_dialog()
		queue_redraw()


func _event_point(event: InputEvent) -> Vector2:
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).position
	return (event as InputEventMouseButton).position


func _panel_rect() -> Rect2:
	var size := get_viewport_rect().size
	return Rect2(Vector2((size.x - width) * 0.5, (size.y - MIN_HEIGHT) * 0.5), Vector2(width, MIN_HEIGHT))


func _close_rect() -> Rect2:
	var panel := _panel_rect()
	return Rect2(panel.position + Vector2(panel.size.x - 32.0, 5.0), Vector2(24.0, 24.0))


func _draw() -> void:
	if not _panel_open:
		return
	var size := get_viewport_rect().size
	if visible_modal:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.4), true)
	var panel := _panel_rect()
	draw_rect(panel, UITheme.DOCK_FILL, true)
	draw_rect(panel, UITheme.BORDER_STRONG, false, 1.0, true)
	# 标题栏 + 分隔线
	draw_string(_font, panel.position + Vector2(PANEL_MARGIN, 27.0), title, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 64.0, 15, UITheme.TEXT_MAIN)
	draw_string(_font, _close_rect().position + Vector2(0.0, 18.0), "×", HORIZONTAL_ALIGNMENT_CENTER, 24.0, 16, UITheme.TEXT_DIM)
	draw_rect(Rect2(panel.position + Vector2(0.0, TITLE_HEIGHT), Vector2(panel.size.x, 1.0)), UITheme.BORDER_SOFT, true)
	# 内容容器（首次绘制时创建，置于面板内容起点）
	if _content == null:
		_content = VBoxContainer.new()
		_content.add_theme_constant_override("separation", UITheme.GAP_XS)
		add_child(_content)
	_content.position = panel.position + Vector2(PANEL_MARGIN, TITLE_HEIGHT + PANEL_MARGIN * 0.5)
	_content.size = Vector2(panel.size.x - PANEL_MARGIN * 2.0, 0.0)
