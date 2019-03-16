extends '../state.gd'

export(float) var DASH_SPEED = 720
export(float) var CHARGE_TIME = 1

var charge_timer : float
var animation_speed : float

func enter(host: PlayerPhysics):
	charge_timer = CHARGE_TIME
	animation_speed = 1.0
	host.audio_player.play('peel_out_charge')

func step(host: PlayerPhysics, delta):
	charge_timer -= delta
	animation_speed += (720.0 / pow(CHARGE_TIME, 2.0)) * delta
	animation_speed = min(animation_speed, 720.0)
	
	if Input.is_action_just_released("ui_up"):
		return 'OnGround'

func exit(host: PlayerPhysics):
	if charge_timer <= 0:
		host.gsp = DASH_SPEED * host.character.scale.x
		host.audio_player.play('peel_out_release')
	else:
		host.audio_player.stop('peel_out_charge')

func animation_step(host: PlayerPhysics, animator: CharacterAnimator):
	var anim_speed = max(-(8.0 / 60.0 - (animation_speed / 120.0)), 1.0)
	var anim_name = 'Walking'
	
	if animation_speed >= 360:
		anim_name = 'Running'
	
	if animation_speed >= 720:
		anim_name = 'PeelOut'
	
	animator.animate(anim_name, anim_speed, false)
