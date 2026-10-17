extends Button

@export var preset_instruction : Instruction

signal change_preset(i:Instruction)

func _pressed() -> void:
	change_preset.emit(preset_instruction)
