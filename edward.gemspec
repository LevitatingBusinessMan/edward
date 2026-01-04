Gem::Specification.new do |s|
  s.name        = "edward"
  s.version     = "0.0.0"
  s.summary     = "Statis site generator"
  s.authors     = ["Rein Fernhout"]
  s.files       = ["lib/edward.rb", "lib/builder.rb"]
  s.license     = "MIT"
  s.executables << "edward"
  s.add_runtime_dependency("tilt", ["~> 2.6"])
  s.add_runtime_dependency("webrick", ["~> 1.9"])
  s.add_runtime_dependency("listen", ["~> 3.9"])
end
