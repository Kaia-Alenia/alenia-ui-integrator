@tool
extends VBoxContainer

var preview_tex : TextureRect
var label_status : Label
var pending_files : Array = []
var batch_dialog : ConfirmationDialog

func _init():
	name = "Alenia Integrator"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

func _ready():
	var header = Label.new()
	header.text = "💎 Alenia Smart Integrator 💎\nDrag & Drop UI PNGs Here"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.custom_minimum_size = Vector2(0, 50)
	add_child(header)
	
	preview_tex = TextureRect.new()
	preview_tex.custom_minimum_size = Vector2(96, 96)
	preview_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var default_bg = PlaceholderTexture2D.new()
	default_bg.size = Vector2(96, 96)
	preview_tex.texture = default_bg
	add_child(preview_tex)
	
	label_status = Label.new()
	label_status.text = "Awaiting deployment..."
	label_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_status.modulate = Color.GRAY
	add_child(label_status)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(spacer)
	
	var fix_btn = Button.new()
	fix_btn.text = "🛠 Fix Selected Nodes (Pixel Art)"
	add_child(fix_btn)
	fix_btn.pressed.connect(_on_fix_pressed)

	batch_dialog = ConfirmationDialog.new()
	batch_dialog.dialog_text = "Multiple logic assets detected.\nWrap them mathematically in a single VBoxContainer?"
	add_child(batch_dialog)
	batch_dialog.confirmed.connect(_on_batch_confirmed)
	batch_dialog.canceled.connect(_on_batch_canceled)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "files":
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant):
	pending_files.clear()
	for f in data["files"]:
		if str(f).ends_with(".png"):
			pending_files.append(str(f))
			
	if pending_files.size() > 1:
		batch_dialog.popup_centered()
	elif pending_files.size() == 1:
		_process_files(false)

func _on_batch_confirmed():
	_process_files(true)

func _on_batch_canceled():
	_process_files(false)

func _process_files(wrap_in_container: bool):
	if pending_files.is_empty(): return
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		_show_status("No active scene! Open one.", Color.RED)
		return
		
	var parent_node = root
	var editor_selection = EditorInterface.get_selection().get_selected_nodes()
	if editor_selection.size() > 0:
		parent_node = editor_selection[0]

	var wrapper = null
	if wrap_in_container:
		wrapper = VBoxContainer.new()
		wrapper.name = "Alenia_Grid"
		wrapper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		parent_node.add_child(wrapper)
		wrapper.owner = root
		parent_node = wrapper
		
	var last_file = ""
	for file in pending_files:
		var parsed_node = _build_alenia_node(file, root)
		if parsed_node:
			parent_node.add_child(parsed_node)
			parsed_node.owner = root
			
			for child in parsed_node.get_children():
				child.owner = root
				
			last_file = file
			
	if last_file != "":
		preview_tex.texture = load(last_file)
		_show_status("Success! Packed UI.", Color.GREEN)

func _show_status(msg: String, c: Color):
	label_status.text = msg
	label_status.modulate = c

func _build_alenia_node(filepath: String, root: Node) -> Control:
	var tex = load(filepath)
	if not tex: return null
	
	var basename = filepath.get_file().get_basename()
	var is_btn = basename.find("btn") != -1 or basename.find("button") != -1
	
	var margin_val = 32
	var parts = basename.split("_")
	for p in parts:
		var p_stripped = p.replace("px", "")
		if p_stripped.is_valid_int() and p_stripped != "96": 
			margin_val = p_stripped.to_int()

	var container = MarginContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.name = basename.replace("_9slice", "").replace("_96px", "")
	
	if is_btn:
		var btn = Button.new()
		btn.name = "Interactive"
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		var sb = StyleBoxTexture.new()
		sb.texture = tex
		sb.texture_margin_left = margin_val
		sb.texture_margin_right = margin_val
		sb.texture_margin_top = margin_val
		sb.texture_margin_bottom = margin_val
		sb.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)
		container.add_child(btn)
	else:
		var n9 = NinePatchRect.new()
		n9.name = "Background"
		n9.texture = tex
		n9.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
			n.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			fixed += 1
		if n is Control:
			n.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			fixed += 1
			
		for c in n.get_children():
			stack.append(c)
	
	if fixed > 0:
		_show_status(str(fixed) + " Nodes Anchored & Fixed!", Color.AQUAMARINE)
	else:
		_show_status("Select UI objects in Tree first.", Color.ORANGE)
