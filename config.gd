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
	else:
		_config = Config.new()
	
	return _config

static func unload() -> void:
	_config.last_fetch_timestamp = 0
	_config.schedule = null
	save()

static func save() -> void:
	ResourceSaver.save(_config, file_path, ResourceSaver.FLAG_CHANGE_PATH | ResourceSaver.FLAG_COMPRESS)
