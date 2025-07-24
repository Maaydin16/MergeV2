extends Control
class_name MergeSlot

# Inspector’dan aşağıya sürükleyeceksin:
@export var merge_handler: MergeHandler

# Şu anki seviye (0 = boş)
var current_level: int = 0

func can_drop_data(pos: Vector2, data: Dictionary) -> bool:
	# data içinde "item" anahtarı varsa drop_data çağrılır
	return data is Dictionary and data.has("item")

func drop_data(pos: Vector2, data: Dictionary) -> void:
	var item   = data["item"]   as TextureRect
	var origin = data["origin"] as Control  # Spawn’dan geliyorsa null
	merge_handler.handle_drop(self, item, origin)
