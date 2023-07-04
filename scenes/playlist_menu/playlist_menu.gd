extends Control

@export var playlist_item: PackedScene = preload("res://scenes/components/playlist_item/playlist_item.tscn")
@export var game_rules_scene: PackedScene = preload("res://scenes/game_rules_menu/game_rules_menu.tscn")

@onready var http_request = $HTTPRequest
@onready var playlist_container = $PlaylistMenuContainer/MarginContainer/PlaylistContainer
@onready var previous_button: TextureButton = $PlaylistMenuContainer/Footer/NavigationButtonContainer/PreviousButton
@onready var next_button: TextureButton = $PlaylistMenuContainer/Footer/NavigationButtonContainer/NextButton

const MAX_ITEMS_PER_PAGE = 5
var current_page = 1

func _ready():
	randomize()
	SceneTransition.fade_out()
	Global.start_game.connect(on_playlist_selected)
	current_page = 1;
	
	Global.playlist_data["data"].shuffle()
	generate_playlist_page(current_page)

func get_playlist_paged(page: int):
	var start = (page - 1) * MAX_ITEMS_PER_PAGE
	var end = start + MAX_ITEMS_PER_PAGE
	return Global.playlist_data["data"].slice(start, end)
	
func is_next_playlist_page_available(page: int) -> bool:
	var items = Global.playlist_data["data"].size()
	var total_pages = floor( items / MAX_ITEMS_PER_PAGE) + 1
	return page < total_pages

func create_playlist_item(name: String, id: String):
	var instance := playlist_item.instantiate() as PlaylistItem
	playlist_container.add_child(instance)
	instance.set_data(name, id)

func on_playlist_selected(name: String, id: String):
	print("playlist clicked " + name)
	Global.current_playlist_id = id;
	YoutubeAPI.get_playlist_videos(id)
	await YoutubeAPI.playlist_request_completed
	SceneTransition.transition_to(game_rules_scene)
	
func clear_current_playlist_items():
	var playlist_items = playlist_container.get_children()
	for item in playlist_items:
		item.queue_free()

func generate_playlist_page(page: int):
	previous_button.disabled = current_page == 1
	next_button.disabled = !is_next_playlist_page_available(current_page)
	
	for item in get_playlist_paged(page) as Array[Dictionary]:
		create_playlist_item(item["name"], item["id"])

func _on_next_button_pressed():
	if !next_button.disabled:
		clear_current_playlist_items()
		current_page = current_page + 1
		generate_playlist_page(current_page)
		
func _on_previous_button_pressed():
	if !previous_button.disabled:
		clear_current_playlist_items()
		current_page = current_page - 1
		generate_playlist_page(current_page)

func _on_update_playlist():
	DirAccess.remove_absolute(Global.playlist_file)
	request_playlist_data()
	
func request_playlist_data():
	http_request.request_completed.connect(self.on_playlist_request_completed)
	http_request.request(Global.playlist_url)
	
func on_playlist_request_completed(result: int, response_code:int, headers: PackedStringArray, body:PackedByteArray) -> void:
	if response_code == 200:
		var playlist_str = body.get_string_from_utf8()
		var json = JSON.parse_string(playlist_str)
		Global.playlist_data = json
		clear_current_playlist_items()
		current_page = 1
		generate_playlist_page(current_page)
		print("playlist-updated")
