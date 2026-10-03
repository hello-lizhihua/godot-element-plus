---
title: 进度条 Progress
---

# 进度条 Progress

extends Control，对标 el-progress。圆角轨道（白6%底）+ 琥珀填充条 + 右端百分比小字（12px 弱化色）；纯展示无事件。

## 交互演示

<div class="demo-stage" id="demo-progress">
      <p class="hint">拖动或点击下方 0-100 滑块，进度条与右端百分比小字实时联动。</p>
    </div>

## 用法

```gdscript
var progress := preload("res://addons/godot-element-plus/progress/progress.gd").new()
add_child(progress)
progress.set_value(64.0)
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>value</code> | 进度值 0-100（钳制） | <code>float</code> | <code>0.0</code> |
| <code>bar_height</code> | 条高 | <code>float</code> | <code>8.0</code> |
| <code>show_percent</code> | 右端百分比小字 | <code>bool</code> | <code>true</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_value(v: float)</code> | 设置进度（钳制 0-100） |
| <code>get_value() -&gt; float</code> | 当前进度 |

## 事件
