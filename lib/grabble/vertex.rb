module Grabble
  class Vertex
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def ==(other)
      @data == other.data
    end

    def hash
      @data.hash
    end
  end
end
