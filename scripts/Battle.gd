extends Node

onready var game_manager = get_node("/root/GameManager")

signal showHand
signal hideHand
signal highlightCard
signal drawCard
signal playCard

onready var background = $BackgroundSprite
onready var enemy = $Enemy
onready var hand = $Hand
onready var activeTween = $ActiveTween # animate while game plays
onready var staticTween = $StaticTween # pause gameplay while animating
onready var fade = $CanvasLayer/Fade
onready var menubar = $CanvasLayer/MenuBar

var card = preload("res://scenes/Card.tscn")
var terribleForestTexture = preload("res://images/terrible-forest.png")
var drawCardTexturePath ="res://images/cards/draw.png"
var fleeCardTexturePath = "res://images/cards/flee.png"

var nodesStaticAnimating = 0
var selectedCardIndex = 0
var startingHandSize = 5
var cardsToDraw = 0
var currentHand = []
var currentDeck = []
var currentDiscard = []

var sceneLoaded = false

func _ready():
	background.texture = terribleForestTexture
	var fleeCard = card.instance()
	fleeCard.type = "flee"
	fleeCard.setTexture(fleeCardTexturePath)
	var drawCard = card.instance()
	drawCard.type = "draw"
	drawCard.setTexture(drawCardTexturePath)
	hand.add_child(fleeCard)
	hand.add_child(drawCard)
	currentHand.append(fleeCard)
	currentHand.append(drawCard)
	spawn_enemy()
	load_player_deck()
	cardsToDraw = startingHandSize
	fade.visible = true
	var fade_tween = fade.get_node("FadeTween")
	fade_tween.interpolate_property(fade, "self_modulate", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade_tween.start()

func _process(delta):
	if nodesStaticAnimating == 0:
		get_input()
		if cardsToDraw > 0:
			Draw()
	
func get_input():
	if Input.is_action_just_pressed('right'):
		selectedCardIndex += 1
		highlightCard(selectedCardIndex)
	if Input.is_action_just_pressed('left'):
		selectedCardIndex -= 1
		highlightCard(selectedCardIndex)
	if Input.is_action_just_pressed('select'):
		playCard(currentHand[selectedCardIndex])
	if Input.is_action_just_pressed('back'):
		pass

func Draw():
	if cardsToDraw > 0:
		cardsToDraw -= 1
		var newCard = card.instance()
		newCard.load_data(currentDeck[0])
		currentDeck.pop_front()
		hand.add_child(newCard)
		currentHand.append(newCard)
		selectedCardIndex = currentHand.size() - 1
		for i in range(0, currentHand.size()):
			var offset = (1.0 / (currentHand.size() + 1)) * (i + 1)
			staticTween.interpolate_property(currentHand[i], "unit_offset", currentHand[i].unit_offset, offset, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
			nodesStaticAnimating += 1
			staticTween.start()
		highlightCard(selectedCardIndex)
		
func highlightCard(index):
	var calcIndex = index % currentHand.size()
	for c in currentHand:
		activeTween.interpolate_property(c, "v_offset", c.v_offset, 0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		c.z_index = 0
	currentHand[calcIndex].z_index = 1
	activeTween.interpolate_property(currentHand[calcIndex], "v_offset", 0, -15, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	activeTween.start()

func playCard(card):
	if card.type == "flee":
		Flee()
	elif card.type == "draw":
		cardsToDraw += 3
	elif card.type == "attack":
		print("attack +" + str(card.value))
	elif card.type == "defend":
		print("defend +" + str(card.value))
	else:
		print("unknown card type: " + str(card.type))

func Flee():
	var fade_tween = fade.get_node("FadeTween")
	fade_tween.interpolate_property(fade, "self_modulate", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade_tween.start()
	set_process(false)

func _on_FadeTween_tween_completed(object, key):
	if sceneLoaded:
		game_manager.load_new_scene("overworld")
	sceneLoaded = true

func _on_StaticTween_tween_completed(object, key):
	nodesStaticAnimating -= 1

func load_player_deck():
	var deckJson = game_manager.load_json_from_file("res://data/player_cards.json")
	currentDeck = deckJson.cards
	
func spawn_enemy():
	var enemyJson = game_manager.load_json_from_file("res://data/enemies.json")
	print(enemyJson)
	enemy.load_data(enemyJson.boss_bee)
