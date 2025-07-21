extends Control

@export var merged_scene: PackedScene = preload("res://DraggableItem.tscn")
var current_level: int = 0

func can_drop_data(pos: Vector2, data: Dictionary) -> bool:
	return data.has("item")

func drop_data(pos: Vector2, data: Dictionary) -> void:
	var item = data["item"] as TextureRect
	var source_slot: Control = (data["origin"] as Control) if data.has("origin") else null
	var sb = get_tree().get_current_scene().get_node("SpawnBox")
	var from_spawn = source_slot == null

	# PLACE
	if current_level == 0:
		current_level = item.level
		_reparent(item)
		if from_spawn or item.is_spawned:
			sb.spawn_item()
		return

	# MERGE
	if current_level == item.level:
		if get_child_count() > 0:
			get_child(0).queue_free()
		item.queue_free()
		current_level += 1
		var merged = merged_scene.instantiate() as TextureRect
		add_child(merged)
		merged.position   = Vector2.ZERO
		merged.is_spawned = false
		if from_spawn or item.is_spawned:
			sb.spawn_item()
		if source_slot:
			source_slot.clear_slot()
		return

	# MISMATCH
	if from_spawn or item.is_spawned:
		item.queue_free()
		sb.spawn_item()
		return

	# SWAP
	if get_child_count() > 0:
		var old = get_child(0)
		remove_child(old)
		_reparent(item)
		if source_slot:
			source_slot.add_child(old)
			old.position = Vector2.ZERO
		current_level = item.level

func _reparent(item: TextureRect) -> void:
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	add_child(item)
	item.position = Vector2.ZERO

func clear_slot():
	for c in get_children():
		c.queue_free()
	current_level = 0
