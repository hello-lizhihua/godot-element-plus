---
title: 输入框 Input
---

# 输入框 Input

extends LineEdit，对标 el-input。构造即应用主题：深色半透底 rgba(20,22,28,0.62)、白 20% 描边、聚焦琥珀描边、圆角 6、左右内边距 10、字号 14、文字 #f0ede6、占位文字 55% 弱化色。

## 交互演示

<div class="demo-stage" id="demo-input">
      <p class="hint">输入即打印 text_changed，回车触发 text_submitted；聚焦时描边变为琥珀色。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var input := preload("res://addons/godot-element-plus/input/input.gd").new()
input.placeholder_text = "输入国家名称"
add_child(input)
input.text_submitted.connect(func(text): print("提交 ", text))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| 无新增 | text、placeholder_text、editable 等继承 LineEdit | — | — |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>text_changed</code> | 继承 LineEdit，输入即发出 | <code>new_text: String</code> |
| <code>text_submitted</code> | 继承 LineEdit（回车触发） | <code>text: String</code> |
