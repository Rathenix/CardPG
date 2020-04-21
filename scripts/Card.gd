extends PathFollow2D

var type = ""
var value = 0

func _ready():
	pass
	
func load_data(cardJson):
	setTexture(cardJson.image)
	type = cardJson.type
	value = cardJson.value

func setTexture(tex):
	$Sprite.texture = load(tex)