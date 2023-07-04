@tool
extends Panel

signal update_playlist

@export var header_text: String = "Playlist"
@export var show_download_button: bool = false

@onready var label = $MarginContainer/HBoxContainer/Label
@onready var update_playlist_button = $MarginContainer/HBoxContainer/HBoxContainer/UpdatePlaylistButton

func _ready():
	label.text = header_text
	update_playlist_button.disabled = !show_download_button
	update_playlist_button.visible = show_download_button

func _on_exit_button_pressed():
	get_tree().quit()

func _on_update_playlist_button_pressed():
	update_playlist.emit()
