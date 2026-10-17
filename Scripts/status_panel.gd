extends Control

const STEPS_FORMAT := "Step: %3d"
const STATUS_FORMAT := "%s"

@onready var status_label: Label = %StatusLabel
@onready var steps_label: Label = %StepsLabel

func _on_status_changed(s:String) ->void:
	status_label.text = STATUS_FORMAT % s

func _on_steps_changed(value:int) ->void:
	steps_label.text = STEPS_FORMAT % value
