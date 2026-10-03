---
title: 停靠面板 DockPanel
---

# 停靠面板 DockPanel

extends Control。右侧停靠面板：深色半透底 + 左缘 1px 分隔线 + 头部（标题 + 计数 + 收起钮）；收起后右缘仅剩圆形「›」把手（滑出动画），点把手展开；面板区域内滚轮一律就地消费（列表到顶/到底不穿透）；面板内未命中控件的按压就地吞掉（防透传成场景拖动）。内容经 content 容器（头部之下的 VBoxContainer）由使用方填充。

## 交互演示

<div class="demo-stage tall" id="demo-dock">
      <p class="hint">右侧停靠面板含标题与计数，点「‹」折叠为右缘圆形把手、点把手展开；列表内容滚动到顶/到底不会穿透。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var dock := preload("res://addons/godot-element-plus/dock_panel/dock_panel.gd").new()
dock.set_header("国家", 12)
add_child(dock)
# 内容经 content 容器由使用方填充
var label := Label.new()
label.text = "成员行交给使用方布局"
dock.content().add_child(label)
dock.collapse_toggled.connect(func(expanded): print("展开：", expanded))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>width</code> | 展开宽度 | <code>float</code> | <code>300.0</code> |
| <code>top</code> | 面板顶边距视口顶部（与左上角控制排同高） | <code>float</code> | <code>20.0</code> |
| <code>bottom_margin</code> | 距视口底部 | <code>float</code> | <code>20.0</code> |
| <code>right_margin</code> | 距视口右边 | <code>float</code> | <code>12.0</code> |
| <code>header_height</code> | 头部高度 | <code>float</code> | <code>34.0</code> |
| <code>pad_x</code> | 内容左右边距 | <code>float</code> | <code>14.0</code> |
| <code>collapsed</code> | 折叠态 | <code>bool</code> | <code>false</code> |
| <code>title</code> | 头部标题 | <code>String</code> | <code>""</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>toggle_collapsed() / set_collapsed(v: bool)</code> | 收起（0.28s 滑出动画，收起后右缘仅剩圆形「›」把手，点击把手展开）/ 程序化收起展开 |
| <code>is_expanded() -&gt; bool</code> | 是否处于展开态 |
| <code>set_header(title: String, count: int)</code> | 设置头部标题与计数 |
| <code>content() -&gt; VBoxContainer</code> | 内容容器（头部之下，折叠时隐藏） |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>collapse_toggled</code> | 折叠状态切换后 | <code>expanded: bool</code> |
