extends Area2D
class_name Hitbox

signal hit_landed(target: Node, hit: Dictionary, source_id: int)

@export var active: bool = false : set = set_active
@export var hit: Dictionary = {   # <-- IMPORTANT: Dictionary type
	"damage": 10,
	"kb": Vector2(200, -50),
	"hitstun_ms": 150,
	"launch": false
}

var source_id: int = -1

func set_active(v: bool) -> void:
	active = v
	monitoring = v
	set_deferred("monitoring", v)

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(a: Area2D) -> void:
	if not active:
		return
	if a.has_method("on_hit"):
		a.on_hit(hit, source_id)
		emit_signal("hit_landed", a, hit, source_id)
