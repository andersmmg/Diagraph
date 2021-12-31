tool
extends 'BaseNode.gd'

# ******************************************************************************

onready var TextEdit = $Body/Text/TextEdit

var slot_colors := [
	Color.aqua,
	Color.orangered,
	Color.green,
	Color.yellow,
]

onready var choices = [
	$Choice1,
	$Choice2,
	$Choice3,
	$Choice4,
]

# ******************************************************************************

func _ready():
	Edit.get_popup().connect('index_pressed', self, 'index_pressed')
	
	data['show_choices'] = false
	set_choices_enabled(false)
	Edit.get_popup().set_item_checked(0, false)
	
	data['choices'] = {}
	for c in choices:
		data['choices'][c.name] = {}

	data['entry'] = false

	TextEdit.add_color_region('{', '}', Color.green)
	TextEdit.add_color_region('<', '>', Color.dodgerblue)
	TextEdit.add_color_region('[', ']', Color.yellow)
	TextEdit.add_color_region('(', ')', Color.orange)
	TextEdit.add_color_region('"', '"', Color.red)
	TextEdit.add_color_region('#', '', Color.forestgreen, true)

	set_slot_color_right(1, slot_colors[0])
	set_slot_color_right(2, slot_colors[1])
	set_slot_color_right(3, slot_colors[2])
	set_slot_color_right(4, slot_colors[3])

func index_pressed(index):
	match Edit.get_popup().get_item_text(index):
		'Choices':
			Edit.get_popup().toggle_item_checked(0)
			var state = Edit.get_popup().is_item_checked(0)
			data['show_choices'] = state
			set_choices_enabled(state)
			
		'Entry':
			Edit.get_popup().toggle_item_checked(0)
			var state = Edit.get_popup().is_item_checked(0)
			data['entry'] = state
			prints('entry:', state)

# ******************************************************************************

func get_data():
	var data = .get_data()
	data['text'] = TextEdit.text
	for c in choices:
		data['choices'][c.name] = c.get_data()
	return data

func set_data(new_data):
	if 'text' in new_data:
		TextEdit.text = new_data.text
	if 'entry' in new_data:
		data['entry'] = new_data['entry']
		Edit.get_popup().set_item_checked(1, new_data['entry'])
	if 'show_choices' in new_data:
		var state = new_data['show_choices']
		data['show_choices'] = new_data['show_choices']
		set_choices_enabled(state)
		Edit.get_popup().set_item_checked(0, state)
	if 'choices' in new_data:
		for c in choices:
			c.set_data(new_data['choices'][c.name])
			
	.set_data(new_data)

func parse():
	var result = {
		text = TextEdit.text.split('\n'),
		next = 'none'
	}

	var connections = {}
	for to in data.connections:
		var num = str(data.connections[to][0] + 1)
		connections[num] = to

	if data['show_choices']:
		result.next = 'choice'
		result['choices'] = {}

		for c in choices:
			var d = c.get_data()
			d['next'] = connections[c.name[6]]
			result['choices'][c.name] = d
	else:
		if '1' in connections:
			result.next = connections['1']

	return result

# ******************************************************************************

# func _input(event):
# 	if event is InputEventMouseButton and event.button_index == 2 and event.pressed:
# 		if Rect2(rect_position, rect_size).has_point(event.position):
# 			accept_event()
# 			print('speech ctxmenu')

# ******************************************************************************

func set_choices_enabled(state):
	$Body/Text/ChoiceTitles.visible = state
	$Choice1.visible = state
	$Choice2.visible = state
	$Choice3.visible = state
	$Choice4.visible = state

	set_slot_enabled_right(0, !state)
	set_slot_enabled_right(1, state)
	set_slot_enabled_right(2, state)
	set_slot_enabled_right(3, state)
	set_slot_enabled_right(4, state)


