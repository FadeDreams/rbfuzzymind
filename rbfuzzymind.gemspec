# rbfuzzymind.gemspec
Gem::Specification.new do |spec|
  spec.name          = 'rbfuzzymind'
  spec.version       = '0.1.0'
  spec.authors       = ["fadedreams7"]
  spec.email         = ["fadedreams7@gmail.com"]
  spec.summary       = %q{A Ruby gem for fuzzy logic systems and inference engines.}
  spec.description   = %q{rbfuzzymind is a Ruby gem that provides a comprehensive suite for implementing fuzzy logic systems. It includes classes for fuzzy sets, fuzzy rules, and inference engines, enabling the development of complex decision-making systems based on fuzzy logic principles. Key features include membership function operations (union, intersection, complement, normalization), rule evaluation, and defuzzification methods (centroid, mean of maxima, and bisector). Designed for flexibility and extensibility, rbfuzzymind helps developers build robust and adaptable systems for handling uncertainty and imprecision in various applications.}
  spec.homepage      = "https://github.com/fadedreams/rbfuzzymind"
  spec.license       = "MIT"
  
  # Add this line to specify the minimum Ruby version
  spec.required_ruby_version = '>= 2.6.0'

  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'rake', '~> 13.0'
end

