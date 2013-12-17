# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "celes-web"
  spec.version       = '1.0.0'
  spec.authors       = ["Andy Schrage"]
  spec.email         = ["ajschrag@mtu.edu"]
  spec.description   = %q{A simple Ruby gem for providing a snipet of text and images based on a url.}
  spec.summary       = %q{A simple Ruby gem for providing a snipet of text and thumbnails based on a url.}
  spec.homepage      = "https://github.com/Swimminschrage/celes"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_dependency 'nokogiri'
end