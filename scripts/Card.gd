extends PathFollow2D

var type = ""
var value = 0

func _ready():
	pass
	
func load_data(cardJson):
	var img = Image.new()
	img.load(cardJson.image)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	$Sprite.set_texture(tex)
	type = cardJson.type
	value = cardJson.value