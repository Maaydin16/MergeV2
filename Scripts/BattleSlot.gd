extends Control
class_name BattleSlot

@export var merge_handler: MergeHandler
var current_level: int = 0

func can_drop_data(pos: Vector2, data: Dictionary) -> bool:
	return data is Dictionary and data.has("item")

func drop_data(pos: Vector2, data: Dictionary) -> void:
	var item   = data["item"]   as TextureRect
	var origin = data["origin"] as Control
	merge_handler.handle_drop(self, item, origin)
