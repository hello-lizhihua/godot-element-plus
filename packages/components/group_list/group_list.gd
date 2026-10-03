extends ScrollContainer
## 分组列表：以手风琴承载的分组列表——分组标题行即手风琴标题
## （标题 + 计数 + 右端箭头 + 激活左缘琥珀强调条），成员行为手风琴内容。
## 手风琴模式（accordion = true）下展开一组收起其余，默认展开 open_section 指定
## 分组（-1 全部收起）；点击标题开一收一；选中成员自动展开所在分组并滚动到可见。
## 组内排序 + 悬停高亮 + 点击去重照旧。行内容经子类钩子定制——子类覆盖
## _fill_item_row 填充行内布局（详情 Label 以 meta "details" 挂到行上，选中展开
## 时由列表统一显隐），覆盖 _format_count 定制标题行计数文案。

signal section_toggled(section_index: int, expanded: bool)
signal item_clicked(item: Dictionary, index: int)
signal rows_changed(rows: Array)

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")
const AccordionScript := preload("res://addons/godot-element-plus/accordion/accordion.gd")

var accordion := true # true 手风琴（开一收一）；false 各分组独立开合
var open_section := 0 # 初始展开的分组序号（set_data 数组序，-1 全部收起）
var sort_keys: Array = [] # [[标签, 键], ...]（排序条由使用方拼装，列表只消费键）
var sort_key := ""
var sort_comparator := Callable() # (key, a, b) -> bool：a 是否排在 b 前；缺省按键数值降序
var filter_callable := Callable() # (item, text) -> bool：成员是否命中筛选文本
var title_height := 32.0
var item_height := 38.0
var detail_extra := 48.0 # 选中行展开详情区高度
var pad_x := 14.0
var selected_index := -1 # 成员载荷索引，-1 = 无
var active_groups: Array = [] # 激活分组（set_data 数组序，标题强调条）

var _groups: Array = []
var _accordion: VBoxContainer # ElementAccordion
var _filter_text := "" # 当前筛选文本（空 = 未筛选）
var _list_rows: Array = [] # [{kind:"title", group_index, name, count} | {kind:"item", index, payload}]
var _row_controls: Array = [] # 与成员行平行的行 Control（标题行不入此表）
var _section_of_group: Dictionary = {} # set_data 数组序 → 手风琴分组序号（空分组跳过后重排）
var _section_totals: Array = [] # 各分组原始成员数（过滤还原计数用）
var _group_of_section: Dictionary = {} # 手风琴分组序号 → set_data 数组序
var _hover := -1 # 悬停成员（载荷索引）
var _press_frame := -1 # 防双发：本帧已发出的成员行
var _press_index := -1
var _font: SystemFont

const ACCENT_WIDTH := 3.0


func _init() -> void:
	_font = UITheme.system_font()
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER


func _ready() -> void:
	_accordion = AccordionScript.new()
	_accordion.accordion = accordion
	_accordion.title_height = title_height
	_accordion.pad_x = pad_x
	# 横向滚动已禁用：手风琴撑满滚动容器宽度（否则内容收缩为零宽，行不可点）
	_accordion.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_accordion)
	_accordion.section_toggled.connect(_on_section_toggled)


func _on_section_toggled(section_index: int, expanded: bool) -> void:
	section_toggled.emit(int(_group_of_section.get(section_index, section_index)), expanded)


## 传入分组数据：每项 {name, title, items}；name 分组键、title 标题显示名、
## items 成员载荷字典数组；分组顺序即数组顺序，空分组跳过
func set_data(groups: Array) -> void:
	_groups = groups
	_rebuild()


func set_sort(key: String) -> void:
	if sort_key == key:
		return
	sort_key = key
	_rebuild()


## 以当前键与比较器重排（排序方向翻转等键不变的场合）
func resort() -> void:
	_rebuild()


