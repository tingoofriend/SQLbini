## Test fixture: a scene script following ADR-0006's `setup(services)` rule.
## It records whether its dependency was in place when `_ready` ran.
extends Node

var dependency: RefCounted = null
var ready_saw_dependency: bool = false


## Stores the injected dependency; must be called before the node enters the tree.
func setup(p_dependency: RefCounted) -> void:
	dependency = p_dependency


func _ready() -> void:
	ready_saw_dependency = dependency != null
