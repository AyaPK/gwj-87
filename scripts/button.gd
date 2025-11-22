class_name ButtonSwitch extends CharacterBody2D

@export var target: Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var _press_count: int = 0

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player") or _body.is_in_group("pushables"):
		_press_count += 1
		if _press_count == 1:
			animation_player.play("pressed")
			target.is_active = true

func _on_area_2d_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("player") or _body.is_in_group("pushables"):
		_press_count = max(0, _press_count - 1)
		if _press_count == 0:
			animation_player.play("unpressed")
			target.is_active = false
