extends Node

const PATH : String = "user://data.tres"
var loaded_save : SaveData = SaveData.new()

func _ready() -> void:
	load_game()

func load_game() -> void :
	if FileAccess.file_exists(PATH):
		loaded_save = ResourceLoader.load(PATH).duplicate()

func save_game() -> void :
	ResourceSaver.save(loaded_save, PATH)
