module Grabble
  class Edge
    def initialize(v1, v2)
      @vertex1 = v1
      @vertex2 = v2
    end

    def other(vertex)
      vtx = vertices.find(vertex)
      return nil unless vtx
      vertices.reject{|v| v == vertex}.first
    end

    def vertices
      [@vertex1, @vertex2]
    end
  end
end
