extends TileMapLayer

@onready var main = $"../.."

const DEBRIS = preload("uid://rg2m11gs0xex")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func take_damage(collision : KinematicCollision2D, knockback_force : int):
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
	# Add additional HP gameplay logic
