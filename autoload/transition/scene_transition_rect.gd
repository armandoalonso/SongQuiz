extends ColorRect

@export var next_scene: PackedScene

@onready var animation_player = $AnimationPlayer

func _ready():
	fade_out()

func transition_to(scene := next_scene) -> void:
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	# get_tree().unload_current_scene()
	get_tree().change_scene_to_packed(scene)
	
func fade_out() -> void:
	animation_player.play("fade")
