extends Sprite

onready var floatingText = $CanvasLayer/Label
onready var floatingTextTween = $CanvasLayer/Label/Tween

var display_name = "enemy"
var maxHealth = 0
var currentHealth = 0
var attack = 0
var defense = 0

func _ready():
	floatingText.text = ""
	floatingText.visible = false

func load_data(enemyJson):
	var img = Image.new()
	img.load(enemyJson.image)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	set_texture(tex)
	display_name = enemyJson.name
	maxHealth = enemyJson.health
	currentHealth = maxHealth
	attack = enemyJson.attack
	defense = enemyJson.defense
	
func show_floating_text(text, color, animation):
	floatingText.text = text
	floatingText.add_color_override("font_color", color)
	if animation == "float":
		floatText()

func floatText():
	floatingText.rect_position = position
	floatingText.visible = true
	floatingTextTween.interpolate_property(floatingText, "rect_position", position, position + Vector2(0, -35), 0.75, Tween.TRANS_EXPO, Tween.EASE_OUT)
	floatingTextTween.start()

func _on_Tween_tween_completed(object, key):
	floatingText.visible = false
