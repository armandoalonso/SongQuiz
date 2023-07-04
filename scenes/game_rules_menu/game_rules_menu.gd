extends VBoxContainer

@export var game_scene: PackedScene = preload("res://scenes/game/game.tscn")

#sliders
@onready var rounds_slider = $GameRuleContainer/VBoxContainer/RoundsSlider
@onready var time_limit_slider = $GameRuleContainer/VBoxContainer/TimeLimitSlider
@onready var clip_length_slider = $GameRuleContainer/VBoxContainer/ClipLengthSlider
#labels
@onready var rounds_active = $GameRuleContainer/VBoxContainer/RoundsContainer/RoundsActive
@onready var time_limit_active = $GameRuleContainer/VBoxContainer/TimeLimitContainer/TimeLimitActive
@onready var clip_length_active = $GameRuleContainer/VBoxContainer/ClipLengthContainer/ClipLengthActive
#toggles
@onready var score_increase_toggle = $GameRuleContainer/VBoxContainer/ScoreIncreaseContainer/ScoreIncreaseToggle
@onready var bonus_rounds_toggle = $GameRuleContainer/VBoxContainer/BonusRoundContainer/BonusRoundsToggle
#progress bar
@onready var loading_bar = $Footer/VBoxContainer/LoadingBar


func _ready():
	#ensure we can't have more rounds than songs
	var max_songs = Global.playlist_songs.size()/2
	rounds_slider.max_value = min(max_songs, 20)
	loading_bar.visible = false
	SceneTransition.fade_out()
	Global.download_progress.connect(on_song_download_progress)
	print(score_increase_toggle.toggle_mode)


func _on_rounds_slider_value_changed(value):
	rounds_active.text = str(value)


func _on_rounds_slider_mouse_exited():
	rounds_slider.release_focus()


func _on_time_limit_slider_value_changed(value):
	time_limit_active.text = str(value)


func _on_time_limit_slider_mouse_exited():
	time_limit_slider.release_focus()


func _on_clip_length_slider_value_changed(value):
	clip_length_active.text = str(value)


func _on_clip_length_slider_mouse_exited():
	clip_length_slider.release_focus()


func _on_start_button_pressed():
	loading_bar.visible = true
	Global.set_game_data(rounds_slider.value, time_limit_slider.value, clip_length_slider.value, score_increase_toggle.button_pressed, bonus_rounds_toggle.button_pressed)
	await Global.game_ready
	SceneTransition.transition_to(game_scene)


func on_song_download_progress(value):
	loading_bar.visible = true
	loading_bar.value = value
