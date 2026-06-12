extends Control
## MainMenu — Lógica de la pantalla de inicio

@onready var play_button: Button = $CenterContainer/PlayButton

const GAME_SCENE_PATH: String = "res://scenes/game/GameScene.tscn"
const PRESS_FEEDBACK_DURATION: float = 0.08
const PRESS_FEEDBACK_SCALE: Vector2 = Vector2(0.92, 0.92)

var _navigating: bool = false

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	play_button.resized.connect(_recenter_pivot)
	await get_tree().process_frame
	_recenter_pivot()

func _recenter_pivot() -> void:
	play_button.pivot_offset = play_button.size / 2.0

func _on_play_pressed() -> void:
	if _navigating:
		return
	_navigating = true

	var tween: Tween = create_tween()
	tween.tween_property(play_button, "scale", PRESS_FEEDBACK_SCALE, PRESS_FEEDBACK_DURATION)
	tween.tween_property(play_button, "scale", Vector2.ONE, PRESS_FEEDBACK_DURATION)
	await tween.finished

	GameManager.change_scene(GAME_SCENE_PATH)
