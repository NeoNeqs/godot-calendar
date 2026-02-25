class_name DayButton
extends Button

@onready var day_name: Label = $DayName
@onready var day_number: Label = $DayNumber

var DAY_BUTTON_NORMAL_STYLEBOX: StyleBoxFlat = load("uid://1fnkwiiyvgsk")
var DAY_BUTTON_PRESSED_STYLEBOX: StyleBoxFlat = load("uid://br2le2q7ifosi")


func update(weekday: String, day: int) -> void:
	$DayName.text = weekday
	$DayNumber.text = str(day)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and not button_pressed:
			scale = Vector2(0.9, 0.9)
		else:
			scale = Vector2.ONE

func add_today_label() -> void:
	var label: Label = (load("uid://br10nre8feq3t") as PackedScene).instantiate()
	add_child(label)
	label.position = Vector2((size.x - label.size.x) / 2, -label.size.y / 2 + 5)

func get_today_label() -> TodayLabel:
	for node: Node in get_children():
		if node is TodayLabel:
			return node
	
	return null

func _toggled(p_toggled: bool) -> void:
	var today_label := get_today_label()
	
	const lighten_amount := 0.1
	if not p_toggled:
		add_theme_stylebox_override("normal", DAY_BUTTON_NORMAL_STYLEBOX)
		add_theme_stylebox_override("pressed", DAY_BUTTON_NORMAL_STYLEBOX)
		day_name.label_settings.font_color = Color.from_string("6a7282", Color.RED)
		day_number.label_settings.font_color = Color.WHITE
		(get_theme_stylebox("hover") as StyleBoxFlat).bg_color = (DAY_BUTTON_NORMAL_STYLEBOX as StyleBoxFlat).bg_color.lightened(lighten_amount)
		if today_label:
			(today_label.get_theme_stylebox("normal") as StyleBoxFlat).bg_color = (DAY_BUTTON_PRESSED_STYLEBOX as StyleBoxFlat).bg_color
			today_label.label_settings.font_color = Color.BLACK
	else:
		add_theme_stylebox_override("normal", DAY_BUTTON_PRESSED_STYLEBOX)
		add_theme_stylebox_override("pressed", DAY_BUTTON_PRESSED_STYLEBOX)
		day_name.label_settings.font_color = Color.BLACK
		day_number.label_settings.font_color = Color.BLACK
		(get_theme_stylebox("hover") as StyleBoxFlat).bg_color = (DAY_BUTTON_PRESSED_STYLEBOX as StyleBoxFlat).bg_color.lightened(lighten_amount)
		if today_label:
			(today_label.get_theme_stylebox("normal") as StyleBoxFlat).bg_color = (DAY_BUTTON_NORMAL_STYLEBOX as StyleBoxFlat).bg_color
			today_label.label_settings.font_color = Color.WHITE
	
