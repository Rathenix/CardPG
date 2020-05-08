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
onready var deck_area = $Deck
onready var discard_area = $Discard
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
var player_initiative = true

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
	spawn_enemy()
	load_player_deck()
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
		if selectedCardIndex > 0:
			selectedCardIndex -= 1
		else:
			selectedCardIndex = hand.get_child_count() - 1
		highlightCard(selectedCardIndex)
	if Input.is_action_just_pressed('select'):
		playCard(hand.get_child(selectedCardIndex))
	if Input.is_action_just_pressed('back'):
		pass

func Draw():
	if cardsToDraw > 0:
		if deck_area.get_child_count() > 0:
			cardsToDraw -= 1
			var drawn_card = deck_area.get_child(deck_area.get_child_count() - 1)
			deck_area.remove_child(drawn_card)
			hand.add_child(drawn_card)
			selectedCardIndex = hand.get_child_count() - 1
			hand.get_child(selectedCardIndex).z_index = selectedCardIndex
			adjust_hand_spacing()
			highlightCard(selectedCardIndex)
		else:
			var new_deck = shuffle(discard_area.get_children())
			for c in new_deck:
				discard_area.remove_child(c)
				deck_area.add_child(c)
				c.offset = 0
			print("reshuffling")
			if deck_area.get_child_count() == 0:
				print("nothing to draw")
				cardsToDraw = 0

func adjust_hand_spacing():
	for i in range(0, hand.get_child_count()):
		var offset = (1.0 / (hand.get_child_count() + 1)) * (i + 1)
		staticTween.interpolate_property(hand.get_child(i), "unit_offset", hand.get_child(i).unit_offset, offset, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
		nodesStaticAnimating += 1
		staticTween.start()
		
func highlightCard(index):
	selectedCardIndex = index % hand.get_child_count()
	var idx = 0
	for c in hand.get_children():
		activeTween.interpolate_property(c, "v_offset", c.v_offset, 0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		c.z_index = idx
		idx += 1
	hand.get_child(selectedCardIndex).z_index = 100
	activeTween.interpolate_property(hand.get_child(selectedCardIndex), "v_offset", 0, -15, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	activeTween.start()

func playCard(card):
	var enemy_attack = enemy.attack
	var enemy_defense = enemy.defense
	var player_attack = game_manager.player_data.attack
	var player_defense = game_manager.player_data.defense
	if card.type == "flee":
		Flee()
	elif card.type == "draw":
		cardsToDraw += 3
	elif card.type == "attack":
		print("attack +" + str(card.value))
		player_attack += card.value
		hand.remove_child(card)
		discard_area.add_child(card)
		adjust_hand_spacing()
		highlightCard(selectedCardIndex)
	elif card.type == "defense":
		print("defense +" + str(card.value))
		player_defense += card.value
		adjust_hand_spacing()
		hand.remove_child(card)
		discard_area.add_child(card)
		adjust_hand_spacing()
		highlightCard(selectedCardIndex)
	else:
		print("unknown card type: " + str(card.type))
	fight(player_attack, player_defense, enemy_attack, enemy_defense)
	
func fight(player_attack, player_defense, enemy_attack, enemy_defense):
	var player_dice = Vector2(randi() % 6 + 1, randi() % 6 + 1)
	var player_roll = int(player_dice.x) + int(player_dice.y)
	print("player dice: " + str(player_dice))
	print("player roll: " + str(player_roll))
	
	var enemy_dice = Vector2(randi() % 6 + 1, randi() % 6 + 1)
	var enemy_roll = int(enemy_dice.x) + int(enemy_dice.y)
	print("enemy dice: " + str(enemy_dice))
	print("enemy roll: " + str(enemy_roll))
	
	var damage = 0
	if player_initiative:
		player_attack += player_roll
		print("player attack: " + str(player_attack))
		enemy_defense += enemy_roll
		print("enemy defense: " + str(enemy_defense))
		damage = max(0, player_attack - enemy_defense)
		game_manager.player_data.current_health -= damage
		enemy.show_floating_text(str(damage), Color(255, 0, 0, 1), "float")
	else:
		enemy_attack += enemy_roll
		print("enemy attack: " + str(enemy_attack))
		player_defense += player_roll
		print("player defense: " + str(player_defense))
		damage = max(0, enemy_attack - player_defense)
		enemy.currentHealth -= damage
	print("damage: " + str(damage))
	player_initiative = !player_initiative

func Flee():
	var fade_tween = fade.get_node("FadeTween")
	fade_tween.interpolate_property(fade, "self_modulate", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade_tween.start()
	set_process(false)

func _on_FadeTween_tween_completed(object, key):
	if sceneLoaded:
		game_manager.load_new_scene(game_manager.player_data.world)
	sceneLoaded = true

func _on_StaticTween_tween_completed(object, key):
	nodesStaticAnimating -= 1

func load_player_deck():
	var cards = []
	for item in game_manager.player_data.equipment:
		for card in item.cards:
			cards.append(card)
	var starting_deck = shuffle(cards)
	for c in starting_deck:
		var newCard = card.instance()
		newCard.load_data(c)
		deck_area.add_child(newCard)
	cardsToDraw = startingHandSize
	
func spawn_enemy():
	var enemyJson = game_manager.load_json_from_file("res://data/enemies.json")
	print(enemyJson)
	enemy.load_data(enemyJson.boss_bee)
	
func shuffle(deck):
    var shuffled = [] 
    var index = range(deck.size())
    for i in range(deck.size()):
        var x = randi()%index.size()
        shuffled.append(deck[index[x]])
        index.remove(x)
    return shuffled
