# Basic wrapper for tuple of move details. Example:
# Bxc6, b5, c6, B
# Note that to_loc and piece are redundant but included for simplicity
class Move:

    def __init__(self, algebraic, from_loc, to_loc, piece):
        self.algebraic = algebraic
        self.from_loc = from_loc
        self.to_loc = to_loc
        self.piece = piece