extends TileMapLayer

@onready var main = $"../.."

const DEBRIS = preload("uid://rg2m11gs0xex")
const DEBRIS_NOEXPL = preload("uid://cnockwlnou78d")

var explosions : bool = true

var total_cells_used : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	total_cells_used = get_used_cells().size()
	print("BG used: " + str(total_cells_used))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Visually destroy tile
func break_random_tile():
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
	var debris_instance
	if explosions:
		debris_instance = DEBRIS.instantiate()
	else:
		debris_instance = DEBRIS_NOEXPL.instantiate()
	main.call_deferred("add_child", debris_instance)
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
	while get_used_cells().size() > 0:
		if not get_tree():
			return
		await get_tree().process_frame
		await get_tree().process_frame
		if total_cells_used <= 0:
			print_debug("No more cells left.")
			return
		@warning_ignore("integer_division")
		if get_used_cells().size() % (total_cells_used / 64) == 0:
			break_random_tile()
		else:
			_remove_random_tile()
