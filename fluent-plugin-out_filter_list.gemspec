# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fluent/plugin/out_filter_list/version"

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-filter-list"
  spec.version       = Fluent::OutFilterList::VERSION
  spec.authors       = ["Shun Yanaura"]
  spec.email         = ["metroplexity@gmail.com"]

  spec.summary       = %q{A fluentd output plugin to filter keywords from messages}
  spec.description   = %q{A fluentd output plugin to filter keywords from messages}
  spec.homepage      = "https://github.com/yanana/fluent-plugin-filter-list"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "test-unit", "~> 3.2"
  spec.add_runtime_dependency "fluentd", "~> 0.12", ">= 0.12.0"
end
