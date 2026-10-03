---
title: 手风琴 Accordion
---

# 手风琴 Accordion

extends VBoxContainer，对标 el-collapse 手风琴。accordion = true 时展开一组收起其余，false 各分组独立开合。标题行视觉：淡底 + 标题（15px）+ 右侧计数（12px 弱化）+ 右端箭头（展开向下、收起向右）+ 激活左缘琥珀强调条。

## 交互演示

<div class="demo-stage" id="demo-accordion">
      <p class="hint">默认展开第一组，点击标题开一收一；点上方「切换为独立开合」进入 accordion = false 模式，各分组可同时展开、独立开合。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var accordion := preload("res://addons/godot-element-plus/accordion/accordion.gd").new()
add_child(accordion)
var asia := accordion.add_section("亚洲", "4")
var row := Label.new()
row.text = "成员行交给使用方填充"
accordion.section_content(asia).add_child(row)
accordion.section_toggled.connect(func(index, expanded): print("分组 ", index, " 展开：", expanded))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>accordion</code> | true 展开一组收起其余；false 各分组独立开合 | <code>bool</code> | <code>true</code> |
| <code>title_height</code> | 标题行高 | <code>float</code> | <code>32.0</code> |
| <code>pad_x</code> | 左右边距 | <code>float</code> | <code>14.0</code> |
| <code>open_sections</code> | 展开分组序号列表 | <code>Array</code> | <code>[0]</code> |
| <code>active_sections</code> | 激活分组（标题左缘琥珀强调条） | <code>Array</code> | <code>[]</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>add_section(title: String, count: String = "") -&gt; int</code> | 追加分组返回序号，count 为标题右侧计数文案 |
| <code>clear_sections()</code> | 清空全部分组 |
| <code>section_content(index: int) -&gt; VBoxContainer</code> | 分组内容容器，收起时隐藏 |
| <code>toggle_section(index: int)</code> | 切换分组展开 / 收起 |
| <code>set_open(index: int, expanded: bool)</code> | 设置分组展开态（accordion 模式下展开并收起其余） |
| <code>is_open(index: int) -&gt; bool</code> | 分组是否展开 |
| <code>set_active_sections(sections: Array)</code> | 设置激活分组（标题左缘琥珀强调条） |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>section_toggled</code> | 标题行点击切换后发出 | <code>section_index: int</code>, <code>expanded: bool</code> |
