require_relative '../app/board'

describe Board do
  context 'initialize' do
    it 'creates an object' do
      board = Board.new
      expect(board.moves).to eq([])
      expect(board.board_string).to eq('rnbqkbnrpppppppp00000000000000000000000000000000PPPPPPPPRNBQKBNR')
    end
  end

  context 'board state after a few moves in a delayed Alapin' do
    let(:board) { Board.new }
    subject do
      %w[
        e4 c5
        Nf3 Nc6
        c3 Nf6
        e5 Nd5
        d4 cxd4
      ].each { |move| board.make_move(algebraic: move) }
    end

    it "is white's move" do
      subject
      expect(board.white_to_move).to eq(true)
    end

    it "has everything in the right place" do
      subject
      expected_board = <<-BOARD
♖️ - ♗️ ♕️ ♔️ ♗️ - ♖️
♙️ ♙️ - ♙️ ♙️ ♙️ ♙️ ♙️
- - ♘️ - - - - -
- - - ♘️ ♟ - - -
- - - ♙️ - - - -
- - ♟ - - ♞️ - -
♟ ♟ - - - ♟ ♟ ♟
♜ ♞️ ♝️ ♛️ ♚️ ♝️ - ♜
BOARD
      expect(board.show).to eq(expected_board.strip)
    end

    it "stored the correct moves" do
      subject
      expect(board.moves).to eq(%w[e4 c5 Nf3 Nc6 c3 Nf6 e5 Nd5 d4 cxd4])
    end
  end
end
