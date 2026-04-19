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
@export var width : float = 500

@export_category("Visual")
@export var stick_color : Color
@export var background_color : Color
@export var outside_color : Color
@export var height : int = 150
@export var number_of_markers : int = 15

var default_years : Vector2i

@export_tool_button("Redraw") var redraw : Callable = (func(): 
	queue_redraw()
	_ready()
	)

func _ready() -> void:
	custom_minimum_size.x = width
	custom_minimum_size.y = height
	update_minimum_size()
	default_years = Vector2i(min_year, max_year)
	
func draw_marker(year : int, c : Color = stick_color):
	var origin : Vector2 = Vector2.RIGHT * year_to_pos(year)
	var down_offset = Vector2.DOWN * (height - ThemeDB.fallback_font_size) if c == stick_color else Vector2.ZERO
	var small_offset = Vector2.DOWN * ThemeDB.fallback_font_size if c == stick_color else Vector2.ZERO
	draw_line(
		origin+small_offset,
		origin + Vector2.DOWN * height + small_offset,
		c,
		2
	)
	
	
	draw_string(
		ThemeDB.fallback_font,
		origin + Vector2.DOWN * ThemeDB.fallback_font_size + Vector2.RIGHT * 3 + down_offset, 
		str(year),
		HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		c if c != stick_color else stick_color
	)

func year_to_pos(year : int) -> int:
	var percent : float = float(year - min_year) / float(max_year - min_year)
	match(continuity):
		Continuity.Linear:
			return int(lerp(0.0,width, percent))
		Continuity.Logarithmic_1:
			return int(lerp(0.0,lerp(0.0, width, percent), percent))
		Continuity.Logarithmic_2:
			return int(lerp(0.0,lerp(0.0, lerp(0.0, width, percent), percent), percent))
		_:
			return 0

func _draw() -> void:
	var min_guess : int = min_year
	var max_guess : int = max_year
	draw_rect(
		Rect2(
			Vector2.DOWN * ThemeDB.fallback_font_size,
			size
		),
		background_color
	)
	for c in get_children():
		if c is Marker:
			match c.relative_position:
				Marker.Position.Before:
					if c.date >= min_guess:
						min_guess = c.date
				Marker.Position.After:
					if c.date <= max_guess:
						max_guess = c.date
				_:
					pass
	if (max_guess - min_guess) > number_of_markers:
		min_year = min_guess - number_of_markers
		max_year = max_guess + number_of_markers
	
	#Drawing default markers 
	for i in range(number_of_markers + 1):
		var percent : float = (float(i)/ number_of_markers)
		#var pos = int(lerp(0.0, width, percent))
		var year = int(
			lerp(min_year, max_year, percent)
		)
		draw_marker(year)
		
	#var current_year : int = min_year
	#var last_year : int = min_year
	
	# Drawing markers
	for c in get_children():
		if c is Marker:
			draw_marker(c.date, c.color)
	var point1 = Vector2.RIGHT * year_to_pos(max_guess) + Vector2.DOWN * ThemeDB.fallback_font_size
	var point2 = Vector2.RIGHT * year_to_pos(min_guess) + Vector2.DOWN * get_rect().end.y
	# Drawing dead zones
	draw_rect(
		Rect2(
			point1,
			size - point1
		),
		outside_color
	)
	draw_rect(
		Rect2(
			Vector2.DOWN * ThemeDB.fallback_font_size,
			point2
		),
		outside_color
	)
	
func reset():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	min_year = default_years.x
	max_year = default_years.y
	
