extends Control

@export var fill_style: StyleBoxTexture = preload("res://resources/theme/loading_bar_fill_style.tres")
@export var menu_scene: PackedScene = preload("res://scenes/playlist_menu/playlist_menu.tscn")

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var loading_bar: ProgressBar = $LoadingUI/BottomContainer/MarginContainer/LoadingBar
@onready var message_label = $LoadingUI/BottomContainer/MessageLabel

var progress_tween: Tween = null


func _ready():
	SceneTransition.fade_out()
	set_info_label("preparing files")
	load_playlist_data()
		
	if not YoutubeDownloader.is_setup():
		YoutubeDownloader.setup()
		await YoutubeDownloader.setup_completed
		
	set_info_label("getting playlist data")
	progress_tween = progress_bar_tween(3)


func load_playlist_data():
	request_playlist_data()


func write_playlist_data():
	var file = FileAccess.open(Global.playlist_file, FileAccess.WRITE)
	file.store_line(JSON.stringify(Global.playlist_data))
	file.close()
	print("playlist-data-written")


func read_playlist_data():
	var file = FileAccess.open(Global.playlist_file, FileAccess.READ)
	Global.playlist_data = JSON.parse_string(file.get_as_text())
	file.close()
	print("playlist-data-read")


func request_playlist_data():
	http_request.request_completed.connect(self.on_playlist_request_completed)
	http_request.request(Global.playlist_url)


func on_playlist_request_completed(result: int, response_code:int, headers: PackedStringArray, body:PackedByteArray) -> void:
	if response_code == 200:
		var playlist_str = body.get_string_from_utf8()
		var json = JSON.parse_string(playlist_str)
		Global.playlist_data = json
		write_playlist_data()
	else:
		fill_style.modulate_color = Color("#fa506a")
		set_error_label("loading failed please check internet connection")
		progress_tween.kill()


func progress_bar_tween(tween_time = 5) -> Tween:
	var tw = create_tween()
	tw.tween_property(loading_bar, "value", 100, tween_time)
	tw.tween_callback(go_to_menu_scene)
	return tw


func go_to_menu_scene():
	SceneTransition.transition_to(menu_scene)


func set_error_label(text: String):
	message_label.text = text
	message_label.add_theme_color_override("font_color", Color("#fa506a"))
	message_label.visible = true


func set_info_label(text: String):
	message_label.text = text
	message_label.add_theme_color_override("font_color", Color("#98c980"))
	message_label.visible = true
