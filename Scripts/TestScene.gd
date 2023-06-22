extends Node2D

@export var tile_map : astar_map
#@onready var tile_map = $tile_map


func _ready():
	pass


func _process(delta):
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT && tile_map.used_cells_base.has(tile_map.focused_cell):
#			SignalsBus.emit_signal("select_cell", tile_map.local_to_map(get_global_mouse_position()))
			SignalsBus.emit_signal("select_cell", tile_map.local_to_map(to_local(get_global_mouse_position())))
#			print(tile_map.local_to_map(get_global_mouse_position()))
	pass
