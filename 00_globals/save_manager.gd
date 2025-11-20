extends Node
 
 
const SAVE_PATH: String = "user://save.json"
const LEVEL_COUNT: int = 11
var data: Dictionary = {}

signal saved
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_save()
 
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
 
# Internal: create a new save dictionary with default values
func _initialize_new() -> void:
	data = {}
	for i in LEVEL_COUNT + 1:
		if i != 0:
			data[i] = {"complete": false, "pickupCollected": false}
	save()
 
# Internal: ensure the save dictionary has all required fields
func _ensure_template() -> void:
	# Normalize keys to integers in case JSON loaded them as strings
	var normalized: Dictionary = {}
	for k in data.keys():
		var ki := int(k)
		normalized[ki] = data[k]
	data = normalized
	for i in LEVEL_COUNT + 1:
		if i != 0:
			if not data.has(i) or typeof(data[i]) != TYPE_DICTIONARY:
				data[i] = {"complete": false, "pickupCollected": false}
			else:
				var lvl: Dictionary = data[i]
				if not lvl.has("complete"):
					lvl["complete"] = false
				if not lvl.has("pickupCollected"):
					lvl["pickupCollected"] = false
				data[i] = lvl
 
# Load save file or create a new one if missing/invalid
func load_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var txt := f.get_as_text()
		f.close()
		var parsed = JSON.parse_string(txt)
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed
			_ensure_template()
			return
	# Fallback to new save
	_initialize_new()
	save()
 
# Save current data to disk
func save() -> void:
	var txt := JSON.stringify(data, "  ")
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(txt)
	f.close()
 
func mark_collected(level_num: int, save_immediately: bool = true) -> void:
	if level_num < 1 or level_num > LEVEL_COUNT:
		return
	_ensure_template()
	data[level_num]["pickupCollected"] = true
	if save_immediately:
		save()
 
func mark_complete(level_num: int, save_immediately: bool = true) -> void:
	if level_num < 1 or level_num > LEVEL_COUNT:
		return
	_ensure_template()
	data[level_num]["complete"] = true
	if save_immediately:
		save()
 
func get_level(level_num: int) -> Dictionary:
	_ensure_template()
	return data.get(level_num, {"complete": false, "pickupCollected": false})
 
func reset(save_immediately: bool = true) -> void:
	_initialize_new()
	if save_immediately:
		save()
