require_relative '../app/board_facts'

describe BoardFacts do

  context "#piece_present" do
    subject { BoardFacts.piece_present(piece_locations:, square:) }
    let(:piece_locations) {
      {
        K: ['g8']
      }
    }
    context "when there isn't" do
      let(:square) { 'g7' }
      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
    context "when there is" do
      let(:square) { 'g8' }
      it 'returns true' do
        expect(subject).to eq(true)
      end
    end
  end

  context "#opponent_piece_at_square" do

  end

  context "#different_rank" do
    subject { BoardFacts.different_rank(square_one:, square_two:) }

    context "two pieces on different ranks" do
      let(:square_one) { 'h6' }
      let(:square_two) { 'b2' }
      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "two pieces on the same rank" do
      let(:square_one) { 'f6' }
      let(:square_two) { 'c6' }
      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end

end
