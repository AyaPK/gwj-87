extends Node

var ui: Ui
var player: Player

var light_intensity: float = 1.0

func reset_light_meter() -> void:
	ui.reset_meter()

func reduce_light_meter() -> void:
	if light_intensity != 0.0:
		ui.light_meter.value -= light_intensity
	ui.hp_anim.play("shake")
	ui.emit_particles()
	
func increase_light_meter() -> void:
	ui.light_meter.value += light_intensity
	ui.hp_anim.play("still")
	ui.stop_emit_particles()
