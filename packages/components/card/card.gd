extends PanelContainer
## 卡片：圆角 14 深色半透卡底 +
## 白 14% 描边，头部标题（可空）+ 内容容器。使用方经 content() 填充内容。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

var title := ""

var _column: VBoxContainer
var _header: Label
var _content: VBoxContainer

const CARD_BG := Color(16.0 / 255.0, 18.0 / 255.0, 23.0 / 255.0, 0.9)


func _init() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = CARD_BG
	style.set_corner_radius_all(UITheme.CORNER_L)
	style.border_color = UITheme.BORDER_SOFT
	style.set_border_width_all(1.0)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 14.0
	add_theme_stylebox_override("panel", style)
	_column = VBoxContainer.new()
	_column.add_theme_constant_override("separation", 10)
	add_child(_column)


func _ready() -> void:
	if _header == null:
		_header = Label.new()
		_header.add_theme_font_override("font", UITheme.system_font())
		_header.add_theme_font_size_override("font_size", 15)
		_header.add_theme_color_override("font_color", UITheme.TEXT_MAIN)
		_column.add_child(_header)
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", UITheme.GAP_XS)
	_column.add_child(_content)
	_apply_title()


func set_title(v: String) -> void:
	title = v
	_apply_title()


## 内容容器（头部之下）
func content() -> VBoxContainer:
	return _content


func _apply_title() -> void:
	if _header == null:
		return
	_header.text = title
	_header.visible = title != ""
