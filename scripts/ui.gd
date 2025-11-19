extends CanvasLayer

@onready var light_meter: TextureProgressBar = $LightMeter
@onready var color_rect: ColorRect = $ColorRect
@onready var hp_anim: AnimationPlayer = $HpAnim
@onready var node_end: GPUParticles2D = $NodeEnd
@onready var node_end_2: GPUParticles2D = $NodeEnd2
@onready var node_end_3: GPUParticles2D = $NodeEnd3
@onready var star_sprite: Sprite2D = $StarSprite

var fading: bool = false

signal fade_out_complete
signal fade_in_complete

const STAR = preload("uid://by5fvda33f248")
const STAR_TRANSPARENT = preload("uid://bf16xm8cpl5iq")
const HELLO_WORLD = preload("uid://ci4ehvgpc7lil")
const SHADOW = preload("uid://d2uln3drsxl7c")

func _ready() -> void:
	$LightMeter.hide()
	$ColorRect.hide()
	$StarSprite.hide()

func set_up() -> void:
	$LightMeter.show()
	$ColorRect.show()
	$StarSprite.show()
	LightManager.ui = self
	reset_meter()
	node_end.emitting = true
	color_rect.color.a = 1
	fading = true
	fade_in()
	await fade_in_complete
	LightManager.player.accepting_input = true
	LevelManager.reset_level.connect(reset_light)

func _process(_delta: float) -> void:
	node_end.global_position = Vector2(light_meter.global_position.x+(light_meter.value*1.28), light_meter.global_position.y)
	node_end_2.global_position = Vector2(light_meter.global_position.x+(light_meter.value*1.28), light_meter.global_position.y+10)
	node_end_3.global_position = Vector2(light_meter.global_position.x+(light_meter.value*1.28), light_meter.global_position.y+20)
	if light_meter.value == 0:
		LevelManager.reset_level.emit()
	pass

func _physics_process(_delta: float) -> void:
	if not fading:
		color_rect.color.a = 1 - (light_meter.value / light_meter.max_value)

func reset_meter() -> void:
	light_meter.value = 1000

func emit_particles() -> void:
	node_end.emitting = true
	node_end_2.emitting = true
	node_end_3.emitting = true

func stop_emit_particles() -> void:
	node_end.emitting = false
	node_end_2.emitting = false
	node_end_3.emitting = false

func fade_out() -> void:
	fading = true
	while true:
		color_rect.color.a = move_toward(color_rect.color.a, 1, 0.02)
		if color_rect.color.a == 1:
			fade_out_complete.emit()
			break
		await get_tree().process_frame

func fade_in() -> void:
	fading = true
	while true:
		color_rect.color.a = move_toward(color_rect.color.a, 0, 0.02)
		if color_rect.color.a == 0:
			fade_in_complete.emit()
			fading = false
			break
		await get_tree().process_frame

func reset_light() -> void:
	light_meter.value = light_meter.max_value

func mark_star_incomplete() -> void:
	star_sprite.texture = STAR_TRANSPARENT

func mark_star_complete() -> void:
	star_sprite.texture = STAR

func play_hello_world() -> void:
	$AudioStreamPlayer.stream = HELLO_WORLD
	$AudioStreamPlayer.play()

func play_level_music() -> void:
	if $AudioStreamPlayer.stream != SHADOW:
		$AudioStreamPlayer.stream = SHADOW
		$AudioStreamPlayer.play()
