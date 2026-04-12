extends Control
class_name Game

signal guess_pressed

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

func _on_guess_pressed() -> void :
	guess_pressed.emit($MarginContainer2/VBoxContainer/HBoxContainer/DateEntry.text)

func _on_answer_submitted(text:String) -> void :
	guess_pressed.emit(text)
