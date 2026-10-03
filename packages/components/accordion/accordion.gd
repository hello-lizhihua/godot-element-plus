extends VBoxContainer
## 手风琴：分组标题行 + 分组内容容器，对标 Element Plus collapse
## 手风琴模式——accordion 为 true 时展开一组收起其余（开一收一），再点已展开的
## 标题收起（允许全部收起）；false 时各分组独立开合。标题行：淡底 + 标题 +
## 右侧计数 + 右端箭头（展开向下、收起向右）+ 激活左缘琥珀强调条。
## 分组内容为 VBox，使用方经 section_content 填充任意控件，收起时整体隐藏。

signal section_toggled(section_index: int, expanded: bool)

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var accordion := true
var title_height := 32.0
var pad_x := 14.0
var open_sections: Array = [0] # 展开的分组序号（accordion 模式下至多一个）
var active_sections: Array = [] # 激活分组：标题左缘琥珀强调条

var _sections: Array = [] # [{bar, content, title, count}]
var _font: SystemFont

const ACCENT_WIDTH := 3.0


func _init() -> void:
	_font = UITheme.system_font()
	add_theme_constant_override("separation", 0)


## 追加分组，返回序号；count 为标题右侧计数文案（空串不显示）
func add_section(title: String, count := "") -> int:
	var index := _sections.size()
	var bar := Control.new()
	bar.custom_minimum_size = Vector2(0, title_height)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.mouse_filter = Control.MOUSE_FILTER_PASS
	bar.draw.connect(_draw_bar.bind(bar, index))
	bar.gui_input.connect(_on_bar_input.bind(index))
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 0)
	add_child(bar)
	add_child(content)
	_sections.append({"bar": bar, "content": content, "title": title, "count": count})
	_apply_visibility()
	return index


## 清空全部分组（重置展开与激活状态）
func clear_sections() -> void:
	for record in _sections:
		record["bar"].queue_free()
		record["content"].queue_free()
	_sections.clear()
	open_sections = []
	active_sections = []


func section_content(index: int) -> VBoxContainer:
	return _sections[index]["content"]


func toggle_section(index: int) -> void:
	set_open(index, not is_open(index))


## 展开或收起分组；accordion 模式下展开即收起其余
func set_open(index: int, expanded: bool) -> void:
	if accordion:
		open_sections = [index] if expanded else []
	else:
		if expanded and not open_sections.has(index):
			open_sections.append(index)
		elif not expanded:
			open_sections.erase(index)
	_apply_visibility()


func is_open(index: int) -> bool:
	return open_sections.has(index)


## 更新分组计数文案（过滤态显示命中数）
func set_section_count(index: int, count_text: String) -> void:
	_sections[index]["count"] = count_text
	_sections[index]["bar"].queue_redraw()


func set_active_sections(sections: Array) -> void:
	active_sections = sections.duplicate()
	for record in _sections:
		record["bar"].queue_redraw()


func _apply_visibility() -> void:
	for i in _sections.size():
		_sections[i]["content"].visible = open_sections.has(i)
		_sections[i]["bar"].queue_redraw()


func _on_bar_input(event: InputEvent, index: int) -> void:
	var hit := false
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		hit = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		hit = touch.pressed and not touch.canceled
	if hit:
		toggle_section(index)
		section_toggled.emit(index, is_open(index))


func _draw_bar(bar: Control, index: int) -> void:
	bar.draw_rect(Rect2(Vector2.ZERO, bar.size), UITheme.ROW_IDLE)
	if active_sections.has(index):
		bar.draw_rect(Rect2(Vector2.ZERO, Vector2(ACCENT_WIDTH, bar.size.y)), UITheme.ACCENT)
	var record: Dictionary = _sections[index]
	# 计数右缘让开右端箭头带 20px（ARROW_ZONE），标题右缘再让开计数带，互不重叠
	var arrow_zone := 20.0
	bar.draw_string(_font, Vector2(pad_x, title_height * 0.7), str(record["title"]), HORIZONTAL_ALIGNMENT_LEFT, minf(120.0, bar.size.x - pad_x * 2.0 - arrow_zone - 60.0), 15, UITheme.TEXT_MAIN)
	if str(record["count"]) != "":
		bar.draw_string(_font, Vector2(bar.size.x - pad_x - arrow_zone - 60.0, title_height * 0.7), str(record["count"]), HORIZONTAL_ALIGNMENT_RIGHT, 60.0, 12, UITheme.TEXT_DIM)
	# 箭头：展开向下、收起向右
	var cx := bar.size.x - pad_x - 8.0
	var cy := title_height * 0.5
	var dir := 1.0 if open_sections.has(index) else -1.0
	bar.draw_polyline(PackedVector2Array([
		Vector2(cx - 4.0, cy - dir * 3.0),
		Vector2(cx, cy + dir * 3.0),
		Vector2(cx + 4.0, cy - dir * 3.0),
	]), UITheme.TEXT_DIM, 1.5, true)
