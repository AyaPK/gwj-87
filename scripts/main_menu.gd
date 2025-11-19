extends Node2D

const LEVEL_BUTTON = preload("uid://cdybsq2xjtoq5")
const STAR = preload("uid://by5fvda33f248")

@onready var level_button_container: HFlowContainer = $CanvasLayer/LevelButtonContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"CanvasLayer/Main Buttons".show()
	$CanvasLayer/LevelButtonContainer.hide()
	$CanvasLayer/LevelSelectBackButton.hide()
	for level in SaveManager.data:
		var level_button: LevelButtonContainer = LEVEL_BUTTON.instantiate()
		level_button_container.add_child(level_button)
		level_button.level_button.text = str(level)
		if SaveManager.get_level(level)["pickupCollected"]:
			level_button.texture_rect.texture = STAR
		if SaveManager.get_level(level)["complete"]:
			level_button.level_button.modulate = Color(0.565, 0.894, 0.518, 0.722)
		else:
			level_button.level_button.modulate = Color(0.962, 0.736, 0.681, 0.722)
	Ui.play_hello_world()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level_1.tscn")
	Ui.set_up()


func _on_level_select_back_button_pressed() -> void:
	$"CanvasLayer/Main Buttons".show()
	$CanvasLayer/LevelSelectBackButton.hide()
	$CanvasLayer/LevelButtonContainer.hide()
	pass

func _on_level_select_button_pressed() -> void:
	$"CanvasLayer/Main Buttons".hide()
	$CanvasLayer/LevelSelectBackButton.show()
	$CanvasLayer/LevelButtonContainer.show()
