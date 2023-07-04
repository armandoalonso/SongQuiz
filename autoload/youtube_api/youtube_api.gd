extends Node

signal playlist_request_completed
signal playlist_request_error

const API_KEY = ""
@onready var http_request = $HTTPRequest

var _current_playlist_request_id = ""
var _current_songs = []

func _ready():
	http_request.request_completed.connect(self.on_playlist_video_request_completed)
	
func get_playlist_videos(playlist_id: String) -> void:
	_current_playlist_request_id = playlist_id
	_current_songs = []
	
	create_playlists_directory()
	if playlist_json_file_exits(playlist_id):
		read_playlist_data(playlist_id)
		await get_tree().process_frame
		playlist_request_completed.emit()
	else:
		print("downloading-playlist-data-json")
		download_playlist_videos(playlist_id)

func download_playlist_videos(playlist_id: String, page_token: String = "") -> void:
	var url = "https://www.googleapis.com/youtube/v3/playlistItems"
	url += "?part=snippet"
	url += "&maxResults=50"
	if page_token != "":
		url += "&pageToken=" + page_token
	url += "&playlistId=" + playlist_id
	url += "&key=" + API_KEY
	
	http_request.request(url)

func on_playlist_video_request_completed(result: int, response_code:int, headers: PackedStringArray, body:PackedByteArray) -> void:
	print("playlist-request-done " + str(response_code))
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var has_next_page = json.has("nextPageToken")
		
		for item in json["items"]:
			var snip = item["snippet"]
			if snip["resourceId"]["kind"] == "youtube#video":
				var song = {}
				song["title"] = snip["title"]
				song["video_id"] = snip["resourceId"]["videoId"]
				song["hash"] = hash(snip["title"])
				song["path"] = "user://audio/"+str(song["hash"])+".mp3"
				_current_songs.append(song)
		
		# check if more songs exists
		if has_next_page:
			var next_page_token = json["nextPageToken"]
			download_playlist_videos(_current_playlist_request_id, next_page_token)
		# the end of the request
		else:
			Global.playlist_songs = _current_songs
			save_playlist_data(_current_playlist_request_id, _current_songs)
			playlist_request_completed.emit()
	else:
		playlist_request_error.emit()
		print(response_code)

func save_playlist_data(id: String, songs: Array):
	var path = "user://playlists/"+id+".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(songs, "\t"))
	file.close()
	print("playlist-data-json-saved")

func read_playlist_data(id: String):
	var path = "user://playlists/"+id+".json"
	var file = FileAccess.open(path, FileAccess.READ)
	Global.playlist_songs = JSON.parse_string(file.get_as_text())
	file.close()
	print("playlist-data-json-read")
	
func playlist_json_file_exits(id: String) -> bool:
	var path = "user://playlists/"+id+".json"
	return FileAccess.file_exists(path)
	
func create_playlists_directory():
	var path = "user://playlists"
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)

# https://www.reddit.com/r/godot/comments/117h6jg/godot_4_how_to_play_a_video_from_youtube/
