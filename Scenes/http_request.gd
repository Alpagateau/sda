extends HTTPRequest
class_name Client

const URL : String = "http://127.0.0.1:8000"
var header : PackedStringArray = PackedStringArray([])

func _ready() -> void:
	request_completed.connect(process_html_request)
	var err : Error = request(
		URL,
		header,
		HTTPClient.Method.METHOD_GET
	)
	
	if err != OK :
		print("Failed to create request.")
	else :
		print("Succeed to create request")


func process_html_request(result : int, response_code : int, headers : PackedStringArray, body : PackedByteArray):
	
	print("Result code: ", result)
	print("Response code: ", response_code)
	print("Header code: ", headers)
	
	var text = body.get_string_from_utf8()
	if text.is_empty() :
		print("Nothing sent, retrying")
		var err : Error = request(
			URL,
			header,
			HTTPClient.Method.METHOD_GET
		)	
	
		if err != OK :
			print("Failed to create request.")
		else :
			print("Succeed to create request")
		return
	$"..".end_waiting()
	var json = JSON.parse_string(text)
	if json == null:
		print("Failed to parse JSON")
		return

	print("Name: ", json["PlayerName"])
	print("Date: ", json["date"])
	print("Streak: ", json["PlayerStreak"])
	print("Answer: ", json["Answer"])
	var b64_image : String = json["Image"]
	$"../Menus/Game".load_b64_image(b64_image)
	$"..".init_player(json["PlayerStreak"], json["Answer"])
