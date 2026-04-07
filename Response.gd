extends Resource

class_name Response

# Player Data
@export var PlayerName : String
@export var PlayerStreak : int
@export var PlayerTotal : int

#Today's challenge
@export var ImageB64 : String
@export var Date : int

#Rules
@export var NumberOfTries : int
@export var AllowedDistance : int #in years
