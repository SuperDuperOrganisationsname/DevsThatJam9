extends Node2D

const Options_Color: Array[int] = [0, 1, 2]
const Options_Sizes: Array[Vector2i] = [Vector2i(2, 2), Vector2i(2, 1), Vector2i(1, 2)]
const Options_Scale: Array[int] = [1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4]

@onready var Sprites: Array[Texture2D] = [
	load("res://assets/art/Presents/2x2Present.png"),
	load("res://assets/art/Presents/2x1Present.png"),
	load("res://assets/art/Presents/1x2Present.png")
]

class Gift:
	var color: int
	var size: Vector2i
	var scale: int
	var texture: Texture2D

func _draw_gift() -> Gift:
	var gift = Gift.new()
	gift.color = Options_Color[randi() % Options_Color.size()]
	gift.scale = Options_Scale[randi() % Options_Scale.size()]
	
	var size_int = randi() % Options_Sizes.size()
	gift.size = Options_Sizes[size_int]
	gift.texture = Sprites[size_int]
	
	return gift

func _spawn_gift(gift: Gift, pos: Vector2):
	var obj = load("res://scenes/gift.tscn").instantiate()
	obj.texture = gift.texture
	obj.scale_size = gift.scale
	obj.gift_size = gift.size
	obj.color = gift.color
	
	obj.position = pos
	$Gifts.add_child(obj)
	obj._init_gift()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_gift(_draw_gift(), Vector2(-100, -100))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
