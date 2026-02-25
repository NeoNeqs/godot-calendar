class_name Item
extends PanelContainer

@onready var lecture_name: Label = $VBoxContainer/Row1/LectureName
@onready var timestamp: Label = $VBoxContainer/Row1/Timestamp
@onready var location: Label = $VBoxContainer/Row2/Location
@onready var relative_time: Label = $VBoxContainer/Row2/RelativeTime
@onready var type_and_lecurer: Label = $VBoxContainer/Row3/HBoxContainer/TypeAndLecurer

var _info: String = ""

func _draw() -> void:
	if _info.strip_edges().length() <= 0:
		return
	
	const x_offset: float = 85.0
	const x_margin: float = 20.0
	const font_size: int = 30
	
	var font := get_window().get_theme_default_font()
	var size_ := font.get_string_size(_info, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	size_.x += x_margin * 2
	
	var s := StyleBoxFlat.new()
	s.bg_color = Color.CRIMSON
	s.corner_detail = 20
	s.set_corner_radius_all(20)
	
	draw_style_box(s, Rect2(Vector2(x_offset - x_margin, -size_.y / 2), size_))
	draw_string(font, Vector2(x_offset, size_.y / 2 - 10), _info, HORIZONTAL_ALIGNMENT_CENTER,-1, font_size, Color.BLACK)


func update_deferred(item: ScheduleItem) -> void:
	update.call_deferred(item)

func update(item: ScheduleItem) -> void:
	type_and_lecurer.text = item.type
	
	if not item.lecturer.strip_edges().is_empty():
		type_and_lecurer.text += " • %s" % [item.lecturer]
	
	timestamp.text = item.timeframe

	if item.name.strip_edges().is_empty():
		lecture_name.text = item.info
		location.text = item.info
	else:
		_info = item.info
		lecture_name.text = item.name
		location.text = item.room
