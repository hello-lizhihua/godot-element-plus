extends Object
class_name ElementTheme
## godot-element-plus 设计令牌：全部界面共用的色板、间距、圆角、字号与字体栈。
## 深色半透面板 + #f0ede6 米白文字 + #ffcc33 琥珀强调；常量以 rgba 注释对齐设计值。
## 组件脚本内部经 const UITheme := preload(...) 引用，不依赖全局类缓存。

# ── 色板 ─────────────────────────────────────────────────────────

## 圆形底盘与图标按钮底色
const CHASSIS_FILL := Color(0.078, 0.086, 0.11, 0.62) # rgba(20,22,28,0.62)
## 弹出面板底色（设置面板）
const POPOUT_FILL := Color(0.078, 0.086, 0.11, 0.78) # rgba(20,22,28,0.78)
## 停靠面板底色
const DOCK_FILL := Color(13.0 / 255.0, 15.0 / 255.0, 20.0 / 255.0, 0.82) # rgba(13,15,20,0.82)
## 底盘描边
const BORDER := Color(1.0, 1.0, 1.0, 0.20)
## 底盘与弹出面板描边
const BORDER_STRONG := Color(1.0, 1.0, 1.0, 0.32)
## 停靠面板左缘分隔线
const BORDER_SOFT := Color(1.0, 1.0, 1.0, 0.14)
## 滑块拇指描边
const BORDER_ACTIVE := Color(1.0, 1.0, 1.0, 0.50)
## 行与筛选项默认底
const ROW_IDLE := Color(1.0, 1.0, 1.0, 0.06)
## 行悬停底
const ROW_HOVER := Color(1.0, 1.0, 1.0, 0.10)
## 行选中底
const ROW_ACTIVE := Color(1.0, 1.0, 1.0, 0.22)
## 主文字
const TEXT_MAIN := Color(0.941, 0.929, 0.902) # #f0ede6
## 次文字
const TEXT_DIM := Color(0.941, 0.929, 0.902, 0.72)
## 弱文字
const TEXT_FAINT := Color(0.941, 0.929, 0.902, 0.55)
## 琥珀强调色
const ACCENT := Color(1.0, 0.8, 0.2) # #ffcc33
## 琥珀选中底
const ACCENT_WASH := Color(1.0, 0.8, 0.2, 0.30)
## 提示小字主体（浅色背景上可读）
const HINT_COLOR := Color(0.16, 0.17, 0.20, 0.82) # rgba(41,43,51,0.82)
## 提示小字描影
const HINT_HALO := Color(1.0, 1.0, 1.0, 0.55)

# ── 间距（点，1600×900 设计分辨率）────────────────────────────────

const GAP_XS := 4.0
const GAP_S := 6.0
const GAP_M := 8.0
const GAP_L := 12.0
const PAD_M := 14.0
const PAD_L := 20.0
const EDGE_L := 24.0

# ── 圆角 ─────────────────────────────────────────────────────────

## chip 圆角
const CORNER_S := 6.0
## 卡片圆角
const CORNER_L := 14.0

# ── 字号 ─────────────────────────────────────────────────────────

const FONT_XS := 12
const FONT_S := 13
const FONT_M := 15
const FONT_L := 16
const FONT_XL := 18
const FONT_H2 := 26
const FONT_H1 := 46

# ── 字体栈 ────────────────────────────────────────────────────────

const FONT_STACK: Array[String] = ["PingFang SC", "Hiragino Sans GB", "STHeiti", "Arial Unicode MS"]


## 按字体栈新建系统字体（每界面一份，控件间共享引用）
static func system_font() -> SystemFont:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(FONT_STACK)
	return font


## 构建 chip 样式：圆角 6、左右边距 10、上下边距 3；bordered 时 1px 琥珀描边
static func chip_style(bg: Color, bordered: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(CORNER_S)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	if bordered:
		style.border_color = ACCENT
		style.set_border_width_all(1.0)
	return style
