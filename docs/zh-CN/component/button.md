---
title: 按钮 Button
---

# 按钮 Button

extends Button，对标 el-button。通过 kind 切换三种样式类别；圆角 6、内边距左右 12 上下 6、悬停提亮、按下压暗。

## 交互演示

<div class="demo-stage" id="demo-button">
      <p class="hint">点击按钮有悬停提亮与按下压暗反馈，下方实时打印 pressed 事件。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var button := preload("res://addons/godot-element-plus/button/button.gd").new()
button.kind = "primary"
button.text = "开始探索"
add_child(button)
button.pressed.connect(func(): print("点击"))
```

## 属性

| 属性 | 说明 | 类型 | 可选值 | 默认值 |
|---|---|---|---|---|
| <code>kind</code> | 样式类别 | <code>String</code> | <code>"default"</code> 深色半透底盘+白32%描边 / <code>"primary"</code> 琥珀底+深色文字 / <code>"ghost"</code> 白6%底无描边 | <code>"default"</code> |
| <code>font_size</code> | 字号 | <code>int</code> | — | <code>14</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_kind(kind: String)</code> | 切换样式 |
| <code>get_kind() -&gt; String</code> | 当前样式类别 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>pressed</code> | 继承 Button 的 pressed | 无 |
