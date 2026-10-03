extends HFlowContainer
## 复选按钮组：流式排列的
## 多选按钮组，勾选状态由组内维护——点击切换并发出 option_toggled(value)，
## 使用方经 set_checked_values / checked_values 读写勾选集合。
## 与 chip 行的分工：chip 行不持有状态（语义由使用方实现），筛选场景优先本组件。

signal option_toggled(value: int)

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")
const ChipScript := preload("res://addons/godot-element-plus/chip/chip.gd")

var chip_gap := 6.0
var row_gap := 4.0

var _checked: Array = [] # 勾选中的 value 列表
var _values: Array = [] # 与子 chip 平行的 value


func _init() -> void:
	add_theme_constant_override("h_separation", chip_gap)
	add_theme_constant_override("v_separation", row_gap)


## 追加选项，返回 chip 供调用方挂 meta；value 为该选项的勾选标识（应唯一）
func add_option(text: String, value := -1) -> Button:
	var chip: Button = ChipScript.new()
	chip.text = text
	var index := get_child_count()
	_values.append(value)
	chip.pressed.connect(func(): _on_chip_pressed(index))
	add_child(chip)
	return chip


func chip_at(index: int) -> Button:
	return get_child(index) as Button


func count() -> int:
	return get_child_count()


## 按 value 批量设置勾选（未出现的选项取消勾选）
func set_checked_values(values: Array) -> void:
	_checked = values.duplicate()
	_refresh()


func checked_values() -> Array:
	return _checked.duplicate()


func _on_chip_pressed(index: int) -> void:
	var value: int = _values[index]
	if _checked.has(value):
		_checked.erase(value)
	else:
		_checked.append(value)
	_refresh()
	option_toggled.emit(value)


func _refresh() -> void:
	for i in get_child_count():
		(get_child(i) as Button).set_active(_checked.has(_values[i]))
