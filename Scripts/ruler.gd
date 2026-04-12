@tool
extends Control
class_name Ruler

enum Direction 
{
	Horizontal,
	Vectical
}
enum Continuity 
{
	Linear,
	Logarithmic_1,
	Logarithmic_2
}

@export_category("General Settings")
@export var direction : Direction = Direction.Horizontal
@export var continuity : Continuity = Continuity.Linear
@export var min_year : int = -500
@export var max_year : int = 2026
@export var precision : int = 100
@export var distance : float = 0.5

@export_category("Visual")
@export var stick_color : Color
@export var background_color : Color
@export var height : int = 150

@export_tool_button("Redraw") var redraw : Callable = (func(): 
	queue_redraw()
	_ready()
	)

var width : float = 100

func _ready() -> void:
	width = year_to_pos(max_year+10) + 50
	custom_minimum_size.x = width
	custom_minimum_size.y = height
	update_minimum_size()
	
func draw_marker(year : int):
	var origin : Vector2 = position + Vector2.RIGHT * year_to_pos(year)
	draw_line(
		origin,
		origin + Vector2.DOWN * height,
		stick_color,
		2
	)
	draw_string(
		ThemeDB.fallback_font,
		origin + Vector2.DOWN * ThemeDB.fallback_font_size + Vector2.RIGHT * 3, 
		str(year)
	)

func year_to_pos(year : int) -> int:
	var total_width : float = distance * (max_year - min_year)
	var percent : float = float(year - min_year) / float(max_year - min_year)
	match(continuity):
		Continuity.Linear:
			return int(lerp(0.0,total_width, percent))
		Continuity.Logarithmic_1:
			return int(lerp(0.0,lerp(0.0, total_width, percent), percent))
		Continuity.Logarithmic_2:
			return int(lerp(0.0,lerp(0.0, lerp(0.0, total_width, percent), percent), percent))
		_:
			return 0

func _draw() -> void:
	var current_year : int = min_year
	var last_year : int = min_year
	draw_rect(
		Rect2(
			position + Vector2.DOWN * ThemeDB.fallback_font_size,
			get_rect().end
		),
		background_color
	)
	while current_year < max_year:
		if(year_to_pos(current_year) - year_to_pos(last_year) >= distance * precision):
			draw_marker(current_year)
			last_year = current_year
		current_year += 5
