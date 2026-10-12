extends HSlider

const LABEL_FORMAT := "Speed: x%.2f"

var previous_speed : float

@onready var speed_label: Label = $SpeedLabel

signal speed_changed(value:float)

func _ready() -> void:
	set_speed.call_deferred(value)
	set_process(false)

func _process(_delta: float) -> void:
	if value == previous_speed:
		return
	
	set_speed(value)


func set_speed(speed:float) ->void:
	speed_label.text = LABEL_FORMAT % speed
	speed_changed.emit(speed)
	previous_speed = speed


func _on_drag_started() -> void:
	set_process(true)

func _on_drag_ended(_value_changed: bool) -> void:
	set_process(false)
