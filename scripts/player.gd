class_name Player extends CharacterBody2D

const SPEED = 80.0
const JUMP_VELOCITY = -250.0

var is_lit: bool = false
const LIGHT_CHECK_INTERVAL := 0.1
const LIGHT_RAY_DISTANCE := 4096.0
var _light_check_accum := 0.0
const MAX_POINT_LIGHT_DISTANCE := 40.0

@onready var light_ray: RayCast2D = $LightRay
@onready var light_ray_up: RayCast2D = $LightRayUp
@onready var light_ray_down: RayCast2D = $LightRayDown

var accepting_input: bool = false

func _ready() -> void:
	LightManager.player = self

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if accepting_input:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if Input.is_action_just_pressed("crouch") and is_on_floor():
			LevelManager.player_entering.emit()

		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	update_animation()
	move_and_slide()

	_light_check_accum += delta
	if _light_check_accum >= LIGHT_CHECK_INTERVAL:
		_light_check_accum = 0.0
		_update_light_state()
	
	if !is_lit:
		LightManager.increase_light_meter(1)
	else:
		LightManager.reduce_light_meter(1)

func update_animation() -> void:
	if velocity.x !=  0:
		%player_animation.play("run")
		if velocity.x < 0:
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false

	else:
		%player_animation.play("idle")  
		
	if !is_on_floor():
		if velocity.y < 0:
			%player_animation.play("jump")
		else:
			%player_animation.play("fall")
	pass

func _update_light_state() -> void:
	var lit := false
	var dlight := _get_directional_light()
	if dlight != null:
		if _check_directional_light(dlight):
			lit = true
	if not lit:
		for plight in _get_point_lights():
			if _check_point_light(plight):
				lit = true
				break
	is_lit = lit

func _get_directional_light() -> DirectionalLight2D:
	var root := get_tree().current_scene
	if root == null:
		return null
	var found := root.find_children("", "DirectionalLight2D", true, false)
	if found.size() > 0:
		return found[0] as DirectionalLight2D
	return null

func _get_point_lights() -> Array:
	return get_tree().get_nodes_in_group("lights")

func _check_directional_light(light: DirectionalLight2D) -> bool:
	var dir := Vector2.DOWN.rotated(light.global_rotation)
	var to_sky: Vector2 = -dir.normalized() * LIGHT_RAY_DISTANCE
	var offsets := [Vector2.ZERO, Vector2(0, -10), Vector2(0, -20)]
	var rays := [light_ray, light_ray_up, light_ray_down]
	var clear_count := 0
	for i in range(rays.size()):
		var ray: RayCast2D = rays[i]
		ray.position = offsets[i]
		ray.target_position = to_sky
		ray.force_raycast_update()
		if not ray.is_colliding():
			clear_count += 1
	return clear_count >= 2

func _check_point_light(light: Node) -> bool:
	var plight: PointLight2D = light as PointLight2D
	if plight == null:
		return false
	var lp: Vector2 = plight.global_position
	if not _point_light_contains(plight, global_position):
		return false
	var space := get_world_2d().direct_space_state
	var points := [
		global_position,
		global_position + Vector2(0, -8),
		global_position + Vector2(0, -16)
	]
	var mask := 1 << 1
	for p in points:
		var result := space.intersect_ray(PhysicsRayQueryParameters2D.create(p, lp, mask))
		if result.is_empty():
			return true
	return false

func _point_light_contains(plight: PointLight2D, world_point: Vector2) -> bool:
	var tex: Texture2D = plight.texture
	if tex == null:
		return true
	var p_local: Vector2 = plight.to_local(world_point)
	var w2: float = float(tex.get_width()) * 0.65 * plight.texture_scale
	var h2: float = float(tex.get_height()) * 0.65 * plight.texture_scale
	if w2 <= 0.0 or h2 <= 0.0:
		return false
	var nx: float = p_local.x / w2
	var ny: float = p_local.y / h2
	return (nx * nx + ny * ny) <= 1.0
