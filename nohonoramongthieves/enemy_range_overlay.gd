extends TileMapLayer

enum BORDER_DIR {BLANK, LEFT, UP, RIGHT, DOWN, LEFT_UP, RIGHT_UP, RIGHT_DOWN, LEFT_DOWN, LEFT_UP_DOWN, LEFT_UP_RIGHT, UP_RIGHT_DOWN, LEFT_DOWN_RIGHT, LEFT_RIGHT, UP_DOWN}
@onready var gameboard = $"../../GameBoard"

func show_overlay_for_grid(grid):
	for pos in grid:
		var c_type = border_check(pos, grid)
		set_cell_enum(pos, c_type)


func border_check(pos, grid):
	if has_left_border(pos, grid) and !has_right_border(pos, grid) and !has_upper_border(pos, grid) and !has_lower_border(pos, grid):
		return BORDER_DIR.LEFT
	if !has_left_border(pos, grid) and has_right_border(pos, grid) and !has_upper_border(pos, grid) and !has_lower_border(pos, grid):
		return BORDER_DIR.RIGHT
	if !has_left_border(pos, grid) and !has_right_border(pos, grid) and has_upper_border(pos, grid) and !has_lower_border(pos, grid):
		return BORDER_DIR.UP
	if !has_left_border(pos, grid) and !has_right_border(pos, grid) and !has_upper_border(pos, grid) and has_lower_border(pos, grid):
		return BORDER_DIR.DOWN
	if has_left_border(pos, grid) and has_right_border(pos, grid) and !has_upper_border(pos, grid) and !has_lower_border(pos, grid):
		return BORDER_DIR.LEFT_RIGHT
	if has_left_border(pos, grid) and !has_right_border(pos, grid) and has_upper_border(pos, grid) and !has_lower_border(pos, grid):
		return BORDER_DIR.LEFT_UP
	if has_left_border(pos, grid) and !has_right_border(pos, grid) and !has_upper_border(pos, grid) and has_lower_border(pos, grid):
		return BORDER_DIR.LEFT_DOWN
	if !has_left_border(pos, grid) and has_right_border(pos, grid) and has_upper_border(pos, grid) and !has_lower_border(pos, grid):
		return BORDER_DIR.RIGHT_UP
	if !has_left_border(pos, grid) and has_right_border(pos, grid) and !has_upper_border(pos, grid) and has_lower_border(pos, grid):
		return BORDER_DIR.RIGHT_DOWN
	if !has_left_border(pos, grid) and !has_right_border(pos, grid) and has_upper_border(pos, grid) and has_lower_border(pos, grid):
		return BORDER_DIR.UP_DOWN
	if has_left_border(pos, grid) and !has_right_border(pos, grid) and has_upper_border(pos, grid) and has_lower_border(pos, grid):
		return BORDER_DIR.LEFT_UP_DOWN
	if has_left_border(pos, grid) and has_right_border(pos, grid) and has_upper_border(pos, grid) and !has_lower_border(pos, grid):
		return BORDER_DIR.LEFT_UP_RIGHT
	if has_left_border(pos, grid) and has_right_border(pos, grid) and !has_upper_border(pos, grid) and has_lower_border(pos, grid):
		return BORDER_DIR.LEFT_DOWN_RIGHT
	if !has_left_border(pos, grid) and has_right_border(pos, grid) and has_upper_border(pos, grid) and has_lower_border(pos, grid):
		return BORDER_DIR.UP_RIGHT_DOWN
	return BORDER_DIR.BLANK


func has_left_border(field, grid):
	if grid.has(Vector2i(field[0]-1, field[1])):
		return false
	return true

func has_right_border(field, grid):
	if grid.has(Vector2i(field[0]+1, field[1])):
		return false
	return true

func has_upper_border(field, grid):
	if grid.has(Vector2i(field[0], field[1]-1)):
		return false
	return true

func has_lower_border(field, grid):
	if grid.has(Vector2i(field[0], field[1]+1)):
		return false
	return true


func set_cell_enum(pos, border_dir: BORDER_DIR):
	var tml_pos = gameboard.grid_to_tml_coords(pos)
	var tml_id = get_id_for_border_dir(border_dir)
	set_cell(tml_pos, tml_id, Vector2i(0, 0))

func get_id_for_border_dir(border_dir: BORDER_DIR):
	match border_dir:
		BORDER_DIR.BLANK: return 0
		BORDER_DIR.LEFT: return 1
		BORDER_DIR.UP: return 2
		BORDER_DIR.RIGHT: return 3
		BORDER_DIR.DOWN: return 4
		BORDER_DIR.LEFT_UP: return 5
		BORDER_DIR.RIGHT_UP: return 6
		BORDER_DIR.RIGHT_DOWN: return 7
		BORDER_DIR.LEFT_DOWN: return 8
		BORDER_DIR.LEFT_UP_DOWN: return 9
		BORDER_DIR.LEFT_UP_RIGHT: return 10
		BORDER_DIR.UP_RIGHT_DOWN: return 11
		BORDER_DIR.LEFT_DOWN_RIGHT: return 12
		BORDER_DIR.LEFT_RIGHT: return 13
		BORDER_DIR.UP_DOWN: return 14
