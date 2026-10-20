class_name Player
extends CharacterBody3D
## BALLS movement-sandbox player (kinematic controller, no RigidBody).
##
## Input collection (`collect_input`) is deliberately separated from movement
## simulation (`_physics_process`): the physics step only consumes the plain
## `PlayerInput` data struct. A future multiplayer build can feed replicated
## input into that same struct without touching the simulation.

# ---------------------------------------------------------------------------
# Input state: plain data, filled by collect_input(), consumed by physics.
# ---------------------------------------------------------------------------
class PlayerInput:
	var move_dir := Vector2.ZERO  # x = strafe (+right), y = forward (+1)
	var jump_held := false
	var reset_requested := false


@export_group("Movement")
## Multiplier applied to the project's default gravity magnitude.
@export var gravity_scale := 2.0
## Steering acceleration while grounded, m/s^2.
@export var ground_accel := 20.0
## Fraction of grounded steering available while airborne.
@export var air_control_factor := 0.35
## Mild linear drag on horizontal velocity (per second). Momentum is preserved;
## this only bleeds a little speed over time.
@export var drag := 0.1
## Vertical impulse for a grounded jump, m/s.
@export var jump_speed := 7.5
## Hard cap on horizontal speed, m/s.
@export var max_horizontal_speed := 32.0

@export_group("Spawn")
## World position the reset control returns to.
@export var spawn_position := Vector3(0, 21, 0)

@export_group("References")
## Camera used for screen-relative steering (a Camera3D). May be empty;
## falls back to course-aligned world axes (+Z forward).
@export var camera_path: NodePath


var radius := 0.5
var input_state := PlayerInput.new()

var _visual: MeshInstance3D
var _camera: Camera3D


func _ready() -> void:
	_visual = get_node_or_null("Visual") as MeshInstance3D
	if camera_path != NodePath(""):
		_camera = get_node_or_null(camera_path) as Camera3D


# ---------------------------------------------------------------------------
# Input collection (replaceable by replicated input in a future build).
# ---------------------------------------------------------------------------
func collect_input() -> void:
	input_state.move_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_back", "move_forward")
	)
	input_state.jump_held = Input.is_action_pressed("jump")
	input_state.reset_requested = Input.is_action_pressed("reset")


# ---------------------------------------------------------------------------
# Movement simulation.
# ---------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	collect_input()

	if input_state.reset_requested:
		reset_to_spawn()
		return

	var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_scale
	velocity.y += gravity * delta

	var dir := _steer_direction()
	var accel := ground_accel if is_on_floor() else ground_accel * air_control_factor
	if dir != Vector3.ZERO:
		velocity += dir * accel * delta

	# Momentum-preserving drag + speed cap on the horizontal component.
	var hv := Vector3(velocity.x, 0.0, velocity.z)
	hv *= maxf(0.0, 1.0 - drag * delta)
	if hv.length() > max_horizontal_speed:
		hv = hv.normalized() * max_horizontal_speed
	velocity.x = hv.x
	velocity.z = hv.z

	# Grounded jump only; horizontal momentum is preserved on landing.
	if input_state.jump_held and is_on_floor():
		velocity.y = jump_speed

	move_and_slide()
	_update_visual_roll(delta)


## World-space horizontal steering direction from the collected input,
## relative to camera yaw (screen-relative third-person control).
func _steer_direction() -> Vector3:
	var m := input_state.move_dir
	if m == Vector2.ZERO:
		return Vector3.ZERO

	var has_cam := _camera != null and is_instance_valid(_camera)
	var basis := Transform3D.IDENTITY.basis
	if has_cam:
		basis = _camera.global_transform.basis

	var fwd := Vector3(-basis.z.x, 0.0, -basis.z.z)
	if not has_cam or fwd.length_squared() < 1e-4:
		fwd = Vector3(0.0, 0.0, 1.0)
	fwd = fwd.normalized()

	var right := Vector3(-1.0, 0.0, 0.0)
	if has_cam:
		right = Vector3(basis.x.x, 0.0, basis.x.z)
	if right.length_squared() < 1e-4:
		right = fwd.cross(Vector3.UP)
	else:
		right = right.normalized()

	return (fwd * m.y + right * m.x).normalized()


## Rotate the visual mesh only, to convey rolling motion.
func _update_visual_roll(delta: float) -> void:
	if _visual == null or velocity.length_squared() < 1e-3:
		return
	var n := get_floor_normal() if is_on_floor() else Vector3.UP
	if n.length_squared() < 1e-8:
		n = Vector3.UP
	var v_tangent := velocity - n * velocity.dot(n)
	if v_tangent.length_squared() < 1e-4:
		return
	var omega := n.cross(v_tangent) / radius
	if omega.length_squared() < 1e-8:
		return
	var q := Quaternion(omega.normalized(), omega.length() * delta)
	# Node3D rotation properties are Euler Vector3s, so accumulate the roll as a
	# Basis in world space (the player body itself never rotates).
	var basis := Basis(q) * _visual.global_transform.basis
	_visual.global_transform = Transform3D(basis, _visual.global_position)


## Return the player to the spawn point with zero velocity.
func reset_to_spawn() -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	if _visual != null:
		_visual.rotation = Vector3.ZERO
