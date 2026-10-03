extends Control
## 选择器：收起态 = 外置标签（可选）
## + 圆角选择框（当前标签或占位文字 + [× 清除] + ▾ 箭头）；展开态 = 下方深色半透
## 弹出面板。单选模式（multiple = false）：点击行选中并收起，发 option_selected。
## 多选模式（multiple = true）：点击行切换勾选，面板保持展开，发 option_toggled，
## 勾选集合经 values / set_values / get_values 读写；exclusive_first 时首项
## （如「全部」）与其他项互斥、代替无筛选语义，show_clear 时有勾选显示「×」
## 清除按钮（点击清空勾选并发 selection_cleared；清空后的语义由使用方回推）。
## 点面板外收起。控件矩形内点击走 gui_input 开合；面板行与面板外点击走
## _input 前置阶段命中消费（面板内 STOP 控件会拦掉 _unhandled_input）。

signal option_selected(value: String)
signal option_toggled(value: String)
signal selection_cleared
signal opened

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var options: Array = [] # [[标签, 值], ...]
var value := "" # 单选模式当前值
var values: Array = [] # 多选模式勾选值集合
var multiple := false
var exclusive_first := false # 多选模式：首项与其他项互斥（「全部」语义）
var show_clear := false # 多选模式：有勾选时显示「×」清除按钮
var label := "" # 外置标签（绘制在选择框左侧）
var label_width := 32.0 # 外置标签宽度
var placeholder := "" # 无选中时选择框显示文字
var popup_top_y_provider := Callable() # 有效时弹层顶边钉在该视口 y（列表贴宿主面板顶部，覆盖筛选行）
var width := 148.0: # 选择框总宽（含外置标签）：setter 同步最小尺寸，容器布局按实宽分配
	set(v):
		width = v
		custom_minimum_size.x = v
var row_height := 34.0
var font_size := 14
var control_height := 30.0

var _panel_open := false
var _font: SystemFont

const ROW_GAP := 4.0
const PANEL_MARGIN := 6.0
const CARET_WIDTH := 14.0
const CLEAR_WIDTH := 16.0


func _init() -> void:
	custom_minimum_size = Vector2(width, control_height)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = UITheme.system_font()


func _ready() -> void:
	custom_minimum_size = Vector2(width, control_height)
	queue_redraw()


func open_panel() -> void:
	_panel_open = true
	_raise_popup()
	opened.emit()
	queue_redraw()


## 弹层期间抬高本控件 z 序：弹层向下方展开，须盖过后绘制的兄弟控件。
## 用 z_index 而非 move_to_front——后者会改子节点顺序，容器按子节点序布局
## 会让兄弟行互换位置
func _raise_popup() -> void:
	z_index = 1


func _lower_popup() -> void:
	z_index = 0


func close_panel() -> void:
	if _panel_open:
		_panel_open = false
		_lower_popup()
		queue_redraw()


func is_open() -> bool:
	return _panel_open


## 选项总数
func count() -> int:
	return options.size()


## 单选模式程序化赋值（不发事件）
func set_value(v: String) -> void:
	value = v
	queue_redraw()


## 多选模式程序化赋值（不发事件，未出现的值保留）
func set_values(v: Array) -> void:
	values = v.duplicate()
	queue_redraw()


func get_values() -> Array:
	return values.duplicate()


## 清空多选勾选（clearable「×」点击路径；清空后语义由使用方回推）
func clear_selection() -> void:
	values = []
	queue_redraw()


func _label_of(v: String) -> String:
	for option in options:
		if str(option[1]) == v:
			return str(option[0])
	return ""


func _first_value() -> String:
	return str(options[0][1]) if options.size() > 0 else ""


## 可清除勾选：多选且有勾选；exclusive_first 时仅勾首项（「全部」= 无筛选语义）
## 不算——× 不显示，点击该区域按开合面板处理
func _has_clearable_selection() -> bool:
	if not multiple or values.is_empty():
		return false
	if exclusive_first and values.size() == 1 and values.has(_first_value()):
		return false
	return true


