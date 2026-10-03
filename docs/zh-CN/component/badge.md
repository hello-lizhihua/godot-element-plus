---
title: 徽章 Badge
---

# 徽章 Badge

extends Control，对标 el-badge。圆点（直径 8）或数字胶囊（琥珀底+深色文字 10px），作为独立小控件叠加在宿主角落（经 position 放置）；纯展示无事件。

## 交互演示

<div class="demo-stage" id="demo-badge">
      <p class="hint">徽章叠加在齿轮图标右上角：大于 0 显示数字胶囊、减到 0 显示小圆点，「显示切换」控制 show。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var badge := preload("res://addons/godot-element-plus/badge/badge.gd").new()
badge.count = 5
badge.position = Vector2(24, -6)  # 叠加在宿主角落
icon_button.add_child(badge)
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>count</code> | 数值（大于 0 显示数字胶囊，等于 0 显示小圆点） | <code>int</code> | <code>0</code> |
| <code>show</code> | 是否显示 | <code>bool</code> | <code>true</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_count(count: int)</code> | 设置数值 |
| <code>set_show(show: bool)</code> | 设置是否显示 |

## 事件
