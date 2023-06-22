extends CanvasLayer

@export var item_list: ItemList
@export var dragable_cells: CanvasLayer

@export var left_inventory     : Control
@export var top_inventory      : Control
@export var right_inventory    : Control

@onready var left_inventory_cells    = left_inventory.get_node("container")
@onready var top_inventory_cells     = top_inventory.get_node("container")
@onready var right_inventory_cells   = right_inventory.get_node("container")
@onready var dragable_cell_class  = preload("res://Entities/dragable_cell.tscn")

var selected_id = null
var selected_building = null
var inventory : Array[inventory_entity]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_inventory()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
#	item_list.deselect_all()
#	if selected_building != null:
#		selected_building.queue_free()
#	if selected_index == null || selected_index != index:
##		prints("selected", recipes[index].name)
#		selected_index = index
#		item_list.select(index)
#		if recipes[index].type == inventory_entity.ENTITY_TYPE.BUILDING:
#			load_building(index)
#	elif selected_index == index:
#		selected_index = null
#		Global.change_action_mode(Global.ACTION_MODES.MOVE)
#	pass # Replace with function body.

func init_inventory():
#	item_list.clear()
	var all_cells := []
	all_cells.append_array(left_inventory_cells.get_children())
	all_cells.append_array(right_inventory_cells.get_children())
	all_cells.append_array(top_inventory_cells.get_children())
	
	var counter = 0
	for inv_cell in all_cells:
		inv_cell.add_to_group("inventory_cells")
		inv_cell.cell_select.connect(on_button_select.bind(inv_cell))
		inv_cell.start_drag.connect(drag_cell.bind(inv_cell))
	pass

func drag_cell(drag_offset, button):
	var button_id = button.get_meta("id") if button.has_meta("id") else null
	if button_id != null:
		Winhud.play_sound("snd_pickup")
		var new_dragable_cell = dragable_cell_class.instantiate()
		dragable_cells.add_child(new_dragable_cell)
		new_dragable_cell.set_dragable(true, drag_offset)
		var obj_index = Global.get_entity_index_in_array(button_id, Global.player.inventory)
		var entities_count = Global.player.inventory[obj_index].count
		var req_count = entities_count
		
		if Global.pressed_ctrl_flag:
			req_count = 1
		elif Global.pressed_shift_flag:
			req_count = 10
		
		if entities_count < req_count:
			req_count = entities_count
		
		new_dragable_cell.cell_resource = inventory_entity.new(button_id, req_count)
		Global.player.remove_from_inventory(button_id, req_count)
		pass
	pass

func set_inventory(inventory_arr : Array[inventory_entity]):
#Сюда засунуть сортировку
#2, 8, 0, 4, 5, 6, 7 - наверх
#1, 9, 10, 11, 12, 13, 15, 14, 18, 16, 19, 17 - налево
#100-111 - направо
#	item_list.clear()
	inventory = inventory_arr
	var top_list_ids = [2, 8, 0, 4, 5, 6, 7]
	var left_list_ids = [1, 9, 10, 11, 12, 13, 15, 14, 18, 16, 19, 17]
	var right_list_ids = [100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111]
	set_inventory_data(left_inventory_cells,  inventory_arr, left_list_ids)
	set_inventory_data(right_inventory_cells, inventory_arr, right_list_ids)
	set_inventory_data(top_inventory_cells,   inventory_arr, top_list_ids)
#
#	var counter = 0
#	for inv_cell in all_cells:
#		if inventory_arr.size() > counter:
#			var inv_obj = inventory_arr[counter]
#			inv_cell.set_texture_name_count(inv_obj.icon, inv_obj.name, inv_obj.count)
#			inv_cell.set_meta("id", inv_obj.id)
#		else:
#			inv_cell.clear()
#			inv_cell.remove_meta("id")
#		counter += 1
#	for inv_obj in iventory_arr:
#		item_list.add_item(inv_obj.name + " x" + str(inv_obj.count), inv_obj.icon)
	pass

