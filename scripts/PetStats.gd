class_name PetStats
extends Resource


signal stats_changed   # renamed from "changed"
signal deformity_warning(stat_name: String)

@export var pet_name := "Ramonculus"
@export_range(0, 100) var happiness := 80
@export_range(0, 100) var hunger := 40     # 0 = full, 100 = starving
@export_range(0, 100) var hygiene := 25

var deformity_triggered := {
	"happiness": false,
	"hunger": false,
	"hygiene": false
}

func set_value(field: String, v: float) -> void:
	v = clamp(v, 0, 100)
	if get(field) != v:
		set(field, v)
		stats_changed.emit()
		_check_deformity(field, v)
		
		
func _check_deformity(field: String, v: int) -> void:
	# trigger warning only once when value crosses the threshold
	if v >= 10 and not deformity_triggered[field]:
		deformity_triggered[field] = true
		deformity_warning.emit(field)
	elif v < 10:
		# reset trigger once the stat returns to safe range
		deformity_triggered[field] = false
