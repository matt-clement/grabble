module Grabble; end

lib_directory = File.dirname(File.expand_path(__FILE__))
Dir[File.join(lib_directory, 'grabble', '*.rb')].each { |f| require f }
