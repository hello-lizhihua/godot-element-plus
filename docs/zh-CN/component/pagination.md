---
title: 分页 Pagination
---

# 分页 Pagination

extends HBoxContainer，对标 el-pagination。分页器——‹ 上一页 + 页码 chips（页多时首尾保留、中间省略号）+ › 下一页；当前页琥珀高亮。

## 交互演示

<div class="demo-stage" id="demo-pagination">
      <p class="hint">12 页示例：点击页码或 ‹/› 切换，当前页琥珀高亮，首尾页码保留、中间以省略号折叠；下方实时打印 page_changed 事件。</p>
      <div class="demo-console"></div>
    </div>

## 用法

```gdscript
var pagination := preload("res://addons/godot-element-plus/pagination/pagination.gd").new()
pagination.set_total(12)
add_child(pagination)
pagination.page_changed.connect(func(page): print("跳到第 ", page, " 页"))
```

## 属性

| 属性 | 说明 | 类型 | 可选值 | 默认值 |
|---|---|---|---|---|
| <code>total_pages</code> | 总页数 | <code>int</code> | — | <code>1</code> |
| <code>current</code> | 当前页（程序化赋值不发事件，超范围钳制） | <code>int</code> | — | <code>1</code> |

## 方法

| 方法 | 说明 |
|---|---|
| <code>set_total(pages: int)</code> | 设置总页数并重排页码 |
| <code>set_current(page: int)</code> | 程序化跳页（不发事件） |
| <code>current_page() -&gt; int</code> | 当前页 |

## 事件

| 事件名 | 说明 | 回调参数 |
|---|---|---|
| <code>page_changed</code> | 点击页码或 ‹/› 切换后发出 | <code>page: int</code> |
