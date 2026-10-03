extends HBoxContainer
## 分页器：‹ 上一页 + 页码 chips（总页数
## 超过 7 页时首尾保留、当前页前后各一、其余省略号）+ › 下一页；当前页琥珀高亮。
## 程序化 set_current 不发事件；点击页码或 ‹/› 发 page_changed。

signal page_changed(page: int)

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")
const ChipScript := preload("res://addons/godot-element-plus/chip/chip.gd")
const ButtonScript := preload("res://addons/godot-element-plus/button/button.gd")

var total_pages := 1
var current := 1

var _row: HBoxContainer

const MAX_PILLS := 7 # 页码位上限（首尾 + 当前±1 + 省略号）


func _init() -> void:
	add_theme_constant_override("separation", UITheme.GAP_XS)
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", UITheme.GAP_XS)
	add_child(_row)
	_rebuild()


func set_total(pages: int) -> void:
	total_pages = maxi(pages, 1)
	current = clampi(current, 1, total_pages)
	_rebuild()


func set_current(page: int) -> void:
	current = clampi(page, 1, total_pages)
	_rebuild()


func current_page() -> int:
	return current


func _goto(page: int) -> void:
	var target := clampi(page, 1, total_pages)
	if target == current:
		return
	current = target
	_rebuild()
	page_changed.emit(current)


func _rebuild() -> void:
	for child in _row.get_children():
		child.queue_free()
	var prev: Button = ButtonScript.new()
	prev.text = "‹"
	prev.kind = "ghost"
	prev.pressed.connect(func(): _goto(current - 1))
	_row.add_child(prev)
	for page in _page_pills():
		if page < 0:
			# 省略号占位
			var dots := Label.new()
			dots.text = "…"
			dots.add_theme_font_override("font", UITheme.system_font())
			dots.add_theme_font_size_override("font_size", 13)
			dots.add_theme_color_override("font_color", UITheme.TEXT_FAINT)
			_row.add_child(dots)
			continue
		var pill: Button = ChipScript.new()
		pill.text = str(page)
		pill.set_active(page == current)
		pill.pressed.connect(_goto.bind(page))
		_row.add_child(pill)
	var next: Button = ButtonScript.new()
	next.text = "›"
	next.kind = "ghost"
	next.pressed.connect(func(): _goto(current + 1))
	_row.add_child(next)


## 页码序列：总页数不超上限全列；否则首尾 + 当前±1，断口填省略号（-1）
func _page_pills() -> Array:
	if total_pages <= MAX_PILLS:
		var all: Array = []
		for page in total_pages:
			all.append(page + 1)
		return all
	var pages: Array = [1]
	var start := maxi(current - 1, 2)
	var end := mini(current + 1, total_pages - 1)
	if start > 2:
		pages.append(-1)
	for page in range(start, end + 1):
		pages.append(page)
	if end < total_pages - 1:
		pages.append(-1)
	pages.append(total_pages)
	return pages
