extends VBoxContainer

@export var guess_scene: PackedScene = preload("res://scenes/guess/guess.tscn")

#components
@onready var header_timer := $HeaderTimer as HeaderTimer
@onready var audio_stream_player_2d := $AudioStreamPlayer2D as AudioStreamPlayer2D
@onready var buzzer_audio_player := $BuzzerAudioPlayer as AudioStreamPlayer2D
@onready var audio_visualizer_container = $AudioVisualizerContainer
#labels
@onready var active_player := $"GameScreen/VBoxContainer/RoundInfoContainer/Active PlayerLabel" as Label
@onready var active_round := $GameScreen/VBoxContainer/RoundInfoContainer/ActiveRoundLabel as Label
@onready var player_score_label := $GameScreen/VBoxContainer/ScoreInfoContainer/PlayerScoreLabel as Label
@onready var score_multipler_label = $GameScreen/VBoxContainer/ScoreInfoContainer/ScoreMultiplerLabel
@onready var message_label := $Footer/VBoxContainer/MessageLabel as Label
#buttons
@onready var replay_song_button := $Footer/VBoxContainer/ButtonMarginContainer/ButtonContainer/ReplaySongButton as TextureButton
@onready var guess_button := $Footer/VBoxContainer/ButtonMarginContainer/ButtonContainer/GuessButton as TextureButton


var start_pos = 0
var play_timer: SceneTreeTimer


func _ready():
	SceneTransition.fade_out()
	
	replay_song_button.disabled = true
	guess_button.disabled = true
	
	set_info_label("downloading...")
	header_timer.set_time(Global.time_limit)
	active_player.text = Global.current_player
	active_round.text = "Round " + str(Global.current_round)
	player_score_label.text = "Score " + str(Global.get_current_player_score())
	score_multipler_label.text = Global.get_available_score_text()
	audio_visualizer_container.visible = false
	
	
	Global.download_current_song()
	var attempts = 0
	var success = await Global.song_download_completed
	
	while(!success and attempts < 3):
		print("retry failed download")
		attempts = attempts + 1
		# try and download next song
		Global.increase_current_song_index()
		Global.download_current_song()
		success = await Global.song_download_completed
	
	if attempts == 4:
		# downloading song failed
		print("song download failed")
	
	message_label.visible = false
	start_round()


func start_round():
	audio_visualizer_container.visible = true
	var stream = get_song_stream(Global.get_current_song_path())
	start_pos = pick_random_starting_point_in_song(stream)
	set_audio_stream_and_play(stream, start_pos)
	
	header_timer.start()
	download_next_song()
	

func download_next_song():
	var attempts = 0
	var next_song_index = Global.current_song_index + 1
	Global.download_song(next_song_index)
	
	var success = await Global.song_download_completed
	while(!success and attempts < 3):
		print("retry failed download")
		attempts = attempts + 1
		# try and download next song
		next_song_index = next_song_index + 1
		Global.download_song(next_song_index)
		success = await Global.song_download_completed
	
	if attempts == 4:
		# downloading song failed
		print("next song download failed")
		
	guess_button.disabled = false


func pick_random_starting_point_in_song(stream: AudioStreamMP3) -> int:
	var length = stream.get_length()
	var mid = length/2
	var section = length * 0.1 # 10% of the length of the song
	var value = randi_range(mid-(section*3), mid+(section*3))
	return value


func get_song_stream(file_path: String) -> AudioStreamMP3:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("failed")
	
	var stream = AudioStreamMP3.new()
	stream.data = file.get_buffer(file.get_length())
	file.close()
	return stream


func set_audio_stream_and_play(stream: AudioStreamMP3, start_position):
	audio_stream_player_2d.stream = stream
	audio_stream_player_2d.play(start_position)
	await get_tree().create_timer(Global.clip_length).timeout
	audio_stream_player_2d.stop()
	replay_song_button.disabled = false
	audio_visualizer_container.visible = false


func set_error_label(text: String):
	message_label.text = text
	message_label.add_theme_color_override("font_color", Color("#fa506a"))
	message_label.visible = true


func set_info_label(text: String):
	message_label.text = text
	message_label.add_theme_color_override("font_color", Color("#98c980"))
	message_label.visible = true


func _on_replay_song_button_pressed():
	replay_song_button.disabled = true
	audio_visualizer_container.visible = true
	audio_stream_player_2d.stop()
	audio_stream_player_2d.play(start_pos)
	
	await get_tree().create_timer(Global.clip_length).timeout
	audio_stream_player_2d.stop()
	replay_song_button.disabled = false
	audio_visualizer_container.visible = false


func _on_guess_button_pressed():
	audio_stream_player_2d.stop()
	SceneTransition.transition_to(guess_scene)


func _on_skip_button_pressed():
	pass # Replace with function body.


func _on_header_timer_time_expired():
	buzzer_audio_player.play()
	await get_tree().create_timer(1)
	audio_stream_player_2d.stop()
	SceneTransition.transition_to(guess_scene)
