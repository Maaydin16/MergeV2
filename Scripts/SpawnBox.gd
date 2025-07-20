# res://Scripts/SpawnBox.gd
extends Control

@export var item_scene: PackedScene = preload("res://DraggableItem.tscn")
@export var respawn_min := 3.0
@export var respawn_max := 10.0

@onready var container = $ItemContainer
@onready var anim      = $AnimationPlayer
@onready var timer     = $RespawnTimer

var current_item: Control = null

func _ready():
	randomize()
	# Timer’ı bağla
	timer.timeout.connect(Callable(self, "_on_RespawnTimer_timeout"))
	_try_spawn()

func _try_spawn():
	if current_item:
		return
	spawn_item()

func spawn_item():
	# Hataları erken yakala
	if item_scene == null:
		push_error("SpawnBox: item_scene null!")
		return
	if container == null:
		push_error("SpawnBox: $ItemContainer bulunamadı!")
		return
	# Yeni instance
	current_item = item_scene.instantiate() as Control
	container.add_child(current_item)
	current_item.position = Vector2.ZERO
	# Direkt görünür olalım (animasyon kapalı test için)
	current_item.scale    = Vector2.ONE
	current_item.modulate = Color(1,1,1,1)
	# Animasyonla efekt istiyorsan önce yukarıyı Vector2.ZERO, a=0 yap,
	# sonra play("spawn_in") de
	# if anim.has_animation("spawn_in"):
	#     anim.play("spawn_in")
	if current_item.has_method("mark_spawned"):
		current_item.mark_spawned()
	current_item.connect("tree_exited", Callable(self, "_on_item_removed"))

func _on_item_removed():
	current_item = null
	timer.wait_time = randf_range(respawn_min, respawn_max)
	timer.one_shot  = true
	timer.start()

func _on_RespawnTimer_timeout():
	_try_spawn()
