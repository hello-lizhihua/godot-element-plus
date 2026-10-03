---
title: 警示条 Alert
---

# 警示条 Alert

extends PanelContainer，对标 el-alert。警示信息条——着色底 + 左缘 3px 强调竖条 + 文字 + 可选右上角关闭钮；四种语义配色（info 米白 / success 翠绿 / warning 琥珀 / danger 红橙）。视觉：圆角 6、内边距左右 12 上下 8、文字 13px（info 主体米白、success 浅绿、warning 浅琥珀、danger 浅红），底色为对应语义色 12% 透明。

## 交互演示

<div class="demo-stage" id="demo-alert">
      <p class="hint">点击配色 chip 切换警示条语义（set_kind），点右上角 × 关闭（closed，面板隐藏），点「重新显示」恢复；下方为四种语义配色参考。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var alert := preload("res://addons/godot-element-plus/alert/alert.gd").new()
alert.kind = "warning"
alert.text = "网络延迟较高"
alert.closable = true
add_child(alert)
alert.closed.connect(func(): print("提示条已关闭"))
```

## 属性

| 属性 | 说明 | 类型 | 可选值 | 默认值 |
|---|---|---|---|---|
| <code>kind</code> | 语义配色 | <code>String</code> | <code>"info"</code> / <code>"success"</code> / <code>"warning"</code> / <code>"danger"</code> | <code>"info"</code> |
| <code>text</code> | 信息文字 | <code>String</code> | — | <code>""</code> |
| <code>closable</code> | 是否显示右上角关闭钮 | <code>bool</code> | — | <code>false</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_kind(kind: String)</code> | 切换配色 |
| <code>set_text(text: String)</code> | 设置文字 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>closed</code> | 点击关闭钮后发出（面板隐藏） | 无 |
