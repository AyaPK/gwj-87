extends Node

var ui: Ui
var player: Player

func reset_light_meter() -> void:
	ui.reset_meter()

func reduce_light_meter(amount: int) -> void:
	ui.light_meter.value -= amount
	
func increase_light_meter(amount: int) -> void:
	ui.light_meter.value += amount
