extends Node
## GameManager — Singleton global del juego
##
## Responsabilidades (Fase 1: solo esqueleto):
##   - Estado global (puntuación, vidas, fase actual)        [Fase 2+]
##   - Transición entre escenas                              [Fase 2]
##   - Señales globales (camera_shake_requested, etc.)       [Fase 4]
##   - Persistencia de datos (settings, save game)           [Fase 6+]

# ============ SEÑALES GLOBALES ============
signal camera_shake_requested(intensity: float)
signal game_paused(is_paused: bool)
signal scene_change_failed(scene_path: String, error_code: int)

# ============ ESTADO ============
var current_scene_path: String = ""

# ============ MÉTODOS PÚBLICOS ============

## Cambia a la escena indicada de forma deferred y captura el código de error.
## Si la ruta no existe (caso típico: MainMenuScene aún no creada en Fase 2),
## emite scene_change_failed para que la UI pueda mostrar un mensaje.
func change_scene(scene_path: String) -> void:
	# TODO Fase 2: implementar fade out + transición + fade in
	current_scene_path = scene_path
	# Diferido para no romper signal handlers en curso (warning de Godot 4)
	call_deferred("_do_change_scene", scene_path)

func _do_change_scene(scene_path: String) -> void:
	var err: int = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		printerr("[GameManager] ERROR CRÍTICO: No se pudo cargar la escena %s. Error: %d" % [scene_path, err])
		scene_change_failed.emit(scene_path, err)

func request_pause(paused: bool) -> void:
	# Fija el estado de pausa de forma explícita. ÚNICA escritura de get_tree().paused.
	get_tree().paused = paused
	game_paused.emit(paused)

## v2.1 (B-05): toggle CENTRALIZADO. Tanto el botón de pausa (Fase 5) como la
## tecla Esc (Fase 6) llaman AQUÍ — una única fuente de verdad evita el doble toggle
## y la desincronización entre el icono y get_tree().paused.
func toggle_pause() -> void:
	request_pause(not get_tree().paused)

# ============ CICLO DE VIDA ============
func _ready() -> void:
await get_tree().create_timer(0.1).timeout
	process_mode = Node.PROCESS_MODE_ALWAYS  # No se pausa nunca
	print_debug("[GameManager] Inicializado")
