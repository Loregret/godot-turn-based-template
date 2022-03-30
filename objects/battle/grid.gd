extends Node2D


export var cell_size := Vector2(80, 80)
export var grid_size := Vector2(5, 5)

var half_cell_size := cell_size / 2
var units := []

onready var draw = $Draw
onready var pathfinding = $Pathfinding 
onready var selected_unit:Area2D = get_node_or_null("Units/Unit")
onready var grid_real_size:Vector2 = grid_size * cell_size


func _ready():
	generate_pathfinding()
	create_units_list()
	yield(get_tree().create_timer(1), "timeout")



func _input(event):
	# Movement
	if event.is_action_released("LeftClick") and selected_unit != null:
		if is_within_bounds(get_global_mouse_position()) and not selected_unit.is_moving:
			selected_unit.move_to_index(pathfinding.astar.get_closest_point(get_global_mouse_position() - position), true)
	# Selection
	if event.is_action_released("LeftClick") and selected_unit == null:
		pass
	# Deselect
	if event.is_action_released('RightClick') and selected_unit != null and not selected_unit.is_moving:
		selected_unit = null


func generate_pathfinding() -> void:
	var i := 0
	for y in range(0, grid_size.y):	
		for x in range(0, grid_size.x):
			# Add point 
			pathfinding.astar.add_point(i, (Vector2(x,y) * cell_size + half_cell_size))	
			generate_connection(x, y, i)
			i += 1


func generate_connection(x:int, y:int, i:int) -> void:
	# connect boundaries
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


func create_units_list():
	units = get_node("Units").get_children()
	connect_to_units()
	
func connect_to_units():
	for cur_unit in units:
			cur_unit.connect("clicked", self, "_on_unit_clicked")


func _on_unit_clicked(value):
	print(value)
