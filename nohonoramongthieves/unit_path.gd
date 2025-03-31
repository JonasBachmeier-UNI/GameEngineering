extends TileMapLayer

@onready var gameboard = $"../../GameBoard"
enum DIRECTION {START_LEFT, START_RIGHT, START_UP, START_DOWN, LEFT_RIGHT, UP_DOWN, LEFT_UP, LEFT_DOWN, RIGHT_UP, RIGHT_DOWN}

func path_to_tilemap(path):
	clear()
	if len(path) < 2:
		return
	
	for i in range(len(path)):
		var old = null
		var cur = path[i]
		var new = null
		if i > 0:
			old = path[i-1]
		if i < len(path)-1:
			new = path[i+1]
		
		var dir = get_direction(old, cur, new)
		set_direction_tile(cur, dir)


func get_direction(pos_old, pos_cur, pos_new):
	if pos_old == null:
		return get_start_direction(pos_cur, pos_new)
	
	if pos_new == null:
		return get_end_direction(pos_old, pos_cur)
	
	if pos_old[0] == pos_new[0]:
		return DIRECTION.UP_DOWN
	
	if pos_old[1] == pos_new[1]:
		return DIRECTION.LEFT_RIGHT
	
	if pos_cur[0] > pos_old[0]:
		if pos_cur[1] > pos_new[1]:
			return DIRECTION.LEFT_UP
		return DIRECTION.LEFT_DOWN
	
	if pos_cur[0] < pos_old[0]:
		if pos_cur[1] > pos_new[1]:
			return DIRECTION.RIGHT_UP
		return DIRECTION.RIGHT_DOWN
	
	if pos_cur[1] > pos_old[1]:
		if pos_cur[0] > pos_new[0]:
			return DIRECTION.LEFT_UP
		return DIRECTION.RIGHT_UP
	
	if pos_cur[1] < pos_old[1]:
		if pos_cur[0] > pos_new[0]:
			return DIRECTION.LEFT_DOWN
		return DIRECTION.RIGHT_DOWN

func get_start_direction(pos_cur, pos_new):
	if pos_new[0] > pos_cur[0]:
		return DIRECTION.START_RIGHT
	if pos_new[0] < pos_cur[0]:
		return DIRECTION.START_LEFT
	if pos_new[1] > pos_cur[1]:
		return DIRECTION.START_DOWN
	return DIRECTION.START_UP

func get_end_direction(pos_old, pos_cur):
	if pos_old[0] > pos_cur[0]:
		return DIRECTION.START_RIGHT
	if pos_old[0] < pos_cur[0]:
		return DIRECTION.START_LEFT
	if pos_old[1] > pos_cur[1]:
		return DIRECTION.START_DOWN
	return DIRECTION.START_UP


func set_direction_tile(gb_pos, dir):
	var tile = gameboard.grid_to_tml_coords(gb_pos)
	var tile_set_id = direction_to_id(dir)
	set_cell(tile, tile_set_id, Vector2i(0, 0))

func direction_to_id(dir: DIRECTION):
	match dir:
		DIRECTION.START_LEFT:
			return 4
		DIRECTION.START_RIGHT:
			return 6
		DIRECTION.START_UP:
			return 5
		DIRECTION.START_DOWN:
			return 7
		DIRECTION.LEFT_RIGHT:
			return 0
		DIRECTION.UP_DOWN:
			return 3
		DIRECTION.LEFT_UP:
			return 1
		DIRECTION.LEFT_DOWN:
			return 8
		DIRECTION.RIGHT_UP:
			return 2
		DIRECTION.RIGHT_DOWN:
			return 9
	print("FEHLER IN unit_path.gd: direction_to_id")
	return 0
