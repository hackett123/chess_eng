require_relative 'fen_reader'
require_relative 'board'
require_relative 'move'

board = Board.new
board.show(print: true)
board.make_move(algebraic: 'e4')
board.make_move(algebraic: 'c6')
board.make_move(algebraic: 'd4')
board.make_move(algebraic: 'd5')
board.make_move(algebraic: 'e5')
board.make_move(algebraic: 'c5')
board.make_move(algebraic: 'dxc5')
board.make_move(algebraic: 'e6')
board.make_move(algebraic: 'a3')