func set_inventory_data(inventory_container : Node, inventory_arr : Array[inventory_entity], filter_arr : Array):
	var filtered_indexes := []
	var all_cells = inventory_container.get_children()
	
	for filter_id in filter_arr:
		var index = Global.get_entity_index_in_array(filter_id, inventory_arr)
		if index != null:
			filtered_indexes.append(index)
	
	var counter := 0
	for cell in all_cells:
		if filtered_indexes.size() > counter:
			var inv_obj = inventory_arr[filtered_indexes[counter]]
			cell.set_texture_name_count(inv_obj.icon, inv_obj.name, inv_obj.count)
			cell.set_meta("id", inv_obj.id)
		else:
			cell.clear()
			cell.remove_meta("id")
		counter += 1
		
	pass

func on_button_select(select_flag : bool, button):
	get_tree().call_group("inventory_cells", "select", false)
	var button_id = button.get_meta("id") if button.has_meta("id") else null
	prints(selected_id == null, selected_id != button_id, button_id != null)
	if selected_building != null:
		selected_building.queue_free()
	if (selected_id == null || selected_id != button_id) && button_id != null:
#		prints("selected", recipes[index].name)
		selected_id = button_id
		button.call_deferred("select", true)
		var button_index = get_index_by_id(button_id)
		if inventory[button_index].type == inventory_entity.ENTITY_TYPE.BUILDING:
			load_building(button_index)
	elif selected_id == button_id:
		selected_id = null
		button.call_deferred("select", false)
#		button.select(false)
#		button.clear()
		Global.change_action_mode(Global.ACTION_MODES.MOVE)
	pass
#func clear_inventory():
#	pass

func load_building(index : int):
#	prints("building_path", recipes[index].building_path, recipes[index].type == inventory_entity.ENTITY_TYPE.RESOURCE)
	var new_building = load(inventory[index].building_path).instantiate()
	MoveSystem.tilemap.add_child(new_building)
	selected_building = new_building
	new_building.select()
	Global.change_action_mode(Global.ACTION_MODES.BUILD)
	
	pass

func build():
	
#	var building_params = Database.get_obj_by_property_value_from_arr("id", selected_building.entity_id, Database.buildings)
#	var building_entity = Database.get_obj_by_property_value_from_arr("id", building_params.entity_id, Database.entities)
	Global.remove_object_from_player_inventory(selected_building.entity_id, 1)
	selected_building = null
	selected_id = null
#	item_list.deselect_all()
	Global.call_deferred("change_action_mode", Global.ACTION_MODES.MOVE)
	
	get_tree().call_group("inventory_cells", "select", false)
#	Global.change_action_mode(Global.ACTION_MODES.MOVE)
	pass


func _on_mining_button_pressed() -> void:
	Winhud.play_sound("snd_button")
	Global.change_action_mode(Global.ACTION_MODES.MINING)
	pass # Replace with function body.

func get_index_by_id(id : int):
	var counter = 0
	for inv_obj in inventory:
		if inv_obj.id == id:
			return counter
		counter += 1
	return null
	pass


func _on_destroy_button_pressed() -> void:
	Winhud.play_sound("snd_button")
	Global.change_action_mode(Global.ACTION_MODES.DESTRUCTION)
	pass # Replace with function body.

func clear_active_building():
	selected_building.queue_free()
	call_deferred("clear_building_variables")
	Global.call_deferred("change_action_mode", Global.ACTION_MODES.MOVE)
	get_tree().call_group("inventory_cells", "select", false)
	pass

func clear_building_variables():
	selected_building = null
	selected_id = null
	pass

#func _input(event: InputEvent) -> void:
#	if event is InputEventMouseButton:
#		if event.pressed && event.button_index == MOUSE_BUTTON_RIGHT && selected_building != null:
#			clear_active_building()
#	pass
