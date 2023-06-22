extends TileMap
class_name astar_map
signal focus_cell(cell)

@onready var astar = AStar2D.new()
@onready var used_cells_base    = get_used_cells(0)
@onready var used_cells_objects = get_used_cells(2)

var path : PackedVector2Array
var selected_cell = null
var focused_cell : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	MoveSystem.tilemap = self
	_add_points()
	connect_points()
	set_obstancles()
	get_tree().call_group("tile_objects", "set_tile_position")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _add_points():
	for cell in used_cells_base:
		astar.add_point(id(cell), cell)
	pass

func connect_points():
	for cell in used_cells_base:
		var neighbors = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
		for neighbor in neighbors:
			var next_cell = cell + Vector2i(neighbor)
			if used_cells_base.has(next_cell):
				astar.connect_points(id(cell), id(next_cell), false)
	pass


func set_obstancles():
	for cell in used_cells_objects:
#		var cell_data = get_cell_tile_data(1, cell)
#		if cell_data.get_custom_data("obstacle"):
		astar.set_point_disabled(id(cell), true)
	pass

func block_point(point : Vector2i, flag : bool):
	astar.set_point_disabled(id(point), flag)
	pass

func _get_path(start, end) -> PackedVector2Array:
#	prints("start", start, "end", end)
	var final_id = id(end)
	if astar.is_point_disabled(final_id):
		final_id = astar.get_closest_point(end)
#		print(final_id)
	path = astar.get_point_path(id(start), final_id)
	if path.size() > 0:
		path.remove_at(0)
	return path
	pass

func get_global_path(start, end) -> PackedVector2Array:
	var map_path = _get_path(start, end)
	var world_path : PackedVector2Array
	for path_point in map_path:
		world_path.append(to_global(map_to_local(path_point)))
	return world_path
	pass

func get_global_path_to_nearest(start, end) -> PackedVector2Array:
	var map_path = _get_path(start, end)
	var world_path : PackedVector2Array
	for path_point in map_path:
		world_path.append(to_global(map_to_local(path_point)))
	return world_path
	pass

func id(point):
#	prints("point", point)
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b
	pass

func is_object_cell_free(cell : Vector2i):
	if used_cells_base.has(cell):
		return !used_cells_objects.has(cell)
#			var cell_data = get_cell_tile_data(1, cell)
#			return cell_data.get_custom_data("buildable")
#		else:
#			return true
	else:
		return false
	pass

#func add_box(cell : Vector2i):
#	set_cell(1, cell, 3, Vector2i(14, 15))
#	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var _focused = local_to_map(to_local(get_global_mouse_position()))
		if _focused != focused_cell:
			focused_cell = _focused
			emit_signal("focus_cell", focused_cell)
		pass
