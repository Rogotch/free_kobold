extends craft_building
class_name player_craft


func press():
	pass

func get_inventory():
	return get_player_inventory()
	pass

func start_work():
	if (selected_recipe_resources.size() > 0 && !working_flag &&
		Global.check_enough_resources_for_recipe(get_player_inventory(), selected_recipe_resources)):
		working_flag = true
		var production_tween = create_tween()
		production_tween.tween_interval(production_time)
		production_tween.tween_callback(Callable(self, "production"))
		production_tween.play()
		emit_signal("production_start")
		Global.remove_objects_from_inventory(get_player_inventory(), selected_recipe_resources)
	pass

func production():
	var recipes_params         = Database.get_obj_by_property_value_from_arr("id", final_recipe_obj_id, Database.recipes)
#	var resource_entity_params = Database.get_obj_by_property_value_from_arr("id", recipes_params.entity_id, Database.entities)
	
	emit_signal("production_end")
	Global.add_object_to_player_inventory(recipes_params.entity_id, recipes_params.count)
#	new_resource_obj.type = MoveSystem.resources[tile_position].type
	Winhud.play_sound("snd_drop")
	working_flag = false
	pass

func connect_to_tilemap():
	pass

func focused(_cell : Vector2i):
	pass

func get_player_inventory() -> Array[inventory_entity]:
	return Global.player.inventory
	pass
