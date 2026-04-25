@tool
class_name GeneratorGrid
extends Node

@export_tool_button("Generate Grid", "Callable") var button_generate_grid = generate_grid
@export var grid_system:PackedScene

func generate_grid():
	var grid_system: GridSystem = grid_system.instantiate()
	
	print("wesh", grid_system, grid_system.get_script())
	add_child(grid_system)
	if grid_system:
		print(grid_system.has_method("grid_system"))
		grid_system.init_grid()
	else:
		push_warning("MISSING REFERENCE TO GridSystem")
		print_stack()
