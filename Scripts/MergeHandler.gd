# res://Scripts/MergeHandler.gd
extends Node
class_name MergeHandler

# Path to the SpawnBox node in the scene tree (set this in Inspector)
@export var respawn_box_path: NodePath
# The PackedScene to instantiate when two items merge
@export var merged_scene: PackedScene

func handle_drop(target_slot: Control, item: TextureRect, origin_slot: Control) -> void:
	var sb = get_node(respawn_box_path)
	var from_spawn = item.is_spawned

	# 1) PLACE: hedef boşsa
	if target_slot.current_level == 0:
		target_slot.current_level = item.level
		_reparent(item, target_slot)
		if from_spawn:
			sb.spawn_item()
		return

	# 2) MERGE: aynı seviye iki öğe
	if target_slot.current_level == item.level:
		# Hedef slot’u temizle
		_clear_slot(target_slot)
		# Sürüklenen öğeyi kaldır
		item.queue_free()
		# Yeni ölçeğe yükselt
		target_slot.current_level += 1
		var merged = merged_scene.instantiate() as TextureRect
		target_slot.add_child(merged)
		merged.position   = Vector2.ZERO
		merged.is_spawned = false
		# Spawn’dan geldiyse yenisini üret
		if from_spawn:
			sb.spawn_item()
		# Kaynak slot’u da temizle
		_clear_slot(origin_slot)
		return

	# 3) MISMATCH: spawn’dan gelen ama seviyeler farklısa geri gönder
	if from_spawn:
		item.queue_free()
		sb.spawn_item()
		return

	# 4) SWAP: seviyeler farklı ve kullanıcı swap istiyor
	_swap(item, origin_slot, target_slot)


# —— Yardımcı Fonksiyonlar —— #

func _reparent(item: TextureRect, slot: Control) -> void:
	if item.get_parent():
		item.get_parent().remove_child(item)
	slot.add_child(item)
	item.position = Vector2.ZERO

func _clear_slot(slot: Control) -> void:
	if slot == null:
		return
	for c in slot.get_children():
		c.queue_free()
	slot.current_level = 0

func _swap(item: TextureRect, origin: Control, target: Control) -> void:
	# Hedefteki eski öğeyi al
	var old = target.get_child(0) as TextureRect
	target.remove_child(old)
	# Sürüklenen öğeyi hedefe ekle
	_reparent(item, target)
	target.current_level = item.level
	# Eski öğeyi orijinal slot’a geri koy
	if origin:
		_reparent(old, origin)
		origin.current_level = old.level
