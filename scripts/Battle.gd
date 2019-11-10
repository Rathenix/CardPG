extends Node

onready var game_manager = get_node("/root/GameManager")

signal showHand
signal hideHand
signal highlightCard
signal drawCard
signal playCard

onready var enemy = $Enemy
onready var hand = $Hand
onready var handTween = $HandTween
onready var cursor = $cursor
onready var fade = $CanvasLayer/Fade

var sceneIsBusy = false
var playerHasControl = false
var handShowing = false
var selectedCardIndex = 0
var startingHandSize = 5
var cardsInHand = 0
var currentDeck = []
var currentDiscard = []

var cursorLocationPlay = Vector2(25, 150) 
var cursorLocationScry = Vector2(25, 166)
var cursorLocationDraw = Vector2(120, 150)
var cursorLocationFlee = Vector2(120, 166)

var sceneLoaded = false

func _ready():
	spawn_enemy()
	fade.visible = true
	var fade_tween = fade.get_node("FadeTween")
	fade_tween.interpolate_property(fade, "self_modulate", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade_tween.start()
	set_process(false)

func setupHand():
	load_player_deck()
	cursor.position = cursorLocationPlay
	cursor.visible = true
	for i in range(startingHandSize):
		Draw()
	selectedCardIndex = 0
	emit_signal("hideHand")
	handShowing = false

func _process(delta):
	playerHasControl = !sceneIsBusy
	if playerHasControl:
		get_input()
	
func get_input():
	var handPos = hand.position
	var cursorPos = cursor.position
	if !handShowing:
		if Input.is_action_just_pressed('right'):
			if cursorPos == cursorLocationPlay:
				cursor.position = cursorLocationDraw
			elif cursorPos == cursorLocationScry:
				 cursor.position = cursorLocationFlee
		if Input.is_action_just_pressed('left'):
			if cursorPos == cursorLocationDraw:
				cursor.position = cursorLocationPlay
			elif cursorPos == cursorLocationFlee:
				 cursor.position = cursorLocationScry
		if Input.is_action_just_pressed('down'):
			if cursorPos == cursorLocationPlay:
				cursor.position = cursorLocationScry
			elif cursorPos == cursorLocationDraw:
				 cursor.position = cursorLocationFlee
		if Input.is_action_just_pressed('up'):
			if cursorPos == cursorLocationScry:
				cursor.position = cursorLocationPlay
			elif cursorPos == cursorLocationFlee:
				 cursor.position = cursorLocationDraw
		if Input.is_action_just_pressed('select'):
			if cursorPos == cursorLocationPlay:
				Play()
			elif cursorPos == cursorLocationScry:
				Scry()
			elif cursorPos == cursorLocationDraw:
				Draw()
			elif cursorPos == cursorLocationFlee:
				Flee()
	elif handShowing:
		if Input.is_action_just_pressed('right'):
			selectedCardIndex += 1
			emit_signal("highlightCard", selectedCardIndex)
		if Input.is_action_just_pressed('left'):
			selectedCardIndex -= 1
			emit_signal("highlightCard", selectedCardIndex)
		if Input.is_action_just_pressed('select'):
			emit_signal("playCard", selectedCardIndex)
		if Input.is_action_just_pressed('back'):
			handShowing = false
			emit_signal("hideHand")
			
func Play():
	handShowing = true
	emit_signal("showHand")
	emit_signal("highlightCard", selectedCardIndex)
	
func Scry():
	pass
	
func Draw():
	handShowing = true
	emit_signal("showHand")
	emit_signal("drawCard", currentDeck[0])
	currentDeck.pop_front()
	cardsInHand += 1
	selectedCardIndex = cardsInHand - 1

func Flee():
	var fade_tween = fade.get_node("FadeTween")
	fade_tween.interpolate_property(fade, "self_modulate", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade_tween.start()
	set_process(false)

func _on_FadeTween_tween_completed(object, key):
	if sceneLoaded:
		game_manager.load_new_scene("overworld")
	else:
		set_process(true)
		setupHand()
	sceneLoaded = true
	
func load_player_deck():
	var deckJson = game_manager.load_json_from_file("res://data/player_cards.json")
	currentDeck = deckJson.cards
	
func spawn_enemy():
	var enemyJson = game_manager.load_json_from_file("res://data/enemies.json")
	print(enemyJson)
	enemy.load_data(enemyJson.boss_bee)

func _on_Hand_dealDamage(damage):
	enemy.show_floating_text(str(damage), Color(255, 0, 0, 1), "float")

func _on_Hand_sceneIsBusy(isSceneBusy):
	sceneIsBusy = isSceneBusy
