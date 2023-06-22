extends Control

@export var restart_button                  : TextureButton 
@export var close_button                    : TextureButton 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Winhud.pause(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
	_on_close_button_pressed()
	pass # Replace with function body.


func _on_close_button_pressed() -> void:
	Winhud.pause(false)
	queue_free()
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		_on_close_button_pressed()
	pass
