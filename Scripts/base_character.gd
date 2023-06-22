extends CharacterBody2D
class_name base_character

enum conditions {idle, move, move_up, mining}

signal action_complete
signal on_cell(cell)

@export var animation_tree    : AnimationTree
@export var sprite            : Sprite2D
@export var inventory         : Array[inventory_entity]
@export var ui_nodes          : Control
@export var start_inventory   : Array[int]
@export var player_craft_obj  : player_craft

@onready var progress_bar: ProgressBar = ui_nodes.get_node("progress_bar")

const SPEED = 100.0

var path : PackedVector2Array
var condition := conditions.idle
var state_machine : AnimationNodeStateMachinePlayback
var tile_position : Vector2i

var next_action = null
var target_obj = null

var in_work_flag := false
var coords_path : PackedVector2Array
var flipped := false

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	SignalsBus.connect("select_cell", Callable(self, "set_path"))
	add_to_group("tile_objects")
#	add_to_group("characters")
	for id in start_inventory:
		add_to_inventory(id, 1)
#		add_to_inventory(0, 2)
	Global.player = self
#	Winhud.set_recipes(inventory)
#	fill_bar(5)
	pass

func flip_sprite(flag : bool):
	print(flag)
	if flipped != flag:
		flipped = flag
		sprite.offset.x = 0 if flag else 59
		sprite.scale.x = -1 if flag else 1
	pass

func step_sound():
	Winhud.play_sound("snd_steps")
	pass

func set_tile_position():
	var new_tile_position = MoveSystem.tilemap.local_to_map(MoveSystem.tilemap.to_local(global_position))
	if new_tile_position != tile_position:
		tile_position = new_tile_position
		if coords_path.size() != 0:
			coords_path.remove_at(0)
			if coords_path.size() != 0:
				flip_sprite(coords_path[0].x < tile_position.x)
				prints((coords_path[0].x < tile_position.x), coords_path[0].x, " < ", tile_position.x)
				if coords_path[0].y < tile_position.y:
					change_condition(conditions.move_up)
				else:
					change_condition(conditions.move)
				prints(tile_position, coords_path[0])
#		if path.size() != 0:
##			prints("flipped", path[0].x < global_position.x, path[0].x, " < ", global_position.x)
#			flip_sprite(path[0].x < global_position.x)
#			if Vector2(0, global_position.y).distance_to(Vector2(0, path[0].y)) > 1:
#				change_condition(conditions.move_up)
#			else:
#				change_condition(conditions.move)
	pass

func _physics_process(delta):
	if path.size() == 0:
		return
	var direction = global_position.direction_to(path[0])
	if global_position.distance_to(path[0]) > 3:
		velocity = lerp(velocity, direction * SPEED, 0.3)
	else:
		set_tile_position()
		path.remove_at(0)
		character_on_cell()
	if path.size() == 0:
		if is_can_dig():
			fill_bar(2)
		elif is_can_destroy():
			destroy_builing()
		else:
			change_condition(conditions.idle)
		velocity = Vector2.ZERO
	move_and_slide()
	pass

func character_on_cell():
	emit_signal("on_cell", tile_position)
	SignalsBus.emit_signal("player_on_cell", tile_position)
#	if path.size() == 0:
	pass

func change_condition(new_condition : conditions):
	if new_condition == condition:
		return
	match new_condition:
		conditions.idle:
			state_machine.travel("idle")
		conditions.move:
			state_machine.travel("move")
		conditions.move_up:
			state_machine.travel("move_up")
		conditions.mining:
			state_machine.travel("dig")
	condition = new_condition
	pass

