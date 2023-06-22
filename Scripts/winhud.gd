extends CanvasLayer

var sounds_nodes = {
	"snd_button"             : "sounds/vfx/snd_button",
	"snd_drop"               : "sounds/vfx/snd_drop",
	"snd_list"               : "sounds/vfx/snd_list",
	"snd_pickup"             : "sounds/vfx/snd_pickup",
	"snd_steps"              : "sounds/vfx/snd_steps",
	"snd_tool"               : "sounds/vfx/snd_tool",
	"snd_whoosh"             : "sounds/vfx/snd_whoosh",
	"snd_work"               : "sounds/vfx/snd_work"
}

var music_nodes = {
	"amb"                 : "sounds/music/music_amb"
}

@onready var ui: CanvasLayer = $ui
@onready var wins: CanvasLayer = $wins
@onready var global_wins: CanvasLayer = $global_wins

const  ui_wins := {
	"recipes_win"  : "res://UI/base_recipe.tscn",
	"menu"         : "res://UI/menu.tscn"
}

var pause_flag := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_music("amb")
	pass # Replace with function body.

func play_sound(sound_name):
	var sound_node = get_node(sounds_nodes[sound_name])
	sound_node.stop()
	sound_node.call_deferred("play")
	pass

func play_music(music_name):
	for music_key in music_nodes.keys():
		var actual_key = music_key
#		print(actual_key)
		var music_node = get_node(music_nodes[music_key])
		if music_name == music_key:
			music_node.play()
		else:
			music_node.stop()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_inventory(recipes_arr : Array[inventory_entity]):
	ui.set_inventory(recipes_arr)
	pass

func show_win(win_name : String):
	var new_win = load(ui_wins[win_name]).instantiate()
	wins.add_child(new_win)
	return new_win
	pass

func show_building_recipes(building_id : int, building_obj, ignore_drop := false):
	var recipe_win = show_win("recipes_win")
	recipe_win.load_recipes(building_id)
	recipe_win.set_building_obj(building_obj)
	recipe_win.ignore_drop_resources = ignore_drop
	recipe_win.player_craft_flag     = ignore_drop
#	recipe_win.building_obj = building_obj
	pass

func _on_craft_button_pressed() -> void:
	Winhud.play_sound("snd_button")
	show_building_recipes(0, Global.player.player_craft_obj, true)
	pass # Replace with function body.

func pause(flag):
	pause_flag = flag
	get_tree().paused = flag
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		show_win("menu")
	pass
