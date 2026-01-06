require_relative "lib/edward"

Gem::Specification.new do |s|
  s.name        = "mr-edward"
  s.version     = Edward::VERSION
  s.summary     = "Statis site generator"
  s.authors     = ["Rein Fernhout"]
  s.homepage    = "https://github.com/LevitatingBusinessMan/edward"
  s.license     = "MIT"
  s.files       = Dir["lib/*"]
  s.executables << "edward"
  s.add_runtime_dependency("tilt", ["~> 2.6"])
  s.add_runtime_dependency("webrick", ["~> 1.9"])
  s.add_runtime_dependency("listen", ["~> 3.9"])
  s.add_runtime_dependency("deep_merge", ["~> 1.2"])
end
