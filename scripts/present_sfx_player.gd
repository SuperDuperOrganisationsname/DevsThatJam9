extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.sfx_player = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_gift_interaction_sound():
	var animation = "rustle_" + str(randi_range(1, 7))
	self.play(animation)
