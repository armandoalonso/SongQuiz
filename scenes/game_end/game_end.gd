extends VBoxContainer

@export var playlist_menu = preload("res://scenes/playlist_menu/playlist_menu.tscn")
@onready var player_one_label = $PlayerScoreContainer/RoundInfoContainer/PlayerLabel
@onready var player_two_label = $PlayerScoreContainer2/RoundInfoContainer/PlayerLabel
@onready var player_1_score = $PlayerScoreContainer/RoundInfoContainer/Player1Score
@onready var player_2_score = $PlayerScoreContainer2/RoundInfoContainer/Player2Score

func _ready():
	SceneTransition.fade_out()
	player_one_label.text = Global.player_one_name
	player_two_label.text = Global.player_two_name
	player_1_score.text = str(Global.player_one_score)
	player_2_score.text = str(Global.player_two_score)


func _on_replay_button_pressed():
	SceneTransition.transition_to(playlist_menu)
