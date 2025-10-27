class_name PetStats
extends Resource


signal stats_changed   # renamed from "changed"
signal deformity_warning(stat_name: String)

@export var pet_name := "Ramonculus"
@export_range(0, 100) var happiness := 80
@export_range(0, 100) var hunger := 40     # 0 = full, 100 = starving
@export_range(0, 100) var hygiene := 25

func set_value(field: String, v: float) -> void:
	v = clamp(v, 0, 100)
	if get(field) != v:
		set(field, v)
		stats_changed.emit()
		_check_deformity(field, v)
		
		
func _check_deformity(field: String, v: int) -> void:
	# Only trigger when value hits or exceeds 10
	if v >= 10:
		deformity_warning.emit(field)
