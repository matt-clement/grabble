require 'grabble.rb'
RSpec.describe Grabble::Cache do

  describe '#add_vertex' do
    it 'creates a new partition if needed' do
      test_cache = Grabble::Cache.new
      expect{test_cache.add_vertex("test")}.to change{test_cache.vertices.keys}.from([]).to(["4"])
    end

    it 'creates new edges if needed' do
      test_cache = Grabble::Cache.new
      test_cache.add_vertex("test")
      expect { test_cache.add_vertex("lest") }.to change{test_cache.total_edges}.by 1
    end

  end
end
