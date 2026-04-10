# Licensed under Standard Licensing: CC BY 4.0 - Alenia Studios
extends Button

func _ready():
	if has_node("HoverAudio"):
		mouse_entered.connect(_on_hover)
	if has_node("ClickAudio"):
		pressed.connect(_on_press)

func _on_hover():
	var audio = get_node_or_null("HoverAudio")
	if audio: audio.play()

func _on_press():
	var audio = get_node_or_null("ClickAudio")
	if audio: audio.play()
