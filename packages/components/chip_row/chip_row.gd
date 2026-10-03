extends HFlowContainer
## chip 行：流式排列、自动换行。行不持有选中状态——点击上报索引，使用方
## 经 set_active_indexes 回推高亮；单选与多选语义由使用方实现（单选：收到
## chip_clicked 后回推单元素列表；多选：回推切换后的全量列表）。

signal chip_clicked(index: int)

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var chip_gap := 6.0
var row_gap := 4.0


func _init() -> void:
	add_theme_constant_override("h_separation", chip_gap)
	add_theme_constant_override("v_separation", row_gap)


## 追加 chip，返回实例供调用方挂 meta 或覆盖样式
func add_chip(text: String) -> Button:
	var chip := preload("res://addons/godot-element-plus/chip/chip.gd").new()
	chip.text = text
	var index := get_child_count()
	chip.pressed.connect(func(): chip_clicked.emit(index))
	add_child(chip)
	return chip


func chip_at(index: int) -> Button:
	return get_child(index) as Button


func count() -> int:
	return get_child_count()


## 按行索引列表批量高亮（多选）
func set_active_indexes(indexes: Array) -> void:
	for i in get_child_count():
		(get_child(i) as Button).set_active(indexes.has(i))
