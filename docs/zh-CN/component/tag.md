---
title: 标签 Tag
---

# 标签 Tag

extends Label，对标 el-tag。圆角 6、样式盒内边距左右 8 上下 2、字号 12；纯展示无事件。

## 交互演示

<div class="demo-stage" id="demo-tag">
      <p class="hint">三种配色类别一目了然；点击任一标签循环切换配色（set_kind），下方实时打印。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var tag := preload("res://addons/godot-element-plus/tag/tag.gd").new()
tag.text = "新上线"
tag.kind = "accent"
add_child(tag)
```

## 属性

| 属性 | 说明 | 类型 | 可选值 | 默认值 |
|---|---|---|---|---|
| <code>kind</code> | 配色类别 | <code>String</code> | <code>"accent"</code> 琥珀30%底+琥珀字 / <code>"info"</code> 白10%底+米白字 / <code>"dim"</code> 白6%底+弱化字 | <code>"info"</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_kind(kind: String)</code> | 切换配色类别 |

## 事件
