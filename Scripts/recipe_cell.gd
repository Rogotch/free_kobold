extends base_ui_cell

@export var line_2d            : Line2D


func select(_flag):
	pass

#func draw_line_to_target(target_node):
#	var points : PackedVector2Array
#
#	pass

func set_recipe_resource_by_id(id : int, count_have : int, count_need : int):
	var object_params = Database.get_obj_by_property_value_from_arr("id", id, Database.entities)
	icon.texture = load(object_params.icon_path)
	name_label.text = object_params.name
	counter_label.text = str(count_have) + "/" + str(count_need)
	pass
