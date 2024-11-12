require_relative 'converters'
require_relative 'board_facts'

module Moves
  module MoveGenerator extend self


    # This defines the common mixin, Piece, that implements the public `legal_moves` method for each piece type, and
    # returns a hash of format { starting_square: [legal_destination_squares] }
    # Modules which include `Piece` must define the private methods `piece_type` and `legal_moves_single_piece` sub-modules return lists of algebraic notation. It contains
    module Piece extend self
      def legal_moves(piece_locations:, white_to_move:)
        this_piece_locations = ::BoardFacts.piece_type_locations(piece_locations:, white: white_to_move, piece_type:)
        this_piece_locations&.map { |loc| [loc, legal_moves_single_piece(loc:, piece_locations:, white_to_move:)] }.to_h
      end

      private def piece_type
        raise "Not Implemented!"
      end

    end

    module Pawn extend self
      include Piece

      private
      def piece_type
        :p
      end

      # initially, we will ignore en-passent as well as promotion.
      def legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
        sign = white_to_move ? 1 : -1
        moves = []
        # Push 1 square...
        index = ::Converters.to_index(algebraic: loc)
        candidate = index + (sign * 8)
        algebraic_candidate = ::Converters.to_algebraic(index: candidate)
        moves << algebraic_candidate unless ::BoardFacts.piece_present(piece_locations:, square: algebraic_candidate)

        # Push 2 squares...
        if on_starting_rank(loc:, white_to_move:)
          candidate = index + (sign * 8 * 2)
          algebraic_candidate = ::Converters.to_algebraic(index: candidate)
          reqs = [
            !::BoardFacts.piece_present(piece_locations:, square: algebraic_candidate),
            !::BoardFacts.piece_present(piece_locations:, square: ::Converters.to_algebraic(index: candidate - (sign * 8)))
          ]
          moves << algebraic_candidate if reqs.all?
        end

        # Capture...
        capture_prefix = "#{loc[0]}x"
        capture_candidates = [candidate - 1, candidate + 1] # this doesn't handle 'off the edge' considerations
        capture_candidates.each do |candidate|
          algebraic_candidate = ::Converters.to_algebraic(index: candidate)
          reqs = [
            ::BoardFacts.piece_present(piece_locations:, square: algebraic_candidate),
            ::BoardFacts.opponent_piece_at_square(white_to_move:, piece_locations:, square: algebraic_candidate),
            ::BoardFacts.different_rank(square_one: loc, square_two: algebraic_candidate)
          ]
          moves << "#{capture_prefix}#{::Converters.to_algebraic(index:candidate)}" if reqs.all?
        end
        moves
      end

      def on_starting_rank(loc:, white_to_move:)
        if white_to_move
          ::Converters::to_rank(algebraic: loc) == 2
        else
          ::Converters::to_rank(algebraic: loc) == 7
        end
      end
    end

    module Rook extend self
      include Piece

      private
      def piece_type
        :r
      end

      def legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
        []
      end
    end

    module Knight extend self
      include Piece

      private
      def piece_type
        :n
      end

      def legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
        []
      end
    end
    module Bishop extend self
      include Piece

      private
      def piece_type
        :b
      end

      def legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
        []
      end
    end
    module Queen extend self
      include Piece

      private
      def piece_type
        :q
      end

      def legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
        []
      end
    end
    module King extend self
      include Piece

      private
      def piece_type
        :k
      end

      def legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
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

    def legal_moves_for(piece_type:, piece_locations:)
      white_to_move = piece_type.downcase == piece_type
      PIECE_TYPE_TO_MODULE[piece_type.downcase].legal_moves(piece_locations:, white_to_move:)
    end

    def generate_white_legal_moves(piece_locations:)
      []
    end

    def generate_black_legal_moves(piece_locations:)
      []
    end

  end
end
