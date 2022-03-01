extends Node2D


export var cell_size := Vector2(80, 80)
export var grid_size := Vector2(5, 5)

var half_cell_size := cell_size / 2

onready var draw = $Draw
onready var pathfinding = $Pathfinding 
onready var selected_unit := get_node("Units/Unit")
onready var grid_real_size := grid_size * cell_size


func _ready():
	generate_pathfinding()


func _input(event):
	if event.is_action_released("LeftClick") and is_within_bounds(get_global_mouse_position()) and not selected_unit.is_moving:
		selected_unit.move_to_index(pathfinding.astar.get_closest_point(get_global_mouse_position() - position), true)
		print("grid mouse input: ", get_global_mouse_position() - position)
		print("Unit ",selected_unit.get_instance_id()," moving to cell: ",
		pathfinding.astar.get_closest_point(get_global_mouse_position()))


func generate_pathfinding() -> void:
	var i := 0
	for y in range(0, grid_size.y):	
		for x in range(0, grid_size.x):
			# Add point 
			pathfinding.astar.add_point(i, (Vector2(x,y) * cell_size + half_cell_size))	
			generate_connection(x, y, i)
			i += 1


func generate_connection(x:int, y:int, i:int) -> void:
	# ?
	connect_point_if_valid(i, i + int(grid_size.y))	
	connect_point_if_valid(i, i - int(grid_size.y))	
	# x
	if x > 0:
		connect_point_if_valid(i, i - 1)
	if x < grid_size.x:
		connect_point_if_valid(i, i + 1)
	# y
	if x < grid_size.x and y < grid_size.y:
		connect_point_if_valid(i, i + int(grid_size.y) + 1)	
	if x > 0 and y > grid_size.y:
		connect_point_if_valid(i, i + int(grid_size.y) - 1)	
	# diagonal
	if x < grid_size.x and y > 0:
		connect_point_if_valid(i, i - int(grid_size.y) + 1)	
	if x > 0 and y > 0:
		connect_point_if_valid(i, i - int(grid_size.y) - 1)	


func connect_point_if_valid( existing_point:int, connect_point:int ) -> void:
	if pathfinding.astar.has_point(connect_point):
		pathfinding.astar.connect_points(existing_point, connect_point, true)	


func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var out := cell_coordinates.x >= position.x and cell_coordinates.x - position.x < grid_real_size.x
	return out and cell_coordinates.y >= position.y and cell_coordinates.y - position.y < grid_real_size.y


