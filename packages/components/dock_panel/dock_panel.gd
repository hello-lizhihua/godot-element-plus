extends Control
## 右侧停靠面板：深色半透底 + 左缘 1px 分隔线 + 头部收起钮；
## 内容区顶距让开头部带（标题/计数/收起钮）再带内边距（4/8/8）由使用方填充。
## 收起 = 面板带滑出动画整体移出屏幕右侧，
## 右缘只留一个圆形「›」把手按钮（与图标按钮同款样式），点击带动画展开——
## 面板区域内滚轮一律就地消费（列表到顶/到底时不再穿透成场景缩放）；面板内
## 未命中控件的按压就地吞掉（防透传成场景拖动）。

signal collapse_toggled(expanded: bool)

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var width := 300.0
var top := 20.0 # 与左上角控制排同高（设置齿轮/滑块上缘对齐）
var bottom_margin := 20.0
var right_margin := 12.0
var header_height := 34.0
var pad_x := 14.0
var collapsed := false
var title := ""
var header_count := -1 # -1 不显示计数

var _panel_margins: MarginContainer
var _content: VBoxContainer
var _handle: Control # 收起态右缘圆形「›」把手（独立子控件：屏内不被画布剔除，gui_input 命中）
var _font: SystemFont
var _collapse_tween: Tween

const ACCENT_WIDTH := 3.0
const HANDLE_SIZE := 32.0
const COLLAPSE_SLIDE_SEC := 0.28


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = UITheme.system_font()


func _ready() -> void:
	get_viewport().size_changed.connect(_relayout)
	_panel_margins = MarginContainer.new()
	# 普通 Control 的子节点不自动拉伸：MarginContainer 需全矩形锚点撑满面板；
	# 顶距让开头部带（标题/计数/收起钮），内容不得与头部 chrome 重叠
	_panel_margins.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel_margins.add_theme_constant_override("margin_top", int(header_height) + 2)
	_panel_margins.add_theme_constant_override("margin_left", 8)
	_panel_margins.add_theme_constant_override("margin_right", 8)
	_panel_margins.add_theme_constant_override("margin_bottom", 8)
	add_child(_panel_margins)
	_content = VBoxContainer.new()
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_panel_margins.add_child(_content)
	_handle = Control.new()
	_handle.size = Vector2(HANDLE_SIZE, HANDLE_SIZE)
	_handle.mouse_filter = Control.MOUSE_FILTER_STOP
	_handle.visible = false
	_handle.draw.connect(_draw_handle.bind(_handle))
	_handle.gui_input.connect(_on_handle_input)
	add_child(_handle)
	_relayout()


## 内容容器（头部之下、带内边距）；使用方向其中填充行、列表等
func content() -> VBoxContainer:
	return _content


func is_expanded() -> bool:
	return not collapsed


func toggle_collapsed() -> void:
	set_collapsed(not collapsed)


## 收起 / 展开（滑出动画：收起滑向屏幕右侧后正文隐藏，右缘只留圆形「›」把手；
## 控制件本体保持可见承载把手绘制，命中走 _input 前置阶段；展开从屏幕右侧滑回）
func set_collapsed(v: bool) -> void:
	if collapsed == v:
		return
	collapsed = v
	if _collapse_tween != null and _collapse_tween.is_valid():
		_collapse_tween.kill()
	var vp_x := get_viewport_rect().size.x
	var target_x := vp_x - right_margin - width
	collapse_toggled.emit(not collapsed)
	if collapsed:
		# 滑出动画结束后：正文隐藏，圆形把手在视口边缘点亮（独立子控件，钉屏内）
		_collapse_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		_collapse_tween.tween_method(_slide_x, position.x, vp_x + 20.0, COLLAPSE_SLIDE_SEC)
		_collapse_tween.tween_callback(func():
			_panel_margins.visible = false # 正文隐藏；把手子控件接管右缘
			_handle.position = _handle_rect().position - position
			_handle.visible = true)
		queue_redraw()
		return
	_handle.visible = false
	position.x = vp_x + 20.0
	_panel_margins.visible = true
	queue_redraw()
	_collapse_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_collapse_tween.tween_method(_slide_x, position.x, target_x, COLLAPSE_SLIDE_SEC)
	collapse_toggled.emit(true)


