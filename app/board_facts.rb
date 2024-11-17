require_relative 'converters'
require 'set'

# Contains utility methods that are useful to several classes
module BoardFacts
  extend self # this lets the methods be defined without self. preceeding them

  EMPTY_SQUARE_CHAR = '0'

  # This is kinda dumb, but otherwise we have to do a select with a ternary on every legal_moves submodule method
  def piece_type_locations(piece_locations:, white:, piece_type:)
    pieces = piece_locations&.select do |colored_piece_type, locations|
      if white
        colored_piece_type == colored_piece_type.downcase && colored_piece_type.downcase == piece_type.downcase
      else
        colored_piece_type == colored_piece_type.upcase && colored_piece_type.downcase == piece_type.downcase
      end
    end
    if !pieces.nil? and pieces.any?
      return pieces.values.first
    end
    []
  end

  def piece_present(piece_locations:, square:)
    board_string = Converters.board_string_from_piece_locations(piece_locations:)
    index = Converters.to_index(algebraic: square)
    (0...64).include?(index) && board_string[index] != EMPTY_SQUARE_CHAR
  end

  def opponent_piece_at_square(white_to_move:, piece_locations:, square:)
    return false unless piece_present(piece_locations:, square:)

    board_string = Converters.board_string_from_piece_locations(piece_locations:)
    index = Converters.to_index(algebraic: square)

    white_to_move ? board_string[index].upcase == board_string[index] : board_string[index].downcase == board_string[index]
  end

  # Returns a signed integer - if square_one is a4 and square_two is c6, the difference is 2. but with opposite args, it's -2.
  def rank_distance(square_one:, square_two:)
    square_two[1] - square_one[1]
  end
    

  def different_rank(square_one:, square_two:)
    square_one[1] != square_two[1]
  end

end
