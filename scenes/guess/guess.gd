extends VBoxContainer

@export var game_scene: PackedScene = preload("res://scenes/game/game.tscn")
@export var game_over_scene: PackedScene = preload("res://scenes/game_end/game_end.tscn")

@onready var answer_label: Label = $AnswerLabel
@onready var correct_artist_toggle = $CorrectArtistMargin/CorrectArtistToggle
@onready var correct_song_toggle = $CorrectSongMargin/CorrectSongToggle

func _ready():
	SceneTransition.fade_out()
	answer_label.text = Global.get_current_song_title()

func _on_next_turn_button_pressed():
	Global.add_score_to_current_player(correct_song_toggle.button_pressed, correct_artist_toggle.button_pressed)
	Global.next_turn()
	
	if Global.game_over:
		SceneTransition.transition_to(game_over_scene)
	else:
		SceneTransition.transition_to(game_scene)


func _on_open_web_button_pressed():
	# use os to open youtube
	var url = Global.get_current_song_url()
	OS.shell_open(url)
