extends Control

const FORMAT_LABEL := "Format: <L/R>,<L/R>,<L/R>,..."

var current_instruction : Instruction

@export var turmite : Turmite
@export var gradient_tex: GradientTexture1D

@onready var edit_box: TextEdit = %InstructionsEdit
@onready var main_panel: Control = $MainPanel
@onready var hidden_panel: Control = $HiddenPanel
@onready var format_label: Label = %FormatLabel
@onready var error_icon: TextureRect = %ErrorIcon

signal instructions_changed(instruction:Instruction)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	error_icon.hide()
	edit_box.text = turmite.current_turmite_instructions.to_string()
	_on_hide_pressed()


func _on_show_pressed() ->void:
	main_panel.show()
	hidden_panel.hide()

func _on_hide_pressed() ->void:
	main_panel.hide()
	hidden_panel.show()

func _on_instructions_set() -> void:
	print("instructions set.")
	# Assuming type is ant by default
	var instruction = Instruction.new()
	instruction.type = Instruction.InstructionType.ANT
	instruction.transitions = edit_box.text.split(",")
	
	if !instruction.is_valid():
		format_label.text = instruction.invalid_message
		error_icon.show()
		return
	format_label.text = FORMAT_LABEL
	error_icon.hide()
	
	instruction.state_colors.clear()
	for i : int in instruction.transitions.size():
		var temp := i / float(instruction.transitions.size()-1.0)
		var color := gradient_tex.gradient.sample(temp)
		print(temp, color)
		instruction.state_colors.append(color)
	print(instruction.transitions)
	
	current_instruction = instruction

func _on_preset_changed(i:Instruction) ->void:
	edit_box.text = i.to_string()
	instructions_changed.emit(i)
	_on_hide_pressed()

func _on_run_pressed() -> void:
	if !current_instruction: return
	elif !current_instruction.is_valid(): return
	
	instructions_changed.emit(current_instruction)
	_on_hide_pressed()
