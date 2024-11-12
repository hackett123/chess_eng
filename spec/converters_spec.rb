require_relative '../app/converters.rb'

describe Converters do

  context 'from index to algebraic' do
    let(:index) { 0 }
    subject { Converters.to_algebraic(index:) }

    context '0' do
      it 'maps to a1' do
        expect(subject).to eq('a1')
      end
    end

    context '1' do
      let(:index) { 1 }
      it 'maps to b1' do
        expect(subject).to eq('b1')
      end
    end

    context '8' do
      let(:index) { 8 }
      it 'maps to a2' do
        expect(subject).to eq('a2')
      end
    end

    context '63' do
      let(:index) { 63}
      it 'maps to h8' do
        expect(subject).to eq('h8')
      end
    end
  end

  context 'from algebraic to index' do
    let(:algebraic) { nil }
    subject { Converters.to_index(algebraic:) }

    context 'a1' do
      let(:algebraic) { 'a1' }
      it 'maps to 0' do
        expect(subject).to eq(0)
      end
    end

    context 'b1' do
      let(:algebraic) { 'b1' }
      it 'maps to 1' do
        expect(subject).to eq(1)
      end
    end

    context 'a2' do
      let(:algebraic) { 'a2' }
      it 'maps to 8' do
        expect(subject).to eq(8)
      end
    end

    context 'h8' do
      let(:algebraic) { 'h8' }
      it 'maps to 63' do
        expect(subject).to eq(63)
      end
    end
  end

  context "#to_rank" do
    subject { Converters.to_rank(algebraic:) }

    context "a1" do
      let(:algebraic) { 'a1' }
      it "returns first rank" do
        expect(subject).to eq(1)
      end
    end

    context "c4" do
      let(:algebraic) { 'c4' }
      it "returns fourth rank" do
        expect(subject).to eq(4)
      end
    end
  end

  context "#file_from_algebraic" do
    subject { Converters.to_file(algebraic:) }

    context "a1" do
      let(:algebraic) { 'a1' }
      it "returns first file" do
        expect(subject).to eq(1)
      end
    end

    context "c4" do
      let(:algebraic) { 'c4' }
      it "returns third file" do
        expect(subject).to eq(3)
      end
    end
  end

end
