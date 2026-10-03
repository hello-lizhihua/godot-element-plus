---
title: 分割线 Divider
---

# 分割线 Divider

extends Control，对标 el-divider。水平 1px 分割线；带文案时线在文案两侧断开，文案 12px 弱化色；控件高度建议 12（纯线）或 20（带文案）；纯展示无事件。

## 交互演示

<div class="demo-stage" id="demo-divider">
      <p class="hint">上为纯分割线，下为带居中文案「筛选条件」的分割线（线在文案两侧断开）。</p>
    </div>

## 用法

```gdscript
var divider := preload("res://addons/godot-element-plus/divider/divider.gd").new()
divider.text = "筛选条件"
add_child(divider)
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>text</code> | 居中文案（空则纯分割线） | <code>String</code> | <code>""</code> |
| <code>line_color</code> | 线色 | <code>Color</code> | <code>rgba(255,255,255,0.14)</code> |

## 方法

## 事件
