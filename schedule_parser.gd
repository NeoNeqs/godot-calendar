class_name ScheduleParser
extends RefCounted

var table_regex := RegEx.new()
var row_regex := RegEx.new()
var cell_regex := RegEx.new()
var strip_tags_regex := RegEx.new()
var time_regex := RegEx.new()

func _init() -> void:
	table_regex.compile("<table.*?>([\\s\\S]*?)</table>")
	row_regex.compile("<tr.*?>([\\s\\S]*?)</tr>")
	cell_regex.compile("<t[dh].*?>([\\s\\S]*?)</t[dh]>")
	strip_tags_regex.compile("<[^>]*>")
	time_regex.compile("(..)\\s(\\d\\d:\\d\\d\\s-\\s\\d\\d:\\d\\d)\\s")

func parse(file_path: String) -> Schedule:
	var sch := Schedule.new()
	
	var html := FileAccess.get_file_as_string(file_path)

	var table_match = table_regex.search(html)
	if table_match:
		var table_content = table_match.get_string(1)
		var previous_row_data: ScheduleItem = null

		for row_match in row_regex.search_all(table_content):
			var row := []
			for cell_match in cell_regex.search_all(row_match.get_string(1)):
				var cell_text := cell_match.get_string(1)
				# Strip HTML tags and trim
				cell_text = strip_tags_regex.sub(cell_text, "", true).strip_edges()
				row.append(cell_text)

			# Handle single-element rows
			if row.size() == 1 and previous_row_data:
				# Store as additional info
				previous_row_data["info"] = row[0]
			else:
				var schedule_item := ScheduleItem.new()
				
				var time: String = row[1] if row.size() > 1 else ""
				var time_match := time_regex.search(time)
				if time_match:
					schedule_item.weekday = time_match.get_string(1)
					schedule_item.timeframe = time_match.get_string(2)
				
					var date: String = row[0] if row.size() > 0 else ""
					var date_parts := date.split('-')
					schedule_item.year = int(date_parts[0])
					schedule_item.month = int(date_parts[1])
					schedule_item.day = int(date_parts[2])
					
					# Convert row array to dictionary with named columns
					#schedule_item.time = row[1] if row.size() > 1 else ""
					schedule_item.name = row[2] if row.size() > 2 else ""
					schedule_item.type = row[3] if row.size() > 3 else ""
					schedule_item.lecturer = row[4] if row.size() > 4 else ""
					schedule_item.room = row[5] if row.size() > 5 else ""
					schedule_item.info = ""
					if date in sch.items:
						sch.items[date].append(schedule_item)
					else:
						sch.items[date] = [schedule_item]
					previous_row_data = schedule_item
	return sch
