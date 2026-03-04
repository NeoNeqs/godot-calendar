extends VBoxContainer

@onready var trains: Button = $MarginContainer/VBoxContainer/HBoxContainer/Trains
@onready var reload: Button = $MarginContainer/VBoxContainer/HBoxContainer/Reload
@onready var day_buttons_container: HBoxContainer = $MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/DayButtonsContainer
@onready var label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var prevoius_day_view_container: VBoxContainer = $MainView/ScrollContainer/HBoxContainer/PrevoiusDayView/PrevoiusDayViewContainer
@onready var current_day_view_container: VBoxContainer = $MainView/ScrollContainer/HBoxContainer/CurrentDayView/CurrentDayViewContainer
@onready var next_day_view_container: VBoxContainer = $MainView/ScrollContainer/HBoxContainer/NextDayView/NextDayViewContainer
@onready var main_view: PanelContainer = $MainView
@onready var h_box_container: HBoxContainer = $MainView/ScrollContainer/HBoxContainer
@onready var scroll_container: ScrollContainer = $MainView/ScrollContainer

var config := Config.load_config()
var selected_date: String
var selected_date_index: int = 0

const weekdays := ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
const weekdays_long := ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
const months := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
const MAX_DAY_BUTTONS_ON_SCREEN: int = 5

static var ITEM: PackedScene = load("uid://dr4yqve67a4pf")

static var DAY_BUTTON: PackedScene = load("uid://jia2fv56h6tv")


func _ready() -> void:
	reload.pressed.connect(func():
		Config.unload()
		# clear
		_load()
	)
	_load()
	main_view.snapped.connect(func(dir: int) -> void:
		if dir == -1:
			for node: Node in next_day_view_container.get_children():
				node.queue_free()
				next_day_view_container.remove_child(node)
			
			for schedule_item: ScheduleItem in config.schedule.items[config.schedule.items.keys()[selected_date_index]]:
				var item := ITEM.instantiate()
				item.update(schedule_item)
				next_day_view_container.add_child(item)
			
			await main_view.snap_ended
			
			selected_date_index -= 1
			(day_buttons_container.get_child(selected_date_index) as Button).set_pressed(true)
			selected_date = config.schedule.items.keys()[selected_date_index]
			#for node: Node in current_day_view_container.get_children():
				#node.queue_free()
				#current_day_view_container.remove_child(node)
			#
			#for schedule_item: ScheduleItem in config.schedule.items[config.schedule.items.keys()[selected_date_index - 1]]:
				#var item := ITEM.instantiate()
				#item.update(schedule_item)
				#current_day_view_container.add_child(item)
			
			update_scroll_container()
			
			#
			#(day_buttons_container.get_child(selected_date_index) as Button).set_pressed_no_signal(true)
			#var datetime: Dictionary = Time.get_datetime_dict_from_datetime_string(selected_date, true)
			#label.text = "%s, %s %d" % [weekdays_long[datetime.weekday - 1], months[datetime.month - 1], datetime.day]
			
			for node: Node in prevoius_day_view_container.get_children():
				node.queue_free()
				prevoius_day_view_container.remove_child(node)
			
			for schedule_item: ScheduleItem in config.schedule.items[config.schedule.items.keys()[selected_date_index - 1]]:
				var item := ITEM.instantiate()
				item.update(schedule_item)
				prevoius_day_view_container.add_child(item)
		elif dir == 1:
			for node: Node in prevoius_day_view_container.get_children():
				node.queue_free()
				prevoius_day_view_container.remove_child(node)
			
			for schedule_item: ScheduleItem in config.schedule.items[config.schedule.items.keys()[selected_date_index]]:
				var item := ITEM.instantiate()
				item.update(schedule_item)
				prevoius_day_view_container.add_child(item)
			
			await main_view.snap_ended
			
			print(selected_date_index)
			(day_buttons_container.get_child(selected_date_index + 1) as Button).set_pressed(true)
			selected_date = config.schedule.items.keys()[selected_date_index]
			selected_date_index += 1
			#for node: Node in current_day_view_container.get_children():
				#node.queue_free()
				#current_day_view_container.remove_child(node)
			#
			#for schedule_item: ScheduleItem in config.schedule.items[config.schedule.items.keys()[selected_date_index + 1]]:
				#var item := ITEM.instantiate()
				#item.update(schedule_item)
				#current_day_view_container.add_child(item)
			
			update_scroll_container()
			
			#
			#(day_buttons_container.get_child(selected_date_index) as Button).set_pressed_no_signal(true)
			#var datetime: Dictionary = Time.get_datetime_dict_from_datetime_string(selected_date, true)
			#label.text = "%s, %s %d" % [weekdays_long[datetime.weekday - 1], months[datetime.month - 1], datetime.day]
			
			for node: Node in next_day_view_container.get_children():
				node.queue_free()
				next_day_view_container.remove_child(node)
			
			for schedule_item: ScheduleItem in config.schedule.items[config.schedule.items.keys()[selected_date_index + 1]]:
				var item := ITEM.instantiate()
				item.update(schedule_item)
				next_day_view_container.add_child(item)
	)
	scroll_container.resized.connect(update_scroll_container)

func update_scroll_container() -> void:
	h_box_container.custom_minimum_size.x = 3 * scroll_container.size.x
	scroll_container.set_h_scroll(int(scroll_container.size.x))


