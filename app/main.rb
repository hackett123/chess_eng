require_relative 'fen_reader'
require_relative 'board'
require_relative 'move'

board = Board.new
board.show
p "Move: 1.e4"
board.make_move(move: Moves::Move.new(algebraic: "e4", from_loc: "e2", to_loc: "e4", piece: "p"))
board.show
board.make_move(move: Moves::Move.new(algebraic: "c5", from_loc: "c7", to_loc: "c5", piece: "p"))
board.show
board.make_move(move: Moves::Move.new(algebraic: "Nf3", from_loc: "g1", to_loc: "f3", piece: "N"))
board.show
board.make_move(move: Moves::Move.new(algebraic: "Nc6", from_loc: "b8", to_loc: "c6", piece: "N"))
board.show