func set_selected(index: int) -> void:
	selected_index = index
	# 选中成员所在分组自动展开（手风琴模式下开一收一）
	if index >= 0:
		var section := _section_of_item(index)
		if section >= 0 and not _accordion.is_open(section):
			_accordion.set_open(section, true)
	_refresh_rows()


func set_active_groups(indexes: Array) -> void:
	active_groups = indexes.duplicate()
	var sections: Array = []
	for group_index in active_groups:
		if _section_of_group.has(group_index):
			sections.append(_section_of_group[group_index])
	_accordion.set_active_sections(sections)


## 文本筛选：命中的成员行保留、所在分组强制展开，未命中分组整体隐藏；
## 空文本还原手风琴状态。匹配逻辑经 filter_callable（item, text）注入
func set_filter(text: String) -> void:
	_filter_text = text.strip_edges()
	_apply_filter()


func _apply_filter() -> void:
	var filtering := _filter_text != "" and filter_callable.is_valid()
	for record in _list_rows:
		if record["kind"] != "item":
			continue
		var row: Control = record["row"]
		if filtering:
			row.visible = filter_callable.call(record["payload"], _filter_text)
		else:
			row.visible = true
	var section := 0
	for record in _list_rows:
		if record["kind"] != "title":
			continue
		var bar: Control = _accordion._sections[section]["bar"]
		var content: VBoxContainer = _accordion._sections[section]["content"]
		if filtering:
			# 分组内有命中成员才显示，命中分组强制展开
			var has_match := false
			for child in content.get_children():
				if child.visible:
					has_match = true
					break
			bar.visible = has_match
			content.visible = has_match
			if has_match and not _accordion.open_sections.has(section):
				_accordion.open_sections.append(section)
		else:
			bar.visible = true
			content.visible = _accordion.is_open(section)
		section += 1
	if not filtering:
		_accordion.open_sections = _accordion.open_sections.filter(func(i): return i < section)
		_accordion._apply_visibility()


func row_count() -> int:
	return _list_rows.size()


## 显示位置 → 成员载荷索引（非成员行返回 -1）
func item_index_at(pos: int) -> int:
	if pos < 0 or pos >= _list_rows.size():
		return -1
	return _list_rows[pos]["index"] if _list_rows[pos]["kind"] == "item" else -1


## 滚动使成员行可见（展开重排在下一帧，等一帧再滚动；列表整体隐藏时跳过）
func scroll_to_item(index: int) -> void:
	if index < 0 or not is_inside_tree() or not is_visible_in_tree():
		return
	await get_tree().process_frame
	if not is_inside_tree():
		return
	var row := _row_of_item(index)
	if row == null:
		return
	var view_height: float = size.y
	if view_height <= 0.0:
		return
	var row_top: float = row.get_global_position().y - get_global_position().y
	if row_top < 0.0:
		scroll_vertical += int(row_top)
	elif row_top + row.size.y > view_height:
		scroll_vertical += int(row_top + row.size.y - view_height)


func _row_of_item(index: int) -> Control:
	for record in _list_rows:
		if record["kind"] == "item" and int(record["index"]) == index:
			return record.get("row")
	return null


func _section_of_item(index: int) -> int:
	for record in _list_rows:
		if record["kind"] == "item" and int(record["index"]) == index:
			return int(record.get("section", -1))
	return -1


func _sorted_items(group: Dictionary) -> Array:
	var items: Array = (group.get("items", []) as Array).duplicate()
	if sort_comparator.is_valid():
		items.sort_custom(func(a, b): return sort_comparator.call(sort_key, a, b))
	elif sort_key != "":
		items.sort_custom(func(a, b): return float(a.get(sort_key, 0)) > float(b.get(sort_key, 0)))
	return items