func _on_day_buttons_parent_resized() -> void:
	var parent_size: Vector2 = get_parent_area_size()
	if parent_size.x > 0:
		var space_between: int = day_buttons_container.get_theme_constant("separation")
		for node: Node in day_buttons_container.get_children():
			(node as Control).custom_minimum_size.x = (parent_size.x - (MAX_DAY_BUTTONS_ON_SCREEN - 1) * space_between) / MAX_DAY_BUTTONS_ON_SCREEN
		day_buttons_container.get_parent_control().resized.disconnect(_on_day_buttons_parent_resized)
		

func _load() -> void:
	var ms_since_last_fetch: int = Time.get_ticks_msec() - config.last_fetch_timestamp
	
	if not config.schedule == null and ms_since_last_fetch <= config.cache_retention_ms:
		show_toast("Loading cached schedule...")
		update()
		return
	
	show_toast("Fetching fresh schedule...")
	
	reload.disabled = true
	
	var schedule := ScheduleFetcher.new()
	add_child(schedule.fetch())
	
	schedule.success.connect(func on_schedule_fetch_success(file_path: String) -> void:
		config.schedule = ScheduleParser.new().parse(file_path)
		config.last_fetch_timestamp = Time.get_ticks_msec()
		Config.save()
		
		update()
		show_toast("Fetching done")
		
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ScheduleFetcher.file))
		reload.disabled = false
	)
	
	schedule.failed.connect(func on_schedule_fetch_failed(code: int) -> void:
		show_toast("Fetching failed, error code: %s" % [code])
		update()
		reload.disabled = false
	)


func update() -> void:
	const MAX_BUTTONS_ON_SCREEN := 5
	var found_today := false
	
	var params: Array[Variant] = [null, null, null, null]
	var today: String = Time.get_date_string_from_system()
	#today = "2026-03-07"
	
	var parent_size: Vector2 = day_buttons_container.get_parent_area_size()
	var space_between: int = day_buttons_container.get_theme_constant("separation")
	# if we don't wait the size is (0, 0) ...
	# There isn't a better way to do this and I will die on that hill.
	while parent_size.x <= 0:
		parent_size = day_buttons_container.get_parent_area_size()
		await get_tree().process_frame
	
	for node: Node in day_buttons_container.get_children():
		node.queue_free()
		day_buttons_container.remove_child(node)
	
	var date_index := 0
	for date: String in config.schedule.items:
		var node: Button = DAY_BUTTON.instantiate()
		day_buttons_container.add_child(node)
		var datetime: Dictionary = Time.get_datetime_dict_from_datetime_string(date, true)
		node.text = "%s\n%s" % [weekdays[datetime.weekday - 1], datetime.day]
		node.custom_minimum_size.x = (parent_size.x - (MAX_BUTTONS_ON_SCREEN - 1) * space_between) / MAX_BUTTONS_ON_SCREEN
		node.toggled.connect(func on_day_button_toggled(state: bool) -> void:
			if not state: return
			label.text = "%s, %s %d" % [weekdays_long[datetime.weekday - 1], months[datetime.month - 1], datetime.day]
			for old_node: Node in current_day_view_container.get_children():
				old_node.queue_free()
				current_day_view_container.remove_child(old_node)
		
			for schedule_item: ScheduleItem in config.schedule.items[date]:
				var item := ITEM.instantiate()
				item.update(schedule_item)
				current_day_view_container.add_child(item)
			selected_date = date
			selected_date_index = date_index
		)
		
		if not found_today:
			if date < today:
				params[0] = node
				params[1] = datetime.weekday
				params[2] = datetime.month
				params[3] = datetime.day
				selected_date = date
				selected_date_index = date_index
				date_index += 1
			elif date == today:
				found_today = true
				selected_date = date
				selected_date_index = date_index
				params[0] = node
				params[1] = datetime.weekday
				params[2] = datetime.month
				params[3] = datetime.day
	label.text = "%s, %s %d" % [weekdays_long[params[1] - 1], months[params[2] - 1], params[3]]
	
	if found_today:
		var normal_stylebox := params[0].get_theme_stylebox("normal") as StyleBoxFlat
		normal_stylebox.set_border_width_all(4)
		normal_stylebox.border_color = Color("2b6cee")
		params[0].add_theme_stylebox_override("hover", normal_stylebox)
		
	params[0].set_pressed(true)
	# There isn't a better way to do this and I will die on that hill.
	for i: int in 2:
		await get_tree().process_frame
	(day_buttons_container.get_parent_control() as ScrollContainer).scroll_horizontal = (params[0].get_index() - params[1] + 1) * (params[0].custom_minimum_size.x + day_buttons_container.get_theme_constant("separation"))

	for schedule_item: ScheduleItem in config.schedule.items[config.schedule.items.keys()[date_index - 1]]:
		var item := ITEM.instantiate()
		item.update(schedule_item)
		prevoius_day_view_container.add_child(item)

	for schedule_item: ScheduleItem in config.schedule.items[config.schedule.items.keys()[date_index]]:
		var item := ITEM.instantiate()
		item.update(schedule_item)
		current_day_view_container.add_child(item)
	
	for schedule_item: ScheduleItem in config.schedule.items[config.schedule.items.keys()[date_index + 1]]:
		var item := ITEM.instantiate()
		item.update(schedule_item)
		next_day_view_container.add_child(item)

func show_toast(msg: String) -> void:
	if OS.has_feature("android"):
		var android_runtime = Engine.get_singleton("AndroidRuntime")
		if android_runtime:
			var activity = android_runtime.getActivity()
			
			var toastCallable = func():
				var ToastClass = JavaClassWrapper.wrap("android.widget.Toast")
				ToastClass.makeText(activity, msg, 1).show()
				
			activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(toastCallable))
		else:
			printerr("Unable to access android runtime")
	print(msg)
