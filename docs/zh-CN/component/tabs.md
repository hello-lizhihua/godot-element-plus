---
title: 页签 Tabs
---

# 页签 Tabs

extends Control，对标 el-tabs。顶部页签条（32px，页签文字 14px：激活米白字+底部 2px 琥珀下划线、未激活弱化色）+ 下方内容区（仅当前页签可见）。

## 交互演示

<div class="demo-stage" id="demo-tabs">
      <p class="hint">点击页签切换内容区，激活页签米白字 + 底部琥珀下划线；下方实时打印 tab_changed 事件。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var tabs := preload("res://addons/godot-element-plus/tabs/tabs.gd").new()
tabs.add_tab("总览")
tabs.add_tab("成员")
add_child(tabs)
tabs.tab_changed.connect(func(index): print("页签 ", index))
```

## 属性

| 属性 | 说明 | 类型 | 默认值 |
|---|---|---|---|
| <code>active_index</code> | 当前页签 | <code>int</code> | <code>0</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>add_tab(title: String) -&gt; int</code> | 追加页签返回序号 |
| <code>set_active(index: int)</code> | 程序化赋值不发事件 |
| <code>active() -&gt; int</code> | 当前页签序号 |
| <code>tab_content(index: int) -&gt; VBoxContainer</code> | 页签内容容器 |
| <code>count() -&gt; int</code> | 页签总数 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>tab_changed</code> | 点击切换后发出 | <code>index: int</code> |
