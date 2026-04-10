# Licensed under Standard Licensing: CC BY 4.0 - Alenia Studios
@tool
extends VBoxContainer

var preview_tex : TextureRect
var label_status : Label
var pending_files : Array = []
var batch_dialog : ConfirmationDialog
var cursor_btn : Button
var last_cursor_path : String = ""

# Recursos Globales Temporales
var temp_fonts : Array = []
var temp_audio_click : String = ""
var temp_audio_hover : String = ""

func _init():
	name = "Alenia Integrator"
	size_flags_horizontal = 3
	size_flags_vertical = 3

func _ready():
	var header = Label.new()
	header.text = "💎 Alenia Smart Assembler 💎\nDrag & Drop UI Folders Here"
	header.horizontal_alignment = 1
	header.custom_minimum_size = Vector2(0, 50)
	add_child(header)
	
	preview_tex = TextureRect.new()
	preview_tex.custom_minimum_size = Vector2(96, 96)
	preview_tex.stretch_mode = 5
	preview_tex.texture_filter = 1
	var default_bg = PlaceholderTexture2D.new()
	default_bg.size = Vector2(96, 96)
	preview_tex.texture = default_bg
	add_child(preview_tex)
	
	label_status = Label.new()
	label_status.text = "Awaiting deployment..."
	label_status.horizontal_alignment = 1
	label_status.modulate = Color(0.5, 0.5, 0.5)
	add_child(label_status)
	
	cursor_btn = Button.new()
	cursor_btn.text = "Set as Project Cursor"
	cursor_btn.visible = false
	cursor_btn.pressed.connect(_on_set_cursor)
	add_child(cursor_btn)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = 3
	add_child(spacer)
	
	var fix_btn = Button.new()
	fix_btn.text = "🛠 Fix Selected Nodes (Pixel Art)"
	add_child(fix_btn)
	fix_btn.pressed.connect(_on_fix_pressed)

	var guide_container = VBoxContainer.new()
	guide_container.add_theme_constant_override("separation", 5)
	add_child(guide_container)
	
	var guide_label = Label.new()
	guide_label.text = "📜 Quick Naming Guide:"
	guide_label.horizontal_alignment = 1
	guide_label.modulate = Color(0.7, 0.7, 1.0) # Tono púrpura Alenia
	guide_container.add_child(guide_label)
	
	var rules = Label.new()
	rules.text = "• btn_name_state_16px\n• slider_name_part_16px\n• cursor_name\n• panel_name_32px"
	rules.horizontal_alignment = 1
	rules.modulate = Color(0.8, 0.8, 0.8)
	guide_container.add_child(rules)
	
	var github_btn = Button.new()
	github_btn.text = "🌐 View Full Documentation"
	github_btn.pressed.connect(func(): OS.shell_open("https://github.com/Kaia-Alenia/alenia-ui-integrator"))
	add_child(github_btn)

	batch_dialog = ConfirmationDialog.new()
	batch_dialog.dialog_text = "Multiple Logic Assets Detected.\nWrap assembled components in a VBoxContainer?"
	add_child(batch_dialog)
	batch_dialog.confirmed.connect(_on_batch_confirmed)
	batch_dialog.canceled.connect(_on_batch_canceled)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "files":
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant):
	pending_files.clear()
	temp_fonts.clear()
	temp_audio_click = ""
	temp_audio_hover = ""
	
	for f in data["files"]:
		var filepath = str(f)
		var l_file = filepath.to_lower()
		var basename = filepath.get_file()
		
		if l_file.ends_with(".png"):
			pending_files.append(filepath)
		elif l_file.ends_with(".ttf") or l_file.ends_with(".otf"):
			temp_fonts.append(filepath)
		elif l_file.ends_with(".wav") or l_file.ends_with(".ogg"):
			if "click" in l_file: temp_audio_click = filepath
			elif "hover" in l_file: temp_audio_hover = filepath
			
	if pending_files.size() > 1:
		batch_dialog.popup_centered()
	elif pending_files.size() == 1:
		_process_files(false)

func _on_batch_confirmed():
	_process_files(true)

func _on_batch_canceled():
	_process_files(false)

func _on_set_cursor():
	if last_cursor_path != "":
		# Modificamos el Setting nativo global
		ProjectSettings.set_setting("display/mouse_cursor/custom_image", last_cursor_path)
		ProjectSettings.save()
		# Forzamos runtime hook en este instante
		Input.set_custom_mouse_cursor(load(last_cursor_path))
		_show_status("Project Cursor Hijacked!", Color(1.0, 0.8, 0.0))

