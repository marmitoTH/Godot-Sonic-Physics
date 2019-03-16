extends AnimationPlayer

class_name CharacterAnimator

var previous_animation : String

func animate(animation_name : String, custom_speed : float, can_loop : bool):
	if can_loop and animation_name == previous_animation:
		return
	
	play(animation_name, -1, custom_speed)
	previous_animation = animation_name
