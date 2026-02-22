class_name Item
extends PanelContainer

@onready var lecture_name: Label = $VBoxContainer/Row1/LectureName
@onready var timestamp: Label = $VBoxContainer/Row1/Timestamp
@onready var lecturers_name: Label = $VBoxContainer/Row2/LecturersName
@onready var relative_time: Label = $VBoxContainer/Row2/RelativeTime
@onready var location: Label = $VBoxContainer/Row3/Location
@onready var info: Label = $VBoxContainer/Row3/Info

func _draw() -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = Color.WHITE
	s.corner_detail = 20
	s.set_corner_radius_all(45)
	draw_style_box(s, Rect2(50, -25, 150, 50))
	draw_string(get_window().get_theme_default_font(), Vector2(85, -25 + 35), "NOW", HORIZONTAL_ALIGNMENT_CENTER,-1,30, Color.BLACK)


func update_deferred(item: ScheduleItem) -> void:
	update.call_deferred(item)

func update(item: ScheduleItem) -> void:
	lecturers_name.text = item.lecturer
	timestamp.text = item.timeframe
	lecture_name.text = item.name
	relative_time.hide()
	location.text = "%s, %s" % [item.type, item.room]
	if item.info.strip_edges().length() > 0:
		info.text = item.info
	else:
		info.hide()
	
	
