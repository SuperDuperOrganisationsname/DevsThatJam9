extends Node2D

@export var empty_state: Texture2D
@export var full_state: Texture2D

var grid_states: Array[bool] = []
var grid_size: Vector2i = Vector2i(8, 8)

var textures: Array[Sprite2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_reset_grid()
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var sprite = Sprite2D.new()
			sprite.texture = empty_state
			sprite.centered = false
			sprite.offset = Vector2(x, y) * (Globals.TILE_SIZE as Vector2)
			add_child(sprite)
			textures.append(sprite)

func _reset_grid():
	grid_states.clear()
	for i in range(grid_size.x * grid_size.y):
		grid_states.append(false)


func is_rect_placeable(rect: Rect2i) -> bool:
	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			if grid_states[x + y * grid_size.y]:
				return false
	
	return true

func place_rect(rect: Rect2i):
	if not is_rect_placeable(rect):
		return
	
	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			grid_states[x + y * grid_size.y] = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
