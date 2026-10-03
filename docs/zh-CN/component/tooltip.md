---
title: 悬停提示 Tooltip
---

# 悬停提示 Tooltip

extends Control，对标 el-tooltip。悬停提示气泡——锚定宿主控件，鼠标悬停显示、移出隐藏；全屏 IGNORE 覆盖层绘制气泡（深色半透 + 白描边 + 箭头），不拦截任何输入；也经 show_tip / hide_tip 编程控制（触屏长按场景由使用方接线）。

## 交互演示

<div class="demo-stage" id="demo-tooltip">
      <p class="hint">鼠标悬停齿轮图标显示气泡、移出隐藏；切换 placement 改变气泡出现在宿主上方或下方；show_tip() / hide_tip() 编程控制。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var tooltip := preload("res://addons/godot-element-plus/tooltip/tooltip.gd").new()
add_child(tooltip)
tooltip.attach_to(gear_button, "全局设置")
tooltip.show_tip()  # 编程显示，hide_tip() 隐藏；悬停显隐已自动接线
```

## 属性

| 属性 | 说明 | 类型 | 可选值 | 默认值 |
|---|---|---|---|---|
| <code>text</code> | 提示文字 | <code>String</code> | — | <code>""</code> |
| <code>placement</code> | 气泡相对宿主位置 | <code>String</code> | <code>"top"</code> / <code>"bottom"</code> | <code>"top"</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>attach_to(target: Control, tip_text: String)</code> | 绑定宿主控件（悬停显隐自动接线，target.mouse_entered/exited） |
| <code>show_tip() / hide_tip()</code> | 编程显示 / 隐藏（定位在宿主上方或下方居中） |

## 事件
