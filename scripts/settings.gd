extends Control


const SAVE_FILE_PATH := "user://savegame.save"
@export var points: int = 0
@export var level: int = 1

func _on_back_pressed():
	get_tree().change_scene("res://Main.tscn")

func _on_load_pressed():
	get_tree().change_scene("res://fileload.tscn")
	

func _on_save_pressed():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		var save_data = {
			"name": PetStatsLoad.name 
			"happiness": PetStatsLoad.happiness
			"hunger": PetStatsLoad.hunger
			"hygine": PetStatsLoad.hygine
		#"points": points
		}
		file.store_var(save_data, true) # true = full objects/dictionaries allowed
		file.close()
		print("Game saved!")
