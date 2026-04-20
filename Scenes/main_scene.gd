extends Control

enum State {
	Loading,
	Guessing,
	Won,
	Lost
}

@export var challenges : Array[Challenge]

var max_attemps : int = 8
var attemps : int = max_attemps
var win_streak : int = 0
var total_win : int = 0
var minimal_date : int = 2019
var maximum_date : int = 2021
var offset : int = 1 # minimal and maximum date are calculated based on offset

var current_challenge_idx : int = -1

signal game_start

func _ready() -> void:	
	show_only_menu($Menus/PanelContainer)
	$Menus/Game.update_attemps_text(attemps)
	
	var current_date : int = int(Time.get_unix_time_from_system())
	var start_date : int = Time.get_unix_time_from_datetime_string("2026-04-21T01:00:00")
	var end_date : int = Time.get_unix_time_from_datetime_string("2026-04-28T01:00:00")
	
	var percent : float = float(current_date - start_date) / float(end_date - start_date)
	var idx : int = -1 
	print(percent)
	if percent < 0 or percent > 1:
		print("[DEBUG] Random !")
		idx = 0 #randi() % len(challenges)
	else:
		idx = int(len(challenges) * percent)
	
	current_challenge_idx = idx
	if idx <= SaveLoader.loaded_save.last_finished_game_idx:
		if SaveLoader.loaded_save.streak == 0 : # if streak is 0 this means the player has lost last time
			on_loose()
		else :
			on_win(SaveLoader.loaded_save.last_finished_game_attemps)
		return
	
	print("IDX : ", idx)
	
	$Menus/Game.load_challenge(challenges[idx])
	init_player(SaveLoader.loaded_save.streak, SaveLoader.loaded_save.total_score, challenges[idx].year)
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

func init_player(player_streak : int, player_total_win : int, answer : int) -> void:
	win_streak = player_streak
	total_win = player_total_win
	minimal_date = answer - offset
	maximum_date = answer + offset
	update_title_screen()
	
func update_title_screen() -> void :
	update_streak_text(win_streak, total_win)

func start_game() -> void :
	if current_challenge_idx <= SaveLoader.loaded_save.last_finished_game_idx:
		if SaveLoader.loaded_save.streak == 0 : # if streak is 0 this means the player has lost last time
			on_loose()
		else :
			on_win(SaveLoader.loaded_save.last_finished_game_attemps)
		return
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
	#get_tree().reload_current_scene()
	
func update_streak_text(streak : int, total : int) -> void:
	$Menus/PanelContainer/MarginContainer/TitleScreen/StreakText.text = "Série actuelle : " + str(streak) + " | Score total : " + str(total)
	
func update_win_text(value : int) -> void :
	var s : String = "" if value < 2 else "s"
	$Menus/EndGamePanel/MarginContainer/EndGameLayout/WinText.text = "Vous avez gagné en " + str(value) + " essai !\nRevenez demain pour une autre oeuvre" + s

func on_win(attemps_nb : int) -> void:
	update_win_text(max_attemps - attemps_nb)
	win_streak += 1
	total_win += 1
	SaveLoader.loaded_save.streak = win_streak
	SaveLoader.loaded_save.total_score = total_win
	SaveLoader.loaded_save.last_finished_game_attemps = attemps_nb
	SaveLoader.loaded_save.last_finished_game_idx = current_challenge_idx
	SaveLoader.save_game()
	show_win_menu()

func on_loose():
	win_streak = 0
	SaveLoader.loaded_save.streak = win_streak
	SaveLoader.loaded_save.total_score = total_win
	SaveLoader.loaded_save.last_finished_game_attemps = max_attemps
	SaveLoader.loaded_save.last_finished_game_idx = current_challenge_idx
	SaveLoader.save_game()
	show_lose_menu()
