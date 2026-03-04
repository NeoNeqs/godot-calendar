class_name Config
extends Resource

@export var last_fetch_timestamp: int
@export var cache_retention_ms: int = 7_200_000
@export var schedule: Schedule

const file_path: String = "user://config.tres"

static var _config: Config = null

static func load_config() -> Config:
	if _config:
		return _config
	
	if FileAccess.file_exists(file_path):
		_config = ResourceLoader.load(file_path, "Config")
		if _config == null:
			Global.show_toast("Failed to load config.")
	else:
		_config = Config.new()
	
	return _config

func _should_fetch_new_data() -> bool:
	var ms_since_last_fetch: int = Time.get_ticks_msec() - _config.last_fetch_timestamp
	
	return _config.schedule == null or ms_since_last_fetch > _config.cache_retention_ms

func load_schedule() -> ScheduleFetcher:
	if not _config._should_fetch_new_data():
		Global.show_toast("Loading cached schedule...")
		return null

	Global.show_toast("Fetching fresh schedule...")
	
	var schedule_fetcher := ScheduleFetcher.new()
	
	schedule_fetcher.success.connect(func on_schedule_fetch_success(saved_file_path: String) -> void:
		_config.schedule = ScheduleParser.new().parse(saved_file_path)
		_config.last_fetch_timestamp = Time.get_ticks_msec()
		Config.save()
		
		Global.show_toast("Fetching done")
		
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ScheduleFetcher.file))
		#reload_button.disabled = false
	)
	
	schedule_fetcher.failed.connect(func on_schedule_fetch_failed(code: int) -> void:
		Global.show_toast("Fetching failed, error code: %s" % [code])
		#reload_button.disabled = false
	)
	
	return schedule_fetcher


static func unload() -> void:
	_config.last_fetch_timestamp = 0
	_config.schedule = null
	save()

static func save() -> void:
	ResourceSaver.save(_config, file_path, ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_COMPRESS)
