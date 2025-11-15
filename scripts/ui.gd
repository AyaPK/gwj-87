class_name Ui extends CanvasLayer

@onready var light_meter: TextureProgressBar = $LightMeter
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	LightManager.ui = self
	reset_meter()
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	color_rect.color.a = 1 - (light_meter.value / light_meter.max_value)

func reset_meter() -> void:
	light_meter.value = 1000
