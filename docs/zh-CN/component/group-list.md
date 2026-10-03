---
title: 分组列表 GroupList
---

# 分组列表 GroupList

extends ScrollContainer。分组列表以手风琴承载——分组标题行即手风琴标题（标题 + 计数 + 右端箭头 + 激活左缘琥珀强调条），成员行为手风琴内容；选中行展开详情 + 组内排序 + 悬停高亮 + 点击去重 + 滚动到可见。行内容经子类钩子定制（列表负责结构与交互，子类负责行内布局）。

## 交互演示

<div class="demo-stage" id="demo-group-list">
      <p class="hint">列表以手风琴承载：默认展开第一组（亚洲），点击标题开一收一（标题 + 计数 + 右端箭头）；点成员行选中并展开详情（再点同行取消）；切换排序条目组内按所选键降序重排并保持选中与展开。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
# 通常经子类使用：子类实现 _fill_item_row 定制行内布局
var list := preload("res://addons/godot-element-plus/group_list/group_list.gd").new()
add_child(list)
list.set_data([
	{"name": "asia", "title": "亚洲", "items": [{"name": "中国", "area": 960.0}]},
])
list.item_clicked.connect(func(item, index): list.set_selected(index))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>sort_keys</code> | 排序条目（每项 [标签, 键]） | <code>Array</code> | <code>[]</code> |
| <code>sort_key</code> | 当前排序键 | <code>String</code> | <code>""</code> |
| <code>sort_comparator</code> | 排序比较器 (key, a, b) -&gt; bool（a 是否排在 b 前）；缺省为按键数值降序 | <code>Callable</code> | <code>空Callable</code> |
| <code>title_height</code> | 标题行高 | <code>float</code> | <code>30.0</code> |
| <code>item_height</code> | 成员行高 | <code>float</code> | <code>38.0</code> |
| <code>detail_extra</code> | 选中行展开详情高度 | <code>float</code> | <code>48.0</code> |
| <code>accordion</code> | 手风琴语义：展开一组收起其余，false 全部展开 | <code>bool</code> | <code>true</code> |
| <code>open_section</code> | 初始展开的分组序号，-1 全部收起 | <code>int</code> | <code>0</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_data(groups: Array)</code> | 传入分组数据，每项 {name, title, items}；name 分组键、title 标题显示名、items 成员载荷字典数组；分组顺序即数组顺序，空分组不显示（跳过） |
| <code>set_sort(key)</code> | 切换排序并重排（保持选中与展开） |
| <code>set_selected(index: int)</code> | 选中成员（载荷索引，-1 取消；选中行展开详情、所在分组自动展开并滚动到可见） |
| <code>set_active_groups(indexes: Array)</code> | 高亮分组标题（标题行左缘琥珀强调条） |
| <code>row_count() -&gt; int</code> | 标题行 + 成员行总数 |
| <code>item_index_at(pos: int) -&gt; int</code> | 显示位置 -&gt; 成员载荷索引（非成员行返回 -1） |
| <code>scroll_to_item(index: int)</code> | 滚动使成员行可见（等一帧重排后滚动） |

## 子类钩子

| 钩子 | 说明 |
|---|---|
| <code>_fill_item_row(row: Control, item: Dictionary)</code> | 填充成员行内容；详情 Label 创建后以 meta "details"（Label 数组）挂到 row，选中展开时由列表统一显隐 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>section_toggled</code> | 标题行点击切换分组展开后发出 | <code>section_index: int</code>（set_data 数组中非空分组的序号）, <code>expanded: bool</code> |
| <code>item_clicked</code> | 成员行点击（同帧同行只发一次） | <code>item: Dictionary</code>（载荷）, <code>index: int</code>（载荷索引） |
| <code>rows_changed</code> | 列表重排完成后 | 行记录数组 <code>{kind: "title"/"item", ...}</code> |
