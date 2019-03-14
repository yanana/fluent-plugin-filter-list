lib = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent/plugin/out_filter_list/version'

Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-filter-list'
  spec.version       = Fluent::Plugin::FilterList::VERSION
  spec.authors       = ['Shun Yanaura']
  spec.email         = ['metroplexity@gmail.com']

  spec.summary       = 'A fluentd output plugin to filter keywords from messages'
  spec.description   = 'A fluentd output plugin to filter keywords from messages'
  spec.homepage      = 'https://github.com/yanana/fluent-plugin-filter-list'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0.1'
  # spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'test-unit', '~> 3.2'
  spec.add_runtime_dependency 'ffi'
  spec.add_runtime_dependency 'fluentd', '>= 0.14.0', '< 2.0.0'
end
