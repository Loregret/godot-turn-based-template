extends Node2D
var grid:Node2D

export var grid_path: NodePath
export var index_on_grid: int = 0

var is_moving := false

onready var tween := $Tween

func _ready():
	position = Vector2.ZERO
	grid = get_node(grid_path)
	yield(get_tree().create_timer(0.01), "timeout")
	move_to_index(index_on_grid, true)


func grid_path_is_valid() -> bool:
	if has_node(grid_path): return true
	push_error("Unit: invalid grid_path!")
	return false 


func move_to_index(index:int, play_tween: bool = false) -> void:
	if !grid_path_is_valid(): return
	if play_tween:
		is_moving = true
		tween.interpolate_property(self, "position",
		position, grid.pathfinding.astar.get_point_position(index), 1, Tween.TRANS_SINE, tween.EASE_OUT)
		tween.start()	
		yield(tween, "tween_all_completed")
		is_moving = false
	else:
		position = grid.pathfinding.astar.get_point_position(index)


