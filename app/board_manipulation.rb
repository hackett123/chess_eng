require_relative 'board_facts'
require_relative 'converters'

module BoardManipulation extend self

  def update_board_string(board_string:, move:)
      index_from = Converters.to_index(algebraic: move.from_loc)
      index_to = Converters.to_index(algebraic: move.to_loc)
      board_string = board_string[0...index_from] + "0" + board_string[(index_from + 1)..-1]
      board_string = board_string[0...index_to] + move.piece.to_s + board_string[(index_to + 1)..-1]
      board_string
    end 

    def update_piece_locations(piece_locations:, move:)
      # Remove the piece that was previously on that square, if there was one
      if BoardFacts.piece_present(piece_locations:, square: move.to_loc)
        piece_locations.select { |p, squares| squares.include?(move.to_loc) }.first[1].delete(move.to_loc)
      end 

      # Move the piece from its starting square to its ending square
      locs = piece_locations[move.piece.to_sym]
      locs.reject! { |l| l == move.from_loc }
      locs.append(move.to_loc)
      piece_locations
    end 

  end
