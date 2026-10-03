---
title: 筛选按钮 Chip / ChipRow
---

# 筛选按钮 Chip / ChipRow

Chip extends Button：单个筛选按钮。未选中 = 白 6% 底 + 悬停白 14%，选中 = 琥珀 30% 底 + 1px 琥珀描边，圆角 6，字号 13。

## 交互演示

<div class="demo-stage" id="demo-chip">
      <p class="hint">上一行为单选（点选切换高亮），下一行为多选（点选切换、再点取消）；下方实时打印 chip_clicked 事件。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var row := preload("res://addons/godot-element-plus/chip_row/chip_row.gd").new()
row.add_chip("面积")
row.add_chip("人口")
row.add_chip("名称")
add_child(row)
# 单选语义：点击后按索引回推高亮
row.chip_clicked.connect(func(index): row.set_active_indexes([index]))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>active</code> | 选中态 | <code>bool</code> | <code>false</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_active(v: bool)</code> | 设置选中态 |
| <code>is_active() -&gt; bool</code> | 查询选中态 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>pressed</code> | 继承 Button 的 pressed | 无 |

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>chip_gap</code> | 横向间距 | <code>float</code> | <code>6.0</code> |
| <code>row_gap</code> | 换行纵向间距 | <code>float</code> | <code>4.0</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>add_chip(text: String) -&gt; Chip</code> | 追加 chip |
| <code>chip(index: int) -&gt; Chip</code> | 按索引取 chip |
| <code>count() -&gt; int</code> | chip 总数 |
| <code>set_active_indexes(indexes: Array)</code> | 按索引列表批量高亮（多选） |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>chip_clicked</code> | 任一 chip 按下 | <code>index: int</code> |
