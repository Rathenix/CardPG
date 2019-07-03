extends Node2D

var card = preload("res://scenes/Card.tscn")

onready var path = $Path2D
onready var pathTween = $Tween

var cards = []
var focusPosition = Vector2(96, 176)
var unfocusPosition = Vector2(96, 216)
var handSize = 7

func _ready():
	pass

func fanCards():
	for i in range(0, handSize):
		var c = card.instance()
		path.add_child(c)
		cards.append(c)
		var offset = (1.0 / (handSize + 1)) * (i + 1)
		var cardTween = c.get_node("Tween")
		cardTween.interpolate_property(c, "unit_offset", 0.5, offset, 0.75, Tween.TRANS_SINE, Tween.EASE_IN)
		cardTween.start()
		
func drawCard():
	var newCard = card.instance()
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
	print(cards[index].value)

func _on_Battle_hideHand():
	unfocus()

func _on_Battle_showHand():
	focus()

func _on_Battle_highlightCard(index):
	highlightCard(index)

func _on_Battle_drawCard():
	drawCard()

func _on_Battle_playCard(index):
	playCard(index)
