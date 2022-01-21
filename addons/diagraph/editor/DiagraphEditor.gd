tool
extends Control

# ******************************************************************************

onready var GraphEdit: GraphEdit = find_node('GraphEdit')
onready var Toolbar = $Toolbar
onready var DialogBox = $Preview/DialogBox

var is_plugin = false

# ******************************************************************************

func _ready():
	$Toolbar/New.connect('pressed', self, 'create_conversation')
	$Toolbar/Clear.connect('pressed', $ConfirmClear, 'popup')
	$ConfirmClear.connect('confirmed', GraphEdit, 'clear')
	$Toolbar/Save.connect('pressed', self, 'save_data')
	$Toolbar/Run.connect('pressed', self, 'run')
	$Preview/Stop.connect('pressed', self, 'stop')
	$Preview/Debug.connect('toggled', $Preview/DialogBox/DebugLog, 'set_visible')
	DialogBox.connect('done', self, 'stop')

	$Preview/DialogBox.show()
	$Preview/Stop.show()
	$Preview/Debug.show()
	$Preview/Dimmer.show()
	$Preview.hide()

	if !Engine.editor_hint or is_plugin:
		load_data()

		remove_child(Toolbar)
		GraphEdit.get_zoom_hbox().add_child(Toolbar)

func create_conversation():
	$FileDialog.popup()

# ******************************************************************************

func run():
	var selection = GraphEdit.get_selected_nodes()
	if selection.size() == 1:
		var node = selection[0]
		if 'entry' in node.data and node.data.entry:
			$Preview.show()
			DialogBox.start(GraphEdit.nodes, node.name)
	
func stop():
	$Preview.hide()

# ******************************************************************************

var file_name = 'res://data.json'

func save_data():
	var data = {
		scroll_offset = var2str(GraphEdit.scroll_offset),
		height = GraphEdit.rect_size.y,
		zoom = GraphEdit.zoom,
		minimap_enabled = GraphEdit.minimap_enabled,
		minimap_opacity = GraphEdit.minimap_opacity,
		minimap_size = var2str(GraphEdit.minimap_size),
		snap = {
			on = GraphEdit.use_snap,
			step = GraphEdit.snap_distance,
		},
		nodes = {},
	}
	for node in GraphEdit.nodes.values():
		data.nodes[str(node.data.id)] = node.get_data()

	
	var f = File.new()
	f.open('test.txt', File.WRITE)
	f.store_string(var2str(data))
	f.close()

	save_json(data)

func load_data():
	var data = load_json()
	if data:
		for id in data.nodes:
			GraphEdit.create_node(data.nodes[id])
		for node in GraphEdit.nodes.values():
			for to in node.data.connections:
				var con = node.data.connections[to]
				GraphEdit.request_connection(node.name, con[0], to, con[1])
		if 'height' in data:
			GraphEdit.rect_size.y = data.height
		if 'scroll_offset' in data:
			GraphEdit.scroll_offset = str2var(data.scroll_offset)
		if 'minimap_enabled' in data:
			GraphEdit.minimap_enabled = data.minimap_enabled
		if 'minimap_opacity' in data:
			GraphEdit.minimap_opacity = data.minimap_opacity
		if 'minimap_size' in data:
			GraphEdit.minimap_size = str2var(data.minimap_size)
		if 'zoom' in data:
			GraphEdit.zoom = data.zoom
		if 'snap' in data:
			GraphEdit.use_snap = data.snap.on
			GraphEdit.snap_distance = data.snap.step

# ******************************************************************************

func save_json(data):
	var f = File.new()
	f.open(file_name, File.WRITE)
	f.store_string(JSON.print(data, "\t"))
	f.close()

func load_json():
	var result = null
	var f = File.new()
	if f.file_exists(file_name):
		f.open(file_name, File.READ)
		var text = f.get_as_text()
		f.close()
		result = JSON.parse(text).result
	return result
