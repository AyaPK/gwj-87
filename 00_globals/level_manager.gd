class_name Level extends Node

var current_level: int = 0
var level_object: Node2D
var got_pickup: bool = false
var playing: bool = false

var prelevel_text: = [
"You are the lumenless.

A lone wanderer...",
"You walk where names have decayed.

Even the silence seems afraid to speak of what happened here.",
"Fragments of old structures murmur beneath your steps.

They remember you, though you have no memories of them.",
"Light has carved scars across this unrecogniseable land.

Yet something about these ruins feels intimately familiar.",
"You sense traces of others who passed through the glow.

Their echoes cling to the stone like forgotten prayers.",
"The ruins watch you as you move. Hollow and unblinking.

You wonder if the world itself keeps track of you.",
"Glass relics glint with a memory that the light could not devour.

In their reflections, you see shapes that are not yours.",
"The world moves for you with mechanical sighs.

You do not know why they yield, only that they always have.",
"Ancient machines stir at your presence, obedient to ghosts.

They shift as though they still recognise a master.",
"You feel the world thinning around you.

Even the shadows grow weary under the unending glare.",
"Light presses closer here, almost listening.

Its hunger has not dimmed since the world first shattered...",
"The land flickers as if remembering itself...

Its shapes whispering a story you can almost recognise.",
"The atmosphere bends under a weight you cannot see.

Something buried beneath the brightness still breathes.",
"You begin to remember a land that time has forgotten.

You begin to remember home.",
"This level hasn't been made yet...",
"At the world's final threshold, the light softens. It's almost gentle.

You step forward, carrying a story that you don't fully recall..."
]

@warning_ignore("unused_signal")
signal player_entering

@warning_ignore("unused_signal")
signal reset_level

func change_level() -> void:
	LightManager.player.accepting_input = false
	LightManager.player.velocity = Vector2.ZERO
	Ui.fade_out()
	await Ui.fade_out_complete
	
	if got_pickup:
		SaveManager.mark_collected(current_level)
	SaveManager.mark_complete(current_level)
	current_level += 1
	if current_level <= SaveManager.LEVEL_COUNT:
		got_pickup = SaveManager.get_level(current_level)["pickupCollected"]
		get_tree().change_scene_to_file("res://levels/level_"+str(current_level)+".tscn")
		Ui.light_meter.value = Ui.light_meter.max_value
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		Ui.fade_in()
