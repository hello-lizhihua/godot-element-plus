---
title: 设计令牌 Theme
---

# 设计令牌 Theme

静态类（class_name Theme），全部界面共用的色板、间距、圆角、字号、字体栈。

## 交互演示

<div class="demo-stage">
      <p class="hint">色卡左半为深色底上的观感、右半为浅色底上的观感；间距标尺按 6 倍放大展示。</p>
      <div class="demo-label">色板（深浅双底对照）</div>
      <div class="swatch-grid" id="theme-swatches"></div>
      <div class="demo-label" style="margin-top:22px;">间距标尺</div>
      <div id="theme-ruler"></div>
      <div class="demo-label" style="margin-top:22px;">圆角</div>
      <div class="radius-row">
        <div class="radius-box" style="border-radius:6px;">CORNER_S = 6</div>
        <div class="radius-box" style="border-radius:14px;">CORNER_L = 14</div>
      </div>
      <div class="demo-label" style="margin-top:22px;">字号标尺</div>
      <div class="font-scale-row"><span class="font-scale-label">FONT_XS = 12</span><span class="font-scale-sample" style="font-size:12px;">  123</span></div>
      <div class="font-scale-row"><span class="font-scale-label">FONT_S = 13（chip）</span><span class="font-scale-sample" style="font-size:13px;">  123</span></div>
      <div class="font-scale-row"><span class="font-scale-label">FONT_M = 15</span><span class="font-scale-sample" style="font-size:15px;">  123</span></div>
      <div class="font-scale-row"><span class="font-scale-label">FONT_L = 16（面板行）</span><span class="font-scale-sample" style="font-size:16px;">  123</span></div>
      <div class="font-scale-row"><span class="font-scale-label">FONT_XL = 18</span><span class="font-scale-sample" style="font-size:18px;">  123</span></div>
      <div class="font-scale-row"><span class="font-scale-label">FONT_H2 = 26</span><span class="font-scale-sample" style="font-size:26px;">  123</span></div>
      <div class="font-scale-row"><span class="font-scale-label">FONT_H1 = 46</span><span class="font-scale-sample" style="font-size:46px;">  123</span></div>
      <div class="demo-label" style="margin-top:22px;">字体栈</div>
      <div class="font-stack-sample">PingFang SC → Hiragino Sans GB → STHeiti → Arial Unicode MS</div>
    </div>

## 用法

```gdscript
# 任意组件内取用设计令牌，禁止在组件内硬编码颜色
label.add_theme_color_override("font_color", Theme.TEXT_MAIN)
var font := Theme.system_font()
var style := Theme.chip_style(Theme.ROW_IDLE, false)
```

## 色板

| 属性 | 说明 | 类型 | 值 |
|---|---|---|---|
| <code>CHASSIS_FILL</code> | 圆形底盘与图标按钮底色 | <code>Color</code> | <code>rgba(20,22,28,0.62)</code> |
| <code>POPOUT_FILL</code> | 弹出面板底色 | <code>Color</code> | <code>rgba(20,22,28,0.78)</code> |
| <code>DOCK_FILL</code> | 停靠面板底色 | <code>Color</code> | <code>rgba(13,15,20,0.82)</code> |
| <code>BORDER</code> | 底盘描边 | <code>Color</code> | <code>rgba(255,255,255,0.20)</code> |
| <code>BORDER_STRONG</code> | 底盘与弹出面板描边 | <code>Color</code> | <code>rgba(255,255,255,0.32)</code> |
| <code>BORDER_SOFT</code> | 停靠面板左缘分隔线 | <code>Color</code> | <code>rgba(255,255,255,0.14)</code> |
| <code>BORDER_ACTIVE</code> | 滑块拇指描边 | <code>Color</code> | <code>rgba(255,255,255,0.50)</code> |
| <code>ROW_IDLE</code> | 行/筛选项默认底 | <code>Color</code> | <code>rgba(255,255,255,0.06)</code> |
| <code>ROW_HOVER</code> | 行悬停底 | <code>Color</code> | <code>rgba(255,255,255,0.10)</code> |
| <code>ROW_ACTIVE</code> | 行选中底 | <code>Color</code> | <code>rgba(255,255,255,0.22)</code> |
| <code>TEXT_MAIN</code> | 主文字 | <code>Color</code> | <code>#f0ede6</code> |
| <code>TEXT_DIM</code> | 次文字（72% 不透明） | <code>Color</code> | <code>rgba(240,237,230,0.72)</code> |
| <code>TEXT_FAINT</code> | 弱文字（55% 不透明） | <code>Color</code> | <code>rgba(240,237,230,0.55)</code> |
| <code>ACCENT</code> | 琥珀强调色 | <code>Color</code> | <code>#ffcc33</code> |
| <code>ACCENT_WASH</code> | 琥珀选中底（30% 不透明） | <code>Color</code> | <code>rgba(255,204,51,0.30)</code> |
| <code>HINT_COLOR</code> | 提示小字主体（浅背景可读） | <code>Color</code> | <code>rgba(41,43,51,0.82)</code> |
| <code>HINT_HALO</code> | 提示小字描影 | <code>Color</code> | <code>rgba(255,255,255,0.55)</code> |

## 间距与圆角

| 属性 | 说明 | 类型 | 值 |
|---|---|---|---|
| <code>GAP_XS</code> | 超小间距 | <code>int</code> | <code>4</code> |
| <code>GAP_S</code> | 小间距（chip 横向间距） | <code>int</code> | <code>6</code> |
| <code>GAP_M</code> | 中间距 | <code>int</code> | <code>8</code> |
| <code>GAP_L</code> | 大间距 | <code>int</code> | <code>12</code> |
| <code>PAD_M</code> | 中内边距（面板内边距） | <code>int</code> | <code>14</code> |
| <code>PAD_L</code> | 大内边距 | <code>int</code> | <code>20</code> |
| <code>EDGE_L</code> | 屏幕边缘间距 | <code>int</code> | <code>24</code> |
| <code>CORNER_S</code> | 小圆角（chip 圆角） | <code>int</code> | <code>6</code> |
| <code>CORNER_L</code> | 大圆角（卡片圆角） | <code>int</code> | <code>14</code> |

## 字号与字体

| 属性 | 说明 | 类型 | 值 |
|---|---|---|---|
| <code>FONT_XS</code> | 超小字号 | <code>int</code> | <code>12</code> |
| <code>FONT_S</code> | 小字号（chip） | <code>int</code> | <code>13</code> |
| <code>FONT_M</code> | 中字号 | <code>int</code> | <code>15</code> |
| <code>FONT_L</code> | 大字号（面板行） | <code>int</code> | <code>16</code> |
| <code>FONT_XL</code> | 特大字号 | <code>int</code> | <code>18</code> |
| <code>FONT_H2</code> | 二级标题字号 | <code>int</code> | <code>26</code> |
| <code>FONT_H1</code> | 一级标题字号 | <code>int</code> | <code>46</code> |
| <code>FONT_STACK</code> | 字体栈 | <code>Array</code> | <code>PingFang SC → Hiragino Sans GB → STHeiti → Arial Unicode MS</code> |

## 方法

| 方法 | 说明 | 返回 |
|---|---|---|
| <code>system_font()</code> | 按字体栈新建 SystemFont | <code>SystemFont</code> |
| <code>chip_style(bg: Color, bordered: bool)</code> | 构建 chip 样式（圆角 6、左右边距 10、上下边距 3；bordered 时 1px 琥珀描边） | <code>StyleBoxFlat</code> |
