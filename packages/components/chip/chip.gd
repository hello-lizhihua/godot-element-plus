extends Button
## 筛选按钮：未选中白 6% 底（悬停白 14%），选中琥珀 30% 底 + 1px 琥珀描边；
## 圆角 6、字号 13。按下即发出继承的 pressed 信号。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var active := false:
	set(v):
		active = v
		_apply_style()


func _init() -> void:
	add_theme_font_override("font", UITheme.system_font())
	_apply_style()


func set_active(v: bool) -> void:
	active = v


func is_active() -> bool:
	return active


func _apply_style() -> void:
	add_theme_color_override("font_color", UITheme.TEXT_MAIN)
	add_theme_color_override("font_hover_color", UITheme.TEXT_MAIN)
	add_theme_color_override("font_pressed_color", UITheme.TEXT_MAIN)
	add_theme_color_override("font_disabled_color", UITheme.TEXT_DIM)
	add_theme_font_size_override("font_size", UITheme.FONT_S)
	add_theme_stylebox_override("normal", UITheme.chip_style(UITheme.ACCENT_WASH if active else UITheme.ROW_IDLE, active))
	add_theme_stylebox_override("hover", UITheme.chip_style(UITheme.ACCENT_WASH if active else Color(1.0, 1.0, 1.0, 0.14), active))
	add_theme_stylebox_override("pressed", UITheme.chip_style(UITheme.ACCENT_WASH, true))
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
