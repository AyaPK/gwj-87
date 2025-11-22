extends RigidBody2D

@onready var shape_cast_2d: ShapeCast2D = $ShapeCast2D
var start_pos: Vector2
var grounded: bool = false
var _sfx_check_timer: float = 0.0
var _hovering_over_pushable: bool = false
var _hover_y: float = 0.0
const MAX_SPEED: float = 200.0
const MAX_NORMAL_PUSH: float = 60.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mass = 1.0
	start_pos = global_position
	LevelManager.reset_level.connect(respawn)
	# Improve stability against sudden impulses
	var mat := PhysicsMaterial.new()
	mat.bounce = 0.0
	mat.friction = 1.5
	physics_material_override = mat
	# Ensure the cast checks slightly below to detect stacks
	shape_cast_2d.enabled = true
	if shape_cast_2d.target_position == Vector2.ZERO:
		shape_cast_2d.target_position = Vector2(0, 4)


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

	# Clamp overall speed to avoid explosive acceleration
	if state.linear_velocity.length() > MAX_SPEED:
		state.linear_velocity = state.linear_velocity.normalized() * MAX_SPEED

	# If colliding with the player, cap velocity along the collision normal
	var contact_count2 := state.get_contact_count()
	for j in range(contact_count2):
		var obj := state.get_contact_collider_object(j)
		if obj and obj is Node and (obj as Node).is_in_group("player"):
			var n2 := state.get_contact_local_normal(j)
			# Remove excess velocity into the player beyond a small push value
			var v := state.linear_velocity
			var into := v.dot(n2)
			if into > MAX_NORMAL_PUSH:
				state.linear_velocity = v - n2 * (into - MAX_NORMAL_PUSH)

	# Detect pushable directly beneath using shape cast
	var detected_pushable: Node2D = null
	shape_cast_2d.force_shapecast_update()
	if shape_cast_2d.is_colliding():
		var collisions := shape_cast_2d.get_collision_count()
		for i in range(collisions):
			var col := shape_cast_2d.get_collider(i)
			if col and col is Node2D:
				var node := col as Node2D
				if node != self and (node.is_in_group("Pushables") or node.is_in_group("pushables")):
					detected_pushable = node
					break

	# Enter hover state: keep collisions, but disable gravity and float by 1px
	if detected_pushable and not _hovering_over_pushable:
		_hovering_over_pushable = true
		gravity_scale = 0.0
		state.linear_velocity.y = min(0.0, state.linear_velocity.y)
		state.transform.origin.y -= 1.0
		_hover_y = state.transform.origin.y

	# Maintain hover while still above a pushable
	elif detected_pushable and _hovering_over_pushable:
		state.linear_velocity.y = min(0.0, state.linear_velocity.y)
		# Pin Y to prevent sinking under added weight
		state.transform.origin.y = _hover_y

	# Exit hover when no longer above a pushable
	elif not detected_pushable and _hovering_over_pushable:
		_hovering_over_pushable = false
		gravity_scale = 1.0

func respawn() -> void:
	global_position = start_pos
