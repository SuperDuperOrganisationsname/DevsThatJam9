extends Node2D

@export var base_cd: float = 5.0

const Options_Color: Array[int] = [0, 1, 2]
const Options_Sizes: Array[Vector2i] = [Vector2i(2, 2), Vector2i(2, 1), Vector2i(1, 2)]
const Options_Scale: Array[int] = [1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4]

@onready var Sprites: Array[Texture2D] = [
	load("res://assets/art/Presents/2x2Present.png"),
	load("res://assets/art/Presents/2x1Present.png"),
	load("res://assets/art/Presents/1x2Present.png")
]

const Num_Starting_Gifts: int = 5

class Gift:
	var color: int
	var size: Vector2i
	var scale: int
	var texture: Texture2D

var pending_gifts: Array[Node2D] = []

var total_score: int = 0

func _draw_gift() -> Gift:
	var gift = Gift.new()
	gift.color = Options_Color[randi() % Options_Color.size()]
	gift.scale = Options_Scale[randi() % Options_Scale.size()]
	
	var size_int = randi() % Options_Sizes.size()
	gift.size = Options_Sizes[size_int]
	gift.texture = Sprites[size_int]
	
	return gift

func _spawn_gift(gift: Gift, pos: Vector2) -> Node2D:
	var obj = load("res://scenes/gift.tscn").instantiate()
	obj.connect("place_gift", Globals.sfx_player.play_gift_interaction_sound)
	obj.connect("reject_gift", Globals.sfx_player.play_gift_rejection_sound)
	obj.texture = gift.texture
	obj.scale_size = gift.scale
	obj.gift_size = gift.size
	obj.color = gift.color
	
	obj.position = pos
	$Gifts.add_child(obj)
	obj._init_gift()
	
	return obj
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.gameplay_node = self
	
	for i in range(Num_Starting_Gifts):
		pending_gifts.append(_spawn_gift(_draw_gift(), Vector2(_int_to_x_pos(i), -100)))
	_update_positions()

func _int_to_x_pos(i: int) -> int:
	return -246 + 36 * (14 - i)

func _update_positions():
	for j in range(pending_gifts.size()):
		if not pending_gifts[j].draggable:
			var tween = get_tree().create_tween()
			tween.tween_property(pending_gifts[j], "position", Vector2(_int_to_x_pos(j), -100), 0.2).set_ease(Tween.EASE_OUT)
			pending_gifts[j].gift_index = j

func remove_gift(index: int):
	pending_gifts.remove_at(index)
	_update_positions()

func add_gift():
	if pending_gifts.size() < 15:
		pending_gifts.append(_spawn_gift(_draw_gift(), Vector2(_int_to_x_pos(14), -100)))
		_update_positions()
	else:
		defeat()

func defeat():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(pending_gifts.size()):
		if not pending_gifts[i].draggable:
			pending_gifts[i].position.y = -100
	
	$Control/Score.text = str(total_score)

	if $Timer/Button1CD.time_left > 0.0:
		$Control/Color1Sendoff.text = "%.1fs" % ($Timer/Button1CD.time_left)
		$Control/Color1Sendoff.disabled = true
		$Packages/Package1.process_mode = Node.PROCESS_MODE_DISABLED
	
	if $Timer/Button2CD.time_left > 0.0:
		$Control/Color2Sendoff.text = "%.1fs" % ($Timer/Button2CD.time_left)
		$Control/Color2Sendoff.disabled = true
		$Packages/Package2.process_mode = Node.PROCESS_MODE_DISABLED
		
	if $Timer/Button3CD.time_left > 0.0:
		$Control/Color3Sendoff.text = "%.1fs" % ($Timer/Button3CD.time_left)
		$Control/Color3Sendoff.disabled = true
		$Packages/Package3.process_mode = Node.PROCESS_MODE_DISABLED

func _send_package_off(i: int):
	for child in $Gifts.get_children():
		if child.color == i and child.is_dropped:
			child.queue_free()
	
	var score: int = 0
	if i == 0:
		score += $Packages/Package1/PackingGrid.reset_grid()
		
		var cd = (1.0 - (score as float / 64.0)) * base_cd
		$Timer/Button1CD.start(cd)
	elif i == 1:
		score += $Packages/Package2/PackingGrid.reset_grid()
		
		var cd = (1.0 - (score as float / 64.0)) * base_cd
		$Timer/Button2CD.start(cd)
	elif i == 2:
		score += $Packages/Package3/PackingGrid.reset_grid()
		
		var cd = (1.0 - (score as float / 64.0)) * base_cd
		$Timer/Button3CD.start(cd)
	
	total_score += score

func _on_color_1_sendoff_button_down() -> void:
	_send_package_off(0)

func _on_color_2_sendoff_button_down() -> void:
	_send_package_off(1)

func _on_color_3_sendoff_button_down() -> void:
	_send_package_off(2)


func _on_new_gift_timer_timeout() -> void:
	add_gift()


const Button_Text = "Package & Send"

func _on_button_1cd_timeout() -> void:
	$Control/Color1Sendoff.text = Button_Text
	$Control/Color1Sendoff.disabled = false
	$Packages/Package1.process_mode = Node.PROCESS_MODE_INHERIT


func _on_button_2cd_timeout() -> void:
	$Control/Color2Sendoff.text = Button_Text
	$Control/Color2Sendoff.disabled = false
	$Packages/Package2.process_mode = Node.PROCESS_MODE_INHERIT


func _on_button_3cd_timeout() -> void:
	$Control/Color3Sendoff.text = Button_Text
	$Control/Color3Sendoff.disabled = false
	$Packages/Package3.process_mode = Node.PROCESS_MODE_INHERIT
