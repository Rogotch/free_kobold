extends CharacterBody2D

@export var type  : resource_object.RES_TYPE
@export var count : int
@export var entity_id : int
var tile_position : Vector2i
var resource : resource_object 
var path : Array[Vector2i]
var SPEED := 50
var used_flag := false

func _ready() -> void:
	SignalsBus.connect("player_on_cell", Callable(self, "go_to_inventory"))
	add_to_group("tile_objects")
	call_deferred("set_tile_position")
	call_deferred("load_resource")
	pass

func load_resource():
	resource = resource_object.new(type, entity_id)
	pass

func _process(delta: float) -> void:
	if path.size() == 0:
		return
	var direction = global_position.direction_to(path[0])
	if global_position.distance_to(path[0]) > 1:
		velocity = direction * SPEED
	else:
		set_tile_position()
		path.remove_at(0)
	if path.size() == 0:
		velocity = Vector2.ZERO
	move_and_slide()
	pass

func set_tile_position():
	tile_position = Global.get_map_position(self)
	if tile_position == Global.player.tile_position:
		go_to_inventory(tile_position)
		Winhud.play_sound("snd_drop")
	pass

#func set_on_firs

func set_path(new_target : Vector2i):
#	path = MoveSystem.tilemap.get_global_path(tile_position, new_target)
	pass

func go_to_inventory(player_position):
#	prints(tile_position, player_position, tile_position != player_position)
	if used_flag || tile_position != player_position:
		return
	Winhud.play_sound("snd_drop")
	used_flag = true
	Global.player.add_to_inventory(resource.id, count)
	move_to_player_tween()
	pass

func move_to_player_tween():
	var move_tween = create_tween()
	move_tween.set_parallel(true)
	move_tween.tween_property(self, "global_position", Global.player.global_position, 0.2)
	move_tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	move_tween.chain().tween_callback(Callable(self, "queue_free"))
	move_tween.play()
	pass
