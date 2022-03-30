extends Node2D

export var grid_path: NodePath
export var index_on_grid: int = 0

var is_moving := false
var path: PoolVector2Array
var grid:Node2D


onready var tween := $Tween
onready var sprite := $Sprite
onready var collision:CollisionShape2D = $CollisionShape2D
onready var rect_shape:RectangleShape2D = collision.shape


signal clicked(unit_ref)


func _ready():
	position = Vector2.ZERO
	grid = get_node(grid_path)
	yield(get_tree().create_timer(0.01), "timeout")
	move_to_index(index_on_grid, false)


func is_within_bounds(pos:Vector2) -> bool:
	if pos.x >= position.x - rect_shape.extents.x and\
	pos.y >= position.y - rect_shape.extents.y and\
	pos.x <= position.x + rect_shape.extents.x and\
	pos.y <= position.y + rect_shape.extents.y: 
		return true
	return false


func grid_nodepath_is_valid() -> bool:
	if has_node(grid_path): return true
	push_error("Unit: invalid grid_path!")
	return false 


func is_point_accesible(point:int) -> bool:
	var path2point = grid.pathfinding.astar.get_point_path(index_on_grid, point)
	if path2point.size() > 0: return true
	return false


func move_to_index(index:int, play_tween: bool = false) -> void:
	if !grid_nodepath_is_valid(): return
	if play_tween:
		is_moving = true
		path = grid.pathfinding.astar.get_point_path(index_on_grid, index)
		for i in path:
			grid.pathfinding.astar.set_point_disabled(index_on_grid, false)
			tween.interpolate_property(self, "position",
			position, i, clamp((0.45 - abs(path.size() * 0.1)), 0.25, 0.6), Tween.TRANS_SINE, tween.EASE_OUT)
			tween.start()	
			yield(tween, "tween_all_completed")
			index_on_grid = index
			grid.pathfinding.astar.set_point_disabled(index_on_grid, true)
			path.remove(0)
		is_moving = false
		path = []
	else:
		grid.pathfinding.astar.set_point_disabled(index_on_grid, true)
		position = grid.pathfinding.astar.get_point_position(index)


func _on_Unit_input_event(_viewport, event, _shape_idx):
	if event.is_action("LeftClick") and event.is_pressed():
		emit_signal("clicked", self)
