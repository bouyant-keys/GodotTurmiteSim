extends Node

#(q0, 0) -> (q0, 1, R), (q0, 1) -> (q0, 0, R)

const DEF_INSTRUCTIONS := "10w010r0E0010k010w0E"
const ANT_INSTRUCTIONS := "10w010k0C0010k010w0X"
const PROPP_ANT := "LR" # state 0 turns L, state 1 turns R, state becomes i + 1 mod n.
const PROPP_ANT_9 := "LRRL"
const PROPP_ANT_12 := "LLRR"
const COLORS := {"k":Color.BLACK, "w":Color.WHITE, "r":Color.RED, "b":Color.BLUE, "g":Color.GREEN}
const DEF_COLOR := Color.WHITE
const DIRECTIONS = {"W":Vector2i(-1.0, 0.0), "E":Vector2i(1.0, 0.0), "N":Vector2i(0.0, -1.0), "S":Vector2i(0.0, 1.0)}
const DEF_STEP_TIME := 0.2

## Machine head position.
var head : Vector2i
## List of machine instructions as an Array of each transition.
var instructions : PackedStringArray
## Dictionary to look up the index of a given state's transitions in instructions.
var state_lookup : Dictionary
## The Turmite's current state.
var state : int = 1
## Previously chosen move direction, used for rotation-based moving (Langton's Ant)
var prev_direction := Vector2i(-1, 0)
## Total steps processed by the Turmite.
var step_count := 0
## Time taken by Turmite to perform each step.
var step_time := DEF_STEP_TIME
## Image read & written to by the Turmite, representing the board.
var board_image : Image

## Instructions follow 'LRLR' format instead of '00010k01...'
var propp_format := false

@export var board : TextureRect

@export var board_size := Vector2i(128, 128)
@export var state_colors : Array[Color]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_image = Image.create_empty(board_size.x, board_size.y, false, Image.FORMAT_RGBAF)
	board_image.fill(Color.WHITE)
	
	head = board_size / 2.0
	state = 1
	set_instructions(PROPP_ANT_9)
	_step()

func _step() ->void:
	print("Step: ", step_count)
	read()
	await get_tree().create_timer(step_time).timeout
	step_count += 1
	_step()

func read() ->void:
	var head_color : Color = board.texture.get_image().get_pixelv(head)
	
	if propp_format:
		for idx : int in state_colors.size():
			print("head: ", head_color, ", state ", idx, " color: ", state_colors[idx])
			if head_color.is_equal_approx(state_colors[idx]):
				state = idx
				print("found")
				break
		print("State: ", state)
		write(state_colors[posmod(state+1, instructions.size())])
		move(instructions[state])
		return
	
	var state_transitions := state_lookup.get(state, []) as Array
	#print("State: ", state, ", State Transitions: ", state_transitions)
	for index in state_transitions:
		var rule := instructions[index]
		var elements := rule.split("0") # format: ["1", "k", "1", "w", "R"]
		var read_color : Color = COLORS[elements[1]]
		if !read_color.is_equal_approx(head_color):
			continue
		else:
			#print("Matched Rule: ", rule, " - read_color: ", read_color)
			state = elements[2].to_int()
			write(COLORS.get(elements[3], DEF_COLOR))
			move(elements[4])
			break

func write(c:Color) ->void:
	print("wrote color: ", c)
	board_image.set_pixelv(head, c)
	board.texture = ImageTexture.create_from_image(board_image)


func move(d:String) ->void:
	var move_dir : Vector2i
	if d in DIRECTIONS:
		move_dir = DIRECTIONS.get(d, Vector2.ZERO)
	elif d == "C" or d == "R":
		move_dir = Vector2i(Vector2(prev_direction).rotated(-PI/2.0))
		#print("Clockwise turn: ", move_dir)
	elif d == "X" or d == "L":
		move_dir = Vector2i(Vector2(prev_direction).rotated(PI/2.0))
		#print("Counter-Clockwise turn: ", move_dir)
	head += move_dir
	prev_direction = move_dir
	
	if head.x > board_size.x or head.x < 0:
		head.x = posmod(head.x, board_size.x)
	if head.y > board_size.y or head.y < 0:
		head.y = posmod(head.y, board_size.y)
	print("Head:", head)

func set_instructions(s:String) ->void:
	# Check if valid format
	if s.begins_with("000"):
		instructions = s.split("00")
		for idx : int in instructions.size():
			var rule := instructions[idx]
			var rule_state := rule.get_slice("0", 0).to_int()
			state_lookup.get_or_add(rule_state, []).append(idx)
	elif s.begins_with("L") or s.begins_with("R"):
		propp_format = true
		instructions = s.split()
	else:
		printerr("Invalid instruction syntax.")


func _on_speed_value_changed(value: float) -> void:
	step_time = value
	print("Wait time changed: ", value)
