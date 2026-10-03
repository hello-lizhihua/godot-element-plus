extends "res://addons/godot-element-plus/icon_button/icon_button.gd"
## 最大化按钮：右上角，点击在无边框全屏与最大化窗口间
## 切换（保留系统标题栏的启动最大化由 app_window 负责）；图标状态感知——最大化
## 窗口态画四角外扩括号（进入全屏语义），全屏态画双叠方框（还原窗口语义）。
## margin 决定图标中心距右上角的横向点距：独占右上角用 40，与齿轮同排用 96
## （齿轮中心 40、命中半径 27，96 间距使命中区不重叠）。

func _init() -> void:
	super() # 父类 _init 不会被隐式调用：补底盘组件状态
	icon = "maximize"
	corner = "top-right"


func _on_pressed() -> void:
	_toggle_fullscreen()
	pressed.emit()


func _toggle_fullscreen() -> void:
	var mode := get_window().mode
	if mode == Window.MODE_FULLSCREEN or mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		get_window().mode = Window.MODE_MAXIMIZED
	else:
		get_window().mode = Window.MODE_FULLSCREEN


func is_fullscreen() -> bool:
	var mode := get_window().mode
	return mode == Window.MODE_FULLSCREEN or mode == Window.MODE_EXCLUSIVE_FULLSCREEN


func _draw_glyph(center: Vector2) -> void:
	if not is_fullscreen():
		# 最大化窗口态：四角外扩括号（进入全屏语义）
		var half := 7.0
		var arm := 4.0
		for sx in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				var point := center + Vector2(sx * half, sy * half)
				draw_line(point, point + Vector2(-sx * arm, 0.0), UITheme.TEXT_MAIN, 2.0, true)
				draw_line(point, point + Vector2(0.0, -sy * arm), UITheme.TEXT_MAIN, 2.0, true)
	else:
		# 全屏态：双叠方框（还原窗口语义）
		draw_rect(Rect2(center + Vector2(-6.5, -2.5), Vector2(9.0, 9.0)), UITheme.TEXT_MAIN, false, 2.0)
		draw_rect(Rect2(center + Vector2(-2.5, -6.5), Vector2(9.0, 9.0)), UITheme.CHASSIS_FILL, true)
		draw_rect(Rect2(center + Vector2(-2.5, -6.5), Vector2(9.0, 9.0)), UITheme.TEXT_MAIN, false, 2.0)
