extends Control

@export var item_scene: PackedScene = preload("res://Scenes/DraggableItem.tscn")

@export var respawn_interval := 3.0

@onready var container = $ItemContainer
@onready var timer     = $RespawnTimer
@onready var anim      = $AnimationPlayer

func _ready():
	randomize()
	timer.wait_time = respawn_interval
	timer.one_shot  = false
	timer.timeout.connect(Callable(self, "spawn_item"))
	timer.start()
	spawn_item()

func spawn_item():
	if container.get_child_count() > 0:
		return

	var new_item = item_scene.instantiate() as TextureRect
	container.add_child(new_item)
	new_item.position = Vector2.ZERO

	if anim and anim.has_animation("spawn_in"):
		anim.play("spawn_in")

	if new_item.has_method("mark_spawned"):
		new_item.mark_spawned()

	new_item.connect("tree_exited", Callable(self, "_on_item_removed"))

func _on_item_removed():
	# container boşaldığında timer döngüsünde next spawn
	pass
