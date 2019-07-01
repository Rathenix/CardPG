extends Node

onready var game_manager = get_node("/root/GameManager")

signal showHand
signal hideHand
signal highlightCard
signal drawCard

onready var hand = $Hand
onready var handTween = $HandTween
onready var cursor = $cursor

var handShowing = false
var selectedCardIndex = 0
var startingHandSize = 5
var cardsInHand = 0

var cursorLocationPlay = Vector2(25, 150) 
var cursorLocationScry = Vector2(25, 166)
var cursorLocationDraw = Vector2(120, 150)
var cursorLocationFlee = Vector2(120, 166)

func _ready():
	cursor.position = cursorLocationPlay
	for i in range(startingHandSize):
		Draw()
	selectedCardIndex = 0
	emit_signal("hideHand")
	handShowing = false

func _process(delta):
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
			pass
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
	emit_signal("drawCard")
	cardsInHand += 1
	selectedCardIndex = cardsInHand - 1

func Flee():
	game_manager.load_new_scene("overworld")