# res://scripts/GameState.gd
extends Node

signal stats_changed
signal money_changed

var money: int = 2

var pet := {
	"name": "Ramonculus",
	"happiness": 0.95,  # 0..1
	"hunger":    0.69,
	"hygiene":   0.25,
}

# very simple inventory skeleton (expand later)
var inventory := {
	"care":    [{"id":"soap","name":"Soap","count":2,"icon":"res://assets/icons/inventory/soap.png"}],
	"food":    [],
	"clothes": [],
	"toys":    []
}

func set_stat(key: String, value: float) -> void:
	if key in pet:
		pet[key] = clamp(value, 0.0, 1.0)
		stats_changed.emit()

func add_money(delta: int) -> void:
	money = max(0, money + delta)
	money_changed.emit()
