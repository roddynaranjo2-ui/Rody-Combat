extends Node
## InputRouter — Abstracción de inputs táctiles / teclado
##
## Cualquier sistema del juego que necesite leer input DEBE pasar por aquí.
## Esto desacopla los TouchScreenButton del PlayerController.
##
## Fase 1: esqueleto. La lógica real se completa en Fase 5 junto con la UI táctil.

# ============ ESTADO TÁCTIL ============
var _touch_left: bool = false
var _touch_right: bool = false
var _touch_jump_pulse: bool = false
var _touch_crouch: bool = false

# ============ API PÚBLICA (la consume PlayerController en Fase 4) ============
func set_touch(action: String, pressed: bool) -> void:
	match action:
		"left":
			_touch_left = pressed
		"right":
			_touch_right = pressed
		"jump":
			if pressed:
				_touch_jump_pulse = true
		"crouch":
			_touch_crouch = pressed

func horizontal_axis() -> float:
	var keyboard: float = Input.get_axis("move_left", "move_right")
	var touch: float = (1.0 if _touch_right else 0.0) - (1.0 if _touch_left else 0.0)
	return clamp(keyboard + touch, -1.0, 1.0)

func jump_just_pressed() -> bool:
	var k: bool = Input.is_action_just_pressed("jump")
	var t: bool = _touch_jump_pulse
	_touch_jump_pulse = false  # consumir pulso (one-shot)
	return k or t

func crouch_pressed() -> bool:
	return Input.is_action_pressed("crouch") or _touch_crouch

# ============ CICLO DE VIDA ============
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print_debug("[InputRouter] Inicializado")
