require_relative 'board'

module FenReader

  # Ingests .fen files, or strings, and outputs a Board object
  # it really just invokes the Board constructor lol..

  def self.read_from_file(filename)
    create_board(File.read(filename))
  end

  # so, bummer, but FEN notation is basically inverted from what i settled on for our notation.
  # it starts with the 8th rank and comes back to one, and flips the casing of ours. so p in ours is white, but P in FEN is black.
  def self.read_from_str(fen_string)
    parts = fen_string.split(" ")
    positions = parts[0]

    # starts with 8th rank and works its way backwards.
    board_string_arr = []
    positions.split("/").each do |rank|

      rank_string = ''
      rank.each_char do |c|
        if %w[r n b q k p].include?(c.downcase)
          rank_string += c.swapcase
        else
          # otherwise it should be an integer representing consecutive empty squares.
          rank_string += ('0'* c.to_i)
        end
      end
      board_string_arr.unshift(rank_string)
    end
    board_string = board_string_arr.join('')

    # now that we built our board string, write the positions hash
    piece_locations = {}
    board_string.each_char.with_index do |c, index|
      next if c == '0'
      unless piece_locations.keys.include?(c.to_sym)
        piece_locations[c.to_sym] = Set.new
      end
      piece_locations[c.to_sym] << Converters.to_algebraic(index:)
    end

    board_string_arr = board_string_arr.reverse
    white_to_move = parts[1] == 'w'
    legal_castles = parts[2]
    en_passent_target = parts[3] # Don't care about this yet
    halfmove_clock = parts[4] # Don't care about this yet
    fullmove_count = parts[5] # Don't care about this yet
    self.create_board(piece_locations:, board_string:, white_to_move:, legal_castles:)
  end

  private
  def self.create_board(piece_locations: nil, board_string: nil, white_to_move: nil, legal_castles: nil)
    Board.new(piece_locations:, board_string:, white_to_move:, legal_castles:)
  end

end
