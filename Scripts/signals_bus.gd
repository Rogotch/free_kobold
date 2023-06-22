extends Node

signal select_cell(cell)
signal inventory_button_rmb(inventory_cell)
signal player_on_cell(cell)
signal drop_resource_cell(cell_rect, resource_cell)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("show_info"):
		get_tree().call_group("deposits_resources", "show_counter_label", true)
	if Input.is_action_just_released("show_info"):
		get_tree().call_group("deposits_resources", "show_counter_label", false)
	pass
