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
      board.make_move(move: Moves::Move.new(algebraic: "Nf6", from_loc: "g8", to_loc: "f6", piece: "N"))
      board.make_move(move: Moves::Move.new(algebraic: "e5", from_loc: "e4", to_loc: "e5", piece: "p"))
      board.make_move(move: Moves::Move.new(algebraic: "Nd5", from_loc: "f6", to_loc: "d5", piece: "N"))
      board.make_move(move: Moves::Move.new(algebraic: "d4", from_loc: "d2", to_loc: "d4", piece: "p"))
      board.make_move(move: Moves::Move.new(algebraic: "cxd4", from_loc: "c5", to_loc: "d4", piece: "P"))
    end

    it "is white's move" do
      subject
      expect(board.white_to_move).to eq(true)
    end

    it "has everything in the right place" do
      subject
      expected_board = <<-BOARD
R - B Q K B - R
P P - P P P P P
- - N - - - - -
- - - N p - - -
- - - P - - - -
- - p - - n - -
p p - - - p p p
r n b q k b - r
BOARD
      expect(board.show).to eq(expected_board.strip)
    end

    it "stored the correct moves" do
      subject
      expect(board.moves).to eq(%w[e4 c5 Nf3 Nc6 c3 Nf6 e5 Nd5 d4 cxd4])
    end
  end
end
