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

#  context '#from_algebraic' do
#    let(:algebraic) { nil }
#    let(:piece_locations) { nil }
#    let(:white_to_move) { true }
#    subject { Moves::Move.from_algebraic(algebraic:, piece_locations:, white_to_move:) }
#
#    context 'with only one piece left of that type' do
#      let(:piece_locations) {
#        {
#          b: ['c1']
#        }
#      }
#      let(:algebraic) { 'Bb2' }
#      it 'returns the only option' do
#        expect(subject).to eq('c1')
#      end
#    end
#
#    context 'with multiple possible pieces' do
#
#    end
#  end

  context 'private methods' do
    let(:algebraic) { nil }
    let(:white_to_move) { true }

    context '#is_pawn_move' do
      subject { Moves::Move.send(:is_pawn_move, algebraic:) }

      context 'when it is' do
        let(:algebraic) { 'd6' }
        it 'returns true' do
          expect(subject).to eq(true)
        end
      end

      context 'when it is not' do
        let(:algebraic) { 'Bxc7' }
        it 'returns false' do
          expect(subject).to eq(false)
        end
      end
    end

    context '#extract_piece_type' do
      subject { Moves::Move.send(:extract_piece_type, algebraic:, white_to_move:) }
      context 'king move' do
        let(:algebraic) { 'Ke2' }
        it 'returns white king' do
          expect(subject).to eq(:k)
        end

        context 'for black' do
          let(:white_to_move) { false }
          it 'returns black king' do
            expect(subject).to eq(:K)
          end
        end
      end

      context 'bishop move' do
        let(:algebraic) { 'Bb5' }
        it 'returns white bishop' do
          expect(subject).to eq(:b)
        end

        context 'for black' do
          let(:white_to_move) { false }
          it 'returns black bishop' do
            expect(subject).to eq(:B)
          end
        end
      end

      context 'pawn move' do
        let(:algebraic) { 'c6' }
        it 'returns white pawn' do
          expect(subject).to eq(:p)
        end
        context 'for black' do
          let(:white_to_move) { false }
          it 'returns black pawn' do
            expect(subject).to eq(:P)
          end
        end
      end

    end

    context '#extract_to_loc' do
      subject { Moves::Move.send(:extract_to_loc, algebraic:) }

      context 'for a pawn move' do
        let(:algebraic) { 'e6' }
        it 'returns the square' do
          expect(subject).to eq('e6')
        end

        context 'with promotion' do
          let(:algebraic) { 'd8=Q' }
          it 'returns the square' do
            expect(subject).to eq('d8')
          end
        end
      end

      context 'for a rook move' do
        let(:algebraic) { 'Ra4' }
        it 'returns the square' do
          expect(subject).to eq('a4')
        end
      end
    end
  end
end
