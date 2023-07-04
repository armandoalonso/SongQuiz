extends Node

signal start_game(playlist_name: String, playlist_id: String)
signal download_progress(value: int)
signal song_download_completed(success: bool)
signal game_ready
signal player_change(player)
signal round_over

var playlist_url: String = "https://raw.githubusercontent.com/armandoalonso/song_quiz/main/playlist_data.json?token=$(date%20+%s)"
var playlist_file: String = "user://playlist_data.json"
var playlist_data : Dictionary = {}

var round_length = 0
var time_limit = 0
var clip_length = 0
var increase_score = false
var bonus_rounds = false
var base_score = 10

var player_names = ["Vivian", "Piranha"]
var player_one_name: String
var player_two_name: String

var current_playlist_id = ""
var playlist_songs = []
var current_songs = []
var backup_songs = []
var current_player = "Player 1"
var current_round = 0
var current_song_index = 0
var game_over = false

var player_one_score = 0
var player_two_score = 0

func set_game_data(round_length: int, time_limit: int, clip_length: int, increase_score: bool, bonus_rounds: bool):
	randomize()
	self.round_length = round_length
	self.time_limit = time_limit
	self.clip_length = clip_length
	self.increase_score = increase_score
	self.bonus_rounds = bonus_rounds
	
	# randomize first player
	player_names.shuffle()
	player_one_name = player_names[0]
	player_two_name = player_names[1]
	current_player = player_one_name
	
	current_round = 1
	current_song_index = 0
	player_one_score = 0
	player_two_score = 0
	current_songs = []
	backup_songs = []
	game_over = false
	
	generate_random_songs(round_length * 2, 10)
	#download_random_songs(round_length * 2)


func generate_random_songs(count: int, backup_buffer: int):
	randomize()
	playlist_songs.shuffle()
	var songs = playlist_songs.slice(0, min(count + backup_buffer, playlist_songs.size()-1))
	for i in range(songs.size()):
		var song_name = sanatize_song_name(songs[i]["title"])
		var song_hash = songs[i]["hash"]
		var song_path = songs[i]["path"]
		var song_id = songs[i]["video_id"]
		current_songs.append({"name" = song_name, "path" = song_path, "hash" = song_hash, "id" = song_id})
	
	await get_tree().process_frame
	print("picked-random-songs")
	game_ready.emit()


func sanatize_song_name(song: String):
	song = _remove_regex_in_string(song, "\\([^()]*\\)")
	song = _remove_regex_in_string(song, "\\[(.*?)\\]")
	song =  _remove_regex_in_string(song, "\\*(.*?)\\*")
	return song


func download_random_songs(count: int):
	randomize()
	playlist_songs.shuffle()
	var songs = playlist_songs.slice(0, count)
	for i in range(songs.size()):
		
		var song_name = songs[i]["title"]
		var song_hash = hash(song_name)
		var song_path = "user://audio/"+str(song_hash)+".mp3"
		
		if FileAccess.file_exists(song_path):
			# file exists don't download
			current_songs.append({"name" = song_name, "path" = song_path, "hash" = song_hash})
		else:
			var download := YoutubeDownloader.download("https://youtu.be/" + songs[i]["video_id"]) \
				.set_destination("user://audio/") \
				.set_file_name(str(song_hash)) \
				.convert_to_audio(YoutubeDownloader.Audio.MP3) \
				.start()
				
			current_songs.append({"name" = song_name, "path" = song_path, "hash" = song_hash})
			await download.download_completed
			
		download_progress.emit(((i+1) * 100 / songs.size()))
		
	await get_tree().process_frame
	print("downloading-songs-complete")
	game_ready.emit()


func download_song(index: int):
	var song = current_songs[index]
	var song_path = song["path"]
	var song_id = song["id"]
	var song_hash = song["hash"]
	var success = false
	
	if FileAccess.file_exists(song_path):
		success = true
	else:
		var download := YoutubeDownloader.download("https://youtu.be/" + song_id) \
			.set_destination("user://audio/") \
			.set_file_name(str(song_hash)) \
			.convert_to_audio(YoutubeDownloader.Audio.MP3) \
			.start()
			
		await download.download_completed
		
		if FileAccess.file_exists(song_path):
			success = true
			
	await get_tree().process_frame
	song_download_completed.emit(success)


func download_current_song(emit: bool = true):
	var song = current_songs[current_song_index]
	var song_path = song["path"]
	var song_id = song["id"]
	var song_hash = song["hash"]
	var success = false
	
	print(song)
	
	if FileAccess.file_exists(song_path):
		success = true
	else:
		var download := YoutubeDownloader.download("https://youtu.be/" + song_id) \
			.set_destination("user://audio/") \
			.set_file_name(str(song_hash)) \
			.convert_to_audio(YoutubeDownloader.Audio.MP3) \
			.start()

		await download.download_completed
		
		#check if file downloaded successfully
		if FileAccess.file_exists(song_path):
			success = true
			
	await get_tree().process_frame
	song_download_completed.emit(success)


func get_current_song_path() -> String:
	var song = current_songs[current_song_index]
	return song["path"]


func get_current_song_title() -> String:
	var song = current_songs[current_song_index]["name"]
	var song_parts = song.split(" - ")
	song = "\n".join(song_parts)
	return song

func get_current_song_url() -> String:
	var song = current_songs[current_song_index]["id"]
	var url = "https://www.youtube.com/watch?v=" + song
	return url

func increase_current_song_index():
	current_song_index = current_song_index + 1


func next_turn():
	if current_player == player_one_name:
		current_player = player_two_name
		current_song_index = current_song_index + 1
		player_change.emit(current_player)
	else:
		current_player = player_one_name
		current_song_index = current_song_index + 1
		player_change.emit(current_player)
		next_round()


func is_bonus_round() -> bool:
	return bonus_rounds and current_round == round_length


func next_round():
	current_round = current_round + 1
	
	if increase_score:
		base_score = 10 * current_round
		
	if is_bonus_round():
		base_score = base_score * 2
		
	if current_round > round_length:
		game_over = true
		round_over.emit()
	else:
		round_over.emit()


func add_score_to_current_player(correct_song: bool, correct_artist: bool):
	var song_points = int(correct_song) * base_score
	var artist_points = int(correct_artist) * base_score
	
	if current_player == player_one_name:
		player_one_score = player_one_score + song_points + artist_points
	elif current_player == player_two_name:
		player_two_score = player_two_score + song_points + artist_points  


func get_current_player_score() -> int:
	if current_player == player_one_name:
		return player_one_score
	else:
		return player_two_score


func _remove_regex_in_string(str: String, pattern: String) -> String:
	var regex = RegEx.new()
	regex.compile(pattern)
	
	var result = regex.search(str)
	if result:
		var value = result.get_string()
		return str.replacen(value, "")
		
	return str


func choose(arr: Array):
	var random_index = randi() % arr.size()
	return arr[random_index]
