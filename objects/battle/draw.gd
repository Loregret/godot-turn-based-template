# tool
extends Node2D


export var draw := true
# Bools
export var draw_grid := true
export var draw_points := true
export var draw_connections := true
export var draw_indexes := true
# Customization
export var color := Color.black
export var connection_color := Color("#47000000")
export var line_thickness := 4.5
# Nodes
export var grid_path: NodePath

var grid:Node2D 
var cell_size:Vector2
var size:Vector2
var pathfinding:Node  


func _ready() -> void:
	if has_node(grid_path):
		grid = get_node(grid_path) 
		cell_size = grid.cell_size
		size = grid.grid_size
		pathfinding = grid.get_node("Pathfinding")
		update()
	else:
		push_error( "draw script: grid_path is invalid")


func _draw() -> void:
	if has_node(grid_path) and draw:
		if draw_grid: _draw_grid()
		if Engine.editor_hint: return
		if draw_connections: _draw_point_connections()
		if draw_indexes: _draw_indexes()
		if draw_points: _draw_points()
		_draw_path(grid.selected_unit)


func _draw_grid() -> void:
	for x in range(0, size.x + 1):
		draw_line(Vector2(x * cell_size.x, 0), Vector2(x*cell_size.x, cell_size.y * size.y), color, line_thickness)
		for y in range(0, size.y + 1):
			draw_line(Vector2(-2.2, y * cell_size.y), Vector2(size.x * cell_size.x + 1.8, y * cell_size.y),color,line_thickness)


func _draw_point_connections() -> void:
	for i in pathfinding.astar.get_points():
		var cp = pathfinding.astar.get_point_connections(i)
		for z in cp:
			var start_pos: Vector2 = pathfinding.astar.get_point_position(i)
			var end_pos:Vector2 = pathfinding.astar.get_point_position(z)
			draw_line(start_pos, end_pos, connection_color, 1)


func _draw_indexes() -> void:
	for i in pathfinding.astar.get_points():
		var label = Label.new()
		var font = label.get_font("")
		var id = str(i)
		draw_string(font, (pathfinding.astar.get_point_position(i)) - Vector2(3.7,-1) * str(i).length(),  id, color)
		label.free()


func _draw_points() -> void:
	for i in pathfinding.astar.get_points():
		draw_circle(pathfinding.astar.get_point_position(i), 2.0, Color.red)


func _draw_path(unit) -> void:
	for i in range(0, unit.path.size()):
		if unit.path.size() > 1:
			draw_circle(unit.path[i], 5.0, Color.red)
			if i < unit.path.size() - 1: 
				draw_line(unit.path[i], unit.path[i+1], Color.red, 2.0)