extends StaticBody2D

# Consts

const FLOOR_HEIGHT = 608 # Standard floor height
const SPAWN_OFFSET = 750 # Next enemy offset in pixels
const FIRST_ENEMY = 2500 # First enemy X coordinate

# =============================================================

# Export vars

@export var HEIGHT_RANGE : Vector2i = Vector2(-500, 608) # Min; Max
# Note: Godot uses inverted Y coords. -500 is higher than 608.

## Length of terrain to be generated before next enemy spawn
@export var SPAWN_INTERVAL = 2250

## Length of flatland for 1v1 mech combat
@export var COMBAT_ARENA_LENGTH : int = 300
@export var COMBAT_ARENA_OFFSET : int = 300

## Average length of terrain generated before height change
@export var SMOOTHNESS : int = 128

## Average height deviation of terrain at height change
@export var ROUGHNESS : int = 128

## Textures
@export var texture_line : Texture2D = null
@export var texture_polygon : Texture2D = null

# =============================================================

# NOTICE
# Next enemy always spawns at: 
# screen_limit.global_position.x - 950

# Node children

@onready var horizon_line: Line2D = $HorizonLine
@onready var horizon_collision: CollisionPolygon2D = $HorizonCollision
@onready var underground: Polygon2D = $Underground

# =============================================================

# Functions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_terrain_objects()
	var terrain_points : PackedVector2Array = generate_terrain(50000)
	var smoothed_terrain_points = smooth_terrain(terrain_points)
	construct_terrain(smoothed_terrain_points)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func initialize_terrain_objects():
	horizon_line.texture = texture_line
	horizon_line.texture_mode = Line2D.LINE_TEXTURE_TILE
	horizon_line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	horizon_line.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	horizon_line.width = 16
	
	underground.texture = texture_polygon
	underground.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	underground.texture_scale = Vector2(1.0, 1.0)

## Generate random terrain points;
## Params: length : int - Terrain length in pixels
## Returns: terrain_points : PackedVector2Array - Points to be used for terrain generation
func generate_terrain(length : int) -> PackedVector2Array:
	
	var terrain_points : PackedVector2Array = []
	
	# Initialize flat terrain at stage start
	terrain_points.append(Vector2(-SPAWN_OFFSET, FLOOR_HEIGHT))
	terrain_points.append(Vector2(FIRST_ENEMY, FLOOR_HEIGHT))
	
	# Start iteratively generating terrain after first enemy
	var current_x : int = FIRST_ENEMY
	var current_y : int = FLOOR_HEIGHT
	var enemy_x : int = 0
	var terrain_point : Vector2 = Vector2.ZERO
	while current_x < length:
		enemy_x = 0
		while enemy_x < SPAWN_INTERVAL - (COMBAT_ARENA_LENGTH + 128):
			@warning_ignore("narrowing_conversion")
			var road_length = randi_range(SMOOTHNESS - SMOOTHNESS * 0.5, SMOOTHNESS + SMOOTHNESS * 0.5)
			current_x += road_length
			enemy_x += road_length
			@warning_ignore("narrowing_conversion")
			current_y += randi_range(ROUGHNESS * -0.5, ROUGHNESS * 0.5)
			current_y = clamp(current_y, HEIGHT_RANGE[0], HEIGHT_RANGE[1])
			terrain_point = Vector2(current_x, current_y)
			terrain_points.append(terrain_point)
		# Add arena point
		current_x += COMBAT_ARENA_LENGTH + COMBAT_ARENA_OFFSET
		terrain_point = Vector2(current_x, current_y)
		terrain_points.append(terrain_point)
		
	# Add final points to finish off polygon
	terrain_points.append(Vector2(current_x, HEIGHT_RANGE[1] + 500))
	terrain_points.append(Vector2(-SPAWN_OFFSET, HEIGHT_RANGE[1] + 500))
	
	return terrain_points

# Chaikin's corner-cutting algorithm
func smooth_terrain(points: PackedVector2Array, iterations := 2) -> PackedVector2Array:
	var current := points

	for _i in range(iterations):
		var next := PackedVector2Array()

		next.append(current[0])

		for j in range(current.size() - 1):
			var p0 = current[j]
			var p1 = current[j + 1]

			var q = p0.lerp(p1, 0.25)
			var r = p0.lerp(p1, 0.75)

			next.append(q)
			next.append(r)

		next.append(current[-1])

		current = next

	return current

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
