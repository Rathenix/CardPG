extends KinematicBody2D

const TILE_SIZE = 16 #px

export (int) var speed = 100

var velocity = Vector2()
var animation = ""
var interactable = false
var interacting = false
signal moved
signal collided
signal interaction
signal advance_text

func get_input():
	velocity = Vector2()
	animation = "idle"
	if interacting:
		if Input.is_action_just_pressed('select'):
			emit_signal("advance_text")
	else:
		if Input.is_action_just_pressed('select'):
			if interactable:
				interacting = true
				emit_signal("interaction")
		if Input.is_action_pressed('right'):
			velocity.x += 1
			$Sprite.flip_h = true
			animation = "move"
		if Input.is_action_pressed('left'):
			velocity.x -= 1
			$Sprite.flip_h = false
			animation = "move"
		if Input.is_action_pressed('down'):
			velocity.y += 1
			animation = "move"
		if Input.is_action_pressed('up'):
			velocity.y -= 1
			animation = "move"
		if animation == "move":
			emit_signal("moved")
		$Sprite.play("idle")
		velocity = velocity.normalized() * speed

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			emit_signal('collided', collision)

func _on_World_finished_interaction():
	interacting = false
