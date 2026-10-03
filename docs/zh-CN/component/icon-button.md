---
title: 图标按钮 IconButton / WindowButton / BackButton
---

# 图标按钮 IconButton / WindowButton / BackButton

IconButton extends Control。圆形底盘 + 程序化绘制图标，锚定屏幕角落；桌面鼠标与触屏统一命中，命中就地消费、未命中透传给场景。

## 交互演示

<div class="demo-stage" id="demo-icon-button" style="min-height:150px;">
      <p class="hint">右上角一枚齿轮 + 一枚最大化按钮：点击有按下反馈；最大化按钮在最大化窗口态（四角外扩括号）与无边框全屏态（双叠方框）两种图标间切换。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var gear := preload("res://addons/godot-element-plus/icon_button/icon_button.gd").new()
gear.icon = "gear"
add_child(gear)
gear.pressed.connect(func(): print("打开设置"))
```

## 属性

| 属性 | 说明 | 类型 | 可选值 | 默认值 |
|---|---|---|---|---|
| <code>icon</code> | 图标种类 | <code>String</code> | <code>"gear"</code> 齿轮 / <code>"list"</code> 列表 / <code>"back"</code> 返回箭头 | <code>"gear"</code> |
| <code>corner</code> | 锚定角落 | <code>String</code> | <code>"top-right"</code> / <code>"top-left"</code> | <code>"top-right"</code> |
| <code>margin</code> | 图标中心距角落横向点距 | <code>float</code> | — | <code>40.0</code> |
| <code>radius</code> | 底盘半径 | <code>float</code> | — | <code>16.0</code> |
| <code>hit_slack</code> | 命中放宽（指尖精度） | <code>float</code> | — | <code>6.0</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>icon_center() -&gt; Vector2</code> | 视口坐标中心 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>pressed</code> | 按下图标 | 无 |

## 差异属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>margin</code> | 与齿轮同排时使用方设 96.0 | <code>float</code> | <code>40.0</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>is_fullscreen() -&gt; bool</code> | 当前是否为无边框全屏 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>pressed</code> | 按下在无边框全屏与最大化窗口间切换，切换后发出 | 无 |

## 差异属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>target_scene</code> | 按下后切换到的场景路径 | <code>String</code> | <code>"res://scenes/scene_picker.tscn"</code> |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>pressed</code> | 按下切换场景到 target_scene | 无 |
