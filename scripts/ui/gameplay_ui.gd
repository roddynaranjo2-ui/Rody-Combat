extends CanvasLayer

@onready var pause_button: TextureButton = $PauseButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.pressed.connect(_on_pause_pressed)
	GameManager.game_paused.connect(_on_game_paused_changed)

func _on_pause_pressed() -> void:
	GameManager.toggle_pause()

func _on_game_paused_changed(paused: bool) -> void:
	pause_button.modulate = Color(1, 1, 1, 1.0) if paused else Color(1, 1, 1, 0.9)
