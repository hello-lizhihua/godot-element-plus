extends Control
## 设置面板：角落齿轮图标 + 单选行弹出面板。点击行立即
## 发出 option_selected（使用方就地生效，场景不重载），面板保持展开；再点图标
## 或点面板外收起。桌面鼠标与触屏统一命中；命中图标/面板的事件就地消费，
## 未命中透传。手风琴：opened 信号 + close_panel() 供使用方互斥开合。
##
## 输入阶段（early_input）：宿主在 _input 阶段处理输入时，点面板外收起会放行事件，
## 让它继续流到 GUI 控件；宿主在 _unhandled_input 阶段处理时，透传由本层完成。
## 面板外点击策略（pass_through_outside）：true = 放行该次点击给后续层（宿主界面
## 是明确点击目标时用），false = 就地吞掉防误触。

signal option_selected(value: String)
signal opened
signal closed
signal switch_toggled(checked: bool)
signal back_selected

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")
const SwitchScript := preload("res://addons/godot-element-plus/switch/switch.gd")

var options: Array = [] # [[标签, 值], ...]
var value := "" # 当前选中值：行高亮 + 行尾选中点
var back_label := "" # 返回行标签（空 = 无返回行；返回行居面板首行，点击发 back_selected）
var switch_label := "" # 开关行标签（空 = 无开关行；开关行居返回行之后）
var switch_checked := false # 开关行当前态
var margin := 40.0 # 齿轮中心横向点距（右锚定时距右边，左锚定时距左边）
var top := 40.0 # 齿轮中心距视口顶部
var left_anchor := false # true 面板与齿轮锚定屏幕左上（左上控制排）；false 右上（右上控制排）
var radius := 16.0
var tooth := 5.0
var hit_slack := 6.0
var early_input := false
var pass_through_outside := false
var panel_width := 148.0
var row_height := 38.0
var row_gap := 6.0
var panel_padding := 8.0
var font_size := 15
var right_offset := 20.0 # 面板右缘距窗口右边
var right_offset_provider := Callable() # 动态右偏移（返回 float），设置时覆盖 right_offset

var _panel_open := false:
	# 面板开合唯一状态入口：从属控件（全屏开关）的显隐与重绘收敛在此，
	# 图标/面板外/返回行任何路径收起都不会泄漏开关到页面上；
	# 收起时发 closed（使用方据手风琴语义恢复让位的面板）
	set(v):
		var was := _panel_open
		_panel_open = v
		_sync_switch()
		queue_redraw()
		if was and not v:
			closed.emit()
var _font: SystemFont
var _switch: Control # ElementSwitch（开关行载体，嵌入面板右上）


func _init() -> void:
	_font = UITheme.system_font()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure_switch()
	queue_redraw()


## 开关行控件懒建（switch_label 入树后才赋值的用法顺序也成立）
func _ensure_switch() -> void:
	if switch_label == "" or _switch != null:
		return
	_switch = SwitchScript.new()
	_switch.checked = switch_checked
	_switch.visible = false
	_switch.track_width = 34.0
	_switch.track_height = 20.0
	_switch.toggled.connect(func(checked: bool):
		switch_checked = checked
		switch_toggled.emit(checked))
	add_child(_switch)


func _input(event: InputEvent) -> void:
	if not early_input:
		return
	_consume(event)


func _unhandled_input(event: InputEvent) -> void:
	if early_input:
		return
	_consume(event)


func _consume(event: InputEvent) -> void:
	var consumed := false
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and not touch.canceled:
			consumed = _handle_press(touch.position)
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			consumed = _handle_press(mouse.position)
	if consumed:
		get_viewport().set_input_as_handled()
		queue_redraw()


