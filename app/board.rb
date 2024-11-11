require_relative 'move'
require_relative 'converters'
require_relative 'move_generator'

class Board
# Public API:
# make_move(move) - takes in algebraic notation
# show - outputs a string visual of the board

  attr_reader :piece_locations, :board_string, :moves, :white_to_move, :legal_castles

  def initialize(piece_locations: nil, board_string: nil, white_to_move: nil, legal_castles: nil)
    @piece_locations = piece_locations || {
      p: ['a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g2', 'h2'],
      r: ['a1', 'h1'],
      n: ['b1', 'g1'],
      b: ['c1', 'f1'],
      q: ['d1'],
      k: ['e1'],
      P: ['a7', 'b7', 'c7', 'd7', 'e7', 'f7', 'g7', 'h7'],
      R: ['a8', 'h8'],
      N: ['b8', 'g8'],
      B: ['c8', 'f8'],
      Q: ['d8'],
      K: ['e8']
    }
    @board_string = board_string || "rnbqkbnrpppppppp00000000000000000000000000000000PPPPPPPPRNBQKBNR"
    @moves = []
    @white_to_move = white_to_move.nil? ? true : white_to_move
    @legal_castles = legal_castles || 'kqKQ'
  end

  def make_move(algebraic:)
    print_move(algebraic:)
    _make_move(move: Moves::Move.from_algebraic(algebraic:, piece_locations:, white_to_move:))
    show(print: true)
  end

  def print_move(algebraic:)
    move_str = ''
    move_str += "#{1 + (moves.length / 2)}. "
    move_str += '..' unless white_to_move
    move_str += algebraic
    p move_str
  end

  def show(print: false)
    # Will use a basic cli output for now.
    ranks, rank = [], ""
    board_string.each_char.with_index do |c, i|
      next_rank = ((i % 8 == 0) and (i > 0)) 
      if next_rank
        ranks.append(rank.strip)
        rank = ""
      end
      piece_str = c + ' ' 
      if piece_str == "0 "
        piece_str = "- " 
      end
      rank += piece_str
    end
    # get last rank in
    ranks << rank.strip

    # flip for visual correctness
    ranks = ranks.reverse

    if print
      for rank in ranks
        p rank
      end
      p ''
    end

    ranks.join("\n")
  end

private
  # Private make_move takes in the dis-ambiguated move object
  # At this point we assume the move is legal.
  def _make_move(move:)
    @moves << move.algebraic
    update_positions(move:)
    @white_to_move = !white_to_move
  end
  def update_positions(move:)
    update_board_string(move.piece.to_s, move.from_loc, move.to_loc)
    update_piece_locations(move.piece, move.from_loc, move.to_loc)
  end

  def update_board_string(piece, from_loc, to_loc)
    index_from = Converters.from_algebraic_to_index(algebraic: from_loc)
    index_to = Converters.from_algebraic_to_index(algebraic: to_loc)
    @board_string = board_string[0...index_from] + "0" + board_string[(index_from + 1)..-1]
    @board_string = board_string[0...index_to] + piece + board_string[(index_to + 1)..-1]
  end

  def update_piece_locations(piece, from_loc, to_loc)
    locs = piece_locations[piece.to_sym]
    locs.reject! { |l| l == from_loc }
    locs.append(to_loc)
    # puts("Update piece locations to", piece_locations)
  end
end
