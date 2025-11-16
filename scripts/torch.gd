extends PointLight2D

@export var scaling: float = 1

func _ready() -> void:
	scale.x = scaling
	scale.y = scaling

func _process(_delta: float) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	add_to_group("lights")

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	remove_from_group("lights")
