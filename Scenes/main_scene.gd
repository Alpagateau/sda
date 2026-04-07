extends Control

enum State {
	Loading,
	Guessing,
	Won,
	Lost
}

const base_url : String = "http://localhost:8000"


func _ready() -> void:
	var header : PackedStringArray = PackedStringArray([])
	$HTTPRequest.request(
		base_url,
		header,
		HTTPClient.Method.METHOD_GET,
		""
	)
	show_only_menu($Menus/TitleScreen)


func show_only_menu(menu : Control) -> void :
	for m in $Menus.get_children():
		if m is CanvasItem :
			m.hide()
	menu.show()


func _on_play_pressed() -> void:
	show_only_menu($Menus/Game)

func _on_rules_pressed() -> void:
	show_only_menu($Menus/Rules)

func _on_return_pressed() -> void:
	show_only_menu($Menus/TitleScreen)
