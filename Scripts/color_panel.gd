extends Control

@export var turmite:Turmite
@export var board : TextureRect

@onready var color_container: VBoxContainer = %ColorContainer
@onready var main_panel: Panel = $MainPanel
@onready var hidden_panel: Panel = $HiddenPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func instructions_changed(instruction:Instruction) ->void:
	for child in color_container.get_children():
		child.queue_free()
	
	for color : Color in instruction.state_colors:
		var palette := PalettePicker.new()
		color_container.add_child(palette)
		palette.color = color
		palette.palette_color_changed.connect(update_palette)

func update_palette(index:int, color:Color) ->void:
	turmite.current_turmite_instructions.state_colors[index] = color
	# Update board colors??
	#board_image = Image.create_empty(board_size.x, board_size.y, false, Image.FORMAT_RGBAF)
	#board_image.fill(Color.WHITE)
	#board.texture = ImageTexture.create_from_image(board_image)


func _on_show_button_pressed() -> void:
	main_panel.show()
	hidden_panel.hide()

func _on_hide_button_pressed() -> void:
	main_panel.hide()
	hidden_panel.show()
