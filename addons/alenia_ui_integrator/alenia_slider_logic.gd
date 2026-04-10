# Licensed under Standard Licensing: CC BY 4.0 - Alenia Studios
extends HSlider

func _ready():
	value_changed.connect(_on_val_change)
	_on_val_change(value)
	
	if has_node("HoverAudio"):
		mouse_entered.connect(_on_hover)

func _on_hover():
	var audio = get_node_or_null("HoverAudio")
	if audio: audio.play()

func _on_val_change(v):
	var lbl = get_node_or_null("ValueLabel")
	if lbl:
		lbl.text = str(int(v)) + "%"
