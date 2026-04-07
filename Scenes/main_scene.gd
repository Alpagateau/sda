extends Control

enum State {
	Loading,
	Guessing,
	Won,
	Lost
}

const base_url : String = "http://localhost:8000"

const MAX_ATTEMPS : int = 5
var attemps : int = MAX_ATTEMPS

func _ready() -> void:
	var header : PackedStringArray = PackedStringArray([])
	$HTTPRequest.request(
		base_url,
		header,
		HTTPClient.Method.METHOD_GET,
		""
	)
	show_only_menu($Menus/TitleScreen)
	update_attemps_text(attemps)


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

func _on_guess_pressed() -> void:
	var date : String = $Menus/Game/DateEntry.text
	if date.is_valid_int():
		decrement_attemps()
		if date.to_int() == 2020 :
			update_win_text(MAX_ATTEMPS - attemps)
			show_only_menu($Menus/Win)
		elif attemps == 0 :
			show_only_menu($Menus/Lose)

func decrement_attemps() -> void :
	attemps -= 1
	update_attemps_text(attemps)

func update_attemps_text(value : int) -> void :
	var s : String = "" if value < 2 else "s"
	$Menus/Game/AttempsText.text = "Il vous reste " + str(value) + " essai" + s
	
func update_win_text(value : int) -> void :
	var s : String = "" if value < 2 else "s"
	$Menus/Win/WinText.text = "Vous avez gagné en " + str(value) + " essai" + s
