require_relative 'fen_reader'
require_relative 'board'
require_relative 'move'

board = Board.new
board.show(print: true)

%w[
e4 c6
d4 d5
e5 c5
dxc5 Nc6
f4 e6
Be3 Nh6
c3 Nf5
Bf2
].each { |algebraic| board.make_move(algebraic:) }
