---
title: 对话框 Dialog
---

# 对话框 Dialog

extends Control，对标 el-dialog。视觉：全屏遮罩（黑40%）+ 居中深色半透面板（白32%描边、圆角 14）+ 标题栏（标题 + 右上角 × 关闭钮）+ 内容区；遮罩与面板就地消费点击。

## 交互演示

<div class="demo-stage" id="demo-dialog" style="min-height:240px;">
      <p class="hint">点击「打开对话框」弹出模态对话框；visible_modal = true 时点遮罩不关闭，需点右上角 × 关闭。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var dialog := preload("res://addons/godot-element-plus/dialog/dialog.gd").new()
dialog.title = "删除确认"
add_child(dialog)
var label := Label.new()
label.text = "确认删除所选国家？"
dialog.content().add_child(label)
dialog.open_dialog()
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>title</code> | 标题栏文字 | <code>String</code> | <code>""</code> |
| <code>width</code> | 面板宽 | <code>float</code> | <code>360.0</code> |
| <code>visible_modal</code> | 模态遮罩（true 时点遮罩不关闭，需点 × 或调 close_dialog） | <code>bool</code> | <code>true</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>open_dialog()</code> | 打开对话框 |
| <code>close_dialog()</code> | 关闭对话框 |
| <code>is_open() -&gt; bool</code> | 是否打开 |
| <code>content() -&gt; VBoxContainer</code> | 内容容器 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>opened</code> | 打开后发出 | 无 |
| <code>closed</code> | 关闭后发出 | 无 |
