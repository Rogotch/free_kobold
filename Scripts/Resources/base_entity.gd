extends Resource

class_name base_entity

@export var icon                       : Texture2D
@export_file("*.tscn") var entity_path : String
@export var name                       : String
@export_multiline var description      : String
var id : int
var building_path : String

func _init(new_id) -> void:
	load_entity(new_id)
	pass

func load_entity(new_id):
	id = new_id
	var entity_params = Database.get_obj_by_property_value_from_arr("id", new_id, Database.entities)
	icon = load(entity_params.icon_path)
	name = entity_params.name
	entity_path = entity_params.entity_path
	description = entity_params.description
	if entity_params.is_building:
		building_path = entity_params.building_path
	pass
