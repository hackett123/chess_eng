require 'set'
require_relative '../app/move_generator'
require_relative '../app/board'

describe Moves::MoveGenerator do

  context "#legal_moves_for" do
    subject { Moves::MoveGenerator.legal_moves_for(piece_type:, piece_locations:) }
    context "it should derive if it's white to move, and then check the submodule's legal moves" do
      let(:piece_type) { :p }
      let(:piece_locations) { Board.new.piece_locations }
      it "has all the white pawn moves" do
        expect(subject).to eq({
          'a2' => ['a3', 'a4'],
          'b2' => ['b3', 'b4'],
          'c2' => ['c3', 'c4'],
          'd2' => ['d3', 'd4'],
          'e2' => ['e3', 'e4'],
          'f2' => ['f3', 'f4'],
          'g2' => ['g3', 'g4'],
          'h2' => ['h3', 'h4'],
        })
      end
    end
  end

  context "legal moves" do

    context "pawns" do
      subject { Moves::MoveGenerator::Pawn.legal_moves(piece_locations:, white_to_move:) }

      context "as white" do
        let(:white_to_move) { true }

        context "with no pawns left" do
          let(:piece_locations) { {} }
          it "returns an empty hash" do
            expect(subject).to eq({})
          end
        end

        context "starting square moves" do
          context "when there is nothing in the two squares ahead" do
            let(:piece_locations) {
              {
                p: ['e2']
              }
            }
            it 'has two options' do
              expect(subject).to eq({'e2' => ['e3', 'e4'] })
            end
          end

          context "and the square ahead is blocked" do
            let(:piece_locations) {
              {
                p: ['e2'],
                b: ['e3']
              }
            }
            it 'returns an empty arr' do
              expect(subject).to eq({'e2' => []})
            end
          end

          context "and the square two ahead is blocked" do
            let(:piece_locations) {
              {
                p: ['e2'],
                Q: ['e4']
              }
            }
            it 'returns just one move arr' do
              expect(subject).to eq({'e2' => ['e3']})
            end

          end
        end

        context "one pawn left" do
          context "when it is blockaded" do
            context "and there are no capturable pieces" do
              let(:piece_locations) {
                {
                  p: ['d5'],
                  P: ['d6']
                }
              }
              it 'returns an empty arr' do
                expect(subject).to eq({'d5' => []})
              end
            end

            context "and there are capturable pieces" do
              let(:piece_locations) {
                {
                  p: ['d5'],
                  Q: ['c6'],
                  N: ['d6'],
                  b: ['e6']
                }
              }
              it 'returns the capturable square' do
                expect(subject).to eq({'d5' => ['dxc6']})
              end
            end
          end
          
          context "when it isn't blockaded" do
            context "and there are no capturable pieces" do
              let(:piece_locations) {
                {
                  p: ['d5'],
                  P: ['d7']
                }
              }
              it 'returns the forward square' do
                expect(subject).to eq({'d5' => ['d6']})
              end
            end

            context "and there are capturable pieces" do
              let(:piece_locations) {
                {
                  p: ['d5'],
                  Q: ['c6'],
                  b: ['e6']
                }
              }
              it 'returns the capturable square and push square' do
                expect(subject).to eq({'d5' => ['d6', 'dxc6']})
              end

            end
          end
        end

        context 'edge cases (literally)' do
          context 'first file' do
            let(:piece_locations) {
              {
                p: ['a5'],
                P: ['h5', 'b6']
              }
            }
            it 'returns the capturable square and push square, but not the edge case square' do
              expect(subject).to eq({'a5' => ['a6', 'axb6']})
            end
          end
          context 'last file' do

          end
        end

      end

      context "as black" do
        let(:white_to_move) { false }

        context "starting square moves" do
          context "when there is nothing in the two squares ahead" do
            let(:piece_locations) {
              {
                P: ['h7']
              }
            }
            it 'has two options' do
              expect(subject).to eq({'h7' => ['h6', 'h5']})
            end
          end

          context "and the square ahead is blocked" do
            let(:piece_locations) {
              {
                P: ['f7'],
                N: ['f6']
              }
            }
            it 'returns an empty arr' do
              expect(subject).to eq({'f7' => []})
            end
          end

          context "and the square two ahead is blocked" do
            let(:piece_locations) {
              {
                P: ['e7'],
                q: ['e5']
              }
            }
            it 'returns just one move arr' do
              expect(subject).to eq({'e7' => ['e6']})
            end

          end
        end


        context "one pawn left" do
          context "when it is blockaded" do
            context "and there are no capturable pieces" do
              let(:piece_locations) {
                {
                  p: ['d5'],
                  P: ['d6']
                }
              }
              it 'returns an empty arr' do
                expect(subject).to eq({'d6' => []})
              end
            end

            context "and there are capturable pieces" do
              let(:piece_locations) {
                {
                  P: ['d5'],
                  q: ['c4'],
                  n: ['d4'],
                  B: ['e4']
                }
              }
              it 'returns the capturable square' do
                expect(subject).to eq({'d5' => ['dxc4']})
              end
            end
          end
          
          context "when it isn't blockaded" do
            context "and there are no capturable pieces" do
              let(:piece_locations) {
                {
                  p: ['c4'],
                  P: ['e6']
                }
              }
              it 'returns the forward square' do
                expect(subject).to eq({'e6' => ['e5']})
              end
            end

            context "and there are capturable pieces" do
              let(:piece_locations) {
                {
                  P: ['d6'],
                  q: ['e5'],
                  B: ['e6']
                }
              }
              it 'returns the capturable square and push square' do
                expect(subject).to eq({'d6' => ['d5', 'dxe5']})
              end

            end
          end
        end
      end
    end
    context "rook moves" do
      subject { Moves::MoveGenerator::Rook.legal_moves(piece_locations:, white_to_move:) }
      let(:white_to_move) { true }
      context "nothing in the way" do
        let(:piece_locations) {
          {
            r: ['f5']
          }
        }
        it "returns all squares possible" do
          expect(subject['f5'].to_set).to eq(%w[f6 f7 f8 f4 f3 f2 f1 g5 h5 e5 d5 c5 b5 a5].to_set)
        end
      end
      context "with pieces in vision" do
        let(:piece_locations) {
          {
            r: ['f5', 'h2'],
            Q: ['h5'], # note this will pass now, but is actually going to be a case where when we implement non-unique algebraic notation will matter
            b: ['f1']
          }
        }
        it "returns all squares possible" do
          expect(subject['f5'].to_set).to eq(%w[f6 f7 f8 f4 f3 f2 g5 Rxh5 e5 d5 c5 b5 a5].to_set)
          expect(subject['h2'].to_set).to eq(%w[h1 h3 h4 Rxh5 g2 f2 e2 d2 c2 b2 a2].to_set)
        end
      end
    end

    context "knight moves" do
      subject { Moves::MoveGenerator::Knight.legal_moves(piece_locations:, white_to_move:) }
      context "8 empty surrounding squares on board" do
        let(:white_to_move) { true }
        let(:piece_locations) {
          {
            n: ['d5']
          }
        }
        it "returns all 8 squares (octoknight)" do
          expect(subject['d5'].to_set).to eq(%w[Nc7 Ne7 Nb6 Nf6 Nc3 Ne3 Nb4 Nf4].to_set)
        end
      end
      context "8 squares available, some occupied" do
        let(:white_to_move) { true }
        let(:piece_locations) {
          {
            n: ['e5'],
            P: ['d7', 'f7'],
            b: ['c4'],
            q: ['f3']
          }
        }
        it "returns all eligible squares for our octoknight" do
          expect(subject['e5'].to_set).to eq(%w[Nxd7 Nxf7 Nc6 Ng6 Nd3 Ng4].to_set)
        end
      end
      context "not all squares are all board" do
        let(:white_to_move) { false }
        let(:piece_locations) {
          {
            N: ['h6']
          }
        }
        it "returns the valid squares" do
          expect(subject['h6'].to_set).to eq(%w[Ng8 Nf7 Nf5 Ng4].to_set)
        end
      end
    end

    context "bishop moves" do

    end

    context "queen moves" do

    end

    context "king moves" do

    end
  end
end
