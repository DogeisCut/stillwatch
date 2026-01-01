extends Node2D

@export var enemy_scene: PackedScene
@export var crate_scene: PackedScene
@export var auto_turret_scene: PackedScene

@onready var navigation_region_2d: NavigationRegion2D = %NavigationRegion2D

const SPAWN_AREA = Rect2(-192.0,-192.0,1536.0,1024.0)
const CRATE_SPAWN_AREA = Rect2(512.0,256.0,128.0,128.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.enemy_spawn_timer.timeout.connect(_spawn_enemy)
	Game.game_state_changed.connect(_on_game_state_changed)

func _physics_process(_delta):
	if get_tree().get_nodes_in_group("crate").size() < Game.current_upgrades[Game.UpgradesList.CRATE]:
		_spawn_crate()
	if get_tree().get_nodes_in_group("auto_turret").size() < Game.current_upgrades[Game.UpgradesList.AUTO_TURRET]:
		_spawn_turret()

func _on_game_state_changed():
	if Game.game_state == Game.GameStates.FIGHTING_WAVE:
		navigation_region_2d.bake_navigation_polygon()

func _spawn_enemy():
	if Game.game_state == Game.GameStates.FIGHTING_WAVE:
		var enemy: Enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.global_position = get_spawn_pos(SPAWN_AREA)

func _spawn_crate():
	var crate: Crate = crate_scene.instantiate()
	navigation_region_2d.add_child(crate)
	crate.global_position = get_total_spawn_pos(CRATE_SPAWN_AREA)

func _spawn_turret():
	var crate: AutoTurret = auto_turret_scene.instantiate()
	navigation_region_2d.add_child(crate)
	crate.global_position = get_total_spawn_pos(CRATE_SPAWN_AREA)

func get_total_spawn_pos(rectangle_area: Rect2) -> Vector2:
	var random_number_generator := RandomNumberGenerator.new()
	var rectangle_position := rectangle_area.position
	var rectangle_size := rectangle_area.size
	var rectangle_end := rectangle_position + rectangle_size
	
	return Vector2(
		random_number_generator.randf_range(rectangle_position.x, rectangle_end.x),
		random_number_generator.randf_range(rectangle_position.y, rectangle_end.y)
	)

func get_spawn_pos(rectangle_area: Rect2) -> Vector2:
	var random_number_generator := RandomNumberGenerator.new()
	var rectangle_position := rectangle_area.position
	var rectangle_size := rectangle_area.size
	var rectangle_end := rectangle_position + rectangle_size
	
	var chosen_edge := random_number_generator.randi_range(0, 3)
	
	if chosen_edge == 0:
		return Vector2(
			random_number_generator.randf_range(rectangle_position.x, rectangle_end.x),
			rectangle_position.y
		)
	elif chosen_edge == 1:
		return Vector2(
			random_number_generator.randf_range(rectangle_position.x, rectangle_end.x),
			rectangle_end.y
		)
	elif chosen_edge == 2:
		return Vector2(
			rectangle_position.x,
			random_number_generator.randf_range(rectangle_position.y, rectangle_end.y)
		)
	else:
		return Vector2(
			rectangle_end.x,
			random_number_generator.randf_range(rectangle_position.y, rectangle_end.y)
		)
