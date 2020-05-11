extends Node2D
onready var game_manager = get_node("/root/GameManager")

var selected_color_code = "[color=#00CC00]"
var unselected_color_code = "[color=#000000]"
var color_end_tag = "[/color]"

var new_game_text = "New Game"
var load_game_text = "Load Game"
var options_text = "Options"

onready var new_game_text_label = $"CanvasLayer/new-game-text"
onready var load_game_text_label = $"CanvasLayer/load-game-text"
onready var options_text_label = $"CanvasLayer/options-text"
var selected

func _ready():
	var save_file = File.new()
	if save_file.file_exists(game_manager.SAVE_0) || save_file.file_exists(game_manager.SAVE_1) || save_file.file_exists(game_manager.SAVE_2):
		selected = load_game_text_label
		load_game_text_label.bbcode_text = selected_color_code + load_game_text + color_end_tag
		new_game_text_label.bbcode_text = unselected_color_code + new_game_text + color_end_tag
		options_text_label.bbcode_text = unselected_color_code + options_text + color_end_tag
	else:
		selected = new_game_text_label
		new_game_text_label.set_bbcode(selected_color_code + new_game_text + color_end_tag)
		load_game_text_label.bbcode_text = unselected_color_code + load_game_text + color_end_tag
		options_text_label.bbcode_text = unselected_color_code + options_text + color_end_tag

func _process(delta):
	if Input.is_action_just_pressed("up"):
		if selected == options_text_label:
			selected = new_game_text_label
			new_game_text_label.bbcode_text = selected_color_code + new_game_text + color_end_tag
			load_game_text_label.bbcode_text = unselected_color_code + load_game_text + color_end_tag
			options_text_label.bbcode_text = unselected_color_code + options_text + color_end_tag
	elif Input.is_action_just_pressed("down"):
		if selected != options_text_label:
			selected = options_text_label
			options_text_label.bbcode_text = selected_color_code + options_text + color_end_tag
			new_game_text_label.bbcode_text = unselected_color_code + new_game_text + color_end_tag
			load_game_text_label.bbcode_text = unselected_color_code + load_game_text + color_end_tag
	elif Input.is_action_just_pressed("left"):
		if selected == load_game_text_label:
			selected = new_game_text_label
			new_game_text_label.bbcode_text = selected_color_code + new_game_text + color_end_tag
			load_game_text_label.bbcode_text = unselected_color_code + load_game_text + color_end_tag
			options_text_label.bbcode_text = unselected_color_code + options_text + color_end_tag
	elif Input.is_action_just_pressed("right"):
		if selected == new_game_text_label:
			selected = load_game_text_label
			load_game_text_label.bbcode_text = selected_color_code + load_game_text + color_end_tag
			new_game_text_label.bbcode_text = unselected_color_code + new_game_text + color_end_tag
			options_text_label.bbcode_text = unselected_color_code + options_text + color_end_tag
	elif Input.is_action_just_pressed("select"):
		if selected == new_game_text_label:
			game_manager.player_data.save = game_manager.SAVE_0
			game_manager.load_new_scene(game_manager.player_data.world)
			game_manager.save_player_data_to_file(game_manager.SAVE_0)
		elif selected == load_game_text_label:
			game_manager.load_player_data_from_file(game_manager.SAVE_0)
			game_manager.load_new_scene(game_manager.player_data.world)
		elif selected == options_text_label:
			pass