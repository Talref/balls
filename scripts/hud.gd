extends CanvasLayer
## Minimal HUD: horizontal speed readout (m/s) plus control hints.

@export var player_path: NodePath

var _player: CharacterBody3D
var _speed_label: Label


func _ready() -> void:
	_player = get_node_or_null(player_path) as CharacterBody3D
	_speed_label = $SpeedLabel


func _process(_delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var hv := Vector3(_player.velocity.x, 0.0, _player.velocity.z)
	_speed_label.text = "SPEED  %5.1f m/s" % hv.length()
