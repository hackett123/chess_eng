require_relative 'fen_reader'
require_relative 'board'
require_relative 'move'

board = Board.new
board.show
p "Move: 1.e4"
board.make_move(move: Moves::Move.new(algebraic: "e4", from_loc: "e2", to_loc: "e4", piece: "p"))
board.show
