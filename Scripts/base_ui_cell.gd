extends Control
class_name base_ui_cell

signal cell_select(flag)
signal cell_select_alternative(flag)
signal start_drag(drag_offset)

@export var counter_label      : Label
@export var name_label         : Label
@export var icon               : TextureRect
@export var dragable           := true
@export var selectable         := true
@export var start_select_flag  := false

const DETECTING_DISTANCE = 15

var selected := false

var start_detecting_drag := false
var detected_drag := false
var start_detect_point : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	select(start_select_flag)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_inventory_object(inventory_object : inventory_entity):
	set_object_by_id(inventory_object.id, inventory_object.count)
	pass

func set_object_by_id(id : int, count : int):
	var object_params = Database.get_obj_by_property_value_from_arr("id", id, Database.entities)
	set_texture_name_count(load(object_params.icon_path), object_params.name, count)
	pass

func set_texture_name_count(texture : Texture2D, new_name : String, count : int):
	icon.texture = texture
	name_label.text = new_name
	counter_label.text = str(count)
	pass

func select(flag):
	selected = flag
	if flag:
		modulate = Color.WHITE
	else:
		modulate = Color.GRAY
	pass

#func _unhandled_input(event: InputEvent) -> void:
#
#	pass


func _on_input_detector_pressed() -> void:
	if !selectable:
		return
	Winhud.play_sound("snd_button")
	emit_signal("cell_select", !selected)
	select(!selected)
	pass # Replace with function body.

func alternative_select():
	if !selectable || !dragable:
		return
	Winhud.play_sound("snd_button")
#	emit_signal("cell_select_alternative", !selected)
	SignalsBus.inventory_button_rmb.emit(self)
	select(true)
	pass

func clear():
	icon.texture = null
	name_label.text = ""
	counter_label.text = str(0)
	select(false)
	pass

func _input(event: InputEvent) -> void:
	if !dragable:
		return
	if event is InputEventMouseButton:
		if event.pressed && get_global_rect().has_point(get_global_mouse_position()):
			start_detect_point = get_global_mouse_position()
			start_detecting_drag = true
		elif !event.pressed:
			detected_drag = false
			start_detecting_drag = false
	if event is InputEventMouseMotion:
		if (!detected_drag &&
			start_detecting_drag &&
			start_detect_point.distance_to(get_global_mouse_position()) > DETECTING_DISTANCE):
			start_drag.emit(get_local_mouse_position())
#			print("drag!")
			detected_drag = true
			start_detecting_drag = false
	pass


func _on_input_detector_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
			alternative_select()
	pass # Replace with function body.
