require_relative '../app/move.rb'

describe Moves::Move do
  context 'init' do
    let(:algebraic) { 'e4' }
    let(:from_loc) { 'e2' }
    let(:to_loc) { 'e4' }
    let(:piece) { 'p' }
    
    it 'returns the right values' do
      move = Moves::Move.new(algebraic:, from_loc:, to_loc:, piece:) 
      expect(move.algebraic).to eq(algebraic)
      expect(move.from_loc).to eq(from_loc)
      expect(move.to_loc).to eq(to_loc)
      expect(move.piece).to eq(piece)
    end
  end
end
