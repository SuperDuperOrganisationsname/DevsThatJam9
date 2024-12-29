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

func _spawn_gift(gift: Gift) -> Node2D:
	var obj = load("res://scenes/gift.tscn").instantiate()
	obj.connect("place_gift", Globals.sfx_player.play_gift_interaction_sound)
	obj.connect("reject_gift", Globals.sfx_player.play_gift_rejection_sound)
	obj.texture = gift.texture
	obj.scale_size = gift.scale
	obj.gift_size = gift.size
	obj.color = gift.color
	obj.gift_index = 15
	
	obj.position = Vector2(_int_to_x_pos(15), -100)
	$Gifts.add_child(obj)
	obj._init_gift()
	
	return obj
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.gameplay_node = self
	
	for i in range(Num_Starting_Gifts):
		pending_gifts.append(_spawn_gift(_draw_gift()))
	_update_positions()

func _int_to_x_pos(i: int) -> int:
	return -246 + 36 * (14 - i)

func _update_positions():
	for j in range(pending_gifts.size()):
		if j >= pending_gifts.size():
			continue
		var gift = pending_gifts[j]
		if not gift.draggable and gift.position.x == _int_to_x_pos(gift.gift_index):
			var tween = get_tree().create_tween()
			gift.pub_area_node.process_mode = Node.PROCESS_MODE_DISABLED
			tween.tween_property(gift, "position", Vector2(_int_to_x_pos(j), -100), 0.1 * (gift.gift_index - j)).set_ease(Tween.EASE_OUT)
			gift.gift_index = j
			
			await tween.finished
			gift.pub_area_node.process_mode = Node.PROCESS_MODE_INHERIT

func remove_gift(index: int):
	pending_gifts.remove_at(index)
	_update_positions()

func add_gift():
	if pending_gifts.size() < 15:
		pending_gifts.append(_spawn_gift(_draw_gift()))
		_update_positions()
	else:
		defeat()

func defeat():
	pass

var update_frame_timer: int = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_frame_timer -= 1
	if update_frame_timer <= 0:
		_update_positions()
		update_frame_timer = 10
	
	for gift in pending_gifts:
		if gift and not gift.draggable:
			gift.position.y = -100
	
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
	var score: int = 0
	if i == 0:
		$ShippingBox1.play("ClosePackage")
		score += $Packages/Package1/PackingGrid.reset_grid()
		
		var cd = (1.0 - (score as float / 64.0)) * base_cd
		$Timer/Button1CD.start(cd)
		$Timer/DeleteGiftsTimer1.start(1.5)
	elif i == 1:
		$ShippingBox2.play("ClosePackage")
		score += $Packages/Package2/PackingGrid.reset_grid()
		
		var cd = (1.0 - (score as float / 64.0)) * base_cd
		$Timer/Button2CD.start(cd)
		$Timer/DeleteGiftsTimer2.start(1.5)
	elif i == 2:
		$ShippingBox3.play("ClosePackage")
		score += $Packages/Package3/PackingGrid.reset_grid()
		
		var cd = (1.0 - (score as float / 64.0)) * base_cd
		$Timer/Button3CD.start(cd)
		$Timer/DeleteGiftsTimer3.start(1.5)
	
	total_score += score

func _on_color_1_sendoff_button_down() -> void:
	_send_package_off(0)

func _on_color_2_sendoff_button_down() -> void:
	_send_package_off(1)

func _on_color_3_sendoff_button_down() -> void:
	_send_package_off(2)


func _on_new_gift_timer_timeout() -> void:
	add_gift()
	var time = 5.0 - 4.0 * ((total_score as float) / (total_score as float + 100.0))
	$Timer/NewGiftTimer.start(time)


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

var to_delete_colors: Array[int] = []

func _on_delete_gifts_timer_1_timeout() -> void:
	$Packages/Package1.visible = false
	for child in $Gifts.get_children():
		if child.color == 0 and child.is_dropped:
			child.queue_free()
	
	var tween = get_tree().create_tween()
	tween.tween_property($ShippingBox1, "position", Vector2(-192, 500), 0.5).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property($ShippingBox1, "position", Vector2(-192, 84), 0.5).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	$Packages/Package1.visible = true
	$ShippingBox1.play("ClosePackage", -1.0)

func _on_delete_gifts_timer_2_timeout() -> void:
	$Packages/Package2.visible = false
	for child in $Gifts.get_children():
		if child.color == 1 and child.is_dropped:
			child.queue_free()
	
	var tween = get_tree().create_tween()
	tween.tween_property($ShippingBox2, "position", Vector2(0, 500), 0.5).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property($ShippingBox2, "position", Vector2(0, 84), 0.5).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	$Packages/Package2.visible = true
	$ShippingBox2.play("ClosePackage", -1.0)


func _on_delete_gifts_timer_3_timeout() -> void:
	$Packages/Package3.visible = false
	for child in $Gifts.get_children():
		if child.color == 2 and child.is_dropped:
			child.queue_free()
	
	var tween = get_tree().create_tween()
	tween.tween_property($ShippingBox3, "position", Vector2(192, 500), 0.5).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property($ShippingBox3, "position", Vector2(192, 84), 0.5).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	$Packages/Package3.visible = true
	$ShippingBox3.play("ClosePackage", -1.0)
