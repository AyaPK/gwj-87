extends Node

var current_level: int = 0

@warning_ignore("unused_signal")
signal player_entering

func change_level() -> void:
	LightManager.player.accepting_input = false
	Ui.fade_out()
	await Ui.fade_out_complete
	
	current_level += 1
	get_tree().change_scene_to_file("res://levels/level_"+str(current_level)+".tscn")
	Ui.light_meter.value = Ui.light_meter.max_value
	Ui.fade_in()
	await Ui.fade_in_complete
	LightManager.player.accepting_input = true
