extends Camera3D
@export var fov_setting = 90.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#zooming()
	pass
		
func zoom(zoom):
	var tween = get_tree().create_tween()
	tween.tween_property($".", "fov", fov_setting * zoom, 0.06)
func unzoom():
	var tween = get_tree().create_tween()
	tween.tween_property($".", "fov", fov_setting, 0.06)