func set_path(new_target : Vector2i):
	var flag_move = (MoveSystem.check_can_go_to_zone(tile_position, new_target))
	if in_work_flag || !flag_move:
		return
	
	
	match Global.action_mode:
		Global.ACTION_MODES.MINING:
			target_obj = MoveSystem.resources[new_target] if MoveSystem.resources.has(new_target) else null
		Global.ACTION_MODES.DESTRUCTION:
			target_obj = MoveSystem.buildings[new_target] if MoveSystem.buildings.has(new_target) else null
		Global.ACTION_MODES.BUILD:
			return
	
	path =  MoveSystem.tilemap.get_global_path(tile_position, new_target)
	coords_path = MoveSystem.tilemap._get_path(tile_position, new_target)
	change_condition(conditions.move)
	
	if (tile_position - new_target).length() != 1:
		next_action = Global.action_mode
		if path.size() == 0:
			target_obj = null
		else:
			path = MoveSystem.chaikin_algorithm_multiple_iterations(path, 2)
			path = MoveSystem.delete_some_points(path, 2)
			path = MoveSystem.delete_some_points(path, 2)
		Global.change_action_mode(Global.ACTION_MODES.MOVE)
#		set_path(new_target)
	else:
		match Global.action_mode:
			Global.ACTION_MODES.MINING:
				if is_can_dig():
					fill_bar(2)
			Global.ACTION_MODES.DESTRUCTION:
				if is_can_destroy():
					call_deferred("destroy_builing")
	
	pass

func fill_bar(time):
	
	Winhud.play_sound("snd_whoosh")
	in_work_flag = true
	progress_bar.value = 0
	progress_bar.visible = true
	var fill_tween = create_tween()
	fill_tween.tween_property(progress_bar, "value", 100, time)
	fill_tween.tween_callback(Callable(self, "filled_bar"))
	fill_tween.play()
	change_condition(conditions.mining)
	pass

func filled_bar():
	progress_bar.visible = false
	emit_signal("action_complete")
	match condition:
		conditions.mining:
			mine_result()
	
	Global.change_action_mode(Global.ACTION_MODES.MOVE)
	change_condition(conditions.idle)
	in_work_flag = false
	pass

func mine_result():
	var resource_obj = target_obj
	var index = Global.get_entity_index_in_array(resource_obj.resource.id, inventory)
	Winhud.play_sound("snd_pickup")
	if index != null:
		inventory[index].count += 1
	else:
		var new_inventory_object = inventory_entity.new(resource_obj.resource.id, 1)
#		new_inventory_object.count = 1
	#	new_inventory_object.type = inventory_entity.ENTITY_TYPE.RESOURCE
		inventory.append(new_inventory_object)
	resource_obj.decrease_resources(1)
	Winhud.set_inventory(inventory)
	pass

func destroy_builing():
	var building_obj = target_obj
#	prints(inventory, building_obj.inventory)
	if building_obj.inventory != null && building_obj.inventory.size() > 0:
		Global.add_objects_to_inventory(inventory, building_obj.inventory)
#	var building_params = Database.get_obj_by_property_value_from_arr("id", building_obj.building_id, Database.buildings)
#	var building_entity = Database.get_obj_by_property_value_from_arr("id", building_params.entity_id, Database.entities)
	add_to_inventory(building_obj.entity_id, 1)
	
	building_obj.crash_me()
	Winhud.play_sound("snd_tool")
	Global.change_action_mode(Global.ACTION_MODES.MOVE)
	change_condition(conditions.idle)
	in_work_flag = false
	pass

func add_to_inventory(id : int, count : int):
	Global.add_obj_to_inventory(id, count, inventory)
	Winhud.set_inventory(inventory)
	pass

func remove_from_inventory(id : int, count : int):
	Global.remove_obj_from_inventory(id, count, inventory)
	Winhud.set_inventory(inventory)
	pass

func is_can_dig():
	return((Global.action_mode == Global.ACTION_MODES.MINING ||
			next_action == Global.ACTION_MODES.MINING) &&
			target_obj  != null &&
			MoveSystem.is_cell_near(tile_position, target_obj.tile_position))
	pass

func is_can_destroy():
	return((Global.action_mode == Global.ACTION_MODES.DESTRUCTION ||
			next_action == Global.ACTION_MODES.DESTRUCTION) &&
			target_obj  != null &&
			MoveSystem.is_cell_near(tile_position, target_obj.tile_position))
	pass
