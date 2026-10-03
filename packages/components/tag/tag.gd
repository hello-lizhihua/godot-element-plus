extends Label
## 标签：小号圆角标签，accent 琥珀
## 30% 底 + 琥珀字、info 白 10% 底 + 米白字、dim 白 6% 底 + 弱化字。纯展示。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var kind := "info" # accent / info / dim


func _init() -> void:
	add_theme_font_override("font", UITheme.system_font())
	add_theme_font_size_override("font_size", 12)
	_apply_style()


func set_kind(v: String) -> void:
	kind = v
	_apply_style()


func get_kind() -> String:
	return kind


func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(UITheme.CORNER_S)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 2.0
	style.content_margin_bottom = 2.0
	match kind:
		"accent":
			style.bg_color = UITheme.ACCENT_WASH
			add_theme_color_override("font_color", UITheme.ACCENT)
		"dim":
			style.bg_color = UITheme.ROW_IDLE
			add_theme_color_override("font_color", UITheme.TEXT_FAINT)
		_:
			style.bg_color = UITheme.ROW_HOVER
			add_theme_color_override("font_color", UITheme.TEXT_MAIN)
	add_theme_stylebox_override("normal", style)
