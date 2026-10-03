---
title: 设置面板 SettingsPanel
---

# 设置面板 SettingsPanel

extends Control。设置面板 = 角落齿轮图标 + 单选行弹出面板。点击行立即发出选择（使用方就地生效，场景不重载）；再点图标或点面板外收起；与场景其他输入层共存不抢事件。

## 交互演示

<div class="demo-stage" id="demo-settings" style="min-height:200px;">
      <p class="hint">点击右上角齿轮展开面板，点「白天 / 夜晚」行立即切换高亮并就地生效（演示区背景随之切换），点面板外或再点齿轮收起。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var panel := preload("res://addons/godot-element-plus/settings_panel/settings_panel.gd").new()
panel.options = [["白天", "day"], ["夜晚", "night"]]
add_child(panel)
# 点击行立即生效，使用方就地应用后回设 value
panel.option_selected.connect(func(value): panel.value = value)
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>options</code> | 行清单（每项 [标签, 值]） | <code>Array</code> | <code>[]</code> |
| <code>back_label</code> | 返回行标签（空 = 无返回行；返回行居面板首行，行下有分隔线，点击发 back_selected 并收起面板） | <code>String</code> | <code>""</code> |
| <code>left_anchor</code> | true 面板与齿轮锚定屏幕左上（左上控制排场景）；false 锚定右上（右上控制排场景） | <code>bool</code> | <code>false</code> |
| <code>value</code> | 当前选中值（行高亮 + 行尾选中点） | <code>String</code> | <code>""</code> |
| <code>switch_label</code> | 开关行标签（空 = 无开关行；开关行居选项之前，行下有分隔线） | <code>String</code> | <code>""</code> |
| <code>switch_checked</code> | 开关行当前态（与开关控件双向同步） | <code>bool</code> | <code>false</code> |
| <code>margin</code> | 齿轮中心横向点距（left_anchor=true 时距左边，false 时距右边） | <code>float</code> | <code>40.0</code> |
| <code>early_input</code> | true 在 _input 阶段处理（点面板外收起时放行事件给 GUI 控件）；false 在 _unhandled_input 阶段处理 | <code>bool</code> | <code>false</code> |
| <code>pass_through_outside</code> | 点面板外收起时是否放行本次点击。true 透传（宿主界面是明确点击目标）；false 吞掉防误触 | <code>bool</code> | <code>false</code> |
| <code>panel_width</code> | 面板宽度 | <code>float</code> | <code>148.0</code> |
| <code>row_height</code> | 行高 | <code>float</code> | <code>38.0</code> |
| <code>font_size</code> | 行字号 | <code>int</code> | <code>15</code> |
| <code>right_offset</code> | 面板右缘距窗口右边点距 | <code>float</code> | <code>20.0</code> |
| <code>right_offset_provider</code> | 动态右偏移提供者（返回 float 的 Callable，设置时覆盖 right_offset，用于打开时避让其他面板） | <code>Callable</code> | <code>空Callable</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>open_panel() / close_panel()</code> | 展开 / 收起（close_panel 供手风琴另一方调用） |
| <code>is_open() -&gt; bool</code> | 面板是否展开 |
| <code>has_switch() -&gt; bool</code> | 是否含开关行 |
| <code>count() -&gt; int</code> | 选项行数（不含开关行） |
| <code>set_switch_checked(v: bool)</code> | 程序化设置开关态（不发事件；其他入口切换后回推） |
| <code>icon_center() -&gt; Vector2</code> | 齿轮中心（视口坐标） |
| <code>row_center(row: int) -&gt; Vector2</code> | 行中心（视口坐标） |
| <code>_panel_rect() -&gt; Rect2</code> | 面板矩形（视口坐标） |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>option_selected</code> | 点击行立即发出（使用方就地生效后回设 value） | <code>value: String</code> |
| <code>back_selected</code> | 点击返回行后发出（面板收起；使用方切换场景或返回上一级） | 无 |
| <code>opened</code> | 面板展开（手风琴钩子：使用方收到后收起其他面板） | 无 |
