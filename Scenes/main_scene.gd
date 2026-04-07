extends Control

enum State {
	Loading,
	Guessing,
	Won,
	Lost
}

const base_url : String = "http://127.0.0.1:8000"

var max_attemps : int = 5
var attemps : int = max_attemps
var win_streak : int = 0
var total_win : int = 0
var minimal_date : int = 2019
var maximum_date : int = 2021

var header : PackedStringArray = PackedStringArray([])

func _ready() -> void:
	$HTTPRequest.request_completed.connect(process_html_request)
	var err : Error = $HTTPRequest.request(
		base_url,
		header,
		HTTPClient.Method.METHOD_GET
	)
	
	if err != OK :
		print("Failed to connect to server")
	else :
		print("Succed to connect to server")
	
	show_only_menu($Menus/TitleScreen)
	update_attemps_text(attemps)

func process_html_request(result : int, response_code : int, headers : PackedStringArray, body : PackedByteArray):
	print("Result code: ", result)
	print("Response code: ", response_code)
	print("Header code: ", headers)
	
	var text = body.get_string_from_utf8()
	if text.is_empty() :
		print("Nothing sent")
		return
	
	var json = JSON.parse_string(text)
	if json == null:
		print("Failed to parse JSON")
		return

	print("Name: ", json["name"])
	print("Date: ", json["date"])
	var b64_image : String = json["image"]
	$Menus/Game.load_b64_image(b64_image)

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
		var date_value : int = date.to_int()
		if minimal_date <= date_value and date_value <= maximum_date :
			update_win_text(max_attemps - attemps)
			win_streak += 1
			total_win += 1
			show_only_menu($Menus/Win)
		elif attemps == 0 :
			win_streak = 0
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
