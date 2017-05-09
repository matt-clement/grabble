module Grabble
  class Edge
    def initialize(v1, v2)
      @vertex1 = v1
      @vertex2 = v2
    end

    def other(vertex)
      case vertex
      when @vertex1
        @vertex2
      when @vertex2
        @vertex1
      end
    end

    def vertices
      [@vertex1, @vertex2]
    end
  end
end
