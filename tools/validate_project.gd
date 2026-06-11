extends SceneTree

const REQUIRED_RESOURCE_FILES := [
	"res://scripts/player/player_controller.gd",
	"res://scripts/ui/touch_button.gd",
	"res://scripts/ui/gameplay_ui.gd",
	"res://scripts/game/game_scene.gd",
	"res://scenes/ui/UI_Gameplay.tscn",
	"res://scenes/character/PlayerCharacter_test.tscn",
	"res://assets/ui/icons/arrow_white.png",
	"res://assets/ui/icons/pause_icon.png"
]

const REQUIRED_PLAIN_FILES := [
	"res://FASE_4_RESULTADO.md",
	"res://FASE_5_RESULTADO.md",
	"res://FASE_6_RESULTADO.md"
]

func _initialize() -> void:
	for p in REQUIRED_RESOURCE_FILES:
		if not ResourceLoader.exists(p):
			push_error("VALIDATION_FAIL missing resource: %s" % p)
			quit(1)
			return

	for p in REQUIRED_PLAIN_FILES:
		if not FileAccess.file_exists(p):
			push_error("VALIDATION_FAIL missing file: %s" % p)
			quit(1)
			return

	var game_scene: PackedScene = load("res://scenes/game/GameScene.tscn")
	if game_scene == null:
		push_error("VALIDATION_FAIL cannot load GameScene")
		quit(1)
		return

	var instance := game_scene.instantiate()
	if instance == null:
		push_error("VALIDATION_FAIL cannot instantiate GameScene")
		quit(1)
		return

	var player := instance.get_node_or_null("PlayerCharacter")
	if player == null or player.get_script() == null:
		push_error("VALIDATION_FAIL PlayerCharacter missing script")
		quit(1)
		return

	var ui := instance.get_node_or_null("UI_Gameplay")
	if ui == null:
		push_error("VALIDATION_FAIL UI_Gameplay missing in GameScene")
		quit(1)
		return

	print("validation_ok")
	instance.queue_free()
	quit(0)
