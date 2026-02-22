extends Node2D

@onready var npcs = $"../NPCs"

const DEFENDER = preload("uid://c2df7dij3p5ck")

@onready var spawn_chance = get_meta("spawn_chance") 

# Called when the node enters the scene tree for the first time.
func _ready():
	var enemies = [DEFENDER]
	
	for spawner in get_children():
		if randf() < spawn_chance:
			var enemy_instance = enemies.pick_random().instantiate()
			npcs.add_child(enemy_instance)
			enemy_instance.global_position = spawner.global_position
