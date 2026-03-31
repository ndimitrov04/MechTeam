extends StaticBody2D

# Consts

const FLOOR_HEIGHT = 608 # Standard floor height
const SPAWN_OFFSET = 750 # Next enemy offset in pixels
const FIRST_ENEMY = 1250 # First enemy X coordinate

# =============================================================

# Export vars

@export var HEIGHT_RANGE : Vector2i = Vector2(-500, 608) # Min; Max
# Note: Godot uses inverted Y coords. -500 is higher than 608.

## Length of flatland for 1v1 mech combat
@export var COMBAT_ARENA_LENGTH : int = 800 

## Average length of terrain generated before height change
@export var SMOOTHNESS : int = 128

## Average height deviation of terrain at height change
@export var ROUGHNESS : int = 128

# =============================================================

# NOTICE
# Next enemy always spawns at: 
# mech.global_position.x + SPAWN_OFFSET + 2000

# Node children

@onready var horizon_line: Line2D = $HorizonLine
@onready var horizon_collision: CollisionPolygon2D = $HorizonCollision
@onready var underground: Polygon2D = $Underground

# =============================================================

# Functions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var terrain_points : PackedVector2Array = generate_terrain(10000)
	construct_terrain(terrain_points)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Generate random terrain points;
## Params: length : int - Terrain length in pixels
## Returns: terrain_points : PackedVector2Array - Points to be used for terrain generation
func generate_terrain(length : int) -> PackedVector2Array:
	
	var terrain_points : PackedVector2Array = []
	
	# Initialize flat terrain at stage start
	terrain_points.append(Vector2(-SPAWN_OFFSET, FLOOR_HEIGHT))
	terrain_points.append(Vector2(0, FLOOR_HEIGHT))
	terrain_points.append(Vector2(FIRST_ENEMY, FLOOR_HEIGHT))
	
	# Start iteratively generating terrain after first enemy
	var current_x : int = FIRST_ENEMY
	var current_y : int = FLOOR_HEIGHT
	while current_x < length:
		current_x += randi_range(SMOOTHNESS - SMOOTHNESS * 0.5, SMOOTHNESS + SMOOTHNESS * 0.5)
		current_y += randi_range(ROUGHNESS * -0.5, ROUGHNESS * 0.5)
		current_y = clamp(current_y, HEIGHT_RANGE[0], HEIGHT_RANGE[1])
		var terrain_point : Vector2 = Vector2(current_x, current_y)
		terrain_points.append(terrain_point)
	
	# Add final points to finish off polygon
	terrain_points.append(Vector2(current_x, HEIGHT_RANGE[1] + 500))
	terrain_points.append(Vector2(-SPAWN_OFFSET, HEIGHT_RANGE[1] + 500))
	
	return terrain_points

## Construct terrain object from terrain points
## Params: points - terrain_points generated via generate_terrain()
## Returns: void
func construct_terrain(points : PackedVector2Array) -> void:
	# Construct HorizonLine
	horizon_line.points = points
	# Construct HorizonCollision
	#horizon_collision.polygon = points
	horizon_collision.set_deferred("polygon", points)
	# Construct Underground (polygon)
	underground.polygon = points
