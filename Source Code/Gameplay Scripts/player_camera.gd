extends Node2D

class_name PlayerCamera

export(float) var LEFT = -16
export(float) var RIGHT = .0
export(float) var GROUND_TOP = .0
export(float) var GROUND_BOTTOM = .0
export(float) var AIR_TOP = 48
export(float) var AIR_BOTTOM = -16

export(float) var SCROLL_UP = -104
export(float) var SCROLL_DOWN = 88
export(float) var SCROLL_SPEED = 120
export(float) var SCROLL_DELAY = 2

var scroll_timer : float

onready var camera_scroll = $CameraScroll

func can_scroll(delta : float):
	if scroll_timer > 0:
		scroll_timer -= delta
		return false
	
	return true

func camera_step(player : PlayerPhysics, delta : float):
	horizontal_border(player)
	vertical_border(player)
	vertical_scrolling(player, delta)

func horizontal_border(player : PlayerPhysics):
	if player.position.x > position.x + RIGHT:
		position.x += min(player.position.x - (position.x + RIGHT), 16)
	elif player.position.x < position.x + LEFT:
		position.x += max(player.position.x - (position.x + LEFT), -16)

func vertical_border(player : PlayerPhysics):
	if player.is_grounded:
		if player.position.y + 16 - position.y != 0:
			if abs(player.velocity.y) <= 360:
				position.y += max(player.position.y + 16 - position.y, -6)
			else:
				position.y += max(player.position.y + 16 - position.y, -16)
		return
	
	if player.position.y < position.y - AIR_TOP:
		position.y += max(player.position.y - (position.y - AIR_TOP), -16)
	elif player.position.y > position.y + AIR_BOTTOM:
		position.y += min(player.position.y - (position.y + AIR_BOTTOM), 16)

func vertical_scrolling(player : PlayerPhysics, delta : float):
	var scroll_back = true
	var scroll_world = camera_scroll.global_position
	
	if player.is_looking_up:
		if can_scroll(delta):
			camera_scroll.position.y -= SCROLL_SPEED * delta
			camera_scroll.position.y = max(camera_scroll.position.y, SCROLL_UP)
			scroll_back = false
	elif player.is_looking_down:
		if can_scroll(delta):
			camera_scroll.position.y += SCROLL_SPEED * delta
			camera_scroll.position.y = min(camera_scroll.position.y, SCROLL_DOWN)
			scroll_back = false
	else:
		scroll_timer = SCROLL_DELAY
	
	if scroll_back:
		if camera_scroll.position.y > 0:
			camera_scroll.position.y -= SCROLL_SPEED * delta
			camera_scroll.position.y = max(camera_scroll.position.y, 0)
		elif camera_scroll.position.y < 0:
			camera_scroll.position.y += SCROLL_SPEED * delta
			camera_scroll.position.y = min(camera_scroll.position.y, 0)
