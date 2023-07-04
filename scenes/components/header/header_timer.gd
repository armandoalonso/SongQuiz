extends Panel
class_name HeaderTimer

signal time_expired

@onready var label: Label = $MarginContainer/HBoxContainer/Label
@onready var timer = $Timer

var current_time: int

func _ready():
	label.text = str(current_time)

func _on_timer_timeout():
	current_time = current_time - 1
	
	if current_time < 0:
		time_expired.emit()
	else:
		label.text = str(current_time)
		timer.start(1)

func start():
	timer.start(1)
	
func _on_exit_button_pressed():
	get_tree().quit()
	
func set_time(time: int):
	current_time = time
	label.text = str(current_time)
