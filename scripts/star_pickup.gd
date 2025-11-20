class_name StarPickup extends Node2D

var collected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.reset_level.connect(respawn)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pickup_zone_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		LevelManager.got_pickup = true
		Ui.mark_star_complete()
		if !collected:
			Ui.play_star_pickup()
			collected = true
		hide()

func respawn() -> void:
	LevelManager.got_pickup = false
	Ui.mark_star_incomplete()
	show()
