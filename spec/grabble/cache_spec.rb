require 'grabble.rb'
RSpec.describe Grabble::Cache do

  describe '#add_vertex' do
    it 'automatically creates a new partition if needed' do
      test_cache = Grabble::Cache.new
      expect{test_cache.add_vertex("test")}.to change{test_cache.vertices.keys}.from([]).to(["4"])
    end
  end
end
