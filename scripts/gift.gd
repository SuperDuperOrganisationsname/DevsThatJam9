extends Node2D

@export var gift_size: Vector2i
@export var scale_size: int = 1
@export var texture: Texture2D
@export var color: int

@onready var size: Vector2i = gift_size * scale_size
@onready var scaled_half_size: Vector2 = (size * Globals.TILE_SIZE) as Vector2 / 2

var sprite: Sprite2D

var initial_position: Vector2
var offset: Vector2

var draggable: bool = false

var can_be_dropped: bool = false
var is_dropped: bool = false
var final_pos_timer: int = 10
var final_pos: Vector2 = Vector2(0, 0)

var gift_index: int = 0

var is_moving: bool = false

@onready var pub_area_node: Area2D = $Area2D

signal place_gift
signal reject_gift

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_gift()

func _init_gift() -> void:
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.hframes = 3
	sprite.frame = color
	
	add_child(sprite)
	
	scale = Vector2(1, 1)
	z_index = 0
	var shape = RectangleShape2D.new()
	shape.size = (gift_size * Globals.TILE_SIZE) as Vector2
	$Area2D/CollisionShape2D.shape = shape

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dropped:
		z_index = -1
		if final_pos_timer > 0:
			final_pos_timer -= 1
		else:
			position = final_pos
		
	
	if draggable and not is_dropped:
		_drag()
	
	if tentative_gift and Globals.current_gift == null:
		_on_area_2d_mouse_entered()

func _drag():
	if Input.is_action_just_pressed("click"):
		initial_position = global_position
		offset = get_global_mouse_position() - global_position
		Globals.is_dragging = true
		Globals.current_gift = self
		
		_on_select_gift()
	if Input.is_action_pressed("click"):
		global_position = get_global_mouse_position() - offset
		
		_on_drag_gift()
	elif Input.is_action_just_released("click"):
		Globals.is_dragging = false
		if Globals.current_grid:
			Globals.current_grid.gift_inside = false
		var tween = get_tree().create_tween()
		z_index = 0
		if can_be_dropped:
			tween.tween_property(self, "position", Globals.current_grid.gift_global_position as Vector2, 0.2).set_ease(Tween.EASE_OUT)
			Globals.current_grid.place_rect(Rect2i(Globals.current_grid.gift_position, size))
			final_pos = Globals.current_grid.gift_global_position as Vector2
			_on_place_gift()
			is_dropped = true
			scale = Vector2(scale_size, scale_size)
			z_index = -1
			
			Globals.gameplay_node.remove_gift(gift_index)
			$Area2D.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			tween.tween_property(self, "global_position", initial_position, 0.2).set_ease(Tween.EASE_OUT)
			scale = Vector2(1, 1)
			_on_reject_gift()
			draggable = false
			is_moving = false
			z_index = 0
		Globals.current_gift = null
		Globals.current_grid = null

func _on_select_gift():
	place_gift.emit()
	
func _on_drag_gift():
	pass

func _on_place_gift():
	place_gift.emit()
	
func _on_reject_gift():
	reject_gift.emit()

var tentative_gift: bool = false

func _on_area_2d_mouse_entered() -> void:
	tentative_gift = true
	if not Globals.is_dragging and Globals.current_gift == null:
		draggable = true
		is_moving = true
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(scale_size + 0.05, scale_size + 0.05), 0.1).set_ease(Tween.EASE_OUT)
		Globals.current_gift = self
		z_index = 1


func _on_area_2d_mouse_exited() -> void:
	tentative_gift = false
	if not Globals.is_dragging and Globals.current_gift == self:
		draggable = false
		is_moving = false
		var tween = get_tree().create_tween()
		if is_dropped:
			tween.tween_property(self, "scale", Vector2(scale_size, scale_size), 0.1).set_ease(Tween.EASE_OUT)
		else:
			tween.tween_property(self, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)
		Globals.current_gift = null
		z_index = 0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if color != body.color:
		return
	Globals.current_grid = body
	Globals.current_grid.gift_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if color != body.color:
		return
	can_be_dropped = false
	if Globals.current_grid:
		Globals.current_grid.gift_inside = false
		Globals.current_grid = null
