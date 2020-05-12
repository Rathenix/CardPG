extends Node2D
onready var game_manager = get_node("/root/GameManager")

var selected_color_code = "[color=#00CC00]"
var unselected_color_code = "[color=#000000]"
var attack_color_code = "[color=#FF0000]"
var defense_color_code = "[color=#FFA500]"
var color_end_tag = "[/color]"
var save = false

onready var hint_text = $"CanvasLayer/hint-text"
onready var player_name = $"CanvasLayer/player-name"
onready var player_level = $"CanvasLayer/player-level"
onready var player_attack = $"CanvasLayer/player-attack"
onready var player_defense = $"CanvasLayer/player-defense"
onready var player_exp = $"CanvasLayer/player-exp"
onready var option_yes = $"CanvasLayer/option-yes"
onready var option_no = $"CanvasLayer/option-no"

var player

func _ready():
	player = game_manager.player_data
	player_name.bbcode_text = unselected_color_code + str(player.player_name) + color_end_tag
	var level = player.experience % 500
	player_level.bbcode_text = unselected_color_code + "Level " + str(level) + " Wizard" + color_end_tag
	player_attack.bbcode_text = attack_color_code + "ATK:" + str(player.attack) + color_end_tag
	player_defense.bbcode_text = defense_color_code + "DEF:" + str(player.defense) + color_end_tag
	player_exp.bbcode_text = unselected_color_code + "EXP:" + str(player.experience) + "/" + str(level * 500) + color_end_tag 
	option_yes.bbcode_text = unselected_color_code + "YES" + color_end_tag
	option_no.bbcode_text = selected_color_code + "NO" + color_end_tag

func _process(delta):
	if Input.is_action_just_pressed("left"):
		if !save:
			option_yes.bbcode_text = selected_color_code + "YES" + color_end_tag
			option_no.bbcode_text = unselected_color_code + "NO" + color_end_tag
			save = true
	elif Input.is_action_just_pressed("right"):
		if save:
			option_yes.bbcode_text = unselected_color_code + "YES" + color_end_tag
			option_no.bbcode_text = selected_color_code + "NO" + color_end_tag
			save = false
	elif Input.is_action_just_pressed("select"):
		if save:
			game_manager.save_player_data_to_file(player.save)
			game_manager.close_scene_on_top()
		else:
			game_manager.close_scene_on_top()
	elif Input.is_action_just_pressed("menu"):
		game_manager.close_scene_on_top()
