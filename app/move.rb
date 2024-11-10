# Basic wrapper for tuple of move details. Example:
# Bxc6, b5, c6
# Note that to_loc and piece are redundant but included for simplicity
module Moves
  class Move
    attr_reader :algebraic, :from_loc, :to_loc, :piece
    def initialize(algebraic:, from_loc:, to_loc:, piece:)
      @algebraic = algebraic
      @from_loc = from_loc
      @to_loc = to_loc
      @piece = piece
    end
  end
end
