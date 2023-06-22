extends Resource
class_name resource_object
enum RES_TYPE {stone, water, grass, earth, wood, coal, iron_ore, gold_ore, clay,
brick, vessel, rope, cloth, iron_bar, gold_bar, steel_bar, hammer, gear, bellows,
Mower, Digger, Miner, Workshop, Loom, Kiln, Water_pump, Pottery, Conveyor, Foundry, Smithy, Shredder}

@export var type  : RES_TYPE
@export var resource_entity : base_entity
var id : int

func _init(selected_type : RES_TYPE, res_id : int) -> void:
	load_resource_by_type(selected_type, res_id)
	pass

func load_resource_by_type(selected_type : RES_TYPE, res_id : int):
#	else:
	resource_entity = base_entity.new(res_id)
	id = res_id
	pass

static func get_id_by_type(selected_type):
	var type_string := ""
	match selected_type:
		RES_TYPE.stone:
			type_string = "stone"
		RES_TYPE.water:
			type_string = "water"
		RES_TYPE.grass:
			type_string = "grass"
		RES_TYPE.earth:
			type_string = "earth"
		RES_TYPE.wood:
			type_string = "wood"
		RES_TYPE.coal:
			type_string = "coal"
		RES_TYPE.iron_ore:
			type_string = "iron_ore"
		RES_TYPE.gold_ore:
			type_string = "gold_ore"
		RES_TYPE.clay:
			type_string = "clay"
		RES_TYPE.brick:
			type_string = "brick"
		RES_TYPE.vessel:
			type_string = "vessel"
		RES_TYPE.rope:
			type_string = "rope"
		RES_TYPE.cloth:
			type_string = "cloth"
		RES_TYPE.iron_bar:
			type_string = "iron_bar"
		RES_TYPE.gold_bar:
			type_string = "gold_bar"
		RES_TYPE.steel_bar:
			type_string = "steel_bar"
		RES_TYPE.hammer:
			type_string = "hammer"
		RES_TYPE.gear:
			type_string = "gear"
		RES_TYPE.bellows:
			type_string = "bellows"
	var resource_params = Database.get_obj_by_property_value_from_arr("type", type_string, Database.resources)
#	resource_entity = base_entity.new(resource_params.entity_id)
	return resource_params.entity_id
	pass
