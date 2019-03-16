extends Area2D

enum Switch { LEFT_TO_RIGHT, RIGHT_TO_LEFT, INVERT }
export(Switch) var SWITCH_MODE = Switch.LEFT_TO_RIGHT

var check_mask : int
var uncheck_mask : int

func left_to_right():
	check_mask = 2
	uncheck_mask = 1

func right_to_left():
	check_mask = 1
	uncheck_mask = 2

func invert(is_left_activated, is_right_activated):
	if is_left_activated :
		check_mask = 2
		uncheck_mask = 1
	elif is_right_activated :
		check_mask = 1
		uncheck_mask = 2

func _on_Area2D_body_entered(body):
	if body.name == 'Player':
		var left = body.get_collision_mask_bit(1)
		var right = body.get_collision_mask_bit(2)
		
		match SWITCH_MODE:
			Switch.LEFT_TO_RIGHT:
				left_to_right()
			Switch.RIGHT_TO_LEFT:
				right_to_left()
			Switch.INVERT:
				invert(left, right)
		
		body.set_collision_mask_bit(check_mask, true)
		body.set_collision_mask_bit(uncheck_mask, false)
		body.left_ground.set_collision_mask_bit(check_mask, true)
		body.left_ground.set_collision_mask_bit(uncheck_mask, false)
		body.right_ground.set_collision_mask_bit(check_mask, true)
		body.right_ground.set_collision_mask_bit(uncheck_mask, false)
