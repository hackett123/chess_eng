require_relative 'move_generator'

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
    # Raises an error if the move is illegal
    def self.from_algebraic(algebraic:, piece_locations:, white_to_move:)
      # Procedure:
      # 1) identify the piece type.
      # 2) Filter down to the subset of relevant piece types to find the from location.
      # 3) for each of the available piece types, look at the existing location(s) and filter down to legal moves
      piece_type = self.extract_piece_type(algebraic:, white_to_move:)
      legal_moves_for_piece_type = MoveGenerator.legal_moves_for(piece_type:, piece_locations:)
      legal_moves_for_piece_type.each do |from_square, moves|
        moves.each do |move|
          if move == algebraic
            return Move.new(algebraic:, from_loc: from_square, to_loc: self.extract_to_loc(algebraic: move), piece: piece_type)
          end
        end
      end
      raise 'Could not find a legal move based on this algebraic input'
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
