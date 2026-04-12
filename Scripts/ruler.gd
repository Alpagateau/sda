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
	
func draw_marker(year : int, c : Color = stick_color):
	var origin : Vector2 = position + Vector2.RIGHT * year_to_pos(year)
	draw_line(
		origin,
		origin + Vector2.DOWN * height,
		c,
		2
	)
	draw_string(
		ThemeDB.fallback_font,
		origin + Vector2.DOWN * ThemeDB.fallback_font_size + Vector2.RIGHT * 3, 
		str(year),
		HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		c if c != stick_color else Color.WHITE
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
	
	var min_guess : int = min_year
	var max_guess : int = max_year
	for c in get_children():
		if c is Marker:
			draw_marker(c.date, c.color)
			match c.relative_position:
				Marker.Position.Before:
					if c.date >= min_guess:
						min_guess = c.date
				Marker.Position.After:
					if c.date <= max_guess:
						max_guess = c.date
				_:
					pass
	var point1 = position +Vector2.RIGHT * year_to_pos(max_guess) + Vector2.DOWN * ThemeDB.fallback_font_size
	var point2 = position +Vector2.RIGHT * year_to_pos(min_guess) + Vector2.DOWN * get_rect().end.y
	draw_rect(
		Rect2(
			point1,
			get_rect().end - point1
		),
		Color.from_rgba8(0,0,0,155)
	)
	draw_rect(
		Rect2(
			position + Vector2.DOWN * ThemeDB.fallback_font_size,
			point2
		),
		Color.from_rgba8(0,0,0,155)
	)
