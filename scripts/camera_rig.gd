extends Node3D
## Smooth third-person follow camera rig.
## The rig chases the player with exponential smoothing; the Camera3D child
## keeps a fixed local offset and aims at the player each frame.

@export var player_path: NodePath
## Higher = snappier follow.
@export var smoothing := 8.0
## World-space point (relative to the player) the camera aims at, giving a
## slight look-ahead down the course.
@export var aim_offset := Vector3(0, 1.2, 2.0)

var _player: Node3D


func _ready() -> void:
	_player = get_node_or_null(player_path) as Node3D


func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return

	var target := _player.global_position + Vector3(0, 1.5, 0)
	global_position = global_position.lerp(target, 1.0 - exp(-smoothing * delta))

	var cam := get_node_or_null("Camera3D") as Camera3D
	if cam != null:
		cam.look_at(_player.global_position + aim_offset, Vector3.UP)
