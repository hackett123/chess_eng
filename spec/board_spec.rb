require_relative '../app/board'

describe Board do
  context 'initialize' do
    it 'creates an object' do
      board = Board.new
      expect(board.moves).to eq([])
      expect(board.board_string).to eq('rnbqkbnrpppppppp00000000000000000000000000000000PPPPPPPPRNBQKBNR')
    end
  end

  context 'board state after a few moves' do
    let(:board) { Board.new }
    subject do
      board.make_move(move: Moves::Move.new(algebraic: "e4", from_loc: "e2", to_loc: "e4", piece: "p"))
      board.make_move(move: Moves::Move.new(algebraic: "c5", from_loc: "c7", to_loc: "c5", piece: "P"))
      board.make_move(move: Moves::Move.new(algebraic: "Nf3", from_loc: "g1", to_loc: "f3", piece: "n"))
      board.make_move(move: Moves::Move.new(algebraic: "Nc6", from_loc: "b8", to_loc: "c6", piece: "N"))
      board.make_move(move: Moves::Move.new(algebraic: "c3", from_loc: "c2", to_loc: "c3", piece: "p"))
    end

    it "is black's move" do
      subject
      expect(board.white_to_move).to eq(false)
    end

    it "has everything in the right place" do
      subject
      expected_board = <<-BOARD
R - B Q K B N R
P P - P P P P P
- - N - - - - -
- - P - - - - -
- - - - p - - -
- - p - - n - -
p p - p - p p p
r n b q k b - r
BOARD
      expect(board.show).to eq(expected_board.strip)
    end
  end
end
