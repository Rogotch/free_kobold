extends base_building
class_name mine_building

@export var types_of_resource  : Array[resource_object.RES_TYPE]

func production():
	var resource_deposit = MoveSystem.resources[tile_position]
	var new_resource_obj = load(resource_deposit.resource.resource_entity.entity_path).instantiate()
	MoveSystem.tilemap.add_child(new_resource_obj)
	
	new_resource_obj.type = MoveSystem.resources[tile_position].type
	new_resource_obj.count = 1
	
	new_resource_obj.load_resource()
	
	emit_signal("production_end")
	MoveSystem.resources[tile_position].decrease_resources(1)
	Winhud.play_sound("snd_pickup")
	rng.randomize()
	var random_offset = (Vector2(rng.randf_range(-1.0,1.0), rng.randf_range(-1.0,1.0)) * 7)
	new_resource_obj.global_position = Global.get_global_position_by_map_position(drop_cell) + random_offset
	new_resource_obj.scale *= rng.randf_range(0.6, 1.2)
	start_work()
	pass

func start_work():
	if (MoveSystem.resources.has(tile_position) &&
		types_of_resource.has(MoveSystem.resources[tile_position].type) &&
		MoveSystem.resources[tile_position].count > 0):
		if !working:
			off_sprite.visible = false
			on_anim.visible = true
			on_anim.frame = 0
			on_anim.play("production")
			working = true
		Winhud.play_sound("snd_work")
		var production_tween = create_tween()
		production_tween.tween_interval(production_time)
		production_tween.tween_callback(Callable(self, "production"))
		production_tween.play()
	else:
		off_sprite.visible = true
		on_anim.visible = false
		on_anim.stop()
		working = false
	pass

func is_can_build() -> bool:
	var wr_flag := true
	
	if MoveSystem.resources.has(tile_position):
		var wr = weakref(MoveSystem.resources[tile_position])
		wr_flag = wr.get_ref() != null
	
	var final_flag = (super.is_can_build() && wr_flag && 
	MoveSystem.resources.has(tile_position) &&
	types_of_resource.has(MoveSystem.resources[tile_position].type))
	return final_flag
	pass

func builded():
	super.builded()
	start_work()
	pass
