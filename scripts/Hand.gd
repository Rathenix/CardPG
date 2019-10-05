extends Node2D

var card = preload("res://scenes/Card.tscn")

onready var path = $Path2D
onready var pathTween = $Tween

var cards = []
var focusPosition = Vector2(96, 176)
var unfocusPosition = Vector2(96, 221)
var playedPosition = Vector2(0, -100)

signal dealDamage

func _ready():
	pass
		
func drawCard(cardJson):
	var newCard = card.instance()
	newCard.load_data(cardJson)
	path.add_child(newCard)
	cards.append(newCard)
	for i in range(0, cards.size()):
		var offset = (1.0 / (cards.size() + 1)) * (i + 1)
		var cardTween = newCard.get_node("Tween")
		cardTween.interpolate_property(cards[i], "unit_offset", cards[i].unit_offset, offset, 0.75, Tween.TRANS_SINE, Tween.EASE_IN)
		cardTween.start()
	highlightCard(cards.size() - 1)

func focus():
	pathTween.interpolate_property(self, "position", unfocusPosition, focusPosition, 0.25, Tween.TRANS_SINE, Tween.EASE_IN)
	pathTween.start()
	
func unfocus():
	for c in cards:
		pathTween.interpolate_property(c, "v_offset", c.v_offset, 0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	pathTween.interpolate_property(self, "position", focusPosition, unfocusPosition, 0.25, Tween.TRANS_SINE, Tween.EASE_IN)
	pathTween.start()
	
func highlightCard(index):
	var calcIndex = index % cards.size()
	for c in cards:
		pathTween.interpolate_property(c, "v_offset", c.v_offset, 0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	pathTween.interpolate_property(cards[calcIndex], "v_offset", 0, -15, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	pathTween.start()
	
func playCard(index):
	var calcIndex = index % cards.size()
	var selectedCard = cards[calcIndex]
	pathTween.interpolate_property(selectedCard, "position", selectedCard.position, playedPosition, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	pathTween.interpolate_property(selectedCard, "rotation_degrees", selectedCard.rotation_degrees, 0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	pathTween.start()
	if selectedCard.type == "attack":
		emit_signal("dealDamage", selectedCard.value)

func _on_Battle_hideHand():
	unfocus()

func _on_Battle_showHand():
	focus()

func _on_Battle_highlightCard(index):
	highlightCard(index)

func _on_Battle_drawCard(card):
	drawCard(card)

func _on_Battle_playCard(index):
	playCard(index)
