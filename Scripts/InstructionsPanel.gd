extends Control

var validation_message := ""

@onready var instructions_edit: TextEdit = %InstructionsEdit
@onready var main_panel: Panel = $MainPanel
@onready var hidden_panel: Panel = $HiddenPanel

signal instructions_changed(instructions:String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_show_pressed()


func _on_show_pressed() ->void:
	main_panel.show()
	hidden_panel.hide()

func _on_hide_pressed() ->void:
	main_panel.hide()
	hidden_panel.show()

func _on_instructions_set() -> void:
	if validate_syntax(instructions_edit.text):
		instructions_changed.emit(instructions_edit.text)


func validate_syntax(text:String) ->bool:
	if text.begins_with("0") or text.begins_with("1"):
		print("TM format detected.")
	elif text.begins_with("L") or text.begins_with("R"):
		for c in text:
			if c not in ["L", "R"]:
				validation_message = "Propp form may only contain L or R characters."
				return false
		print("Propp format detected.")
	return true
