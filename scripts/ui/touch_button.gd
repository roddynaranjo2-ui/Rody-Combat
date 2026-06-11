extends TouchScreenButton
class_name DirectionalTouchButton

@export_enum("left", "right", "jump", "crouch") var direction: String = "left"

func _ready() -> void:
	pressed.connect(_on_pressed)
	released.connect(_on_released)

func _on_pressed() -> void:
	InputRouter.set_touch(direction, true)

func _on_released() -> void:
	InputRouter.set_touch(direction, false)
