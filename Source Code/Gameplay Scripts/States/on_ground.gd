extends '../state.gd'

var slope : float
var is_braking : bool
var idle_anim = 'Idle1'
var brake_sign : int

func enter(host):
	idle_anim = 'Idle1'

func step(host, delta):
	host.is_looking_down = false
	host.is_looking_up = false
	host.is_pushing = false
	
	if !host.is_ray_colliding or host.fall_from_ground():
		host.is_grounded = false
		return 'OnAir'
	
	if Input.is_action_pressed("ui_down"):
		if abs(host.gsp) > 61.875:
			if !host.is_rolling:
				host.audio_player.play('spin')
			host.is_rolling = true
		elif host.ground_mode == 0:
			host.is_rolling = false
			if Input.is_action_just_pressed("ui_accept"):
				return 'SpinDash'
			host.is_looking_down = true
	elif Input.is_action_pressed('ui_up'):
		if abs(host.gsp) < .1 and host.ground_mode == 0:
			if Input.is_action_just_pressed("ui_accept"):
				return 'SuperPeelOut'
			host.is_looking_up = true
	
	if host.is_rolling and abs(host.gsp) < 30.0:
		host.is_rolling = false
	
	if !host.is_rolling:
		slope = host.SLP
	else:
		if sign(host.gsp) == sign(sin(host.ground_angle())):
			slope = host.SLPROLLUP
		else:
			slope = host.SLPROLLDOWN
	
	host.gsp -= slope * sin(host.ground_angle())
	
	if Input.is_action_pressed("ui_left") and !host.control_locked:
		if host.gsp > 0:
			host.gsp -= host.DEC if !host.is_rolling else host.ROLLDEC
			
			if host.gsp > 270 and !host.is_rolling and host.ground_mode == 0:
				if !is_braking:
					brake_sign = sign(host.gsp)
					host.audio_player.play('brake')
				is_braking = true
		elif host.gsp > -host.TOP and !host.is_rolling:
			host.gsp -= host.ACC
		
		if host.is_wall_left and host.gsp < 0:
			host.is_pushing = true
	elif Input.is_action_pressed("ui_right") and !host.control_locked:
		if host.gsp < 0 :
			host.gsp += host.DEC if !host.is_rolling else host.ROLLDEC
			
			if host.gsp < -270 and !host.is_rolling and host.ground_mode == 0:
				if !is_braking:
					brake_sign = sign(host.gsp)
					host.audio_player.play('brake')
				is_braking = true
		elif host.gsp < host.TOP and !host.is_rolling:
			host.gsp += host.ACC
		
		if host.is_wall_right and host.gsp > 0:
			host.is_pushing = true
	elif !host.is_rolling:
		host.gsp -= min(abs(host.gsp), host.FRC) * sign(host.gsp)
	
	if sign(host.gsp) != brake_sign or abs(host.gsp) <= 0.01:
		is_braking = false
	
	host.is_braking = is_braking
	
	if host.is_rolling:
		host.gsp -= min(abs(host.gsp), host.FRC / 2.0) * sign(host.gsp)
		host.gsp = clamp(host.gsp, -host.TOPROLL, host.TOPROLL)
	elif host.is_looking_down:
		host.gsp = .0
	
	host.gsp = .0 if host.is_wall_left and host.gsp < 0 else host.gsp
	host.gsp = .0 if host.is_wall_right and host.gsp > 0 else host.gsp
	host.velocity.x = host.gsp * cos(host.ground_angle())
	host.velocity.y = host.gsp * -sin(host.ground_angle())
	
	if Input.is_action_just_pressed("ui_accept"):
			host.velocity.x -= host.JMP * sin(host.ground_angle())
			host.velocity.y -= host.JMP * cos(host.ground_angle())
			host.rotation_degrees = 0
			host.is_grounded = false
			host.has_jumped = true
			host.audio_player.play('jump')
			return 'OnAir'
	
	if !host.can_fall:
		host.snap_to_ground()

func exit(host):
	is_braking = false
	host.is_braking = false

func animation_step(host, animator):
	var anim_name = idle_anim
	var anim_speed = 1.0
	var abs_gsp = abs(host.gsp)
	var play_once = false
	
	if abs_gsp > .1 and !is_braking:
		idle_anim = 'Idle1'
		anim_name = 'Walking'
		
		if abs_gsp >= 360:
			anim_name = 'Running'
		
		if abs_gsp >= 960:
			anim_name = 'PeelOut'
		
		if host.is_rolling:
			anim_name = 'Rolling'
			anim_speed = -((5.0 / 60.0) - (abs(host.gsp) / 120.0))
		else:
			anim_speed = max(-(8.0 / 60.0 - (abs_gsp / 120.0)), 1.0)
		
		if Input.is_action_pressed("ui_right"):
			host.character.scale.x = 1
		elif Input.is_action_pressed("ui_left"):
			host.character.scale.x = -1
	elif is_braking:
		anim_name = 'Braking'
		anim_speed = 1.0
	else:
		if host.is_looking_down:
			idle_anim = 'Idle1'
			anim_name = 'LookDown'
			play_once = true
		elif host.is_looking_up:
			idle_anim = 'Idle1'
			anim_name = 'LookUp'
			play_once = true
		elif host.is_pushing:
			idle_anim = 'Idle1'
			anim_name = 'Pushing'
	
	animator.animate(anim_name, anim_speed, play_once)

func _on_animation_finished(anim_name):
	if anim_name == 'Braking':
		is_braking = false
	elif anim_name == 'Idle1':
		idle_anim = 'Idle2'
	elif anim_name == 'Idle2':
		idle_anim = 'Idle3'
