---
title: 单选按钮组 RadioGroup
---

# 单选按钮组 RadioGroup

extends HFlowContainer，对标 el-radio-group 按钮组。每项为筛选按钮 chip 形态，选中项琥珀高亮；单选状态由组内维护。

## 交互演示

<div class="demo-stage" id="demo-radio-group">
      <p class="hint">点击任一选项切换选中，选中项琥珀高亮、其余取消；下方实时打印 selected_changed 事件。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var group := preload("res://addons/godot-element-plus/radio_group/radio_group.gd").new()
group.add_option("面积")
group.add_option("人口")
add_child(group)
group.selected_changed.connect(func(index): print("选中 ", index))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>chip_gap</code> | 横向间距 | <code>float</code> | <code>6.0</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>add_option(text: String) -&gt; int</code> | 追加选项返回序号 |
| <code>set_selected(index: int)</code> | 程序化赋值不发事件，超范围钳制 |
| <code>selected() -&gt; int</code> | 当前选中序号 |
| <code>count() -&gt; int</code> | 选项总数 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>selected_changed</code> | 点击选择后发出；单选状态由组内维护 | <code>index: int</code> |
