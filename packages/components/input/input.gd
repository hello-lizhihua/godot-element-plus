extends LineEdit
## 输入框：构造即应用主题——深色半透
## 底、白 20% 描边、聚焦琥珀描边、圆角 6、字号 14、文字 #f0ede6、占位文字弱化。
## text_changed 与 text_submitted（回车）等事件继承 LineEdit。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var font_size := 14


func _init() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = UITheme.CHASSIS_FILL
	style.set_corner_radius_all(UITheme.CORNER_S)
	style.border_color = UITheme.BORDER
	style.set_border_width_all(1.0)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	var focused := style.duplicate() as StyleBoxFlat
	focused.border_color = UITheme.ACCENT
	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("focus", focused)
	add_theme_color_override("font_color", UITheme.TEXT_MAIN)
	add_theme_color_override("font_placeholder_color", UITheme.TEXT_FAINT)
	add_theme_color_override("font_selected_color", Color(0.16, 0.15, 0.10))
	add_theme_color_override("selection_color", UITheme.ACCENT_WASH)
	add_theme_color_override("caret_color", UITheme.TEXT_MAIN)
	add_theme_font_override("font", UITheme.system_font())
	add_theme_font_size_override("font_size", font_size)
