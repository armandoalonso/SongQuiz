extends Control

@onready var spectrum = AudioServer.get_bus_effect_instance(1,0)

@onready var bottomRightArray = $Right/Bottom.get_children()
@onready var topRightArray = $Right/Top.get_children()
@onready var bottomLeftArray = $Left/Bottom.get_children()
@onready var topLeftArray = $Left/Top.get_children()

const VU_COUNT = 12
const HEIGHT = 350
const FREQ_MAX = 11050.0
 
const MIN_DB = 60


func _ready():
	bottomLeftArray.reverse()
	topLeftArray.reverse()


func _process(delta):
	var prev_hz = 0
	for i in range(1,VU_COUNT+1):   
		var hz = i * FREQ_MAX / VU_COUNT;
		var f = spectrum.get_magnitude_for_frequency_range(prev_hz,hz)
		var energy = clamp((MIN_DB + linear_to_db(f.length()))/MIN_DB,0,1)
		var height = energy * HEIGHT

		prev_hz = hz
		var bottomRightRect = bottomRightArray[i - 1]
		var topRightRect = topRightArray[i - 1]
		var topLeftRect = topLeftArray[i - 1]
		var bottomLeftRect = bottomLeftArray[i - 1]
		var tween = get_tree().create_tween()

		tween.tween_property(topRightRect, "size", Vector2(topRightRect.size.x, height), 0.05)
		tween.tween_property(bottomRightRect, "size", Vector2(bottomRightRect.size.x, height), 0.05)
		tween.tween_property(topLeftRect, "size", Vector2(topLeftRect.size.x, height), 0.05)
		tween.tween_property(bottomLeftRect, "size", Vector2(bottomLeftRect.size.x, height), 0.05)
