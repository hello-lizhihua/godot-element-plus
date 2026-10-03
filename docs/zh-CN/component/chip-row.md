---
title: chip 行 ChipRow
---

# chip 行 ChipRow

extends HFlowContainer。流式排列、自动换行的 chip 行。行不持有选中状态——点击上报索引，使用方经 set_active_indexes 回推高亮；单选与多选语义由使用方实现。

## 用法

```gdscript
var row := preload("res://addons/godot-element-plus/chip_row/chip_row.gd").new()
for text in ["亚洲", "欧洲", "北美洲"]:
    row.add_chip(text)
row.chip_clicked.connect(func(index): row.set_active_indexes([index]))
add_child(row)
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>chip_gap</code> | chip 横向间距 | <code>float</code> | <code>6.0</code> |
| <code>row_gap</code> | 行间距 | <code>float</code> | <code>4.0</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>add_chip(text)</code> | 追加一个 chip，返回 chip 组件 |
| <code>set_active_indexes(indexes)</code> | 回推高亮（全量列表） |

## 信号

| 信号 | 说明 |
|---|---|
| <code>chip_clicked(index)</code> | 点击某个 chip，上报其索引 |
