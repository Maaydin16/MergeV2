extends Control

@export var merged_scene: PackedScene
@export var merge_effect_scene: PackedScene

@onready var monster_tex = $MonsterTexture
@onready var anim        = $AnimationPlayer

var current_level: int = 0

func can_drop_data(pos: Vector2, data: Dictionary) -> bool:
	return data.has("item")

func drop_data(pos: Vector2, data: Dictionary) -> void:
	var item = data["item"]
	item.mark_dropped()

	# self‐drop kontrolü
	if item.get_parent() == self:
		return

	var sb = get_tree().get_current_scene().get_node("SpawnBox")

	# --- PLACE ---
	if current_level == 0:
		current_level = item.level
		_reparent(item)
		if anim.has_animation("pop_in"):
			anim.play("pop_in")
		monster_tex.call_deferred("start_fire")
		if item.is_spawned:
			sb.spawn_item()
		item.is_spawned = false
		return

	# --- MERGE ---
	if current_level == item.level:
		# 1) Eski slot öğesini kaldır
		var old = get_child(0)
		old.queue_free()
		# 2) Sürüklenen öğeyi de kaldır
		item.queue_free()
		# 3) Yeni, bir seviye ilerlemiş canavar yarat
		current_level += 1
		var new_item = merged_scene.instantiate() as Control
		add_child(new_item)
		new_item.position = Vector2.ZERO
		new_item.is_spawned = false
		if anim.has_animation("pop_in"):
			anim.play("pop_in")
		monster_tex.call_deferred("start_fire")
		if item.is_spawned:
			sb.spawn_item()
		return

	# --- SWAP ---
	var old = get_child(0)
	remove_child(old)
	old.queue_free()
	_reparent(item)
	current_level = item.level
	if anim.has_animation("pop_in"):
		anim.play("pop_in")
	monster_tex.call_deferred("start_fire")
	if item.is_spawned:
		sb.spawn_item()
	item.is_spawned = false

func _reparent(item: Control) -> void:
	if item.get_parent() != self:
		item.get_parent().remove_child(item)
		add_child(item)
	item.position = Vector2.ZERO
