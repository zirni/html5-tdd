# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'html5/tdd/version'

Gem::Specification.new do |spec|
  spec.name          = "html5-tdd"
  spec.version       = Html5::Tdd::VERSION
  spec.authors       = ["Matthias Zirnstein"]
  spec.email         = ["matthias.zirnstein@googlemail.com"]
  spec.description   = %q{A HTML 5 validtor to fit your TDD process}
  spec.summary       = %q{HTML 5 validator}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "curb", "0.8.4"
  spec.add_runtime_dependency "nokogiri", "1.5.8"
  spec.add_runtime_dependency "equalizer", "0.0.5"
end
