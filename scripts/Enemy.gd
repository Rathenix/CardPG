extends Sprite

var maxHealth = 0
var currentHealth = 0
var attack = 0
var defense = 0

func _ready():
	pass

func load_data(enemyJson):
	var img = Image.new()
	img.load(enemyJson.image)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	set_texture(tex)
	maxHealth = enemyJson.health
	currentHealth = maxHealth
	attack = enemyJson.attack
	defense = enemyJson.defense