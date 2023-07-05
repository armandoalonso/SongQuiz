extends MarginContainer
class_name PlaylistItem

@onready var playlist_label: Label = $PlaylistPanel/MarginContainer/HBoxContainer/PlaylistName
@onready var start_button = $PlaylistPanel/MarginContainer/HBoxContainer/StartButton


var playlist_name: String
var playlist_id: String

func set_data(name: String, id: String):
	playlist_name = name
	playlist_id = id
	playlist_label.text = playlist_name

func disable_start_button():
	start_button.disabled = true

func _on_start_button_pressed():
	Global.start_game.emit(playlist_name, playlist_id)
