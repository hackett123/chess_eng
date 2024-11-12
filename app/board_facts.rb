require_relative 'converters'

# Contains utility methods that are useful to several classes
module BoardFacts
  extend self # this lets the methods be defined without self. preceeding them

  EMPTY_SQUARE_CHAR = '0'

  # This is kinda dumb, but otherwise we have to do a select with a ternary on every legal_moves submodule method
  def piece_type_locations(piece_locations:, white:, piece_type:)
    piece_locations&.select do |colored_piece_type, locations|
      if white
        colored_piece_type == colored_piece_type.downcase && colored_piece_type.downcase == piece_type.downcase
      else
        colored_piece_type == colored_piece_type.upcase && colored_piece_type.downcase == piece_type.downcase
      end
    end.values.first
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

  def different_rank(square_one:, square_two:)
    rank_one = Converters.to_rank(algebraic: square_one)
    rank_two = Converters.to_rank(algebraic: square_two)
    rank_one != rank_two
  end

end
