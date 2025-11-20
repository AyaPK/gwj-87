extends RigidBody2D

@onready var shape_cast_2d: ShapeCast2D = $ShapeCast2D
var start_pos: Vector2
var grounded: bool = false
var _sfx_check_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mass = 1.0
	start_pos = global_position
	LevelManager.reset_level.connect(respawn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	_sfx_check_timer += delta
	if _sfx_check_timer >= 0.05:
		_sfx_check_timer = 0.0
		if abs(linear_velocity.x) > 2.0:
			if LightManager.ui:
				LightManager.ui.play_block()
		else:
			if LightManager.ui:
				LightManager.ui.stop_block()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	grounded = false
	var contact_count := state.get_contact_count()
	for i in range(contact_count):
		var n := state.get_contact_local_normal(i)
		if n.y < -0.3:
			grounded = true
			break
	if not grounded and abs(state.linear_velocity.y) > 10.0:
		state.linear_velocity.x = 0.0

func respawn() -> void:
	global_position = start_pos
