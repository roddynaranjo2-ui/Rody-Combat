extends SceneTree

func _initialize() -> void:
	var main_scene: PackedScene = load("res://scenes/main_menu/MainMenuScene.tscn")
	if main_scene == null:
		push_error("SMOKE_FAIL: no se pudo cargar MainMenuScene")
		quit(1)
		return
	var game_scene: PackedScene = load("res://scenes/game/GameScene.tscn")
	if game_scene == null:
		push_error("SMOKE_FAIL: no se pudo cargar GameScene")
		quit(1)
		return
	var ui_scene: PackedScene = load("res://scenes/ui/UI_Gameplay.tscn")
	if ui_scene == null:
		push_error("SMOKE_FAIL: no se pudo cargar UI_Gameplay")
		quit(1)
		return
	var test_scene: PackedScene = load("res://scenes/character/PlayerCharacter_test.tscn")
	if test_scene == null:
		push_error("SMOKE_FAIL: no se pudo cargar PlayerCharacter_test")
		quit(1)
		return

	var inst: Node = game_scene.instantiate()
	if inst == null:
		push_error("SMOKE_FAIL: no se pudo instanciar GameScene")
		quit(1)
		return
	inst.queue_free()

	print("phase6_smoketest_ok")
	quit(0)
