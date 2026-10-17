class_name PalettePicker extends ColorPickerButton

var palette_index := -1

signal palette_color_changed(index:int, color:Color)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_changed.connect(_on_color_changed)

func _on_color_changed(c:Color) ->void:
	palette_color_changed.emit(palette_index, c)
