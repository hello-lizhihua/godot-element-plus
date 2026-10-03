---
title: 选择器 Select
---

# 选择器 Select

extends Control，对标 el-select。收起态 = 圆角 6 选择框（当前标签 + 右端 ▾）；展开态 = 下方深色半透弹出面板，单选当前项高亮 + 行尾选中点，点选项选中并收起，点面板外收起。多选模式：无选中显示 placeholder，选中 1 项显示其标签，多项显示「首项 等 N 项」；面板中勾选行高亮 + 行首琥珀对勾（替代单选的行尾选中点）。

## 交互演示

<div class="demo-stage" id="demo-select">
      <p class="hint">左侧单选（时段）：点击选择框展开面板，点选项选中并收起（当前项高亮 + 行尾选中点）；右侧多选（大洲）：点击行切换勾选、面板保持展开（勾选行行首琥珀对勾），选择框显示「首项 等 N 项」。点面板外或再点选择框收起。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var select := preload("res://addons/godot-element-plus/select/select.gd").new()
select.options = [["白天", "day"], ["夜晚", "night"]]
add_child(select)
select.option_selected.connect(func(value): print("选择 ", value))

# 多选模式：点击行切换勾选，面板保持展开
var multi := preload("res://addons/godot-element-plus/select/select.gd").new()
multi.multiple = true
multi.options = [["亚洲", "asia"], ["欧洲", "europe"], ["非洲", "africa"]]
add_child(multi)
multi.option_toggled.connect(func(value): print("勾选 ", value))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>options</code> | 选项数组（每项 [标签, 值]） | <code>Array</code> | <code>[]</code> |
| <code>value</code> | 当前值，显示对应标签 | <code>String</code> | <code>""</code> |
| <code>values</code> | 多选模式勾选值集合 | <code>Array</code> | <code>[]</code>（默认 []） |
| <code>multiple</code> | true 多选：点击行切换勾选、面板保持展开，发 option_toggled；false 单选：点击选中并收起，发 option_selected | <code>bool</code> | <code>false</code> |
| <code>exclusive_first</code> | 多选模式：首项与其他项互斥（首项作「全部/无筛选」语义，勾选它清空其他、勾选其他清空它） | <code>bool</code> | <code>false</code> |
| <code>show_clear</code> | 多选模式有可清除勾选时显示「×」清除按钮（▾ 左侧，间隔 3px），点击清空全部勾选并发 selection_cleared；exclusive_first 下仅勾首项（「全部」）视为无勾选，不显示 × | <code>bool</code> | <code>false</code> |
| <code>label</code> | 外置标签（绘制在选择框左侧） | <code>String</code> | <code>""</code> |
| <code>label_width</code> | 外置标签宽度（选择框右移让出） | <code>float</code> | <code>32.0</code> |
| <code>placeholder</code> | 无选中时选择框显示文字 | <code>String</code> | <code>""</code>（默认 ""） |
| <code>width</code> | 控件与弹出面板宽（setter 同步最小尺寸，容器布局按实宽分配） | <code>float</code> | <code>148.0</code> |
| <code>row_height</code> | 行高 | <code>float</code> | <code>34.0</code> |
| <code>font_size</code> | 字号 | <code>int</code> | <code>14</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>open_panel()</code> | 展开面板 |
| <code>close_panel()</code> | 收起面板 |
| <code>is_open() -&gt; bool</code> | 面板是否展开 |
| <code>set_values(v: Array)</code> | 多选模式程序化赋值（不发事件，未出现的值保留） |
| <code>get_values() -&gt; Array</code> | 当前勾选值集合 |
| <code>clear_selection()</code> | 清空多选勾选（不发事件） |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>option_selected</code> | 点击选项后发出并收起面板 | <code>value: String</code> |
| <code>option_toggled</code> | 多选模式点击行切换后发出（勾选状态由组内维护） | <code>value: String</code> |
| <code>opened</code> | 面板展开 | 无 |
