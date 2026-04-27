class_name Furniture3D
extends Node3D

@export var blocks: Array[Node3D]

func blocks_to_2D_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for block in blocks:
		positions.append(Vector2(block.position.x, block.position.z))
	return positions
