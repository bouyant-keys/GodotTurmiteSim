extends Control

const LABEL_FORMAT := "Speed: x%.2f"

var paused := false
var previous_speed : float

@onready var speed_slider : HSlider = %SpeedSlider
@onready var speed_label : Label = %SpeedLabel
@onready var pause_button : TextureButton = %PauseButton
@onready var reset_button : TextureButton = %ResetButton

signal reset_turmite
signal pause_turmite(paused:bool)
signal speed_changed(value:float)

func _ready() -> void:
	await speed_slider.ready
	set_speed.call_deferred(speed_slider.value)
	set_process(false)

func _process(_delta: float) -> void:
	if 1.0 - speed_slider.value == previous_speed:
		return
	
	set_speed(speed_slider.value)


func set_speed(speed:float) ->void:
	var new_speed := 1.0 - speed
	speed_label.text = LABEL_FORMAT % speed
	speed_changed.emit(new_speed)
	previous_speed = new_speed


func _on_drag_started() -> void:
	set_process(true)

func _on_drag_ended(_value_changed: bool) -> void:
	set_process(false)

func _on_pause_button_pressed() -> void:
	paused = !paused
	pause_turmite.emit(paused)

func _on_reset_button_pressed() -> void:
	reset_turmite.emit()
