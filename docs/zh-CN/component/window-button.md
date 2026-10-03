---
title: 窗口按钮 WindowButton
---

# 窗口按钮 WindowButton

extends 图标按钮。右上角，点击在无边框全屏与最大化窗口间切换；图标状态感知——最大化窗口态画四角外扩括号（进入全屏语义），全屏态画双叠方框（还原窗口语义）。margin 决定图标中心距右上角的横向点距：独占右上角用 40，与齿轮同排用 96。

## 用法

```gdscript
var button := preload("res://addons/godot-element-plus/window_button/window_button.gd").new()
button.margin = 96.0
add_child(button)
```

## 方法

| 方法 | 说明 |
|---|---|
| <code>is_fullscreen()</code> | 当前是否处于无边框全屏 |
