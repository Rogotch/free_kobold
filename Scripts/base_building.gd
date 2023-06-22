extends StaticBody2D
class_name base_building

signal production_end
signal production_start

@export var entity_id : int
@export_range(0.1, 10, 0.1) var production_time := 1.0
@export var off_sprite: Sprite2D
@export var on_anim: AnimatedSprite2D
@export var immediatle_build: bool

var inventory : Array[inventory_entity]
var tile_position : Vector2i
var selecting := false
var shader_material : ShaderMaterial
var rng = RandomNumberGenerator.new()
var drop_cell : Vector2i
var working := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shader_material = get_material()
	call_deferred("connect_to_tilemap")
	
	pass # Replace with function body.

func connect_to_tilemap():
	MoveSystem.tilemap.focus_cell.connect(Callable(self, "focused"))
	if immediatle_build:
		set_tile_position()
		build()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#	print(selecting,
#		Global.action_mode == Global.ACTION_MODES.BUILD,
#		tile_position != MoveSystem.tilemap.focused_cell)
	if (selecting &&
		Global.action_mode == Global.ACTION_MODES.BUILD &&
		tile_position != MoveSystem.tilemap.focused_cell):
#		set_tile_position()
		set_on_tile_position(MoveSystem.tilemap.focused_cell)
		if is_can_build():
			modulate = Color.GREEN
		else:
			modulate = Color.RED 
	pass

func set_tile_position():
	tile_position = Global.get_map_position(self)
	drop_cell = MoveSystem.get_near_free_cell(tile_position)
#	tile_position = MoveSystem.tilemap.local_to_map(position)
	pass

func set_on_tile_position(new_tile_position : Vector2i):
	tile_position = new_tile_position
#	print(new_tile_position)
	global_position = Global.get_global_position_by_map_position(tile_position)
	pass

func select():
	set_selecting(true)
	z_index = 10
	pass

func is_can_build() -> bool:
	var flag_move = (MoveSystem.check_can_go_to_zone(Global.player.tile_position, MoveSystem.tilemap.focused_cell))
#	var wr = weakref(holder)
#	set_on_tile_position(Global.get_map_position(self))
	return flag_move && MoveSystem.tilemap.is_object_cell_free(MoveSystem.tilemap.focused_cell) && !MoveSystem.buildings.has(tile_position)
	pass

func build():
	MoveSystem.buildings[tile_position] = self
	MoveSystem.tilemap.block_point(tile_position, true)
	Winhud.play_sound("snd_tool")
	call_deferred("set_selecting", false)
#	selecting = false
	z_index = 0
	modulate = Color.WHITE
	builded()
	pass

func set_selecting(flag : bool):
	selecting = flag
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			if selecting:
#				print("check")
				if is_can_build():
					build()
					Winhud.ui.build()
				else:
					Winhud.ui.clear_active_building()
	pass

func delete():
	
	pass

func production():
	pass

func builded():
	set_tile_position()
	pass

func focused(cell : Vector2i):
#	if cell != tile_position:
#		shader_material.set_shader_parameter("width", 0.0)
#	else:
#		shader_material.set_shader_parameter("width", 1.0)
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT && Global.action_mode != Global.ACTION_MODES.DESTRUCTION:
#			call_deferred("press")
			press()
			pass
	pass # Replace with function body.

func press():
	pass

func crash_me():
	MoveSystem.buildings.erase(tile_position)
	if !MoveSystem.resources.has(tile_position):
		MoveSystem.tilemap.block_point(tile_position, false)
	queue_free()
	pass
