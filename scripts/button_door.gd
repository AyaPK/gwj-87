class_name ButtonDoor extends ButtonTarget

@export var speed: float = 50.0
@onready var shape_cast: ShapeCast2D = $RayCast2D

var start_y: float
var start_x: float

func _ready() -> void:
	start_x = global_position.x
	LevelManager.reset_level.connect(reset)
	pass

func _process(_delta: float) -> void:
	if is_active:
		if !start_y:
			start_y = global_position.y
		velocity.y = -speed
	else:
		velocity.y = speed
	if global_position.x != start_x:
		global_position.x = start_x
	
	shape_cast.force_shapecast_update()

	if shape_cast.is_colliding():
		# ShapeCast2D can detect multiple collisions, so we check them all
		for i in range(shape_cast.get_collision_count()):
			var collider = shape_cast.get_collider(i)
			if collider.is_in_group("player"):
				velocity = Vector2.ZERO
				break
	
	if global_position.y <= start_y:
		move_and_slide()
	if global_position.y > start_y and start_y:
		global_position.y = start_y
	

func active() -> void:
	is_active = true

func inactive() -> void:
	is_active = false

func reset() -> void:
	global_position.y = start_y
