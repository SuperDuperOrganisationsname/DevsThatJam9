extends Button

enum PossibleScenes {
	main_game,
	main_menu,
	settings,
	credits,
	howtoplay
}

@export var scene_to_transition: PossibleScenes
@onready var scene_path = ""

func _ready() -> void:
	match scene_to_transition:
		0:
			scene_path = Globals.MAIN_GAME_SCENE
		1:
			scene_path = Globals.MAIN_MENU_SCENE
		2:
			scene_path = Globals.SETTINGS_SCENE
		3:
			scene_path = Globals.CREDITS_SCENE
		4:
			scene_path = Globals.HOWTOPLAY_SCENE
		_:
			scene_path = Globals.MAIN_GAME_SCENE

func _pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)
