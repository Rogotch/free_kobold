extends StaticBody2D

@export var type     : resource_object.RES_TYPE
@export var count    : int
@export var counter  : Label
@export var hided_counter  : bool

var tile_position : Vector2i
var resource : resource_object 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("deposits_resources")
	add_to_group("tile_objects")
	resource = resource_object.new(type, resource_object.get_id_by_type(type))
	update_counter()
	pass # Replace with function body.

func set_tile_position():
	tile_position = MoveSystem.tilemap.local_to_map(MoveSystem.tilemap.to_local(global_position))
#	tile_position = MoveSystem.tilemap.local_to_map(position)
	position = MoveSystem.tilemap.map_to_local(tile_position)
	MoveSystem.tilemap.block_point(tile_position, true)
	MoveSystem.resources[tile_position] = self
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func check_condition():
	if count == 0:
		if !MoveSystem.buildings.has(tile_position):
			MoveSystem.tilemap.block_point(tile_position, false)
		MoveSystem.resources.erase(tile_position)
		queue_free()
	pass

func update_counter():
	counter.text = str(count)
	pass

func decrease_resources(value):
	count -= value
	update_counter()
	check_condition()
	pass

func show_counter_label(flag : bool):
	if !hided_counter:
		counter.visible = flag
	pass
