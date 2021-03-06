require 'set'
module Grabble
  class Cache
    def options
      @options ||= {
        data_filters: [->(x) { x.match(/^[a-zA-Z]+$/) }],
        partitions: [->(x) { x.length }]
      }
    end

    def vertices
      @vertices ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def total_vertices
      vertices.values.reduce(0, :+)
    end

    def edges
      @edges ||= Hash.new { |hash, key| hash[key] = Set.new }
    end

    def total_edges
      edges.values.uniq.count
    end

    def clear
      @vertices = nil
      @edges = nil
      @options = nil
    end

    def clear_options
      @options = nil
    end

    def partition_key(vertex)
      data = if vertex.is_a? Grabble::Vertex
               vertex.data
             else
               vertex
             end
      options[:partitions].map { |f| f.call(data) }.join
    end

    def partition(vertex)
      vertices[partition_key(vertex)]
    end

    def random(pkey, opts = {})
      selected_vertices = Set.new
      vertex = vertices[pkey].sample
      selected_vertices.add(vertex)
      loop do
        new_vertices = selected_vertices.dup
        init_count = selected_vertices.count
        selected_vertices.map { |vert|
          adjacent_vertices(vertex).each { |adj| new_vertices.add(adj) }
        }
        selected_vertices = new_vertices
        break if init_count == new_vertices.count
      end
      if opts[:max_items]
        selected_vertices.to_a.sample(opts[:max_items].to_i).map(&:data)
      else
        selected_vertices.map(&:data)
      end
    end

    def relevant_edges(vertex)
      vertex = find_vertex(vertex) unless vertex.is_a? Grabble::Vertex
      edges[vertex].select { |e| e.vertices.include? vertex }
    end

    def adjacent_vertices(vertex)
      vertex = find_vertex(vertex) unless vertex.is_a? Grabble::Vertex
      relevant_edges(vertex).map { |e| e.other(vertex) }
    end

    def add_vertex(obj)
      find_or_create_vertex(obj)
    end

    def delete_vertex(obj)
      ev = find_vertex(obj)
      return nil unless ev
      edges.reject! { |e| e.vertices.include?(ev) }
      partition(ev).delete(ev)
    end

    def find_vertex(obj)
      if obj.is_a? Grabble::Vertex
        obj if partition(obj).include? obj
      else
        vertices[partition_key(obj)].find { |x| x.data == obj }
      end
    end

    def sort_vertices(part)
      # TODO: Since we call this method every time we insert, it might be nice
      # to use a sorted data structure that takes care of this automatically.
      vertices[part].sort_by!(&:data)
    end

    def filter_vertex_data(obj)
      data = obj.downcase
      filter_values = if options[:data_filters]
                        options[:data_filters].map do |f|
                          f.call(data)
                        end
                      else
                        [true]
                      end

      filter_values.reduce(true) { |acc, val| acc && val } ? data : nil
    end

    def find_or_create_vertex(obj)
      ev = find_vertex(obj)
      if ev
        vertex = ev
      else
        if obj.is_a? Grabble::Vertex
          vertex = obj
          partition(vertex) << vertex
        else
          data = filter_vertex_data(obj)
          return nil unless data
          part = partition_key(data)
          vertex = Vertex.new(data)
          vertices[part] << vertex
        end
        create_edges(vertex)
        sort_vertices(part)
      end
      vertex
    end

    def likeness(str1, str2)
      str1.chars.zip(str2.chars).count { |a, b| a == b }
    end

    def create_edges(vertex)
      str1 = vertex.data
      similar = partition(vertex).select do |v|
        str2 = v.data
        str1.length == str2.length &&
          likeness(str1, str2) == vertex.data.length - 1
      end
      similar.each do |v|
        find_or_create_edge(v, vertex)
      end
    end

    def create_edge(v1, v2)
      edge = Edge.new(v1, v2)
      edges[v1] << edge
      edges[v2] << edge
      edge
    end

    def find_or_create_edge(a, b)
      v1 = find_or_create_vertex(a)
      v2 = find_or_create_vertex(b)
      e1 = edges[v1].find { |e| e.vertices.include? v2 }
      e2 = edges[v2].find { |e| e.vertices.include? v1 }

      e1 && e2 ? e1 : create_edge(v1, v2)
    end
  end
end
