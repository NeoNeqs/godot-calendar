class_name SimpleHTMLParser
extends RefCounted

var table_regex := RegEx.new()
var row_regex := RegEx.new()
var cell_regex := RegEx.new()
var strip_tags_regex := RegEx.new()


func _init() -> void:
	table_regex.compile("<table.*?>([\\s\\S]*?)</table>")
	row_regex.compile("<tr.*?>([\\s\\S]*?)</tr>")
	cell_regex.compile("<t[dh].*?>([\\s\\S]*?)</t[dh]>")
	strip_tags_regex.compile("<[^>]*>")

func parse():
	var table_data := []
	var html := FileAccess.get_file_as_string("res://page.html")

	var table_match = table_regex.search(html)
	if table_match:
		var table_content = table_match.get_string(1)
		var previous_row_data = null

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
				previous_row_data["additional_info"] = row[0]
			else:
				# Convert row array to dictionary with named columns
				var row_dict := {
					"date": row[0] if row.size() > 0 else "",
					"time": row[1] if row.size() > 1 else "",
					"name": row[2] if row.size() > 2 else "",
					"type": row[3] if row.size() > 3 else "",
					"lecturer": row[4] if row.size() > 4 else "",
					"room": row[5] if row.size() > 5 else "",
					"info": ""
				}
				table_data.append(row_dict)
				previous_row_data = row_dict
	return table_data
