extends base_building
class_name craft_building

@export var building_id : int
@export var ignore_drag := false
var working_flag := false

#var inventory : set = set_inventory, get = get_inventory
var selected_recipe_resources : Array[inventory_entity]
var final_recipe_obj_id : int

#func  _ready() -> void:
#	super._ready()
#	inventory = []
#	pass

func press():
	if !selecting:
#		var wr = weakref(self);
#		if (!wr.get_ref()):
#			return
		Winhud.show_building_recipes(building_id, self)
	pass

#func set_inventory(new_inventory):
#	inventory = new_inventory
#	pass
#
func get_inventory():
	if inventory == null:
		inventory = []
	return inventory
	pass

func start_work():
	if (selected_recipe_resources.size() > 0 && !working_flag &&
		Global.check_enough_resources_for_recipe(inventory, selected_recipe_resources)):
		working_flag = true
		off_sprite.visible = false
		on_anim.visible = true
		on_anim.frame = 0
		on_anim.play("production")
		Winhud.play_sound("snd_work")
		var production_tween = create_tween()
		production_tween.tween_interval(production_time)
		production_tween.tween_callback(Callable(self, "production"))
		production_tween.play()
	else:
		off_sprite.visible = true
		on_anim.visible = false
		on_anim.stop()
	pass

func production():
	var recipes_params         = Database.get_obj_by_property_value_from_arr("id", final_recipe_obj_id, Database.recipes)
	var resource_entity_params = Database.get_obj_by_property_value_from_arr("id", recipes_params.entity_id, Database.entities)
	var new_resource_obj = load(resource_entity_params.entity_path).instantiate()
	
	MoveSystem.tilemap.add_child(new_resource_obj)
	Global.remove_objects_from_inventory(inventory, selected_recipe_resources)
#	new_resource_obj.type = MoveSystem.resources[tile_position].type
	new_resource_obj.count = recipes_params.count
	
	new_resource_obj.load_resource()
	
	emit_signal("production_end")
	Winhud.play_sound("snd_pickup")
	new_resource_obj.global_position = Global.get_global_position_by_map_position(drop_cell)
	working_flag = false
	start_work()
	pass
