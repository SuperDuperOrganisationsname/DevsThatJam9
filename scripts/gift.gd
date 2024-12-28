extends Node2D

@export var size: Vector2i
@export var texture: Texture2D
@export var color: int

var sprite: Sprite2D

var initial_position: Vector2
var offset: Vector2

var draggable: bool = false

var can_be_dropped: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.hframes = 3
	sprite.frame = color
	
	add_child(sprite)
	
	for c in $Area2D.get_children():
		if c is CollisionShape2D:
			var shape = RectangleShape2D.new()
			shape.size = (size * Globals.TILE_SIZE) as Vector2
			c.shape = shape
	
	$Area2D.position += (size * Globals.TILE_SIZE) as Vector2 / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if draggable:
		_drag()

func _drag():
	if Input.is_action_just_pressed("click"):
		initial_position = global_position
		offset = get_global_mouse_position() - global_position
		Globals.is_dragging = true
		Globals.current_gift = self
	if Input.is_action_pressed("click"):
		global_position = get_global_mouse_position() - offset
	elif Input.is_action_just_released("click"):
		Globals.is_dragging = false
		if Globals.current_grid:
			Globals.current_grid.gift_inside = false
		var tween = get_tree().create_tween()
		if can_be_dropped:
			tween.tween_property(self, "position", Globals.current_grid.gift_global_position as Vector2, 0.2).set_ease(Tween.EASE_OUT)
			Globals.current_grid.place_rect(Rect2i(Globals.current_grid.gift_position, size))
			
			$Area2D.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			tween.tween_property(self, "global_position", initial_position, 0.2).set_ease(Tween.EASE_OUT)
		Globals.current_gift = null


func _on_area_2d_mouse_entered() -> void:
	if not Globals.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)


func _on_area_2d_mouse_exited() -> void:
	if not Globals.is_dragging:
		draggable = false
		scale = Vector2(1, 1)


func _on_area_2d_body_entered(body: Node2D) -> void:
	Globals.current_grid = body
	Globals.current_grid.gift_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	can_be_dropped = false
	Globals.current_grid.gift_inside = false
	Globals.current_grid = null
