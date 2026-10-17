class_name Turmite extends Node

#(q0, 0) -> (q0, 1, R), (q0, 1) -> (q0, 0, R)
const DEF_INSTRUCTION := preload("uid://dqe4hfkdbve0p") as Instruction
const DEF_INSTRUCTIONS := "10w010r0E0010k010w0E"
const ANT_INSTRUCTIONS := "10w010k0C0010k010w0X"
const PROPP_ANT := "LR" # state 0 turns L, state 1 turns R, state becomes i + 1 mod n.
const PROPP_ANT_9 := "LRRL"
const PROPP_ANT_12 := "LLRR"
const COLORS := {"k":Color.BLACK, "w":Color.WHITE, "r":Color.RED, "b":Color.BLUE, "g":Color.GREEN}
const DEF_COLOR := Color.WHITE
const DIRECTIONS = {"W":Vector2i(-1.0, 0.0), "E":Vector2i(1.0, 0.0), "N":Vector2i(0.0, -1.0), "S":Vector2i(0.0, 1.0)}
const TURNS = {"C":float(-PI/2.0), "R":float(-PI/2.0), "X":float(PI/2.0), "L":float(PI/2.0)}
const DEF_STEP_TIME := 0.2

## Machine head position.
var head : Vector2i

var current_turmite_instructions : Instruction
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

var halted := false

var paused := false

var wait_timer : Timer

## Instructions follow 'LRLR' format instead of '00010k01...'
var propp_format := false

@export var starting_instructions : Instruction
@export var board : TextureRect
@export var board_size := Vector2i(128, 128)
#@export var state_colors : Array[Color]

signal turmite_moved(to:Vector2i)
signal status_changed(status:String)
signal steps_changed(steps:int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_turmite_instructions = starting_instructions
	
	board_image = Image.create_empty(board_size.x, board_size.y, false, Image.FORMAT_RGBAF)
	board_image.fill(current_turmite_instructions.state_colors[0])
	
	head = board_size / 2.0
	state = 1
	set_turmite_instructions(current_turmite_instructions)
	_step()

func _step() ->void:
	read()
	
	await get_tree().create_timer(step_time).timeout
	if halted or paused:
		return
	
	step_count += 1
	steps_changed.emit(step_count)
	_step()

func read() ->void:
	var tile_color : Color = board.texture.get_image().get_pixelv(head)
	match current_turmite_instructions.type:
		Instruction.InstructionType.TM:
			read_tm(tile_color)
		Instruction.InstructionType.ANT:
			read_ant(tile_color)

func read_tm(tile_color:Color) ->void:
	var state_transitions := state_lookup.get(state, []) as Array
	
	# If no transitions from the current state, halt.
	if state_transitions.size() == 0: halt()
	
	# Otherwise, check existing state transitions:
	for index in state_transitions:
		var rule := instructions[index]
		var elements := rule.split(",") # format: ["1", "k", "1", "w", "R"]
		# Check if color is encoded as a string or custom color index.
		var read_color := parse_color(elements[1])
		
		# If no transition at state with the current tile color, continue or halt.
		if !read_color.is_equal_approx(tile_color):
			# If last possible transition and no match, halt.
			if index == state_transitions.size() - 1:
				halt()
				break
			else:
				continue
		
		#print("Matched Rule: ", rule, " - read_color: ", read_color)
		state = elements[2].to_int()
		print("State: ", state)
		write(parse_color(elements[3]))
		move(elements[4])
		break

func read_ant(tile_color:Color) ->void:
	var ant_colors := current_turmite_instructions.state_colors
	for idx : int in ant_colors.size():
		if !tile_color.is_equal_approx(ant_colors[idx]):
			# If last possible transition and no match, halt.
			if idx == ant_colors.size() - 1:
				halt()
				break
			else:
				continue
		state = idx
		break
	write(current_turmite_instructions.get_color(state+1))
	move(instructions[state])


func write(c:Color) ->void:
	board_image.set_pixelv(head, c)
	board.texture = ImageTexture.create_from_image(board_image)


func move(d:String) ->void:
	var move_dir := Vector2i(0, 0)
	if d in DIRECTIONS:
		move_dir = DIRECTIONS.get(d, Vector2.ZERO)
	elif d in TURNS:
		var rotation := TURNS.get(d, 0.0) as float
		move_dir = Vector2i(Vector2(prev_direction).rotated(rotation))
	else:
		print("No Move.")
		return
	head += move_dir
	prev_direction = move_dir
	
	if head.x > board_size.x or head.x < 0:
		head.x = posmod(head.x, board_size.x)
	if head.y > board_size.y or head.y < 0:
		head.y = posmod(head.y, board_size.y)
	
	turmite_moved.emit(head)
	print("Moved to: ", head)


func halt() ->void:
	print("Halted")
	halted = true
	status_changed.emit("Halted")

func set_turmite_instructions(i:Instruction) ->void:
	## Check if valid format
	if !i.is_valid():
		return
	
	if i.type == Instruction.InstructionType.TM:
		current_turmite_instructions = i
		instructions = i.transitions
		for idx : int in instructions.size():
			print(instructions[idx])
			var transition := instructions[idx]
			var t_state := transition.get_slice(",", 0).to_int()
			state_lookup.get_or_add(t_state, []).append(idx)
	elif i.type == Instruction.InstructionType.ANT:
		current_turmite_instructions = i
		instructions = i.transitions
		print(instructions)
		#propp_format = true
	else:
		printerr("Invalid instruction syntax.")

func parse_color(s:String) ->Color:
	if s.is_valid_int():
		return current_turmite_instructions.get_color(s.to_int())
	else:
		return COLORS.get(s)
	

func _on_speed_changed(value: float) -> void:
	step_time = value
	print("Wait time changed: ", value)

func _on_instructions_changed(i:Instruction) ->void:
	reset_turmite()
	set_turmite_instructions(i)
	_step()


func pause_turmite(set_paused:bool) ->void:
	paused = set_paused
	if !paused:
		_step()
		status_changed.emit("Active")
	else:
		status_changed.emit("Paused")

func reset_turmite() ->void:
	set_turmite_instructions(current_turmite_instructions)
	
	# Clear board
	board_image = Image.create_empty(board_size.x, board_size.y, false, Image.FORMAT_RGBAF)
	board_image.fill(Color.WHITE)
	board.texture = ImageTexture.create_from_image(board_image)
	
	halted = false
	head = board_size / 2.0
	state = 1
	step_count = 0
	turmite_moved.emit(head)
	
