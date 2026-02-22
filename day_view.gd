extends Panel

const ITEM = preload("uid://epvok0frdgrm")
const DAY_BUTTON = preload("uid://dsnuxettrqksg")
@onready var day_buttons_container: HBoxContainer = $Margin/MainLayout/DayButtons/DayButtonsContainer
@onready var v_box_container: VBoxContainer = $Margin/MainLayout/Schedule/VBoxContainer

func _ready() -> void:
	var config := Config.load_config()
	
	var diff := Time.get_ticks_msec() - config.last_fetch_timestamp

	if config.schedule == null or diff > config.cache_retention_ms:
		var schedule := ScheduleFetcher.new()
		schedule.done.connect(func(file_path: String) -> void:
			var parser := ScheduleParser.new()
			config.schedule = parser.parse(file_path)
			config.last_fetch_timestamp = Time.get_ticks_msec()
			Config.save()
			update()
		)
		add_child(schedule.fetch())
	else:
		update()

func update() -> void:
	var config := Config.load_config()
	var today: String = Time.get_date_string_from_system()

	for date: String in config.schedule.items:
		var node: DayButton = DAY_BUTTON.instantiate()
		day_buttons_container.add_child(node)
		node.toggled.connect(func(toggled_on: bool) -> void:
			if toggled_on:
				update_items(date)
		)
		
		if date == today:
			node.set_pressed(true)
		
		for sch_item: ScheduleItem in config.schedule.items[date]:
			node.update(sch_item.weekday, sch_item.day)
	
	

func update_items(date: String) -> void:
	var config := Config.load_config()
	
	for node: Node in v_box_container.get_children():
		if node is Item:
			v_box_container.remove_child(node)
			node.queue_free()
	
	for sch_item: ScheduleItem in config.schedule.items[date]:
		var item: Item = ITEM.instantiate()
		item.update_deferred(sch_item)
		v_box_container.add_child(item)
