extends Control
class_name Game

@warning_ignore("unused_signal")
signal win
@warning_ignore("unused_signal")
signal loose
@warning_ignore("unused_signal")
signal guessed

var minimal_date : int = 1586
var maximum_date : int = 1586
var attemps : int = 5

func b64_to_texture_2d(b64 : String) -> Texture2D:
	var image_bytes: PackedByteArray = Marshalls.base64_to_raw(b64)
	var image : Image = Image.new()
	image.load_png_from_buffer(image_bytes)
	return ImageTexture.create_from_image(image)

# To call when there is a response from the server
func load_b64_image(b64_image : String):
	$MarginContainer2/CenterContainer/TextureRect.texture = b64_to_texture_2d(b64_image)

func update_attemps_text(value : int) -> void :
	var s : String = "" if value < 2 else "s"
	$MarginContainer2/VBoxContainer/AttempsText.text = "Il vous reste " + str(value) + " essai" + s

func _on_answer_submitted(text:String) -> void :
	guessed.emit(text)

func add_marker(year : int):
	var new_marker : Marker = Marker.new()
	new_marker.date = year
	new_marker.relative_position = Marker.Position.Before if year <= minimal_date else Marker.Position.After
	new_marker.color = Color.RED
	$MarginContainer/ScrollContainer/Ruler2.add_child(new_marker)
	$MarginContainer/ScrollContainer/Ruler2.queue_redraw()

func _on_guess_pressed() -> void:
	guessed.emit()
	var date : String = $MarginContainer2/VBoxContainer/HBoxContainer/DateEntry.text
	if date.is_valid_int():
		decrement_attemps()
		var date_value : int = date.to_int()
		add_marker(date_value)
		if minimal_date <= date_value and date_value <= maximum_date :
			win.emit()
		elif attemps == 0 :
			loose.emit()

func decrement_attemps() -> void :
	attemps -= 1
	update_attemps_text(attemps)