## 按下即生效（单触语义，与触屏按钮组一致）。返回 true 表示事件由本层消费。
func _handle_press(point: Vector2) -> bool:
	if _panel_open:
		if _hit_icon(point):
			_panel_open = false # 再点图标收起
		else:
			var row := _hit_row(point)
			if row >= 0:
				if has_back() and row == _back_row_index():
					# 返回行：发出返回信号（使用方切换场景），面板收起
					_panel_open = false
					back_selected.emit()
					return true
				if has_switch() and row == _switch_row_index():
					if _switch != null and _switch_rect().has_point(point):
						return false # 开关控件矩形内：放行给控件自身（GUI 阶段处理）
					# 开关行点击翻转
					switch_checked = not switch_checked
					_sync_switch()
					switch_toggled.emit(switch_checked)
				else:
					# 选择立即生效：就地切换，面板保持展开
					var option_row := row - _option_row_offset()
					value = str(options[option_row][1])
					option_selected.emit(value)
			elif _panel_rect().has_point(point):
				pass # 面板空白处：保持展开，吞掉防误触
			else:
				# 点面板外收起；pass_through_outside 决定是否放行本次点击
				_panel_open = false
				if pass_through_outside:
					return false
		return true
	if _hit_icon(point):
		_panel_open = true
		opened.emit()
		return true
	return false


func open_panel() -> void:
	_panel_open = true


func close_panel() -> void:
	# 手风琴：另一方展开时由使用方调用收起本面板
	_panel_open = false


func is_open() -> bool:
	return _panel_open


func has_switch() -> bool:
	return switch_label != ""


func has_back() -> bool:
	return back_label != ""


## 选项行数（不含返回行与开关行）
func count() -> int:
	return options.size()


## 程序化设置开关态（不发事件；全屏按钮等其他入口切换后回推用）
func set_switch_checked(v: bool) -> void:
	switch_checked = v
	_sync_switch()


func icon_center() -> Vector2:
	var size := get_viewport_rect().size
	return Vector2(margin if left_anchor else size.x - margin, top)


## 齿轮命中区矩形（radius+tooth+hit_slack 外接；面板几何登记与互斥断言用）
func icon_rect() -> Rect2:
	var half := radius + tooth + hit_slack
	return Rect2(icon_center() - Vector2(half, half), Vector2(half * 2.0, half * 2.0))


func row_center(row: int) -> Vector2:
	return _row_rect(row).get_center()


func _hit_icon(point: Vector2) -> bool:
	return point.distance_to(icon_center()) <= radius + tooth + hit_slack


func _back_row_index() -> int:
	return 0 if has_back() else -1


func _switch_row_index() -> int:
	return (1 if has_back() else 0) if has_switch() else -1


func _option_row_offset() -> int:
	return (1 if has_back() else 0) + (1 if has_switch() else 0)


func _hit_row(point: Vector2) -> int:
	var total_rows := options.size() + _option_row_offset()
	for row in total_rows:
		if _row_rect(row).has_point(point):
			return row
	return -1


## 行矩形（row 含开关行：存在时 row 0 为开关行，其余为选项行）
func _row_rect(row: int) -> Rect2:
	var panel := _panel_rect()
	return Rect2(
		panel.position.x + panel_padding,
		panel.position.y + panel_padding + (row_height + row_gap) * float(row),
		panel_width - panel_padding * 2.0,
		row_height)


## 开关控件矩形（开关行右端）
func _switch_rect() -> Rect2:
	var row := _row_rect(_switch_row_index())
	return Rect2(row.position + Vector2(row.size.x - 44.0, (row.size.y - 20.0) * 0.5), Vector2(34.0, 20.0))


## 开关控件显隐、位置与状态同步（面板几何就绪后调用）
func _sync_switch() -> void:
	_ensure_switch()
	if _switch == null:
		return
	_switch.visible = _panel_open
	if _panel_open:
		var rect := _switch_rect()
		_switch.position = rect.position
	_switch.set_checked(switch_checked)


