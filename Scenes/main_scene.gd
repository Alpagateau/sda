extends Control

enum State {
	Loading,
	Guessing,
	Won,
	Lost
}

@export var challenges : Array[Challenge]

var max_attemps : int = 5
var attemps : int = max_attemps
var win_streak : int = 0
var total_win : int = 0
var minimal_date : int = 2019
var maximum_date : int = 2021
var offset : int = 1 # minimal and maximum date are calculated based on offset

signal game_start

func _ready() -> void:	
	show_only_menu($Menus/PanelContainer)
	$Menus/Game.update_attemps_text(attemps)
	
	var current_date : int = int(Time.get_unix_time_from_system())
	var start_date : int = Time.get_unix_time_from_datetime_string("2026-04-20T01:00:00")
	var end_date : int = Time.get_unix_time_from_datetime_string("2026-04-27T01:00:00")
	
	var percent : float = float(current_date - start_date) / float(end_date - start_date)
	var idx : int = -1 
	print(percent)
	if percent < 0 or percent > 1:
		print("[DEBUG] Random !")
		idx = randi() % len(challenges)
	else:
		idx = int(len(challenges) * percent)
	
	print("IDX : ", idx)
	
	$Menus/Game.load_challenge(challenges[idx])
	minimal_date = challenges[idx].year - offset
	maximum_date = challenges[idx].year + offset
	#select correct thingy
	#TODO

var waiting_dot : int = 0
func update_waiting_text():
	waiting_dot += 1
	waiting_dot = waiting_dot % 3
	var s : String = ""
	for i in range(waiting_dot):
		s += "."
	$Menus/PanelContainer/MarginContainer/TitleScreen/WaitingText.text = "Waiting." + s

signal kill_tween

func waiting() -> void:
	$Menus/PanelContainer/MarginContainer/TitleScreen/WaitingText.show()
	$Menus/PanelContainer/MarginContainer/TitleScreen/WaitingText.text = "Waiting."
	$Menus/PanelContainer/MarginContainer/TitleScreen/Play.disabled = true
		
	var tween : Tween = create_tween()
	kill_tween.connect(tween.kill)
	tween.set_loops()
	tween.tween_interval(1.0)
	tween.tween_callback(update_waiting_text)

func end_waiting() -> void:
	kill_tween.emit()
	update_title_screen()
	$Menus/PanelContainer/MarginContainer/TitleScreen/WaitingText.hide()
	$Menus/PanelContainer/MarginContainer/TitleScreen/Play.disabled = false

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
	$Menus/EndGamePanel/MarginContainer/EndGameLayout/LoseText.hide()
	$Menus/EndGamePanel/MarginContainer/EndGameLayout/WinText.show()
	$Menus/EndGamePanel/MarginContainer/EndGameLayout/ReturnButton.show()

func show_lose_menu() -> void:
	show_only_menu($Menus/EndGamePanel)
	$Menus/EndGamePanel/MarginContainer/EndGameLayout/WinText.hide() # Au cas ou on n'avait pas reset le jeu
	$Menus/EndGamePanel/MarginContainer/EndGameLayout/LoseText.show()
	$Menus/EndGamePanel/MarginContainer/EndGameLayout/ReturnButton.show()

func _on_play_pressed() -> void:
	# TODO: Check si le joueur n'a pas deja joué ?
	start_game()

func _on_rules_pressed() -> void:
	show_only_menu($Menus/PanelContainer2)

func _on_return_pressed() -> void:
	update_title_screen()
	show_only_menu($Menus/PanelContainer)
	get_tree().reload_current_scene()
	
func update_streak_text(value : int) -> void:
	$Menus/PanelContainer/MarginContainer/TitleScreen/StreakText.text = "Série actuelle :" + str(value)
	
func update_win_text(value : int) -> void :
	var s : String = "" if value < 2 else "s"
	$Menus/EndGamePanel/MarginContainer/EndGameLayout/WinText.text = "Vous avez gagné en " + str(value) + " essai" + s

func on_win(attemps_nb : int) -> void:
	update_win_text(max_attemps - attemps_nb)
	win_streak += 1
	total_win += 1
	show_win_menu()

func on_loose():
	win_streak = 0
	show_lose_menu()
