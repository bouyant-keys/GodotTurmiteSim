# Purpose
This is my creative artefact for the Computing Theory course at RMIT.
Initially completed on October 18th 2026.

This is a Turmite (2-Dimensional Turing Machine) Simulator constructed using the Godot game engine.
There are 5 presets for Langton's Ant, and 4 symmetric Ant varieties by Jim Propp from: https://arxiv.org/pdf/math/9501233.
There is also an instruction editor box to add transitions to presets or make your own, following the format:
    Instruction = L,R,L,R,... (where L & R represent turns based on the tile-state.) 
    So tile state 4 -> Instruction[4] -> R (turn right).
