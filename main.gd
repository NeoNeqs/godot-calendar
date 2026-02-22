extends Control


func _ready() -> void:
	var s := Time.get_ticks_usec()
	var a := SimpleHTMLParser.new()
	for row: Dictionary in a.parse():
		print(row["time"], ": ", row["info"])
	var e := Time.get_ticks_usec()
	print(e - s)
