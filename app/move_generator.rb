require_relative 'converters'

module Moves
  module MoveGenerator

    # These sub-modules return lists of algebraic notation. It contains
    # all legal moves for the piece type as a hash of format { from_loc: [to_loc, ...] }.

    module Pawn
      # pawns move vertically once, which means an index offset of +-8.
      # We additionally have to account for "first move" possibilities of two squares
      # when accounting for captures, it's +-8, +-1, if enemy piece is present
      def self.legal_moves(piece_locations:, white_to_move:)
        # initially, we will ignore en-passent as well as promotion.
        board_string = ::Converters.board_string_from_piece_locations(piece_locations:)

        pawn_locations = piece_locations&.select { |piece_type, locations| white_to_move ? piece_type == :p : piece_type == :P }.values.first
        sign = white_to_move ? 1 : -1

        moves = {}
        pawn_locations&.each do |loc|
          moves[loc] = []
          # Pushes...
          index = ::Converters.from_algebraic_to_index(algebraic: loc)
          candidate = index + (sign * 8)
          moves[loc] << ::Converters.from_index_to_algebraic(index: candidate) if board_string[candidate] == '0'
          if ((white_to_move && loc[1] == '2') || (!white_to_move && loc[1] == '7'))
            candidate = index + (sign * 8 * 2)
            moves[loc] << ::Converters.from_index_to_algebraic(index: candidate) if (board_string[candidate] == '0' and board_string[candidate - (sign * 8)] == '0')
          end
          
          # Captures...
          capture_prefix = "#{loc[0]}x"
          capture_candidates = [candidate - 1, candidate + 1] # this doesn't handle 'off the edge' considerations
          capture_candidates.each do |candidate|
            piece_present = board_string[candidate] != '0'
            opponent_piece = if white_to_move
              board_string[candidate].upcase == board_string[candidate]
            else
              board_string[candidate].downcase == board_string[candidate]
            end
            moves[loc] << "#{capture_prefix}#{::Converters.from_index_to_algebraic(index:candidate)}" if (piece_present && opponent_piece)
          end
        end
        moves
      end
    end
    module Rook
      def self.legal_moves(piece_locations:, white_to_move:)
        # TODO: Implement
        []
      end
    end
    module Knight
      def self.legal_moves(piece_locations:, white_to_move:)
        # TODO: Implement
        []
      end
    end
    module Bishop
      def self.legal_moves(piece_locations:, white_to_move:)
        # TODO: Implement
        []
      end
    end
    module Queen
      def self.legal_moves(piece_locations:, white_to_move:)
        # TODO: Implement
        []
      end
    end
    module King
      def self.legal_moves(piece_locations:, white_to_move:)
        # TODO: Implement
        []
      end
    end
    PIECE_TYPE_TO_MODULE = {
      p: Pawn,
      r: Rook,
      n: Knight,
      b: Bishop,
      q: Queen,
      k: King
    }

    def self.legal_moves_for(piece_type:, piece_locations:)
      white_to_move = piece_type.downcase == piece_type
      PIECE_TYPE_TO_MODULE[piece_type.downcase].legal_moves(piece_locations:, white_to_move:)
    end

    def self.generate_white_legal_moves(piece_locations:)
      []
    end

    def self.generate_black_legal_moves(piece_locations:)
      []
    end

  end
end
