extends MarginContainer

@onready var day_buttons_container: HBoxContainer = $MainLayout/DayButtons/DayButtonsContainer
@onready var v_box_container: VBoxContainer = $MainLayout/PanelContainer/Schedule/VBoxContainer
@onready var reload: Button = $MainLayout/Header/HBoxContainer/Reload
@onready var day_buttons: ScrollContainer = $MainLayout/DayButtons
@onready var schedule: ScrollContainer = $MainLayout/PanelContainer/Schedule
@onready var label_2: Label = $MainLayout/Header/Label2

var ITEM = load("uid://epvok0frdgrm")
var DAY_BUTTON = load("uid://dsnuxettrqksg")

var can_swipe := true

func _ready() -> void:
	reload.pressed.connect(func():
		Config.unload()
		_load()
	)
	_load()
	
	SignalBus.swiped.connect(func(dir: float) -> void:
		if not can_swipe:
			return
	
		var i := (day_buttons_container.get_child(0) as Button).button_group.get_pressed_button().get_index()
		if abs(dir) >= 250.0 and i - sign(dir) >= 0 and i - sign(dir) < day_buttons_container.get_child_count():
			day_buttons_container.get_child(i - sign(dir)).set_pressed(true)
			can_swipe = false
	)
	
	SignalBus.swipe_stopped.connect(func(): can_swipe = true)

#func _gui_input(event: InputEvent) -> void:
	#print(event)

func _load() -> void:
	reload.disabled = true
	var config := Config.load_config()
	
	var diff := Time.get_ticks_msec() - config.last_fetch_timestamp

	if config.schedule == null or diff > config.cache_retention_ms:
		print("Fetching...")
		var schedule := ScheduleFetcher.new()
		schedule.done.connect(func(file_path: String) -> void:
			var parser := ScheduleParser.new()
			config.schedule = parser.parse(file_path)
			config.last_fetch_timestamp = Time.get_ticks_msec()
			DirAccess.remove_absolute(ProjectSettings.globalize_path(ScheduleFetcher.file))
			Config.save()
			update()
			print("Done")
		)
		add_child(schedule.fetch())
	else:
		print("Loading...")
		update()

func update() -> void:
	reload.disabled = false
	var config := Config.load_config()
	var today: String = Time.get_date_string_from_system()

	for date: String in config.schedule.items:
		var node: DayButton = DAY_BUTTON.instantiate()
		day_buttons_container.add_child(node)
		node.toggled.connect(func(toggled_on: bool) -> void:
			if toggled_on:
				update_items(date)
				if node.global_position.x >= 5 * day_buttons_container.get_theme_constant("separation") + 4 * node.size.x:
					day_buttons.scroll_horizontal += (day_buttons_container.get_theme_constant("separation") + int(node.size.x))
				elif node.global_position.x <= day_buttons_container.get_theme_constant("separation") + node.size.x:
					day_buttons.scroll_horizontal -= (day_buttons_container.get_theme_constant("separation") + int(node.size.x))
				
				var item: ScheduleItem = config.schedule.items[date][0]
				label_2.text = "%s, %02d %s %d" % [
					item.weekday, item.day, ["Styczeń", "Luty", "Marzec", "Kwiecień", "Maj", "Czerwiec", "Lipiec", "Sierpień", "Wrzesień", "Październik", "Listopad", "Grudzień"][item.month - 1], item.year
				]
		)
		
		if date == today:
			node.set_pressed(true)
		
		for sch_item: ScheduleItem in config.schedule.items[date]:
			node.update(sch_item.weekday, sch_item.day)
	
	

func update_items(date: String) -> void:
	var config := Config.load_config()
	
	for node: Node in v_box_container.get_children():
		if node is Item:
			node.queue_free()
	
	for sch_item: ScheduleItem in config.schedule.items[date]:
		var item: Item = ITEM.instantiate()
		v_box_container.add_child(item)
		item.update_deferred(sch_item)
