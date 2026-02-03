extends TileMapLayer

@onready var main = $"../.."

const DEBRIS = preload("uid://rg2m11gs0xex")

# Called when the node enters the scene tree for the first time.
func _ready():
	#for child in get_parent().get_children():
		#if child.name == "Weapons":
			#for module in child.get_children():
				#connected_modules.append(module)
			#break
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

# Call this when taking damage.
func take_damage(damage_value : int, collision : KinematicCollision2D, knockback_force : int):
	# Convert collision position: Global -> Local -> Tilemap
	var collision_pos_global = collision.get_position()
	var collision_pos_local = to_local(collision_pos_global)
	var collided_tile_pos = self.local_to_map(collision_pos_local)
	# Remember tile atlas coords for debris spawning
	var collided_tile_atlas = self.get_cell_atlas_coords(collided_tile_pos)
	# Destroy collided tile at tilemap coords
	self.set_cell(collided_tile_pos, -1)
	# Spawn debris
	var debris_instance = DEBRIS.instantiate()
	main.add_child(debris_instance)
	debris_instance.global_position = collision_pos_global
	debris_instance.set_sprite(collided_tile_atlas)
	# Give debris initial velocity based on projectile collision angle
	# (make debris be "knocked back" by explosion)
	var impact_dir = collision.get_position() - global_position
	debris_instance.apply_impulse(-impact_dir.normalized() * knockback_force)
	debris_instance.apply_impulse(Vector2.UP * knockback_force * 2)
	# HP gameplay logic
	get_parent().take_damage(damage_value)

# Helper function for death handling.
# To be used only by break_all_tiles()
# Do not call this directly.
func _break_random_tile():
	# Get random tile
	var used_cells = get_used_cells()
	var chosen_cell_index = randi_range(0, used_cells.size())
	# Check if cell still exists
	if chosen_cell_index >= used_cells.size():
		return
	var chosen_cell = used_cells[chosen_cell_index]
	# Remember tile atlas coords for debris spawning
	var chosen_tile_atlas = self.get_cell_atlas_coords(chosen_cell)
	# Destroy collided tile at tilemap coords
	self.set_cell(chosen_cell, -1)
	# Spawn debris
	var debris_instance = DEBRIS.instantiate()
	main.add_child(debris_instance)
	debris_instance.global_position = to_global(map_to_local(chosen_cell))
	debris_instance.set_sprite(chosen_tile_atlas)

func break_all_tiles():
	while get_used_cells().size() > 0:
		await get_tree().process_frame
		_break_random_tile()
