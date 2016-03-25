require 'grabble/vertex.rb'
RSpec.describe Grabble::Vertex do
  describe '#data' do
    it 'retrieves stored data' do
      test_vertex = Grabble::Vertex.new("test")
      expect(test_vertex.data).to eq("test")
    end
  end
end
