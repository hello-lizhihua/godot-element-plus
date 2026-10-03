extends Control
## 页签：顶部页签条（激活项米白字
## + 底部 2px 琥珀下划线、未激活弱化色）+ 下方内容区（仅当前页签可见）。
## 使用方经 add_tab 建页签、tab_content 填充内容。

signal tab_changed(index: int)

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var active_index := 0

var _titles: Array = []
var _contents: Array = []
var _tab_rects: Array = []
var _font: SystemFont

const BAR_HEIGHT := 32.0
const TAB_PAD := 14.0
const UNDERLINE := 2.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_font = UITheme.system_font()


func _ready() -> void:
	queue_redraw()


## 追加页签，返回序号
func add_tab(title: String) -> int:
	var index := _titles.size()
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", UITheme.GAP_XS)
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.offset_top = BAR_HEIGHT
	content.visible = index == active_index
	add_child(content)
	_titles.append(title)
	_contents.append(content)
	_layout_tabs()
	return index


func set_active(index: int) -> void:
	active_index = clampi(index, 0, _titles.size() - 1)
	_apply_active()


func active() -> int:
	return active_index


## 页签内容容器
func tab_content(index: int) -> VBoxContainer:
	return _contents[index]


func count() -> int:
	return _titles.size()


func _gui_input(event: InputEvent) -> void:
	var pressed := false
	var point := Vector2.ZERO
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		pressed = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
		point = mouse.position
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		pressed = touch.pressed and not touch.canceled
		point = touch.position
	if pressed and point.y <= BAR_HEIGHT:
		for i in _tab_rects.size():
			if (_tab_rects[i] as Rect2).has_point(point):
				if active_index != i:
					active_index = i
					_apply_active()
					tab_changed.emit(i)
				accept_event()
				return


func _apply_active() -> void:
	for i in _contents.size():
		_contents[i].visible = i == active_index
	queue_redraw()


func _layout_tabs() -> void:
	_tab_rects.clear()
	var x := 0.0
	for title in _titles:
		var text_width: float = _font.get_string_size(str(title), HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		var rect := Rect2(Vector2(x, 0.0), Vector2(text_width + TAB_PAD * 2.0, BAR_HEIGHT))
		_tab_rects.append(rect)
		x += rect.size.x


func _draw() -> void:
	if _tab_rects.size() != _titles.size():
		_layout_tabs()
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 1.0)), UITheme.BORDER_SOFT, true)
	for i in _titles.size():
		var rect: Rect2 = _tab_rects[i]
		var on := i == active_index
		draw_string(_font, rect.position + Vector2(TAB_PAD, BAR_HEIGHT * 0.62), str(_titles[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, UITheme.TEXT_MAIN if on else UITheme.TEXT_FAINT)
		if on:
			draw_rect(Rect2(rect.position + Vector2(TAB_PAD, BAR_HEIGHT - UNDERLINE), Vector2(rect.size.x - TAB_PAD * 2.0, UNDERLINE)), UITheme.ACCENT, true)
