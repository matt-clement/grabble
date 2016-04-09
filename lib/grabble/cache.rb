module Grabble
  class Cache

    def options
      @options ||= {
        data_filters: [lambda {|x| x.match(/^[a-zA-Z]+$/)}],
        partitions: [lambda {|x| x.length}]
      }
    end

    def vertices
      @vertices ||= Hash.new {|hash, key| p "Creating new partition: #{key} | #{key.class}"; hash[key] = Array.new}
    end

    def total_vertices
      count = 0
      vertices.each_value{|va| count += va.size}
      count
    end

    def edges
      @edges ||= []
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
      options[:partitions].map{ |f|
        f.call(data)
      }.join('')
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
        selected_vertices.map{ |vert|
          adjacent_vertices(vertex).each {|adj| new_vertices.add(adj)}
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
      edges.select{|e| e.vertices.include? vertex}
    end

    def adjacent_vertices(vertex)
      vertex = find_vertex(vertex) unless vertex.is_a? Grabble::Vertex
      relevant_edges(vertex).map{|e| e.other(vertex)}
    end

    def add_vertex(obj)
      find_or_create_vertex(obj)
    end

    def delete_vertex(obj)
      ev = find_vertex(obj)
      return nil unless ev
      edges.reject!{|e| e.vertices.include?(ev)}
      partition(ev).delete(ev)
    end

    def find_vertex(obj)
      if obj.is_a? Grabble::Vertex
        partition(obj).include? obj
        obj
      else
        vertices[partition_key(obj)].find{|x| x.data == obj}
      end
    end

    def sort_vertices(part)
      vertices[part].sort!{|v1, v2| v1.data <=> v2.data}
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

      filter_values.reduce(true){|acc, val| acc && val} ? data : nil
    end


    def find_or_create_vertex(obj)
      ev = find_vertex(obj)
      if ev
        vertex = ev
      else
        data = filter_vertex_data(obj)
        return nil unless data
        part = partition_key(data)
        vertex = Vertex.new(data)
        vertices[part] << vertex
        create_edges(vertex)
        sort_vertices(part)
      end
      vertex
    end

    def add_edge(v1, v2)
      find_or_create_edge(v1, v2)
    end

    def likeness(str1, str2)
      chars = str1.chars
      counter = 0
      str2.chars.each.with_index do |ch, index|
        counter+=1 if chars[index] == ch
      end
      counter
    end

    def create_edges(vertex)
      str1 = vertex.data
      similar = partition(vertex).select do |v|
        str2 = v.data
        str1.length == str2.length &&
          likeness(str1, str2) == vertex.data.length - 1
      end
      similar.each do |v|
        add_edge(v, vertex)
      end
    end

    def find_or_create_edge(a, b)
      v1 = find_or_create_vertex(a)
      v2 = find_or_create_vertex(b)
      ee = edges.
        select{|e| e.vertices.include? v1}.
        find{|e| e.vertices.include? v2}
      if ee
        edge = ee
      else
        edge = Edge.new(v1, v2)
        puts "Created edge: #{v1.data} | #{v2.data}"
        edges << edge
      end
      edge
    end
  end
end