func _process_files(wrap_in_container: bool):
	if pending_files.is_empty(): return
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		_show_status("No active scene! Open one.", Color(1.0, 0.0, 0.0))
		return
		
	var parent_node = root
	var editor_selection = EditorInterface.get_selection().get_selected_nodes()
	if editor_selection.size() > 0:
		parent_node = editor_selection[0]

	var wrapper = null
	if wrap_in_container:
		wrapper = VBoxContainer.new()
		wrapper.name = "Alenia_Grid"
		wrapper.set_anchors_and_offsets_preset(15)
		parent_node.add_child(wrapper)
		wrapper.owner = root
		parent_node = wrapper
		
	var groups = {}
	for filepath in pending_files:
		var basename = filepath.get_file().get_basename().to_lower()
		var parts = basename.split("_")
		var tipo = parts[0]
		
		var group_name = basename
		var state = ""
		var margin_val = 32
		
		for p in parts:
			var p_stripped = p.replace("px", "")
			if p_stripped.is_valid_int() and p_stripped != "96":
				margin_val = p_stripped.to_int()
				
		if tipo == "btn" or tipo == "button":
			var nombre = parts[1] if parts.size() > 1 else "generic"
			group_name = "btn_" + nombre
			state = "normal"
			if "hover" in basename: state = "hover"
			elif "pressed" in basename: state = "pressed"
			elif "disabled" in basename: state = "disabled"
		elif tipo == "slider":
			var nombre = parts[1] if parts.size() > 1 else "generic"
			group_name = "slider_" + nombre
			state = "track" # fallback
			if "progress" in basename or "fill" in basename: state = "progress"
			elif "grabber" in basename or "knob" in basename: state = "grabber"
		elif tipo == "cursor" or tipo == "pointer":
			var nombre = parts[1] if parts.size() > 1 else "generic"
			group_name = "cursor_" + nombre
		else:
			var nombre = parts[1] if parts.size() > 1 else "generic"
			group_name = tipo + "_" + nombre

		if not groups.has(group_name):
			groups[group_name] = {"tipo": tipo, "recursos": {}, "margin": 32}
			
		groups[group_name]["recursos"][state] = filepath
		groups[group_name]["margin"] = margin_val

	cursor_btn.visible = false
	var last_file = ""
	
	for gname in groups.keys():
		var data = groups[gname]
		var parsed_node = _build_assembled_node(gname, data, root)
		if parsed_node:
			parent_node.add_child(parsed_node)
			parsed_node.owner = root
			
			for child in parsed_node.get_children():
				child.owner = root
				
			var rvals = data["recursos"].values()
			if rvals.size() > 0: last_file = rvals[0]
			
	if last_file != "":
		preview_tex.texture = load(last_file)
		_show_status("Success! Packed UI.", Color(0.0, 1.0, 0.0))

func _show_status(msg: String, c: Color):
	label_status.text = msg
	label_status.modulate = c

