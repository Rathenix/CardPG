extends Node

onready var game_manager = get_node("/root/GameManager")
onready var camera = $Camera2D
onready var player = $Player
onready var groundTileMap = $GroundTileMap
onready var fade = $CanvasLayer/Fade
onready var textboxBackground = $CanvasLayer/BasicTextBox
onready var textLabel = $CanvasLayer/BasicTextBox/RichTextLabel

const TILE_SIZE = 16 #px
const SCREEN_WIDTH = 12 #tiles
const SCREEN_HEIGHT = 12 #tiles

var sceneLoaded = false
var interactionText = [""]
var encounterRate = 0

signal finished_interaction

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
	if encounterRate != 0:
		var rand = floor(rand_range(0, encounterRate))
		if rand == 0:
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

func _on_Player_collided(collision):
	if collision.collider is TileMap:
		var tile_pos = collision.collider.world_to_map(player.position)
		tile_pos -= collision.normal  # Colliding tile
		var tile = collision.collider.get_cellv(tile_pos)

func _on_MainSignArea_body_entered(body):
	if body == player:
		player.interactable = true
		interactionText = ["[color=#000000]This is a sign.[/color]",
									"[color=#000000]They can have multiple lines of text.[/color]",
									"[color=#000000]You can even do \n[/color][color=#FF0000]R[/color][color=#FFDA00]A[/color][color=#48FF00]I[/color][color=#00FF91]N[/color][color=#0091FF]B[/color][color=#4800FF]O[/color][color=#FF00DA]W [/color][color=#000000]text.[/color]"]

func _on_MainSignArea_body_exited(body):
	if body == player:
		player.interactable = false
		interactionText = [""]

func _on_Player_interaction():
	textboxBackground.visible = true
	if interactionText.size() > 0:
		textLabel.bbcode_text = interactionText[0]

func _on_Player_advance_text():
	interactionText.pop_front()
	if interactionText.size() > 0:
		textLabel.bbcode_text = interactionText[0]
	else:
		textboxBackground.visible = false
		emit_signal("finished_interaction")

func _on_StartingZone_body_entered(body):
	if body == player:
		encounterRate = 0

func _on_StartingZone_body_exited(body):
	if body == player:
		encounterRate = 100
