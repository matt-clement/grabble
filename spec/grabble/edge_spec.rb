require 'grabble/edge.rb'
RSpec.describe Grabble::Edge do
  describe '#new' do
    it 'stores two items' do
      test_edge = Grabble::Edge.new(1,2)
      expect(test_edge.vertices).to match_array([1,2])
    end
  end

  describe '#other' do
    it 'returns the opposite item' do
      test_edge = Grabble::Edge.new(1,2)
      expect(test_edge.other(1)).to eq(2)
    end

    it 'returns nil if the item is not found' do
      test_edge = Grabble::Edge.new(1,2)
      expect(test_edge.other(0)).to be_nil
    end

  end
end
