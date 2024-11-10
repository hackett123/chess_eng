require_relative '../app/fen_reader'

describe FenReader do

  let(:fen_string) { nil }
  let(:fresh_board) { Board.new }
  subject { FenReader.read_from_str(fen_string) }

  context 'for a starting board' do
    let(:fen_string) { 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1' }
    it 'is identical to a fresh board instance' do
      board = subject
      expect(fresh_board.board_string).to eq(board.board_string) 
      expect(fresh_board.piece_locations).to eq(board.piece_locations) 
    end
  end

  context 'after 1. e4 c5 2. Nf3' do
    let(:fen_string) { 'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2'}
    it 'has the right piece positions' do
      board = subject
      positions = board.piece_locations
      expect(positions[:n]).to eq(['b1', 'f3'])
    end

    it 'is black to move' do
      board = subject 
      expect(board.white_to_move).to eq(false)
    end
  end

end
