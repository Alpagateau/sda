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

var wiki_api : String = "https://en.wikipedia.org/w/api.php"
var photo_id = -1

func _ready() -> void:
	$NameRequest.request_completed.connect(_on_http_request_request_completed)
	$ImageURL.request_completed.connect(_on_image_url_request_completed)
	$ImageTexture.request_completed.connect(_on_image_texture_request_completed)
	pass

func b64_to_texture_2d(b64 : String) -> Texture2D:
	var image_bytes: PackedByteArray = Marshalls.base64_to_raw(b64)
	var image : Image = Image.new()
	image.load_png_from_buffer(image_bytes)
	return ImageTexture.create_from_image(image)

# To call when there is a response from the server
func load_b64_image(b64_image : String):
	$CenterContainer/TextureRect.texture = b64_to_texture_2d(b64_image)

func update_attemps_text(value : int) -> void :
	var s : String = "" if value < 2 else "s"
	$PanelContainer/MarginContainer/VBoxContainer/AttempsText.text = "Il vous reste " + str(value) + " essai" + s

func _on_answer_submitted(_text:String) -> void :
	#guessed.emit()
	_on_guess_pressed()

func add_marker(year : int):
	var new_marker : Marker = Marker.new()
	new_marker.date = year
	new_marker.relative_position = Marker.Position.Before if year <= minimal_date else Marker.Position.After
	print(minimal_date)
	new_marker.color = Color.RED
	$MarginContainer/ScrollContainer/Ruler2.add_child(new_marker)
	$MarginContainer/ScrollContainer/Ruler2.queue_redraw()

func game_start(attemps_nb : int, min_date : int, max_date : int) -> void:
	attemps = attemps_nb
	minimal_date = min_date
	maximum_date = max_date

func _on_guess_pressed() -> void:
	#guessed.emit() <- infinite calls ? or idk how signals work
	var date : String = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DateEntry.text
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DateEntry.clear()
	if date.is_valid_int():
		decrement_attemps()
		var date_value : int = date.to_int()
		add_marker(date_value)
		if minimal_date <= date_value and date_value <= maximum_date :
			win.emit(attemps)
			$MarginContainer/ScrollContainer/Ruler2.reset()
		elif attemps == 0 :
			loose.emit()
			$MarginContainer/ScrollContainer/Ruler2.reset()

func decrement_attemps() -> void :
	attemps -= 1
	update_attemps_text(attemps)

func load_challenge(_challenge : Challenge):
	#var request_url = wiki_api + "?action=query&titles="+(_challenge.wiki_link.replace(" ", "%20"))+"&format=json&prop=images"
	var request_url = _challenge.wiki_link
	photo_id = _challenge.photo_id
	#var err : Error = $NameRequest.request(
	var err : Error = $ImageTexture.request(
		request_url,
		PackedStringArray([]),
		HTTPClient.Method.METHOD_GET,
	)
	if err != Error.OK:
		print("Error")
	

# For the name and stuff
func _on_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print(_response_code)
	if _response_code != 200: return
	print(body.get_string_from_ascii())
	var jbody = JSON.parse_string(body.get_string_from_utf8())
	var pages : Dictionary = jbody["query"]["pages"]
	var page = pages[pages.keys()[0]]
	var _name = page["title"]
	var image_url = page["images"][photo_id]["title"]
	get_image(image_url)
	
	print("[NAME]", _name)

func get_image(title : String):
	var request_url = wiki_api \
		+ "?action=query" \
		+ "&titles=" + title.replace(" ", "%20") \
		+ "&format=json&prop=imageinfo" \
		+ "&iiprop=url"
	print("[REQUEST URL] ", request_url)
	var err : Error = $ImageURL.request(
		request_url,
		PackedStringArray([]),
		HTTPClient.Method.METHOD_GET,
	)
	if err != Error.OK:
		print("Error")

func _on_image_url_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print(_response_code)
	var jbody = JSON.parse_string(body.get_string_from_utf8())
	var pages : Dictionary = jbody["query"]["pages"]
	var page = pages[pages.keys()[0]]
	var image_info = page["imageinfo"][0]
	var image_url = image_info["url"]
	print("[IMAGE URL] ", image_url)
	$ImageTexture.request(image_url, [], HTTPClient.METHOD_GET)


func _on_image_texture_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var image : Image = Image.new()
	var type : String = Array(_headers).filter(func(x: String): return x.contains("type"))[0]
	if type.contains("png"):
		image.load_png_from_buffer(body)
	if type.contains("jpeg") or type.contains("jpg"):
		image.load_jpg_from_buffer(body)
	if type.contains("webp"):
		image.load_webp_from_buffer(body)
	if image.is_empty() && photo_id < 10: 
		print("ERROR ", _response_code, " | " ,type)
		return
	$CenterContainer/TextureRect.texture = ImageTexture.create_from_image(image)
