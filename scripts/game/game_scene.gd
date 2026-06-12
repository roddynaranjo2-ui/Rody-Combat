extends Node3D
## Integración final de gameplay (Fase 6):
## - Pausa centralizada (Esc -> GameManager)
## - Overlay de pausa (reanudar/reiniciar/menú)
## - Shake de cámara por señal global

const MAIN_MENU_SCENE_PATH: String = "res://scenes/main_menu/MainMenuScene.tscn"
const GAME_SCENE_PATH: String = "res://scenes/game/GameScene.tscn"

@onready var camera_3d: Camera3D = $CameraRig/Camera3D
@onready var pause_overlay: CanvasLayer = $PauseOverlay
@onready var resume_button: Button = $PauseOverlay/Panel/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PauseOverlay/Panel/VBoxContainer/RestartButton
@onready var main_menu_button: Button = $PauseOverlay/Panel/VBoxContainer/MainMenuButton

var _base_camera_pos: Vector3
var _shake_amount: float = 0.0
var _shake_decay: float = 5.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_base_camera_pos = camera_3d.position
	pause_overlay.visible = false
	pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS

	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	GameManager.game_paused.connect(_on_game_paused_changed)
	GameManager.camera_shake_requested.connect(_on_camera_shake_requested)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameManager.toggle_pause()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if _shake_amount > 0.001:
		var offset := Vector3(
			_rng.randf_range(-_shake_amount, _shake_amount),
			_rng.randf_range(-_shake_amount, _shake_amount),
			0.0
		)
		camera_3d.position = _base_camera_pos + offset
		_shake_amount = maxf(0.0, _shake_amount - _shake_decay * delta)
	else:
		camera_3d.position = _base_camera_pos

func _on_game_paused_changed(paused: bool) -> void:
	pause_overlay.visible = paused

func _on_camera_shake_requested(intensity: float) -> void:
	_shake_amount = maxf(_shake_amount, intensity)

func _on_resume_pressed() -> void:
	if get_tree().paused:
		GameManager.toggle_pause()

func _on_restart_pressed() -> void:
	if get_tree().paused:
		GameManager.request_pause(false)
	GameManager.change_scene(GAME_SCENE_PATH)

func _on_main_menu_pressed() -> void:
	if get_tree().paused:
		GameManager.request_pause(false)
	GameManager.change_scene(MAIN_MENU_SCENE_PATH)
