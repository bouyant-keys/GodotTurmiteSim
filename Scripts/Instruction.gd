class_name Instruction extends Resource

# TM Format: "0,k,0,w,R", "0,w,0,k,R", ...

enum InstructionType {TM, ANT}

@export var name : StringName
@export var type : InstructionType
@export var transitions : PackedStringArray
@export var state_colors : Array[Color]

func _to_string() -> String:
	var s := ""
	
	if type == InstructionType.TM:
		s = "\n".join(transitions)
	elif type == InstructionType.ANT:
		s = ",".join(transitions)
	
	return s

func get_color(state:int) ->Color:
	return state_colors[posmod(state, state_colors.size())]

## Check whether the instructions can be interpreted by the Turmite.
func is_valid() ->bool:
	if transitions.is_empty():
		return false
	elif state_colors.is_empty():
		return false
	
	if type == InstructionType.TM:
		for t : String in transitions:
			if !validate_tm_trans(t):
				return false
	elif type == InstructionType.ANT:
		for t : String in transitions:
			if !validate_ant_trans(t):
				return false
	
	return true

## Check whether the transition can be interpreted as a Turing Machine transition.
func validate_tm_trans(t:String) ->bool:
	if t.is_empty(): return false
	elif t.find(",") == -1: return false
	
	# Split transition into elements.
	var elements = t.split(",")
	
	# Start State Requirements - Must be an Integer.
	if !elements[0].is_valid_int(): return false
	# Read Color Requirements - Must be a valid Color string or in the custom color index.
	if (elements[1] not in Turmite.COLORS) and (!elements[1].is_valid_int()): return false
	# End State Requirements - Must be an integer.
	if !elements[2].is_valid_int(): return false
	# Write Color Requirements - Must be a valid color string or in the custom color index.
	if (elements[3] not in Turmite.COLORS) and (!elements[3].is_valid_int()): return false
	# Move Direction Requirements - Must be in the DIRECTIONS set.
	#if (elements[4] not in Turmite.DIRECTIONS) and (elements[4] not in Turmite.TURNS): return false
	
	return true

## Check whether the transition can be interpreted as an Ant transition.
func validate_ant_trans(t:String) ->bool:
	if t.length() != 1: return false
	elif t not in ["L", "R", "l", "r"]: return false
	return true
