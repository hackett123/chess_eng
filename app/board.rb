require_relative 'move'
require_relative 'converters'
require_relative 'move_generator'
require_relative 'board_facts'
require_relative 'board_manipulation'

class Board
# Public API:
# make_move(move) - takes in algebraic notation
# show - outputs a string visual of the board

  attr_reader :piece_locations, :board_string, :moves, :white_to_move, :legal_castles

  PIECE_TYPE_TO_SYMBOLS = {
   K: '♔️',
   Q: '♕️',
   B: '♗️',
   N: '♘️',
   P: '♙️',
   R: '♖️',
   k: '♚️',
   q: '♛️',
   b: '♝️',
   n: '♞️',
   p: '♟',
   r: '♜'
  }

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

  def make_move(algebraic:, print: false)
    print_move(algebraic:) if print
    _make_move(move: Moves::Move.from_algebraic(algebraic:, piece_locations:, white_to_move:))
    show(print:)
  end

  def print_move(algebraic:)
    move_str = ''
    move_str += "#{1 + (moves.length / 2)}."
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
      piece_str = (PIECE_TYPE_TO_SYMBOLS[c.to_sym] || "-") + ' '
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
  # At this point we assume the move is legal.
  def _make_move(move:)
    @moves << move.algebraic
    @board_string = BoardManipulation.update_board_string(board_string:, move:)
    @piece_locations = BoardManipulation.update_piece_locations(piece_locations:, move:)
    @white_to_move = !white_to_move
  end
end
