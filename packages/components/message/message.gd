extends Control
## 消息提示：视口顶部居中弹出
## 深色半透胶囊提示条，duration 秒后自动淡出并释放；全屏遮罩 IGNORE 不拦截
## 输入；重复调用排队显示（等前一条结束再出下一条）。
## 用法：ElementMessage.show_text(self, "已保存")

const UITheme := preload("res://addons/godot-element-plus/theme/theme.gd")

const PILL_HEIGHT := 36.0
const TOP_MARGIN := 64.0
const FADE_SEC := 0.25

static var _queue: Array = [] # 待显示的 [text, duration]
static var _showing: Control = null

var _text := ""
var _duration := 2.0
var _font: SystemFont


static func show_text(host: Node, text: String, duration := 2.0) -> void:
	# host 提供视口；提示条加入其 root，排队显示
	var viewport := host.get_viewport()
	if viewport == null:
		return
	var message: Control = load("res://addons/godot-element-plus/message/message.gd").new()
	message._text = text
	message._duration = duration
	viewport.add_child.call_deferred(message)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = UITheme.system_font()
	if _showing != null and is_instance_valid(_showing):
		_queue.append(self)
		visible = false
		return
	_showing = self
	_play()


func _play() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_SEC)
	tween.tween_interval(_duration)
	tween.tween_property(self, "modulate:a", 0.0, FADE_SEC)
	tween.tween_callback(_finish)


func _finish() -> void:
	_showing = null
	queue_free()
	# 队列里还有下一条：由其 _ready 后被释放，这里重新触发队首
	if not _queue.is_empty():
		var next: Control = _queue.pop_front()
		if is_instance_valid(next):
			next.visible = true
			next._become_active()


func _become_active() -> void:
	_showing = self
	_play()


func _draw() -> void:
	var size := get_viewport_rect().size
	var text_width := _font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	var pill_width := text_width + 40.0
	var pill := Rect2(Vector2((size.x - pill_width) * 0.5, TOP_MARGIN), Vector2(pill_width, PILL_HEIGHT))
	draw_rect(pill, UITheme.POPOUT_FILL, true)
	draw_rect(pill, UITheme.BORDER_STRONG, false, 1.0, true)
	draw_string(_font, pill.position + Vector2(20.0, PILL_HEIGHT * 0.68), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, UITheme.TEXT_MAIN)
