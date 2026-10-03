---
title: 卡片 Card
---

# 卡片 Card

extends PanelContainer，对标 el-card。圆角 14 深色半透卡底 rgba(16,18,23,0.9) + 白14%描边 + 头部标题 15px 与内容区间距 10；title 为空则不显示头部；纯展示无事件。

## 交互演示

<div class="demo-stage" id="demo-card">
      <p class="hint">头部标题 + 内容容器的标准卡片；内容经 content() 容器由使用方填充（演示内含 Tag 示例）。</p>
    </div>

## 用法

```gdscript
var card := preload("res://addons/godot-element-plus/card/card.gd").new()
card.title = "国家概览"
add_child(card)
var label := Label.new()
label.text = "面积与人口概要"
card.content().add_child(label)
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>title</code> | 头部标题（空则不显示头部） | <code>String</code> | <code>""</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_title(title: String)</code> | 设置头部标题 |
| <code>content() -&gt; VBoxContainer</code> | 内容容器 |

## 事件
