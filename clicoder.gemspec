# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clicoder/version'

Gem::Specification.new do |spec|
  spec.name          = "clicoder"
  spec.version       = Clicoder::VERSION
  spec.authors       = ["Genki Sugimoto"]
  spec.email         = ["cfhoyuk.reccos.nelg@gmail.com"]
  spec.description   = %q{Make it easy to deal with online programming contests from the command line}
  spec.summary       = %q{CLI interface to online programming contests}
  spec.homepage      = "https://github.com/Genki-S/clicoder"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.6.2.1"
  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_dependency "abstract_method", "~> 1.2.1"
  spec.add_dependency "launchy", "~> 2.4.2"
  spec.add_dependency "reverse_markdown", "~> 0.4.7"
  spec.add_dependency "mechanize", "~> 2.7.3"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "pry"
end
