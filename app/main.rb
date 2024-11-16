require_relative 'fen_reader'
require_relative 'board'
require_relative 'move'
require_relative 'move_generator'

board = Board.new
board.show(print: true)

# Note the last move in this Scandi line, Qa5, is actually a check. Once we add check detection, this will update
%w[
e4 d5
exd5 Qxd5
Nf3 Bg4
Be2 Nf6
d4 c6
h3 Bh5
c4 Qa5
].each { |algebraic| board.make_move(algebraic:) }

# Caro, advanced, c5 line:
# %w[
# e4 c6
# d4 d5
# e5 c5
# dxc5 Nc6
# f4 e6
# Be3 Nh6
# c3 Nf5
# Bf2
# ].each { |algebraic| board.make_move(algebraic:) }
