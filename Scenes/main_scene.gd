extends Control

enum State {
	Loading,
	Guessing,
	Won,
	Lost
}

var max_attemps : int = 5
var attemps : int = max_attemps
var win_streak : int = 0
var total_win : int = 0
var minimal_date : int = 2019
var maximum_date : int = 2021
var offset : int = 1 # minimal and maximum date are calculated based on offset

signal game_start

func _ready() -> void:	
	show_only_menu($Menus/TitleScreen)
	$Menus/Game.update_attemps_text(attemps)
	waiting()

var waiting_dot : int = 0
func update_waiting_text():
	waiting_dot += 1
	waiting_dot = waiting_dot % 3
	var s : String = ""
	for i in range(waiting_dot):
		s += "."
	$Menus/TitleScreen/WaitingText.text = "Waiting." + s

signal kill_tween

func waiting() -> void:
	$Menus/TitleScreen/WaitingText.show()
	$Menus/TitleScreen/WaitingText.text = "Waiting."
	$Menus/TitleScreen/Play.disabled = true
		
	var tween : Tween = create_tween()
	kill_tween.connect(tween.kill)
	tween.set_loops()
	tween.tween_interval(1.0)
	tween.tween_callback(update_waiting_text)

func end_waiting() -> void:
	kill_tween.emit()
	update_title_screen()
	$Menus/TitleScreen/WaitingText.hide()
	$Menus/TitleScreen/Play.disabled = false

func show_only_menu(menu : Control) -> void :
	for m in $Menus.get_children():
		if m is CanvasItem :
			m.hide()
	menu.show()

func init_player(player_streak : int, answer : int) -> void:
	win_streak = player_streak
	minimal_date = 	answer - offset
	maximum_date = answer + offset
	update_streak_text(player_streak)
	
func update_title_screen() -> void :
	update_streak_text(win_streak)

func start_game() -> void :
	show_only_menu($Menus/Game)
	game_start.emit(attemps, minimal_date, maximum_date)
	#$Menus/Game/TextureRect.show()
	
func show_win_menu() -> void:
	show_only_menu($Menus/EndGamePanel)
	$Menus/EndGamePanel/Lose.hide()
	$Menus/EndGamePanel/Win.show()
	$Menus/EndGamePanel/ReturnButton.show()

func show_lose_menu() -> void:
	show_only_menu($Menus/EndGamePanel)
	$Menus/EndGamePanel/Win.hide() # Au cas ou on n'avait pas reset le jeu
	$Menus/EndGamePanel/Lose.show()
	$Menus/EndGamePanel/ReturnButton.show()

func _on_play_pressed() -> void:
	# TODO: Check si le joueur n'a pas deja joué ?
	start_game()

func _on_rules_pressed() -> void:
	show_only_menu($Menus/Rules)

func _on_return_pressed() -> void:
	update_title_screen()
	show_only_menu($Menus/TitleScreen)
	
func update_streak_text(value : int) -> void:
	$Menus/TitleScreen/StreakText.text = "Série actuelle :" + str(value)
	
func update_win_text(value : int) -> void :
	var s : String = "" if value < 2 else "s"
	$Menus/EndGamePanel/Win/WinText.text = "Vous avez gagné en " + str(value) + " essai" + s

func on_win():
	update_win_text(max_attemps - attemps)
	win_streak += 1
	total_win += 1
	show_win_menu()

func on_loose():
	win_streak = 0
	show_lose_menu()
