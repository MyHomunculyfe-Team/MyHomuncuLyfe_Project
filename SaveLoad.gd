extends Node

var path := "user://save.json"

var default_data := {
	"Hunger": 0,
	"Happiness": 0,
	"Hygine": 0,
	"Pet_name":"munccy"
}

func save(data: Dictionary):
	FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(data))

func load() -> Dictionary:
	# If the file doesn’t exist, create it with defaults
	if not FileAccess.file_exists(path):
		print("No save file found — creating new one with defaults.")
		save(default_data)
		return default_data.duplicate(true)

	# Otherwise, load existing data
	print("data exists")
	var path = "user://save.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		print("=== SAVE FILE CONTENT ===")
		print(file.get_as_text())
		file.close()
	else:
		print("No save file found!")
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	# Safety: if file is broken or empty, use defaults
	if typeof(data) != TYPE_DICTIONARY:
		print("Save file corrupt — resetting to defaults.")
		save(default_data)
		return default_data.duplicate(true)
	
	return data

func reset():
	print("Resetting save file to defaults...")
	save(default_data)
