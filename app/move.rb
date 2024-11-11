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

    # Given just algebraic notation, create a full move object
    # Requires the hash of all piece locations, and can save time by receiving the white_to_move bool
    def self.from_algebraic(algebraic:, piece_locations:, white_to_move:)
      # Procedure:
      # 1) identify the piece type.
      # 2) Filter down to the subset of relevant piece types to find the from location.
      # 3) for each of the available piece types, look at the existing location(s) and filter down to legal moves
      piece_type = self.extract_piece_type(algebraic:, white_to_move:)
      to_loc = self.extract_to_loc(algebraic:)
      p "Piece type is #{piece_type}, to_loc is #{to_loc}"
      candidate_from_locs = piece_locations[piece_type]

      return candidate_from_locs.first if candidate_from_locs.length == 1

    end

    private
    def self.extract_piece_type(algebraic:, white_to_move:)
      piece_type = is_pawn_move(algebraic:) ? 'p' : algebraic[0]
      white_to_move ? piece_type.downcase.to_sym : piece_type.upcase.to_sym
    end

    def self.extract_to_loc(algebraic:)
      algebraic.split("=")[0].chars[-2..].join
    end

    def self.is_pawn_move(algebraic:)
      algebraic[0].downcase == algebraic[0]
    end
  end
end