func _slide_x(x: float) -> void:
	position.x = x
	queue_redraw()


func set_header(title_text: String, count: int) -> void:
	title = title_text
	header_count = count
	queue_redraw()


func _relayout() -> void:
	if not is_inside_tree():
		return
	var vp := get_viewport_rect().size
	position = Vector2(vp.x - right_margin - width, top)
	size = Vector2(width, maxf(vp.y - top - bottom_margin, 100.0))
	if collapsed:
		# 收起态控制件整体驻留屏幕外（正文已由 _panel_margins 隐藏）；把手子控件
		# 钉在视口边缘（本地坐标 = 视口锚点 - 控制件位移），屏内不被画布剔除
		position.x = vp.x + 20.0
		_handle.position = _handle_rect().position - position
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	# 展开态本体命中：本控件是 STOP 控件，本体矩形内点击在 GUI 阶段即被消费、
	# 不会再进 _unhandled_input——头部收起钮与滚轮就地消费都必须在这里处理
	if collapsed:
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if not mouse.pressed:
			return
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			# 头部收起按钮：带滑出动画收起；其余未命中子控件的按压就地吞掉
			if _chevron_rect().has_point(mouse.position):
				set_collapsed(true)
			accept_event()
		elif mouse.button_index == MOUSE_BUTTON_WHEEL_UP or mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			accept_event() # 滚轮就地消费，不穿透成场景缩放
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and not touch.canceled:
			if _chevron_rect().has_point(touch.position):
				set_collapsed(true)
			accept_event()


## 收起态右缘圆形「›」把手绘制（把手控件本地坐标 32×32，与图标按钮同款样式）
func _draw_handle(handle: Control) -> void:
	var center := Vector2(HANDLE_SIZE, HANDLE_SIZE) * 0.5
	handle.draw_circle(center, HANDLE_SIZE * 0.5, UITheme.CHASSIS_FILL, true, -1.0, true)
	handle.draw_arc(center, HANDLE_SIZE * 0.5, 0.0, TAU, 48, UITheme.BORDER_STRONG, 1.0, true)
	handle.draw_string(_font, Vector2(HANDLE_SIZE * 0.5 - 4.0, HANDLE_SIZE * 0.5 + 5.0), "›", HORIZONTAL_ALIGNMENT_LEFT, 12.0, 14, UITheme.TEXT_MAIN)


func _on_handle_input(event: InputEvent) -> void:
	# 把手点击展开（GUI 阶段命中：把手是屏内 STOP 子控件）
	var pressed := false
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		pressed = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		pressed = touch.pressed and not touch.canceled
	if pressed:
		set_collapsed(false)
		_handle.accept_event()


## 收起态右缘圆形「›」把手矩形（视口坐标）
func _handle_rect() -> Rect2:
	var vp := get_viewport_rect().size
	return Rect2(Vector2(vp.x - right_margin - HANDLE_SIZE, top), Vector2(HANDLE_SIZE, HANDLE_SIZE))


## 头部收起按钮矩形（控件本地坐标；_gui_input 的事件位置即本地坐标）
func _chevron_rect() -> Rect2:
	return Rect2(Vector2(size.x - 32.0, 2.0), Vector2(24.0, 24.0))


func _draw() -> void:
	# 完全收起后正文不画（把手由独立子控件绘制）；滑出动画期间正文随控制件滑出
	if collapsed and not _panel_margins.visible:
		return
	# 面板底色 + 左缘 1px 分隔线
	draw_rect(Rect2(Vector2.ZERO, size), UITheme.DOCK_FILL)
	draw_rect(Rect2(Vector2.ZERO, Vector2(1.0, size.y)), UITheme.BORDER_SOFT)
	# 头部：标题（可选）+ 计数（可选）+ 收起按钮（‹）
	if title != "":
		draw_string(_font, Vector2(pad_x, 22.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UITheme.TEXT_MAIN)
	if header_count >= 0:
		draw_string(_font, Vector2(size.x - pad_x - 80.0, 22.0), str(header_count), HORIZONTAL_ALIGNMENT_RIGHT, 80.0, 13, UITheme.TEXT_DIM)
	draw_string(_font, Vector2(size.x - 28.0, 22.0), "‹", HORIZONTAL_ALIGNMENT_LEFT, 20.0, 17, UITheme.TEXT_DIM)