func _box_label() -> String:
	if multiple:
		if exclusive_first and values.has(_first_value()):
			return _label_of(_first_value())
		if values.is_empty():
			return placeholder
		if values.size() == 1:
			return _label_of(str(values[0]))
		return "%s 等 %d 项" % [_label_of(str(values[0])), values.size()]
	var label_text := _label_of(value)
	return label_text if label_text != "" else placeholder


func _input(event: InputEvent) -> void:
	# 弹层行命中走 _input 前置阶段（GUI 之前）：面板内 STOP 控件会在 GUI 阶段
	# 拦掉点击，_unhandled_input 的命中到不了这里
	if not _panel_open:
		return
	var point := Vector2.ZERO
	var pressed := false
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		point = touch.position
		pressed = touch.pressed and not touch.canceled
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		point = mouse.position
		pressed = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	if not pressed:
		return
	# 选择框本体由 gui_input 处理；这里处理面板行命中与面板外收起
	if _panel_rect().has_point(point):
		var row := _hit_row(point)
		if row >= 0:
			_pick_row(row)
		get_viewport().set_input_as_handled()
	elif not get_global_rect().has_point(point):
		_panel_open = false
		_lower_popup()
		queue_redraw()


func _pick_row(row: int) -> void:
	var option_value := str(options[row][1])
	if multiple:
		if exclusive_first:
			# 首项「全部」与其他项互斥
			if option_value == _first_value():
				if !(values.size() == 1 and values.has(_first_value())):
					values = [_first_value()]
					option_toggled.emit(option_value)
			elif values.has(option_value):
				values.erase(option_value)
				option_toggled.emit(option_value) # 取消勾选同样上报（否则使用方选中状态不同步）
			else:
				values.erase(_first_value())
				values.append(option_value)
				option_toggled.emit(option_value)
		else:
			if values.has(option_value):
				values.erase(option_value)
			else:
				values.append(option_value)
			option_toggled.emit(option_value)
	else:
		value = option_value
		_panel_open = false
		_lower_popup()
		option_selected.emit(value)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var hit := false
	var point := Vector2.ZERO
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		hit = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
		point = mouse.position
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		hit = touch.pressed and not touch.canceled
		point = touch.position
	if hit:
		if show_clear and _has_clearable_selection() and _clear_rect().has_point(point):
			# clearable「×」：清空勾选（使用方经 selection_cleared 回退首项语义），不开合面板
			clear_selection()
			selection_cleared.emit()
		else:
			_panel_open = not _panel_open
			if _panel_open:
				_raise_popup()
				opened.emit()
		queue_redraw()
		accept_event()


## 选择框矩形（外置标签时右移 label_width）
func _box_rect() -> Rect2:
	var box_x := label_width if label != "" else 0.0
	return Rect2(Vector2(box_x, 0.0), Vector2(width - box_x, size.y))


## 清除按钮矩形（caret 左侧）
func _clear_rect() -> Rect2:
	var box := _box_rect()
	return Rect2(Vector2(box.end.x - CARET_WIDTH - CLEAR_WIDTH, (box.size.y - 16.0) * 0.5), Vector2(CLEAR_WIDTH, 16.0))


func _panel_rect() -> Rect2:
	var height := PANEL_MARGIN * 2.0 + row_height * options.size() + ROW_GAP * float(maxi(options.size() - 1, 0))
	var box := _box_rect()
	var top := size.y + 4.0
	if popup_top_y_provider.is_valid():
		# 弹层贴宿主面板顶部：顶边钉在提供方给的视口 y（绘制时换算本地坐标）
		top = float(popup_top_y_provider.call()) - get_global_rect().position.y
	return Rect2(get_global_rect().position + Vector2(box.position.x, top), Vector2(box.size.x, height))


## 选项行矩形（视口坐标，测试与截图管线用）
func option_rect(row: int) -> Rect2:
	return Rect2(
		_panel_rect().position + Vector2(PANEL_MARGIN, PANEL_MARGIN + (row_height + ROW_GAP) * float(row)),
		Vector2(_box_rect().size.x - PANEL_MARGIN * 2.0, row_height))


