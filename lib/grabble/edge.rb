module Grabble
  class Edge
    def initialize(v1, v2)
      @vertex1 = v1
      @vertex2 = v2
    end

    def other(vertex)
      return nil unless vertices.find_index(vertex)
      vertices.reject{|v| v == vertex}.first
    end

    def vertices
      [@vertex1, @vertex2]
    end
  end
end
