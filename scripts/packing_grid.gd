extends Node2D

@export var texture: Texture2D
@export var placement_possible_texture: Texture2D
@export var color: int

var grid_states: Array[bool] = []
var grid_size: Vector2i = Vector2i(8, 8)

var placed_tiles: int = 0

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
	reset_grid()
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var sprite = Sprite2D.new()
			sprite.texture = texture
			sprite.centered = false
			sprite.offset = Vector2(x, y) * (Globals.TILE_SIZE as Vector2)
			sprite.hframes = 3
			sprite.frame = color
			add_child(sprite)
			textures.append(sprite)

func reset_grid() -> int:
	grid_states.clear()
	for i in range(grid_size.x * grid_size.y):
		grid_states.append(false)
	
	var temp = placed_tiles
	placed_tiles = 0
	return temp

func redraw_grid():
	for i in range(grid_size.x * grid_size.y):
		textures[i].texture = texture

func draw_placement_grid(rect: Rect2i):
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			textures[y + x * grid_size.x].texture = placement_possible_texture

func is_rect_placeable(rect: Rect2i) -> bool:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			if x < 0 or y < 0 or x >= grid_size.x or y >= grid_size.y or grid_states[y + x * grid_size.x]:
				redraw_grid()
				return false
	redraw_grid()
	draw_placement_grid(rect)
	return true

func place_rect(rect: Rect2i):
	if not is_rect_placeable(rect):
		return
	
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			grid_states[y + x * grid_size.x] = true
			placed_tiles += 1
	redraw_grid()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gift_inside and Globals.current_gift:
		var pos = (Globals.current_gift.global_position - global_position) as Vector2i + Vector2i(2, 2) - (Globals.current_gift.scaled_half_size as Vector2i)
		gift_position = pos / Globals.TILE_SIZE
		gift_global_position = (global_position as Vector2i + gift_position * Globals.TILE_SIZE) as Vector2 + Globals.current_gift.scaled_half_size
		Globals.current_gift.can_be_dropped = is_rect_placeable(Rect2i(gift_position, Globals.current_gift.size))
