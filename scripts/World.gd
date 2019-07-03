extends Node

onready var game_manager = get_node("/root/GameManager")
onready var camera = $Camera2D
onready var player = $Player
onready var fade = $CanvasLayer/Fade

const TILE_SIZE = 16 #px
const SCREEN_WIDTH = 12 #tiles
const SCREEN_HEIGHT = 12 #tiles

var sceneLoaded = false

func _ready():
	fade.visible = true
	player.set_physics_process(false)
	var fade_tween = fade.get_node("FadeTween")
	fade_tween.interpolate_property(fade, "self_modulate", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade_tween.start()

func _process(delta):
	update_camera()
	
func update_camera():
	var player_pos = player.get_position()
	var camera_grid_pos = Vector2()
	var camera_position = Vector2()
	camera_grid_pos.x = floor(player_pos.x / TILE_SIZE / SCREEN_WIDTH)
	camera_grid_pos.y = floor(player_pos.y / TILE_SIZE / SCREEN_HEIGHT)
	camera_position.x = camera_grid_pos.x * TILE_SIZE * SCREEN_WIDTH
	camera_position.y = camera_grid_pos.y * TILE_SIZE * SCREEN_HEIGHT
	
	var camera_tween = camera.get_node("CameraTween")
	camera_tween.interpolate_property(camera, "position", camera.position, camera_position, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	camera_tween.start()

func _on_Player_moved():
	var rand = floor(rand_range(0, 100))
	if rand == 5:
		player.animation = "idle"
		player.set_physics_process(false)
		var fade_tween = fade.get_node("FadeTween")
		fade_tween.interpolate_property(fade, "self_modulate", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		fade_tween.start()

func _on_FadeTween_tween_completed(object, key):
	if sceneLoaded:
		game_manager.load_new_scene("battle")
	else:
		player.set_physics_process(true)
	sceneLoaded = true
