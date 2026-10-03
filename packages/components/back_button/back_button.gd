extends "res://addons/godot-element-plus/icon_button/icon_button.gd"
## 返回按钮：左上角左向箭头，点击切换场景到 target_scene。

var target_scene := "res://scenes/scene_picker.tscn"


func _init() -> void:
	super() # 父类 _init 不会被隐式调用：补底盘组件状态
	icon = "back"
	corner = "top-left"


func _on_pressed() -> void:
	pressed.emit()
	get_tree().change_scene_to_file(target_scene)
