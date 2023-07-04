extends TextureRect

func _ready():
	var tw = create_tween().set_loops()
	tw.tween_property(self, "rotation_degrees", 360, 2).from_current()
	tw.tween_interval(0.01)
