extends Node2D

@export var empty_state: Texture2D
@export var full_state: Texture2D

var grid_states: Array[bool] = []
var grid_size: Vector2i = Vector2i(8, 8)

var textures: Array[Sprite2D] = []

var gift_inside: bool = false
var gift_position: Vector2i = Vector2i(0, 0)
var gift_global_position: Vector2 = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var shape = RectangleShape2D.new()
	shape.size = (grid_size * Globals.TILE_SIZE) as Vector2
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position += (grid_size * Globals.TILE_SIZE) as Vector2 / 2
	_reset_grid()
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var sprite = Sprite2D.new()
			sprite.texture = empty_state
			sprite.centered = false
			sprite.offset = Vector2(x, y) * (Globals.TILE_SIZE as Vector2)
			add_child(sprite)
			textures.append(sprite)
	
	place_rect(Rect2i(1, 2, 3, 4))

func _reset_grid():
	grid_states.clear()
	for i in range(grid_size.x * grid_size.y):
		grid_states.append(false)

func is_rect_placeable(rect: Rect2i) -> bool:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			if grid_states[y + x * grid_size.x]:
				return false
	
	return true

func place_rect(rect: Rect2i):
	if not is_rect_placeable(rect):
		return
	
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			grid_states[y + x * grid_size.x] = true
	
	_update_textures()

func _update_textures():
	for i in range(grid_size.x * grid_size.y):
		if grid_states[i]:
			textures[i].texture = full_state
		else:
			textures[i].texture = empty_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gift_inside:
		var pos = (Globals.current_gift.global_position - global_position) as Vector2i
		gift_position = pos / Globals.TILE_SIZE
		gift_global_position = (global_position as Vector2i + gift_position * Globals.TILE_SIZE) as Vector2

		Globals.current_gift.can_be_dropped = is_rect_placeable(Rect2i(gift_position, Globals.current_gift.size))
