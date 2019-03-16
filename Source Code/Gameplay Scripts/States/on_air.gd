extends '../state.gd'

var has_jumped : bool
var has_rolled : bool
var roll_jump : bool
var can_attack : bool

var override_anim : String

func enter(host):
	has_jumped = host.has_jumped
	has_rolled = host.is_rolling
	can_attack = has_jumped
	host.has_jumped = false
	host.is_rolling = false
	roll_jump = has_jumped and has_rolled

func step(host, delta):
	if host.is_grounded:
		host.ground_reacquisition()
		return 'OnGround'
	
	var can_move = true if !host.control_locked and !roll_jump else false
	var no_rotation = has_jumped or has_rolled
	host.rotation_degrees = int(lerp(host.rotation_degrees, 0, .2)) if !no_rotation else 0
	
	if Input.is_action_pressed("ui_left") and can_move:
		if host.velocity.x > -host.TOP:
			host.velocity.x -= host.AIR
	elif Input.is_action_pressed("ui_right") and can_move:
		if host.velocity.x < host.TOP:
			host.velocity.x += host.AIR
	
	if Input.is_action_just_pressed("ui_accept") and can_attack:
		host.player_vfx.play('InstaShield', true)
		host.audio_player.play('insta_shield')
		can_attack = false
		roll_jump = false
	
	if host.velocity.y < 0 and host.velocity.y > -240:
		host.velocity.x -= int(host.velocity.x / 7.5) / 15360.0
	
	host.velocity.y += host.GRV
	
	if Input.is_action_just_released("ui_accept"): # has jumped
			if host.velocity.y < -240.0: # set min jump height
				host.velocity.y = -240.0
	
	host.velocity.x = 0 if host.is_wall_left and host.velocity.x < 0 else host.velocity.x
	host.velocity.x = 0 if host.is_wall_right and host.velocity.x > 0 else host.velocity.x

func exit(host):
	pass

func animation_step(host, animator):
	var anim_name = animator.current_animation
	var anim_speed = animator.get_playing_speed()
	
	if anim_name == 'Braking':
		anim_name = 'Walking'
	
	if has_jumped or has_rolled:
		anim_name = 'Rolling'
		anim_speed = max(-((5.0 / 60.0) - (abs(host.gsp) / 120.0)), 1.0)
	
	if Input.is_action_pressed("ui_right"):
		host.character.scale.x = 1
	elif Input.is_action_pressed("ui_left"):
		host.character.scale.x = -1
	
	animator.animate(anim_name, anim_speed, true)
