extends base_entity
class_name inventory_entity

enum ENTITY_TYPE {BUILDING, RESOURCE}
@export var count : int
var type : ENTITY_TYPE

func _init(id, new_count) -> void:
	super._init(id)
	count = new_count
	pass

func load_entity(new_id):
	id = new_id
	var entity_params = Database.get_obj_by_property_value_from_arr("id", new_id, Database.entities)
	icon = load(entity_params.icon_path)
	name = entity_params.name
	entity_path = entity_params.entity_path
	description = entity_params.description
	type = ENTITY_TYPE.BUILDING if entity_params.is_building else ENTITY_TYPE.RESOURCE
	
	if entity_params.is_building:
		building_path = entity_params.building_path
	pass
