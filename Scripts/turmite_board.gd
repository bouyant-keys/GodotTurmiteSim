extends TextureRect

const BOARD_SIZE := Vector2i(128, 128)

var prev_pos := Vector2i(0, 0)
var position_image : Image

@export var turmite : Turmite

func _ready() -> void:
	turmite.turmite_moved.connect(_on_turmite_moved)
	
	position_image = Image.create_empty(BOARD_SIZE.x, BOARD_SIZE.y, false, Image.FORMAT_RGBAF)
	texture = ImageTexture.create_from_image(position_image)

func _on_turmite_moved(new_pos:Vector2i) ->void:
	position_image.set_pixelv(prev_pos, Color.TRANSPARENT)
	position_image.set_pixelv(new_pos, Color.RED)
	texture = ImageTexture.create_from_image(position_image)
	prev_pos = new_pos
