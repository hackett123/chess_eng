module Converters
  extend self

  def to_algebraic(index:)
    # 0 -> a1, 1 -> b1, 8 -> a2, ... 63 -> h8
    rank = index / 8
    file = index % 8
    "#{(file + 'a'.ord).chr}#{rank + 1}"
  end

  # By 'algebraic', we really mean the square name. So e6, g2, ...
  def to_index(algebraic:)
    rank = algebraic[0].ord - 'a'.ord
    file = algebraic[1].to_i
    
    file_index = (file - 1) * 8
    file_index + rank
  end
  
  # This has utility mainly for tests, bc during actual gameplay we keep the board string updated
  def board_string_from_piece_locations(piece_locations:)
    piece_location_as_indexes = piece_locations.transform_values do |squares|
      squares.map { |s| to_index(algebraic: s) }
    end
    board_string = '0' * 64
    piece_location_as_indexes.each do |piece_type, indices|
      indices.each do |index|
        board_string[index] = piece_type.to_s
      end
    end

    board_string
  end

  # Some utility methods for processing
  def to_rank(algebraic:)
    (to_index(algebraic:) / 8) + 1
  end

  def to_file(algebraic:)
    (to_index(algebraic:) % 8) + 1
  end

end
