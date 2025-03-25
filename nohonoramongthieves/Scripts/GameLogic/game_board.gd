extends Node

@export var tml: TileMapLayer

var action_select

## für Übersetzung des TMLs in eine Matrix
var MINIMUM_OFFSET_X: int
var MINIMUM_OFFSET_Y: int

@export var movement_cost = {
	0 : 1,
	1 : 999
}

## Dimensionen der Matrix
var width: int
var height: int
## Matrix für TML
var grid = []
signal matrix_ready(value)

func _ready() -> void:
	var used_cells = tml.get_used_cells()
	calculate_minimum_offsets(used_cells)
	
	create_matrix(used_cells)
	emit_signal("matrix_ready", grid)
	
	action_select = $"../ActionSelect"
	action_select.visible = false
	
func _process(delta: float) -> void:
	pass


func calculate_minimum_offsets(cells: Array[Vector2i]):
	var current_min_x = 0
	var current_min_y = 0
	var current_max_x = 0
	var current_max_y = 0
	
	for cell in cells:
		if current_min_x > cell[0]:
			current_min_x = cell[0]
		if current_min_y > cell[1]:
			current_min_y = cell[1]
			
		if current_max_x < cell[0]:
			current_max_x = cell[0]
		if current_max_y < cell[1]:
			current_max_y = cell[1]
			
	MINIMUM_OFFSET_X = abs(current_min_x)
	MINIMUM_OFFSET_Y = abs(current_min_y)
	
	width = current_max_x - current_min_x + 1
	height = current_max_y - current_min_y + 1
	
	
func create_matrix(cells: Array[Vector2i]):
	
	for x in range(height):
		grid.append([])
		for y in range(width):
			grid[x].append(1000)
	
	# Matrix Koordinaten normalisiert und mit Atlas-ID befüllt
	for cell in cells:
		var grid_coords = tml_to_grid_coords(cell)
		var value = tml.get_cell_source_id(cell)
		set_grid_value(grid_coords, movement_cost[value])
		
	

func tml_to_grid_coords(tml_coords: Vector2i):
	return Vector2i(
		tml_coords[0] + MINIMUM_OFFSET_X,
		tml_coords[1] + MINIMUM_OFFSET_Y
		)
		
func grid_to_tml_coords(grid_coords: Vector2i):
	return Vector2i(
		grid_coords[0] - MINIMUM_OFFSET_X,
		grid_coords[1] - MINIMUM_OFFSET_Y
		)

func get_grid_value(coords: Vector2i):
	return grid[coords[1]][coords[0]]
	
func set_grid_value(coords: Vector2i, value):
	grid[coords[1]][coords[0]] = value

func print_grid():
	for x in grid:
		print(x)
		
func get_grid():
	return grid


func _on_cursor_show_actions(x, y, unit_selected) -> void:
	print(unit_selected)
	print(action_select)
	action_select.unit_selected = unit_selected
	action_select.x_pos = x
	action_select.y_pos = y
	action_select.visible = true
