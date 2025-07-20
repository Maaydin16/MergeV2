# DraggableItem.gd
extends TextureRect

@export var level: int = 1

# Sürüklenen nesnenin gerçekten SpawnBox’tan gelip gelmediğini izler
var is_spawned := false

# Drag-drop için dahili bayraklar
var _dragging := false
var _dropped  := false
var _start_parent: Node
var _start_pos: Vector2

func _ready():
	mouse_filter = MOUSE_FILTER_STOP

func mark_spawned():
	is_spawned = true

func mark_dropped():
	# drop_data içinde çağrılırsa trottle flag’ini koru
	_dropped = true

func _gui_input(event):
	# 1) Mouse button down/up
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not _dragging:
			var local_pos = get_local_mouse_position()
			if Rect2(Vector2.ZERO, size).has_point(local_pos):
				_dragging = true
				_dropped  = false
				_start_parent = get_parent()
				_start_pos    = position
				z_index = 100
				get_viewport().set_input_as_handled()
		elif _dragging and not event.pressed:
			_dragging = false
			z_index   = 0
			_handle_drop(get_global_mouse_position())
			get_viewport().set_input_as_handled()

	# 2) Mouse motion
	elif event is InputEventMouseMotion and _dragging:
		global_position += event.relative
		get_viewport().set_input_as_handled()

func _handle_drop(global_pos: Vector2) -> void:
	var root = get_tree().get_current_scene()
	var dropped = false

	# --- MergeArea slot’ları ---
	if root.has_node("MergeArea/GridContainer"):
		var grid = root.get_node("MergeArea/GridContainer")
		for slot in grid.get_children():
			if slot.get_global_rect().has_point(global_pos):
				slot.drop_data(global_pos, {"item": self})
				dropped = true
				break

	# --- BattleArea slot’ları ---
	if not dropped and root.has_node("BattleArea/HBoxContainer"):
		var hbox = root.get_node("BattleArea/HBoxContainer")
		for slot in hbox.get_children():
			if slot.get_global_rect().has_point(global_pos):
				slot.drop_data(global_pos, {"item": self})
				dropped = true
				break

	# --- Hiçbiri değilse ---
	if not dropped:
		_return_to_spawn()

func _return_to_spawn() -> void:
	# Eğer zaten drop_data’da queue_free olduysa dönme
	if _dropped:
		return
	if get_parent() != _start_parent:
		get_parent().remove_child(self)
		_start_parent.add_child(self)
	position = _start_pos
