extends TileMapLayer

@onready var main = $"../.."

const DEBRIS = preload("uid://rg2m11gs0xex")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func break_random_tile():
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
		break_random_tile()
