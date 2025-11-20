extends CanvasLayer

@onready var light_meter: TextureProgressBar = $LightMeter
@onready var color_rect: ColorRect = $ColorRect
@onready var hp_anim: AnimationPlayer = $HpAnim
@onready var node_end: GPUParticles2D = $NodeEnd
@onready var node_end_2: GPUParticles2D = $NodeEnd2
@onready var node_end_3: GPUParticles2D = $NodeEnd3
@onready var star_sprite: Sprite2D = $StarSprite
@onready var intro_overlay: ColorRect = $IntroOverlay
@onready var intro_label: Label = $IntroOverlay/IntroLabel

var fading: bool = false
var rumble_tween: Tween
var rumble_base_db: float = 12.0

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
	$IntroOverlay.hide()
	rumble_base_db = $RumbleSFX.volume_db

func set_up() -> void:
	$LightMeter.show()
	$ColorRect.show()
	$StarSprite.show()
	LightManager.ui = self
	reset_meter()
	node_end.emitting = true
	color_rect.color.a = 1
	fading = true
	LevelManager.reset_level.connect(reset_light)

func show_intro(text: String, duration: float = 5.0, skip_if_complete: bool = true) -> void:
	var should_skip := false
	if skip_if_complete:
		var lvl := SaveManager.get_level(LevelManager.current_level)
		should_skip = lvl.get("complete", false)
	if should_skip or text == "":
		color_rect.color.a = 1
		fading = true
		fade_in()
		await fade_in_complete
		LightManager.player.accepting_input = true
		return
	LightManager.player.accepting_input = false
	intro_label.text = text
	intro_overlay.show()
	LevelManager.level_object.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().process_frame
	var ap: AnimationPlayer = $IntroOverlay/IntroLabelAnim
	if ap and ap.has_animation("fade_in"):
		ap.play("fade_in")
	await get_tree().create_timer(max(0.0, duration)).timeout
	LevelManager.level_object.process_mode = Node.PROCESS_MODE_ALWAYS
	if ap and ap.has_animation("fade_out"):
		ap.play("fade_out")
		await ap.animation_finished
	intro_overlay.hide()
	color_rect.color.a = 1
	fading = true
	fade_in()
	await fade_in_complete
	LightManager.player.accepting_input = true

func _process(_delta: float) -> void:
	node_end.global_position = Vector2(light_meter.global_position.x+(light_meter.value*1.28), light_meter.global_position.y)
	node_end_2.global_position = Vector2(light_meter.global_position.x+(light_meter.value*1.28), light_meter.global_position.y+10)
	node_end_3.global_position = Vector2(light_meter.global_position.x+(light_meter.value*1.28), light_meter.global_position.y+20)
	if light_meter.value == 0:
		LevelManager.reset_level.emit()

func _physics_process(_delta: float) -> void:
	if not fading:
		color_rect.color.a = 1 - (light_meter.value / light_meter.max_value)

func reset_meter() -> void:
	light_meter.value = 1000

func emit_particles() -> void:
	play_rumble()
	node_end.emitting = true
	node_end_2.emitting = true
	node_end_3.emitting = true

func stop_emit_particles() -> void:
	stop_rumble()
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
	$Music.stream = HELLO_WORLD
	$Music.play()

func play_level_music() -> void:
	if $Music.stream != SHADOW:
		$Music.stream = SHADOW
		$Music.play()

func play_rumble() -> void:
	if rumble_tween:
		rumble_tween.kill()
	# Very slight fade-in
	var start_db := rumble_base_db - 30.0
	$RumbleSFX.volume_db = start_db
	if !$RumbleSFX.playing:
		$RumbleSFX.play()
	rumble_tween = create_tween()
	rumble_tween.tween_property($RumbleSFX, "volume_db", rumble_base_db, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func stop_rumble() -> void:
	if rumble_tween:
		rumble_tween.kill()
	rumble_tween = create_tween()
	rumble_tween.tween_property($RumbleSFX, "volume_db", rumble_base_db - 50.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	rumble_tween.tween_callback(Callable($RumbleSFX, "stop"))

func play_footsteps() -> void:
	if !$StepSFX.playing:
		$StepSFX.play()

func stop_footsteps() -> void:
	$StepSFX.stop()

func play_jump() -> void:
	$JumpSFX.play()

func play_star_pickup() -> void:
	$StarPickup.play()

func play_block() -> void:
	if !$BlockPushSFX.playing:
		$BlockPushSFX.play()

func stop_block() -> void:
	$BlockPushSFX.stop()
