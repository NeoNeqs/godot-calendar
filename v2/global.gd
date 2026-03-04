class_name Global
extends Node

static var weekdays: Array[String] = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
static var weekdays_long: Array[String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
static var months: Array[String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

static func show_toast(msg: String) -> void:
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


static func humanize_day(datetime: Dictionary) -> String:
	return weekdays[int(datetime.weekday) - 1] + '\n' + str(datetime.day)

static func humanize_date(datetime: Dictionary) -> String:
	return weekdays_long[datetime.weekday - 1] + ", " + months[datetime.month - 1] + " " + str(datetime.day)
