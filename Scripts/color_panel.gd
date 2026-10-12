extends Control

@onready var color_container: VBoxContainer = %ColorContainer
@onready var main_panel: Panel = $MainPanel
@onready var hidden_panel: Panel = $HiddenPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func states_changed(num_states:int) ->void:
	for child in color_container.get_children():
		child.queue_free()
	
	for i in range(num_states):
		var color := ColorPickerButton.new()
		color_container.add_child(color)


func _on_show_button_pressed() -> void:
	main_panel.show()
	hidden_panel.hide()

func _on_hide_button_pressed() -> void:
	main_panel.hide()
	hidden_panel.show()
