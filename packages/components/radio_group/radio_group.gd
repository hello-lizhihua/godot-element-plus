extends HFlowContainer
## 单选按钮组：流式排列的
## 单选按钮组，选中状态由组内维护——点击选择并发出 selected_changed(index)，
## 使用方经 set_selected / selected 读写当前项。

signal selected_changed(index: int)

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")
const ChipScript := preload("res://addons/godot-element-plus/chip/chip.gd")

var chip_gap := 6.0

var _selected := -1


func _init() -> void:
	add_theme_constant_override("h_separation", chip_gap)


## 追加选项，返回序号
func add_option(text: String) -> int:
	var chip: Button = ChipScript.new()
	chip.text = text
	var index := get_child_count()
	chip.pressed.connect(func(): _on_chip_pressed(index))
	add_child(chip)
	return index


func option_at(index: int) -> Button:
	return get_child(index) as Button


func count() -> int:
	return get_child_count()


## 程序化设置选中项（超范围钳制，不发事件）
func set_selected(index: int) -> void:
	_selected = clampi(index, -1, get_child_count() - 1)
	_refresh()


func selected() -> int:
	return _selected


func _on_chip_pressed(index: int) -> void:
	_selected = index
	_refresh()
	selected_changed.emit(index)


func _refresh() -> void:
	for i in get_child_count():
		(get_child(i) as Button).set_active(i == _selected)
