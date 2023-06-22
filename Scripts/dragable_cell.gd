extends base_ui_cell

var draging := false
var offset  : Vector2
var cell_resource : set = set_cell_resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	select(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_cell_resource(new_cell_resource):
	if new_cell_resource != null:
		cell_resource = new_cell_resource
		set_object_by_id(cell_resource.id, cell_resource.count)
	else:
		cell_resource = null
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if draging:
			global_position = get_global_mouse_position() - offset
	if event is InputEventMouseButton:
		if !event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			drop_me()
	pass

func set_dragable(flag : bool, drag_offset : Vector2 = Vector2.ZERO):
	draging = flag
	offset = drag_offset
	if flag:
		global_position = get_global_mouse_position() - offset
	pass

func drop_me():
	set_dragable(false)
	SignalsBus.drop_resource_cell.emit(get_global_rect(), self)
	call_deferred("delete_cell")
	pass

func delete_cell():
#	cell_resource = null
	if cell_resource != null:
		Global.add_object_to_player_inventory(cell_resource.id, cell_resource.count)
#		print("i was added to inventory")
#	print("i was deleted")
	call_deferred("queue_free")
#	queue_free()
	pass
