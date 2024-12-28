extends Node

# Scene Paths
const MAIN_MENU_SCENE = "res://scenes/menus/main_menu.tscn"
const CREDITS_SCENE = "res://scenes/menus/credits_menu.tscn"
const SETTINGS_SCENE = ""
const MAIN_GAME_SCENE = "res://scenes/main.tscn"

const TILE_SIZE: Vector2i = Vector2i(12, 12)

var is_dragging: bool = false

var current_gift: Node2D
var current_grid: Node2D

var gameplay_node: Node2D

var sfx_player: AnimationPlayer
