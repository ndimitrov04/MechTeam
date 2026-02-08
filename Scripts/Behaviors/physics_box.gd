extends CollisionPolygon2D

@onready var frame = $"../Frame"
@onready var mech = get_parent()

func _ready():
	generate_collisions()

func generate_collisions():
	var tileset = frame.tile_set
	var tile_size = frame.tile_set.tile_size

	for cell in frame.get_used_cells():
		var source_id = frame.get_cell_source_id(0, cell)
		if source_id == -1:
			continue

		var atlas_coords = frame.get_cell_atlas_coords(0, cell)
		var tile_data = tileset.get_source(source_id).get_tile_data(atlas_coords)

		if tile_data == null:
			continue

		for i in tile_data.get_collision_polygons_count(0):
			var polygon = tile_data.get_collision_polygon_points(0, i)

			var collision := CollisionPolygon2D.new()
			collision.polygon = polygon
			collision.position = frame.map_to_local(cell)

			mech.add_child(collision)
