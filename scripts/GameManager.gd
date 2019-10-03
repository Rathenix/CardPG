extends Node

# the game scenes that can be accessed by the game_manager
#var title_scene = preload("res://scenes/title_screen.tscn")
var overworld_scene = preload("res://scenes/World.tscn")
var battle_scene = preload("res://scenes/Battle.tscn")
#var scene_selector_scene = preload("res://scenes/scene_selector.tscn")
# var game_over_scene = preload("res://scenes/game_over.tscn")

# a dictionary to look up the scene objects by a name
var scenes = {
	"overworld": overworld_scene,
	"battle": battle_scene
}

#player stats
var player_data = { 
	"max_health": 0,
	"current_health": 0
 }

# the current scene that the Player(person) is on
var current_primary_scene

# an array of scenes currently displaying on top of other scenes and taking control
var scenes_on_top = []

# sets the current scene to the title screen and loads in into the tree
func _ready():
	randomize()
	current_primary_scene = overworld_scene.instance()
	add_child(current_primary_scene)
	
# removes the current scene from the tree and then loads a new current scene into the tree by name
func load_new_scene(scene_name):
	current_primary_scene.queue_free()
	current_primary_scene = scenes[scene_name].instance()	
	add_child(current_primary_scene)

# loads a scene into the tree on top of the current scene and gives the scene on top control
func load_scene_on_top(scene_name):
	if scenes_on_top.empty():
		current_primary_scene.set_pause_mode(Node.PAUSE_MODE_STOP)
	else:
		scenes_on_top[0].set_pause_mode(Node.PAUSE_MODE_STOP)
	scenes_on_top.push_front(scenes[scene_name].instance())
	add_child(scenes_on_top[0])
	get_tree().paused = true;
	
# closes the currently loaded scene on top and gives control back to the current scene (or top-most scene on top)
func close_scene_on_top():
	scenes_on_top[0].queue_free()
	scenes_on_top.remove(0)
	if scenes_on_top.empty():
		current_primary_scene.set_pause_mode(Node.PAUSE_MODE_INHERIT)
		get_tree().paused = false;
	else:
		scenes_on_top[0].set_pause_mode(Node.PAUSE_MODE_INHERIT)
		
# closes all scenes on top. useful for loading a new scene when several scenes on top are open
func close_all_scenes_on_top():
	var size = scenes_on_top.size() - 1
	while size >= 0:
		scenes_on_top[size].queue_free()
		scenes_on_top.remove(size)
		size -= 1
		
	get_tree().paused = false;
		
func _input(event):
	if event.is_action_pressed("menu"):
		pass

func set_player_location(node_name, offset):
	var pos = current_primary_scene.get_node(node_name).get_position() + offset
	current_primary_scene.player.set_position(pos)
	
func load_json_from_file(res_path_to_file):
	var file = File.new()
	file.open(res_path_to_file, file.READ)
	var text_json = file.get_as_text()
	var result_json = JSON.parse(text_json)
	file.close()
	if result_json.error == OK:
    	return result_json.result
	else:
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)
		return {}