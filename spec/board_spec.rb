require_relative '../app/board'

describe Board do
  context 'initialize' do
    it 'creates an object' do
      board = Board.new
      expect(board.moves).to eq([])
      expect(board.board_string).to eq('rnbqkbnrpppppppp00000000000000000000000000000000PPPPPPPPRNBQKBNR')
    end
  end
end
