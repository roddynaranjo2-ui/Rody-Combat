# gdlint: disable=class-definitions-order,max-line-length
extends CharacterBody3D
class_name PlayerController

const WALK_SPEED: float = 1.8
const RUN_SPEED: float = 4.5
const ACCELERATION: float = 12.0
const DECELERATION: float = 16.0
const JUMP_VELOCITY: float = 7.5
const GRAVITY: float = 22.0
const FALL_GRAVITY_MULTIPLIER: float = 1.6
const CROUCH_SPEED_MULTIPLIER: float = 0.4
const RUN_THRESHOLD_HOLD: float = 0.6
const LAND_HARD_VELOCITY_THRESHOLD: float = 12.0
const RECOVERY_DURATION: float = 2.6
const IDLE_SNAP_THRESHOLD: float = 0.05
const ROTATION_RATE: float = 14.0

@export var model_yaw_offset: float = 0.0

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var model_root: Node3D = $ModelRoot

var input_dir: float = 0.0
var hold_time: float = 0.0
var is_crouching: bool = false
var is_running: bool = false
var was_on_floor: bool = true
var is_recovering_from_fall: bool = false
var recovery_elapsed: float = 0.0
var velocity_pre_move: Vector3 = Vector3.ZERO

func _ready() -> void:
	if anim_player != null and not anim_player.animation_finished.is_connected(_on_animation_finished):
		anim_player.animation_finished.connect(_on_animation_finished, CONNECT_PERSIST)
	if anim_tree != null:
		anim_tree.active = true
		_set_anim_param("parameters/conditions/is_crouching", false)
		_set_anim_param("parameters/conditions/fall_impact_triggered", false)
		_set_anim_param("parameters/conditions/recovered", false)
		_set_anim_param("parameters/Jump/conditions/landed", false)

func _physics_process(delta: float) -> void:
	_read_input(delta)
	_apply_gravity(delta)
	_handle_jump_and_crouch()
	_handle_horizontal_movement(delta)
	velocity_pre_move = velocity
	move_and_slide()
	_detect_landing()
	_update_recovery_timer(delta)
	if is_on_floor() and velocity.y < 0.0:
		velocity.y = -0.5
	_update_animation_parameters()

func _read_input(delta: float) -> void:
	if is_recovering_from_fall:
		input_dir = 0.0
		hold_time = 0.0
		is_running = false
		return

	input_dir = InputRouter.horizontal_axis()
	if absf(input_dir) > 0.1 and not is_crouching:
		hold_time += delta
		is_running = hold_time > RUN_THRESHOLD_HOLD
	else:
		hold_time = 0.0
		is_running = false

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		var gravity_mult: float = FALL_GRAVITY_MULTIPLIER if velocity.y < 0.0 else 1.0
		velocity.y -= GRAVITY * gravity_mult * delta

func _handle_jump_and_crouch() -> void:
	if is_recovering_from_fall:
		is_crouching = false
		_set_anim_param("parameters/conditions/is_crouching", false)
		return

	var jump_now: bool = InputRouter.jump_just_pressed() and is_on_floor()
	var crouch_pressing: bool = InputRouter.crouch_pressed()

	if jump_now:
		velocity.y = JUMP_VELOCITY
		is_crouching = false
		_set_anim_param("parameters/conditions/is_crouching", false)
		_play_anim("jump_start")
		return

	if crouch_pressing and is_on_floor():
		is_crouching = true
	else:
		is_crouching = false
	_set_anim_param("parameters/conditions/is_crouching", is_crouching)

func _handle_horizontal_movement(delta: float) -> void:
	var target_speed: float = 0.0

	if absf(input_dir) > 0.1:
		target_speed = (RUN_SPEED if is_running else WALK_SPEED) * input_dir
		if is_crouching:
			target_speed *= CROUCH_SPEED_MULTIPLIER

		var base_yaw: float = 0.0 if input_dir > 0.0 else PI
		var target_yaw: float = base_yaw + model_yaw_offset
		var rot_weight: float = 1.0 - exp(-ROTATION_RATE * delta)
		model_root.rotation.y = lerp_angle(model_root.rotation.y, target_yaw, rot_weight)
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

	velocity.z = 0.0

func _detect_landing() -> void:
	var on_floor_now: bool = is_on_floor()
	if not was_on_floor and on_floor_now:
		var impact_velocity: float = absf(velocity_pre_move.y)
		if impact_velocity > LAND_HARD_VELOCITY_THRESHOLD:
			_set_anim_param("parameters/conditions/fall_impact_triggered", true)
			_set_anim_param("parameters/conditions/recovered", false)
			is_recovering_from_fall = true
			recovery_elapsed = 0.0
			_play_anim("fall")
			GameManager.camera_shake_requested.emit(0.3)
		else:
			_set_anim_param("parameters/Jump/conditions/landed", true)
			_play_anim("land")
	was_on_floor = on_floor_now

func _update_recovery_timer(delta: float) -> void:
	if is_recovering_from_fall:
		recovery_elapsed += delta
		if recovery_elapsed >= RECOVERY_DURATION:
			_force_recover("timer")

func _force_recover(reason: String) -> void:
	is_recovering_from_fall = false
	recovery_elapsed = 0.0
	_set_anim_param("parameters/conditions/fall_impact_triggered", false)
	_set_anim_param("parameters/conditions/recovered", true)
	print_debug("[PlayerController] Recovered (%s)" % reason)

func _update_animation_parameters() -> void:
	if anim_tree == null:
		return
	var raw_speed_norm: float = clamp(absf(velocity.x) / RUN_SPEED, 0.0, 1.0)
	var speed_norm: float = 0.0 if raw_speed_norm < IDLE_SNAP_THRESHOLD else raw_speed_norm
	if anim_tree.has_method("has_parameter") and anim_tree.has_parameter("parameters/Movement/locomotion/blend_position"):
		var current: float = anim_tree.get("parameters/Movement/locomotion/blend_position")
		anim_tree.set("parameters/Movement/locomotion/blend_position", lerpf(current, speed_norm, 0.2))

	if not is_on_floor():
		_play_anim("jump_air")
	elif is_crouching:
		if absf(velocity.x) < IDLE_SNAP_THRESHOLD:
			_play_anim("crouch_idle")
		else:
			_play_anim("crouch")
	else:
		if absf(velocity.x) < 0.2:
			_play_anim("idle")
		elif is_running:
			_play_anim("run")
		else:
			_play_anim("walk")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"land":
		_set_anim_param("parameters/Jump/conditions/landed", false)

func _play_anim(name: String) -> void:
	if anim_player == null:
		return
	if anim_player.has_animation(name) and anim_player.current_animation != name:
		anim_player.play(name)

func _set_anim_param(path: String, value: Variant) -> void:
	if anim_tree == null:
		return
	if anim_tree.has_method("has_parameter"):
		if anim_tree.has_parameter(path):
			anim_tree.set(path, value)
	else:
		anim_tree.set(path, value)
