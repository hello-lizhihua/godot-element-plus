extends PanelContainer
## 警示条：着色底 + 左缘 3px 强调
## 竖条 + 文字 + 可选右上角关闭钮；四种语义配色（info 米白 / success 翠绿 /
## warning 琥珀 / danger 红橙）。点击关闭钮隐藏面板并发出 closed。

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

signal closed

var kind := "info" # info / success / warning / danger
var text := ""
var closable := false

var _label: Label
var _close: Button
var _built := false

# 语义配色：[主色, 底色, 文字色]
const KIND_COLORS := {
	"info": [Color(0.941, 0.929, 0.902), Color(1.0, 1.0, 1.0, 0.10), Color(0.941, 0.929, 0.902)],
	"success": [Color(0.27, 0.8, 0.53), Color(0.27, 0.8, 0.53, 0.12), Color(0.62, 0.92, 0.78)],
	"warning": [Color(1.0, 0.8, 0.2), Color(1.0, 0.8, 0.2, 0.12), Color(1.0, 0.92, 0.66)],
	"danger": [Color(1.0, 0.4, 0.27), Color(1.0, 0.4, 0.27, 0.12), Color(1.0, 0.72, 0.66)],
}


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	_build()


func _build() -> void:
	if _built:
		return
	_built = true
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", UITheme.GAP_M)
	add_child(box)
	_label = Label.new()
	_label.add_theme_font_override("font", UITheme.system_font())
	_label.add_theme_font_size_override("font_size", 13)
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_label)
	_close = Button.new()
	_close.text = "×"
	_close.flat = true
	_close.add_theme_font_override("font", UITheme.system_font())
	_close.add_theme_font_size_override("font_size", 14)
	_close.add_theme_color_override("font_color", UITheme.TEXT_DIM)
	_close.add_theme_color_override("font_hover_color", UITheme.TEXT_MAIN)
	_close.focus_mode = Control.FOCUS_NONE
	_close.pressed.connect(func():
		visible = false
		closed.emit())
	box.add_child(_close)
	_apply_style()


func set_kind(v: String) -> void:
	kind = v
	if _built:
		_apply_style()


func set_text(v: String) -> void:
	text = v
	if _built:
		_label.text = v


func _apply_style() -> void:
	var colors: Array = KIND_COLORS.get(kind, KIND_COLORS["info"])
	var style := StyleBoxFlat.new()
	style.bg_color = colors[1]
	style.set_corner_radius_all(UITheme.CORNER_S)
	style.border_color = colors[0]
	style.border_width_left = 3
	style.content_margin_left = 12.0
	style.content_margin_right = 8.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	add_theme_stylebox_override("panel", style)
	_label.text = text
	_label.add_theme_color_override("font_color", colors[2])
	_close.visible = closable
