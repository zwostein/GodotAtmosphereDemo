extends Camera

export var moveForwardAction = "mov_forward"
export var moveBackwardAction = "mov_backward"
export var moveLeftAction = "mov_left"
export var moveRightAction = "mov_right"
export var moveUpAction = "mov_up"
export var moveDownAction = "mov_down"
export var moveFasterAction = "mov_faster"
export var mouseLookToggleAction = "look_mouseToggle"
export var mouseLookAction = "look_mouse"
export var rollLeftAction = "look_roll_left"
export var rollRightAction = "look_roll_right"
export var lookModeAction = "look_mode"
export var toggleUiAction = "ui_cancel"
export var mouseSensitivity = 1.0
export var movementSpeed = 10.0
export var movementSpeedFast = 1000.0
export var rollSpeed = 1.0
export(NodePath) var uiNodePath = NodePath()

var moveUp = false
var moveDown = false
var moveLeft = false
var moveRight = false
var moveForward = false
var moveBackward = false
var moveFaster = false
var rollLeft = false
var rollRight = false
var mousePositionBeforeCapture = Vector2(0.0, 0.0)
var mouseMovement = Vector2(0.0, 0.0)
var pitch = 0.0
var heading = PI
var roll = 0.0
var flightMode_rollCorrectionSpeed = 1.0
var flightMode_rollCorrection = 0.0
var flightMode = false


func _ready():
	set_process_unhandled_input(true)
	#set_as_toplevel(true) # translations are done in world space instead for camera


func _process(delta):
	
	if flightMode:
		rotate_object_local(Vector3(0,1,0),-mouseMovement.x * mouseSensitivity * (1.0/256.0))
		rotate_object_local(Vector3(1,0,0),-mouseMovement.y * mouseSensitivity * (1.0/256.0))
		if rollLeft:
			rotate_object_local(Vector3(0,0,1),rollSpeed * delta)
		if rollRight:
			rotate_object_local(Vector3(0,0,1),-rollSpeed * delta)
		heading = rotation.y
		pitch = rotation.x
		roll = rotation.z
	else:
		if flightMode_rollCorrection > 0.0:
			flightMode_rollCorrection -= flightMode_rollCorrectionSpeed * delta
			if flightMode_rollCorrection < 0.0:
				flightMode_rollCorrection = 0.0
			roll = lerp(0.0, roll, flightMode_rollCorrection)
		heading -= mouseMovement.x * mouseSensitivity * (1.0/256.0)
		heading = fmod(heading, TAU)
		pitch -= mouseMovement.y * mouseSensitivity * (1.0/256.0)
		pitch = clamp(pitch, -PI*0.5, PI*0.5)
		set_rotation(Vector3(pitch, heading, roll))

	var moveDirection = Vector3(0.0, 0.0, 0.0)
	if moveForward:
		moveDirection.z -= 1.0
	if moveBackward:
		moveDirection.z += 1.0
	if moveLeft:
		moveDirection.x -= 1.0
	if moveRight:
		moveDirection.x += 1.0
	if moveDown:
		moveDirection.y -= 1.0
	if moveUp:
		moveDirection.y += 1.0
	if moveDirection.length() > 0.0:
		moveDirection = moveDirection.normalized()
	if moveFaster:
		translate(moveDirection * movementSpeedFast * delta)
	else:
		translate(moveDirection * movementSpeed * delta)

	mouseMovement = Vector2(0.0, 0.0)


func _unhandled_input(event):
	# ignore echos
	if event.is_echo():
		return
	
	# if something unhandled is pressed, reset the focus
	if event.is_pressed() && !uiNodePath.is_empty():
		var focus = get_node(uiNodePath).get_focus_owner()
		if focus:
			focus.release_focus()

	# if event contains mouse position, save it in order to be able to restore it after mouse capture
	if event is InputEventMouse:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			mousePositionBeforeCapture = event.position

	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouseMovement += event.relative
	else:
		if event.is_pressed():
			if event.is_action(toggleUiAction) && has_node(uiNodePath):
				get_node(uiNodePath).visible = !get_node(uiNodePath).visible
				if(get_node(uiNodePath).visible):
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					Input.warp_mouse_position(mousePositionBeforeCapture)
			elif event.is_action(mouseLookAction):
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			elif event.is_action(mouseLookToggleAction):
				if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					Input.warp_mouse_position(mousePositionBeforeCapture)
			elif event.is_action(moveForwardAction):
				moveForward = true
			elif event.is_action(moveBackwardAction):
				moveBackward = true
			elif event.is_action(moveLeftAction):
				moveLeft = true
			elif event.is_action(moveRightAction):
				moveRight = true
			elif event.is_action(moveUpAction):
				moveUp = true
			elif event.is_action(moveDownAction):
				moveDown = true
			elif event.is_action(moveFasterAction):
				moveFaster = true
			elif event.is_action(rollLeftAction):
				rollLeft = true
			elif event.is_action(rollRightAction):
				rollRight = true
			elif event.is_action(lookModeAction):
				flightMode = !flightMode
				if !flightMode:
					flightMode_rollCorrection = 1.0
		else: # not pressed
			if event.is_action(mouseLookAction):
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				Input.warp_mouse_position(mousePositionBeforeCapture)
			elif event.is_action(moveForwardAction):
				moveForward = false
			elif event.is_action(moveBackwardAction):
				moveBackward = false
			elif event.is_action(moveLeftAction):
				moveLeft = false
			elif event.is_action(moveRightAction):
				moveRight = false
			elif event.is_action(moveUpAction):
				moveUp = false
			elif event.is_action(moveDownAction):
				moveDown = false
			elif event.is_action(moveFasterAction):
				moveFaster = false
			elif event.is_action(rollLeftAction):
				rollLeft = false
			elif event.is_action(rollRightAction):
				rollRight = false