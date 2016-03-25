Gem::Specification.new do |s|
  s.name        = 'grabble'
  s.version     = '0.0.1'
  s.date        = '2016-03-24'
  s.summary     = "A simple Ruby graph implementation"
  s.description = "-"
  s.authors     = ["Matt Clement"]
  s.email       = 'clement.matthewp@gmail.com'
  s.files       = ["lib/grabble.rb", "lib/grabble/cache.rb", "lib/grabble/vertex.rb", "lib/grabble/edge.rb"]
  s.license       = 'MIT'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'pry', '~> 0.10'
end
