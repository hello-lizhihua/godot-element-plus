extends SceneTree
## headless godot-element-plus 组件自检：全组件 API 级回归（库自身的测试，独立于场景）。
## 覆盖：令牌、滑块、chip/行/复选组/单选组、手风琴、分组列表（排序/筛选）、
## 图标按钮族、设置面板、停靠面板、按钮、输入框、开关、标签、选择器（单/多选）、
## 进度条、消息、对话框、卡片、分割线、徽章、页签、警示条、悬停提示、分页。
## 运行：godot --headless --path . -s res://tests/components_test.gd

const U := "res://addons/godot-element-plus/"

var _total := 0
var _fail := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1600, 900)
	preload("res://tools/silent_window.gd").apply(root)

	# ── 设计令牌 ──
	var theme: GDScript = load(U + "theme/theme.gd")
	var font: SystemFont = theme.system_font()
	_check(font != null and font.font_names.size() == 4, "T1 字体栈构建", "")
	var style: StyleBoxFlat = theme.chip_style(Color.WHITE, true)
	_check(style.border_width_left == 1.0 and style.corner_radius_top_left == 6.0, "T2 chip 样式描边与圆角", "")

	# ── 滑块 ──
	var slider: Control = load(U + "slider/slider.gd").new()
	root.add_child(slider)
	await process_frame
	slider.set_value(99)
	_check(slider.get_value() == 10, "S1 赋值上钳制", "v=%d" % slider.get_value())
	var fired := []
	slider.value_changed.connect(func(level): fired.append(level))
	slider._emit_value(3)
	_check(fired == [3] and slider.get_value() == 3, "S2 用户路径发事件", "fired=%s" % str(fired))
	slider.set_value(3)
	_check(fired.size() == 1, "S3 程序化赋值不发事件", "")
	slider.top_y = 40.0
	slider.right_align = 200.0
	await process_frame
	var track: Rect2 = slider._track_rect()
	_check(absf(track.position.y - 40.0) < 0.5 and absf(track.end.x - (1600.0 - 200.0 - 38.0)) < 0.5, "S4 顶部右对齐定位", "track=%s" % track)
	slider.queue_free()

	# ── chip / 行 / 复选组 / 单选组 ──
	var chip: Button = load(U + "chip/chip.gd").new()
	chip.set_active(true)
	_check(chip.is_active() and chip.active, "C1 chip 选中态", "")
	chip.queue_free()
	var row: Container = load(U + "chip_row/chip_row.gd").new()
	root.add_child(row)
	var clicks := []
	row.chip_clicked.connect(func(index): clicks.append(index))
	row.add_chip("甲")
	row.add_chip("乙")
	row.chip_at(1).pressed.emit()
	_check(row.count() == 2 and clicks == [1], "C2 chip 行点击上报索引", "clicks=%s" % str(clicks))
	row.set_active_indexes([0])
	_check(row.chip_at(0).is_active() and not row.chip_at(1).is_active(), "C3 批量高亮", "")
	row.queue_free()
	var checkboxes: Container = load(U + "checkbox_group/checkbox_group.gd").new()
	root.add_child(checkboxes)
	var toggles := []
	checkboxes.option_toggled.connect(func(value): toggles.append(value))
	checkboxes.add_option("选项 A", 6)
	checkboxes.add_option("选项 B", 7)
	checkboxes.chip_at(0).pressed.emit()
	checkboxes.chip_at(1).pressed.emit()
	checkboxes.chip_at(0).pressed.emit()
	_check(toggles == [6, 7, 6] and checkboxes.checked_values() == [7], "C4 复选组勾选与取消", "values=%s" % str(checkboxes.checked_values()))
	checkboxes.set_checked_values([6, 7])
	_check(checkboxes.chip_at(0).is_active() and checkboxes.chip_at(1).is_active(), "C5 批量勾选回推", "")
	checkboxes.queue_free()
	var radios: Container = load(U + "radio_group/radio_group.gd").new()
	root.add_child(radios)
	var selects := []
	radios.selected_changed.connect(func(index): selects.append(index))
	radios.add_option("面积")
	radios.add_option("人口")
	radios.option_at(1).pressed.emit()
	_check(selects == [1] and radios.selected() == 1, "C6 单选组选择", "sel=%d" % radios.selected())
	radios.option_at(0).pressed.emit()
	_check(radios.option_at(1).is_active() == false and radios.option_at(0).is_active(), "C7 单选互斥", "")
	radios.queue_free()

	# ── 手风琴 ──
	var accordion: Container = load(U + "accordion/accordion.gd").new()
	root.add_child(accordion)
	var toggled_sections := []
	accordion.section_toggled.connect(func(index, expanded): toggled_sections.append([index, expanded]))
	accordion.add_section("亚洲", "48 国")
	accordion.add_section("欧洲")
	_check(accordion.is_open(0) and not accordion.is_open(1), "A1 默认展开第一组", "")
	accordion.toggle_section(1)
	_check(accordion.is_open(1) and not accordion.is_open(0), "A2 手风琴开一收一", "")
	accordion._on_bar_input(_press_event(Vector2(5, 5)), 0)
	_check(accordion.is_open(0) and not accordion.is_open(1) and toggled_sections == [[0, true]], "A2b 标题点击发事件", "toggled=%s" % str(toggled_sections))
	accordion.accordion = false
	accordion.set_open(1, true)
	accordion.set_open(0, true)
	_check(accordion.is_open(0) and accordion.is_open(1), "A3 独立开合并存", "")
	_check(accordion.section_content(0) is VBoxContainer, "A4 内容容器", "")
	accordion.queue_free()

	# ── 分组列表（排序 + 筛选）──
	var group_list = load(U + "group_list/group_list.gd").new()
	root.add_child(group_list)
	await process_frame
	var data: Array = [
		{"name": "asia", "title": "亚洲", "items": [
			{"index": 0, "area": 960.0, "pop": 14},
			{"index": 1, "area": 328.0, "pop": 1},
		]},
		{"name": "europe", "title": "欧洲", "items": [
			{"index": 2, "area": 35.0, "pop": 0},
		]},
		{"name": "empty", "title": "空洲", "items": []},
	]
	var rows_changed_count := []
	group_list.rows_changed.connect(func(rows): rows_changed_count.append(rows.size()))
	group_list.set_data(data)
	await process_frame
	_check(group_list.row_count() == 5, "G1 行数含标题、空分组跳过", "n=%d" % group_list.row_count())
	_check(group_list._accordion.is_open(0) and group_list._accordion._sections.size() == 2, "G2 默认展开首组、空分组不建", "")
	group_list.item_clicked.connect(func(_item, index): group_list.set_selected(index))
	var item_record: Dictionary = group_list._list_rows[1]
	group_list._emit_press(int(item_record["index"]), item_record["payload"])
	await process_frame
	_check(group_list.selected_index == int(item_record["index"]), "G3 行点击选中回环", "sel=%d" % group_list.selected_index)
	group_list.sort_comparator = func(key, a, b): return float(a["area"]) < float(b["area"])  # 面积升序
	group_list.set_sort("area")
	await process_frame
	_check(int(group_list._list_rows[1]["index"]) == 1, "G4 组内排序生效", "first=%s" % str(group_list._list_rows[1]["index"]))
	group_list.filter_callable = func(item, text): return str(item["area"]).begins_with(text)
	group_list.set_filter("9")
	await process_frame
	_check(not group_list._list_rows[1]["row"].visible and group_list._list_rows[2]["row"].visible, "G5 筛选命中显隐", "")
	group_list.set_filter("")
	await process_frame
	_check(group_list._list_rows[1]["row"].visible, "G6 清空筛选还原", "")
	group_list.queue_free()

	# ── 图标按钮族 ──
	var icon_button: Control = load(U + "icon_button/icon_button.gd").new()
	root.add_child(icon_button)
	await process_frame
	_check(icon_button.icon_center() == Vector2(1600.0 - 40.0, 40.0), "I1 右上角默认点位", "c=%s" % icon_button.icon_center())
	var back_button: Control = load(U + "back_button/back_button.gd").new()
	root.add_child(back_button)
	await process_frame
	_check(back_button.icon_center() == Vector2(40.0, 40.0) and back_button.target_scene.contains("scene_picker"), "I2 返回按钮左上角", "c=%s" % back_button.icon_center())
	var window_button: Control = load(U + "window_button/window_button.gd").new()
	root.add_child(window_button)
	await process_frame
	_check(not window_button.is_fullscreen(), "I3 最大化按钮全屏态判定", "")
	icon_button.queue_free()
	back_button.queue_free()
	window_button.queue_free()

	# ── 设置面板 / 停靠面板 ──
	var settings: Control = load(U + "settings_panel/settings_panel.gd").new()
	root.add_child(settings)
	settings.options = [["白天", "day"], ["夜晚", "night"]]
	await process_frame
	settings.open_panel()
	_check(settings.is_open(), "P1 面板展开", "")
	var picked := []
	settings.option_selected.connect(func(value): picked.append(value))
	settings._handle_press(settings.row_center(1))
	_check(picked == ["night"] and settings.value == "night", "P2 行点击选中上报", "picked=%s" % str(picked))
	settings.close_panel()
	_check(not settings.is_open(), "P3 面板收起", "")
	settings.queue_free()
	# P3b 从属开关随面板开合收敛（单一状态入口）：面板外点击/再点图标收起均不泄漏开关
	var settings_sw: Control = load(U + "settings_panel/settings_panel.gd").new()
	root.add_child(settings_sw)
	settings_sw.options = [["白天", "day"], ["夜晚", "night"]]
	settings_sw.switch_label = "全屏"
	await process_frame
	settings_sw.open_panel()
	_check(settings_sw._switch != null and settings_sw._switch.visible, "P3b 面板开时开关就位", "")
	settings_sw._handle_press(Vector2(800.0, 800.0))
	_check(not settings_sw.is_open() and not settings_sw._switch.visible, "P3b 点面板外收起且开关隐藏", "")
	settings_sw.open_panel()
	settings_sw._handle_press(settings_sw.icon_center())
	_check(not settings_sw.is_open() and not settings_sw._switch.visible, "P3b 再点图标收起且开关隐藏", "")
	settings_sw.queue_free()
	var dock: Control = load(U + "dock_panel/dock_panel.gd").new()
	root.add_child(dock)
	await process_frame
	dock.set_header("国家", 242)
	var collapse_events := []
	dock.collapse_toggled.connect(func(expanded): collapse_events.append(expanded))
	dock.set_collapsed(true)
	for i in 240:
		if not dock._panel_margins.visible:
			break
		await process_frame
	_check(dock.collapsed and dock.visible and not dock._panel_margins.visible and collapse_events == [false], "P4 收起正文隐藏 + 控制件承载把手 + 事件", "ev=%s visible=%s" % [str(collapse_events), str(dock.visible)])
	var handle: Rect2 = dock._handle_rect()
	_check(handle.position.x > 0.0 and handle.size == Vector2(32.0, 32.0), "P4b 右缘圆形把手在位", "rect=%s" % str(handle))
	dock.set_collapsed(false)
	await process_frame
	_check(dock.is_expanded() and dock.visible and dock.content() is VBoxContainer, "P5 展开还原 + 内容容器", "")
	_check(dock.content().get_global_rect().position.y >= dock.position.y + dock.header_height - 0.5, "P6 内容顶距让开头部带（标题/页签不重叠）", "y=%.0f limit=%.0f" % [dock.content().get_global_rect().position.y, dock.position.y + dock.header_height])
	dock.queue_free()

	# ── 按钮 / 输入框 / 开关 / 标签 ──
	var button: Button = load(U + "button/button.gd").new()
	button.set_kind("primary")
	_check(button.get_kind() == "primary", "B1 按钮样式切换", "")
	button.queue_free()
	var input: Control = load(U + "input/input.gd").new()
	_check(input.get_theme_stylebox("normal") != null and input.get_theme_stylebox("focus") != null, "B2 输入框主题样式", "")
	input.queue_free()
	var switch: Control = load(U + "switch/switch.gd").new()
	root.add_child(switch)
	await process_frame
	var switch_events := []
	switch.toggled.connect(func(checked): switch_events.append(checked))
	switch._gui_input(_press_event(Vector2(10, 10)))
	_check(switch.is_checked() and switch_events == [true], "B3 开关点击切换发事件", "ev=%s" % str(switch_events))
	switch.set_checked(false)
	_check(not switch.is_checked() and switch_events.size() == 1, "B4 程序化赋值不发事件", "")
	switch.queue_free()
	var tag: Label = load(U + "tag/tag.gd").new()
	tag.set_kind("accent")
	_check(tag.get_kind() == "accent", "B5 标签配色切换", "")
	tag.queue_free()

	# ── 选择器（单选 + 多选）──
	var select: Control = load(U + "select/select.gd").new()
	root.add_child(select)
	select.options = [["模拟地图", "stylized"], ["卫星影像", "satellite"]]
	await process_frame
	var select_values := []
	select.option_selected.connect(func(value): select_values.append(value))
	select.open_panel()
	select._pick_row(1)
	_check(select_values == ["satellite"] and select.value == "satellite" and not select.is_open(), "SE1 单选选中并收起", "v=%s" % select.value)
	select.multiple = true
	select.set_values(["stylized"])
	select.open_panel()
	select._pick_row(1)
	_check(select.get_values() == ["stylized", "satellite"] and select.is_open(), "SE2 多选切换且保持展开", "values=%s" % str(select.get_values()))
	select._pick_row(1)
	_check(select.get_values() == ["stylized"], "SE3 多选再点取消", "")
	_check(select.count() == 2, "SE4 选项计数", "")
	select.width = 264.0
	_check(select.custom_minimum_size.x == 264.0, "SE5 width 回写最小尺寸（容器按实宽布局）", "min=%s" % str(select.custom_minimum_size))
	select.exclusive_first = true
	select.show_clear = true
	select.options = [["全部", "all"], ["亚洲", "asia"], ["欧洲", "europe"]]
	select.set_values(["all"])
	_check(not select._has_clearable_selection(), "SE6 仅勾「全部」不显示清除钮", "v=%s" % str(select.get_values()))
	select.set_values(["asia"])
	_check(select._has_clearable_selection(), "SE6 勾选项显示清除钮", "")
	_check(select._clear_rect().end.x <= select._box_rect().end.x - 11.0, "SE7 × 与 ▾ 折线带分离", "clear_end=%.0f caret_left=%.0f" % [select._clear_rect().end.x, select._box_rect().end.x - 11.0])
	select.queue_free()

	# ── 进度条 / 消息 / 对话框 ──
	var progress: Control = load(U + "progress/progress.gd").new()
	progress.set_value(150.0)
	_check(progress.get_value() == 100.0, "PR1 进度上钳制", "v=%.0f" % progress.get_value())
	progress.queue_free()
	var dialog: Control = load(U + "dialog/dialog.gd").new()
	root.add_child(dialog)
	var dialog_events := []
	dialog.closed.connect(func(): dialog_events.append("closed"))
	dialog.open_dialog()
	_check(dialog.is_open() and dialog.visible, "D1 对话框展开", "")
	dialog.close_dialog()
	_check(not dialog.is_open() and dialog_events == ["closed"], "D2 对话框关闭发事件", "")
	dialog.queue_free()

	# ── 卡片 / 分割线 / 徽章 / 页签 ──
	var card: Control = load(U + "card/card.gd").new()
	root.add_child(card)
	await process_frame
	card.set_title("标题")
	_check(card.content() is VBoxContainer, "CD1 卡片内容容器", "")
	card.queue_free()
	var badge: Control = load(U + "badge/badge.gd").new()
	badge.set_count(5)
	_check(badge.count == 5, "BD1 徽章计数", "")
	badge.set_show(false)
	_check(not badge.show, "BD2 徽章显隐", "")
	badge.queue_free()
	var tabs: Control = load(U + "tabs/tabs.gd").new()
	root.add_child(tabs)
	var tab_events := []
	tabs.tab_changed.connect(func(index): tab_events.append(index))
	var tab0: int = tabs.add_tab("甲")
	tabs.add_tab("乙")
	tabs.set_active(1)
	_check(tabs.active() == 1 and tabs.tab_content(tab0) is VBoxContainer, "TB1 页签切换与内容", "active=%d" % tabs.active())
	tabs.tab_content(0).add_child(Label.new())
	tabs._gui_input(_press_event(Vector2(tabs._tab_rects[0].get_center().x, 10.0)))
	_check(tab_events == [0] and tabs.active() == 0, "TB2 页签点击发事件", "ev=%s" % str(tab_events))
	tabs.queue_free()

	# ── 警示条 / 悬停提示 / 分页 ──
	var alert: Control = load(U + "alert/alert.gd").new()
	root.add_child(alert)
	alert.set_text("提示文字")
	alert.closable = true
	await process_frame
	var alert_closed := []
	alert.closed.connect(func(): alert_closed.append(true))
	alert._close.pressed.emit()
	_check(not alert.visible and alert_closed == [true], "AL1 关闭钮隐藏并发事件", "")
	alert.set_kind("danger")
	_check(alert.kind == "danger", "AL2 配色切换", "")
	alert.queue_free()
	var tooltip: Control = load(U + "tooltip/tooltip.gd").new()
	root.add_child(tooltip)
	await process_frame
	var host := Button.new()
	root.add_child(host)
	tooltip.attach_to(host, "这是提示")
	host.mouse_entered.emit()
	_check(tooltip.visible and tooltip.text == "这是提示", "TP1 悬停显示气泡", "")
	host.mouse_exited.emit()
	_check(not tooltip.visible, "TP2 移出隐藏", "")
	tooltip.queue_free()
	host.queue_free()
	var pagination: Container = load(U + "pagination/pagination.gd").new()
	root.add_child(pagination)
	var pages := []
	pagination.page_changed.connect(func(page): pages.append(page))
	pagination.set_total(30)
	pagination._goto(5)
	_check(pages == [5] and pagination.current_page() == 5, "PG1 跳页发事件", "pages=%s" % str(pages))
	pagination.set_current(99)
	_check(pagination.current_page() == 30, "PG2 超范围钳制到末页", "cur=%d" % pagination.current_page())
	pagination.set_current(1)
	var pills: Array = pagination._page_pills()
	_check(pills[0] == 1 and pills[-1] == 30 and pills.has(-1) and pills.size() <= 9, "PG3 长列表首尾省略", "pills=%s" % str(pills))
	pagination.queue_free()

	print("—— godot-element-plus 自检：%d 项，%d FAIL ——" % [_total, _fail])
	print("RESULT PASS=", _total - _fail, " FAIL=", _fail)
	quit(1 if _fail > 0 else 0)


func _press_event(pos: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = pos
	return event


func _check(passed: bool, label: String, detail := "") -> void:
	_total += 1
	if not passed:
		_fail += 1
	print(("PASS " if passed else "FAIL ") + label + ("  " + detail if detail != "" else ""))
