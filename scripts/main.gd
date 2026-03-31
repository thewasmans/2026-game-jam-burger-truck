extends Node3D

@export var snack_truck: SnackTruck
@export var game_ui: GameUI
@export var spawner: EnemySpawner
@export var level: Node

func _ready() -> void:
	snack_truck.reputation_changed.connect(game_ui.on_reputation_changed)

func on_child_entered_tree(node: Node) -> void:
	if node is Enemy:
		var enemy: Enemy = node as Enemy
		enemy.leaving_truck.connect(on_enemy_leaving)

func on_enemy_leaving() -> void:
	snack_truck.take_damage(1)
