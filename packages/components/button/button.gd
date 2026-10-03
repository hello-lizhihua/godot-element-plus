extends Button
## 按钮：圆角 6 深色半透按钮，
## default 深色半透底盘 + 白 32% 描边、primary 琥珀底 + 深色文字、ghost 白 6% 底；
## 悬停提亮、按下压暗。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var kind := "default" # default / primary / ghost
var font_size := 14


func _init() -> void:
	add_theme_font_override("font", UITheme.system_font())
	_apply_style()


func set_kind(v: String) -> void:
	kind = v
	_apply_style()


func get_kind() -> String:
	return kind


func _apply_style() -> void:
	add_theme_font_size_override("font_size", font_size)
	var style := func(bg: Color, border: Color, border_width: float) -> StyleBoxFlat:
		var box := StyleBoxFlat.new()
		box.bg_color = bg
		box.set_corner_radius_all(UITheme.CORNER_S)
		box.content_margin_left = 12.0
		box.content_margin_right = 12.0
		box.content_margin_top = 6.0
		box.content_margin_bottom = 6.0
		if border_width > 0.0:
			box.border_color = border
			box.set_border_width_all(border_width)
		return box
	var primary := kind == "primary"
	var text_color := Color(0.16, 0.15, 0.10) if primary else UITheme.TEXT_MAIN
	add_theme_color_override("font_color", text_color)
	add_theme_color_override("font_hover_color", text_color)
	add_theme_color_override("font_pressed_color", text_color)
	add_theme_color_override("font_focus_color", text_color)
	add_theme_stylebox_override("normal", style.call(
		UITheme.ACCENT if primary else (UITheme.ROW_IDLE if kind == "ghost" else UITheme.CHASSIS_FILL),
		Color(0, 0, 0, 0) if primary else UITheme.BORDER_STRONG,
		0.0 if primary else 1.0))
	add_theme_stylebox_override("hover", style.call(
		UITheme.ACCENT.lerp(Color.WHITE, 0.15) if primary else (UITheme.ROW_HOVER if kind == "ghost" else Color(0.11, 0.12, 0.15, 0.72)),
		Color(0, 0, 0, 0) if primary else UITheme.BORDER_ACTIVE,
		0.0 if primary else 1.0))
	add_theme_stylebox_override("pressed", style.call(
		UITheme.ACCENT.lerp(Color.BLACK, 0.15) if primary else UITheme.ROW_ACTIVE,
		Color(0, 0, 0, 0) if primary else UITheme.BORDER_STRONG,
		0.0 if primary else 1.0))
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
