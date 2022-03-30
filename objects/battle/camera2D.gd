extends Camera2D


# Camera control settings:
# key - by keyboard
# drag - by clicking mouse button, right mouse button by default;
# edge - by moving mouse to the window edge
# wheel - zoom in/out by mouse wheel
export (bool) var key = true
export (bool) var drag = true
export (bool) var edge = false
export (bool) var wheel = true


export (int) var camera_speed = 450 

export (int) var camera_margin = 50

export (int) var zoom_out_limit = 100

export (float) var zoom_in_limit = 0.5

export (Vector2) var camera_zoom_speed = Vector2(0.5, 0.5)

var camera_movement = Vector2()
var camera_zoom = get_zoom()
var _prev_mouse_pos = null

# INPUTS

# Right mouse button was or is pressed.
var __rmbk = false
# Move camera by keys: left, top, right, bottom.
var __keys = [false, false, false, false]

func _ready():
	set_h_drag_enabled(false)
	set_v_drag_enabled(false)
	set_enable_follow_smoothing(true)
	set_follow_smoothing(4)

func _physics_process(delta):
	
	# Move camera by keys defined in InputMap (ui_left/top/right/bottom).
	if key:
		if __keys[0]:
			camera_movement.x -= camera_speed * delta
		if __keys[1]:
			camera_movement.y -= camera_speed * delta
		if __keys[2]:
			camera_movement.x += camera_speed * delta
		if __keys[3]:
			camera_movement.y += camera_speed * delta
	
	# Move camera by mouse, when it's on the margin (defined by camera_margin).
	if edge:
		var rec = get_viewport().get_visible_rect()
		var v = get_local_mouse_position() + rec.size/2
		if rec.size.x - v.x <= camera_margin:
			camera_movement.x += camera_speed * delta
		if v.x <= camera_margin:
			camera_movement.x -= camera_speed * delta
		if rec.size.y - v.y <= camera_margin:
			camera_movement.y += camera_speed * delta
		if v.y <= camera_margin:
			camera_movement.y -= camera_speed * delta
	
	# When RMB is pressed, move camera by difference of mouse position
	if drag and __rmbk:
		camera_movement = _prev_mouse_pos - get_local_mouse_position()
	
	# Update position of the camera.
	position += camera_movement * get_zoom()
	
	# Set camera movement to zero, update old mouse position.
	camera_movement = Vector2(0,0)
	_prev_mouse_pos = get_local_mouse_position()

func _unhandled_input( event ):
	if event is InputEventMouseButton:
		if drag and\
		   event.button_index == BUTTON_MIDDLE:
			# Control by right mouse button.
			if event.pressed: __rmbk = true
			else: __rmbk = false
		if wheel:
			if event.button_index == BUTTON_WHEEL_UP:
				if camera_zoom.x - camera_zoom_speed.x > zoom_in_limit and\
				camera_zoom.y - camera_zoom_speed.y > zoom_in_limit:
					camera_zoom -= camera_zoom_speed
					set_zoom(camera_zoom)
				else:
					set_zoom(Vector2(zoom_in_limit, zoom_in_limit))
					print(1)
			if event.button_index == BUTTON_WHEEL_DOWN:
				if camera_zoom.x + camera_zoom_speed.x < zoom_out_limit and\
				camera_zoom.y + camera_zoom_speed.y < zoom_out_limit:
					camera_zoom += camera_zoom_speed
					set_zoom(camera_zoom)
				else:
					set_zoom(Vector2(zoom_out_limit, zoom_out_limit))	
		if key:
			# Control by keyboard handled by InpuMap.
			if event.is_action_pressed("ui_left"):
				__keys[0] = true
			if event.is_action_pressed("ui_up"):
				__keys[1] = true
			if event.is_action_pressed("ui_right"):
				__keys[2] = true
			if event.is_action_pressed("ui_down"):
				__keys[3] = true
			if event.is_action_released("ui_left"):
				__keys[0] = false
			if event.is_action_released("ui_up"):
				__keys[1] = false
			if event.is_action_released("ui_right"):
				__keys[2] = false
			if event.is_action_released("ui_down"):
				__keys[3] = false