func _build_assembled_node(group_name: String, data: Dictionary, root: Node) -> Control:
	var tipo = data["tipo"]
	var recs = data["recursos"]
	var margin_val = data["margin"]
	
	if tipo == "cursor" or tipo == "pointer":
		if not recs.has(""): return null
		var crect = TextureRect.new()
		crect.name = group_name.capitalize()
		crect.texture = load(recs[""])
		crect.texture_filter = 1
		crect.stretch_mode = 5
		
		# Guardar para el setup global
		last_cursor_path = recs[""]
		cursor_btn.visible = true
		
		return crect

	var container = MarginContainer.new()
	container.set_anchors_and_offsets_preset(15)
	container.name = "Marg_" + group_name.capitalize()
	
	if tipo == "btn" or tipo == "button":
		var btn = Button.new()
		btn.name = group_name.capitalize()
		btn.size_flags_horizontal = 3
		btn.size_flags_vertical = 3
		btn.texture_filter = 1
		
		# TIPOGRAFIA Y ALINEACION "Pixel-Perfect"
		btn.text = group_name.replace("btn_", "").capitalize()
		btn.alignment = 1 # HORIZONTAL_ALIGNMENT_CENTER
		btn.clip_text = true
		
		if temp_fonts.size() > 0:
			btn.add_theme_font_override("font", load(temp_fonts[0]))
			btn.add_theme_font_size_override("font_size", 16)
		
		var add_audio_logic = false
		if temp_audio_hover != "":
			var ah = AudioStreamPlayer.new()
			ah.name = "HoverAudio"
			ah.stream = load(temp_audio_hover)
			btn.add_child(ah)
			add_audio_logic = true
		if temp_audio_click != "":
			var ac = AudioStreamPlayer.new()
			ac.name = "ClickAudio"
			ac.stream = load(temp_audio_click)
			btn.add_child(ac)
			add_audio_logic = true
			
		if add_audio_logic:
			btn.set_script(load("res://addons/alenia_ui_integrator/alenia_button_logic.gd"))
		
		for state in ["normal", "hover", "pressed", "disabled"]:
			if recs.has(state):
				var sb = StyleBoxTexture.new()
				sb.texture = load(recs[state])
				sb.texture_margin_left = margin_val
				sb.texture_margin_right = margin_val
				sb.texture_margin_top = margin_val
				sb.texture_margin_bottom = margin_val
				btn.add_theme_stylebox_override(state, sb)
		
		container.add_child(btn)
		
	elif tipo == "slider":
		var slider = HSlider.new()
		slider.name = group_name.capitalize()
		slider.size_flags_horizontal = 3
		slider.size_flags_vertical = 3
		slider.texture_filter = 1
		
		# LABEL DINAMICO (Porcentaje)
		var lbl = Label.new()
		lbl.name = "ValueLabel"
		lbl.text = "50%"
		lbl.horizontal_alignment = 1
		lbl.set_anchors_and_offsets_preset(15)
		if temp_fonts.size() > 0:
			lbl.add_theme_font_override("font", load(temp_fonts[0]))
		slider.add_child(lbl)
		
		var add_audio_logic = false
		if temp_audio_hover != "":
			var ah = AudioStreamPlayer.new()
			ah.name = "HoverAudio"
			ah.stream = load(temp_audio_hover)
			slider.add_child(ah)
			add_audio_logic = true
			
		# Enlaza la logica al vuelo
		slider.set_script(load("res://addons/alenia_ui_integrator/alenia_slider_logic.gd"))
		
		if recs.has("track"):
			var sb = StyleBoxTexture.new()
			sb.texture = load(recs["track"])
			sb.texture_margin_left = margin_val
			sb.texture_margin_right = margin_val
			sb.texture_margin_top = margin_val
			sb.texture_margin_bottom = margin_val
			slider.add_theme_stylebox_override("slider", sb)
		if recs.has("progress"):
			var sb = StyleBoxTexture.new()
			sb.texture = load(recs["progress"])
			sb.texture_margin_left = margin_val
			sb.texture_margin_right = margin_val
			sb.texture_margin_top = margin_val
			sb.texture_margin_bottom = margin_val
			slider.add_theme_stylebox_override("grabber_area", sb)
			slider.add_theme_stylebox_override("grabber_area_highlight", sb)
		if recs.has("grabber"):
			var t_grab = load(recs["grabber"])
			slider.add_theme_icon_override("grabber", t_grab)
			slider.add_theme_icon_override("grabber_highlight", t_grab)
			
		container.add_child(slider)
		
	else:
		var img_path = recs.values()[0] if recs.size() > 0 else ""
		if img_path != "":
			var n9 = NinePatchRect.new()
			n9.name = group_name.capitalize()
			n9.texture = load(img_path)
			n9.texture_filter = 1
			n9.patch_margin_left = margin_val
			n9.patch_margin_right = margin_val
			n9.patch_margin_top = margin_val
			n9.patch_margin_bottom = margin_val
			container.add_child(n9)

	return container

func _on_fix_pressed():
	var nodes = EditorInterface.get_selection().get_selected_nodes()
	var fixed = 0
	
	var stack = nodes.duplicate()
	while not stack.is_empty():
		var n = stack.pop_back()
		if n is TextureRect or n is NinePatchRect or n is Sprite2D:
			n.texture_filter = 1
			fixed += 1
		if n is Control:
			n.set_anchors_and_offsets_preset(15)
			fixed += 1
			
		for c in n.get_children():
			stack.append(c)
	
	if fixed > 0:
		_show_status(str(fixed) + " Nodes Anchored & Fixed!", Color(0.5, 1.0, 0.8))
	else:
		_show_status("Select UI objects in Tree first.", Color(1.0, 0.5, 0.0))