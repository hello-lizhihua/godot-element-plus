---
title: 复选按钮组 CheckboxGroup
---

# 复选按钮组 CheckboxGroup

extends HFlowContainer，对标 el-checkbox-group 按钮组。多选语义内置——与 ChipRow（行不持有选中状态、单选/多选语义由使用方实现）不同，勾选状态由组内维护；每项的 value 为勾选标识，应唯一。

## 交互演示

<div class="demo-stage" id="demo-checkbox-group">
      <p class="hint">点选切换勾选、再点取消，可同时勾选多项；下方实时打印 option_toggled 事件。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var group := preload("res://addons/godot-element-plus/checkbox_group/checkbox_group.gd").new()
group.add_option("分组 A", 1)
group.add_option("分组 B", 2)
add_child(group)
group.set_checked_values([1, 2])
group.option_toggled.connect(func(value): print("勾选标识 ", value))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>chip_gap</code> | 横向间距 | <code>float</code> | <code>6.0</code> |
| <code>row_gap</code> | 换行纵向间距 | <code>float</code> | <code>4.0</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>add_option(text: String, value: int = -1) -&gt; Button</code> | 追加选项返回 chip 供挂 meta；value 为该选项勾选标识 |
| <code>set_checked_values(values: Array)</code> | 按 value 批量勾选 |
| <code>checked_values() -&gt; Array</code> | 当前勾选的 value 列表 |
| <code>count() -&gt; int</code> | 选项总数 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>option_toggled</code> | 点击切换后发出；勾选状态由组内维护 | <code>value: int</code> |
