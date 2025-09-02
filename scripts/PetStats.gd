class_name PetStats
extends Resource

@export var pet_name := "Ramonculus"

@export_range(0, 100) var happiness := 80
@export_range(0, 100) var hunger := 40     # 0 = full, 100 = starving
@export_range(0, 100) var hygiene := 25

signal stats_changed   # renamed from "changed"

func set_value(field: String, v: int) -> void:
	v = clamp(v, 0, 100)
	if get(field) != v:
		set(field, v)
		stats_changed.emit()
