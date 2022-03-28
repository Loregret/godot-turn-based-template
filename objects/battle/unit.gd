extends Node2D

export var grid_path: NodePath
export var index_on_grid: int = 0

var is_moving := false
var path: PoolVector2Array
var grid:Node2D

onready var tween := $Tween
onready var sprite := $Sprite


func _ready():
	self.connect("input_event", self, "_on_unit_input_event")
	position = Vector2.ZERO
	grid = get_node(grid_path)
	yield(get_tree().create_timer(0.01), "timeout")
	move_to_index(index_on_grid, false)


func is_within_bounds(pos:Vector2) -> bool:
	if pos >= position + (grid.unit.sprite.get_rect().size * grid.unit.sprite.scale) / 2:
		return true
	if pos <= position - (grid.unit.sprite.get_rect().size * grid.unit.sprite.scale) / 2:
		return true
	return false


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



func _on_unit_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action("LeftClick") and event.is_pressed():
		print("hello")
