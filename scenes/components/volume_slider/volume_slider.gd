extends HSlider

@export var audio_bus_name: String = "Master"

@onready
var _bus = AudioServer.get_bus_index(audio_bus_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	# using linear scale 0-1
	#value = db_to_linear(AudioServer.get_bus_volume_db(_bus))
	value = AudioServer.get_bus_volume_db(_bus)

func _on_value_changed(value):
	# using linear scale 0-1
	if(value < -11):
		var zero_volume = linear_to_db(0)
		AudioServer.set_bus_volume_db(_bus, zero_volume)
	else:
		AudioServer.set_bus_volume_db(_bus, value)

func _on_mouse_exited():
	self.release_focus()
