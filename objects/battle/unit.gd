extends Node2D
var grid:Node2D

export var grid_path: NodePath
export var index_on_grid: int = 0

var is_moving := false
var path: PoolVector2Array

onready var tween := $Tween


func _ready():
	position = Vector2.ZERO
	grid = get_node(grid_path)
	yield(get_tree().create_timer(0.01), "timeout")
	move_to_index(index_on_grid, false)


func grid_path_is_valid() -> bool:
	if has_node(grid_path): return true
	push_error("Unit: invalid grid_path!")
	return false 


func move_to_index(index:int, play_tween: bool = false) -> void:
	if !grid_path_is_valid(): return
	if play_tween:
		is_moving = true
		path = grid.pathfinding.astar.get_point_path(index_on_grid, index)
		for i in path:
			tween.interpolate_property(self, "position",
			position, i, path.size() * 0.1, Tween.TRANS_SINE, tween.EASE_OUT)
			tween.start()	
			yield(tween, "tween_all_completed")
			index_on_grid = index
			path.remove(0)
			grid.draw.update()
		is_moving = false
		path = []
	else:
		position = grid.pathfinding.astar.get_point_position(index)

