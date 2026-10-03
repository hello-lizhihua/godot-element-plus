---
title: 返回按钮 BackButton
---

# 返回按钮 BackButton

extends 图标按钮。左上角左向箭头，点击发出 pressed 并切换场景到 target_scene。

## 用法

```gdscript
var back := preload("res://addons/godot-element-plus/back_button/back_button.gd").new()
back.target_scene = "res://scenes/scene_picker.tscn"
back.pressed.connect(func(): print("返回"))
add_child(back)
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>target_scene</code> | 点击后切换到的场景路径 | <code>String</code> | <code>"res://scenes/scene_picker.tscn"</code> |

## 信号

| 信号 | 说明 |
|---|---|
| <code>pressed</code> | 点击按钮（切场景由使用方或组件内部执行） |
