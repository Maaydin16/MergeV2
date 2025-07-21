extends TextureRect

@export var level: int = 1

var is_spawned := false
var _dragging := false
var _dropped  := false
var _start_parent: Control = null
var _start_pos: Vector2

func _ready():
	mouse_filter = MOUSE_FILTER_STOP

func mark_spawned():
	is_spawned = true
	_dropped   = false

func mark_dropped():
	_dropped = true

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not _dragging:
			var lp = get_local_mouse_position()
			if Rect2(Vector2.ZERO, size).has_point(lp):
				_dragging  = true
				_dropped   = false
				_start_pos = position
				z_index    = 100
				# En yakın slot ancestor’unu bul
				var p = get_parent()
				while p and not p.has_method("drop_data"):
					p = p.get_parent()
				_start_parent = p as Control  # MergeSlot/BattleSlot ya da null
				print("[DraggableItem] drag start, origin:", _start_parent)
				get_viewport().set_input_as_handled()
		elif _dragging and not event.pressed:
			_dragging = false
			z_index   = 0
			_handle_drop(get_global_mouse_position())
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and _dragging:
		global_position += event.relative
		get_viewport().set_input_as_handled()

func _handle_drop(global_pos: Vector2) -> void:
	print("[DraggableItem] _handle_drop at", global_pos, "origin:", _start_parent)
	var root = get_tree().get_current_scene()
	var dropped = false

	# MergeArea
	if root.has_node("MergeArea/GridContainer"):
		for slot in root.get_node("MergeArea/GridContainer").get_children():
			if slot.get_global_rect().has_point(global_pos):
				mark_dropped()
				print("[DraggableItem] dropping on MergeSlot:", slot.name)
				slot.drop_data(global_pos, {"item": self, "origin": _start_parent})
				dropped = true
				break

	# BattleArea
	if not dropped and root.has_node("BattleArea/HBoxContainer"):
		for slot in root.get_node("BattleArea/HBoxContainer").get_children():
			if slot.get_global_rect().has_point(global_pos):
				mark_dropped()
				print("[DraggableItem] dropping on BattleSlot:", slot.name)
				slot.drop_data(global_pos, {"item": self, "origin": _start_parent})
				dropped = true
				break

	if not dropped:
		_return_to_spawn()

func _return_to_spawn() -> void:
	if _dropped or _start_parent == null:
		return
	if get_parent() != _start_parent:
		get_parent().remove_child(self)
		_start_parent.add_child(self)
	position = _start_pos
