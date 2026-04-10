@tool
extends EditorPlugin

var dock_instance: Control

func _enter_tree():
	dock_instance = preload("res://addons/alenia_ui_integrator/alenia_dock.gd").new()
	if !dock_instance: return
	
	dock_instance.name = "Alenia UI"
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock_instance)

func _exit_tree():
	if dock_instance:
		remove_control_from_dock(dock_instance)
		dock_instance.queue_free()
