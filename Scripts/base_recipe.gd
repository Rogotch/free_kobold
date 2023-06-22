extends Control

@export var recipes            : HBoxContainer
@export var scroll_recipes     : ScrollContainer
@export var recipes_left       : TextureButton
@export var recipes_right      : TextureButton
@export var resources          : HBoxContainer
@export var final_result       : base_ui_cell
@export var title              : Label

@onready var resource_cell_class   = preload("res://Entities/base_ui_cell.tscn")
@onready var   recipe_cell_class   = preload("res://Entities/recipe_cell.tscn")

var building_obj
var recipe_inventory : Array[inventory_entity]
var selected_recipe_id : int
var ignore_drop_resources := false
var player_craft_flag := false

func _ready() -> void:
	SignalsBus.drop_resource_cell.connect(Callable(self, "drag_to_me"))
	SignalsBus.inventory_button_rmb.connect(Callable(self, "cell_rmb_click"))
	pass

func set_building_obj(new_bo):
	building_obj = new_bo
	building_obj.production_end.connect(Callable(self, "update_recipe"))
	building_obj.production_start.connect(Callable(self, "update_recipe"))
	pass

func _on_close_button_pressed() -> void:
	queue_free()
	pass # Replace with function body.

func load_recipes(building_id : int):
	var building_params = Database.get_obj_by_property_value_from_arr("id", building_id, Database.buildings)
	var recipes_id = building_params.recipes
	
	if player_craft_flag:
		var building_entity = Database.get_obj_by_property_value_from_arr("id", building_params.entity_id, Database.entities)
		title.text = building_entity.name
	else:
		title.text = "Craft"
		
	
	for id in recipes_id:
		var recipe_params = Database.get_obj_by_property_value_from_arr("id", id, Database.recipes)
		var new_recipe_cell = resource_cell_class.instantiate()
		new_recipe_cell.set_object_by_id(recipe_params.entity_id, recipe_params.count)
		recipes.add_child(new_recipe_cell)
		new_recipe_cell.cell_select.connect(press_recipe_button.bind(recipe_params.id, new_recipe_cell))
		new_recipe_cell.add_to_group("recipe_cells")
	
#	if recipes_id.size() > 5:
	recipes_left.visible  = recipes_id.size() > 5
	recipes_right.visible = recipes_id.size() > 5
	
	if recipes_id.size() == 1:
		recipes.visible = false
		press_recipe_button(true, recipes_id[0], recipes.get_child(0))
#		set_recipe(recipes_id[0])
	
	pass

func cell_rmb_click(resource_cell):
	var button_id = resource_cell.get_meta("id") if resource_cell.has_meta("id") else null
	if !ignore_drop_resources && button_id != null && Global.has_entity_in_inventory(button_id, recipe_inventory):
		var resorce_id = button_id
		
		var res_indx_plinv  = Global.get_entity_index_in_array(button_id, Global.player.inventory)
		var res_indx_recipe = Global.get_entity_index_in_array(button_id, recipe_inventory)
		var res_indx_build  = Global.get_entity_index_in_array(button_id, building_obj.inventory)
		
		var build_res_count = (building_obj.inventory[res_indx_build].count if res_indx_build != null else 0)
		
		var resorce_count = 0
#		print( building_obj.inventory[res_indx_build].count < recipe_inventory[res_indx_recipe])
#		resource_cell.cell_resource = null
#		if (building_obj.inventory[res_indx_build].count < recipe_inventory[res_indx_recipe]):
		if Global.player.inventory[res_indx_plinv].count >= (recipe_inventory[res_indx_recipe].count - build_res_count):
			resorce_count = recipe_inventory[res_indx_recipe].count - build_res_count
		else:
			resorce_count = Global.player.inventory[res_indx_plinv].count
		pass
		if resorce_count != 0:
			Winhud.play_sound("snd_pickup")
		
		Global.add_obj_to_inventory(resorce_id, resorce_count, building_obj.inventory)
#		Global.add_object_to_player_inventory(resorce_id, resorce_count)
		Global.remove_object_from_player_inventory(resorce_id, resorce_count)
#			print("intersects")
		set_recipe(selected_recipe_id)
		
		
	pass

func press_recipe_button(_flag, recipe_id, button):
	get_tree().call_group("recipe_cells", "select", false)
	button.call_deferred("select", _flag)
	if _flag:
		call_deferred("set_recipe", recipe_id)
#		set_recipe(recipe_id)
	else:
		Global.delete_children(resources)
	pass

func update_recipe():
	set_recipe(selected_recipe_id)
	pass

func set_recipe(recipe_id):
	var recipe_params = Database.get_obj_by_property_value_from_arr("id", recipe_id, Database.recipes)
	selected_recipe_id = recipe_id
	Global.delete_children(resources)
	recipe_inventory.clear()
	for req_res in recipe_params.ingredients:
#		var res_params = Database.get_obj_by_property_value_from_arr("id", recipe_id, Database.recipes)
		var building_inventory = building_obj.get_inventory()
		
		var not_empty_flag = building_inventory != null && building_inventory.size() > 0 
		var has_in_inventory_flag = Global.has_entity_in_inventory(req_res.entity_id, building_inventory)
		
		var new_resource_cell = recipe_cell_class.instantiate()
		var entity_index = Global.get_entity_index_in_array(req_res.entity_id, building_inventory)
		var res_count = 0
		if not_empty_flag && has_in_inventory_flag && entity_index != null:
			res_count = building_inventory[entity_index].count
		new_resource_cell.set_recipe_resource_by_id(req_res.entity_id, res_count, req_res.count)
		recipe_inventory.append(inventory_entity.new(req_res.entity_id, req_res.count))
#		new_resource_cell.set_object_by_id(req_res.entity_id, req_res.count)
		resources.add_child(new_resource_cell)
	building_obj.selected_recipe_resources = recipe_inventory
	building_obj.final_recipe_obj_id = recipe_params.id
	final_result.set_object_by_id(recipe_params.entity_id, recipe_params.count)
	pass

func drag_to_me(cell_rect : Rect2, resource_cell : base_ui_cell):
	if get_global_rect().intersects(cell_rect) && !building_obj.ignore_drag:
		if Global.has_entity_in_inventory(resource_cell.cell_resource.id, recipe_inventory):
			var resorce_id = resource_cell.cell_resource.id
			var resorce_count = resource_cell.cell_resource.count
			resource_cell.cell_resource = null
			Global.add_obj_to_inventory(resorce_id, resorce_count, building_obj.inventory)
#			print("intersects")
			set_recipe(selected_recipe_id)
			Winhud.play_sound("snd_drop")
#		else:
#
#			recipe_inventory.clear()
	pass

func start_work():
	building_obj.start_work()
	pass

func move_scroll(val):
	scroll_recipes
	var scroll_tween = create_tween()
	scroll_tween.tween_property(scroll_recipes, "scroll_horizontal", scroll_recipes.scroll_horizontal + 47 * val, 0.2)
	scroll_tween.play()
	pass

#func _input(event: InputEvent) -> void:
#	if event is InputEventMouseButton:
#		if ((event.button_index == MOUSE_BUTTON_LEFT || event.button_index == MOUSE_BUTTON_MASK_RIGHT) &&
#			!get_global_rect().has_point(get_global_mouse_position())):
#				_on_close_button_pressed()
#	pass


func _on_left_pressed() -> void:
	move_scroll(-1)
	pass


func _on_right_pressed() -> void:
	move_scroll(1)
	pass
