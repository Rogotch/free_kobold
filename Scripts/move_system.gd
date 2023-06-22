extends Node

var tilemap : astar_map
var buildings       := {}
var global_objects  := {}
var conveyors       := {}
var resources       := {}

#var focused_cell : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_tilemap(new_tilemap : astar_map):
	tilemap = new_tilemap
	pass

func is_cell_near(start_point : Vector2i, end_point : Vector2i):
	return (end_point - start_point).length() == 1
	pass

func get_near_free_cell(point : Vector2i):
	var neighbors_cells = [Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP]
	for cell in neighbors_cells:
		var final_cell = cell + point
		if (tilemap.used_cells_base.has(final_cell) &&
			!tilemap.used_cells_objects.has(final_cell) &&
			!resources.has(final_cell) &&
			!buildings.has(final_cell)):
			return final_cell
	pass

func chaikin_algorithm_multiple_iterations(pointArr, iterationsCount : int):
	for i in iterationsCount:
		pointArr = chaikin_algorithm(pointArr)
	return pointArr
	pass

func chaikin_algorithm(pointArr):
	var newArr = []
	var count = 0
	newArr.append(pointArr[0])
	for i in pointArr.size():
		if count != pointArr.size() - 1:
			newArr.append((pointArr[i] / 4 * 3) + (pointArr[i + 1] / 4))
			newArr.append((pointArr[i] / 4) + (pointArr[i + 1] / 4 * 3))
		count += 1
	newArr.append(pointArr[count-1])
	return newArr
	pass

func delete_some_points(array, points_ind_in_position):
	var new_arr = [array[0]]
	var end_arr = array[-1]
	new_arr.append_array(Array(array).slice(0, array.size(), points_ind_in_position))
	new_arr.append(end_arr)
	return new_arr
	pass

func check_can_go_to_zone(start : Vector2i, end : Vector2i):
	var path =  MoveSystem.tilemap.get_global_path(start, end)
	var distance = Vector2(start).distance_to(Vector2(end))
	return distance == 1 || (path.size() != 0 && distance != 0)
	pass