func _panel_rect() -> Rect2:
	var size := get_viewport_rect().size
	# 总行数含返回行与开关行（选项行偏移同一来源，绘制与命中、面板高度三处一致）
	var total_rows := options.size() + _option_row_offset()
	var height := panel_padding * 2.0 + row_height * total_rows + row_gap * float(maxi(total_rows - 1, 0))
	if left_anchor:
		return Rect2(margin, top + radius + tooth + 10.0, panel_width, height)
	var offset := right_offset
	if right_offset_provider.is_valid():
		offset = right_offset_provider.call()
	return Rect2(size.x - offset - panel_width, top + radius + tooth + 10.0, panel_width, height)


func _draw() -> void:
	var center := icon_center()
	# 图标按钮底盘：深色半透圆 + 白描边（与收起把手同款按钮风格）
	draw_circle(center, radius, UITheme.CHASSIS_FILL, true, -1.0, true)
	draw_arc(center, radius, 0.0, TAU, 48, UITheme.BORDER_STRONG, 1.0, true)
	# 齿轮字形：8 齿梯形齿与根圆一体（米白），中孔透出底盘色 + 轴点
	var teeth := 8
	var step := TAU / float(teeth)
	var root_half := step * 0.26
	var tip_half := step * 0.15
	var points := PackedVector2Array()
	for i in teeth:
		var angle := float(i) * step
		points.append(center + Vector2(cos(angle - root_half), sin(angle - root_half)) * 8.0)
		points.append(center + Vector2(cos(angle - tip_half), sin(angle - tip_half)) * 12.0)
		points.append(center + Vector2(cos(angle + tip_half), sin(angle + tip_half)) * 12.0)
		points.append(center + Vector2(cos(angle + root_half), sin(angle + root_half)) * 8.0)
	draw_colored_polygon(points, UITheme.TEXT_MAIN)
	draw_circle(center, 4.5, UITheme.CHASSIS_FILL, true, -1.0, true)
	draw_circle(center, 1.8, UITheme.TEXT_MAIN, true, -1.0, true)
	if not _panel_open:
		return
	# 面板：深色半透 + 白描边；开关行（可选）居首 + 单选行，当前值行高亮 + 选中点
	var panel := _panel_rect()
	draw_rect(panel, UITheme.POPOUT_FILL, true)
	draw_rect(panel, UITheme.BORDER_STRONG, false, 1.0, true)
	var option_offset := _option_row_offset()
	if has_back():
		var back_row := _row_rect(0)
		draw_string(_font, back_row.position + Vector2(12.0, back_row.size.y * 0.68), back_label, HORIZONTAL_ALIGNMENT_LEFT, back_row.size.x - 24.0, font_size, UITheme.TEXT_MAIN)
	if has_switch():
		_sync_switch()
		var switch_row := _row_rect(_switch_row_index())
		draw_string(_font, switch_row.position + Vector2(12.0, row_height * 0.68), switch_label, HORIZONTAL_ALIGNMENT_LEFT, switch_row.size.x - 60.0, font_size, UITheme.TEXT_MAIN)
		# 开关行下的分隔线
		draw_rect(Rect2(switch_row.position.x, switch_row.end.y + row_gap * 0.5, switch_row.size.x, 1.0), UITheme.BORDER_SOFT, true)
	for row in options.size():
		var rect := _row_rect(row + option_offset)
		var active: bool = str(options[row][1]) == value
		draw_rect(rect, UITheme.ROW_ACTIVE if active else UITheme.ROW_IDLE, true)
		draw_string(
			_font,
			rect.position + Vector2(12.0, row_height * 0.68),
			str(options[row][0]),
			HORIZONTAL_ALIGNMENT_LEFT,
			rect.size.x - 28.0,
			font_size,
			UITheme.TEXT_MAIN if active else UITheme.TEXT_FAINT
		)
		if active:
			draw_circle(Vector2(rect.end.x - 14.0, rect.get_center().y), 3.0, UITheme.TEXT_MAIN, true, -1.0, true)
