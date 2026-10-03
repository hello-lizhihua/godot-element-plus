import { defineConfig } from "vitepress"

export default defineConfig({
  lang: "zh-CN",
  title: "godot-element-plus",
  cleanUrls: true,
  description: "Godot 通用 UI 组件库，对标 Element Plus 的组件组织与文档形态",
  themeConfig: {
    siteTitle: "godot-element-plus",
    nav: [
      { text: "GitHub", link: "https://github.com/hello-lizhihua/godot-element-plus" },
    ],
    sidebar: [
    {
        "text": "基础",
        "items": [
            {
                "text": "按钮",
                "link": "/zh-CN/component/button"
            },
            {
                "text": "图标按钮",
                "link": "/zh-CN/component/icon-button"
            },
            {
                "text": "返回按钮",
                "link": "/zh-CN/component/back-button"
            },
            {
                "text": "窗口按钮",
                "link": "/zh-CN/component/window-button"
            },
            {
                "text": "输入框",
                "link": "/zh-CN/component/input"
            },
            {
                "text": "开关",
                "link": "/zh-CN/component/switch"
            }
        ]
    },
    {
        "text": "选择",
        "items": [
            {
                "text": "单选按钮组",
                "link": "/zh-CN/component/radio-group"
            },
            {
                "text": "复选按钮组",
                "link": "/zh-CN/component/checkbox-group"
            },
            {
                "text": "选择器",
                "link": "/zh-CN/component/select"
            },
            {
                "text": "滑块",
                "link": "/zh-CN/component/slider"
            }
        ]
    },
    {
        "text": "展示",
        "items": [
            {
                "text": "chip",
                "link": "/zh-CN/component/chip"
            },
            {
                "text": "chip 行",
                "link": "/zh-CN/component/chip-row"
            },
            {
                "text": "标签",
                "link": "/zh-CN/component/tag"
            },
            {
                "text": "徽章",
                "link": "/zh-CN/component/badge"
            },
            {
                "text": "卡片",
                "link": "/zh-CN/component/card"
            },
            {
                "text": "分割线",
                "link": "/zh-CN/component/divider"
            },
            {
                "text": "进度条",
                "link": "/zh-CN/component/progress"
            },
            {
                "text": "页签",
                "link": "/zh-CN/component/tabs"
            },
            {
                "text": "手风琴",
                "link": "/zh-CN/component/accordion"
            }
        ]
    },
    {
        "text": "反馈",
        "items": [
            {
                "text": "消息提示",
                "link": "/zh-CN/component/message"
            },
            {
                "text": "对话框",
                "link": "/zh-CN/component/dialog"
            },
            {
                "text": "警示条",
                "link": "/zh-CN/component/alert"
            },
            {
                "text": "悬停提示",
                "link": "/zh-CN/component/tooltip"
            },
            {
                "text": "分页",
                "link": "/zh-CN/component/pagination"
            }
        ]
    },
    {
        "text": "布局",
        "items": [
            {
                "text": "停靠面板",
                "link": "/zh-CN/component/dock-panel"
            },
            {
                "text": "设置面板",
                "link": "/zh-CN/component/settings-panel"
            },
            {
                "text": "分组列表",
                "link": "/zh-CN/component/group-list"
            }
        ]
    },
    {
        "text": "主题",
        "items": [
            {
                "text": "设计令牌",
                "link": "/zh-CN/component/theme"
            }
        ]
    }
],
  },
})
