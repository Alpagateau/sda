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
