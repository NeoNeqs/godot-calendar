
class_name ScheduleFetcher
extends RefCounted

#signal done()
signal success(file_path: String)
signal failed(code: int)

const file := "user://schedule.html"

func fetch() -> HTTPRequest:
	var _http := HTTPRequest.new()
	_http.request_completed.connect(func _request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
		if response_code == 200:
			success.emit(file)
		else:
			# TODO: show toast somewhere and try to extract error from body ?
			failed.emit(response_code)
	)
	_http.use_threads = true
	_http.download_file = file
	_http.ready.connect(func():
		_http.request("https://planzajec.uek.krakow.pl/index.php?typ=G&id=261451&okres=2", PackedStringArray([
			"Authorization: Basic %s" % [Marshalls.utf8_to_base64("s222074:WlxnJ94H3SmUKGLybGtn@")]
		]))
	)
	return _http
