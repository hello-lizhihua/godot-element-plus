---
title: 消息提示 Message
---

# 消息提示 Message

extends Control，对标 el-message。静态方法入口：在 host 所在视口顶部居中弹出提示条，duration 秒后自动淡出并释放，重复调用排队显示。视觉：顶部居中深色半透圆角胶囊（白32%描边）+ 米白文字 14px；全屏遮罩 MOUSE_FILTER_IGNORE 不拦截输入。无属性、无事件。

## 交互演示

<div class="demo-stage" id="demo-message" style="min-height:150px;">
      <p class="hint">点击按钮在演示区顶部弹出提示条，2 秒后自动淡出；连续点击多条时排队依次显示。</p>
    </div>

## 用法

```gdscript
const Message := preload("res://addons/godot-element-plus/message/message.gd")
Message.show_text(self, "保存成功")
Message.show_text(self, "网络错误，请重试", 3.0)
```

## 属性

## 方法

| 方法 | 说明 |
|---|---|
| <code>show_text(host: Node, text: String, duration: float = 2.0)</code> | 在 host 所在视口顶部居中弹出提示条，duration 秒后自动淡出并释放；重复调用排队显示 |

## 事件
