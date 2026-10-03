---
title: 开关 Switch
---

# 开关 Switch

extends Control，对标 el-switch。全宽圆角轨道（关=白14%底，开=琥珀底）+ 白色滑动圆钮（关在左、开在右）；控件矩形内鼠标/触屏点击切换。

## 交互演示

<div class="demo-stage" id="demo-switch">
      <p class="hint">点击轨道切换开态，圆钮滑动，下方实时打印 toggled 事件。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var switch := preload("res://addons/godot-element-plus/switch/switch.gd").new()
add_child(switch)
switch.toggled.connect(func(checked): print("开态 ", checked))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>checked</code> | 开态 | <code>bool</code> | <code>false</code> |
| <code>track_width</code> | 轨道宽 | <code>float</code> | <code>40.0</code> |
| <code>track_height</code> | 轨道高 | <code>float</code> | <code>22.0</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_checked(v: bool)</code> | 程序化赋值不发事件 |
| <code>is_checked() -&gt; bool</code> | 当前开态 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>toggled</code> | 点击切换后发出 | <code>checked: bool</code> |
