require_relative 'converters'
require_relative 'board_facts'
require_relative 'board_manipulation'
require 'json'

module Moves
  module MoveGenerator extend self


    # This defines the common mixin, Piece, that implements the public `legal_moves` method for each piece type, and
    # returns a hash of format { starting_square: [legal_destination_squares] }
    # Modules which include `Piece` must define the private methods `piece_type` and `legal_moves_single_piece` sub-modules return lists of algebraic notation. It contains
    module Piece extend self
      def legal_moves(piece_locations:, white_to_move:, filter_out_moves_that_put_us_in_check: true)
        our_king_location = ::BoardFacts.piece_type_locations(piece_locations:, white: white_to_move, piece_type: :k).first
        this_piece_locations = ::BoardFacts.piece_type_locations(piece_locations:, white: white_to_move, piece_type:)
        this_piece_locations&.map do |loc|
          possible_moves = legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
          if filter_out_moves_that_put_us_in_check
            possible_moves = possible_moves.reject { |move| does_move_put_us_in_check(piece_locations:, white_to_move:, move:, from_loc: loc, king_position: our_king_location) }
          end
          [loc, possible_moves] 
        end.to_h
      end

      def in_bounds(index)
        (0...64).include?(index)
      end

      private
      def piece_type
        raise "Not Implemented!"
      end

      # This is a naive implementation; it requires us to generate all legal moves for the opponent for every single one
      # of our own possible moves. It would be considerably faster if we pre-generated the opponent moves, and then,
      # for each of our moves, only recompute opponent moves that previously had the moving piece in its vision.
      def does_move_put_us_in_check(piece_locations:, white_to_move:, move:, from_loc:, king_position:)
        if king_position == '' || king_position.nil?
          raise "CANNOT FIND KING"
        end

        piece_type = Move.extract_piece_type(algebraic: move, white_to_move:)
        to_loc = Move.extract_to_loc(algebraic: move) 

        full_move_obj = Move.new(algebraic: move, from_loc:, to_loc:, piece: piece_type)
        cloned_piece_locations = JSON.parse(piece_locations.to_json, symbolize_names: true)
        future_piece_locations = BoardManipulation::update_piece_locations(piece_locations: cloned_piece_locations, move: full_move_obj)
        opponent_moves = white_to_move ?
          ::Moves::MoveGenerator.generate_black_legal_moves(piece_locations: future_piece_locations, filter_out_moves_that_put_us_in_check: false) :
          ::Moves::MoveGenerator.generate_white_legal_moves(piece_locations: future_piece_locations, filter_out_moves_that_put_us_in_check: false)

        opponent_moves&.any? { |piece, moves| moves.any? { |m| m.include?("x#{king_position}") } }
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
        up_moves = vertical_moves(sign: 1, loc:, piece_locations:, white_to_move:)
        down_moves = vertical_moves(sign: -1, loc:, piece_locations:, white_to_move:)
        left_moves = horizontal_moves(sign: -1, loc:, piece_locations:, white_to_move:)
        right_moves = horizontal_moves(sign: 1, loc:, piece_locations:, white_to_move:)
        up_moves + down_moves + left_moves + right_moves
      end

      def directional_moves(dir:, loc:, piece_locations:, white_to_move:)
        # TODO - extract out horizontal_moves / vertical_moves common behavior here
      end

      def horizontal_moves(sign:, loc:, piece_locations:, white_to_move:)
        moves = []
        starting_rank = ::Converters.to_rank(algebraic: loc)
        curr_index = ::Converters.to_index(algebraic: loc) + (sign * 1)
        collision = ::BoardFacts.piece_present(piece_locations:, square: ::Converters.to_algebraic(index: curr_index))
        while !collision and in_bounds(curr_index) and starting_rank == ::Converters.to_rank(algebraic: ::Converters.to_algebraic(index: curr_index))
          moves << "R#{::Converters.to_algebraic(index: curr_index)}"
          curr_index += (sign * 1)
          collision = ::BoardFacts.piece_present(piece_locations:, square: ::Converters.to_algebraic(index: curr_index))
        end
        if collision
          if ::BoardFacts.opponent_piece_at_square(white_to_move:, piece_locations:, square: ::Converters.to_algebraic(index: curr_index))
            moves << "Rx#{::Converters.to_algebraic(index: curr_index)}"
          end
        end
        moves
      end

      def vertical_moves(sign:, loc:, piece_locations:, white_to_move:)
        moves = []
        curr_index = ::Converters.to_index(algebraic: loc) + (sign * 8)
        collision = ::BoardFacts.piece_present(piece_locations:, square: ::Converters.to_algebraic(index: curr_index))
        while !collision and in_bounds(curr_index)
          moves << "R#{::Converters.to_algebraic(index: curr_index)}"
          curr_index += (sign * 8)
          collision = ::BoardFacts.piece_present(piece_locations:, square: ::Converters.to_algebraic(index: curr_index))
        end
        if collision
          if ::BoardFacts.opponent_piece_at_square(white_to_move:, piece_locations:, square: ::Converters.to_algebraic(index: curr_index))
            moves << "Rx#{::Converters.to_algebraic(index: curr_index)}"
          end
        end
        moves
      end
    end

    module Knight extend self
      include Piece

      private
      def piece_type
        :n
      end

      # L shape is formed by (+-8, +-2), and (+-16, +-1). These correspond to the horizontal and vertical Ls
      # for each of those 8 squares, check 1) on board, 2) appropriate rank distance from knight, and 3) piece present
      def legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
        index = ::Converters.to_index(algebraic: loc)
        horizontal_l_candidates = [index + 8 + 2, index + 8 - 2, index - 8 + 2, index - 8 - 2]
        vertical_l_candidates = [index + 16 + 1, index + 16 - 1, index - 16 + 1, index - 16 - 1]

        starting_rank = ::Converters.to_rank(algebraic: loc)

        # Must be one rank different from starting square
        horizontal_l_candidates.select! do |c|
          candidate_rank = ::Converters.to_rank(algebraic: ::Converters.to_algebraic(index: c))
          (candidate_rank - starting_rank).abs == 1
        end
        # Must be two rank different from starting square
        vertical_l_candidates.select! do |c|
          # candidate_rank = ::Converters.to_rank(algebraic: ::Converters.to_algebraic(index: c))
          candidate_rank = ::Converters.to_rank(algebraic: ::Converters.to_algebraic(index: c))
          (candidate_rank - starting_rank).abs == 2
        end

        (horizontal_l_candidates + vertical_l_candidates)
          .select { |c| in_bounds(c) }
          .map { |c| ::Converters.to_algebraic(index: c) }
          .map { |square|
            if ::BoardFacts.piece_present(piece_locations:, square:)
              if ::BoardFacts.opponent_piece_at_square(white_to_move:, piece_locations:, square:)
                "Nx#{square}"
              end
            else
              "N#{square}"
            end
          }.compact
      end
    end
    module Bishop extend self
      include Piece

      private
      def piece_type
        :b
      end

      def legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
        up_right_moves = diagonal_moves(offset: 9, loc:, piece_locations:, white_to_move:)
        down_right_moves = diagonal_moves(offset: -7, loc:, piece_locations:, white_to_move:)
        up_left_moves = diagonal_moves(offset: 7, loc:, piece_locations:, white_to_move:)
        down_left_moves = diagonal_moves(offset: -9, loc:, piece_locations:, white_to_move:)

        up_right_moves + down_right_moves + up_left_moves + down_left_moves
      end

      def diagonal_moves(offset:, loc:, piece_locations:, white_to_move:)
        moves = []
        curr_index = ::Converters.to_index(algebraic: loc) + offset
        collision = ::BoardFacts.piece_present(piece_locations:, square: ::Converters.to_algebraic(index: curr_index))
        last_rank = ::Converters.to_rank(algebraic: loc)
        curr_rank = ::Converters.to_rank(algebraic: ::Converters.to_algebraic(index: curr_index))
        while !collision and in_bounds(curr_index) and ((curr_rank - last_rank).abs == 1)
          moves << "B#{::Converters.to_algebraic(index: curr_index)}"
          curr_index += offset
          last_rank = curr_rank
          curr_rank = ::Converters.to_rank(algebraic: ::Converters.to_algebraic(index: curr_index))
          collision = ::BoardFacts.piece_present(piece_locations:, square: ::Converters.to_algebraic(index: curr_index))
        end

        if collision
          if ::BoardFacts.opponent_piece_at_square(white_to_move:, piece_locations:, square: ::Converters.to_algebraic(index: curr_index))
            moves << "Bx#{::Converters.to_algebraic(index: curr_index)}"
          end
        end
        moves
      end
    end

    module Queen extend self
      include Piece

      private
      def piece_type
        :q
      end

      def legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
        bishop_ish_moves = Bishop.send(:legal_moves_single_piece, loc:, piece_locations:, white_to_move:)
        rook_ish_moves = Rook.send(:legal_moves_single_piece, loc:, piece_locations:, white_to_move:)
        queen_moves = bishop_ish_moves + rook_ish_moves
        queen_moves.map { |m| "Q#{m[1..]}" }
      end
    end
    module King extend self
      include Piece

      private
      def piece_type
        :k
      end

      def legal_moves_single_piece(loc:, piece_locations:, white_to_move:)
        # we could just get the queen moves and filter by radii of 1, but I don't think that's more elegant
        index = ::Converters.to_index(algebraic: loc)
        rank = ::Converters.to_rank(algebraic: loc)

        up_moves = [index + 7, index + 8, index + 9]
          .select { |i| in_bounds(i) }
          .map { |i| ::Converters.to_algebraic(index: i) }
        lateral_moves = [index - 1, index + 1]
          .select { |i| in_bounds(i) }
          .map { |i| ::Converters.to_algebraic(index: i) }
        down_moves = [index - 9, index - 8, index - 7]
          .select { |i| in_bounds(i) }
          .map { |i| ::Converters.to_algebraic(index: i) }

        up_moves.filter! { |m| ::Converters.to_rank(algebraic: m) - rank == 1 }
        lateral_moves.filter! { |m| ::Converters.to_rank(algebraic: m) - rank == 0 }
        down_moves.filter! { |m| ::Converters.to_rank(algebraic: m) - rank == -1 }

        (up_moves + lateral_moves + down_moves).map do |m|
          if ::BoardFacts.piece_present(piece_locations:, square: m)
            if ::BoardFacts.opponent_piece_at_square(white_to_move:, piece_locations:, square: m)
              "Kx#{m}"
            end
          else
            "K#{m}"
            end
        end.compact
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

    def legal_moves_for(piece_type:, piece_locations:, filter_out_moves_that_put_us_in_check: true)
      white_to_move = piece_type.downcase == piece_type
      PIECE_TYPE_TO_MODULE[piece_type.downcase].legal_moves(piece_locations:, white_to_move:, filter_out_moves_that_put_us_in_check:)
    end

    def generate_white_legal_moves(piece_locations:, filter_out_moves_that_put_us_in_check: true)
      pieces = piece_locations.keys.select { |k| k.downcase == k }
      generate_moves_for_side(pieces:, piece_locations:, filter_out_moves_that_put_us_in_check:)
    end

    def generate_black_legal_moves(piece_locations:, filter_out_moves_that_put_us_in_check: true)
      pieces = piece_locations.keys.select { |k| k.upcase == k }
      generate_moves_for_side(pieces:, piece_locations:, filter_out_moves_that_put_us_in_check:)
    end

    private
    def generate_moves_for_side(pieces:, piece_locations:, filter_out_moves_that_put_us_in_check: true)
      move_hashes = pieces.map { |piece_type| legal_moves_for(piece_type:, piece_locations:, filter_out_moves_that_put_us_in_check:) }
      move_hashes.reduce(&:merge)
    end

  end
end
