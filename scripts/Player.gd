extends KinematicBody2D

const TILE_SIZE = 16 #px

export (int) var speed = 100

var velocity = Vector2()
var animation = ""
signal moved

func get_input():
	velocity = Vector2()
	animation = "idle"
	if Input.is_action_pressed('right'):
		velocity.x += 1
		$Sprite.flip_h = false
		animation = "move"
	if Input.is_action_pressed('left'):
		velocity.x -= 1
		$Sprite.flip_h = true
		animation = "move"
	if Input.is_action_pressed('down'):
		velocity.y += 1
		animation = "move"
	if Input.is_action_pressed('up'):
		velocity.y -= 1
		animation = "move"
	if animation == "move":
		emit_signal("moved")
	$Sprite.play(animation)
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
