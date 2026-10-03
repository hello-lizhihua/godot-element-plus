---
title: 滑块 Slider
---

# 滑块 Slider

extends Control。离散步长滑块：− 圆钮 + 刻度轨道 + 拇指 + ＋ 圆钮，绘制在自身位置；点击轨道或拖动定级（四舍五入取最近级），＋/− 步进一级；触屏与鼠标统一命中，命中就地消费、未命中透传。滑块整体衬深色半透胶囊底（圆角胶囊 + 白 32% 描边），浅色背景上保持可读；＋/− 圆钮改浅色底盘 + 亮描边。

## 交互演示

<div class="demo-stage" id="demo-slider">
      <p class="hint">演示区即浅色背景：上方滑块整体衬深色半透胶囊底（圆角胶囊 + 白 32% 描边），＋/− 圆钮为浅色底盘 + 亮描边；下方为无胶囊对照。点击轨道或拖动定级，＋/− 步进一级。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var slider := preload("res://addons/godot-element-plus/slider/slider.gd").new()
add_child(slider)
slider.value_changed.connect(func(level): print("级别 ", level))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>min_value</code> | 最小级别 | <code>int</code> | <code>1</code> |
| <code>max_value</code> | 最大级别 | <code>int</code> | <code>10</code> |
| <code>step</code> | 离散步长 | <code>int</code> | <code>1</code> |
| <code>value</code> | 当前级别（程序化赋值不发事件） | <code>int</code> | <code>1</code> |
| <code>show_ticks</code> | 是否显示刻度 | <code>bool</code> | <code>true</code> |
| <code>track_width</code> | 轨道宽度 | <code>float</code> | <code>170.0</code> |
| <code>button_size</code> | ＋/− 圆钮直径 | <code>float</code> | <code>26.0</code> |
| <code>bottom_margin</code> | 轨道中心距底边 | <code>float</code> | <code>24.0</code> |
| <code>origin_x</code> | − 圆钮左缘距左边 | <code>float</code> | <code>20.0</code> |
| <code>top_y</code> | ≥0 时轨道中线取该视口 y 值（顶部按钮排布局）；-1 为底部模式（bottom_margin 生效） | <code>float</code> | <code>-1.0</code> |
| <code>right_align</code> | ≥0 时滑块右缘按该距离对齐视口右边（覆盖 origin_x，随窗口宽度自适应，使用方在窗口变化时刷新） | <code>float</code> | <code>-1.0</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_value(v: int)</code> | 程序化赋值（不发 value_changed，超出范围钳制） |
| <code>get_value() -&gt; int</code> | 当前级别 |
| <code>_track_rect() / _minus_rect() / _plus_rect() -&gt; Rect2</code> | 视口坐标命中区（截图管线与测试用） |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>value_changed</code> | 用户点击轨道、拖动或 ＋/− 步进时发出 | <code>level: int</code> |
