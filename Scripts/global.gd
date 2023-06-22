extends Node
enum ACTION_MODES {MOVE, BUILD, MINING, DESTRUCTION}

var action_mode := ACTION_MODES.MOVE
var player : base_character

var pressed_shift_flag := false
var pressed_ctrl_flag  := false

var hand   = load("res://Sprites/cursor.png")
var pick   = load("res://Sprites/Icons/pick_iron.png")
var hammer = load("res://Sprites/Icons/hammer.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event: InputEvent) -> void:
	if   Input.is_action_just_pressed("ctrl"):
		pressed_ctrl_flag  = true
	elif Input.is_action_just_released("ctrl"):
		pressed_ctrl_flag  = false
	if   Input.is_action_just_pressed("shift"):
		pressed_shift_flag = true
	elif Input.is_action_just_released("shift"):
		pressed_shift_flag = false
	pass

func change_action_mode(new_action_mode : ACTION_MODES):
	action_mode = new_action_mode
	match action_mode:
		ACTION_MODES.MINING:
			Input.set_custom_mouse_cursor(pick, Input.CURSOR_ARROW, Vector2(12, 0))
		ACTION_MODES.DESTRUCTION:
			Input.set_custom_mouse_cursor(hammer, Input.CURSOR_ARROW, Vector2(12, 0))
		_:
			Input.set_custom_mouse_cursor(hand, Input.CURSOR_ARROW)
	pass

func delete_children(node : Node):
	var all_children = node.get_children()
	for child in all_children:
		child.queue_free()
	pass

func add_obj_to_inventory(id : int, count : int, inventory : Array[inventory_entity]):
	var index = get_entity_index_in_array(id, inventory)
	if index != null:
		inventory[index].count += count
	else:
		var new_inventory_object = inventory_entity.new(id, count)
		inventory.append(new_inventory_object)
	pass

func remove_obj_from_inventory(id : int, count : int, inventory : Array[inventory_entity]):
	var index = get_entity_index_in_array(id, inventory)
	if index != null:
		inventory[index].count -= count
		if inventory[index].count == 0:
			inventory.remove_at(index)
	pass

func has_entity_in_inventory(id : int, inventory : Array[inventory_entity]):
	var index = get_entity_index_in_array(id, inventory)
	return index != null
	pass


func add_object_to_player_inventory(id : int, count : int):
	var inventory = player.inventory
	var index = get_entity_index_in_array(id, inventory)
	if index != null:
		inventory[index].count += count
	else:
		var new_inventory_object = inventory_entity.new(id, count)
		inventory.append(new_inventory_object)
	Winhud.set_inventory(player.inventory)
	pass

func remove_object_from_player_inventory(id : int, count : int):
	var inventory = player.inventory
	var index = get_entity_index_in_array(id, inventory)
	if index != null:
		inventory[index].count -= count
		if inventory[index].count == 0:
			inventory.remove_at(index)
	Winhud.set_inventory(player.inventory)
	pass

func add_objects_to_inventory(recived_inventory : Array[inventory_entity], emmited_inventory : Array[inventory_entity]):
	for inv_obj in emmited_inventory:
		add_obj_to_inventory(inv_obj.id, inv_obj.count, recived_inventory)
	pass

func remove_objects_from_inventory(recived_inventory : Array[inventory_entity], emmited_inventory : Array[inventory_entity]):
	for inv_obj in emmited_inventory:
		remove_obj_from_inventory(inv_obj.id, inv_obj.count, recived_inventory)
	pass

func check_enough_resources_for_recipe(main_inventory : Array[inventory_entity], recipe_arr : Array[inventory_entity]) -> bool:
	var final_flag = true
	for recipe_res in recipe_arr:
		var index = get_entity_index_in_array(recipe_res.id, main_inventory)
		final_flag = final_flag && (index != null && main_inventory[index].count >= recipe_res.count)
	return final_flag
	pass

static func deep_copy(v): #Функция для дублирования объектов вроде словарей
	var t = typeof(v)

	if t == TYPE_DICTIONARY:
		var d = {}
		for k in v:
			d[k] = deep_copy(v[k])
		return d

	elif t == TYPE_ARRAY:
		var d = []
		d.resize(len(v))
		for i in range(len(v)):
			d[i] = deep_copy(v[i])
		return d

	elif t == TYPE_OBJECT:
		if v.has_method("duplicate"):
			return v.duplicate()
		else:
			print("Found an object, but I don't know how to copy it!")
			return v

	else:
		# Other types should be fine,
		# they are value types (except poolarrays maybe)
		return v
	pass

func get_entity_index_in_array(id : int, array : Array[inventory_entity]):
	var count = 0
	for entity in array:
		if int(entity.id) == int(id):
			return count
		count += 1
	return null
	pass

func get_map_position(node : Node2D) -> Vector2i:
	return MoveSystem.tilemap.local_to_map(MoveSystem.tilemap.to_local(node.global_position))
	pass

func get_global_position_by_map_position(map_position : Vector2i) -> Vector2:
	return MoveSystem.tilemap.to_global(MoveSystem.tilemap.map_to_local(map_position))
	pass
