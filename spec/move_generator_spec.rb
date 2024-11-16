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

  context "#generate_legal_moves_for_*" do
    context "from a starting position" do
      let(:piece_locations) { Board.new.piece_locations }
      context "for white" do
        subject { Moves::MoveGenerator.generate_white_legal_moves(piece_locations:) }
        it "returns a hash of all the legal first moves for white" do
          expect(subject).to eq({
            "a2"=>["a3", "a4"],
            "b2"=>["b3", "b4"],
            "c2"=>["c3", "c4"],
            "d2"=>["d3", "d4"],
            "e2"=>["e3", "e4"],
            "f2"=>["f3", "f4"],
            "g2"=>["g3", "g4"],
            "h2"=>["h3", "h4"],
            "a1"=>[],
            "h1"=>[],
            "b1"=>["Nc3", "Na3"],
            "g1"=>["Nh3", "Nf3"],
            "c1"=>[],
            "f1"=>[],
            "d1"=>[],
            "e1"=>[]}
          )
        end
      end

      context "for black" do
        subject { Moves::MoveGenerator.generate_black_legal_moves(piece_locations:) }
        it "returns a hash of all the legal first moves for black" do
          expect(subject).to eq({
            "a7"=>["a6", "a5"],
            "b7"=>["b6", "b5"],
            "c7"=>["c6", "c5"],
            "d7"=>["d6", "d5"],
            "e7"=>["e6", "e5"],
            "f7"=>["f6", "f5"],
            "g7"=>["g6", "g5"],
            "h7"=>["h6", "h5"],
            "a8"=>[],
            "h8"=>[],
            "b8"=>["Nc6", "Na6"],
            "g8"=>["Nh6", "Nf6"],
            "c8"=>[],
            "f8"=>[],
            "d8"=>[],
            "e8"=>[]}
)
        end
      end

    end
  end

  context "legal moves - per piece" do

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
          expect(subject['f5'].to_set).to eq(%w[Rf6 Rf7 Rf8 Rf4 Rf3 Rf2 Rf1 Rg5 Rh5 Re5 Rd5 Rc5 Rb5 Ra5].to_set)
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
          expect(subject['f5'].to_set).to eq(%w[Rf6 Rf7 Rf8 Rf4 Rf3 Rf2 Rg5 Rxh5 Re5 Rd5 Rc5 Rb5 Ra5].to_set)
          expect(subject['h2'].to_set).to eq(%w[Rh1 Rh3 Rh4 Rxh5 Rg2 Rf2 Re2 Rd2 Rc2 Rb2 Ra2].to_set)
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
      subject { Moves::MoveGenerator::Bishop.legal_moves(piece_locations:, white_to_move:) }
      let(:white_to_move) { true }
      context "clear board" do
        let(:piece_locations) {
          {
            b: ['d5']
          }
        }
        it 'returns all visible squares' do
          expect(subject['d5'].to_set).to eq(%w[Be6 Bf7 Bg8 Bc6 Bb7 Ba8 Be4 Bf3 Bg2 Bh1 Bc4 Bb3 Ba2].to_set)
        end
      end
      context "with pieces" do
        let(:piece_locations) {
          {
            b: ['d6'],
            P: ['e7'],
            N: ['f8', 'c7'],
            p: ['c5']
          }
        }
        it 'returns all viable squares' do
          expect(subject['d6'].to_set).to eq(%w[Bxe7 Bxc7 Be5 Bf4 Bg3 Bh2].to_set)
        end
      end
    end

    context "queen moves" do
      subject { Moves::MoveGenerator::Queen.legal_moves(piece_locations:, white_to_move:) }
      let(:white_to_move) { true }
      context "clear board" do
        let(:piece_locations) {
          {
            q: ['d5']
          }
        }
        it 'returns all visible squares' do
          expect(subject['d5'].to_set).to eq(%w[Qd6 Qd7 Qd8 Qd4 Qd3 Qd2 Qd1 Qe5 Qf5 Qg5 Qh5 Qc5 Qb5 Qa5 Qe6 Qf7 Qg8 Qe4 Qf3 Qg2 Qh1 Qc6 Qb7 Qa8 Qc4 Qb3 Qa2].to_set)
        end
      end
      context "with pieces" do
        let(:piece_locations) {
          {
            q: ['d6'],
            Q: ['d4'],
            b: ['g3'],
            P: ['e7'],
            N: ['f8', 'c7'],
            p: ['c5'],
            n: ['c6', 'g6']
          }
        }
        it 'returns all viable squares' do
          expect(subject['d6'].to_set).to eq(%w[Qxc7 Qd7 Qd8 Qxe7 Qe6 Qf6 Qe5 Qf4 Qd5 Qxd4].to_set)
        end
      end

    end

    context "king moves" do
      subject { Moves::MoveGenerator::King.legal_moves(piece_locations:, white_to_move:) }
      let(:white_to_move) { true }
      context "clear board" do
        let(:piece_locations) {
          {
            k: ['d5']
          }
        }

        it 'returns the 8 surrounding squares' do
          expect(subject['d5'].to_set).to eq(%w[Kd4 Kd6 Ke4 Ke5 Ke6 Kc4 Kc5 Kc6].to_set)
        end
      end
      context "clear, edge of board" do
        let(:piece_locations) {
          {
            k: ['e1']
          }
        }

        it 'returns the valid surrounding squares' do
          expect(subject['e1'].to_set).to eq(%w[Kd1 Kf1 Kd2 Ke2 Kf2].to_set)
        end
      end
      context "with pieces adjacent" do
        let(:piece_locations) {
          {
            k: ['g1'],
            p: ['h2', 'g2'],
            B: ['f2'],
            r: ['f1']
          }
        }

        it 'returns the valid surrounding squares' do
          expect(subject['g1'].to_set).to eq(%w[Kxf2 Kh1].to_set)
        end
      end
    end
  end
end