func _hit_row(point: Vector2) -> int:
	for row in options.size():
		if option_rect(row).has_point(point):
			return row
	return -1


func _draw() -> void:
	# 外置标签
	if label != "":
		draw_string(_font, Vector2(0.0, size.y * 0.68), label, HORIZONTAL_ALIGNMENT_LEFT, label_width, font_size, UITheme.TEXT_DIM)
	# 选择框：圆角 6 深色半透 + 当前标签（或占位）+ [×] + ▾
	var box := _box_rect()
	draw_rect(box, UITheme.CHASSIS_FILL, true)
	draw_rect(box, UITheme.BORDER_STRONG, false, 1.0, true)
	var has_any := multiple and not values.is_empty()
	var has_selection := _has_clearable_selection()
	draw_string(_font, box.position + Vector2(10.0, box.size.y * 0.68), _box_label(), HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 34.0 - (CLEAR_WIDTH if has_selection else 0.0), font_size, UITheme.TEXT_MAIN if (has_any or (not multiple and value != "")) else UITheme.TEXT_FAINT)
	# clearable「×」（有可清除勾选时显示；caret 左侧留 3px 间隙）
	if show_clear and has_selection:
		var clear_center := _clear_rect().get_center()
		draw_string(_font, Vector2(clear_center.x - 4.0, clear_center.y + 4.5), "×", HORIZONTAL_ALIGNMENT_LEFT, 10.0, 13, UITheme.TEXT_DIM)
	# ▾ 箭头（caret 带右缘内收：折线右缘不越过选择框边）
	var cx := box.end.x - CARET_WIDTH * 0.5
	var cy := box.size.y * 0.5
	var dir := -1.0 if _panel_open else 1.0
	draw_polyline(PackedVector2Array([
		Vector2(cx - 4.0, cy - dir * 3.0),
		Vector2(cx, cy + dir * 3.0),
		Vector2(cx + 4.0, cy - dir * 3.0),
	]), UITheme.TEXT_DIM, 1.5, true)
	if not _panel_open:
		return
	# 弹出面板：深色半透 + 白描边；单选行高亮当前项 + 行尾选中点；多选勾选行行首琥珀对勾。
	# 面板与行矩形是视口坐标（_input 命中测试用），绘制在控件本地空间须减去控件原点——
	# 否则整层按「全局位置 + 全局矩形」二次偏移飞出屏幕（状态是开的、肉眼看不到）
	var local_offset := -get_global_rect().position
	var panel := _panel_rect()
	panel.position += local_offset
	draw_rect(panel, UITheme.POPOUT_FILL, true)
	draw_rect(panel, UITheme.BORDER_STRONG, false, 1.0, true)
	var tick_offset := 16.0 if (multiple and exclusive_first) else 0.0
	for row in options.size():
		var option_value := str(options[row][1])
		var active: bool = values.has(option_value) if multiple else option_value == value
		var rect := option_rect(row)
		rect.position += local_offset
		draw_rect(rect, UITheme.ROW_ACTIVE if active else UITheme.ROW_IDLE, true)
		draw_string(_font, Vector2(rect.position.x + 12.0 + tick_offset, rect.position.y + row_height * 0.68), str(options[row][0]), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 28.0 - tick_offset, font_size, UITheme.TEXT_MAIN if active else UITheme.TEXT_FAINT)
		if active:
			if multiple:
				# 多选：行首琥珀对勾
				var cy2 := rect.get_center().y
				draw_polyline(PackedVector2Array([
					Vector2(rect.position.x + 10.0, cy2 + 1.0),
					Vector2(rect.position.x + 13.0, cy2 + 4.0),
					Vector2(rect.position.x + 18.0, cy2 - 4.0),
				]), UITheme.ACCENT, 2.0, true)
			else:
				draw_circle(Vector2(rect.end.x - 14.0, rect.get_center().y), 3.0, UITheme.TEXT_MAIN, true, -1.0, true)