func _rebuild() -> void:
	_accordion.clear_sections()
	_row_controls.clear()
	_list_rows.clear()
	_section_of_group.clear()
	_group_of_section.clear()
	_hover = -1
	# 初始展开集合：accordion 组件默认展开序 0；按 open_section 属性对齐
	var initial_open := open_section
	var section := 0
	for g in _groups.size():
		var group: Dictionary = _groups[g]
		var members := _sorted_items(group)
		if members.is_empty():
			continue
		var accordion_index: int = _accordion.add_section(str(group.get("title", group.get("name", ""))), _format_count(members.size()))
		if section >= _section_totals.size():
			_section_totals.append(members.size())
		else:
			_section_totals[section] = members.size()
		_section_of_group[g] = accordion_index
		_group_of_section[accordion_index] = g
		var content: VBoxContainer = _accordion.section_content(accordion_index)
		_list_rows.append({"kind": "title", "group_index": accordion_index, "name": str(group.get("title", group.get("name", ""))), "count": members.size()})
		for item in members:
			var record := {"kind": "item", "index": int(item.get("index", -1)), "payload": item, "section": accordion_index}
			var row := _make_item_row(record)
			_row_controls.append(row)
			content.add_child(row)
			_list_rows.append(record)
		section += 1
	# 初始展开：-1 全部收起，否则展开指定分组（缺省 0 = 第一组）
	if initial_open < 0:
		_accordion.open_sections = []
	elif _section_of_group.has(initial_open):
		_accordion.set_open(_section_of_group[initial_open], true)
	_accordion.set_active_sections(_active_sections())
	_refresh_rows()
	rows_changed.emit(_list_rows)


func _active_sections() -> Array:
	var sections: Array = []
	for group_index in active_groups:
		if _section_of_group.has(group_index):
			sections.append(_section_of_group[group_index])
	return sections


func _make_item_row(record: Dictionary) -> Control:
	var row := Control.new()
	row.custom_minimum_size = Vector2(0, item_height)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.draw.connect(_draw_item_row.bind(row, record))
	row.gui_input.connect(_on_item_input.bind(record))
	row.mouse_entered.connect(_set_hover.bind(int(record["index"]), true))
	row.mouse_exited.connect(_set_hover.bind(int(record["index"]), false))
	_fill_item_row(row, record["payload"])
	record["row"] = row
	return row


## 子类钩子：填充成员行内容（Label 等）
func _fill_item_row(_row: Control, _item: Dictionary) -> void:
	pass


## 子类钩子：标题行计数文案
func _format_count(count: int) -> String:
	return str(count)


func _on_item_input(event: InputEvent, record: Dictionary) -> void:
	var hit := false
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		hit = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		hit = touch.pressed and not touch.canceled
	if hit:
		_emit_press(int(record["index"]), record["payload"])


func _emit_press(index: int, payload: Dictionary) -> void:
	if _press_frame == Engine.get_process_frames() and _press_index == index:
		return
	_press_frame = Engine.get_process_frames()
	_press_index = index
	item_clicked.emit(payload, index)


func _set_hover(index: int, entered: bool) -> void:
	_hover = index if entered else -1
	_refresh_rows()


func _refresh_rows() -> void:
	for record in _list_rows:
		if record["kind"] != "item":
			continue
		var index: int = record["index"]
		var row: Control = record["row"]
		var expanded := index == selected_index
		row.custom_minimum_size.y = item_height + (detail_extra if expanded else 0.0)
		if row.has_meta("details"):
			for label in row.get_meta("details"):
				label.visible = expanded
		row.queue_redraw()


func _draw_item_row(row: Control, record: Dictionary) -> void:
	# 选中：白 22% 底 + 左缘 3px 琥珀竖条；悬停（非选中）：白 10% 底
	var index: int = record["index"]
	if index == selected_index:
		row.draw_rect(Rect2(Vector2.ZERO, row.size), UITheme.ROW_ACTIVE)
		row.draw_rect(Rect2(Vector2.ZERO, Vector2(ACCENT_WIDTH, row.size.y)), UITheme.ACCENT)
	elif index == _hover:
		row.draw_rect(Rect2(Vector2.ZERO, row.size), UITheme.ROW_HOVER)
