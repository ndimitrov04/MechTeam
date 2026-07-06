extends TileMapLayer

@onready var main = $"../.."
#@onready var navigation_region: NavigationRegion2D = $"../NavigationRegion"

const DEBRIS = preload("uid://rg2m11gs0xex")
const DEBRIS_NOEXPL = preload("uid://cnockwlnou78d")

# Used as collider for rigidbody
const PHYSICS_COLLIDER = preload("uid://d27duv3avvgoi")
# Used by regenerate_frame_collision
# Determines where hitbox child clearing will start
var collision_child_index_start

var explosions : bool = true

var total_cells_used : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	#for child in get_parent().get_children():
		#if child.name == "Weapons":
			#for module in child.get_children():
				#connected_modules.append(module)
			#break
	await get_tree().create_timer(0.2).timeout
	collision_child_index_start = get_parent().get_child_count()
	await get_tree().create_timer(0.2).timeout
	regenerate_frame_collision() # Extremely expensive :(
	total_cells_used = get_used_cells().size()
	print("Frame used: " + str(total_cells_used))

# Called every self. 'delta' is the elapsed time since the previous self.
func _physics_process(_delta):
	pass

# Call this when taking damage.
func take_damage(damage_value : int, collision : KinematicCollision2D, knockback_force : int):
	# HP gameplay logic
	get_parent().take_damage(damage_value)
	# Convert collision position: Global -> Local -> Tilemap
	if not collision:
		return
	#print("Took hit")
	var collision_pos_global = collision.get_position()
	# Push the point slightly into the tile that was hit
	# to ensure correct coordinate match-up with tile position
	var collision_normal = collision.get_normal()
	var biased_pos = collision_pos_global - collision_normal * 0.1
	var collision_pos_local = to_local(biased_pos)
	var collided_tile_pos = self.local_to_map(collision_pos_local)
	# Remember tile atlas coords for debris spawning
	var collided_tile_atlas = self.get_cell_atlas_coords(collided_tile_pos)
	# Destroy collided tile at tilemap coords
	self.set_cell(collided_tile_pos, -1)
	destroy_frame_collision_cell(collided_tile_pos)
	# Spawn debris
	var debris_instance = DEBRIS.instantiate()
	main.add_child(debris_instance)
	debris_instance.global_position = collision_pos_global
	debris_instance.set_sprite(collided_tile_atlas)
	# Give debris initial velocity based on projectile collision angle
	# (make debris be "knocked back" by explosion)
	var impact_dir = biased_pos - collision.get_position()
	debris_instance.apply_impulse(impact_dir.normalized() * knockback_force)
	debris_instance.apply_impulse(Vector2.UP * knockback_force * 2)
	# Push parent back; Push the parent back more *the more it weighs*
	# (No, this is not a mistake)
	var true_knockback = impact_dir * knockback_force * (get_parent().weight + 30)
	var predictable_knockback = true_knockback * Vector2(1, 0.1)  # Eliminate wild upward momentum
	get_parent().apply_impulse(predictable_knockback, collision_pos_global)
	# Regenerate physics body's hitboxes
	# regenerate_frame_collision()

# Helper function for death handling.
# To be used only by break_all_tiles()
# Do not call this directly.
func _break_random_tile():
	# Get random tile
	var used_cells = get_used_cells()
	if used_cells.is_empty():
		return
	var chosen_cell_index = randi_range(0, used_cells.size() - 1)
	# Check if cell still exists
	if chosen_cell_index >= used_cells.size():
		return
	var chosen_cell = used_cells[chosen_cell_index]
	# Remember tile atlas coords for debris spawning
	var chosen_tile_atlas = self.get_cell_atlas_coords(chosen_cell)
	# Destroy collided tile at tilemap coords
	self.set_cell(chosen_cell, -1)
	# Spawn debris
	var debris_instance
	if explosions:
		debris_instance = DEBRIS.instantiate()
	else:
		debris_instance = DEBRIS_NOEXPL.instantiate()
	main.add_child(debris_instance)
	debris_instance.global_position = to_global(map_to_local(chosen_cell))
	debris_instance.set_sprite(chosen_tile_atlas)

# Remove tile instantly without explosion or debris
func _remove_random_tile():
	# Get random tile
	var used_cells = get_used_cells()
	var chosen_cell_index = randi_range(0, used_cells.size() - 1)
	var chosen_cell = used_cells[chosen_cell_index]
	# Check if cell still exists
	if chosen_cell_index >= used_cells.size():
		return
	# Destroy collided tile at tilemap coords
	self.set_cell(chosen_cell, -1)

func break_all_tiles():
	explosions = false
	if not get_tree():
		return
	while get_used_cells().size() > 0:
		await get_tree().process_frame
		await get_tree().process_frame
		if total_cells_used <= 0:
			print_debug("No more cells left.")
			return
		@warning_ignore("integer_division")
		if get_used_cells().size() % (max(1, total_cells_used / 64)) == 0:
			_break_random_tile()
		else:
			_remove_random_tile()

## Generates static hitboxes based on tile data.
## For use as a physics body's hitbox children. 
## Extremely expensive :(
func regenerate_frame_collision():
	# Clear physics collision shapes
	for i in range(collision_child_index_start, get_parent().get_child_count()):
		get_parent().get_child(i).queue_free()
	
	# Generate physics collision shapes
	var cells = self.get_used_cells()
	for cell_coord in cells:
		var collider_instance = PHYSICS_COLLIDER.instantiate()
		get_parent().add_child(collider_instance)
		collider_instance.position = self.map_to_local(cell_coord)
		collider_instance.cell_coordinates = cell_coord
	
	# Regenerate loacl navmesh
	#navigation_region.bake_navigation_polygon()

func destroy_frame_collision_cell(cell_coords : Vector2i):
	for i in range(collision_child_index_start, get_parent().get_child_count()):
		var current_collider = get_parent().get_child(i)
		if current_collider.cell_coordinates != cell_coords:
			continue
		current_collider.queue_free()
